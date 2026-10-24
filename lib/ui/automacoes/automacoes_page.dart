import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/notificacoes.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/automacoes_repo.dart';
import '../../data/banco.dart';
import '../../data/servico_automacoes.dart';
import '../componentes.dart';
import '../em_breve.dart';
import '../formulario.dart';
import 'form_automacao.dart';

class AutomacoesPage extends StatefulWidget {
  const AutomacoesPage({super.key, this.voltar, this.abrirAssistente});
  final VoidCallback? voltar;
  final VoidCallback? abrirAssistente;

  @override
  State<AutomacoesPage> createState() => _AutomacoesPageState();
}

class _AutomacoesPageState extends State<AutomacoesPage> {
  AutomacoesRepo? _repo;
  Stream<List<Automacao>>? _lista;
  bool? _ligadas;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = AuroraEscopo.de(context).db;
    if (_repo?.db != db) {
      _repo = AutomacoesRepo(db);
      _repo!.garantirModelos();
      _lista = _repo!.observarAutomacoes();
      _repo!.ligadas().then((v) {
        if (mounted) setState(() => _ligadas = v);
      });
    }
  }

  Future<void> _definirLigadas(bool v) async {
    setState(() => _ligadas = v);
    await _repo!.definirLigadas(v);
    await Notificador.instancia.reagendar(_repo!.db);
  }

  Future<void> _rodarAgora(Automacao a) async {
    await executarAutomacao(_repo!.db, a, agora: agoraLocal(), marcar: false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('“${a.nome}” está no assistente.'),
      action: widget.abrirAssistente == null
          ? null
          : SnackBarAction(label: 'Abrir', onPressed: widget.abrirAssistente!),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return StreamBuilder<List<Automacao>>(
      stream: _lista,
      builder: (context, snap) {
        final lista = snap.data;
        if (lista == null || _ligadas == null) return const SizedBox(height: 200);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TituloPagina(
              'Automações',
              voltar: widget.voltar,
              acao: BotaoRedondo(
                icone: Icons.add_rounded,
                dica: 'Nova automação',
                preenchido: true,
                aoTocar: () => abrirFormAutomacao(context),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Rotinas que a Aurora faz sozinha no horário: um aviso no aparelho e o resultado na '
              'conversa do assistente. Os modelos prontos funcionam sem internet.',
              style: manrope(13, cor: c.muted, altura: 1.5),
            ),
            const SizedBox(height: 14),
            LinhaInterruptor(
              titulo: 'Automações neste aparelho',
              detalhe: _ligadas! ? 'ligadas: avisos e resumos no horário' : 'desligadas: nada roda aqui',
              valor: _ligadas!,
              aoMudar: _definirLigadas,
            ),
            const SizedBox(height: 14),
            for (final a in lista)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Opacity(
                  opacity: _ligadas! ? 1 : 0.55,
                  child: _CartaoAutomacao(
                    automacao: a,
                    aoAlternar: (v) => _repo!.alternar(a, v),
                    aoEditar: () => abrirFormAutomacao(context, automacao: a),
                    aoRodar: () => _rodarAgora(a),
                  ),
                ),
              ),
            CartaoNovo(
              titulo: '+ Nova automação',
              detalhe: 'Um pedido seu para a IA em dias e horário fixos. Ex.: toda segunda às 8h, '
                  '"o que preciso resolver esta semana?".',
              aoTocar: () => abrirFormAutomacao(context),
            ),
          ],
        );
      },
    );
  }
}

class _CartaoAutomacao extends StatelessWidget {
  const _CartaoAutomacao({
    required this.automacao,
    required this.aoAlternar,
    required this.aoEditar,
    required this.aoRodar,
  });

  final Automacao automacao;
  final ValueChanged<bool> aoAlternar;
  final VoidCallback aoEditar;
  final VoidCallback aoRodar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final a = automacao;
    final modelo = ModeloAutomacao.de(a.modelo);
    final ultima = a.ultimaExecucao;
    return Cartao(
      raio: 16,
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      aoTocar: aoEditar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(a.nome, style: manrope(15, peso: FontWeight.w700)),
                Text(descreverAgenda(a), style: manrope(12, peso: FontWeight.w600, cor: a.ativa ? c.accent : c.muted)),
              ]),
            ),
            Switch(
              value: a.ativa,
              onChanged: aoAlternar,
              activeThumbColor: Colors.white,
              activeTrackColor: c.teal,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: c.line,
              trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
            ),
          ]),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              modelo == ModeloAutomacao.personalizada ? '“${a.pedido ?? ''}”' : modelo.descricao,
              style: manrope(13, cor: c.muted, altura: 1.4),
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: Text(
                ultima == null ? 'Ainda não rodou.' : 'Última: ${_ultima(ultima)}',
                style: manrope(12, cor: c.muted),
              ),
            ),
            TextButton(
              onPressed: aoRodar,
              child: Text('Rodar agora', style: manrope(13, peso: FontWeight.w700, cor: c.accent)),
            ),
          ]),
        ],
      ),
    );
  }

  /// "2026-10-17 07:00" → "hoje às 07:00" / "sex, 16 out às 07:00".
  String _ultima(String chave) {
    final p = chave.split(' ');
    final dia = DateTime.tryParse(p.first);
    if (dia == null) return chave;
    final hoje = hojeLocal();
    final rel = dia == hoje ? 'hoje' : (dia == hoje.subtract(const Duration(days: 1)) ? 'ontem' : null);
    return '${rel ?? '${dia.day}/${dia.month}'} às ${p.length > 1 ? p[1] : ''}';
  }
}
