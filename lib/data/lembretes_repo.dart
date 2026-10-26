import 'package:drift/drift.dart';

import '../core/recorrencia.dart';
import '../core/relogio.dart';
import 'banco.dart';
import 'observar.dart';

class LembreteVisto {
  const LembreteVisto({required this.lembrete, required this.proxima, this.ligadoA});

  final Lembrete lembrete;

  /// Próximo disparo (instante no fuso do aparelho); nulo se já passou e não repete.
  final DateTime? proxima;

  /// Nome do item ligado ("Tarefa · Pagar faculdade").
  final String? ligadoA;

  Regra? get regra => Regra.ler(lembrete.regraRepeticao);
  bool get recorrente => regra != null;
}

class QuadroLembretes {
  const QuadroLembretes(this.todos);
  final List<LembreteVisto> todos;

  /// Ativos com disparo futuro, do mais próximo ao mais distante.
  List<LembreteVisto> get proximos =>
      todos.where((l) => l.lembrete.ativo && l.proxima != null).toList()
        ..sort((a, b) => a.proxima!.compareTo(b.proxima!));

  LembreteVisto? get aSeguir => proximos.firstOrNull;
  List<LembreteVisto> get recorrentes => todos.where((l) => l.recorrente).toList();

  int contarAte(DateTime limite) => proximos.where((l) => l.proxima!.isBefore(limite)).length;
}

/// Próximo disparo de um lembrete a partir de [agora].
DateTime? proximaOcorrencia(Lembrete l, DateTime agora) => ocorrenciasLembrete(l, agora).firstOrNull;

/// Disparos de um lembrete a partir de [agora], em ordem (até [limite] dias).
Iterable<DateTime> ocorrenciasLembrete(Lembrete l, DateTime agora, {int limite = 400}) sync* {
  final base = emLocal(l.quando);
  final regra = Regra.ler(l.regraRepeticao);
  if (regra == null) {
    if (l.quando.isAfter(agora)) yield l.quando;
    return;
  }
  final hoje = dataLocal(agora);
  final inicio = DateTime(base.year, base.month, base.day);
  for (final d in regra.ocorrencias(inicio, hoje, somarDias(hoje, limite))) {
    final instante = instanteLocal(d, base.hour, base.minute);
    if (instante.isAfter(agora)) yield instante;
  }
}

class LembretesRepo {
  LembretesRepo(this.db);
  final BancoAurora db;

  Stream<QuadroLembretes> observarQuadro() =>
      observar(db, [db.lembretes, db.tarefas, db.habitos], carregar);

  Future<QuadroLembretes> carregar() async {
    final agora = agoraLocal();
    final lista = await (db.select(db.lembretes)..where((l) => l.apagadoEm.isNull())).get();
    final tarefas = {
      for (final t in await (db.select(db.tarefas)..where((t) => t.apagadoEm.isNull())).get())
        t.id: t.titulo
    };
    final habitos = {
      for (final h in await (db.select(db.habitos)..where((h) => h.apagadoEm.isNull())).get())
        h.id: h.nome
    };
    String? ligado(Lembrete l) => switch (l.itemTipo) {
          'tarefa' => 'Tarefa',
          'habito' => 'Hábito',
          _ => null,
        };
    return QuadroLembretes([
      for (final l in lista)
        // Lembrete de item que não existe mais não aparece.
        if (!(l.itemTipo == 'tarefa' && !tarefas.containsKey(l.itemId)) &&
            !(l.itemTipo == 'habito' && !habitos.containsKey(l.itemId)))
          LembreteVisto(lembrete: l, proxima: proximaOcorrencia(l, agora), ligadoA: ligado(l)),
    ]);
  }

  /// Cria ou atualiza; devolve o id.
  Future<String> salvar(LembretesCompanion dados, {String? id}) async {
    if (id == null) return (await db.into(db.lembretes).insertReturning(dados)).id;
    await (db.update(db.lembretes)..where((l) => l.id.equals(id)))
        .write(dados.copyWith(atualizadoEm: Value(DateTime.now())));
    return id;
  }

  Future<void> alternarAtivo(String id, bool ativo) =>
      (db.update(db.lembretes)..where((l) => l.id.equals(id)))
          .write(LembretesCompanion(ativo: Value(ativo), atualizadoEm: Value(DateTime.now())));

  Future<void> excluir(String id) {
    final agora = DateTime.now();
    return (db.update(db.lembretes)..where((l) => l.id.equals(id)))
        .write(LembretesCompanion(apagadoEm: Value(agora), atualizadoEm: Value(agora)));
  }
}
