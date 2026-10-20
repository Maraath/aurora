import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../core/tema.dart';
import 'icone_ia.dart';

/// Um item do dock lateral.
class ItemDock {
  const ItemDock({
    required this.icone,
    required this.rotulo,
    required this.aoTocar,
    this.ativo = false,
    this.espacoAntes = 0,
  });

  final IconData icone;
  final String rotulo;
  final VoidCallback aoTocar;
  final bool ativo;

  /// Espaço extra antes do item (separa os grupos).
  final double espacoAntes;
}

/// Menu lateral em "dock": os ícones perto do ponteiro crescem até 32% com física de mola
/// (rigidez 200, amortecimento 26, massa 1), se afastam 10 px para a direita e
/// abrem espaço entre si; o nome aparece ao lado depois de 40 ms; uma barrinha
/// marca o item ativo; o clique dá um "pulo" curto. Cores do Aurora.
/// Com "reduzir movimento" do sistema, tudo responde sem animar.
class MenuDock extends StatefulWidget {
  const MenuDock({super.key, required this.itens, this.largura = 72});
  final List<ItemDock> itens;
  final double largura;

  @override
  State<MenuDock> createState() => _MenuDockState();
}

class _MenuDockState extends State<MenuDock> with SingleTickerProviderStateMixin {
  // Medidas e física do dock.
  static const _tamanho = 40.0;
  static const _vao = 8.0;
  static const _escalaMax = 1.32;
  static const _influencia = 48.0;
  static const _desloca = 10.0;
  static const _abre = 0.3;
  static const _rigidez = 200.0;
  static const _amortece = 26.0;
  static const _icone = 0.55;
  static const _pulo = 0.55;
  static const _limiarRotulo = 0.2;
  static const _atrasoRotulo = Duration(milliseconds: 40);
  static const _afastaRotulo = 12.0;

  late final Ticker _ticker = createTicker(_quadro);
  Duration? _anterior;
  double? _ponteiro;
  int? _focado;

  // Estado de cada item: ampliação (m) e "pulo" do clique, com as velocidades.
  List<double> _m = [], _v = [], _pop = [], _popV = [];

  // Barrinha do ativo: também anda com mola.
  double? _barraY;
  double _barraV = 0;

  int? _comRotulo;
  Duration _rotuloDesde = Duration.zero;
  Duration _agora = Duration.zero;

  final _portal = OverlayPortalController();
  final _ancora = LayerLink();

  @override
  void initState() {
    super.initState();
    _ajustar();
  }

  @override
  void didUpdateWidget(MenuDock antigo) {
    super.didUpdateWidget(antigo);
    if (antigo.itens.length != widget.itens.length) _ajustar();
    _acordar();
  }

  void _ajustar() {
    final n = widget.itens.length;
    _m = List.filled(n, 0);
    _v = List.filled(n, 0);
    _pop = List.filled(n, 0);
    _popV = List.filled(n, 0);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  bool get _semMovimento => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// Centros em repouso (sem ampliação), relativos ao topo do dock.
  List<double> get _centrosRepouso {
    final centros = <double>[];
    var y = 0.0;
    for (var i = 0; i < widget.itens.length; i++) {
      if (i > 0) y += _vao + widget.itens[i].espacoAntes;
      centros.add(y + _tamanho / 2);
      y += _tamanho;
    }
    return centros;
  }

  double get _alturaRepouso {
    final c = _centrosRepouso;
    return c.isEmpty ? 0 : c.last + _tamanho / 2;
  }

  void _acordar() {
    if (!_ticker.isActive) {
      _anterior = null;
      _ticker.start();
    }
  }

  void _quadro(Duration agora) {
    _agora = agora;
    final dt = _anterior == null ? 0.016 : math.min((agora - _anterior!).inMicroseconds / 1e6, 0.05);
    _anterior = agora;
    final centros = _centrosRepouso;
    final alvoY = _ponteiro ?? (_focado == null ? null : centros[_focado!]);
    var mexendo = false;

    for (var i = 0; i < _m.length; i++) {
      var alvo = 0.0;
      if (alvoY != null) {
        final z = (alvoY - centros[i]).abs() / _influencia;
        alvo = z >= 1 ? 0 : 1 - z; // queda linear
      }
      if (_semMovimento) {
        _m[i] = alvo;
        _v[i] = 0;
        _pop[i] = 0;
        _popV[i] = 0;
        continue;
      }
      // Integra a mola em passos de 4 ms (estável mesmo com quadros lentos).
      final passos = math.max(1, (dt / 0.004).ceil());
      final h = dt / passos;
      for (var p = 0; p < passos; p++) {
        final a = -_rigidez * (_m[i] - alvo) - _amortece * _v[i];
        _v[i] += a * h;
        _m[i] += _v[i] * h;
        final ap = -620 * _pop[i] - 34 * _popV[i];
        _popV[i] += ap * h;
        _pop[i] += _popV[i] * h;
      }
      if (_m[i] < 0 && _v[i] < 0) {
        _m[i] = 0;
        _v[i] = 0;
      }
      if ((_m[i] - alvo).abs() > .0015 || _v[i].abs() > .0015 || _pop[i].abs() > .0015) mexendo = true;
    }

    // Barrinha do ativo segue o centro vivo do item com uma mola mais firme.
    final vivo = _layout().centros;
    final ativo = widget.itens.indexWhere((x) => x.ativo);
    if (ativo >= 0) {
      final alvoBarra = vivo[ativo];
      if (_barraY == null || _semMovimento) {
        _barraY = alvoBarra;
        _barraV = 0;
      } else {
        final a = -320 * (_barraY! - alvoBarra) - 32 * _barraV;
        _barraV += a * dt;
        _barraY = _barraY! + _barraV * dt;
        if ((_barraY! - alvoBarra).abs() > .1 || _barraV.abs() > .1) mexendo = true;
      }
    }

    // Rótulo: o item mais ampliado, depois de 40 ms acima do limiar.
    var maior = -1;
    var mMaior = 0.0;
    for (var i = 0; i < _m.length; i++) {
      if (_m[i] > mMaior) {
        mMaior = _m[i];
        maior = i;
      }
    }
    final candidato = mMaior > _limiarRotulo ? maior : null;
    if (candidato != _comRotulo) {
      _comRotulo = candidato;
      _rotuloDesde = agora;
    }
    if (_comRotulo != null) {
      _portal.show();
      if (agora - _rotuloDesde < _atrasoRotulo) mexendo = true;
    } else {
      _portal.hide();
    }

    setState(() {});
    // Parado (mesmo com o mouse em cima) o ticker desliga: antes ele seguia
    // pedindo quadro a cada vsync (144 por segundo) só por o mouse estar no
    // menu. Mexer o mouse ou mudar o foco acorda de novo.
    if (!mexendo) _ticker.stop();
  }

  /// Tamanhos e centros vivos: cada item cresce
  /// com a ampliação, o vão entre vizinhos abre um pouco, e o conjunto cresce
  /// para cima e para baixo a partir do centro.
  ({List<double> tamanhos, List<double> centros}) _layout() {
    final n = widget.itens.length;
    final tamanhos = [for (var i = 0; i < n; i++) _tamanho * (1 + (_escalaMax - 1) * _m[i])];
    var total = 0.0;
    for (var i = 0; i < n; i++) {
      if (i > 0) total += _vao + _vao * _abre * math.max(_m[i], _m[i - 1]) + widget.itens[i].espacoAntes;
      total += tamanhos[i];
    }
    var y = (_alturaRepouso - total) / 2;
    final centros = <double>[];
    for (var i = 0; i < n; i++) {
      if (i > 0) y += _vao + _vao * _abre * math.max(_m[i], _m[i - 1]) + widget.itens[i].espacoAntes;
      centros.add(y + tamanhos[i] / 2);
      y += tamanhos[i];
    }
    return (tamanhos: tamanhos, centros: centros);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final (:tamanhos, :centros) = _layout();
    final meio = widget.largura / 2;
    final ativo = widget.itens.indexWhere((x) => x.ativo);
    if (_barraY == null && ativo >= 0) WidgetsBinding.instance.addPostFrameCallback((_) => _acordar());

    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: (context) => _rotulo(context, tamanhos, centros),
      child: CompositedTransformTarget(
        link: _ancora,
        child: MouseRegion(
          onHover: (e) {
            _ponteiro = e.localPosition.dy;
            _acordar();
          },
          onExit: (_) {
            _ponteiro = null;
            _acordar();
          },
          child: SizedBox(
            width: widget.largura,
            height: _alturaRepouso,
            child: Stack(clipBehavior: Clip.none, children: [
              // Barrinha do ativo, colada à esquerda.
              if (ativo >= 0 && _barraY != null)
                Positioned(
                  left: 0,
                  top: _barraY! - math.max(10, tamanhos[ativo] * .42) / 2,
                  child: Container(
                    width: 3,
                    height: math.max(10, tamanhos[ativo] * .42),
                    decoration: BoxDecoration(
                      color: c.accent,
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(3)),
                      boxShadow: [BoxShadow(color: c.accent.withValues(alpha: .35), blurRadius: 6)],
                    ),
                  ),
                ),
              for (var i = 0; i < widget.itens.length; i++)
                _item(context, i, tamanhos[i], centros[i], meio),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, int i, double tamanho, double centro, double meio) {
    final c = context.cores;
    final item = widget.itens[i];
    final m = _m[i].clamp(0.0, 1.0);
    final pulo = 1 - .14 * _pulo * math.max(0, _pop[i]);
    final lado = tamanho * pulo;
    // Tinta do ícone: apagada em repouso, acesa quando o ponteiro chega perto.
    final repouso = item.ativo ? .85 : .55;
    final tinta = repouso + (1 - repouso) * m;
    final corIcone = item.ativo ? c.accent : Color.lerp(c.muted, c.text, m)!;

    return Positioned(
      left: meio - lado / 2 + _desloca * m,
      top: centro - lado / 2,
      width: lado,
      height: lado,
      child: Semantics(
        button: true,
        selected: item.ativo,
        label: item.rotulo,
        child: Focus(
          onFocusChange: (f) {
            _focado = f ? i : (_focado == i ? null : _focado);
            _acordar();
          },
          onKeyEvent: (_, e) => KeyEventResult.ignored,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) {
              _pop[i] = 1;
              _popV[i] = 0;
              _acordar();
            },
            onTap: item.aoTocar,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.ativo
                      ? c.accentSoft
                      : Color.lerp(Colors.transparent, c.surface2, m),
                  boxShadow: m > .01
                      ? [
                          BoxShadow(color: c.accent.withValues(alpha: .26 * .4 * m), blurRadius: 14 * m),
                          BoxShadow(
                              color: Colors.black.withValues(alpha: .25 * m),
                              blurRadius: 5 * m,
                              offset: Offset(0, 3 * m)),
                        ]
                      : null,
                ),
                child: Center(
                  child: Opacity(
                    opacity: tinta.clamp(0.0, 1.0),
                    child: IconeApp(item.icone, size: 21 * (1 + (_escalaMax - 1) * m * _icone), color: corIcone),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Nome do item ampliado, ao lado do dock (por cima do conteúdo).
  Widget _rotulo(BuildContext context, List<double> tamanhos, List<double> centros) {
    final i = _comRotulo;
    if (i == null || i >= centros.length) return const SizedBox.shrink();
    final c = context.cores;
    final m = _m[i].clamp(0.0, 1.0);
    final pronto = _agora - _rotuloDesde >= _atrasoRotulo;
    final opacidade = pronto ? ((m - _limiarRotulo) / (1 - _limiarRotulo)).clamp(0.0, 1.0) : 0.0;
    final x = widget.largura / 2 + _desloca * m + tamanhos[i] / 2 + _afastaRotulo;
    return Align(
      alignment: Alignment.topLeft,
      child: CompositedTransformFollower(
        link: _ancora,
        showWhenUnlinked: false,
        offset: Offset(x, centros[i]),
        followerAnchor: Alignment.centerLeft,
        child: IgnorePointer(
          child: Opacity(
            opacity: opacidade,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: c.line),
                boxShadow: sombraCartao(context),
              ),
              child: Text(widget.itens[i].rotulo, style: manrope(13, peso: FontWeight.w600, cor: c.text)),
            ),
          ),
        ),
      ),
    );
  }
}
