import 'package:flutter/material.dart';

import '../icone_ia.dart';
import '../../app.dart';
import '../../core/formato.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/analise_tarefas.dart';
import '../../data/banco.dart';
import '../../data/tarefas_repo.dart';
import '../barras_dias.dart';
import '../calendario.dart';
import '../componentes.dart';
import '../em_breve.dart';
import 'form_tarefa.dart';
import 'linha_tarefa.dart';

enum _Vista {
  agora('Agora'),
  todas('Todas'),
  recorrentes('Recorrentes'),
  calendario('Calendário'),
  analise('Análise');

  const _Vista(this.rotulo);
  final String rotulo;
}

class TarefasPage extends StatefulWidget {
  const TarefasPage({super.key});

  @override
  State<TarefasPage> createState() => _TarefasPageState();
}

class _TarefasPageState extends State<TarefasPage> {
  TarefasRepo? _repo;
  Stream<QuadroTarefas>? _quadro;
  var _vista = _Vista.agora;
  late DateTime _mes = hojeLocal();
  late DateTime _diaSelecionado = hojeLocal();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = AuroraEscopo.de(context).db;
    if (_repo?.db != db) {
      _repo = TarefasRepo(db);
      _quadro = _repo!.observarQuadro();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuadroTarefas>(
      stream: _quadro,
      builder: (context, snap) {
        if (snap.hasError) return Text('Não consegui ler as tarefas: ${snap.error}');
        final q = snap.data;
        if (q == null) return const SizedBox(height: 200);
        return _conteudo(context, q);
      },
    );
  }

  Widget _conteudo(BuildContext context, QuadroTarefas q) {
    final c = context.cores;
    final hoje = hojeLocal();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TituloPagina(
          'Tarefas',
          acao: BotaoRedondo(
            icone: Icons.add_rounded,
            dica: 'Nova tarefa',
            preenchido: true,
            aoTocar: () => abrirFormTarefa(context,
                dataInicial: _vista == _Vista.calendario ? _diaSelecionado : null),
          ),
        ),
        const SizedBox(height: 18),
        LinhaContadores([
          Contador(valor: '${q.atrasadas}', rotulo: 'atrasadas', cor: c.bad, fundo: c.badSoft),
          Contador(valor: '${q.abertas}', rotulo: 'abertas'),
          Contador(valor: '${q.feitasHoje}', rotulo: 'feitas hoje', cor: c.teal, fundo: c.tealSoft),
        ]),
        const SizedBox(height: 18),
        Segmentos<_Vista>(
          opcoes: _Vista.values,
          selecionado: _vista,
          rotulo: (v) => v.rotulo,
          aoEscolher: (v) => setState(() => _vista = v),
        ),
        const SizedBox(height: 18),
        ...switch (_vista) {
          _Vista.agora => _agora(q, hoje),
          _Vista.todas => _todas(q, hoje),
          _Vista.recorrentes => _recorrentes(q, hoje),
          _Vista.calendario => _calendario(q, hoje),
          _Vista.analise => _analise(q, hoje),
        },
      ],
    );
  }

  Widget _linha(OcorrenciaTarefa o, DateTime hoje) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: LinhaTarefa(
          ocorrencia: o,
          hoje: hoje,
          aoAlternar: () => _repo!.alternar(o, !o.feita),
          aoEditar: () => abrirFormTarefa(context, tarefa: o.tarefa),
        ),
      );

  List<Widget> _agora(QuadroTarefas q, DateTime hoje) {
    final lista = q.resolverAgora(hoje);
    return [
      const TituloSecao('Resolver agora'),
      if (lista.isEmpty) const Vazio('Nada atrasado nem para hoje. Toque em + para criar uma tarefa.'),
      for (final o in lista) _linha(o, hoje),
    ];
  }

  List<Widget> _todas(QuadroTarefas q, DateTime hoje) {
    final amanha = somarDias(hoje, 1);
    final grupos = <String, List<OcorrenciaTarefa>>{
      'Atrasadas': [],
      'Hoje': [],
      'Amanhã': [],
      'Próximos dias': [],
      'Sem data': [],
      'Concluídas hoje': [],
    };
    for (final o in q.atuais) {
      final grupo = o.feita
          ? 'Concluídas hoje'
          : o.atrasada
              ? 'Atrasadas'
              : o.dia == null
                  ? 'Sem data'
                  : o.dia == hoje
                      ? 'Hoje'
                      : o.dia == amanha
                          ? 'Amanhã'
                          : 'Próximos dias';
      grupos[grupo]!.add(o);
    }
    if (q.atuais.isEmpty) return const [Vazio('Nenhuma tarefa ainda. Toque em + para criar.')];
    return [
      for (final MapEntry(key: nome, value: itens) in grupos.entries)
        if (itens.isNotEmpty) ...[
          TituloSecao(nome, direita: Text('${itens.length}', style: rotulo(context.cores.muted))),
          for (final o in itens) _linha(o, hoje),
          const SizedBox(height: 10),
        ],
    ];
  }

  List<Widget> _recorrentes(QuadroTarefas q, DateTime hoje) => [
        const TituloSecao('Repetem sozinhas'),
        if (q.recorrentes.isEmpty)
          const Vazio('Nenhuma tarefa recorrente. Ao criar uma tarefa, escolha em "Repetir".'),
        for (final o in q.recorrentes) _linha(o, hoje),
        const SizedBox(height: 4),
        Text(
          'Cada repetição aparece no dia dela. Repetições que passaram sem ser feitas '
          'não se acumulam como atrasadas.',
          style: manrope(12, cor: context.cores.muted, altura: 1.5),
        ),
      ];

  static const _diasSemana = ['na segunda', 'na terça', 'na quarta', 'na quinta', 'na sexta', 'no sábado', 'no domingo'];

  List<Widget> _analise(QuadroTarefas q, DateTime hoje) {
    final c = context.cores;
    final a = analisarTarefas(q, hoje);
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
            ? Text('Nenhuma tarefa com prazo concluída nos últimos 30 dias.',
                style: manrope(14, cor: c.muted))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text('${a.noPrazo} de ${a.comPrazo} feitas até o prazo (30 dias)',
                          style: manrope(14)),
                    ),
                    Text('${(taxa * 100).round()}%', style: sora(20, cor: taxa >= 0.7 ? c.teal : c.warn)),
                  ]),
                  const SizedBox(height: 10),
                  BarraProgresso(fracao: taxa, cor: taxa >= 0.7 ? c.teal : c.warn),
                ],
              ),
      ),
      const SizedBox(height: 18),
      const TituloSecao('Abertas por prioridade'),
      LinhaContadores([
        Contador(
            valor: '${a.abertasPorPrioridade[Prioridade.alta]}', rotulo: 'alta', cor: c.bad, fundo: c.badSoft),
        Contador(valor: '${a.abertasPorPrioridade[Prioridade.media]}', rotulo: 'média'),
        Contador(valor: '${a.abertasPorPrioridade[Prioridade.baixa]}', rotulo: 'baixa'),
      ]),
      if (a.melhorDiaSemana != null) ...[
        const SizedBox(height: 18),
        Cartao(
          child: Row(children: [
            IconeIa(size: 18, color: c.violeta),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Você conclui mais tarefas ${_diasSemana[a.melhorDiaSemana! - 1]} (últimos 60 dias).',
                style: manrope(14, altura: 1.4),
              ),
            ),
          ]),
        ),
      ],
    ];
  }

  List<Widget> _calendario(QuadroTarefas q, DateTime hoje) {
    final c = context.cores;
    final inicio = DateTime(_mes.year, _mes.month, 1);
    final fim = DateTime(_mes.year, _mes.month + 1, 0);
    final porDia = q.porDia(inicio, fim, agoraLocal());
    final doDia = (porDia[_diaSelecionado] ??
        q.porDia(_diaSelecionado, _diaSelecionado, agoraLocal())[_diaSelecionado] ??
        const []);
    return [
      Cartao(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
        child: CalendarioMes(
          mes: _mes,
          hoje: hoje,
          selecionado: _diaSelecionado,
          aoSelecionar: (d) => setState(() => _diaSelecionado = d),
          aoMudarMes: (m) => setState(() => _mes = m),
          marcador: (d) {
            final itens = porDia[d];
            if (itens == null || itens.isEmpty) return null;
            final cor = itens.any((o) => o.atrasada)
                ? c.bad
                : itens.every((o) => o.feita)
                    ? c.teal
                    : c.accent;
            return Ponto(cor);
          },
        ),
      ),
      const SizedBox(height: 18),
      TituloSecao(diaRelativo(_diaSelecionado, hoje)),
      if (doDia.isEmpty) const Vazio('Nada neste dia.'),
      for (final o in doDia) _linha(o, hoje),
    ];
  }
}
