import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/tema.dart';
import '../../data/gamificacao_repo.dart';
import '../componentes.dart';

/// Card compacto de Maestria & Nível Cósmico para o Raio-X da Visão.
class CardNivelMastery extends StatelessWidget {
  const CardNivelMastery({
    super.key,
    required this.gamificacao,
  });

  final QuadroGamificacao gamificacao;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final lvl = gamificacao.nivel;
    final progresso = gamificacao.progressoNivel;

    return Cartao(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      raio: 20,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compacto = constraints.maxWidth < 620;

          final conteudoEsq = Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      c.accent.withValues(alpha: 0.25),
                      c.violeta.withValues(alpha: 0.35),
                    ],
                  ),
                  border: Border.all(color: c.accent.withValues(alpha: 0.6), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: c.accent.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '⚡',
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Nível $lvl · ${gamificacao.tituloRank}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: sora(14.5, peso: FontWeight.w700, espaco: -.3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: c.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: c.accent.withValues(alpha: 0.25)),
                          ),
                          child: Text(
                            '${gamificacao.xpTotal} XP',
                            style: manrope(10, peso: FontWeight.w800, cor: c.accent),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progresso,
                        minHeight: 5,
                        color: c.accent,
                        backgroundColor: c.line.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${gamificacao.conquistasDesbloqueadas} de ${gamificacao.totalConquistas} medalhas desbloqueadas',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: manrope(11, cor: c.muted),
                          ),
                        ),
                        if (gamificacao.xpParaProximoNivel > 0)
                          Text(
                            '${gamificacao.xpParaProximoNivel - gamificacao.xpNoNivelAtual} XP p/ Nível ${lvl + 1}',
                            style: manrope(10, peso: FontWeight.w600, cor: c.muted),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );

          final botaoGaleria = Material(
            color: c.accent.withValues(alpha: 0.12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: c.accent.withValues(alpha: 0.35)),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => ModalGaleriaConquistas.abrir(context, gamificacao),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events_outlined, size: 16, color: c.accent),
                    const SizedBox(width: 6),
                    Text(
                      'Galeria',
                      style: manrope(12.5, peso: FontWeight.w700, cor: c.accent),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 14, color: c.accent),
                  ],
                ),
              ),
            ),
          );

          if (compacto) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                conteudoEsq,
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: botaoGaleria,
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: conteudoEsq),
              const SizedBox(width: 16),
              botaoGaleria,
            ],
          );
        },
      ),
    );
  }
}

/// Modal / Diálogo da Galeria de Conquistas Cósmicas.
class ModalGaleriaConquistas extends StatefulWidget {
  const ModalGaleriaConquistas({
    super.key,
    required this.gamificacao,
  });

  final QuadroGamificacao gamificacao;

  static Future<void> abrir(BuildContext context, QuadroGamificacao gamificacao) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => ModalGaleriaConquistas(gamificacao: gamificacao),
    );
  }

  @override
  State<ModalGaleriaConquistas> createState() => _ModalGaleriaConquistasState();
}

class _ModalGaleriaConquistasState extends State<ModalGaleriaConquistas> {
  CategoriaConquista? _filtro;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final g = widget.gamificacao;
    final tamanho = MediaQuery.sizeOf(context);
    final largura = math.min(tamanho.width - 32, 880.0);
    final altura = math.min(tamanho.height - 48, 760.0);

    final listaFiltrada = _filtro == null
        ? g.conquistas
        : g.conquistas.where((x) => x.categoria == _filtro).toList();

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: largura,
          height: altura,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF100F28)
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: c.line.withValues(alpha: 0.8)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: c.accent.withValues(alpha: 0.1),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabeçalho do Modal
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: c.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: c.accent.withValues(alpha: 0.3)),
                      ),
                      child: Icon(Icons.emoji_events_rounded, color: c.accent, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Maestria & Conquistas',
                                style: sora(18, peso: FontWeight.w700, espaco: -.4),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: c.accent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'LVL ${g.nivel}',
                                  style: manrope(10.5, peso: FontWeight.w800, cor: c.accent),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${g.conquistasDesbloqueadas} de ${g.totalConquistas} medalhas desbloqueadas · ${g.xpTotal} XP acumulados',
                            style: manrope(12, cor: c.muted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
                      color: c.muted,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 1),

              // Banner do Nível Atual Detalhado
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: c.surface2.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: c.line),
                  ),
                  child: Row(
                    children: [
                      _MiniEstatisticaTopo(
                        rotulo: 'Nível Atual',
                        valor: '${g.nivel}',
                        subtitulo: g.tituloRank,
                        cor: c.accent,
                      ),
                      _divisorVertical(c),
                      _MiniEstatisticaTopo(
                        rotulo: 'Total de XP',
                        valor: '${g.xpTotal}',
                        subtitulo: 'Pontos de Vida',
                        cor: c.violeta,
                      ),
                      _divisorVertical(c),
                      _MiniEstatisticaTopo(
                        rotulo: 'Medalhas',
                        valor: '${g.conquistasDesbloqueadas}/${g.totalConquistas}',
                        subtitulo: 'Desbloqueadas',
                        cor: c.teal,
                      ),
                      if (g.streakDias > 0) ...[
                        _divisorVertical(c),
                        _MiniEstatisticaTopo(
                          rotulo: 'Maior Streak',
                          valor: '🔥 ${g.streakDias}d',
                          subtitulo: 'Consistência',
                          cor: Colors.amber,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Pílulas de Filtro por Categoria
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FiltroPill(
                        rotulo: 'Todas (${g.totalConquistas})',
                        ativo: _filtro == null,
                        aoTocar: () => setState(() => _filtro = null),
                      ),
                      for (final cat in CategoriaConquista.values) ...[
                        const SizedBox(width: 8),
                        _FiltroPill(
                          rotulo: cat.rotulo,
                          icone: cat.icone,
                          ativo: _filtro == cat,
                          aoTocar: () => setState(() => _filtro = cat),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Grade de Medalhas Rolável
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  child: GridView.builder(
                    itemCount: listaFiltrada.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: largura >= 700 ? 2 : 1,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: largura >= 700 ? 2.6 : 3.0,
                    ),
                    itemBuilder: (context, index) {
                      final item = listaFiltrada[index];
                      return _CardMedalha(
                        conquista: item,
                        aoTocar: () => _mostrarDetalheConquista(context, item),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divisorVertical(AuroraCores c) {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      color: c.line.withValues(alpha: 0.8),
    );
  }

  void _mostrarDetalheConquista(BuildContext context, Conquista item) {
    final c = context.cores;

    showDialog<void>(
      context: context,
      builder: (_) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF141332),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: item.desbloqueada ? c.accent : c.line,
                width: item.desbloqueada ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 30,
                ),
                if (item.desbloqueada)
                  BoxShadow(
                    color: c.accent.withValues(alpha: 0.25),
                    blurRadius: 24,
                  ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item.desbloqueada
                        ? c.accent.withValues(alpha: 0.18)
                        : Colors.white.withValues(alpha: 0.05),
                    border: Border.all(
                      color: item.desbloqueada ? c.accent : c.line,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      item.icone,
                      style: TextStyle(
                        fontSize: 34,
                        color: item.desbloqueada ? null : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  item.titulo,
                  textAlign: TextAlign.center,
                  style: sora(18, peso: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: c.accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+${item.xp} XP',
                    style: manrope(11.5, peso: FontWeight.w800, cor: c.accent),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.descricao,
                  textAlign: TextAlign.center,
                  style: manrope(13, cor: c.muted, altura: 1.4),
                ),
                const SizedBox(height: 18),
                if (item.desbloqueada) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 16, color: c.accent),
                      const SizedBox(width: 6),
                      Text(
                        'Conquista Desbloqueada!',
                        style: manrope(12.5, peso: FontWeight.w700, cor: c.accent),
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    'Progresso: ${item.textoProgresso}',
                    style: manrope(12, peso: FontWeight.w600, cor: c.muted),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: item.fracaoProgresso,
                      minHeight: 6,
                      color: c.violeta,
                      backgroundColor: c.line,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: c.surface2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Fechar',
                      style: manrope(13, peso: FontWeight.w700, cor: c.text),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniEstatisticaTopo extends StatelessWidget {
  const _MiniEstatisticaTopo({
    required this.rotulo,
    required this.valor,
    required this.subtitulo,
    required this.cor,
  });

  final String rotulo;
  final String valor;
  final String subtitulo;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            rotulo.toUpperCase(),
            style: manrope(9, peso: FontWeight.w800, cor: c.muted, espaco: 0.8),
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style: sora(16, peso: FontWeight.w700, cor: cor),
          ),
          Text(
            subtitulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: manrope(10, cor: c.muted),
          ),
        ],
      ),
    );
  }
}

class _FiltroPill extends StatelessWidget {
  const _FiltroPill({
    required this.rotulo,
    required this.ativo,
    required this.aoTocar,
    this.icone,
  });

  final String rotulo;
  final bool ativo;
  final VoidCallback aoTocar;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Material(
      color: ativo ? c.accent.withValues(alpha: 0.15) : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(
          color: ativo ? c.accent : c.line,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icone != null) ...[
                Icon(icone, size: 14, color: ativo ? c.accent : c.muted),
                const SizedBox(width: 5),
              ],
              Text(
                rotulo,
                style: manrope(
                  12,
                  peso: ativo ? FontWeight.w700 : FontWeight.w600,
                  cor: ativo ? c.accent : c.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardMedalha extends StatelessWidget {
  const _CardMedalha({
    required this.conquista,
    required this.aoTocar,
  });

  final Conquista conquista;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final desbloqueada = conquista.desbloqueada;

    return Material(
      color: desbloqueada
          ? c.surface2.withValues(alpha: 0.6)
          : c.surface.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: desbloqueada
              ? c.accent.withValues(alpha: 0.35)
              : c.line.withValues(alpha: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: desbloqueada
                      ? c.accent.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.04),
                  border: Border.all(
                    color: desbloqueada ? c.accent.withValues(alpha: 0.5) : c.line,
                  ),
                ),
                child: Center(
                  child: Text(
                    desbloqueada ? conquista.icone : '🔒',
                    style: TextStyle(
                      fontSize: desbloqueada ? 22 : 16,
                      color: desbloqueada ? null : c.muted,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conquista.titulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: manrope(13, peso: FontWeight.w700),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: desbloqueada
                                ? c.accent.withValues(alpha: 0.12)
                                : c.line.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            '+${conquista.xp} XP',
                            style: manrope(
                              9.5,
                              peso: FontWeight.w800,
                              cor: desbloqueada ? c.accent : c.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      conquista.descricao,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: manrope(11, cor: c.muted),
                    ),
                    const SizedBox(height: 4),
                    if (desbloqueada)
                      Text(
                        '✓ Desbloqueada',
                        style: manrope(10, peso: FontWeight.w700, cor: c.accent),
                      )
                    else
                      Text(
                        conquista.textoProgresso,
                        style: manrope(10, peso: FontWeight.w600, cor: c.muted),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
