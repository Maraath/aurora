import 'package:flutter/material.dart';

import '../../core/recorrencia.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../componentes.dart';

/// "30 min · 07:00", "8 copos · dias úteis · sem horário".
String detalheHabito(Habito h, {bool mostrarDias = false, int sequencia = 0}) {
  final partes = <String>[];
  if (h.alvo != null) {
    switch (h.tipo) {
      case TipoHabito.duracao:
        partes.add(h.alvo! >= 60 && h.alvo! % 60 == 0 ? '${h.alvo! ~/ 60} h' : '${h.alvo} min');
      case TipoHabito.quantidade:
        partes.add('${h.alvo} ${h.unidade ?? 'vezes'}');
      case TipoHabito.marcar:
        break;
    }
  }
  if (mostrarDias) partes.add(descreverDias(h.diasSemana).toLowerCase());
  partes.add(h.horario ?? 'sem horário');
  if (sequencia >= 2) partes.add('$sequencia seguidos');
  return partes.join(' · ');
}

class LinhaHabito extends StatelessWidget {
  const LinhaHabito({
    super.key,
    required this.habito,
    required this.feito,
    required this.aoAlternar,
    this.aoEditar,
    this.detalhe,
  });

  final Habito habito;
  final bool feito;
  final VoidCallback? aoAlternar;
  final VoidCallback? aoEditar;
  final String? detalhe;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Semantics(
      label: aoAlternar == null ? habito.nome : '${feito ? 'Desmarcar' : 'Concluir'} ${habito.nome}',
      button: aoAlternar != null,
      child: Cartao(
        raio: 16,
        padding: EdgeInsets.fromLTRB(14, 10, aoEditar == null ? 14 : 4, 10),
        aoTocar: aoAlternar,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 36),
          child: Row(
            children: [
              if (aoAlternar != null) ...[
                MarcaConcluir(feito: feito),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: feito ? 0.6 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        habito.nome,
                        style: manrope(15, peso: FontWeight.w600).copyWith(
                          decoration: feito ? TextDecoration.lineThrough : null,
                          decorationColor: c.text,
                        ),
                      ),
                      Text(detalhe ?? detalheHabito(habito), style: manrope(12, cor: c.muted)),
                    ],
                  ),
                ),
              ),
              if (aoEditar != null)
                IconButton(
                  tooltip: 'Editar',
                  onPressed: aoEditar,
                  icon: Icon(Icons.edit_outlined, size: 18, color: c.muted),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
