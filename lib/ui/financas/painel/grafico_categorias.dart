import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/formato.dart';
import '../../../core/tema.dart';
import '../../../data/financas_repo.dart';
import '../categorias_visual.dart';
import 'cartao_painel.dart';

/// Rosca "Despesas por categoria": o centro mostra o total ou, ao tocar (ou
/// passar o mouse) numa fatia, o valor dela. Legenda com ícone, % e valor.
class GraficoCategorias extends StatefulWidget {
  const GraficoCategorias({super.key, required this.categorias});
  final List<CategoriaGasto> categorias;

  @override
  State<GraficoCategorias> createState() => _GraficoCategoriasState();
}

class _GraficoCategoriasState extends State<GraficoCategorias> {
  int? _tocada;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final cats = widget.categorias;
    final total = cats.fold(0, (s, x) => s + x.centavos);

    if (total == 0) {
      return CartaoPainel(
        titulo: 'Despesas por categoria',
        child: SizedBox(
          height: 120,
          child: Center(
            child: Text('Nenhuma despesa paga neste mês.', style: manrope(14, cor: c.muted)),
          ),
        ),
      );
    }

    final destaque = _tocada == null || _tocada! >= cats.length ? null : cats[_tocada!];
    return CartaoPainel(
      titulo: 'Despesas por categoria',
      subtitulo: 'Para onde foi o dinheiro neste mês',
      child: Column(children: [
        SizedBox(
          height: 190,
          child: Stack(alignment: Alignment.center, children: [
            PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 58,
                startDegreeOffset: -90,
                pieTouchData: PieTouchData(
                  touchCallback: (evento, resposta) {
                    final i = resposta?.touchedSection?.touchedSectionIndex;
                    final saiu = !evento.isInterestedForInteractions || i == null || i < 0;
                    setState(() => _tocada = saiu ? null : i);
                  },
                ),
                sections: [
                  for (var i = 0; i < cats.length; i++)
                    PieChartSectionData(
                      value: cats[i].centavos.toDouble(),
                      color: visualDaCategoria(context, cats[i].nome).cor,
                      radius: i == _tocada ? 30 : 24,
                      showTitle: false,
                    ),
                ],
              ),
            ),
            // Centro: total ou a fatia escolhida.
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text(destaque?.nome ?? 'Total', style: manrope(12, peso: FontWeight.w600, cor: c.muted)),
              const SizedBox(height: 2),
              Text(reais(destaque?.centavos ?? total), style: sora(17)),
              if (destaque != null)
                Text('${_pct(destaque.centavos, total)}%', style: manrope(12, peso: FontWeight.w700, cor: c.muted)),
            ]),
          ]),
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < cats.length; i++)
          _ItemLegenda(
            categoria: cats[i],
            porcento: _pct(cats[i].centavos, total),
            destacado: i == _tocada,
            aoPassar: (dentro) => setState(() => _tocada = dentro ? i : null),
          ),
      ]),
    );
  }

  static int _pct(int parte, int total) => (parte * 100 / total).round();
}

class _ItemLegenda extends StatelessWidget {
  const _ItemLegenda({
    required this.categoria,
    required this.porcento,
    required this.destacado,
    required this.aoPassar,
  });

  final CategoriaGasto categoria;
  final int porcento;
  final bool destacado;
  final ValueChanged<bool> aoPassar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final v = visualDaCategoria(context, categoria.nome);
    return MouseRegion(
      onEnter: (_) => aoPassar(true),
      onExit: (_) => aoPassar(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: destacado ? v.cor.withValues(alpha: 0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: v.cor.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(9)),
            child: Icon(v.icone, size: 16, color: v.cor),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(categoria.nome, style: manrope(14, peso: FontWeight.w600))),
          Text('$porcento%', style: manrope(12, peso: FontWeight.w700, cor: c.muted)),
          const SizedBox(width: 12),
          SizedBox(
            width: 92,
            child: Text(reais(categoria.centavos),
                textAlign: TextAlign.right, style: manrope(14, peso: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }
}
