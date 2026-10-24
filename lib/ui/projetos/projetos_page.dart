import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/projetos_repo.dart';
import '../../data/tarefas_repo.dart';
import '../componentes.dart';
import '../em_breve.dart';
import '../vidro.dart';
import '../tarefas/form_tarefa.dart';
import 'form_projeto.dart';

/// Meses mostrados na linha do tempo.
const _mesesNaLinha = 5;

class ProjetosPage extends StatefulWidget {
  const ProjetosPage({super.key, this.voltar});
  final VoidCallback? voltar;

  @override
  State<ProjetosPage> createState() => _ProjetosPageState();
}

class _ProjetosPageState extends State<ProjetosPage> {
  ProjetosRepo? _repo;
  Stream<List<ProgressoProjeto>>? _projetos;
  String? _aberto;
  final _hoje = hojeLocal();

  /// Primeiro mês da linha do tempo (começa no mês passado).
  late DateTime _janela = DateTime(_hoje.year, _hoje.month - 1, 1);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = AuroraEscopo.de(context).db;
    if (_repo?.db != db) {
      _repo = ProjetosRepo(db);
      _projetos = _repo!.observarProjetos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProgressoProjeto>>(
      stream: _projetos,
      builder: (context, snap) {
        if (snap.hasError) return Text('Não consegui ler os projetos: ${snap.error}');
        final lista = snap.data;
        if (lista == null) return const SizedBox(height: 200);
        final aberto = lista.any((p) => p.projeto.id == _aberto)
            ? _aberto
            : lista.where((p) => p.estado != EstadoProjeto.arquivado).firstOrNull?.projeto.id;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TituloPagina(
              'Projetos',
              voltar: widget.voltar,
              acao: BotaoRedondo(
                icone: Icons.add_rounded,
                dica: 'Novo projeto',
                preenchido: true,
                aoTocar: () => abrirFormProjeto(context),
              ),
            ),
            const SizedBox(height: 18),
            if (lista.any((p) => p.estado != EstadoProjeto.arquivado)) ...[
              _LinhaDoTempo(
                projetos: lista.where((p) => p.estado != EstadoProjeto.arquivado).toList(),
                hoje: _hoje,
                janela: _janela,
                aberto: aberto,
                aoMudarJanela: (j) => setState(() => _janela = j),
                aoEscolher: (id) => setState(() => _aberto = id),
              ),
              const SizedBox(height: 18),
            ],
            for (final p in lista)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CartaoProjeto(
                  progresso: p,
                  aberto: p.projeto.id == aberto,
                  aoTocar: () => setState(() => _aberto = p.projeto.id == aberto ? '' : p.projeto.id),
                  aoAlternar: (e) => TarefasRepo(_repo!.db).alternar(e.ocorrencia, !e.ocorrencia.feita),
                  aoNovaEtapa: (titulo) => _repo!.novaEtapa(p.projeto.id, titulo),
                ),
              ),
            CartaoNovo(
              titulo: '+ Novo projeto',
              detalhe: 'Um objetivo com começo e fim, dividido em etapas. Cada etapa vira uma tarefa, '
                  'e o Aurora mostra se o projeto está em dia ou em risco.',
              aoTocar: () => abrirFormProjeto(context),
            ),
          ],
        );
      },
    );
  }
}

class _LinhaDoTempo extends StatelessWidget {
  const _LinhaDoTempo({
    required this.projetos,
    required this.hoje,
    required this.janela,
    required this.aberto,
    required this.aoMudarJanela,
    required this.aoEscolher,
  });

  final List<ProgressoProjeto> projetos;
  final DateTime hoje;
  final DateTime janela;
  final String? aberto;
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
                  for (final p in projetos)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: SizedBox(
                        height: 30,
                        child: Stack(children: [
                          if (!p.fim.isBefore(janela) && p.inicio.isBefore(fimJanela))
                            Positioned(
                              left: pos(p.inicio) * w,
                              width: ((pos(p.fim) - pos(p.inicio)) * w).clamp(30.0, w),
                              top: 0,
                              bottom: 0,
                              child: _Barra(
                                progresso: p,
                                aberto: p.projeto.id == aberto,
                                aoTocar: () => aoEscolher(p.projeto.id),
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
          Text('A linha azul é hoje. A parte preenchida de cada barra é o quanto já foi feito.',
              style: manrope(12, cor: c.muted, altura: 1.4)),
        ],
      ),
    );
  }
}

class _Barra extends StatelessWidget {
  const _Barra({required this.progresso, required this.aberto, required this.aoTocar});
  final ProgressoProjeto progresso;
  final bool aberto;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final cor = progresso.estado == EstadoProjeto.emRisco ? c.bad : c.teal;
    return Semantics(
      button: true,
      label: 'Abrir ${progresso.projeto.nome}',
      child: Material(
        color: aberto ? c.accentSoft : c.surface2,
        shape: StadiumBorder(side: BorderSide(color: aberto ? c.accent : c.line, width: aberto ? 1.5 : 1)),
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
                child: Text(progresso.projeto.nome,
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

class _CartaoProjeto extends StatefulWidget {
  const _CartaoProjeto({
    required this.progresso,
    required this.aberto,
    required this.aoTocar,
    required this.aoAlternar,
    required this.aoNovaEtapa,
  });

  final ProgressoProjeto progresso;
  final bool aberto;
  final VoidCallback aoTocar;
  final ValueChanged<EtapaProjeto> aoAlternar;
  final ValueChanged<String> aoNovaEtapa;

  @override
  State<_CartaoProjeto> createState() => _CartaoProjetoState();
}

class _CartaoProjetoState extends State<_CartaoProjeto> {
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
    final corEstado = switch (p.estado) {
      EstadoProjeto.emDia => c.accent,
      EstadoProjeto.emRisco => c.bad,
      EstadoProjeto.concluido => c.teal,
      EstadoProjeto.arquivado => c.muted,
    };
    final rotinas = p.etapas.where((e) => e.rotina).length;

    final escuro = Theme.of(context).brightness == Brightness.dark;
    final cartao = Material(
      color: escuro ? Colors.transparent : c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: escuro && !widget.aberto
            ? BorderSide.none
            : BorderSide(color: widget.aberto ? c.accent : c.line, width: widget.aberto ? 1.5 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: widget.aoTocar,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.projeto.nome, style: sora(18)),
                        const SizedBox(height: 2),
                        Text('${diaMesCurto(p.inicio)} → ${diaMesCurto(p.fim)} · ${p.textoPrazo}',
                            style: manrope(12, cor: c.muted)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Etiqueta(p.estado.rotulo, cor: corEstado),
                  IconButton(
                    tooltip: 'Editar projeto',
                    onPressed: () => abrirFormProjeto(context, projeto: p.projeto),
                    icon: Icon(Icons.edit_outlined, size: 20, color: c.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: Text('Etapas', style: manrope(12, cor: c.muted))),
              Text('${p.feitas} de ${p.total}', style: manrope(12, cor: c.muted)),
            ]),
            const SizedBox(height: 6),
            BarraProgresso(fracao: p.progresso, cor: p.estado == EstadoProjeto.emRisco ? c.bad : c.teal),
            if (widget.aberto) ...[
              const SizedBox(height: 8),
              for (final e in p.etapas) _linhaEtapa(context, c, e),
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
                    onPressed: () => abrirFormTarefa(context, projetoInicial: p.projeto.id, dataInicial: null),
                    icon: Icon(Icons.event_note_outlined, color: c.muted),
                  ),
                ]),
              ),
              if (p.meta != null || rotinas > 0) ...[
                const SizedBox(height: 6),
                Wrap(spacing: 6, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
                  Text('Ligado a:', style: manrope(11, peso: FontWeight.w600, cor: c.muted)),
                  if (p.meta != null) _Selo('Meta ${p.meta!.nome}'),
                  if (rotinas > 0) _Selo('$rotinas ${rotinas == 1 ? 'rotina' : 'rotinas'}'),
                ]),
              ],
            ],
          ],
        ),
      ),
    );
    if (!escuro) return cartao;
    // Vidro por trás; a borda verde de "aberto" fica no Material, por cima.
    return Vidro(raio: BorderRadius.circular(20), borda: !widget.aberto, child: cartao);
  }

  Widget _linhaEtapa(BuildContext context, AuroraCores c, EtapaProjeto e) {
    final feita = e.feita || (e.rotina && e.ocorrencia.feita);
    final corDetalhe = feita ? c.teal : (e.atrasada ? c.bad : c.muted);
    return Container(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: c.line))),
      child: Row(
        children: [
          Semantics(
            label: 'Concluir etapa ${e.tarefa.titulo}',
            checked: feita,
            child: IconButton(
              onPressed: () => widget.aoAlternar(e),
              icon: Icon(
                feita ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                color: feita ? c.teal : c.muted,
              ),
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

class _Selo extends StatelessWidget {
  const _Selo(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: c.accentSoft, borderRadius: BorderRadius.circular(8)),
      child: Text(texto, style: manrope(11, peso: FontWeight.w700, cor: c.accent)),
    );
  }
}
