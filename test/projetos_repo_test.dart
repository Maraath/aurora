import 'package:aurora/core/relogio.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/projetos_repo.dart';
import 'package:aurora/data/tarefas_repo.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late BancoAurora db;
  late ProjetosRepo repo;
  late DateTime hoje;

  setUpAll(() async {
    iniciarRelogio();
    await initializeDateFormatting('pt_BR');
  });

  setUp(() {
    db = BancoAurora(NativeDatabase.memory());
    repo = ProjetosRepo(db);
    hoje = hojeSP();
  });

  tearDown(() => db.close());

  Future<String> projeto({int comecouHa = 10, int terminaEm = 30}) => repo.salvar(ProjetosCompanion.insert(
        nome: 'Estágio',
        inicio: instanteSP(hoje.subtract(Duration(days: comecouHa))),
        fim: instanteSP(hoje.add(Duration(days: terminaEm))),
      ));

  Future<ProgressoProjeto> carregar() async => (await repo.carregar()).single;

  test('etapas contam no progresso; rotinas não', () async {
    final id = await projeto();
    await repo.novaEtapa(id, 'Pesquisar vagas', dia: hoje.add(const Duration(days: 2)));
    await repo.novaEtapa(id, 'Entrevista');
    await TarefasRepo(db).salvar(
      TarefasCompanion.insert(
        titulo: 'Estudar inglês',
        prazo: Value(instanteSP(hoje)),
        regraRepeticao: const Value('FREQ=DAILY'),
        projetoId: Value(id),
      ),
      avisar: false,
    );

    var p = await carregar();
    expect(p.total, 2);
    expect(p.feitas, 0);
    expect(p.etapas, hasLength(3));
    expect(p.estado, EstadoProjeto.emDia);
    expect(detalheEtapa(p.etapas.last, hoje), 'rotina · todo dia');

    final pesquisar = p.etapas.firstWhere((e) => e.tarefa.titulo == 'Pesquisar vagas');
    await TarefasRepo(db).alternar(pesquisar.ocorrencia, true);
    p = await carregar();
    expect(p.feitas, 1);
    expect(p.progresso, 0.5);
    // Feitas vão para o fim da lista.
    expect(p.etapas.last.tarefa.titulo, 'Pesquisar vagas');
    expect(detalheEtapa(p.etapas.last, hoje), 'feita hoje');
  });

  test('etapa atrasada deixa em risco; tudo feito conclui', () async {
    final id = await projeto();
    await repo.novaEtapa(id, 'Testes', dia: hoje.subtract(const Duration(days: 3)));
    var p = await carregar();
    expect(p.estado, EstadoProjeto.emRisco);
    expect(detalheEtapa(p.etapas.single, hoje), 'atrasada 3 dias');

    await TarefasRepo(db).alternar(p.etapas.single.ocorrencia, true);
    p = await carregar();
    expect(p.estado, EstadoProjeto.concluido);
    expect(p.textoPrazo, 'concluído');
  });

  test('tempo andando bem mais rápido que o progresso é risco', () async {
    final id = await projeto(comecouHa: 80, terminaEm: 20);
    await repo.novaEtapa(id, 'A');
    await repo.novaEtapa(id, 'B');
    expect((await carregar()).estado, EstadoProjeto.emRisco);
  });

  test('prazo passou sem terminar é risco', () async {
    final id = await projeto(comecouHa: 30, terminaEm: -1);
    await repo.novaEtapa(id, 'A');
    final p = await carregar();
    expect(p.estado, EstadoProjeto.emRisco);
    expect(p.textoPrazo, 'prazo passou há 1 dia');
  });

  test('excluir o projeto mantém as tarefas sem vínculo', () async {
    final id = await projeto();
    await repo.novaEtapa(id, 'Entrevista');
    await repo.excluir(id);
    expect(await repo.carregar(), isEmpty);
    final t = await (db.select(db.tarefas)..where((t) => t.titulo.equals('Entrevista'))).getSingle();
    expect(t.projetoId, isNull);
    expect(t.apagadoEm, isNull);
  });
}
