import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../icone_ia.dart';
import '../../app.dart';
import '../../core/comandos.dart';
import '../../core/formato.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/assistente_repo.dart';
import '../../data/banco.dart';
import '../../data/tarefas_repo.dart';

/// O que a captura rápida vai fazer com o comando, numa linha (ícone e texto).
(IconData, String) descreverComando(Comando c, DateTime hoje) => switch (c) {
      CmdDinheiro() => (
          c.entrada ? Icons.south_west_rounded : Icons.shopping_cart_outlined,
          [
            c.entrada ? 'Receita' : 'Despesa',
            reais(c.centavos),
            c.descricao,
            if (normalizar(c.categoria) != normalizar(c.descricao)) c.categoria,
            diaRelativo(c.dia, hoje),
          ].join(' · '),
        ),
      CmdLembrete() => (
          Icons.notifications_none_rounded,
          'Lembrete · ${c.texto} · '
              '${c.regra != null ? '${c.regra!.descricao.toLowerCase()}, ' : ''}'
              '${diaRelativo(c.dia, hoje)} às ${horaDe(c.hora, c.minuto)}',
        ),
      CmdTarefa() => (
          Icons.task_alt_rounded,
          'Tarefa · ${c.titulo} · '
              '${c.dia == null ? 'sem data' : diaRelativo(c.dia!, hoje)}'
              '${c.hora == null ? '' : ' às ${horaDe(c.hora!, c.minuto)}'}',
        ),
      CmdHabito() => (Icons.repeat_rounded, 'Marcar hábito · ${c.nome} · hoje'),
      CmdMedida() => (Icons.straighten_rounded, 'Medida · ${c.tipo} ${numero(c.valor)} ${c.unidade} · hoje'),
      CmdComida() => (
          Icons.restaurant_rounded,
          'Alimentação · ${c.nome}'
              '${c.gramas != null ? ' · ${numero(c.gramas!)} g' : c.porcoes != null ? ' · ${numero(c.porcoes!)} porção(ões)' : ''}',
        ),
      CmdResumoDia() => (Icons.wb_sunny_outlined, 'Resumo do dia (a resposta aparece no chat)'),
      CmdResumoFinancas() => (Icons.account_balance_wallet_outlined, 'Resumo das finanças (a resposta aparece no chat)'),
    };

/// Captura rápida: uma linha de texto que vira gasto, lembrete, tarefa,
/// hábito, medida ou refeição pelos mesmos comandos do assistente (sem
/// internet). Mostra o que entendeu antes de salvar; o que não for comando
/// pode ir para a Aurora ou virar tarefa.
class PainelCaptura extends StatefulWidget {
  const PainelCaptura({super.key, required this.aoFechar, required this.aoPerguntar});

  final VoidCallback aoFechar;

  /// Manda o texto para a IA e abre o mini chat.
  final ValueChanged<String> aoPerguntar;

  @override
  State<PainelCaptura> createState() => _PainelCapturaState();
}

class _PainelCapturaState extends State<PainelCaptura> {
  final _texto = TextEditingController();
  Comando? _comando;
  bool _salvando = false;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  void _mudou(String t) {
    final agora = agoraLocal();
    setState(() => _comando = interpretar(t, hoje: dataLocal(agora), agora: agora));
  }

  void _avisar(String texto) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
      content: Text(texto),
      behavior: SnackBarBehavior.floating,
      width: 420,
      duration: const Duration(seconds: 3),
    ));
  }

  Future<void> _salvar() async {
    final t = _texto.text.trim();
    if (t.isEmpty || _salvando) return;
    final c = _comando;
    if (c == null) return _comoTarefa();
    setState(() => _salvando = true);
    final db = AuroraEscopo.de(context).db;
    final repo = AssistenteRepo(db);
    // Pelo assistente: fica registrado na conversa e pode ser desfeito lá.
    await repo.enviar(t);
    if (!mounted) return;
    if (c is CmdResumoDia || c is CmdResumoFinancas) {
      widget.aoPerguntar('');
      return;
    }
    final conversa = await repo.carregarConversa();
    if (!mounted) return;
    final resposta = conversa.lastWhere((m) => m.papel == PapelMensagem.aurora, orElse: () => conversa.last);
    _avisar(resposta.texto);
    widget.aoFechar();
  }

  Future<void> _comoTarefa() async {
    final t = _texto.text.trim();
    if (t.isEmpty || _salvando) return;
    setState(() => _salvando = true);
    final db = AuroraEscopo.de(context).db;
    await TarefasRepo(db).salvar(TarefasCompanion.insert(titulo: t, prazo: const Value(null)), avisar: false);
    if (!mounted) return;
    _avisar('Criei a tarefa “$t”, sem data.');
    widget.aoFechar();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final hoje = hojeLocal();
    final temTexto = _texto.text.trim().isNotEmpty;
    final cmd = _comando;
    final (icone, descricao) = cmd == null ? (null, null) : descreverComando(cmd, hoje);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          _Icone(icone: Icons.bolt_rounded, cor: c.accent),
          const SizedBox(width: 10),
          Expanded(child: Text('Captura rápida', style: sora(15))),
          IconButton(
            tooltip: 'Fechar',
            onPressed: widget.aoFechar,
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.close_rounded, size: 19, color: c.muted),
          ),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 4, 4, 4),
          decoration: BoxDecoration(
            color: c.surface2.withValues(alpha: .7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.line),
          ),
          child: Row(children: [
            Expanded(
              child: CallbackShortcuts(
                bindings: {
                  const SingleActivator(LogicalKeyboardKey.enter): _salvar,
                  const SingleActivator(LogicalKeyboardKey.numpadEnter): _salvar,
                  const SingleActivator(LogicalKeyboardKey.escape): widget.aoFechar,
                },
                child: TextField(
                  controller: _texto,
                  autofocus: true,
                  onChanged: _mudou,
                  textCapitalization: TextCapitalization.sentences,
                  style: manrope(14, cor: c.text),
                  cursorColor: c.accent,
                  decoration: InputDecoration(
                    hintText: 'gastei 35 no mercado, lembrar de pagar a luz sexta…',
                    hintStyle: manrope(14, cor: c.muted),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Tooltip(
              message: 'Salvar',
              child: Material(
                type: MaterialType.transparency,
                child: Ink(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: temTexto ? c.gradiente : null,
                    color: temTexto ? null : c.surface2,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: temTexto ? _salvar : null,
                    child: Icon(Icons.arrow_upward_rounded, size: 19, color: temTexto ? c.noAccent : c.muted),
                  ),
                ),
              ),
            ),
          ]),
        ),
        if (temTexto) ...[
          const SizedBox(height: 12),
          if (cmd != null)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: BoxDecoration(
                color: c.surface2.withValues(alpha: .7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.line),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('A AURORA ENTENDEU', style: manrope(10, peso: FontWeight.w800, cor: c.muted, espaco: 1)),
                const SizedBox(height: 6),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(icone, size: 18, color: c.teal),
                  const SizedBox(width: 10),
                  Expanded(child: Text(descricao!, style: manrope(13, peso: FontWeight.w600, cor: c.text, altura: 1.4))),
                ]),
              ]),
            )
          else
            Text('Não é um comando rápido. Mande para a Aurora ou guarde como tarefa.',
                style: manrope(12, cor: c.muted, altura: 1.4)),
          const SizedBox(height: 12),
          Wrap(alignment: WrapAlignment.end, spacing: 8, runSpacing: 8, children: [
            if (cmd == null)
              _Pilula(
                texto: 'Perguntar à Aurora',
                icone: iconeIa,
                aoTocar: () => widget.aoPerguntar(_texto.text.trim()),
              ),
            _Pilula(
              texto: cmd == null ? 'Salvar como tarefa' : 'Enter para salvar',
              icone: cmd == null ? Icons.task_alt_rounded : Icons.keyboard_return_rounded,
              destaque: true,
              aoTocar: _salvar,
            ),
          ]),
        ],
      ]),
    );
  }
}

class _Icone extends StatelessWidget {
  const _Icone({required this.icone, required this.cor});
  final IconData icone;
  final Color cor;

  @override
  Widget build(BuildContext context) => Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(color: cor.withValues(alpha: .14), borderRadius: BorderRadius.circular(10)),
        child: Icon(icone, size: 19, color: cor),
      );
}

class _Pilula extends StatelessWidget {
  const _Pilula({required this.texto, required this.icone, required this.aoTocar, this.destaque = false});
  final String texto;
  final IconData icone;
  final VoidCallback aoTocar;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final cor = destaque ? c.accent : c.muted;
    return Material(
      color: destaque ? c.accentSoft : Colors.transparent,
      shape: StadiumBorder(side: BorderSide(color: destaque ? c.accent.withValues(alpha: .45) : c.line)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            IconeApp(icone, size: 15, color: cor),
            const SizedBox(width: 6),
            Text(texto, style: manrope(12, peso: FontWeight.w700, cor: cor)),
          ]),
        ),
      ),
    );
  }
}
