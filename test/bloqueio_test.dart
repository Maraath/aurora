import 'package:aurora/app.dart';
import 'package:aurora/core/bloqueio.dart';
import 'package:aurora/core/relogio.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/exemplo.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late BancoAurora db;

  setUpAll(() async {
    iniciarRelogio();
    await initializeDateFormatting('pt_BR');
  });

  setUp(() => db = BancoAurora(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('PIN é guardado como hash com sal e conferido', () async {
    final s = ServicoBloqueio(db);
    expect(await s.modo(), ModoBloqueio.nenhum);
    await s.ativarPin('2468');
    expect(await s.modo(), ModoBloqueio.pin);
    // O PIN digitado não fica gravado em lugar nenhum.
    final prefs = await db.select(db.preferencias).get();
    expect(prefs.any((p) => p.valor.contains('2468')), isFalse);
    expect(await s.conferirPin('2468'), isTrue);
    expect(await s.conferirPin('1357'), isFalse);

    // Mesmo PIN, sal novo: o hash muda.
    final antes = await db.preferencia('bloqueio_pin');
    await s.ativarPin('2468');
    expect(await db.preferencia('bloqueio_pin'), isNot(antes));

    await s.desligar();
    expect(await s.modo(), ModoBloqueio.nenhum);
    expect(await s.conferirPin('2468'), isFalse);
  });

  test('PIN precisa ter de 4 a 6 números', () {
    expect(ServicoBloqueio.pinValido('123'), isFalse);
    expect(ServicoBloqueio.pinValido('1234'), isTrue);
    expect(ServicoBloqueio.pinValido('123456'), isTrue);
    expect(ServicoBloqueio.pinValido('1234567'), isFalse);
    expect(ServicoBloqueio.pinValido('12a4'), isFalse);
    expect(() => ServicoBloqueio(db).ativarPin('12'), throwsArgumentError);
  });

  testWidgets('com PIN, o app abre bloqueado e só libera com o PIN certo', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      await semearExemplo(db);
      await ServicoBloqueio(db).ativarPin('2468');
    });
    await tester.pumpWidget(AuroraApp(db: db, escuro: ValueNotifier(true)));
    Future<void> assentar() async {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 80)));
      await tester.pump(const Duration(milliseconds: 300));
    }

    await assentar();
    expect(find.text('Aurora bloqueado'), findsOneWidget);

    Future<void> digitar(String pin) async {
      for (final d in pin.split('')) {
        await tester.tap(find.text(d));
        await tester.pump();
      }
      await tester.tap(find.bySemanticsLabel('Confirmar'));
      await assentar();
    }

    await digitar('1111');
    expect(find.text('PIN incorreto.'), findsOneWidget);
    expect(find.text('Aurora bloqueado'), findsOneWidget);

    await digitar('2468');
    expect(find.text('Aurora bloqueado'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
