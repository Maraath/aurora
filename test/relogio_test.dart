import 'package:aurora/core/relogio.dart';
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

  test('fuso desconhecido cai no padrão', () {
    iniciarRelogio('Planeta/Marte');
    expect(fusoLocal.name, fusoPadrao);
  });
}
