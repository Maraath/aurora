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
            aoTocar: () => abrirFormTreino(context),
          ),
        ),
        const SizedBox(height: 14),
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
          titulo: '+ Novo treino',
          detalhe: 'Nome (Treino A, B…), foco, dias da semana e exercícios com séries e repetições.',
          aoTocar: () => abrirFormTreino(context),
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
}
