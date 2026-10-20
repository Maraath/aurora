/// Conversa com a Edge Function "assistente" no protocolo de UI da Vercel AI
/// SDK (o mesmo stream SSE que o hook useChat consome no navegador):
///
///   data: {"type":"text-delta","id":"t1","delta":"Vou anotar "}
///   data: {"type":"tool-input-available","toolCallId":"c1","toolName":"marcar_habito","input":{...}}
///   data: {"type":"error","errorText":"..."}
///   data: {"type":"finish","finishReason":"tool-calls"}
///   data: [DONE]
///
/// Aqui só se transforma o stream em [EventoIa]; quem decide o que fazer com
/// eles (gravar o texto, executar ferramentas, chamar de novo) é o
/// AssistenteRepo, que faz o papel do useChat.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../core/nuvem.dart';

sealed class EventoIa {
  const EventoIa();
}

/// Mais um pedaço do texto da resposta.
class TextoIa extends EventoIa {
  const TextoIa(this.delta);
  final String delta;
}

/// A IA quer usar uma ferramenta (o app executa e devolve o resultado).
class FerramentaIa extends EventoIa {
  const FerramentaIa({required this.id, required this.nome, required this.entrada});
  final String id;
  final String nome;
  final Map<String, Object?> entrada;
}

/// Fim da resposta ("stop", "tool-calls", "length"...).
class FimIa extends EventoIa {
  const FimIa(this.motivo);
  final String? motivo;
}

/// Falha ao falar com a IA. [mensagem] já vem pronta para mostrar.
class ErroIa implements Exception {
  const ErroIa(this.mensagem, {this.semConexao = false});
  final String mensagem;

  /// Sem internet: o pedido fica na fila e segue depois.
  final bool semConexao;

  /// O fornecedor da IA recusou por excesso de pedidos no minuto (passa logo).
  /// O texto vem da Edge Function (`mensagemDeErro` em index.ts). O limite do
  /// dia ("limite de 60 pedidos à IA hoje") é outro e não entra aqui.
  bool get limitePorMinuto => mensagem.contains('limite de pedidos por minuto');
  @override
  String toString() => mensagem;
}

/// Manda a conversa (formato ModelMessage da AI SDK) e o resumo dos dados;
/// devolve os eventos do stream. Lança [ErroIa].
/// [reserva]: usar o modelo reserva do servidor (o principal bateu no limite).
typedef TransporteIa = Stream<EventoIa> Function(List<Map<String, Object?>> mensagens, String contexto,
    {bool reserva});

/// Lê um stream SSE (bytes) e devolve os eventos que interessam ao app.
/// Pedaços desconhecidos (start, start-step, reasoning…) são ignorados.
///
/// Stream que termina SEM o evento "finish" é resposta cortada (a função caiu
/// ou passou do tempo no meio): vira [ErroIa], em vez de passar por resposta
/// completa (aparecia só "Pr" e nenhum aviso).
Stream<EventoIa> lerEventosSse(Stream<List<int>> bytes) async* {
  var terminou = false;
  await for (final linha in bytes.transform(utf8.decoder).transform(const LineSplitter())) {
    if (!linha.startsWith('data:')) continue;
    final dado = linha.substring(5).trim();
    if (dado.isEmpty || dado == '[DONE]') continue;
    final Object? json;
    try {
      json = jsonDecode(dado);
    } on FormatException {
      continue;
    }
    if (json is! Map<String, Object?>) continue;
    switch (json['type']) {
      case 'text-delta':
        final delta = json['delta'];
        if (delta is String && delta.isNotEmpty) yield TextoIa(delta);
      case 'tool-input-available':
        final entrada = json['input'];
        yield FerramentaIa(
          id: '${json['toolCallId']}',
          nome: '${json['toolName']}',
          entrada: entrada is Map<String, Object?> ? entrada : const {},
        );
      case 'error':
        throw ErroIa('${json['errorText'] ?? 'A IA não respondeu agora.'}');
      case 'finish':
        terminou = true;
        yield FimIa(json['finishReason'] as String?);
    }
  }
  if (!terminou) throw const ErroIa('A conexão com a IA caiu no meio da resposta.', semConexao: true);
}

/// Transporte de verdade: POST na Edge Function com a sessão de quem está
/// logado e leitura do stream. Nulo sem conta conectada (aí os pedidos
/// esperam na fila).
TransporteIa? iaDaNuvem() {
  final cliente = nuvem;
  final sessao = cliente?.auth.currentSession;
  if (cliente == null || sessao == null) return null;
  return (mensagens, contexto, {reserva = false}) async* {
    final http = HttpClient()..connectionTimeout = const Duration(seconds: 20);
    try {
      final HttpClientResponse r;
      try {
        final pedido = await http.postUrl(Uri.parse('$supabaseUrl/functions/v1/assistente'));
        pedido.headers
          ..set(HttpHeaders.authorizationHeader, 'Bearer ${cliente.auth.currentSession?.accessToken ?? sessao.accessToken}')
          ..set('apikey', supabaseAnonKey)
          ..contentType = ContentType.json
          ..set(HttpHeaders.acceptHeader, 'text/event-stream');
        if (reserva) pedido.headers.set('x-ia-reserva', '1');
        pedido.add(utf8.encode(jsonEncode({'mensagens': mensagens, 'contexto': contexto})));
        r = await pedido.close().timeout(const Duration(seconds: 30));
      } on SocketException catch (e) {
        debugPrint('IA: sem conexão ($e)');
        throw const ErroIa('Sem conexão com a internet.', semConexao: true);
      } on HandshakeException catch (e) {
        debugPrint('IA: falha de conexão segura ($e)');
        throw const ErroIa('Sem conexão com a internet.', semConexao: true);
      } on TimeoutException {
        throw const ErroIa('A IA demorou demais para responder. O pedido continua na fila.', semConexao: true);
      }

      if (r.statusCode != 200) {
        final corpo = await r.transform(utf8.decoder).join();
        String? erro;
        try {
          final j = jsonDecode(corpo);
          if (j is Map && j['erro'] is String) erro = j['erro'] as String;
        } on FormatException {
          // corpo não é JSON
        }
        throw ErroIa(erro ?? 'A IA não respondeu (erro ${r.statusCode}).');
      }
      // Sem nada chegando por 60 s, desiste (a conexão caiu no meio).
      yield* lerEventosSse(r.timeout(const Duration(seconds: 60), onTimeout: (s) {
        s.addError(const ErroIa('A conexão com a IA caiu no meio da resposta.', semConexao: true));
        s.close();
      }));
    } finally {
      http.close(force: true);
    }
  };
}
