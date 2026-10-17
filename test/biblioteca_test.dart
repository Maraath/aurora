import 'dart:io';

import 'package:aurora/core/relogio.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/biblioteca_exercicios.dart';
import 'package:aurora/data/saude_repo.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  final biblioteca = BibliotecaExercicios.deTexto(File('assets/exercicios.json').readAsStringSync());

  setUpAll(() async {
    iniciarRelogio();
    await initializeDateFormatting('pt_BR');
  });

  test('470 exercícios em 12 grupos, nomes com acento normalizados', () {
    expect(biblioteca.itens, hasLength(470));
    expect(biblioteca.grupos, hasLength(12));
    expect(biblioteca.grupos, containsAll(['Bíceps', 'Peitoral', 'Pernas', 'Abdômen']));
    // Ids únicos e seguros para URL.
    expect(biblioteca.itens.map((e) => e.id).toSet(), hasLength(470));
    expect(biblioteca.itens.every((e) => RegExp(r'^[a-z0-9-]+$').hasMatch(e.id)), isTrue);
    expect(biblioteca.itens.every((e) => e.arquivo == '${e.id}.webp'), isTrue);
  });

  test('busca por palavras, sem acento, e por grupo', () {
    final supinos = biblioteca.buscar('supino', grupo: 'Peitoral');
    expect(supinos, isNotEmpty);
    expect(supinos.every((e) => e.grupo == 'Peitoral' && e.nome.toLowerCase().contains('supino')), isTrue);
    expect(biblioteca.buscar('rosca biceps').every((e) => e.nome.toLowerCase().contains('rosca')), isTrue);
    expect(biblioteca.buscar('', grupo: 'Trapézio'), hasLength(9));
    expect(biblioteca.porNome('ROSCA BÍCEPS UNILATERAL')?.grupo, 'Bíceps');
  });

  test('URL pública da animação', () {
    expect(urlAnimacao('rosca-biceps-unilateral.webp'),
        'https://fhmhmdzbujqhkdsfnbtx.supabase.co/storage/v1/object/public/exercicios/exercicios_webp/rosca-biceps-unilateral.webp');
  });

  test('exercício escolhido da biblioteca fica ligado à animação', () async {
    final db = BancoAurora(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = SaudeRepo(db);
    final e = biblioteca.porNome('Rosca bíceps unilateral')!;
    await repo.salvarTreino(
      TreinosCompanion.insert(nome: 'Treino C'),
      [(nome: e.nome, series: 3, repeticoes: 12, cargaInicial: 8)],
      biblioteca: {e.nome.toLowerCase(): (e.arquivo, e.grupo)},
    );
    final ex = (await repo.carregar()).treinos.single.exercicios.single.exercicio;
    expect((ex.midia, ex.grupo), (e.arquivo, 'Bíceps'));

    // Um exercício já existente (sem animação) ganha a ligação ao ser escolhido.
    await repo.exercicioPorNome('Supino reto');
    await repo.exercicioPorNome('Supino reto', midia: 'supino-reto.webp', grupo: 'Peitoral');
    final supino = await (db.select(db.exercicios)..where((x) => x.nome.equals('Supino reto'))).getSingle();
    expect(supino.midia, 'supino-reto.webp');
  });
}
