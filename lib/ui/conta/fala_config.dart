import 'package:flutter/material.dart';

import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/ia/fala.dart';
import '../componentes.dart';

/// Conta › Resposta em voz: quando a Aurora lê a resposta em voz alta (vale só
/// para este aparelho) e um botão para ouvir a voz.
class SecaoRespostaFalada extends StatefulWidget {
  const SecaoRespostaFalada({super.key, required this.db, this.falador});
  final BancoAurora db;

  /// Nos testes: alto-falante falso.
  final Falador Function()? falador;

  @override
  State<SecaoRespostaFalada> createState() => _SecaoRespostaFaladaState();
}

class _SecaoRespostaFaladaState extends State<SecaoRespostaFalada> {
  QuandoFalar? _quando;
  late final _fala = FalaDaAurora(falador: widget.falador);

  @override
  void initState() {
    super.initState();
    QuandoFalar.ler(widget.db).then((q) {
      if (mounted) setState(() => _quando = q);
    });
  }

  @override
  void dispose() {
    _fala.dispose();
    super.dispose();
  }

  Future<void> _escolher(QuandoFalar q) async {
    setState(() => _quando = q);
    if (q == QuandoFalar.nunca) _fala.parar();
    await q.salvar(widget.db);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final quando = _quando;
    if (quando == null) return const SizedBox.shrink();
    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('RESPOSTA EM VOZ', style: rotulo(c.accent)),
          const SizedBox(height: 6),
          Text(
            switch (quando) {
              QuandoFalar.pedidoPorVoz => 'Quando você fala com a Aurora pelo microfone, ela lê a resposta em voz alta. '
                  'Pedidos digitados ficam só no texto.',
              QuandoFalar.sempre => 'A Aurora lê em voz alta toda resposta, falada ou digitada.',
              QuandoFalar.nunca => 'A Aurora responde só por escrito, mesmo quando você fala com ela.',
            },
            style: manrope(13, cor: c.muted, altura: 1.5),
          ),
          const SizedBox(height: 14),
          Segmentos<QuandoFalar>(
            opcoes: QuandoFalar.values,
            selecionado: quando,
            rotulo: (q) => q.rotulo,
            aoEscolher: _escolher,
          ),
          const SizedBox(height: 12),
          Text('Usa a voz do aparelho (no Windows, a Microsoft Maria) e funciona sem internet. Vale só para este aparelho.',
              style: manrope(12, cor: c.muted, altura: 1.5)),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: ListenableBuilder(
              listenable: _fala,
              builder: (context, _) => BotaoPilula(
                texto: _fala.falando ? 'Parar' : 'Ouvir a voz',
                principal: false,
                aoTocar: _fala.falando
                    ? _fala.parar
                    : () => _fala.falar('Oi! Eu sou a Aurora. Quando você falar comigo, eu respondo assim.'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
