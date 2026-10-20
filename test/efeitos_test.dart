import 'package:aurora/core/efeitos.dart';
import 'package:aurora/core/tema.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/ui/vidro.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => Efeitos.estado.value = const EstadoEfeitos());

  test('quadros chegando devagar (mediana acima de 18 ms, abaixo de ~55/s) vão para efeitos leves', () {
    expect(Efeitos.deveSerLeve([16.6, 16.7, 16.7, 33, 50]), isFalse);
    expect(Efeitos.deveSerLeve([16.7, 25, 33.3, 33.3, 50]), isTrue);
    expect(Efeitos.deveSerLeve([]), isFalse);
  });

  test('a escolha manual vale sobre a medição e fica no aparelho', () async {
    final db = BancoAurora(NativeDatabase.memory());
    addTearDown(db.close);
    await db.salvarPreferencia(ModoEfeitos.chaveMedido, 'leves');
    await db.salvarPreferencia(ModoEfeitos.chaveFps, '38');

    await Efeitos.iniciar(db);
    expect(Efeitos.estado.value.leves, isTrue, reason: 'automático segue a medição');
    expect(Efeitos.estado.value.cintilar, isFalse);
    expect(Efeitos.fpsMedido.value, 38);

    await Efeitos.escolher(db, ModoEfeitos.completos);
    expect(Efeitos.estado.value, const EstadoEfeitos(leves: false, cintilar: true));
    expect(await ModoEfeitos.ler(db), ModoEfeitos.completos);

    await Efeitos.escolher(db, ModoEfeitos.leves);
    expect(Efeitos.estado.value.leves, isTrue);
  });

  test('a medição antiga (só do processador) é descartada', () async {
    final db = BancoAurora(NativeDatabase.memory());
    addTearDown(db.close);
    await db.salvarPreferencia('efeitos_medido', 'completos');
    await Efeitos.iniciar(db);
    expect(await db.preferencia(ModoEfeitos.chaveMedido), isNull);
  });

  testWidgets('com efeitos leves o vidro não desfoca', (tester) async {
    Widget tela() => MaterialApp(
          theme: temaAurora(Brightness.dark),
          home: EscopoEfeitos(child: const Vidro(tipo: TipoVidro.barra, child: SizedBox(height: 40))),
        );
    await tester.pumpWidget(tela());
    expect(find.byType(BackdropFilter), findsOneWidget);

    Efeitos.estado.value = const EstadoEfeitos(leves: true, cintilar: false);
    await tester.pump();
    expect(find.byType(BackdropFilter), findsNothing);
  });
}
