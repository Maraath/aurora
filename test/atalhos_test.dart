import 'package:aurora/app.dart';
import 'package:aurora/core/comandos.dart';
import 'package:aurora/core/relogio.dart';
import 'package:aurora/data/assistente_repo.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/busca.dart';
import 'package:aurora/data/exemplo.dart';
import 'package:aurora/ui/atalhos/captura.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late BancoAurora db;

  setUpAll(() async {
    iniciarRelogio();
    await initializeDateFormatting('pt_BR');
  });

  setUp(() async {
    db = BancoAurora(NativeDatabase.memory());
    await semearExemplo(db);
  });

  tearDown(() => db.close());

  test('busca: ignora acento e maiúscula, e o começo do nome vem primeiro', () async {
    final r = await buscarTudo(db, 'formula magica');
    expect(r.first.titulo, 'Fórmula Mágica');
    expect(r.first.tipo, TipoResultado.tarefa);

    final treino = await buscarTudo(db, 'TREINO');
    expect(treino.where((x) => x.tipo == TipoResultado.treino).map((x) => x.titulo), containsAll(['Treino A', 'Treino B']));

    // Termo curto demais não busca; trecho achado serve para destacar.
    expect(await buscarTudo(db, 'a'), isEmpty);
    expect(trechoEncontrado('Fórmula Mágica', 'magi'), (8, 12));
  });

  test('busca: filtro sem texto lista o grupo para navegar', () async {
    expect(await buscarTudo(db, ''), isEmpty, reason: 'sem filtro e sem texto, nada');
    final saude = await buscarTudo(db, '', grupo: GrupoBusca.saude, porGrupo: 50);
    expect(saude.map((x) => x.titulo), containsAll(['Treino A', 'Treino B', 'Supino reto']));
    expect(saude.every((x) => x.tipo.grupo == GrupoBusca.saude), isTrue);
    final tarefas = await buscarTudo(db, '', grupo: GrupoBusca.tarefas, porGrupo: 50);
    expect(tarefas.where((x) => x.tipo == TipoResultado.tarefa).every((x) => (x.item as Tarefa).feitaEm == null), isTrue,
        reason: 'só as pendentes');
    final fin = await buscarTudo(db, '', grupo: GrupoBusca.financas, porGrupo: 3);
    expect(fin.where((x) => x.tipo == TipoResultado.categoria).length, inInclusiveRange(1, 3), reason: 'limite por tipo');
    expect(fin.where((x) => x.tipo == TipoResultado.transacao), hasLength(3));
    // Filtro com texto: só o grupo escolhido.
    final soSaude = await buscarTudo(db, 'tr', grupo: GrupoBusca.saude);
    expect(soSaude, isNotEmpty);
    expect(soSaude.every((x) => x.tipo.grupo == GrupoBusca.saude), isTrue);
  });

  test('busca: no máximo N por grupo', () async {
    final r = await buscarTudo(db, 'e', porGrupo: 2);
    expect(r, isEmpty, reason: 'uma letra só');
    final todos = await buscarTudo(db, 'ra', porGrupo: 2);
    for (final g in GrupoBusca.values) {
      expect(todos.where((x) => x.tipo.grupo == g).length, lessThanOrEqualTo(2));
    }
  });

  test('captura rápida descreve o comando antes de salvar', () {
    final agora = agoraSP();
    final hoje = dataSP(agora);
    final c = interpretar('gastei 42,90 no mercado', hoje: hoje, agora: agora)!;
    final (_, texto) = descreverComando(c, hoje);
    expect(texto, contains('Despesa'));
    expect(texto, contains('42,90'));
    expect(texto, contains('hoje'));
  });

  group('tela', () {
    Future<void> abrir(WidgetTester t, Size tamanho) async {
      t.view.physicalSize = tamanho;
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(AuroraApp(db: db, escuro: ValueNotifier(true)));
      await assentar(t);
    }

    testWidgets('computador: + abre o menu e a captura rápida salva o gasto', (t) async {
      await abrir(t, const Size(1280, 900));
      expect(find.bySemanticsLabel('Buscar em tudo (Ctrl+K)'), findsOneWidget);
      expect(find.bySemanticsLabel('Conversar com a Aurora'), findsOneWidget);

      await t.tap(find.bySemanticsLabel('Ação rápida'));
      await assentar(t);
      for (final o in ['Captura rápida', 'Nova tarefa', 'Novo lançamento', 'Novo lembrete', 'Marcar hábito']) {
        expect(find.text(o), findsOneWidget);
      }
      // Mouse por cima: as opções e os botões animam sem quebrar nada.
      final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      for (final alvo in [find.text('Nova tarefa'), find.bySemanticsLabel('Conversar com a Aurora'), find.bySemanticsLabel('Ação rápida')]) {
        await mouse.moveTo(t.getCenter(alvo));
        await assentar(t);
        expect(t.takeException(), isNull);
      }
      await mouse.moveTo(Offset.zero);
      await assentar(t);
      await t.tap(find.text('Captura rápida'));
      await assentar(t);
      await t.enterText(find.byType(TextField).last, 'gastei 42,90 no padaria teste');
      await assentar(t);
      expect(find.text('A AURORA ENTENDEU'), findsOneWidget);
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await assentar(t);
      await assentar(t);
      final salvos = await t.runAsync(() =>
          (db.select(db.transacoes)..where((x) => x.valorCentavos.equals(4290))).get());
      expect(salvos, hasLength(1));
      expect(find.text('A AURORA ENTENDEU'), findsNothing, reason: 'o painel fecha ao salvar');
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('computador: Ctrl+K busca e Enter abre o item', (t) async {
      await abrir(t, const Size(1280, 900));
      await t.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await t.sendKeyEvent(LogicalKeyboardKey.keyK);
      await t.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await assentar(t);
      expect(find.text('IR PARA'), findsOneWidget, reason: 'sem texto, mostra as áreas');
      // Filtro sem texto: lista o grupo.
      await t.ensureVisible(find.bySemanticsLabel('Filtro: Saúde'));
      await t.tap(find.bySemanticsLabel('Filtro: Saúde'));
      await assentar(t);
      expect(find.text('TREINOS'), findsOneWidget);
      expect(find.text('Treino A'), findsOneWidget);
      expect(find.text('IR PARA'), findsNothing);
      await t.ensureVisible(find.bySemanticsLabel('Filtro: Tudo'));
      await t.tap(find.bySemanticsLabel('Filtro: Tudo'));
      await assentar(t);
      expect(find.text('IR PARA'), findsOneWidget);
      await t.enterText(find.byType(TextField).last, 'formula');
      await assentar(t);
      expect(find.text('TAREFAS E LEMBRETES'), findsOneWidget);
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await assentar(t);
      // Abre a tarefa para editar, já na área Tarefas.
      expect(find.widgetWithText(TextField, 'Fórmula Mágica'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('computador: mini chat abre, responde comando e expande', (t) async {
      await abrir(t, const Size(1280, 900));
      await t.tap(find.bySemanticsLabel('Conversar com a Aurora'));
      await assentar(t);
      expect(find.byTooltip('Abrir o Assistente em tela cheia'), findsOneWidget);
      await t.enterText(find.byType(TextField).last, 'fiz o cardio');
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await assentar(t);
      expect(find.textContaining('Cardio'), findsWidgets);
      await t.tap(find.byTooltip('Abrir o Assistente em tela cheia'));
      await assentar(t);
      expect(find.text('Assistente'), findsWidgets);
      expect(find.byTooltip('Abrir o Assistente em tela cheia'), findsNothing);
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('exclusão pedida pela IA abre o mini chat com o cartão de confirmação', (t) async {
      await abrir(t, const Size(1280, 900));
      final resposta = AssistenteRepo.confirmarNaConversa('Excluir a medida Peso 74 kg do dia 3 de outubro?');
      await assentar(t);
      expect(find.text('Excluir a medida Peso 74 kg do dia 3 de outubro?'), findsOneWidget);
      expect(find.byTooltip('Abrir o Assistente em tela cheia'), findsOneWidget, reason: 'abriu o mini chat');
      await t.tap(find.text('Excluir'));
      await assentar(t);
      expect(await resposta, isTrue);
      expect(find.text('Excluir a medida Peso 74 kg do dia 3 de outubro?'), findsNothing);

      final cancelada = AssistenteRepo.confirmarNaConversa('Excluir a foto de frente?');
      await assentar(t);
      await t.tap(find.text('Cancelar'));
      await assentar(t);
      expect(await cancelada, isFalse);
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('celular: busca no cabeçalho, sem atalhos flutuantes', (t) async {
      await abrir(t, const Size(390, 860));
      expect(find.byTooltip('Buscar em tudo'), findsOneWidget);
      expect(find.bySemanticsLabel('Ação rápida'), findsNothing);
      await t.tap(find.byTooltip('Buscar em tudo'));
      await assentar(t);
      expect(find.text('IR PARA'), findsOneWidget);
      // No celular não há teclado físico: sem dicas de teclas, com botão de fechar.
      expect(find.text('navegar'), findsNothing);
      await t.tap(find.byTooltip('Fechar a busca'));
      await assentar(t);
      expect(find.text('IR PARA'), findsNothing);
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('computador: busca mostra as dicas de teclado', (t) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      await abrir(t, const Size(1280, 900));
      await t.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await t.sendKeyEvent(LogicalKeyboardKey.keyK);
      await t.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await assentar(t);
      expect(find.text('navegar'), findsOneWidget);
      expect(find.byTooltip('Fechar a busca'), findsNothing);
      await t.pumpWidget(const SizedBox());
      debugDefaultTargetPlatformOverride = null;
    });
  });
}

/// A orbe do assistente pulsa sem parar: nada de pumpAndSettle.
Future<void> assentar(WidgetTester t) async {
  await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 60)));
  await t.pump(const Duration(milliseconds: 300));
  await t.pump(const Duration(milliseconds: 300));
}
