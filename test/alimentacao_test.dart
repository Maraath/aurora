import 'dart:io';

import 'package:aurora/core/relogio.dart';
import 'package:aurora/data/catalogo_taco.dart';
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
  final taco = CatalogoTaco.deTexto(File('assets/taco.json').readAsStringSync());

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
    final hoje = hojeLocal();
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

    // Exemplo: Treino A segunda e quinta, Treino B terça e sexta. Semana longe de
    // hoje: o exemplo tem um treino feito 3 dias atrás, que viraria dia de treino.
    final segunda = DateTime(2030, 1, 7), domingo = DateTime(2030, 1, 6);
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

  group('catálogo TACO', () {
    test('valores conhecidos', () {
      final frango = taco.porCodigo(410)!;
      expect(frango.nome, 'Frango, peito, sem pele, grelhado');
      expect((frango.kcal, frango.proteina, frango.gordura), (159.0, 32.0, 2.5));
    });

    test('sem crus que não se comem; comidos crus sem o sufixo', () {
      final nomes = taco.itens.map((i) => i.nome).toSet();
      expect(taco.itens.where((i) => i.grupo.startsWith('Carnes') && i.nome.contains('cru')), isEmpty);
      expect(nomes, isNot(contains('Arroz, tipo 1, cru')));
      expect(nomes, isNot(contains('Feijão, carioca, cru')));
      expect(nomes, isNot(contains('Ovo, de galinha, inteiro, cru')));
      expect(nomes, containsAll(['Arroz, tipo 1, cozido', 'Maçã, Fuji, com casca', 'Laranja, pêra', 'Cenoura', 'Noz']));
      // Só existem crus e se cozinham antes: ficam, avisando que é o peso cru.
      expect(nomes, contains('Macarrão, trigo, peso cru'));
      expect(
          taco.itens.where((i) => RegExp(r'\bcru[as]*\b').hasMatch(i.nome) && !i.nome.endsWith('peso cru')),
          isEmpty);
    });

    test('busca por palavras, sem acento e sem plural; o mais genérico primeiro', () {
      expect(taco.buscar('ovo cozido').first.nome, startsWith('Ovo, de galinha, inteiro, cozido'));
      expect(taco.buscar('banana prata').first.nome, 'Banana, prata');
      expect(taco.buscar('pães').map((i) => i.nome), contains(startsWith('Pão')));
      expect(taco.buscar('xyzw'), isEmpty);
    });

    test('alimentos de unidade trazem o peso de uma unidade', () async {
      final ovo = taco.itens.firstWhere((i) => i.nome.startsWith('Ovo, de galinha, inteiro, cozido'));
      expect((ovo.porcaoNome, ovo.porcaoGramas), ('1 ovo', 50.0));
      expect(taco.itens.firstWhere((i) => i.nome == 'Banana, prata').porcaoGramas, 70);
      expect(taco.itens.firstWhere((i) => i.nome == 'Laranja, pêra, suco').porcaoGramas, isNull);
      expect(taco.itens.firstWhere((i) => i.nome == 'Arroz, tipo 1, cozido').porcaoGramas, isNull);

      final repoTaco = AlimentacaoRepo(db, catalogo: () async => taco);
      final copia = await repoTaco.doCatalogo(ovo);
      expect((copia.porcaoNome, copia.porcaoGramas), ('1 ovo', 50.0));

      // Ajuste da pessoa vale e não é desfeito ao usar de novo.
      await repoTaco.definirPorcao(copia.id, '1 ovo grande', 60);
      expect((await repoTaco.doCatalogo(ovo)).porcaoGramas, 60);
    });

    test('pelo assistente: "comi 2 ovos cozidos" usa a unidade da TACO', () async {
      final comTaco = AssistenteRepo(db, catalogo: () async => taco);
      await comTaco.enviar('comi 2 ovos cozidos no café');
      expect((await comTaco.carregarConversa()).last.texto,
          startsWith('Anotei 100 g de Ovo, de galinha, inteiro, cozido/10minutos no café da manhã: 146 kcal'));
    });

    test('cópias antigas acompanham o catálogo: renomeia e tira as que saíram', () async {
      Future<String> copia(int codigo, String nome) async {
        final id = idNatural('taco', ['$codigo']);
        await db.into(db.alimentos).insert(AlimentosCompanion.insert(
            id: Value(id), nome: nome, kcal: 100, origem: const Value('taco')));
        return id;
      }

      final maca = await copia(taco.itens.firstWhere((i) => i.nome == 'Maçã, Fuji, com casca').codigo,
          'Maçã, Fuji, com casca, crua');
      final arrozCru = await copia(9999, 'Arroz, tipo 1, cru'); // código fora do catálogo
      final repoTaco = AlimentacaoRepo(db, catalogo: () async => taco);
      await repoTaco.atualizarCopiasTaco();

      final lista = {for (final a in await repoTaco.listarAlimentos()) a.id: a};
      expect(lista[maca]?.nome, 'Maçã, Fuji, com casca');
      expect(lista[maca]?.porcaoNome, '1 maçã'); // ganhou a unidade
      expect(lista.containsKey(arrozCru), isFalse);
    });

    test('copiar da TACO usa id fixo pelo código e reativa se excluído', () async {
      final repoTaco = AlimentacaoRepo(db, catalogo: () async => taco);
      final a = await repoTaco.doCatalogo(taco.porCodigo(410)!);
      expect(a.id, idNatural('taco', ['410']));
      await repoTaco.excluirAlimento(a.id);
      await repoTaco.doCatalogo(taco.porCodigo(410)!);
      expect(await repoTaco.listarAlimentos(), hasLength(1));
    });
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
      expect((await repo.carregarDia(hojeLocal())).daRefeicao(Refeicao.cafe), hasLength(1));

      await assistente.desfazer(r);
      expect((await repo.carregarDia(hojeLocal())).registros, isEmpty);
    });

    test('fora da lista e da TACO pede cadastro', () async {
      final semTaco = AssistenteRepo(db, catalogo: () async => CatalogoTaco.deTexto('{"alimentos": []}'));
      await semTaco.enviar('comi 200 g de picanha');
      expect((await ultima()).texto, contains('Não achei “picanha” nos seus alimentos nem na TACO'));
    });

    test('várias opções na TACO: lista para a pessoa escolher', () async {
      final comTaco = AssistenteRepo(db, catalogo: () async => taco);
      await comTaco.enviar('comi 200 g de picanha');
      final r = (await ultima()).texto;
      expect(r, startsWith('Achei mais de uma opção na TACO para “picanha”'));
      expect(r, contains('Carne, bovina, picanha'));
    });

    test('uma opção só na TACO: registra e copia para a lista', () async {
      final comTaco = AssistenteRepo(db, catalogo: () async => taco);
      await comTaco.enviar('comi 150 g de frango peito sem pele grelhado no almoço');
      expect((await ultima()).texto,
          startsWith('Anotei 150 g de Frango, peito, sem pele, grelhado no almoço: 239 kcal, 48 g de proteína.'));
      final copia = (await repo.listarAlimentos()).single;
      expect(copia.origem, 'taco');
      expect(copia.id, idNatural('taco', ['410']));
    });

    test('sem porção e número pequeno pergunta os gramas', () async {
      await alimento('Arroz branco cozido', 130, 2.5, 28, 0.3);
      await assistente.enviar('comi 2 arroz');
      expect((await ultima()).texto, startsWith('Quantos gramas de Arroz branco cozido?'));
    });
  });
}
