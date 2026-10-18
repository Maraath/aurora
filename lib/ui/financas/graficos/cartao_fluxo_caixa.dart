import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/formato.dart';
import '../../../core/tema.dart';
import '../../../data/financas_repo.dart';
import '../../../data/graficos_financas.dart';
import '../painel/cartao_painel.dart';
import 'config.dart';

/// "Fluxo de caixa" dos últimos meses: entradas × saídas em barras, linhas ou
/// área; ou o saldo total em velas (abre, fecha, máxima e mínima do mês).
class CartaoFluxoCaixa extends StatelessWidget {
  const CartaoFluxoCaixa({
    super.key,
    required this.meses,
    required this.velas,
    required this.tipo,
    required this.aoEscolherTipo,
    this.mesEscolhido,
  });

  final List<TotaisMes> meses;
  final List<VelaSaldo> velas;
  final TipoGrafico tipo;
  final ValueChanged<TipoGrafico> aoEscolherTipo;

  /// Mês aberto na tela (fica em destaque).
  final DateTime? mesEscolhido;

  bool _escolhido(DateTime m) => mesEscolhido != null && m.year == mesEscolhido!.year && m.month == mesEscolhido!.month;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final velas = tipo == TipoGrafico.velas;
    final maior = meses.fold<int>(0, (m, t) => math.max(m, math.max(t.entrouCentavos, t.saiuCentavos)));
    final vazio = velas ? this.velas.every((v) => v.abertura == 0 && v.maxima == 0 && v.minima == 0) : maior == 0;

    return CartaoPainel(
      titulo: 'Fluxo de caixa',
      subtitulo: velas
          ? 'Seu saldo total mês a mês: abertura, fechamento, máxima e mínima'
          : 'Entradas e saídas dos últimos ${meses.length} meses',
      acao: SeletorTipo(tipos: CartaoFin.fluxoCaixa.tipos, atual: tipo, aoEscolher: aoEscolherTipo),
      child: vazio
          ? SizedBox(
              height: 120,
              child: Center(child: Text('Ainda não há movimentos nestes meses.', style: manrope(14, cor: c.muted))),
            )
          : Column(children: [
              SizedBox(
                height: 210,
                child: switch (tipo) {
                  TipoGrafico.linhas => _linhas(context, maior, area: false),
                  TipoGrafico.area => _linhas(context, maior, area: true),
                  TipoGrafico.velas => _velas(context),
                  _ => _barras(context, maior),
                },
              ),
              const SizedBox(height: 12),
              Wrap(spacing: 18, alignment: WrapAlignment.center, children: velas
                  ? [
                      _Legenda(cor: c.teal, texto: 'Terminou acima'),
                      _Legenda(cor: c.bad, texto: 'Terminou abaixo'),
                    ]
                  : [
                      _Legenda(cor: c.teal, texto: 'Entradas'),
                      _Legenda(cor: c.bad, texto: 'Saídas'),
                    ]),
            ]),
    );
  }

  FlTitlesData _titulos(BuildContext context, double minimo, double teto, List<DateTime> rotulos) {
    final c = context.cores;
    return FlTitlesData(
      rightTitles: const AxisTitles(),
      topTitles: const AxisTitles(),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 62,
          interval: (teto - minimo) / 4,
          getTitlesWidget: (y, meta) => y <= minimo || y >= teto
              ? const SizedBox.shrink()
              : Text(reaisCurto(y), style: manrope(10, cor: c.muted)),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 26,
          interval: 1,
          getTitlesWidget: (x, meta) {
            final i = x.round();
            if (i < 0 || i >= rotulos.length || (x - i).abs() > 0.01) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(mesCurto(rotulos[i]),
                  style: manrope(11, peso: FontWeight.w700, cor: _escolhido(rotulos[i]) ? c.text : c.muted)),
            );
          },
        ),
      ),
    );
  }

  FlGridData _grade(BuildContext context, double minimo, double teto) => FlGridData(
        drawVerticalLine: false,
        horizontalInterval: (teto - minimo) / 4,
        getDrawingHorizontalLine: (_) => FlLine(color: context.cores.line, strokeWidth: 1, dashArray: [4, 4]),
      );

  /// Dica com entradas, saídas e o que sobrou no mês.
  List<TextSpan> _dica(BuildContext context, TotaisMes t) {
    final c = context.cores;
    final sobra = t.entrouCentavos - t.saiuCentavos;
    return [
      TextSpan(text: 'Entradas ${reais(t.entrouCentavos)}\n', style: manrope(12, peso: FontWeight.w700, cor: c.teal)),
      TextSpan(text: 'Saídas ${reais(t.saiuCentavos)}\n', style: manrope(12, peso: FontWeight.w700, cor: c.bad)),
      TextSpan(text: sobra >= 0 ? 'Sobrou ${reais(sobra)}' : 'Faltou ${reais(-sobra)}', style: manrope(12, cor: c.muted)),
    ];
  }

  Widget _barras(BuildContext context, int maior) {
    final c = context.cores;
    final teto = maior / 100 * 1.2;
    BarChartRodData barra(int centavos, Color cor, bool forte) => BarChartRodData(
          toY: centavos / 100,
          color: forte ? cor : cor.withValues(alpha: 0.45),
          width: 12,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
        );
    return BarChart(
      BarChartData(
        maxY: teto,
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: _grade(context, 0, teto),
        titlesData: _titulos(context, 0, teto, [for (final t in meses) t.mes]),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => c.surface2,
            tooltipBorderRadius: BorderRadius.circular(12),
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItem: (grupo, _, _, indice) => indice != 0
                ? null
                : BarTooltipItem('${mesAno(meses[grupo.x].mes)}\n', manrope(12, peso: FontWeight.w700, cor: c.text),
                    children: _dica(context, meses[grupo.x])),
          ),
        ),
        barGroups: [
          for (var i = 0; i < meses.length; i++)
            BarChartGroupData(x: i, barsSpace: 4, barRods: [
              barra(meses[i].entrouCentavos, c.teal, _escolhido(meses[i].mes) || mesEscolhido == null),
              barra(meses[i].saiuCentavos, c.bad, _escolhido(meses[i].mes) || mesEscolhido == null),
            ]),
        ],
      ),
    );
  }

  Widget _linhas(BuildContext context, int maior, {required bool area}) {
    final c = context.cores;
    final teto = maior / 100 * 1.2;
    LineChartBarData serie(int Function(TotaisMes) valor, Color cor) => LineChartBarData(
          spots: [for (var i = 0; i < meses.length; i++) FlSpot(i.toDouble(), valor(meses[i]) / 100)],
          isCurved: true,
          preventCurveOverShooting: true,
          color: cor,
          barWidth: 2.5,
          dotData: FlDotData(
            getDotPainter: (spot, _, _, i) => FlDotCirclePainter(
              radius: _escolhido(meses[i].mes) ? 4.5 : 3,
              color: cor,
              strokeWidth: 0,
            ),
          ),
          belowBarData: BarAreaData(
            show: area,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [cor.withValues(alpha: 0.32), cor.withValues(alpha: 0.02)],
            ),
          ),
        );
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: teto,
        minX: -0.3,
        maxX: meses.length - 0.7,
        borderData: FlBorderData(show: false),
        gridData: _grade(context, 0, teto),
        titlesData: _titulos(context, 0, teto, [for (final t in meses) t.mes]),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => c.surface2,
            tooltipBorderRadius: BorderRadius.circular(12),
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (pontos) => [
              for (final p in pontos)
                p.barIndex == 0
                    ? LineTooltipItem('${mesAno(meses[p.x.round()].mes)}\n',
                        manrope(12, peso: FontWeight.w700, cor: c.text),
                        children: _dica(context, meses[p.x.round()]))
                    : null,
            ],
          ),
        ),
        lineBarsData: [
          serie((t) => t.entrouCentavos, c.teal),
          serie((t) => t.saiuCentavos, c.bad),
        ],
      ),
    );
  }

  Widget _velas(BuildContext context) {
    final c = context.cores;
    final baixo = velas.map((v) => v.minima).reduce(math.min) / 100;
    final alto = velas.map((v) => v.maxima).reduce(math.max) / 100;
    final folga = math.max((alto - baixo) * 0.15, 50);
    final minimo = baixo - folga, teto = alto + folga;
    return CandlestickChart(
      CandlestickChartData(
        minX: -0.6,
        maxX: velas.length - 0.4,
        minY: minimo,
        maxY: teto,
        borderData: FlBorderData(show: false),
        gridData: _grade(context, minimo, teto),
        titlesData: _titulos(context, minimo, teto, [for (final v in velas) v.mes]),
        candlestickPainter: DefaultCandlestickPainter(
          candlestickStyleProvider: (spot, i) {
            final cor = velas[i].subiu ? c.teal : c.bad;
            return CandlestickStyle(
              lineColor: cor,
              lineWidth: 1.6,
              bodyStrokeColor: cor,
              bodyStrokeWidth: 1,
              bodyFillColor: cor.withValues(alpha: _escolhido(velas[i].mes) || mesEscolhido == null ? 0.9 : 0.55),
              bodyWidth: 14,
              bodyRadius: 3,
            );
          },
        ),
        candlestickTouchData: CandlestickTouchData(
          touchTooltipData: CandlestickTouchTooltipData(
            getTooltipColor: (_) => c.surface2,
            tooltipBorderRadius: BorderRadius.circular(12),
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (painter, spot, i) {
              final v = velas[i];
              return CandlestickTooltipItem(
                '${mesAno(v.mes)}\n',
                textStyle: manrope(12, peso: FontWeight.w700, cor: c.text),
                children: [
                  TextSpan(text: 'Abriu ${reais(v.abertura)}\nFechou ${reais(v.fechamento)}\n',
                      style: manrope(12, peso: FontWeight.w700, cor: v.subiu ? c.teal : c.bad)),
                  TextSpan(text: 'Máxima ${reais(v.maxima)}\nMínima ${reais(v.minima)}', style: manrope(12, cor: c.muted)),
                ],
              );
            },
          ),
        ),
        candlestickSpots: [
          for (var i = 0; i < velas.length; i++)
            CandlestickSpot(
              x: i.toDouble(),
              open: velas[i].abertura / 100,
              close: velas[i].fechamento / 100,
              high: velas[i].maxima / 100,
              low: velas[i].minima / 100,
            ),
        ],
      ),
    );
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
