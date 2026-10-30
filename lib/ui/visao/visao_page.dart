import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/objetivos_repo.dart';
import '../../data/visao_repo.dart';
import '../componentes.dart';
import '../icone_ia.dart';
import '../rotina/form_rotina.dart';
import '../rotina/hoje_rotina.dart' show BotaoNovoRotina;
import '../shell.dart';

/// Visão principal do Aurora: Raio-X Estratégico & Momentum Semanal,
/// integrando Score de Ritmo, Hiper-Foco, Heatmap de Hábitos, Áreas da Vida,
/// Vitórias da Semana, Pontos de Atenção e Reflexão com a IA.
class VisaoPage extends StatefulWidget {
  const VisaoPage({
    super.key,
    required this.ir,
    required this.irRotina,
    this.aoBuscar,
  });

  final ValueChanged<Secao> ir;
  final ValueChanged<AbaRotina> irRotina;

  /// Abre a busca em tudo (Ctrl+K). Nulo = o campo não aparece no cabeçalho.
  final VoidCallback? aoBuscar;

  @override
  State<VisaoPage> createState() => _VisaoPageState();
}

class _VisaoPageState extends State<VisaoPage> {
  VisaoRepo? _repo;
  Stream<ResumoVisao>? _resumo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = AuroraEscopo.de(context).db;
    if (_repo?.db != db) {
      _repo = VisaoRepo(db);
      _resumo = _repo!.observarResumo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ResumoVisao>(
      stream: _resumo,
      builder: (context, snap) {
        if (snap.hasError) {
          return Text('Não consegui ler os dados: ${snap.error}');
        }
        final r = snap.data;
        if (r == null) return const SizedBox(height: 200);
        return _Conteudo(
          resumo: r,
          repo: _repo!,
          ir: widget.ir,
          irRotina: widget.irRotina,
          aoBuscar: widget.aoBuscar,
        );
      },
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({
    required this.resumo,
    required this.repo,
    required this.ir,
    required this.irRotina,
    this.aoBuscar,
  });

  final ResumoVisao resumo;
  final VisaoRepo repo;
  final ValueChanged<Secao> ir;
  final ValueChanged<AbaRotina> irRotina;
  final VoidCallback? aoBuscar;

  @override
  Widget build(BuildContext context) {
    final agora = agoraLocal();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Cabecalho(
          resumo: resumo,
          agora: agora,
          aoBuscar: aoBuscar,
          ir: ir,
        ),
        const SizedBox(height: Espaco.md),
        _PainelRaioX(
          resumo: resumo,
          ir: ir,
          irRotina: irRotina,
        ),
      ],
    );
  }
}

/// Cabeçalho: data em caixa alta, saudação grande com o nome na cor da marca,
/// botão de busca, assistente e botão "+ Novo" direto no cockpit.
class _Cabecalho extends StatelessWidget {
  const _Cabecalho({
    required this.resumo,
    required this.agora,
    required this.aoBuscar,
    required this.ir,
  });

  final ResumoVisao resumo;
  final DateTime agora;
  final VoidCallback? aoBuscar;
  final ValueChanged<Secao> ir;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final desktop = MediaQuery.sizeOf(context).width >= larguraDesktop;
    final nome = resumo.nome;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${dataCabecalho(agora)} · ${hora(agora)}',
                style: manrope(
                  11,
                  peso: FontWeight.w700,
                  cor: c.muted,
                  espaco: 1.5,
                ),
              ),
              const SizedBox(height: Espaco.sm),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: nome.isEmpty
                          ? saudacao(agora)
                          : '${saudacao(agora)}, ',
                    ),
                    if (nome.isNotEmpty)
                      TextSpan(
                        text: nome,
                        style: TextStyle(color: c.accent),
                      ),
                  ],
                ),
                style: sora(31, altura: 1.08, espaco: -.8),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (desktop) ...[
          if (aoBuscar != null) ...[
            const SizedBox(width: Espaco.md),
            _CampoBusca(aoTocar: aoBuscar!),
          ],
          const SizedBox(width: Espaco.sm + 2),
          BotaoRedondo(
            icone: iconeIa,
            dica: 'Abrir a Aurora (assistente)',
            aoTocar: () => ir(Secao.assistente),
          ),
          const SizedBox(width: Espaco.sm + 2),
          BotaoNovoRotina(aoTocar: () => abrirFormRotina(context)),
        ],
        if (!desktop) ...[
          const SizedBox(width: Espaco.sm),
          BotaoNovoRotina(aoTocar: () => abrirFormRotina(context)),
        ],
      ],
    );
  }
}

/// Campo que só parece campo: abre a busca em tudo (Ctrl+K) ao toque.
class _CampoBusca extends StatelessWidget {
  const _CampoBusca({required this.aoTocar});
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final cantos = BorderRadius.circular(13);
    return Semantics(
      button: true,
      label: 'Buscar em tudo',
      child: Material(
        color: Theme.of(context).brightness == Brightness.dark
            ? c.surface.withValues(alpha: 0.55)
            : c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: cantos,
          side: BorderSide(color: c.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 250),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 11, 12, 11),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_rounded, size: 19, color: c.muted),
                  const SizedBox(width: Espaco.sm + 1),
                  Text('Buscar em tudo', style: manrope(13, cor: c.muted)),
                  const SizedBox(width: Espaco.lg),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: c.line),
                    ),
                    child: Text(
                      'Ctrl K',
                      style: manrope(
                        10.5,
                        peso: FontWeight.w700,
                        cor: c.muted,
                        espaco: 0.3,
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

/// Cartão comum dos blocos da grade.
class _Bloco extends StatelessWidget {
  const _Bloco({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Cartao(
    padding: const EdgeInsets.all(16),
    raio: 22,
    child: child,
  );
}

/// Painel do Raio-X Semanal: Score de Ritmo, Horas de Foco, Heatmap de Hábitos,
/// Vitórias da Semana, Pontos de Atenção e Fechamento com IA.
class _PainelRaioX extends StatelessWidget {
  const _PainelRaioX({
    required this.resumo,
    required this.ir,
    required this.irRotina,
  });

  final ResumoVisao resumo;
  final ValueChanged<Secao> ir;
  final ValueChanged<AbaRotina> irRotina;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final largura = constraints.maxWidth;
        final telaLarga = largura >= 940;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (telaLarga)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 5, child: _CardScoreRitmo(resumo: resumo)),
                    const SizedBox(width: Espaco.md),
                    Expanded(flex: 7, child: _CardFocoSemanal(resumo: resumo)),
                  ],
                ),
              )
            else ...[
              _CardScoreRitmo(resumo: resumo),
              const SizedBox(height: Espaco.md),
              _CardFocoSemanal(resumo: resumo),
            ],
            const SizedBox(height: Espaco.md),
            _CardHeatmapHabitos(
              resumo: resumo,
              irRotina: irRotina,
            ),
            const SizedBox(height: Espaco.md),
            _CartaoAreas(
              resumo: resumo,
              ir: ir,
              irRotina: irRotina,
              emLinha: telaLarga,
            ),
            const SizedBox(height: Espaco.md),
            _GridVitoriasEAtencao(
              resumo: resumo,
              ir: ir,
              telaLarga: telaLarga,
            ),
            const SizedBox(height: Espaco.md),
            _CardBannerReflexaoIa(ir: ir),
          ],
        );
      },
    );
  }
}

class _CardScoreRitmo extends StatelessWidget {
  const _CardScoreRitmo({required this.resumo});
  final ResumoVisao resumo;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final score = resumo.scoreRitmo;
    final fracao = (score / 100).clamp(0.0, 1.0);

    return Cartao(
      padding: const EdgeInsets.all(20),
      raio: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const _Rotulo('Score de ritmo'),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: c.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: c.accent.withValues(alpha: 0.25)),
                ),
                child: Text(
                  'Semanal',
                  style: manrope(10, peso: FontWeight.w700, cor: c.accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: Espaco.md),
          Row(
            children: [
              _Anel(
                fracao: fracao,
                tamanho: 84,
                espessura: 8,
                cor: c.accent,
                centro: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score',
                      style: sora(26, peso: FontWeight.w700, altura: 1),
                    ),
                    Text(
                      '/100',
                      style: manrope(10, peso: FontWeight.w700, cor: c.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Espaco.md + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resumo.rotuloRitmo,
                      style: sora(16, peso: FontWeight.w700, espaco: -.3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resumo.subtituloRitmo,
                      style: manrope(12, cor: c.muted, altura: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Espaco.md + 4),
          Row(
            children: [
              Expanded(
                child: _MiniMetricaRitmo(
                  titulo: 'Tarefas',
                  valor: '${(resumo.taxaTarefas * 100).round()}%',
                  subtitulo: 'concluídas',
                  cor: c.corTarefa,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniMetricaRitmo(
                  titulo: 'Hábitos',
                  valor: '${(resumo.taxaHabitos * 100).round()}%',
                  subtitulo: 'consistência',
                  cor: c.corHabito,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniMetricaRitmo(
                  titulo: 'Treinos',
                  valor: '${resumo.treinosFeitosSemana}/${resumo.metaTreinosSemana > 0 ? resumo.metaTreinosSemana : '—'}',
                  subtitulo: 'sessões',
                  cor: c.violeta,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniMetricaRitmo extends StatelessWidget {
  const _MiniMetricaRitmo({
    required this.titulo,
    required this.valor,
    required this.subtitulo,
    required this.cor,
  });

  final String titulo;
  final String valor;
  final String subtitulo;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? c.surface.withValues(alpha: 0.5)
            : c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.line.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: manrope(10, peso: FontWeight.w700, cor: c.muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(valor, style: sora(13.5, peso: FontWeight.w700)),
          Text(
            subtitulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: manrope(9.5, cor: c.muted),
          ),
        ],
      ),
    );
  }
}

class _CardFocoSemanal extends StatelessWidget {
  const _CardFocoSemanal({required this.resumo});
  final ResumoVisao resumo;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final totalMinutos = resumo.totalMinutosFocoSemana;
    final totalHoras = totalMinutos / 60.0;
    const metaMinutos = 600; // 10 horas
    const metaHoras = 10;
    final fracaoMeta = (totalMinutos / metaMinutos).clamp(0.0, 1.0);

    final hoje = hojeLocal();
    final inicioSemana = somarDias(hoje, -(hoje.weekday - 1));
    final dias = [for (var i = 0; i < 7; i++) somarDias(inicioSemana, i)];
    final nomesDias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

    var maiorMinuto = 60;
    for (final d in dias) {
      final m = resumo.focoMinutosPorDia[chaveData(d)] ?? 0;
      if (m > maiorMinuto) maiorMinuto = m;
    }

    return Cartao(
      padding: const EdgeInsets.all(20),
      raio: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.timelapse_rounded, size: 18, color: c.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tempo em Hiper-Foco',
                  style: sora(16, peso: FontWeight.w700, espaco: -.3),
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${totalHoras.toStringAsFixed(1)}h',
                      style: sora(15, peso: FontWeight.w700, cor: c.accent),
                    ),
                    TextSpan(
                      text: ' / ${metaHoras}h meta',
                      style: manrope(11.5, cor: c.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Espaco.sm + 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: fracaoMeta,
              minHeight: 6,
              color: c.accent,
              backgroundColor: c.line.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: Espaco.md),
          SizedBox(
            height: 98,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < 7; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final dia = dias[i];
                        final chave = chaveData(dia);
                        final min = resumo.focoMinutosPorDia[chave] ?? 0;
                        final ehHoje = dia == hoje;
                        final alturaBarra = (10 + (min / maiorMinuto) * 44).clamp(10.0, 54.0);

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              min > 0 ? '${min}m' : '—',
                              style: manrope(
                                9,
                                peso: FontWeight.w700,
                                cor: min > 0
                                    ? (ehHoje ? c.accent : c.text)
                                    : c.muted.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              height: alturaBarra,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                gradient: ehHoje && min > 0
                                    ? LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [c.gradIni, c.gradFim],
                                      )
                                    : null,
                                color: ehHoje && min > 0
                                    ? null
                                    : (min > 0
                                        ? c.accent.withValues(alpha: 0.75)
                                        : c.line.withValues(alpha: 0.6)),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              ehHoje ? 'Hoje' : nomesDias[i],
                              style: manrope(
                                9.5,
                                peso: FontWeight.w800,
                                cor: ehHoje ? c.accent : c.muted,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardHeatmapHabitos extends StatelessWidget {
  const _CardHeatmapHabitos({
    required this.resumo,
    required this.irRotina,
  });

  final ResumoVisao resumo;
  final ValueChanged<AbaRotina> irRotina;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final quadro = resumo.quadroHabitos;
    final habitos = quadro?.habitos ?? const [];
    final hoje = hojeLocal();
    final ultimos14Dias = [for (var i = 13; i >= 0; i--) somarDias(hoje, -i)];

    return Cartao(
      padding: const EdgeInsets.all(20),
      raio: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_view_week_rounded, size: 18, color: c.corHabito),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Heatmap de Hábitos · Últimos 14 dias',
                  style: sora(16, peso: FontWeight.w700, espaco: -.3),
                ),
              ),
              _LinkAcao(
                texto: 'Ver hábitos',
                aoTocar: () => irRotina(AbaRotina.habitos),
              ),
            ],
          ),
          const SizedBox(height: Espaco.md),
          if (habitos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Espaco.md),
              child: Center(
                child: Text(
                  'Nenhum hábito ativo configurado no momento.',
                  style: manrope(13, cor: c.muted),
                ),
              ),
            )
          else ...[
            for (var idx = 0; idx < habitos.length; idx++) ...[
              if (idx > 0) const SizedBox(height: 12),
              Builder(
                builder: (context) {
                  final h = habitos[idx];
                  final seq = quadro?.sequencia(h, hoje) ?? 0;

                  return Row(
                    children: [
                      SizedBox(
                        width: 130,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              h.nome,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: manrope(12.5, peso: FontWeight.w700),
                            ),
                            Text(
                              seq >= 2 ? '🔥 $seq dias seguidos' : (seq == 1 ? '🔥 1 dia' : '—'),
                              style: manrope(10, cor: seq >= 2 ? c.accent : c.muted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (final dia in ultimos14Dias)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2.5),
                                  child: Builder(
                                    builder: (context) {
                                      final feito = quadro?.feito(h.id, dia) ?? false;
                                      final ehHoje = dia == hoje;

                                      return Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: feito
                                              ? c.corHabito
                                              : c.line.withValues(alpha: 0.4),
                                          borderRadius: BorderRadius.circular(4),
                                          border: ehHoje
                                              ? Border.all(color: c.accent, width: 1.5)
                                              : null,
                                        ),
                                        child: feito
                                            ? const Center(
                                                child: Icon(
                                                  Icons.check_rounded,
                                                  size: 11,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : null,
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _GridVitoriasEAtencao extends StatelessWidget {
  const _GridVitoriasEAtencao({
    required this.resumo,
    required this.ir,
    required this.telaLarga,
  });

  final ResumoVisao resumo;
  final ValueChanged<Secao> ir;
  final bool telaLarga;

  @override
  Widget build(BuildContext context) {
    final colunaVitorias = Cartao(
      padding: const EdgeInsets.all(20),
      raio: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'Vitórias da Semana',
                style: sora(16, peso: FontWeight.w700, espaco: -.3),
              ),
            ],
          ),
          const SizedBox(height: Espaco.md),
          for (var i = 0; i < resumo.vitorias.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _ItemCardDestaque(
              item: resumo.vitorias[i],
              ehPositivo: true,
            ),
          ],
        ],
      ),
    );

    final colunaAtencao = Cartao(
      padding: const EdgeInsets.all(20),
      raio: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'Pontos de Atenção',
                style: sora(16, peso: FontWeight.w700, espaco: -.3),
              ),
            ],
          ),
          const SizedBox(height: Espaco.md),
          for (var i = 0; i < resumo.atencoes.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _ItemCardDestaque(
              item: resumo.atencoes[i],
              ehPositivo: false,
            ),
          ],
        ],
      ),
    );

    if (telaLarga) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: colunaVitorias),
            const SizedBox(width: Espaco.md),
            Expanded(child: colunaAtencao),
          ],
        ),
      );
    }

    return Column(
      children: [
        colunaVitorias,
        const SizedBox(height: Espaco.md),
        colunaAtencao,
      ],
    );
  }
}

class _ItemCardDestaque extends StatelessWidget {
  const _ItemCardDestaque({
    required this.item,
    required this.ehPositivo,
  });

  final ItemDestaqueRaioX item;
  final bool ehPositivo;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final bordaCor = ehPositivo
        ? c.teal.withValues(alpha: 0.3)
        : Colors.amber.withValues(alpha: 0.35);

    final icone = switch (item.tipo) {
      'treino' => Icons.fitness_center_rounded,
      'habito' => Icons.local_fire_department_rounded,
      'foco' => Icons.timelapse_rounded,
      'tarefa' => Icons.check_circle_outline_rounded,
      'financas' => Icons.account_balance_wallet_outlined,
      _ => ehPositivo ? Icons.star_rounded : Icons.info_outline_rounded,
    };

    final iconeCor = ehPositivo ? c.teal : Colors.amber;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? c.surface.withValues(alpha: 0.5)
            : c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bordaCor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 17, color: iconeCor),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.titulo,
                  style: manrope(12.5, peso: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  item.detalhe,
                  style: manrope(11.5, cor: c.muted, altura: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBannerReflexaoIa extends StatelessWidget {
  const _CardBannerReflexaoIa({required this.ir});
  final ValueChanged<Secao> ir;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            c.gradIni.withValues(alpha: 0.18),
            c.gradFim.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(color: c.accent.withValues(alpha: 0.3)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compacto = constraints.maxWidth < 600;
          final conteudo = Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.accent.withValues(alpha: 0.15),
                ),
                child: Icon(iconeIa, size: 24, color: c.accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reflexão Semanal com a Aurora',
                      style: sora(16, peso: FontWeight.w700, espaco: -.3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Feche o ciclo com inteligência: analise gargalos, celebre vitórias e alinhe o plano estratégico para a próxima semana.',
                      style: manrope(12, cor: c.muted, altura: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          );

          if (compacto) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                conteudo,
                const SizedBox(height: 14),
                _BotaoRefletirIa(aoTocar: () => ir(Secao.assistente)),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: conteudo),
              const SizedBox(width: 16),
              _BotaoRefletirIa(aoTocar: () => ir(Secao.assistente)),
            ],
          );
        },
      ),
    );
  }
}

class _BotaoRefletirIa extends StatelessWidget {
  const _BotaoRefletirIa({required this.aoTocar});
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Material(
      color: c.accent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Refletir agora',
                style: manrope(13, peso: FontWeight.w700, cor: c.noAccent),
              ),
              const SizedBox(width: 7),
              Icon(Icons.arrow_forward_rounded, size: 16, color: c.noAccent),
            ],
          ),
        ),
      ),
    );
  }
}

/// Painel das áreas: quatro blocos pequenos, numa linha (tela larga) ou 2 x 2.
class _CartaoAreas extends StatelessWidget {
  const _CartaoAreas({
    required this.resumo,
    required this.ir,
    required this.irRotina,
    this.emLinha = false,
  });

  final ResumoVisao resumo;
  final ValueChanged<Secao> ir;
  final ValueChanged<AbaRotina> irRotina;

  /// Tela larga: a faixa ocupa a largura toda e os blocos ficam lado a lado.
  final bool emLinha;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final o = resumo.objetivo;
    final atrasadas = resumo.tarefasAtrasadas;

    final blocos = [
      _MiniArea(
        rotulo: 'Tarefas',
        valor: atrasadas > 0
            ? '$atrasadas ${atrasadas == 1 ? 'atrasada' : 'atrasadas'}'
            : 'em dia',
        subtitulo: '${resumo.tarefasHoje.length} para hoje',
        cor: atrasadas > 0 ? c.bad : null,
        aoTocar: () => irRotina(AbaRotina.hoje),
      ),
      _MiniArea(
        rotulo: 'Hábitos',
        valor: '${resumo.habitosFeitos} de ${resumo.habitos.length}',
        subtitulo: 'concluídos hoje',
        aoTocar: () => irRotina(AbaRotina.habitos),
      ),
      _MiniArea(
        rotulo: 'Finanças',
        valor: reais(resumo.saldoCentavos),
        subtitulo: resumo.contasAPagar > 0
            ? '${reais(resumo.aPagarCentavos)} a pagar'
            : 'contas em dia',
        cor: resumo.saldoCentavos < 0 ? c.bad : null,
        aoTocar: () => ir(Secao.financas),
      ),
      _MiniArea(
        rotulo: 'Objetivo',
        valor: o == null ? '—' : valorMeta(o.valorAtual, o.unidade),
        subtitulo: o == null ? 'nenhum ativo' : o.nome,
        aoTocar: () => ir(Secao.objetivos),
      ),
    ];

    Widget par(Widget a, Widget b) => Padding(
      padding: const EdgeInsets.only(top: Espaco.sm),
      child: Row(
        children: [
          Expanded(child: a),
          const SizedBox(width: Espaco.sm),
          Expanded(child: b),
        ],
      ),
    );

    return _Bloco(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Painel das áreas', style: sora(19, espaco: -.4)),
              ),
              Text(
                'abrir',
                style: manrope(11, peso: FontWeight.w700, cor: c.muted),
              ),
            ],
          ),
          if (emLinha)
            Padding(
              padding: const EdgeInsets.only(top: Espaco.sm + 2),
              child: Row(
                children: [
                  for (var i = 0; i < blocos.length; i++) ...[
                    if (i > 0) const SizedBox(width: Espaco.sm),
                    Expanded(child: blocos[i]),
                  ],
                ],
              ),
            )
          else ...[
            par(blocos[0], blocos[1]),
            par(blocos[2], blocos[3]),
          ],
        ],
      ),
    );
  }
}

class _MiniArea extends StatelessWidget {
  const _MiniArea({
    required this.rotulo,
    required this.valor,
    required this.aoTocar,
    this.subtitulo,
    this.cor,
  });

  final String rotulo;
  final String valor;
  final String? subtitulo;
  final VoidCallback aoTocar;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.line.withValues(alpha: 0.7)),
            color: Colors.white.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark ? 0.03 : 0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rotulo.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: manrope(
                  8.5,
                  peso: FontWeight.w800,
                  cor: c.muted,
                  espaco: 1.1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                valor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: sora(16, cor: cor, espaco: -.3),
              ),
              if (subtitulo != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitulo!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: manrope(9.5, cor: c.muted),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Rótulo pequeno em caixa alta (título de bloco).
class _Rotulo extends StatelessWidget {
  const _Rotulo(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) => Text(
    texto.toUpperCase(),
    style: manrope(
      9,
      peso: FontWeight.w800,
      cor: context.cores.muted,
      espaco: 1.4,
    ),
  );
}

/// Ação de texto com seta ("Ver calendário →").
class _LinkAcao extends StatelessWidget {
  const _LinkAcao({required this.texto, required this.aoTocar});
  final String texto;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                texto,
                style: manrope(11.5, peso: FontWeight.w700, cor: c.accent),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, size: 14, color: c.accent),
            ],
          ),
        ),
      ),
    );
  }
}

/// Anel de progresso desenhado à mão (arco com ponta arredondada).
class _Anel extends StatelessWidget {
  const _Anel({
    required this.fracao,
    required this.tamanho,
    required this.espessura,
    this.cor,
    this.centro,
  });

  final double fracao;
  final double tamanho;
  final double espessura;
  final Color? cor;
  final Widget? centro;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: tamanho,
      child: CustomPaint(
        painter: _PintorAnel(
          fracao: fracao,
          espessura: espessura,
          cor: cor,
          cores: context.cores,
        ),
        child: centro == null ? null : Center(child: centro),
      ),
    );
  }
}

class _PintorAnel extends CustomPainter {
  _PintorAnel({
    required this.fracao,
    required this.espessura,
    required this.cores,
    this.cor,
  });

  final double fracao;
  final double espessura;
  final AuroraCores cores;
  final Color? cor;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final raio = (size.shortestSide - espessura) / 2;
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = espessura
      ..color = cores.line.withValues(alpha: 0.65);
    canvas.drawCircle(centro, raio, base);

    final f = fracao.clamp(0.0, 1.0);
    if (f <= 0) return;
    final arco = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = espessura
      ..strokeCap = StrokeCap.round
      ..color = cor ?? cores.accent;
    canvas.drawArc(
      Rect.fromCircle(center: centro, radius: raio),
      -math.pi / 2,
      2 * math.pi * f,
      false,
      arco,
    );
  }

  @override
  bool shouldRepaint(_PintorAnel antigo) =>
      antigo.fracao != fracao ||
      antigo.espessura != espessura ||
      antigo.cor != cor ||
      antigo.cores != cores;
}
