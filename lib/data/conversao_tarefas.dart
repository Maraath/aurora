import 'package:drift/drift.dart';

import '../core/recorrencia.dart';
import '../core/relogio.dart';
import 'banco.dart';

/// Desde a Rotina (1.12) tarefa não repete: o que repete é hábito ou lembrete.
/// Cada tarefa com repetição vira:
/// - hábito, se repete todo dia ou em dias da semana (sem intervalo): os dias
///   concluídos viram registros do hábito e o aviso ligado passa para ele;
/// - lembrete repetido, nos outros casos (todo mês, a cada N semanas…).
/// Depois a tarefa é apagada.
///
/// Roda ao abrir e depois de cada sincronização (um aparelho com app antigo
/// ainda pode criar tarefa repetida). Os ids são naturais, iguais em todos os
/// aparelhos: dois aparelhos convertendo a mesma tarefa chegam às mesmas linhas.
/// Devolve quantas tarefas converteu.
Future<int> converterTarefasRepetidas(BancoAurora db) async {
  final tarefas = await (db.select(db.tarefas)
        ..where((t) => t.regraRepeticao.isNotNull() & t.apagadoEm.isNull()))
      .get();
  var n = 0;
  for (final t in tarefas) {
    final regra = Regra.ler(t.regraRepeticao);
    if (regra == null) continue;
    await db.transaction(() async {
      final agora = DateTime.now();
      final prazo = t.prazo == null ? null : emLocal(t.prazo!);
      final inicio = prazo == null ? dataLocal(t.criadoEm) : DateTime(prazo.year, prazo.month, prazo.day);
      final ligados = await (db.select(db.lembretes)
            ..where((l) => l.itemTipo.equals('tarefa') & l.itemId.equals(t.id) & l.apagadoEm.isNull()))
          .get();
      final viraHabito = regra.intervalo == 1 &&
          (regra.frequencia == Frequencia.diaria || regra.frequencia == Frequencia.semanal);

      if (viraHabito) {
        final dias = regra.frequencia == Frequencia.diaria
            ? todosOsDias
            : (regra.dias == 0 ? bitDoDiaDaSemana(inicio) : regra.dias);
        final habitoId = idNatural('habito_de_tarefa', [t.id]);
        final horario = prazo != null && t.prazoTemHora
            ? '${prazo.hour.toString().padLeft(2, '0')}:${prazo.minute.toString().padLeft(2, '0')}'
            : null;
        await db.into(db.habitos).insert(
              HabitosCompanion.insert(
                id: Value(habitoId),
                nome: t.titulo,
                diasSemana: Value(dias),
                horario: Value(horario),
                metaId: Value(t.metaId),
                // A data de criação da tarefa: o histórico e a sequência contam desde ela.
                criadoEm: Value(t.criadoEm),
              ),
              mode: InsertMode.insertOrIgnore,
            );
        final feitos = await (db.select(db.conclusoesTarefa)
              ..where((c) => c.tarefaId.equals(t.id) & c.apagadoEm.isNull()))
            .get();
        for (final c in feitos) {
          await db.into(db.registrosHabito).insert(
                RegistrosHabitoCompanion.insert(
                  id: Value(idNatural('registro_habito', [habitoId, c.dia])),
                  habitoId: habitoId,
                  dia: c.dia,
                ),
                mode: InsertMode.insertOrIgnore,
              );
        }
        for (final l in ligados) {
          await (db.update(db.lembretes)..where((x) => x.id.equals(l.id))).write(LembretesCompanion(
            itemTipo: const Value('habito'),
            itemId: Value(habitoId),
            regraRepeticao: Value(Regra.semanal(dias).rrule),
            atualizadoEm: Value(agora),
          ));
        }
      } else if (ligados.isNotEmpty) {
        // Já tinha aviso: ele vira o lembrete solto, com a mesma repetição.
        for (final l in ligados) {
          await (db.update(db.lembretes)..where((x) => x.id.equals(l.id))).write(LembretesCompanion(
            texto: Value(t.titulo),
            itemTipo: const Value(null),
            itemId: const Value(null),
            regraRepeticao: Value(regra.rrule),
            atualizadoEm: Value(agora),
          ));
        }
      } else {
        await db.into(db.lembretes).insert(
              LembretesCompanion.insert(
                id: Value(idNatural('lembrete_de_tarefa', [t.id])),
                texto: t.titulo,
                quando: prazo != null && t.prazoTemHora ? t.prazo! : instanteLocal(inicio, 9),
                regraRepeticao: Value(regra.rrule),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
      await (db.update(db.tarefas)..where((x) => x.id.equals(t.id)))
          .write(TarefasCompanion(apagadoEm: Value(agora), atualizadoEm: Value(agora)));
    });
    n++;
  }
  return n;
}
