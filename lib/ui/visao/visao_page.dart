import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/metas_repo.dart';
import '../../data/visao_repo.dart';
import '../componentes.dart';
import '../shell.dart';
import '../habitos/linha_habito.dart';
import 'foco.dart';

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
    final restantes = resumo.habitos.length - resumo.habitosFeitos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(dataCabecalho(agora),
            style: manrope(12, peso: FontWeight.w600, cor: c.muted, espaco: 1.4)),
        const SizedBox(height: 4),
        Text(
          resumo.nome.isEmpty ? saudacao(agora) : '${saudacao(agora)}, ${resumo.nome}',
          style: sora(28, altura: 1.2),
        ),
        const SizedBox(height: 20),
        _CartaoFoco(itens: _itensFoco(resumo)),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Hoje', style: sora(17)),
            const Spacer(),
            Text(
              restantes == 1 ? '1 hábito restante' : '$restantes hábitos restantes',
              style: manrope(13, cor: c.muted),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (resumo.habitos.isEmpty)
          Text('Nenhum hábito para hoje.', style: manrope(14, cor: c.muted)),
        for (final h in resumo.habitos) ...[
          LinhaHabito(
            habito: h.habito,
            feito: h.feito,
            aoAlternar: () => repo.alternarHabito(h.habito.id, !h.feito),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 10),
        Text('Panorama', style: sora(17)),
        const SizedBox(height: 10),
        _Panorama(resumo: resumo, ir: ir),
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
