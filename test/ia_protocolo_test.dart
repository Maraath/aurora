import 'dart:convert';

import 'package:aurora/data/ia/protocolo.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stream real gerado pela Vercel AI SDK 7 (toUIMessageStreamResponse) com uma
/// resposta em dois pedaços e uma chamada de ferramenta.
const _sse = '''data: {"type":"start"}

data: {"type":"start-step"}

data: {"type":"text-start","id":"t1"}

data: {"type":"text-delta","id":"t1","delta":"Vou anotar "}

data: {"type":"text-delta","id":"t1","delta":"isso."}

data: {"type":"text-end","id":"t1"}

data: {"type":"tool-input-available","toolCallId":"c1","toolName":"marcar_habito","input":{"nome":"Cardio"}}

data: {"type":"finish-step"}

data: {"type":"finish","finishReason":"tool-calls"}

data: [DONE]

''';

/// Bytes picados em pedaços pequenos, como chegam pela rede.
Stream<List<int>> _emPedacos(String s, int tamanho) async* {
  final bytes = utf8.encode(s);
  for (var i = 0; i < bytes.length; i += tamanho) {
    yield bytes.sublist(i, i + tamanho > bytes.length ? bytes.length : i + tamanho);
  }
}

void main() {
  test('lê texto, ferramenta e fim do protocolo da AI SDK, mesmo picado', () async {
    for (final tamanho in [1, 7, 4096]) {
      final eventos = await lerEventosSse(_emPedacos(_sse, tamanho)).toList();
      expect(eventos.whereType<TextoIa>().map((e) => e.delta).join(), 'Vou anotar isso.');
      final f = eventos.whereType<FerramentaIa>().single;
      expect(f.id, 'c1');
      expect(f.nome, 'marcar_habito');
      expect(f.entrada, {'nome': 'Cardio'});
      expect((eventos.last as FimIa).motivo, 'tool-calls');
    }
  });

  test('evento de erro vira ErroIa com a mensagem do servidor', () async {
    const sse = 'data: {"type":"text-delta","id":"t","delta":"Oi"}\n\n'
        'data: {"type":"error","errorText":"A IA chegou ao limite de pedidos por minuto."}\n\n';
    final eventos = <EventoIa>[];
    await expectLater(
      lerEventosSse(_emPedacos(sse, 5)).forEach(eventos.add),
      throwsA(isA<ErroIa>().having((e) => e.mensagem, 'mensagem', contains('limite'))),
    );
    expect(eventos.single, isA<TextoIa>());
  });

  test('acentos partidos entre pedaços continuam certos', () async {
    const sse = 'data: {"type":"text-delta","id":"t","delta":"ação é ótima"}\n\n'
        'data: {"type":"finish","finishReason":"stop"}\n\n';
    final eventos = await lerEventosSse(_emPedacos(sse, 3)).toList();
    expect((eventos.first as TextoIa).delta, 'ação é ótima');
  });

  test('stream que acaba sem "finish" é resposta cortada', () async {
    const sse = 'data: {"type":"start"}\n\ndata: {"type":"text-delta","id":"t","delta":"Pr"}\n\n';
    final eventos = <EventoIa>[];
    await expectLater(
      lerEventosSse(_emPedacos(sse, 8)).forEach(eventos.add),
      throwsA(isA<ErroIa>().having((e) => e.mensagem, 'mensagem', contains('caiu no meio'))),
    );
    expect((eventos.single as TextoIa).delta, 'Pr', reason: 'o que chegou continua valendo');
  });
}
