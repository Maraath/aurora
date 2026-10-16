import 'package:drift/drift.dart';

import '../core/comandos.dart' show normalizar;
import '../core/relogio.dart';
import 'banco.dart';
import 'observar.dart';
import 'saude_repo.dart';

enum Refeicao {
  cafe('Café da manhã'),
  almoco('Almoço'),
  lanche('Lanche'),
  jantar('Jantar'),
  ceia('Ceia');

  const Refeicao(this.rotulo);
  final String rotulo;

  static Refeicao de(String nome) => values.firstWhere((r) => r.name == nome, orElse: () => lanche);

  /// Refeição mais provável pelo horário.
  static Refeicao pelaHora(int hora) {
    if (hora < 10) return cafe;
    if (hora < 15) return almoco;
    if (hora < 18) return lanche;
    if (hora < 22) return jantar;
    return ceia;
  }
}

enum TipoDia { treino, descanso }

/// kcal e macros (g) de uma quantidade.
class Nutrientes {
  const Nutrientes(this.kcal, this.proteina, this.carboidrato, this.gordura);
  static const zero = Nutrientes(0, 0, 0, 0);

  final double kcal;
  final double proteina;
  final double carboidrato;
  final double gordura;

  Nutrientes operator +(Nutrientes o) =>
      Nutrientes(kcal + o.kcal, proteina + o.proteina, carboidrato + o.carboidrato, gordura + o.gordura);

  /// Valores do [alimento] para [gramas].
  factory Nutrientes.de(Alimento alimento, double gramas) {
    final f = gramas / 100;
    return Nutrientes(alimento.kcal * f, alimento.proteina * f, alimento.carboidrato * f, alimento.gordura * f);
  }

  factory Nutrientes.doRegistro(RegistroAlimentacao r) =>
      Nutrientes(r.kcal, r.proteina, r.carboidrato, r.gordura);
}

/// kcal pelos macros: 4 por g de proteína e carboidrato, 9 por g de gordura.
double kcalDosMacros(double p, double c, double g) => p * 4 + c * 4 + g * 9;

class DiaAlimentacao {
  const DiaAlimentacao({
    required this.dia,
    required this.tipo,
    required this.alvo,
    required this.registros,
    required this.alimentos,
  });

  final DateTime dia;
  final TipoDia tipo;
  final AlvoDieta? alvo;
  final List<RegistroAlimentacao> registros;
  final List<Alimento> alimentos;

  Nutrientes get total => registros.fold(Nutrientes.zero, (s, r) => s + Nutrientes.doRegistro(r));

  List<RegistroAlimentacao> daRefeicao(Refeicao r) => registros.where((x) => x.refeicao == r.name).toList();
}

class AlimentacaoRepo {
  AlimentacaoRepo(this.db);
  final BancoAurora db;

  Stream<DiaAlimentacao> observarDia(DateTime dia) => observar(db, [
        db.alimentos,
        db.alvosDieta,
        db.registrosAlimentacao,
        db.treinos,
        db.sessoesTreino,
      ], () => carregarDia(dia));

  Future<DiaAlimentacao> carregarDia(DateTime dia) async {
    final chave = chaveData(dia);
    final registros = await (db.select(db.registrosAlimentacao)
          ..where((r) => r.dia.equals(chave) & r.apagadoEm.isNull())
          ..orderBy([(r) => OrderingTerm(expression: r.criadoEm)]))
        .get();
    final tipo = await tipoDoDia(dia);
    return DiaAlimentacao(
      dia: dia,
      tipo: tipo,
      alvo: await alvo(tipo),
      registros: registros,
      alimentos: await listarAlimentos(),
    );
  }

  /// Dia de treino: tem treino marcado na ficha ou um treino registrado.
  Future<TipoDia> tipoDoDia(DateTime dia) async {
    final saude = await SaudeRepo(db).carregar();
    final treinou = saude.diasComTreino.contains(chaveData(dia));
    return treinou || saude.treinoDoDia(dia) != null ? TipoDia.treino : TipoDia.descanso;
  }

  Future<AlvoDieta?> alvo(TipoDia tipo) => (db.select(db.alvosDieta)
        ..where((a) => a.tipoDia.equals(tipo.name) & a.apagadoEm.isNull()))
      .getSingleOrNull();

  Future<void> salvarAlvo(TipoDia tipo, Nutrientes n) => db.into(db.alvosDieta).insertOnConflictUpdate(
        AlvosDietaCompanion.insert(
          id: Value(idNatural('alvo_dieta', [tipo.name])),
          tipoDia: tipo.name,
          kcal: n.kcal,
          proteina: Value(n.proteina),
          carboidrato: Value(n.carboidrato),
          gordura: Value(n.gordura),
          atualizadoEm: Value(DateTime.now()),
        ),
      );

  Future<List<Alimento>> listarAlimentos() => (db.select(db.alimentos)
        ..where((a) => a.apagadoEm.isNull())
        ..orderBy([(a) => OrderingTerm(expression: a.nome)]))
      .get();

  /// Alimento pelo nome: igual (sem acento/maiúscula); senão, o de nome mais
  /// curto em que cada palavra buscada (sem plural) começa alguma palavra
  /// do nome: "ovos" acha "Ovo cozido", "pao" acha "Pão francês".
  Future<Alimento?> acharAlimento(String nome) async {
    final alvo = normalizar(nome.trim());
    final todos = await listarAlimentos();
    for (final a in todos) {
      if (normalizar(a.nome) == alvo) return a;
    }
    final buscadas = _palavras(alvo);
    if (buscadas.isEmpty) return null;
    final achados = todos.where((a) {
      final doNome = _palavras(normalizar(a.nome));
      return buscadas.every((b) => doNome.any((p) => p.startsWith(b) || b.startsWith(p)));
    }).toList()
      ..sort((a, b) => a.nome.length.compareTo(b.nome.length));
    return achados.firstOrNull;
  }

  /// Palavras sem plural simples e sem "de/da/do".
  static List<String> _palavras(String texto) => [
        for (final p in texto.split(RegExp(r'[^a-z0-9]+')))
          if (p.length > 2 && !const {'de', 'da', 'do', 'das', 'dos', 'com'}.contains(p))
            p.endsWith('oes') || p.endsWith('aes')
                ? '${p.substring(0, p.length - 3)}ao'
                : (p.endsWith('s') && p.length > 3 ? p.substring(0, p.length - 1) : p),
      ];

  Future<String> salvarAlimento(AlimentosCompanion dados, {String? id}) async {
    if (id == null) return (await db.into(db.alimentos).insertReturning(dados)).id;
    await (db.update(db.alimentos)..where((a) => a.id.equals(id)))
        .write(dados.copyWith(atualizadoEm: Value(DateTime.now())));
    return id;
  }

  Future<void> excluirAlimento(String id) {
    final agora = DateTime.now();
    return (db.update(db.alimentos)..where((a) => a.id.equals(id)))
        .write(AlimentosCompanion(apagadoEm: Value(agora), atualizadoEm: Value(agora)));
  }

  /// Registra [gramas] do [alimento] numa refeição. Retorna o id.
  Future<String> registrar({
    required DateTime dia,
    required Refeicao refeicao,
    required Alimento alimento,
    required double gramas,
  }) async {
    final n = Nutrientes.de(alimento, gramas);
    final r = await db.into(db.registrosAlimentacao).insertReturning(RegistrosAlimentacaoCompanion.insert(
          dia: chaveData(dia),
          refeicao: refeicao.name,
          alimentoId: Value(alimento.id),
          nome: alimento.nome,
          gramas: gramas,
          kcal: n.kcal,
          proteina: Value(n.proteina),
          carboidrato: Value(n.carboidrato),
          gordura: Value(n.gordura),
        ));
    return r.id;
  }

  Future<void> excluirRegistro(String id) {
    final agora = DateTime.now();
    return (db.update(db.registrosAlimentacao)..where((r) => r.id.equals(id)))
        .write(RegistrosAlimentacaoCompanion(apagadoEm: Value(agora), atualizadoEm: Value(agora)));
  }
}
