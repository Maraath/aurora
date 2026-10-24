import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/metas_repo.dart';
import '../componentes.dart';
import '../em_breve.dart';
import '../formulario.dart';
import 'form_meta.dart';

class MetasPage extends StatefulWidget {
  const MetasPage({super.key, this.voltar});
  final VoidCallback? voltar;

  @override
  State<MetasPage> createState() => _MetasPageState();
}

class _MetasPageState extends State<MetasPage> {
  MetasRepo? _repo;
  Stream<List<ProgressoMeta>>? _metas;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = AuroraEscopo.de(context).db;
    if (_repo?.db != db) {
      _repo = MetasRepo(db);
      _metas = _repo!.observarMetas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProgressoMeta>>(
      stream: _metas,
      builder: (context, snap) {
        if (snap.hasError) return Text('Não consegui ler as metas: ${snap.error}');
        final metas = snap.data;
        if (metas == null) return const SizedBox(height: 200);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TituloPagina(
              'Metas',
              voltar: widget.voltar,
              acao: BotaoRedondo(
                icone: Icons.add_rounded,
                dica: 'Nova meta',
                preenchido: true,
                aoTocar: () => abrirFormMeta(context),
              ),
            ),
            const SizedBox(height: 18),
            for (final p in metas)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CartaoMeta(
                  progresso: p,
                  aoTocar: () => abrirFormMeta(context, meta: p.meta),
                  aoAtualizar: () => _atualizar(p),
                ),
              ),
            CartaoNovo(
              titulo: '+ Nova meta',
              detalhe: 'Defina um alvo e uma data. O Aurora calcula o ritmo e liga suas tarefas '
                  'e hábitos a ela.',
              aoTocar: () => abrirFormMeta(context),
            ),
          ],
        );
      },
    );
  }

  /// Pergunta só o valor de hoje (o jeito rápido de registrar avanço).
  Future<void> _atualizar(ProgressoMeta p) async {
    final m = p.meta;
    final c = context.cores;
    final controle = TextEditingController(text: valorParaCampo(m.valorAtual, m.unidade));
    final valor = await showDialog<double>(
      context: context,
      builder: (ctx) {
        void confirmar() => Navigator.pop(ctx, lerValorMeta(controle.text, m.unidade));
        return AlertDialog(
          backgroundColor: c.surface,
          title: Text('Onde você está hoje?', style: sora(18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${m.nome} · alvo ${valorMeta(m.valorAlvo, m.unidade)}',
                  style: manrope(13, cor: c.muted)),
              const SizedBox(height: 12),
              CampoTexto(controle: controle, dica: '0', decimal: true, autofoco: true),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            TextButton(onPressed: confirmar, child: const Text('Salvar')),
          ],
        );
      },
    );
    controle.dispose();
    if (valor != null) await _repo!.atualizarValor(m.id, valor);
  }
}

/// Cartão de meta do protótipo: estado, progresso, tempo passado e ritmo.
class CartaoMeta extends StatelessWidget {
  const CartaoMeta({super.key, required this.progresso, required this.aoTocar, this.aoAtualizar});
  final ProgressoMeta progresso;
  final VoidCallback aoTocar;
  final VoidCallback? aoAtualizar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final p = progresso;
    final m = p.meta;
    final corEstado = switch (p.estado) {
      EstadoMeta.nova => c.accent,
      EstadoMeta.emDia || EstadoMeta.concluida => c.teal,
      EstadoMeta.emRisco => c.bad,
      EstadoMeta.parada => c.warn,
    };

    final ligados = [
      if (p.tarefasLigadas > 0)
        '${p.tarefasLigadas} ${p.tarefasLigadas == 1 ? 'tarefa ligada' : 'tarefas ligadas'}'
            '${p.tarefasAbertas > 0 ? ' (${p.tarefasAbertas} em aberto)' : ''}',
      if (p.habitosLigados > 0)
        '${p.habitosLigados} ${p.habitosLigados == 1 ? 'hábito' : 'hábitos'}',
    ];
    final texto = [
      if (p.estado == EstadoMeta.concluida) 'Meta alcançada.',
      if (p.estado == EstadoMeta.parada)
        'Nenhum avanço há mais de $diasParaParada dias.',
      ?p.ritmo,
      if (ligados.isNotEmpty) '${ligados.join(' e ')} a esta meta.',
    ].join(' ');

    Widget linha(String a, String b) => Row(children: [
          Expanded(child: Text(a, style: manrope(12, cor: c.muted))),
          Text(b, style: manrope(12, cor: c.muted)),
        ]);

    return Cartao(
      aoTocar: aoTocar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(m.nome, style: sora(20))),
              const SizedBox(width: 8),
              Etiqueta(p.estado.rotulo, cor: corEstado),
            ],
          ),
          const SizedBox(height: 14),
          linha('Progresso',
              '${valorMeta(m.valorAtual, m.unidade)} de ${valorMeta(m.valorAlvo, m.unidade)}'),
          const SizedBox(height: 6),
          BarraProgresso(fracao: p.progresso, cor: c.teal),
          if (p.tempo != null) ...[
            const SizedBox(height: 10),
            linha('Tempo passado',
                '${diaMesCurto(dataLocal(m.criadoEm))} → ${diaMesCurto(dataLocal(m.dataAlvo!))}'),
            const SizedBox(height: 6),
            BarraProgresso(fracao: p.tempo!, cor: c.accent),
          ],
          if (texto.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(texto, style: manrope(13, altura: 1.5)),
          ],
          if (aoAtualizar != null && p.estado != EstadoMeta.concluida) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: BotaoPilula(texto: 'Atualizar progresso', principal: false, aoTocar: aoAtualizar!),
            ),
          ],
        ],
      ),
    );
  }
}
