import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/formato.dart';
import '../../core/tema.dart';
import '../../data/financas_repo.dart';

/// Barras de recebido (verde-água) x gasto (vermelho) por mês.
class GraficoMeses extends StatelessWidget {
  const GraficoMeses({super.key, required this.meses});
  final List<TotaisMes> meses;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final maior = meses.fold<int>(
        0, (m, t) => [m, t.entrouCentavos, t.saiuCentavos].reduce((a, b) => a > b ? a : b));
    if (maior == 0) {
      return SizedBox(
        height: 60,
        child: Center(
          child: Text('Ainda não há movimentos nestes meses.', style: manrope(13, cor: c.muted)),
        ),
      );
    }
    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          maxY: maior / 100 * 1.15,
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(color: c.line, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (x, meta) => Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(mesCurto(meses[x.toInt()].mes),
                      style: manrope(10, peso: FontWeight.w700, cor: c.muted)),
                ),
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => c.surface2,
              getTooltipItem: (grupo, _, barra, indice) => BarTooltipItem(
                '${indice == 0 ? 'Entrou' : 'Saiu'} ${reais((barra.toY * 100).round())}',
                manrope(12, peso: FontWeight.w700, cor: indice == 0 ? c.teal : c.bad),
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < meses.length; i++)
              BarChartGroupData(
                x: i,
                barsSpace: 4,
                barRods: [
                  BarChartRodData(
                    toY: meses[i].entrouCentavos / 100,
                    color: c.teal,
                    width: 10,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  BarChartRodData(
                    toY: meses[i].saiuCentavos / 100,
                    color: c.bad,
                    width: 10,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
