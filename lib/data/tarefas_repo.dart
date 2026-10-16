import 'package:drift/drift.dart';

import '../core/recorrencia.dart';
import '../core/relogio.dart';
import 'banco.dart';
import 'observar.dart';

/// Uma ocorrência de tarefa: a própria tarefa (se não repete) ou a ocorrência
/// de um dia de uma tarefa recorrente.
class OcorrenciaTarefa {
  const OcorrenciaTarefa({
    required this.tarefa,
    required this.dia,
    required this.feita,
    required this.atrasada,
    this.meta,
  });

  final Tarefa tarefa;

  /// Data de calendário (São Paulo) da ocorrência; nulo = sem data.
  final DateTime? dia;
  final bool feita;
  final bool atrasada;
  final Meta? meta;

  Regra? get regra => Regra.ler(tarefa.regraRepeticao);
  bool get recorrente => regra != null;

  /// Horário "HH:mm" da ocorrência, se a tarefa tem hora.
  ({int hora, int minuto})? get horario {
    if (!tarefa.prazoTemHora || tarefa.prazo == null) return null;
    final p = emSP(tarefa.prazo!);
    return (hora: p.hour, minuto: p.minute);
  }

  /// Instante exato (com hora) ou o fim do dia, para ordenar.
  DateTime? get momento {
    if (dia == null) return null;
    final h = horario;
    return h == null ? instanteSP(dia!, 23, 59) : instanteSP(dia!, h.hora, h.minuto);
  }
}

/// Fotografia das tarefas para as telas.
class QuadroTarefas {
  const QuadroTarefas({
    required this.atuais,
    required this.recorrentes,
    required this.feitasHoje,
    required this.metas,
    required this.tarefas,
    required this.conclusoes,
  });

  /// Uma ocorrência por tarefa: a de hoje ou a próxima (recorrentes), ou a
  /// própria tarefa. Ocorrências passadas de recorrentes não viram atrasadas:
  /// assim não se forma a pilha de atrasadas repetidas.
  final List<OcorrenciaTarefa> atuais;
  final List<OcorrenciaTarefa> recorrentes;
  final int feitasHoje;
  final List<Meta> metas;
  final List<Tarefa> tarefas;

  /// tarefaId → dias concluídos ("aaaa-mm-dd").
  final Map<String, Set<String>> conclusoes;

  List<OcorrenciaTarefa> get pendentes => atuais.where((o) => !o.feita).toList();
  int get atrasadas => atuais.where((o) => o.atrasada).length;
  int get abertas => pendentes.length;

  /// Atrasadas, depois as de hoje (pendentes e, no fim, as feitas hoje).
  List<OcorrenciaTarefa> resolverAgora(DateTime hoje) {
    final lista = atuais
        .where((o) => o.atrasada || (o.dia != null && o.dia == hoje))
        .toList()
      ..sort(compararOcorrencias);
    return lista;
  }

  /// Ocorrências em cada dia do período (para o calendário).
  Map<DateTime, List<OcorrenciaTarefa>> porDia(DateTime de, DateTime ate, DateTime agora) {
    final mapa = <DateTime, List<OcorrenciaTarefa>>{};
    final metasPorId = {for (final m in metas) m.id: m};
    for (final t in tarefas) {
      final regra = Regra.ler(t.regraRepeticao);
      if (t.prazo == null) continue;
      final inicio = dataSP(t.prazo!);
      final dias = regra == null
          ? [if (!inicio.isBefore(de) && !inicio.isAfter(ate)) inicio]
          : regra.ocorrencias(inicio, de, ate);
      for (final d in dias) {
        final feita = regra == null
            ? t.feitaEm != null
            : (conclusoes[t.id]?.contains(chaveData(d)) ?? false);
        mapa.putIfAbsent(d, () => []).add(OcorrenciaTarefa(
              tarefa: t,
              dia: d,
              feita: feita,
              atrasada: regra == null && tarefaAtrasada(t, agora),
              meta: metasPorId[t.metaId],
            ));
      }
    }
    for (final l in mapa.values) {
      l.sort(compararOcorrencias);
    }
    return mapa;
  }
}

/// Pendentes antes de feitas; atrasadas primeiro; depois data/hora e prioridade.
int compararOcorrencias(OcorrenciaTarefa a, OcorrenciaTarefa b) {
  if (a.feita != b.feita) return a.feita ? 1 : -1;
  if (a.atrasada != b.atrasada) return a.atrasada ? -1 : 1;
  final ma = a.momento, mb = b.momento;
  if (ma != null && mb != null && ma != mb) return ma.compareTo(mb);
  if ((ma == null) != (mb == null)) return ma == null ? 1 : -1;
  return a.tarefa.prioridade.index.compareTo(b.tarefa.prioridade.index);
}

/// Tarefa sem repetição atrasada: com hora, passou do horário; sem hora, passou do dia.
bool tarefaAtrasada(Tarefa t, DateTime agora) {
  if (t.feitaEm != null || t.prazo == null || t.regraRepeticao != null) return false;
  if (t.prazoTemHora) return t.prazo!.isBefore(agora);
  return dataSP(t.prazo!).isBefore(dataSP(agora));
}

class TarefasRepo {
  TarefasRepo(this.db);
  final BancoAurora db;

  Stream<QuadroTarefas> observarQuadro() =>
      observar(db, [db.tarefas, db.conclusoesTarefa, db.metas], carregar);

  Future<QuadroTarefas> carregar() async {
    final agora = agoraSP();
    final hoje = dataSP(agora);
    final chaveHoje = chaveData(hoje);

    final tarefas = await (db.select(db.tarefas)..where((t) => t.apagadoEm.isNull())).get();
    final metas = await (db.select(db.metas)..where((m) => m.apagadoEm.isNull())).get();
    final metasPorId = {for (final m in metas) m.id: m};
    final linhas =
        await (db.select(db.conclusoesTarefa)..where((c) => c.apagadoEm.isNull())).get();
    final conclusoes = <String, Set<String>>{};
    for (final c in linhas) {
      conclusoes.putIfAbsent(c.tarefaId, () => {}).add(c.dia);
    }

    final atuais = <OcorrenciaTarefa>[];
    final recorrentes = <OcorrenciaTarefa>[];
    var feitasHoje = linhas.where((c) => c.dia == chaveHoje).length;

    for (final t in tarefas) {
      final regra = Regra.ler(t.regraRepeticao);
      final meta = metasPorId[t.metaId];
      if (regra == null) {
        if (t.feitaEm != null && dataSP(t.feitaEm!) == hoje) feitasHoje++;
        // Concluídas em outros dias saem da lista.
        if (t.feitaEm != null && dataSP(t.feitaEm!) != hoje) continue;
        atuais.add(OcorrenciaTarefa(
          tarefa: t,
          dia: t.prazo == null ? null : dataSP(t.prazo!),
          feita: t.feitaEm != null,
          atrasada: tarefaAtrasada(t, agora),
          meta: meta,
        ));
        continue;
      }
      final inicio = t.prazo == null ? hoje : dataSP(t.prazo!);
      final feitos = conclusoes[t.id] ?? const {};
      final DateTime? dia;
      if (regra.ocorreEm(hoje, inicio)) {
        dia = hoje;
      } else {
        dia = regra.proxima(inicio, hoje.add(const Duration(days: 1)));
      }
      if (dia == null) continue;
      final o = OcorrenciaTarefa(
        tarefa: t,
        dia: dia,
        feita: feitos.contains(chaveData(dia)),
        atrasada: false,
        meta: meta,
      );
      atuais.add(o);
      recorrentes.add(o);
    }
    atuais.sort(compararOcorrencias);
    recorrentes.sort((a, b) => a.tarefa.titulo.compareTo(b.tarefa.titulo));

    return QuadroTarefas(
      atuais: atuais,
      recorrentes: recorrentes,
      feitasHoje: feitasHoje,
      metas: metas,
      tarefas: tarefas,
      conclusoes: conclusoes,
    );
  }

  /// Conclui ou reabre uma ocorrência.
  Future<void> alternar(OcorrenciaTarefa o, bool feita) async {
    final agora = DateTime.now();
    if (!o.recorrente) {
      await (db.update(db.tarefas)..where((t) => t.id.equals(o.tarefa.id))).write(
          TarefasCompanion(feitaEm: Value(feita ? agora : null), atualizadoEm: Value(agora)));
      return;
    }
    final dia = chaveData(o.dia ?? hojeSP());
    if (feita) {
      await db.into(db.conclusoesTarefa).insert(
            ConclusoesTarefaCompanion.insert(
                id: Value(idNatural('conclusao_tarefa', [o.tarefa.id, dia])),
                tarefaId: o.tarefa.id,
                dia: dia),
            onConflict: DoUpdate(
              (_) => ConclusoesTarefaCompanion(
                  apagadoEm: const Value(null), atualizadoEm: Value(agora)),
              target: [db.conclusoesTarefa.tarefaId, db.conclusoesTarefa.dia],
            ),
          );
    } else {
      // Reabrir marca a conclusão como apagada (para a sincronização saber).
      await (db.update(db.conclusoesTarefa)
            ..where((c) => c.tarefaId.equals(o.tarefa.id) & c.dia.equals(dia)))
          .write(ConclusoesTarefaCompanion(apagadoEm: Value(agora), atualizadoEm: Value(agora)));
    }
  }

  /// Cria ou atualiza a tarefa. Com [avisar], mantém um lembrete ligado a ela
  /// no horário do prazo (09:00 se não tiver hora), com a mesma repetição.
  Future<String> salvar(TarefasCompanion dados, {String? id, required bool avisar}) {
    return db.transaction(() async {
      final agora = DateTime.now();
      late final String tarefaId;
      if (id == null) {
        final t = await db.into(db.tarefas).insertReturning(dados);
        tarefaId = t.id;
      } else {
        tarefaId = id;
        await (db.update(db.tarefas)..where((t) => t.id.equals(id)))
            .write(dados.copyWith(atualizadoEm: Value(agora)));
      }
      await _apagarLembretesDe(tarefaId, agora);
      final prazo = dados.prazo.present ? dados.prazo.value : null;
      if (avisar && prazo != null) {
        final temHora = dados.prazoTemHora.present && dados.prazoTemHora.value;
        final p = emSP(prazo);
        await db.into(db.lembretes).insert(LembretesCompanion.insert(
              texto: dados.titulo.value,
              quando: temHora ? prazo : diaSP(p.year, p.month, p.day, 9),
              regraRepeticao: dados.regraRepeticao,
              itemTipo: const Value('tarefa'),
              itemId: Value(tarefaId),
            ));
      }
      return tarefaId;
    });
  }

  Future<bool> temLembrete(String tarefaId) async {
    final l = await (db.select(db.lembretes)
          ..where((l) =>
              l.itemTipo.equals('tarefa') & l.itemId.equals(tarefaId) & l.apagadoEm.isNull()))
        .get();
    return l.isNotEmpty;
  }

  Future<void> excluir(String id) => db.transaction(() async {
        final agora = DateTime.now();
        await (db.update(db.tarefas)..where((t) => t.id.equals(id)))
            .write(TarefasCompanion(apagadoEm: Value(agora), atualizadoEm: Value(agora)));
        await _apagarLembretesDe(id, agora);
      });

  Future<void> _apagarLembretesDe(String tarefaId, DateTime agora) =>
      (db.update(db.lembretes)
            ..where((l) =>
                l.itemTipo.equals('tarefa') & l.itemId.equals(tarefaId) & l.apagadoEm.isNull()))
          .write(LembretesCompanion(apagadoEm: Value(agora), atualizadoEm: Value(agora)));
}
