import 'package:aurora/app.dart';
import 'package:aurora/core/relogio.dart';
import 'package:aurora/core/tema.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/exemplo.dart';
import 'package:aurora/data/habitos_repo.dart';
import 'package:aurora/ui/habitos/form_habito.dart';
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

  test('relógio iniciado', () => expect(hojeSP(), isNotNull));
}
