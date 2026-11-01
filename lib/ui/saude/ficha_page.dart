import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/recorrencia.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/saude_repo.dart';
import '../componentes.dart';
import '../em_breve.dart';
import 'blocos_saude.dart';
import 'form_ciclo_treino.dart';
import 'form_sessao.dart';
import 'form_treino.dart';

class FichaPage extends StatefulWidget {
  const FichaPage({super.key, this.voltar, this.abrirBiblioteca});
  final VoidCallback? voltar;
  final VoidCallback? abrirBiblioteca;

  @override
  State<FichaPage> createState() => _FichaPageState();
}

class _FichaPageState extends State<FichaPage> {
  SaudeRepo? _repo;
  Stream<QuadroSaude>? _quadro;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = AuroraEscopo.de(context).db;
    if (_repo?.db != db) {
      _repo = SaudeRepo(db);
      _quadro = _repo!.observarQuadro();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuadroSaude>(
      stream: _quadro,
      builder: (context, snap) {
        if (snap.hasError) return Text('Não consegui ler a ficha: ${snap.error}');
        final q = snap.data;
        if (q == null) return const SizedBox(height: 200);
        return _conteudo(context, q);
      },
    );
  }

  Widget _conteudo(BuildContext context, QuadroSaude q) {
    final c = context.cores;
    final hoje = hojeLocal();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TituloPagina(
          'Ficha de treino',
          voltar: widget.voltar,
          acao: BotaoRedondo(
            icone: Icons.add_rounded,
            dica: 'Novo treino',
            preenchido: true,
            aoTocar: () => _escolherTipoNovoTreino(context, q),
          ),
        ),
        const SizedBox(height: 14),
        if (q.temCicloAtivo) ...[
          _CartaoCicloIntercalado(quadro: q, repo: _repo!, hoje: hoje),
          const SizedBox(height: 14),
        ] else ...[
          Cartao(
            raio: 16,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            aoTocar: () => abrirFormCicloTreino(context, quadro: q),
            child: Row(children: [
              Icon(Icons.autorenew_rounded, color: c.teal),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Montar treino intercalado (ciclo rotativo)', style: manrope(15, peso: FontWeight.w600)),
                  Text('Alterne treinos e descansos continuamente (ex: ABC + Descanso)', style: manrope(12, cor: c.muted)),
                ]),
              ),
              Icon(Icons.chevron_right_rounded, color: c.muted),
            ]),
          ),
          const SizedBox(height: 14),
        ],
        if (widget.abrirBiblioteca != null) ...[
          Cartao(
            raio: 16,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            aoTocar: widget.abrirBiblioteca,
            child: Row(children: [
              Icon(Icons.video_library_outlined, color: c.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Biblioteca de exercícios', style: manrope(15, peso: FontWeight.w600)),
                  Text('Busque por nome ou grupo e veja o movimento', style: manrope(12, cor: c.muted)),
                ]),
              ),
              Icon(Icons.chevron_right_rounded, color: c.muted),
            ]),
          ),
          const SizedBox(height: 14),
        ],
        for (final t in q.treinos)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Cartao(
              aoTocar: () => abrirFormTreino(context, treino: t),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(t.titulo, style: sora(18)),
                  const SizedBox(height: 2),
                  Text(
                    [
                      t.treino.diasSemana == 0 ? 'sem dia fixo' : descreverDias(t.treino.diasSemana),
                      t.ultimaVez == null ? 'ainda não feito' : 'último ${diaRelativo(dataLocal(t.ultimaVez!), hoje)}',
                    ].join(' · '),
                    style: manrope(12, cor: c.muted),
                  ),
                  const SizedBox(height: 6),
                  for (final e in t.exercicios) LinhaExercicio(exercicio: e),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: BotaoPilula(
                      texto: q.feitoEm(t.treino.id, hoje) ? 'Registrar de novo' : 'Começar',
                      principal: !q.feitoEm(t.treino.id, hoje),
                      aoTocar: () => abrirFormSessao(context, t),
                    ),
                  ),
                ],
              ),
            ),
          ),
        CartaoNovo(
          titulo: '+ Novo treino ou ciclo intercalado',
          detalhe: 'Crie um treino simples ou monte um ciclo rotativo com treinos e descansos.',
          aoTocar: () => _escolherTipoNovoTreino(context, q),
        ),
        const SizedBox(height: 18),
        const TituloSecao('Histórico'),
        if (q.historico.isEmpty) const Vazio('Nenhum treino registrado ainda.'),
        for (final r in q.historico.take(20))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Cartao(
              raio: 16,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              aoTocar: () => _excluirSessao(r),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.treino?.nome ?? 'Treino avulso', style: manrope(15, peso: FontWeight.w600)),
                        Text(
                          '${diaRelativo(DateTime.parse(r.sessao.dia), hoje)} · ${r.series} séries',
                          style: manrope(12, cor: c.muted),
                        ),
                      ],
                    ),
                  ),
                  Text(_volume(r.volumeKg), style: manrope(13, peso: FontWeight.w700, cor: c.teal)),
                ],
              ),
            ),
          ),
        if (q.historico.isNotEmpty)
          Text('Volume = carga × repetições somadas. Toque num treino para excluí-lo.',
              style: manrope(12, cor: c.muted)),
      ],
    );
  }

  String _volume(double kg) => kg >= 1000 ? '${numero((kg / 100).round() / 10)} t' : '${numero(kg.roundToDouble())} kg';

  Future<void> _excluirSessao(ResumoSessao r) async {
    final c = context.cores;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text('Excluir este treino?', style: sora(18)),
        content: Text('As séries dele deixam de contar para a carga sugerida.',
            style: manrope(14, cor: c.text, altura: 1.4)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Excluir', style: TextStyle(color: c.bad)),
          ),
        ],
      ),
    );
    if (ok == true) await _repo!.excluirSessao(r.sessao.id);
  }

  void _escolherTipoNovoTreino(BuildContext context, QuadroSaude q) {
    final c = context.cores;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Criar treino', style: sora(18)),
              const SizedBox(height: 6),
              Text('Como você deseja programar seus treinos?', style: manrope(13, cor: c.muted)),
              const SizedBox(height: 16),
              Cartao(
                aoTocar: () {
                  Navigator.pop(ctx);
                  abrirFormTreino(context);
                },
                child: Row(
                  children: [
                    Icon(Icons.fitness_center_rounded, color: c.accent, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Treino individual', style: manrope(15, peso: FontWeight.w700)),
                          Text('Treino simples por dias da semana ou sem dia fixo.', style: manrope(12, cor: c.muted)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: c.muted),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Cartao(
                aoTocar: () {
                  Navigator.pop(ctx);
                  abrirFormCicloTreino(context, quadro: q);
                },
                child: Row(
                  children: [
                    Icon(Icons.autorenew_rounded, color: c.teal, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Treino intercalado (ciclo rotativo)', style: manrope(15, peso: FontWeight.w700)),
                          Text('Alterne treinos e descansos continuamente (ex: ABC + Descanso).', style: manrope(12, cor: c.muted)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: c.muted),
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

class _CartaoCicloIntercalado extends StatelessWidget {
  const _CartaoCicloIntercalado({
    required this.quadro,
    required this.repo,
    required this.hoje,
  });

  final QuadroSaude quadro;
  final SaudeRepo repo;
  final DateTime hoje;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final ciclo = quadro.ciclo!;
    final passoHoje = ciclo.passoNoDia(hoje);
    final treinoHoje = quadro.treinoDoDia(hoje);
    final proximo = quadro.proximoTreino(hoje);
    final feitoHoje = treinoHoje != null && quadro.feitoEm(treinoHoje.treino.id, hoje);

    return Cartao(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.autorenew_rounded, size: 18, color: c.teal),
              const SizedBox(width: 8),
              Expanded(
                child: Text('TREINO INTERCALADO (CICLO)', style: rotulo(c.teal)),
              ),
              InkWell(
                onTap: () => abrirFormCicloTreino(context, quadro: quadro),
                child: Text('Editar ciclo', style: manrope(12, peso: FontWeight.w700, cor: c.accent)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (treinoHoje != null) ...[
            Text('Hoje · Dia ${passoHoje?.dia ?? 1}: ${treinoHoje.titulo}', style: sora(18)),
            const SizedBox(height: 4),
            Text(
              feitoHoje ? 'Treino já realizado hoje!' : 'Treino programado para a sua sequência de hoje.',
              style: manrope(12, cor: c.muted),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: BotaoPilula(
                texto: feitoHoje ? 'Registrar de novo' : 'Começar treino de hoje',
                principal: !feitoHoje,
                aoTocar: () => abrirFormSessao(context, treinoHoje),
              ),
            ),
          ] else ...[
            Row(
              children: [
                Icon(Icons.nights_stay_rounded, color: c.accent, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hoje · Dia ${passoHoje?.dia ?? 1}: Descanso 💤', style: sora(18)),
                      const SizedBox(height: 2),
                      Text(
                        proximo != null
                            ? 'Recuperação muscular. Próximo: ${proximo.treino.titulo} amanhã.'
                            : 'Recuperação muscular para render mais no próximo treino.',
                        style: manrope(12, cor: c.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Text('Sequência do ciclo (toque para sincronizar o dia de hoje):', style: manrope(11, peso: FontWeight.w600, cor: c.muted)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < ciclo.passos.length; i++) ...[
                  if (i > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.arrow_forward_rounded, size: 14, color: c.muted),
                    ),
                  _chipPasso(context, c, ciclo.passos[i], ciclo.passos[i].dia == passoHoje?.dia),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.refresh_rounded, size: 14, color: c.teal),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipPasso(BuildContext context, AuroraCores c, PassoCiclo p, bool isHoje) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _mudarDiaHoje(context, p.dia),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isHoje ? c.teal.withValues(alpha: 0.15) : c.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isHoje ? c.teal : c.line, width: isHoje ? 1.5 : 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  p.isDescanso ? Icons.bedtime_rounded : Icons.fitness_center_rounded,
                  size: 13,
                  color: isHoje ? c.teal : c.muted,
                ),
                const SizedBox(width: 4),
                Text(
                  'Dia ${p.dia}',
                  style: manrope(11, peso: FontWeight.w700, cor: isHoje ? c.teal : c.text),
                ),
                if (isHoje) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(color: c.teal, borderRadius: BorderRadius.circular(4)),
                    child: Text('HOJE', style: manrope(9, peso: FontWeight.w800, cor: Colors.white)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 2),
            Text(
              p.isDescanso ? 'Descanso' : (p.rotulo.isNotEmpty ? p.rotulo : 'Treino'),
              style: manrope(11, cor: isHoje ? c.text : c.muted),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _mudarDiaHoje(BuildContext context, int dia) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cores.surface,
        title: Text('Ajustar dia do ciclo?', style: sora(18)),
        content: Text(
          'Deseja definir o dia de HOJE como o Dia $dia do seu ciclo rotativo?',
          style: manrope(14, cor: context.cores.text, altura: 1.4),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Confirmar', style: TextStyle(color: context.cores.teal)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await repo.definirDiaAtualCiclo(dia);
    }
  }
}
