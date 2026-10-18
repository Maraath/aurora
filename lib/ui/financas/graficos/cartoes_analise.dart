import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/formato.dart';
import '../../../core/tema.dart';
import '../../../data/graficos_financas.dart';
import '../categorias_visual.dart';
import '../painel/cartao_painel.dart';
import 'config.dart';

// ---------------------------------------------------------------- trajetória

/// "Trajetória do saldo": o saldo total nos últimos meses e a projeção para os
/// próximos (linha pela média, faixa entre o pior e o melhor mês); em área; ou
/// em velas.
class CartaoTrajetoria extends StatelessWidget {
  const CartaoTrajetoria({
    super.key,
    required this.velas,
    required this.projecao,
    required this.tipo,
    required this.aoEscolherTipo,
  });

  final List<VelaSaldo> velas;
  final ProjecaoSaldo projecao;
  final TipoGrafico tipo;
  final ValueChanged<TipoGrafico> aoEscolherTipo;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final hist = [for (final v in velas) v.fechamento / 100];
    final n = hist.length;
    final comProjecao = tipo == TipoGrafico.projecao;
    final mostrarProjecao = tipo != TipoGrafico.velas && comProjecao;
    final todos = [
      ...hist,
      for (final v in velas) ...[v.maxima / 100, v.minima / 100],
      if (mostrarProjecao) ...[...projecao.otimista.map((v) => v / 100), ...projecao.pessimista.map((v) => v / 100)],
    ];
    final baixo = todos.reduce(math.min), alto = todos.reduce(math.max);
    final folga = math.max((alto - baixo) * 0.15, 50);
    final minimo = baixo - folga, teto = alto + folga;
    final rotulos = [
      for (final v in velas) v.mes,
      if (mostrarProjecao)
        for (var i = 1; i <= projecao.media.length; i++) DateTime(velas.last.mes.year, velas.last.mes.month + i, 1),
    ];
    final eixos = _titulos(context, minimo, teto, rotulos);

    Widget grafico;
    if (tipo == TipoGrafico.velas) {
      grafico = CandlestickChart(
        CandlestickChartData(
          minX: -0.6,
          maxX: n - 0.4,
          minY: minimo,
          maxY: teto,
          borderData: FlBorderData(show: false),
          gridData: _grade(context, minimo, teto),
          titlesData: eixos,
          candlestickPainter: DefaultCandlestickPainter(
            candlestickStyleProvider: (spot, i) {
              final cor = velas[i].subiu ? c.teal : c.bad;
              return CandlestickStyle(
                lineColor: cor,
                lineWidth: 1.6,
                bodyStrokeColor: cor,
                bodyStrokeWidth: 1,
                bodyFillColor: cor.withValues(alpha: 0.85),
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
              getTooltipItems: (_, _, i) => CandlestickTooltipItem(
                '${mesAno(velas[i].mes)}\n',
                textStyle: manrope(12, peso: FontWeight.w700, cor: c.text),
                children: [
                  TextSpan(
                    text: 'Abriu ${reais(velas[i].abertura)} · fechou ${reais(velas[i].fechamento)}',
                    style: manrope(12, peso: FontWeight.w700, cor: velas[i].subiu ? c.teal : c.bad),
                  ),
                ],
              ),
            ),
          ),
          candlestickSpots: [
            for (var i = 0; i < n; i++)
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
    } else {
      final pontosHist = [for (var i = 0; i < n; i++) FlSpot(i.toDouble(), hist[i])];
      List<FlSpot> futuro(List<int> serie) => [
            FlSpot(n - 1, hist.last),
            for (var i = 0; i < serie.length; i++) FlSpot((n + i).toDouble(), serie[i] / 100),
          ];
      final barras = <LineChartBarData>[
        LineChartBarData(
          spots: pontosHist,
          color: c.accent,
          barWidth: 3,
          isCurved: true,
          preventCurveOverShooting: true,
          dotData: FlDotData(getDotPainter: (s, _, _, i) => FlDotCirclePainter(radius: i == n - 1 ? 4.5 : 0, color: c.accent, strokeWidth: 0)),
          belowBarData: BarAreaData(
            show: tipo == TipoGrafico.area,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [c.accent.withValues(alpha: 0.32), c.accent.withValues(alpha: 0.02)],
            ),
          ),
        ),
        if (mostrarProjecao) ...[
          LineChartBarData(spots: futuro(projecao.otimista), color: Colors.transparent, barWidth: 0, dotData: const FlDotData(show: false)),
          LineChartBarData(spots: futuro(projecao.pessimista), color: Colors.transparent, barWidth: 0, dotData: const FlDotData(show: false)),
          LineChartBarData(
            spots: futuro(projecao.media),
            color: c.violeta,
            barWidth: 2.4,
            dashArray: [6, 5],
            dotData: const FlDotData(show: false),
          ),
        ],
      ];
      grafico = LineChart(
        LineChartData(
          minX: 0,
          maxX: (rotulos.length - 1).toDouble(),
          minY: minimo,
          maxY: teto,
          borderData: FlBorderData(show: false),
          gridData: _grade(context, minimo, teto),
          titlesData: eixos,
          betweenBarsData: [
            if (mostrarProjecao) BetweenBarsData(fromIndex: 1, toIndex: 2, color: c.violeta.withValues(alpha: 0.16)),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => c.surface2,
              tooltipBorderRadius: BorderRadius.circular(12),
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (pontos) => [
                for (final p in pontos)
                  (p.barIndex == 0 || p.barIndex == 3) && p.x.round() < rotulos.length
                      ? LineTooltipItem(
                          '${mesAno(rotulos[p.x.round()])}\n',
                          manrope(12, peso: FontWeight.w700, cor: c.text),
                          children: [
                            TextSpan(
                              text: '${p.barIndex == 3 ? 'previsto ' : ''}${reais((p.y * 100).round())}',
                              style: manrope(12, peso: FontWeight.w700, cor: p.barIndex == 3 ? c.violeta : c.accent),
                            ),
                          ],
                        )
                      : null,
              ],
            ),
          ),
          lineBarsData: barras,
        ),
      );
    }

    final hoje = velas.last.fechamento;
    final daqui6 = projecao.media.isEmpty ? hoje : projecao.media.last;
    return CartaoPainel(
      titulo: 'Trajetória do saldo',
      subtitulo: comProjecao ? 'Últimos ${velas.length} meses e projeção para os próximos 6' : 'Saldo total mês a mês',
      acao: SeletorTipo(tipos: CartaoFin.trajetoria.tipos, atual: tipo, aoEscolher: aoEscolherTipo),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(height: 210, child: grafico),
        const SizedBox(height: 10),
        Text('Hoje: ${reais(hoje)}', style: manrope(13, peso: FontWeight.w700, cor: c.accent)),
        if (comProjecao)
          Text(
            'No ritmo dos últimos meses, em 6 meses: ${reais(daqui6)} '
            '(entre ${reais(projecao.pessimista.last)} e ${reais(projecao.otimista.last)}).',
            style: manrope(12.5, cor: c.muted, altura: 1.4),
          ),
      ]),
    );
  }
}

FlGridData _grade(BuildContext context, double minimo, double teto) => FlGridData(
      drawVerticalLine: false,
      horizontalInterval: math.max((teto - minimo) / 4, 1),
      getDrawingHorizontalLine: (_) => FlLine(color: context.cores.line, strokeWidth: 1, dashArray: [4, 4]),
    );

FlTitlesData _titulos(BuildContext context, double minimo, double teto, List<DateTime> rotulos) {
  final c = context.cores;
  return FlTitlesData(
    rightTitles: const AxisTitles(),
    topTitles: const AxisTitles(),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 62,
        interval: math.max((teto - minimo) / 4, 1),
        getTitlesWidget: (y, _) =>
            y <= minimo || y >= teto ? const SizedBox.shrink() : Text(reaisCurto(y), style: manrope(10, cor: c.muted)),
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 24,
        interval: 1,
        getTitlesWidget: (x, _) {
          final i = x.round();
          if (i < 0 || i >= rotulos.length || (x - i).abs() > 0.01) return const SizedBox.shrink();
          if (rotulos.length > 8 && i.isOdd) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(mesCurto(rotulos[i]), style: manrope(10.5, peso: FontWeight.w700, cor: c.muted)),
          );
        },
      ),
    ),
  );
}

// ---------------------------------------------------------------- categorias no tempo

/// "Categorias no tempo": como cada categoria cresceu ou caiu nos últimos
/// meses, em áreas empilhadas, linhas ou barras empilhadas. As etiquetas
/// embaixo ligam e desligam cada categoria.
class CartaoCategoriasTempo extends StatefulWidget {
  const CartaoCategoriasTempo({super.key, required this.dados, required this.tipo, required this.aoEscolherTipo});
  final CategoriasNoTempo dados;
  final TipoGrafico tipo;
  final ValueChanged<TipoGrafico> aoEscolherTipo;

  @override
  State<CartaoCategoriasTempo> createState() => _CartaoCategoriasTempoState();
}

class _CartaoCategoriasTempoState extends State<CartaoCategoriasTempo> {
  final _desligadas = <String>{};

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final d = widget.dados;
    final nomes = d.series.keys.where((n) => !_desligadas.contains(n)).toList();
    Color cor(String n) => n == 'Outras' ? c.muted : visualDaCategoria(context, n).cor;
    final vazio = d.series.values.every((s) => s.every((v) => v == 0));

    Widget grafico() {
      final empilhar = widget.tipo != TipoGrafico.linhas;
      final acumulado = List.filled(d.meses.length, 0);
      final camadas = <String, List<int>>{};
      for (final n in nomes) {
        for (var i = 0; i < d.meses.length; i++) {
          acumulado[i] += empilhar ? d.series[n]![i] : 0;
        }
        camadas[n] = empilhar ? [...acumulado] : d.series[n]!;
      }
      final maiorValor = empilhar
          ? acumulado.fold(0, math.max)
          : nomes.expand((n) => d.series[n]!).fold(0, math.max);
      final teto = math.max(maiorValor / 100 * 1.15, 1.0);
      final eixos = _titulos(context, 0, teto, d.meses);

      if (widget.tipo == TipoGrafico.empilhadas) {
        return BarChart(
          BarChartData(
            maxY: teto,
            alignment: BarChartAlignment.spaceAround,
            borderData: FlBorderData(show: false),
            gridData: _grade(context, 0, teto),
            titlesData: eixos,
            barTouchData: BarTouchData(enabled: false),
            barGroups: [
              for (var i = 0; i < d.meses.length; i++)
                BarChartGroupData(x: i, barRods: [
                  BarChartRodData(
                    toY: (nomes.isEmpty ? 0 : camadas[nomes.last]![i]) / 100,
                    width: 22,
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.transparent,
                    rodStackItems: [
                      for (var k = 0; k < nomes.length; k++)
                        BarChartRodStackItem(
                          (k == 0 ? 0 : camadas[nomes[k - 1]]![i]) / 100,
                          camadas[nomes[k]]![i] / 100,
                          cor(nomes[k]).withValues(alpha: 0.85),
                        ),
                    ],
                  ),
                ]),
            ],
          ),
        );
      }

      final barras = [
        for (final n in nomes)
          LineChartBarData(
            spots: [for (var i = 0; i < d.meses.length; i++) FlSpot(i.toDouble(), camadas[n]![i] / 100)],
            isCurved: true,
            preventCurveOverShooting: true,
            color: cor(n),
            barWidth: empilhar ? 1.2 : 2.4,
            dotData: FlDotData(show: !empilhar),
          ),
      ];
      return LineChart(
        LineChartData(
          minY: 0,
          maxY: teto,
          minX: 0,
          maxX: (d.meses.length - 1).toDouble(),
          borderData: FlBorderData(show: false),
          gridData: _grade(context, 0, teto),
          titlesData: eixos,
          lineTouchData: const LineTouchData(enabled: false),
          betweenBarsData: [
            if (empilhar)
              for (var k = 1; k < barras.length; k++)
                BetweenBarsData(fromIndex: k - 1, toIndex: k, color: cor(nomes[k]).withValues(alpha: 0.5)),
          ],
          lineBarsData: [
            for (var k = 0; k < barras.length; k++)
              k == 0 && empilhar
                  ? barras[k].copyWith(
                      belowBarData: BarAreaData(show: true, color: cor(nomes[k]).withValues(alpha: 0.5)),
                    )
                  : barras[k],
          ],
        ),
      );
    }

    return CartaoPainel(
      titulo: 'Categorias no tempo',
      subtitulo: 'Como cada categoria cresceu ou caiu',
      acao: SeletorTipo(tipos: CartaoFin.categoriasTempo.tipos, atual: widget.tipo, aoEscolher: widget.aoEscolherTipo),
      child: vazio
          ? SizedBox(
              height: 120,
              child: Center(child: Text('Sem despesas nestes meses.', style: manrope(14, cor: c.muted))),
            )
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SizedBox(height: 200, child: nomes.isEmpty ? const SizedBox() : grafico()),
              const SizedBox(height: 12),
              Wrap(spacing: 6, runSpacing: 6, children: [
                for (final n in d.series.keys)
                  _Etiqueta(
                    texto: n,
                    cor: cor(n),
                    ligada: !_desligadas.contains(n),
                    aoTocar: () => setState(() => _desligadas.contains(n) ? _desligadas.remove(n) : _desligadas.add(n)),
                  ),
              ]),
            ]),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({required this.texto, required this.cor, required this.ligada, required this.aoTocar});
  final String texto;
  final Color cor;
  final bool ligada;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Semantics(
      button: true,
      toggled: ligada,
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: ligada ? cor.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: ligada ? cor.withValues(alpha: 0.5) : c.line),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: ligada ? cor : c.muted, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 6),
            Text(texto, style: manrope(12, peso: FontWeight.w700, cor: ligada ? c.text : c.muted)),
          ]),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- rigidez

/// "Fixo × parcelas × variável": quanto do gasto já nasce decidido. Barras
/// empilhadas por mês (com as partes ligáveis) ou rosca do mês mais recente.
class CartaoRigidez extends StatefulWidget {
  const CartaoRigidez({super.key, required this.meses, required this.tipo, required this.aoEscolherTipo});
  final List<RigidezMes> meses;
  final TipoGrafico tipo;
  final ValueChanged<TipoGrafico> aoEscolherTipo;

  @override
  State<CartaoRigidez> createState() => _CartaoRigidezState();
}

class _CartaoRigidezState extends State<CartaoRigidez> {
  final _desligadas = <ClasseGasto>{};

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final cores = {ClasseGasto.fixo: c.muted, ClasseGasto.parcela: c.violeta, ClasseGasto.variavel: c.accent};
    const nomes = {ClasseGasto.fixo: 'Fixo', ClasseGasto.parcela: 'Parcelas', ClasseGasto.variavel: 'Variável'};
    int valor(RigidezMes r, ClasseGasto k) => switch (k) {
          ClasseGasto.fixo => r.fixoCentavos,
          ClasseGasto.parcela => r.parcelasCentavos,
          ClasseGasto.variavel => r.variavelCentavos,
        };
    final ligadas = ClasseGasto.values.where((k) => !_desligadas.contains(k)).toList();
    final vazio = widget.meses.every((r) => r.totalCentavos == 0);
    final recente = widget.meses.lastWhere((r) => r.totalCentavos > 0, orElse: () => widget.meses.last);

    Widget grafico() {
      if (widget.tipo == TipoGrafico.rosca) {
        final total = ligadas.fold(0, (s, k) => s + valor(recente, k));
        return Row(children: [
          SizedBox(
            width: 150,
            height: 150,
            child: PieChart(PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 42,
              startDegreeOffset: -90,
              sections: [
                for (final k in ligadas)
                  if (valor(recente, k) > 0)
                    PieChartSectionData(value: valor(recente, k).toDouble(), color: cores[k], radius: 22, showTitle: false),
              ],
            )),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(mesAno(recente.mes), style: manrope(12, peso: FontWeight.w700, cor: c.muted)),
              const SizedBox(height: 6),
              for (final k in ligadas)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${nomes[k]}: ${reais(valor(recente, k))}'
                    '${total > 0 ? ' · ${(valor(recente, k) * 100 / total).round()}%' : ''}',
                    style: manrope(13, peso: FontWeight.w600, cor: c.text),
                  ),
                ),
            ]),
          ),
        ]);
      }
      final maior = widget.meses.map((r) => ligadas.fold(0, (s, k) => s + valor(r, k))).fold(0, math.max);
      final teto = math.max(maior / 100 * 1.15, 1.0);
      return SizedBox(
        height: 190,
        child: BarChart(
          BarChartData(
            maxY: teto,
            alignment: BarChartAlignment.spaceAround,
            borderData: FlBorderData(show: false),
            gridData: _grade(context, 0, teto),
            titlesData: _titulos(context, 0, teto, [for (final r in widget.meses) r.mes]),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => c.surface2,
                tooltipBorderRadius: BorderRadius.circular(12),
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipItem: (g, _, _, _) {
                  final r = widget.meses[g.x];
                  return BarTooltipItem('${mesAno(r.mes)}\n', manrope(12, peso: FontWeight.w700, cor: c.text), children: [
                    for (final k in ligadas)
                      TextSpan(text: '${nomes[k]} ${reais(valor(r, k))}\n', style: manrope(12, peso: FontWeight.w700, cor: cores[k])),
                  ]);
                },
              ),
            ),
            barGroups: [
              for (var i = 0; i < widget.meses.length; i++)
                () {
                  var base = 0.0;
                  final itens = <BarChartRodStackItem>[];
                  for (final k in ligadas) {
                    final v = valor(widget.meses[i], k) / 100;
                    itens.add(BarChartRodStackItem(base, base + v, cores[k]!.withValues(alpha: 0.85)));
                    base += v;
                  }
                  return BarChartGroupData(x: i, barRods: [
                    BarChartRodData(toY: base, width: 24, borderRadius: BorderRadius.circular(5), color: Colors.transparent, rodStackItems: itens),
                  ]);
                }(),
            ],
          ),
        ),
      );
    }

    return CartaoPainel(
      titulo: 'Fixo × parcelas × variável',
      subtitulo: 'Quanto do gasto já nasce decidido',
      acao: SeletorTipo(tipos: CartaoFin.rigidez.tipos, atual: widget.tipo, aoEscolher: widget.aoEscolherTipo),
      child: vazio
          ? SizedBox(
              height: 120,
              child: Center(child: Text('Sem despesas nestes meses.', style: manrope(14, cor: c.muted))),
            )
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Wrap(spacing: 6, runSpacing: 6, children: [
                for (final k in ClasseGasto.values)
                  _Etiqueta(
                    texto: nomes[k]!,
                    cor: cores[k]!,
                    ligada: !_desligadas.contains(k),
                    aoTocar: () => setState(() => _desligadas.contains(k) ? _desligadas.remove(k) : _desligadas.add(k)),
                  ),
              ]),
              const SizedBox(height: 12),
              grafico(),
              if (recente.totalCentavos > 0 && recente.comprometido > 0) ...[
                const SizedBox(height: 10),
                Text(
                  '${(recente.comprometido * 100).round()}% do gasto de ${mesAno(recente.mes)} já estava comprometido '
                  'antes do mês começar.',
                  style: manrope(12.5, cor: c.muted, altura: 1.4),
                ),
              ],
            ]),
    );
  }
}

// ---------------------------------------------------------------- leituras

/// "Leituras do período": frases automáticas sobre os meses escolhidos.
class CartaoLeituras extends StatelessWidget {
  const CartaoLeituras({super.key, required this.frases, required this.periodo, required this.aoMudarPeriodo});
  final List<String> frases;
  final int periodo;
  final ValueChanged<int> aoMudarPeriodo;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return CartaoPainel(
      titulo: 'Leituras do período',
      subtitulo: 'Os gráficos abaixo usam os últimos $periodo meses',
      acao: Row(mainAxisSize: MainAxisSize.min, children: [
        for (final p in const [3, 6, 12])
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: InkWell(
              onTap: () => aoMudarPeriodo(p),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: p == periodo ? c.accentSoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: p == periodo ? c.accent.withValues(alpha: 0.45) : c.line),
                ),
                child: Text('${p}m', style: manrope(12, peso: FontWeight.w700, cor: p == periodo ? c.accent : c.muted)),
              ),
            ),
          ),
      ]),
      child: frases.isEmpty
          ? Text('Ainda sem leituras: conforme os lançamentos se acumulam, os padrões aparecem aqui.',
              style: manrope(13.5, cor: c.muted, altura: 1.45))
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (final f in frases)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7, right: 10),
                      child: Container(width: 6, height: 6, decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle)),
                    ),
                    Expanded(child: Text(f, style: manrope(13.5, cor: c.text, altura: 1.45))),
                  ]),
                ),
            ]),
    );
  }
}
