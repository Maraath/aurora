import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../data/banco.dart';

/// Efeitos sonoros do Aurora para feedback auditivo de conclusão e foco.
enum EfeitoSonoro {
  /// Clique no botão de iniciar sessão/temporizador de foco (tom suave e calmante).
  iniciarFoco('sons/iniciar_foco.wav'),

  /// Temporizador de foco atinge 00:00 (acorde harmônico sereno de alívio).
  finalizarFoco('sons/finalizar_foco.wav'),

  /// Checkbox / botão de check de tarefa ou hábito (pop/ding tátil gratificante).
  concluirItem('sons/concluir_item.wav'),

  /// Conclusão de uma sessão ou registro de treino (acorde triunfante enérgico).
  concluirTreino('sons/concluir_treino.wav'),

  /// Marcador/botão de etapa de projeto ou marco concluído (escala ascendente).
  concluirEtapa('sons/concluir_etapa.wav'),

  /// Conclusão de objetivo ou meta global 100% (grande celebração festiva).
  concluirObjetivo('sons/concluir_objetivo.wav');

  const EfeitoSonoro(this.arquivo);

  /// Caminho relativo dentro de assets.
  final String arquivo;
}

/// Serviço centralizado de efeitos sonoros (SFX).
///
/// Gerencia carregamento, volume calibrado não-invasivo (padrão 50%), estado de mudo
/// global e tratamento de erro silencioso para nunca travar a aplicação.
class Sons {
  Sons._();
  static final instancia = Sons._();

  static const chaveAtivo = 'sons_ativos';
  static const chaveVolume = 'sons_volume';

  /// Volume padrão calibrado entre 40% e 60% (50%).
  static const double volumePadrao = 0.5;

  final ativo = ValueNotifier<bool>(true);
  final volume = ValueNotifier<double>(volumePadrao);

  BancoAurora? _db;
  bool _iniciado = false;

  /// Inicia o serviço lendo as preferências do usuário no banco.
  Future<void> iniciar(BancoAurora db) async {
    _db = db;
    try {
      final prefAtivo = await db.preferencia(chaveAtivo);
      if (prefAtivo != null) {
        ativo.value = prefAtivo == 'sim';
      }
      final prefVol = await db.preferencia(chaveVolume);
      if (prefVol != null) {
        final v = double.tryParse(prefVol);
        if (v != null) volume.value = v.clamp(0.0, 1.0);
      }
    } catch (e) {
      debugPrint('Sons.iniciar: erro ao ler preferências ($e)');
    } finally {
      _iniciado = true;
    }
  }

  /// Alterna se os efeitos sonoros estão ativados globalmente.
  Future<void> alternar(bool novoAtivo) async {
    ativo.value = novoAtivo;
    final db = _db;
    if (db != null) {
      await db.salvarPreferencia(chaveAtivo, novoAtivo ? 'sim' : 'nao');
    }
  }

  /// Ajusta o volume global dos efeitos (0.0 a 1.0).
  Future<void> definirVolume(double novoVolume) async {
    final v = novoVolume.clamp(0.0, 1.0);
    volume.value = v;
    final db = _db;
    if (db != null) {
      await db.salvarPreferencia(chaveVolume, v.toStringAsFixed(2));
    }
  }

  /// Toca um efeito sonoro de forma segura e não bloqueante.
  Future<void> tocar(EfeitoSonoro efeito) async {
    // Se o som estiver desativado ou rodando em testes automatizados, ignora.
    if (!ativo.value) return;
    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) return;

    try {
      final player = AudioPlayer();
      await player.setAudioContext(AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.assistanceSonification,
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        ),
      ));
      await player.setVolume(volume.value);
      await player.play(AssetSource(efeito.arquivo), mode: PlayerMode.lowLatency);

      // Limpa os recursos do player após o término do áudio.
      unawaited(
        player.onPlayerComplete.first
            .timeout(const Duration(seconds: 4), onTimeout: () => null)
            .then((_) => player.dispose())
            .catchError((_) {}),
      );
    } catch (e) {
      // Falha silenciosa: nunca quebra a UI nem interrompe ações do usuário.
      debugPrint('Sons.tocar: áudio indisponível ou bloqueado ($e)');
    }
  }

  // Métodos diretos de conveniência:
  void tocarIniciarFoco() => unawaited(tocar(EfeitoSonoro.iniciarFoco));
  void tocarFinalizarFoco() => unawaited(tocar(EfeitoSonoro.finalizarFoco));
  void tocarConcluirItem() => unawaited(tocar(EfeitoSonoro.concluirItem));
  void tocarConcluirTreino() => unawaited(tocar(EfeitoSonoro.concluirTreino));
  void tocarConcluirEtapa() => unawaited(tocar(EfeitoSonoro.concluirEtapa));
  void tocarConcluirObjetivo() => unawaited(tocar(EfeitoSonoro.concluirObjetivo));
}
