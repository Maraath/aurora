import 'package:drift/drift.dart';

import '../core/relogio.dart';
import 'banco.dart';
import 'financas_repo.dart';
import 'habitos_repo.dart';
import 'observar.dart';
import 'tarefas_repo.dart';

class HabitoDoDia {
  const HabitoDoDia({required this.habito, required this.feito});
  final Habito habito;
  final bool feito;
}

class ItemFoco {
  const ItemFoco(this.titulo, this.detalhe);
  final String titulo;
  final String detalhe;
}

class ResumoVisao {
  const ResumoVisao({
    required this.nome,
    required this.habitos,
    required this.tarefasHoje,
    required this.tarefasAtrasadas,
    required this.tarefasAbertas,
    required this.aPagarCentavos,
    required this.contasAPagar,
    required this.meta,
  });

  final String nome;
  final List<HabitoDoDia> habitos;

  /// Ocorrências pendentes de hoje.
  final List<OcorrenciaTarefa> tarefasHoje;
  final int tarefasAtrasadas;
  final int tarefasAbertas;
  final int aPagarCentavos;
  final int contasAPagar;
  final Meta? meta;

  int get habitosFeitos => habitos.where((h) => h.feito).length;
}

class VisaoRepo {
  VisaoRepo(this.db)
      : _tarefas = TarefasRepo(db),
        _financas = FinancasRepo(db),
        habitos = HabitosRepo(db);
  final BancoAurora db;
  final TarefasRepo _tarefas;
  final FinancasRepo _financas;
  final HabitosRepo habitos;

  Stream<ResumoVisao> observarResumo() => observar(db, [
        db.habitos,
        db.registrosHabito,
        db.tarefas,
        db.conclusoesTarefa,
        db.transacoes,
        db.pagamentosTransacao,
        db.contasFinanceiras,
        db.metas,
      ], carregar);

  Future<ResumoVisao> carregar() async {
    final agora = agoraSP();
    final hoje = dataSP(agora);

    final quadroHabitos = await habitos.carregar();
    final habitosHoje = [
      for (final h in quadroHabitos.doDia(hoje))
        HabitoDoDia(habito: h, feito: quadroHabitos.feito(h.id, hoje)),
    ];

    final quadro = await _tarefas.carregar();

    final financas = await _financas.carregar();
    final mes = financas.mes(hoje);

    final meta = await (db.select(db.metas)
          ..where((m) => m.status.equals('ativa') & m.apagadoEm.isNull())
          ..orderBy([(m) => OrderingTerm(expression: m.dataAlvo)])
          ..limit(1))
        .getSingleOrNull();

    return ResumoVisao(
      nome: await db.preferencia('nome') ?? '',
      habitos: habitosHoje,
      tarefasHoje: quadro.pendentes.where((o) => o.dia == hoje).toList(),
      tarefasAtrasadas: quadro.atrasadas,
      tarefasAbertas: quadro.abertas,
      aPagarCentavos: mes.faltaPagarCentavos,
      contasAPagar: mes.contasAbertas,
      meta: meta,
    );
  }

  /// Marca ou desmarca o hábito hoje.
  Future<void> alternarHabito(String habitoId, bool feito) =>
      habitos.alternar(habitoId, hojeSP(), feito);
}
