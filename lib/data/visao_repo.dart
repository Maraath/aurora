import 'package:drift/drift.dart';

import '../core/relogio.dart';
import '../ui/visao/foco.dart';
import 'banco.dart';
import 'compromissos_repo.dart';
import 'financas_repo.dart';
import 'habitos_repo.dart';
import 'lembretes_repo.dart';
import 'observar.dart';
import 'saude_repo.dart';
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

enum TipoItemLinha { compromisso, tarefa, lembrete, conta, habito }

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

  /// Instante (fuso do aparelho); nulo = ao longo do dia.
  final DateTime? hora;
  final bool feito;
  final bool atrasado;

  /// Hábito: dá para marcar direto da linha.
  final String? habitoId;
}

/// Quantos compromissos cada dia da semana tem.
class DiaSemana {
  const DiaSemana(this.dia, {this.compromissos = 0, this.tarefas = 0, this.lembretes = 0, this.contas = 0});
  final DateTime dia;
  final int compromissos;
  final int tarefas;
  final int lembretes;
  final int contas;
  int get total => compromissos + tarefas + lembretes + contas;
}

/// Destaque de conquista ou alerta para o Raio-X Semanal.
class ItemDestaqueRaioX {
  const ItemDestaqueRaioX({
    required this.titulo,
    required this.detalhe,
    required this.tipo,
  });

  final String titulo;
  final String detalhe;
  final String tipo;
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
    required this.objetivo,
    this.saldoCentavos = 0,
    this.patrimonioCentavos = 0,
    this.compromissosHoje = const [],
    this.linha = const [],
    this.semana = const [],
    this.insights = const [],
    this.quadroHabitos,
    this.focoMinutosPorDia = const {},
    this.treinosFeitosSemana = 0,
    this.metaTreinosSemana = 0,
    this.scoreRitmo = 0,
    this.rotuloRitmo = 'Ritmo Firme ⚡',
    this.subtituloRitmo = 'Consistência equilibrada',
    this.taxaTarefas = 0,
    this.taxaHabitos = 0,
    this.vitorias = const [],
    this.atencoes = const [],
    this.totalMinutosFocoSemana = 0,
  });

  final String nome;
  final List<HabitoDoDia> habitos;

  /// Ocorrências pendentes de hoje.
  final List<OcorrenciaTarefa> tarefasHoje;
  final int tarefasAtrasadas;
  final int tarefasAbertas;
  final int aPagarCentavos;
  final int contasAPagar;
  final int saldoCentavos;
  final int patrimonioCentavos;
  final Objetivo? objetivo;

  /// Compromissos de hoje, em ordem (dia inteiro primeiro).
  final List<OcorrenciaCompromisso> compromissosHoje;

  /// Hoje em ordem de horário; o que não tem hora vai para o fim.
  final List<ItemLinha> linha;

  /// Hoje e os 6 dias seguintes.
  final List<DiaSemana> semana;

  /// Frases curtas tiradas dos dados ("3 tarefas atrasadas").
  final List<String> insights;

  /// Dados avançados para o Raio-X Semanal
  final QuadroHabitos? quadroHabitos;
  final Map<String, int> focoMinutosPorDia;
  final int treinosFeitosSemana;
  final int metaTreinosSemana;
  final int scoreRitmo;
  final String rotuloRitmo;
  final String subtituloRitmo;
  final double taxaTarefas;
  final double taxaHabitos;
  final List<ItemDestaqueRaioX> vitorias;
  final List<ItemDestaqueRaioX> atencoes;
  final int totalMinutosFocoSemana;

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
        db.objetivos,
        db.lembretes,
        db.compromissos,
        db.sessoesTreino,
        db.preferencias,
      ], carregar);

  Future<ResumoVisao> carregar() async {
    final agora = agoraLocal();
    final hoje = dataLocal(agora);
    final fimSemana = somarDias(hoje, 6);
    final inicioSemana = somarDias(hoje, -(hoje.weekday - 1));

    // As leituras não dependem umas das outras: saem todas juntas. Na web cada
    // consulta vai e volta do worker do banco, e em fila somava ~0,5 s no PC.
    final pedidoHabitos = habitos.carregar();
    final pedidoTarefas = _tarefas.carregar();
    final pedidoFinancas = _financas.carregar();
    final pedidoSaude = SaudeRepo(db).carregar();
    final pedidoHistoricoFoco = ControleFoco.carregarHistoricoMinutos(db);
    final pedidoLembretes = (db.select(db.lembretes)
          ..where((l) => l.apagadoEm.isNull() & l.ativo.equals(true) & l.itemTipo.isNull()))
        .get();
    final pedidoObjetivo = (db.select(db.objetivos)
          ..where((o) => o.status.equals('ativa') & o.unidade.isNotValue('') & o.apagadoEm.isNull())
          ..orderBy([(o) => OrderingTerm(expression: o.dataAlvo)])
          ..limit(1))
        .getSingleOrNull();
    final pedidoNome = db.preferencia('nome');
    final pedidoCompromissos = CompromissosRepo(db).carregar();

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

    final quadroSaude = await pedidoSaude;
    final historicoFoco = await pedidoHistoricoFoco;

    // Disparos de lembretes ativos de hoje até o fim da semana. Os ligados a
    // uma tarefa ou hábito ficam de fora: o próprio item já aparece.
    final lembretes = await pedidoLembretes;
    final inicioHoje = instanteLocal(hoje).subtract(const Duration(seconds: 1));
    final disparos = <DateTime, List<(Lembrete, DateTime)>>{};
    for (final l in lembretes) {
      for (final instante in ocorrenciasLembrete(l, inicioHoje, limite: 8)) {
        final d = dataLocal(instante);
        if (d.isAfter(fimSemana)) break;
        disparos.putIfAbsent(d, () => []).add((l, instante));
      }
    }

    final objetivo = await pedidoObjetivo;
    final compromissos = (await pedidoCompromissos).porDia(hoje, fimSemana);

    final linha = <ItemLinha>[
      for (final o in compromissos[hoje] ?? const <OcorrenciaCompromisso>[])
        ItemLinha(
          tipo: TipoItemLinha.compromisso,
          titulo: o.compromisso.titulo,
          hora: o.diaInteiro ? null : o.inicio,
          feito: o.terminou(agora),
        ),
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
          final d = somarDias(hoje, i);
          return DiaSemana(
            d,
            compromissos: (compromissos[d] ?? const []).length,
            tarefas: (tarefasPorDia[d] ?? const []).where((o) => !o.feita).length,
            lembretes: (disparos[d] ?? const []).length,
            contas: contas.where((o) => o.vencimento == d && !o.paga).length,
          );
        }(),
    ];

    // Cálculos para o Raio-X Semanal:
    var treinosFeitosSemana = 0;
    for (var i = 0; i < 7; i++) {
      final d = somarDias(inicioSemana, i);
      if (d.isAfter(hoje)) break;
      if (quadroSaude.diasComTreino.contains(chaveData(d))) {
        treinosFeitosSemana++;
      }
    }

    var metaTreinosSemana = 0;
    for (final t in quadroSaude.treinos) {
      if (t.treino.diasSemana > 0) {
        metaTreinosSemana += t.treino.diasSemana.toRadixString(2).split('1').length - 1;
      }
    }
    if (metaTreinosSemana == 0 && quadroSaude.treinos.isNotEmpty) {
      metaTreinosSemana = quadroSaude.treinos.length.clamp(1, 5);
    }

    var totalMinutosFocoSemana = 0;
    final focoMinutosPorDia = <String, int>{};
    for (var i = 0; i < 7; i++) {
      final d = somarDias(inicioSemana, i);
      final chave = chaveData(d);
      final min = historicoFoco[chave] ?? 0;
      focoMinutosPorDia[chave] = min;
      totalMinutosFocoSemana += min;
    }

    var habitosEsperadosSemana = 0;
    var habitosConcluidosSemana = 0;
    for (var i = 0; i < 7; i++) {
      final d = somarDias(inicioSemana, i);
      if (d.isAfter(hoje)) break;
      final listaDia = quadroHabitos.doDia(d);
      habitosEsperadosSemana += listaDia.length;
      for (final h in listaDia) {
        if (quadroHabitos.feito(h.id, d)) {
          habitosConcluidosSemana++;
        }
      }
    }
    final taxaHabitos = habitosEsperadosSemana == 0
        ? 1.0
        : (habitosConcluidosSemana / habitosEsperadosSemana).clamp(0.0, 1.0);

    final tarefasFeitasHoje = linha.where((i) => i.tipo == TipoItemLinha.tarefa && i.feito).length;
    final totalTarefasHoje = linha.where((i) => i.tipo == TipoItemLinha.tarefa).length;
    final taxaTarefas = totalTarefasHoje == 0 ? 1.0 : (tarefasFeitasHoje / totalTarefasHoje).clamp(0.0, 1.0);

    double somaScore = 0;
    double pesoTotal = 0;

    somaScore += taxaHabitos * 35;
    pesoTotal += 35;

    var pontuacaoTarefas = taxaTarefas;
    if (quadro.atrasadas > 0) {
      pontuacaoTarefas = (pontuacaoTarefas - (quadro.atrasadas * 0.1)).clamp(0.0, 1.0);
    }
    somaScore += pontuacaoTarefas * 30;
    pesoTotal += 30;

    if (metaTreinosSemana > 0) {
      final taxaTreino = (treinosFeitosSemana / metaTreinosSemana).clamp(0.0, 1.0);
      somaScore += taxaTreino * 20;
      pesoTotal += 20;
    } else {
      somaScore += taxaHabitos * 10 + pontuacaoTarefas * 10;
      pesoTotal += 20;
    }

    const metaMinutosFoco = 600;
    final taxaFoco = (totalMinutosFocoSemana / metaMinutosFoco).clamp(0.0, 1.0);
    somaScore += taxaFoco * 15;
    pesoTotal += 15;

    final scoreRitmo = ((somaScore / pesoTotal) * 100).round().clamp(0, 100);

    final (rotuloRitmo, subtituloRitmo) = switch (scoreRitmo) {
      >= 85 => ('Semana Imparável 🔥', 'Execução em nível de excelência'),
      >= 70 => ('Ritmo Forte ⚡', 'Constância e foco alinhados'),
      >= 50 => ('Ritmo Firme 🎯', 'Progresso consistente nas metas'),
      >= 30 => ('Construindo Força 🌱', 'Ganhando tração para avançar'),
      _ => ('Retomando o Foco 🧭', 'Bom momento para recalibrar o dia'),
    };

    final vitorias = <ItemDestaqueRaioX>[];
    final atencoes = <ItemDestaqueRaioX>[];

    if (metaTreinosSemana > 0 && treinosFeitosSemana >= metaTreinosSemana) {
      vitorias.add(ItemDestaqueRaioX(
        titulo: 'Meta de Treinos Atingida',
        detalhe: '$treinosFeitosSemana de $metaTreinosSemana sessões concluídas com disciplina.',
        tipo: 'treino',
      ));
    } else if (treinosFeitosSemana > 0) {
      vitorias.add(ItemDestaqueRaioX(
        titulo: 'Corpo em Movimento',
        detalhe: '$treinosFeitosSemana ${treinosFeitosSemana == 1 ? 'treino realizado' : 'treinos realizados'} na semana.',
        tipo: 'treino',
      ));
    }

    final destaquesHabitos = quadroHabitos.habitos.where((h) => quadroHabitos.sequencia(h, hoje) >= 3).toList();
    if (destaquesHabitos.isNotEmpty) {
      final h = destaquesHabitos.first;
      final seq = quadroHabitos.sequencia(h, hoje);
      vitorias.add(ItemDestaqueRaioX(
        titulo: 'Consistência de Hábito',
        detalhe: '$seq dias ininterruptos de "${h.nome}".',
        tipo: 'habito',
      ));
    } else if (taxaHabitos >= 0.75 && habitosEsperadosSemana > 0) {
      vitorias.add(ItemDestaqueRaioX(
        titulo: 'Rotina Blindada',
        detalhe: '${(taxaHabitos * 100).round()}% dos hábitos concluídos nesta semana.',
        tipo: 'habito',
      ));
    }

    if (totalMinutosFocoSemana >= 120) {
      final horas = totalMinutosFocoSemana ~/ 60;
      final mins = totalMinutosFocoSemana % 60;
      vitorias.add(ItemDestaqueRaioX(
        titulo: 'Hiper-Foco Acumulado',
        detalhe: '${horas}h ${mins > 0 ? '${mins}m ' : ''}de imersão profunda dedicada.',
        tipo: 'foco',
      ));
    }

    if (quadro.atrasadas == 0 && quadro.pendentes.isNotEmpty) {
      vitorias.add(const ItemDestaqueRaioX(
        titulo: 'Zero Atrasos',
        detalhe: 'Todas as tarefas planejadas para o período estão em dia.',
        tipo: 'tarefa',
      ));
    }

    if (vitorias.isEmpty) {
      vitorias.add(const ItemDestaqueRaioX(
        titulo: 'Ciclo em Andamento',
        detalhe: 'Cada pequeno bloco concluído constrói o seu momentum semanal.',
        tipo: 'geral',
      ));
    }

    if (quadro.atrasadas > 0) {
      atencoes.add(ItemDestaqueRaioX(
        titulo: '${quadro.atrasadas} ${quadro.atrasadas == 1 ? 'tarefa atrasada' : 'tarefas atrasadas'}',
        detalhe: 'Realoque os horários ou conclua para limpar a linha do tempo.',
        tipo: 'tarefa',
      ));
    }

    final contasVencendo = contas.where((o) => !o.paga && diasEntre(hoje, o.vencimento) <= 3).toList();
    if (mes.aPagar.any((o) => o.atrasada(hoje))) {
      final atrasadasContas = mes.aPagar.where((o) => o.atrasada(hoje)).length;
      atencoes.add(ItemDestaqueRaioX(
        titulo: '$atrasadasContas ${atrasadasContas == 1 ? 'conta vencida' : 'contas vencidas'}',
        detalhe: 'Pagamentos pendentes que precisam de atenção financeira.',
        tipo: 'financas',
      ));
    } else if (contasVencendo.isNotEmpty) {
      atencoes.add(ItemDestaqueRaioX(
        titulo: '${contasVencendo.length} ${contasVencendo.length == 1 ? 'conta vence em breve' : 'contas vencem em breve'}',
        detalhe: 'Próximos 3 dias com vencimentos financeiros programados.',
        tipo: 'financas',
      ));
    }

    for (final h in quadroHabitos.habitos) {
      final ontem = somarDias(hoje, -1);
      final anteontem = somarDias(hoje, -2);
      if (!quadroHabitos.feito(h.id, ontem) &&
          !quadroHabitos.feito(h.id, anteontem) &&
          quadroHabitos.doDia(ontem).any((item) => item.id == h.id)) {
        atencoes.add(ItemDestaqueRaioX(
          titulo: 'Atenção a "${h.nome}"',
          detalhe: '2 dias sem registro. Evite quebrar o hábito por um 3º dia consecutivo.',
          tipo: 'habito',
        ));
        break;
      }
    }

    if (metaTreinosSemana > 0 && treinosFeitosSemana == 0 && hoje.weekday >= 4) {
      atencoes.add(const ItemDestaqueRaioX(
        titulo: 'Treinos Pendentes',
        detalhe: 'A semana já passou da metade e nenhum treino foi registrado ainda.',
        tipo: 'treino',
      ));
    }

    if (atencoes.isEmpty) {
      atencoes.add(const ItemDestaqueRaioX(
        titulo: 'Radar Limpo',
        detalhe: 'Nenhum gargalo crítico detectado. Mantenha a velocidade de cruzeiro.',
        tipo: 'geral',
      ));
    }

    return ResumoVisao(
      nome: await pedidoNome ?? '',
      habitos: habitosHoje,
      tarefasHoje: quadro.pendentes.where((o) => o.dia == hoje).toList(),
      tarefasAtrasadas: quadro.atrasadas,
      tarefasAbertas: quadro.abertas,
      aPagarCentavos: mes.faltaPagarCentavos,
      contasAPagar: mes.contasAbertas,
      saldoCentavos: financas.saldoCentavos,
      patrimonioCentavos: financas.patrimonioCentavos,
      objetivo: objetivo,
      compromissosHoje: compromissos[hoje] ?? const [],
      linha: linha,
      semana: semana,
      insights: _insights(
        hoje: hoje,
        atrasadas: quadro.atrasadas,
        contasVencidas: mes.aPagar.where((o) => o.atrasada(hoje)).length,
        contasProximas: contas.where((o) => !o.paga && diasEntre(hoje, o.vencimento) <= 3).length,
        sequencias: {for (final h in quadroHabitos.habitos) h.nome: quadroHabitos.sequencia(h, hoje)},
        semana: semana,
      ),
      quadroHabitos: quadroHabitos,
      focoMinutosPorDia: focoMinutosPorDia,
      treinosFeitosSemana: treinosFeitosSemana,
      metaTreinosSemana: metaTreinosSemana,
      scoreRitmo: scoreRitmo,
      rotuloRitmo: rotuloRitmo,
      subtituloRitmo: subtituloRitmo,
      taxaTarefas: taxaTarefas,
      taxaHabitos: taxaHabitos,
      vitorias: vitorias,
      atencoes: atencoes,
      totalMinutosFocoSemana: totalMinutosFocoSemana,
    );
  }

  /// Marca ou desmarca o hábito hoje.
  Future<void> alternarHabito(String habitoId, bool feito) =>
      habitos.alternar(habitoId, hojeLocal(), feito);
}

/// "HH:mm" do hábito, no dia de hoje.
DateTime? _horario(String? texto, DateTime hoje) {
  final partes = texto?.split(':');
  if (partes == null || partes.length != 2) return null;
  final h = int.tryParse(partes[0]), m = int.tryParse(partes[1]);
  return h == null || m == null ? null : instanteLocal(hoje, h, m);
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
    lista.add('${_diasSemana[cheio.dia.weekday - 1]} é o dia mais cheio da semana (${cheio.total} itens).');
  }
  return lista.take(3).toList();
}
