import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app.dart';
import 'core/notificacoes.dart';
import 'core/nuvem.dart';
import 'core/relogio.dart';
import 'data/alimentacao_repo.dart';
import 'data/banco.dart';
import 'data/exemplo.dart';
import 'data/servico_automacoes.dart';
import 'data/servico_sync.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'pt_BR';
  await initializeDateFormatting('pt_BR');
  iniciarRelogio();
  // As fontes vêm no app: a licença delas entra em Conta › Licenças.
  LicenseRegistry.addLicense(() async* {
    for (final fonte in ['Sora', 'Manrope']) {
      yield LicenseEntryWithLineBreaks([fonte], await rootBundle.loadString('assets/fonts/OFL-$fonte.txt'));
    }
  });
  await iniciarNuvem();

  final db = BancoAurora();
  final tema = await db.preferencia('tema');
  final primeiraVez = await ehPrimeiraVez(db);

  runApp(AuroraApp(db: db, escuro: ValueNotifier(tema != 'claro'), primeiraVez: primeiraVez));

  // Depois da primeira tela: pede permissão e agenda os avisos.
  unawaited(Notificador.instancia.iniciar(db));
  // Com conta conectada, sincroniza ao abrir e a cada mudança.
  unawaited(ServicoSync.instancia.iniciar(db));
  // Briefing e outras rotinas no horário (e as que passaram há pouco).
  unawaited(ServicoAutomacoes.instancia.iniciar(db));
  // Cópias de alimentos da TACO acompanham o catálogo do app.
  unawaited(AlimentacaoRepo(db).atualizarCopiasTaco());
}
