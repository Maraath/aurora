import 'package:flutter/material.dart';

import '../core/atualizacao.dart';
import '../core/tema.dart';

/// Confere se há versão nova e, se houver, pergunta se pode atualizar.
Future<void> oferecerAtualizacao(BuildContext context) async {
  final a = await Atualizador.instancia.verificar();
  if (a == null || !context.mounted) return;
  await mostrarAtualizacao(context, a);
}

Future<void> mostrarAtualizacao(BuildContext context, Atualizacao a) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _DialogoAtualizacao(a),
  );
}

class _DialogoAtualizacao extends StatefulWidget {
  const _DialogoAtualizacao(this.a);
  final Atualizacao a;

  @override
  State<_DialogoAtualizacao> createState() => _DialogoAtualizacaoState();
}

class _DialogoAtualizacaoState extends State<_DialogoAtualizacao> {
  String? _erro;

  Future<void> _atualizar() async {
    setState(() => _erro = null);
    try {
      await Atualizador.instancia.aplicar(widget.a);
    } catch (e) {
      if (mounted) setState(() => _erro = 'Não deu para atualizar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final atual = Atualizador.instancia.versaoAtual;
    return ValueListenableBuilder<double?>(
      valueListenable: Atualizador.instancia.progresso,
      builder: (context, p, _) => AlertDialog(
        backgroundColor: c.surface,
        title: Text('Atualização disponível', style: sora(18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versão ${widget.a.versao}${atual.isEmpty ? '' : ' (você tem a $atual)'}.',
              style: manrope(14, peso: FontWeight.w600, cor: c.text),
            ),
            if (widget.a.notas.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(widget.a.notas, style: manrope(13, cor: c.muted, altura: 1.5)),
            ],
            const SizedBox(height: 12),
            Text(
              p == null
                  ? 'O Aurora fecha, instala a nova versão e abre de novo sozinho. Seus dados continuam aqui.'
                  : 'Baixando… ${(p * 100).round()}%',
              style: manrope(13, cor: c.muted, altura: 1.5),
            ),
            if (p != null) ...[
              const SizedBox(height: 10),
              LinearProgressIndicator(value: p),
            ],
            if (_erro != null) ...[
              const SizedBox(height: 10),
              Text(_erro!, style: manrope(13, peso: FontWeight.w600, cor: c.bad, altura: 1.4)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: p == null ? () => Navigator.pop(context) : null,
            child: const Text('Depois'),
          ),
          TextButton(
            onPressed: p == null ? _atualizar : null,
            child: Text('Atualizar agora', style: TextStyle(color: c.accent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
