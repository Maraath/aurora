import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/notificacoes.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/lembretes_repo.dart';
import '../componentes.dart';
import '../em_breve.dart';
import 'form_lembrete.dart';

enum _Vista {
  proximos('Próximos'),
  recorrentes('Recorrentes');

  const _Vista(this.rotulo);
  final String rotulo;
}

class LembretesPage extends StatefulWidget {
  const LembretesPage({super.key, required this.voltar});
  final VoidCallback voltar;

  @override
  State<LembretesPage> createState() => _LembretesPageState();
}

class _LembretesPageState extends State<LembretesPage> {
  LembretesRepo? _repo;
  Stream<QuadroLembretes>? _quadro;
  var _vista = _Vista.proximos;

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
    return StreamBuilder<QuadroLembretes>(
      stream: _quadro,
      builder: (context, snap) {
        if (snap.hasError) return Text('Não consegui ler os lembretes: ${snap.error}');
        final q = snap.data;
        if (q == null) return const SizedBox(height: 200);
        return _conteudo(context, q);
      },
    );
  }

  Widget _conteudo(BuildContext context, QuadroLembretes q) {
    final c = context.cores;
    final agora = agoraSP();
    final hoje = dataSP(agora);
    final amanha = instanteSP(hoje.add(const Duration(days: 1)));
    final fimDaSemana = instanteSP(hoje.add(Duration(days: 8 - hoje.weekday)));
    final aSeguir = q.aSeguir;

    // Próximos: ativos por data; depois os desligados e os que já passaram.
    final lista = _vista == _Vista.proximos
        ? [
            ...q.proximos,
            ...q.todos.where((l) => !l.lembrete.ativo || l.proxima == null),
          ]
        : (q.recorrentes..sort((a, b) => a.lembrete.texto.compareTo(b.lembrete.texto)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TituloPagina(
          'Lembretes',
          voltar: widget.voltar,
          acao: BotaoRedondo(
            icone: Icons.add_rounded,
            dica: 'Novo lembrete',
            preenchido: true,
            aoTocar: () => abrirFormLembrete(context),
          ),
        ),
        const SizedBox(height: 18),
        Cartao(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('A SEGUIR', style: rotulo(c.teal)),
              const SizedBox(height: 6),
              Text(aSeguir?.lembrete.texto ?? 'Nada à frente', style: sora(20)),
              const SizedBox(height: 4),
              Text(
                aSeguir == null
                    ? 'Nenhum lembrete ligado'
                    : '${_quando(aSeguir.proxima!, hoje)} · '
                        '${(aSeguir.regra?.descricao ?? 'Uma vez').toLowerCase()}',
                style: manrope(13, cor: c.muted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        LinhaContadores([
          Contador(valor: '${q.contarAte(amanha)}', rotulo: 'hoje'),
          Contador(valor: '${q.contarAte(fimDaSemana)}', rotulo: 'esta semana'),
          Contador(
            valor: '${q.recorrentes.where((l) => l.lembrete.ativo).length}',
            rotulo: 'recorrentes',
          ),
        ]),
        const SizedBox(height: 18),
        Segmentos<_Vista>(
          opcoes: _Vista.values,
          selecionado: _vista,
          rotulo: (v) => v.rotulo,
          aoEscolher: (v) => setState(() => _vista = v),
        ),
        const SizedBox(height: 18),
        if (lista.isEmpty) const Vazio('Nenhum lembrete aqui. Toque em + para criar.'),
        for (final l in lista)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _LinhaLembrete(
              item: l,
              hoje: hoje,
              aoAlternar: () => _repo!.alternarAtivo(l.lembrete.id, !l.lembrete.ativo),
              aoEditar: () => abrirFormLembrete(context, lembrete: l.lembrete),
            ),
          ),
        const SizedBox(height: 4),
        Text(
          'O sino liga ou desliga a notificação no celular e no PC. '
          'Tarefas e hábitos com "Me avisar" criam lembretes aqui.',
          style: manrope(12, cor: c.muted, altura: 1.5),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: Notificador.instancia.testar,
            icon: Icon(Icons.notifications_outlined, size: 18, color: c.accent),
            label: Text('Testar notificação',
                style: manrope(13, peso: FontWeight.w700, cor: c.accent)),
          ),
        ),
      ],
    );
  }

  String _quando(DateTime instante, DateTime hoje) {
    final d = emSP(instante);
    final rel = diaRelativo(DateTime(d.year, d.month, d.day), hoje);
    return '${rel[0].toUpperCase()}${rel.substring(1)} às ${hora(d)}';
  }
}

class _LinhaLembrete extends StatelessWidget {
  const _LinhaLembrete({
    required this.item,
    required this.hoje,
    required this.aoAlternar,
    required this.aoEditar,
  });

  final LembreteVisto item;
  final DateTime hoje;
  final VoidCallback aoAlternar;
  final VoidCallback aoEditar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final l = item.lembrete;
    final ligado = l.ativo;
    final momento = emSP(item.proxima ?? l.quando);
    final dia = item.proxima == null
        ? 'PASSOU'
        : rotuloDiaLembrete(DateTime(momento.year, momento.month, momento.day), hoje);

    return Opacity(
      opacity: ligado && item.proxima != null ? 1 : 0.55,
      child: Cartao(
        raio: 16,
        padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
        aoTocar: aoEditar,
        child: Row(
          children: [
            SizedBox(
              width: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hora(momento), style: sora(16)),
                  Text(dia, style: manrope(11, peso: FontWeight.w700, cor: c.muted)),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.texto, style: manrope(15, peso: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: c.accentSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(item.regra?.descricao ?? 'Uma vez',
                            style: manrope(11, peso: FontWeight.w700, cor: c.accent)),
                      ),
                      if (item.ligadoA != null)
                        Text(item.ligadoA!,
                            style: manrope(11, peso: FontWeight.w600, cor: c.muted)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: ligado ? 'Desligar notificação de ${l.texto}' : 'Ligar notificação de ${l.texto}',
              onPressed: aoAlternar,
              icon: Icon(
                ligado ? Icons.notifications_active_outlined : Icons.notifications_off_outlined,
                color: ligado ? c.teal : c.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
