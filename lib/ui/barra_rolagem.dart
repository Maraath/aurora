import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../core/tema.dart';

/// Rolagem do Aurora: no computador, as listas verticais ganham [BarraRolagem]
/// no lugar da barra cinza padrão. Horizontais e celular seguem o padrão.
class RolagemAurora extends MaterialScrollBehavior {
  const RolagemAurora();

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    final desktop = switch (getPlatform(context)) {
      TargetPlatform.windows || TargetPlatform.linux || TargetPlatform.macOS => true,
      _ => false,
    };
    if (!desktop || axisDirectionToAxis(details.direction) != Axis.vertical) {
      return super.buildScrollbar(context, child, details);
    }
    return BarraRolagem(child: child);
  }
}

/// Barra fina com o degradê da marca (gradIni → gradFim), sem trilho.
/// Aparece ao rolar e some depois de um tempo parada; com o mouse em cima
/// engrossa e acende. Dá para arrastar e clicar no trilho para pular uma página.
class BarraRolagem extends StatefulWidget {
  const BarraRolagem({super.key, required this.child});

  final Widget child;

  @override
  State<BarraRolagem> createState() => _BarraRolagemState();
}

const _margem = 4.0;
const _faixa = 14.0; // área de toque/arraste junto à borda
const _minimo = 36.0;

class _BarraRolagemState extends State<BarraRolagem> {
  ScrollMetrics? _m;
  ScrollPosition? _pos;
  bool _rolando = false;
  bool _emCima = false;
  bool _arrastando = false;
  Timer? _sumir;

  @override
  void dispose() {
    _sumir?.cancel();
    super.dispose();
  }

  bool _aoNotificar(Notification n) {
    final ScrollMetrics metrics;
    final BuildContext? ctx;
    if (n is ScrollNotification) {
      if (n.depth != 0) return false;
      metrics = n.metrics;
      ctx = n.context;
    } else if (n is ScrollMetricsNotification) {
      if (n.depth != 0) return false;
      metrics = n.metrics;
      ctx = n.context;
    } else {
      return false;
    }
    if (metrics.axis != Axis.vertical) return false;
    if (ctx != null) _pos = Scrollable.maybeOf(ctx)?.position ?? _pos;
    final rolou = n is ScrollUpdateNotification || n is OverscrollNotification;
    setState(() {
      _m = metrics;
      if (rolou) _rolando = true;
    });
    if (rolou) _agendarSumir();
    return false;
  }

  void _agendarSumir() {
    _sumir?.cancel();
    _sumir = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _rolando = false);
    });
  }

  ({double topo, double tamanho, double trilho})? _geometria(double altura) {
    final m = _m;
    if (m == null || !m.hasContentDimensions || m.maxScrollExtent <= m.minScrollExtent) return null;
    final trilho = altura - _margem * 2;
    if (trilho <= _minimo) return null;
    final total = m.viewportDimension + m.maxScrollExtent - m.minScrollExtent;
    final tamanho = (trilho * m.viewportDimension / total).clamp(_minimo, trilho);
    final fracao = ((m.pixels - m.minScrollExtent) / (m.maxScrollExtent - m.minScrollExtent)).clamp(0.0, 1.0);
    return (topo: _margem + (trilho - tamanho) * fracao, tamanho: tamanho, trilho: trilho);
  }

  void _arrastar(double dy, double trilho, double tamanho) {
    final pos = _pos;
    final m = _m;
    if (pos == null || m == null || trilho <= tamanho) return;
    final porPixel = (m.maxScrollExtent - m.minScrollExtent) / (trilho - tamanho);
    pos.jumpTo((pos.pixels + dy * porPixel).clamp(m.minScrollExtent, m.maxScrollExtent));
  }

  void _pularPagina(double y, double topoBarra) {
    final pos = _pos;
    final m = _m;
    if (pos == null || m == null) return;
    final passo = m.viewportDimension * 0.9 * (y < topoBarra ? -1 : 1);
    final alvo = (pos.pixels + passo).clamp(m.minScrollExtent, m.maxScrollExtent);
    final semMovimento = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (semMovimento) {
      pos.jumpTo(alvo);
    } else {
      pos.animateTo(alvo, duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final semMovimento = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final dur = semMovimento ? Duration.zero : const Duration(milliseconds: 180);
    return NotificationListener<Notification>(
      onNotification: _aoNotificar,
      child: LayoutBuilder(
        builder: (context, box) {
          final g = box.hasBoundedHeight ? _geometria(box.maxHeight) : null;
          final aceso = _emCima || _arrastando;
          final opacidade = aceso ? 1.0 : (_rolando ? 0.6 : 0.0);
          final espessura = aceso ? 8.0 : 5.0;
          return Stack(
            fit: StackFit.passthrough,
            children: [
              widget.child,
              if (g != null)
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  width: _faixa,
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _emCima = true),
                    onExit: (_) => setState(() => _emCima = false),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      dragStartBehavior: DragStartBehavior.down,
                      onVerticalDragStart: (_) => setState(() => _arrastando = true),
                      onVerticalDragUpdate: (d) => _arrastar(d.delta.dy, g.trilho, g.tamanho),
                      onVerticalDragEnd: (_) => setState(() => _arrastando = false),
                      onVerticalDragCancel: () => setState(() => _arrastando = false),
                      onTapUp: (d) {
                        final y = d.localPosition.dy;
                        if (y < g.topo || y > g.topo + g.tamanho) _pularPagina(y, g.topo);
                      },
                      child: Stack(children: [
                        Positioned(
                          top: g.topo,
                          height: g.tamanho,
                          right: 3,
                          child: IgnorePointer(
                            child: AnimatedOpacity(
                              duration: dur,
                              opacity: opacidade,
                              child: AnimatedContainer(
                                duration: dur,
                                width: espessura,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [c.gradIni, c.gradFim],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
