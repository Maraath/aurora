import 'package:flutter/foundation.dart';

import '../core/avisos_push.dart';
import '../core/bloqueio.dart';
import '../core/login_google.dart';
import '../core/nuvem.dart';
import 'banco.dart';
import 'fotos/cofre.dart';
import 'fotos/cofre_audios.dart';
import 'sincronizacao.dart';

/// Sai da conta neste aparelho. Antes de sair, os avisos por push deixam de vir
/// para cá (senão a pessoa seguinte receberia os lembretes de quem saiu).
/// [limpar]: apaga também tudo o que está no aparelho.
Future<void> sairDaConta(BancoAurora db, {bool limpar = false}) async {
  await AvisosPush.aoSair();
  await sairDoGoogle();
  await nuvem?.auth.signOut();
  if (limpar) await limparEsteAparelho(db);
}

/// Apaga do aparelho os dados, as preferências (PIN incluído), as fotos e os
/// áudios. O que está na nuvem fica. Vale para sair de um aparelho compartilhado
/// e para quem esqueceu o PIN: sem isso, não haveria saída.
Future<void> limparEsteAparelho(BancoAurora db) async {
  await apagarDadosSincronizados(db);
  await db.delete(db.preferencias).go();
  // Web: não há pasta de fotos, e cada falha aqui não pode impedir o resto.
  try {
    await CofreFotos(db).limparSobras(const {});
  } catch (e) {
    debugPrint('Limpar aparelho: fotos ($e)');
  }
  try {
    await CofreAudios(db).limparSobras(const {});
  } catch (e) {
    debugPrint('Limpar aparelho: áudios ($e)');
  }
  ServicoBloqueio.mudou.value++;
}
