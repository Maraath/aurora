import 'package:flutter/material.dart';

import '../../../core/tema.dart';

/// Cartão do painel de Finanças: cantos arredondados, borda fina e sombra
/// suave. Com [titulo], mostra um cabeçalho (e [acao] à direita).
class CartaoPainel extends StatelessWidget {
  const CartaoPainel({
    super.key,
    required this.child,
    this.titulo,
    this.subtitulo,
    this.acao,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final String? titulo;
  final String? subtitulo;
  final Widget? acao;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final escuro = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.line),
        boxShadow: [
          BoxShadow(
            color: escuro ? const Color(0x59000000) : const Color(0x140D0B26),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (titulo != null) ...[
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(titulo!, style: sora(16)),
                  if (subtitulo != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitulo!, style: manrope(12, cor: c.muted)),
                  ],
                ]),
              ),
              ?acao,
            ]),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }
}

/// "▲ 5% vs. mês passado", em verde quando é bom e magenta quando é ruim.
/// [subirEBom]: para receitas subir é bom; para despesas, é ruim.
class Tendencia extends StatelessWidget {
  const Tendencia({super.key, required this.variacao, required this.subirEBom});
  final double? variacao;
  final bool subirEBom;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final v = variacao;
    if (v == null) {
      return Text('sem mês anterior para comparar', style: manrope(12, cor: c.muted));
    }
    final pct = (v.abs() * 100).round();
    if (pct == 0) return Text('igual ao mês passado', style: manrope(12, cor: c.muted));
    final subiu = v > 0;
    final cor = subiu == subirEBom ? c.teal : c.bad;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: cor.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(subiu ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 13, color: cor),
          const SizedBox(width: 2),
          Text('$pct%', style: manrope(12, peso: FontWeight.w700, cor: cor)),
        ]),
      ),
      const SizedBox(width: 6),
      Flexible(child: Text('vs. mês passado', style: manrope(12, cor: c.muted), overflow: TextOverflow.ellipsis)),
    ]);
  }
}
