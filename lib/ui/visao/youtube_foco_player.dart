import 'dart:io';

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';

import '../../core/tema.dart';
import 'foco.dart';

/// Extrai o ID do vídeo e/ou playlist a partir de qualquer formato de link do YouTube.
({String? videoId, String? listId}) extrairIdsYoutube(String url) {
  final limpa = url.trim();
  final uri = Uri.tryParse(limpa);
  if (uri != null) {
    final listId = uri.queryParameters['list'];
    final v = uri.queryParameters['v'];
    if (v != null && v.isNotEmpty) {
      return (videoId: v, listId: listId);
    }
    if (uri.host.contains('youtu.be') && uri.pathSegments.isNotEmpty) {
      return (videoId: uri.pathSegments.first, listId: listId);
    }
    if (uri.pathSegments.contains('embed') && uri.pathSegments.isNotEmpty) {
      final idx = uri.pathSegments.indexOf('embed');
      if (idx + 1 < uri.pathSegments.length) {
        return (videoId: uri.pathSegments[idx + 1], listId: listId);
      }
    }
    if (listId != null && listId.isNotEmpty) {
      return (videoId: null, listId: listId);
    }
  }

  final match = RegExp(r'([a-zA-Z0-9_-]{11})').firstMatch(limpa);
  if (match != null) {
    return (videoId: match.group(1), listId: null);
  }

  return (videoId: 'WPni755-Krg', listId: null);
}

/// Servidor local leve em loopback (127.0.0.1).
/// Serve uma página HTML com Origin/Referer válidos e política de cabeçalhos adequada,
/// eliminando o "Erro 153: Erro de configuração do player de vídeo" do YouTube no WebView.
class ServidorYoutubeProxy {
  static ServidorYoutubeProxy? _instancia;
  static ServidorYoutubeProxy get instancia => _instancia ??= ServidorYoutubeProxy._();
  ServidorYoutubeProxy._();

  HttpServer? _server;
  int? get porta => _server?.port;

  Future<int> iniciar() async {
    if (_server != null) return _server!.port;

    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server!.listen((HttpRequest request) {
      final videoId = request.uri.queryParameters['v'] ?? 'WPni755-Krg';
      final listId = request.uri.queryParameters['list'];

      final embedSrc = listId != null && listId.isNotEmpty
          ? 'https://www.youtube.com/embed/videoseries?list=$listId&autoplay=1&modestbranding=1&rel=0'
          : 'https://www.youtube.com/embed/$videoId?autoplay=1&modestbranding=1&rel=0';

      final html = '''
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="referrer" content="strict-origin-when-cross-origin">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { width: 100%; height: 100%; background: #000; overflow: hidden; }
    iframe { width: 100%; height: 100%; border: none; display: block; }
  </style>
</head>
<body>
  <iframe
    id="player"
    src="$embedSrc"
    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
    referrerpolicy="strict-origin-when-cross-origin"
    allowfullscreen>
  </iframe>
</body>
</html>
''';

      request.response.headers.contentType = ContentType.html;
      request.response.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin');
      request.response.headers.set('Access-Control-Allow-Origin', '*');
      request.response.write(html);
      request.response.close();
    });

    return _server!.port;
  }
}

/// Player oficial embutido do YouTube para PC (Windows) via WebView2.
/// Toca áudio e vídeo de foco sem o Erro 153 através do proxy de origem local.
class PlayerYoutubeIntegrado extends StatefulWidget {
  const PlayerYoutubeIntegrado({
    super.key,
    required this.url,
    this.titulo,
    this.segmento,
    this.alturaPadrao = 220,
    this.aoFechar,
    this.aoAbrirExterno,
  });

  final String url;
  final String? titulo;
  final SegmentoAudioFoco? segmento;
  final double alturaPadrao;
  final VoidCallback? aoFechar;
  final VoidCallback? aoAbrirExterno;

  @override
  State<PlayerYoutubeIntegrado> createState() => _PlayerYoutubeIntegradoState();
}

class _PlayerYoutubeIntegradoState extends State<PlayerYoutubeIntegrado> {
  final WebviewController _controller = WebviewController();
  bool _inicializado = false;
  bool _carregando = true;
  bool _expandido = false;
  String? _erro;

  static const _corYoutube = Color(0xFFFF4E45);

  bool get _podeUsarWebview => !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  double get _alturaAtual => _expandido ? 340 : widget.alturaPadrao;

  @override
  void initState() {
    super.initState();
    if (_podeUsarWebview) {
      _iniciarWebview();
    }
  }

  Future<void> _iniciarWebview() async {
    try {
      final porta = await ServidorYoutubeProxy.instancia.iniciar();
      await _controller.initialize();
      await _controller.setBackgroundColor(Colors.black);
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);

      final urlLocal = _gerarUrlLocal(porta, widget.url);
      await _controller.loadUrl(urlLocal);

      if (mounted) {
        setState(() {
          _inicializado = true;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _erro = 'Não foi possível carregar o player do YouTube: $e';
          _carregando = false;
        });
      }
    }
  }

  String _gerarUrlLocal(int porta, String urlOriginal) {
    final ids = extrairIdsYoutube(urlOriginal);
    final params = <String>[];
    if (ids.videoId != null) params.add('v=${ids.videoId}');
    if (ids.listId != null) params.add('list=${ids.listId}');
    final query = params.isNotEmpty ? '?${params.join('&')}' : '';
    return 'http://127.0.0.1:$porta/$query';
  }

  @override
  void didUpdateWidget(covariant PlayerYoutubeIntegrado oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url && _inicializado) {
      final porta = ServidorYoutubeProxy.instancia.porta;
      if (porta != null) {
        final urlLocal = _gerarUrlLocal(porta, widget.url);
        _controller.loadUrl(urlLocal);
      }
    }
  }

  @override
  void dispose() {
    if (_podeUsarWebview) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final tituloExibicao = widget.titulo ?? widget.segmento?.titulo ?? 'YouTube Foco';

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: _corYoutube.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _corYoutube.withValues(alpha: 0.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barra superior do player YouTube
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
            child: Row(
              children: [
                const Icon(Icons.play_circle_fill_rounded, size: 18, color: _corYoutube),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tituloExibicao,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: manrope(12.5, peso: FontWeight.w700, cor: _corYoutube),
                  ),
                ),
                IconButton(
                  tooltip: _expandido ? 'Modo compacto (220px)' : 'Modo expandido (340px)',
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    _expandido ? Icons.unfold_less_rounded : Icons.unfold_more_rounded,
                    size: 16,
                    color: c.muted,
                  ),
                  onPressed: () => setState(() => _expandido = !_expandido),
                ),
                if (widget.aoAbrirExterno != null)
                  IconButton(
                    tooltip: 'Abrir no navegador',
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.open_in_new_rounded, size: 16, color: c.muted),
                    onPressed: widget.aoAbrirExterno,
                  ),
                if (widget.aoFechar != null)
                  IconButton(
                    tooltip: 'Fechar player',
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.close_rounded, size: 16, color: c.muted),
                    onPressed: widget.aoFechar,
                  ),
              ],
            ),
          ),
          // Janela do player WebView
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            height: _alturaAtual,
            child: _conteudoPlayer(c),
          ),
        ],
      ),
    );
  }

  Widget _conteudoPlayer(AuroraCores c) {
    if (!_podeUsarWebview) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.desktop_windows_rounded, size: 28, color: _corYoutube),
              const SizedBox(height: 6),
              Text(
                'O player integrado do YouTube está disponível no aplicativo para Windows.',
                textAlign: TextAlign.center,
                style: manrope(12, cor: c.muted),
              ),
              const SizedBox(height: 6),
              if (widget.aoAbrirExterno != null)
                TextButton.icon(
                  onPressed: widget.aoAbrirExterno,
                  icon: const Icon(Icons.open_in_new_rounded, size: 14),
                  label: const Text('Abrir no YouTube'),
                ),
            ],
          ),
        ),
      );
    }

    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline_rounded, size: 24, color: c.bad),
              const SizedBox(height: 6),
              Text(
                _erro!,
                textAlign: TextAlign.center,
                style: manrope(11.5, cor: c.bad),
              ),
              const SizedBox(height: 6),
              if (widget.aoAbrirExterno != null)
                TextButton.icon(
                  onPressed: widget.aoAbrirExterno,
                  icon: const Icon(Icons.open_in_new_rounded, size: 14),
                  label: const Text('Abrir no navegador'),
                ),
            ],
          ),
        ),
      );
    }

    if (_carregando || !_inicializado) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: _corYoutube),
            ),
            SizedBox(height: 8),
            Text(
              'Carregando YouTube...',
              style: TextStyle(fontSize: 12, color: _corYoutube),
            ),
          ],
        ),
      );
    }

    return Webview(_controller);
  }
}
