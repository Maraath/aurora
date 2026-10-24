import 'package:aurora/core/recorrencia.dart';
import 'package:aurora/core/relogio.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/exemplo.dart';
import 'package:aurora/data/financas_repo.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late BancoAurora db;
  late FinancasRepo repo;
  late DateTime hoje;
  late DateTime primeiroDoMes;

  setUpAll(() async {
    iniciarRelogio();
    await initializeDateFormatting('pt_BR');
  });

  setUp(() async {
    db = BancoAurora(NativeDatabase.memory());
    repo = FinancasRepo(db);
    await semearExemplo(db);
    hoje = hojeLocal();
    primeiroDoMes = DateTime(hoje.year, hoje.month, 1);
  });

  tearDown(() => db.close());

  DateTime mesQueVem(int n) => DateTime(hoje.year, hoje.month + n, 1);

  Future<Transacao> criar({
    required String nome,
    required int centavos,
    TipoTransacao tipo = TipoTransacao.saida,
    String? regra,
    int? parcelas,
    bool paga = false,
    String? contaId,
    String categoria = 'Serviços',
  }) async {
    final venc = instanteLocal(primeiroDoMes, 9);
    final id = await repo.salvar(
      TransacoesCompanion.insert(
        descricao: nome,
        valorCentavos: centavos,
        tipo: tipo,
        data: venc,
        vencimento: paga && regra == null ? const Value(null) : Value(venc),
        pagoEm: Value(paga && regra == null ? venc : null),
        regraRepeticao: Value(regra),
        parcelaNumero: Value(parcelas == null ? null : 1),
        parcelaTotal: Value(parcelas),
        categoria: Value(categoria),
        contaId: Value(contaId),
      ),
      pagarPrimeira: paga,
    );
    return (db.select(db.transacoes)..where((t) => t.id.equals(id))).getSingle();
  }

  test('exemplo: saldo inicial e as três contas atrasadas', () async {
    final q = await repo.carregar();
    expect(q.saldoCentavos, 70318);
    final mes = q.mes(hoje);
    expect(mes.contasAbertas, 3);
    expect(mes.faltaPagarCentavos, 22280);
    expect(mes.aPagar.every((o) => o.atrasada(hoje)), isTrue);
    expect(mes.aPagar.map((o) => o.nome), contains('Faculdade · 2/27'));
  });

  test('pagar uma conta única tira do saldo e entra em "para onde foi"', () async {
    var q = await repo.carregar();
    final icloud = q.mes(hoje).aPagar.firstWhere((o) => o.nome == 'iCloud');
    await repo.pagar(icloud, true);

    q = await repo.carregar();
    final mes = q.mes(hoje);
    expect(q.saldoCentavos, 70318 - 1990);
    expect(mes.faltaPagarCentavos, 22280 - 1990);
    expect(mes.saiuCentavos, 1990);
    expect(mes.categorias.single.nome, 'Serviços');
    expect(mes.extrato.single.nome, 'iCloud');
    // A conta paga continua na lista do mês, marcada como paga.
    expect(mes.aPagar.firstWhere((o) => o.nome == 'iCloud').paga, isTrue);

    await repo.pagar(icloud, false);
    expect((await repo.carregar()).saldoCentavos, 70318);
  });

  test('recorrente é uma regra: aparece todo mês e só o pagamento vira linha', () async {
    final t = await criar(nome: 'Spotify', centavos: 2190, regra: const Regra.mensal(1).rrule);
    var q = await repo.carregar();
    final agora = q.mes(hoje).aPagar.where((o) => o.transacao.id == t.id).single;
    expect(agora.vencimento, primeiroDoMes);
    expect(q.mes(mesQueVem(1)).aPagar.where((o) => o.transacao.id == t.id), hasLength(1));
    expect(q.mes(mesQueVem(5)).aPagar.where((o) => o.transacao.id == t.id), hasLength(1));

    await repo.pagar(agora, true);
    q = await repo.carregar();
    expect(q.mes(hoje).aPagar.where((o) => o.transacao.id == t.id).single.paga, isTrue);
    expect(q.mes(mesQueVem(1)).aPagar.where((o) => o.transacao.id == t.id).single.paga, isFalse);
    expect(await db.select(db.transacoes).get(), hasLength(4));
    expect(await db.select(db.pagamentosTransacao).get(), hasLength(1));
    expect(q.proximaAberta(t)?.vencimento, mesQueVem(1));
  });

  test('editar o valor de uma recorrente não muda o que já foi pago', () async {
    final t = await criar(
        nome: 'Academia', centavos: 9900, regra: const Regra.mensal(1).rrule, paga: true);
    await repo.salvar(const TransacoesCompanion(valorCentavos: Value(12900)), id: t.id);
    final q = await repo.carregar();
    expect(q.mes(hoje).saiuCentavos, 9900);
    expect(q.mes(mesQueVem(1)).aPagar.where((o) => o.transacao.id == t.id).single.valorCentavos,
        12900);
  });

  test('parcelada termina na última parcela', () async {
    final t = await criar(
        nome: 'Notebook', centavos: 10000, regra: const Regra.mensal(1).rrule, parcelas: 3);
    final q = await repo.carregar();
    String? nome(int n) =>
        q.mes(mesQueVem(n)).aPagar.where((o) => o.transacao.id == t.id).firstOrNull?.nome;
    expect(nome(0), 'Notebook · 1/3');
    expect(nome(2), 'Notebook · 3/3');
    expect(nome(3), isNull);
    expect(q.parceladas.map((p) => p.descricao), containsAll(['Notebook', 'Faculdade']));
  });

  test('excluir recorrente com pagamento encerra a regra e mantém o histórico', () async {
    final t = await criar(
        nome: 'Streaming', centavos: 3990, regra: const Regra.mensal(1).rrule, paga: true);
    await repo.excluir(t);
    final q = await repo.carregar();
    expect(q.mes(mesQueVem(1)).aPagar.where((o) => o.transacao.id == t.id), isEmpty);
    expect(q.mes(hoje).extrato.where((m) => m.transacao.id == t.id), hasLength(1));
    expect(q.recorrentes.map((r) => r.descricao), contains('Streaming'));
  });

  test('excluir sem pagamento apaga', () async {
    final t = await criar(nome: 'Teste', centavos: 100, regra: const Regra.mensal(1).rrule);
    await repo.excluir(t);
    expect((await repo.carregar()).recorrentes, isEmpty);
  });

  test('compra no cartão vai para a fatura; pagar a fatura não conta como gasto de novo', () async {
    final corrente = (await repo.carregar()).contaPrincipalId!;
    final cartaoId = await repo.salvarConta(ContasFinanceirasCompanion.insert(
        nome: 'Cartão', tipo: TipoConta.cartao, diaVencimento: const Value(10)));
    await criar(nome: 'Mercado', centavos: 5000, paga: true, contaId: cartaoId, categoria: 'Mercado');

    var q = await repo.carregar();
    expect(q.faturasCentavos, 5000);
    expect(q.saldoCentavos, 70318);
    expect(q.mes(hoje).saiuCentavos, 5000);

    final cartao = q.contas.firstWhere((c) => c.id == cartaoId);
    await repo.pagarFatura(
        cartao: cartao, origemId: corrente, valorCentavos: 5000, instante: DateTime.now());
    q = await repo.carregar();
    expect(q.faturasCentavos, 0);
    expect(q.saldoCentavos, 70318 - 5000);
    expect(q.mes(hoje).saiuCentavos, 5000);
    expect(q.mes(hoje).categorias.map((c) => c.nome), ['Mercado']);
    expect(q.patrimonioCentavos, 70318 - 5000);
  });

  test('conta em uso não pode ser excluída', () async {
    final q = await repo.carregar();
    expect(await repo.excluirConta(q.contaPrincipalId!), isFalse);
  });

  test('entrada recorrente aparece em "a receber" e soma em "entrou" ao receber', () async {
    final t = await criar(
        nome: 'Salário', centavos: 500000, tipo: TipoTransacao.entrada,
        regra: const Regra.mensal(1).rrule, categoria: 'Salário');
    var q = await repo.carregar();
    final o = q.mes(hoje).aReceber.single;
    expect(o.transacao.id, t.id);
    await repo.pagar(o, true);
    q = await repo.carregar();
    expect(q.mes(hoje).entrouCentavos, 500000);
    expect(q.saldoCentavos, 70318 + 500000);
    expect(q.serie(hoje).last.entrouCentavos, 500000);
  });

  test('sem nenhuma conta cadastrada, a entrada recebida entra no saldo', () async {
    // App novo: começa vazio, sem conta. (Bug da 1.0.6: o saldo ficava em zero.)
    final vazio = BancoAurora(NativeDatabase.memory());
    addTearDown(vazio.close);
    await vazio.into(vazio.transacoes).insert(TransacoesCompanion.insert(
          descricao: 'Salário',
          valorCentavos: 70000,
          tipo: TipoTransacao.entrada,
          data: instanteLocal(hoje, 9),
          pagoEm: Value(instanteLocal(hoje, 9)),
        ));
    final q = await FinancasRepo(vazio).carregar();
    expect(q.contas, isEmpty);
    expect(q.mes(hoje).entrouCentavos, 70000);
    expect(q.semContaCentavos, 70000);
    expect(q.saldoCentavos, 70000);
    expect(q.patrimonioCentavos, 70000);
  });

  test('lançamento numa conta excluída não some do saldo', () async {
    final conta = await db.into(db.contasFinanceiras).insertReturning(
        ContasFinanceirasCompanion.insert(nome: 'Antiga', tipo: TipoConta.corrente));
    await (db.update(db.contasFinanceiras)..where((c) => c.id.equals(conta.id)))
        .write(ContasFinanceirasCompanion(apagadoEm: Value(DateTime.now())));
    final antes = await repo.carregar();
    await db.into(db.transacoes).insert(TransacoesCompanion.insert(
          descricao: 'Pix recebido',
          valorCentavos: 5000,
          tipo: TipoTransacao.entrada,
          data: instanteLocal(hoje, 10),
          pagoEm: Value(instanteLocal(hoje, 10)),
          contaId: Value(conta.id),
        ));
    final depois = await repo.carregar();
    expect(depois.saldoCentavos, antes.saldoCentavos + 5000);
  });
}
