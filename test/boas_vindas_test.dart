import 'package:aurora/core/tema.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/exemplo.dart';
import 'package:aurora/ui/boas_vindas_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('primeira vez', () {
    late BancoAurora db;
    setUp(() => db = BancoAurora(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('aparelho novo começa vazio e vê as boas-vindas', () async {
      expect(await ehPrimeiraVez(db), isTrue);
      expect(await db.select(db.tarefas).get(), isEmpty);
    });

    test('depois das boas-vindas não aparecem mais', () async {
      await db.salvarPreferencia(chaveInicio, '2026-10-17');
      expect(await ehPrimeiraVez(db), isFalse);
    });

    test('aparelho de antes (com os dados de exemplo) não vê as boas-vindas', () async {
      await db.salvarPreferencia('exemplo_semeado', '2026-10-16');
      expect(await ehPrimeiraVez(db), isFalse);
    });
  });

  Future<void> montar(WidgetTester tester, {ValueChanged<String>? comecar, VoidCallback? entrar}) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: temaAurora(Brightness.dark),
      home: BoasVindasPage(aoComecar: comecar ?? (_) {}, aoEntrar: entrar ?? () {}),
    ));
  }

  testWidgets('Começar devolve o nome digitado', (tester) async {
    String? nome;
    await montar(tester, comecar: (n) => nome = n);
    expect(tester.takeException(), isNull);
    await tester.enterText(find.byType(TextField), '  Ana ');
    await tester.tap(find.text('Começar'));
    expect(nome, 'Ana');
  });

  testWidgets('Entrar na minha conta', (tester) async {
    var entrou = false;
    await montar(tester, entrar: () => entrou = true);
    await tester.tap(find.text('Entrar na minha conta'));
    expect(entrou, isTrue);
  });
}
