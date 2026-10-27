import 'package:aurora/app.dart';
import 'package:aurora/core/relogio.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/exemplo.dart';
import 'package:aurora/data/financas_repo.dart';
import 'package:aurora/data/graficos_financas.dart';
import 'package:aurora/ui/financas/graficos/cartao_categorias.dart';
import 'package:aurora/ui/financas/graficos/config.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
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

  test('gasto por dia: soma o mês e prevê os dias que faltam', () async {
    final q = await FinancasRepo(db).carregar();
    final hoje = hojeLocal();
    final mes = DateTime(hoje.year, hoje.month, 1);
    final g = gastoPorDia(q, mes, hoje);
    expect(g.pago.length, DateTime(mes.year, mes.month + 1, 0).day);
    expect(g.totalPagoCentavos, q.mes(mes).saiuCentavos);
    expect(g.hojeIndice, hoje.day - 1);
    for (var i = 0; i <= hoje.day - 1; i++) {
      expect(g.previsto[i], 0, reason: 'dia ${i + 1} já passou');
    }
    // Mês passado: sem previsão.
    final passado = gastoPorDia(q, DateTime(hoje.year, hoje.month - 1, 1), hoje);
    expect(passado.totalPrevistoCentavos, 0);
    expect(passado.hojeIndice, isNull);
  });

  test('fluxo do dinheiro: entradas e saídas fecham com a sobra', () async {
    final q = await FinancasRepo(db).carregar();
    final hoje = hojeLocal();
    for (final previstos in [false, true]) {
      final f = fluxoDoDinheiro(q, hoje, comPrevistos: previstos);
      final entra = f.origens.fold(0, (s, x) => s + x.centavos);
      final sai = f.destinos.fold(0, (s, x) => s + x.centavos);
      expect(entra, sai, reason: 'os dois lados do fluxo têm a mesma altura');
      if (f.sobraCentavos > 0) expect(f.destinos.last.nome, nomeSobra);
      if (f.sobraCentavos < 0) expect(f.origens.last.nome, nomeSaldoAnterior);
    }
    final m = q.mes(hoje);
    expect(fluxoDoDinheiro(q, hoje).sobraCentavos, m.entrouCentavos - m.saiuCentavos);
  });

  test('velas do saldo: cada mês abre onde o anterior fechou e termina no saldo de hoje', () async {
    final q = await FinancasRepo(db).carregar();
    final hoje = hojeLocal();
    final velas = velasDoSaldo(q, hoje, hoje);
    expect(velas, hasLength(6));
    for (var i = 1; i < velas.length; i++) {
      expect(velas[i].abertura, velas[i - 1].fechamento);
    }
    expect(velas.last.fechamento, q.patrimonioCentavos);
    for (final v in velas) {
      expect(v.maxima, greaterThanOrEqualTo(v.abertura));
      expect(v.maxima, greaterThanOrEqualTo(v.fechamento));
      expect(v.minima, lessThanOrEqualTo(v.abertura));
      expect(v.minima, lessThanOrEqualTo(v.fechamento));
    }
    final p = projetarSaldo(velas.last.fechamento, q.serie(hoje));
    for (var i = 0; i < p.media.length; i++) {
      expect(p.pessimista[i], lessThanOrEqualTo(p.media[i]));
      expect(p.otimista[i], greaterThanOrEqualTo(p.media[i]));
    }
  });

  test('rigidez, categorias no tempo e mapa de calor batem com o gasto', () async {
    final q = await FinancasRepo(db).carregar();
    final hoje = hojeLocal();
    final r = rigidez(q, hoje);
    expect(r.last.totalCentavos, q.mes(hoje).saiuCentavos);
    final ct = categoriasNoTempo(q, hoje, maxCategorias: 2);
    expect(ct.series.length, lessThanOrEqualTo(3));
    for (var i = 0; i < ct.meses.length; i++) {
      final soma = ct.series.values.fold(0, (s, serie) => s + serie[i]);
      expect(soma, q.mes(ct.meses[i]).saiuCentavos);
    }
    final calor = mapaDeCalor(q, hoje, hoje);
    expect(calor.valores, hasLength(6));
    expect(calor.inicio.weekday, DateTime.monday);
    expect(calor.valores.last.where((v) => v == null).length, 7 - hoje.weekday);
  });

  test('configuração do painel: guarda e lê ordem, ocultos e tipos', () {
    final c = ConfigPainel.padrao()
      ..ocultos.add(CartaoFin.recentes)
      ..tipos[CartaoFin.categorias] = TipoGrafico.radar
      ..porGrupo.add(CartaoFin.categorias);
    c.ordem[PainelFin.resumo] = [CartaoFin.fluxoCaixa, ...CartaoFin.doPainel(PainelFin.resumo).where((x) => x != CartaoFin.fluxoCaixa)];
    final lida = ConfigPainel.deJson(c.paraJson());
    expect(lida.ordem[PainelFin.resumo]!.first, CartaoFin.fluxoCaixa);
    expect(lida.ocultos, {CartaoFin.recentes});
    expect(lida.tipoDe(CartaoFin.categorias), TipoGrafico.radar);
    expect(lida.tipoDe(CartaoFin.fluxoCaixa), TipoGrafico.barras, reason: 'sem escolha, o primeiro tipo');
    expect(lida.visiveis(PainelFin.resumo), isNot(contains(CartaoFin.recentes)));
    expect(lida.usaGrupo(CartaoFin.categorias), isTrue);
    expect(lida.usaGrupo(CartaoFin.fluxoCaixa), isFalse);
    // JSON estragado ou de versão antiga: volta ao padrão sem quebrar.
    expect(ConfigPainel.deJson('{oi').ordem[PainelFin.analise], CartaoFin.doPainel(PainelFin.analise));
    final parcial = ConfigPainel.deJson('{"ordem":{"resumo":["recentes","nao_existe"]}}');
    expect(parcial.ordem[PainelFin.resumo]!.first, CartaoFin.recentes);
    expect(parcial.ordem[PainelFin.resumo]!.toSet(), CartaoFin.doPainel(PainelFin.resumo).toSet());
  });

  test('blocos (treemap): cobrem a área toda, proporcionais aos valores', () {
    const area = Rect.fromLTWH(0, 0, 300, 200);
    final valores = <double>[50, 25, 15, 10];
    final r = dividirEmBlocos(valores, area);
    final soma = r.fold(0.0, (s, x) => s + x.width * x.height);
    expect(soma, closeTo(area.width * area.height, 0.01));
    for (var i = 0; i < valores.length; i++) {
      expect(r[i].width * r[i].height / soma, closeTo(valores[i] / 100, 0.001));
    }
  });

  group('tela', () {
    Future<void> abrir(WidgetTester t, Size tamanho) async {
      t.view.physicalSize = tamanho;
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(AuroraApp(db: db, escuro: ValueNotifier(true)));
      await assentar(t);
      await t.tap(find.bySemanticsLabel('Finanças').first);
      await assentar(t);
    }

    Future<void> tocarTodosOsTipos(WidgetTester t) async {
      // Cada seletor de tipo: toca todos os tipos de todos os cartões visíveis.
      for (final tipo in TipoGrafico.values) {
        final alvo = find.bySemanticsLabel('Gráfico: ${tipo.rotulo}');
        for (var i = 0; i < alvo.evaluate().length; i++) {
          await t.ensureVisible(alvo.at(i));
          await t.tap(alvo.at(i), warnIfMissed: false);
          await assentar(t);
          expect(t.takeException(), isNull, reason: 'tipo ${tipo.name}');
        }
      }
    }

    for (final (nome, tamanho) in [('computador', const Size(1280, 900)), ('celular', const Size(390, 860))]) {
      testWidgets('$nome: Resumo e Análise mostram os cartões e trocam de tipo', (t) async {
        await abrir(t, tamanho);
        if (find.bySemanticsLabel('Finanças').evaluate().isEmpty) return;
        for (final titulo in ['Fluxo do dinheiro no mês', 'Despesas por categoria', 'Gasto por dia', 'Fluxo de caixa']) {
          await t.scrollUntilVisible(find.text(titulo), 300, scrollable: _lista);
          expect(find.text(titulo), findsWidgets);
        }
        await tocarTodosOsTipos(t);

        for (var i = 0; i < 6; i++) {
          await t.drag(_lista, const Offset(0, 3000), warnIfMissed: false);
          await t.pump();
        }
        await t.ensureVisible(find.text('Análise').first);
        await t.pump();
        await t.tap(find.text('Análise').first);
        await assentar(t);
        for (final titulo in ['Leituras do período', 'Trajetória do saldo', 'Categorias no tempo', 'Mapa de calor do gasto']) {
          await t.scrollUntilVisible(find.text(titulo), 300, scrollable: _lista);
          expect(find.text(titulo), findsWidgets);
        }
        await tocarTodosOsTipos(t);
        await t.pumpWidget(const SizedBox());
      });
    }

    testWidgets('Despesas por categoria: agrupa por grupo e guarda a escolha', (t) async {
      // Um gasto pago no mês: sem ele o cartão fica no estado vazio (sem subtítulo).
      await t.runAsync(() => FinancasRepo(db).salvar(TransacoesCompanion.insert(
            descricao: 'Feira',
            valorCentavos: 5000,
            tipo: TipoTransacao.saida,
            data: instanteLocal(hojeLocal(), 10),
            pagoEm: Value(instanteLocal(hojeLocal(), 10)),
            categoria: const Value('Mercado'),
          )));
      await abrir(t, const Size(1280, 900));
      await t.scrollUntilVisible(find.text('Despesas por categoria'), 300, scrollable: _lista);
      expect(find.text('Para onde foi o dinheiro neste mês'), findsOneWidget);

      final botao = find.bySemanticsLabel('Somar por grupo');
      await t.ensureVisible(botao);
      await t.pump();
      await t.tap(botao);
      await assentar(t);
      expect(find.text('Para onde foi o dinheiro neste mês · por grupo'), findsOneWidget);
      expect(find.bySemanticsLabel('Ver por categoria'), findsOneWidget);

      final salvo = await t.runAsync(() => db.preferencia(PreferenciasPainel.chave));
      expect(ConfigPainel.deJson(salvo).usaGrupo(CartaoFin.categorias), isTrue);

      await t.tap(find.bySemanticsLabel('Ver por categoria'));
      await assentar(t);
      expect(find.text('Para onde foi o dinheiro neste mês'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('Outros: o pé do cartão abre a revisão, com a sugestão pelo nome', (t) async {
      await t.runAsync(() => FinancasRepo(db).salvar(TransacoesCompanion.insert(
            descricao: 'Empréstimo carol',
            valorCentavos: 10000,
            tipo: TipoTransacao.saida,
            data: instanteLocal(hojeLocal(), 10),
            pagoEm: Value(instanteLocal(hojeLocal(), 10)),
            categoria: const Value('Outros'),
          )));
      await abrir(t, const Size(1280, 900));
      final pe = find.textContaining('em Outros ·');
      await t.scrollUntilVisible(pe, 300, scrollable: _lista);
      expect(pe, findsOneWidget);

      final alvo = find.ancestor(of: pe, matching: find.byType(InkWell)).first;
      await t.ensureVisible(alvo);
      await t.pump();
      await t.tap(alvo);
      await assentar(t);
      expect(find.text('O que caiu em Outros'), findsOneWidget);
      expect(find.text('Empréstimo carol'), findsWidgets);
      // "empréstimo" no nome já cai em Dívidas e juros.
      expect(find.text('Dívidas e juros'), findsWidgets);

      await t.tap(find.text('Pronto'));
      await assentar(t);
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('Personalizar: desligar um cartão some com ele e fica salvo', (t) async {
      await abrir(t, const Size(1280, 900));
      expect(find.text('Fluxo do dinheiro no mês'), findsWidgets);
      await t.tap(find.text('Personalizar'));
      await assentar(t);
      expect(find.text('Personalizar painel'), findsOneWidget);
      final linha = find.ancestor(of: find.text('Fluxo do dinheiro no mês').last, matching: find.byType(Row)).first;
      await t.tap(find.descendant(of: linha, matching: find.byType(Switch)));
      await assentar(t);
      await t.tap(find.text('Pronto'));
      await assentar(t);
      expect(find.text('Fluxo do dinheiro no mês'), findsNothing);
      final salvo = await t.runAsync(() => db.preferencia(PreferenciasPainel.chave));
      expect(ConfigPainel.deJson(salvo).ocultos, contains(CartaoFin.fluxoDinheiro));
      await t.pumpWidget(const SizedBox());
    });
  });
}

Future<void> assentar(WidgetTester t) async {
  await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 60)));
  await t.pump(const Duration(milliseconds: 300));
  await t.pump(const Duration(milliseconds: 300));
}

/// A lista principal da tela (a última rolável vertical; no computador o menu
/// lateral também rola e vem antes).
final _lista = find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down).last;
