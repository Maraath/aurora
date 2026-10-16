import 'package:aurora/core/recorrencia.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final inicio = DateTime(2026, 10, 16); // sexta

  test('lê e escreve RRULE', () {
    for (final texto in [
      'FREQ=DAILY',
      'FREQ=WEEKLY;BYDAY=MO,WE,FR',
      'FREQ=MONTHLY;BYMONTHDAY=11',
      'FREQ=DAILY;INTERVAL=2',
    ]) {
      expect(Regra.ler(texto)!.rrule, texto);
    }
    expect(Regra.ler(null), isNull);
    expect(Regra.ler('FREQ=YEARLY'), isNull);
  });

  test('todo dia, a cada 2 dias', () {
    const r = Regra.diaria();
    expect(r.ocorreEm(DateTime(2026, 10, 15), inicio), isFalse, reason: 'antes do início');
    expect(r.ocorreEm(DateTime(2026, 10, 20), inicio), isTrue);
    const r2 = Regra.diaria(intervalo: 2);
    expect(r2.ocorreEm(DateTime(2026, 10, 17), inicio), isFalse);
    expect(r2.ocorreEm(DateTime(2026, 10, 18), inicio), isTrue);
  });

  test('semanal: dias úteis e dias escolhidos', () {
    const uteis = Regra.semanal(diasUteis);
    expect(uteis.ocorrencias(inicio, inicio, DateTime(2026, 10, 22)).map((d) => d.day),
        [16, 19, 20, 21, 22]);
    final segQuaSex = Regra.ler('FREQ=WEEKLY;BYDAY=MO,WE,FR')!;
    expect(segQuaSex.proxima(inicio, DateTime(2026, 10, 17)), DateTime(2026, 10, 19));
  });

  test('mensal: dia 31 cai no último dia de meses curtos', () {
    const r = Regra.mensal(31);
    final jan = DateTime(2026, 1, 31);
    expect(r.ocorreEm(DateTime(2026, 2, 28), jan), isTrue);
    expect(r.ocorreEm(DateTime(2026, 4, 30), jan), isTrue);
    expect(r.ocorreEm(DateTime(2026, 4, 29), jan), isFalse);
  });

  test('descrições', () {
    expect(const Regra.diaria().descricao, 'Todo dia');
    expect(const Regra.semanal(diasUteis).descricao, 'Dias úteis');
    expect(Regra.semanal(bitDoDiaDaSemana(inicio)).descricao, 'Toda sexta');
    expect(Regra.ler('FREQ=WEEKLY;BYDAY=SU')!.descricao, 'Todo domingo');
    expect(Regra.ler('FREQ=WEEKLY;BYDAY=MO,WE,FR')!.descricao, 'Seg, qua e sex');
    expect(const Regra.mensal(9).descricao, 'Todo dia 9');
  });

  test('regra encerrada (UNTIL) para de gerar e sobrevive à leitura', () {
    final r = const Regra.mensal(10).encerradaEm(DateTime(2026, 12, 10));
    expect(r.rrule, 'FREQ=MONTHLY;BYMONTHDAY=10;UNTIL=20261210');
    final lida = Regra.ler(r.rrule)!;
    expect(lida, r);
    final dias = lida.ocorrencias(DateTime(2026, 10, 10), DateTime(2026, 10, 1), DateTime(2027, 6, 1));
    expect(dias, [DateTime(2026, 10, 10), DateTime(2026, 11, 10), DateTime(2026, 12, 10)]);
    expect(lida.descricao, 'Todo dia 10');
  });

  test('atravessa o fim do horário de verão sem pular dias', () {
    const r = Regra.diaria();
    final dias = r.ocorrencias(DateTime(2026, 10, 1), DateTime(2026, 10, 1), DateTime(2026, 11, 30));
    expect(dias.length, 61);
  });
}
