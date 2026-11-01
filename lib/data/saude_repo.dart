import 'dart:convert';

import 'package:drift/drift.dart';

import '../core/formato.dart';
import '../core/relogio.dart';
import '../core/sons.dart';
import 'banco.dart';
import 'observar.dart';

/// Medidas que o formulário oferece de cara; qualquer outro nome também vale.
const medidasPadrao = [('Peso', 'kg'), ('Braço', 'cm'), ('Cintura', 'cm')];

/// Quanto a carga sobe quando todas as séries chegaram nas repetições alvo.
double incrementoCarga(double carga) => carga >= 20 ? 2.5 : 1;

String kg(double v) => '${numero(v)} kg';

class SugestaoCarga {
  const SugestaoCarga(this.cargaKg, this.motivo, {this.subiu = false});
  final double? cargaKg;
  final String motivo;
  final bool subiu;

  String get texto => cargaKg == null ? '—' : kg(cargaKg!);
}

/// Carga do próximo treino a partir das séries da última vez que o exercício
/// foi feito: se todas bateram as repetições alvo, sobe; senão, repete.
SugestaoCarga sugerirCarga(ItemTreino item, List<SerieFeita> ultimaVez) {
  if (ultimaVez.isEmpty) {
    return item.cargaInicial == null
        ? const SugestaoCarga(null, 'sem histórico')
        : SugestaoCarga(item.cargaInicial, 'carga inicial');
  }
  final maior = ultimaVez.map((s) => s.cargaKg).reduce((a, b) => a > b ? a : b);
  final naMaior = ultimaVez.where((s) => s.cargaKg == maior).toList();
  final bateu = ultimaVez.length >= item.series &&
      naMaior.every((s) => s.repeticoes >= item.repeticoes);
  if (bateu) {
    final inc = incrementoCarga(maior);
    return SugestaoCarga(maior + inc, 'subiu ${kg(inc)}: fez todas as repetições', subiu: true);
  }
  return SugestaoCarga(maior, 'mesma do último treino');
}

class ExercicioDoTreino {
  const ExercicioDoTreino({
    required this.item,
    required this.exercicio,
    required this.sugestao,
    required this.ultimaVez,
  });

  final ItemTreino item;
  final Exercicio exercicio;
  final SugestaoCarga sugestao;

  /// Séries da última sessão em que o exercício apareceu (pode ser vazia).
  final List<SerieFeita> ultimaVez;

  String get plano => '${item.series} ${item.series == 1 ? 'série' : 'séries'} × ${item.repeticoes}';
}

class TreinoCompleto {
  const TreinoCompleto({required this.treino, required this.exercicios, this.ultimaVez});
  final Treino treino;
  final List<ExercicioDoTreino> exercicios;
  final DateTime? ultimaVez;

  String get titulo => treino.foco == null || treino.foco!.isEmpty
      ? treino.nome
      : '${treino.nome} · ${treino.foco}';
}

class ResumoSessao {
  const ResumoSessao({required this.sessao, required this.treino, required this.series, required this.volumeKg});
  final SessaoTreino sessao;
  final Treino? treino;
  final int series;

  /// Soma de carga × repetições.
  final double volumeKg;
}

/// Um dia dentro de um ciclo de treinos intercalados.
/// Se [treinoId] for nulo, representa um dia de descanso.
class PassoCiclo {
  const PassoCiclo({
    required this.dia,
    this.treinoId,
    this.nome,
    this.foco,
  });

  /// Número do dia no ciclo (1, 2, 3, 4...).
  final int dia;

  /// ID do treino associado; se for nulo, é dia de descanso.
  final String? treinoId;

  /// Nome do dia (ex.: "Treino A" ou "Descanso").
  final String? nome;

  /// Foco muscular (ex.: "Peito, tríceps e ombro" ou "Recuperação").
  final String? foco;

  bool get isDescanso => treinoId == null;

  String get rotulo => isDescanso ? (nome ?? 'Descanso') : (nome ?? 'Treino');
  String get detalhe => isDescanso ? (foco ?? 'Recuperação muscular') : (foco ?? '');

  Map<String, dynamic> toJson() => {
        'dia': dia,
        'treinoId': treinoId,
        'nome': nome,
        'foco': foco,
      };

  factory PassoCiclo.fromJson(Map<String, dynamic> json) => PassoCiclo(
        dia: json['dia'] as int? ?? 1,
        treinoId: json['treinoId'] as String?,
        nome: json['nome'] as String?,
        foco: json['foco'] as String?,
      );

  PassoCiclo copyWith({
    int? dia,
    String? treinoId,
    String? nome,
    String? foco,
    bool nullTreinoId = false,
  }) =>
      PassoCiclo(
        dia: dia ?? this.dia,
        treinoId: nullTreinoId ? null : (treinoId ?? this.treinoId),
        nome: nome ?? this.nome,
        foco: foco ?? this.foco,
      );
}

/// Configuração de treino intercalado rotativo.
/// Exemplo:
/// Dia 1: Peito, tríceps e ombro
/// Dia 2: Costas, bíceps e ombro
/// Dia 3: Perna e ombro
/// Dia 4: Descanso
/// Dia 5: Repete o Dia 1 sucessivamente.
class CicloTreino {
  const CicloTreino({
    required this.ativo,
    required this.dataInicio,
    required this.passos,
  });

  final bool ativo;

  /// Data de referência (quando o Dia 1 começou).
  final DateTime dataInicio;

  /// Passos do ciclo em ordem (Dia 1 até N).
  final List<PassoCiclo> passos;

  int get totalDias => passos.length;

  /// Retorna o índice no ciclo (0 a passos.length - 1) para a [data].
  int indiceNoDia(DateTime data) {
    if (passos.isEmpty) return 0;
    final inicio = DateTime(dataInicio.year, dataInicio.month, dataInicio.day);
    final alvo = DateTime(data.year, data.month, data.day);
    final diff = alvo.difference(inicio).inDays;
    return ((diff % passos.length) + passos.length) % passos.length;
  }

  /// Retorna o passo do ciclo (1 a N) correspondente à [data].
  PassoCiclo? passoNoDia(DateTime data) {
    if (!ativo || passos.isEmpty) return null;
    return passos[indiceNoDia(data)];
  }

  /// Retorna o número do dia (1 a N) em que a [data] cai.
  int numeroDia(DateTime data) {
    final p = passoNoDia(data);
    return p?.dia ?? (indiceNoDia(data) + 1);
  }

  Map<String, dynamic> toJson() => {
        'ativo': ativo,
        'dataInicio': chaveData(dataInicio),
        'passos': passos.map((p) => p.toJson()).toList(),
      };

  factory CicloTreino.fromJson(Map<String, dynamic> json) {
    final passosRaw = json['passos'] as List<dynamic>?;
    final passos = passosRaw != null
        ? [for (final p in passosRaw) PassoCiclo.fromJson(p as Map<String, dynamic>)]
        : <PassoCiclo>[];
    DateTime inicio = hojeLocal();
    final dataStr = json['dataInicio'] as String?;
    if (dataStr != null) {
      final p = DateTime.tryParse(dataStr);
      if (p != null) inicio = p;
    }
    return CicloTreino(
      ativo: json['ativo'] as bool? ?? false,
      dataInicio: inicio,
      passos: passos,
    );
  }

  CicloTreino copyWith({
    bool? ativo,
    DateTime? dataInicio,
    List<PassoCiclo>? passos,
  }) =>
      CicloTreino(
        ativo: ativo ?? this.ativo,
        dataInicio: dataInicio ?? this.dataInicio,
        passos: passos ?? this.passos,
      );
}

class QuadroSaude {
  const QuadroSaude({
    required this.treinos,
    required this.historico,
    required this.medidas,
    required this.exercicios,
    required this.diasComTreino,
    this.ciclo,
  });

  final List<TreinoCompleto> treinos;

  /// Sessões, da mais recente para a mais antiga.
  final List<ResumoSessao> historico;

  /// Tipo → medidas, da mais antiga para a mais recente.
  final Map<String, List<Medida>> medidas;
  final List<Exercicio> exercicios;

  /// Dias ("aaaa-mm-dd") em que houve treino.
  final Set<String> diasComTreino;

  /// Ciclo de treinos intercalados, se configurado.
  final CicloTreino? ciclo;

  bool get temCicloAtivo => ciclo != null && ciclo!.ativo && ciclo!.passos.isNotEmpty;

  /// Retorna o passo do ciclo para a data dada, se o ciclo estiver ativo.
  PassoCiclo? passoDoCiclo(DateTime data) => temCicloAtivo ? ciclo!.passoNoDia(data) : null;

  /// O treino marcado para o dia de [hoje]. Se estiver em ciclo intercalado,
  /// usa o passo do ciclo (retorna null se for dia de descanso).
  TreinoCompleto? treinoDoDia(DateTime hoje) {
    if (temCicloAtivo) {
      final passo = ciclo!.passoNoDia(hoje);
      if (passo == null || passo.isDescanso || passo.treinoId == null) {
        return null;
      }
      return treinos.where((t) => t.treino.id == passo.treinoId).firstOrNull;
    }
    final bit = 1 << (hoje.weekday - 1);
    for (final t in treinos) {
      if (t.treino.diasSemana & bit != 0) return t;
    }
    return null;
  }

  /// Próximo treino a partir de amanhã (para dias de descanso).
  ({TreinoCompleto treino, DateTime dia})? proximoTreino(DateTime hoje) {
    if (temCicloAtivo) {
      for (var i = 1; i <= 14; i++) {
        final d = somarDias(hoje, i);
        final passo = ciclo!.passoNoDia(d);
        if (passo != null && !passo.isDescanso && passo.treinoId != null) {
          final t = treinos.where((x) => x.treino.id == passo.treinoId).firstOrNull;
          if (t != null) return (treino: t, dia: d);
        }
      }
      return null;
    }
    for (var i = 1; i <= 7; i++) {
      final d = somarDias(hoje, i);
      final t = treinoDoDia(d);
      if (t != null) return (treino: t, dia: d);
    }
    return null;
  }

  /// Sessão já registrada hoje para o treino.
  bool feitoEm(String treinoId, DateTime dia) =>
      historico.any((r) => r.sessao.treinoId == treinoId && r.sessao.dia == chaveData(dia));

  /// Tipos com registro: os padrão primeiro, depois os livres em ordem alfabética.
  List<String> get tiposMedida {
    final padrao = [for (final (t, _) in medidasPadrao) if (medidas.containsKey(t)) t];
    final livres = medidas.keys.where((t) => !padrao.contains(t)).toList()..sort();
    return [...padrao, ...livres];
  }

  Medida? ultima(String tipo) => medidas[tipo]?.lastOrNull;

  /// Diferença para o registro anterior (nulo se só houver um).
  double? variacao(String tipo) {
    final l = medidas[tipo];
    if (l == null || l.length < 2) return null;
    return l.last.valor - l[l.length - 2].valor;
  }
}

class SaudeRepo {
  SaudeRepo(this.db);
  final BancoAurora db;

  Stream<QuadroSaude> observarQuadro() => observar(db, [
        db.treinos,
        db.itensTreino,
        db.exercicios,
        db.sessoesTreino,
        db.seriesFeitas,
        db.medidas,
        db.preferencias,
      ], carregar);

  Future<QuadroSaude> carregar() async {
    final treinos = await (db.select(db.treinos)
          ..where((t) => t.apagadoEm.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.ordem), (t) => OrderingTerm(expression: t.nome)]))
        .get();
    final itens = await (db.select(db.itensTreino)
          ..where((i) => i.apagadoEm.isNull())
          ..orderBy([(i) => OrderingTerm(expression: i.ordem)]))
        .get();
    final exercicios = await (db.select(db.exercicios)
          ..where((e) => e.apagadoEm.isNull())
          ..orderBy([(e) => OrderingTerm(expression: e.nome)]))
        .get();
    final sessoes = await (db.select(db.sessoesTreino)
          ..where((s) => s.apagadoEm.isNull())
          ..orderBy([(s) => OrderingTerm(expression: s.inicio, mode: OrderingMode.desc)]))
        .get();
    final series = await (db.select(db.seriesFeitas)..where((s) => s.apagadoEm.isNull())).get();
    final medidas = await (db.select(db.medidas)
          ..where((m) => m.apagadoEm.isNull())
          ..orderBy([(m) => OrderingTerm(expression: m.dia)]))
        .get();

    final exPorId = {for (final e in exercicios) e.id: e};
    final treinoPorId = {for (final t in treinos) t.id: t};
    final seriesPorSessao = <String, List<SerieFeita>>{};
    for (final s in series) {
      seriesPorSessao.putIfAbsent(s.sessaoId, () => []).add(s);
    }
    for (final l in seriesPorSessao.values) {
      l.sort((a, b) => a.numero.compareTo(b.numero));
    }

    // Última vez de cada exercício: a sessão mais recente que o tem.
    final ultimaVez = <String, List<SerieFeita>>{};
    for (final s in sessoes) {
      final porEx = <String, List<SerieFeita>>{};
      for (final f in seriesPorSessao[s.id] ?? const <SerieFeita>[]) {
        porEx.putIfAbsent(f.exercicioId, () => []).add(f);
      }
      porEx.forEach((ex, l) => ultimaVez.putIfAbsent(ex, () => l));
    }

    final completos = [
      for (final t in treinos)
        TreinoCompleto(
          treino: t,
          ultimaVez: sessoes.where((s) => s.treinoId == t.id).firstOrNull?.inicio,
          exercicios: [
            for (final i in itens.where((i) => i.treinoId == t.id))
              if (exPorId[i.exercicioId] case final ex?)
                ExercicioDoTreino(
                  item: i,
                  exercicio: ex,
                  ultimaVez: ultimaVez[ex.id] ?? const [],
                  sugestao: sugerirCarga(i, ultimaVez[ex.id] ?? const []),
                ),
          ],
        ),
    ];

    final porTipo = <String, List<Medida>>{};
    for (final m in medidas) {
      porTipo.putIfAbsent(m.tipo, () => []).add(m);
    }

    final ciclo = await carregarCiclo();

    return QuadroSaude(
      treinos: completos,
      historico: [
        for (final s in sessoes)
          ResumoSessao(
            sessao: s,
            treino: treinoPorId[s.treinoId],
            series: seriesPorSessao[s.id]?.length ?? 0,
            volumeKg: (seriesPorSessao[s.id] ?? const <SerieFeita>[])
                .fold(0.0, (v, f) => v + f.cargaKg * f.repeticoes),
          ),
      ],
      medidas: porTipo,
      exercicios: exercicios,
      diasComTreino: {for (final s in sessoes) s.dia},
      ciclo: ciclo,
    );
  }

  /// Exercício pelo nome (sem diferenciar maiúsculas); cria se não existir.
  /// Com [midia] (arquivo da animação na biblioteca), o exercício fica ligado a ela.
  Future<String> exercicioPorNome(String nome, {String? midia, String? grupo}) async {
    final limpo = nome.trim();
    final existentes = await (db.select(db.exercicios)..where((e) => e.apagadoEm.isNull())).get();
    for (final e in existentes) {
      if (e.nome.toLowerCase() == limpo.toLowerCase()) {
        if (midia != null && e.midia != midia) {
          await (db.update(db.exercicios)..where((x) => x.id.equals(e.id))).write(ExerciciosCompanion(
              midia: Value(midia), grupo: Value(grupo ?? e.grupo), atualizadoEm: Value(DateTime.now())));
        }
        return e.id;
      }
    }
    return (await db.into(db.exercicios).insertReturning(
            ExerciciosCompanion.insert(nome: limpo, midia: Value(midia), grupo: Value(grupo))))
        .id;
  }

  /// Cria ou atualiza um treino com a lista de exercícios na ordem dada.
  Future<String> salvarTreino(
    TreinosCompanion dados,
    List<({String nome, int series, int repeticoes, double? cargaInicial})> itens, {
    String? id,

    /// Nome do exercício (minúsculo) → (arquivo da animação, grupo muscular),
    /// para os escolhidos na biblioteca.
    Map<String, (String, String)> biblioteca = const {},
  }) {
    return db.transaction(() async {
      final agora = DateTime.now();
      late final String treinoId;
      if (id == null) {
        final ordem = (await (db.select(db.treinos)..where((t) => t.apagadoEm.isNull())).get()).length;
        treinoId = (await db.into(db.treinos).insertReturning(dados.copyWith(ordem: Value(ordem)))).id;
      } else {
        treinoId = id;
        await (db.update(db.treinos)..where((t) => t.id.equals(id)))
            .write(dados.copyWith(atualizadoEm: Value(agora)));
        await (db.update(db.itensTreino)..where((i) => i.treinoId.equals(id) & i.apagadoEm.isNull()))
            .write(ItensTreinoCompanion(apagadoEm: Value(agora), atualizadoEm: Value(agora)));
      }
      for (var n = 0; n < itens.length; n++) {
        final it = itens[n];
        await db.into(db.itensTreino).insert(ItensTreinoCompanion.insert(
              treinoId: treinoId,
              exercicioId: await exercicioPorNome(it.nome,
                  midia: biblioteca[it.nome.trim().toLowerCase()]?.$1,
                  grupo: biblioteca[it.nome.trim().toLowerCase()]?.$2),
              ordem: Value(n),
              series: Value(it.series),
              repeticoes: Value(it.repeticoes),
              cargaInicial: Value(it.cargaInicial),
            ));
      }
      return treinoId;
    });
  }

  Future<void> excluirTreino(String id) {
    final agora = DateTime.now();
    return (db.update(db.treinos)..where((t) => t.id.equals(id)))
        .write(TreinosCompanion(apagadoEm: Value(agora), atualizadoEm: Value(agora)));
  }

  /// Grava um treino feito com as séries marcadas.
  Future<String> registrarSessao({
    String? treinoId,
    required DateTime inicio,
    required List<({String exercicioId, int numero, int repeticoes, double cargaKg})> series,
  }) {
    return db.transaction(() async {
      final sessao = await db.into(db.sessoesTreino).insertReturning(SessoesTreinoCompanion.insert(
            treinoId: Value(treinoId),
            dia: chaveDia(inicio),
            inicio: inicio,
            fim: Value(DateTime.now()),
          ));
      for (final s in series) {
        await db.into(db.seriesFeitas).insert(SeriesFeitasCompanion.insert(
              sessaoId: sessao.id,
              exercicioId: s.exercicioId,
              numero: s.numero,
              repeticoes: s.repeticoes,
              cargaKg: s.cargaKg,
            ));
      }
      Sons.instancia.tocarConcluirTreino();
      return sessao.id;
    });
  }

  Future<void> excluirSessao(String id) {
    final agora = DateTime.now();
    return (db.update(db.sessoesTreino)..where((s) => s.id.equals(id)))
        .write(SessoesTreinoCompanion(apagadoEm: Value(agora), atualizadoEm: Value(agora)));
  }

  /// Grava as medidas de um dia (uma por tipo; regravar o mesmo dia substitui).
  Future<void> salvarMedidas(DateTime dia, List<({String tipo, double valor, String unidade})> lista) {
    final chave = chaveData(dia);
    final agora = DateTime.now();
    return db.transaction(() async {
      for (final m in lista) {
        await db.into(db.medidas).insert(
              MedidasCompanion.insert(
                  id: Value(idNatural('medida', [chave, m.tipo])),
                  dia: chave,
                  tipo: m.tipo,
                  valor: m.valor,
                  unidade: m.unidade),
              onConflict: DoUpdate(
                (_) => MedidasCompanion(
                  valor: Value(m.valor),
                  unidade: Value(m.unidade),
                  apagadoEm: const Value(null),
                  atualizadoEm: Value(agora),
                ),
                target: [db.medidas.dia, db.medidas.tipo],
              ),
            );
      }
    });
  }

  Future<void> excluirMedida(String id) {
    final agora = DateTime.now();
    return (db.update(db.medidas)..where((m) => m.id.equals(id)))
        .write(MedidasCompanion(apagadoEm: Value(agora), atualizadoEm: Value(agora)));
  }

  /// Lê a configuração atual do treino intercalado / ciclo.
  Future<CicloTreino?> carregarCiclo() async {
    final raw = await db.preferencia('ciclo_treino');
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final mapa = jsonDecode(raw) as Map<String, dynamic>;
      return CicloTreino.fromJson(mapa);
    } catch (_) {
      return null;
    }
  }

  /// Salva ou atualiza a configuração do ciclo intercalado.
  Future<void> salvarCiclo(CicloTreino ciclo) async {
    await db.salvarPreferencia('ciclo_treino', jsonEncode(ciclo.toJson()));
  }

  /// Desativa o treino intercalado, voltando aos dias da semana fixos.
  Future<void> desativarCiclo() async {
    final atual = await carregarCiclo();
    if (atual != null) {
      await salvarCiclo(atual.copyWith(ativo: false));
    }
  }

  /// Define qual dia do ciclo (1 a N) corresponde ao dia de hoje.
  Future<void> definirDiaAtualCiclo(int dia) async {
    final atual = await carregarCiclo();
    if (atual == null || atual.passos.isEmpty) return;
    final hoje = hojeLocal();
    final diaAjustado = dia.clamp(1, atual.passos.length);
    // Para que hoje caia no diaAjustado (índice diaAjustado - 1):
    final novaDataInicio = DateTime(hoje.year, hoje.month, hoje.day).subtract(Duration(days: diaAjustado - 1));
    await salvarCiclo(atual.copyWith(dataInicio: novaDataInicio, ativo: true));
  }

  /// Associa ou atualiza um treino existente como passo [diaCiclo] do ciclo.
  Future<void> associarTreinoAoCiclo(String treinoId, int diaCiclo, {String? nome, String? foco}) async {
    final atual = await carregarCiclo();
    final passos = List<PassoCiclo>.from(atual?.passos ?? const []);
    while (passos.length < diaCiclo) {
      passos.add(PassoCiclo(dia: passos.length + 1));
    }
    final idx = diaCiclo - 1;
    passos[idx] = PassoCiclo(
      dia: diaCiclo,
      treinoId: treinoId,
      nome: nome ?? passos[idx].nome,
      foco: foco ?? passos[idx].foco,
    );
    final novoCiclo = (atual ?? CicloTreino(ativo: true, dataInicio: hojeLocal(), passos: passos)).copyWith(
      passos: passos,
      ativo: true,
    );
    await salvarCiclo(novoCiclo);
  }
}
