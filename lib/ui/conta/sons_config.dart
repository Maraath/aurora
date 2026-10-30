import 'package:flutter/material.dart';

import '../../core/sons.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../componentes.dart';

/// Conta › Efeitos sonoros: feedback auditivo ao concluir tarefas, hábitos,
/// treinos, etapas de projetos e sessões de foco.
class SecaoSons extends StatefulWidget {
  const SecaoSons({super.key, required this.db});
  final BancoAurora db;

  @override
  State<SecaoSons> createState() => _SecaoSonsState();
}

class _SecaoSonsState extends State<SecaoSons> {
  late bool _ativo;
  late double _volume;

  @override
  void initState() {
    super.initState();
    _ativo = Sons.instancia.ativo.value;
    _volume = Sons.instancia.volume.value;
  }

  Future<void> _alternar(bool valor) async {
    setState(() => _ativo = valor);
    await Sons.instancia.alternar(valor);
    if (valor) {
      Sons.instancia.tocarConcluirItem();
    }
  }

  Future<void> _mudarVolume(double valor) async {
    setState(() => _volume = valor);
    await Sons.instancia.definirVolume(valor);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('EFEITOS SONOROS', style: rotulo(c.accent)),
          const SizedBox(height: 6),
          Text(
            'Feedback auditivo suave ao concluir tarefas, hábitos, treinos, marcos de projetos '
            'e ao iniciar ou finalizar sessões de foco.',
            style: manrope(13, cor: c.muted, altura: 1.5),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Sons de conclusão e foco',
                  style: manrope(14, peso: FontWeight.w600, cor: c.texto),
                ),
              ),
              Switch(
                value: _ativo,
                onChanged: _alternar,
                activeThumbColor: Colors.white,
                activeTrackColor: c.teal,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: c.line,
                trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
              ),
            ],
          ),
          if (_ativo) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _volume == 0 ? Icons.volume_mute_rounded : Icons.volume_up_rounded,
                  size: 18,
                  color: c.muted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: c.teal,
                      inactiveTrackColor: c.line,
                      thumbColor: Colors.white,
                      overlayColor: c.teal.withValues(alpha: 0.15),
                      trackHeight: 3.5,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    ),
                    child: Slider(
                      value: _volume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      onChanged: _mudarVolume,
                      onChangeEnd: (_) => Sons.instancia.tocarConcluirItem(),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 38,
                  child: Text(
                    '${(_volume * 100).round()}%',
                    textAlign: TextAlign.end,
                    style: manrope(12, peso: FontWeight.w600, cor: c.muted),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
