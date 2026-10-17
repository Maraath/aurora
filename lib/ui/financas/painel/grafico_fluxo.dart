import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/formato.dart';
import '../../../core/tema.dart';
import '../../../data/financas_repo.dart';
import 'cartao_painel.dart';

/// "Fluxo de caixa": entradas x saídas dos últimos meses em barras, com a dica
/// mostrando os dois valores e o que sobrou no mês tocado.
class GraficoFluxo extends StatelessWidget {
  const GraficoFluxo({super.key, required this.meses, this.mesEscolhido});
  final List<TotaisMes> meses;

  /// Mês aberto na tela (fica em destaque).
  final DateTime? mesEscolhido;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final maior = meses.fold<int>(
        0, (m, t) => [m, t.entrouCentavos, t.saiuCentavos].reduce((a, b) => a > b ? a : b));

    return CartaoPainel(
      titulo: 'Fluxo de caixa',
      subtitulo: 'Entradas e saídas dos últimos ${meses.length} meses',
      child: maior == 0
          ? SizedBox(
              height: 120,
              child: Center(child: Text('Ainda não há movimentos nestes meses.', style: manrope(14, cor: c.muted))),
            )
          : Column(children: [
              SizedBox(height: 200, child: _barras(context, maior)),
              const SizedBox(height: 12),
              Wrap(spacing: 18, alignment: WrapAlignment.center, children: [
                _Legenda(cor: c.teal, texto: 'Entradas'),
                _Legenda(cor: c.bad, texto: 'Saídas'),
              ]),
            ]),
    );
  }

  Widget _barras(BuildContext context, int maior) {
    final c = context.cores;
    final teto = maior / 100 * 1.2;
    bool escolhido(TotaisMes t) =>
        mesEscolhido != null && t.mes.year == mesEscolhido!.year && t.mes.month == mesEscolhido!.month;

    return BarChart(
      BarChartData(
        maxY: teto,
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: teto / 4,
          getDrawingHorizontalLine: (_) => FlLine(color: c.line, strokeWidth: 1, dashArray: [4, 4]),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              interval: teto / 4,
              getTitlesWidget: (y, meta) => y == 0 || y >= teto
                  ? const SizedBox.shrink()
                  : Text(_curto(y), style: manrope(10, cor: c.muted)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              getTitlesWidget: (x, meta) {
                final t = meses[x.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(mesCurto(t.mes),
                      style: manrope(11, peso: FontWeight.w700, cor: escolhido(t) ? c.text : c.muted)),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => c.surface2,
            tooltipBorderRadius: BorderRadius.circular(12),
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItem: (grupo, _, barra, indice) {
              // Uma dica só por mês (na barra de entradas), com os dois valores.
              if (indice != 0) return null;
              final t = meses[grupo.x];
              final sobra = t.entrouCentavos - t.saiuCentavos;
              return BarTooltipItem(
                '${mesAno(t.mes)}\n',
                manrope(12, peso: FontWeight.w700, cor: c.text),
                children: [
                  TextSpan(text: 'Entradas ${reais(t.entrouCentavos)}\n',
                      style: manrope(12, peso: FontWeight.w700, cor: c.teal)),
                  TextSpan(text: 'Saídas ${reais(t.saiuCentavos)}\n',
                      style: manrope(12, peso: FontWeight.w700, cor: c.bad)),
                  TextSpan(
                    text: sobra >= 0 ? 'Sobrou ${reais(sobra)}' : 'Faltou ${reais(-sobra)}',
                    style: manrope(12, cor: c.muted),
                  ),
                ],
              );
            },
          ),
        ),
        barGroups: [
          for (var i = 0; i < meses.length; i++)
            BarChartGroupData(
              x: i,
              barsSpace: 4,
              barRods: [
                _barra(meses[i].entrouCentavos, c.teal, escolhido(meses[i]) || mesEscolhido == null),
                _barra(meses[i].saiuCentavos, c.bad, escolhido(meses[i]) || mesEscolhido == null),
              ],
            ),
        ],
      ),
    );
  }

  BarChartRodData _barra(int centavos, Color cor, bool forte) => BarChartRodData(
        toY: centavos / 100,
        color: forte ? cor : cor.withValues(alpha: 0.45),
        width: 12,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
      );

  /// Eixo: "R$ 1,2 mil" em vez de "R$ 1.234,00".
  static String _curto(double reaisValor) {
    if (reaisValor >= 1000) {
      final mil = reaisValor / 1000;
      return 'R\$ ${mil.toStringAsFixed(mil < 10 ? 1 : 0).replaceAll('.', ',')} mil';
    }
    return 'R\$ ${reaisValor.round()}';
  }
}

class _Legenda extends StatelessWidget {
  const _Legenda({required this.cor, required this.texto});
  final Color cor;
  final String texto;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(texto, style: manrope(12, peso: FontWeight.w600, cor: context.cores.muted)),
      ]);
}
