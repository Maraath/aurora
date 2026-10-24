import 'package:drift/drift.dart';

import '../core/recorrencia.dart';
import '../core/relogio.dart';
import 'banco.dart';
import 'observar.dart';

class QuadroHabitos {
  const QuadroHabitos({
    required this.habitos,
    required this.feitos,
    required this.metas,
    required this.comAviso,
  });

  final List<Habito> habitos;

  /// "aaaa-mm-dd" → ids dos hábitos feitos naquele dia.
  final Map<String, Set<String>> feitos;
  final List<Meta> metas;

  /// Ids dos hábitos com lembrete ligado.
  final Set<String> comAviso;

  bool feito(String habitoId, DateTime dia) => feitos[chaveData(dia)]?.contains(habitoId) ?? false;

  /// Hábitos previstos para o dia (pela regra de dias da semana e pela data de criação).
  List<Habito> doDia(DateTime dia) => habitos
      .where((h) => h.diasSemana & bitDoDiaDaSemana(dia) != 0 && !dia.isBefore(dataLocal(h.criadoEm)))
      .toList();

  /// Fração feita no dia (0 a 1), ou nulo se não havia hábito previsto.
  double? progresso(DateTime dia) {
    final previstos = doDia(dia);
    if (previstos.isEmpty) return null;
    return previstos.where((h) => feito(h.id, dia)).length / previstos.length;
  }

  /// Dias seguidos (até hoje, ou até ontem se hoje ainda está pendente) em que
  /// o hábito foi feito nos dias previstos.
  int sequencia(Habito h, DateTime hoje) {
    var n = 0;
    var d = feito(h.id, hoje) ? hoje : hoje.subtract(const Duration(days: 1));
    final inicio = dataLocal(h.criadoEm);
    for (var i = 0; i < 366 && !d.isBefore(inicio); i++) {
      if (h.diasSemana & bitDoDiaDaSemana(d) != 0) {
        if (!feito(h.id, d)) break;
        n++;
      }
      d = DateTime(d.year, d.month, d.day - 1);
    }
    return n;
  }
}

class HabitosRepo {
  HabitosRepo(this.db);
  final BancoAurora db;

  Stream<QuadroHabitos> observarQuadro() =>
      observar(db, [db.habitos, db.registrosHabito, db.metas, db.lembretes], carregar);

  Future<QuadroHabitos> carregar() async {
    final habitos = await (db.select(db.habitos)
          ..where((h) => h.apagadoEm.isNull())
          ..orderBy([(h) => OrderingTerm(expression: h.horario), (h) => OrderingTerm(expression: h.criadoEm)]))
        .get();
    // Últimos ~13 meses bastam para semana, calendário e sequência.
    final hoje = hojeLocal();
    final desde = chaveData(DateTime(hoje.year - 1, hoje.month - 1, 1));
    final registros = await (db.select(db.registrosHabito)
          ..where((r) => r.feito & r.apagadoEm.isNull() & r.dia.isBiggerOrEqualValue(desde)))
        .get();
    final feitos = <String, Set<String>>{};
    for (final r in registros) {
      feitos.putIfAbsent(r.dia, () => {}).add(r.habitoId);
    }
    final metas = await (db.select(db.metas)..where((m) => m.apagadoEm.isNull())).get();
    final avisos = await (db.select(db.lembretes)
          ..where((l) => l.itemTipo.equals('habito') & l.apagadoEm.isNull()))
        .get();
    return QuadroHabitos(
      habitos: habitos,
      feitos: feitos,
      metas: metas,
      comAviso: {for (final l in avisos) l.itemId!},
    );
  }

  /// Marca ou desmarca o hábito no dia (um registro por hábito e dia).
  Future<void> alternar(String habitoId, DateTime dia, bool feito) {
    return db.into(db.registrosHabito).insert(
          RegistrosHabitoCompanion.insert(
              id: Value(idNatural('registro_habito', [habitoId, chaveData(dia)])),
              habitoId: habitoId,
              dia: chaveData(dia),
              feito: Value(feito)),
          onConflict: DoUpdate(
            (_) => RegistrosHabitoCompanion(
                feito: Value(feito), atualizadoEm: Value(DateTime.now())),
            target: [db.registrosHabito.habitoId, db.registrosHabito.dia],
          ),
        );
  }

  /// Cria ou atualiza o hábito. Com [avisar], mantém um lembrete recorrente
  /// nos dias escolhidos, no horário do hábito (08:00 se não tiver).
  Future<void> salvar(HabitosCompanion dados, {String? id, required bool avisar}) {
    return db.transaction(() async {
      final agora = DateTime.now();
      late final String habitoId;
      if (id == null) {
        habitoId = (await db.into(db.habitos).insertReturning(dados)).id;
      } else {
        habitoId = id;
        await (db.update(db.habitos)..where((h) => h.id.equals(id)))
            .write(dados.copyWith(atualizadoEm: Value(agora)));
      }
      await _apagarLembretesDe(habitoId, agora);
      if (avisar) {
        final dias = dados.diasSemana.present ? dados.diasSemana.value : todosOsDias;
        final horario = dados.horario.present ? dados.horario.value : null;
        final partes = (horario ?? '08:00').split(':');
        final regra = Regra.semanal(dias);
        final hoje = hojeLocal();
        final primeiro = regra.proxima(hoje, hoje) ?? hoje;
        await db.into(db.lembretes).insert(LembretesCompanion.insert(
              texto: dados.nome.value,
              quando: instanteLocal(primeiro, int.parse(partes[0]), int.parse(partes[1])),
              regraRepeticao: Value(regra.rrule),
              itemTipo: const Value('habito'),
              itemId: Value(habitoId),
            ));
      }
    });
  }

  Future<void> excluir(String id) => db.transaction(() async {
        final agora = DateTime.now();
        await (db.update(db.habitos)..where((h) => h.id.equals(id)))
            .write(HabitosCompanion(apagadoEm: Value(agora), atualizadoEm: Value(agora)));
        await _apagarLembretesDe(id, agora);
      });

  Future<void> _apagarLembretesDe(String habitoId, DateTime agora) =>
      (db.update(db.lembretes)
            ..where((l) =>
                l.itemTipo.equals('habito') & l.itemId.equals(habitoId) & l.apagadoEm.isNull()))
          .write(LembretesCompanion(apagadoEm: Value(agora), atualizadoEm: Value(agora)));
}
