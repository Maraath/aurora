import 'package:flutter/material.dart';

/// Tokens de cor do Aurora: paleta "Aurora completa" (ver CLAUDE.md).
/// Acesse com `context.cores`.
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
    required this.noAccent,
    required this.gradIni,
    required this.gradFim,
    required this.violeta,
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

  /// Preenchimento sólido (marcadores, balões); o botão principal usa [gradiente].
  final Color accentFill;
  final Color accentSoft;

  /// Texto e ícones sobre [accentFill], [gradiente] e [teal].
  final Color noAccent;
  final Color gradIni;
  final Color gradFim;

  /// Nitrogênio da aurora: assistente e destaques secundários.
  final Color violeta;
  final Color teal;
  final Color tealSoft;
  final Color warn;
  final Color bad;
  final Color badSoft;

  /// Verde → violeta, como a aurora sobe no céu. Só no botão principal.
  LinearGradient get gradiente => LinearGradient(colors: [gradIni, gradFim]);

  static const escuro = AuroraCores(
    bg: Color(0xFF080716),
    surface: Color(0xFF0F0E26),
    surface2: Color(0xFF18173A),
    line: Color(0xFF232250),
    text: Color(0xFFEEF0FB),
    muted: Color(0xFFA3A6C8),
    accent: Color(0xFF5CF0B0),
    accentFill: Color(0xFF3EDB9A),
    accentSoft: Color(0x295CF0B0), // 16%
    noAccent: Color(0xFF06061A),
    gradIni: Color(0xFF3EDB9A),
    gradFim: Color(0xFF7E7BFF),
    violeta: Color(0xFF9D8CFF),
    teal: Color(0xFF42E3C8),
    tealSoft: Color(0x2442E3C8), // 14%
    warn: Color(0xFFF5C35B),
    bad: Color(0xFFE77BFF),
    badSoft: Color(0x24E77BFF), // 14%
  );

  static const claro = AuroraCores(
    bg: Color(0xFFF4F3FB),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFE9E8F6),
    line: Color(0xFFD6D4EA),
    text: Color(0xFF0D0B26),
    muted: Color(0xFF55557A),
    accent: Color(0xFF0B8A5C),
    accentFill: Color(0xFF0B8A5C),
    accentSoft: Color(0x1A0B8A5C), // 10%
    noAccent: Color(0xFFFFFFFF),
    gradIni: Color(0xFF0B8A5C),
    gradFim: Color(0xFF5B45D6),
    violeta: Color(0xFF5B45D6),
    teal: Color(0xFF0A7C70),
    tealSoft: Color(0x1A0A7C70),
    warn: Color(0xFF9A5B06),
    bad: Color(0xFFA8259A),
    badSoft: Color(0x1AA8259A),
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
      noAccent: l(noAccent, other.noAccent),
      gradIni: l(gradIni, other.gradIni),
      gradFim: l(gradFim, other.gradFim),
      violeta: l(violeta, other.violeta),
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
      onPrimary: c.noAccent,
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
