import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as rede;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/nuvem.dart';
import '../banco.dart';
import 'cofre.dart';
import 'disco_audios_stub.dart' if (dart.library.js_interop) 'disco_audios_web.dart';

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
    // package:http, que também funciona na web (lá não há HttpClient).
    final resposta = await rede.get(Uri.parse(url)).timeout(const Duration(seconds: 90));
    if (resposta.statusCode == 404 || resposta.statusCode == 400) return null;
    if (resposta.statusCode != 200) throw StateError('Erro ${resposta.statusCode} ao baixar o áudio');
    return resposta.bodyBytes;
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

/// Onde os áudios ficam neste aparelho, por nome (`<id>.<ext>`): arquivos no
/// app instalado, IndexedDB na web (que não tem pasta).
abstract class DiscoAudios {
  Future<void> gravar(String nome, Uint8List bytes);

  /// Nulo se não existe.
  Future<Uint8List?> ler(String nome);
  Future<bool> existe(String nome);
  Future<void> apagar(String nome);

  /// Nomes de todos os guardados.
  Future<List<String>> nomes();

  /// Arquivo para tocar direto dele, sem carregar na memória (nulo na web).
  Future<String?> caminho(String nome);
}

/// `<suporte>/audios/<id>.<ext>`.
class DiscoAudiosArquivos implements DiscoAudios {
  DiscoAudiosArquivos(this._pasta);
  final Future<Directory> Function() _pasta;

  Future<Directory> get _audios async => Directory('${(await _pasta()).path}/audios');

  Future<File> _arquivo(String nome) async => File('${(await _audios).path}/$nome');

  @override
  Future<void> gravar(String nome, Uint8List bytes) async {
    final destino = await _arquivo(nome);
    await destino.parent.create(recursive: true);
    final temp = File('${destino.path}.parcial');
    await temp.writeAsBytes(bytes, flush: true);
    if (await destino.exists()) await destino.delete();
    await temp.rename(destino.path);
  }

  @override
  Future<Uint8List?> ler(String nome) async {
    final f = await _arquivo(nome);
    return await f.exists() ? f.readAsBytes() : null;
  }

  @override
  Future<bool> existe(String nome) async => (await _arquivo(nome)).exists();

  @override
  Future<void> apagar(String nome) async {
    final f = await _arquivo(nome);
    if (await f.exists()) await f.delete();
  }

  @override
  Future<List<String>> nomes() async {
    final pasta = await _audios;
    if (!await pasta.exists()) return [];
    return [
      await for (final f in pasta.list())
        if (f is File && !f.path.endsWith('.parcial')) f.uri.pathSegments.last,
    ];
  }

  @override
  Future<String?> caminho(String nome) async => (await _arquivo(nome)).path;
}

/// IndexedDB do navegador (`window.auroraAudios` no web/index.html). Fica até a
/// pessoa limpar os dados do site, como o próprio banco do app na web.
class DiscoAudiosNavegador implements DiscoAudios {
  @override
  Future<void> gravar(String nome, Uint8List bytes) => gravarNoNavegador(nome, bytes);

  @override
  Future<Uint8List?> ler(String nome) => lerDoNavegador(nome);

  @override
  Future<bool> existe(String nome) => existeNoNavegador(nome);

  @override
  Future<void> apagar(String nome) => apagarDoNavegador(nome);

  @override
  Future<List<String>> nomes() => nomesNoNavegador();

  @override
  Future<String?> caminho(String nome) async => null;
}

/// Áudios das notas no aparelho e a ponte com a nuvem, com as mesmas regras das
/// fotos (ver CofreFotos): o modo é o mesmo ("Onde guardar", `fotos_modo`), a
/// cópia local vale se o hash nas preferências (`audio_local:`) é o da linha, e
/// envios e exclusões sem internet ficam pendentes (`audios_enviar:` /
/// `audios_apagar:`, com o formato no valor) até a próxima sincronização.
class CofreAudios {
  CofreAudios(this.db, {Future<Directory> Function()? pasta, DiscoAudios? disco, ArmazemAudios? Function()? armazem})
    : disco = disco ?? (kIsWeb ? DiscoAudiosNavegador() : DiscoAudiosArquivos(pasta ?? pastaFotosPadrao)),
      _armazem = armazem ?? armazemAudiosDaConta;

  final BancoAurora db;
  final DiscoAudios disco;
  final ArmazemAudios? Function() _armazem;

  ArmazemAudios? get armazem => _armazem();

  static const _local = 'audio_local:', _enviar = 'audios_enviar:', _apagar = 'audios_apagar:';

  static String nome(String id, String formato) => '$id.${extensaoAudio(formato)}';

  /// Grava o áudio como cópia atual e devolve o hash (SHA-256).
  Future<String> guardar(String id, String formato, Uint8List bytes) async {
    final hash = sha256.convert(bytes).toString();
    await disco.gravar(nome(id, formato), bytes);
    await db.salvarPreferencia('$_local$id', hash);
    return hash;
  }

  /// Se a cópia deste aparelho existe e é a atual.
  Future<bool> temLocal(RefAudio ref) async {
    if (ref.hash == null) return false;
    if (!await disco.existe(nome(ref.id, ref.formato))) return false;
    return await db.preferencia('$_local${ref.id}') == ref.hash;
  }

  final _baixando = <String, Future<bool>>{};

  /// Deixa o áudio pronto para tocar: a cópia local ou, se está na nuvem,
  /// baixado agora. Falso se não deu (outro aparelho, sem conta, sem internet).
  Future<bool> obter(RefAudio ref) async {
    if (await temLocal(ref)) return true;
    if (!ref.naNuvem) return false;
    final chave = '${ref.id}|${ref.hash}';
    return _baixando[chave] ??= _baixar(ref).whenComplete(() {
      _baixando.remove(chave);
    });
  }

  /// Os bytes (baixando se preciso), para transcrever ou tocar na web.
  Future<Uint8List?> ler(RefAudio ref) async => await obter(ref) ? disco.ler(nome(ref.id, ref.formato)) : null;

  /// O arquivo para tocar (nulo na web: toca de [ler]). Chamar depois de [obter].
  Future<String?> caminho(RefAudio ref) => disco.caminho(nome(ref.id, ref.formato));

  Future<bool> _baixar(RefAudio ref) async {
    final armazem = this.armazem;
    if (armazem == null) return false;
    try {
      final bytes = await armazem.baixar(ref.id, ref.formato);
      if (bytes == null) return false;
      await disco.gravar(nome(ref.id, ref.formato), bytes);
      await db.salvarPreferencia('$_local${ref.id}', ref.hash!);
      return true;
    } catch (e) {
      debugPrint('Áudios: não baixei ${ref.id}: $e');
      return false;
    }
  }

  Future<void> apagarLocal(String id, String formato) async {
    try {
      await disco.apagar(nome(id, formato));
    } catch (e) {
      debugPrint('Áudios: não apaguei $id: $e');
    }
    await _tirar('$_local$id');
  }

  /// Envia agora (sem login ou sem internet, lança o erro).
  Future<void> enviarAgora(RefAudio ref) async {
    final armazem = this.armazem;
    if (armazem == null) throw StateError('Entre na sua conta para enviar áudios para a nuvem.');
    final bytes = await temLocal(ref) ? await disco.ler(nome(ref.id, ref.formato)) : null;
    if (bytes == null) throw StateError('O áudio não está neste aparelho.');
    await armazem.enviar(ref.id, ref.formato, bytes);
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

  Future<List<({String id, String formato})>> pendentesApagar() async => [
    for (final p in await _comPrefixo(_apagar)) (id: p.chave, formato: p.valor),
  ];

  Future<void> apagamentoFeito(String id) => _tirar('$_apagar$id');

  /// Apaga áudios que não existem mais (apagados em outro aparelho).
  Future<void> limparSobras(Set<String> idsEmUso) async {
    for (final nome in await disco.nomes()) {
      final ponto = nome.lastIndexOf('.');
      if (ponto <= 0) continue;
      final id = nome.substring(0, ponto);
      if (!idsEmUso.contains(id)) {
        await disco.apagar(nome);
        await _tirar('$_local$id');
      }
    }
  }

  Future<void> _tirar(String chave) => (db.delete(db.preferencias)..where((p) => p.chave.equals(chave))).go();

  Future<List<({String chave, String valor})>> _comPrefixo(String prefixo) async {
    final linhas = await (db.select(db.preferencias)..where((p) => p.chave.like('$prefixo%'))).get();
    return [for (final l in linhas) (chave: l.chave.substring(prefixo.length), valor: l.valor)];
  }
}
