import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../icone_ia.dart';
import '../../app.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/analise_habitos.dart';
import '../../data/habitos_repo.dart';
import '../barras_dias.dart';
import '../calendario.dart';
import '../componentes.dart';
import '../em_breve.dart';
import 'form_habito.dart';
import 'linha_habito.dart';

class HabitosPage extends StatefulWidget {
  const HabitosPage({super.key});

  @override
  State<HabitosPage> createState() => _HabitosPageState();
}

class _HabitosPageState extends State<HabitosPage> {
  HabitosRepo? _repo;
  Stream<QuadroHabitos>? _quadro;
  late DateTime _mes = hojeSP();
  _Aba _aba = _Aba.hoje;

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

  void _editar(QuadroHabitos q, [Habito? h]) => abrirFormHabito(
        context,
        habito: h,
        metas: q.metas,
        avisar: h != null && q.comAviso.contains(h.id),
      );

  static const _diasSemana = ['às segundas', 'às terças', 'às quartas', 'às quintas', 'às sextas', 'aos sábados', 'aos domingos'];

  List<Widget> _analise(QuadroHabitos q, DateTime hoje) {
    final c = context.cores;
    final a = analisarHabitos(q, hoje);
    if (q.habitos.isEmpty) return const [Vazio('Crie um hábito para ver a constância aqui.')];
    final taxa = a.taxa30;
    return [
      Cartao(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Constância nos últimos 30 dias', style: manrope(12, peso: FontWeight.w600, cor: c.muted)),
            const SizedBox(height: 2),
            Text(taxa == null ? '—' : '${(taxa * 100).round()}%', style: sora(30)),
            Text('média do que foi feito em cada dia', style: manrope(13, cor: c.muted)),
            const SizedBox(height: 16),
            BarrasDias(
              valores: [for (final d in a.porDia) d.progresso ?? 0],
              maximo: 1,
              rotulos: [for (final d in a.porDia) d.dia == hoje ? 'hoje' : '${d.dia.day}'],
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      const TituloSecao('Por hábito'),
      for (final h in a.habitos)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Cartao(
            raio: 16,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  Expanded(child: Text(h.habito.nome, style: manrope(15, peso: FontWeight.w600))),
                  Text(h.devidos == 0 ? '—' : '${(h.taxa * 100).round()}%',
                      style: manrope(14, peso: FontWeight.w700, cor: h.taxa >= 0.7 ? c.teal : c.text)),
                ]),
                Text(
                  [
                    '${h.feitos} de ${h.devidos} dias',
                    if (h.sequencia > 0) 'sequência de ${h.sequencia}',
                    if (h.melhorSequencia > 1) 'recorde ${h.melhorSequencia}',
                  ].join(' · '),
                  style: manrope(12, cor: c.muted),
                ),
                const SizedBox(height: 10),
                BarraProgresso(fracao: h.taxa, cor: c.teal),
              ],
            ),
          ),
        ),
      if (a.melhorDiaSemana != null) ...[
        const SizedBox(height: 10),
        Cartao(
          child: Row(children: [
            IconeIa(size: 18, color: c.violeta),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Seus hábitos rendem mais ${_diasSemana[a.melhorDiaSemana! - 1]} (últimos 60 dias).',
                  style: manrope(14, altura: 1.4)),
            ),
          ]),
        ),
      ],
    ];
  }

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
          'Hábitos',
          acao: BotaoRedondo(
            icone: Icons.add_rounded,
            dica: 'Novo hábito',
            preenchido: true,
            aoTocar: () => _editar(q),
          ),
        ),
        const SizedBox(height: 14),
        Segmentos<_Aba>(
          opcoes: _Aba.values,
          selecionado: _aba,
          rotulo: (a) => a.rotulo,
          aoEscolher: (a) => setState(() => _aba = a),
        ),
        const SizedBox(height: 18),
        if (_aba == _Aba.hoje) ...[
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
        ] else if (_aba == _Aba.analise) ...[
          ..._analise(q, hoje),
        ] else ...[
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
            'Turquesa: tudo feito. Amarelo: parte. Magenta: nada feito no dia.',
            style: manrope(12, cor: c.muted, altura: 1.5),
          ),
        ],
      ],
    );
  }
}

enum _Aba {
  hoje('Hoje'),
  calendario('Calendário'),
  analise('Análise');

  const _Aba(this.rotulo);
  final String rotulo;
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
