import 'dart:io';

import 'package:aurora/core/cofre_seguro.dart';
import 'package:aurora/data/abertura_banco.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CofreFalso implements CofreTexto {
  final dados = <String, String>{};
  var falhaAoLer = false;
  var falhaAoGravar = false;
  var naoGuarda = false;

  @override
  Future<String?> ler(String chave) async {
    if (falhaAoLer) throw StateError('cofre fora do ar');
    return dados[chave];
  }

  @override
  Future<void> gravar(String chave, String valor) async {
    if (falhaAoGravar) throw StateError('cofre fora do ar');
    if (!naoGuarda) dados[chave] = valor;
  }

  @override
  Future<void> apagar(String chave) async => dados.remove(chave);
}

void main() {
  late Directory pasta;
  late String caminho;
  late CofreFalso cofre;

  setUp(() async {
    pasta = await Directory.systemTemp.createTemp('aurora_cifra');
    caminho = '${pasta.path}/aurora.sqlite';
    cofre = CofreFalso();
  });
  tearDown(() => pasta.delete(recursive: true));

  void bancoAberto() {
    final db = sqlite3.open(caminho);
    db.execute("CREATE TABLE notas (texto TEXT); INSERT INTO notas VALUES ('segredo do dono')");
    db.close();
  }

  String lerNota(String chave) {
    final db = sqlite3.open(caminho);
    try {
      db.execute(pragmaChave(chave));
      return db.select('SELECT texto FROM notas').first.columnAt(0) as String;
    } finally {
      db.close();
    }
  }

  bool cifrado() => !String.fromCharCodes(File(caminho).readAsBytesSync().take(15)).startsWith('SQLite format 3');
  bool temTexto() => String.fromCharCodes(File(caminho).readAsBytesSync()).contains('segredo do dono');

  test('banco em texto aberto é cifrado sem perder dados, e a cópia some', () async {
    bancoAberto();
    expect(temTexto(), isTrue);

    final chave = (await prepararBanco(caminho, cofre))!;

    expect(cifrado(), isTrue);
    expect(temTexto(), isFalse); // o texto não aparece mais no arquivo
    expect(lerNota(chave), 'segredo do dono');
    expect(File('$caminho.antes-da-cifra').existsSync(), isFalse);

    expect(await prepararBanco(caminho, cofre), chave); // abrir de novo não muda nada
    expect(lerNota(chave), 'segredo do dono');
  });

  test('sem a chave certa, o arquivo não abre', () async {
    bancoAberto();
    await prepararBanco(caminho, cofre);
    expect(() => lerNota('00'), throwsA(isA<SqliteException>()));
    final db = sqlite3.open(caminho);
    expect(() => db.select('SELECT texto FROM notas'), throwsA(isA<SqliteException>()));
    db.close();
  });

  test('banco novo nasce cifrado', () async {
    final chave = (await prepararBanco(caminho, cofre))!;
    final db = sqlite3.open(caminho);
    db.execute(pragmaChave(chave));
    db.execute("CREATE TABLE notas (texto TEXT); INSERT INTO notas VALUES ('novo')");
    db.close();
    expect(cifrado(), isTrue);
    expect(await prepararBanco(caminho, cofre), chave);
  });

  test('chave perdida: guarda o arquivo de lado e começa do zero', () async {
    bancoAberto();
    await prepararBanco(caminho, cofre);
    cofre.dados.clear();

    final nova = await prepararBanco(caminho, cofre);

    expect(nova, isNotNull);
    expect(File(caminho).existsSync(), isFalse);
    final guardados = pasta.listSync().where((a) => a.path.contains('.sem-chave-'));
    expect(guardados, hasLength(1));
  });

  test('conversão interrompida: a cópia original volta e a conversão termina', () async {
    bancoAberto();
    await File(caminho).copy('$caminho.antes-da-cifra');
    await File(caminho).writeAsBytes(List.filled(4096, 7)); // cifra pela metade

    final chave = (await prepararBanco(caminho, cofre))!;

    expect(lerNota(chave), 'segredo do dono');
    expect(cifrado(), isTrue);
    expect(File('$caminho.antes-da-cifra').existsSync(), isFalse);
  });

  test('cofre fora do ar com banco aberto: segue sem cifra, sem mexer em nada', () async {
    bancoAberto();
    cofre.falhaAoLer = true;
    expect(await prepararBanco(caminho, cofre), isNull);
    expect(cifrado(), isFalse);
  });

  test('cofre que não guarda: a chave não é usada (senão o banco se perderia)', () async {
    bancoAberto();
    cofre.naoGuarda = true;
    expect(await prepararBanco(caminho, cofre), isNull);
    expect(cifrado(), isFalse);
    cofre
      ..naoGuarda = false
      ..falhaAoGravar = true;
    expect(await prepararBanco(caminho, cofre), isNull);
    expect(cifrado(), isFalse);
  });

  test('cofre fora do ar com banco cifrado: avisa e não toca no arquivo', () async {
    bancoAberto();
    final chave = (await prepararBanco(caminho, cofre))!;
    cofre.falhaAoLer = true;
    await expectLater(prepararBanco(caminho, cofre), throwsA(isA<CofreIndisponivel>()));
    expect(lerNota(chave), 'segredo do dono');
  });

  group('sessão no cofre', () {
    const chave = 'sb-teste-auth-token';
    SharedPreferencesLocalStorage antiga() => SharedPreferencesLocalStorage(persistSessionKey: chave);

    test('quem já estava conectado continua, e a sessão sai das preferências', () async {
      SharedPreferences.setMockInitialValues({chave: '{"sessao":"antiga"}'});
      final s = SessaoSegura(cofre, antiga());
      await s.initialize();

      expect(await s.hasAccessToken(), isTrue);
      expect(await s.accessToken(), '{"sessao":"antiga"}');
      expect((await SharedPreferences.getInstance()).containsKey(chave), isFalse);
      expect(cofre.dados.values, contains('{"sessao":"antiga"}'));

      final depois = SessaoSegura(cofre, antiga());
      await depois.initialize();
      expect(await depois.accessToken(), '{"sessao":"antiga"}');
    });

    test('gravar e sair usam o cofre', () async {
      SharedPreferences.setMockInitialValues({});
      final s = SessaoSegura(cofre, antiga());
      await s.initialize();
      expect(await s.hasAccessToken(), isFalse);

      await s.persistSession('nova');
      expect(cofre.dados.values, contains('nova'));
      expect((await SharedPreferences.getInstance()).containsKey(chave), isFalse);

      await s.removePersistedSession();
      expect(cofre.dados, isEmpty);
      expect(await s.hasAccessToken(), isFalse);
    });

    test('cofre com defeito não desconecta: a sessão fica onde estava', () async {
      SharedPreferences.setMockInitialValues({chave: 'sessao'});
      cofre.falhaAoGravar = true;
      final s = SessaoSegura(cofre, antiga());
      await s.initialize();

      expect(await s.accessToken(), 'sessao');
      expect((await SharedPreferences.getInstance()).getString(chave), 'sessao');
      await s.persistSession('renovada');
      expect((await SharedPreferences.getInstance()).getString(chave), 'renovada');

      // Cofre voltou: a sessão mais nova sobe para ele.
      cofre.falhaAoGravar = false;
      final depois = SessaoSegura(cofre, antiga());
      await depois.initialize();
      expect(await depois.accessToken(), 'renovada');
      expect((await SharedPreferences.getInstance()).containsKey(chave), isFalse);
    });

    test('nome da sessão antiga é o que o Supabase usa', () {
      expect(chaveSessaoAntiga('https://abc.supabase.co'), 'sb-abc-auth-token');
    });
  });
}
