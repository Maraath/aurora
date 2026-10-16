import 'package:flutter/material.dart';

/// Tokens de cor do Aurora (ver CLAUDE.md). Acesse com `context.cores`.
@immutable
class AuroraCores extends ThemeExtension<AuroraCores> {
  const AuroraCores({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.line,
    required this.text,
    required this.muted,
    required this.accent,
    required this.accentFill,
    required this.accentSoft,
    required this.teal,
    required this.tealSoft,
    required this.warn,
    required this.bad,
    required this.badSoft,
  });

  final Color bg;
  final Color surface;
  final Color surface2;
  final Color line;
  final Color text;
  final Color muted;
  final Color accent;
  final Color accentFill;
  final Color accentSoft;
  final Color teal;
  final Color tealSoft;
  final Color warn;
  final Color bad;
  final Color badSoft;

  static const escuro = AuroraCores(
    bg: Color(0xFF060B18),
    surface: Color(0xFF0D1730),
    surface2: Color(0xFF16264D),
    line: Color(0xFF1F3160),
    text: Color(0xFFE9EFFC),
    muted: Color(0xFF9DACCB),
    accent: Color(0xFF6B9AF2),
    accentFill: Color(0xFF2F63D6),
    accentSoft: Color(0x296B9AF2), // 16%
    teal: Color(0xFF4FD6C3),
    tealSoft: Color(0x244FD6C3), // 14%
    warn: Color(0xFFF2B45A),
    bad: Color(0xFFF27E8C),
    badSoft: Color(0x24F27E8C), // 14%
  );

  static const claro = AuroraCores(
    bg: Color(0xFFF2F5FB),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFE6ECF8),
    line: Color(0xFFD3DBEC),
    text: Color(0xFF0A1530),
    muted: Color(0xFF4A5878),
    accent: Color(0xFF1E56C8),
    accentFill: Color(0xFF1E56C8),
    accentSoft: Color(0x1A1E56C8), // 10%
    teal: Color(0xFF0B7A6B),
    tealSoft: Color(0x1A0B7A6B),
    warn: Color(0xFF9A5B06),
    bad: Color(0xFFB92F44),
    badSoft: Color(0x1AB92F44),
  );

  @override
  AuroraCores copyWith() => this;

  @override
  AuroraCores lerp(AuroraCores? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AuroraCores(
      bg: l(bg, other.bg),
      surface: l(surface, other.surface),
      surface2: l(surface2, other.surface2),
      line: l(line, other.line),
      text: l(text, other.text),
      muted: l(muted, other.muted),
      accent: l(accent, other.accent),
      accentFill: l(accentFill, other.accentFill),
      accentSoft: l(accentSoft, other.accentSoft),
      teal: l(teal, other.teal),
      tealSoft: l(tealSoft, other.tealSoft),
      warn: l(warn, other.warn),
      bad: l(bad, other.bad),
      badSoft: l(badSoft, other.badSoft),
    );
  }
}

extension AuroraContexto on BuildContext {
  AuroraCores get cores => Theme.of(this).extension<AuroraCores>()!;
}

/// As fontes são variáveis: o peso precisa ir também como eixo `wght`.
TextStyle _fonte(String familia, double tamanho, FontWeight peso,
    {Color? cor, double? altura, double? espaco}) {
  return TextStyle(
    fontFamily: familia,
    fontSize: tamanho,
    fontWeight: peso,
    fontVariations: [FontVariation.weight(peso.value.toDouble())],
    color: cor,
    height: altura,
    letterSpacing: espaco,
  );
}

/// Sora: títulos e números de destaque.
TextStyle sora(double tamanho,
        {FontWeight peso = FontWeight.w600, Color? cor, double? altura, double? espaco}) =>
    _fonte('Sora', tamanho, peso, cor: cor, altura: altura, espaco: espaco);

/// Manrope: texto corrido, rótulos e botões.
TextStyle manrope(double tamanho,
        {FontWeight peso = FontWeight.w400, Color? cor, double? altura, double? espaco}) =>
    _fonte('Manrope', tamanho, peso, cor: cor, altura: altura, espaco: espaco);

/// Rótulo pequeno em caixa alta ("EM FOCO AGORA", "PANORAMA").
TextStyle rotulo(Color cor) => manrope(11, peso: FontWeight.w700, cor: cor, espaco: 1.3);

ThemeData temaAurora(Brightness brilho) {
  final c = brilho == Brightness.dark ? AuroraCores.escuro : AuroraCores.claro;
  final base = ThemeData(
    brightness: brilho,
    useMaterial3: true,
    fontFamily: 'Manrope',
    scaffoldBackgroundColor: c.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: c.accentFill,
      brightness: brilho,
      primary: c.accentFill,
      surface: c.surface,
      onSurface: c.text,
      error: c.bad,
    ),
    extensions: [c],
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      fontFamily: 'Manrope',
      bodyColor: c.text,
      displayColor: c.text,
    ),
    dividerColor: c.line,
  );
}
