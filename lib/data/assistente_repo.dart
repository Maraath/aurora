import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../core/comandos.dart';
import '../core/formato.dart';
import '../core/nuvem.dart' show mensagemDeErro;
import '../core/relogio.dart';
import 'alimentacao_repo.dart';
import 'banco.dart';
import 'catalogo_taco.dart';
import 'contexto_ia.dart';
import 'financas_repo.dart';
import 'habitos_repo.dart';
import 'ia/ferramentas_ia.dart';
import 'ia/protocolo.dart';
import 'lembretes_repo.dart';
import 'metas_repo.dart';
import 'observar.dart';
import 'saude_repo.dart';
import 'tarefas_repo.dart';
import 'visao_repo.dart';

export 'ia/protocolo.dart' show ErroIa, EventoIa, FerramentaIa, FimIa, TextoIa, TransporteIa, iaDaNuvem;

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

/// Janela de memória: quanto da conversa vai para a IA a cada pedido. As
/// últimas mensagens até caberem em ~24 mil caracteres (uns 6 mil tokens),
/// sempre começando numa mensagem da pessoa. A Edge Function corta de novo.
const maxMensagensIa = 30;
const maxCaracteresIa = 24000;

/// Quantas voltas de ferramenta uma resposta pode dar (pedir, executar, seguir).
const maxVoltasFerramenta = 6;

/// A conversa gravada → mensagens no formato ModelMessage da AI SDK.
/// Avisos do sistema ficam de fora; mensagens seguidas do mesmo papel se
/// juntam (resposta + confirmação de ação, por exemplo).
List<Map<String, Object?>> mensagensParaIa(List<MensagemAssistente> conversa,
    {int maxMensagens = maxMensagensIa, int maxCaracteres = maxCaracteresIa}) {
  final lista = <({String papel, String texto})>[];
  for (final m in conversa) {
    if (m.papel == PapelMensagem.sistema || m.texto.trim().isEmpty) continue;
    final papel = m.papel == PapelMensagem.eu ? 'user' : 'assistant';
    final texto = m.desfeita ? '${m.texto} (desfeito depois)' : m.texto;
    if (lista.isNotEmpty && lista.last.papel == papel) {
      lista[lista.length - 1] = (papel: papel, texto: '${lista.last.texto}\n${texto.trim()}');
    } else {
      lista.add((papel: papel, texto: texto.trim()));
    }
  }
  var inicio = lista.length, total = 0;
  while (inicio > 0 && lista.length - inicio < maxMensagens) {
    final t = lista[inicio - 1].texto.length;
    if (total + t > maxCaracteres && inicio < lista.length) break;
    total += t;
    inicio--;
  }
  while (inicio < lista.length && lista[inicio].papel != 'user') {
    inicio++;
  }
  return [for (final m in lista.skip(inicio)) {'role': m.papel, 'content': m.texto}];
}

/// O "useChat" do Aurora: guarda a conversa, manda o histórico para a IA, mostra
/// a resposta chegando aos poucos (stream) e executa no aparelho as
/// ferramentas que a IA pedir. Comandos rápidos ("gastei 35 no mercado")
/// continuam saindo na hora, sem IA e sem internet.
/// Exclusão esperando a pessoa responder (cartão com "Excluir" e "Cancelar"
/// na conversa). A IA nunca apaga nada sem esse sim.
class PedidoConfirmacao {
  PedidoConfirmacao(this.pergunta);
  final String pergunta;
  final _resposta = Completer<bool>();
  Future<bool> get resposta => _resposta.future;
  void responder(bool sim) {
    if (!_resposta.isCompleted) _resposta.complete(sim);
  }
}

/// Ferramentas que apagam dados: só rodam depois do sim da pessoa.
const ferramentasDeExclusao = {'excluir_registro_shape', 'excluir_item'};

/// Ferramentas que só leem ou navegam: repetir não muda nada, então não entram
/// na proteção contra ação repetida.
const ferramentasSoDeLeitura = {'consultar', 'buscar', 'abrir_tela'};

/// O que aparece no indicador enquanto a ferramenta roda.
String etapaDaFerramenta(String nome) => switch (nome) {
      'consultar' || 'buscar' => 'Consultando seus dados...',
      'abrir_tela' => 'Abrindo a tela...',
      _ when ferramentasDeExclusao.contains(nome) => 'Excluindo...',
      _ => 'Atualizando seus dados...',
    };

class AssistenteRepo {
  AssistenteRepo(this.db,
      {TransporteIa? Function()? ia,
      Future<CatalogoTaco> Function()? catalogo,
      Future<bool> Function(String pergunta)? confirmar})
      : _ia = ia ?? iaDaNuvem,
        _catalogoTaco = catalogo ?? CatalogoTaco.carregar,
        _confirmar = confirmar ?? confirmarNaConversa;
  final BancoAurora db;
  final TransporteIa? Function() _ia;
  final Future<CatalogoTaco> Function() _catalogoTaco;
  final Future<bool> Function(String pergunta) _confirmar;

  /// Etapa do momento ("Atualizando seus dados..."); nula = só pensando.
  static final etapa = ValueNotifier<String?>(null);

  /// Exclusão esperando o sim da pessoa (a tela mostra o cartão).
  static final confirmacao = ValueNotifier<PedidoConfirmacao?>(null);

  /// Mostra o cartão e espera a resposta; sem resposta em 3 min, cancela.
  static Future<bool> confirmarNaConversa(String pergunta) async {
    final pedido = PedidoConfirmacao(pergunta);
    confirmacao.value = pedido;
    try {
      return await pedido.resposta.timeout(const Duration(minutes: 3), onTimeout: () => false);
    } finally {
      if (confirmacao.value == pedido) confirmacao.value = null;
    }
  }

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
    final agora = agoraLocal();
    final hoje = dataLocal(agora);
    var comando = interpretar(limpo, hoje: hoje, agora: agora);
    // Com a IA conectada, os resumos vão para ela: resposta conversada e
    // personalizada em vez do texto fixo (que continua valendo offline).
    if ((comando is CmdResumoDia || comando is CmdResumoFinancas) && _ia() != null) comando = null;

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
      final r = await executarComando(comando, hoje, agora);
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
        if (!await _responder(ia, pedido, avisarFalha: avisarFalha)) return;
      }
    } finally {
      _processando = false;
      pensando.value = false;
      etapa.value = null;
    }
  }

  /// Responde um pedido: manda a janela da conversa, grava o texto conforme
  /// chega e, quando a IA pede ferramentas, executa no aparelho e volta com os
  /// resultados até ela terminar. Falso se não deu para falar com a IA (o
  /// pedido continua na fila).
  /// Esta resposta já passou para o modelo reserva (fica nele até terminar).
  bool _reserva = false;

  /// Esperas entre as novas tentativas quando a IA bate no limite por minuto:
  /// a primeira é imediata (já no modelo reserva), as outras esperam a cota voltar.
  @visibleForTesting
  static List<Duration> esperasLimite = const [Duration.zero, Duration(seconds: 20), Duration(seconds: 40)];

  Future<bool> _responder(TransporteIa ia, MensagemAssistente pedido, {required bool avisarFalha}) async {
    final conversa = await carregarConversa();
    final ate = conversa.indexWhere((m) => m.id == pedido.id);
    final mensagens = mensagensParaIa(conversa.sublist(0, ate + 1));
    final ferramentas = FerramentasIa(db, this);
    var comecou = false;
    _reserva = false;
    // Ações já feitas nesta resposta (ferramenta + entrada). Um modelo da fila
    // às vezes pede de novo, numa volta seguinte, o que outro já fez (o mesmo
    // lembrete saía duas vezes): a repetição não roda, só avisa a IA.
    final feitas = <String, ResultadoFerramenta>{};

    for (var volta = 0; volta <= maxVoltasFerramenta; volta++) {
      final contexto = await montarContexto(db);
      final texto = StringBuffer();
      final chamadas = <FerramentaIa>[];
      String? idResposta;
      var ultimaGravacao = DateTime(2000);

      Future<void> gravarTexto({bool forcar = false}) async {
        final agora = DateTime.now();
        if (!forcar && agora.difference(ultimaGravacao) < const Duration(milliseconds: 60)) return;
        ultimaGravacao = agora;
        if (idResposta == null) {
          idResposta = await _gravar(PapelMensagem.aurora, texto.toString());
        } else {
          await (db.update(db.mensagensAssistente)..where((m) => m.id.equals(idResposta!))).write(
              MensagensAssistenteCompanion(texto: Value(texto.toString()), atualizadoEm: Value(agora)));
        }
      }

      // Limite por minuto antes de chegar qualquer coisa: tenta de novo sozinho,
      // primeiro já com o modelo reserva (cota separada) e depois esperando.
      for (var tentativa = 0;; tentativa++) {
        try {
          await for (final evento in ia(mensagens, contexto, reserva: _reserva)) {
            if (!comecou) {
              comecou = true;
              await _tirarDaFila(pedido.id);
            }
            switch (evento) {
              case TextoIa(:final delta):
                pensando.value = false;
                etapa.value = null;
                texto.write(delta);
                await gravarTexto();
              case FerramentaIa():
                chamadas.add(evento);
              case FimIa():
                break;
            }
          }
          break;
        } catch (e) {
          final erro = e is ErroIa ? e : ErroIa(mensagemDeErro(e), semConexao: true);
          final nadaChegou = texto.isEmpty && chamadas.isEmpty;
          if (erro.limitePorMinuto && nadaChegou && tentativa < esperasLimite.length) {
            _reserva = true;
            final espera = esperasLimite[tentativa];
            etapa.value = espera == Duration.zero
                ? 'A IA está cheia de pedidos; tentando de novo...'
                : 'A IA está cheia de pedidos; tentando de novo em ${espera.inSeconds} s...';
            pensando.value = true;
            await Future<void>.delayed(espera);
            continue;
          }
          if (texto.isNotEmpty) await gravarTexto(forcar: true);
          if (!comecou) {
            if (avisarFalha) {
              await _gravar(
                  PapelMensagem.sistema,
                  erro.semConexao
                      ? 'Sem conexão: o pedido fica na fila e a IA responde quando a internet voltar.'
                      : erro.mensagem);
            }
            return false;
          }
          // Caiu depois de começar: o que já foi feito e o que chegou ficam.
          await _gravar(
              PapelMensagem.sistema,
              nadaChegou && volta > 0
                  ? 'A IA não conseguiu terminar a resposta: ${erro.mensagem} O que ela já fez ficou salvo.'
                  : 'A resposta parou no meio: ${erro.mensagem}');
          return true;
        }
      }
      if (texto.isNotEmpty) await gravarTexto(forcar: true);
      if (chamadas.isEmpty) return true;

      // A IA pediu ferramentas: executa aqui e volta com os resultados.
      pensando.value = true;
      if (volta == maxVoltasFerramenta) {
        await _gravar(PapelMensagem.sistema, 'A IA tentou fazer coisas demais de uma vez; parei por aqui.');
        return true;
      }
      final resultados = <Map<String, Object?>>[];
      for (final c in chamadas) {
        final ResultadoFerramenta r;
        final chave = '${c.nome}|${jsonEncode(c.entrada)}';
        final jaFeita = ferramentasSoDeLeitura.contains(c.nome) ? null : feitas[chave];
        final nadaAExcluir = jaFeita == null && ferramentasDeExclusao.contains(c.nome)
            ? await ferramentas.semNadaAExcluir(c.nome, c.entrada)
            : null;
        if (jaFeita != null) {
          r = ResultadoFerramenta(
              'Isso já foi feito agora há pouco, nesta mesma resposta (resultado: ${jaFeita.paraIa}). '
              'Não repita a ação: só confirme para a pessoa o que foi feito.');
        } else if (nadaAExcluir != null) {
          // Excluir não mudaria nada: a IA fica sabendo, sem perguntar à pessoa.
          r = nadaAExcluir;
        } else if (ferramentasDeExclusao.contains(c.nome)) {
          // Exclusão: a pessoa confirma num cartão antes de qualquer coisa sumir.
          final pergunta = await ferramentas.perguntaDeExclusao(c.nome, c.entrada);
          etapa.value = null;
          pensando.value = false;
          final sim = pergunta != null && await _confirmar(pergunta);
          pensando.value = true;
          etapa.value = sim ? etapaDaFerramenta(c.nome) : null;
          r = pergunta == null
              ? const ResultadoFerramenta('Esse registro não existe (o id não confere). Consulte de novo.', erro: true)
              : sim
                  ? await ferramentas.executar(c.nome, c.entrada)
                  : const ResultadoFerramenta('A pessoa cancelou a exclusão. Nada foi apagado.');
        } else {
          etapa.value = etapaDaFerramenta(c.nome);
          r = await ferramentas.executar(c.nome, c.entrada);
        }
        if (jaFeita == null && !r.erro) feitas[chave] = r;
        final aviso = r.aviso;
        if (aviso != null) {
          await _gravar(PapelMensagem.aurora, aviso.texto, itemTipo: aviso.itemTipo, itemId: aviso.itemId);
        }
        resultados.add({
          'type': 'tool-result',
          'toolCallId': c.id,
          'toolName': c.nome,
          'output': {'type': r.erro ? 'error-text' : 'text', 'value': r.paraIa},
        });
      }
      mensagens
        ..add({
          'role': 'assistant',
          'content': [
            if (texto.isNotEmpty) {'type': 'text', 'text': texto.toString()},
            for (final c in chamadas) {'type': 'tool-call', 'toolCallId': c.id, 'toolName': c.nome, 'input': c.entrada},
          ],
        })
        ..add({'role': 'tool', 'content': resultados});
    }
    return true;
  }

  Future<void> _tirarDaFila(String id) => (db.update(db.mensagensAssistente)..where((m) => m.id.equals(id)))
      .write(MensagensAssistenteCompanion(naFila: const Value(false), atualizadoEm: Value(DateTime.now())));

  /// A conversa é ordenada por `criadoEm`; o relógio pode repetir o mesmo
  /// instante entre a pergunta e a resposta, então ele só anda para a frente.
  static DateTime _ultimo = DateTime(2000);

  /// Grava uma mensagem e devolve o id.
  Future<String> _gravar(PapelMensagem papel, String texto,
      {bool naFila = false, String? itemTipo, String? itemId}) async {
    var agora = DateTime.now();
    if (!agora.isAfter(_ultimo)) agora = _ultimo.add(const Duration(microseconds: 1));
    _ultimo = agora;
    final m = await db.into(db.mensagensAssistente).insertReturning(MensagensAssistenteCompanion.insert(
          papel: papel,
          texto: texto,
          naFila: Value(naFila),
          itemTipo: Value(itemTipo),
          itemId: Value(itemId),
          criadoEm: Value(agora),
        ));
    return m.id;
  }

  /// Executa um comando rápido (vindo do texto ou de uma ferramenta da IA) e
  /// devolve a confirmação.
  Future<Resposta> executarComando(Comando c, DateTime hoje, DateTime agora) async {
    switch (c) {
      case CmdDinheiro():
        final financas = FinancasRepo(db);
        final q = await financas.carregar();
        final instante = c.dia == hoje ? DateTime.now() : instanteLocal(c.dia, 12);
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
              quando: instanteLocal(c.dia, c.hora, c.minuto),
              regraRepeticao: Value(c.regra?.rrule),
            ));
        final quando = c.regra != null
            ? '${c.regra!.descricao.toLowerCase()} às ${horaDe(c.hora, c.minuto)}, a partir de ${diaRelativo(c.dia, hoje)}'
            : '${diaRelativo(c.dia, hoje)} às ${horaDe(c.hora, c.minuto)}';
        return Resposta('Pronto: lembrete “${c.texto}” $quando. Está em Mais › Lembretes.',
            itemTipo: 'lembrete', itemId: l.id);

      case CmdTarefa():
        final prazo = c.dia == null ? null : instanteLocal(c.dia!, c.hora ?? 0, c.minuto);
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
      case 'treino':
        await SaudeRepo(db).excluirTreino(id);
      case 'medida_excluida':
        await (db.update(db.medidas)..where((x) => x.id.equals(id)))
            .write(MedidasCompanion(apagadoEm: const Value(null), atualizadoEm: Value(DateTime.now())));
      case 'alvo_dieta':
        // "treino:kcal:p:c:g;descanso:-" → volta cada dia ao que era (ou apaga).
        final alimentacao = AlimentacaoRepo(db);
        for (final parte in id.split(';')) {
          final [tipo, ...v] = parte.split(':');
          final t = TipoDia.values.byName(tipo);
          if (v.first == '-') {
            await (db.update(db.alvosDieta)..where((a) => a.tipoDia.equals(tipo))).write(
                AlvosDietaCompanion(apagadoEm: Value(DateTime.now()), atualizadoEm: Value(DateTime.now())));
          } else {
            final n = v.map(double.parse).toList();
            await alimentacao.salvarAlvo(t, Nutrientes(n[0], n[1], n[2], n[3]));
          }
        }
      case 'meta':
        final [metaId, atual, alvo, data] = id.split('|');
        await MetasRepo(db).salvar(
          MetasCompanion(
            valorAtual: Value(double.parse(atual)),
            valorAlvo: Value(double.parse(alvo)),
            dataAlvo: Value(data.isEmpty ? null : DateTime.parse(data)),
          ),
          id: metaId,
        );
      case 'alimentacao':
        await AlimentacaoRepo(db).excluirRegistro(id);
      case 'restaurar':
        // Edição ou exclusão feita pela IA: a linha volta a ser como era.
        await restaurar(db, id);
      case 'pagamento':
        await desfazerPagamento(db, id);
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
