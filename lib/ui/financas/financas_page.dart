import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/recorrencia.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/analise_financas.dart';
import '../../data/financas_repo.dart';
import '../componentes.dart';
import '../em_breve.dart';
import 'form_conta.dart';
import 'form_lancamento.dart';
import 'grafico_meses.dart';

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
  final _hoje = hojeSP();
  late DateTime _mes = DateTime(_hoje.year, _hoje.month, 1);
  _Vista _vista = _Vista.resumo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = AuroraEscopo.de(context).db;
    if (_repo?.db != db) {
      _repo = FinancasRepo(db);
      _quadro = _repo!.observarQuadro();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuadroFinancas>(
      stream: _quadro,
      builder: (context, snap) {
        if (snap.hasError) return Text('Não consegui ler as finanças: ${snap.error}');
        final q = snap.data;
        if (q == null) return const SizedBox(height: 200);
        return _conteudo(context, q);
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
              aoPagar: (o) => _repo!.pagar(o, !o.paga),
              aoEditar: (t) => _lancar(q, t),
            ),
          _Vista.extrato => _Extrato(quadro: q, mes: mes, hoje: _hoje, aoEditar: (t) => _lancar(q, t)),
          _Vista.fixas => _Fixas(quadro: q, aoEditar: (t) => _lancar(q, t)),
          _Vista.parceladas => _Parceladas(quadro: q, aoEditar: (t) => _lancar(q, t)),
          _Vista.contas => _Contas(quadro: q),
          _Vista.analise => _Analise(quadro: q, mes: _mes, hoje: _hoje),
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

class _Resumo extends StatelessWidget {
  const _Resumo({
    required this.quadro,
    required this.mes,
    required this.hoje,
    required this.aoPagar,
    required this.aoEditar,
  });

  final QuadroFinancas quadro;
  final MesFinancas mes;
  final DateTime hoje;
  final ValueChanged<Ocorrencia> aoPagar;
  final ValueChanged<Transacao> aoEditar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final faltaReceber =
        mes.aReceber.where((o) => !o.paga).fold(0, (s, o) => s + o.valorCentavos);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Cartao(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Saldo em conta', style: manrope(12, peso: FontWeight.w600, cor: c.muted)),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(reais(quadro.saldoCentavos),
                    style: sora(30, cor: quadro.saldoCentavos < 0 ? c.bad : c.text)),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _Caixa('Entrou', mes.entrouCentavos, c.tealSoft, c.teal)),
                const SizedBox(width: 10),
                Expanded(child: _Caixa('Saiu', mes.saiuCentavos, c.badSoft, c.bad)),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 18),
        TituloSecao(
          'Contas a pagar',
          direita: Text(reais(mes.faltaPagarCentavos), style: manrope(13, peso: FontWeight.w700)),
        ),
        if (mes.aPagar.isEmpty) const Vazio('Nenhuma conta neste mês. Toque em + para lançar.'),
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
        if (mes.aReceber.isNotEmpty) ...[
          const SizedBox(height: 10),
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
      ],
    );
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
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < lista.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: c.line),
                  _LinhaMovimento(
                    movimento: lista[i],
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

class _LinhaMovimento extends StatelessWidget {
  const _LinhaMovimento({
    required this.movimento,
    required this.conta,
    required this.destino,
    required this.aoTocar,
  });

  final Movimento movimento;
  final String? conta;
  final String? destino;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final m = movimento;
    final detalhe = m.transferencia
        ? '${conta ?? ''} → ${destino ?? ''}'
        : [m.categoria, ?conta].join(' · ');
    final valor = m.transferencia
        ? reais(m.valorCentavos)
        : (m.entrada ? '+${reais(m.valorCentavos)}' : '−${reais(m.valorCentavos)}');
    return InkWell(
      onTap: m.transferencia ? null : aoTocar,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.nome, style: manrope(15, peso: FontWeight.w600)),
                  Text(detalhe, style: manrope(12, cor: c.muted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(valor,
                style: manrope(15,
                    peso: FontWeight.w700,
                    cor: m.transferencia ? c.muted : (m.entrada ? c.teal : c.text))),
          ],
        ),
      ),
    );
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

class _Analise extends StatelessWidget {
  const _Analise({required this.quadro, required this.mes, required this.hoje});
  final QuadroFinancas quadro;
  final DateTime mes;
  final DateTime hoje;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final a = analisarMes(quadro, mes, hoje);
    final v = a.variacao;
    final maior = a.categorias.isEmpty ? 1 : a.gastoCentavos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Cartao(
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
        ),
        const SizedBox(height: 18),
        const TituloSecao('Entrou x saiu'),
        Cartao(
          padding: const EdgeInsets.fromLTRB(12, 18, 12, 8),
          child: GraficoMeses(meses: quadro.serie(mes)),
        ),
        const SizedBox(height: 18),
        const TituloSecao('Para onde foi'),
        if (a.categorias.isEmpty) const Vazio('Nenhum gasto pago neste mês.'),
        for (final cat in a.categorias)
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
                            peso: FontWeight.w700,
                            cor: cat.atual.centavos > cat.anteriorCentavos ? c.bad : c.teal),
                      ),
                    ),
                  Text(reais(cat.atual.centavos), style: manrope(14, peso: FontWeight.w700)),
                ]),
                const SizedBox(height: 6),
                BarraProgresso(fracao: cat.atual.centavos / maior, cor: c.accent),
              ],
            ),
          ),
        if (a.maiores.isNotEmpty) ...[
          const SizedBox(height: 8),
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
                        Text('${a.maiores[i].categoria} · ${diaMesCurto(a.maiores[i].dia)}',
                            style: manrope(12, cor: c.muted)),
                      ]),
                    ),
                    Text(reais(a.maiores[i].valorCentavos), style: manrope(14, peso: FontWeight.w700)),
                  ]),
                ),
              ],
            ]),
          ),
        ],
      ],
    );
  }

  /// "+12%" / "−8%" em relação ao mês anterior.
  String _delta(int atual, int anterior) {
    final p = ((atual / anterior - 1) * 100).round();
    return p == 0 ? '=' : (p > 0 ? '+$p%' : '−${-p}%');
  }
}
