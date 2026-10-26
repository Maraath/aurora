import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/notificacoes.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/lembretes_repo.dart';
import '../componentes.dart';
import '../formulario.dart';
import '../lembretes/avisos_web.dart';
import 'form_rotina.dart';
import 'linhas_rotina.dart';

/// Todos os lembretes numa folha: os próximos (por data), os desligados e os
/// que já passaram, mais os avisos do aparelho (Web Push ou "Testar notificação").
Future<void> abrirTodosLembretes(BuildContext context) =>
    abrirFolha<void>(context, (_) => const _TodosLembretes());

class _TodosLembretes extends StatefulWidget {
  const _TodosLembretes();

  @override
  State<_TodosLembretes> createState() => _TodosLembretesState();
}

class _TodosLembretesState extends State<_TodosLembretes> {
  LembretesRepo? _repo;
  Stream<QuadroLembretes>? _quadro;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = AuroraEscopo.de(context).db;
    if (_repo?.db != db) {
      _repo = LembretesRepo(db);
      _quadro = _repo!.observarQuadro();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final barra = MediaQuery.paddingOf(context).bottom;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9),
      child: StreamBuilder<QuadroLembretes>(
        stream: _quadro,
        builder: (context, snap) {
          final q = snap.data;
          final hoje = hojeLocal();
          final lista = q == null
              ? const <LembreteVisto>[]
              : [
                  ...q.proximos,
                  ...q.todos.where((l) => !l.lembrete.ativo || l.proxima == null),
                ];
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.fromLTRB(20, 10, 20, 24 + barra),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: c.line, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: Text('Todos os lembretes', style: sora(20))),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Fechar', style: manrope(14, peso: FontWeight.w700, cor: c.muted)),
                ),
              ]),
              const SizedBox(height: 12),
              if (q != null && lista.isEmpty) const Vazio('Nenhum lembrete ainda.'),
              for (final l in lista)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: LinhaLembrete(
                    visto: l,
                    toque: l.proxima,
                    hoje: hoje,
                    mostrarDia: true,
                    aoAlternar: () => _repo!.alternarAtivo(l.lembrete.id, !l.lembrete.ativo),
                    aoEditar: () => abrirFormRotina(context, item: l.lembrete),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                'O sino liga ou desliga a notificação no celular e no PC. '
                'Tarefas e hábitos com "Me avisar" também aparecem aqui.',
                style: manrope(12, cor: c.muted, altura: 1.5),
              ),
              // Web: os avisos vêm do servidor (Web Push) e precisam ser ativados no aparelho.
              if (kIsWeb) ...[
                const SizedBox(height: 14),
                const CartaoAvisosWeb(),
              ] else
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: Notificador.instancia.testar,
                    icon: Icon(Icons.notifications_outlined, size: 18, color: c.accent),
                    label: Text('Testar notificação', style: manrope(13, peso: FontWeight.w700, cor: c.accent)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
