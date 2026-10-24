import 'package:aurora/core/relogio.dart';
import 'package:aurora/data/analise_financas.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/exemplo.dart';
import 'package:aurora/data/financas_repo.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
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

  test('parceladas: quanto falta e quando termina', () async {
    final q = await FinancasRepo(db).carregar();
    final lista = listarParceladas(q);
    final faculdade = lista.singleWhere((p) => p.transacao.descricao == 'Faculdade');
    expect(faculdade.total, 27);
    expect(faculdade.quitada, isFalse);
    expect(faculdade.faltaCentavos, (27 - faculdade.pagas) * 19000);
    expect(faculdade.termina, isNotNull);
    // Lançada como a parcela 2 de 27: a última vence 25 meses depois desta.
    final esta = q.ocorrencias(faculdade.transacao, DateTime(2000), DateTime(2100)).single.vencimento;
    expect(faculdade.termina, DateTime(esta.year, esta.month + 25, esta.day));
  });

  test('análise do mês: média, projeção e comparação', () async {
    final q = await FinancasRepo(db).carregar();
    final hoje = hojeLocal();
    final mes = DateTime(hoje.year, hoje.month, 1);
    final a = analisarMes(q, mes, hoje);
    expect(a.gastoCentavos, q.mes(mes).saiuCentavos);
    expect(a.mediaDiaCentavos, a.gastoCentavos ~/ hoje.day);
    expect(a.projecaoCentavos, isNotNull);
    expect(a.projecaoCentavos!, greaterThanOrEqualTo(a.gastoCentavos));
    expect(a.maiores.length, lessThanOrEqualTo(5));
    for (var i = 1; i < a.maiores.length; i++) {
      expect(a.maiores[i - 1].valorCentavos, greaterThanOrEqualTo(a.maiores[i].valorCentavos));
    }

    // Mês passado: sem projeção; média sobre o mês inteiro.
    final passado = DateTime(hoje.year, hoje.month - 1, 1);
    final b = analisarMes(q, passado, hoje);
    expect(b.projecaoCentavos, isNull);
    expect(b.mediaDiaCentavos, b.gastoCentavos ~/ DateTime(passado.year, passado.month + 1, 0).day);
  });

  test('painel: receitas, despesas, tendência e transações recentes', () async {
    final repo = FinancasRepo(db);
    final hoje = hojeLocal();
    final mes = DateTime(hoje.year, hoje.month, 1);
    final passado = DateTime(hoje.year, hoje.month - 1, 10);
    Future<void> lancar(String nome, int centavos, TipoTransacao tipo, DateTime quando, String cat) =>
        db.into(db.transacoes).insert(TransacoesCompanion.insert(
              descricao: nome,
              valorCentavos: centavos,
              tipo: tipo,
              data: instanteLocal(quando, 12),
              categoria: Value(cat),
              pagoEm: Value(instanteLocal(quando, 12)),
            ));
    await lancar('Salário', 500000, TipoTransacao.entrada, passado, 'Salário');
    await lancar('Mercado', 40000, TipoTransacao.saida, passado, 'Mercado');
    await lancar('Salário', 550000, TipoTransacao.entrada, hoje, 'Salário');
    await lancar('Mercado', 30000, TipoTransacao.saida, hoje, 'Mercado');
    await lancar('Cinema', 6000, TipoTransacao.saida, hoje, 'Lazer');

    final q = await repo.carregar();
    final p = painelDoMes(q, mes);
    final m = q.mes(mes);
    expect(p.receitasCentavos, m.entrouCentavos);
    expect(p.despesasCentavos, m.saiuCentavos);
    expect(p.resultadoCentavos, m.entrouCentavos - m.saiuCentavos);
    expect(p.saldoCentavos, q.saldoCentavos);
    // Há receitas no mês passado, então dá para comparar.
    expect(p.variacaoReceitas, isNotNull);
    expect(p.categorias.first.centavos, greaterThanOrEqualTo(p.categorias.last.centavos));
    expect(p.recentes.length, lessThanOrEqualTo(6));
    expect(p.recentes.every((x) => !x.transferencia), isTrue);
    for (var i = 1; i < p.recentes.length; i++) {
      expect(p.recentes[i - 1].instante.isBefore(p.recentes[i].instante), isFalse);
    }
  });
}
