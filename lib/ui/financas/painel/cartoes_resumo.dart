import 'package:flutter/material.dart';

import '../../../core/formato.dart';
import '../../../core/tema.dart';
import '../../../data/analise_financas.dart';
import 'cartao_painel.dart';

/// Topo do painel: Saldo atual (com o que sobrou no mês) e, lado a lado,
/// Receitas e Despesas do mês com a tendência em relação ao mês passado.
class CartoesResumo extends StatelessWidget {
  const CartoesResumo({super.key, required this.painel});
  final PainelMes painel;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final p = painel;
    final resultado = p.resultadoCentavos;
    final saldo = CartaoPainel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _Icone(Icons.account_balance_wallet_outlined, c.accent),
          const SizedBox(width: 10),
          Text('Saldo atual', style: manrope(13, peso: FontWeight.w600, cor: c.muted)),
        ]),
        const SizedBox(height: 12),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(reais(p.saldoCentavos), style: sora(34, cor: p.saldoCentavos < 0 ? c.bad : c.text)),
        ),
        const SizedBox(height: 6),
        Text(
          resultado == 0
              ? 'Nada sobrou nem faltou neste mês.'
              : resultado > 0
                  ? 'Sobraram ${reais(resultado)} neste mês.'
                  : 'Faltaram ${reais(-resultado)} neste mês.',
          style: manrope(13, peso: FontWeight.w600, cor: resultado >= 0 ? c.teal : c.bad),
        ),
      ]),
    );

    final receitas = _CartaoValor(
      titulo: 'Receitas',
      icone: Icons.south_west_rounded,
      cor: c.teal,
      centavos: p.receitasCentavos,
      tendencia: Tendencia(variacao: p.variacaoReceitas, subirEBom: true),
    );
    final despesas = _CartaoValor(
      titulo: 'Despesas',
      icone: Icons.north_east_rounded,
      cor: c.bad,
      centavos: p.despesasCentavos,
      tendencia: Tendencia(variacao: p.variacaoDespesas, subirEBom: false),
    );

    return LayoutBuilder(builder: (context, box) {
      // Largo: os três lado a lado; estreito: saldo em cima, os outros dois embaixo.
      if (box.maxWidth >= 680) {
        return IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(flex: 4, child: saldo),
            const SizedBox(width: 12),
            Expanded(flex: 3, child: receitas),
            const SizedBox(width: 12),
            Expanded(flex: 3, child: despesas),
          ]),
        );
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        saldo,
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: receitas),
            const SizedBox(width: 12),
            Expanded(child: despesas),
          ]),
        ),
      ]);
    });
  }
}

class _CartaoValor extends StatelessWidget {
  const _CartaoValor({
    required this.titulo,
    required this.icone,
    required this.cor,
    required this.centavos,
    required this.tendencia,
  });

  final String titulo;
  final IconData icone;
  final Color cor;
  final int centavos;
  final Widget tendencia;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return CartaoPainel(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _Icone(icone, cor),
          const SizedBox(width: 10),
          Flexible(
            child: Text(titulo,
                maxLines: 1, overflow: TextOverflow.ellipsis, style: manrope(13, peso: FontWeight.w600, cor: c.muted)),
          ),
        ]),
        const SizedBox(height: 12),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(reais(centavos), style: sora(22)),
        ),
        const SizedBox(height: 8),
        tendencia,
      ]),
    );
  }
}

class _Icone extends StatelessWidget {
  const _Icone(this.icone, this.cor);
  final IconData icone;
  final Color cor;

  @override
  Widget build(BuildContext context) => Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: cor.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(10)),
        child: Icon(icone, size: 18, color: cor),
      );
}
