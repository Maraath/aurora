import 'package:drift/drift.dart';

import '../core/relogio.dart';
import 'banco.dart';
import 'financas_repo.dart';
import 'habitos_repo.dart';
import 'lembretes_repo.dart';
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

enum TipoItemLinha { tarefa, lembrete, conta, habito }

/// Um compromisso de hoje na "Linha do dia".
class ItemLinha {
  const ItemLinha({
    required this.tipo,
    required this.titulo,
    this.hora,
    this.feito = false,
    this.atrasado = false,
    this.habitoId,
  });

  final TipoItemLinha tipo;
  final String titulo;

  /// Instante (São Paulo); nulo = ao longo do dia.
  final DateTime? hora;
  final bool feito;
  final bool atrasado;

  /// Hábito: dá para marcar direto da linha.
  final String? habitoId;
}

/// Quantos compromissos cada dia da semana tem.
class DiaSemana {
  const DiaSemana(this.dia, {this.tarefas = 0, this.lembretes = 0, this.contas = 0});
  final DateTime dia;
  final int tarefas;
  final int lembretes;
  final int contas;
  int get total => tarefas + lembretes + contas;
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
    this.linha = const [],
    this.semana = const [],
    this.insights = const [],
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

  /// Hoje em ordem de horário; o que não tem hora vai para o fim.
  final List<ItemLinha> linha;

  /// Hoje e os 6 dias seguintes.
  final List<DiaSemana> semana;

  /// Frases curtas tiradas dos dados ("3 tarefas atrasadas").
  final List<String> insights;

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
        db.lembretes,
      ], carregar);

  Future<ResumoVisao> carregar() async {
    final agora = agoraSP();
    final hoje = dataSP(agora);
    final fimSemana = hoje.add(const Duration(days: 6));

    // As leituras não dependem umas das outras: saem todas juntas. Na web cada
    // consulta vai e volta do worker do banco, e em fila somava ~0,5 s no PC.
    final pedidoHabitos = habitos.carregar();
    final pedidoTarefas = _tarefas.carregar();
    final pedidoFinancas = _financas.carregar();
    final pedidoLembretes = (db.select(db.lembretes)
          ..where((l) => l.apagadoEm.isNull() & l.ativo.equals(true) & l.itemTipo.isNull()))
        .get();
    final pedidoMeta = (db.select(db.metas)
          ..where((m) => m.status.equals('ativa') & m.apagadoEm.isNull())
          ..orderBy([(m) => OrderingTerm(expression: m.dataAlvo)])
          ..limit(1))
        .getSingleOrNull();
    final pedidoNome = db.preferencia('nome');

    final quadroHabitos = await pedidoHabitos;
    final habitosHoje = [
      for (final h in quadroHabitos.doDia(hoje))
        HabitoDoDia(habito: h, feito: quadroHabitos.feito(h.id, hoje)),
    ];

    final quadro = await pedidoTarefas;
    final tarefasPorDia = quadro.porDia(hoje, fimSemana, agora);

    final financas = await pedidoFinancas;
    final mes = financas.mes(hoje);
    final contas = [
      for (final t in financas.transacoes)
        for (final o in financas.ocorrencias(t, hoje, fimSemana))
          if (!o.entrada) o,
    ];

    // Disparos de lembretes ativos de hoje até o fim da semana. Os ligados a
    // uma tarefa ou hábito ficam de fora: o próprio item já aparece.
    final lembretes = await pedidoLembretes;
    final inicioHoje = instanteSP(hoje).subtract(const Duration(seconds: 1));
    final disparos = <DateTime, List<(Lembrete, DateTime)>>{};
    for (final l in lembretes) {
      for (final instante in ocorrenciasLembrete(l, inicioHoje, limite: 8)) {
        final d = dataSP(instante);
        if (d.isAfter(fimSemana)) break;
        disparos.putIfAbsent(d, () => []).add((l, instante));
      }
    }

    final meta = await pedidoMeta;

    final linha = <ItemLinha>[
      for (final o in tarefasPorDia[hoje] ?? const <OcorrenciaTarefa>[])
        ItemLinha(
          tipo: TipoItemLinha.tarefa,
          titulo: o.tarefa.titulo,
          hora: o.horario == null ? null : o.momento,
          feito: o.feita,
          atrasado: o.atrasada,
        ),
      for (final (l, instante) in disparos[hoje] ?? const <(Lembrete, DateTime)>[])
        ItemLinha(
          tipo: TipoItemLinha.lembrete,
          titulo: l.texto,
          hora: instante,
          feito: instante.isBefore(agora),
        ),
      for (final o in contas)
        if (o.vencimento == hoje)
          ItemLinha(tipo: TipoItemLinha.conta, titulo: o.nome, feito: o.paga),
      for (final h in habitosHoje)
        ItemLinha(
          tipo: TipoItemLinha.habito,
          titulo: h.habito.nome,
          hora: _horario(h.habito.horario, hoje),
          feito: h.feito,
          habitoId: h.habito.id,
        ),
    ]..sort(_compararLinha);

    final semana = [
      for (var i = 0; i < 7; i++)
        () {
          final d = hoje.add(Duration(days: i));
          return DiaSemana(
            d,
            tarefas: (tarefasPorDia[d] ?? const []).where((o) => !o.feita).length,
            lembretes: (disparos[d] ?? const []).length,
            contas: contas.where((o) => o.vencimento == d && !o.paga).length,
          );
        }(),
    ];

    return ResumoVisao(
      nome: await pedidoNome ?? '',
      habitos: habitosHoje,
      tarefasHoje: quadro.pendentes.where((o) => o.dia == hoje).toList(),
      tarefasAtrasadas: quadro.atrasadas,
      tarefasAbertas: quadro.abertas,
      aPagarCentavos: mes.faltaPagarCentavos,
      contasAPagar: mes.contasAbertas,
      meta: meta,
      linha: linha,
      semana: semana,
      insights: _insights(
        hoje: hoje,
        atrasadas: quadro.atrasadas,
        contasVencidas: mes.aPagar.where((o) => o.atrasada(hoje)).length,
        contasProximas: contas.where((o) => !o.paga && o.vencimento.difference(hoje).inDays <= 3).length,
        sequencias: {for (final h in quadroHabitos.habitos) h.nome: quadroHabitos.sequencia(h, hoje)},
        semana: semana,
      ),
    );
  }

  /// Marca ou desmarca o hábito hoje.
  Future<void> alternarHabito(String habitoId, bool feito) =>
      habitos.alternar(habitoId, hojeSP(), feito);
}

/// "HH:mm" do hábito, no dia de hoje.
DateTime? _horario(String? texto, DateTime hoje) {
  final partes = texto?.split(':');
  if (partes == null || partes.length != 2) return null;
  final h = int.tryParse(partes[0]), m = int.tryParse(partes[1]);
  return h == null || m == null ? null : instanteSP(hoje, h, m);
}

/// Com hora primeiro, em ordem; sem hora no fim, pendentes antes de feitos.
int _compararLinha(ItemLinha a, ItemLinha b) {
  if ((a.hora == null) != (b.hora == null)) return a.hora == null ? 1 : -1;
  if (a.hora != null && b.hora != null) return a.hora!.compareTo(b.hora!);
  if (a.feito != b.feito) return a.feito ? 1 : -1;
  return a.titulo.compareTo(b.titulo);
}

const _diasSemana = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];

/// Até três observações curtas, da mais urgente para a mais leve.
List<String> _insights({
  required DateTime hoje,
  required int atrasadas,
  required int contasVencidas,
  required int contasProximas,
  required Map<String, int> sequencias,
  required List<DiaSemana> semana,
}) {
  String plural(int n, String um, String varios) => n == 1 ? '1 $um' : '$n $varios';
  final lista = <String>[
    if (atrasadas > 0)
      '${plural(atrasadas, 'tarefa atrasada', 'tarefas atrasadas')}: vale resolver ou remarcar.'
    else
      'Nenhuma tarefa atrasada.',
    if (contasVencidas > 0)
      '${plural(contasVencidas, 'conta vencida', 'contas vencidas')} sem pagar neste mês.'
    else if (contasProximas > 0)
      '${plural(contasProximas, 'conta vence', 'contas vencem')} nos próximos 3 dias.',
  ];
  final melhor = sequencias.entries.where((e) => e.value >= 2).fold<MapEntry<String, int>?>(
      null, (m, e) => m == null || e.value > m.value ? e : m);
  if (melhor != null) lista.add('${melhor.value} dias seguidos de ${melhor.key}.');
  final cheio = semana.skip(1).fold<DiaSemana?>(null, (m, d) => m == null || d.total > m.total ? d : m);
  if (cheio != null && cheio.total >= 3) {
    lista.add('${_diasSemana[cheio.dia.weekday - 1]} é o dia mais cheio da semana (${cheio.total} compromissos).');
  }
  return lista.take(3).toList();
}
