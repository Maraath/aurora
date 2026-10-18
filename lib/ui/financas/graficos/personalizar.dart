import 'package:flutter/material.dart';

import '../../../core/tema.dart';
import '../../formulario.dart';
import 'config.dart';

/// Abre a folha "Personalizar painel" do [painel]: ligar e desligar cartões,
/// arrastar para mudar a ordem e escolher o tipo de gráfico de cada um. Cada
/// mudança vale na hora (e fica salva neste aparelho).
Future<void> abrirPersonalizar(BuildContext context, PreferenciasPainel prefs, PainelFin painel) =>
    abrirFolha<void>(context, (_) => _Personalizar(prefs: prefs, painel: painel));

class _Personalizar extends StatelessWidget {
  const _Personalizar({required this.prefs, required this.painel});
  final PreferenciasPainel prefs;
  final PainelFin painel;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return ListenableBuilder(
      listenable: prefs,
      builder: (context, _) {
        final config = prefs.config;
        final ordem = config.ordem[painel]!;
        return SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: c.line, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: Text('Personalizar painel', style: sora(20))),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Pronto', style: manrope(14, peso: FontWeight.w700, cor: c.accent)),
                  ),
                ]),
                Text(
                  'Finanças › ${painel == PainelFin.resumo ? 'Resumo' : 'Análise'} · arraste para mudar a ordem. Vale para este aparelho.',
                  style: manrope(12.5, cor: c.muted, altura: 1.4),
                ),
                const SizedBox(height: 14),
                Flexible(
                  child: ReorderableListView(
                    shrinkWrap: true,
                    buildDefaultDragHandles: false,
                    onReorderItem: (de, para) {
                      final nova = config.copiar();
                      final lista = nova.ordem[painel]!;
                      lista.insert(para, lista.removeAt(de));
                      prefs.salvar(nova);
                    },
                    children: [
                      for (var i = 0; i < ordem.length; i++)
                        _Linha(
                          key: ValueKey(ordem[i]),
                          indice: i,
                          cartao: ordem[i],
                          ligado: !config.ocultos.contains(ordem[i]),
                          tipo: config.tipoDe(ordem[i]),
                          aoLigar: (v) {
                            final nova = config.copiar();
                            v ? nova.ocultos.remove(ordem[i]) : nova.ocultos.add(ordem[i]);
                            prefs.salvar(nova);
                          },
                          aoEscolherTipo: (t) => prefs.escolherTipo(ordem[i], t),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      final padrao = ConfigPainel.padrao();
                      final nova = config.copiar()
                        ..ordem[painel] = padrao.ordem[painel]!
                        ..ocultos.removeWhere((c) => c.painel == painel)
                        ..tipos.removeWhere((c, _) => c.painel == painel);
                      prefs.salvar(nova);
                    },
                    icon: Icon(Icons.restart_alt_rounded, size: 18, color: c.muted),
                    label: Text('Restaurar padrão', style: manrope(13, peso: FontWeight.w700, cor: c.muted)),
                  ),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha({
    super.key,
    required this.indice,
    required this.cartao,
    required this.ligado,
    required this.tipo,
    required this.aoLigar,
    required this.aoEscolherTipo,
  });

  final int indice;
  final CartaoFin cartao;
  final bool ligado;
  final TipoGrafico? tipo;
  final ValueChanged<bool> aoLigar;
  final ValueChanged<TipoGrafico> aoEscolherTipo;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: c.surface2.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.line),
        ),
        child: Row(children: [
          ReorderableDragStartListener(
            index: indice,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.drag_indicator_rounded, color: c.muted, semanticLabel: 'Arrastar ${cartao.rotulo}'),
            ),
          ),
          Expanded(
            child: Text(cartao.rotulo,
                style: manrope(14, peso: FontWeight.w700, cor: ligado ? c.text : c.muted)),
          ),
          if (tipo != null)
            PopupMenuButton<TipoGrafico>(
              tooltip: 'Tipo de gráfico',
              initialValue: tipo,
              onSelected: aoEscolherTipo,
              color: c.surface,
              itemBuilder: (_) => [
                for (final t in cartao.tipos)
                  PopupMenuItem(
                    value: t,
                    child: Row(children: [
                      Icon(t.icone, size: 18, color: t == tipo ? c.accent : c.muted),
                      const SizedBox(width: 10),
                      Text(t.rotulo, style: manrope(14, peso: FontWeight.w600)),
                    ]),
                  ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(tipo!.icone, size: 16, color: c.muted),
                  const SizedBox(width: 4),
                  Text(tipo!.rotulo, style: manrope(12, peso: FontWeight.w600, cor: c.muted)),
                  Icon(Icons.arrow_drop_down_rounded, color: c.muted),
                ]),
              ),
            ),
          Switch(value: ligado, onChanged: aoLigar, activeThumbColor: c.noAccent, activeTrackColor: c.accentFill),
        ]),
      ),
    );
  }
}
