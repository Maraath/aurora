import 'package:aurora/core/notificacoes.dart';
import 'package:aurora/core/relogio.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/exemplo.dart';
import 'package:aurora/data/habitos_repo.dart';
import 'package:aurora/data/lembretes_repo.dart';
import 'package:aurora/data/tarefas_repo.dart';
import 'package:aurora/data/visao_repo.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late BancoAurora db;
  late VisaoRepo visao;
  late TarefasRepo tarefas;

  setUpAll(() async {
    iniciarRelogio();
    await initializeDateFormatting('pt_BR');
  });

  setUp(() async {
    db = BancoAurora(NativeDatabase.memory());
    visao = VisaoRepo(db);
    tarefas = TarefasRepo(db);
    await semearExemplo(db);
  });

  tearDown(() => db.close());

  test('dados de exemplo geram o resumo do protótipo', () async {
    final r = await visao.carregar();
    expect(r.nome, 'Maraath');
    expect(r.habitos.map((h) => h.habito.nome), ['Cardio', 'Estudo']);
    expect(r.habitosFeitos, 0);
    // 5 tarefas da etapa 1 + 1 recorrente ("Planejar a semana").
    expect(r.tarefasAbertas, 6);
    // "Fórmula Mágica" é hoje às 21:00 e passa a contar como atrasada depois disso.
    expect(r.tarefasAtrasadas, agoraSP().hour >= 21 ? 4 : 3);
    expect(r.aPagarCentavos, 22280);
    expect(r.contasAPagar, 3);
    expect(r.meta?.nome, 'Shape 80kg');
  });

  test('linha do dia, semana e insights', () async {
    final r = await visao.carregar();
    // Hábitos de hoje entram na linha, com o id para marcar direto dela.
    final habitos = r.linha.where((i) => i.tipo == TipoItemLinha.habito).toList();
    expect(habitos.map((i) => i.titulo), containsAll(['Cardio', 'Estudo']));
    expect(habitos.every((i) => i.habitoId != null), isTrue);
    // Itens com hora vêm antes dos sem hora, em ordem.
    final horas = r.linha.takeWhile((i) => i.hora != null).map((i) => i.hora!).toList();
    expect(horas, [...horas]..sort());
    expect(r.linha.skip(horas.length).every((i) => i.hora == null), isTrue);

    expect(r.semana, hasLength(7));
    expect(r.semana.first.dia, hojeSP());
    expect(r.insights, isNotEmpty);
    expect(r.insights.length, lessThanOrEqualTo(3));
  });

  test('semear duas vezes não duplica', () async {
    await semearExemplo(db);
    expect((await visao.carregar()).tarefasAbertas, 6);
    expect((await LembretesRepo(db).carregar()).todos, hasLength(5));
  });

  test('marcar hábito grava um registro por dia e pode desfazer', () async {
    final cardio = (await visao.carregar()).habitos.first.habito;
    await visao.alternarHabito(cardio.id, true);
    await visao.alternarHabito(cardio.id, true);
    expect((await visao.carregar()).habitosFeitos, 1);
    expect(await db.select(db.registrosHabito).get(), hasLength(1));

    await visao.alternarHabito(cardio.id, false);
    expect((await visao.carregar()).habitosFeitos, 0);
  });

  test('tarefa sem repetição: com hora atrasa pelo horário; sem hora, pelo dia', () {
    final agora = diaSP(2026, 10, 16, 15);
    Tarefa t(DateTime prazo, bool temHora) => Tarefa(
          id: 'x',
          criadoEm: agora,
          atualizadoEm: agora,
          titulo: 't',
          prazo: prazo,
          prazoTemHora: temHora,
          prioridade: Prioridade.media,
        );
    expect(tarefaAtrasada(t(diaSP(2026, 10, 16, 9), true), agora), isTrue);
    expect(tarefaAtrasada(t(diaSP(2026, 10, 16), false), agora), isFalse);
    expect(tarefaAtrasada(t(diaSP(2026, 10, 15), false), agora), isTrue);
  });

  group('tarefa recorrente', () {
    late String id;

    setUp(() async {
      // Começou há 10 dias e repete todo dia: não pode virar 10 atrasadas.
      id = await tarefas.salvar(
        TarefasCompanion.insert(
          titulo: 'Tomar creatina',
          prazo: Value(instanteSP(hojeSP().subtract(const Duration(days: 10)), 8)),
          prazoTemHora: const Value(true),
          regraRepeticao: const Value('FREQ=DAILY'),
        ),
        avisar: true,
      );
    });

    OcorrenciaTarefa daTarefa(QuadroTarefas q) => q.atuais.firstWhere((o) => o.tarefa.id == id);

    test('mostra só a ocorrência de hoje, sem acumular atrasadas', () async {
      final q = await tarefas.carregar();
      final o = daTarefa(q);
      expect(o.dia, hojeSP());
      expect(o.atrasada, isFalse);
      expect(q.atuais.where((o) => o.tarefa.id == id), hasLength(1));
    });

    test('concluir hoje grava uma linha e não mexe na regra', () async {
      await tarefas.alternar(daTarefa(await tarefas.carregar()), true);
      var q = await tarefas.carregar();
      expect(daTarefa(q).feita, isTrue);
      expect(await db.select(db.conclusoesTarefa).get(), hasLength(1));
      expect((await db.select(db.tarefas).get()).where((t) => t.id == id), hasLength(1));

      await tarefas.alternar(daTarefa(q), false);
      q = await tarefas.carregar();
      expect(daTarefa(q).feita, isFalse);
    });

    test('"Me avisar" cria um lembrete ligado; excluir a tarefa leva o lembrete', () async {
      var lembretes = (await LembretesRepo(db).carregar()).todos;
      final ligado = lembretes.where((l) => l.lembrete.itemId == id).single;
      expect(ligado.regra?.rrule, 'FREQ=DAILY');
      expect(ligado.proxima, isNotNull);

      await tarefas.excluir(id);
      lembretes = (await LembretesRepo(db).carregar()).todos;
      expect(lembretes.where((l) => l.lembrete.itemId == id), isEmpty);
    });

    test('calendário mostra a ocorrência em cada dia do mês', () async {
      final q = await tarefas.carregar();
      final hoje = hojeSP();
      final semana = q.porDia(hoje, hoje.add(const Duration(days: 6)), agoraSP());
      expect(semana.values.where((l) => l.any((o) => o.tarefa.id == id)), hasLength(7));
    });
  });

  test('hábito só nos dias escolhidos e sequência de dias', () async {
    final repo = HabitosRepo(db);
    await repo.salvar(
      HabitosCompanion.insert(nome: 'Ler', diasSemana: const Value(127)),
      avisar: false,
    );
    var q = await repo.carregar();
    final ler = q.habitos.firstWhere((h) => h.nome == 'Ler');
    final hoje = hojeSP();
    expect(q.doDia(hoje).map((h) => h.nome), contains('Ler'));

    await repo.alternar(ler.id, hoje, true);
    q = await repo.carregar();
    expect(q.sequencia(ler, hoje), 1);
    expect(q.progresso(hoje), closeTo(1 / 3, 0.001));
  });

  group('planejar avisos', () {
    late final agora = diaSP(2026, 10, 16, 10);
    Lembrete lembrete(String texto, DateTime quando,
            {String? regra, bool ativo = true, String? tipo, String? item}) =>
        Lembrete(
          id: texto,
          criadoEm: agora,
          atualizadoEm: agora,
          texto: texto,
          quando: quando,
          regraRepeticao: regra,
          notificarAntesMin: 0,
          ativo: ativo,
          itemTipo: tipo,
          itemId: item,
        );

    List<AvisoPlanejado> planejar(List<Lembrete> l,
            {Map<String, Tarefa> tarefas = const {},
            Set<String> habitos = const {},
            Map<String, Set<String>> habitosFeitos = const {}}) =>
        planejarAvisos(
          lembretes: l,
          tarefas: tarefas,
          habitos: habitos,
          tarefasFeitasNoDia: const {},
          habitosFeitosNoDia: habitosFeitos,
          agora: agora,
        );

    test('único no futuro, passado não, desligado não', () {
      final avisos = planejar([
        lembrete('futuro', diaSP(2026, 10, 17, 9)),
        lembrete('passado', diaSP(2026, 10, 15, 9)),
        lembrete('desligado', diaSP(2026, 10, 17, 9), ativo: false),
      ]);
      expect(avisos.map((a) => a.titulo), ['futuro']);
    });

    test('diário gera 14 dias, em ordem, e respeita o limite', () {
      final avisos = planejar([
        lembrete('vitamina', diaSP(2026, 10, 1, 8), regra: 'FREQ=DAILY'),
      ]);
      // Hoje às 8h já passou (agora = 10h): começa amanhã.
      expect(avisos.first.quando, diaSP(2026, 10, 17, 8));
      expect(avisos, hasLength(14));
      final muitos = planejarAvisos(
        lembretes: [
          for (var i = 0; i < 10; i++) lembrete('l$i', diaSP(2026, 10, 1, 12), regra: 'FREQ=DAILY'),
        ],
        tarefas: const {},
        habitos: const {},
        tarefasFeitasNoDia: const {},
        habitosFeitosNoDia: const {},
        agora: agora,
      );
      expect(muitos, hasLength(60));
    });

    test('hábito já feito hoje não avisa hoje', () {
      final avisos = planejar(
        [lembrete('Cardio', diaSP(2026, 10, 1, 18), regra: 'FREQ=DAILY', tipo: 'habito', item: 'h1')],
        habitos: {'h1'},
        habitosFeitos: {
          '2026-10-16': {'h1'},
        },
      );
      expect(avisos.first.quando, diaSP(2026, 10, 17, 18));
    });

    test('lembrete de item apagado não avisa', () {
      final avisos = planejar([
        lembrete('órfão', diaSP(2026, 10, 17, 9), tipo: 'habito', item: 'sumiu'),
      ]);
      expect(avisos, isEmpty);
    });
  });
}
