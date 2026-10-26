import '../core/recorrencia.dart';
import '../core/relogio.dart';
import 'banco.dart';
import 'compromissos_repo.dart';
import 'habitos_repo.dart';
import 'lembretes_repo.dart';
import 'observar.dart';
import 'tarefas_repo.dart';

/// Tudo o que a Rotina mostra (aba Hoje e Calendário), lido de uma vez:
/// compromissos, tarefas, hábitos e lembretes.
class QuadroRotina {
  const QuadroRotina({
    required this.tarefas,
    required this.habitos,
    required this.lembretes,
    required this.compromissos,
  });

  final QuadroTarefas tarefas;
  final QuadroHabitos habitos;
  final QuadroLembretes lembretes;
  final QuadroCompromissos compromissos;

  /// Coluna Fazer: atrasadas, as de hoje (pendentes, depois as feitas) e as sem data.
  List<OcorrenciaTarefa> fazer(DateTime hoje) => [
        ...tarefas.resolverAgora(hoje),
        ...tarefas.atuais.where((o) => o.dia == null && !o.feita),
      ];

  /// Lembretes soltos (não ligados a tarefa ou hábito) que tocam no [dia],
  /// com o horário do toque, em ordem.
  List<LembreteDoDia> lembretesDoDia(DateTime dia) {
    final lista = <LembreteDoDia>[];
    for (final v in lembretes.todos) {
      final l = v.lembrete;
      if (l.itemTipo != null) continue;
      final toque = toqueNoDia(l, dia);
      if (toque != null) lista.add(LembreteDoDia(v, toque));
    }
    lista.sort((a, b) => a.toque.compareTo(b.toque));
    return lista;
  }
}

class LembreteDoDia {
  const LembreteDoDia(this.visto, this.toque);
  final LembreteVisto visto;

  /// Instante do toque naquele dia.
  final DateTime toque;

  Lembrete get lembrete => visto.lembrete;
}

/// Instante em que o lembrete toca no [dia] (data de calendário), ou nulo.
DateTime? toqueNoDia(Lembrete l, DateTime dia) {
  final base = emLocal(l.quando);
  final inicio = DateTime(base.year, base.month, base.day);
  final regra = Regra.ler(l.regraRepeticao);
  final toca = regra == null ? inicio == dia : regra.ocorreEm(dia, inicio);
  return toca ? instanteLocal(dia, base.hour, base.minute) : null;
}

class RotinaRepo {
  RotinaRepo(this.db);
  final BancoAurora db;

  Stream<QuadroRotina> observarQuadro() => observar(
        db,
        [
          db.tarefas,
          db.conclusoesTarefa,
          db.habitos,
          db.registrosHabito,
          db.lembretes,
          db.compromissos,
          db.metas,
        ],
        carregar,
      );

  Future<QuadroRotina> carregar() async => QuadroRotina(
        tarefas: await TarefasRepo(db).carregar(),
        habitos: await HabitosRepo(db).carregar(),
        lembretes: await LembretesRepo(db).carregar(),
        compromissos: await CompromissosRepo(db).carregar(),
      );
}
