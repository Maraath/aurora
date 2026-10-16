import 'package:aurora/core/relogio.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/exemplo.dart';
import 'package:aurora/data/visao_repo.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late BancoAurora db;
  late VisaoRepo repo;

  setUpAll(() async {
    iniciarRelogio();
    await initializeDateFormatting('pt_BR');
  });

  setUp(() async {
    db = BancoAurora(NativeDatabase.memory());
    repo = VisaoRepo(db);
    await semearExemplo(db);
  });

  tearDown(() => db.close());

  test('dados de exemplo geram o resumo do protótipo', () async {
    final r = await repo.carregar();
    expect(r.nome, 'Maraath');
    expect(r.habitos.map((h) => h.habito.nome), ['Cardio', 'Estudo']);
    expect(r.habitosFeitos, 0);
    expect(r.tarefasAbertas, 5);
    // "Fórmula Mágica" é hoje às 21:00 e passa a contar como atrasada depois disso.
    expect(r.tarefasAtrasadas, agoraSP().hour >= 21 ? 4 : 3);
    expect(r.aPagarCentavos, 22280);
    expect(r.contasAPagar, 3);
    expect(r.meta?.nome, 'Shape 80kg');
  });

  test('semear duas vezes não duplica', () async {
    await semearExemplo(db);
    final r = await repo.carregar();
    expect(r.tarefasAbertas, 5);
  });

  test('marcar hábito grava um registro por dia e pode desfazer', () async {
    final cardio = (await repo.carregar()).habitos.first.habito;
    await repo.alternarHabito(cardio.id, true);
    await repo.alternarHabito(cardio.id, true);
    expect((await repo.carregar()).habitosFeitos, 1);
    expect(await db.select(db.registrosHabito).get(), hasLength(1));

    await repo.alternarHabito(cardio.id, false);
    expect((await repo.carregar()).habitosFeitos, 0);
  });

  test('tarefa com hora atrasa pelo horário; sem hora, pelo dia', () {
    final agora = diaSP(2026, 10, 16, 15);
    Tarefa t(DateTime prazo, bool temHora) => Tarefa(
          id: 'x',
          criadoEm: agora,
          atualizadoEm: agora,
          titulo: 't',
          prazo: prazo,
          prazoTemHora: temHora,
          prioridade: Prioridade.media,
        );
    expect(tarefaAtrasada(t(diaSP(2026, 10, 16, 9), true), agora), isTrue);
    expect(tarefaAtrasada(t(diaSP(2026, 10, 16), false), agora), isFalse);
    expect(tarefaAtrasada(t(diaSP(2026, 10, 15), false), agora), isTrue);
  });
}
