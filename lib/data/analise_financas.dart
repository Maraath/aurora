import 'banco.dart';
import 'financas_repo.dart';

/// Números da aba "Análise" de Finanças para um mês.
class AnaliseMes {
  const AnaliseMes({
    required this.gastoCentavos,
    required this.gastoAnteriorCentavos,
    required this.mediaDiaCentavos,
    required this.projecaoCentavos,
    required this.categorias,
    required this.maiores,
  });

  final int gastoCentavos;
  final int gastoAnteriorCentavos;
  final int mediaDiaCentavos;

  /// Só no mês corrente: o ritmo de gasto até hoje levado ao fim do mês.
  final int? projecaoCentavos;

  /// Categorias do mês com o quanto foi gasto nelas no mês anterior.
  final List<({CategoriaGasto atual, int anteriorCentavos})> categorias;

  /// Maiores saídas do mês (sem transferências).
  final List<Movimento> maiores;

  /// Variação em relação ao mês anterior (0,15 = 15% a mais); nulo sem base.
  double? get variacao =>
      gastoAnteriorCentavos == 0 ? null : gastoCentavos / gastoAnteriorCentavos - 1;
}

AnaliseMes analisarMes(QuadroFinancas q, DateTime mes, DateTime hoje) {
  final atual = q.mes(mes);
  final anterior = q.mes(DateTime(mes.year, mes.month - 1, 1));
  final diasNoMes = DateTime(mes.year, mes.month + 1, 0).day;
  final corrente = mes.year == hoje.year && mes.month == hoje.month;
  final futuro = DateTime(mes.year, mes.month, 1).isAfter(hoje);
  final dias = corrente ? hoje.day : diasNoMes;
  final porCategoria = {for (final c in anterior.categorias) c.nome: c.centavos};

  return AnaliseMes(
    gastoCentavos: atual.saiuCentavos,
    gastoAnteriorCentavos: anterior.saiuCentavos,
    mediaDiaCentavos: futuro ? 0 : atual.saiuCentavos ~/ dias,
    projecaoCentavos: corrente ? (atual.saiuCentavos / hoje.day * diasNoMes).round() : null,
    categorias: [
      for (final c in atual.categorias) (atual: c, anteriorCentavos: porCategoria[c.nome] ?? 0),
    ],
    maiores: (atual.extrato.where((m) => !m.entrada && !m.transferencia).toList()
          ..sort((a, b) => b.valorCentavos.compareTo(a.valorCentavos)))
        .take(5)
        .toList(),
  );
}

/// Uma compra parcelada vista na aba "Parceladas".
class Parcelada {
  const Parcelada({
    required this.transacao,
    required this.pagas,
    required this.total,
    required this.termina,
  });

  final Transacao transacao;
  final int pagas;
  final int total;

  /// Vencimento da última parcela.
  final DateTime? termina;

  bool get quitada => pagas >= total;
  int get faltaCentavos => (total - pagas) * transacao.valorCentavos;
  double get fracao => total == 0 ? 1 : pagas / total;
}

/// Vencimento da última parcela. Parcelada com regra gera todas as parcelas;
/// a lançada como uma parcela solta ("2 de 27") avança os meses que faltam.
DateTime? _ultimaParcela(QuadroFinancas q, Transacao t) {
  final ultima = q.ocorrencias(t, DateTime(2000), DateTime(2100)).lastOrNull?.vencimento;
  if (ultima == null || t.regraRepeticao != null || t.parcelaNumero == null || t.parcelaTotal == null) {
    return ultima;
  }
  return DateTime(ultima.year, ultima.month + t.parcelaTotal! - t.parcelaNumero!, ultima.day);
}

/// Em andamento primeiro (as que terminam antes no topo), quitadas no fim.
List<Parcelada> listarParceladas(QuadroFinancas q) {
  final lista = [
    for (final t in q.parceladas)
      Parcelada(
        transacao: t,
        pagas: q.parcelasPagas(t).clamp(0, t.parcelaTotal ?? 0),
        total: t.parcelaTotal ?? 0,
        termina: _ultimaParcela(q, t),
      ),
  ];
  lista.sort((a, b) {
    if (a.quitada != b.quitada) return a.quitada ? 1 : -1;
    final ta = a.termina, tb = b.termina;
    if (ta != null && tb != null) return ta.compareTo(tb);
    return a.transacao.descricao.compareTo(b.transacao.descricao);
  });
  return lista;
}
