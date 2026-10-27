import 'package:flutter/material.dart';

/// Marcador do ícone da IA para os campos `IconData` (menu, botões, busca).
/// Não é uma fonte de verdade: quem desenha ícones vindos de fora usa
/// [IconeApp], que troca o marcador pelo desenho de [IconeIa].
///
/// Sem `fontFamily` de propósito: o build release do Flutter varre os
/// `IconData` constantes atrás das famílias de fonte e avisava
/// "Expected to find fonts for (…, AuroraIconeIa)" por causa de uma família que
/// não existe (a faísca é desenhada com CustomPaint, não é glifo). O ponto
/// 0x10FFFD fica fora da faixa dos ícones do Material, então nenhum ícone real
/// se confunde com este marcador.
const iconeIa = IconData(0x10FFFD);

/// `Icon` que também sabe desenhar o ícone da IA.
class IconeApp extends StatelessWidget {
  const IconeApp(this.icone, {super.key, this.size, this.color, this.semanticLabel});

  final IconData icone;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => icone == iconeIa
      ? IconeIa(size: size, color: color, semanticLabel: semanticLabel)
      : Icon(icone, size: size, color: color, semanticLabel: semanticLabel);
}

/// Ícone da IA (Aurora): a faísca de quatro pontas com uma fita de aurora
/// correndo embaixo. Traço como o dos ícones "outlined" do Material, numa
/// grade de 24.
class IconeIa extends StatelessWidget {
  const IconeIa({super.key, this.size, this.color, this.semanticLabel});

  final double? size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tema = IconTheme.of(context);
    final lado = size ?? tema.size ?? 24;
    final cor = color ?? tema.color ?? const Color(0xFF000000);
    return Semantics(
      label: semanticLabel,
      excludeSemantics: semanticLabel == null,
      child: SizedBox.square(
        dimension: lado,
        child: CustomPaint(painter: _PintorIa(cor)),
      ),
    );
  }
}

class _PintorIa extends CustomPainter {
  _PintorIa(this.cor);

  final Color cor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);
    final p = Paint()
      ..color = cor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    // Faísca.
    canvas.drawPath(
      Path()
        ..moveTo(8, 2.5)
        ..lineTo(9.2, 6.3)
        ..lineTo(13, 7.5)
        ..lineTo(9.2, 8.7)
        ..lineTo(8, 12.5)
        ..lineTo(6.8, 8.7)
        ..lineTo(3, 7.5)
        ..lineTo(6.8, 6.3)
        ..close(),
      p,
    );
    // Fita de aurora e o eco dela embaixo.
    canvas.drawPath(
      Path()
        ..moveTo(3.5, 19)
        ..cubicTo(7, 15, 10.5, 18.5, 14, 15.5)
        ..cubicTo(17.5, 12.5, 19, 10, 20.5, 9),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(8, 21)
        ..cubicTo(10.5, 19.4, 13, 20.8, 15.5, 19.2),
      p,
    );
  }

  @override
  bool shouldRepaint(_PintorIa old) => old.cor != cor;
}
