import 'package:flutter/material.dart';

import '../core/tema.dart';
import 'componentes.dart';

/// Tela provisória dos módulos que chegam nas próximas fases.
class EmBreve extends StatelessWidget {
  const EmBreve({
    super.key,
    required this.titulo,
    required this.fase,
    required this.descricao,
    this.voltar,
  });

  final String titulo;
  final String fase;
  final String descricao;
  final VoidCallback? voltar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TituloPagina(titulo, voltar: voltar),
        const SizedBox(height: 18),
        Cartao(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CHEGA NA ${fase.toUpperCase()}', style: rotulo(c.accent)),
              const SizedBox(height: 8),
              Text(descricao, style: manrope(14, cor: c.text, altura: 1.5)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Título grande de página, com botão de voltar opcional.
class TituloPagina extends StatelessWidget {
  const TituloPagina(this.texto, {super.key, this.voltar});
  final String texto;
  final VoidCallback? voltar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Row(
      children: [
        if (voltar != null)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              onPressed: voltar,
              tooltip: 'Voltar',
              icon: Icon(Icons.chevron_left_rounded, size: 28, color: c.text),
              style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
            ),
          ),
        Text(texto, style: sora(26)),
      ],
    );
  }
}
