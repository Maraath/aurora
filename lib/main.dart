import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app.dart';
import 'core/notificacoes.dart';
import 'core/relogio.dart';
import 'data/banco.dart';
import 'data/exemplo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'pt_BR';
  await initializeDateFormatting('pt_BR');
  iniciarRelogio();

  final db = BancoAurora();
  await semearExemplo(db);
  final tema = await db.preferencia('tema');

  runApp(AuroraApp(db: db, escuro: ValueNotifier(tema != 'claro')));

  // Depois da primeira tela: pede permissão e agenda os avisos.
  unawaited(Notificador.instancia.iniciar(db));
}
