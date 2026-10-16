import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/saude_repo.dart';
import '../formulario.dart';

/// Registra as medidas de um dia. Só o que for preenchido é gravado.
Future<void> abrirFormMedidas(BuildContext context, QuadroSaude quadro) {
  final repo = SaudeRepo(AuroraEscopo.de(context).db);
  return abrirFolha<void>(context, (_) => _FormMedidas(repo: repo, quadro: quadro));
}

class _FormMedidas extends StatefulWidget {
  const _FormMedidas({required this.repo, required this.quadro});
  final SaudeRepo repo;
  final QuadroSaude quadro;

  @override
  State<_FormMedidas> createState() => _FormMedidasState();
}

class _FormMedidasState extends State<_FormMedidas> {
  final _hoje = hojeSP();
  late DateTime _dia = _hoje;

  /// Tipo → (unidade, campo). Os padrão e os livres que já têm registro.
  late final Map<String, (String, TextEditingController)> _campos = {
    for (final (t, u) in medidasPadrao) t: (u, TextEditingController()),
    for (final t in widget.quadro.tiposMedida)
      if (!medidasPadrao.any((p) => p.$1 == t))
        t: (widget.quadro.ultima(t)!.unidade, TextEditingController()),
  };
  final _outraNome = TextEditingController();
  final _outraValor = TextEditingController();
  final _outraUnidade = TextEditingController(text: 'cm');
  String? _erro;

  @override
  void dispose() {
    for (final (_, c) in _campos.values) {
      c.dispose();
    }
    _outraNome.dispose();
    _outraValor.dispose();
    _outraUnidade.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final lista = <({String tipo, double valor, String unidade})>[];
    for (final MapEntry(key: tipo, value: (unidade, campo)) in _campos.entries) {
      if (campo.text.trim().isEmpty) continue;
      final v = lerNumero(campo.text);
      if (v == null || v <= 0) {
        setState(() => _erro = 'O valor de $tipo não é um número.');
        return;
      }
      lista.add((tipo: tipo, valor: v, unidade: unidade));
    }
    final outra = _outraNome.text.trim();
    if (outra.isNotEmpty) {
      final v = lerNumero(_outraValor.text);
      if (v == null || v <= 0) {
        setState(() => _erro = 'Informe o valor de $outra.');
        return;
      }
      final nome = outra[0].toUpperCase() + outra.substring(1);
      lista.add((tipo: nome, valor: v, unidade: _outraUnidade.text.trim()));
    }
    if (lista.isEmpty) {
      setState(() => _erro = 'Preencha pelo menos uma medida.');
      return;
    }
    await widget.repo.salvarMedidas(_dia, lista);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Folha(
      titulo: 'Registrar medidas',
      textoSalvar: 'Salvar medidas',
      aoSalvar: _salvar,
      campos: [
        Campo(
          rotulo: 'Dia',
          child: EscolhaData(
            data: _dia,
            hoje: _hoje,
            permiteSemData: false,
            aoMudar: (d) => setState(() => _dia = d ?? _hoje),
          ),
        ),
        for (final MapEntry(key: tipo, value: (unidade, campo)) in _campos.entries)
          Row(
            children: [
              SizedBox(width: 96, child: Text(tipo, style: manrope(14, peso: FontWeight.w600))),
              SizedBox(
                width: 100,
                child: CampoTexto(
                  controle: campo,
                  dica: widget.quadro.ultima(tipo) == null
                      ? '0'
                      : numero(widget.quadro.ultima(tipo)!.valor),
                  decimal: true,
                  aoMudar: (_) => setState(() => _erro = null),
                ),
              ),
              const SizedBox(width: 8),
              Text(unidade, style: manrope(13, cor: c.muted)),
            ],
          ),
        Campo(
          rotulo: 'Outra medida (opcional)',
          child: Row(
            children: [
              Expanded(child: CampoTexto(controle: _outraNome, dica: 'Ex.: Coxa, Peito')),
              const SizedBox(width: 8),
              SizedBox(width: 84, child: CampoTexto(controle: _outraValor, dica: '0', decimal: true)),
              const SizedBox(width: 8),
              SizedBox(width: 64, child: CampoTexto(controle: _outraUnidade, dica: 'cm')),
            ],
          ),
        ),
        Text('O número cinza é o último registro. Gravar de novo no mesmo dia substitui.',
            style: manrope(12, cor: c.muted, altura: 1.4)),
        if (_erro != null) Text(_erro!, style: manrope(13, peso: FontWeight.w600, cor: c.bad)),
      ],
    );
  }
}
