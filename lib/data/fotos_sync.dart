import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import 'shape_repo.dart';

/// Leva as imagens das fotos depois da sincronização das tabelas:
///  1. apaga da nuvem o que ficou pendente (fotos apagadas ou tiradas da
///     nuvem sem internet);
///  2. envia as fotos marcadas para subir (modo "Sincronizar" ou "Enviar para
///     a nuvem" sem internet) e marca a linha como `na_nuvem`;
///  3. apaga do aparelho os arquivos de fotos que não existem mais.
/// Não baixa nada: miniaturas e fotos inteiras descem quando aparecem na tela
/// (CofreFotos.obter) e ficam guardadas.
class SincronizadorFotos {
  SincronizadorFotos(this.repo);
  final ShapeRepo repo;

  Future<({int enviadas, int apagadas})> sincronizar() async {
    final cofre = repo.cofre;
    final armazem = cofre.armazem;
    var enviadas = 0, apagadas = 0;
    if (armazem != null) {
      final apagar = await cofre.pendentesApagar();
      if (apagar.isNotEmpty) {
        await armazem.apagar(apagar);
        for (final id in apagar) {
          await cofre.apagamentoFeito(id);
        }
        apagadas = apagar.length;
      }

      final ativas = {for (final f in await repo.fotosAtivas()) f.id: f};
      for (final id in await cofre.pendentesEnviar()) {
        final foto = ativas[id];
        if (foto == null) {
          await cofre.esquecerEnvio(id);
          continue;
        }
        try {
          await repo.enviarParaNuvem(foto);
          enviadas++;
        } on StateError catch (e) {
          // A imagem não está aqui (trocada em outro aparelho): nada a enviar.
          debugPrint('Fotos: não enviei $id: ${e.message}');
          await cofre.esquecerEnvio(id);
        }
      }
    }
    await cofre.limparSobras({for (final f in await repo.fotosAtivas()) f.id});
    if (enviadas > 0) repo.db.notifyUpdates({TableUpdate.onTable(repo.db.fotosShape)});
    return (enviadas: enviadas, apagadas: apagadas);
  }
}
