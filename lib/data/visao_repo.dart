import 'package:drift/drift.dart';

import '../core/relogio.dart';
import 'banco.dart';

class HabitoDoDia {
  const HabitoDoDia({required this.habito, required this.feito});
  final Habito habito;
  final bool feito;
}

class ItemFoco {
  const ItemFoco(this.titulo, this.detalhe);
  final String titulo;
  final String detalhe;
}

class ResumoVisao {
  const ResumoVisao({
    required this.nome,
    required this.habitos,
    required this.tarefasHoje,
    required this.tarefasAtrasadas,
    required this.tarefasAbertas,
    required this.aPagarCentavos,
    required this.contasAPagar,
    required this.meta,
  });

  final String nome;
  final List<HabitoDoDia> habitos;
  final List<Tarefa> tarefasHoje;
  final int tarefasAtrasadas;
  final int tarefasAbertas;
  final int aPagarCentavos;
  final int contasAPagar;
  final Meta? meta;

  int get habitosFeitos => habitos.where((h) => h.feito).length;
}

/// Bit do dia da semana em `Habitos.diasSemana` (segunda = 1 ... domingo = 64).
int bitDoDia(DateTime d) => 1 << (d.weekday - 1);

/// Tarefa atrasada: com hora, passou do horário; sem hora, passou do dia.
bool tarefaAtrasada(Tarefa t, DateTime agora) {
  if (t.feitaEm != null || t.prazo == null) return false;
  if (t.prazoTemHora) return t.prazo!.isBefore(agora);
  return inicioDoDia(t.prazo!).isBefore(inicioDoDia(agora));
}

class VisaoRepo {
  VisaoRepo(this.db);
  final BancoAurora db;

  Stream<ResumoVisao> observar() async* {
    yield await carregar();
    final mudancas = db.tableUpdates(TableUpdateQuery.onAllTables([
      db.habitos,
      db.registrosHabito,
      db.tarefas,
      db.transacoes,
      db.metas,
    ]));
    await for (final _ in mudancas) {
      yield await carregar();
    }
  }

  Future<ResumoVisao> carregar() async {
    final agora = agoraSP();
    final hoje = chaveDia(agora);
    final bit = bitDoDia(agora);

    final habitos = await (db.select(db.habitos)
          ..where((h) => h.apagadoEm.isNull())
          ..orderBy([(h) => OrderingTerm(expression: h.criadoEm)]))
        .get();
    final registros = await (db.select(db.registrosHabito)
          ..where((r) => r.dia.equals(hoje) & r.feito & r.apagadoEm.isNull()))
        .get();
    final feitos = registros.map((r) => r.habitoId).toSet();
    final habitosHoje = [
      for (final h in habitos)
        if (h.diasSemana & bit != 0) HabitoDoDia(habito: h, feito: feitos.contains(h.id)),
    ];

    final abertas = await (db.select(db.tarefas)
          ..where((t) => t.feitaEm.isNull() & t.apagadoEm.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.prazo)]))
        .get();
    final inicioHoje = inicioDoDia(agora);
    final tarefasHoje = abertas
        .where((t) => t.prazo != null && inicioDoDia(t.prazo!) == inicioHoje)
        .toList();

    final fimDoMes = diaSP(agora.year, agora.month + 1, 1);
    final contas = await (db.select(db.transacoes)
          ..where((t) =>
              t.tipo.equalsValue(TipoTransacao.saida) &
              t.pagoEm.isNull() &
              t.apagadoEm.isNull() &
              t.vencimento.isSmallerThanValue(fimDoMes)))
        .get();

    final meta = await (db.select(db.metas)
          ..where((m) => m.status.equals('ativa') & m.apagadoEm.isNull())
          ..orderBy([(m) => OrderingTerm(expression: m.dataAlvo)])
          ..limit(1))
        .getSingleOrNull();

    return ResumoVisao(
      nome: await db.preferencia('nome') ?? '',
      habitos: habitosHoje,
      tarefasHoje: tarefasHoje,
      tarefasAtrasadas: abertas.where((t) => tarefaAtrasada(t, agora)).length,
      tarefasAbertas: abertas.length,
      aPagarCentavos: contas.fold(0, (soma, t) => soma + t.valorCentavos),
      contasAPagar: contas.length,
      meta: meta,
    );
  }

  /// Marca ou desmarca o hábito hoje (um registro por hábito e dia).
  Future<void> alternarHabito(String habitoId, bool feito) {
    final dia = chaveDia(agoraSP());
    return db.into(db.registrosHabito).insert(
          RegistrosHabitoCompanion.insert(
              habitoId: habitoId, dia: dia, feito: Value(feito)),
          onConflict: DoUpdate(
            (_) => RegistrosHabitoCompanion(
                feito: Value(feito), atualizadoEm: Value(DateTime.now())),
            target: [db.registrosHabito.habitoId, db.registrosHabito.dia],
          ),
        );
  }
}
