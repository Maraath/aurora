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
}
