import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../core/efeitos.dart';
import '../core/tema.dart';
import 'icone_ia.dart';

/// Uma área do menu.
class ItemMenu {
  const ItemMenu({
    required this.nome,
    required this.rotulo,
    required this.icone,
    required this.cor,
    required this.aoTocar,
    this.ativo = false,
  });

  /// Nome em pé no pilar e na cortina ao abrir ("Conta").
  final String nome;

  /// Nome para o leitor de tela e os testes ("Conta e sincronização").
  final String rotulo;
  final IconData icone;

  /// Cor da área: um toque dela na aurora do pilar e no brilho da tela aberta.
  final Color cor;
  final VoidCallback aoTocar;
  final bool ativo;
}

final _emTeste = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

Future<ui.FragmentProgram?>? _programa;

/// O shader é carregado uma vez por execução. Se falhar, os pilares ficam com um
/// degradê parado, sem quebrar o menu.
Future<ui.FragmentProgram?> _carregarPrograma() =>
    _programa ??= ui.FragmentProgram.fromAsset('shaders/aurora_menu.frag').then<ui.FragmentProgram?>(
      (p) => p,
      onError: (Object e) {
        debugPrint('Pilares sem shader: $e');
        return null;
      },
    );

/// O que a aurora precisa a cada quadro. O estado atualiza e avisa; só o pintor
/// repinta (nada de rebuild da árvore por quadro).
class _Cena extends ChangeNotifier {
  double tempo = 40;
  double mx = -999;
  double my = -999;
  double forcaMouse = 0;
  List<Rect> lugares = const [];
  List<Color> cores = const [];
  List<double> forcas = const [];
  int ativo = 0;

  void avisar() => notifyListeners();
}

/// Menu do computador em PILARES DE AURORA (03/11/2026; protótipo aprovado em
/// `docs/prototipo/cortinas.html`): cada área é um pilar da altura inteira da
/// janela e a área aberta fica no meio deles, com os pilares divididos dos dois
/// lados. UMA aurora (`shaders/aurora_menu.frag`) atravessa a janela: forte nos
/// pilares, fraca nos vãos e quase nada sobre a área aberta. Ao trocar de área,
/// o pilar cresce até o meio, a aurora sobe como uma cortina grande com o nome
/// da área e se recolhe deixando a tela. Com o mouse num pilar, a aurora ondula
/// em volta do ponteiro e o vidro acende na cor da área.
///
/// Balança sozinha a 15 quadros/s (timer, como o céu); quadro a quadro só com o
/// mouse num pilar ou numa troca. Para com a janela em segundo plano; parada em
/// Efeitos leves e "reduzir movimento"; nos testes sem shader (degradê).
class PilaresAurora extends StatefulWidget {
  const PilaresAurora({super.key, required this.itens, required this.child});

  /// Até 8 áreas, na ordem da esquerda para a direita; uma com `ativo`.
  final List<ItemMenu> itens;

  /// A tela da área aberta.
  final Widget child;

  @override
  State<PilaresAurora> createState() => _PilaresAuroraState();
}

const _intervaloLento = Duration(milliseconds: 66);
const _raio = 24.0;

class _PilaresAuroraState extends State<PilaresAurora> with TickerProviderStateMixin {
  final _cena = _Cena();
  final _relogio = Stopwatch();
  late final Ticker _ticker = createTicker(_aoQuadro);
  late final _troca = AnimationController(vsync: this, duration: const Duration(milliseconds: 900), value: 1);
  late final _vida = AppLifecycleListener(onStateChange: (_) => _ajustar());
  late final Future<ui.FragmentProgram?>? _futuro = _emTeste ? null : _carregarPrograma();
  Timer? _timer;
  Duration? _ultimo;
  bool _animar = false;
  int? _pairando;
  late int _ativo = _indiceAtivo;
  late int _deAtivo = _ativo;
  late List<double> _forcas = List.filled(widget.itens.length, 0);

  int get _indiceAtivo => math.max(0, widget.itens.indexWhere((i) => i.ativo));
  bool get _semMovimento => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  @override
  void initState() {
    super.initState();
    _vida; // começa a ouvir o ciclo de vida do app
    _troca.addListener(_ajustar);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animar = !_emTeste && !EscopoEfeitos.leves(context) && !_semMovimento;
    _ajustar();
  }

  @override
  void didUpdateWidget(PilaresAurora antigo) {
    super.didUpdateWidget(antigo);
    if (_forcas.length != widget.itens.length) _forcas = List.filled(widget.itens.length, 0);
    final novo = _indiceAtivo;
    if (novo != _ativo) {
      _deAtivo = _ativo;
      _ativo = novo;
      if (_semMovimento || _emTeste) {
        _troca.value = 1;
      } else {
        _troca.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ticker.dispose();
    _troca.dispose();
    _vida.dispose();
    _cena.dispose();
    super.dispose();
  }

  bool get _mexendo => _pairando != null || _forcas.any((f) => f > .01) || _troca.isAnimating;

  void _ajustar() {
    final estado = SchedulerBinding.instance.lifecycleState;
    final visivel = estado == null || estado == AppLifecycleState.resumed;
    final ligar = visivel && (_animar || _troca.isAnimating);
    final rapido = ligar && _mexendo;
    if (ligar && _animar) {
      _relogio.start();
    } else {
      _relogio.stop();
    }
    if (ligar && _animar && !rapido) {
      _timer ??= Timer.periodic(_intervaloLento, (_) => _passo(_intervaloLento.inMicroseconds / 1e6));
    } else {
      _timer?.cancel();
      _timer = null;
    }
    if (rapido && !_ticker.isActive) {
      _ultimo = null;
      _ticker.start();
    } else if (!rapido && _ticker.isActive) {
      _ticker.stop();
    }
  }

  void _aoQuadro(Duration agora) {
    final dt = _ultimo == null ? .016 : math.min((agora - _ultimo!).inMicroseconds / 1e6, .05);
    _ultimo = agora;
    _passo(dt);
    if (!_mexendo) _ajustar();
  }

  void _passo(double dt) {
    final k = 1 - math.exp(-dt * 6);
    for (var i = 0; i < _forcas.length; i++) {
      final alvo = i == _pairando ? 1.0 : 0.0;
      _forcas[i] += (alvo - _forcas[i]) * k;
      if ((_forcas[i] - alvo).abs() < .005) _forcas[i] = alvo;
    }
    _cena
      ..tempo = 40 + _relogio.elapsedMicroseconds / 1e6
      ..forcas = _forcasDaCena()
      ..forcaMouse = _forcas.fold<double>(0, math.max)
      ..avisar();
  }

  void _pairar(int i, bool sim) {
    final novo = sim ? i : (_pairando == i ? null : _pairando);
    if (novo == _pairando) return;
    setState(() => _pairando = novo);
    if (_animar) {
      _ajustar();
    } else {
      // Sem animação: acende parado.
      for (var j = 0; j < _forcas.length; j++) {
        _forcas[j] = j == _pairando ? 1 : 0;
      }
      _passo(0);
    }
  }

  /// Medidas conforme a janela: pilares mais finos em janelas menores.
  ({double largura, double vao}) _medidas(double janela) => janela >= 1400
      ? (largura: 50.0, vao: 9.0)
      : janela >= 1100
          ? (largura: 44.0, vao: 8.0)
          : (largura: 36.0, vao: 6.0);

  List<Rect> _layout(Size s, int ativo, double topo) {
    final n = widget.itens.length;
    final (:largura, :vao) = _medidas(s.width);
    const margem = 12.0;
    final painel = s.width - 2 * margem - (n - 1) * (largura + vao);
    final altura = math.max(0.0, s.height - topo - margem);
    var x = margem;
    final r = <Rect>[];
    for (var i = 0; i < n; i++) {
      final w = i == ativo ? painel : largura;
      r.add(Rect.fromLTWH(x, topo, w, altura));
      x += w + vao;
    }
    return r;
  }

  static double _suave(double t) => t < .5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3) / 2;

  /// Força da aurora em cada lugar: pilar 1 (mais com o mouse); a área aberta
  /// quase apaga, menos na abertura (cortina grande); a que deixou de ser a
  /// aberta acende enquanto encolhe.
  List<double> _forcasDaCena() {
    const fundoPainel = .06;
    final t = _troca.value;
    final abrindo = _troca.isAnimating || t < 1;
    final cortina = !abrindo ? 0.0 : (t < .45 ? t / .45 * 1.6 : 1.6 * (1 - (t - .45) / .55));
    return [
      for (var i = 0; i < widget.itens.length; i++)
        if (i == _ativo)
          fundoPainel + cortina
        else if (abrindo && i == _deAtivo)
          fundoPainel + (1 - fundoPainel) * _suave(t)
        else
          1 + .45 * _forcas[i],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final topo = MediaQuery.paddingOf(context).top + 8;
    final itens = widget.itens;

    return FutureBuilder<ui.FragmentProgram?>(
      future: _futuro,
      builder: (context, snap) => LayoutBuilder(
        builder: (context, box) {
          final tamanho = box.biggest;
          final destino = _layout(tamanho, _ativo, topo);
          return MouseRegion(
            onHover: (e) {
              if (_pairando == null) return;
              _cena
                ..mx = e.localPosition.dx
                ..my = e.localPosition.dy;
            },
            child: AnimatedBuilder(
              animation: _troca,
              builder: (context, _) {
                final t = _troca.value;
                final e = _suave(t);
                final origem = t < 1 ? _layout(tamanho, _deAtivo, topo) : destino;
                final lugares = [for (var i = 0; i < itens.length; i++) Rect.lerp(origem[i], destino[i], e)!];
                _cena
                  ..lugares = lugares
                  ..cores = [for (final i in itens) i.cor]
                  ..ativo = _ativo
                  ..forcas = _forcasDaCena()
                  // Repinta a aurora com os lugares novos (layout, sem rebuild).
                  ..avisar();
                final painel = destino[_ativo];
                final conteudo = t >= 1 ? 1.0 : ((t - .55) / .3).clamp(0.0, 1.0);
                final nome = t >= 1
                    ? 0.0
                    : t < .25
                        ? 0.0
                        : t < .5
                            ? (t - .25) / .25
                            : t < .8
                                ? 1.0
                                : 1 - (t - .8) / .2;
                final corAtiva = itens[_ativo].cor;
                return Stack(
                  children: [
                    // A área aberta: vidro leve com o brilho da cor da área no alto.
                    Positioned.fromRect(
                      rect: painel,
                      child: _Painel(cor: corAtiva, escuro: escuro, opacidade: conteudo, child: widget.child),
                    ),
                    // A aurora por cima de tudo (só luz, não pega clique).
                    Positioned.fill(
                      child: IgnorePointer(
                        child: RepaintBoundary(
                          child: CustomPaint(
                            painter: _PintorAurora(
                              programa: snap.data,
                              cena: _cena,
                              escuro: escuro,
                              fundo: escuro ? .26 : .18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    for (var i = 0; i < itens.length; i++)
                      if (i != _ativo)
                        Positioned.fromRect(
                          // Chave por área: sem ela, ao trocar, o Flutter reaproveita
                          // o pilar clicado (com o efeito do toque) para outra área.
                          key: ValueKey(itens[i].rotulo),
                          rect: lugares[i],
                          child: _Pilar(
                            item: itens[i],
                            pairando: _pairando == i,
                            aoPairar: (sim) => _pairar(i, sim),
                            cores: c,
                            escuro: escuro,
                          ),
                        ),
                    // A área aberta segue no menu para o leitor de tela (e para os
                    // testes): um ponto invisível no canto da tela aberta.
                    Positioned(
                      left: painel.left + 6,
                      top: painel.top + 6,
                      width: 28,
                      height: 28,
                      child: Semantics(
                        button: true,
                        selected: true,
                        label: itens[_ativo].rotulo,
                        excludeSemantics: true,
                        child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: itens[_ativo].aoTocar),
                      ),
                    ),
                    // O nome grande na cortina, enquanto ela abre.
                    // Fica no lugar final (o pilar ainda está crescendo) e encolhe a
                    // letra se o nome não couber.
                    if (nome > 0)
                      Positioned.fromRect(
                        rect: painel.deflate(24),
                        child: IgnorePointer(
                          child: Center(
                            child: Opacity(
                              opacity: nome,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                itens[_ativo].nome.toUpperCase(),
                                maxLines: 1,
                                softWrap: false,
                                style: sora(
                                  56,
                                  peso: FontWeight.w700,
                                  cor: Colors.white,
                                  espaco: 3 + 6 * nome,
                                ).copyWith(
                                  shadows: [
                                    Shadow(color: corAtiva, blurRadius: 40),
                                    Shadow(color: Colors.white.withValues(alpha: .6), blurRadius: 2),
                                  ],
                                ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// A área aberta: vidro leve, cantos redondos, brilho da cor da área no alto.
class _Painel extends StatelessWidget {
  const _Painel({required this.cor, required this.escuro, required this.opacidade, required this.child});

  final Color cor;
  final bool escuro;
  final double opacidade;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: (escuro ? Colors.white : Colors.black).withValues(alpha: .07)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: escuro
                ? [const Color(0xFF18173A).withValues(alpha: .42), const Color(0xFF0F0E26).withValues(alpha: .30)]
                : [c.surface.withValues(alpha: .72), c.surface.withValues(alpha: .55)],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-.4, -1.2),
                    radius: 1.0,
                    colors: [cor.withValues(alpha: escuro ? .16 : .08), cor.withValues(alpha: 0)],
                  ),
                ),
              ),
            ),
            // O conteúdo começa logo abaixo da borda do painel (a faixa da
            // moldura da janela já ficou fora dele).
            Opacity(
              opacity: opacidade,
              child: MediaQuery.removePadding(context: context, removeTop: true, child: child),
            ),
          ],
        ),
      ),
    );
  }
}

/// Um pilar: vidro quase invisível (a luz da aurora é que o desenha), ícone no
/// alto e o nome em pé.
class _Pilar extends StatelessWidget {
  const _Pilar({
    required this.item,
    required this.pairando,
    required this.aoPairar,
    required this.cores,
    required this.escuro,
  });

  final ItemMenu item;
  final bool pairando;
  final ValueChanged<bool> aoPairar;
  final AuroraCores cores;
  final bool escuro;

  @override
  Widget build(BuildContext context) {
    final c = cores;
    final cor = item.cor;
    final vidro = escuro ? Colors.white : Colors.black;
    final cantos = BorderRadius.circular(_raio);
    final sombra = [Shadow(color: c.bg.withValues(alpha: .9), blurRadius: 12)];
    return Semantics(
      button: true,
      selected: false,
      label: item.rotulo,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        decoration: BoxDecoration(
          borderRadius: cantos,
          border: Border.all(
            color: pairando ? Color.lerp(cor, vidro, .55)!.withValues(alpha: .55) : vidro.withValues(alpha: .07),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [vidro.withValues(alpha: .05), vidro.withValues(alpha: 0), vidro.withValues(alpha: 0), vidro.withValues(alpha: .025)],
            stops: const [0, .18, .85, 1],
          ),
          boxShadow: pairando ? [BoxShadow(color: cor.withValues(alpha: .35), blurRadius: 30, spreadRadius: -6)] : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: cantos,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: item.aoTocar,
            onHover: aoPairar,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: cor.withValues(alpha: .18),
            focusColor: cor.withValues(alpha: .14),
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  AnimatedScale(
                    scale: pairando ? 1.12 : 1,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutBack,
                    child: IconeApp(item.icone, size: 20, color: Color.lerp(cor, c.text, pairando ? .45 : .15)),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          item.nome.toUpperCase(),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: sora(11.5, peso: FontWeight.w600, cor: Color.lerp(cor, c.text, pairando ? .6 : .3), espaco: 2.4)
                              .copyWith(shadows: sombra),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PintorAurora extends CustomPainter {
  _PintorAurora({required this.programa, required this.cena, required this.escuro, required this.fundo})
      : super(repaint: cena);

  final ui.FragmentProgram? programa;
  final _Cena cena;
  final bool escuro;
  final double fundo;

  static final _shaders = Expando<ui.FragmentShader>();

  @override
  void paint(Canvas canvas, Size size) {
    final p = programa;
    if (p == null) {
      _reserva(canvas);
      return;
    }
    final s = _shaders[p] ??= p.fragmentShader();
    var i = 0;
    void f(double v) => s.setFloat(i++, v);
    f(size.width);
    f(size.height);
    f(cena.tempo);
    f(cena.mx);
    f(cena.my);
    f(cena.forcaMouse);
    f(fundo);
    f(escuro ? 1 : 0);
    f(cena.ativo.toDouble());
    for (var k = 0; k < 8; k++) {
      final r = k < cena.lugares.length ? cena.lugares[k] : Rect.zero;
      f(r.left);
      f(r.top);
      f(r.width);
      f(r.height);
    }
    for (var k = 0; k < 8; k++) {
      final tem = k < cena.cores.length && k < cena.forcas.length;
      final cor = tem ? cena.cores[k] : Colors.black;
      f(cor.r);
      f(cor.g);
      f(cor.b);
      f(tem ? cena.forcas[k] : 0);
    }
    canvas.drawRect(Offset.zero & size, Paint()..shader = s);
  }

  /// Sem shader: um degradê parado dentro de cada pilar.
  void _reserva(Canvas canvas) {
    for (var k = 0; k < cena.lugares.length && k < cena.cores.length; k++) {
      if (k == cena.ativo) continue;
      final r = cena.lugares[k];
      final cor = cena.cores[k];
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(_raio)),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [cor.withValues(alpha: .10), cor.withValues(alpha: escuro ? .30 : .18), cor.withValues(alpha: 0)],
            stops: const [0, .62, .9],
          ).createShader(r),
      );
    }
  }

  @override
  bool shouldRepaint(_PintorAurora old) => old.programa != programa || old.escuro != escuro || old.fundo != fundo;
}
