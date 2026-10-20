import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Medidor de quadros para comparar desempenho entre versões. Só liga com
/// `--dart-define=AURORA_MEDIR=true` (de preferência em `flutter run --profile`):
/// a cada 5 s escreve no console quantos quadros houve, a média e o pior tempo
/// de montagem (UI) e de desenho (placa de vídeo), e quantos passaram de 16 ms.
const medirQuadros = bool.fromEnvironment('AURORA_MEDIR');

void iniciarMedidorDeQuadros() {
  if (!medirQuadros) return;
  final ui = <int>[];
  final gpu = <int>[];
  var inicio = DateTime.now();
  SchedulerBinding.instance.addTimingsCallback((List<FrameTiming> quadros) {
    for (final q in quadros) {
      ui.add(q.buildDuration.inMicroseconds);
      gpu.add(q.rasterDuration.inMicroseconds);
    }
    final agora = DateTime.now();
    if (agora.difference(inicio).inSeconds < 5) return;
    String resumo(List<int> v) {
      if (v.isEmpty) return '-';
      final ord = [...v]..sort();
      final media = v.reduce((a, b) => a + b) / v.length / 1000;
      final p90 = ord[(ord.length * 0.9).floor().clamp(0, ord.length - 1)] / 1000;
      return 'média ${media.toStringAsFixed(1)} ms, p90 ${p90.toStringAsFixed(1)}, '
          'pior ${(ord.last / 1000).toStringAsFixed(1)}';
    }

    final lentos = [for (var i = 0; i < ui.length; i++) if (ui[i] > 16000 || gpu[i] > 16000) i].length;
    debugPrint('[quadros] ${ui.length} em ${agora.difference(inicio).inSeconds}s | '
        'UI ${resumo(ui)} | GPU ${resumo(gpu)} | acima de 16 ms: $lentos');
    ui.clear();
    gpu.clear();
    inicio = agora;
  });
}
