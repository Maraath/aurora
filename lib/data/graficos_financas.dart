import 'dart:math' as math;

import 'banco.dart';
import 'financas_repo.dart';

/// Números dos gráficos de Finanças (Resumo e Análise). Tudo sai do
/// [QuadroFinancas] do aparelho: nada aqui vai para o servidor.

// ---------------------------------------------------------------- gasto por dia

/// Gasto de cada dia do mês e a previsão dos dias que faltam.
class GastoDiario {
  const GastoDiario({
    required this.mes,
    required this.pago,
    required this.previsto,
    required this.mediaCentavos,
    required this.hojeIndice,
  });

  /// Primeiro dia do mês.
  final DateTime mes;

  /// Gasto pago em cada dia (índice 0 = dia 1).
  final List<int> pago;

  /// Previsão para os dias depois de hoje (0 nos dias que já passaram):
  /// a média de gasto variável por dia mais as contas agendadas para o dia.
  final List<int> previsto;

  /// Média de gasto por dia até hoje (ou no mês inteiro, se já acabou).
  final int mediaCentavos;

  /// Índice de hoje no mês, ou nulo se o mês não é o atual.
  final int? hojeIndice;

  int get totalPagoCentavos => pago.fold(0, (s, v) => s + v);
  int get totalPrevistoCentavos => previsto.fold(0, (s, v) => s + v);
  int get totalCentavos => totalPagoCentavos + totalPrevistoCentavos;
}

GastoDiario gastoPorDia(QuadroFinancas q, DateTime mesQualquer, DateTime hoje) {
  final mes = DateTime(mesQualquer.year, mesQualquer.month, 1);
  final dias = DateTime(mes.year, mes.month + 1, 0).day;
  final corrente = mes.year == hoje.year && mes.month == hoje.month;
  final futuro = mes.isAfter(hoje);
  final m = q.mes(mes);

  final pago = List.filled(dias, 0);
  var variavel = 0;
  for (final mov in m.extrato) {
    if (mov.entrada || mov.transferencia) continue;
    pago[mov.dia.day - 1] += mov.valorCentavos;
    if (formaDe(mov.transacao) == FormaTransacao.unica && mov.transacao.parcelaNumero == null) {
      variavel += mov.valorCentavos;
    }
  }

  final diasPassados = futuro ? 0 : (corrente ? hoje.day : dias);
  final media = diasPassados == 0 ? 0 : pago.fold(0, (s, v) => s + v) ~/ diasPassados;
  final mediaVariavel = diasPassados == 0 ? 0 : variavel ~/ diasPassados;

  final previsto = List.filled(dias, 0);
  if (corrente || futuro) {
    final inicio = futuro ? 1 : hoje.day + 1;
    for (var d = inicio; d <= dias; d++) {
      previsto[d - 1] = mediaVariavel;
    }
    for (final o in m.aPagar) {
      if (o.paga || o.vencimento.year != mes.year || o.vencimento.month != mes.month) continue;
      if (o.vencimento.day >= inicio) previsto[o.vencimento.day - 1] += o.valorCentavos;
    }
  }
  return GastoDiario(
    mes: mes,
    pago: pago,
    previsto: previsto,
    mediaCentavos: media,
    hojeIndice: corrente ? hoje.day - 1 : null,
  );
}

// ---------------------------------------------------------------- fluxo do dinheiro

class FatiaFluxo {
  const FatiaFluxo(this.nome, this.centavos);
  final String nome;
  final int centavos;
}

/// De onde veio (entradas por categoria) e para onde foi (saídas por
/// categoria) no mês. A diferença vira "Sobra do mês" (destino) ou "Saldo
/// anterior" (origem, quando saiu mais do que entrou).
class FluxoDinheiro {
  const FluxoDinheiro(this.origens, this.destinos, this.sobraCentavos);
  final List<FatiaFluxo> origens;
  final List<FatiaFluxo> destinos;

  /// Positivo: sobrou; negativo: usou dinheiro de antes.
  final int sobraCentavos;

  int get totalCentavos => math.max(
        origens.fold(0, (s, f) => s + f.centavos),
        destinos.fold(0, (s, f) => s + f.centavos),
      );
  bool get vazio => totalCentavos == 0;
}

const nomeSobra = 'Sobra do mês';
const nomeSaldoAnterior = 'Saldo anterior';

/// [comPrevistos]: soma também o que ainda vai entrar e sair no mês (contas e
/// recebimentos agendados não pagos).
FluxoDinheiro fluxoDoDinheiro(QuadroFinancas q, DateTime mes, {bool comPrevistos = false, int maxDestinos = 6}) {
  final m = q.mes(mes);
  final entra = <String, int>{}, sai = <String, int>{};
  void somar(Map<String, int> mapa, String nome, int v) => mapa.update(nome, (x) => x + v, ifAbsent: () => v);

  for (final mov in m.extrato) {
    if (mov.transferencia) continue;
    somar(mov.entrada ? entra : sai, mov.categoria, mov.valorCentavos);
  }
  if (comPrevistos) {
    bool doMes(Ocorrencia o) => o.vencimento.year == m.mes.year && o.vencimento.month == m.mes.month;
    for (final o in m.aPagar.where((o) => !o.paga && doMes(o))) {
      somar(sai, o.transacao.categoria ?? 'Outros', o.valorCentavos);
    }
    for (final o in m.aReceber.where((o) => !o.paga && doMes(o))) {
      somar(entra, o.transacao.categoria ?? 'Outros', o.valorCentavos);
    }
  }

  List<FatiaFluxo> ordenar(Map<String, int> mapa, int limite) {
    final lista = [for (final e in mapa.entries) FatiaFluxo(e.key, e.value)]
      ..sort((a, b) => b.centavos.compareTo(a.centavos));
    if (lista.length <= limite) return lista;
    final resto = lista.skip(limite - 1).fold(0, (s, f) => s + f.centavos);
    return [...lista.take(limite - 1), FatiaFluxo('Outras', resto)];
  }

  final origens = ordenar(entra, 4);
  final destinos = ordenar(sai, maxDestinos);
  final totalEntra = entra.values.fold(0, (s, v) => s + v);
  final totalSai = sai.values.fold(0, (s, v) => s + v);
  final sobra = totalEntra - totalSai;
  return FluxoDinheiro(
    [...origens, if (sobra < 0) FatiaFluxo(nomeSaldoAnterior, -sobra)],
    [...destinos, if (sobra > 0) FatiaFluxo(nomeSobra, sobra)],
    sobra,
  );
}

// ---------------------------------------------------------------- saldo (velas e trajetória)

/// O saldo total (todas as contas e cartões) num mês: como abriu, como
/// fechou, o maior e o menor do mês. É a "vela" do gráfico financeiro.
class VelaSaldo {
  const VelaSaldo(this.mes, this.abertura, this.fechamento, this.maxima, this.minima);
  final DateTime mes;
  final int abertura, fechamento, maxima, minima;
  bool get subiu => fechamento >= abertura;
}

/// Velas dos [meses] meses que terminam no mês de [ate]. Volta do saldo de
/// hoje desfazendo os movimentos (transferências não mudam o total).
List<VelaSaldo> velasDoSaldo(QuadroFinancas q, DateTime ate, DateTime hoje, {int meses = 6}) {
  final efeito = <DateTime, int>{};
  for (final m in q.movimentos) {
    if (m.transferencia) continue;
    efeito.update(m.dia, (v) => v + (m.entrada ? m.valorCentavos : -m.valorCentavos),
        ifAbsent: () => m.entrada ? m.valorCentavos : -m.valorCentavos);
  }
  // Saldo no fim de um dia = saldo de hoje − efeitos depois desse dia.
  final dias = efeito.keys.toList()..sort();
  int saldoNoFimDe(DateTime dia) {
    var s = q.patrimonioCentavos;
    for (final d in dias.reversed) {
      if (!d.isAfter(dia)) break;
      s -= efeito[d]!;
    }
    return s;
  }

  final fimSerie = DateTime(ate.year, ate.month, 1);
  return [
    for (var i = meses - 1; i >= 0; i--)
      () {
        final inicio = DateTime(fimSerie.year, fimSerie.month - i, 1);
        final ultimo = DateTime(inicio.year, inicio.month + 1, 0);
        final ateDia = ultimo.isAfter(hoje) ? hoje : ultimo;
        final abertura = saldoNoFimDe(inicio.subtract(const Duration(days: 1)));
        var s = abertura, maxima = abertura, minima = abertura;
        if (!inicio.isAfter(hoje)) {
          for (var d = inicio; !d.isAfter(ateDia); d = DateTime(d.year, d.month, d.day + 1)) {
            s += efeito[d] ?? 0;
            maxima = math.max(maxima, s);
            minima = math.min(minima, s);
          }
        }
        return VelaSaldo(inicio, abertura, s, maxima, minima);
      }(),
  ];
}

/// Projeção do saldo para os próximos [meses] meses a partir do resultado
/// mensal (entrou − saiu) dos meses de [historico]: linha pela média, faixa
/// entre o pior e o melhor mês.
class ProjecaoSaldo {
  const ProjecaoSaldo(this.media, this.otimista, this.pessimista);
  final List<int> media, otimista, pessimista;
}

ProjecaoSaldo projetarSaldo(int saldoHoje, List<TotaisMes> historico, {int meses = 6}) {
  final resultados = [for (final t in historico) t.entrouCentavos - t.saiuCentavos];
  if (resultados.isEmpty) resultados.add(0);
  final media = resultados.fold(0, (s, v) => s + v) ~/ resultados.length;
  final melhor = resultados.reduce(math.max), pior = resultados.reduce(math.min);
  List<int> serie(int passo) => [for (var i = 1; i <= meses; i++) saldoHoje + passo * i];
  return ProjecaoSaldo(serie(media), serie(melhor), serie(pior));
}

// ---------------------------------------------------------------- categorias no tempo

class CategoriasNoTempo {
  const CategoriasNoTempo(this.meses, this.series);
  final List<DateTime> meses;

  /// Categoria → gasto em cada mês (mesma ordem de [meses]); "Outras" junta o resto.
  final Map<String, List<int>> series;
}

CategoriasNoTempo categoriasNoTempo(QuadroFinancas q, DateTime ate, {int meses = 6, int maxCategorias = 5}) {
  final fim = DateTime(ate.year, ate.month, 1);
  final lista = [for (var i = meses - 1; i >= 0; i--) DateTime(fim.year, fim.month - i, 1)];
  final porMes = [for (final m in lista) q.mes(m).categorias];
  final total = <String, int>{};
  for (final cats in porMes) {
    for (final c in cats) {
      total.update(c.nome, (v) => v + c.centavos, ifAbsent: () => c.centavos);
    }
  }
  final principais = (total.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
      .take(maxCategorias)
      .map((e) => e.key)
      .toList();
  final series = <String, List<int>>{for (final n in principais) n: List.filled(lista.length, 0)};
  var temOutras = false;
  final outras = List.filled(lista.length, 0);
  for (var i = 0; i < porMes.length; i++) {
    for (final c in porMes[i]) {
      if (series.containsKey(c.nome)) {
        series[c.nome]![i] += c.centavos;
      } else {
        outras[i] += c.centavos;
        temOutras = true;
      }
    }
  }
  if (temOutras) series['Outras'] = outras;
  return CategoriasNoTempo(lista, series);
}

/// Gasto deste mês e a média dos [meses] anteriores, por categoria (radar).
class ComparacaoCategoria {
  const ComparacaoCategoria(this.nome, this.atualCentavos, this.mediaCentavos);
  final String nome;
  final int atualCentavos, mediaCentavos;
}

List<ComparacaoCategoria> compararComMedia(QuadroFinancas q, DateTime mes, {int meses = 3, int maxCategorias = 6}) {
  final atual = {for (final c in q.mes(mes).categorias) c.nome: c.centavos};
  final soma = <String, int>{};
  for (var i = 1; i <= meses; i++) {
    for (final c in q.mes(DateTime(mes.year, mes.month - i, 1)).categorias) {
      soma.update(c.nome, (v) => v + c.centavos, ifAbsent: () => c.centavos);
    }
  }
  final nomes = {...atual.keys, ...soma.keys}.toList()
    ..sort((a, b) => ((atual[b] ?? 0) + (soma[b] ?? 0) ~/ meses).compareTo((atual[a] ?? 0) + (soma[a] ?? 0) ~/ meses));
  return [
    for (final n in nomes.take(maxCategorias)) ComparacaoCategoria(n, atual[n] ?? 0, (soma[n] ?? 0) ~/ meses),
  ];
}

// ---------------------------------------------------------------- mapa de calor

/// Gasto de cada dia nas últimas [semanas] semanas (segunda a domingo),
/// terminando na semana de [ate].
class MapaCalor {
  const MapaCalor(this.inicio, this.valores);

  /// Segunda-feira da primeira semana.
  final DateTime inicio;

  /// [semana][diaDaSemana 0=segunda] → centavos; nulo nos dias depois de hoje.
  final List<List<int?>> valores;

  int get maximo => valores.expand((s) => s).whereType<int>().fold(0, math.max);

  /// Média de um dia de fim de semana dividida pela de um dia útil (nulo sem base).
  double? get pesoFimDeSemana {
    var util = 0, nUtil = 0, fds = 0, nFds = 0;
    for (final s in valores) {
      for (var d = 0; d < 7; d++) {
        final v = s[d];
        if (v == null) continue;
        if (d >= 5) {
          fds += v;
          nFds++;
        } else {
          util += v;
          nUtil++;
        }
      }
    }
    if (nUtil == 0 || nFds == 0 || util == 0) return null;
    return (fds / nFds) / (util / nUtil);
  }
}

MapaCalor mapaDeCalor(QuadroFinancas q, DateTime ate, DateTime hoje, {int semanas = 6}) {
  final fimRef = ate.isAfter(hoje) ? hoje : ate;
  final segundaFinal = DateTime(fimRef.year, fimRef.month, fimRef.day - (fimRef.weekday - 1));
  final inicio = DateTime(segundaFinal.year, segundaFinal.month, segundaFinal.day - 7 * (semanas - 1));
  final porDia = <DateTime, int>{};
  for (final m in q.movimentos) {
    if (m.entrada || m.transferencia || m.dia.isBefore(inicio)) continue;
    porDia.update(m.dia, (v) => v + m.valorCentavos, ifAbsent: () => m.valorCentavos);
  }
  return MapaCalor(inicio, [
    for (var s = 0; s < semanas; s++)
      [
        for (var d = 0; d < 7; d++)
          () {
            final dia = DateTime(inicio.year, inicio.month, inicio.day + s * 7 + d);
            return dia.isAfter(fimRef) ? null : porDia[dia] ?? 0;
          }(),
      ],
  ]);
}

// ---------------------------------------------------------------- fixo × parcelas × variável

class RigidezMes {
  const RigidezMes(this.mes, this.fixoCentavos, this.parcelasCentavos, this.variavelCentavos);
  final DateTime mes;
  final int fixoCentavos, parcelasCentavos, variavelCentavos;
  int get totalCentavos => fixoCentavos + parcelasCentavos + variavelCentavos;

  /// Parte do gasto que já estava decidida antes do mês (fixo + parcelas).
  double get comprometido => totalCentavos == 0 ? 0 : (fixoCentavos + parcelasCentavos) / totalCentavos;
}

enum ClasseGasto { fixo, parcela, variavel }

ClasseGasto classeDoGasto(Transacao t) => switch (formaDe(t)) {
      FormaTransacao.recorrente => ClasseGasto.fixo,
      FormaTransacao.parcelada => ClasseGasto.parcela,
      FormaTransacao.unica => t.parcelaNumero != null ? ClasseGasto.parcela : ClasseGasto.variavel,
    };

List<RigidezMes> rigidez(QuadroFinancas q, DateTime ate, {int meses = 6}) {
  final fim = DateTime(ate.year, ate.month, 1);
  return [
    for (var i = meses - 1; i >= 0; i--)
      () {
        final mes = DateTime(fim.year, fim.month - i, 1);
        var fixo = 0, parcela = 0, variavel = 0;
        for (final m in q.mes(mes).extrato) {
          if (m.entrada || m.transferencia) continue;
          switch (classeDoGasto(m.transacao)) {
            case ClasseGasto.fixo:
              fixo += m.valorCentavos;
            case ClasseGasto.parcela:
              parcela += m.valorCentavos;
            case ClasseGasto.variavel:
              variavel += m.valorCentavos;
          }
        }
        return RigidezMes(mes, fixo, parcela, variavel);
      }(),
  ];
}

// ---------------------------------------------------------------- leituras

/// Frases curtas sobre o período, só quando há dados que as sustentem.
List<String> leiturasDoPeriodo({
  required List<TotaisMes> serie,
  required MapaCalor calor,
  required List<RigidezMes> rigidezMeses,
  required String Function(DateTime) nomeMes,
}) {
  final frases = <String>[];
  final comMovimento = serie.where((t) => t.entrouCentavos > 0 || t.saiuCentavos > 0).toList();
  if (comMovimento.length >= 2) {
    double taxa(TotaisMes t) => t.entrouCentavos == 0 ? -1 : (t.entrouCentavos - t.saiuCentavos) / t.entrouCentavos;
    final ordenados = [...comMovimento]..sort((a, b) => taxa(b).compareTo(taxa(a)));
    final melhor = ordenados.first, pior = ordenados.last;
    if (melhor.entrouCentavos > 0) {
      frases.add('Melhor mês: ${nomeMes(melhor.mes)}, sobrou ${(taxa(melhor) * 100).round()}% do que entrou.');
    }
    if (pior != melhor && pior.entrouCentavos > 0) {
      final t = taxa(pior);
      frases.add(t < 0
          ? 'Mês mais apertado: ${nomeMes(pior.mes)}, saiu mais do que entrou.'
          : 'Mês mais apertado: ${nomeMes(pior.mes)}, sobrou só ${(t * 100).round()}%.');
    }
  }
  final peso = calor.pesoFimDeSemana;
  if (peso != null && peso >= 1.3) {
    frases.add('Sábado e domingo custam em média ${peso.toStringAsFixed(1).replaceAll('.', ',')}× um dia útil.');
  } else if (peso != null && peso <= 0.7) {
    frases.add('Os fins de semana pesam menos que os dias úteis no seu gasto.');
  }
  final ultimo = rigidezMeses.lastWhere((r) => r.totalCentavos > 0, orElse: () => rigidezMeses.last);
  if (ultimo.totalCentavos > 0 && ultimo.comprometido >= 0.4) {
    frases.add('${(ultimo.comprometido * 100).round()}% do gasto de ${nomeMes(ultimo.mes)} já estava '
        'comprometido (contas fixas e parcelas).');
  }
  return frases;
}
