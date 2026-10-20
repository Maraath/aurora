import 'dart:async';
import 'dart:typed_data';

import 'package:aurora/app.dart';
import 'package:aurora/core/relogio.dart';
import 'package:aurora/core/tema.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/exemplo.dart';
import 'package:aurora/data/financas_repo.dart';
import 'package:aurora/data/ia/protocolo.dart';
import 'package:aurora/data/ia/voz.dart';
import 'package:aurora/ui/assistente/assistente_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Microfone de mentira: grava "bytes" e mostra um volume.
class GravadorFalso implements Gravador {
  GravadorFalso({this.deixa = true, this.falhaAoComecar = false});
  final bool deixa;
  final bool falhaAoComecar;
  var gravando = false;
  var cancelado = false;
  final _nivel = StreamController<double>.broadcast();

  @override
  Future<bool> permitido() async => deixa;

  @override
  Future<String> comecar() async {
    if (falhaAoComecar) throw Exception('microfone ocupado');
    gravando = true;
    Timer(const Duration(milliseconds: 50), () {
      if (!_nivel.isClosed) _nivel.add(.7);
    });
    return 'audio/flac';
  }

  @override
  Stream<double> get nivel => _nivel.stream;

  @override
  Future<Uint8List?> parar() async {
    gravando = false;
    return Uint8List.fromList([1, 2, 3]);
  }

  @override
  Future<void> cancelar() async {
    gravando = false;
    cancelado = true;
  }

  @override
  Future<void> fechar() => _nivel.close();
}

void main() {
  const fala = Duration(milliseconds: 700);

  group('ComandoDeVoz', () {
    late GravadorFalso gravador;
    late List<String> entendidos;
    late List<(int, String)> enviados;

    ComandoDeVoz voz({
      Future<String> Function(Uint8List, String)? transcrever,
      bool conectada = true,
      Duration maximo = const Duration(seconds: 60),
    }) =>
        ComandoDeVoz(
          aoEntender: (t) async => entendidos.add(t),
          gravador: () => gravador,
          transcrever: () => !conectada
              ? null
              : (audio, formato) async {
                  enviados.add((audio.length, formato));
                  return transcrever == null ? 'gastei 35 no mercado' : transcrever(audio, formato);
                },
          maximo: maximo,
        );

    setUp(() {
      gravador = GravadorFalso();
      entendidos = [];
      enviados = [];
    });

    test('toca, fala, toca de novo: transcreve e entrega o texto', () async {
      final v = voz();
      await v.alternar();
      expect(v.fase, FaseVoz.ouvindo);
      expect(gravador.gravando, isTrue);
      await Future<void>.delayed(fala);
      expect(v.nivel, .7, reason: 'o volume chega na tela');
      expect(v.tempo, greaterThan(Duration.zero));
      await v.alternar();
      expect(v.fase, FaseVoz.parada);
      expect(enviados.single, (3, 'audio/flac'));
      expect(entendidos.single, 'gastei 35 no mercado');
      expect(v.aviso, isNull);
      v.dispose();
    });

    test('toque rápido sem querer não manda nada', () async {
      final v = voz();
      await v.ouvir();
      await v.concluir();
      expect(enviados, isEmpty);
      expect(gravador.cancelado, isTrue);
      expect(v.aviso, contains('fale e toque de novo'));
      v.dispose();
    });

    test('cancelar joga o áudio fora', () async {
      final v = voz();
      await v.ouvir();
      await Future<void>.delayed(fala);
      await v.cancelar();
      expect(v.fase, FaseVoz.parada);
      expect(enviados, isEmpty);
      expect(entendidos, isEmpty);
      expect(gravador.cancelado, isTrue);
      v.dispose();
    });

    test('para sozinho no tempo máximo e envia', () async {
      final v = voz(maximo: const Duration(milliseconds: 900));
      await v.ouvir();
      await Future<void>.delayed(const Duration(milliseconds: 1400));
      expect(v.fase, FaseVoz.parada);
      expect(entendidos.single, 'gastei 35 no mercado');
      v.dispose();
    });

    test('sem conta, sem microfone, sem fala e sem internet: avisa e não envia', () async {
      var v = voz(conectada: false);
      await v.ouvir();
      expect(v.fase, FaseVoz.parada);
      expect(gravador.gravando, isFalse);
      expect(v.aviso, contains('entre na conta'));
      v.dispose();

      gravador = GravadorFalso(deixa: false);
      v = voz();
      await v.ouvir();
      expect(v.aviso, contains('Privacidade › Microfone'));
      v.dispose();

      gravador = GravadorFalso(falhaAoComecar: true);
      v = voz();
      await v.ouvir();
      expect(v.fase, FaseVoz.parada);
      expect(v.aviso, contains('microfone'));
      v.dispose();

      gravador = GravadorFalso();
      v = voz(transcrever: (_, _) async => '');
      await v.ouvir();
      await Future<void>.delayed(fala);
      await v.concluir();
      expect(v.aviso, contains('Não entendi'));
      v.dispose();

      gravador = GravadorFalso();
      v = voz(transcrever: (_, _) async => throw const ErroIa('Sem conexão com a internet.', semConexao: true));
      await v.ouvir();
      await Future<void>.delayed(fala);
      await v.concluir();
      expect(v.fase, FaseVoz.parada);
      expect(v.aviso, contains('Sem internet'));

      gravador = GravadorFalso();
      v = voz(transcrever: (_, _) async => throw const ErroIa('Áudio longo demais: fale em até um minuto.'));
      await v.ouvir();
      await Future<void>.delayed(fala);
      await v.concluir();
      expect(v.aviso, 'Áudio longo demais: fale em até um minuto.');
      expect(entendidos, isEmpty);
      v.dispose();
    });
  });

  group('na tela do assistente', () {
    late BancoAurora db;

    setUpAll(() async {
      iniciarRelogio();
      await initializeDateFormatting('pt_BR');
    });

    setUp(() => db = BancoAurora(NativeDatabase.memory()));
    tearDown(() => db.close());

    testWidgets('fala vira mensagem e o comando roda como se fosse digitado', (tester) async {
      await tester.runAsync(() => semearExemplo(db));
      tester.view.physicalSize = const Size(1180, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final gravador = GravadorFalso();
      await tester.pumpWidget(AuroraEscopo(
        db: db,
        escuro: ValueNotifier(true),
        child: MaterialApp(
          theme: temaAurora(Brightness.dark),
          home: Scaffold(
            body: AssistentePage(
              gravador: () => gravador,
              transcrever: () => (audio, formato) async => 'gastei 35 no mercado',
            ),
          ),
        ),
      ));
      // A orbe da conversa vazia pulsa sem parar: nada de pumpAndSettle.
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byTooltip('Falar com a Aurora'));
      await tester.runAsync(() => Future<void>.delayed(fala));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Ouvindo'), findsOneWidget);
      expect(find.byTooltip('Cancelar a gravação'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byTooltip('Parar e enviar'));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('gastei 35 no mercado'), findsOneWidget, reason: 'o que foi dito aparece como mensagem');
      expect(find.textContaining('Anotei R\$ 35,00'), findsOneWidget);
      final saiu = await tester.runAsync(() async => (await FinancasRepo(db).carregar()).mes(hojeSP()).saiuCentavos);
      expect(saiu, 3500);
      expect(find.text('Ouvindo'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('com texto no campo o microfone dá lugar ao enviar', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(AuroraEscopo(
        db: db,
        escuro: ValueNotifier(false),
        child: MaterialApp(
          theme: temaAurora(Brightness.light),
          home: Scaffold(body: AssistentePage(gravador: GravadorFalso.new, transcrever: () => null)),
        ),
      ));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byTooltip('Falar com a Aurora'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'oi');
      await tester.pump();
      expect(find.byTooltip('Falar com a Aurora'), findsNothing);

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      await tester.tap(find.byTooltip('Falar com a Aurora'));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('Para falar com a Aurora'), findsOneWidget, reason: 'sem conta, explica');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 7));
    });
  });
}
