import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';

import '../../core/tema.dart';

/// Converte uma URL comum do Spotify em uma URL de Embed do player oficial.
String converterUrlParaEmbedSpotify(String url) {
  var limpa = url.trim();
  if (limpa.isEmpty) {
    limpa = 'https://open.spotify.com/playlist/37i9dQZF1DWZeKCadgRdKQ';
  }

  // Se for URI no formato spotify:playlist:id ou spotify:track:id
  if (limpa.startsWith('spotify:')) {
    final partes = limpa.split(':');
    if (partes.length >= 3) {
      final tipo = partes[1];
      final id = partes[2];
      return 'https://open.spotify.com/embed/$tipo/$id?utm_source=generator&theme=0';
    }
  }

  // Remove parâmetros antigos de query para padronizar
  final semQuery = limpa.split('?').first;

  // Substitui os caminhos padrão por /embed/
  String resultado = semQuery;
  if (!resultado.contains('/embed/')) {
    resultado = resultado
        .replaceAll('open.spotify.com/playlist/', 'open.spotify.com/embed/playlist/')
        .replaceAll('open.spotify.com/track/', 'open.spotify.com/embed/track/')
        .replaceAll('open.spotify.com/album/', 'open.spotify.com/embed/album/')
        .replaceAll('open.spotify.com/artist/', 'open.spotify.com/embed/artist/');
  }

  // Se não foi alterado e não tem embed, tenta colocar antes do caminho
  if (!resultado.contains('/embed/')) {
    resultado = resultado.replaceAll('open.spotify.com/', 'open.spotify.com/embed/');
  }

  return '$resultado?utm_source=generator&theme=0';
}

/// Player oficial embutido do Spotify para PC (Windows).
/// Renderiza o widget web oficial do Spotify com capa, controles e faixas.
class PlayerSpotifyIntegrado extends StatefulWidget {
  const PlayerSpotifyIntegrado({
    super.key,
    required this.url,
    this.alturaPadrao = 352,
    this.aoFechar,
    this.aoAbrirExterno,
  });

  final String url;
  final double alturaPadrao;
  final VoidCallback? aoFechar;
  final VoidCallback? aoAbrirExterno;

  @override
  State<PlayerSpotifyIntegrado> createState() => _PlayerSpotifyIntegradoState();
}

class _PlayerSpotifyIntegradoState extends State<PlayerSpotifyIntegrado> {
  final WebviewController _controller = WebviewController();
  bool _inicializado = false;
  bool _carregando = true;
  bool _expandido = true;
  bool _emTelaDeLogin = false;
  String? _erro;

  static const _verdeSpotify = Color(0xFF1DB954);

  bool get _podeUsarWebview => !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  double get _alturaAtual {
    if (_emTelaDeLogin) return 460;
    return _expandido ? widget.alturaPadrao : 152;
  }

  @override
  void initState() {
    super.initState();
    if (_podeUsarWebview) {
      _iniciarWebview();
    }
  }

  Future<void> _iniciarWebview() async {
    try {
      await _controller.initialize();
      await _controller.setBackgroundColor(Colors.transparent);
      // Exibe popups na mesma janela para permitir login e ações interativas
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.sameWindow);

      final embedUrl = converterUrlParaEmbedSpotify(widget.url);
      await _controller.loadUrl(embedUrl);

      _controller.url.listen((urlAtual) {
        if (!mounted) return;
        if (urlAtual.contains('accounts.spotify.com')) {
          if (!_emTelaDeLogin) setState(() => _emTelaDeLogin = true);
        } else if (urlAtual.contains('open.spotify.com/embed') && _emTelaDeLogin) {
          setState(() => _emTelaDeLogin = false);
        }
      });

      if (mounted) {
        setState(() {
          _inicializado = true;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _erro = 'Não foi possível carregar o player integrado: $e';
          _carregando = false;
        });
      }
    }
  }

  void _irParaLoginOuVoltar() {
    final embedUrl = converterUrlParaEmbedSpotify(widget.url);
    if (_emTelaDeLogin) {
      setState(() => _emTelaDeLogin = false);
      _controller.loadUrl(embedUrl);
    } else {
      setState(() => _emTelaDeLogin = true);
      final loginUrl = 'https://accounts.spotify.com/login?continue=${Uri.encodeComponent(embedUrl)}';
      _controller.loadUrl(loginUrl);
    }
  }

  @override
  void didUpdateWidget(covariant PlayerSpotifyIntegrado oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url && _inicializado) {
      final embedUrl = converterUrlParaEmbedSpotify(widget.url);
      _controller.loadUrl(embedUrl);
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

    return Container(
      decoration: BoxDecoration(
        color: _verdeSpotify.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _verdeSpotify.withValues(alpha: 0.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barra de título do player Spotify
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
            child: Row(
              children: [
                const Icon(Icons.music_note_rounded, size: 16, color: _verdeSpotify),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _emTelaDeLogin ? 'Login no Spotify' : 'Player Oficial do Spotify',
                    style: manrope(12.5, peso: FontWeight.w700, cor: _verdeSpotify),
                  ),
                ),
                // Botão explícito para Fazer Login ou Voltar à Playlist
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: _verdeSpotify,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  onPressed: _inicializado ? _irParaLoginOuVoltar : null,
                  icon: Icon(
                    _emTelaDeLogin ? Icons.arrow_back_rounded : Icons.login_rounded,
                    size: 14,
                  ),
                  label: Text(
                    _emTelaDeLogin ? 'Voltar à playlist' : 'Fazer login',
                    style: manrope(11.5, peso: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 4),
                if (!_emTelaDeLogin)
                  IconButton(
                    tooltip: _expandido ? 'Modo compacto (152px)' : 'Modo expandido (352px)',
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
                    tooltip: 'Abrir no app desktop do Spotify',
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.open_in_new_rounded, size: 16, color: c.muted),
                    onPressed: widget.aoAbrirExterno,
                  ),
                if (widget.aoFechar != null)
                  IconButton(
                    tooltip: 'Recolher player',
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.close_rounded, size: 16, color: c.muted),
                    onPressed: widget.aoFechar,
                  ),
              ],
            ),
          ),
          // Área de visualização do Player
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
              const Icon(Icons.desktop_windows_rounded, size: 28, color: _verdeSpotify),
              const SizedBox(height: 6),
              Text(
                'O Player Integrado do Spotify está disponível no aplicativo para Windows.',
                textAlign: TextAlign.center,
                style: manrope(12, cor: c.muted),
              ),
              const SizedBox(height: 6),
              if (widget.aoAbrirExterno != null)
                TextButton.icon(
                  onPressed: widget.aoAbrirExterno,
                  icon: const Icon(Icons.open_in_new_rounded, size: 14),
                  label: const Text('Ouvir no Spotify'),
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
                  label: const Text('Abrir no aplicativo do Spotify'),
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
              child: CircularProgressIndicator(strokeWidth: 2, color: _verdeSpotify),
            ),
            SizedBox(height: 8),
            Text(
              'Carregando Spotify...',
              style: TextStyle(fontSize: 12, color: _verdeSpotify),
            ),
          ],
        ),
      );
    }

    return Webview(_controller);
  }
}
