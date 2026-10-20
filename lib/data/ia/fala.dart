/// Resposta falada: a Aurora lê a resposta em voz alta com a voz do aparelho
/// ("Microsoft Maria" no Windows, a voz do Google no Android, a do sistema no
/// iOS). Grátis, sem cota e funciona sem internet.
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../banco.dart';

/// Alto-falante. Trocável nos testes.
abstract class Falador {
  /// Fala o texto; termina quando acaba de falar ou é parado.
  Future<void> falar(String texto);

  Future<void> parar();

  Future<void> fechar();
}

/// A voz de cada sistema: no Windows a do runner, nos outros a do flutter_tts.
Falador faladorDoAparelho() => Platform.isWindows ? FaladorWindows() : FaladorDoAparelho();

/// Windows: SAPI no runner (`windows/runner/fala.cpp`, canal "aurora/fala").
/// O flutter_tts fala no Windows, mas avisa o fim fora da thread da
/// plataforma e o aviso se perde (o "Parar" ficaria preso na tela).
/// A voz é uma só para o app todo: falar numa tela cala a fala de outra (a
/// outra fica sabendo, porque o fim é compartilhado).
class FaladorWindows implements Falador {
  FaladorWindows() {
    _canal.setMethodCallHandler((chamada) async {
      if (chamada.method == 'fim') _acabou();
    });
  }

  static const _canal = MethodChannel('aurora/fala');
  static Completer<void>? _fim;

  static void _acabou() {
    final fim = _fim;
    _fim = null;
    if (fim != null && !fim.isCompleted) fim.complete();
  }

  @override
  Future<void> falar(String texto) async {
    _acabou();
    final fim = _fim = _minha = Completer<void>();
    if (await _canal.invokeMethod<bool>('falar', texto) != true) {
      _acabou();
      throw StateError('sem voz no Windows');
    }
    return fim.future;
  }

  /// Só cala se a fala de agora for desta tela.
  Future<void> _pararSe(Completer<void>? minha) async {
    if (_fim == null || _fim != minha) return;
    _acabou();
    await _canal.invokeMethod<void>('parar');
  }

  Completer<void>? _minha;

  @override
  Future<void> parar() => _pararSe(_minha);

  @override
  Future<void> fechar() => parar();
}

/// Android e iOS: flutter_tts em português do Brasil.
class FaladorDoAparelho implements Falador {
  final _tts = FlutterTts();
  Future<void>? _preparo;
  Completer<void>? _fim;

  /// Vozes preferidas, nesta ordem, entre as de pt-BR (Windows, iOS).
  static const _preferidas = ['maria', 'francisca', 'luciana'];

  /// O Android não fala textos maiores que isso de uma vez.
  static const _maximo = 3900;

  Future<void> _preparar() async {
    // Sem esperar o fim pelo plugin (no Windows, parar sem nada falando
    // derruba o app): o fim chega pelos avisos de concluído e cancelado.
    _tts
      ..setCompletionHandler(_acabou)
      ..setCancelHandler(_acabou)
      ..setErrorHandler((e) {
        debugPrint('Fala: erro ($e)');
        _acabou();
      });
    await _tts.setLanguage('pt-BR');
    final vozes = [
      for (final v in (await _tts.getVoices as List? ?? const []))
        if (v is Map && '${v['locale']}'.toLowerCase().replaceAll('_', '-').startsWith('pt-br'))
          {'name': '${v['name']}', 'locale': '${v['locale']}'},
    ];
    for (final nome in _preferidas) {
      final voz = vozes.where((v) => v['name']!.toLowerCase().contains(nome)).firstOrNull;
      if (voz != null) {
        await _tts.setVoice(voz);
        break;
      }
    }
  }

  void _acabou() {
    final fim = _fim;
    _fim = null;
    if (fim != null && !fim.isCompleted) fim.complete();
  }

  @override
  Future<void> falar(String texto) async {
    await (_preparo ??= _preparar());
    _acabou();
    final fim = _fim = Completer<void>();
    await _tts.speak(texto.length > _maximo ? _cortar(texto) : texto);
    return fim.future;
  }

  /// Corta no fim da última frase que cabe.
  static String _cortar(String texto) {
    final corte = texto.substring(0, _maximo);
    final ponto = corte.lastIndexOf(RegExp(r'[.!?]\s'));
    return ponto > _maximo ~/ 2 ? corte.substring(0, ponto + 1) : corte;
  }

  @override
  Future<void> parar() async {
    if (_fim == null) return;
    await _tts.stop();
    _acabou();
  }

  @override
  Future<void> fechar() => parar();
}

/// Quando a Aurora responde falando (Conta › Resposta em voz, por aparelho).
enum QuandoFalar {
  /// Só quando o pedido veio pelo microfone (padrão).
  pedidoPorVoz('Quando eu falar'),
  sempre('Sempre'),
  nunca('Nunca');

  const QuandoFalar(this.rotulo);
  final String rotulo;

  static const chave = 'voz_resposta';

  static Future<QuandoFalar> ler(BancoAurora db) async =>
      values.asNameMap()[await db.preferencia(chave)] ?? pedidoPorVoz;

  Future<void> salvar(BancoAurora db) => db.salvarPreferencia(chave, name);

  bool deveFalar({required bool porVoz}) => switch (this) {
        pedidoPorVoz => porVoz,
        sempre => true,
        nunca => false,
      };
}

/// O que a Aurora respondeu ao último pedido [pedido]: as mensagens dela (e
/// os avisos, como "sem conexão") depois dele, até o próximo pedido.
String respostaDoPedido(List<MensagemAssistente> conversa, String pedido) {
  final i = conversa.lastIndexWhere((m) => m.papel == PapelMensagem.eu && m.texto.trim() == pedido.trim());
  if (i < 0) return '';
  return [
    for (final m in conversa.skip(i + 1).takeWhile((m) => m.papel != PapelMensagem.eu))
      if (!m.desfeita && m.texto.trim().isNotEmpty) m.texto.trim(),
  ].join('\n');
}

/// O texto da resposta como se fala: sem markdown (`**`, marcadores `•`),
/// sem emoji, valores em reais por extenso ("R$ 35,00" → "35 reais") e cada
/// linha terminando em pausa.
String textoParaFala(String texto) {
  var t = texto
      .replaceAll('**', '')
      .replaceAll('`', '')
      .replaceAll(RegExp(r'^\s*#+\s*', multiLine: true), '')
      .replaceAll(RegExp(r'^\s*[•\-*·▪◦]\s+', multiLine: true), '')
      .replaceAll(RegExp(r'\s*[•·]\s*'), ', ')
      .replaceAll(RegExp(r'\s*›\s*'), ', ')
      .replaceAll(RegExp(r'[“”"]'), '')
      .replaceAll(RegExp(r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE0F}\u{200D}]', unicode: true), '');
  t = t.replaceAllMapped(RegExp(r'(−\s*)?R\$\s*(\d{1,3}(?:\.\d{3})+|\d+)(?:,(\d{2}))?'), (m) {
    final sinal = m[1] == null ? '' : 'menos ';
    final reais = int.tryParse(m[2]!.replaceAll('.', '')) ?? 0;
    final centavos = int.tryParse(m[3] ?? '0') ?? 0;
    final partes = [
      if (reais > 0 || centavos == 0) '${m[2]} ${reais == 1 ? 'real' : 'reais'}',
      if (centavos > 0) '$centavos ${centavos == 1 ? 'centavo' : 'centavos'}',
    ];
    return '$sinal${partes.join(' e ')}';
  });
  final linhas = [
    for (final l in t.split('\n'))
      if (l.trim().isNotEmpty) RegExp(r'[.!?:;,]$').hasMatch(l.trim()) ? l.trim() : '${l.trim()}.',
  ];
  return linhas.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// A voz da Aurora numa tela: fala uma resposta por vez e avisa a tela
/// enquanto fala (para mostrar o "Parar").
class FalaDaAurora extends ChangeNotifier {
  FalaDaAurora({Falador Function()? falador}) : _novoFalador = falador ?? faladorDoAparelho;

  final Falador Function() _novoFalador;
  Falador? _falador;
  bool _fechado = false;

  /// Cada fala ganha um número: a que foi parada não desliga a seguinte.
  int _vez = 0;

  bool falando = false;

  /// Lê [texto] (já limpo por [textoParaFala] aqui), parando o que estava falando.
  Future<void> falar(String texto) async {
    final limpo = textoParaFala(texto);
    if (limpo.isEmpty || _fechado) return;
    await parar();
    final vez = ++_vez;
    falando = true;
    _mudou();
    try {
      await (_falador ??= _novoFalador()).falar(limpo);
    } catch (e) {
      debugPrint('Fala: não deu para falar ($e)');
    } finally {
      if (vez == _vez) {
        falando = false;
        _mudou();
      }
    }
  }

  Future<void> parar() async {
    if (!falando) return;
    _vez++;
    falando = false;
    _mudou();
    try {
      await _falador?.parar();
    } catch (e) {
      debugPrint('Fala: não deu para parar ($e)');
    }
  }

  void _mudou() {
    if (!_fechado) notifyListeners();
  }

  @override
  void dispose() {
    _fechado = true;
    _vez++;
    final f = _falador;
    if (f != null) (falando ? f.parar().whenComplete(f.fechar) : f.fechar()).ignore();
    super.dispose();
  }
}
