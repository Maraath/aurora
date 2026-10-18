import 'dart:io';
import 'dart:typed_data';

import 'package:aurora/app.dart';
import 'package:aurora/core/relogio.dart';
import 'package:aurora/core/tema.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/fotos/armazem.dart';
import 'package:aurora/data/fotos/cofre.dart';
import 'package:aurora/data/fotos/compressao.dart';
import 'package:aurora/data/fotos_sync.dart';
import 'package:aurora/data/shape_repo.dart';
import 'package:aurora/ui/conta/fotos_config.dart';
import 'package:aurora/ui/saude/shape_page.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:intl/date_symbol_data_local.dart';

/// Balde de fotos em memória (o de verdade é o "fotos", privado, no Supabase).
class ArmazemMemoria implements ArmazemFotos {
  final inteiras = <String, Uint8List>{};
  final miniaturas = <String, Uint8List>{};
  var downloads = 0;
  var fora = false; // simula falta de internet

  void _rede() {
    if (fora) throw const SocketException('sem internet');
  }

  @override
  Future<void> enviar(String id, {required Uint8List completa, required Uint8List miniatura}) async {
    _rede();
    inteiras[id] = completa;
    miniaturas[id] = miniatura;
  }

  @override
  Future<Uint8List?> baixar(String id, {bool miniatura = false}) async {
    _rede();
    downloads++;
    return (miniatura ? miniaturas : inteiras)[id];
  }

  @override
  Future<void> apagar(List<String> ids) async {
    _rede();
    for (final id in ids) {
      inteiras.remove(id);
      miniaturas.remove(id);
    }
  }
}

/// Imagem com degradê e textura, parecida com uma foto (cor chapada comprime
/// demais e não diz nada sobre o tamanho real).
Uint8List imagemTeste({int largura = 2400, int altura = 3200}) => img.encodePng(imagem(largura, altura));

img.Image imagem(int largura, int altura) {
  final im = img.Image(width: largura, height: altura);
  for (final p in im) {
    final ruido = ((p.x * 7919 + p.y * 104729) % 23) - 11;
    p
      ..r = (40 + p.x * 150 ~/ largura + ruido).clamp(0, 255)
      ..g = (60 + p.y * 140 ~/ altura + ruido).clamp(0, 255)
      ..b = (90 + (p.x + p.y) * 60 ~/ (largura + altura) - ruido).clamp(0, 255);
  }
  return im;
}

/// Um aparelho: banco, pasta e a mesma "nuvem".
class Aparelho {
  Aparelho._(this.db, this.pasta, this.repo);
  final BancoAurora db;
  final Directory pasta;
  final ShapeRepo repo;
  CofreFotos get cofre => repo.cofre;

  static Future<Aparelho> novo(ArmazemMemoria? Function() armazem) async {
    final db = BancoAurora(NativeDatabase.memory());
    final pasta = await Directory.systemTemp.createTemp('fotos_');
    return Aparelho._(db, pasta, ShapeRepo(db, cofre: CofreFotos(db, pasta: () async => pasta, armazem: armazem)));
  }

  Future<void> fechar() async {
    await db.close();
    // No Windows a imagem aberta pode segurar o arquivo; a pasta temporária fica.
    await pasta.delete(recursive: true).catchError((_) => pasta);
  }

  /// A linha chega a outro aparelho pela sincronização das tabelas.
  Future<void> receberLinhasDe(Aparelho outro) async {
    for (final l in await outro.db.select(outro.db.fotosShape).get()) {
      await db.into(db.fotosShape).insertOnConflictUpdate(l);
    }
  }

  Future<FotoShape> foto(AnguloShape a) async => (await repo.fotosAtivas()).firstWhere((f) => f.angulo == a.name);
}

void main() {
  late ArmazemMemoria nuvem;
  var logado = true;
  late Aparelho pc;

  setUpAll(() async {
    iniciarRelogio();
    await initializeDateFormatting('pt_BR');
  });

  setUp(() async {
    nuvem = ArmazemMemoria();
    logado = true;
    pc = await Aparelho.novo(() => logado ? nuvem : null);
  });

  tearDown(() => pc.fechar());

  test('comprime: WebP de até 1080 px, miniatura de 300, sem EXIF, de pé', () async {
    // Foto "deitada" com orientação 6 (girar 90°), GPS e modelo no EXIF, como sai do celular.
    final original = imagem(3200, 2400);
    original.exif.imageIfd.orientation = 6;
    original.exif.imageIfd['Model'] = img.IfdValueAscii('Celular X');
    original.exif.gpsIfd['GPSLatitudeRef'] = img.IfdValueAscii('S');
    final jpeg = img.encodeJpg(original);
    final textoJpeg = String.fromCharCodes(jpeg);
    expect(textoJpeg, contains('Exif'));
    expect(textoJpeg, contains('Celular X'));

    final f = await comprimirFoto(jpeg);
    final inteira = img.decodeWebP(f.completa)!;
    final mini = img.decodeWebP(f.miniatura)!;
    expect(String.fromCharCodes(f.completa.sublist(8, 12)), 'WEBP');
    expect((inteira.width, inteira.height), (810, 1080)); // girada: fica em pé
    expect((mini.width, mini.height), (225, 300));
    expect(inteira.exif.isEmpty, isTrue);
    expect(String.fromCharCodes(f.completa), isNot(contains('Celular X')));
    expect(f.hash, sha256.convert(f.completa).toString());
    expect(f.completa.length, lessThan(320 * 1024));
    expect(f.miniatura.length, lessThan(40 * 1024));
  });

  test('padrão: só neste aparelho; nada sobe nem na sincronização', () async {
    expect(await pc.cofre.modo(), ModoFotos.aparelho);
    await pc.repo.salvarFoto(hojeSP(), AnguloShape.frente, imagemTeste(largura: 300, altura: 400));
    final r = await SincronizadorFotos(pc.repo).sincronizar();
    expect(r.enviadas, 0);
    expect(nuvem.inteiras, isEmpty);
    final f = await pc.foto(AnguloShape.frente);
    expect(f.naNuvem, isFalse);
    expect(f.hash, isNotNull);
    expect(await pc.cofre.local(f.ref), isNotNull);
    expect(await pc.cofre.local(f.ref, miniatura: true), isNotNull);
  });

  test('sincronizar: a foto sobe e o outro aparelho baixa uma vez só', () async {
    await pc.cofre.definirModo(ModoFotos.nuvem);
    await pc.repo.salvarFoto(hojeSP(), AnguloShape.frente, imagemTeste(largura: 600, altura: 800));
    expect((await SincronizadorFotos(pc.repo).sincronizar()).enviadas, 1);
    final f = await pc.foto(AnguloShape.frente);
    expect(f.naNuvem, isTrue);
    expect(nuvem.inteiras.keys, [f.id]);

    final cel = await Aparelho.novo(() => nuvem);
    addTearDown(cel.fechar);
    await cel.receberLinhasDe(pc);
    final noCel = await cel.foto(AnguloShape.frente);
    expect(await cel.cofre.obter(noCel.ref, miniatura: true), isNotNull);
    expect(nuvem.downloads, 1); // só a miniatura; a inteira desce ao abrir
    await cel.cofre.obter(noCel.ref, miniatura: true);
    expect(nuvem.downloads, 1, reason: 'já está no aparelho: não baixa de novo');

    // Trocada no PC: hash novo, o celular baixa de novo.
    await pc.repo.salvarFoto(hojeSP(), AnguloShape.frente, imagemTeste(largura: 640, altura: 800));
    await SincronizadorFotos(pc.repo).sincronizar();
    await cel.receberLinhasDe(pc);
    final trocada = await cel.foto(AnguloShape.frente);
    expect(trocada.hash, isNot(noCel.hash));
    expect(await cel.cofre.obter(trocada.ref, miniatura: true), isNotNull);
    expect(nuvem.downloads, 2);
  });

  test('outro aparelho: foto que não foi para a nuvem não é procurada lá', () async {
    await pc.repo.salvarFoto(hojeSP(), AnguloShape.lado, imagemTeste(largura: 300, altura: 400));
    final cel = await Aparelho.novo(() => nuvem);
    addTearDown(cel.fechar);
    await cel.receberLinhasDe(pc);
    final f = await cel.foto(AnguloShape.lado);
    expect(await cel.cofre.obter(f.ref, miniatura: true), isNull);
    expect(nuvem.downloads, 0);
  });

  test('"Enviar para a nuvem" vale para uma foto, mesmo no modo só no aparelho', () async {
    await pc.repo.salvarFoto(hojeSP(), AnguloShape.frente, imagemTeste(largura: 300, altura: 400));
    await pc.repo.salvarFoto(hojeSP(), AnguloShape.costas, imagemTeste(largura: 300, altura: 400));
    await pc.repo.enviarParaNuvem(await pc.foto(AnguloShape.frente));
    expect(nuvem.inteiras.keys, [(await pc.foto(AnguloShape.frente)).id]);
    expect((await pc.foto(AnguloShape.frente)).naNuvem, isTrue);
    expect((await pc.foto(AnguloShape.costas)).naNuvem, isFalse);
    expect((await pc.repo.paraEnviar()).map((f) => f.angulo), ['costas']);

    logado = false;
    await expectLater(pc.repo.enviarParaNuvem(await pc.foto(AnguloShape.costas)), throwsStateError);
  });

  test('apagar foto apaga da nuvem; sem internet, apaga na próxima sincronização', () async {
    await pc.cofre.definirModo(ModoFotos.nuvem);
    await pc.repo.salvarFoto(hojeSP(), AnguloShape.frente, imagemTeste(largura: 300, altura: 400));
    await pc.repo.salvarFoto(hojeSP(), AnguloShape.lado, imagemTeste(largura: 300, altura: 400));
    await SincronizadorFotos(pc.repo).sincronizar();
    expect(nuvem.inteiras, hasLength(2));

    await pc.repo.apagarFoto(await pc.foto(AnguloShape.frente));
    expect(nuvem.inteiras, hasLength(1));

    nuvem.fora = true;
    await pc.repo.apagarFoto(await pc.foto(AnguloShape.lado));
    expect(nuvem.inteiras, hasLength(1));
    nuvem.fora = false;
    expect((await SincronizadorFotos(pc.repo).sincronizar()).apagadas, 1);
    expect(nuvem.inteiras, isEmpty);
  });

  test('trocar foto no modo só no aparelho tira a versão antiga da nuvem', () async {
    await pc.repo.salvarFoto(hojeSP(), AnguloShape.frente, imagemTeste(largura: 300, altura: 400));
    await pc.repo.enviarParaNuvem(await pc.foto(AnguloShape.frente));
    expect(nuvem.inteiras, hasLength(1));
    await pc.repo.salvarFoto(hojeSP(), AnguloShape.frente, imagemTeste(largura: 320, altura: 400));
    expect(nuvem.inteiras, isEmpty);
    expect((await pc.foto(AnguloShape.frente)).naNuvem, isFalse);
  });

  test('limpar cache só apaga cópias que estão na nuvem', () async {
    await pc.repo.salvarFoto(hojeSP(), AnguloShape.frente, imagemTeste(largura: 600, altura: 800));
    await pc.repo.salvarFoto(hojeSP(), AnguloShape.lado, imagemTeste(largura: 600, altura: 800));
    await pc.repo.enviarParaNuvem(await pc.foto(AnguloShape.frente));
    final antes = await pc.cofre.espacoOcupado();

    final liberado = await pc.cofre.limparCache([for (final f in await pc.repo.fotosAtivas()) f.ref]);
    expect(liberado, greaterThan(0));
    expect(await pc.cofre.espacoOcupado(), antes - liberado);
    expect(await pc.cofre.local((await pc.foto(AnguloShape.frente)).ref), isNull);
    expect(await pc.cofre.local((await pc.foto(AnguloShape.lado)).ref), isNotNull, reason: 'só existe aqui');
    // A da nuvem volta quando abrir.
    expect(await pc.cofre.obter((await pc.foto(AnguloShape.frente)).ref), isNotNull);
  });

  test('tirar da nuvem guarda uma cópia aqui antes de apagar lá', () async {
    await pc.cofre.definirModo(ModoFotos.nuvem);
    await pc.repo.salvarFoto(hojeSP(), AnguloShape.frente, imagemTeste(largura: 300, altura: 400));
    await SincronizadorFotos(pc.repo).sincronizar();

    final cel = await Aparelho.novo(() => nuvem);
    addTearDown(cel.fechar);
    await cel.receberLinhasDe(pc);
    final f = await cel.foto(AnguloShape.frente);
    expect(await cel.cofre.local(f.ref), isNull);

    expect(await cel.repo.tirarDaNuvem(f), isTrue);
    expect(nuvem.inteiras, isEmpty);
    expect(await cel.cofre.local((await cel.foto(AnguloShape.frente)).ref), isNotNull);
    expect((await cel.foto(AnguloShape.frente)).naNuvem, isFalse);
  });

  test('converte as fotos antigas (JPEG 1600 px) para WebP com miniatura', () async {
    final antiga = await Directory.systemTemp.createTemp('shape_antigo_');
    await File('${antiga.path}/velha.jpg').writeAsBytes(img.encodeJpg(imagem(1200, 1600)));
    await pc.db
        .into(pc.db.fotosShape)
        .insert(FotosShapeCompanion.insert(id: const Value('x1'), dia: '2026-10-10', angulo: 'frente', arquivo: 'velha.jpg'));

    await pc.repo.converterFotosAntigas(pastaAntiga: () async => antiga);
    final f = await pc.foto(AnguloShape.frente);
    expect(f.hash, isNotNull);
    expect(f.arquivo, 'x1.webp');
    expect(await pc.cofre.local(f.ref), isNotNull);
    expect(await antiga.exists(), isFalse);
  });

  group('tela', () {
    Future<void> abrir(WidgetTester tester, Widget filho) async {
      tester.view.physicalSize = const Size(1180, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(AuroraEscopo(
        db: pc.db,
        escuro: ValueNotifier(true),
        child: MaterialApp(
          theme: temaAurora(Brightness.dark),
          home: Scaffold(body: SingleChildScrollView(child: filho)),
        ),
      ));
      await assentar(tester);
    }

    Future<void> abrirTela(WidgetTester tester, {EscolherFoto? escolher}) =>
        abrir(tester, ShapePage(repo: pc.repo, escolher: escolher));

    testWidgets('vazia: três vagas e histórico vazio', (tester) async {
      await abrirTela(tester);
      expect(find.textContaining('Check-in de'), findsOneWidget);
      for (final a in ['frente', 'costas', 'lado']) {
        expect(find.bySemanticsLabel('Enviar foto de $a'), findsOneWidget);
      }
      expect(find.text('Comparar evolução'), findsOneWidget);
      await tester.tap(find.text('Comparar evolução'));
      await tester.pump();
      expect(find.text('Faça check-ins em pelo menos dois dias para comparar.'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('foto de outro aparelho aparece como espaço reservado', (tester) async {
      final outro = (await tester.runAsync(() => Aparelho.novo(() => nuvem)))!;
      await tester.runAsync(() async {
        await outro.repo.salvarFoto(hojeSP(), AnguloShape.frente, imagemTeste(largura: 300, altura: 400));
        await pc.receberLinhasDe(outro);
      });
      await abrirTela(tester);
      await assentar(tester);
      expect(find.text('Foto guardada em outro aparelho'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(outro.fechar);
    });

    testWidgets('Shape: escolher onde guardar perto das fotos', (tester) async {
      await tester.runAsync(
        () => pc.repo.salvarFoto(hojeSP(), AnguloShape.frente, imagemTeste(largura: 300, altura: 400)),
      );
      await abrirTela(tester);
      for (var i = 0; i < 20 && find.text('Na nuvem').evaluate().isEmpty; i++) {
        await assentar(tester);
      }
      expect(find.text('ONDE GUARDAR AS FOTOS'), findsOneWidget);
      expect(find.textContaining('se perdem se o app for desinstalado'), findsOneWidget);

      await tester.runAsync(() async {
        await tester.tap(find.text('Na nuvem'));
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await assentar(tester);
      expect(find.text('Enviar as fotos que já estão aqui?'), findsOneWidget);
      await tester.runAsync(() async {
        await tester.tap(find.text('Enviar 1 foto'));
        for (var i = 0; i < 60 && nuvem.inteiras.isEmpty; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await assentar(tester);
      expect(nuvem.inteiras, hasLength(1));
      expect(await tester.runAsync(pc.cofre.modo), ModoFotos.nuvem);
      expect(find.textContaining('aparecem nos seus outros aparelhos'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('foto trocada no mesmo arquivo não mostra a versão antiga da memória', (tester) async {
      await tester.runAsync(
        () => pc.repo.salvarFoto(hojeSP(), AnguloShape.frente, imagemTeste(largura: 300, altura: 400)),
      );
      await abrirTela(tester);
      Future<void> esperarImagem() async {
        for (var i = 0; i < 20 && find.byType(Image).evaluate().isEmpty; i++) {
          await assentar(tester);
        }
      }

      ImageProvider chave() => (tester.widget<Image>(find.byType(Image).first).image as ResizeImage).imageProvider;
      await esperarImagem();
      final antes = chave();
      await tester.runAsync(
        () => pc.repo.salvarFoto(hojeSP(), AnguloShape.frente, imagemTeste(largura: 320, altura: 400)),
      );
      await assentar(tester);
      await assentar(tester);
      expect((chave() as FileImage).file.path, (antes as FileImage).file.path); // mesmo arquivo
      expect(chave(), isNot(antes)); // chave nova: o cache de imagens não reaproveita a antiga
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('enviar foto e comparar duas datas', (tester) async {
      final passado = hojeSP().subtract(const Duration(days: 40));
      await tester.runAsync(() async {
        await pc.repo.salvarFoto(passado, AnguloShape.frente, imagemTeste(largura: 300, altura: 400));
        await pc.repo.salvarFoto(passado, AnguloShape.costas, imagemTeste(largura: 300, altura: 400));
      });
      await abrirTela(tester, escolher: (_, _) async => imagemTeste(largura: 300, altura: 400));

      // Histórico com o check-in antigo.
      expect(find.textContaining('Check-in de'), findsNWidgets(2));

      // Enviar a frente de hoje pela vaga vazia.
      // Toque dentro do runAsync: a compressão roda num isolate de verdade.
      await tester.runAsync(() async {
        await tester.tap(find.bySemanticsLabel('Enviar foto de frente'));
        final hoje = chaveData(hojeSP());
        for (var i = 0; i < 50 && !(await pc.repo.carregar()).any((k) => k.dia == hoje); i++) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
      });
      await assentar(tester);
      expect(find.bySemanticsLabel('Enviar foto de frente'), findsNothing);
      expect(tester.takeException(), isNull);

      // Comparar: abre em tela cheia com Data A, Data B e os ângulos.
      await tester.tap(find.text('Comparar evolução'));
      await assentar(tester);
      expect(find.text('DATA A'), findsOneWidget);
      expect(find.text('DATA B'), findsOneWidget);
      expect(find.text('40 dias entre as fotos.'), findsOneWidget);
      await tester.tap(find.text('Lado').last); // a tela de comparar fica por cima
      await assentar(tester);
      expect(find.text('Sem foto de lado neste dia'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('Conta › Fotos: padrão com aviso; sincronizar envia as que já existem', (tester) async {
      await tester.runAsync(() async {
        await pc.repo.salvarFoto(hojeSP(), AnguloShape.frente, imagemTeste(largura: 300, altura: 400));
        await pc.repo.salvarFoto(hojeSP(), AnguloShape.costas, imagemTeste(largura: 300, altura: 400));
      });
      await abrir(tester, SecaoFotos(db: pc.db, repo: pc.repo));
      // A seção lê o modo e mede a pasta (disco de verdade) antes de aparecer.
      for (var i = 0; i < 20 && find.text('Onde guardar minhas fotos').evaluate().isEmpty; i++) {
        await assentar(tester);
      }
      expect(find.text('Onde guardar minhas fotos'), findsOneWidget);
      expect(find.textContaining('se perdem se o app for desinstalado'), findsOneWidget);
      expect(find.text('Limpar cache de fotos'), findsOneWidget);

      await tester.runAsync(() async {
        await tester.tap(find.text('Sincronizar com a nuvem'));
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await assentar(tester);
      expect(find.text('Enviar as fotos que já estão aqui?'), findsOneWidget);
      await tester.runAsync(() async {
        await tester.tap(find.text('Enviar 2 fotos'));
        for (var i = 0; i < 60 && nuvem.inteiras.length < 2; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await assentar(tester);
      expect(nuvem.inteiras, hasLength(2));
      expect(await tester.runAsync(pc.cofre.modo), ModoFotos.nuvem);
      expect(find.textContaining('as 2 fotos foram enviadas'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  });
}

Future<void> assentar(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 80)));
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 300));
}
