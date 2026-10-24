/// Gravação de uma nota em áudio: microfone com pausa, tempo, volume ao vivo
/// e, no fim, o arquivo com a "onda" para desenhar sem abrir o áudio.
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as rede;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Microfone das notas. Trocável nos testes.
abstract class GravadorDeNota {
  Future<bool> permitido();

  /// Começa e devolve o formato do arquivo ("audio/mp4", "audio/flac"…).
  Future<String> comecar();
  Future<void> pausar();
  Future<void> continuar();

  /// Volume de agora, de 0 a 1.
  Stream<double> get nivel;

  /// Para e devolve o áudio (nulo se não gravou nada).
  Future<Uint8List?> parar();
  Future<void> cancelar();
  Future<void> fechar();
}

/// Gravador de verdade (pacote record). AAC num arquivo .m4a quando o aparelho
/// tem o codificador (~0,35 MB por minuto); senão FLAC ou WAV de 16 kHz, como
/// na voz do assistente.
class GravadorNotaDoAparelho implements GravadorDeNota {
  final _gravador = AudioRecorder();
  String? _caminho;

  @override
  Future<bool> permitido() => _gravador.hasPermission();

  @override
  Future<String> comecar() async {
    final (encoder, formato, ext, taxa) = await _escolher();
    _caminho = kIsWeb
        ? 'aurora_nota'
        : '${(await getTemporaryDirectory()).path}${Platform.pathSeparator}aurora_nota.$ext';
    await _gravador.start(
      RecordConfig(encoder: encoder, sampleRate: taxa, numChannels: 1, bitRate: 48000, noiseSuppress: true),
      path: _caminho!,
    );
    return formato;
  }

  Future<(AudioEncoder, String, String, int)> _escolher() async {
    if (await _gravador.isEncoderSupported(AudioEncoder.aacLc)) {
      return (AudioEncoder.aacLc, 'audio/mp4', 'm4a', 44100);
    }
    if (await _gravador.isEncoderSupported(AudioEncoder.flac)) return (AudioEncoder.flac, 'audio/flac', 'flac', 16000);
    return (AudioEncoder.wav, 'audio/wav', 'wav', 16000);
  }

  @override
  Future<void> pausar() => _gravador.pause();

  @override
  Future<void> continuar() => _gravador.resume();

  @override
  Stream<double> get nivel => _gravador
      .onAmplitudeChanged(const Duration(milliseconds: 100))
      .map((a) => ((a.current + 50) / 50).clamp(0.0, 1.0));

  @override
  Future<Uint8List?> parar() async {
    final caminho = await _gravador.stop() ?? _caminho;
    if (caminho == null) return null;
    if (kIsWeb) {
      final resposta = await rede.get(Uri.parse(caminho));
      return resposta.statusCode == 200 && resposta.bodyBytes.isNotEmpty ? resposta.bodyBytes : null;
    }
    final arquivo = File(caminho);
    if (!await arquivo.exists()) return null;
    final bytes = await arquivo.readAsBytes();
    await arquivo.delete().catchError((_) => arquivo);
    return bytes;
  }

  @override
  Future<void> cancelar() => _gravador.cancel();

  @override
  Future<void> fechar() => _gravador.dispose();
}

enum FaseGravacao { parada, gravando, pausada, pronta }

/// O que sai de uma gravação.
class AudioGravado {
  const AudioGravado({required this.bytes, required this.formato, required this.duracao, required this.onda});
  final Uint8List bytes;
  final String formato;
  final Duration duracao;

  /// 48 dígitos de 0 a 9 (ver AnexosNota.onda).
  final String onda;
}

/// Estado da gravação para a tela: fase, tempo (sem contar as pausas) e as
/// últimas barrinhas de volume.
class ControleGravacao extends ChangeNotifier {
  ControleGravacao({GravadorDeNota Function()? gravador, this.maximo = const Duration(minutes: 10)})
      : _novo = gravador ?? GravadorNotaDoAparelho.new;

  final GravadorDeNota Function() _novo;

  /// Passou disso, para sozinha.
  final Duration maximo;

  FaseGravacao fase = FaseGravacao.parada;
  Duration tempo = Duration.zero;

  /// Volumes recentes (o mais novo no fim), para a onda ao vivo.
  final List<double> recentes = [];

  /// Recado curto ("Não consegui usar o microfone").
  String? aviso;

  AudioGravado? resultado;

  GravadorDeNota? _gravador;
  String _formato = 'audio/wav';
  final List<double> _todos = [];
  final _cronometro = Stopwatch();
  Timer? _relogio;
  StreamSubscription<double>? _volume;
  bool _fechado = false;

  static const barrasAoVivo = 48;

  Future<void> comecar() async {
    if (fase != FaseGravacao.parada) return;
    final g = _gravador ??= _novo();
    try {
      if (!await g.permitido()) return _avisar(_semMicrofone);
      _formato = await g.comecar();
    } catch (e) {
      debugPrint('Nota de áudio: não deu para gravar ($e)');
      return _avisar(_semMicrofone);
    }
    fase = FaseGravacao.gravando;
    _cronometro
      ..reset()
      ..start();
    _volume = g.nivel.listen((v) {
      if (fase != FaseGravacao.gravando) return;
      _todos.add(v);
      recentes.add(v);
      if (recentes.length > barrasAoVivo) recentes.removeAt(0);
      _mudou();
    }, onError: (_) {});
    _relogio = Timer.periodic(const Duration(milliseconds: 250), (_) {
      tempo = _cronometro.elapsed;
      if (tempo >= maximo) {
        parar();
      } else {
        _mudou();
      }
    });
    _mudou();
  }

  Future<void> alternarPausa() async {
    final g = _gravador;
    if (g == null) return;
    if (fase == FaseGravacao.gravando) {
      await g.pausar();
      _cronometro.stop();
      fase = FaseGravacao.pausada;
    } else if (fase == FaseGravacao.pausada) {
      await g.continuar();
      _cronometro.start();
      fase = FaseGravacao.gravando;
    }
    _mudou();
  }

  /// Para e guarda o resultado (a tela salva a nota).
  Future<AudioGravado?> parar() async {
    if (fase != FaseGravacao.gravando && fase != FaseGravacao.pausada) return resultado;
    _cronometro.stop();
    tempo = _cronometro.elapsed;
    _pararRelogios();
    fase = FaseGravacao.pronta;
    _mudou();
    final bytes = await _gravador!.parar();
    if (bytes == null || bytes.isEmpty || tempo < const Duration(milliseconds: 700)) {
      fase = FaseGravacao.parada;
      _avisar('Não gravei nada. Confira o microfone e tente de novo.');
      return null;
    }
    return resultado = AudioGravado(bytes: bytes, formato: _formato, duracao: tempo, onda: resumirOnda(_todos));
  }

  Future<void> cancelar() async {
    _pararRelogios();
    if (fase == FaseGravacao.gravando || fase == FaseGravacao.pausada) await _gravador?.cancelar();
    fase = FaseGravacao.parada;
    _mudou();
  }

  static const _semMicrofone =
      'Não consegui usar o microfone. No Windows, libere em Configurações › Privacidade › Microfone.';

  void _avisar(String texto) {
    aviso = texto;
    _mudou();
  }

  void _pararRelogios() {
    _relogio?.cancel();
    _volume?.cancel();
    _relogio = null;
    _volume = null;
  }

  void _mudou() {
    if (!_fechado) notifyListeners();
  }

  @override
  void dispose() {
    _fechado = true;
    _pararRelogios();
    final g = _gravador;
    if (g != null) {
      (fase == FaseGravacao.gravando || fase == FaseGravacao.pausada ? g.cancelar().whenComplete(g.fechar) : g.fechar())
          .ignore();
    }
    super.dispose();
  }
}

/// Junta os volumes em 48 barras (o pico de cada pedaço) e escreve cada uma
/// como um dígito de 0 a 9.
String resumirOnda(List<double> volumes, {int barras = 48}) {
  if (volumes.isEmpty) return '0' * barras;
  final b = StringBuffer();
  for (var i = 0; i < barras; i++) {
    final ini = (i * volumes.length / barras).floor();
    final fim = (((i + 1) * volumes.length) / barras).ceil().clamp(ini + 1, volumes.length);
    var pico = 0.0;
    for (var j = ini; j < fim && j < volumes.length; j++) {
      if (volumes[j] > pico) pico = volumes[j];
    }
    b.write((pico * 9).round().clamp(0, 9));
  }
  return b.toString();
}

/// A onda gravada (0 a 1 por barra). Sem onda: barras médias, iguais.
List<double> lerOnda(String? onda, {int barras = 48}) {
  if (onda == null || onda.isEmpty) return List.filled(barras, 0.35);
  return [for (final ch in onda.split('')) (int.tryParse(ch) ?? 3) / 9];
}
