import 'package:aurora/core/atualizacao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final json = {
    'versao': '1.0.1',
    'build': 2,
    'notas': 'Correções.',
    'instalador': 'Aurora-1.0.1-setup.exe',
    'sha256': 'ABC123',
  };

  test('build publicado maior que o atual é atualização', () {
    final a = novaVersao(json, 1)!;
    expect(a.versao, '1.0.1');
    expect(a.instalador, 'Aurora-1.0.1-setup.exe');
    expect(a.sha256, 'abc123');
  });

  test('mesmo build ou menor não é atualização', () {
    expect(novaVersao(json, 2), isNull);
    expect(novaVersao(json, 3), isNull);
  });

  test('endereço do GitHub quando vem no versao.json; sem ele, o balde', () {
    expect(novaVersao(json, 1)!.url, isNull);
    const gh = 'https://github.com/Maraath/aurora/releases/download/v1.0.1/Aurora-1.0.1-setup.exe';
    expect(novaVersao({...json, 'url': gh}, 1)!.url, gh);
    // Só https: qualquer outra coisa cai no balde.
    expect(novaVersao({...json, 'url': 'http://exemplo.test/a.exe'}, 1)!.url, isNull);
    expect(novaVersao({...json, 'url': 'arquivo.exe'}, 1)!.url, isNull);
    final android = {
      'versao': '1.0.2',
      'build': 3,
      'abis': {
        'arm64-v8a': {'instalador': 'Aurora-1.0.2-arm64-v8a.apk', 'sha256': 'AA', 'url': '$gh.apk'},
      },
    };
    expect(novaVersao(android, 2, abis: ['arm64-v8a'])!.url, '$gh.apk');
  });

  group('Android, um APK por arquitetura', () {
    final android = {
      'versao': '1.0.2',
      'build': 3,
      'abis': {
        'arm64-v8a': {'instalador': 'Aurora-1.0.2-arm64-v8a.apk', 'sha256': 'AA'},
        'x86_64': {'instalador': 'Aurora-1.0.2-x86_64.apk', 'sha256': 'BB'},
      },
    };

    test('escolhe a primeira arquitetura do aparelho que foi publicada', () {
      final a = novaVersao(android, 2, abis: ['x86_64', 'x86', 'arm64-v8a'])!;
      expect(a.instalador, 'Aurora-1.0.2-x86_64.apk');
      expect(a.sha256, 'bb');
      expect(novaVersao(android, 2, abis: ['arm64-v8a', 'armeabi-v7a'])!.instalador, 'Aurora-1.0.2-arm64-v8a.apk');
    });

    test('ignora o 1000 × arquitetura somado ao versionCode', () {
      expect(novaVersao(android, 4002, abis: ['x86_64']), isNotNull);
      expect(novaVersao(android, 4003, abis: ['x86_64']), isNull);
    });

    test('sem APK para a arquitetura do aparelho, não oferece', () {
      expect(novaVersao(android, 2, abis: ['armeabi-v7a']), isNull);
    });
  });
}
