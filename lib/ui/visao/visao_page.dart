import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../icone_ia.dart';
import '../../app.dart';
import '../../core/formato.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/objetivos_repo.dart';
import '../../data/visao_repo.dart';
import '../componentes.dart';
import '../shell.dart';
import 'foco.dart';

/// Visão: o dia inteiro numa tela, em cinco blocos fixos: em
/// foco, linha do dia, semana, painel das áreas e insights.
class VisaoPage extends StatefulWidget {
  const VisaoPage({super.key, required this.ir, required this.irRotina});
  final ValueChanged<Secao> ir;
  final ValueChanged<AbaRotina> irRotina;

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
        return _Conteudo(resumo: r, repo: _repo!, ir: widget.ir, irRotina: widget.irRotina);
      },
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({required this.resumo, required this.repo, required this.ir, required this.irRotina});
  final ResumoVisao resumo;
  final VisaoRepo repo;
  final ValueChanged<Secao> ir;
  final ValueChanged<AbaRotina> irRotina;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final agora = agoraLocal();
    final data = DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(agora);
    final feitos = resumo.linha.where((i) => i.feito).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cabeçalho: data discreta, saudação grande.
        Text('${data[0].toUpperCase()}${data.substring(1)} · ${hora(agora)}',
            style: manrope(13, peso: FontWeight.w500, cor: c.muted)),
        const SizedBox(height: Espaco.sm),
        Text(
          resumo.nome.isEmpty ? saudacao(agora) : '${saudacao(agora)}, ${resumo.nome}',
          style: sora(30, altura: 1.15, espaco: -0.3),
        ),
        const SizedBox(height: Espaco.lg),
        _CartaoFoco(itens: _itensFoco(resumo)),
        const SizedBox(height: Espaco.xl),
        _Bloco(
          titulo: 'Linha do dia',
          descricao: 'Tudo o que é de hoje, na ordem do relógio.',
          direita: resumo.linha.isEmpty ? null : '$feitos de ${resumo.linha.length} feitos',
          child: _LinhaDoDia(itens: resumo.linha, repo: repo),
        ),
        const SizedBox(height: Espaco.xl),
        _Bloco(
          titulo: 'Semana',
          descricao: 'Compromissos de hoje e dos próximos 6 dias.',
          child: _Semana(dias: resumo.semana, aoTocar: () => irRotina(AbaRotina.calendario)),
        ),
        const SizedBox(height: Espaco.xl),
        _Bloco(
          titulo: 'Painel das áreas',
          descricao: 'Toque num cartão para abrir a área.',
          child: _Panorama(resumo: resumo, ir: ir, irRotina: irRotina),
        ),
        if (resumo.insights.isNotEmpty) ...[
          const SizedBox(height: Espaco.xl),
          _Bloco(titulo: 'Insights', child: _Insights(frases: resumo.insights)),
        ],
      ],
    );
  }

  List<ItemFoco> _itensFoco(ResumoVisao r) => [
        for (final o in r.compromissosHoje)
          if (!o.terminou(agoraLocal()))
            ItemFoco(
              o.compromisso.titulo,
              o.emAndamento(agoraLocal())
                  ? 'Agora · Compromisso'
                  : (o.diaInteiro ? 'Hoje · Compromisso' : 'Hoje às ${hora(emLocal(o.inicio))} · Compromisso'),
            ),
        for (final h in r.habitos)
          if (!h.feito) ItemFoco(h.habito.nome, 'Para hoje · Hábitos'),
        for (final o in r.tarefasHoje)
          ItemFoco(
            o.tarefa.titulo,
            o.momento != null && o.horario != null
                ? 'Hoje às ${hora(emLocal(o.momento!))} · Tarefas'
                : 'Para hoje · Tarefas',
          ),
      ];
}

/// Bloco da Visão: título, uma linha de explicação e o conteúdo.
class _Bloco extends StatelessWidget {
  const _Bloco({required this.titulo, required this.child, this.descricao, this.direita});
  final String titulo;
  final String? descricao;
  final String? direita;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titulo, style: sora(18)),
            if (descricao != null) ...[
              const SizedBox(height: Espaco.xs),
              Text(descricao!, style: manrope(13, cor: c.muted)),
            ],
          ]),
        ),
        if (direita != null) Text(direita!, style: manrope(13, peso: FontWeight.w600, cor: c.muted)),
      ]),
      const SizedBox(height: Espaco.md),
      child,
    ]);
  }
}

/// O que fazer agora: um item por vez, com o botão principal da tela.
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
            ? const ItemFoco('Tudo em dia', 'Nada pendente para hoje.')
            : itens[foco.indice % itens.length];
        return Cartao(
          padding: const EdgeInsets.all(Espaco.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.adjust_rounded, size: 16, color: c.accent),
                const SizedBox(width: Espaco.sm),
                Text('Em foco agora', style: manrope(13, peso: FontWeight.w600, cor: c.muted)),
                const Spacer(),
                if (itens.length > 1)
                  Text('${foco.indice % itens.length + 1} de ${itens.length}',
                      style: manrope(12, peso: FontWeight.w600, cor: c.muted)),
              ]),
              const SizedBox(height: Espaco.md),
              Text(item.titulo, style: sora(24, altura: 1.2)),
              const SizedBox(height: Espaco.xs),
              Text(item.detalhe, style: manrope(14, cor: c.muted)),
              const SizedBox(height: Espaco.lg),
              Wrap(
                spacing: Espaco.sm + 4,
                runSpacing: Espaco.sm + 4,
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
        padding: const EdgeInsets.all(Espaco.lg),
        child: Row(children: [
          Icon(Icons.wb_twilight_rounded, color: c.muted),
          const SizedBox(width: Espaco.md),
          Expanded(child: Text('Dia livre: nada marcado para hoje.', style: manrope(14, cor: c.muted))),
        ]),
      );
    }
    return Cartao(
      padding: const EdgeInsets.symmetric(horizontal: Espaco.md + 4, vertical: Espaco.xs),
      child: Column(children: [
        for (var i = 0; i < itens.length; i++) ...[
          if (i > 0) Divider(height: 1, color: c.line),
          _linha(context, itens[i]),
        ],
      ]),
    );
  }

  Widget _linha(BuildContext context, ItemLinha item) {
    final c = context.cores;
    final (icone, tipo) = switch (item.tipo) {
      TipoItemLinha.compromisso => (Icons.event_rounded, 'Compromisso'),
      TipoItemLinha.tarefa => (Icons.check_box_outlined, 'Tarefa'),
      TipoItemLinha.lembrete => (Icons.notifications_none_rounded, 'Lembrete'),
      TipoItemLinha.conta => (Icons.receipt_long_outlined, 'Conta'),
      TipoItemLinha.habito => (Icons.donut_large_rounded, 'Hábito'),
    };
    final habito = item.habitoId;
    return InkWell(
      onTap: habito == null ? null : () => repo.alternarHabito(habito, !item.feito),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(children: [
          SizedBox(
            width: 52,
            child: Text(item.hora == null ? 'Dia' : hora(emLocal(item.hora!)),
                style: manrope(13, peso: FontWeight.w600, cor: c.muted)),
          ),
          // Ícone neutro; só o "feito" ganha cor.
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: item.feito ? c.tealSoft : c.surface2,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.feito ? Icons.check_rounded : icone, size: 17, color: item.feito ? c.teal : c.muted),
          ),
          const SizedBox(width: Espaco.md - 4),
          Expanded(
            child: Text(
              item.titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: manrope(15,
                  peso: FontWeight.w600,
                  cor: item.feito ? c.muted : (item.atrasado ? c.bad : c.text)),
            ),
          ),
          const SizedBox(width: Espaco.sm),
          Text(item.feito ? 'Feito' : tipo, style: manrope(12, peso: FontWeight.w500, cor: c.muted)),
        ]),
      ),
    );
  }
}

/// Hoje e os próximos 6 dias: barra mais alta = dia mais cheio; hoje em destaque.
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
      padding: const EdgeInsets.fromLTRB(Espaco.md, Espaco.lg, Espaco.md, Espaco.md + 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < dias.length; i++)
            Expanded(
              child: Column(
                children: [
                  Text('${dias[i].total}',
                      style: manrope(13, peso: FontWeight.w700, cor: i == 0 ? c.text : c.muted)),
                  const SizedBox(height: Espaco.sm),
                  Container(
                    height: 6 + 56 * dias[i].total / maior,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      gradient: i == 0 && dias[i].total > 0
                          ? LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [c.gradIni, c.gradFim],
                            )
                          : null,
                      color: i == 0 && dias[i].total > 0 ? null : c.line,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: Espaco.sm + 2),
                  Text(
                    i == 0 ? 'Hoje' : _primeiraMaiuscula(DateFormat('EEE', 'pt_BR').format(dias[i].dia).replaceAll('.', '')),
                    style: manrope(12, peso: FontWeight.w600, cor: i == 0 ? c.text : c.muted),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String _primeiraMaiuscula(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _Insights extends StatelessWidget {
  const _Insights({required this.frases});
  final List<String> frases;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Cartao(
      padding: const EdgeInsets.all(Espaco.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < frases.length; i++) ...[
            if (i > 0) const SizedBox(height: Espaco.md),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(9)),
                child: IconeIa(size: 15, color: c.violeta),
              ),
              const SizedBox(width: Espaco.md - 4),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(frases[i], style: manrope(14, altura: 1.5)),
                ),
              ),
            ]),
          ],
        ],
      ),
    );
  }
}

class _Panorama extends StatelessWidget {
  const _Panorama({required this.resumo, required this.ir, required this.irRotina});
  final ResumoVisao resumo;
  final ValueChanged<Secao> ir;
  final ValueChanged<AbaRotina> irRotina;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final objetivo = resumo.objetivo;
    final agora = agoraLocal();

    final cartoes = <Widget>[
      _CartaoNumero(
        icone: Icons.check_box_outlined,
        rotulo: 'Tarefas',
        valor: '${resumo.tarefasAtrasadas}',
        corValor: resumo.tarefasAtrasadas > 0 ? c.bad : null,
        detalhe: 'atrasadas · ${resumo.tarefasAbertas} abertas',
        aoTocar: () => irRotina(AbaRotina.hoje),
      ),
      _CartaoNumero(
        icone: Icons.repeat_rounded,
        rotulo: 'Hábitos',
        valor: '${resumo.habitosFeitos}/${resumo.habitos.length}',
        detalhe: 'feitos hoje',
        aoTocar: () => irRotina(AbaRotina.habitos),
      ),
      _CartaoNumero(
        icone: Icons.account_balance_wallet_outlined,
        rotulo: nomeDoMes(agora),
        valor: reais(resumo.aPagarCentavos),
        detalhe: 'a pagar · ${resumo.contasAPagar} ${resumo.contasAPagar == 1 ? 'conta' : 'contas'}',
        aoTocar: () => ir(Secao.financas),
      ),
      if (objetivo != null)
        _CartaoNumero(
          icone: Icons.flag_outlined,
          rotulo: objetivo.nome,
          valor: valorMeta(objetivo.valorAtual, objetivo.unidade),
          detalhe: _detalheObjetivo(objetivo),
          aoTocar: () => ir(Secao.objetivos),
        ),
    ];

    return LayoutBuilder(builder: (context, box) {
      final colunas = box.maxWidth >= 640 ? cartoes.length.clamp(2, 4) : 2;
      const espaco = Espaco.md;
      final largura = (box.maxWidth - espaco * (colunas - 1)) / colunas;
      return Wrap(
        spacing: espaco,
        runSpacing: espaco,
        children: [for (final w in cartoes) SizedBox(width: largura, child: w)],
      );
    });
  }

  String _detalheObjetivo(Objetivo o) {
    final falta = (o.valorAlvo - o.valorAtual).abs();
    final partes = [
      falta == 0 ? 'objetivo alcançado' : 'faltam ${valorMeta(falta, o.unidade)}',
      if (o.dataAlvo != null) diaMesCurto(emLocal(o.dataAlvo!)),
    ];
    return partes.join(' · ');
  }
}

class _CartaoNumero extends StatelessWidget {
  const _CartaoNumero({
    required this.icone,
    required this.rotulo,
    required this.valor,
    required this.detalhe,
    required this.aoTocar,
    this.corValor,
  });

  final IconData icone;
  final String rotulo;
  final String valor;
  final String detalhe;
  final VoidCallback aoTocar;
  final Color? corValor;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Cartao(
      padding: const EdgeInsets.all(Espaco.md + 4),
      aoTocar: aoTocar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(9)),
              child: Icon(icone, size: 16, color: c.muted),
            ),
            const SizedBox(width: Espaco.sm + 2),
            Expanded(
              child: Text(rotulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: manrope(13, peso: FontWeight.w600, cor: c.muted)),
            ),
          ]),
          const SizedBox(height: Espaco.md),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(valor, style: sora(24, cor: corValor ?? c.text)),
          ),
          const SizedBox(height: Espaco.xs),
          Text(detalhe, style: manrope(12, cor: c.muted), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
