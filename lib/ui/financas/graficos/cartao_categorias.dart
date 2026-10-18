import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/formato.dart';
import '../../../core/tema.dart';
import '../../../data/financas_repo.dart';
import '../../../data/graficos_financas.dart';
import '../categorias_visual.dart';
import '../painel/cartao_painel.dart';
import 'config.dart';

/// "Despesas por categoria" em rosca, pizza, barras, blocos (treemap) ou
/// radar (este mês × média dos 3 anteriores). Tocar (ou passar o mouse) numa
/// parte destaca a categoria na legenda e mostra o valor dela.
class CartaoCategorias extends StatefulWidget {
  const CartaoCategorias({
    super.key,
    required this.categorias,
    required this.comparacao,
    required this.tipo,
    required this.aoEscolherTipo,
  });

  final List<CategoriaGasto> categorias;
  final List<ComparacaoCategoria> comparacao;
  final TipoGrafico tipo;
  final ValueChanged<TipoGrafico> aoEscolherTipo;

  @override
  State<CartaoCategorias> createState() => _CartaoCategoriasState();
}

class _CartaoCategoriasState extends State<CartaoCategorias> {
  int? _tocada;

  void _tocar(int? i) => setState(() => _tocada = i);

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final cats = widget.categorias;
    final total = cats.fold(0, (s, x) => s + x.centavos);
    final seletor = SeletorTipo(tipos: CartaoFin.categorias.tipos, atual: widget.tipo, aoEscolher: widget.aoEscolherTipo);

    if (total == 0 && widget.tipo != TipoGrafico.radar) {
      return CartaoPainel(
        titulo: 'Despesas por categoria',
        acao: seletor,
        child: SizedBox(
          height: 120,
          child: Center(child: Text('Nenhuma despesa paga neste mês.', style: manrope(14, cor: c.muted))),
        ),
      );
    }

    final destaque = _tocada == null || _tocada! >= cats.length ? null : cats[_tocada!];
    final grafico = switch (widget.tipo) {
      TipoGrafico.pizza => _pizza(context, total, buraco: false),
      TipoGrafico.barrasDeitadas => _barras(context, total),
      TipoGrafico.blocos => _blocos(context, total),
      TipoGrafico.radar => _radar(context),
      _ => _pizza(context, total, buraco: true),
    };

    return CartaoPainel(
      titulo: 'Despesas por categoria',
      subtitulo: widget.tipo == TipoGrafico.radar
          ? 'Este mês comparado à média dos 3 anteriores'
          : 'Para onde foi o dinheiro neste mês',
      acao: seletor,
      child: Column(children: [
        AnimatedSwitcher(
          duration: MediaQuery.maybeDisableAnimationsOf(context) ?? false
              ? Duration.zero
              : const Duration(milliseconds: 220),
          child: KeyedSubtree(key: ValueKey(widget.tipo), child: grafico),
        ),
        if (widget.tipo == TipoGrafico.pizza && destaque != null) ...[
          const SizedBox(height: 6),
          Text('${destaque.nome} · ${reais(destaque.centavos)} · ${_pct(destaque.centavos, total)}%',
              style: manrope(13, peso: FontWeight.w700)),
        ],
        const SizedBox(height: 14),
        if (widget.tipo != TipoGrafico.radar && widget.tipo != TipoGrafico.barrasDeitadas)
          for (var i = 0; i < cats.length; i++)
            _ItemLegenda(
              categoria: cats[i],
              porcento: _pct(cats[i].centavos, total),
              destacado: i == _tocada,
              aoPassar: (dentro) => _tocar(dentro ? i : null),
            ),
      ]),
    );
  }

  Widget _pizza(BuildContext context, int total, {required bool buraco}) {
    final c = context.cores;
    final cats = widget.categorias;
    final destaque = _tocada == null || _tocada! >= cats.length ? null : cats[_tocada!];
    return SizedBox(
      height: 190,
      child: Stack(alignment: Alignment.center, children: [
        PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: buraco ? 58 : 0,
            startDegreeOffset: -90,
            pieTouchData: PieTouchData(
              touchCallback: (evento, resposta) {
                final i = resposta?.touchedSection?.touchedSectionIndex;
                final saiu = !evento.isInterestedForInteractions || i == null || i < 0;
                _tocar(saiu ? null : i);
              },
            ),
            sections: [
              for (var i = 0; i < cats.length; i++)
                PieChartSectionData(
                  value: cats[i].centavos.toDouble(),
                  color: visualDaCategoria(context, cats[i].nome).cor,
                  radius: buraco ? (i == _tocada ? 30 : 24) : (i == _tocada ? 92 : 86),
                  showTitle: false,
                ),
            ],
          ),
        ),
        if (buraco)
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text(destaque?.nome ?? 'Total', style: manrope(12, peso: FontWeight.w600, cor: c.muted)),
            const SizedBox(height: 2),
            Text(reais(destaque?.centavos ?? total), style: sora(17)),
            if (destaque != null)
              Text('${_pct(destaque.centavos, total)}%', style: manrope(12, peso: FontWeight.w700, cor: c.muted)),
          ]),
      ]),
    );
  }

  Widget _barras(BuildContext context, int total) {
    final c = context.cores;
    final cats = widget.categorias;
    final maior = cats.first.centavos;
    return Column(children: [
      for (var i = 0; i < cats.length; i++)
        MouseRegion(
          onEnter: (_) => _tocar(i),
          onExit: (_) => _tocar(null),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Icon(visualDaCategoria(context, cats[i].nome).icone,
                    size: 15, color: visualDaCategoria(context, cats[i].nome).cor),
                const SizedBox(width: 8),
                Expanded(child: Text(cats[i].nome, style: manrope(13.5, peso: FontWeight.w600))),
                Text('${_pct(cats[i].centavos, total)}%', style: manrope(12, peso: FontWeight.w700, cor: c.muted)),
                const SizedBox(width: 10),
                Text(reais(cats[i].centavos), style: manrope(13.5, peso: FontWeight.w700)),
              ]),
              const SizedBox(height: 6),
              LayoutBuilder(builder: (context, box) {
                final cor = visualDaCategoria(context, cats[i].nome).cor;
                return Stack(children: [
                  Container(height: 10, decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(6))),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: box.maxWidth * cats[i].centavos / maior,
                    height: 10,
                    decoration: BoxDecoration(
                      color: i == _tocada ? cor : cor.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ]);
              }),
            ]),
          ),
        ),
    ]);
  }

  Widget _blocos(BuildContext context, int total) {
    final cats = widget.categorias;
    return SizedBox(
      height: 200,
      child: LayoutBuilder(builder: (context, box) {
        final retangulos = dividirEmBlocos([for (final x in cats) x.centavos.toDouble()], Offset.zero & box.biggest);
        return Stack(children: [
          for (var i = 0; i < cats.length; i++)
            Positioned.fromRect(
              rect: retangulos[i].deflate(2),
              child: MouseRegion(
                onEnter: (_) => _tocar(i),
                onExit: (_) => _tocar(null),
                child: GestureDetector(
                  onTap: () => _tocar(_tocada == i ? null : i),
                  child: _Bloco(
                    nome: cats[i].nome,
                    porcento: _pct(cats[i].centavos, total),
                    cor: visualDaCategoria(context, cats[i].nome).cor,
                    destacado: i == _tocada,
                  ),
                ),
              ),
            ),
        ]);
      }),
    );
  }

  Widget _radar(BuildContext context) {
    final c = context.cores;
    final comp = widget.comparacao;
    if (comp.length < 3) {
      return SizedBox(
        height: 140,
        child: Center(
          child: Text('O radar precisa de gastos em pelo menos 3 categorias.',
              textAlign: TextAlign.center, style: manrope(14, cor: c.muted)),
        ),
      );
    }
    final maior = comp.fold<int>(1, (m, x) => [m, x.atualCentavos, x.mediaCentavos].reduce((a, b) => a > b ? a : b));
    RadarDataSet serie(List<double> valores, Color cor, double alfa) => RadarDataSet(
          dataEntries: [for (final v in valores) RadarEntry(value: v)],
          fillColor: cor.withValues(alpha: alfa),
          borderColor: cor,
          borderWidth: 2,
          entryRadius: 2.5,
        );
    return Column(children: [
      SizedBox(
        height: 230,
        child: RadarChart(
          RadarChartData(
            radarShape: RadarShape.polygon,
            tickCount: 3,
            ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 1),
            radarBorderData: BorderSide(color: c.line),
            gridBorderData: BorderSide(color: c.line),
            tickBorderData: BorderSide(color: c.line),
            titleTextStyle: manrope(11, peso: FontWeight.w600, cor: c.muted),
            titlePositionPercentageOffset: 0.12,
            getTitle: (i, _) => RadarChartTitle(text: comp[i].nome),
            dataSets: [
              serie([for (final x in comp) x.mediaCentavos / maior * 100], c.violeta, 0.12),
              serie([for (final x in comp) x.atualCentavos / maior * 100], c.accent, 0.22),
              // Âncora invisível: o radar começa em zero e vai até o maior valor.
              RadarDataSet(
                dataEntries: [for (var i = 0; i < comp.length; i++) RadarEntry(value: i == 0 ? 100 : 0)],
                fillColor: Colors.transparent,
                borderColor: Colors.transparent,
                entryRadius: 0,
                borderWidth: 0,
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 8),
      Wrap(spacing: 18, children: [
        _Marca(cor: c.accent, texto: 'Este mês'),
        _Marca(cor: c.violeta, texto: 'Média dos 3 anteriores'),
      ]),
    ]);
  }

  static int _pct(int parte, int total) => total == 0 ? 0 : (parte * 100 / total).round();
}

/// Divide [area] em retângulos proporcionais a [valores] (já do maior para o
/// menor), cortando sempre pelo lado mais comprido: um treemap simples.
List<Rect> dividirEmBlocos(List<double> valores, Rect area) {
  final saida = List<Rect>.filled(valores.length, Rect.zero);
  void dividir(int de, int ate, Rect r) {
    if (ate - de <= 0) return;
    if (ate - de == 1) {
      saida[de] = r;
      return;
    }
    final total = valores.sublist(de, ate).fold(0.0, (s, v) => s + v);
    var meio = de, acumulado = 0.0;
    while (meio < ate - 1 && acumulado + valores[meio] <= total / 2) {
      acumulado += valores[meio];
      meio++;
    }
    if (meio == de) {
      acumulado = valores[de];
      meio = de + 1;
    }
    final fracao = total == 0 ? 0.5 : acumulado / total;
    if (r.width >= r.height) {
      final w = r.width * fracao;
      dividir(de, meio, Rect.fromLTWH(r.left, r.top, w, r.height));
      dividir(meio, ate, Rect.fromLTWH(r.left + w, r.top, r.width - w, r.height));
    } else {
      final h = r.height * fracao;
      dividir(de, meio, Rect.fromLTWH(r.left, r.top, r.width, h));
      dividir(meio, ate, Rect.fromLTWH(r.left, r.top + h, r.width, r.height - h));
    }
  }

  dividir(0, valores.length, area);
  return saida;
}

class _Bloco extends StatelessWidget {
  const _Bloco({required this.nome, required this.porcento, required this.cor, required this.destacado});
  final String nome;
  final int porcento;
  final Color cor;
  final bool destacado;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: destacado ? 0.85 : 0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(builder: (context, box) {
        if (box.maxWidth < 34 || box.maxHeight < 22) return const SizedBox.shrink();
        return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(nome,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: manrope(12, peso: FontWeight.w800, cor: c.noAccent)),
          if (box.maxHeight > 40) Text('$porcento%', style: manrope(11, peso: FontWeight.w700, cor: c.noAccent)),
        ]);
      }),
    );
  }
}

class _Marca extends StatelessWidget {
  const _Marca({required this.cor, required this.texto});
  final Color cor;
  final String texto;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(texto, style: manrope(12, peso: FontWeight.w600, cor: context.cores.muted)),
      ]);
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
            child: Text(reais(categoria.centavos), textAlign: TextAlign.right, style: manrope(14, peso: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }
}
