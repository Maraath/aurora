import '../core/relogio.dart';
import 'banco.dart';
import 'tarefas_repo.dart';

/// Números da aba "Análise" de Tarefas.
class AnaliseTarefas {
  const AnaliseTarefas({
    required this.porDia,
    required this.semana,
    required this.semanaAnterior,
    required this.noPrazo,
    required this.comPrazo,
    required this.abertasPorPrioridade,
    required this.melhorDiaSemana,
  });

  /// Conclusões em cada um dos últimos 14 dias (o último é hoje).
  final List<({DateTime dia, int feitas})> porDia;
  final int semana;
  final int semanaAnterior;

  /// Das tarefas com prazo concluídas nos últimos 30 dias, quantas no prazo.
  final int noPrazo;
  final int comPrazo;
  final Map<Prioridade, int> abertasPorPrioridade;

  /// Dia da semana (1 = segunda) com mais conclusões nos últimos 60 dias.
  final int? melhorDiaSemana;

  double? get taxaNoPrazo => comPrazo == 0 ? null : noPrazo / comPrazo;
}

AnaliseTarefas analisarTarefas(QuadroTarefas q, DateTime hoje) {
  // Cada conclusão vira um dia: a tarefa única pela data em que foi feita,
  // a recorrente por cada dia marcado.
  final feitas = <DateTime>[];
  var noPrazo = 0, comPrazo = 0;
  final limite30 = somarDias(hoje, -29);
  for (final t in q.tarefas) {
    if (t.regraRepeticao == null) {
      if (t.feitaEm == null) continue;
      final dia = dataLocal(t.feitaEm!);
      feitas.add(dia);
      if (t.prazo != null && !dia.isBefore(limite30)) {
        comPrazo++;
        final prazo = t.prazoTemHora ? t.prazo! : instanteLocal(dataLocal(t.prazo!), 23, 59);
        if (!t.feitaEm!.isAfter(prazo)) noPrazo++;
      }
    } else {
      for (final chave in q.conclusoes[t.id] ?? const <String>{}) {
        feitas.add(DateTime.parse(chave));
      }
    }
  }

  int contar(DateTime de, DateTime ate) =>
      feitas.where((d) => !d.isBefore(de) && !d.isAfter(ate)).length;

  final porDiaSemana = <int, int>{};
  final limite60 = somarDias(hoje, -59);
  for (final d in feitas.where((d) => !d.isBefore(limite60) && !d.isAfter(hoje))) {
    porDiaSemana[d.weekday] = (porDiaSemana[d.weekday] ?? 0) + 1;
  }
  final melhor = porDiaSemana.entries.fold<MapEntry<int, int>?>(
      null, (m, e) => m == null || e.value > m.value ? e : m);

  final abertas = {for (final p in Prioridade.values) p: 0};
  for (final o in q.pendentes) {
    abertas[o.tarefa.prioridade] = abertas[o.tarefa.prioridade]! + 1;
  }

  return AnaliseTarefas(
    porDia: [
      for (var i = 13; i >= 0; i--)
        () {
          final d = somarDias(hoje, -i);
          return (dia: d, feitas: contar(d, d));
        }(),
    ],
    semana: contar(somarDias(hoje, -6), hoje),
    semanaAnterior: contar(somarDias(hoje, -13), somarDias(hoje, -7)),
    noPrazo: noPrazo,
    comPrazo: comPrazo,
    abertasPorPrioridade: abertas,
    // Com poucas conclusões o "melhor dia" seria acaso.
    melhorDiaSemana: porDiaSemana.values.fold(0, (s, n) => s + n) >= 5 ? melhor?.key : null,
  );
}
