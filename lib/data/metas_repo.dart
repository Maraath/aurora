import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../core/formato.dart';
import '../core/relogio.dart';
import 'banco.dart';
import 'observar.dart';

/// Sem nenhum avanço nem tarefa/hábito ligado feito por esse tempo, a meta está parada.
const diasParaParada = 14;

enum EstadoMeta {
  nova('Nova'),
  emDia('Em dia'),
  emRisco('Em risco'),
  parada('Parada'),
  concluida('Concluída');

  const EstadoMeta(this.rotulo);
  final String rotulo;
}

/// Medidas que o formulário oferece; qualquer outro texto é unidade livre.
const unidadesMeta = ['R\$', 'kg', 'km', 'livros'];

bool ehDinheiro(String unidade) => unidade == 'R\$';

/// "R$ 1.000,00", "74 kg", "3 livros". Metas em R$ guardam centavos.
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

class ProgressoMeta {
  const ProgressoMeta({
    required this.meta,
    required this.estado,
    required this.progresso,
    required this.tempo,
    required this.ritmo,
    required this.tarefasAbertas,
    required this.tarefasLigadas,
    required this.habitosLigados,
    required this.ultimaAtividade,
  });

  final Meta meta;
  final EstadoMeta estado;

  /// 0 a 1: quanto do caminho (do valor inicial ao alvo) já foi feito.
  final double progresso;

  /// 0 a 1: quanto do prazo já passou (nulo sem data-alvo).
  final double? tempo;
  final String? ritmo;
  final int tarefasAbertas;
  final int tarefasLigadas;
  final int habitosLigados;
  final DateTime ultimaAtividade;
}

/// Calcula progresso, tempo e estado de uma meta.
ProgressoMeta calcularProgresso(
  Meta m, {
  required DateTime hoje,
  required DateTime ultimaAtividade,
  int tarefasAbertas = 0,
  int tarefasLigadas = 0,
  int habitosLigados = 0,
}) {
  final caminho = m.valorAlvo - m.valorInicial;
  final progresso =
      caminho == 0 ? 1.0 : ((m.valorAtual - m.valorInicial) / caminho).clamp(0.0, 1.0);
  final criada = dataSP(m.criadoEm);
  final alvo = m.dataAlvo == null ? null : dataSP(m.dataAlvo!);
  double? tempo;
  if (alvo != null) {
    final total = diasEntre(criada, alvo);
    tempo = total <= 0 ? 1.0 : (diasEntre(criada, hoje) / total).clamp(0.0, 1.0);
  }

  final EstadoMeta estado;
  if (m.status == 'concluida' || progresso >= 1) {
    estado = EstadoMeta.concluida;
  } else if (diasEntre(criada, hoje) < 7) {
    estado = EstadoMeta.nova;
  } else if (diasEntre(dataSP(ultimaAtividade), hoje) >= diasParaParada) {
    estado = EstadoMeta.parada;
  } else if (tempo != null && progresso < tempo - 0.1) {
    estado = EstadoMeta.emRisco;
  } else {
    estado = EstadoMeta.emDia;
  }

  return ProgressoMeta(
    meta: m,
    estado: estado,
    progresso: progresso,
    tempo: tempo,
    ritmo: alvo == null || estado == EstadoMeta.concluida
        ? null
        : ritmoMeta(
            atual: m.valorAtual, alvo: m.valorAlvo, unidade: m.unidade, dataAlvo: alvo, hoje: hoje),
    tarefasAbertas: tarefasAbertas,
    tarefasLigadas: tarefasLigadas,
    habitosLigados: habitosLigados,
    ultimaAtividade: ultimaAtividade,
  );
}

class MetasRepo {
  MetasRepo(this.db);
  final BancoAurora db;

  Stream<List<ProgressoMeta>> observarMetas() => observar(db, [
        db.metas,
        db.tarefas,
        db.conclusoesTarefa,
        db.habitos,
        db.registrosHabito,
      ], carregar);

  /// Metas ativas primeiro (pela data-alvo), concluídas no fim.
  Future<List<ProgressoMeta>> carregar() async {
    final hoje = hojeSP();
    final metas = await (db.select(db.metas)..where((m) => m.apagadoEm.isNull())).get();
    final tarefas = await (db.select(db.tarefas)
          ..where((t) => t.apagadoEm.isNull() & t.metaId.isNotNull()))
        .get();
    final habitos = await (db.select(db.habitos)
          ..where((h) => h.apagadoEm.isNull() & h.metaId.isNotNull()))
        .get();
    final metaDaTarefa = {for (final t in tarefas) t.id: t.metaId!};
    final metaDoHabito = {for (final h in habitos) h.id: h.metaId!};

    // Última atividade de cada meta: edição da meta ou algo ligado feito.
    final atividade = {for (final m in metas) m.id: m.atualizadoEm};
    void marcar(String? metaId, DateTime quando) {
      if (metaId == null || !atividade.containsKey(metaId)) return;
      if (quando.isAfter(atividade[metaId]!)) atividade[metaId] = quando;
    }

    for (final t in tarefas) {
      if (t.feitaEm != null) marcar(t.metaId, t.feitaEm!);
    }
    if (metaDaTarefa.isNotEmpty) {
      final conclusoes = await (db.select(db.conclusoesTarefa)
            ..where((c) => c.apagadoEm.isNull() & c.tarefaId.isIn(metaDaTarefa.keys)))
          .get();
      for (final c in conclusoes) {
        marcar(metaDaTarefa[c.tarefaId], c.criadoEm);
      }
    }
    if (metaDoHabito.isNotEmpty) {
      final registros = await (db.select(db.registrosHabito)
            ..where((r) =>
                r.apagadoEm.isNull() & r.feito.equals(true) & r.habitoId.isIn(metaDoHabito.keys)))
          .get();
      for (final r in registros) {
        marcar(metaDoHabito[r.habitoId], r.criadoEm);
      }
    }

    final lista = [
      for (final m in metas)
        calcularProgresso(
          m,
          hoje: hoje,
          ultimaAtividade: atividade[m.id]!,
          tarefasLigadas: tarefas.where((t) => t.metaId == m.id).length,
          tarefasAbertas: tarefas
              .where((t) => t.metaId == m.id && (t.feitaEm == null || t.regraRepeticao != null))
              .length,
          habitosLigados: habitos.where((h) => h.metaId == m.id).length,
        ),
    ];
    lista.sort((a, b) {
      final fa = a.estado == EstadoMeta.concluida, fb = b.estado == EstadoMeta.concluida;
      if (fa != fb) return fa ? 1 : -1;
      final da = a.meta.dataAlvo, db_ = b.meta.dataAlvo;
      if (da != null && db_ != null) return da.compareTo(db_);
      if ((da == null) != (db_ == null)) return da == null ? 1 : -1;
      return a.meta.nome.compareTo(b.meta.nome);
    });
    return lista;
  }

  Future<String> salvar(MetasCompanion dados, {String? id}) async {
    if (id == null) return (await db.into(db.metas).insertReturning(dados)).id;
    await (db.update(db.metas)..where((m) => m.id.equals(id)))
        .write(dados.copyWith(atualizadoEm: Value(DateTime.now())));
    return id;
  }

  /// Registra onde a meta está hoje (conta como atividade).
  Future<void> atualizarValor(String id, double valorAtual) =>
      (db.update(db.metas)..where((m) => m.id.equals(id))).write(
          MetasCompanion(valorAtual: Value(valorAtual), atualizadoEm: Value(DateTime.now())));

  Future<void> excluir(String id) {
    final agora = DateTime.now();
    return (db.update(db.metas)..where((m) => m.id.equals(id)))
        .write(MetasCompanion(apagadoEm: Value(agora), atualizadoEm: Value(agora)));
  }
}
