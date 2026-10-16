import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/tema.dart';
import '../../data/alimentacao_repo.dart';
import '../../data/banco.dart';
import '../formulario.dart';

/// Alvos diários para dia de treino e de descanso.
Future<void> abrirFormAlvos(BuildContext context, {AlvoDieta? treino, AlvoDieta? descanso}) {
  final repo = AlimentacaoRepo(AuroraEscopo.de(context).db);
  return abrirFolha<void>(context, (_) => _FormAlvos(repo: repo, treino: treino, descanso: descanso));
}

class _Campos {
  _Campos(AlvoDieta? a)
      : kcal = TextEditingController(text: a == null ? '' : numero(a.kcal)),
        p = TextEditingController(text: a == null ? '' : numero(a.proteina)),
        c = TextEditingController(text: a == null ? '' : numero(a.carboidrato)),
        g = TextEditingController(text: a == null ? '' : numero(a.gordura));
  final TextEditingController kcal, p, c, g;

  void dispose() {
    for (final x in [kcal, p, c, g]) {
      x.dispose();
    }
  }

  bool get vazio => [kcal, p, c, g].every((x) => x.text.trim().isEmpty);

  Nutrientes ler() {
    double v(TextEditingController x) => lerNumero(x.text) ?? 0;
    final p_ = v(p), c_ = v(c), g_ = v(g);
    return Nutrientes(kcal.text.trim().isEmpty ? kcalDosMacros(p_, c_, g_) : v(kcal), p_, c_, g_);
  }
}

class _FormAlvos extends StatefulWidget {
  const _FormAlvos({required this.repo, required this.treino, required this.descanso});
  final AlimentacaoRepo repo;
  final AlvoDieta? treino;
  final AlvoDieta? descanso;

  @override
  State<_FormAlvos> createState() => _FormAlvosState();
}

class _FormAlvosState extends State<_FormAlvos> {
  late final _treino = _Campos(widget.treino);
  late final _descanso = _Campos(widget.descanso);
  String? _erro;

  @override
  void dispose() {
    _treino.dispose();
    _descanso.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    for (final (tipo, campos) in [(TipoDia.treino, _treino), (TipoDia.descanso, _descanso)]) {
      if (campos.vazio) continue;
      final n = campos.ler();
      if (n.kcal <= 0) {
        setState(() => _erro = 'Informe as calorias (ou os macros) do dia de ${tipo.name}.');
        return;
      }
      await widget.repo.salvarAlvo(tipo, n);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    Widget bloco(String titulo, _Campos x) {
      Widget campo(String rotulo, TextEditingController controle) => Expanded(
            child: Campo(rotulo: rotulo, child: CampoTexto(controle: controle, dica: '0', decimal: true)),
          );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(titulo, style: rotulo(c.accent)),
          const SizedBox(height: 8),
          Row(children: [campo('Calorias (kcal)', x.kcal), const SizedBox(width: 10), campo('Proteína (g)', x.p)]),
          const SizedBox(height: 8),
          Row(children: [campo('Carboidrato (g)', x.c), const SizedBox(width: 10), campo('Gordura (g)', x.g)]),
        ],
      );
    }

    return Folha(
      titulo: 'Alvos do dia',
      textoSalvar: 'Salvar alvos',
      aoSalvar: _salvar,
      campos: [
        Text(
          'O Aurora usa o alvo de dia de treino quando há treino na sua ficha ou registrado no dia. '
          'Sem calorias, calcula pelos macros.',
          style: manrope(13, cor: c.muted, altura: 1.4),
        ),
        bloco('DIA DE TREINO', _treino),
        bloco('DIA DE DESCANSO', _descanso),
        if (_erro != null) Text(_erro!, style: manrope(13, peso: FontWeight.w600, cor: c.bad)),
      ],
    );
  }
}
