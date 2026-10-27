import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/objetivos_repo.dart';
import '../componentes.dart';
import '../em_breve.dart';
import '../formulario.dart';
import '../tarefas/form_tarefa.dart';
import 'form_objetivo.dart';

/// Meses mostrados na linha do tempo.
const _mesesNaLinha = 5;

/// A cor do objetivo (uma das [coresObjetivo]) vira o token do tema.
Color _corObjetivo(AuroraCores c, String? cor) => switch (cor) {
      'teal' => c.teal,
      'violeta' => c.violeta,
      'warn' => c.warn,
      _ => c.accent,
    };

class ObjetivosPage extends StatefulWidget {
  const ObjetivosPage({super.key, this.voltar});
  final VoidCallback? voltar;

  @override
  State<ObjetivosPage> createState() => _ObjetivosPageState();
}

class _ObjetivosPageState extends State<ObjetivosPage> {
  ObjetivosRepo? _repo;
  Stream<List<ProgressoObjetivo>>? _objetivos;
  String _modo = 'Lista';
  String _filtro = 'Todas';
  String? _aberto;
  final _hoje = hojeLocal();
  late DateTime _janela = DateTime(_hoje.year, _hoje.month - 1, 1);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = AuroraEscopo.de(context).db;
    if (_repo?.db != db) {
      _repo = ObjetivosRepo(db);
      _objetivos = _repo!.observarObjetivos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProgressoObjetivo>>(
      stream: _objetivos,
      builder: (context, snap) {
        if (snap.hasError) return Text('Não consegui ler os objetivos: ${snap.error}');
        final lista = snap.data;
        if (lista == null) return const SizedBox(height: 200);
        final visiveis = _filtrados(lista);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TituloPagina(
              'Objetivos',
              voltar: widget.voltar,
              acao: BotaoRedondo(
                icone: Icons.add_rounded,
                dica: 'Novo objetivo',
                preenchido: true,
                aoTocar: () => abrirFormObjetivo(context),
              ),
            ),
            const SizedBox(height: 16),
            Segmentos<String>(
              opcoes: const ['Lista', 'Linha do tempo'],
              selecionado: _modo,
              rotulo: (m) => m,
              aoEscolher: (m) => setState(() => _modo = m),
            ),
            const SizedBox(height: 12),
            Segmentos<String>(
              opcoes: const ['Todas', 'Em risco', 'Em andamento', 'Paradas', 'Concluídas', 'Arquivadas'],
              selecionado: _filtro,
              rotulo: (f) => f,
              aoEscolher: (f) => setState(() => _filtro = f),
            ),
            const SizedBox(height: 18),
            if (_modo == 'Linha do tempo')
              _LinhaDoTempo(
                objetivos: visiveis.where((p) => p.estado != EstadoObjetivo.arquivada).toList(),
                hoje: _hoje,
                janela: _janela,
                aoMudarJanela: (j) => setState(() => _janela = j),
                aoEscolher: (id) => setState(() {
                  _modo = 'Lista';
                  _aberto = id;
                }),
              )
            else ...[
              for (final p in visiveis)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CartaoObjetivo(
                    progresso: p,
                    aberto: p.objetivo.id == _aberto,
                    aoTocar: () => setState(() => _aberto = p.objetivo.id == _aberto ? null : p.objetivo.id),
                    aoAtualizar: () => _atualizar(p),
                    aoAlternar: (e) => _repo!.alternarEtapa(e, !(e.feita || (e.rotina && e.ocorrencia.feita))),
                    aoNovaEtapa: (titulo) => _repo!.novaEtapa(p.objetivo.id, titulo),
                    aoAcao: (acao) => _acao(p, acao),
                  ),
                ),
              CartaoNovo(
                titulo: '+ Novo objetivo',
                detalhe: 'Uma meta com número, um plano de etapas, ou os dois. O Aurora calcula o '
                    'ritmo e liga suas tarefas e hábitos a ele.',
                aoTocar: () => abrirFormObjetivo(context),
              ),
            ],
          ],
        );
      },
    );
  }

  List<ProgressoObjetivo> _filtrados(List<ProgressoObjetivo> lista) {
    switch (_filtro) {
      case 'Em risco':
        return lista.where((p) => p.estado == EstadoObjetivo.emRisco).toList();
      case 'Em andamento':
        return lista.where((p) => p.estado == EstadoObjetivo.emDia).toList();
      case 'Paradas':
        return lista.where((p) => p.estado == EstadoObjetivo.parada).toList();
      case 'Concluídas':
        return lista.where((p) => p.estado == EstadoObjetivo.concluida).toList();
      case 'Arquivadas':
        return lista.where((p) => p.estado == EstadoObjetivo.arquivada).toList();
      default:
        return lista;
    }
  }

  /// Pergunta só o valor de hoje (o jeito rápido de registrar avanço).
  Future<void> _atualizar(ProgressoObjetivo p) async {
    final o = p.objetivo;
    final c = context.cores;
    final controle = TextEditingController(text: valorParaCampo(o.valorAtual, o.unidade));
    final valor = await showDialog<double>(
      context: context,
      builder: (ctx) {
        void confirmar() => Navigator.pop(ctx, lerValorMeta(controle.text, o.unidade));
        return AlertDialog(
          backgroundColor: c.surface,
          title: Text('Onde você está hoje?', style: sora(18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${o.nome} · alvo ${valorMeta(o.valorAlvo, o.unidade)}', style: manrope(13, cor: c.muted)),
              const SizedBox(height: 12),
              CampoTexto(controle: controle, dica: '0', decimal: true, autofoco: true),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            TextButton(onPressed: confirmar, child: const Text('Salvar')),
          ],
        );
      },
    );
    controle.dispose();
    if (valor != null) await _repo!.atualizarValor(o.id, valor);
  }

  /// Ações do menu: pausar, concluir, arquivar, reabrir, excluir.
  Future<void> _acao(ProgressoObjetivo p, String acao) async {
    final o = p.objetivo;
    switch (acao) {
      case 'pausar':
        await _repo!.mudarStatus(o.id, 'pausada');
      case 'retomar' || 'reabrir':
        await _repo!.mudarStatus(o.id, 'ativa');
      case 'concluir':
        await _repo!.mudarStatus(o.id, 'concluida');
        if (o.unidade.isNotEmpty) await _repo!.atualizarValor(o.id, o.valorAlvo);
      case 'arquivar':
        await _repo!.mudarStatus(o.id, 'arquivada');
      case 'excluir':
        final c = context.cores;
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: c.surface,
            title: Text('Excluir objetivo?', style: sora(18)),
            content: Text('“${o.nome}” sai da lista. Tarefas e hábitos ligados continuam.',
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
        if (ok == true && mounted) await _repo!.excluir(o.id);
    }
  }
}

/// Cartão de objetivo: número (com ritmo) e/ou etapas, conforme o que ele tem.
class _CartaoObjetivo extends StatefulWidget {
  const _CartaoObjetivo({
    required this.progresso,
    required this.aberto,
    required this.aoTocar,
    required this.aoAtualizar,
    required this.aoAlternar,
    required this.aoNovaEtapa,
    required this.aoAcao,
  });

  final ProgressoObjetivo progresso;
  final bool aberto;
  final VoidCallback aoTocar;
  final VoidCallback aoAtualizar;
  final ValueChanged<EtapaObjetivo> aoAlternar;
  final ValueChanged<String> aoNovaEtapa;
  final ValueChanged<String> aoAcao;

  @override
  State<_CartaoObjetivo> createState() => _CartaoObjetivoState();
}

class _CartaoObjetivoState extends State<_CartaoObjetivo> {
  final _nova = TextEditingController();

  @override
  void dispose() {
    _nova.dispose();
    super.dispose();
  }

  void _adicionar() {
    final t = _nova.text.trim();
    if (t.isEmpty) return;
    widget.aoNovaEtapa(t);
    _nova.clear();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final p = widget.progresso;
    final o = p.objetivo;
    final corEstado = switch (p.estado) {
      EstadoObjetivo.emDia || EstadoObjetivo.concluida => c.teal,
      EstadoObjetivo.emRisco => c.bad,
      EstadoObjetivo.parada => c.warn,
      EstadoObjetivo.pausada || EstadoObjetivo.arquivada => c.muted,
    };
    final concluida = p.estado == EstadoObjetivo.concluida;
    final arquivada = p.estado == EstadoObjetivo.arquivada;
    final pausada = p.estado == EstadoObjetivo.pausada;
    final ativa = !concluida && !arquivada && !pausada;
    final corObjetivo = _corObjetivo(c, o.cor);

    final ligados = [
      if (p.tarefasLigadas > 0)
        '${p.tarefasLigadas} ${p.tarefasLigadas == 1 ? 'tarefa' : 'tarefas'}'
            '${p.tarefasAbertas > 0 ? ' (${p.tarefasAbertas} em aberto)' : ''}',
      if (p.habitosLigados > 0)
        '${p.habitosLigados} ${p.habitosLigados == 1 ? 'hábito' : 'hábitos'}',
    ];
    final nota = switch (p.estado) {
      EstadoObjetivo.parada => 'Nenhum avanço há mais de $diasParaParada dias.',
      EstadoObjetivo.emRisco => 'Você está atrás do ritmo do prazo.',
      EstadoObjetivo.emDia => 'No ritmo.',
      EstadoObjetivo.pausada => 'Pausada.',
      EstadoObjetivo.concluida => 'Objetivo alcançado.',
      EstadoObjetivo.arquivada => 'Arquivada.',
    };

    return Cartao(
      aoTocar: widget.aoTocar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(width: 10, height: 10, decoration: BoxDecoration(color: corObjetivo, shape: BoxShape.circle)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o.nome, style: sora(18)),
                    if (o.descricao != null && o.descricao!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(o.descricao!, style: manrope(12, cor: c.muted, altura: 1.4)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Etiqueta(p.estado.rotulo, cor: corEstado),
            ],
          ),
          if (p.temNumero) ...[
            const SizedBox(height: 14),
            if (concluida)
              Text(valorMeta(o.valorAlvo, o.unidade), style: sora(26))
            else ...[
              Text('faltam ${valorMeta((o.valorAlvo - o.valorAtual).abs(), o.unidade)}', style: sora(26)),
              const SizedBox(height: 2),
              Text('${valorMeta(o.valorAtual, o.unidade)} → ${valorMeta(o.valorAlvo, o.unidade)}',
                  style: manrope(12, cor: c.muted)),
              const SizedBox(height: 10),
              _BarraRitmo(progresso: p.progresso, tempo: p.tempo),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('feito ${(p.progresso * 100).round()}%', style: manrope(11, cor: c.muted)),
                  if (p.tempo != null)
                    Text('ritmo ideal ${(p.tempo! * 100).round()}%', style: manrope(11, cor: c.violeta)),
                ],
              ),
            ],
          ],
          if (p.temEtapas) ...[
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: Text('Etapas', style: manrope(12, cor: c.muted))),
              Text('${p.feitas} de ${p.total}', style: manrope(12, cor: c.muted)),
            ]),
            const SizedBox(height: 6),
            BarraProgresso(fracao: p.progressoEtapas, cor: corEstado == c.bad ? c.bad : c.teal),
            if (widget.aberto) ...[
              const SizedBox(height: 8),
              for (final e in p.etapas) _linhaEtapa(e),
              if (ativa)
                Container(
                  padding: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: c.line))),
                  child: Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _nova,
                        onSubmitted: (_) => _adicionar(),
                        textCapitalization: TextCapitalization.sentences,
                        style: manrope(14),
                        decoration: InputDecoration(
                          hintText: 'Nova etapa…',
                          hintStyle: manrope(14, cor: c.muted),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Adicionar etapa',
                      onPressed: _adicionar,
                      icon: Icon(Icons.add_circle_outline_rounded, color: c.accent),
                    ),
                    IconButton(
                      tooltip: 'Etapa com data e lembrete',
                      onPressed: () => abrirFormTarefa(context, objetivoInicial: o.id, dataInicial: null),
                      icon: Icon(Icons.event_note_outlined, color: c.muted),
                    ),
                  ]),
                ),
            ],
          ],
          if (nota.isNotEmpty && !concluida && !arquivada) ...[
            const SizedBox(height: 10),
            Text(nota, style: manrope(13, peso: FontWeight.w600, cor: corEstado)),
          ],
          if (p.ritmo != null) ...[
            const SizedBox(height: 8),
            Text(p.ritmo!, style: manrope(12.5, cor: c.muted, altura: 1.5)),
          ],
          if (ligados.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('${ligados.join(' e ')} a este objetivo.', style: manrope(12, cor: c.muted)),
          ],
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ativa
                      ? (p.temNumero
                          ? BotaoPilula(
                              texto: 'Atualizar progresso', principal: false, aoTocar: widget.aoAtualizar)
                          : const SizedBox.shrink())
                      : (pausada
                          ? BotaoPilula(
                              texto: 'Retomar', principal: false, aoTocar: () => widget.aoAcao('retomar'))
                          : const SizedBox.shrink()),
                ),
              ),
            ),
            _MenuAcoes(aoAcao: widget.aoAcao, pausada: pausada, concluida: concluida, arquivada: arquivada),
          ]),
        ],
      ),
    );
  }

  Widget _linhaEtapa(EtapaObjetivo e) {
    final c = context.cores;
    final feita = e.feita || (e.rotina && e.ocorrencia.feita);
    final corDetalhe = feita ? c.teal : (e.atrasada ? c.bad : c.muted);
    return Container(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: c.line))),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Concluir etapa ${e.tarefa.titulo}',
            onPressed: () => widget.aoAlternar(e),
            icon: Icon(
              feita ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
              color: feita ? c.teal : c.muted,
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => abrirFormTarefa(context, tarefa: e.tarefa),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.tarefa.titulo,
                      style: manrope(14, peso: FontWeight.w600, cor: e.feita ? c.muted : c.text)
                          .copyWith(decoration: e.feita ? TextDecoration.lineThrough : null),
                    ),
                    Text(
                      e.rotina && e.ocorrencia.feita
                          ? '${detalheEtapa(e, widget.progresso.hoje)} · feita hoje'
                          : detalheEtapa(e, widget.progresso.hoje),
                      style: manrope(12, cor: corDetalhe),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra única com o marcador de "onde você deveria estar" (pelo prazo).
class _BarraRitmo extends StatelessWidget {
  const _BarraRitmo({required this.progresso, required this.tempo});
  final double progresso;
  final double? tempo;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return SizedBox(
      height: 12,
      child: LayoutBuilder(builder: (context, box) {
        final w = box.maxWidth;
        return Stack(children: [
          Container(
            height: 10,
            decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(5)),
          ),
          FractionallySizedBox(
            widthFactor: progresso.clamp(0.0, 1.0),
            child: Container(
              height: 10,
              decoration: BoxDecoration(color: c.teal, borderRadius: BorderRadius.circular(5)),
            ),
          ),
          if (tempo != null)
            Positioned(
              left: (tempo! * w).clamp(0.0, w),
              top: -2,
              bottom: -2,
              child: Container(width: 3, decoration: BoxDecoration(color: c.violeta, borderRadius: BorderRadius.circular(2))),
            ),
        ]);
      }),
    );
  }
}

/// Menu ⋯ com pausar, concluir, arquivar, reabrir e excluir.
class _MenuAcoes extends StatelessWidget {
  const _MenuAcoes({required this.aoAcao, this.pausada = false, this.concluida = false, this.arquivada = false});
  final ValueChanged<String> aoAcao;
  final bool pausada;
  final bool concluida;
  final bool arquivada;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final itens = <(String, IconData)>[
      if (arquivada) ('reabrir', Icons.unarchive_outlined),
      if (pausada) ('retomar', Icons.play_arrow_rounded),
      if (!pausada && !concluida && !arquivada) ('pausar', Icons.pause_rounded),
      if (!concluida && !arquivada) ('concluir', Icons.check_rounded),
      if (!arquivada) ('arquivar', Icons.archive_outlined),
      ('excluir', Icons.delete_outline_rounded),
    ];
    return PopupMenuButton<String>(
      tooltip: 'Mais ações',
      onSelected: aoAcao,
      itemBuilder: (context) => [
        for (final (id, icone) in itens)
          PopupMenuItem<String>(
            value: id == 'excluir' ? 'excluir' : id,
            child: Row(children: [
              Icon(icone, size: 18, color: id == 'excluir' ? c.bad : c.text),
              const SizedBox(width: 10),
              Text(_rotulo(id)),
            ]),
          ),
      ],
      icon: Icon(Icons.more_horiz_rounded, color: c.muted),
    );
  }

  String _rotulo(String id) => switch (id) {
        'pausar' => 'Pausar',
        'retomar' || 'reabrir' => 'Reabrir',
        'concluir' => 'Concluir',
        'arquivar' => 'Arquivar',
        'excluir' => 'Excluir',
        _ => id,
      };
}

/// Linha do tempo (Gantt): cada objetivo numa barra, do começo ao fim, com o
/// quanto já foi feito preenchido. A linha vertical é hoje.
class _LinhaDoTempo extends StatelessWidget {
  const _LinhaDoTempo({
    required this.objetivos,
    required this.hoje,
    required this.janela,
    required this.aoMudarJanela,
    required this.aoEscolher,
  });

  final List<ProgressoObjetivo> objetivos;
  final DateTime hoje;
  final DateTime janela;
  final ValueChanged<DateTime> aoMudarJanela;
  final ValueChanged<String> aoEscolher;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final fimJanela = DateTime(janela.year, janela.month + _mesesNaLinha, 1);
    final totalDias = diasEntre(janela, fimJanela).toDouble();
    double pos(DateTime d) => (diasEntre(janela, d) / totalDias).clamp(0.0, 1.0);

    return Cartao(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(child: Text('LINHA DO TEMPO', style: rotulo(c.muted))),
            IconButton(
              tooltip: 'Meses anteriores',
              onPressed: () => aoMudarJanela(DateTime(janela.year, janela.month - 1, 1)),
              icon: Icon(Icons.chevron_left_rounded, color: c.muted),
            ),
            IconButton(
              tooltip: 'Próximos meses',
              onPressed: () => aoMudarJanela(DateTime(janela.year, janela.month + 1, 1)),
              icon: Icon(Icons.chevron_right_rounded, color: c.muted),
            ),
          ]),
          Row(children: [
            for (var i = 0; i < _mesesNaLinha; i++)
              Expanded(
                child: Text(mesCurto(DateTime(janela.year, janela.month + i, 1)),
                    style: manrope(11, peso: FontWeight.w700, cor: c.muted)),
              ),
          ]),
          const SizedBox(height: 8),
          LayoutBuilder(builder: (context, box) {
            final w = box.maxWidth;
            final hojeVisivel = !hoje.isBefore(janela) && hoje.isBefore(fimJanela);
            return Stack(
              children: [
                Column(children: [
                  for (final p in objetivos)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: SizedBox(
                        height: 30,
                        child: Stack(children: [
                          if (!p.fim!.isBefore(janela) && p.inicio.isBefore(fimJanela))
                            Positioned(
                              left: pos(p.inicio) * w,
                              width: ((pos(p.fim!) - pos(p.inicio)) * w).clamp(30.0, w),
                              top: 0,
                              bottom: 0,
                              child: _Barra(
                                progresso: p,
                                aoTocar: () => aoEscolher(p.objetivo.id),
                              ),
                            ),
                        ]),
                      ),
                    ),
                ]),
                if (hojeVisivel)
                  Positioned(
                    left: pos(hoje) * w - 1,
                    top: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: Container(
                        width: 2,
                        decoration: BoxDecoration(color: c.accent, borderRadius: BorderRadius.circular(1)),
                      ),
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(height: 10),
          Text('A linha verde é hoje. A parte preenchida de cada barra é o que já foi feito.',
              style: manrope(12, cor: c.muted, altura: 1.4)),
        ],
      ),
    );
  }
}

class _Barra extends StatelessWidget {
  const _Barra({required this.progresso, required this.aoTocar});
  final ProgressoObjetivo progresso;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final cor = progresso.estado == EstadoObjetivo.emRisco ? c.bad : c.teal;
    return Semantics(
      button: true,
      label: 'Abrir ${progresso.objetivo.nome}',
      child: Material(
        color: c.surface2,
        shape: StadiumBorder(side: BorderSide(color: c.line, width: 1)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          child: Stack(children: [
            FractionallySizedBox(
              widthFactor: progresso.progresso.clamp(0.0, 1.0),
              heightFactor: 1,
              child: ColoredBox(color: cor.withValues(alpha: 0.35)),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(progresso.objetivo.nome,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    softWrap: false,
                    style: manrope(12, peso: FontWeight.w700)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
