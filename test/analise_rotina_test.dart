import 'package:aurora/core/relogio.dart';
import 'package:aurora/data/analise_habitos.dart';
import 'package:aurora/data/analise_tarefas.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/exemplo.dart';
import 'package:aurora/data/habitos_repo.dart';
import 'package:aurora/data/tarefas_repo.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late BancoAurora db;

  setUpAll(() async {
    iniciarRelogio();
    await initializeDateFormatting('pt_BR');
  });

  setUp(() async {
    db = BancoAurora(NativeDatabase.memory());
    await semearExemplo(db);
  });

  tearDown(() => db.close());

  test('tarefas: conclusões por dia, semana e prazo', () async {
    final repo = TarefasRepo(db);
    final hoje = hojeLocal();
    // Tarefa de hoje sem hora: só fica atrasada quando o dia acaba. A de
    // exemplo vence às 21h e, depois disso, o teste não achava nenhuma.
    await db.into(db.tarefas).insert(TarefasCompanion.insert(
          titulo: 'Tarefa do teste',
          prazo: Value(instanteLocal(hoje)),
        ));
    final antes = await repo.carregar();
    final base = analisarTarefas(antes, hoje);
    expect(base.porDia, hasLength(14));
    expect(base.porDia.last.dia, hoje);

    // Concluir uma tarefa única com prazo hoje conta na semana e no prazo.
    final unica = antes.pendentes.firstWhere((o) => o.tarefa.titulo == 'Tarefa do teste');
    expect(unica.recorrente || unica.atrasada || unica.dia != hoje, isFalse);
    await repo.alternar(unica, true);
    final a = analisarTarefas(await repo.carregar(), hoje);
    expect(a.porDia.last.feitas, base.porDia.last.feitas + 1);
    expect(a.semana, base.semana + 1);
    expect(a.comPrazo, base.comPrazo + 1);
    expect(a.noPrazo, base.noPrazo + 1);
    // Uma conclusão só ainda não define o dia que rende mais.
    expect(a.melhorDiaSemana, isNull);
    expect(a.abertasPorPrioridade.values.fold(0, (s, n) => s + n), (await repo.carregar()).abertas);
  });

  test('hábitos: constância, sequência e recorde', () async {
    final repo = HabitosRepo(db);
    final hoje = hojeLocal();
    final cardio = (await repo.carregar()).habitos.firstWhere((h) => h.nome == 'Cardio');
    // Hábito criado há 10 dias, feito nos últimos 3 (ontem incluso) e hoje.
    await (db.update(db.habitos)..where((h) => h.id.equals(cardio.id)))
        .write(HabitosCompanion(criadoEm: Value(instanteLocal(hoje.subtract(const Duration(days: 10))))));
    for (var i = 0; i <= 3; i++) {
      await repo.alternar(cardio.id, hoje.subtract(Duration(days: i)), true);
    }
    final q = await repo.carregar();
    final a = analisarHabitos(q, hoje);
    final c = a.habitos.firstWhere((h) => h.habito.id == cardio.id);
    expect(c.sequencia, 4);
    expect(c.melhorSequencia, 4);
    expect(c.feitos, 4);
    expect(c.taxa, greaterThan(0));
    expect(c.taxa, lessThanOrEqualTo(1));
    expect(a.porDia, hasLength(14));
    expect(a.taxa30, isNotNull);
  });
}
