import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:aurora/app.dart';
import 'package:aurora/core/relogio.dart';
import 'package:aurora/data/anotacoes_repo.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/busca.dart';
import 'package:aurora/data/fotos/cofre.dart';
import 'package:aurora/data/fotos/cofre_audios.dart';
import 'package:aurora/data/gravacao_nota.dart';
import 'package:aurora/data/sincronizacao.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'navegacao_test.dart' show assentar;

/// Balde de áudios em memória (o de verdade é o "audios", privado).
class AudiosNaMemoria implements ArmazemAudios {
  final guardados = <String, Uint8List>{};

  @override
  Future<void> enviar(String id, String formato, Uint8List bytes) async => guardados[id] = bytes;

  @override
  Future<Uint8List?> baixar(String id, String formato) async => guardados[id];

  @override
  Future<void> apagar(List<({String id, String formato})> audios) async {
    for (final a in audios) {
      guardados.remove(a.id);
    }
  }
}

/// Microfone falso: devolve sempre o mesmo "áudio" e um volume que sobe e desce.
class GravadorFalso implements GravadorDeNota {
  final _volume = StreamController<double>.broadcast();
  Timer? _timer;
  var pausas = 0;

  @override
  Future<bool> permitido() async => true;

  @override
  Future<String> comecar() async {
    var i = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 20), (_) => _volume.add((i++ % 10) / 10));
    return 'audio/mp4';
  }

  @override
  Future<void> pausar() async => pausas++;

  @override
  Future<void> continuar() async {}

  @override
  Stream<double> get nivel => _volume.stream;

  @override
  Future<Uint8List?> parar() async {
    _timer?.cancel();
    return Uint8List.fromList(List.generate(2000, (i) => i % 256));
  }

  @override
  Future<void> cancelar() async => _timer?.cancel();

  @override
  Future<void> fechar() async => _volume.close();
}

void main() {
  late BancoAurora db;
  late Directory pasta;
  late AudiosNaMemoria nuvem;
  late AnotacoesRepo repo;
  String? transcricaoFalsa;

  setUpAll(() async {
    iniciarRelogio();
    await initializeDateFormatting('pt_BR');
  });

  setUp(() async {
    db = BancoAurora(NativeDatabase.memory());
    pasta = await Directory.systemTemp.createTemp('notas_');
    nuvem = AudiosNaMemoria();
    transcricaoFalsa = 'Preciso comprar café e ligar para o João.';
    repo = AnotacoesRepo(
      db,
      cofreFotos: CofreFotos(db, pasta: () async => pasta, armazem: () => null),
      cofreAudios: CofreAudios(db, pasta: () async => pasta, armazem: () => nuvem),
      transcrever: () => transcricaoFalsa == null ? null : (audio, formato) async => transcricaoFalsa!,
    );
  });

  tearDown(() async {
    await db.close();
    await pasta.delete(recursive: true).catchError((_) => pasta);
  });

  test('caixinhas: grava e lê o JSON; texto quebrado vira lista vazia', () {
    final json = gravarItens(const [ItemLista('Ovos', feito: true), ItemLista('Café')]);
    final lidos = lerItens(json);
    expect([for (final i in lidos) (i.texto, i.feito)], [('Ovos', true), ('Café', false)]);
    expect(lerItens('{quebrado'), isEmpty);
    expect(gravarItens(const []), isNull);
  });

  test('nota: cria, edita, fixada fica em cima e a busca ignora acentos', () async {
    final a = await repo.criarNota(titulo: 'Ideias para o app', texto: 'Área de anotações');
    final b = await repo.criarNota(tipo: TipoNota.lista, itens: const [ItemLista('Pão'), ItemLista('Feijão')]);
    await repo.salvarNota(a, fixada: true);
    await repo.salvarNota(b, itens: const [ItemLista('Pão', feito: true), ItemLista('Feijão')]);

    final q = await repo.carregar();
    expect(q.notas.map((n) => n.id), [a, b]);
    final lista = q.nota(b)!;
    expect(lista.feitos, 1);
    expect(lista.tituloVisivel, 'Pão, Feijão');
    expect(filtrarNotas(q.notas, const TodasAsNotas(), 'feijao').map((n) => n.id), [b]);
    expect(filtrarNotas(q.notas, const TodasAsNotas(), 'AREA').map((n) => n.id), [a]);
  });

  test('pasta: filtra, renomeia e, apagada, as notas ficam sem pasta', () async {
    final p = await repo.criarPasta(' Trabalho ');
    final n = await repo.criarNota(pastaId: p, titulo: 'Reunião');
    await repo.criarNota(titulo: 'Solta');
    var q = await repo.carregar();
    expect(q.pastas.single.nome, 'Trabalho');
    expect(filtrarNotas(q.notas, NaPasta(p), '').map((x) => x.id), [n]);

    await repo.renomearPasta(p, 'Serviço');
    await repo.apagarPasta(p);
    q = await repo.carregar();
    expect(q.pastas, isEmpty);
    expect(q.nota(n)!.nota.pastaId, isNull);
  });

  test('nota em branco some ao fechar; apagar tem desfazer', () async {
    final vazia = await repo.criarNota(tipo: TipoNota.lista, itens: const [ItemLista('')]);
    final cheia = await repo.criarNota(titulo: 'Fica');
    expect(await repo.descartarSeVazia(vazia), isTrue);
    expect(await repo.descartarSeVazia(cheia), isFalse);

    await repo.apagarNota(cheia);
    expect((await repo.carregar()).notas, isEmpty);
    await repo.desfazerApagar(cheia);
    expect((await repo.carregar()).notas.single.id, cheia);
  });

  test('áudio: guarda no aparelho, transcreve e, no modo nuvem, sobe na sincronização', () async {
    await CofreFotos(db).definirModo(ModoFotos.nuvem);
    final id = await repo.criarNota(tipo: TipoNota.audio);
    final audio = AudioGravado(
      bytes: Uint8List.fromList([1, 2, 3, 4]),
      formato: 'audio/mp4',
      duracao: const Duration(seconds: 12),
      onda: resumirOnda([0.1, 0.9, 0.5]),
    );
    final anexo = await repo.adicionarAudio(id, audio);
    expect(await File('${pasta.path}/audios/${anexo.id}.m4a').exists(), isTrue);

    expect(await repo.tentarTranscrever(anexo), isNull);
    var n = (await repo.nota(id))!;
    expect(n.audios.single.transcricao, 'Preciso comprar café e ligar para o João.');
    expect(n.tituloVisivel, startsWith('Preciso comprar café'));
    expect(filtrarNotas([n], const SoAudios(), 'joao'), hasLength(1));

    final r = await repo.sincronizarAudios();
    expect(r.enviados, 1);
    expect(nuvem.guardados[anexo.id], [1, 2, 3, 4]);
    n = (await repo.nota(id))!;
    expect(n.audios.single.naNuvem, isTrue);

    // Apagar o áudio tira do aparelho e da nuvem.
    await repo.apagarAnexo(n.audios.single);
    expect(nuvem.guardados, isEmpty);
    expect(await File('${pasta.path}/audios/${anexo.id}.m4a').exists(), isFalse);
  });

  test('áudio: sem conta, a transcrição fica para depois com o aviso', () async {
    transcricaoFalsa = null;
    final id = await repo.criarNota(tipo: TipoNota.audio);
    final anexo = await repo.adicionarAudio(
      id,
      AudioGravado(bytes: Uint8List(8), formato: 'audio/wav', duracao: const Duration(seconds: 3), onda: '5' * 48),
    );
    expect(await repo.tentarTranscrever(anexo), contains('entre na sua conta'));
    expect((await repo.nota(id))!.audios.single.transcricao, isNull);
  });

  test('onda: 48 dígitos de 0 a 9 e leitura de volta', () {
    final onda = resumirOnda(List.generate(500, (i) => (i % 50) / 50));
    expect(onda, hasLength(48));
    expect(RegExp(r'^[0-9]{48}$').hasMatch(onda), isTrue);
    expect(lerOnda(onda), hasLength(48));
    expect(lerOnda(null), hasLength(48));
  });

  test('gravação: pausa não conta no tempo e o resultado traz a onda', () async {
    final g = GravadorFalso();
    final ctl = ControleGravacao(gravador: () => g);
    await ctl.comecar();
    expect(ctl.fase, FaseGravacao.gravando);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await ctl.alternarPausa();
    expect(ctl.fase, FaseGravacao.pausada);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await ctl.alternarPausa();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final r = await ctl.parar();
    expect(r, isNotNull);
    expect(r!.formato, 'audio/mp4');
    expect(r.duracao, lessThan(const Duration(milliseconds: 1250)));
    expect(r.duracao, greaterThan(const Duration(milliseconds: 800)));
    expect(r.onda, hasLength(48));
    expect(g.pausas, 1);
    ctl.dispose();
  });

  test('sincronização e busca enxergam as anotações', () async {
    final nomes = tabelasSincronizadas(db).map((t) => t.actualTableName).toList();
    expect(nomes, containsAllInOrder(['pastas_notas', 'notas', 'anexos_nota']));

    await repo.criarNota(titulo: 'Presente da mãe', texto: 'Livro de receitas antigas');
    final r = await buscarTudo(db, 'receitas');
    expect(r.where((x) => x.tipo == TipoResultado.nota).single.titulo, 'Presente da mãe');
  });

  group('tela', () {
    Future<void> abrir(WidgetTester tester, Size tamanho) async {
      tester.view.physicalSize = tamanho;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(AuroraApp(db: db, escuro: ValueNotifier(true)));
      await assentar(tester);
      if (tamanho.width >= 840) {
        await tester.tap(find.bySemanticsLabel('Anotações').first);
      } else {
        await tester.tap(find.bySemanticsLabel('Página 2 do menu'));
        await assentar(tester);
        await tester.tap(find.bySemanticsLabel('Anotações').first);
      }
      await assentar(tester);
    }

    testWidgets('computador: Nova nota › Lista abre ao lado do mural', (tester) async {
      await tester.runAsync(() => repo.criarNota(titulo: 'Ideias para o Aurora', texto: 'Pastas e áudio'));
      await abrir(tester, const Size(1400, 900));
      expect(find.text('Ideias para o Aurora'), findsOneWidget);

      await tester.tap(find.text('Nova nota'));
      await assentar(tester);
      expect(find.text('O que você quer criar?'), findsOneWidget);
      await tester.tap(find.text('Caixinhas para ir marcando'));
      await assentar(tester);
      // A lista nova abre ao lado, com a primeira caixinha pronta.
      expect(find.byTooltip('Fechar a nota'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextField, 'Item').first, 'Comprar café');
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 700)));
      await assentar(tester);
      await tester.tap(find.byTooltip('Fechar a nota'));
      await assentar(tester);
      expect(find.text('Comprar café'), findsWidgets);

      // Só o mural de cartões: sem "Ver como".
      expect(find.bySemanticsLabel('Ver como Lista'), findsNothing);
      await tester.tap(find.text('Ideias para o Aurora'));
      await assentar(tester);
      expect(find.byTooltip('Fechar a nota'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('celular: a nota abre na tela toda e a nota vazia some', (tester) async {
      await abrir(tester, const Size(390, 844));
      expect(find.textContaining('Nenhuma nota ainda'), findsOneWidget);
      await tester.tap(find.text('Nova nota'));
      await assentar(tester);
      await tester.tap(find.text('Nota'));
      await assentar(tester);
      expect(find.byTooltip('Voltar'), findsWidgets);
      await tester.tap(find.byTooltip('Voltar').last);
      await assentar(tester);
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      await assentar(tester);
      expect((await tester.runAsync(() => repo.carregar()))!.notas, isEmpty);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  });
}
