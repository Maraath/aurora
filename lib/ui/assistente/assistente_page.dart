import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/tema.dart';
import '../../data/assistente_repo.dart';
import '../../data/banco.dart';
import '../componentes.dart';
import '../em_breve.dart';

class AssistentePage extends StatefulWidget {
  const AssistentePage({super.key});

  @override
  State<AssistentePage> createState() => _AssistentePageState();
}

class _AssistentePageState extends State<AssistentePage> {
  AssistenteRepo? _repo;
  Stream<List<MensagemAssistente>>? _conversa;
  final _texto = TextEditingController();
  final _foco = FocusNode();
  final _chaveEntrada = GlobalKey();
  String _nome = '';
  int _vistas = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = AuroraEscopo.de(context).db;
    if (_repo?.db != db) {
      _repo = AssistenteRepo(db);
      _conversa = _repo!.observarConversa();
      db.preferencia('nome').then((n) {
        if (mounted) setState(() => _nome = n ?? '');
      });
    }
  }

  @override
  void dispose() {
    _texto.dispose();
    _foco.dispose();
    super.dispose();
  }

  Future<void> _enviar([String? texto]) async {
    final t = (texto ?? _texto.text).trim();
    if (t.isEmpty) return;
    _texto.clear();
    await _repo!.enviar(t);
    _foco.requestFocus();
  }

  /// Mantém o campo de mensagem à vista quando a conversa cresce.
  void _rolarAteEntrada(int mensagens) {
    if (mensagens == _vistas) return;
    _vistas = mensagens;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _chaveEntrada.currentContext;
      if (ctx != null && ctx.mounted) {
        Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 200), alignment: 1);
      }
    });
  }

  Future<void> _limpar() async {
    final c = context.cores;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text('Limpar a conversa?', style: sora(18)),
        content: Text('O que o assistente criou (gastos, lembretes, tarefas) continua no app.',
            style: manrope(14, cor: c.text, altura: 1.4)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Limpar')),
        ],
      ),
    );
    if (ok == true) await _repo!.limparConversa();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return StreamBuilder<List<MensagemAssistente>>(
      stream: _conversa,
      builder: (context, snap) {
        final conversa = snap.data ?? const <MensagemAssistente>[];
        final fila = conversa.where((m) => m.naFila).length;
        _rolarAteEntrada(conversa.length);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TituloPagina(
              'Assistente',
              acao: conversa.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Limpar conversa',
                      onPressed: _limpar,
                      icon: Icon(Icons.delete_sweep_outlined, color: c.muted),
                    ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: c.warn),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: c.warn, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(fila == 0 ? 'Comandos rápidos' : 'Comandos rápidos · $fila na fila',
                        style: manrope(12, peso: FontWeight.w700, cor: c.warn)),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Gastos, lembretes, tarefas, hábitos, medidas e resumos funcionam agora, mesmo sem '
              'internet. Perguntas livres ficam na fila até a IA ser conectada.',
              style: manrope(12, cor: c.muted, altura: 1.5),
            ),
            const SizedBox(height: 14),
            _Balao(
              papel: PapelMensagem.aurora,
              texto: 'Oi${_nome.isEmpty ? '' : ', $_nome'}. Posso anotar gastos, criar lembretes e tarefas, '
                  'marcar hábitos, registrar medidas e resumir seu dia ou suas finanças. É só pedir.',
            ),
            for (final m in conversa)
              _Balao(
                papel: m.papel,
                texto: m.texto,
                naFila: m.naFila,
                desfeita: m.desfeita,
                aoDesfazer: m.itemId != null && !m.desfeita ? () => _repo!.desfazer(m) : null,
              ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in sugestoesAssistente)
                  ActionChip(
                    label: Text(s, style: manrope(12, peso: FontWeight.w600)),
                    onPressed: () => _enviar(s),
                    backgroundColor: c.surface,
                    side: BorderSide(color: c.line),
                    shape: const StadiumBorder(),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              key: _chaveEntrada,
              padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: c.line),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _texto,
                      focusNode: _foco,
                      onSubmitted: (_) => _enviar(),
                      textInputAction: TextInputAction.send,
                      textCapitalization: TextCapitalization.sentences,
                      style: manrope(15),
                      cursorColor: c.accent,
                      decoration: InputDecoration(
                        hintText: 'Peça algo ao Aurora…',
                        hintStyle: manrope(15, cor: c.muted),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  BotaoRedondo(
                    icone: Icons.arrow_forward_rounded,
                    dica: 'Enviar',
                    preenchido: true,
                    aoTocar: _enviar,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Balao extends StatelessWidget {
  const _Balao({
    required this.papel,
    required this.texto,
    this.naFila = false,
    this.desfeita = false,
    this.aoDesfazer,
  });

  final PapelMensagem papel;
  final String texto;
  final bool naFila;
  final bool desfeita;
  final VoidCallback? aoDesfazer;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final largura = MediaQuery.sizeOf(context).width;

    if (papel == PapelMensagem.sistema) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.warn),
            ),
            child: Text(texto, textAlign: TextAlign.center, style: manrope(12, cor: c.warn, altura: 1.45)),
          ),
        ),
      );
    }

    final eu = papel == PapelMensagem.eu;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: eu ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: (largura * 0.82).clamp(0, 560)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: eu ? c.accentFill : c.surface,
                border: eu ? null : Border.all(color: c.line),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(eu ? 18 : 4),
                  bottomRight: Radius.circular(eu ? 4 : 18),
                ),
              ),
              child: Text(
                texto,
                style: manrope(14,
                        cor: eu ? Colors.white : (desfeita ? c.muted : c.text), altura: 1.45)
                    .copyWith(decoration: desfeita ? TextDecoration.lineThrough : null),
              ),
            ),
          ),
          if (naFila)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('na fila da IA', style: manrope(11, peso: FontWeight.w700, cor: c.warn)),
            ),
          if (aoDesfazer != null)
            TextButton(
              onPressed: aoDesfazer,
              style: TextButton.styleFrom(minimumSize: const Size(44, 32), padding: const EdgeInsets.symmetric(horizontal: 8)),
              child: Text('Desfazer', style: manrope(12, peso: FontWeight.w700, cor: c.accent)),
            ),
        ],
      ),
    );
  }
}
