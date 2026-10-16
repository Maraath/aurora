import 'package:flutter/material.dart';

import '../../core/formato.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/tarefas_repo.dart';
import '../componentes.dart';

/// Linha de tarefa: tocar conclui/reabre; o lápis abre a edição.
class LinhaTarefa extends StatelessWidget {
  const LinhaTarefa({
    super.key,
    required this.ocorrencia,
    required this.hoje,
    required this.aoAlternar,
    required this.aoEditar,
  });

  final OcorrenciaTarefa ocorrencia;
  final DateTime hoje;
  final VoidCallback aoAlternar;
  final VoidCallback aoEditar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final o = ocorrencia;
    final (prio, corPrio) = switch (o.tarefa.prioridade) {
      Prioridade.alta => ('Alta', c.bad),
      Prioridade.media => ('Média', c.warn),
      Prioridade.baixa => ('Baixa', c.muted),
    };
    final corDetalhe = o.feita ? c.teal : (o.atrasada ? c.bad : c.muted);

    return Semantics(
      label: '${o.feita ? 'Reabrir' : 'Concluir'} ${o.tarefa.titulo}',
      button: true,
      child: Cartao(
        raio: 16,
        padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
        aoTocar: aoAlternar,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          child: Row(
            children: [
              MarcaConcluir(feito: o.feita),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: o.feita ? 0.6 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        o.tarefa.titulo,
                        style: manrope(15, peso: FontWeight.w600).copyWith(
                          decoration: o.feita ? TextDecoration.lineThrough : null,
                          decorationColor: c.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(detalheTarefa(o, hoje), style: manrope(12, cor: corDetalhe)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: corPrio),
                ),
                child: Text(prio, style: manrope(11, peso: FontWeight.w700, cor: corPrio)),
              ),
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

/// "atrasada 4 dias · Shape 80kg", "hoje · 21:00 · todo dia", "concluída".
String detalheTarefa(OcorrenciaTarefa o, DateTime hoje) {
  final partes = <String>[];
  if (o.feita && o.dia == hoje) {
    partes.add('concluída');
  } else if (o.atrasada) {
    final dias = diasEntre(o.dia!, hoje);
    partes.add(dias <= 0 ? 'atrasada' : 'atrasada $dias ${dias == 1 ? 'dia' : 'dias'}');
  } else if (o.dia == null) {
    partes.add('sem data');
  } else {
    partes.add(diaRelativo(o.dia!, hoje));
  }
  final h = o.horario;
  if (h != null && !o.feita) partes.add(horaDe(h.hora, h.minuto));
  final regra = o.regra;
  if (regra != null) partes.add(regra.descricao.toLowerCase());
  if (o.meta != null) partes.add(o.meta!.nome);
  return partes.join(' · ');
}
