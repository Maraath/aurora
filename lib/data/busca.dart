/// Busca em tudo (Ctrl+K): procura no banco local, sem internet, em tarefas,
/// hábitos, lançamentos, categorias, lembretes, metas, projetos, exercícios e
/// treinos. A comparação ignora maiúsculas e acentos.
library;

import 'package:drift/drift.dart';

import '../core/comandos.dart' show normalizar;
import '../core/formato.dart';
import '../core/relogio.dart';
import 'banco.dart';

enum GrupoBusca {
  financas('Finanças'),
  tarefas('Tarefas e lembretes'),
  habitos('Hábitos'),
  planos('Metas e projetos'),
  saude('Saúde');

  const GrupoBusca(this.rotulo);
  final String rotulo;
}

enum TipoResultado {
  tarefa(GrupoBusca.tarefas),
  lembrete(GrupoBusca.tarefas),
  transacao(GrupoBusca.financas),
  categoria(GrupoBusca.financas),
  habito(GrupoBusca.habitos),
  meta(GrupoBusca.planos),
  projeto(GrupoBusca.planos),
  exercicio(GrupoBusca.saude),
  treino(GrupoBusca.saude);

  const TipoResultado(this.grupo);
  final GrupoBusca grupo;
}

class ResultadoBusca {
  const ResultadoBusca({
    required this.tipo,
    required this.titulo,
    required this.detalhe,
    required this.pontos,
    this.direita,
    this.item,
  });

  final TipoResultado tipo;
  final String titulo;
  final String detalhe;

  /// Texto à direita (valor do lançamento, por exemplo).
  final String? direita;

  /// A linha do banco (Tarefa, Transacao…) ou o nome da categoria.
  final Object? item;

  /// Quanto maior, mais perto do topo.
  final int pontos;
}

/// Onde [termo] aparece em [texto] (posições do texto original), ou nulo.
/// Serve também para destacar o trecho na tela.
(int, int)? trechoEncontrado(String texto, String termo) {
  final t = normalizar(termo.trim());
  if (t.isEmpty) return null;
  final i = normalizar(texto).indexOf(t);
  return i < 0 ? null : (i, i + t.length);
}

/// Pontuação do nome: começa com o termo > alguma palavra começa > contém.
int? _pontuar(String texto, String termo) {
  final t = normalizar(termo.trim());
  final n = normalizar(texto);
  if (t.isEmpty) return null;
  if (n == t) return 400;
  if (n.startsWith(t)) return 300;
  if (n.contains(' $t')) return 200;
  if (n.contains(t)) return 100;
  return null;
}

/// Procura [termo] e devolve no máximo [porGrupo] resultados de cada grupo,
/// já ordenados (melhor primeiro, depois o mais recente).
Future<List<ResultadoBusca>> buscarTudo(BancoAurora db, String termo,
    {int porGrupo = 5, DateTime? hoje}) async {
  if (termo.trim().length < 2) return const [];
  final dia = hoje ?? hojeSP();
  final r = <ResultadoBusca>[];

  void add(TipoResultado tipo, String titulo, String detalhe, Object? item,
      {String? direita, int extra = 0, String? tambem}) {
    final p = _pontuar(titulo, termo) ?? (tambem == null ? null : _pontuar(tambem, termo));
    if (p == null) return;
    r.add(ResultadoBusca(
        tipo: tipo, titulo: titulo, detalhe: detalhe, item: item, direita: direita, pontos: p + extra));
  }

  for (final t in await (db.select(db.tarefas)..where((x) => x.apagadoEm.isNull())).get()) {
    final quando = t.prazo == null ? 'sem data' : diaRelativo(dataSP(t.prazo!), dia);
    add(TipoResultado.tarefa, t.titulo, t.feitaEm != null ? 'Tarefa · feita' : 'Tarefa · $quando', t,
        extra: t.feitaEm == null ? 20 : 0, tambem: t.notas);
  }
  for (final l in await (db.select(db.lembretes)..where((x) => x.apagadoEm.isNull())).get()) {
    final q = l.quando.toLocal();
    add(TipoResultado.lembrete, l.texto, 'Lembrete · ${rotuloDiaLembrete(dataSP(q), dia)}, ${hora(q)}', l);
  }

  // Lançamentos: do mais recente ao mais antigo (o desempate fica com a data).
  final transacoes = await (db.select(db.transacoes)
        ..where((x) => x.apagadoEm.isNull() & x.contaDestinoId.isNull())
        ..orderBy([(x) => OrderingTerm.desc(x.data)]))
      .get();
  final contas = {for (final c in await db.select(db.contasFinanceiras).get()) c.id: c.nome};
  final categorias = <String, int>{};
  for (var i = 0; i < transacoes.length; i++) {
    final t = transacoes[i];
    final cat = t.categoria;
    if (cat != null && cat.isNotEmpty) categorias[cat] = (categorias[cat] ?? 0) + 1;
    final entrada = t.tipo == TipoTransacao.entrada;
    final partes = [
      entrada ? 'Receita' : 'Despesa',
      diaMesCurto(dataSP(t.data)),
      if (cat != null && cat.isNotEmpty && normalizar(cat) != normalizar(t.descricao)) cat,
      ?contas[t.contaId],
    ];
    add(TipoResultado.transacao, t.descricao, partes.join(' · '), t,
        direita: '${entrada ? '+' : '−'} ${reais(t.valorCentavos)}',
        // Mais recentes à frente entre os de mesma pontuação.
        extra: (50 - i).clamp(0, 50) ~/ 10,
        tambem: cat);
  }
  for (final e in categorias.entries) {
    add(TipoResultado.categoria, e.key,
        'Categoria · ${e.value} ${e.value == 1 ? 'lançamento' : 'lançamentos'}', e.key, extra: 30);
  }

  for (final h in await (db.select(db.habitos)..where((x) => x.apagadoEm.isNull())).get()) {
    add(TipoResultado.habito, h.nome, 'Hábito${h.horario == null ? '' : ' · ${h.horario}'}', h);
  }
  for (final m in await (db.select(db.metas)..where((x) => x.apagadoEm.isNull())).get()) {
    add(TipoResultado.meta, m.nome, m.status == 'ativa' ? 'Meta' : 'Meta · ${m.status}', m);
  }
  for (final p in await (db.select(db.projetos)..where((x) => x.apagadoEm.isNull())).get()) {
    add(TipoResultado.projeto, p.nome, p.status == 'ativo' ? 'Projeto' : 'Projeto · arquivado', p);
  }
  for (final t in await (db.select(db.treinos)..where((x) => x.apagadoEm.isNull())).get()) {
    add(TipoResultado.treino, t.nome, 'Treino', t);
  }
  for (final e in await (db.select(db.exercicios)..where((x) => x.apagadoEm.isNull())).get()) {
    add(TipoResultado.exercicio, e.nome, 'Exercício', e);
  }

  r.sort((a, b) => b.pontos.compareTo(a.pontos));
  final porTipo = <GrupoBusca, int>{};
  return [
    for (final x in r)
      if ((porTipo[x.tipo.grupo] = (porTipo[x.tipo.grupo] ?? 0) + 1) <= porGrupo) x,
  ];
}
