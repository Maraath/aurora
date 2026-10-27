/// Ferramentas que a IA pode usar, executadas AQUI no aparelho (o banco local
/// é a fonte dos dados e funciona offline). A lista e os esquemas ficam na Edge
/// Function (`supabase/functions/assistente/agente.ts`); os nomes e campos têm
/// de bater com os de lá.
library;

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../core/comandos.dart';
import '../../core/formato.dart';
import '../../core/recorrencia.dart';
import '../../core/relogio.dart';
import '../alimentacao_repo.dart';
import '../assistente_repo.dart';
import '../banco.dart';
import '../busca.dart';
import '../compromissos_repo.dart';
import '../financas_repo.dart';
import '../habitos_repo.dart';
import '../lembretes_repo.dart';
import '../objetivos_repo.dart';
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
        'criar_compromisso' => _acao(_compromisso(e)),
        'editar_compromisso' => _editarCompromisso(e),
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
        'editar_lancamento' => _editarLancamento(e),
        'editar_tarefa' => _editarTarefa(e),
        'editar_lembrete' => _editarLembrete(e),
        'editar_treino' => _editarTreino(e),
        'excluir_item' => _excluirItem(e),
        'marcar_pagamento' => _marcarPagamento(e),
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
    final agora = agoraLocal();
    final r = await assistente.executarComando(c, dataLocal(agora), agora);
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
      dia: _data(e['data']) ?? hojeLocal(),
      entrada: receita,
    );
  }

  Future<ResultadoFerramenta> _lembrete(Map<String, Object?> e) {
    final texto = _texto(e, 'texto');
    final (h, m) = _hora(e['hora']) ?? (9, 0);
    final repeticao = (e['repeticao'] as String?)?.trim() ?? '';
    if (repeticao.isNotEmpty) {
      // A repetição em português passa pelo mesmo interpretador dos comandos.
      final agora = agoraLocal();
      final c = interpretar('me lembra de $texto $repeticao às ${horaDe(h, m)}', hoje: dataLocal(agora), agora: agora);
      if (c is CmdLembrete && c.regra != null) return _acao(c);
      return Future.value(ResultadoFerramenta(
          'Não entendi a repetição "$repeticao". Use algo como "todo dia", "toda segunda e quarta" ou "todo dia 10".',
          erro: true));
    }
    return _acao(CmdLembrete(texto: texto, dia: _data(e['data']) ?? hojeLocal(), hora: h, minuto: m));
  }

  CmdCompromisso _compromisso(Map<String, Object?> e) {
    final dia = _data(e['data']) ?? hojeLocal();
    final hora = _hora(e['hora']);
    final fim = _hora(e['fim']);
    final aviso = _numero(e['aviso_min']);
    final local = (e['local'] as String?)?.trim();
    return CmdCompromisso(
      titulo: _capitalizar(_texto(e, 'titulo')),
      dia: dia,
      hora: hora?.$1,
      minuto: hora?.$2 ?? 0,
      fimHora: fim?.$1,
      fimMinuto: fim?.$2 ?? 0,
      diaInteiro: e['dia_inteiro'] == true || hora == null,
      local: local == null || local.isEmpty ? null : local,
      regra: _regraCompromisso(e['repeticao'], dia),
      avisoMin: aviso == null ? 30 : aviso.round(),
    );
  }

  /// "semana", "quinzena", "mes", "ano" (o dia da semana e do mês vêm de [dia]).
  static Regra? _regraCompromisso(Object? repeticao, DateTime dia) => switch (repeticao) {
        'semana' => Regra.semanal(bitDoDiaDaSemana(dia)),
        'quinzena' => Regra.semanal(bitDoDiaDaSemana(dia), intervalo: 2),
        'mes' => Regra.mensal(dia.day),
        'ano' => const Regra.anual(),
        _ => null,
      };

  Future<ResultadoFerramenta> _editarCompromisso(Map<String, Object?> e) async {
    final c = await _compromissoDe(_texto(e, 'id'));
    if (c == null) return const ResultadoFerramenta(_naoAchei, erro: true);
    final titulo = (e['titulo'] as String?)?.trim();
    final dia = _data(e['data']);
    final hora = _hora(e['hora']);
    final fim = _hora(e['fim']);
    final diaInteiro = e['dia_inteiro'] is bool ? e['dia_inteiro'] as bool : null;
    final local = e['local'] is String ? (e['local'] as String).trim() : null;
    final repeticao = e['repeticao'] as String?;
    final aviso = _numero(e['aviso_min'])?.round();
    if ((titulo == null || titulo.isEmpty) &&
        [dia, hora, fim, diaInteiro, local, repeticao, aviso].every((x) => x == null)) {
      return const ResultadoFerramenta(
          'Diga o que mudar no compromisso: título, dia, hora, fim, local, repetição ou aviso.',
          erro: true);
    }
    final ini = emLocal(c.inicio);
    final novoDia = dia ?? DateTime(ini.year, ini.month, ini.day);
    final inteiro = diaInteiro ?? (hora == null ? c.diaInteiro : false);
    final (h, m) = hora ?? (ini.hour, ini.minute);
    final inicio = inteiro ? instanteLocal(novoDia) : instanteLocal(novoDia, h, m);
    DateTime? novoFim;
    if (!inteiro) {
      if (fim != null) {
        novoFim = instanteLocal(novoDia, fim.$1, fim.$2);
        if (!novoFim.isAfter(inicio)) novoFim = instanteLocal(somarDias(novoDia, 1), fim.$1, fim.$2);
      } else {
        // Sem fim novo: mantém a duração de antes (1 hora se não tinha).
        novoFim = inicio.add(c.fim == null || c.diaInteiro ? const Duration(hours: 1) : c.fim!.difference(c.inicio));
      }
    }
    await CompromissosRepo(db).salvar(
      CompromissosCompanion(
        titulo: titulo == null || titulo.isEmpty ? const Value.absent() : Value(_capitalizar(titulo)),
        inicio: Value(inicio),
        fim: Value(novoFim),
        diaInteiro: Value(inteiro),
        local: local == null ? const Value.absent() : Value(local.isEmpty ? null : local),
        regraRepeticao: repeticao == null ? const Value.absent() : Value(_regraCompromisso(repeticao, novoDia)?.rrule),
        avisoAntesMin: aviso == null ? const Value.absent() : Value(aviso < 0 ? null : aviso),
      ),
      id: c.id,
    );
    final partes = [
      if (titulo != null && titulo.isNotEmpty) 'título “${_capitalizar(titulo)}”',
      if (dia != null || hora != null || diaInteiro != null)
        '${diaRelativo(novoDia, hojeLocal())}${inteiro ? ', o dia todo' : ' às ${horaDe(h, m)}'}',
      if (fim != null) 'até ${horaDe(fim.$1, fim.$2)}',
      if (local != null) local.isEmpty ? 'sem local' : 'em $local',
      if (repeticao != null) repeticao == 'nao' ? 'sem repetição' : 'repete (${_regraCompromisso(repeticao, novoDia)?.descricao.toLowerCase()})',
      if (aviso != null) aviso < 0 ? 'sem aviso' : (aviso == 0 ? 'aviso na hora' : 'aviso $aviso min antes'),
    ];
    return _comDesfazer('Atualizei o compromisso “${c.titulo}”: ${partes.join(', ')}.', 'compromissos', c.toJson());
  }

  Future<ResultadoFerramenta> _treino(Map<String, Object?> e) async {
    final dias = _diasSemana(e['dias']);
    final itens = _exercicios(e['exercicios']);
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
    final texto = 'Criei o $nome${foco == null || foco.isEmpty ? '' : ' ($foco)'} com ${itens.length} '
        '${itens.length == 1 ? 'exercício' : 'exercícios'}, ${_rotuloDias(dias)}. Está em Saúde › Treino › Ficha.';
    return ResultadoFerramenta(texto, aviso: Resposta(texto, itemTipo: 'treino', itemId: id));
  }

  // --------------------------------------------------------------- edição
  //
  // Cada edição guarda a linha de antes (JSON) no itemId da confirmação, com
  // o tipo 'restaurar': "Desfazer" grava aquela linha de volta (`restaurar`).

  Future<Transacao?> _transacao(String id) =>
      (db.select(db.transacoes)..where((x) => x.id.equals(id) & x.apagadoEm.isNull())).getSingleOrNull();
  Future<Tarefa?> _tarefa(String id) =>
      (db.select(db.tarefas)..where((x) => x.id.equals(id) & x.apagadoEm.isNull())).getSingleOrNull();
  Future<Lembrete?> _lembreteDe(String id) =>
      (db.select(db.lembretes)..where((x) => x.id.equals(id) & x.apagadoEm.isNull())).getSingleOrNull();
  Future<Treino?> _treinoDe(String id) =>
      (db.select(db.treinos)..where((x) => x.id.equals(id) & x.apagadoEm.isNull())).getSingleOrNull();
  Future<Compromisso?> _compromissoDe(String id) =>
      (db.select(db.compromissos)..where((x) => x.id.equals(id) & x.apagadoEm.isNull())).getSingleOrNull();

  static const _naoAchei = 'Não achei esse registro (o id não confere ou ele foi excluído). '
      'Procure de novo com "buscar" ou "consultar".';

  Future<ResultadoFerramenta> _editarLancamento(Map<String, Object?> e) async {
    final t = await _transacao(_texto(e, 'id'));
    if (t == null) return const ResultadoFerramenta(_naoAchei, erro: true);
    final valor = _numero(e['valor']);
    final descricao = (e['descricao'] as String?)?.trim();
    final categoria = (e['categoria'] as String?)?.trim();
    final dia = _data(e['data']);
    final tipo = switch (e['tipo']) {
      'gasto' => TipoTransacao.saida,
      'receita' => TipoTransacao.entrada,
      _ => null,
    };
    if (valor == null && (descricao == null || descricao.isEmpty) && (categoria == null || categoria.isEmpty) &&
        dia == null && tipo == null) {
      return const ResultadoFerramenta('Diga o que mudar no lançamento: valor, descrição, categoria, data ou tipo.',
          erro: true);
    }
    if (dia != null && t.regraRepeticao != null) {
      return const ResultadoFerramenta(
          'Esse lançamento repete (conta fixa ou parcelado): a data dele não muda por aqui. '
          'Valor, descrição e categoria podem mudar.',
          erro: true);
    }
    var dados = TransacoesCompanion(
      valorCentavos: valor == null ? const Value.absent() : Value((valor * 100).round()),
      descricao: descricao == null || descricao.isEmpty ? const Value.absent() : Value(_capitalizar(descricao)),
      categoria: categoria == null || categoria.isEmpty ? const Value.absent() : Value(_capitalizar(categoria)),
      tipo: tipo == null ? const Value.absent() : Value(tipo),
    );
    if (dia != null) {
      // Como no formulário: pago muda a data e o pagamento; a pagar, o vencimento.
      dados = t.pagoEm != null
          ? dados.copyWith(data: Value(_instante(dia)), pagoEm: Value(_instante(dia)))
          : dados.copyWith(data: Value(instanteLocal(dia, 9)), vencimento: Value(instanteLocal(dia, 9)));
    }
    await FinancasRepo(db).salvar(dados, id: t.id);
    final partes = [
      if (tipo != null && tipo != t.tipo) tipo == TipoTransacao.entrada ? 'agora é receita' : 'agora é gasto',
      if (valor != null) 'valor ${reais((valor * 100).round())}',
      if (descricao != null && descricao.isNotEmpty) 'descrição “${_capitalizar(descricao)}”',
      if (categoria != null && categoria.isNotEmpty) 'categoria ${_capitalizar(categoria)}',
      if (dia != null) 'dia ${diaMesLongo(dia)}',
    ];
    final texto = 'Atualizei o lançamento “${t.descricao}”: ${partes.join(', ')}.'
        '${t.regraRepeticao != null && (valor != null || descricao != null) ? ' Vale para todas as ocorrências.' : ''}';
    return _comDesfazer(texto, 'transacoes', t.toJson());
  }

  Future<ResultadoFerramenta> _editarTarefa(Map<String, Object?> e) async {
    final t = await _tarefa(_texto(e, 'id'));
    if (t == null) return const ResultadoFerramenta(_naoAchei, erro: true);
    final titulo = (e['titulo'] as String?)?.trim();
    final dia = _data(e['data']);
    final hora = _hora(e['hora']);
    final semPrazo = e['sem_prazo'] == true;
    final concluida = e['concluida'] is bool ? e['concluida'] as bool : null;
    if ((titulo == null || titulo.isEmpty) && dia == null && hora == null && !semPrazo && concluida == null) {
      return const ResultadoFerramenta('Diga o que mudar na tarefa: título, data, hora, tirar o prazo ou concluir.',
          erro: true);
    }
    if (concluida != null && t.regraRepeticao != null) {
      return const ResultadoFerramenta(
          'Essa tarefa repete: cada dia é concluído na lista de Tarefas, não pela tarefa toda. '
          'Título, data e hora podem mudar.',
          erro: true);
    }
    final antes = t.prazo == null ? null : emLocal(t.prazo!);
    if (hora != null && dia == null && antes == null) {
      return const ResultadoFerramenta('A tarefa não tem data: diga o dia também.', erro: true);
    }
    var dados = t.toCompanion(false);
    if (titulo != null && titulo.isNotEmpty) dados = dados.copyWith(titulo: Value(_capitalizar(titulo)));
    if (semPrazo) {
      dados = dados.copyWith(prazo: const Value(null), prazoTemHora: const Value(false));
    } else if (dia != null || hora != null) {
      final d = dia ?? DateTime(antes!.year, antes.month, antes.day);
      final temHora = hora != null || (t.prazoTemHora && antes != null);
      final (h, m) = hora ?? (temHora ? (antes!.hour, antes.minute) : (0, 0));
      dados = dados.copyWith(prazo: Value(instanteLocal(d, h, m)), prazoTemHora: Value(temHora));
    }
    if (concluida != null) dados = dados.copyWith(feitaEm: Value(concluida ? DateTime.now() : null));
    final repo = TarefasRepo(db);
    final avisar = await repo.temLembrete(t.id);
    await repo.salvar(dados, id: t.id, avisar: avisar);

    final hoje = hojeLocal();
    final novoPrazo = dados.prazo.value == null ? null : emLocal(dados.prazo.value!);
    final partes = [
      if (titulo != null && titulo.isNotEmpty) 'título “${_capitalizar(titulo)}”',
      if (semPrazo) 'sem prazo',
      if (!semPrazo && novoPrazo != null && (dia != null || hora != null))
        'prazo ${diaRelativo(DateTime(novoPrazo.year, novoPrazo.month, novoPrazo.day), hoje)}'
            '${dados.prazoTemHora.value ? ' às ${horaDe(novoPrazo.hour, novoPrazo.minute)}' : ''}',
      if (concluida == true) 'marcada como feita',
      if (concluida == false) 'reaberta',
    ];
    return _comDesfazer('Atualizei a tarefa “${t.titulo}”: ${partes.join(', ')}.', 'tarefas', t.toJson(),
        extra: {'avisar': avisar});
  }

  Future<ResultadoFerramenta> _editarLembrete(Map<String, Object?> e) async {
    final l = await _lembreteDe(_texto(e, 'id'));
    if (l == null) return const ResultadoFerramenta(_naoAchei, erro: true);
    if (l.itemTipo == 'tarefa' || l.itemTipo == 'habito') {
      return ResultadoFerramenta(
          'Esse lembrete é o aviso de ${l.itemTipo == 'tarefa' ? 'uma tarefa' : 'um hábito'}: '
          'mude a ${l.itemTipo == 'tarefa' ? 'tarefa (editar_tarefa)' : 'hora do hábito na tela de Hábitos'}.',
          erro: true);
    }
    final texto = (e['texto'] as String?)?.trim();
    var dia = _data(e['data']);
    final hora = _hora(e['hora']);
    final repeticao = (e['repeticao'] as String?)?.trim();
    final ativo = e['ativo'] is bool ? e['ativo'] as bool : null;
    if ((texto == null || texto.isEmpty) && dia == null && hora == null && repeticao == null && ativo == null) {
      return const ResultadoFerramenta('Diga o que mudar no lembrete: texto, dia, hora, repetição ou o aviso.',
          erro: true);
    }
    final quando = emLocal(l.quando);
    final (h, m) = hora ?? (quando.hour, quando.minute);
    var regra = const Value<String?>.absent();
    String? descricaoRegra;
    if (repeticao != null && repeticao.isNotEmpty) {
      final r = normalizar(repeticao);
      if (r.contains('nao repet') || r.contains('sem repet') || r == 'nenhuma' || r == 'uma vez') {
        regra = const Value(null);
        descricaoRegra = 'sem repetição';
      } else {
        // A repetição em português passa pelo mesmo interpretador dos comandos.
        final agora = agoraLocal();
        final c = interpretar('me lembra de ${texto ?? l.texto} $repeticao às ${horaDe(h, m)}',
            hoje: dataLocal(agora), agora: agora);
        if (c is! CmdLembrete || c.regra == null) {
          return ResultadoFerramenta(
              'Não entendi a repetição "$repeticao". Use algo como "todo dia", "toda segunda e quarta" ou "todo dia 10".',
              erro: true);
        }
        regra = Value(c.regra!.rrule);
        descricaoRegra = c.regra!.descricao.toLowerCase();
        dia ??= c.dia;
      }
    }
    final novoDia = dia ?? DateTime(quando.year, quando.month, quando.day);
    await LembretesRepo(db).salvar(
      LembretesCompanion(
        texto: texto == null || texto.isEmpty ? const Value.absent() : Value(_capitalizar(texto)),
        quando: dia == null && hora == null ? const Value.absent() : Value(instanteLocal(novoDia, h, m)),
        regraRepeticao: regra,
        ativo: ativo == null ? const Value.absent() : Value(ativo),
      ),
      id: l.id,
    );
    final partes = [
      if (texto != null && texto.isNotEmpty) 'texto “${_capitalizar(texto)}”',
      if (dia != null || hora != null) '${rotuloDiaLembrete(novoDia, hojeLocal())} às ${horaDe(h, m)}',
      ?descricaoRegra,
      if (ativo == true) 'aviso ligado',
      if (ativo == false) 'aviso desligado',
    ];
    return _comDesfazer('Atualizei o lembrete “${l.texto}”: ${partes.join(', ')}.', 'lembretes', l.toJson());
  }

  Future<ResultadoFerramenta> _editarTreino(Map<String, Object?> e) async {
    final t = await _treinoDe(_texto(e, 'id'));
    if (t == null) return const ResultadoFerramenta(_naoAchei, erro: true);
    final nome = (e['nome'] as String?)?.trim();
    final foco = (e['foco'] as String?)?.trim();
    final dias = e['dias'] is List ? _diasSemana(e['dias']) : null;
    final itens = e['exercicios'] is List ? _exercicios(e['exercicios']) : null;
    if ((nome == null || nome.isEmpty) && foco == null && dias == null && itens == null) {
      return const ResultadoFerramenta('Diga o que mudar no treino: nome, foco, dias ou exercícios.', erro: true);
    }
    if (itens != null && itens.isEmpty) {
      return const ResultadoFerramenta('O treino precisa de pelo menos um exercício.', erro: true);
    }
    final dados = TreinosCompanion(
      nome: nome == null || nome.isEmpty ? const Value.absent() : Value(_capitalizar(nome)),
      foco: foco == null ? const Value.absent() : Value(foco.isEmpty ? null : foco),
      diasSemana: dias == null ? const Value.absent() : Value(dias),
    );
    // Os exercícios de antes, para "Desfazer" trazer a lista de volta.
    final antes = await (db.select(db.itensTreino)..where((i) => i.treinoId.equals(t.id) & i.apagadoEm.isNull())).get();
    if (itens == null) {
      await (db.update(db.treinos)..where((x) => x.id.equals(t.id)))
          .write(dados.copyWith(atualizadoEm: Value(DateTime.now())));
    } else {
      await SaudeRepo(db).salvarTreino(dados, itens, id: t.id);
    }
    final partes = [
      if (nome != null && nome.isNotEmpty) 'nome ${_capitalizar(nome)}',
      if (foco != null) foco.isEmpty ? 'sem foco' : 'foco $foco',
      if (dias != null) _rotuloDias(dias),
      if (itens != null) '${itens.length} ${itens.length == 1 ? 'exercício' : 'exercícios'} (${itens.map((x) => x.nome).join(', ')})',
    ];
    return _comDesfazer('Atualizei o ${t.nome}: ${partes.join('; ')}.', 'treinos', t.toJson(),
        extra: itens == null ? const {} : {'itens': [for (final i in antes) i.id]});
  }

  /// Paga ou desfaz o pagamento de uma conta: a única com vencimento ou uma
  /// ocorrência de fixa/parcelada (a do [vencimento]; sem ele, a última paga
  /// para desfazer e a mais antiga em aberto para pagar). A conta continua.
  Future<ResultadoFerramenta> _marcarPagamento(Map<String, Object?> e) async {
    final t = await _transacao(_texto(e, 'id'));
    if (t == null) return const ResultadoFerramenta(_naoAchei, erro: true);
    if (e['pago'] is! bool) return const ResultadoFerramenta('Diga se é para marcar como paga (true) ou não (false).', erro: true);
    final pago = e['pago'] as bool;
    final repo = FinancasRepo(db);
    final q = await repo.carregar();
    final hoje = hojeLocal();
    final dia = _data(e['vencimento']);
    final Ocorrencia? o;
    if (t.regraRepeticao == null) {
      if (t.vencimento == null) {
        return const ResultadoFerramenta(
            'Esse lançamento é um gasto ou receita direto, não uma conta com vencimento: não há pagamento para '
            'marcar. Para tirá-lo do extrato, use excluir_item.',
            erro: true);
      }
      o = Ocorrencia(transacao: t, vencimento: dataLocal(t.vencimento!), pagoEm: t.pagoEm);
    } else {
      final lista = q.ocorrencias(t, inicioDaRegra(t), somarDias(hoje, 62)).toList();
      o = dia != null
          ? lista.where((x) => x.vencimento == dia).firstOrNull
          : (pago ? lista.where((x) => !x.paga).firstOrNull : lista.where((x) => x.paga).lastOrNull);
    }
    if (o == null) {
      return ResultadoFerramenta(
          dia != null
              ? '“${t.descricao}” não vence em ${diaMesLongo(dia)}.'
              : (pago ? '“${t.descricao}” não tem conta em aberto.' : '“${t.descricao}” não tem nenhum pagamento feito.'),
          erro: true);
    }
    final quando = diaMesLongo(o.vencimento);
    if (o.paga == pago) {
      return ResultadoFerramenta('“${o.nome}” de $quando já estava ${pago ? 'paga' : 'em aberto'}; nada mudou.');
    }
    await repo.pagar(o, pago);
    final texto = pago
        ? 'Marquei “${o.nome}” de $quando como paga (${reais(o.valorCentavos)}). O saldo já foi atualizado.'
        : 'Desfiz o pagamento de “${o.nome}” de $quando (${reais(o.valorCentavos)}): saiu do extrato e voltou '
            'para as contas a pagar.';
    return ResultadoFerramenta(texto,
        aviso: Resposta(texto, itemTipo: 'pagamento', itemId: '${t.id}|${chaveData(o.vencimento)}|${pago ? 0 : 1}'));
  }

  /// Confirmação com "Desfazer" que devolve [linha] (como era) à [tabela].
  ResultadoFerramenta _comDesfazer(String texto, String tabela, Map<String, dynamic> linha,
      {Map<String, Object?> extra = const {}}) {
    final antes = jsonEncode({'tabela': tabela, 'linha': linha, ...extra});
    return ResultadoFerramenta(texto, aviso: Resposta(texto, itemTipo: 'restaurar', itemId: antes));
  }

  // ------------------------------------------------------------- exclusão

  /// Exclusão que não mudaria nada: a resposta vai direto para a IA, sem
  /// perguntar à pessoa. Hoje, encerrar de novo uma conta fixa já encerrada.
  Future<ResultadoFerramenta?> semNadaAExcluir(String nome, Map<String, Object?> e) async {
    if (nome != 'excluir_item' || e['tipo'] != 'lancamento' || e['apagar_pagos'] == true) return null;
    final t = await _transacao('${e['id']}');
    if (t == null) return null;
    final pagos = await FinancasRepo(db).pagamentosDe(t.id);
    final regra = Regra.ler(t.regraRepeticao);
    if (regra?.fim == null || pagos.isEmpty || regra!.fim!.isAfter(FinancasRepo.fimAoEncerrar(pagos))) return null;
    return ResultadoFerramenta(
        '“${t.descricao}” já está encerrada: não gera mais contas. O que continua aparecendo são os pagamentos já '
        'feitos (${_listaPagos(pagos)}). Para tirar também esses, chame excluir_item com apagar_pagos true '
        '(apaga de vez) ou marcar_pagamento com pago false (só desfaz o pagamento).',
        erro: true);
  }

  /// Pergunta mostrada à pessoa antes de excluir (o AssistenteRepo pede a
  /// confirmação). Nula se o registro não existe.
  Future<String?> perguntaDeExclusao(String nome, Map<String, Object?> e) async {
    final id = '${e['id']}';
    if (nome == 'excluir_item') {
      switch (e['tipo']) {
        case 'lancamento':
          final t = await _transacao(id);
          if (t == null) return null;
          if (t.regraRepeticao == null) {
            return 'Excluir ${_rotuloLancamento(t)} do dia ${diaMesLongo(dataLocal(t.data))}? '
                'Sai das contas e do extrato.';
          }
          final pagos = await FinancasRepo(db).pagamentosDe(t.id);
          if (e['apagar_pagos'] == true || pagos.isEmpty) {
            return 'Apagar de vez ${_rotuloLancamento(t)}, que repete'
                '${pagos.isEmpty ? '' : ', com ${_quantosPagos(pagos)} (${_listaPagos(pagos)})'}? '
                'Some das contas fixas, do extrato e do saldo.';
          }
          return 'Encerrar ${_rotuloLancamento(t)}, que repete? As próximas deixam de aparecer; '
              '${_quantosPagos(pagos)} (${_listaPagos(pagos)}) continua${pagos.length == 1 ? '' : 'm'} no extrato.';
        case 'tarefa':
          final t = await _tarefa(id);
          if (t == null) return null;
          return 'Excluir a tarefa “${t.titulo}”${t.regraRepeticao == null ? '' : ' e todas as repetições dela'}?';
        case 'lembrete':
          final l = await _lembreteDe(id);
          if (l == null) return null;
          final q = l.quando.toLocal();
          return 'Excluir o lembrete “${l.texto}” (${rotuloDiaLembrete(dataLocal(q), hojeLocal())}, ${hora(q)}'
              '${l.regraRepeticao == null ? '' : ', repete'})?';
        case 'treino':
          final t = await _treinoDe(id);
          if (t == null) return null;
          return 'Excluir o ${t.nome} da ficha? As sessões já feitas continuam no histórico.';
        case 'compromisso':
          final c = await _compromissoDe(id);
          if (c == null) return null;
          final i = emLocal(c.inicio);
          return 'Excluir o compromisso “${c.titulo}” (${diaRelativo(DateTime(i.year, i.month, i.day), hojeLocal())}'
              '${c.diaInteiro ? '' : ', ${hora(i)}'}${c.regraRepeticao == null ? '' : ', e todas as repetições'})?';
      }
      return null;
    }
    if (nome != 'excluir_registro_shape') return null;
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

  /// Exclui lançamento, tarefa, lembrete ou treino (a confirmação já foi dada).
  /// "Desfazer" traz a linha de volta como era.
  Future<ResultadoFerramenta> _excluirItem(Map<String, Object?> e) async {
    final id = _texto(e, 'id');
    switch (e['tipo']) {
      case 'lancamento':
        final t = await _transacao(id);
        if (t == null) break;
        final repo = FinancasRepo(db);
        final pagos = t.regraRepeticao == null ? const <PagamentoTransacao>[] : await repo.pagamentosDe(t.id);
        if (pagos.isNotEmpty && e['apagar_pagos'] != true) {
          // Conta fixa ou parcelada já paga: só encerra (como o "Encerrar" de Finanças).
          await repo.excluir(t);
          return _comDesfazer(
              'Encerrei ${_rotuloLancamento(t)}: as próximas não aparecem mais. ${_capitalizar(_quantosPagos(pagos))} '
              '(${_listaPagos(pagos)}) continua${pagos.length == 1 ? '' : 'm'} no extrato; se era teste, peça para '
              'apagar de vez.',
              'transacoes',
              t.toJson());
        }
        final apagados = pagos.isEmpty ? const <String>[] : await repo.apagarComPagamentos(t);
        if (pagos.isEmpty) await repo.excluir(t);
        return _comDesfazer(
            '${pagos.isEmpty ? 'Excluí' : 'Apaguei de vez'} ${_rotuloLancamento(t)}'
            '${pagos.isEmpty ? '' : ' e ${_quantosPagos(pagos)} (${_listaPagos(pagos)})'}. '
            'O saldo em Finanças já foi atualizado.',
            'transacoes',
            t.toJson(),
            extra: apagados.isEmpty ? const {} : {'pagamentos': apagados});
      case 'tarefa':
        final t = await _tarefa(id);
        if (t == null) break;
        final repo = TarefasRepo(db);
        final avisar = await repo.temLembrete(t.id);
        await repo.excluir(t.id);
        return _comDesfazer('Excluí a tarefa “${t.titulo}”.', 'tarefas', t.toJson(), extra: {'avisar': avisar});
      case 'lembrete':
        final l = await _lembreteDe(id);
        if (l == null) break;
        await LembretesRepo(db).excluir(l.id);
        return _comDesfazer('Excluí o lembrete “${l.texto}”.', 'lembretes', l.toJson());
      case 'treino':
        final t = await _treinoDe(id);
        if (t == null) break;
        await SaudeRepo(db).excluirTreino(t.id);
        return _comDesfazer('Excluí o ${t.nome} da ficha.', 'treinos', t.toJson());
      case 'compromisso':
        final c = await _compromissoDe(id);
        if (c == null) break;
        await CompromissosRepo(db).excluir(c.id);
        return _comDesfazer('Excluí o compromisso “${c.titulo}”.', 'compromissos', c.toJson());
    }
    return const ResultadoFerramenta(_naoAchei, erro: true);
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

  /// Um objetivo do app pelo nome: valor atual, alvo e/ou data.
  Future<ResultadoFerramenta> _metaApp(Map<String, Object?> e) async {
    final nome = _texto(e, 'nome_meta');
    final objetivos = await (db.select(db.objetivos)..where((o) => o.apagadoEm.isNull())).get();
    final alvo = normalizar(nome);
    final objetivo = objetivos.where((o) => normalizar(o.nome) == alvo).firstOrNull ??
        objetivos.where((o) => normalizar(o.nome).contains(alvo) || alvo.contains(normalizar(o.nome))).firstOrNull;
    if (objetivo == null) {
      return ResultadoFerramenta(
          'Não achei o objetivo "$nome". Os objetivos são: ${objetivos.map((o) => o.nome).join(', ')}.',
          erro: true);
    }
    final atual = _numero(e['valor_atual']), valorAlvo = _numero(e['valor_alvo']), data = _data(e['data_alvo']);
    if (atual == null && valorAlvo == null && data == null) {
      return const ResultadoFerramenta('Diga o que mudar no objetivo: valor atual, alvo ou data.', erro: true);
    }
    await ObjetivosRepo(db).salvar(
      ObjetivosCompanion(
        valorAtual: atual == null ? const Value.absent() : Value(atual),
        valorAlvo: valorAlvo == null ? const Value.absent() : Value(valorAlvo),
        dataAlvo: data == null ? const Value.absent() : Value(instanteLocal(data, 12)),
      ),
      id: objetivo.id,
    );
    final partes = [
      if (atual != null) 'agora em ${valorMeta(atual, objetivo.unidade)}',
      if (valorAlvo != null) 'alvo ${valorMeta(valorAlvo, objetivo.unidade)}',
      if (data != null) 'até ${diaMesLongo(data)}',
    ];
    final texto = 'Objetivo “${objetivo.nome}” atualizado: ${partes.join(', ')}.';
    final antes = '${objetivo.id}|${objetivo.valorAtual}|${objetivo.valorAlvo}|${objetivo.dataAlvo?.toIso8601String() ?? ''}';
    return ResultadoFerramenta(texto, aviso: Resposta(texto, itemTipo: 'meta', itemId: antes));
  }

  Future<ResultadoFerramenta> _buscar(String termo) async {
    final r = await buscarTudo(db, termo, porGrupo: 6);
    if (r.isEmpty) return ResultadoFerramenta('Nada encontrado para "$termo".');
    return ResultadoFerramenta([
      for (final x in r)
        '- ${x.titulo} (${x.detalhe}${x.direita == null ? '' : ', ${x.direita}'})'
            '${switch (x.item) { Transacao(regraRepeticao: final String r) => ', ${_rotuloRegra(r)}', _ => '' }}'
            '${_idDe(x.item) == null ? '' : ' (id ${_idDe(x.item)})'}',
    ].join('\n'));
  }

  /// Id da linha achada pela busca (categorias não têm).
  static String? _idDe(Object? item) => switch (item) {
        Tarefa(:final id) ||
        Lembrete(:final id) ||
        Compromisso(:final id) ||
        Transacao(:final id) ||
        Habito(:final id) ||
        Objetivo(:final id) ||
        Treino(:final id) ||
        Exercicio(:final id) =>
          id,
        _ => null,
      };

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

/// Hoje = agora; outro dia = meio-dia (como nos comandos rápidos).
DateTime _instante(DateTime dia) => dia == hojeLocal() ? DateTime.now() : instanteLocal(dia, 12);

const _bitsDias = {'seg': 1, 'ter': 2, 'qua': 4, 'qui': 8, 'sex': 16, 'sab': 32, 'dom': 64};

int _diasSemana(Object? v) => (v as List? ?? const []).fold<int>(0, (s, d) => s | (_bitsDias['$d'] ?? 0));

String _rotuloDias(int dias) =>
    dias == 0 ? 'sem dia fixo' : [for (final d in _bitsDias.entries) if (dias & d.value != 0) d.key].join(', ');

List<({String nome, int series, int repeticoes, double? cargaInicial})> _exercicios(Object? v) => [
      for (final x in (v as List? ?? const []).cast<Map<String, Object?>>())
        (
          nome: _capitalizar(_texto(x, 'nome')),
          series: _numero(x['series'])!.round(),
          repeticoes: _numero(x['repeticoes'])!.round(),
          cargaInicial: _numero(x['carga']),
        ),
    ];

/// "conta fixa, todo mês" ou "conta fixa encerrada".
String _rotuloRegra(String rrule) {
  final r = Regra.ler(rrule);
  if (r == null) return 'repete';
  return r.fim == null ? 'repete ${r.descricao.toLowerCase()}' : 'repetia, encerrada em ${diaMesCurto(r.fim!)}';
}

/// "1 pagamento já feito" / "2 pagamentos já feitos".
String _quantosPagos(List<PagamentoTransacao> pagos) =>
    pagos.length == 1 ? 'o pagamento já feito' : 'os ${pagos.length} pagamentos já feitos';

/// "R$ 50,00 de 18 out, R$ 50,00 de 18 set" (os mais novos primeiro).
String _listaPagos(List<PagamentoTransacao> pagos) {
  final lista = pagos.reversed.take(4).map((p) => '${reais(p.valorCentavos)} de ${diaMesCurto(DateTime.parse(p.vencimento))}');
  return '${lista.join(', ')}${pagos.length > 4 ? ' e mais ${pagos.length - 4}' : ''}';
}

/// "o gasto “Educação” de R$ 200,00".
String _rotuloLancamento(Transacao t) {
  final tipo = t.contaDestinoId != null
      ? 'a transferência'
      : (t.tipo == TipoTransacao.entrada ? 'a receita' : 'o gasto');
  return '$tipo “${t.descricao}” de ${reais(t.valorCentavos)}';
}

/// "Desfazer" de `marcar_pagamento`: "transacaoId|aaaa-mm-dd|1" volta a ocorrência
/// a paga (1) ou em aberto (0).
Future<void> desfazerPagamento(BancoAurora db, String itemId) async {
  final [id, venc, antes] = itemId.split('|');
  final t = await (db.select(db.transacoes)..where((x) => x.id.equals(id))).getSingleOrNull();
  if (t == null) return;
  await FinancasRepo(db).pagar(Ocorrencia(transacao: t, vencimento: DateTime.parse(venc)), antes == '1');
}

/// "Desfazer" de uma edição ou exclusão feita pela IA: grava de volta a linha
/// como era (o itemId 'restaurar' é o JSON de `_comDesfazer`).
Future<void> restaurar(BancoAurora db, String json) async {
  final e = jsonDecode(json) as Map<String, dynamic>;
  final linha = e['linha'] as Map<String, dynamic>;
  final agora = DateTime.now();
  switch (e['tabela']) {
    case 'transacoes':
      await db.update(db.transacoes).replace(Transacao.fromJson(linha).copyWith(atualizadoEm: agora));
      // Apagada de vez: os pagamentos voltam junto.
      final pagamentos = (e['pagamentos'] as List?)?.cast<String>();
      if (pagamentos != null) {
        await (db.update(db.pagamentosTransacao)..where((p) => p.id.isIn(pagamentos)))
            .write(PagamentosTransacaoCompanion(apagadoEm: const Value(null), atualizadoEm: Value(agora)));
      }
    case 'tarefas':
      // Pelo repositório, para o lembrete ligado à tarefa voltar junto.
      final t = Tarefa.fromJson(linha);
      await TarefasRepo(db).salvar(t.toCompanion(false), id: t.id, avisar: e['avisar'] == true);
    case 'lembretes':
      await db.update(db.lembretes).replace(Lembrete.fromJson(linha).copyWith(atualizadoEm: agora));
    case 'compromissos':
      await db.update(db.compromissos).replace(Compromisso.fromJson(linha).copyWith(atualizadoEm: agora));
    case 'treinos':
      final t = Treino.fromJson(linha);
      await db.transaction(() async {
        await db.update(db.treinos).replace(t.copyWith(atualizadoEm: agora));
        final itens = (e['itens'] as List?)?.cast<String>();
        if (itens == null) return;
        // A lista de exercícios mudou: apaga a nova e traz a antiga de volta.
        await (db.update(db.itensTreino)..where((i) => i.treinoId.equals(t.id) & i.apagadoEm.isNull() & i.id.isNotIn(itens)))
            .write(ItensTreinoCompanion(apagadoEm: Value(agora), atualizadoEm: Value(agora)));
        await (db.update(db.itensTreino)..where((i) => i.id.isIn(itens)))
            .write(ItensTreinoCompanion(apagadoEm: const Value(null), atualizadoEm: Value(agora)));
      });
  }
}

// ------------------------------------------------------------------ consulta

/// Dados detalhados de uma área, em texto, para a ferramenta "consultar".
/// Vai além do resumo mandado em toda pergunta (ver contexto_ia.dart).
Future<String> consultar(BancoAurora db, String area, {int dias = 30}) async {
  final hoje = hojeLocal();
  final desde = somarDias(hoje, -(dias - 1));
  final l = <String>['Período: últimos $dias dias (de ${diaMesCurto(desde)} a ${diaMesCurto(hoje)}).'];

  switch (area) {
    case 'tarefas':
      final q = await TarefasRepo(db).carregar();
      l.add('Em aberto: ${q.abertas} (${q.atrasadas} atrasadas).');
      for (final o in q.pendentes.take(40)) {
        final h = o.horario;
        l.add('- ${o.tarefa.titulo}: ${o.dia == null ? 'sem data' : diaRelativo(o.dia!, hoje)}'
            '${h == null ? '' : ' ${horaDe(h.hora, h.minuto)}'}${o.atrasada ? ', atrasada' : ''} (id ${o.tarefa.id})');
      }
      final feitas = q.tarefas.where((t) => t.feitaEm != null && !dataLocal(t.feitaEm!).isBefore(desde)).toList();
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
            ..where((t) => t.apagadoEm.isNull() & t.pagoEm.isNotNull() & t.regraRepeticao.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.data)])
            ..limit(25))
          .get();
      l.add('Lançamentos únicos recentes:');
      for (final t in recentes.where((t) => !dataLocal(t.data).isBefore(desde))) {
        l.add('- ${diaMesCurto(dataLocal(t.data))} ${t.descricao}${t.categoria == null ? '' : ' (${t.categoria})'}: '
            '${t.tipo == TipoTransacao.entrada ? '+' : '−'}${reais(t.valorCentavos)} (id ${t.id})');
      }
      // Contas fixas e parceladas: uma linha (o id) gera todas as ocorrências;
      // o que foi pago fica nos pagamentos de cada vencimento.
      final regras = q.transacoes.where((t) => t.regraRepeticao != null).toList()
        ..sort((a, b) => a.descricao.compareTo(b.descricao));
      if (regras.isNotEmpty) l.add('Contas fixas e parceladas (cada uma é UM lançamento que se repete):');
      for (final t in regras) {
        final regra = Regra.ler(t.regraRepeticao)!;
        final pagos = (q.pagamentos[t.id]?.values.toList() ?? [])..sort((a, b) => a.vencimento.compareTo(b.vencimento));
        l.add('- ${t.descricao}: ${t.tipo == TipoTransacao.entrada ? '+' : '−'}${reais(t.valorCentavos)} '
            '${regra.descricao.toLowerCase()}'
            '${regra.fim == null ? '' : ', encerrada (última em ${diaMesCurto(regra.fim!)})'}'
            '; ${pagos.isEmpty ? 'nenhuma paga' : 'pagas: ${_listaPagos(pagos)}'} (id ${t.id})');
      }

    case 'treino':
      final s = await SaudeRepo(db).carregar();
      if (s.treinos.isEmpty) l.add('Nenhum treino na ficha.');
      for (final t in s.treinos) {
        l.add('${t.titulo} (${_rotuloDias(t.treino.diasSemana)})'
            '${t.ultimaVez == null ? '' : ', feito por último em ${diaMesCurto(t.ultimaVez!)}'} (id ${t.treino.id}):');
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
        final d = somarDias(hoje, -i);
        final dia = await repo.carregarDia(d);
        final t = dia.total;
        String g(double v) => numero(v.roundToDouble());
        l.add('${diaRelativo(d, hoje)}: ${g(t.kcal)} kcal, P ${g(t.proteina)} g, C ${g(t.carboidrato)} g, G ${g(t.gordura)} g'
            '${dia.alvo == null ? '' : ' (alvo ${g(dia.alvo!.kcal)} kcal, P ${g(dia.alvo!.proteina)} g)'}'
            ', ${dia.registros.length} registros.');
      }

    case 'metas' || 'projetos' || 'objetivos':
      final objetivos = await ObjetivosRepo(db).carregar();
      if (objetivos.isEmpty) l.add('Nenhum objetivo.');
      for (final p in objetivos) {
        final o = p.objetivo;
        final medida = p.temNumero
            ? '${valorMeta(o.valorAtual, o.unidade)} de ${valorMeta(o.valorAlvo, o.unidade)}'
            : '${p.feitas} de ${p.total} etapas feitas';
        l.add('- ${o.nome}: $medida'
            '${o.dataAlvo == null ? '' : ' até ${diaMesCurto(dataLocal(o.dataAlvo!))}'}, ${p.estado.rotulo.toLowerCase()}.');
      }

    case 'lembretes':
      final q = await LembretesRepo(db).carregar();
      if (q.todos.isEmpty) l.add('Nenhum lembrete.');
      for (final x in q.proximos.take(30)) {
        final p = x.proxima!.toLocal();
        l.add('- ${x.lembrete.texto}: ${rotuloDiaLembrete(dataLocal(p), hoje)} ${hora(p)}${x.recorrente ? ' (repete)' : ''} (id ${x.lembrete.id})');
      }

    case 'compromissos':
      final q = await CompromissosRepo(db).carregar();
      if (q.todos.isEmpty) l.add('Nenhum compromisso.');
      // Os do período (para trás) e os dos próximos 60 dias.
      final mapa = q.porDia(desde, somarDias(hoje, 60));
      for (final d in mapa.keys.toList()..sort()) {
        for (final o in mapa[d]!.take(40)) {
          final c = o.compromisso;
          l.add('- ${c.titulo}: ${diaRelativo(d, hoje)}, ${o.horario.toLowerCase()}'
              '${c.local == null ? '' : ', em ${c.local}'}${o.regra == null ? '' : ', ${o.regra!.descricao.toLowerCase()}'}'
              '${c.avisoAntesMin == null ? ', sem aviso' : ', aviso ${c.avisoAntesMin} min antes'} (id ${c.id})');
        }
      }

    default:
      return 'Área desconhecida: $area.';
  }
  return l.join('\n');
}
