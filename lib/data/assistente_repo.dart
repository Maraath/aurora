import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FunctionException;

import '../core/comandos.dart';
import '../core/formato.dart';
import '../core/nuvem.dart';
import '../core/relogio.dart';
import 'alimentacao_repo.dart';
import 'banco.dart';
import 'catalogo_taco.dart';
import 'contexto_ia.dart';
import 'financas_repo.dart';
import 'habitos_repo.dart';
import 'lembretes_repo.dart';
import 'observar.dart';
import 'saude_repo.dart';
import 'tarefas_repo.dart';
import 'visao_repo.dart';

/// Frases de exemplo mostradas como atalhos na conversa.
const sugestoesAssistente = [
  'Resumo do meu dia',
  'Como estão meus gastos?',
  'Me lembra de ligar pro dentista amanhã às 10h',
  'Gastei 35 no mercado',
  'Fiz o cardio',
  'Pesei 74,5',
];

class Resposta {
  const Resposta(this.texto, {this.itemTipo, this.itemId});
  final String texto;
  final String? itemTipo;
  final String? itemId;
}

/// O que a IA devolve: a resposta e frases de comando rápido para executar.
class RespostaIa {
  const RespostaIa(this.resposta, this.comandos);
  final String resposta;
  final List<String> comandos;
}

/// Falha ao falar com a IA. [mensagem] já vem pronta para mostrar.
class ErroIa implements Exception {
  const ErroIa(this.mensagem, {this.semConexao = false});
  final String mensagem;
  final bool semConexao;
  @override
  String toString() => mensagem;
}

typedef ChamarIa = Future<RespostaIa> Function({
  required String pedido,
  required String contexto,
  required List<MensagemAssistente> historico,
});

/// Chama a Edge Function "assistente" com a sessão de quem está logado.
/// Nulo quando não há conta conectada (aí os pedidos esperam na fila).
ChamarIa? iaDaNuvem() {
  final cliente = nuvem;
  if (cliente == null || cliente.auth.currentSession == null) return null;
  return ({required pedido, required contexto, required historico}) async {
    try {
      final r = await cliente.functions.invoke('assistente', body: {
        'pedido': pedido,
        'contexto': contexto,
        'historico': [
          for (final m in historico)
            if (m.papel != PapelMensagem.sistema) {'papel': m.papel.name, 'texto': m.texto},
        ],
      }).timeout(const Duration(seconds: 45));
      final dados = r.data as Map<String, dynamic>;
      return RespostaIa(
        (dados['resposta'] as String?) ?? '',
        [for (final c in (dados['comandos'] as List? ?? const [])) '$c'],
      );
    } on FunctionException catch (e) {
      final detalhes = e.details;
      final erro = detalhes is Map ? detalhes['erro'] as String? : null;
      throw ErroIa(erro ?? 'A IA não respondeu (erro ${e.status}).');
    } on TimeoutException {
      throw const ErroIa('A IA demorou demais para responder. O pedido continua na fila.');
    } catch (e) {
      if (e is ErroIa) rethrow;
      debugPrint('IA: falha $e');
      throw ErroIa(mensagemDeErro(e), semConexao: true);
    }
  };
}

class AssistenteRepo {
  AssistenteRepo(this.db, {ChamarIa? Function()? ia, Future<CatalogoTaco> Function()? catalogo})
      : _ia = ia ?? iaDaNuvem,
        _catalogoTaco = catalogo ?? CatalogoTaco.carregar;
  final BancoAurora db;
  final ChamarIa? Function() _ia;
  final Future<CatalogoTaco> Function() _catalogoTaco;

  /// Verdadeiro enquanto a IA está respondendo (para a tela mostrar).
  static final pensando = ValueNotifier<bool>(false);

  Stream<List<MensagemAssistente>> observarConversa() =>
      observar(db, [db.mensagensAssistente], carregarConversa);

  Future<List<MensagemAssistente>> carregarConversa() =>
      (db.select(db.mensagensAssistente)
            ..where((m) => m.apagadoEm.isNull())
            ..orderBy([(m) => OrderingTerm(expression: m.criadoEm)]))
          .get();

  Future<int> tamanhoDaFila() async =>
      (await (db.select(db.mensagensAssistente)
                ..where((m) => m.apagadoEm.isNull() & m.naFila.equals(true)))
              .get())
          .length;

  /// Registra o pedido, executa se for comando rápido e responde. O que não
  /// for comando fica na fila da IA.
  Future<void> enviar(String texto) async {
    final limpo = texto.trim();
    if (limpo.isEmpty) return;
    final agora = agoraSP();
    final hoje = dataSP(agora);
    final comando = interpretar(limpo, hoje: hoje, agora: agora);

    await db.transaction(() async {
      await _gravar(PapelMensagem.eu, limpo, naFila: comando == null);
      if (comando == null) {
        if (_ia() == null) {
          await _gravar(PapelMensagem.sistema,
              'Guardei este pedido para a IA. Ela responde quando você entrar na conta '
              '(Mais › Conta e sincronização). Comandos rápidos funcionam sem conta.');
        }
        return;
      }
      final r = await _executar(comando, hoje, agora);
      await _gravar(PapelMensagem.aurora, r.texto, itemTipo: r.itemTipo, itemId: r.itemId);
    });
    if (comando == null) await processarFila(avisarFalha: true);
  }

  /// Mensagem de uma automação (modelo pronto), já com o texto montado.
  Future<void> mensagemDaAutomacao(String titulo, String texto) =>
      _gravar(PapelMensagem.aurora, '$titulo\n$texto');

  /// Automação personalizada: o pedido entra na fila da IA como se a pessoa
  /// tivesse pedido, e segue já se houver conexão.
  Future<void> pedidoDaAutomacao(String titulo, String pedido) async {
    await _gravar(PapelMensagem.eu, '$titulo: $pedido', naFila: true);
    await processarFila();
  }

  static bool _processando = false;

  /// Manda os pedidos da fila para a IA, do mais antigo ao mais novo. Para no
  /// primeiro erro (sem internet, limite do dia) e tenta de novo depois.
  /// [avisarFalha]: grava o motivo na conversa (só quando a pessoa acabou de pedir).
  Future<void> processarFila({bool avisarFalha = false}) async {
    final ia = _ia();
    if (ia == null || _processando) return;
    _processando = true;
    pensando.value = true;
    try {
      final fila = (await carregarConversa()).where((m) => m.naFila).toList();
      for (final pedido in fila) {
        final conversa = await carregarConversa();
        final antes = conversa.takeWhile((m) => m.id != pedido.id).toList();
        final RespostaIa r;
        final contexto = await montarContexto(db);
        try {
          r = await ia(
            pedido: pedido.texto,
            contexto: contexto,
            historico: antes.length > 10 ? antes.sublist(antes.length - 10) : antes,
          );
        } on ErroIa catch (e) {
          if (avisarFalha) {
            await _gravar(
                PapelMensagem.sistema,
                e.semConexao
                    ? 'Sem conexão: o pedido fica na fila e a IA responde quando a internet voltar.'
                    : e.mensagem);
          }
          return;
        }
        await (db.update(db.mensagensAssistente)..where((m) => m.id.equals(pedido.id))).write(
            MensagensAssistenteCompanion(naFila: const Value(false), atualizadoEm: Value(DateTime.now())));
        if (r.resposta.isNotEmpty) await _gravar(PapelMensagem.aurora, r.resposta);
        await _executarDaIa(r.comandos);
      }
    } finally {
      _processando = false;
      pensando.value = false;
    }
  }

  /// Executa os comandos que a IA propôs com o mesmo interpretador offline.
  Future<void> _executarDaIa(List<String> comandos) async {
    for (final texto in comandos) {
      final agora = agoraSP();
      final c = interpretar(texto, hoje: dataSP(agora), agora: agora);
      if (c == null || c is CmdResumoDia || c is CmdResumoFinancas) continue;
      final r = await _executar(c, dataSP(agora), agora);
      await _gravar(PapelMensagem.aurora, r.texto, itemTipo: r.itemTipo, itemId: r.itemId);
    }
  }

  /// A conversa é ordenada por `criadoEm`; o relógio pode repetir o mesmo
  /// instante entre a pergunta e a resposta, então ele só anda para a frente.
  static DateTime _ultimo = DateTime(2000);

  Future<void> _gravar(PapelMensagem papel, String texto,
      {bool naFila = false, String? itemTipo, String? itemId}) {
    var agora = DateTime.now();
    if (!agora.isAfter(_ultimo)) agora = _ultimo.add(const Duration(microseconds: 1));
    _ultimo = agora;
    return db.into(db.mensagensAssistente).insert(MensagensAssistenteCompanion.insert(
          papel: papel,
          texto: texto,
          naFila: Value(naFila),
          itemTipo: Value(itemTipo),
          itemId: Value(itemId),
          criadoEm: Value(agora),
        ));
  }

  Future<Resposta> _executar(Comando c, DateTime hoje, DateTime agora) async {
    switch (c) {
      case CmdDinheiro():
        final financas = FinancasRepo(db);
        final q = await financas.carregar();
        final instante = c.dia == hoje ? DateTime.now() : instanteSP(c.dia, 12);
        final id = await financas.salvar(TransacoesCompanion.insert(
          descricao: c.descricao,
          valorCentavos: c.centavos,
          tipo: c.entrada ? TipoTransacao.entrada : TipoTransacao.saida,
          data: instante,
          pagoEm: Value(instante),
          categoria: Value(c.categoria),
          contaId: Value(q.contaPrincipalId),
        ));
        final quando = c.dia == hoje ? 'hoje' : diaRelativo(c.dia, hoje);
        return Resposta(
          c.entrada
              ? 'Anotei a entrada de ${reais(c.centavos)} (“${c.descricao}”, ${c.categoria}), $quando.'
              : 'Anotei ${reais(c.centavos)} em “${c.descricao}” (${c.categoria}), $quando. '
                  'O saldo em Finanças já foi atualizado.',
          itemTipo: 'transacao',
          itemId: id,
        );

      case CmdLembrete():
        final l = await db.into(db.lembretes).insertReturning(LembretesCompanion.insert(
              texto: c.texto,
              quando: instanteSP(c.dia, c.hora, c.minuto),
              regraRepeticao: Value(c.regra?.rrule),
            ));
        final quando = c.regra != null
            ? '${c.regra!.descricao.toLowerCase()} às ${horaDe(c.hora, c.minuto)}, a partir de ${diaRelativo(c.dia, hoje)}'
            : '${diaRelativo(c.dia, hoje)} às ${horaDe(c.hora, c.minuto)}';
        return Resposta('Pronto: lembrete “${c.texto}” $quando. Está em Mais › Lembretes.',
            itemTipo: 'lembrete', itemId: l.id);

      case CmdTarefa():
        final prazo = c.dia == null ? null : instanteSP(c.dia!, c.hora ?? 0, c.minuto);
        final id = await TarefasRepo(db).salvar(
          TarefasCompanion.insert(
            titulo: c.titulo,
            prazo: Value(prazo),
            prazoTemHora: Value(c.dia != null && c.hora != null),
          ),
          avisar: false,
        );
        final quando = c.dia == null
            ? 'sem data'
            : '${diaRelativo(c.dia!, hoje)}${c.hora == null ? '' : ' às ${horaDe(c.hora!, c.minuto)}'}';
        return Resposta('Criei a tarefa “${c.titulo}”, $quando.', itemTipo: 'tarefa', itemId: id);

      case CmdHabito():
        final habitos = HabitosRepo(db);
        final q = await habitos.carregar();
        final h = _acharHabito(q.habitos, c.nome);
        if (h == null) {
          final nomes = q.habitos.map((h) => h.nome).join(', ');
          return Resposta('Não achei um hábito chamado “${c.nome}”.'
              '${nomes.isEmpty ? ' Você ainda não tem hábitos.' : ' Os seus são: $nomes.'}');
        }
        if (q.feito(h.id, hoje)) return Resposta('${h.nome} já estava marcado como feito hoje.');
        await habitos.alternar(h.id, hoje, true);
        final faltam = q.doDia(hoje).where((x) => x.id != h.id && !q.feito(x.id, hoje)).map((x) => x.nome);
        return Resposta(
          'Marquei ${h.nome} como feito hoje.${faltam.isEmpty ? ' Rotina de hoje completa.' : ' Falta: ${faltam.join(', ')}.'}',
          itemTipo: 'habito',
          itemId: '${h.id}|${chaveData(hoje)}',
        );

      case CmdMedida():
        final saude = SaudeRepo(db);
        final antes = (await saude.carregar()).ultima(c.tipo);
        await saude.salvarMedidas(hoje, [(tipo: c.tipo, valor: c.valor, unidade: c.unidade)]);
        final m = (await saude.carregar()).ultima(c.tipo)!;
        final dif = antes == null || antes.dia == m.dia ? null : c.valor - antes.valor;
        return Resposta(
          'Anotei ${c.tipo.toLowerCase()} ${numero(c.valor)} ${c.unidade} hoje'
          '${dif == null || dif == 0 ? '.' : ' (${dif > 0 ? '+' : '−'}${numero(dif.abs())} ${c.unidade} desde ${diaMesCurto(DateTime.parse(antes!.dia))}).'}',
          itemTipo: 'medida',
          itemId: m.id,
        );

      case CmdComida():
        return _comida(c, hoje, agora);

      case CmdResumoDia():
        return Resposta(await _resumoDia(hoje));

      case CmdResumoFinancas():
        return Resposta(await _resumoFinancas(hoje));
    }
  }

  Future<Resposta> _comida(CmdComida c, DateTime hoje, DateTime agora) async {
    final repo = AlimentacaoRepo(db, catalogo: _catalogoTaco);
    final busca = await repo.resolver(c.nome);
    final alimento = busca.alimento;
    if (alimento == null) {
      if (busca.opcoes.isNotEmpty) {
        return Resposta('Achei mais de uma opção na TACO para “${c.nome}”: '
            '${busca.opcoes.map((o) => o.nome).join('; ')}. '
            'Diga qual, por exemplo “comi 150 g de ${busca.opcoes.first.nome.toLowerCase()}”.');
      }
      return Resposta('Não achei “${c.nome}” nos seus alimentos nem na TACO. Cadastre em '
          'Hábitos › Alimentação (valores por 100 g) e peça de novo.');
    }
    double? gramas = c.gramas;
    if (gramas == null && c.porcoes != null) {
      final porcao = alimento.porcaoGramas;
      if (porcao != null) {
        gramas = c.porcoes! * porcao;
      } else if (c.porcoes! >= 10) {
        gramas = c.porcoes; // "comi 150 arroz": número grande sem unidade = gramas
      } else {
        return Resposta('Quantos gramas de ${alimento.nome}? Esse alimento não tem porção caseira; '
            'diga por exemplo “comi 150 g de ${alimento.nome.toLowerCase()}”.');
      }
    }
    final refeicao = c.refeicao == null ? Refeicao.pelaHora(agora.hour) : Refeicao.de(c.refeicao!);
    final id = await repo.registrar(dia: hoje, refeicao: refeicao, alimento: alimento, gramas: gramas!);
    final n = Nutrientes.de(alimento, gramas);
    final d = await repo.carregarDia(hoje);
    final total = d.total.kcal.round();
    return Resposta(
      'Anotei ${numero(gramas)} g de ${alimento.nome} no ${refeicao.rotulo.toLowerCase()}: '
      '${n.kcal.round()} kcal, ${numero((n.proteina * 10).round() / 10)} g de proteína. '
      'Hoje: $total${d.alvo == null ? '' : ' de ${d.alvo!.kcal.round()}'} kcal.',
      itemTipo: 'alimentacao',
      itemId: id,
    );
  }

  Habito? _acharHabito(List<Habito> habitos, String nome) {
    final alvo = normalizar(nome);
    for (final h in habitos) {
      if (normalizar(h.nome) == alvo) return h;
    }
    for (final h in habitos) {
      final n = normalizar(h.nome);
      if (n.contains(alvo) || alvo.contains(n)) return h;
    }
    return null;
  }

  Future<String> _resumoDia(DateTime hoje) async {
    final r = await VisaoRepo(db).carregar();
    final partes = <String>[];
    final faltam = r.habitos.where((h) => !h.feito).map((h) => h.habito.nome).toList();
    partes.add(r.habitos.isEmpty
        ? 'Nenhum hábito para hoje.'
        : (faltam.isEmpty ? 'Hábitos de hoje: todos feitos.' : 'Hábitos por fazer: ${faltam.join(', ')}.'));
    if (r.tarefasHoje.isNotEmpty) {
      final itens = r.tarefasHoje.map((o) {
        final h = o.horario;
        return h == null ? o.tarefa.titulo : '${o.tarefa.titulo} às ${horaDe(h.hora, h.minuto)}';
      });
      partes.add('Tarefas de hoje: ${itens.join(', ')}.');
    }
    if (r.tarefasAtrasadas > 0) {
      partes.add('${r.tarefasAtrasadas} ${r.tarefasAtrasadas == 1 ? 'tarefa atrasada' : 'tarefas atrasadas'}.');
    }
    if (r.contasAPagar > 0) {
      partes.add('${reais(r.aPagarCentavos)} em ${r.contasAPagar} ${r.contasAPagar == 1 ? 'conta' : 'contas'} a pagar.');
    }
    final treino = (await SaudeRepo(db).carregar()).treinoDoDia(hoje);
    if (treino != null) partes.add('Treino de hoje: ${treino.titulo}.');
    return 'Seu dia: ${partes.join(' ')}';
  }

  Future<String> _resumoFinancas(DateTime hoje) async {
    final q = await FinancasRepo(db).carregar();
    final mes = q.mes(hoje);
    final atrasadas = mes.aPagar.where((o) => o.atrasada(hoje)).toList();
    final partes = [
      'Em ${nomeDoMes(hoje).toLowerCase()} entrou ${reais(mes.entrouCentavos)} e saiu ${reais(mes.saiuCentavos)}.',
      if (mes.categorias.isNotEmpty)
        'O maior gasto foi ${mes.categorias.first.nome} (${reais(mes.categorias.first.centavos)}).',
      if (mes.contasAbertas > 0)
        'Faltam ${reais(mes.faltaPagarCentavos)} em ${mes.contasAbertas} '
            '${mes.contasAbertas == 1 ? 'conta' : 'contas'}'
            '${atrasadas.isEmpty ? '' : ', ${atrasadas.length} atrasada${atrasadas.length == 1 ? '' : 's'} (${atrasadas.map((o) => o.nome).join(', ')})'}.',
      'Saldo em conta: ${reais(q.saldoCentavos)}'
          '${mes.faltaPagarCentavos > 0 ? '; depois das contas sobram ${reais(q.saldoCentavos - mes.faltaPagarCentavos)}' : ''}.',
    ];
    return partes.join(' ');
  }

  /// Desfaz o que um comando criou.
  Future<void> desfazer(MensagemAssistente m) async {
    final id = m.itemId;
    if (id == null || m.desfeita) return;
    switch (m.itemTipo) {
      case 'transacao':
        final t = await (db.select(db.transacoes)..where((t) => t.id.equals(id))).getSingleOrNull();
        if (t != null) await FinancasRepo(db).excluir(t);
      case 'lembrete':
        await LembretesRepo(db).excluir(id);
      case 'tarefa':
        await TarefasRepo(db).excluir(id);
      case 'habito':
        final [habitoId, dia] = id.split('|');
        await HabitosRepo(db).alternar(habitoId, DateTime.parse(dia), false);
      case 'medida':
        await SaudeRepo(db).excluirMedida(id);
      case 'alimentacao':
        await AlimentacaoRepo(db).excluirRegistro(id);
    }
    await (db.update(db.mensagensAssistente)..where((x) => x.id.equals(m.id)))
        .write(MensagensAssistenteCompanion(desfeita: const Value(true), atualizadoEm: Value(DateTime.now())));
    await _gravar(PapelMensagem.sistema, 'Desfeito.');
  }

  /// Apaga a conversa (os itens criados continuam).
  Future<void> limparConversa() {
    final agora = DateTime.now();
    return (db.update(db.mensagensAssistente)..where((m) => m.apagadoEm.isNull()))
        .write(MensagensAssistenteCompanion(apagadoEm: Value(agora), atualizadoEm: Value(agora)));
  }
}
