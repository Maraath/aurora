import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void main() {
  const sampleRate = 44100;
  final dir = Directory('assets/sons');
  if (!dir.existsSync()) dir.createSync(recursive: true);

  // 1. Iniciar Foco: tom suave, meditativo e sutil (528 Hz com harmônicos)
  salvar(
    'assets/sons/iniciar_foco.wav',
    gerarSinoSuave(sampleRate: sampleRate, duracao: 0.85, freqBase: 528.0),
  );

  // 2. Finalizar Foco: acorde harmônico de alívio e conclusão (F-A-C)
  salvar(
    'assets/sons/finalizar_foco.wav',
    gerarAcordeSuave(
      sampleRate: sampleRate,
      duracao: 1.5,
      freqs: [349.23, 440.00, 523.25],
    ),
  );

  // 3. Concluir Tarefa ou Hábito: pop / ding tátil e gratificante
  salvar(
    'assets/sons/concluir_item.wav',
    gerarPopDing(sampleRate: sampleRate, duracao: 0.22),
  );

  // 4. Concluir Treino: acorde triunfante enérgico
  salvar(
    'assets/sons/concluir_treino.wav',
    gerarFanfarraTreino(sampleRate: sampleRate, duracao: 1.2),
  );

  // 5. Concluir Etapa: escala ascendente de progresso (G4 -> B4 -> D5)
  salvar(
    'assets/sons/concluir_etapa.wav',
    gerarEscalaAscendente(
      sampleRate: sampleRate,
      duracao: 0.75,
      freqs: [392.00, 493.88, 587.33],
      intervalo: 0.08,
    ),
  );

  // 6. Concluir Objetivo: celebração rica e marcante
  salvar(
    'assets/sons/concluir_objetivo.wav',
    gerarCelebracaoObjetivo(sampleRate: sampleRate, duracao: 2.2),
  );

  stdout.writeln('Sons gerados com sucesso em assets/sons/');
}

void salvar(String caminho, List<double> amostras) {
  final bytes = gerarWav(sampleRate: 44100, amostras: amostras);
  File(caminho).writeAsBytesSync(bytes);
}

Uint8List gerarWav({required int sampleRate, required List<double> amostras}) {
  final numSamples = amostras.length;
  const numChannels = 1;
  const bitsPerSample = 16;
  final byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);
  const blockAlign = numChannels * (bitsPerSample ~/ 8);
  final subchunk2Size = numSamples * numChannels * (bitsPerSample ~/ 8);
  final chunkSize = 36 + subchunk2Size;

  final b = BytesBuilder();
  b.add('RIFF'.codeUnits);
  b.add(_int32(chunkSize));
  b.add('WAVE'.codeUnits);

  b.add('fmt '.codeUnits);
  b.add(_int32(16));
  b.add(_int16(1));
  b.add(_int16(numChannels));
  b.add(_int32(sampleRate));
  b.add(_int32(byteRate));
  b.add(_int16(blockAlign));
  b.add(_int16(bitsPerSample));

  b.add('data'.codeUnits);
  b.add(_int32(subchunk2Size));

  for (final a in amostras) {
    final clamped = a.clamp(-1.0, 1.0);
    final val = (clamped * 32767.0).round();
    b.add(_int16(val));
  }

  return b.toBytes();
}

List<int> _int16(int value) => [value & 0xff, (value >> 8) & 0xff];
List<int> _int32(int value) => [
      value & 0xff,
      (value >> 8) & 0xff,
      (value >> 16) & 0xff,
      (value >> 24) & 0xff,
    ];

/// 1. Tom calmante tipo sino tibetano / chime sutil
List<double> gerarSinoSuave({
  required int sampleRate,
  required double duracao,
  required double freqBase,
}) {
  final total = (sampleRate * duracao).round();
  final amostras = List<double>.filled(total, 0.0);
  for (var i = 0; i < total; i++) {
    final t = i / sampleRate;
    // Envelope: ataque de 30ms, decaimento exponencial suave
    final attack = (t / 0.03).clamp(0.0, 1.0);
    final env = attack * exp(-t * 4.2);

    final s1 = sin(2 * pi * freqBase * t);
    final s2 = 0.25 * sin(2 * pi * (freqBase * 2) * t);
    final s3 = 0.08 * sin(2 * pi * (freqBase * 3) * t);

    amostras[i] = (s1 + s2 + s3) * env * 0.7;
  }
  return amostras;
}

/// 2. Acorde harmônico e sereno de alívio
List<double> gerarAcordeSuave({
  required int sampleRate,
  required double duracao,
  required List<double> freqs,
}) {
  final total = (sampleRate * duracao).round();
  final amostras = List<double>.filled(total, 0.0);
  for (var i = 0; i < total; i++) {
    final t = i / sampleRate;
    final attack = (t / 0.04).clamp(0.0, 1.0);
    final env = attack * exp(-t * 2.6);

    var soma = 0.0;
    for (final f in freqs) {
      soma += sin(2 * pi * f * t) + 0.15 * sin(2 * pi * f * 2 * t);
    }
    amostras[i] = (soma / freqs.length) * env * 0.65;
  }
  return amostras;
}

/// 3. Pop / ding tátil e gratificante
List<double> gerarPopDing({required int sampleRate, required double duracao}) {
  final total = (sampleRate * duracao).round();
  final amostras = List<double>.filled(total, 0.0);
  for (var i = 0; i < total; i++) {
    final t = i / sampleRate;
    // Pitch sobe nos primeiros 18ms de 600Hz para 1100Hz
    final pitchProgresso = (t / 0.018).clamp(0.0, 1.0);
    final freq = 600.0 + (500.0 * sin(pitchProgresso * pi / 2));
    final env = exp(-t * 18.0);

    final s1 = sin(2 * pi * freq * t);
    final s2 = 0.2 * sin(2 * pi * freq * 2 * t);
    amostras[i] = (s1 + s2) * env * 0.75;
  }
  return amostras;
}

/// 4. Acorde triunfante enérgico para treino
List<double> gerarFanfarraTreino({required int sampleRate, required double duracao}) {
  final total = (sampleRate * duracao).round();
  final amostras = List<double>.filled(total, 0.0);
  final notas = [261.63, 329.63, 392.00, 523.25]; // C4, E4, G4, C5
  const step = 0.055; // 55ms entre cada nota do arpeggio

  for (var i = 0; i < total; i++) {
    final t = i / sampleRate;
    var soma = 0.0;
    var ativas = 0;

    for (var n = 0; n < notas.length; n++) {
      final inicio = n * step;
      if (t >= inicio) {
        final dt = t - inicio;
        final attack = (dt / 0.015).clamp(0.0, 1.0);
        final env = attack * exp(-dt * 3.0);
        soma += (sin(2 * pi * notas[n] * dt) + 0.2 * sin(4 * pi * notas[n] * dt)) * env;
        ativas++;
      }
    }

    if (ativas > 0) {
      amostras[i] = (soma / max(1, ativas * 0.7)) * 0.8;
    }
  }
  return amostras;
}

/// 5. Escala ascendente de progresso
List<double> gerarEscalaAscendente({
  required int sampleRate,
  required double duracao,
  required List<double> freqs,
  required double intervalo,
}) {
  final total = (sampleRate * duracao).round();
  final amostras = List<double>.filled(total, 0.0);

  for (var i = 0; i < total; i++) {
    final t = i / sampleRate;
    var soma = 0.0;
    var ativas = 0;

    for (var n = 0; n < freqs.length; n++) {
      final inicio = n * intervalo;
      if (t >= inicio) {
        final dt = t - inicio;
        final attack = (dt / 0.015).clamp(0.0, 1.0);
        final env = attack * exp(-dt * 5.0);
        soma += (sin(2 * pi * freqs[n] * dt) + 0.18 * sin(4 * pi * freqs[n] * dt)) * env;
        ativas++;
      }
    }

    if (ativas > 0) {
      amostras[i] = (soma / max(1, ativas * 0.75)) * 0.75;
    }
  }
  return amostras;
}

/// 6. Celebração de Objetivo Macro (o maior impacto)
List<double> gerarCelebracaoObjetivo({required int sampleRate, required double duracao}) {
  final total = (sampleRate * duracao).round();
  final amostras = List<double>.filled(total, 0.0);
  final notas = [261.63, 392.00, 523.25, 659.25, 783.99]; // C4, G4, C5, E5, G5
  const step = 0.07;

  for (var i = 0; i < total; i++) {
    final t = i / sampleRate;
    var soma = 0.0;
    var ativas = 0;

    for (var n = 0; n < notas.length; n++) {
      final inicio = n * step;
      if (t >= inicio) {
        final dt = t - inicio;
        final attack = (dt / 0.02).clamp(0.0, 1.0);
        final env = attack * exp(-dt * 1.8);
        final s1 = sin(2 * pi * notas[n] * dt);
        final s2 = 0.25 * sin(4 * pi * notas[n] * dt);
        final s3 = 0.1 * sin(6 * pi * notas[n] * dt);
        soma += (s1 + s2 + s3) * env;
        ativas++;
      }
    }

    if (ativas > 0) {
      amostras[i] = (soma / max(1, ativas * 0.65)) * 0.85;
    }
  }
  return amostras;
}
