import 'dart:async';

import 'package:aurora/core/relogio.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/observar.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(iniciarRelogio);

  test('o dia de um instante segue o fuso escolhido', () {
    // 02:30 UTC de 10/03/2026: ainda dia 9 em São Paulo (UTC−3), já dia 10 em Lisboa.
    final instante = DateTime.utc(2026, 3, 10, 2, 30);

    iniciarRelogio();
    expect(chaveDia(instante), '2026-03-09');

    iniciarRelogio('Europe/Lisbon');
    expect(fusoLocal.name, 'Europe/Lisbon');
    expect(chaveDia(instante), '2026-03-10');

    iniciarRelogio('Asia/Tokyo');
    expect(instanteLocal(DateTime(2026, 3, 10), 9).toUtc(), DateTime.utc(2026, 3, 10, 0));
  });

  test('somarDias anda em dias de calendário, não em blocos de 24 h', () {
    expect(somarDias(DateTime(2026, 10, 24), 1), DateTime(2026, 10, 25));
    expect(somarDias(DateTime(2026, 10, 31), 1), DateTime(2026, 11, 1));
    expect(somarDias(DateTime(2026, 12, 31), 1), DateTime(2027, 1, 1));
    expect(somarDias(DateTime(2026, 3, 1), -1), DateTime(2026, 2, 28));
    // Uma semana a partir de sábado tem 7 dias diferentes, mesmo cruzando a troca
    // do horário de verão (em Lisboa, 25/10/2026 tem 25 horas).
    final semana = [for (var i = 0; i < 7; i++) somarDias(DateTime(2026, 10, 24), i).day];
    expect(semana, [24, 25, 26, 27, 28, 29, 30]);
  });

  test('fuso desconhecido cai no padrão', () {
    iniciarRelogio('Planeta/Marte');
    expect(fusoLocal.name, fusoPadrao);
  });

  test('observar recarrega quando o fuso muda (a pessoa viajou)', () async {
    iniciarRelogio();
    final db = BancoAurora(NativeDatabase.memory());
    addTearDown(db.close);
    final cargas = <String>[];
    final sub = observar(db, [db.tarefas], () async => fusoLocal.name).listen(cargas.add);
    // Sem esperar o cancelamento: o banco em memória do Drift demora a soltar a escuta nos testes.
    addTearDown(() => unawaited(sub.cancel()));
    await pumpEventQueue();
    expect(cargas, [fusoPadrao]);

    expect(mudarFuso('Europe/Lisbon'), isTrue);
    await pumpEventQueue();
    expect(cargas, [fusoPadrao, 'Europe/Lisbon']);

    // O mesmo fuso de novo não recarrega.
    expect(mudarFuso('Europe/Lisbon'), isFalse);
    await pumpEventQueue();
    expect(cargas, hasLength(2));
  });
}
