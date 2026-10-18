import 'dart:io';

import 'package:aurora/data/banco.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('abre banco com fotos_shape já criada mas versão voltada para 9', () async {
    // Caso real da 1.3.0: o app de desenvolvimento criou a tabela e o índice,
    // depois a 1.2.0 abriu o mesmo banco e voltou user_version para 9.
    final pasta = await Directory.systemTemp.createTemp('aurora_migracao');
    final arquivo = File('${pasta.path}/banco.sqlite');
    try {
      final novo = BancoAurora(NativeDatabase(arquivo));
      await novo.preferencia('tema');
      await novo.customStatement('PRAGMA user_version = 9');
      await novo.close();

      final reaberto = BancoAurora(NativeDatabase(arquivo));
      await reaberto.preferencia('tema');
      final versao = await reaberto.customSelect('PRAGMA user_version').getSingle();
      expect(versao.read<int>('user_version'), reaberto.schemaVersion);
      await reaberto.close();
    } finally {
      await pasta.delete(recursive: true);
    }
  });
}
