import 'package:flutter/material.dart';

import '../core/tema.dart';

/// Barras verticais por dia, no degradê da aurora (Análise de Tarefas e Hábitos).
/// [valores] de 0 a [maximo]; [rotulos] embaixo de cada barra (pode ser vazio).
class BarrasDias extends StatelessWidget {
  const BarrasDias({super.key, required this.valores, required this.rotulos, this.maximo, this.altura = 90});

  final List<num> valores;
  final List<String> rotulos;
  final num? maximo;
  final double altura;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final teto = maximo ?? valores.fold<num>(1, (m, v) => v > m ? v : m);
    return SizedBox(
      height: altura + 22,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < valores.length; i++)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 4 + (altura - 4) * (teto == 0 ? 0 : valores[i] / teto),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      gradient: valores[i] == 0
                          ? null
                          : LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [c.gradIni, c.gradFim],
                            ),
                      color: valores[i] == 0 ? c.line : null,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 16,
                    child: Text(rotulos[i],
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: manrope(10, peso: FontWeight.w700, cor: c.muted)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
