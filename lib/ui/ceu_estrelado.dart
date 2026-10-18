import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/tema.dart';

/// Fundo de céu noturno do Aurora: brilho de aurora bem fraco no topo,
/// estrelas fixas em três profundidades e algumas poucas cintilando devagar.
///
/// Pinta o próprio fundo (opaco), então serve de `body` em qualquer Scaffold,
/// inclusive em telas empurradas por cima de outras. No modo claro é só a cor
/// `bg`. Cartões, menu e barras continuam sólidos por cima, para o texto ficar
/// 100% legível; o céu aparece só no respiro entre eles.
///
/// Desempenho: as estrelas fixas são pintadas uma vez (só repintam ao mudar o
/// tamanho), cada camada fica num RepaintBoundary, e por quadro só se repintam
/// as ~30 que cintilam, mudando a opacidade. Sem animação com "reduzir
/// movimento" e nos testes (a cintilação nunca para e travaria o pumpAndSettle).
class CeuEstrelado extends StatefulWidget {
  const CeuEstrelado({super.key, required this.child});

  final Widget child;

  @override
  State<CeuEstrelado> createState() => _CeuEstreladoState();
}

final _emTeste = Platform.environment.containsKey('FLUTTER_TEST');

class _CeuEstreladoState extends State<CeuEstrelado> with SingleTickerProviderStateMixin {
  // Um ciclo longo; cada estrela tem a sua fase e velocidade dentro dele.
  late final _ciclo = AnimationController(vsync: this, duration: const Duration(seconds: 24));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animar = !_emTeste &&
        Theme.of(context).brightness == Brightness.dark &&
        !(MediaQuery.maybeDisableAnimationsOf(context) ?? false);
    if (animar && !_ciclo.isAnimating) {
      _ciclo.repeat();
    } else if (!animar && _ciclo.isAnimating) {
      _ciclo.stop();
    }
  }

  @override
  void dispose() {
    _ciclo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    if (Theme.of(context).brightness != Brightness.dark) {
      return ColoredBox(color: c.bg, child: widget.child);
    }
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(painter: _CeuFixo(c)),
          ),
        ),
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(painter: _Cintilantes(_ciclo, _ciclo.isAnimating)),
          ),
        ),
        widget.child,
      ],
    );
  }
}

/// Uma estrela em coordenadas de 0 a 1 (a posição acompanha o tamanho da tela).
class _Estrela {
  const _Estrela(this.x, this.y, this.raio, this.opacidade, [this.fase = 0, this.voltas = 1]);
  final double x, y, raio, opacidade;

  /// Onde, no ciclo, a estrela começa (0 a 1) e quantas vezes pisca nele.
  final double fase;
  final int voltas;
}

// Sementes fixas: o mesmo céu em todas as telas e a cada abertura.
final List<_Estrela> _fixas = () {
  final r = math.Random(1709);
  final lista = <_Estrela>[];
  // Profundidade: muitas pequenas e apagadas, poucas maiores e claras.
  void camada(int n, double raioMin, double raioMax, double opMin, double opMax) {
    for (var i = 0; i < n; i++) {
      lista.add(_Estrela(
        r.nextDouble(),
        r.nextDouble(),
        raioMin + r.nextDouble() * (raioMax - raioMin),
        opMin + r.nextDouble() * (opMax - opMin),
      ));
    }
  }

  camada(170, 0.5, 0.8, 0.3, 0.5);
  camada(70, 0.8, 1.15, 0.5, 0.7);
  camada(18, 1.2, 1.6, 0.75, 0.95);
  return lista;
}();

final List<_Estrela> _cintilantes = () {
  final r = math.Random(2610);
  return [
    for (var i = 0; i < 30; i++)
      _Estrela(r.nextDouble(), r.nextDouble(), 0.9 + r.nextDouble() * 0.7,
          0.65 + r.nextDouble() * 0.35, r.nextDouble(), 2 + r.nextInt(3)),
  ];
}();

/// Em telas pequenas mostra só parte das estrelas, para a densidade não
/// ficar maior no celular do que no computador.
int _quantas(Size s, int total) {
  final fracao = (s.width * s.height) / (1440 * 900);
  return (total * fracao.clamp(0.35, 1.0)).round();
}

class _CeuFixo extends CustomPainter {
  _CeuFixo(this.c);
  final AuroraCores c;

  @override
  void paint(Canvas canvas, Size size) {
    final tudo = Offset.zero & size;
    canvas.drawRect(tudo, Paint()..color = c.bg);

    // Brilho de aurora: verde no canto de cima à esquerda, violeta à direita.
    // Bem fraco (8% e 9%), só para o preto não ficar chapado.
    final maior = math.max(size.width, size.height);
    void brilho(Offset centro, double raio, Color cor) {
      canvas.drawRect(
        tudo,
        Paint()
          ..shader = RadialGradient(
            colors: [cor, cor.withValues(alpha: 0)],
          ).createShader(Rect.fromCircle(center: centro, radius: raio)),
      );
    }

    brilho(Offset(size.width * 0.12, -size.height * 0.08), maior * 0.55,
        c.accentFill.withValues(alpha: 0.08));
    brilho(Offset(size.width * 0.92, -size.height * 0.04), maior * 0.5,
        c.violeta.withValues(alpha: 0.09));

    final tinta = Paint();
    final n = _quantas(size, _fixas.length);
    for (var i = 0; i < n; i++) {
      final e = _fixas[i];
      tinta.color = c.text.withValues(alpha: e.opacidade);
      canvas.drawCircle(Offset(e.x * size.width, e.y * size.height), e.raio, tinta);
    }
  }

  @override
  bool shouldRepaint(_CeuFixo antigo) => antigo.c != c;
}

class _Cintilantes extends CustomPainter {
  _Cintilantes(this.ciclo, this.animando) : super(repaint: ciclo);
  final Animation<double> ciclo;
  final bool animando;

  static const _cor = Color(0xFFEDEFF8);

  @override
  void paint(Canvas canvas, Size size) {
    final tinta = Paint();
    final n = _quantas(size, _cintilantes.length);
    for (var i = 0; i < n; i++) {
      final e = _cintilantes[i];
      // Onda suave entre 25% e 100% do brilho da estrela; parada, fica no meio.
      final onda = animando
          ? 0.5 + 0.5 * math.sin(2 * math.pi * (ciclo.value * e.voltas + e.fase))
          : 0.5;
      tinta.color = _cor.withValues(alpha: e.opacidade * (0.25 + 0.75 * onda));
      canvas.drawCircle(Offset(e.x * size.width, e.y * size.height), e.raio, tinta);
    }
  }

  @override
  bool shouldRepaint(_Cintilantes antigo) => antigo.animando != animando;
}
