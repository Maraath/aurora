import 'package:aurora/app.dart';
import 'package:aurora/core/relogio.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/exemplo.dart';
import 'package:aurora/ui/componentes.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Percorre as áreas pelo menu lateral (computador) e pela barra flutuante
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
    for (final area in ['Rotina', 'Objetivos', 'Anotações', 'Finanças', 'Assistente', 'Visão']) {
      await tocar(tester, find.bySemanticsLabel(area));
    }
    // Rotina: as abas, o calendário em mês e semana e a análise dos dois tipos.
    await tocar(tester, find.bySemanticsLabel('Rotina'));
    // Hoje: Timeblocking do dia lado a lado.
    expect(find.text('CAPACIDADE DO SEU DIA'), findsOneWidget);
    expect(find.text('Linha do Tempo de Hoje'), findsOneWidget);
    await tocar(tester, find.text('Calendário'));
    expect(find.text('Compromisso neste dia'), findsOneWidget);
    await tocar(tester, find.text('Semana'));
    expect(find.text('dia\ntodo'), findsOneWidget);
    await tocar(tester, find.text('Hábitos'));
    expect(find.text('Constância'), findsOneWidget);
    await tocar(tester, find.text('Análise'));
    expect(find.text('Concluídas nos últimos 7 dias'), findsOneWidget);
    await tocar(tester, find.text('Hábitos').last);
    expect(find.text('Constância nos últimos 30 dias'), findsOneWidget);
    await tocar(tester, find.bySemanticsLabel('Finanças'));
    await tocar(tester, find.text('Parceladas'));
    await tocar(tester, find.text('Análise'));
    await tocar(tester, find.bySemanticsLabel('Saúde'));
    for (final aba in ['Alimentação', 'Treino']) {
      await tocar(tester, find.text(aba));
    }
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Saúde: Medidas e Exercícios ficam dentro de Treino', (tester) async {
    await abrirApp(tester, const Size(1280, 860));
    await tocar(tester, find.bySemanticsLabel('Saúde'));
    // No topo, só Treino e Alimentação; Treino abre na ficha.
    expect(find.text('Alimentação'), findsOneWidget);
    expect(find.text('Ficha de treino'), findsOneWidget);
    await tocar(tester, find.text('Medidas'));
    expect(find.text('Ficha de treino'), findsNothing);
    expect(find.text('Medidas'), findsNWidgets(2)); // a pílula e o título da tela
    await tocar(tester, find.text('Exercícios'));
    expect(find.text('Biblioteca de exercícios'), findsOneWidget);
    // A subseção sobrevive a uma ida até Alimentação.
    await tocar(tester, find.text('Alimentação'));
    expect(find.text('Biblioteca de exercícios'), findsNothing);
    await tocar(tester, find.text('Treino'));
    expect(find.text('Biblioteca de exercícios'), findsOneWidget);
    await tocar(tester, find.text('Ficha'));
    expect(find.text('Ficha de treino'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('celular: Saúde › Treino troca de subseção', (tester) async {
    await abrirApp(tester, const Size(390, 844));
    await tocar(tester, find.bySemanticsLabel('Saúde'));
    // Se as pílulas não couberem na largura, a fileira rola de lado.
    for (final sub in ['Medidas', 'Exercícios', 'Shape', 'Ficha']) {
      await tester.ensureVisible(find.text(sub).first);
      await tocar(tester, find.text(sub));
    }
    expect(find.text('Ficha de treino'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('computador: Rotina › Automações e Conta', (tester) async {
    await abrirApp(tester, const Size(1280, 860));
    await tocar(tester, find.bySemanticsLabel('Rotina'));
    await tocar(tester, find.text('Automações'));
    await tocar(tester, find.bySemanticsLabel('Conta e sincronização'));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('trocar de aba mantém a fileira de abas (Rotina e Saúde)', (tester) async {
    await abrirApp(tester, const Size(1280, 860));
    final abas = find.byType(Segmentos<int>);
    await tocar(tester, find.bySemanticsLabel('Rotina'));
    final rotina = tester.element(abas);
    final largura = tester.getSize(abas).width;
    for (final aba in ['Calendário', 'Hábitos', 'Análise', 'Hoje']) {
      await tocar(tester, find.text(aba).first);
      expect(tester.element(abas), same(rotina), reason: 'a fileira foi refeita ao abrir $aba');
      expect(tester.getSize(abas).width, largura, reason: 'a fileira mudou de largura em $aba');
    }
    await tocar(tester, find.bySemanticsLabel('Saúde'));
    final saude = tester.element(abas);
    await tocar(tester, find.text('Alimentação'));
    expect(tester.element(abas), same(saude));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('celular: Rotina › Hoje alterna entre Timeblocking e Sala de Foco Imersivo', (tester) async {
    await abrirApp(tester, const Size(390, 844));
    await tocar(tester, find.bySemanticsLabel('Rotina'));
    await assentar(tester); // a Rotina lê quatro tabelas
    expect(find.text('CAPACIDADE DO SEU DIA'), findsOneWidget);
    expect(find.text('Linha do Tempo de Hoje'), findsOneWidget);
    await tocar(tester, find.text('Foco Imersivo'));
    expect(find.text('Música e Ambiente de Foco'), findsOneWidget);
    expect(find.text('Vincular Spotify'), findsOneWidget);
    await tocar(tester, find.text('Timeblocking'));
    await tocar(tester, find.text('Calendário'));
    expect(find.text('Compromisso neste dia'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Visão abre direto como Raio-X Estratégico com todas as seções integradas', (tester) async {
    await abrirApp(tester, const Size(1280, 860));
    await assentar(tester);
    expect(find.text('SCORE DE RITMO'), findsOneWidget);
    expect(find.text('Tempo em Hiper-Foco'), findsOneWidget);
    expect(find.text('Heatmap de Hábitos · Últimos 14 dias'), findsOneWidget);
    expect(find.text('Painel das áreas'), findsOneWidget);
    expect(find.text('Vitórias da Semana'), findsOneWidget);
    expect(find.text('Pontos de Atenção'), findsOneWidget);
    expect(find.text('Reflexão Semanal com a Aurora'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('semana: compromisso curto cabe no bloco numa linha só', (tester) async {
    final hoje = hojeLocal();
    await tester.runAsync(() => db.into(db.compromissos).insert(CompromissosCompanion.insert(
        titulo: 'Dentista', inicio: instanteLocal(hoje, 8), fim: Value(instanteLocal(hoje, 8, 45)))));
    await abrirApp(tester, const Size(1280, 860));
    await tocar(tester, find.bySemanticsLabel('Rotina'));
    await tocar(tester, find.text('Calendário'));
    await tocar(tester, find.text('Semana'));
    // 45 min = 28 px na grade: hora e título juntos, sem estourar o bloco.
    expect(find.text('08:00 Dentista', findRichText: true), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('celular: a barra rolável leva a todas as áreas e a orbe ao assistente', (tester) async {
    await abrirApp(tester, const Size(390, 844));
    for (final area in ['Visão', 'Rotina', 'Finanças', 'Saúde', 'Objetivos']) {
      await tocar(tester, find.bySemanticsLabel(area));
    }
    // A 2ª página da barra (pelos pontinhos): o resto das áreas.
    await tocar(tester, find.bySemanticsLabel('Página 2 do menu'));
    for (final area in ['Anotações', 'Conta']) {
      await tocar(tester, find.bySemanticsLabel(area));
    }
    expect(find.text('Conta e sincronização'), findsWidgets);
    await tocar(tester, find.bySemanticsLabel('Abrir a Aurora (assistente)'));
    // Ir para uma área da 1ª página leva a barra junto (aqui, pela página 1).
    await tocar(tester, find.bySemanticsLabel('Página 1 do menu'));
    // Finanças tem 6 abas: no celular a barra rola de lado até a Análise.
    await tocar(tester, find.bySemanticsLabel('Finanças'));
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
