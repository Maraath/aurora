import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/metas_repo.dart';
import '../../data/visao_repo.dart';
import '../componentes.dart';
import '../shell.dart';
import 'foco.dart';

/// Visão: o dia inteiro numa tela, em cinco blocos fixos: em
/// foco, linha do dia, semana, painel das áreas e insights.
class VisaoPage extends StatefulWidget {
  const VisaoPage({super.key, required this.ir});
  final ValueChanged<Secao> ir;

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
        return _Conteudo(resumo: r, repo: _repo!, ir: widget.ir);
      },
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({required this.resumo, required this.repo, required this.ir});
  final ResumoVisao resumo;
  final VisaoRepo repo;
  final ValueChanged<Secao> ir;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final agora = agoraSP();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('${dataCabecalho(agora)} · ${hora(agora)}',
            style: manrope(12, peso: FontWeight.w600, cor: c.muted, espaco: 1.4)),
        const SizedBox(height: 4),
        Text(
          resumo.nome.isEmpty ? saudacao(agora) : '${saudacao(agora)}, ${resumo.nome}',
          style: sora(28, altura: 1.2),
        ),
        const SizedBox(height: 20),
        _CartaoFoco(itens: _itensFoco(resumo)),
        const SizedBox(height: 22),
        _TituloBloco('Linha do dia',
            direita: '${resumo.linha.where((i) => i.feito).length}/${resumo.linha.length} feitos'),
        _LinhaDoDia(itens: resumo.linha, repo: repo),
        const SizedBox(height: 22),
        const _TituloBloco('Semana'),
        _Semana(dias: resumo.semana, aoTocar: () => ir(Secao.tarefas)),
        const SizedBox(height: 22),
        const _TituloBloco('Painel das áreas'),
        _Panorama(resumo: resumo, ir: ir),
        if (resumo.insights.isNotEmpty) ...[
          const SizedBox(height: 22),
          const _TituloBloco('Insights'),
          _Insights(frases: resumo.insights),
        ],
      ],
    );
  }

  List<ItemFoco> _itensFoco(ResumoVisao r) => [
        for (final h in r.habitos)
          if (!h.feito) ItemFoco(h.habito.nome, 'para hoje · Hábitos'),
        for (final o in r.tarefasHoje)
          ItemFoco(
            o.tarefa.titulo,
            o.momento != null && o.horario != null
                ? 'hoje às ${hora(emSP(o.momento!))} · Tarefas'
                : 'para hoje · Tarefas',
          ),
      ];
}

class _TituloBloco extends StatelessWidget {
  const _TituloBloco(this.texto, {this.direita});
  final String texto;
  final String? direita;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(texto, style: sora(17)),
          const Spacer(),
          if (direita != null) Text(direita!, style: manrope(13, cor: c.muted)),
        ],
      ),
    );
  }
}

/// Hoje em ordem de horário: tarefas, lembretes, contas e hábitos.
class _LinhaDoDia extends StatelessWidget {
  const _LinhaDoDia({required this.itens, required this.repo});
  final List<ItemLinha> itens;
  final VisaoRepo repo;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    if (itens.isEmpty) {
      return Cartao(
        child: Text('Dia livre: nada marcado para hoje.', style: manrope(14, cor: c.muted)),
      );
    }
    return Cartao(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          for (var i = 0; i < itens.length; i++) ...[
            if (i > 0) Divider(height: 1, color: c.line),
            _linha(context, itens[i]),
          ],
        ],
      ),
    );
  }

  Widget _linha(BuildContext context, ItemLinha item) {
    final c = context.cores;
    final (cor, icone, tipo) = switch (item.tipo) {
      TipoItemLinha.tarefa => (c.accent, Icons.check_box_outlined, 'Tarefa'),
      TipoItemLinha.lembrete => (c.violeta, Icons.notifications_none_rounded, 'Lembrete'),
      TipoItemLinha.conta => (c.warn, Icons.receipt_long_outlined, 'Conta'),
      TipoItemLinha.habito => (c.teal, Icons.repeat_rounded, 'Hábito'),
    };
    final habito = item.habitoId;
    return InkWell(
      onTap: habito == null ? null : () => repo.alternarHabito(habito, !item.feito),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: Text(item.hora == null ? 'dia' : hora(emSP(item.hora!)),
                  style: manrope(13, peso: FontWeight.w700, cor: item.hora == null ? c.muted : c.text)),
            ),
            Icon(icone, size: 18, color: item.feito ? c.muted : cor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: manrope(14,
                    peso: FontWeight.w600,
                    cor: item.feito ? c.muted : (item.atrasado ? c.bad : c.text)),
              ),
            ),
            const SizedBox(width: 8),
            Text(item.feito ? 'feito' : tipo, style: manrope(12, cor: item.feito ? c.teal : c.muted)),
          ],
        ),
      ),
    );
  }
}

/// Hoje e os próximos 6 dias, com quantos compromissos cada um tem.
class _Semana extends StatelessWidget {
  const _Semana({required this.dias, required this.aoTocar});
  final List<DiaSemana> dias;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final maior = dias.fold<int>(1, (m, d) => d.total > m ? d.total : m);
    return Cartao(
      aoTocar: aoTocar,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < dias.length; i++)
            Expanded(
              child: Column(
                children: [
                  Text('${dias[i].total}',
                      style: manrope(12, peso: FontWeight.w700, cor: dias[i].total == 0 ? c.muted : c.text)),
                  const SizedBox(height: 6),
                  Container(
                    height: 6 + 46 * dias[i].total / maior,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      gradient: dias[i].total == 0
                          ? null
                          : LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [c.gradIni, c.gradFim],
                            ),
                      color: dias[i].total == 0 ? c.line : null,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    i == 0 ? 'hoje' : DateFormat('EEE', 'pt_BR').format(dias[i].dia).replaceAll('.', ''),
                    style: manrope(11, peso: FontWeight.w700, cor: i == 0 ? c.accent : c.muted),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Insights extends StatelessWidget {
  const _Insights({required this.frases});
  final List<String> frases;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < frases.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(Icons.auto_awesome_outlined, size: 16, color: c.violeta),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(frases[i], style: manrope(14, altura: 1.4))),
            ]),
          ],
        ],
      ),
    );
  }
}

class _CartaoFoco extends StatelessWidget {
  const _CartaoFoco({required this.itens});
  final List<ItemFoco> itens;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final foco = ControleFoco.instancia;
    return ListenableBuilder(
      listenable: foco,
      builder: (context, _) {
        final item = itens.isEmpty
            ? const ItemFoco('Tudo em dia', 'nada pendente para hoje')
            : itens[foco.indice % itens.length];
        return Cartao(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('EM FOCO AGORA', style: rotulo(c.teal)),
              const SizedBox(height: 14),
              Text(item.titulo, style: sora(22)),
              const SizedBox(height: 2),
              Text(item.detalhe, style: manrope(13, cor: c.muted)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  BotaoPilula(texto: foco.rotulo, aoTocar: foco.alternar),
                  if (itens.length > 1)
                    BotaoPilula(texto: 'Focar em outra', principal: false, aoTocar: foco.proximo),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Panorama extends StatelessWidget {
  const _Panorama({required this.resumo, required this.ir});
  final ResumoVisao resumo;
  final ValueChanged<Secao> ir;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final meta = resumo.meta;
    final agora = agoraSP();

    final cartoes = <Widget>[
      _CartaoNumero(
        rotulo: 'Tarefas',
        valor: '${resumo.tarefasAtrasadas}',
        corValor: resumo.tarefasAtrasadas > 0 ? c.bad : c.text,
        detalhe: 'atrasadas · ${resumo.tarefasAbertas} abertas',
        aoTocar: () => ir(Secao.tarefas),
      ),
      _CartaoNumero(
        rotulo: 'Hábitos',
        valor: '${resumo.habitosFeitos}/${resumo.habitos.length}',
        corValor: c.teal,
        detalhe: 'feitos hoje',
        aoTocar: () => ir(Secao.habitos),
      ),
      _CartaoNumero(
        rotulo: nomeDoMes(agora),
        valor: reais(resumo.aPagarCentavos),
        tamanhoValor: 22,
        detalhe: 'a pagar · ${resumo.contasAPagar} ${resumo.contasAPagar == 1 ? 'conta' : 'contas'}',
        aoTocar: () => ir(Secao.financas),
      ),
      if (meta != null)
        _CartaoNumero(
          rotulo: meta.nome,
          valor: valorMeta(meta.valorAtual, meta.unidade),
          tamanhoValor: 22,
          detalhe: _detalheMeta(meta),
          aoTocar: () => ir(Secao.metas),
        ),
    ];

    return LayoutBuilder(builder: (context, box) {
      final colunas = box.maxWidth >= 620 ? 4 : 2;
      const espaco = 10.0;
      final largura = (box.maxWidth - espaco * (colunas - 1)) / colunas;
      return Wrap(
        spacing: espaco,
        runSpacing: espaco,
        children: [for (final w in cartoes) SizedBox(width: largura, child: w)],
      );
    });
  }

  String _detalheMeta(Meta m) {
    final falta = (m.valorAlvo - m.valorAtual).abs();
    final partes = [
      falta == 0 ? 'meta alcançada' : 'faltam ${valorMeta(falta, m.unidade)}',
      if (m.dataAlvo != null) diaMesCurto(emSP(m.dataAlvo!)),
    ];
    return partes.join(' · ');
  }
}

class _CartaoNumero extends StatelessWidget {
  const _CartaoNumero({
    required this.rotulo,
    required this.valor,
    required this.detalhe,
    required this.aoTocar,
    this.corValor,
    this.tamanhoValor = 24,
  });

  final String rotulo;
  final String valor;
  final String detalhe;
  final VoidCallback aoTocar;
  final Color? corValor;
  final double tamanhoValor;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Cartao(
      raio: 16,
      padding: const EdgeInsets.all(14),
      aoTocar: aoTocar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo, style: manrope(12, peso: FontWeight.w600, cor: c.muted)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(valor, style: sora(tamanhoValor, cor: corValor ?? c.text)),
          ),
          const SizedBox(height: 6),
          Text(detalhe, style: manrope(12, cor: c.muted), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
