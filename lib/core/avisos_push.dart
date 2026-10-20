import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'avisos_push_stub.dart' if (dart.library.js_interop) 'avisos_push_web.dart';
import 'nuvem.dart';

/// Situação dos avisos neste aparelho (só na web; nos apps instalados o
/// Notificador agenda no próprio sistema).
enum EstadoAvisos {
  /// iPhone abrindo pelo Safari: os avisos só existem com o app na tela de início.
  instalar,
  semSuporte,

  /// A pessoa recusou; só volta pelos Ajustes do iPhone (ou do navegador).
  negado,
  desligado,
  ativo,
}

/// Chave pública VAPID (gerada por tool/push/gerar_chaves.ps1). A privada fica
/// só nos segredos da Edge Function avisos-push.
const chavePublicaAvisos = 'BBmNlsffol642eYz0prAZdZFBwBrJON842apZxW8FDI9ChabBsm1cnirLyX3hcGeHjNwSnJ3p3OJamnCiPKFGjw';

/// Avisos por Web Push: o aparelho se inscreve (push_inscricoes) e o app manda
/// a agenda dos próximos dias (Notificador → substituir_avisos); o servidor
/// envia na hora (migração 20261020200000_avisos_push.sql).
class AvisosPush {
  AvisosPush._();

  /// Muda quando o aparelho ativa ou desativa (as telas releem o estado).
  static final mudou = ValueNotifier<int>(0);

  static Future<EstadoAvisos> estado() async {
    if (!kIsWeb) return EstadoAvisos.semSuporte;
    return switch (await estadoNoNavegador()) {
      'instalar' => EstadoAvisos.instalar,
      'negado' => EstadoAvisos.negado,
      'desligado' => EstadoAvisos.desligado,
      'ativo' => EstadoAvisos.ativo,
      _ => EstadoAvisos.semSuporte,
    };
  }

  static bool get logado => nuvem?.auth.currentUser != null;

  /// Pede a permissão, inscreve o aparelho e registra no servidor. Chamar direto
  /// no toque do botão (o iPhone só mostra o pedido dentro de um toque).
  /// Devolve uma mensagem de erro para a pessoa, ou nulo se deu certo.
  static Future<String?> ativar() async {
    if (!logado) return 'Entre na sua conta primeiro: é ela que recebe os avisos.';
    final String? inscricao;
    try {
      inscricao = await ativarNoNavegador(chavePublicaAvisos);
    } catch (e) {
      debugPrint('Avisos: falha ao inscrever ($e)');
      return 'Não deu para ativar os avisos neste aparelho.';
    }
    if (inscricao == null) return 'Os avisos não foram permitidos.';
    try {
      await _registrar(inscricao);
    } catch (e) {
      debugPrint('Avisos: falha ao registrar ($e)');
      return 'Sem conexão com o servidor. Tente de novo com internet.';
    }
    mudou.value++;
    return null;
  }

  /// Ao abrir o app: um aparelho já inscrito confirma no servidor que é desta
  /// conta (troca de conta, inscrição renovada pelo sistema).
  static Future<void> renovar() async {
    if (!kIsWeb || !logado) return;
    final inscricao = await inscricaoNoNavegador();
    if (inscricao == null) return;
    try {
      await _registrar(inscricao);
    } catch (e) {
      debugPrint('Avisos: falha ao renovar ($e)');
    }
  }

  static Future<void> desativar() async {
    final inscricao = await desativarNoNavegador();
    if (inscricao != null && logado) {
      final endpoint = (jsonDecode(inscricao) as Map<String, dynamic>)['endpoint'];
      try {
        await nuvem!.from('push_inscricoes').delete().eq('endpoint', '$endpoint');
      } catch (e) {
        debugPrint('Avisos: falha ao apagar a inscrição ($e)');
      }
    }
    mudou.value++;
  }

  /// Um aviso agora (chega em até 1 minuto, quando o servidor passa).
  static Future<void> testar() => nuvem!.rpc('aviso_de_teste');

  static Future<void> _registrar(String inscricao) async {
    final dados = jsonDecode(inscricao) as Map<String, dynamic>;
    final chaves = dados['keys'] as Map<String, dynamic>;
    await nuvem!.rpc('registrar_push', params: {
      'endpoint_push': dados['endpoint'],
      'chave_p256dh': chaves['p256dh'],
      'chave_auth': chaves['auth'],
      'nome_aparelho': nomeDoAparelho(),
    });
  }
}
