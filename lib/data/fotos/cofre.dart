import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../banco.dart';
import 'armazem.dart';
import 'compressao.dart';

/// Onde a pessoa quer as fotos. Vale para ESTE aparelho (fica nas
/// preferências, que não sincronizam). Padrão: só no aparelho, porque são
/// fotos sensíveis.
enum ModoFotos {
  aparelho('Só neste aparelho'),
  nuvem('Sincronizar com a nuvem');

  const ModoFotos(this.rotulo);
  final String rotulo;
}

/// O que o cofre precisa saber de uma foto (de qualquer tabela).
typedef RefFoto = ({String id, String? hash, bool naNuvem});

/// Pasta base das fotos no aparelho (fora de Documentos, junto dos dados do app).
Future<Directory> pastaFotosPadrao() async => getApplicationSupportDirectory();

/// Fotos do usuário no aparelho e a ponte com a nuvem. Regras:
///  * No aparelho só fica a versão comprimida (WebP), nunca a original:
///    `<base>/fotos/<id>.webp` e `<base>/miniaturas/<id>.webp`.
///  * Cópia local atual = o arquivo existe E o hash guardado nas preferências
///    (`foto_local:` / `mini_local:` + id) é o da linha. Só baixa de novo se a
///    foto mudou (hash novo) ou o arquivo sumiu.
///  * Envios e exclusões na nuvem que falharem (sem internet) ficam pendentes
///    (`fotos_enviar:` / `fotos_apagar:` + id) e saem na próxima sincronização.
class CofreFotos {
  CofreFotos(this.db, {Future<Directory> Function()? pasta, ArmazemFotos? Function()? armazem})
    : _pasta = pasta ?? pastaFotosPadrao,
      _armazem = armazem ?? armazemDaConta;

  final BancoAurora db;
  final Future<Directory> Function() _pasta;
  final ArmazemFotos? Function() _armazem;

  /// Armazém da conta conectada (nulo sem login).
  ArmazemFotos? get armazem => _armazem();

  static const _chaveModo = 'fotos_modo';
  static const _local = 'foto_local:', _miniLocal = 'mini_local:';
  static const _enviar = 'fotos_enviar:', _apagar = 'fotos_apagar:';

  // ---------- modo ----------

  Future<ModoFotos> modo() async =>
      await db.preferencia(_chaveModo) == ModoFotos.nuvem.name ? ModoFotos.nuvem : ModoFotos.aparelho;

  Future<void> definirModo(ModoFotos modo) => db.salvarPreferencia(_chaveModo, modo.name);

  // ---------- arquivos no aparelho ----------

  Future<File> arquivo(String id, {bool miniatura = false}) async =>
      File('${(await _pasta()).path}/${miniatura ? 'miniaturas' : 'fotos'}/$id.webp');

  /// Grava a foto comprimida (inteira e miniatura) como cópia atual.
  Future<void> guardar(String id, FotoComprimida foto) async {
    await _gravar(await arquivo(id), foto.completa);
    await _gravar(await arquivo(id, miniatura: true), foto.miniatura);
    await db.salvarPreferencia('$_local$id', foto.hash);
    await db.salvarPreferencia('$_miniLocal$id', foto.hash);
  }

  /// Bytes da foto inteira deste aparelho, se for a versão atual.
  Future<FotoComprimida?> lerLocal(RefFoto ref) async {
    final inteira = await local(ref);
    final mini = await local(ref, miniatura: true);
    if (inteira == null || mini == null || ref.hash == null) return null;
    return FotoComprimida(await inteira.readAsBytes(), await mini.readAsBytes(), ref.hash!);
  }

  /// A cópia local, se existe e é a atual.
  Future<File?> local(RefFoto ref, {bool miniatura = false}) async {
    if (ref.hash == null) return null;
    final f = await arquivo(ref.id, miniatura: miniatura);
    if (!await f.exists()) return null;
    return await db.preferencia('${miniatura ? _miniLocal : _local}${ref.id}') == ref.hash ? f : null;
  }

  final _baixando = <String, Future<File?>>{};

  /// A imagem para mostrar: a cópia local atual ou, se a foto está na nuvem,
  /// baixada agora (e guardada). Nulo se não dá: foto só em outro aparelho,
  /// sem login ou sem internet.
  Future<File?> obter(RefFoto ref, {bool miniatura = false}) async {
    final atual = await local(ref, miniatura: miniatura);
    if (atual != null || !ref.naNuvem) return atual;
    final chave = '${ref.id}|${ref.hash}|$miniatura';
    // Chaves {} de propósito: devolver o remove() faria a tarefa esperar a si mesma.
    return _baixando[chave] ??= _baixar(ref, miniatura).whenComplete(() {
      _baixando.remove(chave);
    });
  }

  Future<File?> _baixar(RefFoto ref, bool miniatura) async {
    final armazem = this.armazem;
    if (armazem == null) return null;
    try {
      final bytes = await armazem.baixar(ref.id, miniatura: miniatura);
      if (bytes == null) return null;
      final f = await arquivo(ref.id, miniatura: miniatura);
      await _gravar(f, bytes);
      await db.salvarPreferencia('${miniatura ? _miniLocal : _local}${ref.id}', ref.hash!);
      return f;
    } catch (e) {
      debugPrint('Fotos: não baixei ${ref.id}: $e');
      return null;
    }
  }

  Future<void> apagarLocal(String id) async {
    for (final mini in [false, true]) {
      try {
        final f = await arquivo(id, miniatura: mini);
        if (await f.exists()) await f.delete();
      } catch (e) {
        debugPrint('Fotos: não apaguei $id: $e');
      }
    }
    await (db.delete(db.preferencias)
          ..where((p) => p.chave.equals('$_local$id') | p.chave.equals('$_miniLocal$id')))
        .go();
  }

  // ---------- nuvem ----------

  /// Envia agora (sem login ou sem internet, lança o erro).
  Future<void> enviarAgora(RefFoto ref) async {
    final armazem = this.armazem;
    if (armazem == null) throw StateError('Entre na sua conta para enviar fotos para a nuvem.');
    final foto = await lerLocal(ref);
    if (foto == null) throw StateError('A foto não está neste aparelho.');
    await armazem.enviar(ref.id, completa: foto.completa, miniatura: foto.miniatura);
    await _tirar('$_enviar${ref.id}');
  }

  /// Apaga da nuvem agora ou, se não der, na próxima sincronização.
  Future<void> apagarDaNuvem(String id) async {
    await _tirar('$_enviar$id');
    final armazem = this.armazem;
    try {
      if (armazem == null) throw StateError('sem login');
      await armazem.apagar([id]);
      await _tirar('$_apagar$id');
    } catch (_) {
      await db.salvarPreferencia('$_apagar$id', '1');
    }
  }

  Future<void> marcarParaEnviar(String id) async {
    await _tirar('$_apagar$id');
    await db.salvarPreferencia('$_enviar$id', '1');
  }

  Future<void> esquecerEnvio(String id) => _tirar('$_enviar$id');

  Future<List<String>> pendentesEnviar() => _comPrefixo(_enviar);
  Future<List<String>> pendentesApagar() => _comPrefixo(_apagar);
  Future<void> apagamentoFeito(String id) => _tirar('$_apagar$id');

  // ---------- espaço e cache ----------

  /// Bytes que as fotos ocupam neste aparelho (inteiras e miniaturas).
  Future<int> espacoOcupado() async {
    var total = 0;
    for (final sub in ['fotos', 'miniaturas']) {
      final pasta = Directory('${(await _pasta()).path}/$sub');
      if (!await pasta.exists()) continue;
      await for (final f in pasta.list()) {
        if (f is File) total += await f.length();
      }
    }
    return total;
  }

  /// Apaga do aparelho só as cópias de fotos que estão na nuvem (baixam de
  /// novo quando abertas). Fotos que só existem aqui nunca são tocadas.
  /// Devolve quantos bytes liberou.
  Future<int> limparCache(Iterable<RefFoto> fotos) async {
    var liberado = 0;
    final pendentes = (await pendentesEnviar()).toSet();
    for (final ref in fotos) {
      if (!ref.naNuvem || pendentes.contains(ref.id)) continue;
      for (final mini in [false, true]) {
        final f = await arquivo(ref.id, miniatura: mini);
        if (await f.exists()) liberado += await f.length();
      }
      await apagarLocal(ref.id);
    }
    return liberado;
  }

  /// Apaga arquivos de fotos que não existem mais (apagadas em outro aparelho).
  Future<void> limparSobras(Set<String> idsEmUso) async {
    for (final sub in ['fotos', 'miniaturas']) {
      final pasta = Directory('${(await _pasta()).path}/$sub');
      if (!await pasta.exists()) continue;
      await for (final f in pasta.list()) {
        final nome = f.uri.pathSegments.last;
        if (f is! File || !nome.endsWith('.webp')) continue;
        final id = nome.substring(0, nome.length - 5);
        if (!idsEmUso.contains(id)) await apagarLocal(id);
      }
    }
  }

  // ---------- apoio ----------

  Future<void> _gravar(File destino, Uint8List bytes) async {
    await destino.parent.create(recursive: true);
    final temp = File('${destino.path}.parcial');
    await temp.writeAsBytes(bytes, flush: true);
    if (await destino.exists()) await destino.delete();
    await temp.rename(destino.path);
  }

  Future<void> _tirar(String chave) => (db.delete(db.preferencias)..where((p) => p.chave.equals(chave))).go();

  Future<List<String>> _comPrefixo(String prefixo) async {
    final linhas = await (db.select(db.preferencias)..where((p) => p.chave.like('$prefixo%'))).get();
    return [for (final l in linhas) l.chave.substring(prefixo.length)];
  }
}

/// "3,2 MB", "840 KB".
String tamanhoLegivel(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1).replaceAll('.', ',')} MB';
}
