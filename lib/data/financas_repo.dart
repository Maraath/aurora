import 'package:drift/drift.dart';

import '../core/recorrencia.dart';
import '../core/relogio.dart';
import 'banco.dart';
import 'observar.dart';

/// Categoria das transferências que pagam a fatura de um cartão.
const categoriaFatura = 'Fatura do cartão';

const categoriasSaida = [
  'Mercado', 'Serviços', 'Transporte', 'Lazer', 'Saúde', 'Educação', 'Moradia', 'Outros',
];
const categoriasEntrada = ['Salário', 'Freela', 'Outros'];

enum FormaTransacao { unica, recorrente, parcelada }

FormaTransacao formaDe(Transacao t) {
  if (t.regraRepeticao == null) return FormaTransacao.unica;
  return t.parcelaTotal != null ? FormaTransacao.parcelada : FormaTransacao.recorrente;
}

/// Uma conta a pagar (ou a receber) num vencimento: a própria transação única
/// ou uma ocorrência de recorrente/parcelada.
class Ocorrencia {
  const Ocorrencia({
    required this.transacao,
    required this.vencimento,
    this.parcela,
    this.pagoEm,
    this.valorPagoCentavos,
  });

  final Transacao transacao;

  /// Data de calendário (São Paulo).
  final DateTime vencimento;
  final int? parcela;
  final DateTime? pagoEm;
  final int? valorPagoCentavos;

  bool get paga => pagoEm != null;
  bool get entrada => transacao.tipo == TipoTransacao.entrada;
  bool get daRegra => transacao.regraRepeticao != null;
  int get valorCentavos => valorPagoCentavos ?? transacao.valorCentavos;
  String get nome => nomeComParcela(transacao, parcela);
  bool atrasada(DateTime hoje) => !paga && vencimento.isBefore(hoje);
}

/// Dinheiro que de fato entrou ou saiu (vai para o extrato e os saldos).
class Movimento {
  const Movimento({
    required this.transacao,
    required this.instante,
    required this.valorCentavos,
    this.parcela,
  });

  final Transacao transacao;
  final DateTime instante;
  final int valorCentavos;
  final int? parcela;

  DateTime get dia => dataSP(instante);
  bool get entrada => transacao.tipo == TipoTransacao.entrada;
  bool get transferencia => transacao.contaDestinoId != null;
  String get nome => nomeComParcela(transacao, parcela);
  String get categoria => transacao.categoria ?? 'Outros';
}

String nomeComParcela(Transacao t, int? parcela) {
  final n = parcela ?? t.parcelaNumero;
  final total = t.parcelaTotal;
  return n != null && total != null ? '${t.descricao} · $n/$total' : t.descricao;
}

class SaldoConta {
  const SaldoConta(this.conta, this.saldoCentavos);
  final ContaFinanceira conta;

  /// Num cartão, saldo negativo é a fatura em aberto.
  final int saldoCentavos;

  bool get cartao => conta.tipo == TipoConta.cartao;
  int get faturaCentavos => cartao && saldoCentavos < 0 ? -saldoCentavos : 0;
}

class CategoriaGasto {
  const CategoriaGasto(this.nome, this.centavos);
  final String nome;
  final int centavos;
}

class TotaisMes {
  const TotaisMes(this.mes, this.entrouCentavos, this.saiuCentavos);
  final DateTime mes;
  final int entrouCentavos;
  final int saiuCentavos;
}

/// O mês visto em Finanças.
class MesFinancas {
  const MesFinancas({
    required this.mes,
    required this.entrouCentavos,
    required this.saiuCentavos,
    required this.aPagar,
    required this.aReceber,
    required this.categorias,
    required this.extrato,
  });

  /// Primeiro dia do mês.
  final DateTime mes;
  final int entrouCentavos;
  final int saiuCentavos;

  /// Contas do mês (pagas e não pagas) e, no mês atual, as atrasadas de antes.
  final List<Ocorrencia> aPagar;
  final List<Ocorrencia> aReceber;

  /// Para onde foi o dinheiro, do maior para o menor.
  final List<CategoriaGasto> categorias;

  /// Movimentos do mês, do mais recente para o mais antigo.
  final List<Movimento> extrato;

  int get faltaPagarCentavos =>
      aPagar.where((o) => !o.paga).fold(0, (s, o) => s + o.valorCentavos);
  int get contasAbertas => aPagar.where((o) => !o.paga).length;
}

/// Fotografia das finanças para as telas.
class QuadroFinancas {
  QuadroFinancas({
    required this.hoje,
    required this.contas,
    required this.transacoes,
    required this.pagamentos,
  }) {
    _calcularMovimentos();
  }

  final DateTime hoje;
  final List<ContaFinanceira> contas;
  final List<Transacao> transacoes;

  /// transacaoId → vencimento ("aaaa-mm-dd") → pagamento.
  final Map<String, Map<String, PagamentoTransacao>> pagamentos;

  late final List<Movimento> movimentos;
  late final List<SaldoConta> saldos;

  /// Movimentos sem conta cadastrada (ou de conta excluída).
  late final int semContaCentavos;

  /// Conta usada quando a transação não diz qual: a primeira que não é cartão.
  String? get contaPrincipalId =>
      contas.where((c) => c.tipo != TipoConta.cartao).firstOrNull?.id ?? contas.firstOrNull?.id;

  int get saldoCentavos =>
      saldos.where((s) => !s.cartao).fold(semContaCentavos, (soma, s) => soma + s.saldoCentavos);
  int get faturasCentavos => saldos.fold(0, (soma, s) => soma + s.faturaCentavos);

  /// Patrimônio: o que há nas contas menos as faturas em aberto.
  int get patrimonioCentavos => saldos.fold(semContaCentavos, (soma, s) => soma + s.saldoCentavos);

  List<Transacao> get recorrentes =>
      transacoes.where((t) => formaDe(t) == FormaTransacao.recorrente).toList()
        ..sort((a, b) => a.descricao.compareTo(b.descricao));

  /// Parceladas por regra e as antigas gravadas como uma parcela só.
  List<Transacao> get parceladas => transacoes
      .where((t) =>
          formaDe(t) == FormaTransacao.parcelada ||
          (t.regraRepeticao == null && t.parcelaTotal != null))
      .toList()
    ..sort((a, b) => a.descricao.compareTo(b.descricao));

  void _calcularMovimentos() {
    final porId = {for (final t in transacoes) t.id: t};
    final lista = <Movimento>[];
    for (final t in transacoes) {
      if (t.regraRepeticao == null && t.pagoEm != null) {
        lista.add(Movimento(transacao: t, instante: t.pagoEm!, valorCentavos: t.valorCentavos));
      }
    }
    for (final MapEntry(key: id, value: porVenc) in pagamentos.entries) {
      final t = porId[id];
      if (t == null) continue;
      for (final p in porVenc.values) {
        lista.add(Movimento(
          transacao: t,
          instante: p.pagoEm,
          valorCentavos: p.valorCentavos,
          parcela: numeroParcela(t, DateTime.parse(p.vencimento)),
        ));
      }
    }
    lista.sort((a, b) => b.instante.compareTo(a.instante));
    movimentos = lista;

    final principal = contaPrincipalId;
    final soma = {for (final c in contas) c.id: c.saldoInicialCentavos};
    var semConta = 0;
    // Sem conta cadastrada (ou com a conta excluída) o valor não some: vai
    // para "sem conta", que também entra no saldo.
    void somar(String? conta, int centavos) {
      if (conta != null && soma.containsKey(conta)) {
        soma[conta] = soma[conta]! + centavos;
      } else {
        semConta += centavos;
      }
    }

    for (final m in lista) {
      final conta = m.transacao.contaId ?? principal;
      if (m.entrada) {
        somar(conta, m.valorCentavos);
      } else {
        somar(conta, -m.valorCentavos);
        final destino = m.transacao.contaDestinoId;
        if (destino != null) somar(destino, m.valorCentavos);
      }
    }
    saldos = [for (final c in contas) SaldoConta(c, soma[c.id] ?? 0)];
    semContaCentavos = semConta;
  }

  /// Ocorrências de [t] com vencimento entre [de] e [ate] (inclusive).
  Iterable<Ocorrencia> ocorrencias(Transacao t, DateTime de, DateTime ate) sync* {
    final regra = Regra.ler(t.regraRepeticao);
    if (regra == null) {
      if (t.vencimento == null) return; // movimento direto, não é conta
      final v = dataSP(t.vencimento!);
      if (!v.isBefore(de) && !v.isAfter(ate)) {
        yield Ocorrencia(transacao: t, vencimento: v, pagoEm: t.pagoEm);
      }
      return;
    }
    final inicio = inicioDaRegra(t);
    final pagos = pagamentos[t.id] ?? const {};
    for (final v in regra.ocorrencias(inicio, de, ate)) {
      final n = numeroParcela(t, v);
      if (n != null && n > t.parcelaTotal!) break;
      final p = pagos[chaveData(v)];
      yield Ocorrencia(
        transacao: t,
        vencimento: v,
        parcela: n,
        pagoEm: p?.pagoEm,
        valorPagoCentavos: p?.valorCentavos,
      );
    }
  }

  /// Próxima ocorrência ainda não paga (para as listas de fixas).
  Ocorrencia? proximaAberta(Transacao t) {
    final de = t.regraRepeticao == null ? DateTime(2000) : inicioDaRegra(t);
    for (final o in ocorrencias(t, de, DateTime(hoje.year + 5, hoje.month, hoje.day))) {
      if (!o.paga) return o;
    }
    return null;
  }

  /// Parcelas já pagas de uma parcelada.
  int parcelasPagas(Transacao t) {
    if (t.regraRepeticao == null) return t.pagoEm == null ? (t.parcelaNumero ?? 1) - 1 : t.parcelaNumero ?? 1;
    return (t.parcelaNumero ?? 1) - 1 + (pagamentos[t.id]?.length ?? 0);
  }

  MesFinancas mes(DateTime qualquerDia) {
    final inicio = DateTime(qualquerDia.year, qualquerDia.month, 1);
    final fim = DateTime(qualquerDia.year, qualquerDia.month + 1, 0);
    final mesAtual = inicio.year == hoje.year && inicio.month == hoje.month;

    final aPagar = <Ocorrencia>[];
    final aReceber = <Ocorrencia>[];
    for (final t in transacoes) {
      if (t.contaDestinoId != null) continue;
      final lista = t.tipo == TipoTransacao.entrada ? aReceber : aPagar;
      lista.addAll(ocorrencias(t, inicio, fim));
      // No mês atual, o que ficou sem pagar nos meses anteriores também aparece.
      if (mesAtual) {
        lista.addAll(ocorrencias(t, DateTime(2000), inicio.subtract(const Duration(days: 1)))
            .where((o) => !o.paga));
      }
    }
    int ordem(Ocorrencia a, Ocorrencia b) {
      final c = a.vencimento.compareTo(b.vencimento);
      return c != 0 ? c : a.nome.compareTo(b.nome);
    }

    aPagar.sort(ordem);
    aReceber.sort(ordem);

    final doMes = movimentos
        .where((m) => !m.dia.isBefore(inicio) && !m.dia.isAfter(fim))
        .toList();
    var entrou = 0, saiu = 0;
    final porCategoria = <String, int>{};
    for (final m in doMes) {
      if (m.transferencia) continue;
      if (m.entrada) {
        entrou += m.valorCentavos;
      } else {
        saiu += m.valorCentavos;
        porCategoria.update(m.categoria, (v) => v + m.valorCentavos, ifAbsent: () => m.valorCentavos);
      }
    }
    final categorias = [
      for (final MapEntry(:key, :value) in porCategoria.entries) CategoriaGasto(key, value),
    ]..sort((a, b) => b.centavos.compareTo(a.centavos));

    return MesFinancas(
      mes: inicio,
      entrouCentavos: entrou,
      saiuCentavos: saiu,
      aPagar: aPagar,
      aReceber: aReceber,
      categorias: categorias,
      extrato: doMes,
    );
  }

  /// Entrou e saiu nos [meses] meses que terminam no mês de [ate].
  List<TotaisMes> serie(DateTime ate, {int meses = 6}) {
    return [
      for (var i = meses - 1; i >= 0; i--)
        () {
          final inicio = DateTime(ate.year, ate.month - i, 1);
          final fim = DateTime(inicio.year, inicio.month + 1, 0);
          var entrou = 0, saiu = 0;
          for (final m in movimentos) {
            if (m.transferencia || m.dia.isBefore(inicio) || m.dia.isAfter(fim)) continue;
            if (m.entrada) {
              entrou += m.valorCentavos;
            } else {
              saiu += m.valorCentavos;
            }
          }
          return TotaisMes(inicio, entrou, saiu);
        }(),
    ];
  }
}

/// Data do primeiro vencimento de uma transação com regra.
DateTime inicioDaRegra(Transacao t) => dataSP(t.vencimento ?? t.data);

/// Número da parcela que vence em [vencimento] (nulo se não é parcelada).
int? numeroParcela(Transacao t, DateTime vencimento) {
  if (t.parcelaTotal == null || t.regraRepeticao == null) return null;
  final i = inicioDaRegra(t);
  final meses = (vencimento.year - i.year) * 12 + vencimento.month - i.month;
  return (t.parcelaNumero ?? 1) + meses;
}

class FinancasRepo {
  FinancasRepo(this.db);
  final BancoAurora db;

  Stream<QuadroFinancas> observarQuadro() => observar(
      db, [db.transacoes, db.pagamentosTransacao, db.contasFinanceiras], carregar);

  Future<QuadroFinancas> carregar() async {
    final contas = await (db.select(db.contasFinanceiras)
          ..where((c) => c.apagadoEm.isNull())
          ..orderBy([(c) => OrderingTerm(expression: c.criadoEm)]))
        .get();
    final transacoes =
        await (db.select(db.transacoes)..where((t) => t.apagadoEm.isNull())).get();
    final linhas =
        await (db.select(db.pagamentosTransacao)..where((p) => p.apagadoEm.isNull())).get();
    final pagamentos = <String, Map<String, PagamentoTransacao>>{};
    for (final p in linhas) {
      pagamentos.putIfAbsent(p.transacaoId, () => {})[p.vencimento] = p;
    }
    return QuadroFinancas(
      hoje: hojeSP(),
      contas: contas,
      transacoes: transacoes,
      pagamentos: pagamentos,
    );
  }

  /// Paga (ou desfaz o pagamento de) uma ocorrência.
  Future<void> pagar(Ocorrencia o, bool pago) => _pagar(o.transacao, o.vencimento, pago);

  Future<void> _pagar(Transacao t, DateTime vencimento, bool pago) async {
    final agora = DateTime.now();
    if (t.regraRepeticao == null) {
      await (db.update(db.transacoes)..where((x) => x.id.equals(t.id))).write(
          TransacoesCompanion(pagoEm: Value(pago ? agora : null), atualizadoEm: Value(agora)));
      return;
    }
    final chave = chaveData(vencimento);
    if (pago) {
      await db.into(db.pagamentosTransacao).insert(
            PagamentosTransacaoCompanion.insert(
                id: Value(idNatural('pagamento_transacao', [t.id, chave])),
                transacaoId: t.id,
                vencimento: chave,
                pagoEm: agora,
                valorCentavos: t.valorCentavos),
            onConflict: DoUpdate(
              (_) => PagamentosTransacaoCompanion(
                pagoEm: Value(agora),
                valorCentavos: Value(t.valorCentavos),
                apagadoEm: const Value(null),
                atualizadoEm: Value(agora),
              ),
              target: [db.pagamentosTransacao.transacaoId, db.pagamentosTransacao.vencimento],
            ),
          );
    } else {
      await (db.update(db.pagamentosTransacao)
            ..where((p) => p.transacaoId.equals(t.id) & p.vencimento.equals(chave)))
          .write(PagamentosTransacaoCompanion(apagadoEm: Value(agora), atualizadoEm: Value(agora)));
    }
  }

  /// Cria ou atualiza. Com [pagarPrimeira], a primeira ocorrência de uma
  /// recorrente/parcelada já nasce paga.
  Future<String> salvar(TransacoesCompanion dados, {String? id, bool pagarPrimeira = false}) {
    return db.transaction(() async {
      final Transacao t;
      if (id == null) {
        t = await db.into(db.transacoes).insertReturning(dados);
      } else {
        await (db.update(db.transacoes)..where((x) => x.id.equals(id)))
            .write(dados.copyWith(atualizadoEm: Value(DateTime.now())));
        t = await (db.select(db.transacoes)..where((x) => x.id.equals(id))).getSingle();
      }
      if (pagarPrimeira && t.regraRepeticao != null) {
        await _pagar(t, inicioDaRegra(t), true);
      }
      return t.id;
    });
  }

  /// Exclui. Uma recorrente ou parcelada com pagamentos é ENCERRADA (a regra
  /// ganha fim), para o histórico continuar no extrato e nos saldos.
  Future<void> excluir(Transacao t) => db.transaction(() async {
        final agora = DateTime.now();
        final regra = Regra.ler(t.regraRepeticao);
        final pagos = regra == null
            ? const <PagamentoTransacao>[]
            : await (db.select(db.pagamentosTransacao)
                  ..where((p) => p.transacaoId.equals(t.id) & p.apagadoEm.isNull()))
                .get();
        if (regra != null && pagos.isNotEmpty) {
          var fim = hojeSP().subtract(const Duration(days: 1));
          for (final p in pagos) {
            final v = DateTime.parse(p.vencimento);
            if (v.isAfter(fim)) fim = v;
          }
          await (db.update(db.transacoes)..where((x) => x.id.equals(t.id))).write(
              TransacoesCompanion(
                  regraRepeticao: Value(regra.encerradaEm(fim).rrule), atualizadoEm: Value(agora)));
          return;
        }
        await (db.update(db.transacoes)..where((x) => x.id.equals(t.id)))
            .write(TransacoesCompanion(apagadoEm: Value(agora), atualizadoEm: Value(agora)));
      });

  Future<String> salvarConta(ContasFinanceirasCompanion dados, {String? id}) async {
    if (id == null) return (await db.into(db.contasFinanceiras).insertReturning(dados)).id;
    await (db.update(db.contasFinanceiras)..where((c) => c.id.equals(id)))
        .write(dados.copyWith(atualizadoEm: Value(DateTime.now())));
    return id;
  }

  /// Exclui a conta se nenhuma transação usa. Retorna falso se estiver em uso.
  Future<bool> excluirConta(String id) async {
    final usadas = await (db.select(db.transacoes)
          ..where((t) =>
              t.apagadoEm.isNull() & (t.contaId.equals(id) | t.contaDestinoId.equals(id)))
          ..limit(1))
        .get();
    if (usadas.isNotEmpty) return false;
    final agora = DateTime.now();
    await (db.update(db.contasFinanceiras)..where((c) => c.id.equals(id)))
        .write(ContasFinanceirasCompanion(apagadoEm: Value(agora), atualizadoEm: Value(agora)));
    return true;
  }

  /// Paga a fatura do [cartao] com dinheiro da conta [origemId].
  Future<void> pagarFatura({
    required ContaFinanceira cartao,
    required String origemId,
    required int valorCentavos,
    required DateTime instante,
  }) =>
      db.into(db.transacoes).insert(TransacoesCompanion.insert(
            descricao: 'Fatura ${cartao.nome}',
            valorCentavos: valorCentavos,
            tipo: TipoTransacao.saida,
            data: instante,
            pagoEm: Value(instante),
            categoria: const Value(categoriaFatura),
            contaId: Value(origemId),
            contaDestinoId: Value(cartao.id),
          ));
}
