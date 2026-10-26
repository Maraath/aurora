import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/habitos_repo.dart';
import '../calendario.dart';
import '../componentes.dart';
import '../habitos/linha_habito.dart';
import 'form_rotina.dart';

/// Rotina › Hábitos: a semana, todos os hábitos (os de hoje marcam) e o
/// calendário de constância. A análise fica em Rotina › Análise.
class HabitosRotina extends StatefulWidget {
  const HabitosRotina({super.key});

  @override
  State<HabitosRotina> createState() => _HabitosRotinaState();
}

class _HabitosRotinaState extends State<HabitosRotina> {
  HabitosRepo? _repo;
  Stream<QuadroHabitos>? _quadro;
  late DateTime _mes = hojeLocal();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = AuroraEscopo.de(context).db;
    if (_repo?.db != db) {
      _repo = HabitosRepo(db);
      _quadro = _repo!.observarQuadro();
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

  Widget _conteudo(BuildContext context, QuadroHabitos q) {
    final c = context.cores;
    final hoje = hojeLocal();
    final deHoje = q.doDia(hoje);
    final outros = q.habitos.where((h) => !deHoje.contains(h)).toList();
    final feitosHoje = deHoje.where((h) => q.feito(h.id, hoje)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Semana(quadro: q, hoje: hoje),
        const SizedBox(height: 18),
        TituloSecao(
          'Para hoje',
          direita: Text('$feitosHoje/${deHoje.length}', style: rotulo(c.corHabito)),
        ),
        if (deHoje.isEmpty) const Vazio('Nenhum hábito para hoje.'),
        for (final h in deHoje)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: LinhaHabito(
              habito: h,
              feito: q.feito(h.id, hoje),
              detalhe: detalheHabito(h, mostrarDias: true, sequencia: q.sequencia(h, hoje)),
              aoAlternar: () => _repo!.alternar(h.id, hoje, !q.feito(h.id, hoje)),
              aoEditar: () => abrirFormRotina(context, item: h),
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
                aoEditar: () => abrirFormRotina(context, item: h),
              ),
            ),
        ],
        CartaoNovo(
          titulo: 'Novo hábito',
          detalhe: 'Beber água, ler, alongar…',
          aoTocar: () => abrirFormRotina(context, tipo: TipoRotina.habito),
        ),
        const SizedBox(height: 18),
        const TituloSecao('Constância'),
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
              return Ponto(p >= 1 ? c.corHabito : (p > 0 ? c.warn : (d == hoje ? c.line : c.bad)));
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Verde: tudo feito. Amarelo: parte. Magenta: nada feito no dia.',
          style: manrope(12, cor: c.muted, altura: 1.5),
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
    final segunda = somarDias(hoje, -(hoje.weekday - 1));
    return Row(
      children: [
        for (var i = 0; i < 7; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(child: _dia(c, somarDias(segunda, i))),
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
      ponto = c.corHabito;
    } else if (ehHoje) {
      ponto = c.teal;
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
