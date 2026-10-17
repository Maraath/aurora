import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/tema.dart';
import '../../data/saude_repo.dart';
import '../formulario.dart';
import 'biblioteca_ui.dart';

/// Registro de um treino: cada série vem preenchida com a carga sugerida e as
/// repetições alvo; marca-se o que foi feito (ajustando se precisar).
Future<void> abrirFormSessao(BuildContext context, TreinoCompleto treino) {
  final repo = SaudeRepo(AuroraEscopo.de(context).db);
  return abrirFolha<void>(context, (_) => _FormSessao(repo: repo, treino: treino));
}

class _Serie {
  _Serie(double? carga, int reps)
      : carga = TextEditingController(text: carga == null ? '' : numero(carga)),
        reps = TextEditingController(text: '$reps');
  final TextEditingController carga;
  final TextEditingController reps;
  bool feita = false;
}

class _FormSessao extends StatefulWidget {
  const _FormSessao({required this.repo, required this.treino});
  final SaudeRepo repo;
  final TreinoCompleto treino;

  @override
  State<_FormSessao> createState() => _FormSessaoState();
}

class _FormSessaoState extends State<_FormSessao> {
  final _inicio = DateTime.now();
  late final List<List<_Serie>> _series = [
    for (final e in widget.treino.exercicios)
      [for (var n = 0; n < e.item.series; n++) _Serie(e.sugestao.cargaKg, e.item.repeticoes)],
  ];
  String? _erro;

  @override
  void dispose() {
    for (final l in _series) {
      for (final s in l) {
        s.carga.dispose();
        s.reps.dispose();
      }
    }
    super.dispose();
  }

  int get _feitas => _series.fold(0, (t, l) => t + l.where((s) => s.feita).length);

  Future<void> _salvar() async {
    final lista = <({String exercicioId, int numero, int repeticoes, double cargaKg})>[];
    for (var i = 0; i < _series.length; i++) {
      final ex = widget.treino.exercicios[i];
      var numero = 0;
      for (final s in _series[i]) {
        if (!s.feita) continue;
        final carga = lerNumero(s.carga.text) ?? 0;
        final reps = int.tryParse(s.reps.text.trim()) ?? 0;
        if (reps <= 0) {
          setState(() => _erro = 'Confira as repetições de ${ex.exercicio.nome}.');
          return;
        }
        lista.add((exercicioId: ex.exercicio.id, numero: ++numero, repeticoes: reps, cargaKg: carga));
      }
    }
    if (lista.isEmpty) {
      setState(() => _erro = 'Marque pelo menos uma série feita.');
      return;
    }
    await widget.repo.registrarSessao(treinoId: widget.treino.treino.id, inicio: _inicio, series: lista);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Folha(
      titulo: widget.treino.titulo,
      textoSalvar: _feitas == 0 ? 'Concluir treino' : 'Concluir treino · $_feitas séries',
      aoSalvar: _salvar,
      campos: [
        Text('Toque no círculo de cada série feita. Ajuste carga e repetições se mudou algo.',
            style: manrope(13, cor: c.muted, altura: 1.4)),
        for (var i = 0; i < _series.length; i++) _exercicio(c, i),
        if (_erro != null) Text(_erro!, style: manrope(13, peso: FontWeight.w600, cor: c.bad)),
      ],
    );
  }

  Widget _exercicio(AuroraCores c, int i) {
    final e = widget.treino.exercicios[i];
    final s = e.sugestao;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(e.exercicio.nome, style: manrope(15, peso: FontWeight.w700))),
            if (e.exercicio.midia != null)
              IconButton(
                tooltip: 'Ver o movimento',
                visualDensity: VisualDensity.compact,
                onPressed: () => verExercicio(context,
                    nome: e.exercicio.nome, arquivo: e.exercicio.midia!, grupo: e.exercicio.grupo),
                icon: Icon(Icons.play_circle_outline_rounded, color: c.accent),
              ),
            Text(e.plano, style: manrope(12, cor: c.muted)),
          ],
        ),
        Text(s.cargaKg == null ? 'sem histórico: anote a carga usada' : '${s.texto} · ${s.motivo}',
            style: manrope(12, cor: s.subiu ? c.teal : c.muted)),
        const SizedBox(height: 6),
        for (var n = 0; n < _series[i].length; n++) _linhaSerie(c, n + 1, _series[i][n]),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() {
              final ultima = _series[i].lastOrNull;
              _series[i].add(_Serie(
                ultima == null ? s.cargaKg : lerNumero(ultima.carga.text),
                ultima == null ? e.item.repeticoes : int.tryParse(ultima.reps.text) ?? e.item.repeticoes,
              ));
            }),
            icon: Icon(Icons.add_rounded, size: 18, color: c.accent),
            label: Text('Série extra', style: manrope(12, peso: FontWeight.w700, cor: c.accent)),
          ),
        ),
      ],
    );
  }

  Widget _linhaSerie(AuroraCores c, int numero, _Serie s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('$numero', style: manrope(13, peso: FontWeight.w700, cor: c.muted)),
          ),
          SizedBox(width: 84, child: CampoTexto(controle: s.carga, dica: '0', decimal: true)),
          const SizedBox(width: 6),
          Text('kg', style: manrope(13, cor: c.muted)),
          const SizedBox(width: 14),
          SizedBox(width: 64, child: CampoTexto(controle: s.reps, dica: '10', numerico: true)),
          const SizedBox(width: 6),
          Text('reps', style: manrope(13, cor: c.muted)),
          const Spacer(),
          Semantics(
            label: 'Série $numero feita',
            checked: s.feita,
            child: IconButton(
              onPressed: () => setState(() {
                s.feita = !s.feita;
                _erro = null;
              }),
              icon: Icon(
                s.feita ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: s.feita ? c.teal : c.muted,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
