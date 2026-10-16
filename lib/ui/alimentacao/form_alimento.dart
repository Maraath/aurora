import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/tema.dart';
import '../../data/alimentacao_repo.dart';
import '../../data/banco.dart';
import '../formulario.dart';

/// Novo alimento ou edição. Valores por 100 g, como nos rótulos e tabelas.
Future<String?> abrirFormAlimento(BuildContext context, {Alimento? alimento, String? nomeInicial}) {
  final repo = AlimentacaoRepo(AuroraEscopo.de(context).db);
  return abrirFolha<String>(
    context,
    (_) => _FormAlimento(repo: repo, alimento: alimento, nomeInicial: nomeInicial),
  );
}

class _FormAlimento extends StatefulWidget {
  const _FormAlimento({required this.repo, required this.alimento, this.nomeInicial});
  final AlimentacaoRepo repo;
  final Alimento? alimento;
  final String? nomeInicial;

  @override
  State<_FormAlimento> createState() => _FormAlimentoState();
}

class _FormAlimentoState extends State<_FormAlimento> {
  late final _nome = TextEditingController(text: widget.alimento?.nome ?? widget.nomeInicial ?? '');
  late final _kcal = TextEditingController(text: _num(widget.alimento?.kcal));
  late final _p = TextEditingController(text: _num(widget.alimento?.proteina));
  late final _c = TextEditingController(text: _num(widget.alimento?.carboidrato));
  late final _g = TextEditingController(text: _num(widget.alimento?.gordura));
  late final _porcaoNome = TextEditingController(text: widget.alimento?.porcaoNome ?? '');
  late final _porcaoG = TextEditingController(text: _num(widget.alimento?.porcaoGramas));
  String? _erro;

  static String _num(double? v) => v == null ? '' : numero(v);

  @override
  void dispose() {
    for (final c in [_nome, _kcal, _p, _c, _g, _porcaoNome, _porcaoG]) {
      c.dispose();
    }
    super.dispose();
  }

  double _ler(TextEditingController c) => lerNumero(c.text) ?? 0;

  Future<void> _salvar() async {
    final nome = _nome.text.trim();
    if (nome.isEmpty) {
      setState(() => _erro = 'Dê um nome para o alimento.');
      return;
    }
    final p = _ler(_p), c = _ler(_c), g = _ler(_g);
    // Sem kcal informada, calcula pelos macros.
    final kcal = _kcal.text.trim().isEmpty ? kcalDosMacros(p, c, g) : _ler(_kcal);
    if (kcal <= 0) {
      setState(() => _erro = 'Informe as calorias ou os macros por 100 g.');
      return;
    }
    final porcaoG = lerNumero(_porcaoG.text);
    final porcaoNome = _porcaoNome.text.trim();
    if ((porcaoNome.isEmpty) != (porcaoG == null)) {
      setState(() => _erro = 'Para a porção caseira, preencha o nome e os gramas.');
      return;
    }
    final id = await widget.repo.salvarAlimento(
      AlimentosCompanion(
        nome: Value(nome),
        kcal: Value(kcal),
        proteina: Value(p),
        carboidrato: Value(c),
        gordura: Value(g),
        porcaoNome: Value(porcaoNome.isEmpty ? null : porcaoNome),
        porcaoGramas: Value(porcaoG),
      ),
      id: widget.alimento?.id,
    );
    if (mounted) Navigator.pop(context, id);
  }

  Future<void> _excluir() async {
    await widget.repo.excluirAlimento(widget.alimento!.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    Widget campo(String rotulo, TextEditingController controle, String dica) => Expanded(
          child: Campo(
            rotulo: rotulo,
            child: CampoTexto(controle: controle, dica: dica, decimal: true, aoMudar: (_) => setState(() => _erro = null)),
          ),
        );

    return Folha(
      titulo: widget.alimento == null ? 'Novo alimento' : 'Editar alimento',
      textoSalvar: 'Salvar alimento',
      aoSalvar: _salvar,
      aoExcluir: widget.alimento == null ? null : _excluir,
      campos: [
        Campo(
          rotulo: 'Nome',
          child: CampoTexto(
            controle: _nome,
            dica: 'Ex.: Arroz branco cozido, Peito de frango grelhado',
            autofoco: widget.alimento == null && widget.nomeInicial == null,
            aoMudar: (_) => setState(() => _erro = null),
          ),
        ),
        Text('VALORES EM 100 g', style: rotulo(c.accent)),
        Row(children: [
          campo('Calorias (kcal)', _kcal, 'auto'),
          const SizedBox(width: 10),
          campo('Proteína (g)', _p, '0'),
        ]),
        Row(children: [
          campo('Carboidrato (g)', _c, '0'),
          const SizedBox(width: 10),
          campo('Gordura (g)', _g, '0'),
        ]),
        Text('Sem calorias, o Aurora calcula pelos macros (4 kcal por g de proteína e carboidrato, 9 por g de gordura).',
            style: manrope(12, cor: c.muted, altura: 1.4)),
        Campo(
          rotulo: 'Porção caseira (opcional)',
          child: Row(children: [
            Expanded(child: CampoTexto(controle: _porcaoNome, dica: 'Ex.: 1 ovo, 1 colher')),
            const SizedBox(width: 8),
            SizedBox(width: 90, child: CampoTexto(controle: _porcaoG, dica: 'g', decimal: true)),
            const SizedBox(width: 6),
            Text('g', style: manrope(13, cor: c.muted)),
          ]),
        ),
        if (_erro != null) Text(_erro!, style: manrope(13, peso: FontWeight.w600, cor: c.bad)),
      ],
    );
  }
}
