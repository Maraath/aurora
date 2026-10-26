import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/analise_habitos.dart';
import '../../data/analise_tarefas.dart';
import '../../data/rotina_repo.dart';
import '../barras_dias.dart';
import '../componentes.dart';
import '../icone_ia.dart';

enum _Sub {
  tarefas('Tarefas', Icons.check_box_outlined),
  habitos('Hábitos', Icons.donut_large_rounded);

  const _Sub(this.rotulo, this.icone);
  final String rotulo;
  final IconData icone;
}

/// Rotina › Análise: o ritmo das tarefas e a constância dos hábitos.
class AnaliseRotina extends StatefulWidget {
  const AnaliseRotina({super.key});

  @override
  State<AnaliseRotina> createState() => _AnaliseRotinaState();
}

class _AnaliseRotinaState extends State<AnaliseRotina> {
  RotinaRepo? _repo;
  Stream<QuadroRotina>? _quadro;
  var _sub = _Sub.tarefas;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = AuroraEscopo.de(context).db;
    if (_repo?.db != db) {
      _repo = RotinaRepo(db);
      _quadro = _repo!.observarQuadro();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuadroRotina>(
      stream: _quadro,
      builder: (context, snap) {
        if (snap.hasError) return Text('Não consegui ler a rotina: ${snap.error}');
        final q = snap.data;
        if (q == null) return const SizedBox(height: 200);
        final hoje = hojeLocal();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SubAbas<_Sub>(
              opcoes: _Sub.values,
              selecionado: _sub,
              rotulo: (s) => s.rotulo,
              icone: (s) => s.icone,
              aoEscolher: (s) => setState(() => _sub = s),
            ),
            const SizedBox(height: Espaco.lg),
            ...switch (_sub) {
              _Sub.tarefas => _tarefas(context, q, hoje),
              _Sub.habitos => _habitos(context, q, hoje),
            },
          ],
        );
      },
    );
  }

  static const _diasTarefa = ['na segunda', 'na terça', 'na quarta', 'na quinta', 'na sexta', 'no sábado', 'no domingo'];
  static const _diasHabito = ['às segundas', 'às terças', 'às quartas', 'às quintas', 'às sextas', 'aos sábados', 'aos domingos'];

  List<Widget> _tarefas(BuildContext context, QuadroRotina q, DateTime hoje) {
    final c = context.cores;
    final a = analisarTarefas(q.tarefas, hoje);
    final diferenca = a.semana - a.semanaAnterior;
    final taxa = a.taxaNoPrazo;
    String plural(int n) => n == 1 ? '1 tarefa' : '$n tarefas';
    return [
      Cartao(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Concluídas nos últimos 7 dias', style: manrope(12, peso: FontWeight.w600, cor: c.muted)),
            const SizedBox(height: 2),
            Text('${a.semana}', style: sora(30)),
            Text(
              diferenca == 0
                  ? 'o mesmo que nos 7 dias anteriores'
                  : '${plural(diferenca.abs())} ${diferenca > 0 ? 'a mais' : 'a menos'} que nos 7 dias anteriores',
              style: manrope(13, peso: FontWeight.w600, cor: diferenca >= 0 ? c.teal : c.warn),
            ),
            const SizedBox(height: 16),
            BarrasDias(
              valores: [for (final d in a.porDia) d.feitas],
              rotulos: [for (final d in a.porDia) d.dia == hoje ? 'hoje' : '${d.dia.day}'],
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      const TituloSecao('No prazo'),
      Cartao(
        child: taxa == null
            ? Text('Nenhuma tarefa com prazo concluída nos últimos 30 dias.', style: manrope(14, cor: c.muted))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text('${a.noPrazo} de ${a.comPrazo} feitas até o prazo (30 dias)', style: manrope(14)),
                    ),
                    Text('${(taxa * 100).round()}%', style: sora(20, cor: taxa >= 0.7 ? c.teal : c.warn)),
                  ]),
                  const SizedBox(height: 10),
                  BarraProgresso(fracao: taxa, cor: taxa >= 0.7 ? c.teal : c.warn),
                ],
              ),
      ),
      const SizedBox(height: 18),
      LinhaContadores([
        Contador(valor: '${q.tarefas.atrasadas}', rotulo: 'atrasadas', cor: c.bad, fundo: c.badSoft),
        Contador(valor: '${q.tarefas.abertas}', rotulo: 'abertas'),
        Contador(valor: '${q.tarefas.feitasHoje}', rotulo: 'feitas hoje', cor: c.corTarefa),
      ]),
      if (a.melhorDiaSemana != null) ...[
        const SizedBox(height: 18),
        _Insight('Você conclui mais tarefas ${_diasTarefa[a.melhorDiaSemana! - 1]} (últimos 60 dias).'),
      ],
    ];
  }

  List<Widget> _habitos(BuildContext context, QuadroRotina q, DateTime hoje) {
    final c = context.cores;
    if (q.habitos.habitos.isEmpty) return const [Vazio('Crie um hábito para ver a constância aqui.')];
    final a = analisarHabitos(q.habitos, hoje);
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
                      style: manrope(14, peso: FontWeight.w700, cor: h.taxa >= 0.7 ? c.corHabito : c.text)),
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
                BarraProgresso(fracao: h.taxa, cor: c.corHabito),
              ],
            ),
          ),
        ),
      if (a.melhorDiaSemana != null) ...[
        const SizedBox(height: 10),
        _Insight('Seus hábitos rendem mais ${_diasHabito[a.melhorDiaSemana! - 1]} (últimos 60 dias).'),
      ],
    ];
  }
}

class _Insight extends StatelessWidget {
  const _Insight(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Cartao(
      child: Row(children: [
        IconeIa(size: 18, color: c.violeta),
        const SizedBox(width: 10),
        Expanded(child: Text(texto, style: manrope(14, altura: 1.4))),
      ]),
    );
  }
}
