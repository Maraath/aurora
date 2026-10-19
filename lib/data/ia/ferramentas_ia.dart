/// Ferramentas que a IA pode usar, executadas AQUI no aparelho (o banco local
/// é a fonte dos dados e funciona offline). A lista e os esquemas ficam na Edge
/// Function (`supabase/functions/assistente/agente.ts`); os nomes e campos têm
/// de bater com os de lá.
library;

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../core/comandos.dart';
import '../../core/formato.dart';
import '../../core/relogio.dart';
import '../alimentacao_repo.dart';
import '../assistente_repo.dart';
import '../banco.dart';
import '../busca.dart';
import '../financas_repo.dart';
import '../habitos_repo.dart';
import '../lembretes_repo.dart';
import '../metas_repo.dart';
import '../projetos_repo.dart';
import '../saude_repo.dart';
import '../shape_repo.dart';
import '../tarefas_repo.dart';

/// Resultado de uma ferramenta: o texto que volta para a IA e, quando a
/// ferramenta criou algo, a confirmação que aparece na conversa (com
/// "Desfazer").
class ResultadoFerramenta {
  const ResultadoFerramenta(this.paraIa, {this.erro = false, this.aviso});
  final String paraIa;
  final bool erro;

  /// Confirmação visível na conversa (nula para consultas e navegação).
  final Resposta? aviso;
}

/// Tela pedida pela IA ("mostre minhas fotos do shape"). A Shell escuta e
/// navega; nomes iguais aos de `abrir_tela` na Edge Function.
final telaPedidaPelaIa = ValueNotifier<String?>(null);

class FerramentasIa {
  FerramentasIa(this.db, this.assistente);
  final BancoAurora db;
  final AssistenteRepo assistente;

  Future<ResultadoFerramenta> executar(String nome, Map<String, Object?> e) async {
    try {
      return await switch (nome) {
        'registrar_lancamento' => _acao(_lancamento(e)),
        'criar_tarefa' => _acao(CmdTarefa(
            titulo: _texto(e, 'titulo'),
            dia: _data(e['data']),
            hora: _hora(e['hora'])?.$1,
            minuto: _hora(e['hora'])?.$2 ?? 0,
          )),
        'criar_lembrete' => _lembrete(e),
        'marcar_habito' => _acao(CmdHabito(_texto(e, 'nome'))),
        'registrar_medida' => _acao(CmdMedida(
            tipo: _capitalizar(_texto(e, 'tipo')),
            valor: _numero(e['valor'])!,
            unidade: (e['unidade'] as String?)?.trim() ?? '',
          )),
        'registrar_refeicao' => _acao(CmdComida(
            nome: _texto(e, 'alimento'),
            gramas: _numero(e['gramas']),
            porcoes: _numero(e['porcoes']),
            refeicao: e['refeicao'] as String?,
          )),
        'criar_treino' => _treino(e),
        'excluir_registro_shape' => _excluirShape(e),
        'atualizar_metas' => e['alvo'] == 'dieta' ? _metaDieta(e) : _metaApp(e),
        'consultar' => Future.value(ResultadoFerramenta(
            await consultar(db, '${e['area']}', dias: (_numero(e['periodo_dias']) ?? 30).round()))),
        'buscar' => _buscar(_texto(e, 'termo')),
        'abrir_tela' => _abrirTela('${e['tela']}'),
        _ => Future.value(ResultadoFerramenta('Ferramenta desconhecida: $nome.', erro: true)),
      };
    } catch (err) {
      debugPrint('IA: ferramenta $nome falhou: $err');
      return ResultadoFerramenta('Não deu para executar ($nome): dados incompletos ou inválidos.', erro: true);
    }
  }

  /// Executa um comando rápido (o mesmo caminho dos comandos por texto).
  Future<ResultadoFerramenta> _acao(Comando c) async {
    final agora = agoraSP();
    final r = await assistente.executarComando(c, dataSP(agora), agora);
    // Sem item criado (hábito não achado, alimento ambíguo…): é um aviso para
    // a IA explicar, não uma confirmação.
    return ResultadoFerramenta(r.texto, erro: r.itemId == null, aviso: r.itemId == null ? null : r);
  }

  Comando _lancamento(Map<String, Object?> e) {
    final receita = e['tipo'] == 'receita';
    final descricao = _capitalizar(_texto(e, 'descricao'));
    final categoria = (e['categoria'] as String?)?.trim();
    return CmdDinheiro(
      centavos: (_numero(e['valor'])! * 100).round(),
      descricao: descricao,
      categoria: categoria != null && categoria.isNotEmpty
          ? _capitalizar(categoria)
          : (receita ? categoriaEntrada(descricao) : categoriaGasto(descricao)),
      dia: _data(e['data']) ?? hojeSP(),
      entrada: receita,
    );
  }

  Future<ResultadoFerramenta> _lembrete(Map<String, Object?> e) {
    final texto = _texto(e, 'texto');
    final (h, m) = _hora(e['hora']) ?? (9, 0);
    final repeticao = (e['repeticao'] as String?)?.trim() ?? '';
    if (repeticao.isNotEmpty) {
      // A repetição em português passa pelo mesmo interpretador dos comandos.
      final agora = agoraSP();
      final c = interpretar('me lembra de $texto $repeticao às ${horaDe(h, m)}', hoje: dataSP(agora), agora: agora);
      if (c is CmdLembrete && c.regra != null) return _acao(c);
      return Future.value(ResultadoFerramenta(
          'Não entendi a repetição "$repeticao". Use algo como "todo dia", "toda segunda e quarta" ou "todo dia 10".',
          erro: true));
    }
    return _acao(CmdLembrete(texto: texto, dia: _data(e['data']) ?? hojeSP(), hora: h, minuto: m));
  }

  Future<ResultadoFerramenta> _treino(Map<String, Object?> e) async {
    const bits = {'seg': 1, 'ter': 2, 'qua': 4, 'qui': 8, 'sex': 16, 'sab': 32, 'dom': 64};
    final dias = (e['dias'] as List? ?? const []).fold<int>(0, (s, d) => s | (bits['$d'] ?? 0));
    final itens = [
      for (final x in (e['exercicios'] as List? ?? const []).cast<Map<String, Object?>>())
        (
          nome: _capitalizar(_texto(x, 'nome')),
          series: _numero(x['series'])!.round(),
          repeticoes: _numero(x['repeticoes'])!.round(),
          cargaInicial: _numero(x['carga']),
        ),
    ];
    if (itens.isEmpty) return const ResultadoFerramenta('O treino precisa de pelo menos um exercício.', erro: true);
    final nome = _capitalizar(_texto(e, 'nome'));
    final foco = (e['foco'] as String?)?.trim();
    final id = await SaudeRepo(db).salvarTreino(
      TreinosCompanion.insert(
        nome: nome,
        foco: Value(foco == null || foco.isEmpty ? null : foco),
        diasSemana: Value(dias),
      ),
      itens,
    );
    final quando = dias == 0
        ? 'sem dia fixo'
        : [for (final d in bits.entries) if (dias & d.value != 0) d.key].join(', ');
    final texto = 'Criei o $nome${foco == null || foco.isEmpty ? '' : ' ($foco)'} com ${itens.length} '
        '${itens.length == 1 ? 'exercício' : 'exercícios'}, $quando. Está em Saúde › Treino › Ficha.';
    return ResultadoFerramenta(texto, aviso: Resposta(texto, itemTipo: 'treino', itemId: id));
  }

  // ------------------------------------------------------------- exclusão

  /// Pergunta mostrada à pessoa antes de excluir (o AssistenteRepo pede a
  /// confirmação). Nula se o registro não existe.
  Future<String?> perguntaDeExclusao(String nome, Map<String, Object?> e) async {
    if (nome != 'excluir_registro_shape') return null;
    final id = '${e['id']}';
    if (e['tipo'] == 'foto') {
      final f = await (db.select(db.fotosShape)..where((x) => x.id.equals(id) & x.apagadoEm.isNull()))
          .getSingleOrNull();
      if (f == null) return null;
      final angulo = AnguloShape.de(f.angulo)?.rotulo.toLowerCase() ?? f.angulo;
      return 'Excluir a foto de $angulo do dia ${diaMesLongo(DateTime.parse(f.dia))}? A foto não volta depois.';
    }
    final m = await (db.select(db.medidas)..where((x) => x.id.equals(id) & x.apagadoEm.isNull())).getSingleOrNull();
    if (m == null) return null;
    return 'Excluir a medida ${m.tipo} ${numero(m.valor)} ${m.unidade} do dia ${diaMesLongo(DateTime.parse(m.dia))}?';
  }

  /// Executa a exclusão (a confirmação já foi dada).
  Future<ResultadoFerramenta> _excluirShape(Map<String, Object?> e) async {
    final id = _texto(e, 'id');
    if (e['tipo'] == 'foto') {
      final f = await (db.select(db.fotosShape)..where((x) => x.id.equals(id) & x.apagadoEm.isNull()))
          .getSingleOrNull();
      if (f == null) return const ResultadoFerramenta('Essa foto não existe mais.', erro: true);
      // Apaga aqui e, se estava na nuvem, do balde também (ou fica pendente sem internet).
      await ShapeRepo(db).apagarFoto(f);
      final angulo = AnguloShape.de(f.angulo)?.rotulo.toLowerCase() ?? f.angulo;
      final texto = 'Excluí a foto de $angulo do dia ${diaMesLongo(DateTime.parse(f.dia))}.';
      return ResultadoFerramenta(texto, aviso: Resposta(texto));
    }
    final m = await (db.select(db.medidas)..where((x) => x.id.equals(id) & x.apagadoEm.isNull())).getSingleOrNull();
    if (m == null) return const ResultadoFerramenta('Essa medida não existe mais.', erro: true);
    await SaudeRepo(db).excluirMedida(m.id);
    final texto = 'Excluí a medida ${m.tipo} ${numero(m.valor)} ${m.unidade} do dia ${diaMesLongo(DateTime.parse(m.dia))}.';
    return ResultadoFerramenta(texto, aviso: Resposta(texto, itemTipo: 'medida_excluida', itemId: m.id));
  }

  // ---------------------------------------------------------------- metas

  /// Calorias e macros do dia de treino e/ou de descanso. Só muda o que veio;
  /// "Desfazer" volta os valores de antes.
  Future<ResultadoFerramenta> _metaDieta(Map<String, Object?> e) async {
    final repo = AlimentacaoRepo(db);
    final tipos = switch (e['dia']) {
      'treino' => [TipoDia.treino],
      'descanso' => [TipoDia.descanso],
      _ => TipoDia.values,
    };
    final kcal = _numero(e['kcal']), p = _numero(e['proteina']), c = _numero(e['carboidrato']), g = _numero(e['gordura']);
    if ([kcal, p, c, g].every((x) => x == null)) {
      return const ResultadoFerramenta('Diga quais valores mudar (kcal, proteína, carboidrato ou gordura).', erro: true);
    }
    final antes = <String>[];
    for (final t in tipos) {
      final a = await repo.alvo(t);
      antes.add(a == null ? '${t.name}:-' : '${t.name}:${a.kcal}:${a.proteina}:${a.carboidrato}:${a.gordura}');
      if (a == null && kcal == null) {
        return ResultadoFerramenta('Ainda não há meta de dieta para o dia de ${t.name}: diga também as calorias.',
            erro: true);
      }
      await repo.salvarAlvo(t, Nutrientes(kcal ?? a!.kcal, p ?? a?.proteina ?? 0, c ?? a?.carboidrato ?? 0, g ?? a?.gordura ?? 0));
    }
    String n(double? v, String u) => v == null ? '' : '${numero(v.roundToDouble())} $u';
    final mudou = [n(kcal, 'kcal'), if (p != null) 'proteína ${n(p, 'g')}', if (c != null) 'carboidrato ${n(c, 'g')}', if (g != null) 'gordura ${n(g, 'g')}']
        .where((x) => x.isNotEmpty)
        .join(', ');
    final dias = tipos.length == 2 ? 'dias de treino e de descanso' : 'dia de ${tipos.single.name}';
    final texto = 'Meta de dieta atualizada ($dias): $mudou.';
    return ResultadoFerramenta(texto, aviso: Resposta(texto, itemTipo: 'alvo_dieta', itemId: antes.join(';')));
  }

  /// Uma meta do app pelo nome: valor atual, alvo e/ou data.
  Future<ResultadoFerramenta> _metaApp(Map<String, Object?> e) async {
    final nome = _texto(e, 'nome_meta');
    final metas = await (db.select(db.metas)..where((m) => m.apagadoEm.isNull())).get();
    final alvo = normalizar(nome);
    final meta = metas.where((m) => normalizar(m.nome) == alvo).firstOrNull ??
        metas.where((m) => normalizar(m.nome).contains(alvo) || alvo.contains(normalizar(m.nome))).firstOrNull;
    if (meta == null) {
      return ResultadoFerramenta(
          'Não achei a meta "$nome". As metas são: ${metas.map((m) => m.nome).join(', ')}.',
          erro: true);
    }
    final atual = _numero(e['valor_atual']), valorAlvo = _numero(e['valor_alvo']), data = _data(e['data_alvo']);
    if (atual == null && valorAlvo == null && data == null) {
      return const ResultadoFerramenta('Diga o que mudar na meta: valor atual, alvo ou data.', erro: true);
    }
    await MetasRepo(db).salvar(
      MetasCompanion(
        valorAtual: atual == null ? const Value.absent() : Value(atual),
        valorAlvo: valorAlvo == null ? const Value.absent() : Value(valorAlvo),
        dataAlvo: data == null ? const Value.absent() : Value(instanteSP(data, 12)),
      ),
      id: meta.id,
    );
    final partes = [
      if (atual != null) 'agora em ${valorMeta(atual, meta.unidade)}',
      if (valorAlvo != null) 'alvo ${valorMeta(valorAlvo, meta.unidade)}',
      if (data != null) 'até ${diaMesLongo(data)}',
    ];
    final texto = 'Meta “${meta.nome}” atualizada: ${partes.join(', ')}.';
    final antes = '${meta.id}|${meta.valorAtual}|${meta.valorAlvo}|${meta.dataAlvo?.toIso8601String() ?? ''}';
    return ResultadoFerramenta(texto, aviso: Resposta(texto, itemTipo: 'meta', itemId: antes));
  }

  Future<ResultadoFerramenta> _buscar(String termo) async {
    final r = await buscarTudo(db, termo, porGrupo: 6);
    if (r.isEmpty) return ResultadoFerramenta('Nada encontrado para "$termo".');
    return ResultadoFerramenta([
      for (final x in r) '- ${x.titulo} (${x.detalhe}${x.direita == null ? '' : ', ${x.direita}'})',
    ].join('\n'));
  }

  Future<ResultadoFerramenta> _abrirTela(String tela) async {
    telaPedidaPelaIa.value = null; // pedir a mesma tela de novo também avisa
    telaPedidaPelaIa.value = tela;
    return ResultadoFerramenta('Abri a tela "$tela" para a pessoa.');
  }
}

// ------------------------------------------------------------------ leitura

String _texto(Map<String, Object?> e, String campo) {
  final v = e[campo];
  if (v is! String || v.trim().isEmpty) throw ArgumentError('falta $campo');
  return v.trim();
}

double? _numero(Object? v) => switch (v) {
      num n => n.toDouble(),
      String s => double.tryParse(s.replaceAll(',', '.')),
      _ => null,
    };

DateTime? _data(Object? v) {
  if (v is! String) return null;
  final d = DateTime.tryParse(v.trim());
  return d == null ? null : DateTime(d.year, d.month, d.day);
}

(int, int)? _hora(Object? v) {
  if (v is! String) return null;
  final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(v.trim());
  if (m == null) return null;
  final h = int.parse(m[1]!), min = int.parse(m[2]!);
  return h < 24 && min < 60 ? (h, min) : null;
}

String _capitalizar(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

// ------------------------------------------------------------------ consulta

/// Dados detalhados de uma área, em texto, para a ferramenta "consultar".
/// Vai além do resumo mandado em toda pergunta (ver contexto_ia.dart).
Future<String> consultar(BancoAurora db, String area, {int dias = 30}) async {
  final hoje = hojeSP();
  final desde = hoje.subtract(Duration(days: dias - 1));
  final l = <String>['Período: últimos $dias dias (de ${diaMesCurto(desde)} a ${diaMesCurto(hoje)}).'];

  switch (area) {
    case 'tarefas':
      final q = await TarefasRepo(db).carregar();
      l.add('Em aberto: ${q.abertas} (${q.atrasadas} atrasadas).');
      for (final o in q.pendentes.take(40)) {
        final h = o.horario;
        l.add('- ${o.tarefa.titulo}: ${o.dia == null ? 'sem data' : diaRelativo(o.dia!, hoje)}'
            '${h == null ? '' : ' ${horaDe(h.hora, h.minuto)}'}${o.atrasada ? ', atrasada' : ''}');
      }
      final feitas = q.tarefas.where((t) => t.feitaEm != null && !dataSP(t.feitaEm!).isBefore(desde)).toList();
      l.add('Tarefas únicas concluídas no período: ${feitas.length}'
          '${feitas.isEmpty ? '' : ' (${feitas.take(15).map((t) => t.titulo).join(', ')})'}.');

    case 'habitos':
      final q = await HabitosRepo(db).carregar();
      if (q.habitos.isEmpty) l.add('Nenhum hábito cadastrado.');
      for (final h in q.habitos) {
        var feitos = 0, previstos = 0;
        for (var d = desde; !d.isAfter(hoje); d = DateTime(d.year, d.month, d.day + 1)) {
          if (q.doDia(d).any((x) => x.id == h.id)) previstos++;
          if (q.feito(h.id, d)) feitos++;
        }
        l.add('- ${h.nome}${h.horario == null ? '' : ' (${h.horario})'}: feito $feitos de $previstos dias previstos, '
            'sequência atual ${q.sequencia(h, hoje)} dias, hoje ${q.feito(h.id, hoje) ? 'feito' : 'pendente'}.');
      }

    case 'financas':
      final q = await FinancasRepo(db).carregar();
      l.add('Saldo em conta: ${reais(q.saldoCentavos)}. Patrimônio: ${reais(q.patrimonioCentavos)}.');
      final meses = <DateTime>{for (var d = desde; !d.isAfter(hoje); d = DateTime(d.year, d.month + 1, 1)) DateTime(d.year, d.month, 1)};
      for (final m in meses) {
        final r = q.mes(m);
        l.add('${nomeDoMes(m)} de ${m.year}: entrou ${reais(r.entrouCentavos)}, saiu ${reais(r.saiuCentavos)}'
            '${r.categorias.isEmpty ? '' : '; por categoria: ${r.categorias.take(8).map((c) => '${c.nome} ${reais(c.centavos)}').join(', ')}'}.');
      }
      final recentes = await (db.select(db.transacoes)
            ..where((t) => t.apagadoEm.isNull() & t.pagoEm.isNotNull())
            ..orderBy([(t) => OrderingTerm.desc(t.data)])
            ..limit(25))
          .get();
      l.add('Lançamentos recentes:');
      for (final t in recentes.where((t) => !dataSP(t.data).isBefore(desde))) {
        l.add('- ${diaMesCurto(dataSP(t.data))} ${t.descricao}${t.categoria == null ? '' : ' (${t.categoria})'}: '
            '${t.tipo == TipoTransacao.entrada ? '+' : '−'}${reais(t.valorCentavos)}');
      }

    case 'treino':
      final s = await SaudeRepo(db).carregar();
      if (s.treinos.isEmpty) l.add('Nenhum treino na ficha.');
      for (final t in s.treinos) {
        l.add('${t.titulo}${t.ultimaVez == null ? '' : ', feito por último em ${diaMesCurto(t.ultimaVez!)}'}:');
        for (final x in t.exercicios) {
          l.add('  - ${x.exercicio.nome}: ${x.plano}, carga sugerida ${x.sugestao.texto}');
        }
      }
      final sessoes = s.historico.where((r) => !DateTime.parse(r.sessao.dia).isBefore(desde)).toList();
      l.add('Sessões no período: ${sessoes.length}.');
      for (final r in sessoes.take(20)) {
        l.add('- ${diaMesCurto(DateTime.parse(r.sessao.dia))}: ${r.treino?.nome ?? 'treino'}, ${r.series} séries, '
            'volume ${numero(r.volumeKg.roundToDouble())} kg');
      }

    case 'medidas':
      final s = await SaudeRepo(db).carregar();
      if (s.medidas.isEmpty) l.add('Nenhuma medida registrada.');
      for (final tipo in s.tiposMedida) {
        final lista = s.medidas[tipo]!.where((m) => !DateTime.parse(m.dia).isBefore(desde)).toList();
        final ultima = s.ultima(tipo)!;
        l.add('$tipo: última ${numero(ultima.valor)} ${ultima.unidade} (${diaMesCurto(DateTime.parse(ultima.dia))}).');
        for (final m in lista.reversed.take(30)) {
          l.add('  - ${diaMesCurto(DateTime.parse(m.dia))} ${numero(m.valor)} ${m.unidade} (id ${m.id})');
        }
      }

    case 'shape':
      final fotos = (await ShapeRepo(db).fotosAtivas())
          .where((f) => !DateTime.parse(f.dia).isBefore(desde))
          .toList();
      l.add(fotos.isEmpty ? 'Nenhuma foto de Shape no período.' : 'Fotos de evolução (Shape):');
      for (final f in fotos.take(60)) {
        l.add('- ${diaMesLongo(DateTime.parse(f.dia))} (${f.dia}), ${AnguloShape.de(f.angulo)?.rotulo ?? f.angulo}'
            '${f.naNuvem ? ', na nuvem' : ''} (id ${f.id})');
      }

    case 'alimentacao':
      final repo = AlimentacaoRepo(db);
      final n = dias.clamp(1, 7);
      for (var i = 0; i < n; i++) {
        final d = hoje.subtract(Duration(days: i));
        final dia = await repo.carregarDia(d);
        final t = dia.total;
        String g(double v) => numero(v.roundToDouble());
        l.add('${diaRelativo(d, hoje)}: ${g(t.kcal)} kcal, P ${g(t.proteina)} g, C ${g(t.carboidrato)} g, G ${g(t.gordura)} g'
            '${dia.alvo == null ? '' : ' (alvo ${g(dia.alvo!.kcal)} kcal, P ${g(dia.alvo!.proteina)} g)'}'
            ', ${dia.registros.length} registros.');
      }

    case 'metas':
      final metas = await MetasRepo(db).carregar();
      if (metas.isEmpty) l.add('Nenhuma meta.');
      for (final p in metas) {
        final m = p.meta;
        l.add('- ${m.nome}: ${valorMeta(m.valorAtual, m.unidade)} de ${valorMeta(m.valorAlvo, m.unidade)}'
            '${m.dataAlvo == null ? '' : ' até ${diaMesCurto(dataSP(m.dataAlvo!))}'}, ${p.estado.rotulo.toLowerCase()}.');
      }

    case 'projetos':
      final projetos = await ProjetosRepo(db).carregar();
      if (projetos.isEmpty) l.add('Nenhum projeto.');
      for (final p in projetos) {
        final feitas = p.etapas.where((e) => e.tarefa.feitaEm != null).length;
        l.add('- ${p.projeto.nome}: ${p.estado.rotulo.toLowerCase()}, $feitas de ${p.etapas.length} etapas feitas, '
            'até ${diaMesCurto(dataSP(p.projeto.fim))}.');
      }

    case 'lembretes':
      final q = await LembretesRepo(db).carregar();
      if (q.todos.isEmpty) l.add('Nenhum lembrete.');
      for (final x in q.proximos.take(30)) {
        final p = x.proxima!.toLocal();
        l.add('- ${x.lembrete.texto}: ${rotuloDiaLembrete(dataSP(p), hoje)} ${hora(p)}${x.recorrente ? ' (repete)' : ''}');
      }

    default:
      return 'Área desconhecida: $area.';
  }
  return l.join('\n');
}
