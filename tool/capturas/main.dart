import 'dart:io';

import 'package:aurora/app.dart';
import 'package:aurora/core/efeitos.dart';
import 'package:aurora/core/relogio.dart';
import 'package:aurora/data/banco.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'demonstracao.dart';

/// App com os dados de demonstração, para as capturas do README:
///   flutter run -d windows -t tool/capturas/main.dart --dart-define=AURORA_BANCO=aurora_capturas
/// Sem nuvem, sincronização, avisos nem automações: nada sai do banco separado.
/// Depois, apagar `Documentos\aurora_capturas.sqlite`.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const banco = String.fromEnvironment('AURORA_BANCO');
  if (banco.isEmpty || banco == 'aurora') {
    throw StateError('Use um banco separado: --dart-define=AURORA_BANCO=aurora_capturas');
  }
  Intl.defaultLocale = 'pt_BR';
  await initializeDateFormatting('pt_BR');
  iniciarRelogio(await fusoDoAparelho());

  final db = BancoAurora();
  await semearDemonstracao(db);
  // Painel de Finanças da foto (ex.: esconder os cartões de cima para os gráficos
  // caberem na janela): `Documentos\aurora_capturas_painel.json`, no formato da
  // preferência `financas_painel`. Sem o arquivo, volta ao painel padrão.
  final painel = File('${(await getApplicationDocumentsDirectory()).path}/aurora_capturas_painel.json');
  if (painel.existsSync()) {
    await db.salvarPreferencia('financas_painel', painel.readAsStringSync());
  } else {
    await (db.delete(db.preferencias)..where((x) => x.chave.equals('financas_painel'))).go();
  }
  final tema = await db.preferencia('tema');
  await Efeitos.iniciar(db);
  runApp(AuroraApp(db: db, escuro: ValueNotifier(tema != 'claro')));
}
