import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/recorrencia.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/analise_financas.dart';
import '../../data/financas_repo.dart';
import '../../data/graficos_financas.dart';
import '../componentes.dart';
import '../em_breve.dart';
import 'form_conta.dart';
import 'form_lancamento.dart';
import 'graficos/cartao_categorias.dart';
import 'graficos/cartao_fluxo_caixa.dart';
import 'graficos/cartao_fluxo_dinheiro.dart';
import 'graficos/cartao_gasto_dia.dart';
import 'graficos/cartoes_analise.dart';
import 'graficos/config.dart';
import 'graficos/personalizar.dart';
import 'painel/cartoes_resumo.dart';
import 'painel/transacoes.dart';
import 'revisar_outros.dart';

enum _Vista {
  resumo('Resumo'),
  extrato('Extrato'),
  fixas('Fixas'),
  parceladas('Parceladas'),
  contas('Contas'),
  analise('Análise');

  const _Vista(this.rotulo);
  final String rotulo;
}

class FinancasPage extends StatefulWidget {
  const FinancasPage({super.key});

  @override
  State<FinancasPage> createState() => _FinancasPageState();
}

class _FinancasPageState extends State<FinancasPage> {
  FinancasRepo? _repo;
  Stream<QuadroFinancas>? _quadro;
  PreferenciasPainel? _prefs;
  final _hoje = hojeLocal();
  late DateTime _mes = DateTime(_hoje.year, _hoje.month, 1);
  _Vista _vista = _Vista.resumo;

  /// Meses usados nos gráficos da Análise (3, 6 ou 12).
  int _periodo = 6;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = AuroraEscopo.de(context).db;
    if (_repo?.db != db) {
      _repo = FinancasRepo(db);
      _quadro = _repo!.observarQuadro();
      _prefs?.dispose();
      _prefs = PreferenciasPainel(db);
      // Nome antigo de categoria (Educação → Estudos) não pode ficar dividido
      // em duas fatias nos gráficos.
      _converterCategorias();
    }
  }

  Future<void> _converterCategorias() async {
    try {
      await _repo?.converterCategoriasRenomeadas();
    } catch (e) {
      debugPrint('Finanças: não converti categorias antigas ($e)');
    }
  }

  @override
  void dispose() {
    _prefs?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuadroFinancas>(
      stream: _quadro,
      builder: (context, snap) {
        if (snap.hasError) return Text('Não consegui ler as finanças: ${snap.error}');
        final q = snap.data;
        if (q == null) return const SizedBox(height: 200);
        return ListenableBuilder(listenable: _prefs!, builder: (context, _) => _conteudo(context, q));
      },
    );
  }

  void _lancar(QuadroFinancas q, [Transacao? t]) => abrirFormLancamento(
        context,
        transacao: t,
        contas: q.contas,
        contaPrincipalId: q.contaPrincipalId,
      );

  Widget _conteudo(BuildContext context, QuadroFinancas q) {
    final mes = q.mes(_mes);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TituloPagina(
          'Finanças',
          acao: BotaoRedondo(
            icone: Icons.add_rounded,
            dica: 'Novo lançamento',
            preenchido: true,
            aoTocar: () => _lancar(q),
          ),
        ),
        const SizedBox(height: 8),
        _SeletorMes(
          mes: _mes,
          hoje: _hoje,
          aoMudar: (m) => setState(() => _mes = m),
        ),
        const SizedBox(height: 12),
        Segmentos<_Vista>(
          opcoes: _Vista.values,
          selecionado: _vista,
          rotulo: (v) => v.rotulo,
          aoEscolher: (v) => setState(() => _vista = v),
        ),
        const SizedBox(height: 18),
        switch (_vista) {
          _Vista.resumo => _Resumo(
              quadro: q,
              mes: mes,
              hoje: _hoje,
              prefs: _prefs!,
              aoPagar: (o) => _repo!.pagar(o, !o.paga),
              aoEditar: (t) => _lancar(q, t),
              aoVerExtrato: () => setState(() => _vista = _Vista.extrato),
              aoRevisarOutros: (outros) =>
                  abrirRevisarOutros(context, repo: _repo!, movimentos: outros),
            ),
          _Vista.extrato => _Extrato(quadro: q, mes: mes, hoje: _hoje, aoEditar: (t) => _lancar(q, t)),
          _Vista.fixas => _Fixas(quadro: q, aoEditar: (t) => _lancar(q, t)),
          _Vista.parceladas => _Parceladas(quadro: q, aoEditar: (t) => _lancar(q, t)),
          _Vista.contas => _Contas(quadro: q),
          _Vista.analise => _Analise(
              quadro: q,
              mes: _mes,
              hoje: _hoje,
              prefs: _prefs!,
              periodo: _periodo,
              aoMudarPeriodo: (p) => setState(() => _periodo = p),
            ),
        },
      ],
    );
  }
}

class _SeletorMes extends StatelessWidget {
  const _SeletorMes({required this.mes, required this.hoje, required this.aoMudar});
  final DateTime mes;
  final DateTime hoje;
  final ValueChanged<DateTime> aoMudar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final atual = mes.year == hoje.year && mes.month == hoje.month;
    return Row(
      children: [
        IconButton(
          onPressed: () => aoMudar(DateTime(mes.year, mes.month - 1, 1)),
          tooltip: 'Mês anterior',
          icon: Icon(Icons.chevron_left_rounded, color: c.muted),
        ),
        Text(mesAno(mes).replaceAll(' de ', ' ').toUpperCase(),
            style: manrope(12, peso: FontWeight.w700, cor: c.muted, espaco: 1.4)),
        IconButton(
          onPressed: () => aoMudar(DateTime(mes.year, mes.month + 1, 1)),
          tooltip: 'Próximo mês',
          icon: Icon(Icons.chevron_right_rounded, color: c.muted),
        ),
        const Spacer(),
        if (!atual)
          TextButton(
            onPressed: () => aoMudar(DateTime(hoje.year, hoje.month, 1)),
            child: Text('Voltar para hoje', style: manrope(12, peso: FontWeight.w700, cor: c.accent)),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------- Resumo

/// Painel do mês, montado com os cartões ligados em Personalizar e na ordem
/// escolhida: resumo, contas do mês, fluxo do dinheiro, categorias, gasto por
/// dia, fluxo de caixa e últimas transações.
class _Resumo extends StatelessWidget {
  const _Resumo({
    required this.quadro,
    required this.mes,
    required this.hoje,
    required this.prefs,
    required this.aoPagar,
    required this.aoEditar,
    required this.aoVerExtrato,
    required this.aoRevisarOutros,
  });

  final QuadroFinancas quadro;
  final MesFinancas mes;
  final DateTime hoje;
  final PreferenciasPainel prefs;
  final ValueChanged<Ocorrencia> aoPagar;
  final ValueChanged<Transacao> aoEditar;
  final VoidCallback aoVerExtrato;

  /// Abre a revisão dos lançamentos que ficaram em "Outros" no mês.
  final ValueChanged<List<Movimento>> aoRevisarOutros;

  @override
  Widget build(BuildContext context) {
    final config = prefs.config;
    final painel = painelDoMes(quadro, mes.mes);
    final faltaReceber = mes.aReceber.where((o) => !o.paga).fold(0, (s, o) => s + o.valorCentavos);

    Widget? cartao(CartaoFin c) => switch (c) {
          CartaoFin.resumo => CartoesResumo(painel: painel),
          CartaoFin.contas => mes.aPagar.isEmpty && mes.aReceber.isEmpty ? null : _contas(context, faltaReceber),
          CartaoFin.fluxoDinheiro => CartaoFluxoDinheiro(
              fato: fluxoDoDinheiro(quadro, mes.mes),
              comPrevistos: fluxoDoDinheiro(quadro, mes.mes, comPrevistos: true),
            ),
          CartaoFin.categorias => _categorias(context, c, painel),
          CartaoFin.gastoDia => CartaoGastoDia(
              dados: gastoPorDia(quadro, mes.mes, hoje),
              receitasCentavos: painel.receitasCentavos + faltaReceber,
              tipo: config.tipoDe(c)!,
              aoEscolherTipo: (t) => prefs.escolherTipo(c, t),
            ),
          CartaoFin.fluxoCaixa => CartaoFluxoCaixa(
              meses: quadro.serie(mes.mes),
              velas: config.tipoDe(c) == TipoGrafico.velas ? velasDoSaldo(quadro, mes.mes, hoje) : const [],
              mesEscolhido: mes.mes,
              tipo: config.tipoDe(c)!,
              aoEscolherTipo: (t) => prefs.escolherTipo(c, t),
            ),
          CartaoFin.recentes => TransacoesRecentes(
              movimentos: painel.recentes,
              hoje: hoje,
              nomesContas: {for (final conta in quadro.contas) conta.id: conta.nome},
              contaPrincipalId: quadro.contaPrincipalId,
              aoVerTudo: aoVerExtrato,
              aoEditar: aoEditar,
            ),
          _ => null,
        };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BotaoPersonalizar(aoTocar: () => abrirPersonalizar(context, prefs, PainelFin.resumo)),
        _Grade(itens: [
          for (final c in config.visiveis(PainelFin.resumo))
            if (cartao(c) case final w?) (c, w),
        ]),
      ],
    );
  }

  /// "Despesas por categoria": por categoria ou somada por grupo (preferência
  /// do aparelho) e, no pé, o atalho para revisar o que ficou em "Outros".
  Widget _categorias(BuildContext context, CartaoFin c, PainelMes painel) {
    final porGrupo = prefs.config.usaGrupo(c);
    final outros = [
      for (final m in mes.extrato)
        if (!m.transferencia && !m.entrada && m.categoria == 'Outros') m,
    ];
    return CartaoCategorias(
      categorias: porGrupo ? agruparCategorias(painel.categorias) : painel.categorias,
      // Agrupar depois de somar TODAS as categorias: cortar em 6 antes daria
      // grupo pela metade.
      comparacao: porGrupo
          ? agruparComparacao(compararComMedia(quadro, mes.mes, maxCategorias: 99))
          : compararComMedia(quadro, mes.mes),
      tipo: prefs.config.tipoDe(c)!,
      aoEscolherTipo: (t) => prefs.escolherTipo(c, t),
      porGrupo: porGrupo,
      aoAlternarGrupo: () => prefs.alternarGrupo(c),
      rodape: outros.isEmpty
          ? null
          : _RodapeOutros(
              quantos: outros.length,
              centavos: outros.fold(0, (s, m) => s + m.valorCentavos),
              aoTocar: () => aoRevisarOutros(outros),
            ),
    );
  }

  Widget _contas(BuildContext context, int faltaReceber) {
    final c = context.cores;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (mes.aPagar.isNotEmpty) ...[
        TituloSecao(
          'Contas a pagar',
          direita: Text(reais(mes.faltaPagarCentavos), style: manrope(13, peso: FontWeight.w700)),
        ),
        for (final o in mes.aPagar)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _LinhaConta(
              ocorrencia: o,
              hoje: hoje,
              aoPagar: () => aoPagar(o),
              aoEditar: () => aoEditar(o.transacao),
            ),
          ),
      ],
      if (mes.aReceber.isNotEmpty) ...[
        if (mes.aPagar.isNotEmpty) const SizedBox(height: 8),
        TituloSecao(
          'A receber',
          direita: Text(reais(faltaReceber), style: manrope(13, peso: FontWeight.w700, cor: c.teal)),
        ),
        for (final o in mes.aReceber)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _LinhaConta(
              ocorrencia: o,
              hoje: hoje,
              aoPagar: () => aoPagar(o),
              aoEditar: () => aoEditar(o.transacao),
            ),
          ),
      ],
    ]);
  }
}

/// Pé do cartão de despesas: "6 em Outros · R$ 480,00 · Revisar". Aparece só
/// quando sobrou alguma coisa em "Outros" no mês.
class _RodapeOutros extends StatelessWidget {
  const _RodapeOutros({required this.quantos, required this.centavos, required this.aoTocar});

  final int quantos;
  final int centavos;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Material(
      color: c.surface2.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(children: [
            Icon(Icons.category_outlined, size: 16, color: c.muted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$quantos em Outros · ${reais(centavos)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: manrope(12.5, cor: c.muted),
              ),
            ),
            const SizedBox(width: 8),
            Text('Revisar', style: manrope(12.5, peso: FontWeight.w700, cor: c.accent)),
          ]),
        ),
      ),
    );
  }
}

/// "Personalizar" no topo dos painéis de Resumo e Análise.
class _BotaoPersonalizar extends StatelessWidget {
  const _BotaoPersonalizar({required this.aoTocar});
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextButton.icon(
          onPressed: aoTocar,
          icon: Icon(Icons.tune_rounded, size: 18, color: c.accent),
          label: Text('Personalizar', style: manrope(13, peso: FontWeight.w700, cor: c.accent)),
        ),
      ),
    );
  }
}

/// Os cartões um embaixo do outro; em tela larga, dois cartões seguidos de
/// meia largura dividem a linha.
class _Grade extends StatelessWidget {
  const _Grade({required this.itens});
  final List<(CartaoFin, Widget)> itens;

  static const _vao = 16.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final largo = box.maxWidth >= 700;
      final linhas = <Widget>[];
      for (var i = 0; i < itens.length; i++) {
        final (cartao, w) = itens[i];
        if (largo && cartao.meia && i + 1 < itens.length && itens[i + 1].$1.meia) {
          // Sem IntrinsicHeight: os gráficos usam LayoutBuilder, que não mede altura intrínseca.
          linhas.add(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: w),
            const SizedBox(width: _vao),
            Expanded(child: itens[i + 1].$2),
          ]));
          i++;
        } else {
          linhas.add(w);
        }
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (var i = 0; i < linhas.length; i++) ...[
          if (i > 0) const SizedBox(height: _vao),
          linhas[i],
        ],
      ]);
    });
  }
}

class _Caixa extends StatelessWidget {
  const _Caixa(this.rotulo, this.centavos, this.fundo, this.cor);
  final String rotulo;
  final int centavos;
  final Color fundo;
  final Color cor;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: fundo, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(rotulo, style: manrope(12, cor: context.cores.text)),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(reais(centavos), style: manrope(16, peso: FontWeight.w700, cor: cor)),
            ),
          ],
        ),
      );
}

/// Conta a pagar ou a receber com o botão Pagar/Desfazer (como no protótipo).
class _LinhaConta extends StatelessWidget {
  const _LinhaConta({
    required this.ocorrencia,
    required this.hoje,
    required this.aoPagar,
    required this.aoEditar,
  });

  final Ocorrencia ocorrencia;
  final DateTime hoje;
  final VoidCallback aoPagar;
  final VoidCallback aoEditar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final o = ocorrencia;
    final v = o.vencimento;
    final String status;
    final Color corStatus;
    if (o.paga) {
      status = o.entrada ? 'recebida' : 'paga';
      corStatus = c.teal;
    } else if (o.atrasada(hoje)) {
      status = v.month == hoje.month && v.year == hoje.year
          ? 'atrasada'
          : 'atrasada desde ${diaMesCurto(v)}';
      corStatus = c.bad;
    } else if (v == hoje) {
      status = o.entrada ? 'chega hoje' : 'vence hoje';
      corStatus = c.warn;
    } else {
      status = '${o.entrada ? 'chega' : 'vence'} dia ${v.day}';
      corStatus = c.muted;
    }
    final etiqueta = switch (formaDe(o.transacao)) {
      FormaTransacao.recorrente => ' · todo mês',
      FormaTransacao.parcelada => ' · parcelada',
      FormaTransacao.unica => o.transacao.parcelaTotal != null ? ' · parcelada' : '',
    };

    return Cartao(
      raio: 16,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      aoTocar: aoEditar,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(12)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${v.day}', style: manrope(15, peso: FontWeight.w700, altura: 1)),
                Text(mesCurto(v), style: manrope(9, peso: FontWeight.w700, cor: c.muted)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(o.nome, style: manrope(15, peso: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('$status · ${reais(o.valorCentavos)}$etiqueta',
                    style: manrope(12, cor: corStatus)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          BotaoPilula(
            texto: o.paga ? 'Desfazer' : (o.entrada ? 'Receber' : 'Pagar'),
            principal: !o.paga,
            aoTocar: aoPagar,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- Extrato

class _Extrato extends StatelessWidget {
  const _Extrato({required this.quadro, required this.mes, required this.hoje, required this.aoEditar});
  final QuadroFinancas quadro;
  final MesFinancas mes;
  final DateTime hoje;
  final ValueChanged<Transacao> aoEditar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    if (mes.extrato.isEmpty) {
      return const Vazio('Nada entrou nem saiu neste mês. Contas pagas e gastos aparecem aqui.');
    }
    final nomes = {for (final conta in quadro.contas) conta.id: conta.nome};
    final porDia = <DateTime, List<Movimento>>{};
    for (final m in mes.extrato) {
      porDia.putIfAbsent(m.dia, () => []).add(m);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final MapEntry(key: dia, value: lista) in porDia.entries) ...[
          TituloSecao(
            diaRelativo(dia, hoje),
            direita: Text(
              _totalDoDia(lista),
              style: manrope(12, peso: FontWeight.w700, cor: c.muted),
            ),
          ),
          Cartao(
            raio: 16,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Column(
              children: [
                for (var i = 0; i < lista.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: c.line),
                  LinhaTransacao(
                    movimento: lista[i],
                    hoje: hoje,
                    mostrarDia: false,
                    conta: nomes[lista[i].transacao.contaId ?? quadro.contaPrincipalId],
                    destino: nomes[lista[i].transacao.contaDestinoId],
                    aoTocar: () => aoEditar(lista[i].transacao),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  String _totalDoDia(List<Movimento> lista) {
    var total = 0;
    for (final m in lista) {
      if (m.transferencia) continue;
      total += m.entrada ? m.valorCentavos : -m.valorCentavos;
    }
    return total >= 0 ? '+${reais(total)}' : '−${reais(-total)}';
  }
}

// ---------------------------------------------------------------- Fixas

class _Fixas extends StatelessWidget {
  const _Fixas({required this.quadro, required this.aoEditar});
  final QuadroFinancas quadro;
  final ValueChanged<Transacao> aoEditar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final recorrentes = quadro.recorrentes;
    final custoMensal = recorrentes
        .where((t) => t.tipo == TipoTransacao.saida && quadro.proximaAberta(t) != null)
        .fold(0, (s, t) => s + t.valorCentavos);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TituloSecao(
          'Recorrentes',
          direita: custoMensal > 0
              ? Text('${reais(custoMensal)}/mês', style: manrope(12, peso: FontWeight.w700, cor: c.muted))
              : null,
        ),
        if (recorrentes.isEmpty)
          const Vazio('Nenhuma conta ou entrada que se repete. Ao lançar, escolha "Recorrente".'),
        for (final t in recorrentes)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _LinhaFixa(
              titulo: t.descricao,
              detalhe: _detalheRecorrente(t),
              valor: reais(t.valorCentavos),
              corValor: t.tipo == TipoTransacao.entrada ? c.teal : c.text,
              aoTocar: () => aoEditar(t),
            ),
          ),
      ],
    );
  }

  String _detalheRecorrente(Transacao t) {
    final regra = Regra.ler(t.regraRepeticao);
    final prox = quadro.proximaAberta(t);
    if (prox == null) return 'encerrada';
    final quando = prox.vencimento.isBefore(quadro.hoje)
        ? 'em aberto desde ${diaMesCurto(prox.vencimento)}'
        : 'próxima ${diaMesCurto(prox.vencimento)}';
    return '${regra?.descricao ?? ''} · $quando';
  }
}

class _LinhaFixa extends StatelessWidget {
  const _LinhaFixa({
    required this.titulo,
    required this.detalhe,
    required this.valor,
    required this.corValor,
    required this.aoTocar,
    this.fracao,
  });

  final String titulo;
  final String detalhe;
  final String valor;
  final Color corValor;
  final VoidCallback aoTocar;
  final double? fracao;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Cartao(
      raio: 16,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      aoTocar: aoTocar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: manrope(15, peso: FontWeight.w600)),
                    Text(detalhe, style: manrope(12, cor: c.muted)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(valor, style: manrope(14, peso: FontWeight.w700, cor: corValor)),
            ],
          ),
          if (fracao != null) ...[
            const SizedBox(height: 10),
            BarraProgresso(fracao: fracao!, cor: c.teal),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- Contas

class _Contas extends StatelessWidget {
  const _Contas({required this.quadro});
  final QuadroFinancas quadro;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final naoCartoes = quadro.contas.where((x) => x.tipo != TipoConta.cartao).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Cartao(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Patrimônio', style: manrope(12, peso: FontWeight.w600, cor: c.muted)),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(reais(quadro.patrimonioCentavos),
                    style: sora(30, cor: quadro.patrimonioCentavos < 0 ? c.bad : c.text)),
              ),
              const SizedBox(height: 6),
              Text(
                'Contas ${reais(quadro.saldoCentavos)} · faturas em aberto ${reais(quadro.faturasCentavos)}',
                style: manrope(12, cor: c.muted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const TituloSecao('Contas e cartões'),
        for (final s in quadro.saldos)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _LinhaSaldo(
              saldo: s,
              aoTocar: () => abrirFormConta(context, conta: s.conta),
              aoPagarFatura: s.faturaCentavos > 0
                  ? () => abrirPagarFatura(context, cartao: s, contas: naoCartoes)
                  : null,
            ),
          ),
        if (quadro.semContaCentavos != 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Cartao(
              raio: 16,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.payments_outlined, size: 20, color: c.muted),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Sem conta', style: manrope(15, peso: FontWeight.w600)),
                    Text('Lançamentos que não dizem a conta. Cadastre uma conta e escolha nela.',
                        style: manrope(12, cor: c.muted)),
                  ]),
                ),
                const SizedBox(width: 8),
                Text(reais(quadro.semContaCentavos),
                    style: manrope(14, peso: FontWeight.w700, cor: quadro.semContaCentavos < 0 ? c.bad : c.text)),
              ]),
            ),
          ),
        const SizedBox(height: 2),
        CartaoNovo(
          titulo: '+ Nova conta ou cartão',
          detalhe: 'Conta corrente, poupança ou cartão de crédito. Cada lançamento diz de onde saiu o dinheiro.',
          aoTocar: () => abrirFormConta(context),
        ),
      ],
    );
  }
}

class _LinhaSaldo extends StatelessWidget {
  const _LinhaSaldo({required this.saldo, required this.aoTocar, this.aoPagarFatura});
  final SaldoConta saldo;
  final VoidCallback aoTocar;
  final VoidCallback? aoPagarFatura;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final conta = saldo.conta;
    final icone = switch (conta.tipo) {
      TipoConta.corrente => Icons.account_balance_outlined,
      TipoConta.poupanca => Icons.savings_outlined,
      TipoConta.cartao => Icons.credit_card_outlined,
    };
    final detalhe = saldo.cartao
        ? [
            nomeTipoConta(conta.tipo),
            if (conta.diaFechamento != null) 'fecha dia ${conta.diaFechamento}',
            if (conta.diaVencimento != null) 'vence dia ${conta.diaVencimento}',
          ].join(' · ')
        : nomeTipoConta(conta.tipo);
    final valor = saldo.cartao ? reais(saldo.faturaCentavos) : reais(saldo.saldoCentavos);
    final corValor = saldo.cartao
        ? (saldo.faturaCentavos > 0 ? c.bad : c.muted)
        : (saldo.saldoCentavos < 0 ? c.bad : c.text);

    return Cartao(
      raio: 16,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      aoTocar: aoTocar,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: saldo.cartao ? c.badSoft : c.accentSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icone, size: 20, color: saldo.cartao ? c.bad : c.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(conta.nome, style: manrope(15, peso: FontWeight.w600)),
                Text(detalhe, style: manrope(12, cor: c.muted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (saldo.cartao) Text('fatura', style: manrope(11, cor: c.muted)),
              Text(valor, style: manrope(15, peso: FontWeight.w700, cor: corValor)),
            ],
          ),
          if (aoPagarFatura != null) ...[
            const SizedBox(width: 10),
            BotaoPilula(texto: 'Pagar', aoTocar: aoPagarFatura!),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- Parceladas

class _Parceladas extends StatelessWidget {
  const _Parceladas({required this.quadro, required this.aoEditar});
  final QuadroFinancas quadro;
  final ValueChanged<Transacao> aoEditar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final lista = listarParceladas(quadro);
    final ativas = lista.where((p) => !p.quitada).toList();
    final porMes = ativas.fold(0, (s, p) => s + p.transacao.valorCentavos);
    final falta = ativas.fold(0, (s, p) => s + p.faltaCentavos);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          Expanded(child: _Caixa('Por mês', porMes, c.accentSoft, c.accent)),
          const SizedBox(width: 10),
          Expanded(child: _Caixa('Falta pagar', falta, c.badSoft, c.bad)),
        ]),
        const SizedBox(height: 18),
        TituloSecao(
          'Em andamento',
          direita: Text('${ativas.length}', style: manrope(13, peso: FontWeight.w700, cor: c.muted)),
        ),
        if (lista.isEmpty)
          const Vazio('Nenhuma compra parcelada. Ao lançar um gasto, escolha "Parcelada".')
        else if (ativas.isEmpty)
          const Vazio('Nenhuma parcela em aberto.'),
        for (final p in lista) ...[
          if (p.quitada && p == lista.firstWhere((x) => x.quitada)) ...[
            const SizedBox(height: 10),
            const TituloSecao('Quitadas'),
          ],
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _LinhaFixa(
              titulo: p.transacao.descricao,
              detalhe: p.quitada
                  ? 'quitada · ${p.total} parcelas'
                  : '${p.pagas} de ${p.total} pagas · faltam ${reais(p.faltaCentavos)}'
                      '${p.termina == null ? '' : ' · termina em ${mesCurto(p.termina!)}'}',
              valor: '${reais(p.transacao.valorCentavos)}/mês',
              corValor: p.quitada ? c.muted : c.text,
              fracao: p.fracao,
              aoTocar: () => aoEditar(p.transacao),
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------- Análise

/// Análise: o gasto do mês e gráficos de vários meses ([periodo]), montados
/// com os cartões ligados em Personalizar e na ordem escolhida.
class _Analise extends StatelessWidget {
  const _Analise({
    required this.quadro,
    required this.mes,
    required this.hoje,
    required this.prefs,
    required this.periodo,
    required this.aoMudarPeriodo,
  });

  final QuadroFinancas quadro;
  final DateTime mes;
  final DateTime hoje;
  final PreferenciasPainel prefs;
  final int periodo;
  final ValueChanged<int> aoMudarPeriodo;

  @override
  Widget build(BuildContext context) {
    final config = prefs.config;
    final a = analisarMes(quadro, mes, hoje);
    final fimDoMes = DateTime(mes.year, mes.month + 1, 0);
    final serie = quadro.serie(mes, meses: periodo);
    final calor = mapaDeCalor(quadro, fimDoMes, hoje);
    final rigidezMeses = rigidez(quadro, mes, meses: periodo);
    final velas = velasDoSaldo(quadro, mes, hoje, meses: periodo);

    Widget? cartao(CartaoFin c) => switch (c) {
          CartaoFin.gastoMes => _gastoMes(context, a),
          CartaoFin.leituras => CartaoLeituras(
              frases: leiturasDoPeriodo(serie: serie, calor: calor, rigidezMeses: rigidezMeses, nomeMes: mesAno),
              periodo: periodo,
              aoMudarPeriodo: aoMudarPeriodo,
            ),
          CartaoFin.trajetoria => CartaoTrajetoria(
              velas: velas,
              projecao: projetarSaldo(velas.last.fechamento, serie),
              tipo: config.tipoDe(c)!,
              aoEscolherTipo: (t) => prefs.escolherTipo(c, t),
            ),
          CartaoFin.categoriasTempo => CartaoCategoriasTempo(
              dados: categoriasNoTempo(quadro, mes, meses: periodo),
              tipo: config.tipoDe(c)!,
              aoEscolherTipo: (t) => prefs.escolherTipo(c, t),
            ),
          CartaoFin.mapaCalor => CartaoMapaCalor(mapa: calor),
          CartaoFin.rigidez => CartaoRigidez(
              meses: rigidezMeses,
              tipo: config.tipoDe(c)!,
              aoEscolherTipo: (t) => prefs.escolherTipo(c, t),
            ),
          CartaoFin.paraOndeFoi => _paraOndeFoi(context, a),
          CartaoFin.maiores => a.maiores.isEmpty ? null : _maiores(context, a),
          _ => null,
        };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BotaoPersonalizar(aoTocar: () => abrirPersonalizar(context, prefs, PainelFin.analise)),
        _Grade(itens: [
          for (final c in config.visiveis(PainelFin.analise))
            if (cartao(c) case final w?) (c, w),
        ]),
      ],
    );
  }

  Widget _gastoMes(BuildContext context, AnaliseMes a) {
    final c = context.cores;
    final v = a.variacao;
    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gasto no mês', style: manrope(12, peso: FontWeight.w600, cor: c.muted)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(reais(a.gastoCentavos), style: sora(30)),
          ),
          if (v != null) ...[
            const SizedBox(height: 4),
            Text(
              v.abs() < 0.005
                  ? 'igual ao mês anterior'
                  : '${(v.abs() * 100).round()}% ${v > 0 ? 'a mais' : 'a menos'} que o mês anterior '
                      '(${reais(a.gastoAnteriorCentavos)})',
              style: manrope(13, peso: FontWeight.w600, cor: v > 0 ? c.bad : c.teal),
            ),
          ],
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _Caixa('Média por dia', a.mediaDiaCentavos, c.surface2, c.text)),
            if (a.projecaoCentavos != null) ...[
              const SizedBox(width: 10),
              Expanded(child: _Caixa('Projeção do mês', a.projecaoCentavos!, c.accentSoft, c.violeta)),
            ],
          ]),
        ],
      ),
    );
  }

  Widget _paraOndeFoi(BuildContext context, AnaliseMes a) {
    final c = context.cores;
    final porGrupo = prefs.config.usaGrupo(CartaoFin.paraOndeFoi);
    final cats = porGrupo ? agruparParaOndeFoi(a.categorias) : a.categorias;
    final maior = cats.isEmpty ? 1 : a.gastoCentavos;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      TituloSecao(
        'Para onde foi',
        direita: TextButton(
          onPressed: () => prefs.alternarGrupo(CartaoFin.paraOndeFoi),
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 34),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(porGrupo ? 'Por categoria' : 'Por grupo',
              style: manrope(12, peso: FontWeight.w700, cor: c.accent)),
        ),
      ),
      if (cats.isEmpty) const Vazio('Nenhum gasto pago neste mês.'),
      for (final cat in cats)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                Expanded(child: Text(cat.atual.nome, style: manrope(14))),
                if (cat.anteriorCentavos > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Text(
                      _delta(cat.atual.centavos, cat.anteriorCentavos),
                      style: manrope(12,
                          peso: FontWeight.w700, cor: cat.atual.centavos > cat.anteriorCentavos ? c.bad : c.teal),
                    ),
                  ),
                Text(reais(cat.atual.centavos), style: manrope(14, peso: FontWeight.w700)),
              ]),
              const SizedBox(height: 6),
              BarraProgresso(fracao: cat.atual.centavos / maior, cor: c.accent),
            ],
          ),
        ),
    ]);
  }

  Widget _maiores(BuildContext context, AnaliseMes a) {
    final c = context.cores;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const TituloSecao('Maiores gastos'),
      Cartao(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(children: [
          for (var i = 0; i < a.maiores.length; i++) ...[
            if (i > 0) Divider(height: 1, color: c.line),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(a.maiores[i].nome,
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: manrope(14, peso: FontWeight.w600)),
                    Text('${a.maiores[i].categoria} · ${diaMesCurto(a.maiores[i].dia)}', style: manrope(12, cor: c.muted)),
                  ]),
                ),
                Text(reais(a.maiores[i].valorCentavos), style: manrope(14, peso: FontWeight.w700)),
              ]),
            ),
          ],
        ]),
      ),
    ]);
  }

  /// "+12%" / "−8%" em relação ao mês anterior.
  String _delta(int atual, int anterior) {
    final p = ((atual / anterior - 1) * 100).round();
    return p == 0 ? '=' : (p > 0 ? '+$p%' : '−${-p}%');
  }
}
