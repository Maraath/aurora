import 'package:aurora/core/relogio.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/exemplo.dart';
import 'package:aurora/data/objetivos_repo.dart';
import 'package:aurora/data/tarefas_repo.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    iniciarRelogio();
    await initializeDateFormatting('pt_BR');
  });

  final hoje = DateTime(2026, 10, 16);

  Objetivo objetivo({
    double inicial = 0,
    double atual = 0,
    double alvo = 100,
    String unidade = 'kg',
    String status = 'ativa',
    required DateTime criada,
    DateTime? dataAlvo,
  }) => Objetivo(
    id: 'o',
    criadoEm: criada,
    atualizadoEm: criada,
    nome: 'Objetivo',
    valorInicial: inicial,
    valorAtual: atual,
    valorAlvo: alvo,
    unidade: unidade,
    dataAlvo: dataAlvo,
    status: status,
  );

  EstadoObjetivo estado(Objetivo o, {DateTime? ultima}) {
    final dias = o.dataAlvo == null
        ? null
        : diasEntre(dataLocal(o.criadoEm), dataLocal(o.dataAlvo!));
    final t = dias == null || dias <= 0
        ? null
        : (diasEntre(dataLocal(o.criadoEm), hoje) / dias).clamp(0.0, 1.0);
    final c = o.valorAlvo == o.valorInicial
        ? 1.0
        : ((o.valorAtual - o.valorInicial) / (o.valorAlvo - o.valorInicial))
              .clamp(0.0, 1.0);
    return estadoObjetivo(
      o,
      hoje: hoje,
      ultimaAtividade: ultima ?? hoje,
      progresso: c,
      tempo: t,
      etapas: const [],
    );
  }

  group('estado', () {
    test('parada sem atividade há duas semanas', () {
      final o = objetivo(
        criada: DateTime(2026, 9, 1),
        atual: 50,
        dataAlvo: DateTime(2026, 12, 31),
      );
      expect(estado(o, ultima: DateTime(2026, 10, 1)), EstadoObjetivo.parada);
    });

    test('em risco quando o tempo passa mais rápido que o progresso', () {
      final o = objetivo(
        criada: DateTime(2026, 8, 1),
        atual: 10,
        dataAlvo: DateTime(2026, 11, 30),
      );
      expect(estado(o), EstadoObjetivo.emRisco);
    });

    test('em dia e concluída', () {
      final o = objetivo(
        criada: DateTime(2026, 8, 1),
        atual: 70,
        dataAlvo: DateTime(2026, 11, 30),
      );
      expect(estado(o), EstadoObjetivo.emDia);
      final feita = objetivo(criada: DateTime(2026, 8, 1), atual: 100);
      expect(estado(feita), EstadoObjetivo.concluida);
    });

    test('meta de redução (peso para baixo) também progride', () {
      final o = objetivo(
        inicial: 90,
        atual: 85,
        alvo: 80,
        criada: DateTime(2026, 9, 1),
        dataAlvo: DateTime(2026, 12, 31),
      );
      expect(estado(o, ultima: hoje), EstadoObjetivo.emDia);
    });

    test('pausada e arquivada vêm do status', () {
      expect(
        estado(objetivo(criada: hoje, status: 'pausada')),
        EstadoObjetivo.pausada,
      );
      expect(
        estado(objetivo(criada: hoje, status: 'arquivada')),
        EstadoObjetivo.arquivada,
      );
    });
  });

  test('ritmo por semana, como no protótipo', () {
    final t = ritmoMeta(
      atual: 74,
      alvo: 80,
      unidade: 'kg',
      dataAlvo: DateTime(2026, 12, 31),
      hoje: hoje,
    );
    expect(
      t,
      'Para aumentar 6 kg até 31 de dezembro, são cerca de 0,6 kg por semana. Faltam 76 dias.',
    );
  });

  test('valores em R\$ guardam centavos e mostram reais', () {
    expect(lerValorMeta('1.500,50', 'R\$'), 150050);
    expect(valorMeta(150050, 'R\$'), 'R\$ 1.500,50');
    expect(valorParaCampo(150050, 'R\$'), '1.500,50');
    expect(lerValorMeta('74,5', 'kg'), 74.5);
  });

  group('repositório', () {
    late BancoAurora db;
    late ObjetivosRepo repo;

    setUp(() async {
      db = BancoAurora(NativeDatabase.memory());
      repo = ObjetivosRepo(db);
      await semearExemplo(db);
    });

    tearDown(() => db.close());

    /// Um objetivo-plano (o que antes era "projeto"): começa [comecouHa] dias
    /// atrás e termina em [terminaEm] dias (negativo = já passou).
    Future<String> plano({int comecouHa = 10, int terminaEm = 30}) {
      final hoje = hojeLocal();
      return repo.salvar(
        ObjetivosCompanion.insert(
          nome: 'Estágio',
          inicio: Value(instanteLocal(somarDias(hoje, -comecouHa), 9)),
          dataAlvo: Value(instanteLocal(somarDias(hoje, terminaEm), 9)),
        ),
      );
    }

    Future<ProgressoObjetivo> carregarPorNome(String nome) async =>
        (await repo.carregar()).firstWhere((p) => p.objetivo.nome == nome);

    Future<ProgressoObjetivo> carregarEstagio() => carregarPorNome('Estágio');

    test('conta tarefas ligadas e grava o valor de hoje', () async {
      var lista = await repo.carregar();
      final shape = lista.single;
      expect(shape.objetivo.nome, 'Shape 80kg');
      expect(shape.tarefasLigadas, 1);
      expect(shape.tarefasAbertas, 1);

      await repo.atualizarValor(shape.objetivo.id, 75);
      lista = await repo.carregar();
      expect(lista.single.objetivo.valorAtual, 75);
    });

    test('concluir tarefa ligada conta como atividade', () async {
      final quadro = await TarefasRepo(db).carregar();
      final ligada = quadro.atuais.firstWhere(
        (o) => o.tarefa.objetivoId != null,
      );
      await (db.update(db.objetivos))
          .write(ObjetivosCompanion(atualizadoEm: Value(DateTime(2026, 1, 1))));
      await TarefasRepo(db).alternar(ligada, true);
      final p = (await repo.carregar()).single;
      expect(dataLocal(p.ultimaAtividade), hojeLocal());
      expect(p.tarefasAbertas, 0);
    });

    test(
      'excluir tira o objetivo da lista e mantém as tarefas sem vínculo',
      () async {
        final id = (await repo.carregar()).single.objetivo.id;
        await repo.excluir(id);
        expect(await repo.carregar(), isEmpty);
        final t = await (db.select(
          db.tarefas,
        )..where((t) => t.titulo.equals('Tribulus + creatina'))).getSingle();
        expect(t.objetivoId, isNull);
        expect(t.apagadoEm, isNull);
      },
    );

    test('etapas contam no progresso e tudo feito conclui', () async {
      final id = await repo.salvar(ObjetivosCompanion.insert(nome: 'Estágio'));
      await repo.novaEtapa(id, 'Pesquisar vagas');
      await repo.novaEtapa(id, 'Entrevista');

      // Etapas NÃO viram tarefas nem aparecem como tarefas
      final tarefas = await (db.select(
        db.tarefas,
      )..where((t) => t.titulo.equals('Pesquisar vagas'))).get();
      expect(tarefas, isEmpty, reason: 'etapa não deve ser criada como tarefa');

      var p = (await repo.carregar()).firstWhere(
        (p) => p.objetivo.nome == 'Estágio',
      );
      expect(p.total, 2);
      expect(p.feitas, 0);
      expect(p.estado, EstadoObjetivo.emDia);

      await repo.alternarEtapa(p.etapas.first, true);
      p = (await repo.carregar()).firstWhere(
        (p) => p.objetivo.nome == 'Estágio',
      );
      expect(p.feitas, 1);

      final pendente = p.etapas.firstWhere((e) => !e.feita);
      await repo.alternarEtapa(pendente, true);
      p = (await repo.carregar()).firstWhere(
        (p) => p.objetivo.nome == 'Estágio',
      );
      expect(p.estado, EstadoObjetivo.concluida);
    });

    test('etapas do projeto ordenam e feitas vão para o fim', () async {
      final id = await plano();
      await repo.novaEtapa(id, 'Pesquisar vagas');
      await repo.novaEtapa(id, 'Entrevista');

      var p = await carregarEstagio();
      expect(p.etapas, hasLength(2));
      expect(p.total, 2);
      expect(p.feitas, 0);
      expect(p.estado, EstadoObjetivo.emDia);
      expect(detalheEtapa(p.etapas.first, hojeLocal()), 'etapa do projeto');

      await repo.alternarEtapa(
        p.etapas.firstWhere((e) => e.titulo == 'Pesquisar vagas'),
        true,
      );
      p = await carregarEstagio();
      expect(p.feitas, 1);
      expect(p.progresso, 0.5);
      // Feitas vão para o fim da lista.
      expect(p.etapas.last.titulo, 'Pesquisar vagas');
      expect(detalheEtapa(p.etapas.last, hojeLocal()), 'feita hoje');
    });

    test('concluir todas as etapas conclui o objetivo', () async {
      final id = await plano();
      await repo.novaEtapa(id, 'Testes');
      var p = await carregarEstagio();
      expect(p.estado, EstadoObjetivo.emDia);

      await repo.alternarEtapa(p.etapas.single, true);
      p = await carregarEstagio();
      expect(p.estado, EstadoObjetivo.concluida);
      expect(p.textoPrazo, 'concluído');
    });

    test('tempo correndo mais rápido que as etapas é risco', () async {
      final id = await plano(comecouHa: 80, terminaEm: 20);
      await repo.novaEtapa(id, 'A');
      await repo.novaEtapa(id, 'B');
      expect((await carregarEstagio()).estado, EstadoObjetivo.emRisco);
    });

    test('prazo passou sem terminar é risco', () async {
      final id = await plano(comecouHa: 30, terminaEm: -1);
      await repo.novaEtapa(id, 'A');
      final p = await carregarEstagio();
      expect(p.estado, EstadoObjetivo.emRisco);
      expect(p.textoPrazo, 'prazo passou há 1 dia');
    });

    test('pausar, arquivar e reabrir mudam o estado', () async {
      final id = await repo.salvar(ObjetivosCompanion.insert(nome: 'Pausado'));
      await repo.mudarStatus(id, 'pausada');
      expect((await carregarPorNome('Pausado')).estado, EstadoObjetivo.pausada);
      await repo.mudarStatus(id, 'arquivada');
      expect(
        (await carregarPorNome('Pausado')).estado,
        EstadoObjetivo.arquivada,
      );
      await repo.mudarStatus(id, 'ativa');
      expect((await carregarPorNome('Pausado')).estado, EstadoObjetivo.emDia);
    });
  });
}
