import 'package:flutter/material.dart';

import '../../../core/formato.dart';
import '../../../core/tema.dart';
import '../../../data/banco.dart';
import '../../../data/financas_repo.dart';
import '../categorias_visual.dart';
import 'cartao_painel.dart';

/// Uma transação: ícone da categoria, nome, "Hoje · Mercado" e o valor em
/// verde (entrada) ou na cor do texto com sinal de menos (saída).
class LinhaTransacao extends StatelessWidget {
  const LinhaTransacao({
    super.key,
    required this.movimento,
    required this.hoje,
    this.conta,
    this.destino,
    this.mostrarDia = true,
    this.aoTocar,
  });

  final Movimento movimento;
  final DateTime hoje;
  final String? conta;
  final String? destino;

  /// No extrato o dia já vem no título do grupo.
  final bool mostrarDia;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final m = movimento;
    final v = m.transferencia
        ? VisualCategoria(Icons.swap_horiz_rounded, c.muted)
        : visualDaCategoria(context, m.categoria);
    final detalhe = [
      if (mostrarDia) _dia(m.dia, hoje),
      if (m.transferencia) '${conta ?? ''} → ${destino ?? ''}' else ...[m.categoria, ?conta],
    ].join(' · ');
    final valor = m.transferencia
        ? reais(m.valorCentavos)
        : (m.entrada ? '+ ${reais(m.valorCentavos)}' : '− ${reais(m.valorCentavos)}');

    return InkWell(
      onTap: m.transferencia ? null : aoTocar,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: v.cor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(v.icone, size: 20, color: v.cor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.nome, maxLines: 1, overflow: TextOverflow.ellipsis, style: manrope(15, peso: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(detalhe, maxLines: 1, overflow: TextOverflow.ellipsis, style: manrope(12, cor: c.muted)),
            ]),
          ),
          const SizedBox(width: 10),
          Text(valor,
              style: manrope(15,
                  peso: FontWeight.w700, cor: m.transferencia ? c.muted : (m.entrada ? c.teal : c.text))),
        ]),
      ),
    );
  }

  /// "Hoje", "Ontem", "sex, 17 out".
  static String _dia(DateTime d, DateTime hoje) {
    final texto = diaRelativo(d, hoje);
    return texto.isEmpty ? texto : texto[0].toUpperCase() + texto.substring(1);
  }
}

/// Últimas transações do mês, com "Ver extrato" para a lista completa.
class TransacoesRecentes extends StatelessWidget {
  const TransacoesRecentes({
    super.key,
    required this.movimentos,
    required this.hoje,
    required this.nomesContas,
    required this.contaPrincipalId,
    required this.aoVerTudo,
    required this.aoEditar,
  });

  final List<Movimento> movimentos;
  final DateTime hoje;
  final Map<String, String> nomesContas;
  final String? contaPrincipalId;
  final VoidCallback aoVerTudo;
  final ValueChanged<Transacao> aoEditar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return CartaoPainel(
      titulo: 'Transações recentes',
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      acao: movimentos.isEmpty
          ? null
          : TextButton(
              onPressed: aoVerTudo,
              child: Text('Ver extrato', style: manrope(13, peso: FontWeight.w700, cor: c.accent)),
            ),
      child: movimentos.isEmpty
          ? Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text('Nada entrou nem saiu neste mês. Toque em + para lançar.',
                  style: manrope(14, cor: c.muted)),
            )
          : Column(children: [
              for (var i = 0; i < movimentos.length; i++) ...[
                if (i > 0) Divider(height: 1, color: c.line),
                LinhaTransacao(
                  movimento: movimentos[i],
                  hoje: hoje,
                  conta: nomesContas[movimentos[i].transacao.contaId ?? contaPrincipalId],
                  destino: nomesContas[movimentos[i].transacao.contaDestinoId],
                  aoTocar: () => aoEditar(movimentos[i].transacao),
                ),
              ],
            ]),
    );
  }
}
