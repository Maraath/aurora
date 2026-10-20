import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/tema.dart';

/// Quanto de vidro cada peça leva. Mais desfoque e menos opacidade nas barras
/// (que ficam sobre o céu inteiro). Valores leves (pedido do dono, 18/10): com desfoque
/// acima de ~2 as estrelas somem e o vidro parece sólido.
enum TipoVidro {
  /// Barra do celular: a lista passa por baixo, então desfoca bastante.
  barra(desfoque: 10, opacidade: 0.30),

  /// Cartões soltos sobre o céu. Sem desfoque (19/10): o de 2 quase não
  /// aparecia e era o que mais pesava na placa de vídeo, porque cada cartão
  /// refazia o filtro a cada cintilar do céu e a cada quadro de rolagem.
  cartao(desfoque: 0, opacidade: 0.36),

  /// Folhas que sobem de baixo (formulários).
  folha(desfoque: 10, opacidade: 0.78);

  const TipoVidro({required this.desfoque, required this.opacidade});
  final double desfoque;
  final double opacidade;
}

/// Saturação 1,4: as cores do céu (verde e violeta da aurora) ficam um pouco
/// mais vivas atrás do vidro, em vez de virarem cinza com o desfoque.
const _saturacao = 1.4;
const _r = 0.2126, _g = 0.7152, _b = 0.0722;
final _matrizSaturacao = <double>[
  _r * (1 - _saturacao) + _saturacao,
  _g * (1 - _saturacao),
  _b * (1 - _saturacao),
  0,
  0, //
  _r * (1 - _saturacao),
  _g * (1 - _saturacao) + _saturacao,
  _b * (1 - _saturacao),
  0,
  0, //
  _r * (1 - _saturacao),
  _g * (1 - _saturacao),
  _b * (1 - _saturacao) + _saturacao,
  0,
  0, //
  0, 0, 0, 1, 0,
];

ui.ImageFilter _filtro(double desfoque) => ui.ImageFilter.compose(
  outer: ColorFilter.matrix(_matrizSaturacao),
  inner: ui.ImageFilter.blur(
    sigmaX: desfoque,
    sigmaY: desfoque,
    tileMode: TileMode.mirror,
  ),
);

/// Vidro do Aurora: desfoca e satura o que está atrás (o céu estrelado), pinta a
/// superfície da paleta com transparência, uma borda clara fina e um brilho de
/// 1 px no alto. Só no modo escuro; no claro é a superfície sólida de sempre.
///
/// Usa BackdropFilter.grouped: com um BackdropGroup acima (a Shell põe um), todos
/// os vidros da tela leem o fundo uma vez só, o que mantém o desempenho com
/// vários cartões.
class Vidro extends StatelessWidget {
  const Vidro({
    super.key,
    required this.child,
    this.tipo = TipoVidro.cartao,
    this.raio = BorderRadius.zero,
    this.cor,
    this.borda = true,
    this.lados,
  });

  final Widget child;
  final TipoVidro tipo;
  final BorderRadius raio;

  /// Cor de base (padrão: `surface`). Cores já transparentes entram como estão.
  final Color? cor;
  final bool borda;

  /// Borda só em alguns lados (ex.: a barra do celular só em cima). Nulo = todos.
  final Border? lados;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final base = cor ?? c.surface;
    final escuro = Theme.of(context).brightness == Brightness.dark;
    if (!escuro) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: base,
          borderRadius: raio,
          border: borda ? (lados ?? Border.all(color: c.line)) : null,
        ),
        child: child,
      );
    }

    final fundo = base.a < 1 ? base : base.withValues(alpha: tipo.opacidade);
    final contorno = Colors.white.withValues(alpha: 0.09);
    final vidro = DecoratedBox(
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: raio,
        border: borda ? (lados ?? Border.all(color: contorno)) : null,
      ),
      // Brilho suave no alto, como luz batendo na borda de cima do vidro.
      position: DecorationPosition.background,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: raio,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0, 0.35],
            colors: [
              Colors.white.withValues(alpha: 0.045),
              Colors.white.withValues(alpha: 0),
            ],
          ),
        ),
        child: child,
      ),
    );
    if (tipo.desfoque == 0) return ClipRRect(borderRadius: raio, child: vidro);
    return ClipRRect(
      borderRadius: raio,
      child: BackdropFilter.grouped(
        filter: _filtro(tipo.desfoque),
        child: vidro,
      ),
    );
  }
}
