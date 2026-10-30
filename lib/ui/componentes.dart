import 'package:flutter/material.dart';

import 'icone_ia.dart';
import '../core/tema.dart';
import 'vidro.dart';

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
    final cantos = BorderRadius.circular(raio);
    final toque = Material(
      type: MaterialType.transparency,
      shape: RoundedRectangleBorder(borderRadius: cantos),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: aoTocar,
        child: Padding(padding: padding, child: child),
      ),
    );

    if (Theme.of(context).brightness == Brightness.dark) {
      // Cartão sobre o céu: vidro com desfoque. Cartão dentro de outro cartão
      // (sem sombra): só transparência, para não empilhar desfoques.
      if (sombra)
        return Vidro(raio: cantos, cor: cor, borda: borda, child: toque);
      final base = cor ?? c.surface2;
      return DecoratedBox(
        decoration: BoxDecoration(
          color: base.a < 1 ? base : base.withValues(alpha: 0.35),
          borderRadius: cantos,
          border: borda
              ? Border.all(color: Colors.white.withValues(alpha: 0.07))
              : null,
        ),
        child: toque,
      );
    }

    final forma = RoundedRectangleBorder(
      borderRadius: cantos,
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
        side: principal ? BorderSide.none : BorderSide(color: c.line),
      ),
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
                style: manrope(
                  14,
                  peso: principal ? FontWeight.w700 : FontWeight.w600,
                  cor: principal ? c.noAccent : c.text,
                ),
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
    final Color fundo = preenchido
        ? c.accentFill
        : (ativo ? c.accentSoft : c.surface);
    final Color frente = preenchido ? c.noAccent : (ativo ? c.accent : c.text);
    return Tooltip(
      message: dica,
      child: Material(
        color: fundo,
        shape: CircleBorder(
          side: preenchido
              ? BorderSide.none
              : BorderSide(color: ativo ? c.accent : c.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          child: SizedBox(
            width: 44,
            height: 44,
            child: IconeApp(
              icone,
              size: 20,
              color: frente,
              semanticLabel: dica,
            ),
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
    final trilho = Padding(
      padding: const EdgeInsets.all(4),
      child: LayoutBuilder(
        builder: (context, box) {
          final larguras = [
            for (final o in opcoes) _largura(context, rotulo(o)) + 28,
          ];
          final cabe =
              larguras.fold<double>(0, (s, l) => s + l) <= box.maxWidth;
          if (cabe) {
            return Row(
              children: [for (final o in opcoes) Expanded(child: _opcao(c, o))],
            );
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < opcoes.length; i++)
                  SizedBox(width: larguras[i], child: _opcao(c, opcoes[i])),
              ],
            ),
          );
        },
      ),
    );
    final cantos = BorderRadius.circular(14);
    if (Theme.of(context).brightness == Brightness.dark) {
      return Vidro(raio: cantos, cor: c.surface2, child: trilho);
    }
    return DecoratedBox(
      decoration: BoxDecoration(color: c.surface2, borderRadius: cantos),
      child: trilho,
    );
  }

  double _largura(BuildContext context, String texto) {
    final p = TextPainter(
      text: TextSpan(
        text: texto,
        style: manrope(13, peso: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    return p.width;
  }

  /// Selecionada: degradê da marca bem leve, contorno violeta e um traço com o
  /// degradê embaixo. Mouse em cima: turquesa, para não se confundir com a
  /// seleção.
  Widget _opcao(AuroraCores c, T o) {
    final ativo = o == selecionado;
    final cantos = BorderRadius.circular(10);
    return Semantics(
      selected: ativo,
      button: true,
      child: Material(
        type: MaterialType.transparency,
        borderRadius: cantos,
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: ativo
              ? BoxDecoration(
                  borderRadius: cantos,
                  gradient: LinearGradient(
                    colors: [
                      c.gradIni.withValues(alpha: 0.20),
                      c.gradFim.withValues(alpha: 0.22),
                    ],
                  ),
                  border: Border.all(
                    color: c.violeta.withValues(alpha: 0.45),
                    width: 0.6,
                  ),
                )
              : null,
          child: InkWell(
            onTap: () => aoEscolher(o),
            hoverColor: c.teal.withValues(alpha: 0.10),
            highlightColor: c.teal.withValues(alpha: 0.06),
            splashColor: c.violeta.withValues(alpha: 0.14),
            child: SizedBox(
              height: 40,
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      rotulo(o),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: manrope(
                        13,
                        peso: FontWeight.w700,
                        cor: ativo ? c.text : c.muted,
                      ),
                    ),
                  ),
                  if (ativo)
                    Positioned(
                      bottom: 4,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: FractionallySizedBox(
                          widthFactor: 0.42,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: LinearGradient(
                                colors: [c.gradIni, c.gradFim],
                              ),
                            ),
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

/// Contador do topo das telas (atrasadas / abertas / feitas hoje).
class Contador extends StatelessWidget {
  const Contador({
    super.key,
    required this.valor,
    required this.rotulo,
    this.cor,
    this.fundo,
  });
  final String valor;
  final String rotulo;
  final Color? cor;
  final Color? fundo;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final cantos = BorderRadius.circular(14);
    final conteudo = Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(valor, style: sora(22, cor: cor ?? c.text)),
          const SizedBox(height: 2),
          Text(
            rotulo,
            style: manrope(12, cor: fundo == null ? c.muted : c.text),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
    if (Theme.of(context).brightness == Brightness.dark) {
      // Vidro com a cor do contador por cima (magenta, verde...), como vidro tingido.
      return Vidro(
        raio: cantos,
        child: fundo == null
            ? conteudo
            : ColoredBox(color: fundo!, child: conteudo),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fundo ?? c.surface,
        borderRadius: cantos,
        border: fundo == null ? Border.all(color: c.line) : null,
      ),
      child: conteudo,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: Text(texto, style: sora(16))),
          ?direita,
        ],
      ),
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
    child: Text(
      texto,
      style: manrope(11, peso: FontWeight.w700, cor: cor),
    ),
  );
}

/// Botão tracejado de "+ Nova …" no fim das listas.
class CartaoNovo extends StatelessWidget {
  const CartaoNovo({
    super.key,
    required this.titulo,
    required this.detalhe,
    required this.aoTocar,
  });
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
          Text(
            titulo,
            style: manrope(15, peso: FontWeight.w600, cor: c.accent),
          ),
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
    child: Text(
      texto,
      style: manrope(14, cor: context.cores.muted, altura: 1.4),
    ),
  );
}

/// Círculo de concluir: vazio quando pendente, verde-água com ✓ quando feito.
class MarcaConcluir extends StatelessWidget {
  const MarcaConcluir({
    super.key,
    required this.feito,
    this.cor,
    this.quadrado = false,
  });
  final bool feito;

  /// Cor do tipo (Rotina): borda em aberto e preenchimento feito. Sem ela, turquesa.
  final Color? cor;

  /// Caixinha de canto arredondado (tarefa) em vez de círculo.
  final bool quadrado;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final destaque = cor ?? c.teal;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: quadrado ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: quadrado ? BorderRadius.circular(7) : null,
        color: feito ? destaque : Colors.transparent,
        border: Border.all(
          color: feito || cor != null ? destaque : c.muted,
          width: 2,
        ),
      ),
      child: feito
          ? Icon(Icons.check_rounded, size: 15, color: c.noAccent)
          : null,
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

/// Navegação de segundo nível (dentro de uma aba): pílulas pequenas com ícone,
/// alinhadas à esquerda, para não competir com os `Segmentos` da área.
/// Rola de lado se não couber.
class SubAbas<T> extends StatelessWidget {
  const SubAbas({
    super.key,
    required this.opcoes,
    required this.selecionado,
    required this.rotulo,
    required this.aoEscolher,
    this.icone,
    this.sufixo,
  });

  final List<T> opcoes;
  final T selecionado;
  final String Function(T) rotulo;
  final IconData Function(T)? icone;
  final Widget? Function(T)? sufixo;
  final ValueChanged<T> aoEscolher;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final semMovimento = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final duracao = semMovimento
        ? Duration.zero
        : const Duration(milliseconds: 180);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < opcoes.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _pilula(c, opcoes[i], duracao),
          ],
        ],
      ),
    );
  }

  Widget _pilula(AuroraCores c, T o, Duration duracao) {
    final ativo = o == selecionado;
    final cor = ativo ? c.accent : c.muted;
    return Semantics(
      selected: ativo,
      button: true,
      child: AnimatedContainer(
        duration: duracao,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: ativo ? c.accentSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: ativo ? c.accent.withValues(alpha: 0.45) : c.line,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => aoEscolher(o),
            customBorder: const StadiumBorder(),
            hoverColor: c.teal.withValues(alpha: 0.10),
            splashColor: c.violeta.withValues(alpha: 0.14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icone != null) ...[
                    IconeApp(icone!(o), size: 16, color: cor),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    rotulo(o),
                    style: manrope(
                      13,
                      peso: ativo ? FontWeight.w700 : FontWeight.w600,
                      cor: ativo ? c.text : c.muted,
                    ),
                  ),
                  if (sufixo?.call(o) != null) ...[
                    const SizedBox(width: 6),
                    sufixo!(o)!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
