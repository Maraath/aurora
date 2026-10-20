import 'package:aurora/core/tema.dart';
import 'package:aurora/ui/barra_rolagem.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  double opacidade(WidgetTester tester) => tester
      .widget<AnimatedOpacity>(find.descendant(of: find.byType(BarraRolagem), matching: find.byType(AnimatedOpacity)))
      .opacity;

  Future<void> montar(WidgetTester tester, ScrollController controle) async {
    await tester.binding.setSurfaceSize(const Size(400, 300));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
      theme: temaAurora(Brightness.dark),
      scrollBehavior: const RolagemAurora(),
      home: Scaffold(
        body: ListView(controller: controle, children: [for (var i = 0; i < 40; i++) SizedBox(height: 40, child: Text('$i'))]),
      ),
    ));
    await tester.pump();
  }

  testWidgets('aparece ao rolar, acende com o mouse e arrasta a lista', (tester) async {
    final controle = ScrollController();
    await montar(tester, controle);

    // Parada, sem rolar: escondida (a barra só existe depois das medidas da lista).
    expect(find.byType(AnimatedOpacity), findsOneWidget);
    expect(opacidade(tester), 0);

    controle.jumpTo(100);
    await tester.pump();
    expect(opacidade(tester), greaterThan(0));

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(200, 150));
    await mouse.moveTo(const Offset(394, 150));
    await tester.pump();
    expect(opacidade(tester), 1);

    // Arrastar a barra para baixo rola a lista.
    final antes = controle.offset;
    final dedo = await tester.startGesture(const Offset(394, 20), kind: PointerDeviceKind.mouse);
    await dedo.moveBy(const Offset(0, 60));
    await dedo.up();
    await tester.pump(const Duration(seconds: 2));
    expect(controle.offset, greaterThan(antes));
    await mouse.removePointer();
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));
}
