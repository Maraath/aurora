import 'package:aurora/app.dart';
import 'package:aurora/core/relogio.dart';
import 'package:aurora/core/tema.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/exemplo.dart';
import 'package:aurora/data/habitos_repo.dart';
import 'package:aurora/data/lembretes_repo.dart';
import 'package:aurora/data/alimentacao_repo.dart';
import 'package:aurora/ui/alimentacao/alimentacao_page.dart';
import 'package:aurora/ui/alimentacao/form_alvos.dart';
import 'package:aurora/ui/alimentacao/form_registro.dart';
import 'package:aurora/ui/assistente/assistente_page.dart';
import 'package:aurora/ui/automacoes/automacoes_page.dart';
import 'package:drift/drift.dart' show Value;
import 'package:aurora/ui/financas/financas_page.dart';
import 'package:aurora/ui/financas/form_conta.dart';
import 'package:aurora/ui/financas/form_lancamento.dart';
import 'package:aurora/ui/habitos/form_habito.dart';
import 'package:aurora/ui/metas/form_meta.dart';
import 'package:aurora/ui/metas/metas_page.dart';
import 'package:aurora/data/projetos_repo.dart';
import 'package:aurora/ui/projetos/projetos_page.dart';
import 'package:aurora/data/saude_repo.dart';
import 'package:aurora/ui/rotina/form_rotina.dart';
import 'package:aurora/ui/rotina/habitos_rotina.dart';
import 'package:aurora/ui/formulario.dart' show OpcaoChip;
import 'package:aurora/ui/saude/biblioteca_ui.dart';
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

  testWidgets('folha única: novo compromisso grava com aviso de 30 min', (tester) async {
    await abrir(tester, (c) => abrirFormRotina(c, tipo: TipoRotina.compromisso));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();
    expect(find.text('Novo compromisso'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Dentista');
    await tester.ensureVisible(find.text('Salvar compromisso'));
    await tester.tap(find.text('Salvar compromisso'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final c = (await tester.runAsync(() => db.select(db.compromissos).getSingle()))!;
    expect(c.titulo, 'Dentista');
    expect(c.avisoAntesMin, 30);
    expect(c.fim!.difference(c.inicio), const Duration(hours: 1));
  });

  testWidgets('folha única: converter tarefa em hábito apaga a tarefa', (tester) async {
    final tarefa = (await tester.runAsync(
        () => db.into(db.tarefas).insertReturning(TarefasCompanion.insert(titulo: 'Ler 20 páginas'))))!;
    await abrir(tester, (c) => abrirFormTarefa(c, tarefa: tarefa));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();
    expect(find.text('Editar tarefa'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Tipo: Hábito'));
    await tester.pumpAndSettle();
    expect(find.text('Converter em hábito'), findsOneWidget);
    await tester.ensureVisible(find.text('Salvar hábito'));
    await tester.tap(find.text('Salvar hábito'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final habito = (await tester.runAsync(() => db.select(db.habitos).getSingle()))!;
    expect(habito.nome, 'Ler 20 páginas');
    final t = (await tester.runAsync(() => db.select(db.tarefas).getSingle()))!;
    expect(t.apagadoEm, isNotNull);
  });

  testWidgets('"Me despertar" fica gravado no lembrete', (tester) async {
    final amanha = agoraLocal().add(const Duration(days: 1));
    await tester.runAsync(() => LembretesRepo(db).salvar(LembretesCompanion(
          texto: const Value('Acordar'),
          quando: Value(amanha),
          regraRepeticao: const Value('FREQ=DAILY'),
        )));
    final l = (await tester.runAsync(() => db.select(db.lembretes).getSingle()))!;
    expect(l.despertar, isFalse);
    await abrir(tester, (c) => abrirFormLembrete(c, lembrete: l));
    await tester.ensureVisible(find.text('Me despertar'));
    await tester.tap(find.byType(Switch).last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Salvar lembrete'));
    await tester.tap(find.text('Salvar lembrete'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final salvo = (await tester.runAsync(() => db.select(db.lembretes).getSingle()))!;
    expect(salvo.despertar, isTrue);
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
          for (final aba in ['Extrato', 'Fixas', 'Parceladas', 'Contas', 'Análise', 'Resumo']) {
            // No celular a barra de abas rola de lado.
            await tester.ensureVisible(find.text(aba));
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
      for (final pagina in const [HabitosRotina(), FichaPage(), MedidasPage()]) {
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

  testWidgets('assistente responde a um atalho', (tester) async {
    await tester.runAsync(() => semearExemplo(db));
    for (final tamanho in const [Size(390, 844), Size(1180, 800)]) {
      tester.view.physicalSize = tamanho;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(AuroraEscopo(
        db: db,
        escuro: ValueNotifier(true),
        child: MaterialApp(
          theme: temaAurora(Brightness.dark),
          home: const Scaffold(body: AssistentePage()),
        ),
      ));
      // A orbe da conversa vazia pulsa sem parar: nada de pumpAndSettle.
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull, reason: '$tamanho');
    }
    await tester.tap(find.text('Gastei 35 no mercado').first);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    // A resposta aparece aos poucos (efeito de digitação).
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.textContaining('Anotei R\$ 35,00'), findsOneWidget);
    expect(find.text('Desfazer'), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.view.reset();
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('projetos: tela, linha do tempo e formulário', (tester) async {
    await tester.runAsync(() async {
      await semearExemplo(db);
      final hoje = hojeLocal();
      final repo = ProjetosRepo(db);
      final id = await repo.salvar(ProjetosCompanion.insert(
        nome: 'Estágio',
        inicio: instanteLocal(hoje.subtract(const Duration(days: 40))),
        fim: instanteLocal(hoje.add(const Duration(days: 45))),
      ));
      await repo.novaEtapa(id, 'Pesquisar vagas');
      await repo.novaEtapa(id, 'Entrevista', dia: hoje.subtract(const Duration(days: 2)));
    });
    for (final tamanho in const [Size(390, 844), Size(1180, 800)]) {
      tester.view.physicalSize = tamanho;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(AuroraEscopo(
        db: db,
        escuro: ValueNotifier(true),
        child: MaterialApp(
          theme: temaAurora(Brightness.dark),
          home: const Scaffold(body: SingleChildScrollView(child: ProjetosPage())),
        ),
      ));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$tamanho');
      expect(find.text('Em risco'), findsOneWidget);
      expect(find.text('atrasada 2 dias'), findsOneWidget);
    }
    await tester.tap(find.byTooltip('Editar projeto'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
    expect(find.text('Editar projeto'), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.view.reset();
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('alimentação: tela, registro e alvos', (tester) async {
    late List<Alimento> alimentos;
    await tester.runAsync(() async {
      await semearExemplo(db);
      final repo = AlimentacaoRepo(db);
      await repo.salvarAlimento(AlimentosCompanion.insert(
          nome: 'Ovo cozido', kcal: 146, porcaoNome: const Value('1 ovo'), porcaoGramas: const Value(50)));
      await repo.salvarAlvo(TipoDia.treino, const Nutrientes(2600, 160, 300, 70));
      await repo.salvarAlvo(TipoDia.descanso, const Nutrientes(2200, 150, 220, 70));
      alimentos = await repo.listarAlimentos();
      await repo.registrar(dia: hojeLocal(), refeicao: Refeicao.cafe, alimento: alimentos.single, gramas: 100);
    });
    for (final tamanho in const [Size(390, 844), Size(1180, 800)]) {
      tester.view.physicalSize = tamanho;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(AuroraEscopo(
        db: db,
        escuro: ValueNotifier(true),
        child: MaterialApp(
          theme: temaAurora(Brightness.dark),
          home: const Scaffold(body: SingleChildScrollView(child: AlimentacaoPage())),
        ),
      ));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$tamanho');
      expect(find.text('Ovo cozido'), findsOneWidget);
    }
    tester.view.reset();
    await tester.pumpWidget(const SizedBox());

    await abrir(tester, (c) => abrirFormRegistro(c, dia: hojeLocal(), alimentos: alimentos));
    await tester.tap(find.text('Ovo cozido'));
    await tester.pumpAndSettle();
    expect(find.textContaining('73 kcal'), findsOneWidget); // 1 ovo = 50 g
    await tester.tap(find.byTooltip('Uma a mais'));
    await tester.pumpAndSettle();
    expect(find.textContaining('146 kcal'), findsOneWidget); // 2 ovos
    expect(find.text('Ajustar peso da unidade'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('formulário de alvos', (tester) async {
    await abrir(tester, (c) => abrirFormAlvos(c));
    expect(find.text('DIA DE TREINO'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('automações: tela e formulário', (tester) async {
    await tester.runAsync(() => semearExemplo(db));
    for (final tamanho in const [Size(390, 844), Size(1180, 800)]) {
      tester.view.physicalSize = tamanho;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(AuroraEscopo(
        db: db,
        escuro: ValueNotifier(true),
        child: MaterialApp(
          theme: temaAurora(Brightness.dark),
          home: const Scaffold(body: SingleChildScrollView(child: AutomacoesPage())),
        ),
      ));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$tamanho');
      expect(find.text('Briefing do dia'), findsOneWidget);
      expect(find.text('Todo dia às 07:00'), findsOneWidget);
    }
    await tester.tap(find.text('Briefing do dia'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
    expect(find.text('Editar automação'), findsOneWidget);
    expect(find.text('Excluir'), findsNothing); // modelos prontos não se excluem
    expect(tester.takeException(), isNull);
    tester.view.reset();
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('biblioteca de exercícios: página, grupos e animação', (tester) async {
    for (final tamanho in const [Size(390, 844), Size(1180, 800)]) {
      tester.view.physicalSize = tamanho;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(AuroraEscopo(
        db: db,
        escuro: ValueNotifier(true),
        child: MaterialApp(
          theme: temaAurora(Brightness.dark),
          home: const Scaffold(body: SingleChildScrollView(child: BibliotecaPage())),
        ),
      ));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$tamanho');
      expect(find.text('Todos'), findsOneWidget);
    }
    await tester.tap(find.widgetWithText(OpcaoChip, 'Antebraço'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Ver o movimento'), findsNWidgets(15));
    await tester.tap(find.byTooltip('Ver o movimento').first);
    // A animação tenta baixar (carregando): só confere que a folha abriu com ela.
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(AnimacaoExercicio), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.view.reset();
    await tester.pumpWidget(const SizedBox());
  });

  test('relógio iniciado', () => expect(hojeLocal(), isNotNull));
}
