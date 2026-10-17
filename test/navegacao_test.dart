import 'package:aurora/app.dart';
import 'package:aurora/core/relogio.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/exemplo.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Percorre as áreas pelo menu lateral (computador) e pela tela "Mais"
/// (celular), conferindo que cada uma monta sem erro de layout.
void main() {
  late BancoAurora db;

  setUpAll(() async {
    iniciarRelogio();
    await initializeDateFormatting('pt_BR');
  });

  setUp(() => db = BancoAurora(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> abrirApp(WidgetTester tester, Size tamanho) async {
    tester.view.physicalSize = tamanho;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(() => semearExemplo(db));
    await tester.pumpWidget(AuroraApp(db: db, escuro: ValueNotifier(true)));
    await assentar(tester);
  }

  Future<void> tocar(WidgetTester tester, Finder alvo) async {
    await tester.tap(alvo.first);
    await assentar(tester);
    expect(tester.takeException(), isNull);
  }

  testWidgets('computador: todas as áreas no menu lateral', (tester) async {
    await abrirApp(tester, const Size(1280, 860));
    for (final area in ['Tarefas', 'Hábitos', 'Metas', 'Projetos', 'Finanças', 'Assistente', 'Visão']) {
      await tocar(tester, find.bySemanticsLabel(area));
    }
    // Abas novas (Análise e Parceladas).
    await tocar(tester, find.bySemanticsLabel('Tarefas'));
    await tocar(tester, find.text('Análise'));
    await tocar(tester, find.bySemanticsLabel('Hábitos'));
    await tocar(tester, find.text('Análise'));
    await tocar(tester, find.bySemanticsLabel('Finanças'));
    await tocar(tester, find.text('Parceladas'));
    await tocar(tester, find.text('Análise'));
    await tocar(tester, find.bySemanticsLabel('Saúde'));
    for (final aba in ['Alimentação', 'Medidas', 'Exercícios', 'Treino']) {
      await tocar(tester, find.text(aba));
    }
    await tocar(tester, find.bySemanticsLabel('Lembretes'));
    await tocar(tester, find.text('Automações'));
    await tocar(tester, find.bySemanticsLabel('Conta e sincronização'));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('celular: áreas fora da barra ficam em Mais', (tester) async {
    await abrirApp(tester, const Size(390, 844));
    for (final area in ['Saúde', 'Lembretes', 'Metas', 'Projetos', 'Conta e sincronização']) {
      await tocar(tester, find.text('Mais'));
      await tocar(tester, find.text(area));
    }
    // Finanças tem 6 abas: no celular a barra rola de lado até a Análise.
    await tocar(tester, find.text('Finanças'));
    await tester.ensureVisible(find.text('Análise'));
    await tocar(tester, find.text('Análise'));
    expect(find.text('Gasto no mês'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}

/// Os repositórios respondem por streams do banco: deixa o tempo correr de
/// verdade antes de redesenhar.
Future<void> assentar(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 80)));
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 300));
}
