import 'package:aurora/core/relogio.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/exemplo.dart';
import 'package:aurora/data/metas_repo.dart';
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

  Meta meta({
    double inicial = 0,
    double atual = 0,
    double alvo = 100,
    String unidade = 'kg',
    required DateTime criada,
    DateTime? dataAlvo,
  }) =>
      Meta(
        id: 'm',
        criadoEm: criada,
        atualizadoEm: criada,
        nome: 'Meta',
        valorInicial: inicial,
        valorAtual: atual,
        valorAlvo: alvo,
        unidade: unidade,
        dataAlvo: dataAlvo,
        status: 'ativa',
      );

  final hoje = DateTime(2026, 10, 16);

  group('estado', () {
    test('nova na primeira semana', () {
      final m = meta(criada: DateTime(2026, 10, 14), dataAlvo: DateTime(2026, 12, 31));
      expect(calcularProgresso(m, hoje: hoje, ultimaAtividade: m.atualizadoEm).estado,
          EstadoMeta.nova);
    });

    test('parada sem atividade há duas semanas', () {
      final m = meta(criada: DateTime(2026, 9, 1), atual: 50, dataAlvo: DateTime(2026, 12, 31));
      final p = calcularProgresso(m, hoje: hoje, ultimaAtividade: DateTime(2026, 10, 1));
      expect(p.estado, EstadoMeta.parada);
    });

    test('em risco quando o tempo passa mais rápido que o progresso', () {
      final m = meta(criada: DateTime(2026, 8, 1), atual: 10, dataAlvo: DateTime(2026, 11, 30));
      final p = calcularProgresso(m, hoje: hoje, ultimaAtividade: hoje);
      expect(p.tempo, greaterThan(0.6));
      expect(p.estado, EstadoMeta.emRisco);
    });

    test('em dia e concluída', () {
      final m = meta(criada: DateTime(2026, 8, 1), atual: 70, dataAlvo: DateTime(2026, 11, 30));
      expect(calcularProgresso(m, hoje: hoje, ultimaAtividade: hoje).estado, EstadoMeta.emDia);
      final feita = meta(criada: DateTime(2026, 8, 1), atual: 100);
      final p = calcularProgresso(feita, hoje: hoje, ultimaAtividade: hoje);
      expect(p.estado, EstadoMeta.concluida);
      expect(p.ritmo, isNull);
    });

    test('meta de redução (peso para baixo) também progride', () {
      final m = meta(
          inicial: 90, atual: 85, alvo: 80, criada: DateTime(2026, 9, 1), dataAlvo: DateTime(2026, 12, 31));
      expect(calcularProgresso(m, hoje: hoje, ultimaAtividade: hoje).progresso, closeTo(0.5, 0.001));
    });
  });

  test('ritmo por semana, como no protótipo', () {
    final t = ritmoMeta(
        atual: 74, alvo: 80, unidade: 'kg', dataAlvo: DateTime(2026, 12, 31), hoje: hoje);
    expect(t, 'Para aumentar 6 kg até 31 de dezembro, são cerca de 0,6 kg por semana. Faltam 76 dias.');
  });

  test('metas em R\$ guardam centavos e mostram reais', () {
    expect(lerValorMeta('1.500,50', 'R\$'), 150050);
    expect(valorMeta(150050, 'R\$'), 'R\$ 1.500,50');
    expect(valorParaCampo(150050, 'R\$'), '1.500,50');
    expect(lerValorMeta('74,5', 'kg'), 74.5);
  });

  group('repositório', () {
    late BancoAurora db;
    late MetasRepo repo;

    setUp(() async {
      db = BancoAurora(NativeDatabase.memory());
      repo = MetasRepo(db);
      await semearExemplo(db);
    });

    tearDown(() => db.close());

    test('conta tarefas ligadas e grava o valor de hoje', () async {
      var lista = await repo.carregar();
      final shape = lista.single;
      expect(shape.meta.nome, 'Shape 80kg');
      expect(shape.tarefasLigadas, 1);
      expect(shape.tarefasAbertas, 1);

      await repo.atualizarValor(shape.meta.id, 75);
      lista = await repo.carregar();
      expect(lista.single.meta.valorAtual, 75);
    });

    test('concluir tarefa ligada conta como atividade', () async {
      final quadro = await TarefasRepo(db).carregar();
      final ligada = quadro.atuais.firstWhere((o) => o.tarefa.metaId != null);
      await (db.update(db.metas)).write(MetasCompanion(atualizadoEm: Value(DateTime(2026, 1, 1))));
      await TarefasRepo(db).alternar(ligada, true);
      final p = (await repo.carregar()).single;
      expect(dataSP(p.ultimaAtividade), hojeSP());
      expect(p.tarefasAbertas, 0);
    });

    test('excluir tira a meta da lista', () async {
      final id = (await repo.carregar()).single.meta.id;
      await repo.excluir(id);
      expect(await repo.carregar(), isEmpty);
    });
  });
}
