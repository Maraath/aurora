import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/formato.dart';
import '../../../core/tema.dart';
import '../../../data/graficos_financas.dart';
import '../painel/cartao_painel.dart';
import 'config.dart';

/// "Gasto por dia e projeção": barras do gasto de cada dia (as dos dias que
/// faltam, mais claras, são a previsão) com a linha da média; ou a linha do
/// gasto acumulado, tracejada daqui até o fim do mês.
class CartaoGastoDia extends StatelessWidget {
  const CartaoGastoDia({
    super.key,
    required this.dados,
    required this.receitasCentavos,
    required this.tipo,
    required this.aoEscolherTipo,
  });

  final GastoDiario dados;

  /// Entradas do mês, para dizer quanto deve sobrar.
  final int receitasCentavos;
  final TipoGrafico tipo;
  final ValueChanged<TipoGrafico> aoEscolherTipo;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final d = dados;
    final temPrevisao = d.totalPrevistoCentavos > 0;
    final vazio = d.totalCentavos == 0;
    final sobra = receitasCentavos - d.totalCentavos;

    return CartaoPainel(
      titulo: 'Gasto por dia',
      subtitulo: temPrevisao ? 'E a previsão até o fim do mês' : 'Quanto saiu em cada dia do mês',
      acao: SeletorTipo(tipos: CartaoFin.gastoDia.tipos, atual: tipo, aoEscolher: aoEscolherTipo),
      child: vazio
          ? SizedBox(
              height: 120,
              child: Center(child: Text('Nenhum gasto neste mês ainda.', style: manrope(14, cor: c.muted))),
            )
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SizedBox(height: 190, child: tipo == TipoGrafico.acumulada ? _acumulada(context) : _barras(context)),
              const SizedBox(height: 12),
              Wrap(spacing: 16, runSpacing: 6, children: [
                _Item(cor: c.violeta, texto: 'Gasto ${reais(d.totalPagoCentavos)}'),
                if (temPrevisao)
                  _Item(cor: c.violeta.withValues(alpha: 0.35), texto: 'Previsto ${reais(d.totalPrevistoCentavos)}'),
                _Item(cor: c.warn, texto: 'Média ${reais(d.mediaCentavos)}/dia', linha: true),
              ]),
              if (temPrevisao && receitasCentavos > 0) ...[
                const SizedBox(height: 8),
                Text(
                  sobra >= 0 ? 'No ritmo atual, sobram ${reais(sobra)} no fim do mês.' : 'No ritmo atual, faltam ${reais(-sobra)} no fim do mês.',
                  style: manrope(13, peso: FontWeight.w700, cor: sobra >= 0 ? c.accent : c.bad),
                ),
              ],
            ]),
    );
  }

  Widget _barras(BuildContext context) {
    final c = context.cores;
    final d = dados;
    final maior = [for (var i = 0; i < d.pago.length; i++) d.pago[i] + d.previsto[i]].fold(0, math.max);
    final teto = math.max(maior, d.mediaCentavos) / 100 * 1.2 + 1;
    return BarChart(
      BarChartData(
        maxY: teto,
        alignment: BarChartAlignment.spaceBetween,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        extraLinesData: ExtraLinesData(horizontalLines: [
          if (d.mediaCentavos > 0)
            HorizontalLine(y: d.mediaCentavos / 100, color: c.warn.withValues(alpha: 0.8), strokeWidth: 1.4, dashArray: [5, 4]),
        ]),
        titlesData: _titulosDias(context, d),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => c.surface2,
            tooltipBorderRadius: BorderRadius.circular(12),
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItem: (grupo, _, _, _) {
              final i = grupo.x;
              final previsto = d.previsto[i] > 0 && d.pago[i] == 0;
              return BarTooltipItem(
                'Dia ${i + 1}\n',
                manrope(12, peso: FontWeight.w700, cor: c.text),
                children: [
                  TextSpan(
                    text: previsto ? 'Previsto ${reais(d.previsto[i])}' : reais(d.pago[i]),
                    style: manrope(12, peso: FontWeight.w700, cor: c.violeta),
                  ),
                ],
              );
            },
          ),
        ),
        barGroups: [
          for (var i = 0; i < d.pago.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: (d.pago[i] + d.previsto[i]) / 100,
                width: d.pago.length > 30 ? 5 : 6,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                color: d.pago[i] > 0 ? c.violeta : c.violeta.withValues(alpha: 0.3),
              ),
            ]),
        ],
      ),
    );
  }

  Widget _acumulada(BuildContext context) {
    final c = context.cores;
    final d = dados;
    final pago = <FlSpot>[], previsto = <FlSpot>[];
    var soma = 0;
    final ultimoPago = d.hojeIndice ?? (d.totalPrevistoCentavos > 0 ? -1 : d.pago.length - 1);
    for (var i = 0; i < d.pago.length; i++) {
      soma += d.pago[i] + d.previsto[i];
      if (i <= ultimoPago) pago.add(FlSpot(i.toDouble(), soma / 100));
      if (i >= ultimoPago && ultimoPago < d.pago.length - 1) previsto.add(FlSpot(i.toDouble(), soma / 100));
    }
    final teto = soma / 100 * 1.15 + 1;
    LineChartBarData linha(List<FlSpot> pontos, {required bool tracejada}) => LineChartBarData(
          spots: pontos,
          color: c.violeta,
          barWidth: 2.6,
          isCurved: false,
          dashArray: tracejada ? [6, 5] : null,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: !tracejada,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [c.violeta.withValues(alpha: 0.3), c.violeta.withValues(alpha: 0.02)],
            ),
          ),
        );
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: d.pago.length - 1,
        minY: 0,
        maxY: teto,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: teto / 4,
          getDrawingHorizontalLine: (_) => FlLine(color: c.line, strokeWidth: 1, dashArray: [4, 4]),
        ),
        titlesData: _titulosDias(context, d, eixoY: teto),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => c.surface2,
            tooltipBorderRadius: BorderRadius.circular(12),
            fitInsideHorizontally: true,
            getTooltipItems: (pontos) => [
              for (final p in pontos)
                LineTooltipItem('Até o dia ${p.x.round() + 1}\n', manrope(12, peso: FontWeight.w700, cor: c.text),
                    children: [TextSpan(text: reais((p.y * 100).round()), style: manrope(12, peso: FontWeight.w700, cor: c.violeta))]),
            ],
          ),
        ),
        lineBarsData: [
          if (pago.isNotEmpty) linha(pago, tracejada: false),
          if (previsto.length > 1) linha(previsto, tracejada: true),
        ],
      ),
    );
  }

  FlTitlesData _titulosDias(BuildContext context, GastoDiario d, {double? eixoY}) {
    final c = context.cores;
    return FlTitlesData(
      rightTitles: const AxisTitles(),
      topTitles: const AxisTitles(),
      leftTitles: eixoY == null
          ? const AxisTitles()
          : AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                interval: eixoY / 4,
                getTitlesWidget: (y, _) =>
                    y == 0 || y >= eixoY ? const SizedBox.shrink() : Text(reaisCurto(y), style: manrope(10, cor: c.muted)),
              ),
            ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          interval: 1,
          getTitlesWidget: (x, _) {
            final i = x.round();
            final hoje = d.hojeIndice == i;
            if (!(i == 0 || i == d.pago.length - 1 || hoje || (i + 1) % 7 == 0)) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(hoje ? 'hoje' : '${i + 1}',
                  style: manrope(10, peso: FontWeight.w700, cor: hoje ? c.text : c.muted)),
            );
          },
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.cor, required this.texto, this.linha = false});
  final Color cor;
  final String texto;
  final bool linha;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: linha ? 14 : 10,
          height: linha ? 2 : 10,
          decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(texto, style: manrope(12, peso: FontWeight.w600, cor: context.cores.muted)),
      ]);
}

/// "Mapa de calor do gasto": um quadrado por dia das últimas semanas, mais
/// forte quanto mais gasto, e uma leitura sobre o fim de semana.
class CartaoMapaCalor extends StatelessWidget {
  const CartaoMapaCalor({super.key, required this.mapa});
  final MapaCalor mapa;

  static const _dias = ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final maximo = mapa.maximo;
    final peso = mapa.pesoFimDeSemana;
    return CartaoPainel(
      titulo: 'Mapa de calor do gasto',
      subtitulo: 'Em que dias o dinheiro sai mais (últimas ${mapa.valores.length} semanas)',
      child: maximo == 0
          ? SizedBox(
              height: 120,
              child: Center(child: Text('Sem gastos nessas semanas.', style: manrope(14, cor: c.muted))),
            )
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (var d = 0; d < 7; d++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [
                    SizedBox(width: 34, child: Text(_dias[d], style: manrope(11, peso: FontWeight.w600, cor: c.muted))),
                    for (var s = 0; s < mapa.valores.length; s++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: _Quadrado(
                            valor: mapa.valores[s][d],
                            maximo: maximo,
                            dia: DateTime(mapa.inicio.year, mapa.inicio.month, mapa.inicio.day + s * 7 + d),
                          ),
                        ),
                      ),
                  ]),
                ),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text('menos', style: manrope(10.5, cor: c.muted)),
                for (final a in [0.1, 0.35, 0.6, 0.9])
                  Container(
                    width: 14,
                    height: 10,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(color: c.bad.withValues(alpha: a), borderRadius: BorderRadius.circular(3)),
                  ),
                const SizedBox(width: 4),
                Text('mais', style: manrope(10.5, cor: c.muted)),
              ]),
              if (peso != null) ...[
                const SizedBox(height: 10),
                Text(
                  peso >= 1.15
                      ? 'Sábado e domingo custam em média ${peso.toStringAsFixed(1).replaceAll('.', ',')}× um dia útil.'
                      : peso <= 0.85
                          ? 'Os fins de semana pesam menos que os dias úteis.'
                          : 'Fim de semana e dia útil custam parecido.',
                  style: manrope(13, peso: FontWeight.w600, cor: c.text),
                ),
              ],
            ]),
    );
  }
}

class _Quadrado extends StatelessWidget {
  const _Quadrado({required this.valor, required this.maximo, required this.dia});
  final int? valor;
  final int maximo;
  final DateTime dia;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final v = valor;
    final caixa = Container(
      height: 18,
      decoration: BoxDecoration(
        color: v == null
            ? Colors.transparent
            : v == 0
                ? c.surface2.withValues(alpha: 0.6)
                : c.bad.withValues(alpha: 0.12 + 0.78 * (v / maximo)),
        borderRadius: BorderRadius.circular(4),
        border: v == null ? Border.all(color: c.line.withValues(alpha: 0.4)) : null,
      ),
    );
    if (v == null) return caixa;
    return Tooltip(message: '${diaMesCurto(dia)}: ${reais(v)}', child: caixa);
  }
}
