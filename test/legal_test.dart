import 'dart:io';

import 'package:aurora/core/tema.dart';
import 'package:aurora/ui/conta/legal_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget filho) => MaterialApp(theme: temaAurora(Brightness.dark), home: filho);

void main() {
  test('textos legais citam o que o app faz e só usam {{CONTATO}} como lacuna', () {
    final privacidade = File('assets/legal/privacidade.md').readAsStringSync();
    final termos = File('assets/legal/termos.md').readAsStringSync();
    for (final t in [privacidade, termos]) {
      expect(t.replaceAll('{{CONTATO}}', ''), isNot(contains('{{')));
      expect(t, contains('Excluir conta'));
    }
    for (final tema in ['dados sensíveis', 'Estados Unidos', 'Gemini', 'Shape', 'LGPD']) {
      expect(privacidade, contains(tema));
    }
    expect(termos, contains('TACO'));
  });

  testWidgets('abre a política de privacidade com títulos e itens', (t) async {
    t.view.physicalSize = const Size(900, 1600);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(_app(const LegalPage(DocumentoLegal.privacidade)));
    await t.pumpAndSettle();
    expect(find.text('Política de privacidade'), findsOneWidget);
    expect(find.text('Quem é o responsável'), findsOneWidget);
    expect(find.textContaining('{{CONTATO}}'), findsNothing);
  });

  testWidgets('aviso de aceite cita os dois textos', (t) async {
    await t.pumpWidget(_app(const Scaffold(body: AvisoAceite())));
    expect(find.textContaining('Termos de uso e com a Política de privacidade', findRichText: true), findsOneWidget);
  });

  testWidgets('links legais abrem os termos', (t) async {
    await t.pumpWidget(_app(const Scaffold(body: LinksLegais())));
    await t.tap(find.text('Termos de uso'));
    await t.pumpAndSettle();
    expect(find.text('O que é o Aurora'), findsOneWidget);
  });
}
