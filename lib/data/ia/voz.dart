/// Comando por voz: o app grava, a Edge Function "assistente" transcreve (o
/// Gemini ouve o áudio) e o texto vai para a conversa como se a pessoa tivesse
/// digitado. Assim comandos rápidos, ferramentas, confirmação de exclusão e
/// "Desfazer" funcionam igual ao texto.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../core/nuvem.dart';
import 'protocolo.dart';

/// Microfone. Trocável nos testes.
abstract class Gravador {
  /// Pede (se preciso) e diz se pode usar o microfone.
  Future<bool> permitido();

  /// Começa a gravar e devolve o formato ("audio/flac" ou "audio/wav").
  Future<String> comecar();

  /// Volume de agora, de 0 a 1 (para as barrinhas na tela).
  Stream<double> get nivel;

  /// Para e devolve o áudio gravado (nulo se não gravou nada).
  Future<Uint8List?> parar();

  /// Para e joga o áudio fora.
  Future<void> cancelar();

  Future<void> fechar();
}

/// Gravador de verdade (pacote record): 16 kHz, mono, FLAC quando o aparelho
/// tem o codificador (metade do tamanho), senão WAV. O arquivo fica na pasta
/// temporária só até ser lido.
class GravadorDoAparelho implements Gravador {
  final _gravador = AudioRecorder();
  String? _caminho;

  @override
  Future<bool> permitido() => _gravador.hasPermission();

  @override
  Future<String> comecar() async {
    final flac = await _gravador.isEncoderSupported(AudioEncoder.flac);
    final pasta = await getTemporaryDirectory();
    _caminho = '${pasta.path}${Platform.pathSeparator}aurora_voz.${flac ? 'flac' : 'wav'}';
    await _gravador.start(
      RecordConfig(
        encoder: flac ? AudioEncoder.flac : AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
        noiseSuppress: true,
      ),
      path: _caminho!,
    );
    return flac ? 'audio/flac' : 'audio/wav';
  }

  @override
  Stream<double> get nivel => _gravador
      .onAmplitudeChanged(const Duration(milliseconds: 100))
      // dBFS: -50 ou menos é silêncio; 0 é o máximo.
      .map((a) => ((a.current + 50) / 50).clamp(0.0, 1.0));

  @override
  Future<Uint8List?> parar() async {
    final caminho = await _gravador.stop() ?? _caminho;
    if (caminho == null) return null;
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

/// Áudio → texto. Lança [ErroIa].
typedef TranscreverIa = Future<String> Function(Uint8List audio, String formato);

/// Transcrição pela Edge Function, com a sessão de quem está logado. Nula sem
/// conta conectada (a voz precisa da nuvem).
TranscreverIa? transcricaoDaNuvem() {
  final cliente = nuvem;
  if (cliente?.auth.currentSession == null) return null;
  return (audio, formato) async {
    final http = HttpClient()..connectionTimeout = const Duration(seconds: 20);
    try {
      final pedido = await http.postUrl(Uri.parse('$supabaseUrl/functions/v1/assistente'));
      pedido.headers
        ..set(HttpHeaders.authorizationHeader, 'Bearer ${cliente!.auth.currentSession!.accessToken}')
        ..set('apikey', supabaseAnonKey)
        ..contentType = ContentType.json;
      pedido.add(utf8.encode(jsonEncode({'audio': base64Encode(audio), 'formato': formato})));
      final r = await pedido.close().timeout(const Duration(seconds: 90));
      final corpo = await r.transform(utf8.decoder).join();
      final Object? j;
      try {
        j = jsonDecode(corpo);
      } on FormatException {
        throw ErroIa('A IA não respondeu (erro ${r.statusCode}).');
      }
      if (j is Map && j['texto'] is String) return (j['texto'] as String).trim();
      throw ErroIa(j is Map && j['erro'] is String ? j['erro'] as String : 'A IA não respondeu (erro ${r.statusCode}).');
    } on SocketException {
      throw const ErroIa('Sem conexão com a internet.', semConexao: true);
    } on HandshakeException {
      throw const ErroIa('Sem conexão com a internet.', semConexao: true);
    } on TimeoutException {
      throw const ErroIa('A transcrição demorou demais. Tente de novo.', semConexao: true);
    } finally {
      http.close(force: true);
    }
  };
}

enum FaseVoz { parada, ouvindo, entendendo }

/// O botão de microfone: toca para ouvir, toca de novo para enviar. Entendido
/// o áudio, chama [aoEntender] com o texto (a tela manda para a conversa).
class ComandoDeVoz extends ChangeNotifier {
  ComandoDeVoz({
    required this.aoEntender,
    Gravador Function()? gravador,
    TranscreverIa? Function()? transcrever,
    this.maximo = const Duration(seconds: 60),
  })  : _novoGravador = gravador ?? GravadorDoAparelho.new,
        _transcrever = transcrever ?? transcricaoDaNuvem;

  final Future<void> Function(String texto) aoEntender;
  final Gravador Function() _novoGravador;
  final TranscreverIa? Function() _transcrever;

  /// Fala mais longa que isso para sozinha e envia.
  final Duration maximo;

  /// Menos que isso é toque sem querer: nem manda para transcrever.
  static const minimo = Duration(milliseconds: 600);

  FaseVoz fase = FaseVoz.parada;

  /// Tempo de fala até agora.
  Duration tempo = Duration.zero;

  /// Volume de agora (0 a 1).
  double nivel = 0;

  /// Recado curto para a pessoa ("Não ouvi nada"); some sozinho.
  String? aviso;

  Gravador? _gravador;
  String _formato = 'audio/wav';
  DateTime? _inicio;
  Timer? _relogio;
  Timer? _apagaAviso;
  StreamSubscription<double>? _volume;
  bool _fechado = false;

  /// Toque no microfone: começa a ouvir ou, ouvindo, envia.
  Future<void> alternar() => switch (fase) {
        FaseVoz.parada => ouvir(),
        FaseVoz.ouvindo => concluir(),
        FaseVoz.entendendo => Future.value(),
      };

  Future<void> ouvir() async {
    if (fase != FaseVoz.parada) return;
    _avisar(null);
    if (_transcrever() == null) {
      _avisar('Para falar com a Aurora, entre na conta (Conta › Conta e sincronização).');
      return;
    }
    final g = _gravador ??= _novoGravador();
    try {
      if (!await g.permitido()) {
        _avisar(_semMicrofone);
        return;
      }
      _formato = await g.comecar();
    } catch (e) {
      debugPrint('Voz: não deu para gravar ($e)');
      _avisar(_semMicrofone);
      return;
    }
    fase = FaseVoz.ouvindo;
    tempo = Duration.zero;
    nivel = 0;
    _inicio = DateTime.now();
    _volume = g.nivel.listen((v) {
      nivel = v;
      _mudou();
    }, onError: (_) {});
    _relogio = Timer.periodic(const Duration(milliseconds: 250), (_) {
      tempo = DateTime.now().difference(_inicio!);
      if (tempo >= maximo) {
        concluir();
      } else {
        _mudou();
      }
    });
    _mudou();
  }

  /// Para de ouvir, transcreve e entrega o texto.
  Future<void> concluir() async {
    if (fase != FaseVoz.ouvindo) return;
    final falou = DateTime.now().difference(_inicio!);
    _pararRelogios();
    final g = _gravador!;
    if (falou < minimo) {
      await g.cancelar();
      fase = FaseVoz.parada;
      _avisar('Toque no microfone, fale e toque de novo para enviar.');
      return;
    }
    fase = FaseVoz.entendendo;
    _mudou();
    try {
      final audio = await g.parar();
      final transcrever = _transcrever();
      if (audio == null || audio.isEmpty) {
        _avisar('Não consegui gravar. Confira o microfone.');
      } else if (transcrever == null) {
        _avisar('Para falar com a Aurora, entre na conta (Conta › Conta e sincronização).');
      } else {
        final texto = await transcrever(audio, _formato);
        if (texto.isEmpty) {
          _avisar('Não entendi o que você disse. Tente de novo, mais perto do microfone.');
        } else {
          fase = FaseVoz.parada;
          _mudou();
          await aoEntender(texto);
          return;
        }
      }
    } on ErroIa catch (e) {
      _avisar(e.semConexao ? 'Sem internet: a voz precisa de conexão. Digite o comando.' : e.mensagem);
    } catch (e) {
      debugPrint('Voz: falhou ($e)');
      _avisar('Não deu para entender o áudio agora. Tente de novo ou digite.');
    }
    fase = FaseVoz.parada;
    _mudou();
  }

  /// Desiste da gravação sem enviar.
  Future<void> cancelar() async {
    if (fase != FaseVoz.ouvindo) return;
    _pararRelogios();
    fase = FaseVoz.parada;
    _mudou();
    await _gravador?.cancelar();
  }

  static const _semMicrofone =
      'Não consegui usar o microfone. No Windows, libere em Configurações › Privacidade › Microfone '
      '(“Permitir que aplicativos da área de trabalho acessem o microfone”).';

  void _avisar(String? texto) {
    _apagaAviso?.cancel();
    aviso = texto;
    if (texto != null) {
      _apagaAviso = Timer(const Duration(seconds: 6), () {
        aviso = null;
        _mudou();
      });
    }
    _mudou();
  }

  void _pararRelogios() {
    _relogio?.cancel();
    _volume?.cancel();
    _relogio = null;
    _volume = null;
    nivel = 0;
  }

  void _mudou() {
    if (!_fechado) notifyListeners();
  }

  @override
  void dispose() {
    _fechado = true;
    _pararRelogios();
    _apagaAviso?.cancel();
    final g = _gravador;
    if (g != null) (fase == FaseVoz.ouvindo ? g.cancelar().whenComplete(g.fechar) : g.fechar()).ignore();
    super.dispose();
  }
}
