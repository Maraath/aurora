import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/financas_repo.dart';
import '../formulario.dart';

const _nomesTipo = {
  TipoConta.corrente: 'Conta corrente',
  TipoConta.poupanca: 'Poupança',
  TipoConta.cartao: 'Cartão',
};

String nomeTipoConta(TipoConta t) => _nomesTipo[t]!;

/// Nova conta/cartão ou edição.
Future<void> abrirFormConta(BuildContext context, {ContaFinanceira? conta}) {
  final repo = FinancasRepo(AuroraEscopo.de(context).db);
  return abrirFolha<void>(context, (_) => _FormConta(repo: repo, conta: conta));
}

class _FormConta extends StatefulWidget {
  const _FormConta({required this.repo, required this.conta});
  final FinancasRepo repo;
  final ContaFinanceira? conta;

  @override
  State<_FormConta> createState() => _FormContaState();
}

class _FormContaState extends State<_FormConta> {
  late final TextEditingController _nome;
  late final TextEditingController _saldo;
  late final TextEditingController _fecha;
  late final TextEditingController _vence;
  late TipoConta _tipo;
  String? _erro;

  bool get _cartao => _tipo == TipoConta.cartao;

  @override
  void initState() {
    super.initState();
    final c = widget.conta;
    _tipo = c?.tipo ?? TipoConta.corrente;
    _nome = TextEditingController(text: c?.nome ?? '');
    // No cartão, o saldo inicial negativo é a fatura que já existia.
    final inicial = c?.saldoInicialCentavos ?? 0;
    _saldo = TextEditingController(
        text: inicial == 0 ? '' : centavosParaCampo(_cartao ? -inicial : inicial));
    _fecha = TextEditingController(text: c?.diaFechamento?.toString() ?? '');
    _vence = TextEditingController(text: c?.diaVencimento?.toString() ?? '');
  }

  @override
  void dispose() {
    _nome.dispose();
    _saldo.dispose();
    _fecha.dispose();
    _vence.dispose();
    super.dispose();
  }

  int? _dia(TextEditingController c) {
    final d = int.tryParse(c.text.trim());
    return d != null && d >= 1 && d <= 31 ? d : null;
  }

  Future<void> _salvar() async {
    final nome = _nome.text.trim();
    if (nome.isEmpty) {
      setState(() => _erro = 'Dê um nome para a conta.');
      return;
    }
    final saldo = _saldo.text.trim().isEmpty ? 0 : lerCentavos(_saldo.text);
    if (saldo == null) {
      setState(() => _erro = 'O valor não é um número.');
      return;
    }
    final dados = ContasFinanceirasCompanion(
      nome: Value(nome),
      tipo: Value(_tipo),
      saldoInicialCentavos: Value(_cartao ? -saldo : saldo),
      diaFechamento: Value(_cartao ? _dia(_fecha) : null),
      diaVencimento: Value(_cartao ? _dia(_vence) : null),
    );
    await widget.repo.salvarConta(dados, id: widget.conta?.id);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _excluir() async {
    final ok = await widget.repo.excluirConta(widget.conta!.id);
    if (!mounted) return;
    if (!ok) {
      setState(() => _erro = 'Há lançamentos nesta conta. Exclua ou mude a conta deles antes.');
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    Widget dia(String rotulo, TextEditingController controle) => Row(
          children: [
            Text(rotulo, style: manrope(13, cor: c.muted)),
            const SizedBox(width: 10),
            SizedBox(width: 72, child: CampoTexto(controle: controle, dica: '10', numerico: true)),
          ],
        );

    return Folha(
      titulo: widget.conta == null ? 'Nova conta ou cartão' : 'Editar ${widget.conta!.nome}',
      textoSalvar: 'Salvar',
      aoSalvar: _salvar,
      aoExcluir: widget.conta == null ? null : _excluir,
      campos: [
        Campo(
          rotulo: 'Tipo',
          child: GradeChips(filhos: [
            for (final t in TipoConta.values)
              OpcaoChip(
                texto: nomeTipoConta(t),
                quadrado: true,
                selecionado: _tipo == t,
                aoTocar: () => setState(() => _tipo = t),
              ),
          ]),
        ),
        Campo(
          rotulo: 'Nome',
          child: CampoTexto(
            controle: _nome,
            dica: _cartao ? 'Ex.: Nubank, Visa' : 'Ex.: Conta do banco, Reserva',
            autofoco: widget.conta == null,
            aoMudar: (_) => setState(() => _erro = null),
          ),
        ),
        Campo(
          rotulo: _cartao ? 'Fatura em aberto quando começou a usar o Aurora' : 'Saldo inicial',
          child: CampoValor(controle: _saldo, aoMudar: (_) => setState(() => _erro = null)),
        ),
        if (_cartao) ...[
          dia('Fecha no dia', _fecha),
          dia('Vence no dia', _vence),
        ],
        if (_erro != null) Text(_erro!, style: manrope(13, peso: FontWeight.w600, cor: c.bad)),
      ],
    );
  }
}

/// Paga a fatura do [cartao] com dinheiro de uma das [contas] (não cartões).
Future<void> abrirPagarFatura(BuildContext context,
    {required SaldoConta cartao, required List<ContaFinanceira> contas}) {
  final repo = FinancasRepo(AuroraEscopo.de(context).db);
  return abrirFolha<void>(
    context,
    (_) => _PagarFatura(repo: repo, cartao: cartao, contas: contas),
  );
}

class _PagarFatura extends StatefulWidget {
  const _PagarFatura({required this.repo, required this.cartao, required this.contas});
  final FinancasRepo repo;
  final SaldoConta cartao;
  final List<ContaFinanceira> contas;

  @override
  State<_PagarFatura> createState() => _PagarFaturaState();
}

class _PagarFaturaState extends State<_PagarFatura> {
  late final TextEditingController _valor =
      TextEditingController(text: centavosParaCampo(widget.cartao.faturaCentavos));
  late String? _origem = widget.contas.firstOrNull?.id;
  final _hoje = hojeLocal();
  late DateTime _data = _hoje;
  String? _erro;

  @override
  void dispose() {
    _valor.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final valor = lerCentavos(_valor.text);
    if (valor == null || valor <= 0) {
      setState(() => _erro = 'Informe um valor maior que zero.');
      return;
    }
    if (_origem == null) {
      setState(() => _erro = 'Crie uma conta corrente ou poupança para pagar a fatura.');
      return;
    }
    await widget.repo.pagarFatura(
      cartao: widget.cartao.conta,
      origemId: _origem!,
      valorCentavos: valor,
      instante: _data == _hoje ? DateTime.now() : instanteLocal(_data, 12),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Folha(
      titulo: 'Pagar fatura · ${widget.cartao.conta.nome}',
      textoSalvar: 'Pagar fatura',
      aoSalvar: _salvar,
      campos: [
        Campo(rotulo: 'Valor', child: CampoValor(controle: _valor)),
        if (widget.contas.length > 1)
          Campo(
            rotulo: 'Pagar com',
            child: GrupoChips<String?>(
              opcoes: [for (final x in widget.contas) x.id],
              selecionado: _origem,
              rotulo: (id) => widget.contas.firstWhere((x) => x.id == id).nome,
              aoEscolher: (id) => setState(() => _origem = id),
            ),
          ),
        Campo(
          rotulo: 'Quando',
          child: EscolhaData(
            data: _data,
            hoje: _hoje,
            permiteSemData: false,
            aoMudar: (d) => setState(() => _data = d ?? _hoje),
          ),
        ),
        Text(
          'O pagamento sai da conta e zera a fatura; não conta como gasto de novo, '
          'porque as compras já entraram em "para onde foi".',
          style: manrope(12, cor: c.muted, altura: 1.4),
        ),
        if (_erro != null) Text(_erro!, style: manrope(13, peso: FontWeight.w600, cor: c.bad)),
      ],
    );
  }
}
