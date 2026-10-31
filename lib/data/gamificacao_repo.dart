import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/relogio.dart';
import '../ui/visao/foco.dart';
import 'banco.dart';
import 'financas_repo.dart';
import 'habitos_repo.dart';
import 'observar.dart';
import 'saude_repo.dart';
import 'tarefas_repo.dart';

enum CategoriaConquista {
  foco('Foco & Tarefas', Icons.timelapse_rounded),
  habitos('Hábitos & Streaks', Icons.local_fire_department_rounded),
  saude('Treino & Saúde', Icons.fitness_center_rounded),
  financas('Finanças & Metas', Icons.diamond_outlined);

  const CategoriaConquista(this.rotulo, this.icone);
  final String rotulo;
  final IconData icone;
}

class Conquista {
  const Conquista({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.categoria,
    required this.xp,
    required this.desbloqueada,
    this.progressoAtual,
    this.progressoTotal,
    this.unidadeProgresso = '',
    this.desbloqueadaEm,
  });

  final String id;
  final String titulo;
  final String descricao;
  final String icone;
  final CategoriaConquista categoria;
  final int xp;
  final bool desbloqueada;
  final double? progressoAtual;
  final double? progressoTotal;
  final String unidadeProgresso;
  final DateTime? desbloqueadaEm;

  double get fracaoProgresso {
    if (desbloqueada) return 1.0;
    if (progressoAtual == null || progressoTotal == null || progressoTotal! <= 0) return 0.0;
    return (progressoAtual! / progressoTotal!).clamp(0.0, 1.0);
  }

  String get textoProgresso {
    if (desbloqueada) return 'Concluída';
    if (progressoAtual == null || progressoTotal == null) return 'Em andamento';
    final atual = progressoAtual! >= 10 ? progressoAtual!.round().toString() : progressoAtual!.toStringAsFixed(1);
    final total = progressoTotal! >= 10 ? progressoTotal!.round().toString() : progressoTotal!.toStringAsFixed(1);
    return '$atual / $total $unidadeProgresso'.trim();
  }
}

class QuadroGamificacao {
  const QuadroGamificacao({
    required this.xpTotal,
    required this.nivel,
    required this.tituloRank,
    required this.xpNoNivelAtual,
    required this.xpParaProximoNivel,
    required this.conquistas,
    required this.streakDias,
  });

  final int xpTotal;
  final int nivel;
  final String tituloRank;
  final int xpNoNivelAtual;
  final int xpParaProximoNivel;
  final List<Conquista> conquistas;
  final int streakDias;

  int get conquistasDesbloqueadas => conquistas.where((c) => c.desbloqueada).length;
  int get totalConquistas => conquistas.length;

  double get progressoNivel {
    if (xpParaProximoNivel <= 0) return 1.0;
    return (xpNoNivelAtual / xpParaProximoNivel).clamp(0.0, 1.0);
  }

  static (int nivel, String titulo, int noNivel, int paraProximo) calcularNivel(int xp) {
    const niveisXp = [
      0, 200, 450, 750, 1100, 1550, 2100, 2750, 3500, 4400,
      5500, 6800, 8300, 10000, 12000, 14500, 17500, 21000, 25000, 30000, 36000
    ];

    var lvl = 1;
    for (var i = 0; i < niveisXp.length; i++) {
      if (xp >= niveisXp[i]) {
        lvl = i + 1;
      } else {
        break;
      }
    }

    final piso = niveisXp[(lvl - 1).clamp(0, niveisXp.length - 1)];
    final teto = lvl < niveisXp.length ? niveisXp[lvl] : piso + 8000;
    final noNivel = xp - piso;
    final paraProximo = teto - piso;

    final titulo = switch (lvl) {
      >= 30 => 'Lenda Inabalável 👑',
      >= 20 => 'Arquiteto da Rotina 🏛️',
      >= 15 => 'Mestre Cósmico 🌌',
      >= 10 => 'Mestre do Hiper-Foco 🪐',
      >= 7 => 'Guardião do Ritmo ⚡',
      >= 4 => 'Praticante Focado 🎯',
      _ => 'Iniciado da Aurora 🌱',
    };

    return (lvl, titulo, noNivel, paraProximo);
  }
}

class GamificacaoRepo {
  GamificacaoRepo(this.db);
  final BancoAurora db;

  static const _chaveConquistasData = 'conquistas_desbloqueadas_v1';

  Stream<QuadroGamificacao> observarGamificacao() => observar(db, [
        db.tarefas,
        db.conclusoesTarefa,
        db.habitos,
        db.registrosHabito,
        db.sessoesTreino,
        db.transacoes,
        db.pagamentosTransacao,
        db.objetivos,
        db.preferencias,
      ], carregar);

  Future<QuadroGamificacao> carregar() async {
    final hoje = hojeLocal();

    // Carregamento de dados base
    final tarefas = await TarefasRepo(db).carregar();
    final habitos = await HabitosRepo(db).carregar();
    final saude = await SaudeRepo(db).carregar();
    final financas = await FinancasRepo(db).carregar();
    final focoMinutos = await ControleFoco.carregarHistoricoMinutos(db);

    // Contagens de execução
    final concluidasTarefas = tarefas.tarefas.where((t) => t.feitaEm != null).length +
        tarefas.conclusoes.values.fold<int>(0, (s, set) => s + set.length);
    final registrosHabitos = habitos.feitos.values.fold<int>(0, (s, set) => s + set.length);
    final sessoesTreino = saude.historico.length;
    final contasPagas = financas.movimentos.where((m) => !m.entrada && !m.transferencia).length;

    var minutosFocoTotal = 0;
    for (final m in focoMinutos.values) {
      minutosFocoTotal += m;
    }

    // Objetivos concluídos
    final objetivos = await (db.select(db.objetivos)..where((o) => o.apagadoEm.isNull())).get();
    var objetivosConcluidos = 0;
    for (final o in objetivos) {
      if (o.status == 'concluida') {
        objetivosConcluidos++;
      } else if (o.valorAlvo > o.valorInicial && o.valorAtual >= o.valorAlvo) {
        objetivosConcluidos++;
      }
    }

    // Maior sequência de hábito
    var maiorStreakHabito = 0;
    for (final h in habitos.habitos) {
      final s = habitos.sequencia(h, hoje);
      if (s > maiorStreakHabito) maiorStreakHabito = s;
    }

    // Leitura das datas de desbloqueio salvas
    final datasMap = <String, DateTime>{};
    try {
      final raw = await db.preferencia(_chaveConquistasData);
      if (raw != null && raw.isNotEmpty) {
        final mapa = jsonDecode(raw) as Map<String, dynamic>;
        for (final e in mapa.entries) {
          if (e.value is String) {
            datasMap[e.key] = DateTime.tryParse(e.value as String) ?? DateTime.now();
          }
        }
      }
    } catch (_) {}

    // Definição das 16 Conquistas do Aurora
    final listaDefinicoes = <({
      String id,
      String titulo,
      String descricao,
      String icone,
      CategoriaConquista categoria,
      int xp,
      bool atingiu,
      double? progressoAtual,
      double? progressoTotal,
      String unidade,
    })>[
      // 1. Foco & Tarefas
      (
        id: 'foco_primeiro',
        titulo: 'Primeiro Mergulho',
        descricao: 'Conclua sua primeira sessão de foco imersivo.',
        icone: '🧘',
        categoria: CategoriaConquista.foco,
        xp: 30,
        atingiu: minutosFocoTotal >= 15,
        progressoAtual: math.min(minutosFocoTotal.toDouble(), 15),
        progressoTotal: 15,
        unidade: 'min',
      ),
      (
        id: 'foco_10h',
        titulo: 'Mente Blindada',
        descricao: 'Acumule 10 horas de hiper-foco profundo.',
        icone: '🧠',
        categoria: CategoriaConquista.foco,
        xp: 80,
        atingiu: minutosFocoTotal >= 600,
        progressoAtual: math.min(minutosFocoTotal / 60.0, 10.0),
        progressoTotal: 10.0,
        unidade: 'h',
      ),
      (
        id: 'foco_50h',
        titulo: 'Mestre do Tempo',
        descricao: 'Acumule 50 horas de imersão total.',
        icone: '⏳',
        categoria: CategoriaConquista.foco,
        xp: 200,
        atingiu: minutosFocoTotal >= 3000,
        progressoAtual: math.min(minutosFocoTotal / 60.0, 50.0),
        progressoTotal: 50.0,
        unidade: 'h',
      ),
      (
        id: 'tarefas_10',
        titulo: 'Centelha de Ação',
        descricao: 'Conclua 10 tarefas no Aurora.',
        icone: '📝',
        categoria: CategoriaConquista.foco,
        xp: 40,
        atingiu: concluidasTarefas >= 10,
        progressoAtual: math.min(concluidasTarefas.toDouble(), 10),
        progressoTotal: 10,
        unidade: 'tarefas',
      ),
      (
        id: 'tarefas_50',
        titulo: 'Centurião da Rotina',
        descricao: 'Conclua 50 tarefas no histórico.',
        icone: '⚔️',
        categoria: CategoriaConquista.foco,
        xp: 120,
        atingiu: concluidasTarefas >= 50,
        progressoAtual: math.min(concluidasTarefas.toDouble(), 50),
        progressoTotal: 50,
        unidade: 'tarefas',
      ),

      // 2. Hábitos & Streaks
      (
        id: 'habito_3d',
        titulo: 'Centelha Inicial',
        descricao: 'Mantenha 3 dias ininterruptos de qualquer hábito.',
        icone: '✨',
        categoria: CategoriaConquista.habitos,
        xp: 40,
        atingiu: maiorStreakHabito >= 3,
        progressoAtual: math.min(maiorStreakHabito.toDouble(), 3),
        progressoTotal: 3,
        unidade: 'dias',
      ),
      (
        id: 'habito_7d',
        titulo: 'Fogo Constante',
        descricao: 'Atinja 7 dias consecutivos em um mesmo hábito.',
        icone: '🔥',
        categoria: CategoriaConquista.habitos,
        xp: 80,
        atingiu: maiorStreakHabito >= 7,
        progressoAtual: math.min(maiorStreakHabito.toDouble(), 7),
        progressoTotal: 7,
        unidade: 'dias',
      ),
      (
        id: 'habito_14d',
        titulo: 'Ritmo Blindado',
        descricao: 'Atinja 14 dias seguidos de consistência inabalável.',
        icone: '⚡',
        categoria: CategoriaConquista.habitos,
        xp: 120,
        atingiu: maiorStreakHabito >= 14,
        progressoAtual: math.min(maiorStreakHabito.toDouble(), 14),
        progressoTotal: 14,
        unidade: 'dias',
      ),
      (
        id: 'habito_21d',
        titulo: 'Hábito de Ferro',
        descricao: 'Atinja 21 dias consecutivos (consolidação neurológica).',
        icone: '🛡️',
        categoria: CategoriaConquista.habitos,
        xp: 180,
        atingiu: maiorStreakHabito >= 21,
        progressoAtual: math.min(maiorStreakHabito.toDouble(), 21),
        progressoTotal: 21,
        unidade: 'dias',
      ),
      (
        id: 'habito_total_30',
        titulo: 'Constância Diária',
        descricao: 'Acumule 30 conclusões totais de hábitos.',
        icone: '🌟',
        categoria: CategoriaConquista.habitos,
        xp: 90,
        atingiu: registrosHabitos >= 30,
        progressoAtual: math.min(registrosHabitos.toDouble(), 30),
        progressoTotal: 30,
        unidade: 'feitas',
      ),

      // 3. Treino & Saúde
      (
        id: 'treino_1',
        titulo: 'Primeira Gota',
        descricao: 'Registre sua primeira sessão de treino na ficha.',
        icone: '💧',
        categoria: CategoriaConquista.saude,
        xp: 50,
        atingiu: sessoesTreino >= 1,
        progressoAtual: math.min(sessoesTreino.toDouble(), 1),
        progressoTotal: 1,
        unidade: 'treino',
      ),
      (
        id: 'treino_5',
        titulo: 'Corpo em Ação',
        descricao: 'Complete 5 sessões de treino registradas.',
        icone: '🏃',
        categoria: CategoriaConquista.saude,
        xp: 90,
        atingiu: sessoesTreino >= 5,
        progressoAtual: math.min(sessoesTreino.toDouble(), 5),
        progressoTotal: 5,
        unidade: 'treinos',
      ),
      (
        id: 'treino_20',
        titulo: 'Disciplina de Aço',
        descricao: 'Complete 20 sessões de treino no histórico.',
        icone: '🏋️',
        categoria: CategoriaConquista.saude,
        xp: 180,
        atingiu: sessoesTreino >= 20,
        progressoAtual: math.min(sessoesTreino.toDouble(), 20),
        progressoTotal: 20,
        unidade: 'treinos',
      ),

      // 4. Finanças & Metas
      (
        id: 'financas_1',
        titulo: 'Ordem no Bolso',
        descricao: 'Registre o pagamento da sua primeira conta.',
        icone: '💳',
        categoria: CategoriaConquista.financas,
        xp: 40,
        atingiu: contasPagas >= 1,
        progressoAtual: math.min(contasPagas.toDouble(), 1),
        progressoTotal: 1,
        unidade: 'paga',
      ),
      (
        id: 'financas_10',
        titulo: 'Contas Blindadas',
        descricao: 'Acumule 10 pagamentos de contas registrados em dia.',
        icone: '💎',
        categoria: CategoriaConquista.financas,
        xp: 100,
        atingiu: contasPagas >= 10,
        progressoAtual: math.min(contasPagas.toDouble(), 10),
        progressoTotal: 10,
        unidade: 'pagas',
      ),
      (
        id: 'objetivo_1',
        titulo: 'Primeiro Topo',
        descricao: 'Conclua 100% de um Grande Objetivo cadastrado.',
        icone: '🏔️',
        categoria: CategoriaConquista.financas,
        xp: 200,
        atingiu: objetivosConcluidos >= 1,
        progressoAtual: math.min(objetivosConcluidos.toDouble(), 1),
        progressoTotal: 1,
        unidade: 'objetivo',
      ),
    ];

    var houveNovasConquistas = false;
    final listaConquistas = <Conquista>[];

    for (final def in listaDefinicoes) {
      var data = datasMap[def.id];
      if (def.atingiu && data == null) {
        data = DateTime.now();
        datasMap[def.id] = data;
        houveNovasConquistas = true;
      }

      listaConquistas.add(Conquista(
        id: def.id,
        titulo: def.titulo,
        descricao: def.descricao,
        icone: def.icone,
        categoria: def.categoria,
        xp: def.xp,
        desbloqueada: def.atingiu,
        progressoAtual: def.progressoAtual,
        progressoTotal: def.progressoTotal,
        unidadeProgresso: def.unidade,
        desbloqueadaEm: def.atingiu ? data : null,
      ));
    }

    if (houveNovasConquistas) {
      await db.salvarPreferencia(
        _chaveConquistasData,
        jsonEncode({for (final e in datasMap.entries) e.key: e.value.toIso8601String()}),
      );
    }

    // Cálculo do XP Total
    var xpTotal = 0;
    xpTotal += concluidasTarefas * 15;
    xpTotal += minutosFocoTotal * 1;
    xpTotal += registrosHabitos * 20;
    xpTotal += sessoesTreino * 50;
    xpTotal += contasPagas * 30;
    xpTotal += objetivosConcluidos * 100;

    for (final c in listaConquistas) {
      if (c.desbloqueada) {
        xpTotal += c.xp;
      }
    }

    final (nivel, tituloRank, xpNoNivel, xpParaProximo) = QuadroGamificacao.calcularNivel(xpTotal);

    return QuadroGamificacao(
      xpTotal: xpTotal,
      nivel: nivel,
      tituloRank: tituloRank,
      xpNoNivelAtual: xpNoNivel,
      xpParaProximoNivel: xpParaProximo,
      conquistas: listaConquistas,
      streakDias: maiorStreakHabito,
    );
  }
}
