import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../core/formato.dart';
import '../core/recorrencia.dart';
import '../core/relogio.dart';
import 'banco.dart';
import 'observar.dart';
import 'tarefas_repo.dart';

/// Sem nenhum avanço nem tarefa ligada feita por esse tempo, o objetivo está parado.
const diasParaParada = 14;

enum EstadoObjetivo {
  emDia('Em dia'),
  emRisco('Em risco'),
  parada('Parada'),
  pausada('Pausada'),
  concluida('Concluída'),
  arquivada('Arquivada');

  const EstadoObjetivo(this.rotulo);
  final String rotulo;
}

/// Medidas que o formulário oferece; qualquer outro texto é unidade livre.
const unidadesMeta = ['R\$', 'kg', 'km', 'livros'];

/// Cores que o formulário oferece (chave → token do tema).
const coresObjetivo = ['accent', 'teal', 'violeta', 'warn'];

bool ehDinheiro(String unidade) => unidade == 'R\$';

/// "R$ 1.000,00", "74 kg", "3 livros". Valores em R$ guardam centavos.
String valorMeta(double v, String unidade) {
  if (ehDinheiro(unidade)) return reais(v.round());
  return '${numero(v)} $unidade'.trim();
}

/// Converte o que se digitou para o que se grava (centavos quando R$).
double? lerValorMeta(String texto, String unidade) {
  final v = lerNumero(texto);
  if (v == null) return null;
  return ehDinheiro(unidade) ? (v * 100).roundToDouble() : v;
}

/// Valor gravado → texto do campo.
String valorParaCampo(double v, String unidade) =>
    ehDinheiro(unidade) ? centavosParaCampo(v.round()) : numero(v);

/// "Para aumentar 6 kg até 31 de dezembro, são cerca de 0,5 kg por semana.
/// Faltam 76 dias." Nulo quando não dá para calcular.
String? ritmoMeta({
  required double atual,
  required double alvo,
  required String unidade,
  required DateTime dataAlvo,
  required DateTime hoje,
}) {
  final dias = diasEntre(hoje, dataAlvo);
  if (dias <= 0 || atual == alvo) return null;
  final falta = (alvo - atual).abs();
  final semanas = math.max(dias / 7, 1);
  final porSemana = falta / semanas;
  final verbo = alvo > atual ? 'aumentar' : 'reduzir';
  final mensal = ehDinheiro(unidade) && dias >= 45
      ? ' (cerca de ${valorMeta(falta / (dias / 30.4), unidade)} por mês)'
      : '';
  return 'Para $verbo ${valorMeta(falta, unidade)} até ${diaMesLongo(dataAlvo)}, '
      'são cerca de ${valorMeta(porSemana, unidade)} por semana$mensal. '
      'Faltam $dias ${dias == 1 ? 'dia' : 'dias'}.';
}

/// Etapa de um objetivo: a ocorrência atual de uma tarefa ligada a ele.
class EtapaObjetivo {
  const EtapaObjetivo(this.ocorrencia);

  final OcorrenciaTarefa ocorrencia;

  Tarefa get tarefa => ocorrencia.tarefa;
  bool get rotina => ocorrencia.recorrente;
  bool get feita => !rotina && tarefa.feitaEm != null;
  bool get atrasada => ocorrencia.atrasada;
}

class ProgressoObjetivo {
  const ProgressoObjetivo({
    required this.objetivo,
    required this.estado,
    required this.progresso,
    required this.tempo,
    required this.ritmo,
    required this.etapas,
    required this.tarefasAbertas,
    required this.tarefasLigadas,
    required this.habitosLigados,
    required this.ultimaAtividade,
    required this.hoje,
  });

  final Objetivo objetivo;
  final EstadoObjetivo estado;

  /// Progresso principal (0 a 1): o número quando há unidade, senão as etapas.
  final double progresso;

  /// Quanto do prazo já passou (0 a 1), nulo sem data-alvo.
  final double? tempo;
  final String? ritmo;
  final List<EtapaObjetivo> etapas;
  final int tarefasAbertas;
  final int tarefasLigadas;
  final int habitosLigados;
  final DateTime ultimaAtividade;
  final DateTime hoje;

  bool get temNumero => objetivo.unidade.isNotEmpty;
  bool get temEtapas => etapas.isNotEmpty || tarefasLigadas > 0;

  /// Etapas que contam no progresso (tarefas recorrentes são "rotina").
  List<EtapaObjetivo> get contaveis => etapas.where((e) => !e.rotina).toList();
  int get feitas => contaveis.where((e) => e.feita).length;
  int get total => contaveis.length;
  double get progressoEtapas => total == 0 ? 0 : feitas / total;

  DateTime get inicio => objetivo.inicio == null ? dataLocal(objetivo.criadoEm) : dataLocal(objetivo.inicio!);
  DateTime? get fim => objetivo.dataAlvo == null ? null : dataLocal(objetivo.dataAlvo!);
  int get diasRestantes => fim == null ? 0 : diasEntre(hoje, fim!);

  String get textoPrazo {
    if (estado == EstadoObjetivo.concluida) return 'concluído';
    if (fim == null) return 'sem prazo';
    final d = diasRestantes;
    if (d < 0) return 'prazo passou há ${-d} ${d == -1 ? 'dia' : 'dias'}';
    if (d == 0) return 'termina hoje';
    return 'faltam $d ${d == 1 ? 'dia' : 'dias'}';
  }
}

/// Estado de um objetivo pelo valor/etapas e pelo prazo.
EstadoObjetivo estadoObjetivo(
  Objetivo o, {
  required DateTime hoje,
  required DateTime ultimaAtividade,
  required double progresso,
  required double? tempo,
  required List<EtapaObjetivo> etapas,
}) {
  switch (o.status) {
    case 'arquivada':
      return EstadoObjetivo.arquivada;
    case 'pausada':
      return EstadoObjetivo.pausada;
    case 'concluida':
      return EstadoObjetivo.concluida;
  }
  final contaveis = etapas.where((e) => !e.rotina).toList();
  final feitas = contaveis.where((e) => e.feita).length;
  if (o.unidade.isNotEmpty && progresso >= 1) return EstadoObjetivo.concluida;
  if (contaveis.isNotEmpty && feitas == contaveis.length) return EstadoObjetivo.concluida;
  if (diasEntre(dataLocal(ultimaAtividade), hoje) >= diasParaParada) return EstadoObjetivo.parada;
  if (etapas.any((e) => e.atrasada)) return EstadoObjetivo.emRisco;
  if (o.dataAlvo != null && hoje.isAfter(dataLocal(o.dataAlvo!))) return EstadoObjetivo.emRisco;
  if (tempo != null && o.unidade.isNotEmpty && progresso < tempo - 0.1) {
    return EstadoObjetivo.emRisco;
  }
  if (tempo != null && o.unidade.isEmpty && tempo > 0.33) {
    final p = contaveis.isEmpty ? 0.0 : feitas / contaveis.length;
    if (p < tempo - 0.25) return EstadoObjetivo.emRisco;
  }
  return EstadoObjetivo.emDia;
}

/// Texto curto da etapa: "feita", "atrasada 3 dias", "sex, 23 out · 14:00", "sem data", "rotina · todo dia".
String detalheEtapa(EtapaObjetivo e, DateTime hoje) {
  final o = e.ocorrencia;
  if (e.rotina) {
    final regra = Regra.ler(e.tarefa.regraRepeticao);
    return 'rotina · ${regra?.descricao.toLowerCase() ?? ''}';
  }
  if (e.feita) return 'feita ${diaRelativo(dataLocal(e.tarefa.feitaEm!), hoje)}';
  if (o.dia == null) return 'sem data';
  if (e.atrasada) {
    final dias = diasEntre(o.dia!, hoje);
    return dias <= 0 ? 'atrasada' : 'atrasada $dias ${dias == 1 ? 'dia' : 'dias'}';
  }
  final h = o.horario;
  return '${diaRelativo(o.dia!, hoje)}${h == null ? '' : ' · ${horaDe(h.hora, h.minuto)}'}';
}

class ObjetivosRepo {
  ObjetivosRepo(this.db);
  final BancoAurora db;

  Stream<List<ProgressoObjetivo>> observarObjetivos() => observar(db, [
        db.objetivos,
        db.tarefas,
        db.conclusoesTarefa,
        db.habitos,
        db.registrosHabito,
      ], carregar);

  /// Ativos primeiro (pela data-alvo), concluídos e arquivados no fim.
  Future<List<ProgressoObjetivo>> carregar() async {
    final hoje = hojeLocal();
    final objetivos = await (db.select(db.objetivos)..where((o) => o.apagadoEm.isNull())).get();
    final tarefas = await (db.select(db.tarefas)
          ..where((t) => t.apagadoEm.isNull() & t.objetivoId.isNotNull()))
        .get();
    final habitos = await (db.select(db.habitos)
          ..where((h) => h.apagadoEm.isNull() & h.objetivoId.isNotNull()))
        .get();
    final objetivoDaTarefa = {for (final t in tarefas) t.id: t.objetivoId!};
    final objetivoDoHabito = {for (final h in habitos) h.id: h.objetivoId!};

    // Última atividade de cada objetivo: edição dele ou algo ligado feito.
    final atividade = {for (final o in objetivos) o.id: o.atualizadoEm};
    void marcar(String? objetivoId, DateTime quando) {
      if (objetivoId == null || !atividade.containsKey(objetivoId)) return;
      if (quando.isAfter(atividade[objetivoId]!)) atividade[objetivoId] = quando;
    }

    for (final t in tarefas) {
      if (t.feitaEm != null) marcar(t.objetivoId, t.feitaEm!);
    }
    if (objetivoDaTarefa.isNotEmpty) {
      final conclusoes = await (db.select(db.conclusoesTarefa)
            ..where((c) => c.apagadoEm.isNull() & c.tarefaId.isIn(objetivoDaTarefa.keys)))
          .get();
      for (final c in conclusoes) {
        marcar(objetivoDaTarefa[c.tarefaId], c.criadoEm);
      }
    }
    if (objetivoDoHabito.isNotEmpty) {
      final registros = await (db.select(db.registrosHabito)
            ..where((r) =>
                r.apagadoEm.isNull() & r.feito.equals(true) & r.habitoId.isIn(objetivoDoHabito.keys)))
          .get();
      for (final r in registros) {
        marcar(objetivoDoHabito[r.habitoId], r.criadoEm);
      }
    }

    // Etapas: a ocorrência atual de cada tarefa ligada (inclui as feitas).
    final quadro = await TarefasRepo(db).carregar();
    final porObjetivo = <String, List<EtapaObjetivo>>{};
    for (final t in quadro.tarefas) {
      final oid = t.objetivoId;
      if (oid == null) continue;
      final atual = quadro.atuais.where((o) => o.tarefa.id == t.id).firstOrNull ??
          OcorrenciaTarefa(
            tarefa: t,
            dia: t.prazo == null ? null : dataLocal(t.prazo!),
            feita: t.feitaEm != null,
            atrasada: false,
          );
      porObjetivo.putIfAbsent(oid, () => []).add(EtapaObjetivo(atual));
    }

    final lista = [
      for (final o in objetivos)
        () {
          final etapas = (porObjetivo[o.id] ?? [])..sort(_ordemEtapas);
          final inicio = o.inicio == null ? dataLocal(o.criadoEm) : dataLocal(o.inicio!);
          final alvo = o.dataAlvo == null ? null : dataLocal(o.dataAlvo!);
          double? tempo;
          if (alvo != null) {
            final total = diasEntre(inicio, alvo);
            tempo = total <= 0 ? 1.0 : (diasEntre(inicio, hoje) / total).clamp(0.0, 1.0);
          }
          final contaveis = etapas.where((e) => !e.rotina).toList();
          final feitas = contaveis.where((e) => e.feita).length;
          final progressoNumero = o.unidade.isEmpty || o.valorAlvo == o.valorInicial
              ? 1.0
              : ((o.valorAtual - o.valorInicial) / (o.valorAlvo - o.valorInicial)).clamp(0.0, 1.0);
          final progressoEtapas = contaveis.isEmpty ? 0.0 : feitas / contaveis.length;
          final progresso = o.unidade.isNotEmpty ? progressoNumero : progressoEtapas;
          final estado = estadoObjetivo(
            o,
            hoje: hoje,
            ultimaAtividade: atividade[o.id]!,
            progresso: progressoNumero,
            tempo: tempo,
            etapas: etapas,
          );
          return ProgressoObjetivo(
            objetivo: o,
            estado: estado,
            progresso: progresso,
            tempo: tempo,
            ritmo: o.unidade.isEmpty ||
                    estado == EstadoObjetivo.concluida ||
                    alvo == null
                ? null
                : ritmoMeta(
                    atual: o.valorAtual, alvo: o.valorAlvo, unidade: o.unidade, dataAlvo: alvo, hoje: hoje),
            etapas: etapas,
            tarefasAbertas: tarefas
                .where((t) => t.objetivoId == o.id && (t.feitaEm == null || t.regraRepeticao != null))
                .length,
            tarefasLigadas: tarefas.where((t) => t.objetivoId == o.id).length,
            habitosLigados: habitos.where((h) => h.objetivoId == o.id).length,
            ultimaAtividade: atividade[o.id]!,
            hoje: hoje,
          );
        }(),
    ];
    lista.sort((a, b) {
      int peso(EstadoObjetivo e) => switch (e) {
            EstadoObjetivo.emRisco || EstadoObjetivo.emDia || EstadoObjetivo.parada || EstadoObjetivo.pausada => 0,
            EstadoObjetivo.concluida => 1,
            EstadoObjetivo.arquivada => 2,
          };
      final c = peso(a.estado).compareTo(peso(b.estado));
      if (c != 0) return c;
      final da = a.objetivo.dataAlvo, db_ = b.objetivo.dataAlvo;
      if (da != null && db_ != null) return da.compareTo(db_);
      if ((da == null) != (db_ == null)) return da == null ? 1 : -1;
      return a.objetivo.nome.compareTo(b.objetivo.nome);
    });
    return lista;
  }

  /// Pendentes primeiro (atrasadas, depois por data), rotinas, e as feitas no fim.
  static int _ordemEtapas(EtapaObjetivo a, EtapaObjetivo b) {
    int grupo(EtapaObjetivo e) => e.feita ? 2 : (e.rotina ? 1 : 0);
    final g = grupo(a).compareTo(grupo(b));
    if (g != 0) return g;
    if (a.atrasada != b.atrasada) return a.atrasada ? -1 : 1;
    final da = a.ocorrencia.dia, db_ = b.ocorrencia.dia;
    if (da != null && db_ != null && da != db_) return da.compareTo(db_);
    if ((da == null) != (db_ == null)) return da == null ? 1 : -1;
    return a.tarefa.criadoEm.compareTo(b.tarefa.criadoEm);
  }

  Future<String> salvar(ObjetivosCompanion dados, {String? id}) async {
    if (id == null) return (await db.into(db.objetivos).insertReturning(dados)).id;
    await (db.update(db.objetivos)..where((o) => o.id.equals(id)))
        .write(dados.copyWith(atualizadoEm: Value(DateTime.now())));
    return id;
  }

  /// Registra onde o objetivo está hoje (conta como atividade).
  Future<void> atualizarValor(String id, double valorAtual) =>
      (db.update(db.objetivos)..where((o) => o.id.equals(id))).write(
          ObjetivosCompanion(valorAtual: Value(valorAtual), atualizadoEm: Value(DateTime.now())));

  /// Muda o status (pausar, concluir, arquivar, reabrir…).
  Future<void> mudarStatus(String id, String status) =>
      (db.update(db.objetivos)..where((o) => o.id.equals(id))).write(
          ObjetivosCompanion(status: Value(status), atualizadoEm: Value(DateTime.now())));

  /// Nova etapa (uma tarefa ligada ao objetivo).
  Future<String> novaEtapa(String objetivoId, String titulo, {DateTime? dia}) => TarefasRepo(db).salvar(
        TarefasCompanion.insert(
          titulo: titulo,
          prazo: Value(dia == null ? null : instanteLocal(dia)),
          objetivoId: Value(objetivoId),
        ),
        avisar: false,
      );

  /// Conclui ou reabre uma etapa (delega para a tarefa).
  Future<void> alternarEtapa(EtapaObjetivo etapa, bool feita) =>
      TarefasRepo(db).alternar(etapa.ocorrencia, feita);

  /// Exclui o objetivo; as tarefas e hábitos continuam, só sem o vínculo.
  Future<void> excluir(String id) => db.transaction(() async {
        final agora = DateTime.now();
        await (db.update(db.tarefas)..where((t) => t.objetivoId.equals(id)))
            .write(TarefasCompanion(objetivoId: const Value(null), atualizadoEm: Value(agora)));
        await (db.update(db.habitos)..where((h) => h.objetivoId.equals(id)))
            .write(HabitosCompanion(objetivoId: const Value(null), atualizadoEm: Value(agora)));
        await (db.update(db.objetivos)..where((o) => o.id.equals(id)))
            .write(ObjetivosCompanion(apagadoEm: Value(agora), atualizadoEm: Value(agora)));
      });
}
