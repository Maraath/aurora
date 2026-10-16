import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/recorrencia.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/financas_repo.dart';
import '../componentes.dart';
import '../formulario.dart';

/// Novo lançamento ou edição de um existente. [contas] alimenta a escolha de
/// conta ou cartão.
Future<void> abrirFormLancamento(BuildContext context,
    {Transacao? transacao, required List<ContaFinanceira> contas, String? contaPrincipalId}) {
  final repo = FinancasRepo(AuroraEscopo.de(context).db);
  return abrirFolha<void>(
    context,
    (_) => _FormLancamento(
      repo: repo,
      transacao: transacao,
      contas: contas,
      contaPrincipalId: contaPrincipalId,
    ),
  );
}

class _FormLancamento extends StatefulWidget {
  const _FormLancamento({
    required this.repo,
    required this.transacao,
    required this.contas,
    required this.contaPrincipalId,
  });

  final FinancasRepo repo;
  final Transacao? transacao;
  final List<ContaFinanceira> contas;
  final String? contaPrincipalId;

  @override
  State<_FormLancamento> createState() => _FormLancamentoState();
}

class _FormLancamentoState extends State<_FormLancamento> {
  late final TextEditingController _desc;
  late final TextEditingController _valor;
  late final TextEditingController _parcelas;
  late TipoTransacao _tipo;
  late String _categoria;
  late FormaTransacao _forma;
  late bool _pago;
  late DateTime _data;
  String? _contaId;
  String? _erro;

  final _hoje = hojeSP();

  Transacao? get _t => widget.transacao;
  bool get _editando => _t != null;
  bool get _saida => _tipo == TipoTransacao.saida;

  @override
  void initState() {
    super.initState();
    final t = _t;
    _desc = TextEditingController(text: t?.descricao ?? '');
    _valor = TextEditingController(text: t == null ? '' : centavosParaCampo(t.valorCentavos));
    _parcelas = TextEditingController(text: '${t?.parcelaTotal ?? 3}');
    _tipo = t?.tipo ?? TipoTransacao.saida;
    _categoria = t?.categoria ?? (_saida ? 'Mercado' : 'Salário');
    _forma = t == null ? FormaTransacao.unica : formaDe(t);
    _pago = t == null ? true : t.pagoEm != null;
    _data = t == null ? _hoje : dataSP(t.pagoEm ?? t.vencimento ?? t.data);
    _contaId = t?.contaId ?? widget.contaPrincipalId;
  }

  @override
  void dispose() {
    _desc.dispose();
    _valor.dispose();
    _parcelas.dispose();
    super.dispose();
  }

  int get _numParcelas => (int.tryParse(_parcelas.text.trim()) ?? 2).clamp(2, 48);

  String get _textoSalvar {
    if (_editando) return 'Salvar';
    if (!_saida) return 'Salvar entrada';
    return _pago ? 'Salvar gasto' : 'Salvar conta a pagar';
  }

  /// Instante gravado para a data escolhida: agora, se for hoje; senão meio-dia.
  DateTime _instante(DateTime dia, {int hora = 12}) =>
      dia == _hoje ? DateTime.now() : instanteSP(dia, hora);

  Future<void> _salvar() async {
    final desc = _desc.text.trim();
    if (desc.isEmpty) {
      setState(() => _erro = 'Escreva uma descrição.');
      return;
    }
    final valor = lerCentavos(_valor.text);
    if (valor == null || valor <= 0) {
      setState(() => _erro = 'Informe um valor maior que zero.');
      return;
    }

    if (_editando) {
      final t = _t!;
      var dados = TransacoesCompanion(
        descricao: Value(desc),
        valorCentavos: Value(valor),
        categoria: Value(_categoria),
        contaId: Value(_contaId),
      );
      if (_forma == FormaTransacao.unica) {
        dados = t.pagoEm != null
            ? dados.copyWith(data: Value(_instante(_data)), pagoEm: Value(_instante(_data)))
            : dados.copyWith(data: Value(instanteSP(_data, 9)), vencimento: Value(instanteSP(_data, 9)));
      }
      await widget.repo.salvar(dados, id: t.id);
      if (mounted) Navigator.pop(context);
      return;
    }

    final forma = _saida ? _forma : (_forma == FormaTransacao.parcelada ? FormaTransacao.unica : _forma);
    final TransacoesCompanion dados;
    switch (forma) {
      case FormaTransacao.unica:
        final instante = _pago ? _instante(_data) : instanteSP(_data, 9);
        dados = TransacoesCompanion.insert(
          descricao: desc,
          valorCentavos: valor,
          tipo: _tipo,
          data: instante,
          vencimento: Value(_pago ? null : instante),
          pagoEm: Value(_pago ? instante : null),
          categoria: Value(_categoria),
          contaId: Value(_contaId),
        );
      case FormaTransacao.recorrente:
      case FormaTransacao.parcelada:
        final parcelada = forma == FormaTransacao.parcelada;
        final venc = instanteSP(_data, 9);
        dados = TransacoesCompanion.insert(
          descricao: desc,
          valorCentavos: parcelada ? (valor / _numParcelas).round() : valor,
          tipo: _tipo,
          data: venc,
          vencimento: Value(venc),
          regraRepeticao: Value(Regra.mensal(_data.day).rrule),
          parcelaNumero: Value(parcelada ? 1 : null),
          parcelaTotal: Value(parcelada ? _numParcelas : null),
          categoria: Value(_categoria),
          contaId: Value(_contaId),
        );
    }
    await widget.repo.salvar(dados, pagarPrimeira: _pago);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _excluir() async {
    final c = context.cores;
    final t = _t!;
    final regra = t.regraRepeticao != null;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text(regra ? 'Encerrar “${t.descricao}”?' : 'Excluir lançamento?', style: sora(18)),
        content: Text(
          regra
              ? 'As próximas deixam de aparecer. O que já foi pago continua no extrato.'
              : '“${t.descricao}” sai das contas e do extrato.',
          style: manrope(14, cor: c.text, altura: 1.4),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(regra ? 'Encerrar' : 'Excluir', style: TextStyle(color: c.bad)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await widget.repo.excluir(t);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final categorias = _saida ? categoriasSaida : categoriasEntrada;
    final valorParcela = lerCentavos(_valor.text);
    final regra = _forma != FormaTransacao.unica;

    final String rotuloData;
    if (regra) {
      rotuloData = _editando ? 'Vence todo mês no dia' : 'Primeiro vencimento';
    } else {
      rotuloData = _pago ? (_saida ? 'Quando foi' : 'Quando recebeu') : 'Vencimento';
    }

    return Folha(
      titulo: _editando ? 'Editar lançamento' : 'Novo lançamento',
      textoSalvar: _textoSalvar,
      aoSalvar: _salvar,
      aoExcluir: _editando ? _excluir : null,
      campos: [
        if (!_editando)
          Segmentos<TipoTransacao>(
            opcoes: const [TipoTransacao.saida, TipoTransacao.entrada],
            selecionado: _tipo,
            rotulo: (t) => t == TipoTransacao.saida ? 'Gasto ou conta' : 'Entrada',
            aoEscolher: (t) => setState(() {
              _tipo = t;
              _categoria = t == TipoTransacao.saida ? 'Mercado' : 'Salário';
              if (t == TipoTransacao.entrada && _forma == FormaTransacao.parcelada) {
                _forma = FormaTransacao.unica;
              }
              _erro = null;
            }),
          ),
        Campo(
          rotulo: 'Descrição',
          child: CampoTexto(
            controle: _desc,
            dica: _saida ? 'Ex.: Mercado do mês, Conta de luz' : 'Ex.: Salário de outubro',
            autofoco: !_editando,
            aoMudar: (_) => setState(() => _erro = null),
          ),
        ),
        Campo(
          rotulo: !_editando && _forma == FormaTransacao.parcelada
              ? 'Valor total da compra'
              : (_editando && _forma == FormaTransacao.parcelada ? 'Valor de cada parcela' : 'Valor'),
          child: CampoValor(
            controle: _valor,
            cor: _saida ? c.text : c.teal,
            aoMudar: (_) => setState(() => _erro = null),
          ),
        ),
        Campo(
          rotulo: 'Categoria',
          child: GrupoChips<String>(
            opcoes: [...categorias, if (!categorias.contains(_categoria)) _categoria],
            selecionado: _categoria,
            rotulo: (s) => s,
            aoEscolher: (s) => setState(() => _categoria = s),
          ),
        ),
        if (!_editando)
          Campo(
            rotulo: 'Forma',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GradeChips(filhos: [
                  for (final (f, texto, dica) in [
                    (FormaTransacao.unica, 'Única', 'uma vez'),
                    (FormaTransacao.recorrente, 'Recorrente', 'todo mês'),
                    if (_saida) (FormaTransacao.parcelada, 'Parcelada', 'em vezes'),
                  ])
                    OpcaoChip(
                      texto: texto,
                      dica: dica,
                      quadrado: true,
                      selecionado: _forma == f,
                      aoTocar: () => setState(() => _forma = f),
                    ),
                ]),
                if (_forma == FormaTransacao.parcelada)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        Text('Parcelas', style: manrope(13, cor: c.muted)),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 72,
                          child: CampoTexto(
                            controle: _parcelas,
                            dica: '3',
                            numerico: true,
                            aoMudar: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (valorParcela != null && valorParcela > 0)
                          Expanded(
                            child: Text(
                              '${_numParcelas}x de ${reais((valorParcela / _numParcelas).round())}',
                              style: manrope(13, peso: FontWeight.w700, cor: c.accent),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        if (!_editando)
          LinhaInterruptor(
            titulo: _saida ? 'Já foi pago?' : 'Já recebeu?',
            detalhe: regra
                ? (_pago ? 'o primeiro mês já conta como pago' : 'o primeiro mês fica em aberto')
                : (_saida
                    ? (_pago ? 'sai do saldo agora' : 'vai para Contas a pagar')
                    : (_pago ? 'entra no saldo agora' : 'fica em A receber')),
            valor: _pago,
            aoMudar: (v) => setState(() => _pago = v),
          ),
        if (!_editando || !regra)
          Campo(
            rotulo: rotuloData,
            child: EscolhaData(
              data: _data,
              hoje: _hoje,
              permiteSemData: false,
              aoMudar: (d) => setState(() => _data = d ?? _hoje),
            ),
          )
        else
          Text(
            '${Regra.ler(_t!.regraRepeticao)?.descricao ?? ''}. Para mudar o dia, encerre e crie de novo.',
            style: manrope(13, cor: c.muted, altura: 1.4),
          ),
        if (widget.contas.length > 1)
          Campo(
            rotulo: 'Conta ou cartão',
            child: GrupoChips<String?>(
              opcoes: [for (final conta in widget.contas) conta.id],
              selecionado: _contaId,
              rotulo: (id) => widget.contas.firstWhere((x) => x.id == id).nome,
              aoEscolher: (id) => setState(() => _contaId = id),
            ),
          ),
        if (_erro != null)
          Text(_erro!, style: manrope(13, peso: FontWeight.w600, cor: c.bad)),
      ],
    );
  }
}
