import 'package:flutter/material.dart';

import '../core/tema.dart';

/// Cartão padrão: superfície com borda fina e cantos arredondados.
class Cartao extends StatelessWidget {
  const Cartao({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.raio = 20,
    this.aoTocar,
    this.cor,
    this.borda = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double raio;
  final VoidCallback? aoTocar;
  final Color? cor;
  final bool borda;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final forma = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(raio),
      side: borda ? BorderSide(color: c.line) : BorderSide.none,
    );
    return Material(
      color: cor ?? c.surface,
      shape: forma,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: aoTocar,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Botão principal (pílula azul) e secundário (contorno).
class BotaoPilula extends StatelessWidget {
  const BotaoPilula({
    super.key,
    required this.texto,
    required this.aoTocar,
    this.principal = true,
  });

  final String texto;
  final VoidCallback aoTocar;
  final bool principal;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Material(
      color: principal ? c.accentFill : Colors.transparent,
      shape: StadiumBorder(
          side: principal ? BorderSide.none : BorderSide(color: c.line)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: aoTocar,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Center(
            widthFactor: 1,
            child: Text(
              texto,
              style: manrope(14,
                  peso: principal ? FontWeight.w700 : FontWeight.w600,
                  cor: principal ? Colors.white : c.text),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botão redondo de 44 px com ícone (assistente, tema, "+").
class BotaoRedondo extends StatelessWidget {
  const BotaoRedondo({
    super.key,
    required this.icone,
    required this.dica,
    required this.aoTocar,
    this.ativo = false,
    this.preenchido = false,
  });

  final IconData icone;
  final String dica;
  final VoidCallback aoTocar;
  final bool ativo;
  final bool preenchido;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final Color fundo = preenchido ? c.accentFill : (ativo ? c.accentSoft : c.surface);
    final Color frente = preenchido ? Colors.white : (ativo ? c.accent : c.text);
    return Tooltip(
      message: dica,
      child: Material(
        color: fundo,
        shape: CircleBorder(
          side: preenchido ? BorderSide.none : BorderSide(color: ativo ? c.accent : c.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icone, size: 20, color: frente, semanticLabel: dica),
          ),
        ),
      ),
    );
  }
}

/// Controle segmentado (Próximos | Recorrentes), como no protótipo.
class Segmentos<T> extends StatelessWidget {
  const Segmentos({
    super.key,
    required this.opcoes,
    required this.selecionado,
    required this.rotulo,
    required this.aoEscolher,
  });

  final List<T> opcoes;
  final T selecionado;
  final String Function(T) rotulo;
  final ValueChanged<T> aoEscolher;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          for (final o in opcoes)
            Expanded(
              child: Semantics(
                selected: o == selecionado,
                button: true,
                child: Material(
                  color: o == selecionado ? c.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => aoEscolher(o),
                    child: SizedBox(
                      height: 40,
                      child: Center(
                        child: Text(
                          rotulo(o),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: manrope(13,
                              peso: FontWeight.w700,
                              cor: o == selecionado ? c.text : c.muted),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Contador do topo das telas (atrasadas / abertas / feitas hoje).
class Contador extends StatelessWidget {
  const Contador({super.key, required this.valor, required this.rotulo, this.cor, this.fundo});
  final String valor;
  final String rotulo;
  final Color? cor;
  final Color? fundo;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fundo ?? c.surface,
        borderRadius: BorderRadius.circular(14),
        border: fundo == null ? Border.all(color: c.line) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(valor, style: sora(22, cor: cor ?? c.text)),
          const SizedBox(height: 2),
          Text(rotulo,
              style: manrope(12, cor: fundo == null ? c.muted : c.text),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

/// Linha de três contadores com espaço igual.
class LinhaContadores extends StatelessWidget {
  const LinhaContadores(this.contadores, {super.key});
  final List<Contador> contadores;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          for (var i = 0; i < contadores.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: contadores[i]),
          ],
        ],
      );
}

/// Rótulo de seção em caixa alta ("RESOLVER AGORA").
class TituloSecao extends StatelessWidget {
  const TituloSecao(this.texto, {super.key, this.direita});
  final String texto;
  final Widget? direita;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Expanded(child: Text(texto.toUpperCase(), style: rotulo(c.muted))),
        ?direita,
      ]),
    );
  }
}

/// Texto de lista vazia.
class Vazio extends StatelessWidget {
  const Vazio(this.texto, {super.key});
  final String texto;

  @override
  Widget build(BuildContext context) => Cartao(
        raio: 16,
        padding: const EdgeInsets.all(16),
        child: Text(texto, style: manrope(14, cor: context.cores.muted, altura: 1.4)),
      );
}

/// Círculo de concluir: vazio quando pendente, verde-água com ✓ quando feito.
class MarcaConcluir extends StatelessWidget {
  const MarcaConcluir({super.key, required this.feito});
  final bool feito;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: feito ? c.teal : Colors.transparent,
        border: Border.all(color: feito ? c.teal : c.muted, width: 2),
      ),
      child: feito ? const Icon(Icons.check_rounded, size: 15, color: Colors.white) : null,
    );
  }
}

/// Logo provisória: círculo com dois arcos (do protótipo).
class LogoAurora extends StatelessWidget {
  const LogoAurora({super.key, this.tamanho = 28});
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return CustomPaint(
      size: Size.square(tamanho),
      painter: _LogoPintor(c.accent, c.teal),
    );
  }
}

class _LogoPintor extends CustomPainter {
  _LogoPintor(this.azul, this.verde);
  final Color azul;
  final Color verde;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 28);
    final traco = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(const Offset(14, 14), 13, traco..color = azul..strokeWidth = 1.5);
    final arcoMaior = Path()
      ..moveTo(5, 17)
      ..cubicTo(8, 12, 11, 10, 14, 10)
      ..cubicTo(17, 10, 20, 12, 23, 17);
    canvas.drawPath(arcoMaior, traco..color = verde..strokeWidth = 2);
    final arcoMenor = Path()
      ..moveTo(8, 20)
      ..cubicTo(10, 17, 12, 16, 14, 16)
      ..cubicTo(16, 16, 18, 17, 20, 20);
    canvas.drawPath(arcoMenor, traco..color = azul..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(_LogoPintor old) => old.azul != azul || old.verde != verde;
}
