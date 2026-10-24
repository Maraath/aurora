import 'banco.dart';
import 'habitos_repo.dart';
import '../core/relogio.dart';

/// Constância de um hábito nos últimos 30 dias.
class ConstanciaHabito {
  const ConstanciaHabito({
    required this.habito,
    required this.feitos,
    required this.devidos,
    required this.sequencia,
    required this.melhorSequencia,
  });

  final Habito habito;
  final int feitos;
  final int devidos;
  final int sequencia;
  final int melhorSequencia;

  double get taxa => devidos == 0 ? 0 : feitos / devidos;
}

/// Números da aba "Análise" de Hábitos.
class AnaliseHabitos {
  const AnaliseHabitos({
    required this.porDia,
    required this.taxa30,
    required this.habitos,
    required this.melhorDiaSemana,
  });

  /// Progresso (0 a 1) de cada um dos últimos 14 dias; nulo = nenhum hábito no dia.
  final List<({DateTime dia, double? progresso})> porDia;

  /// Média do progresso diário nos últimos 30 dias (nulo sem hábitos).
  final double? taxa30;

  /// Do mais constante para o menos.
  final List<ConstanciaHabito> habitos;

  /// Dia da semana (1 = segunda) com a melhor média nos últimos 60 dias.
  final int? melhorDiaSemana;
}

AnaliseHabitos analisarHabitos(QuadroHabitos q, DateTime hoje) {
  List<DateTime> ultimos(int n) => [for (var i = n - 1; i >= 0; i--) somarDias(hoje, -i)];

  final dias30 = ultimos(30);
  // Hoje fica de fora da média: o dia ainda está em andamento.
  final progressos30 = [for (final d in dias30) if (d != hoje) q.progresso(d)].whereType<double>().toList();

  final somaDia = <int, double>{}, contaDia = <int, int>{};
  for (final d in ultimos(60)) {
    final p = q.progresso(d);
    if (p == null || d == hoje) continue; // hoje ainda está em andamento
    somaDia[d.weekday] = (somaDia[d.weekday] ?? 0) + p;
    contaDia[d.weekday] = (contaDia[d.weekday] ?? 0) + 1;
  }
  int? melhorDia;
  var melhorMedia = -1.0;
  // Só com pelo menos duas semanas daquele dia, para não tirar conclusão de um dia só.
  for (final dia in somaDia.keys.where((d) => contaDia[d]! >= 2)) {
    final media = somaDia[dia]! / contaDia[dia]!;
    if (media > melhorMedia) {
      melhorMedia = media;
      melhorDia = dia;
    }
  }

  final constancias = [
    for (final h in q.habitos)
      () {
        var feitos = 0, devidos = 0;
        for (final d in dias30) {
          if (!q.doDia(d).contains(h)) continue;
          // Hoje só conta se já foi feito: o dia ainda não acabou.
          final feito = q.feito(h.id, d);
          if (d == hoje && !feito) continue;
          devidos++;
          if (feito) feitos++;
        }
        var melhor = 0, atual = 0;
        for (final d in ultimos(365)) {
          if (!q.doDia(d).contains(h)) continue;
          if (q.feito(h.id, d)) {
            atual++;
            if (atual > melhor) melhor = atual;
          } else if (d != hoje) {
            atual = 0;
          }
        }
        return ConstanciaHabito(
          habito: h,
          feitos: feitos,
          devidos: devidos,
          sequencia: q.sequencia(h, hoje),
          melhorSequencia: melhor,
        );
      }(),
  ]..sort((a, b) => b.taxa.compareTo(a.taxa));

  return AnaliseHabitos(
    porDia: [for (final d in ultimos(14)) (dia: d, progresso: q.progresso(d))],
    taxa30: progressos30.isEmpty ? null : progressos30.reduce((a, b) => a + b) / progressos30.length,
    habitos: constancias,
    melhorDiaSemana: melhorDia,
  );
}
