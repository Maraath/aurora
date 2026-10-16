import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/habitos_repo.dart';
import '../../data/saude_repo.dart';
import '../calendario.dart';
import '../componentes.dart';
import '../em_breve.dart';
import '../saude/blocos_saude.dart';
import '../saude/form_sessao.dart';
import '../shell.dart';
import 'form_habito.dart';
import 'linha_habito.dart';

class HabitosPage extends StatefulWidget {
  const HabitosPage({super.key, required this.ir});
  final ValueChanged<Secao> ir;

  @override
  State<HabitosPage> createState() => _HabitosPageState();
}

class _HabitosPageState extends State<HabitosPage> {
  HabitosRepo? _repo;
  Stream<QuadroHabitos>? _quadro;
  Stream<QuadroSaude>? _saude;
  late DateTime _mes = hojeSP();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = AuroraEscopo.de(context).db;
    if (_repo?.db != db) {
      _repo = HabitosRepo(db);
      _quadro = _repo!.observarQuadro();
      _saude = SaudeRepo(db).observarQuadro();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuadroHabitos>(
      stream: _quadro,
      builder: (context, snap) {
        if (snap.hasError) return Text('Não consegui ler os hábitos: ${snap.error}');
        final q = snap.data;
        if (q == null) return const SizedBox(height: 200);
        return _conteudo(context, q);
      },
    );
  }

  void _editar(QuadroHabitos q, [Habito? h]) => abrirFormHabito(
        context,
        habito: h,
        metas: q.metas,
        avisar: h != null && q.comAviso.contains(h.id),
      );

  Widget _conteudo(BuildContext context, QuadroHabitos q) {
    final c = context.cores;
    final hoje = hojeSP();
    final deHoje = q.doDia(hoje);
    final outros = q.habitos.where((h) => !deHoje.contains(h)).toList();
    final feitosHoje = deHoje.where((h) => q.feito(h.id, hoje)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TituloPagina(
          'Hábitos e saúde',
          acao: BotaoRedondo(
            icone: Icons.add_rounded,
            dica: 'Novo hábito',
            preenchido: true,
            aoTocar: () => _editar(q),
          ),
        ),
        const SizedBox(height: 18),
        _Semana(quadro: q, hoje: hoje),
        const SizedBox(height: 18),
        TituloSecao(
          'Rotina de hoje',
          direita: Text('$feitosHoje/${deHoje.length}', style: rotulo(c.teal)),
        ),
        if (deHoje.isEmpty)
          const Vazio('Nenhum hábito para hoje. Toque em + para criar um.'),
        for (final h in deHoje)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: LinhaHabito(
              habito: h,
              feito: q.feito(h.id, hoje),
              detalhe: detalheHabito(h, sequencia: q.sequencia(h, hoje)),
              aoAlternar: () => _repo!.alternar(h.id, hoje, !q.feito(h.id, hoje)),
              aoEditar: () => _editar(q, h),
            ),
          ),
        if (outros.isNotEmpty) ...[
          const SizedBox(height: 10),
          const TituloSecao('Outros dias'),
          for (final h in outros)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: LinhaHabito(
                habito: h,
                feito: false,
                detalhe: detalheHabito(h, mostrarDias: true),
                aoAlternar: null,
                aoEditar: () => _editar(q, h),
              ),
            ),
        ],
        const SizedBox(height: 10),
        const TituloSecao('Calendário'),
        Cartao(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
          child: CalendarioMes(
            mes: _mes,
            hoje: hoje,
            aoMudarMes: (m) => setState(() => _mes = m),
            marcador: (d) {
              if (d.isAfter(hoje)) return null;
              final p = q.progresso(d);
              if (p == null) return null;
              return Ponto(p >= 1 ? c.teal : (p > 0 ? c.warn : (d == hoje ? c.line : c.bad)));
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Verde-água: tudo feito. Amarelo: parte. Vermelho: nada feito no dia.',
          style: manrope(12, cor: c.muted, altura: 1.5),
        ),
        const SizedBox(height: 18),
        StreamBuilder<QuadroSaude>(
          stream: _saude,
          builder: (context, snap) {
            final s = snap.data;
            if (s == null) return const SizedBox(height: 120);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CartaoTreinoDoDia(
                  quadro: s,
                  hoje: hoje,
                  aoComecar: (t) => abrirFormSessao(context, t),
                  aoAbrirFicha: () => widget.ir(Secao.treino),
                ),
                const SizedBox(height: 10),
                BlocosMedidas(quadro: s, aoTocar: () => widget.ir(Secao.medidas)),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Semana atual (segunda a domingo) com o progresso de cada dia.
class _Semana extends StatelessWidget {
  const _Semana({required this.quadro, required this.hoje});
  final QuadroHabitos quadro;
  final DateTime hoje;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final segunda = hoje.subtract(Duration(days: hoje.weekday - 1));
    return Row(
      children: [
        for (var i = 0; i < 7; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(child: _dia(c, segunda.add(Duration(days: i)))),
        ],
      ],
    );
  }

  Widget _dia(AuroraCores c, DateTime d) {
    final ehHoje = d == hoje;
    final p = quadro.progresso(d);
    final Color ponto;
    if (d.isAfter(hoje) || p == null) {
      ponto = c.line;
    } else if (p >= 1) {
      ponto = c.teal;
    } else if (ehHoje) {
      ponto = c.accent;
    } else {
      ponto = p > 0 ? c.warn : c.bad;
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: ehHoje ? c.accentSoft : c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ehHoje ? c.accent : c.line),
      ),
      child: Column(
        children: [
          Text(DateFormat('EEE', 'pt_BR').format(d).replaceAll('.', '').toUpperCase(),
              style: manrope(10, peso: FontWeight.w700, cor: c.muted)),
          const SizedBox(height: 4),
          Text('${d.day}', style: sora(15)),
          const SizedBox(height: 4),
          Ponto(ponto),
        ],
      ),
    );
  }
}
