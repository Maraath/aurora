import 'package:flutter/material.dart';

import '../core/tema.dart';

/// Cartão padrão: superfície com borda fina e cantos arredondados.
class Cartao extends StatelessWidget {
  const Cartao({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.raio = Raio.cartao,
    this.aoTocar,
    this.cor,
    this.borda = true,
    this.sombra = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double raio;
  final VoidCallback? aoTocar;
  final Color? cor;
  final bool borda;

  /// Sombra sutil de elevação (desligue em cartões dentro de cartões).
  final bool sombra;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final forma = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(raio),
      side: borda ? BorderSide(color: c.line) : BorderSide.none,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(raio),
        boxShadow: sombra ? sombraCartao(context) : null,
      ),
      child: Material(
        color: cor ?? c.surface,
        shape: forma,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          child: Padding(padding: padding, child: child),
        ),
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
      color: Colors.transparent,
      shape: StadiumBorder(
          side: principal ? BorderSide.none : BorderSide(color: c.line)),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(gradient: principal ? c.gradiente : null),
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
                    cor: principal ? c.noAccent : c.text),
              ),
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
    final Color frente = preenchido ? c.noAccent : (ativo ? c.accent : c.text);
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

/// Controle segmentado (Próximos | Recorrentes), como no protótipo. Quando os
/// rótulos não cabem na largura (muitas abas no celular), rola de lado.
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
      child: LayoutBuilder(builder: (context, box) {
        final larguras = [for (final o in opcoes) _largura(context, rotulo(o)) + 28];
        final cabe = larguras.fold<double>(0, (s, l) => s + l) <= box.maxWidth;
        if (cabe) {
          return Row(children: [for (final o in opcoes) Expanded(child: _opcao(c, o))]);
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (var i = 0; i < opcoes.length; i++)
              SizedBox(width: larguras[i], child: _opcao(c, opcoes[i])),
          ]),
        );
      }),
    );
  }

  double _largura(BuildContext context, String texto) {
    final p = TextPainter(
      text: TextSpan(text: texto, style: manrope(13, peso: FontWeight.w700)),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    return p.width;
  }

  Widget _opcao(AuroraCores c, T o) => Semantics(
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
                  style: manrope(13, peso: FontWeight.w700, cor: o == selecionado ? c.text : c.muted),
                ),
              ),
            ),
          ),
        ),
      );
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
    // Título de verdade (Sora 16, cor do texto), não mais um rótulo em caixa alta.
    return Padding(
      padding: const EdgeInsets.only(top: Espaco.sm, bottom: Espaco.md - 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(child: Text(texto, style: sora(16))),
        ?direita,
      ]),
    );
  }
}

/// Barra fina de progresso (0 a 1).
class BarraProgresso extends StatelessWidget {
  const BarraProgresso({super.key, required this.fracao, required this.cor});
  final double fracao;
  final Color cor;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: fracao.clamp(0.0, 1.0),
          minHeight: 8,
          color: cor,
          backgroundColor: context.cores.surface2,
        ),
      );
}

/// Etiqueta pequena com borda ("Parada", "Nova").
class Etiqueta extends StatelessWidget {
  const Etiqueta(this.texto, {super.key, required this.cor});
  final String texto;
  final Color cor;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cor),
        ),
        child: Text(texto, style: manrope(11, peso: FontWeight.w700, cor: cor)),
      );
}

/// Botão tracejado de "+ Nova …" no fim das listas.
class CartaoNovo extends StatelessWidget {
  const CartaoNovo({super.key, required this.titulo, required this.detalhe, required this.aoTocar});
  final String titulo;
  final String detalhe;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Cartao(
      aoTocar: aoTocar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: manrope(15, peso: FontWeight.w600, cor: c.accent)),
          const SizedBox(height: 6),
          Text(detalhe, style: manrope(13, cor: c.muted, altura: 1.4)),
        ],
      ),
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
      child: feito ? Icon(Icons.check_rounded, size: 15, color: c.noAccent) : null,
    );
  }
}

class LogoAurora extends StatelessWidget {
  const LogoAurora({super.key, this.tamanho = 28});
  final double tamanho;

  /// O mesmo desenho do ícone do app (gerado por tool/icone/gerar.ps1).
  @override
  Widget build(BuildContext context) => Image.asset(
        'assets/icone/aurora.png',
        width: tamanho,
        height: tamanho,
        filterQuality: FilterQuality.medium,
        semanticLabel: 'Aurora',
      );
}
