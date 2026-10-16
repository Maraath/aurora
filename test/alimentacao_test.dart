import 'package:aurora/core/relogio.dart';
import 'package:aurora/data/alimentacao_repo.dart';
import 'package:aurora/data/assistente_repo.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/exemplo.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late BancoAurora db;
  late AlimentacaoRepo repo;

  setUpAll(() async {
    iniciarRelogio();
    await initializeDateFormatting('pt_BR');
  });

  setUp(() async {
    db = BancoAurora(NativeDatabase.memory());
    repo = AlimentacaoRepo(db);
    await semearExemplo(db);
  });

  tearDown(() => db.close());

  Future<Alimento> alimento(String nome, double kcal, double p, double c, double g,
      {String? porcao, double? porcaoG}) async {
    final id = await repo.salvarAlimento(AlimentosCompanion.insert(
      nome: nome,
      kcal: kcal,
      proteina: Value(p),
      carboidrato: Value(c),
      gordura: Value(g),
      porcaoNome: Value(porcao),
      porcaoGramas: Value(porcaoG),
    ));
    return (db.select(db.alimentos)..where((a) => a.id.equals(id))).getSingle();
  }

  test('valores proporcionais e kcal pelos macros', () async {
    final frango = await alimento('Peito de frango grelhado', 160, 32, 0, 2.5);
    final n = Nutrientes.de(frango, 200);
    expect(n.kcal, 320);
    expect(n.proteina, 64);
    expect(kcalDosMacros(10, 20, 5), 165);
  });

  test('registro soma o dia e guarda os valores do momento', () async {
    final arroz = await alimento('Arroz branco cozido', 130, 2.5, 28, 0.3);
    final hoje = hojeSP();
    await repo.registrar(dia: hoje, refeicao: Refeicao.almoco, alimento: arroz, gramas: 150);
    await repo.registrar(dia: hoje, refeicao: Refeicao.jantar, alimento: arroz, gramas: 100);
    var d = await repo.carregarDia(hoje);
    expect(d.total.kcal, closeTo(325, 0.01));
    expect(d.daRefeicao(Refeicao.almoco).single.gramas, 150);

    // Corrigir o alimento depois não muda o que já foi registrado.
    await repo.salvarAlimento(const AlimentosCompanion(kcal: Value(999)), id: arroz.id);
    d = await repo.carregarDia(hoje);
    expect(d.total.kcal, closeTo(325, 0.01));
  });

  test('alvo pelo tipo do dia (pela ficha de treino)', () async {
    await repo.salvarAlvo(TipoDia.treino, const Nutrientes(2600, 160, 300, 70));
    await repo.salvarAlvo(TipoDia.descanso, const Nutrientes(2200, 150, 220, 70));
    await repo.salvarAlvo(TipoDia.treino, const Nutrientes(2700, 160, 320, 70)); // regravar substitui
    expect(await db.select(db.alvosDieta).get(), hasLength(2));

    // Exemplo: Treino A segunda e quinta, Treino B terça e sexta.
    final segunda = DateTime(2026, 10, 19), domingo = DateTime(2026, 10, 18);
    expect(await repo.tipoDoDia(segunda), TipoDia.treino);
    expect(await repo.tipoDoDia(domingo), TipoDia.descanso);
    expect((await repo.carregarDia(segunda)).alvo?.kcal, 2700);
    expect((await repo.carregarDia(domingo)).alvo?.kcal, 2200);
  });

  test('busca o alimento pelo nome, sem acento e por parte do nome', () async {
    await alimento('Pão francês', 300, 8, 58, 3, porcao: '1 pão', porcaoG: 50);
    await alimento('Ovo cozido', 146, 13, 0.6, 9.5, porcao: '1 ovo', porcaoG: 50);
    expect((await repo.acharAlimento('pao frances'))?.nome, 'Pão francês');
    expect((await repo.acharAlimento('ovos'))?.nome, 'Ovo cozido');
    expect(await repo.acharAlimento('picanha'), isNull);
  });

  group('pelo assistente', () {
    late AssistenteRepo assistente;
    setUp(() => assistente = AssistenteRepo(db));

    Future<MensagemAssistente> ultima() async => (await assistente.carregarConversa()).last;

    test('comi 2 ovos usa a porção caseira e pode desfazer', () async {
      await alimento('Ovo cozido', 146, 13, 0.6, 9.5, porcao: '1 ovo', porcaoG: 50);
      await assistente.enviar('comi 2 ovos no café');
      final r = await ultima();
      expect(r.texto, startsWith('Anotei 100 g de Ovo cozido no café da manhã: 146 kcal'));
      expect((await repo.carregarDia(hojeSP())).daRefeicao(Refeicao.cafe), hasLength(1));

      await assistente.desfazer(r);
      expect((await repo.carregarDia(hojeSP())).registros, isEmpty);
    });

    test('alimento desconhecido pede cadastro', () async {
      await assistente.enviar('comi 200 g de picanha');
      expect((await ultima()).texto, contains('Não achei “picanha”'));
    });

    test('sem porção e número pequeno pergunta os gramas', () async {
      await alimento('Arroz branco cozido', 130, 2.5, 28, 0.3);
      await assistente.enviar('comi 2 arroz');
      expect((await ultima()).texto, startsWith('Quantos gramas de Arroz branco cozido?'));
    });
  });
}
