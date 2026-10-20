import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../core/efeitos.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../componentes.dart';

/// Conta › Efeitos visuais: desfoque dos vidros e céu cintilando, ou a versão
/// leve para aparelhos mais antigos. Vale só para este aparelho.
class SecaoEfeitos extends StatefulWidget {
  const SecaoEfeitos({super.key, required this.db});
  final BancoAurora db;

  @override
  State<SecaoEfeitos> createState() => _SecaoEfeitosState();
}

class _SecaoEfeitosState extends State<SecaoEfeitos> {
  ModoEfeitos _modo = Efeitos.modo;

  Future<void> _escolher(ModoEfeitos m) async {
    setState(() => _modo = m);
    await Efeitos.escolher(widget.db, m);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final leves = EscopoEfeitos.leves(context);
    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('EFEITOS VISUAIS', style: rotulo(c.accent)),
          const SizedBox(height: 6),
          Text(
            switch (_modo) {
              ModoEfeitos.automatico => leves
                  ? 'Este aparelho ficou mais lento com os efeitos, então o Aurora está no modo leve: '
                      'sem desfoque nos vidros e com o céu parado.'
                  : 'O Aurora mede o aparelho e, se ficar lento, tira o desfoque sozinho. '
                      '${kIsWeb ? 'No navegador o céu fica parado (cintilar pesa); em "Completos" ele cintila.' : ''}',
              ModoEfeitos.completos => 'Vidro desfocado e céu cintilando, mesmo que o aparelho fique mais lento.',
              ModoEfeitos.leves => 'Sem desfoque nos vidros e com o céu parado: mais leve em aparelhos antigos.',
            },
            style: manrope(13, cor: c.muted, altura: 1.5),
          ),
          const SizedBox(height: 14),
          Segmentos<ModoEfeitos>(
            opcoes: ModoEfeitos.values,
            selecionado: _modo,
            rotulo: (m) => m.rotulo,
            aoEscolher: _escolher,
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<int?>(
            valueListenable: Efeitos.fpsMedido,
            builder: (context, fps, _) => Text(
              fps == null
                  ? 'Vale só para este aparelho.'
                  : 'Vale só para este aparelho. Medição com os efeitos ligados: $fps quadros por segundo '
                      '(o ideal é 60).',
              style: manrope(12, cor: c.muted, altura: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
