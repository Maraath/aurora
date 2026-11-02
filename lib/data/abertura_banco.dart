import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as caminhos;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/common.dart' show CommonDatabase;
import 'package:sqlite3/sqlite3.dart';

import '../core/cofre_seguro.dart';

/// Banco do app, cifrado (SQLite3 Multiple Ciphers, `hooks` no pubspec). A chave é
/// aleatória e fica no cofre do sistema, não no arquivo: uma cópia do banco (backup,
/// OneDrive, disco levado embora) não abre em outro lugar. O programa rodando na
/// conta da pessoa ainda consegue abrir: isto protege a cópia, não um vírus aberto.
QueryExecutor abrirBancoDoApp(String nome) => LazyDatabase(() async {
      final pasta = await getApplicationDocumentsDirectory();
      final caminho = caminhos.join(pasta.path, '$nome.sqlite');
      try {
        return _conectar(nome, await prepararBanco(caminho, CofreSistema()));
      } on CofreIndisponivel catch (e) {
        // O arquivo fica intacto; nesta abertura o app segue só com a nuvem.
        debugPrint('Banco: $e');
        return NativeDatabase.memory();
      }
    });

/// Fora do [abrirBancoDoApp]: a função que abre o banco vai para outro isolate e
/// não pode levar junto nada além da chave.
QueryExecutor _conectar(String nome, String? chave) => driftDatabase(
      name: nome,
      native: DriftNativeOptions(setup: chave == null ? null : comChave(chave)),
    );

/// Primeira coisa ao abrir o banco. Sem capturar nada além da chave: vai para outro isolate.
void Function(CommonDatabase) comChave(String chave) => (db) => db.execute(pragmaChave(chave));

/// [chave] tem só números e letras de a a f: não há como quebrar as aspas.
String pragmaChave(String chave) => "PRAGMA key = '$chave'";

/// O cofre não respondeu e o banco já está cifrado: não dá para abrir agora.
class CofreIndisponivel implements Exception {
  const CofreIndisponivel(this.causa);
  final Object causa;
  @override
  String toString() => 'cofre indisponível ($causa)';
}

const _nomeNoCofre = 'aurora_banco_chave';

/// Deixa o banco em [caminho] pronto e devolve a chave (nula = sem cifra por agora).
/// Nunca apaga dados: o que não dá para abrir é posto de lado, e o banco em texto
/// aberto só deixa de existir depois de conferida a cópia cifrada.
Future<String?> prepararBanco(String caminho, CofreTexto cofre) async {
  final arquivo = File(caminho);
  final copia = File('$caminho.antes-da-cifra');
  String? chave;
  try {
    chave = await cofre.ler(_nomeNoCofre);
  } catch (e) {
    if (await _estaCifrado(arquivo)) throw CofreIndisponivel(e);
    debugPrint('Banco: sem cofre, segue sem cifra por agora ($e)');
    return null;
  }

  // Conversão interrompida: se o banco não abre com a chave, a cópia é a verdadeira.
  if (await copia.exists()) {
    if (chave != null && await _estaCifrado(arquivo) && await _abreComChave(caminho, chave)) {
      await copia.delete();
    } else {
      await copia.rename(caminho);
    }
  }

  if (chave != null && await _estaCifrado(arquivo) && !await _abreComChave(caminho, chave)) chave = null;
  if (chave == null) {
    // Banco cifrado sem a chave certa (cofre perdido, senha do Windows trocada à
    // força): não abre nunca mais, mas fica guardado. A conta traz os dados da nuvem.
    if (await _estaCifrado(arquivo)) {
      final parado = '$caminho.sem-chave-${DateTime.now().millisecondsSinceEpoch}';
      debugPrint('Banco: sem a chave; guardado em $parado');
      await arquivo.rename(parado);
    }
    chave = _novaChave();
    try {
      await cofre.gravar(_nomeNoCofre, chave);
      if (await cofre.ler(_nomeNoCofre) != chave) throw StateError('o cofre não guardou a chave');
    } catch (e) {
      debugPrint('Banco: não guardei a chave, segue sem cifra por agora ($e)');
      return null;
    }
  }

  if (await _emTextoAberto(arquivo)) {
    await arquivo.copy(copia.path);
    final destino = caminho, senha = chave;
    final deuCerto = await Isolate.run(() => _cifrar(destino, senha));
    if (!deuCerto) {
      debugPrint('Banco: a cifra falhou; voltei ao original');
      await copia.rename(caminho);
      return null;
    }
    await copia.delete();
  }
  return chave;
}

String _novaChave() {
  final sorteio = Random.secure();
  return List.generate(32, (_) => sorteio.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
}

/// Cabeçalho de todo arquivo SQLite sem cifra.
const _assinatura = 'SQLite format 3';

Future<List<int>> _inicio(File arquivo) async {
  if (!await arquivo.exists()) return const [];
  final leitor = await arquivo.open();
  try {
    return await leitor.read(_assinatura.length);
  } finally {
    await leitor.close();
  }
}

Future<bool> _emTextoAberto(File arquivo) async => String.fromCharCodes(await _inicio(arquivo)) == _assinatura;

Future<bool> _estaCifrado(File arquivo) async {
  final inicio = await _inicio(arquivo);
  return inicio.isNotEmpty && String.fromCharCodes(inicio) != _assinatura;
}

Future<bool> _abreComChave(String caminho, String chave) => Isolate.run(() => _confere(caminho, chave));

bool _confere(String caminho, String chave) {
  try {
    final db = sqlite3.open(caminho);
    try {
      db.execute(pragmaChave(chave));
      return db.select('PRAGMA integrity_check').first.columnAt(0) == 'ok';
    } finally {
      db.close();
    }
  } catch (_) {
    return false;
  }
}

/// Cifra no próprio arquivo e confere que abre, com as mesmas tabelas.
bool _cifrar(String caminho, String chave) {
  try {
    final db = sqlite3.open(caminho);
    int tabelas;
    try {
      db.execute('PRAGMA journal_mode = DELETE');
      tabelas = db.select('SELECT count(*) FROM sqlite_master').first.columnAt(0) as int;
      db.execute("PRAGMA rekey = '$chave'");
    } finally {
      db.close();
    }
    final conferido = sqlite3.open(caminho);
    try {
      conferido.execute(pragmaChave(chave));
      final depois = conferido.select('SELECT count(*) FROM sqlite_master').first.columnAt(0);
      return depois == tabelas && conferido.select('PRAGMA integrity_check').first.columnAt(0) == 'ok';
    } finally {
      conferido.close();
    }
  } catch (e) {
    debugPrint('Banco: falha ao cifrar ($e)');
    return false;
  }
}
