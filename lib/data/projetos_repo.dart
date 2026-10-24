import 'package:drift/drift.dart';

import '../core/formato.dart';
import '../core/recorrencia.dart';
import '../core/relogio.dart';
import 'banco.dart';
import 'observar.dart';
import 'tarefas_repo.dart';

enum EstadoProjeto {
  emDia('Em dia'),
  emRisco('Em risco'),
  concluido('Concluído'),
  arquivado('Arquivado');

  const EstadoProjeto(this.rotulo);
  final String rotulo;
}

class EtapaProjeto {
  const EtapaProjeto(this.ocorrencia);

  /// A tarefa por trás da etapa (a ocorrência atual, se for recorrente).
  final OcorrenciaTarefa ocorrencia;

  Tarefa get tarefa => ocorrencia.tarefa;
  bool get rotina => ocorrencia.recorrente;
  bool get feita => !rotina && tarefa.feitaEm != null;
  bool get atrasada => ocorrencia.atrasada;
}

class ProgressoProjeto {
  const ProgressoProjeto({
    required this.projeto,
    required this.etapas,
    required this.estado,
    required this.meta,
    required this.hoje,
  });

  final Projeto projeto;
  final List<EtapaProjeto> etapas;
  final EstadoProjeto estado;
  final Meta? meta;
  final DateTime hoje;

  DateTime get inicio => dataLocal(projeto.inicio);
  DateTime get fim => dataLocal(projeto.fim);

  /// Etapas que contam no progresso (tarefas recorrentes são "rotina").
  List<EtapaProjeto> get contaveis => etapas.where((e) => !e.rotina).toList();
  int get feitas => contaveis.where((e) => e.feita).length;
  int get total => contaveis.length;
  double get progresso => total == 0 ? 0 : feitas / total;

  /// Quanto do prazo já passou (0 a 1).
  double get tempo {
    final dias = diasEntre(inicio, fim);
    return dias <= 0 ? 1 : (diasEntre(inicio, hoje) / dias).clamp(0.0, 1.0);
  }

  int get diasRestantes => diasEntre(hoje, fim);

  String get textoPrazo {
    if (estado == EstadoProjeto.concluido) return 'concluído';
    final d = diasRestantes;
    if (d < 0) return 'prazo passou há ${-d} ${d == -1 ? 'dia' : 'dias'}';
    if (d == 0) return 'termina hoje';
    return 'faltam $d ${d == 1 ? 'dia' : 'dias'}';
  }
}

/// Estado de um projeto pelas etapas e pelo prazo.
EstadoProjeto estadoProjeto(Projeto p, List<EtapaProjeto> etapas, DateTime hoje) {
  if (p.status == 'arquivado') return EstadoProjeto.arquivado;
  final contaveis = etapas.where((e) => !e.rotina).toList();
  final feitas = contaveis.where((e) => e.feita).length;
  if (contaveis.isNotEmpty && feitas == contaveis.length) return EstadoProjeto.concluido;
  if (etapas.any((e) => e.atrasada)) return EstadoProjeto.emRisco;
  final inicio = dataLocal(p.inicio), fim = dataLocal(p.fim);
  if (hoje.isAfter(fim)) return EstadoProjeto.emRisco;
  final dias = diasEntre(inicio, fim);
  final tempo = dias <= 0 ? 1.0 : (diasEntre(inicio, hoje) / dias).clamp(0.0, 1.0);
  final progresso = contaveis.isEmpty ? 0.0 : feitas / contaveis.length;
  // Com mais de um terço do prazo andado, ficar 25 pontos atrás é risco.
  if (tempo > 0.33 && progresso < tempo - 0.25) return EstadoProjeto.emRisco;
  return EstadoProjeto.emDia;
}

/// Texto curto da etapa: "feita", "atrasada 3 dias", "sex, 23 out · 14:00", "sem data", "rotina · todo dia".
String detalheEtapa(EtapaProjeto e, DateTime hoje) {
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

class ProjetosRepo {
  ProjetosRepo(this.db);
  final BancoAurora db;

  Stream<List<ProgressoProjeto>> observarProjetos() =>
      observar(db, [db.projetos, db.tarefas, db.conclusoesTarefa, db.metas], carregar);

  /// Ativos primeiro (pelo fim), depois concluídos e arquivados.
  Future<List<ProgressoProjeto>> carregar() async {
    final hoje = hojeLocal();
    final projetos = await (db.select(db.projetos)..where((p) => p.apagadoEm.isNull())).get();
    final metas = {for (final m in await db.select(db.metas).get()) m.id: m};
    final quadro = await TarefasRepo(db).carregar();

    // Etapas: a ocorrência atual de cada tarefa ligada (inclui as feitas).
    final porProjeto = <String, List<EtapaProjeto>>{};
    for (final t in quadro.tarefas) {
      final pid = t.projetoId;
      if (pid == null) continue;
      final atual = quadro.atuais.where((o) => o.tarefa.id == t.id).firstOrNull ??
          OcorrenciaTarefa(
            tarefa: t,
            dia: t.prazo == null ? null : dataLocal(t.prazo!),
            feita: t.feitaEm != null,
            atrasada: false,
          );
      porProjeto.putIfAbsent(pid, () => []).add(EtapaProjeto(atual));
    }

    final lista = [
      for (final p in projetos)
        () {
          final etapas = (porProjeto[p.id] ?? [])..sort(_ordemEtapas);
          return ProgressoProjeto(
            projeto: p,
            etapas: etapas,
            estado: estadoProjeto(p, etapas, hoje),
            meta: metas[p.metaId],
            hoje: hoje,
          );
        }(),
    ];
    int peso(EstadoProjeto e) => switch (e) {
          EstadoProjeto.emRisco || EstadoProjeto.emDia => 0,
          EstadoProjeto.concluido => 1,
          EstadoProjeto.arquivado => 2,
        };
    lista.sort((a, b) {
      final c = peso(a.estado).compareTo(peso(b.estado));
      return c != 0 ? c : a.projeto.fim.compareTo(b.projeto.fim);
    });
    return lista;
  }

  /// Pendentes primeiro (atrasadas, depois por data), rotinas, e as feitas no fim.
  static int _ordemEtapas(EtapaProjeto a, EtapaProjeto b) {
    int grupo(EtapaProjeto e) => e.feita ? 2 : (e.rotina ? 1 : 0);
    final g = grupo(a).compareTo(grupo(b));
    if (g != 0) return g;
    if (a.atrasada != b.atrasada) return a.atrasada ? -1 : 1;
    final da = a.ocorrencia.dia, db_ = b.ocorrencia.dia;
    if (da != null && db_ != null && da != db_) return da.compareTo(db_);
    if ((da == null) != (db_ == null)) return da == null ? 1 : -1;
    return a.tarefa.criadoEm.compareTo(b.tarefa.criadoEm);
  }

  Future<String> salvar(ProjetosCompanion dados, {String? id}) async {
    if (id == null) return (await db.into(db.projetos).insertReturning(dados)).id;
    await (db.update(db.projetos)..where((p) => p.id.equals(id)))
        .write(dados.copyWith(atualizadoEm: Value(DateTime.now())));
    return id;
  }

  /// Nova etapa (uma tarefa ligada ao projeto).
  Future<String> novaEtapa(String projetoId, String titulo, {DateTime? dia}) => TarefasRepo(db).salvar(
        TarefasCompanion.insert(
          titulo: titulo,
          prazo: Value(dia == null ? null : instanteLocal(dia)),
          projetoId: Value(projetoId),
        ),
        avisar: false,
      );

  /// Exclui o projeto; as tarefas continuam, só sem o vínculo.
  Future<void> excluir(String id) => db.transaction(() async {
        final agora = DateTime.now();
        await (db.update(db.tarefas)..where((t) => t.projetoId.equals(id)))
            .write(TarefasCompanion(projetoId: const Value(null), atualizadoEm: Value(agora)));
        await (db.update(db.projetos)..where((p) => p.id.equals(id)))
            .write(ProjetosCompanion(apagadoEm: Value(agora), atualizadoEm: Value(agora)));
      });
}
