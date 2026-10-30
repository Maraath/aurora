import 'package:aurora/core/tema.dart';
import 'package:aurora/ui/janela/moldura_janela.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final chamadas = <MethodCall>[];

  setUp(() {
    chamadas.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(JanelaWindows.canal, (chamada) async {
      chamadas.add(chamada);
      return chamada.method == 'estado' ? {'maximizada': false, 'ativa': true} : null;
    });
  });

  Future<void> montar(WidgetTester tester, {required bool escuro}) async {
    await tester.pumpWidget(MaterialApp(
      theme: temaAurora(escuro ? Brightness.dark : Brightness.light),
      builder: (context, filho) => MolduraJanela(ativa: true, child: filho!),
      home: Scaffold(
        body: SafeArea(
          child: Builder(
            builder: (context) => Text('topo ${MediaQuery.paddingOf(context).top}'),
          ),
        ),
      ),
    ));
    await tester.pump();
  }

  testWidgets('conteúdo começa abaixo da barra e os botões chamam a janela', (tester) async {
    await montar(tester, escuro: true);

    // Dentro da SafeArea o padding já foi consumido; o texto fica abaixo da barra.
    expect(tester.getTopLeft(find.textContaining('topo')).dy, greaterThanOrEqualTo(alturaBarraJanela));
    expect(find.bySemanticsLabel('Minimizar'), findsOneWidget);
    expect(find.bySemanticsLabel('Maximizar'), findsOneWidget);
    expect(find.bySemanticsLabel('Fechar'), findsOneWidget);
    expect(chamadas.where((c) => c.method == 'tema').single.arguments, isTrue);

    await tester.tap(find.bySemanticsLabel('Minimizar'));
    await tester.tap(find.bySemanticsLabel('Fechar'));
    expect(chamadas.map((c) => c.method), containsAllInOrder(['minimizar', 'fechar']));
  });

  testWidgets('maximizada mostra Restaurar; modo claro avisa a janela', (tester) async {
    await montar(tester, escuro: false);
    expect(chamadas.where((c) => c.method == 'tema').last.arguments, isFalse);

    JanelaWindows.instancia.maximizada.value = true;
    await tester.pump();
    expect(find.bySemanticsLabel('Restaurar'), findsOneWidget);
    JanelaWindows.instancia.maximizada.value = false;
  });

  testWidgets('sem a moldura (testes e outras plataformas) nada muda', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: temaAurora(Brightness.dark),
      builder: (context, filho) => MolduraJanela(child: filho!),
      home: const Scaffold(body: Text('oi')),
    ));
    expect(find.bySemanticsLabel('Fechar'), findsNothing);
  });

  test('JanelaWindows suporta métodos de bandeja e encerramento', () async {
    await JanelaWindows.instancia.sair();
    await JanelaWindows.instancia.restaurar();
    await JanelaWindows.instancia.ocultar();
    await JanelaWindows.instancia.configurarFecharParaBandeja(true);

    expect(chamadas.map((c) => c.method), containsAll(['sair', 'restaurar', 'ocultar', 'fecharParaBandeja']));
  });
}
