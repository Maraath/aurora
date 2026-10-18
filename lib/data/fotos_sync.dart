import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide TableUpdate;

import 'banco.dart';
import 'shape_repo.dart';

/// Um objeto guardado no balde de fotos.
class ObjetoFoto {
  const ObjetoFoto(this.nome, this.criadoEm);
  final String nome;
  final DateTime? criadoEm;
}

/// O balde privado das fotos do Shape (Supabase no app, memória nos testes).
/// Os nomes são relativos à pasta do usuário.
abstract class ArmazemFotos {
  /// De quem é o balde: a marca de "já enviada" vale por conta.
  String get conta;

  Future<void> enviar(String arquivo, Uint8List bytes);
  Future<Uint8List?> baixar(String arquivo);
  Future<List<ObjetoFoto>> listar();
  Future<void> apagar(List<String> arquivos);
}

class ArmazemSupabase implements ArmazemFotos {
  ArmazemSupabase(this.cliente, this.usuarioId);
  final SupabaseClient cliente;
  final String usuarioId;

  @override
  String get conta => usuarioId;

  StorageFileApi get _balde => cliente.storage.from('shape');

  @override
  Future<void> enviar(String arquivo, Uint8List bytes) => _balde.uploadBinary(
    '$usuarioId/$arquivo',
    bytes,
    fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
  );

  @override
  Future<Uint8List?> baixar(String arquivo) async {
    try {
      return await _balde.download('$usuarioId/$arquivo');
    } on StorageException catch (e) {
      // Ainda não chegou (o outro aparelho envia a linha antes da imagem).
      if (e.statusCode == '400' || e.statusCode == '404') return null;
      rethrow;
    }
  }

  @override
  Future<List<ObjetoFoto>> listar() async {
    final lista = <ObjetoFoto>[];
    for (var desde = 0; ; desde += 100) {
      final pagina = await _balde.list(
        path: usuarioId,
        searchOptions: SearchOptions(limit: 100, offset: desde),
      );
      lista.addAll([
        for (final o in pagina) ObjetoFoto(o.name, o.createdAt == null ? null : DateTime.tryParse(o.createdAt!)),
      ]);
      if (pagina.length < 100) return lista;
    }
  }

  @override
  Future<void> apagar(List<String> arquivos) => _balde.remove([for (final a in arquivos) '$usuarioId/$a']);
}

/// Leva as imagens junto com as linhas de `fotos_shape`, depois da
/// sincronização das tabelas:
///  1. envia as fotos deste aparelho que ainda não subiram;
///  2. baixa as que faltam aqui;
///  3. apaga, na nuvem e no aparelho, as imagens que nenhuma foto usa mais
///     (trocadas ou excluídas). Só as com mais de um dia: uma imagem nova de
///     outro aparelho pode chegar antes da linha dela.
class SincronizadorFotos {
  SincronizadorFotos(this.repo, this.armazem);
  final ShapeRepo repo;
  final ArmazemFotos armazem;

  static const folga = Duration(days: 1);

  BancoAurora get _db => repo.db;

  Future<({int enviadas, int baixadas})> sincronizar({DateTime? agora}) async {
    final emUso = await repo.arquivosEmUso();
    var enviadas = 0, baixadas = 0;

    for (final arquivo in emUso) {
      final local = await repo.arquivoLocal(arquivo);
      final marca = 'shape_enviada:${armazem.conta}:$arquivo';
      if (await local.exists()) {
        if (await _db.preferencia(marca) != null) continue;
        await armazem.enviar(arquivo, await local.readAsBytes());
        await _db.salvarPreferencia(marca, '1');
        enviadas++;
      } else {
        final bytes = await armazem.baixar(arquivo);
        if (bytes == null) continue;
        await local.parent.create(recursive: true);
        final temp = File('${local.path}.parcial');
        await temp.writeAsBytes(bytes, flush: true);
        await temp.rename(local.path);
        await _db.salvarPreferencia(marca, '1');
        baixadas++;
      }
    }

    final limite = (agora ?? DateTime.now()).subtract(folga);
    final sobras = [
      for (final o in await armazem.listar())
        if (!emUso.contains(o.nome) && o.criadoEm != null && o.criadoEm!.isBefore(limite)) o.nome,
    ];
    if (sobras.isNotEmpty) await armazem.apagar(sobras);
    await _limparLocais(emUso, limite);
    if (enviadas + baixadas > 0) _db.notifyUpdates({TableUpdate.onTable(_db.fotosShape)});
    return (enviadas: enviadas, baixadas: baixadas);
  }

  Future<void> _limparLocais(Set<String> emUso, DateTime limite) async {
    final pasta = (await repo.arquivoLocal('x')).parent;
    if (!await pasta.exists()) return;
    await for (final f in pasta.list()) {
      final nome = f.uri.pathSegments.last;
      if (f is! File || emUso.contains(nome)) continue;
      try {
        if ((await f.lastModified()).isBefore(limite)) {
          await f.delete();
          await (_db.delete(_db.preferencias)..where((p) => p.chave.like('shape_enviada:%:$nome'))).go();
        }
      } catch (e) {
        debugPrint('Shape: não limpei $nome: $e');
      }
    }
  }
}
