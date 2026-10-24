import 'dart:io' hide BytesBuilder;
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/nuvem.dart';
import '../banco.dart';
import 'cofre.dart';

/// Extensão do arquivo pelo tipo do áudio.
String extensaoAudio(String formato) => switch (formato) {
      'audio/mp4' || 'audio/aac' => 'm4a',
      'audio/flac' => 'flac',
      'audio/ogg' => 'ogg',
      'audio/webm' => 'webm',
      _ => 'wav',
    };

/// O que o cofre precisa saber de um áudio.
typedef RefAudio = ({String id, String? hash, bool naNuvem, String formato});

/// Onde os áudios ficam na nuvem (Supabase no app, memória nos testes).
abstract class ArmazemAudios {
  Future<void> enviar(String id, String formato, Uint8List bytes);

  /// Nulo se não existe lá.
  Future<Uint8List?> baixar(String id, String formato);

  Future<void> apagar(List<({String id, String formato})> audios);
}

/// Balde PRIVADO "audios" (supabase/migrations/20261024200000_anotacoes.sql):
/// `{user_id}/audios/{id}.{ext}`, lido só por URL assinada de 1 hora.
class ArmazemAudiosSupabase implements ArmazemAudios {
  ArmazemAudiosSupabase(this.cliente, this.usuarioId);
  final SupabaseClient cliente;
  final String usuarioId;

  StorageFileApi get _balde => cliente.storage.from('audios');

  String caminho(String id, String formato) => '$usuarioId/audios/$id.${extensaoAudio(formato)}';

  @override
  Future<void> enviar(String id, String formato, Uint8List bytes) => _balde.uploadBinary(
        caminho(id, formato),
        bytes,
        fileOptions: FileOptions(contentType: formato, upsert: true, cacheControl: '3600'),
      );

  @override
  Future<Uint8List?> baixar(String id, String formato) async {
    final String url;
    try {
      url = await _balde.createSignedUrl(caminho(id, formato), 3600);
    } on StorageException catch (e) {
      if (e.statusCode == '400' || e.statusCode == '404') return null;
      rethrow;
    }
    final http = HttpClient()..connectionTimeout = const Duration(seconds: 15);
    try {
      final resposta = await (await http.getUrl(Uri.parse(url))).close();
      if (resposta.statusCode == 404 || resposta.statusCode == 400) return null;
      if (resposta.statusCode != 200) throw HttpException('Erro ${resposta.statusCode} ao baixar o áudio');
      final bytes = BytesBuilder(copy: false);
      await for (final parte in resposta) {
        bytes.add(parte);
      }
      return bytes.takeBytes();
    } finally {
      http.close();
    }
  }

  @override
  Future<void> apagar(List<({String id, String formato})> audios) async {
    if (audios.isEmpty) return;
    await _balde.remove([for (final a in audios) caminho(a.id, a.formato)]);
  }
}

ArmazemAudios? armazemAudiosDaConta() {
  final cliente = nuvem;
  final usuario = cliente?.auth.currentUser;
  if (cliente == null || usuario == null) return null;
  return ArmazemAudiosSupabase(cliente, usuario.id);
}

/// Áudios das notas no aparelho e a ponte com a nuvem, com as mesmas regras das
/// fotos (ver CofreFotos): o modo é o mesmo ("Onde guardar", `fotos_modo`), a
/// cópia local vale se o hash nas preferências (`audio_local:`) é o da linha, e
/// envios e exclusões sem internet ficam pendentes (`audios_enviar:` /
/// `audios_apagar:`, com o formato no valor) até a próxima sincronização.
class CofreAudios {
  CofreAudios(this.db, {Future<Directory> Function()? pasta, ArmazemAudios? Function()? armazem})
      : _pasta = pasta ?? pastaFotosPadrao,
        _armazem = armazem ?? armazemAudiosDaConta;

  final BancoAurora db;
  final Future<Directory> Function() _pasta;
  final ArmazemAudios? Function() _armazem;

  ArmazemAudios? get armazem => _armazem();

  static const _local = 'audio_local:', _enviar = 'audios_enviar:', _apagar = 'audios_apagar:';

  Future<File> arquivo(String id, String formato) async =>
      File('${(await _pasta()).path}/audios/$id.${extensaoAudio(formato)}');

  /// Grava o áudio como cópia atual e devolve o hash (SHA-256).
  Future<String> guardar(String id, String formato, Uint8List bytes) async {
    final hash = sha256.convert(bytes).toString();
    await _gravar(await arquivo(id, formato), bytes);
    await db.salvarPreferencia('$_local$id', hash);
    return hash;
  }

  /// A cópia local, se existe e é a atual.
  Future<File?> local(RefAudio ref) async {
    if (ref.hash == null) return null;
    final f = await arquivo(ref.id, ref.formato);
    if (!await f.exists()) return null;
    return await db.preferencia('$_local${ref.id}') == ref.hash ? f : null;
  }

  final _baixando = <String, Future<File?>>{};

  /// O arquivo para tocar: a cópia local ou, se está na nuvem, baixado agora.
  Future<File?> obter(RefAudio ref) async {
    final atual = await local(ref);
    if (atual != null || !ref.naNuvem) return atual;
    final chave = '${ref.id}|${ref.hash}';
    return _baixando[chave] ??= _baixar(ref).whenComplete(() {
      _baixando.remove(chave);
    });
  }

  Future<File?> _baixar(RefAudio ref) async {
    final armazem = this.armazem;
    if (armazem == null) return null;
    try {
      final bytes = await armazem.baixar(ref.id, ref.formato);
      if (bytes == null) return null;
      final f = await arquivo(ref.id, ref.formato);
      await _gravar(f, bytes);
      await db.salvarPreferencia('$_local${ref.id}', ref.hash!);
      return f;
    } catch (e) {
      debugPrint('Áudios: não baixei ${ref.id}: $e');
      return null;
    }
  }

  Future<void> apagarLocal(String id, String formato) async {
    try {
      final f = await arquivo(id, formato);
      if (await f.exists()) await f.delete();
    } catch (e) {
      debugPrint('Áudios: não apaguei $id: $e');
    }
    await _tirar('$_local$id');
  }

  /// Envia agora (sem login ou sem internet, lança o erro).
  Future<void> enviarAgora(RefAudio ref) async {
    final armazem = this.armazem;
    if (armazem == null) throw StateError('Entre na sua conta para enviar áudios para a nuvem.');
    final f = await local(ref);
    if (f == null) throw StateError('O áudio não está neste aparelho.');
    await armazem.enviar(ref.id, ref.formato, await f.readAsBytes());
    await _tirar('$_enviar${ref.id}');
  }

  Future<void> apagarDaNuvem(String id, String formato) async {
    await _tirar('$_enviar$id');
    try {
      final armazem = this.armazem;
      if (armazem == null) throw StateError('sem login');
      await armazem.apagar([(id: id, formato: formato)]);
      await _tirar('$_apagar$id');
    } catch (_) {
      await db.salvarPreferencia('$_apagar$id', formato);
    }
  }

  Future<void> marcarParaEnviar(String id) async {
    await _tirar('$_apagar$id');
    await db.salvarPreferencia('$_enviar$id', '1');
  }

  Future<void> esquecerEnvio(String id) => _tirar('$_enviar$id');

  Future<List<String>> pendentesEnviar() async => [for (final p in await _comPrefixo(_enviar)) p.chave];

  Future<List<({String id, String formato})>> pendentesApagar() async =>
      [for (final p in await _comPrefixo(_apagar)) (id: p.chave, formato: p.valor)];

  Future<void> apagamentoFeito(String id) => _tirar('$_apagar$id');

  /// Bytes que os áudios ocupam neste aparelho.
  Future<int> espacoOcupado() async {
    final pasta = Directory('${(await _pasta()).path}/audios');
    if (!await pasta.exists()) return 0;
    var total = 0;
    await for (final f in pasta.list()) {
      if (f is File) total += await f.length();
    }
    return total;
  }

  /// Apaga arquivos de áudios que não existem mais (apagados em outro aparelho).
  Future<void> limparSobras(Set<String> idsEmUso) async {
    final pasta = Directory('${(await _pasta()).path}/audios');
    if (!await pasta.exists()) return;
    await for (final f in pasta.list()) {
      final nome = f.uri.pathSegments.last;
      final ponto = nome.lastIndexOf('.');
      if (f is! File || ponto <= 0 || nome.endsWith('.parcial')) continue;
      final id = nome.substring(0, ponto);
      if (!idsEmUso.contains(id)) {
        await f.delete();
        await _tirar('$_local$id');
      }
    }
  }

  Future<void> _gravar(File destino, Uint8List bytes) async {
    await destino.parent.create(recursive: true);
    final temp = File('${destino.path}.parcial');
    await temp.writeAsBytes(bytes, flush: true);
    if (await destino.exists()) await destino.delete();
    await temp.rename(destino.path);
  }

  Future<void> _tirar(String chave) => (db.delete(db.preferencias)..where((p) => p.chave.equals(chave))).go();

  Future<List<({String chave, String valor})>> _comPrefixo(String prefixo) async {
    final linhas = await (db.select(db.preferencias)..where((p) => p.chave.like('$prefixo%'))).get();
    return [for (final l in linhas) (chave: l.chave.substring(prefixo.length), valor: l.valor)];
  }
}
