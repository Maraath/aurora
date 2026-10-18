import 'dart:io';
import 'dart:typed_data';

import 'package:aurora/app.dart';
import 'package:aurora/core/relogio.dart';
import 'package:aurora/core/tema.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/fotos_sync.dart';
import 'package:aurora/data/shape_repo.dart';
import 'package:aurora/ui/saude/shape_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:intl/date_symbol_data_local.dart';

/// Balde de fotos em memória (o de verdade é o "shape", privado, no Supabase).
class ArmazemMemoria implements ArmazemFotos {
  final objetos = <String, (Uint8List, DateTime)>{};

  @override
  String get conta => 'conta-teste';

  @override
  Future<void> enviar(String arquivo, Uint8List bytes) async => objetos[arquivo] = (bytes, DateTime.now());

  @override
  Future<Uint8List?> baixar(String arquivo) async => objetos[arquivo]?.$1;

  @override
  Future<List<ObjetoFoto>> listar() async => [for (final e in objetos.entries) ObjetoFoto(e.key, e.value.$2)];

  @override
  Future<void> apagar(List<String> arquivos) async => arquivos.forEach(objetos.remove);
}

Uint8List imagemTeste({int largura = 2400, int altura = 3200}) =>
    img.encodePng(img.Image(width: largura, height: altura)..clear(img.ColorRgb8(60, 200, 150)));

void main() {
  late BancoAurora db;
  late Directory pasta;
  late ShapeRepo repo;

  setUpAll(() async {
    iniciarRelogio();
    await initializeDateFormatting('pt_BR');
  });

  setUp(() async {
    db = BancoAurora(NativeDatabase.memory());
    pasta = await Directory.systemTemp.createTemp('shape_');
    repo = ShapeRepo(db, pasta: () async => pasta);
  });

  tearDown(() async {
    await db.close();
    // No Windows a imagem aberta pode segurar o arquivo; a pasta temporária fica.
    await pasta.delete(recursive: true).catchError((_) => pasta);
  });

  test('comprime: lado maior vira 1600 px, em JPEG', () async {
    final jpeg = await comprimirFoto(imagemTeste());
    final foto = img.decodeJpg(jpeg)!;
    expect(foto.height, ladoMaximoFoto);
    expect(foto.width, 1200);
  });

  test('check-in: guarda, troca e apaga fotos agrupadas por dia', () async {
    final hoje = hojeSP();
    final ontem = hoje.subtract(const Duration(days: 1));
    await repo.salvarFoto(hoje, AnguloShape.frente, imagemTeste(largura: 300, altura: 400));
    await repo.salvarFoto(hoje, AnguloShape.lado, imagemTeste(largura: 300, altura: 400));
    await repo.salvarFoto(ontem, AnguloShape.frente, imagemTeste(largura: 300, altura: 400));

    var lista = await repo.carregar();
    expect(lista.map((k) => k.dia), [chaveData(hoje), chaveData(ontem)]);
    expect(lista.first.fotos.keys, unorderedEquals([AnguloShape.frente, AnguloShape.lado]));

    // Trocar: mesma linha (id natural), arquivo novo; o antigo some do aparelho.
    final antiga = lista.first.fotos[AnguloShape.frente]!;
    await repo.salvarFoto(hoje, AnguloShape.frente, imagemTeste(largura: 300, altura: 400));
    lista = await repo.carregar();
    final nova = lista.first.fotos[AnguloShape.frente]!;
    expect(nova.id, antiga.id);
    expect(nova.arquivo, isNot(antiga.arquivo));
    expect(await (await repo.arquivoLocal(antiga.arquivo)).exists(), isFalse);
    expect(await (await repo.arquivoLocal(nova.arquivo)).exists(), isTrue);

    // Apagar.
    await repo.apagarFoto(nova);
    lista = await repo.carregar();
    expect(lista.first.fotos.keys, [AnguloShape.lado]);
    expect(await (await repo.arquivoLocal(nova.arquivo)).exists(), isFalse);
  });

  test('sincroniza as imagens e limpa as que ninguém usa', () async {
    final armazem = ArmazemMemoria();
    await repo.salvarFoto(hojeSP(), AnguloShape.costas, imagemTeste(largura: 300, altura: 400));
    final arquivo = (await repo.arquivosEmUso()).single;

    var r = await SincronizadorFotos(repo, armazem).sincronizar();
    expect(r.enviadas, 1);
    expect(armazem.objetos.keys, [arquivo]);
    // Já enviada: não sobe de novo.
    r = await SincronizadorFotos(repo, armazem).sincronizar();
    expect(r.enviadas, 0);

    // Outro aparelho: a linha chegou pela sincronização das tabelas, a imagem não.
    final db2 = BancoAurora(NativeDatabase.memory());
    final pasta2 = await Directory.systemTemp.createTemp('shape2_');
    addTearDown(() async {
      await db2.close();
      await pasta2.delete(recursive: true);
    });
    final linha = (await db.select(db.fotosShape).get()).single;
    await db2.into(db2.fotosShape).insert(linha);
    final repo2 = ShapeRepo(db2, pasta: () async => pasta2);
    r = await SincronizadorFotos(repo2, armazem).sincronizar();
    expect(r.baixadas, 1);
    expect(await (await repo2.arquivoLocal(arquivo)).exists(), isTrue);

    // Apagada aqui: a imagem na nuvem só sai depois da folga de um dia.
    await repo.apagarFoto(linha);
    await SincronizadorFotos(repo, armazem).sincronizar();
    expect(armazem.objetos, contains(arquivo));
    await SincronizadorFotos(repo, armazem).sincronizar(agora: DateTime.now().add(const Duration(days: 2)));
    expect(armazem.objetos, isEmpty);
  });

  group('tela', () {
    Future<void> abrirTela(WidgetTester tester, {EscolherFoto? escolher}) async {
      tester.view.physicalSize = const Size(1180, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(AuroraEscopo(
        db: db,
        escuro: ValueNotifier(true),
        child: MaterialApp(
          theme: temaAurora(Brightness.dark),
          home: Scaffold(body: SingleChildScrollView(child: ShapePage(repo: repo, escolher: escolher))),
        ),
      ));
      await assentar(tester);
    }

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

    testWidgets('enviar foto e comparar duas datas', (tester) async {
      final passado = hojeSP().subtract(const Duration(days: 40));
      await tester.runAsync(() async {
        await repo.salvarFoto(passado, AnguloShape.frente, imagemTeste(largura: 300, altura: 400));
        await repo.salvarFoto(passado, AnguloShape.costas, imagemTeste(largura: 300, altura: 400));
      });
      await abrirTela(tester, escolher: (_, _) async => imagemTeste(largura: 300, altura: 400));

      // Histórico com o check-in antigo.
      expect(find.textContaining('Check-in de'), findsNWidgets(2));

      // Enviar a frente de hoje pela vaga vazia.
      // Toque dentro do runAsync: a compressão roda num isolate de verdade.
      await tester.runAsync(() async {
        await tester.tap(find.bySemanticsLabel('Enviar foto de frente'));
        for (var i = 0; i < 50 && (await repo.carregar()).first.fotos.isEmpty; i++) {
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
  });
}

Future<void> assentar(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 80)));
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 300));
}
