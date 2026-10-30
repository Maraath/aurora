import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/relogio.dart';
import '../../core/sons.dart';
import '../../data/banco.dart';

/// Os três modos do timer de foco imersivo, cada um com minutos personalizáveis.
enum ModoFoco {
  pomodoro('Pomodoro', 25),
  imersao('Imersão', 50),
  pausa('Pausa', 5);

  const ModoFoco(this.rotulo, this.padraoMinutos);
  final String rotulo;
  final int padraoMinutos;
}

/// Segmento de áudio/música de foco com playlist no YouTube.
enum SegmentoAudioFoco {
  binaural(
    'Binaural Cósmico',
    'Ondas Alpha & Theta',
    'https://www.youtube.com/watch?v=WPni755-Krg',
  ),
  chuva(
    'Chuva Noturna',
    'Isolamento calmo',
    'https://www.youtube.com/watch?v=q76bMs-NwRk',
  ),
  lofi(
    'Lofi Estrelado',
    'Beats para focar',
    'https://www.youtube.com/watch?v=lTRiuFIWV54',
  ),
  ruido(
    'Ruído Marrom',
    'Concentração profunda',
    'https://www.youtube.com/watch?v=RqzGzwTY-6w',
  );

  const SegmentoAudioFoco(this.titulo, this.subtitulo, this.urlPadrao);
  final String titulo;
  final String subtitulo;
  final String urlPadrao;
}

/// Playlists oficiais sugeridas para vincular rápido ao Spotify.
const sugestoesSpotifyFoco = <(String, String)>[
  ('Deep Focus · Spotify', 'https://open.spotify.com/playlist/37i9dQZF1DWZeKCadgRdKQ'),
  ('Lo-Fi Beats · Spotify', 'https://open.spotify.com/playlist/37i9dQZF1DWWQRwui0ExPn'),
  ('Brain Food · Spotify', 'https://open.spotify.com/playlist/37i9dQZF1DWXLeA8Omikj7'),
  ('Peaceful Piano · Spotify', 'https://open.spotify.com/playlist/37i9dQZF1DX4sWSpwq3LiO'),
];

const _chaveTempos = 'foco_tempos_v1';
const _chaveSpotify = 'foco_spotify_v1';
const _chaveYoutube = 'foco_youtube_v1';
const _chaveEstatisticas = 'foco_estatisticas_v1';
const _chaveHistoricoFoco = 'foco_historico_dias_v1';

/// Controle global de foco imersivo. Fica fora da tela para não zerar ao trocar
/// de aba e guarda os tempos personalizados (Pomodoro, Imersão e Pausa),
/// links de playlists do YouTube e vínculo com o Spotify.
class ControleFoco extends ChangeNotifier {
  ControleFoco._();
  static final instancia = ControleFoco._();

  static const duracao = Duration(minutes: 25);

  ModoFoco modo = ModoFoco.pomodoro;

  final Map<ModoFoco, int> _minutosPorModo = {
    for (final m in ModoFoco.values) m: m.padraoMinutos,
  };

  final Map<SegmentoAudioFoco, String> _urlsYoutube = {
    for (final s in SegmentoAudioFoco.values) s: s.urlPadrao,
  };

  SegmentoAudioFoco? segmentoAtivo;

  bool spotifyVinculado = false;
  String spotifyNome = 'Deep Focus · Spotify';
  String spotifyUrl = 'https://open.spotify.com/playlist/37i9dQZF1DWZeKCadgRdKQ';

  int indice = 0;
  ({String titulo, String detalhe})? itemSelecionado;

  Duration duracaoTotal = duracao;
  Duration restante = duracao;
  Timer? _timer;
  int _segundosAcumulados = 0;

  int minutosFocadosHoje = 0;
  int sessoesHoje = 0;
  String _diaEstatisticas = '';
  final Map<String, int> _historicoDias = {};

  BancoAurora? _dbCarregado;

  bool get focando => _timer != null;

  /// Minutos configurados pelo usuário para o [m].
  int minutosDe(ModoFoco m) => _minutosPorModo[m] ?? m.padraoMinutos;

  /// URL do YouTube para o segmento [s].
  String urlYoutubeDe(SegmentoAudioFoco s) => _urlsYoutube[s] ?? s.urlPadrao;

  /// Fração concluída do ciclo atual (0.0 a 1.0).
  double get progresso {
    final total = duracaoTotal.inSeconds;
    if (total <= 0) return 0;
    return ((total - restante.inSeconds) / total).clamp(0.0, 1.0);
  }

  /// Carrega tempos personalizados, Spotify e estatísticas do banco local.
  Future<void> carregarPreferencias(BancoAurora db) async {
    if (_dbCarregado == db) return;
    _dbCarregado = db;
    try {
      final rawTempos = await db.preferencia(_chaveTempos);
      if (rawTempos != null && rawTempos.isNotEmpty) {
        final mapa = jsonDecode(rawTempos) as Map<String, dynamic>;
        for (final m in ModoFoco.values) {
          final v = mapa[m.name];
          if (v is num && v >= 1 && v <= 480) {
            _minutosPorModo[m] = v.toInt();
          }
        }
        if (!focando) {
          duracaoTotal = Duration(minutes: minutosDe(modo));
          restante = duracaoTotal;
        }
      }

      final rawSpotify = await db.preferencia(_chaveSpotify);
      if (rawSpotify != null && rawSpotify.isNotEmpty) {
        final mapa = jsonDecode(rawSpotify) as Map<String, dynamic>;
        spotifyVinculado = mapa['vinculado'] == true;
        final nome = (mapa['nome'] as String?)?.trim();
        final url = (mapa['url'] as String?)?.trim();
        if (nome != null && nome.isNotEmpty) spotifyNome = nome;
        if (url != null && url.isNotEmpty) spotifyUrl = url;
      }

      final rawYoutube = await db.preferencia(_chaveYoutube);
      if (rawYoutube != null && rawYoutube.isNotEmpty) {
        final mapa = jsonDecode(rawYoutube) as Map<String, dynamic>;
        for (final s in SegmentoAudioFoco.values) {
          final u = (mapa[s.name] as String?)?.trim();
          // Ignora URLs legadas que tinham problemas no YouTube
          final ehAntiga = u != null && (u.contains('mPZkdNFkNps') || u.contains('jfKfPfyJRdk'));
          if (u != null && u.isNotEmpty && !ehAntiga) {
            _urlsYoutube[s] = u;
          }
        }
      }

      final hoje = chaveData(hojeLocal());
      _diaEstatisticas = hoje;
      final rawEst = await db.preferencia(_chaveEstatisticas);
      if (rawEst != null && rawEst.isNotEmpty) {
        final mapa = jsonDecode(rawEst) as Map<String, dynamic>;
        if (mapa['dia'] == hoje) {
          minutosFocadosHoje = (mapa['minutos'] as num?)?.toInt() ?? 0;
          sessoesHoje = (mapa['sessoes'] as num?)?.toInt() ?? 0;
        } else {
          minutosFocadosHoje = 0;
          sessoesHoje = 0;
        }
      }

      final rawHist = await db.preferencia(_chaveHistoricoFoco);
      if (rawHist != null && rawHist.isNotEmpty) {
        final mapa = jsonDecode(rawHist) as Map<String, dynamic>;
        _historicoDias.clear();
        for (final e in mapa.entries) {
          if (e.value is num) {
            _historicoDias[e.key] = (e.value as num).toInt();
          }
        }
      }
      if (minutosFocadosHoje > 0) {
        _historicoDias[hoje] = minutosFocadosHoje;
      }
      notifyListeners();
    } catch (_) {
      // Ignora JSON inválido em preferências antigas.
    }
  }

  /// Muda o modo ativo (Pomodoro, Imersão ou Pausa) e reinicia o contador.
  void selecionarModo(ModoFoco novoModo) {
    _pararTimer();
    modo = novoModo;
    duracaoTotal = Duration(minutes: minutosDe(novoModo));
    restante = duracaoTotal;
    notifyListeners();
  }

  /// Altera os minutos de uma das 3 opções (Pomodoro, Imersão ou Pausa).
  Future<void> definirMinutosModo(ModoFoco m, int minutos, {BancoAurora? db}) async {
    final limpo = minutos.clamp(1, 480);
    _minutosPorModo[m] = limpo;
    if (modo == m && !focando) {
      duracaoTotal = Duration(minutes: limpo);
      restante = duracaoTotal;
    }
    notifyListeners();
    final alvoDb = db ?? _dbCarregado;
    if (alvoDb != null) {
      await alvoDb.salvarPreferencia(
        _chaveTempos,
        jsonEncode({for (final e in _minutosPorModo.entries) e.key.name: e.value}),
      );
    }
  }

  /// Salva de uma vez os minutos das 3 opções.
  Future<void> salvarTodosTempos({
    required int pomodoro,
    required int imersao,
    required int pausa,
    BancoAurora? db,
  }) async {
    _minutosPorModo[ModoFoco.pomodoro] = pomodoro.clamp(1, 480);
    _minutosPorModo[ModoFoco.imersao] = imersao.clamp(1, 480);
    _minutosPorModo[ModoFoco.pausa] = pausa.clamp(1, 480);
    if (!focando) {
      duracaoTotal = Duration(minutes: minutosDe(modo));
      restante = duracaoTotal;
    }
    notifyListeners();
    final alvoDb = db ?? _dbCarregado;
    if (alvoDb != null) {
      await alvoDb.salvarPreferencia(
        _chaveTempos,
        jsonEncode({for (final e in _minutosPorModo.entries) e.key.name: e.value}),
      );
    }
  }

  /// Prepara o timer para um item específico vindo do Timeblocking.
  void prepararItem({required String titulo, String detalhe = 'Bloco de foco', int? minutos}) {
    _pararTimer();
    itemSelecionado = (titulo: titulo, detalhe: detalhe);
    if (minutos != null && minutos > 0) {
      final limpo = minutos.clamp(1, 480);
      if (limpo == minutosDe(ModoFoco.pomodoro)) {
        modo = ModoFoco.pomodoro;
      } else if (limpo == minutosDe(ModoFoco.imersao)) {
        modo = ModoFoco.imersao;
      }
      duracaoTotal = Duration(minutes: limpo);
      restante = duracaoTotal;
    } else {
      duracaoTotal = Duration(minutes: minutosDe(modo));
      restante = duracaoTotal;
    }
    notifyListeners();
  }

  /// Vincula ou atualiza a playlist/conta do Spotify.
  Future<void> vincularSpotify({
    required String nome,
    required String url,
    BancoAurora? db,
  }) async {
    spotifyVinculado = true;
    spotifyNome = nome.trim().isEmpty ? 'Playlist de Foco · Spotify' : nome.trim();
    spotifyUrl = url.trim().isEmpty ? sugestoesSpotifyFoco.first.$2 : url.trim();
    notifyListeners();
    final alvoDb = db ?? _dbCarregado;
    if (alvoDb != null) {
      await alvoDb.salvarPreferencia(
        _chaveSpotify,
        jsonEncode({
          'vinculado': true,
          'nome': spotifyNome,
          'url': spotifyUrl,
        }),
      );
    }
  }

  /// Desvincula o Spotify.
  Future<void> desvincularSpotify({BancoAurora? db}) async {
    spotifyVinculado = false;
    notifyListeners();
    final alvoDb = db ?? _dbCarregado;
    if (alvoDb != null) {
      await alvoDb.salvarPreferencia(
        _chaveSpotify,
        jsonEncode({
          'vinculado': false,
          'nome': spotifyNome,
          'url': spotifyUrl,
        }),
      );
    }
  }

  /// Atualiza o link do YouTube de um segmento de foco.
  Future<void> definirUrlYoutube(SegmentoAudioFoco s, String url, {BancoAurora? db}) async {
    final limpo = url.trim();
    _urlsYoutube[s] = limpo.isEmpty ? s.urlPadrao : limpo;
    notifyListeners();
    final alvoDb = db ?? _dbCarregado;
    if (alvoDb != null) {
      await alvoDb.salvarPreferencia(
        _chaveYoutube,
        jsonEncode({for (final e in _urlsYoutube.entries) e.key.name: e.value}),
      );
    }
  }

  /// Abre a playlist de YouTube do segmento [s] e marca como ativo.
  Future<bool> abrirSegmentoYoutube(SegmentoAudioFoco s) async {
    segmentoAtivo = s;
    notifyListeners();
    return abrirLinkExterno(urlYoutubeDe(s));
  }

  /// Abre o Spotify vinculado.
  Future<bool> abrirSpotify() => abrirLinkExterno(spotifyUrl);

  /// Abre uma URL externa (YouTube ou Spotify) no navegador ou app.
  Future<bool> abrirLinkExterno(String endereco) async {
    final uri = Uri.tryParse(endereco.trim());
    if (uri == null) return false;
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  void alternar() {
    if (focando) {
      _pararTimer();
    } else {
      if (modo != ModoFoco.pausa) {
        Sons.instancia.tocarIniciarFoco();
      }
      if (restante <= Duration.zero) {
        restante = duracaoTotal;
      }
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        restante -= const Duration(seconds: 1);
        if (modo != ModoFoco.pausa) {
          _segundosAcumulados++;
          if (_segundosAcumulados >= 60) {
            _segundosAcumulados -= 60;
            _registrarMinutoFocado();
          }
        }
        if (restante <= Duration.zero) {
          if (modo != ModoFoco.pausa) {
            _registrarSessaoConcluida();
          }
          Sons.instancia.tocarFinalizarFoco();
          _pararTimer();
          restante = duracaoTotal;
        }
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void reiniciar() {
    _pararTimer();
    duracaoTotal = Duration(minutes: minutosDe(modo));
    restante = duracaoTotal;
    notifyListeners();
  }

  void proximo() {
    _pararTimer();
    itemSelecionado = null;
    indice++;
    restante = duracaoTotal;
    notifyListeners();
  }

  void _pararTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _garantirDiaAtual() {
    final hoje = chaveData(hojeLocal());
    if (_diaEstatisticas != hoje) {
      _diaEstatisticas = hoje;
      minutosFocadosHoje = 0;
      sessoesHoje = 0;
    }
  }

  void _registrarMinutoFocado() {
    _garantirDiaAtual();
    minutosFocadosHoje++;
    _salvarEstatisticas();
  }

  void _registrarSessaoConcluida() {
    _garantirDiaAtual();
    sessoesHoje++;
    _salvarEstatisticas();
  }

  void _salvarEstatisticas() {
    final db = _dbCarregado;
    if (db == null) return;
    _historicoDias[_diaEstatisticas] = minutosFocadosHoje;
    db.salvarPreferencia(
      _chaveEstatisticas,
      jsonEncode({
        'dia': _diaEstatisticas,
        'minutos': minutosFocadosHoje,
        'sessoes': sessoesHoje,
      }),
    );
    db.salvarPreferencia(
      _chaveHistoricoFoco,
      jsonEncode(_historicoDias),
    );
  }

  /// Retorna os minutos focados no dia [dia].
  int minutosNoDia(DateTime dia) {
    final chave = chaveData(dia);
    if (chave == _diaEstatisticas) return minutosFocadosHoje;
    return _historicoDias[chave] ?? 0;
  }

  /// Consulta estática do histórico de foco diário salvo no banco.
  static Future<Map<String, int>> carregarHistoricoMinutos(BancoAurora db) async {
    try {
      final raw = await db.preferencia(_chaveHistoricoFoco);
      if (raw != null && raw.isNotEmpty) {
        final mapa = jsonDecode(raw) as Map<String, dynamic>;
        return {
          for (final e in mapa.entries)
            if (e.value is num) e.key: (e.value as num).toInt(),
        };
      }
    } catch (_) {}
    return const {};
  }

  String get mostrador {
    final m = restante.inMinutes.toString().padLeft(2, '0');
    final s = (restante.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get rotulo {
    if (!focando) return 'Começar foco';
    return 'Focando · $mostrador';
  }
}
