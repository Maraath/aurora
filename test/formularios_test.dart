import 'package:aurora/app.dart';
import 'package:aurora/core/relogio.dart';
import 'package:aurora/core/tema.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/exemplo.dart';
import 'package:aurora/data/habitos_repo.dart';
import 'package:aurora/ui/financas/financas_page.dart';
import 'package:aurora/ui/financas/form_conta.dart';
import 'package:aurora/ui/financas/form_lancamento.dart';
import 'package:aurora/ui/habitos/form_habito.dart';
import 'package:aurora/ui/metas/form_meta.dart';
import 'package:aurora/ui/metas/metas_page.dart';
import 'package:aurora/data/saude_repo.dart';
import 'package:aurora/ui/habitos/habitos_page.dart';
import 'package:aurora/ui/saude/ficha_page.dart';
import 'package:aurora/ui/saude/form_medidas.dart';
import 'package:aurora/ui/saude/form_sessao.dart';
import 'package:aurora/ui/saude/form_treino.dart';
import 'package:aurora/ui/saude/medidas_page.dart';
import 'package:aurora/ui/lembretes/form_lembrete.dart';
import 'package:aurora/ui/tarefas/form_tarefa.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Abre cada formulário em modo de edição (com o botão Excluir) numa tela
/// de desktop e garante que monta sem erro de layout.
void main() {
  late BancoAurora db;

  setUpAll(() async {
    iniciarRelogio();
    await initializeDateFormatting('pt_BR');
  });

  setUp(() async {
    db = BancoAurora(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Future<void> abrir(WidgetTester tester, Future<void> Function(BuildContext) abrirForm) async {
    tester.view.physicalSize = const Size(1180, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AuroraEscopo(
      db: db,
      escuro: ValueNotifier(true),
      child: MaterialApp(
        theme: temaAurora(Brightness.dark),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => abrirForm(context),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('editar hábito', (tester) async {
    await tester.runAsync(() => semearExemplo(db));
    final q = (await tester.runAsync(() => HabitosRepo(db).carregar()))!;
    await abrir(tester, (c) => abrirFormHabito(c, habito: q.habitos.first, metas: q.metas));
    expect(tester.takeException(), isNull);
    expect(find.text('Editar hábito'), findsOneWidget);
    expect(find.text('Excluir'), findsOneWidget);
  });

  testWidgets('editar tarefa', (tester) async {
    await tester.runAsync(() => semearExemplo(db));
    final tarefa = (await tester.runAsync(() => db.select(db.tarefas).get()))!.first;
    await abrir(tester, (c) => abrirFormTarefa(c, tarefa: tarefa));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Editar tarefa'), findsOneWidget);
  });

  testWidgets('editar lembrete', (tester) async {
    await tester.runAsync(() => semearExemplo(db));
    final l = (await tester.runAsync(() => db.select(db.lembretes).get()))!.first;
    await abrir(tester, (c) => abrirFormLembrete(c, lembrete: l));
    expect(tester.takeException(), isNull);
    expect(find.text('Editar lembrete'), findsOneWidget);
  });

  testWidgets('novo lançamento e edição de recorrente', (tester) async {
    await tester.runAsync(() => semearExemplo(db));
    final contas = (await tester.runAsync(() => db.select(db.contasFinanceiras).get()))!;
    await abrir(tester, (c) => abrirFormLancamento(c, contas: contas));
    expect(tester.takeException(), isNull);
    expect(find.text('Salvar gasto'), findsOneWidget);
    await tester.tap(find.text('Parcelada'));
    await tester.pumpAndSettle();
    expect(find.text('Valor total da compra'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('editar lançamento', (tester) async {
    await tester.runAsync(() => semearExemplo(db));
    final t = (await tester.runAsync(() => db.select(db.transacoes).get()))!.first;
    await abrir(tester, (c) => abrirFormLancamento(c, transacao: t, contas: const []));
    expect(tester.takeException(), isNull);
    expect(find.text('Editar lançamento'), findsOneWidget);
    expect(find.text('Excluir'), findsOneWidget);
  });

  testWidgets('editar conta e trocar para cartão', (tester) async {
    await tester.runAsync(() => semearExemplo(db));
    final conta = (await tester.runAsync(() => db.select(db.contasFinanceiras).get()))!.first;
    await abrir(tester, (c) => abrirFormConta(c, conta: conta));
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Cartão'));
    await tester.pumpAndSettle();
    expect(find.text('Vence no dia'), findsOneWidget);
  });

  testWidgets('editar meta mostra o ritmo', (tester) async {
    await tester.runAsync(() => semearExemplo(db));
    final meta = (await tester.runAsync(() => db.select(db.metas).get()))!.first;
    await abrir(tester, (c) => abrirFormMeta(c, meta: meta));
    expect(tester.takeException(), isNull);
    expect(find.text('Editar meta'), findsOneWidget);
    expect(find.textContaining('Para aumentar 6 kg'), findsOneWidget);
  });

  testWidgets('telas de Finanças e Metas montam no celular e no desktop', (tester) async {
    await tester.runAsync(() => semearExemplo(db));
    for (final tamanho in const [Size(390, 844), Size(1180, 800)]) {
      tester.view.physicalSize = tamanho;
      tester.view.devicePixelRatio = 1;
      for (final pagina in [const FinancasPage(), const MetasPage()]) {
        await tester.pumpWidget(AuroraEscopo(
          db: db,
          escuro: ValueNotifier(true),
          child: MaterialApp(
            theme: temaAurora(Brightness.dark),
            home: Scaffold(body: SingleChildScrollView(child: pagina)),
          ),
        ));
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (pagina is FinancasPage) {
          for (final aba in ['Extrato', 'Fixas', 'Contas', 'Resumo']) {
            await tester.tap(find.text(aba));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: aba);
          }
          expect(find.text('Faculdade · 2/27'), findsOneWidget);
        } else {
          expect(find.text('Shape 80kg'), findsOneWidget);
        }
      }
    }
    tester.view.reset();
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('editar treino: incluir e tirar exercício', (tester) async {
    await tester.runAsync(() => semearExemplo(db));
    final q = (await tester.runAsync(() => SaudeRepo(db).carregar()))!;

    await abrir(tester, (c) => abrirFormTreino(c, treino: q.treinos.first));
    expect(tester.takeException(), isNull);
    expect(find.text('Editar treino'), findsOneWidget);
    expect(find.byTooltip('Tirar exercício'), findsNWidgets(3));
    await tester.ensureVisible(find.text('Exercício'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Exercício'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Tirar exercício'), findsNWidgets(4));
    await tester.ensureVisible(find.byTooltip('Tirar exercício').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tirar exercício').first);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Tirar exercício'), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('registrar sessão de treino', (tester) async {
    await tester.runAsync(() => semearExemplo(db));
    final q = (await tester.runAsync(() => SaudeRepo(db).carregar()))!;
    await abrir(tester, (c) => abrirFormSessao(c, q.treinos.first));
    expect(tester.takeException(), isNull);
    expect(find.text('Concluir treino'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Série 1 feita').first);
    await tester.pumpAndSettle();
    expect(find.text('Concluir treino · 1 séries'), findsOneWidget);
  });

  testWidgets('registrar medidas', (tester) async {
    await tester.runAsync(() => semearExemplo(db));
    final q = (await tester.runAsync(() => SaudeRepo(db).carregar()))!;
    await abrir(tester, (c) => abrirFormMedidas(c, q));
    expect(tester.takeException(), isNull);
    expect(find.text('Registrar medidas'), findsOneWidget);
    expect(find.text('Cintura'), findsOneWidget);
  });

  testWidgets('telas de Saúde montam no celular e no desktop', (tester) async {
    await tester.runAsync(() => semearExemplo(db));
    for (final tamanho in const [Size(390, 844), Size(1180, 800)]) {
      tester.view.physicalSize = tamanho;
      tester.view.devicePixelRatio = 1;
      for (final pagina in [HabitosPage(ir: (_) {}), const FichaPage(), const MedidasPage()]) {
        await tester.pumpWidget(AuroraEscopo(
          db: db,
          escuro: ValueNotifier(true),
          child: MaterialApp(
            theme: temaAurora(Brightness.dark),
            home: Scaffold(body: SingleChildScrollView(child: pagina)),
          ),
        ));
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '${pagina.runtimeType} $tamanho');
      }
      expect(find.text('74 kg'), findsWidgets);
    }
    tester.view.reset();
    await tester.pumpWidget(const SizedBox());
  });

  test('relógio iniciado', () => expect(hojeSP(), isNotNull));
}
