import 'package:aurora/core/relogio.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/exemplo.dart';
import 'package:aurora/data/saude_repo.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late BancoAurora db;
  late SaudeRepo repo;

  setUpAll(() async {
    iniciarRelogio();
    await initializeDateFormatting('pt_BR');
  });

  setUp(() async {
    db = BancoAurora(NativeDatabase.memory());
    repo = SaudeRepo(db);
    await semearExemplo(db);
  });

  tearDown(() => db.close());

  ItemTreino item({int series = 3, int reps = 10, double? inicial}) => ItemTreino(
        id: 'i',
        criadoEm: DateTime(2026),
        atualizadoEm: DateTime(2026),
        treinoId: 't',
        exercicioId: 'e',
        ordem: 0,
        series: series,
        repeticoes: reps,
        cargaInicial: inicial,
      );

  SerieFeita serie(int n, int reps, double carga) => SerieFeita(
        id: 's$n',
        criadoEm: DateTime(2026),
        atualizadoEm: DateTime(2026),
        sessaoId: 'x',
        exercicioId: 'e',
        numero: n,
        repeticoes: reps,
        cargaKg: carga,
      );

  group('carga sugerida', () {
    test('sem histórico usa a carga inicial', () {
      expect(sugerirCarga(item(inicial: 20), const []).cargaKg, 20);
      expect(sugerirCarga(item(), const []).cargaKg, isNull);
    });

    test('bateu todas as repetições: sobe 2,5 kg (ou 1 kg em carga leve)', () {
      final s = sugerirCarga(item(), [serie(1, 10, 40), serie(2, 10, 40), serie(3, 11, 40)]);
      expect(s.cargaKg, 42.5);
      expect(s.subiu, isTrue);
      expect(sugerirCarga(item(), [serie(1, 10, 8), serie(2, 10, 8), serie(3, 10, 8)]).cargaKg, 9);
    });

    test('faltou repetição ou série: repete a carga', () {
      expect(sugerirCarga(item(), [serie(1, 10, 40), serie(2, 8, 40), serie(3, 7, 40)]).cargaKg, 40);
      expect(sugerirCarga(item(), [serie(1, 10, 40), serie(2, 10, 40)]).cargaKg, 40);
    });
  });

  test('exemplo: treino A com as cargas do protótipo', () async {
    final q = await repo.carregar();
    expect(q.treinos.map((t) => t.titulo), ['Treino A · Peito e tríceps', 'Treino B · Costas e bíceps']);
    final a = q.treinos.first;
    expect([for (final e in a.exercicios) e.sugestao.cargaKg], [40, 14, 25]);
    expect(a.exercicios.first.plano, '4 séries × 10');
    expect(q.historico, hasLength(1));
    expect(q.historico.single.volumeKg, 4 * 10 * 37.5 + (12 + 12 + 10) * 14 + 3 * 12 * 22.5);
    // Treino B nunca foi feito: carga inicial.
    expect(q.treinos.last.exercicios.first.sugestao.motivo, 'carga inicial');
  });

  test('treino do dia segue os dias da semana', () async {
    final q = await repo.carregar();
    final segunda = DateTime(2026, 10, 12), terca = DateTime(2026, 10, 13), domingo = DateTime(2026, 10, 18);
    expect(q.treinoDoDia(segunda)?.treino.nome, 'Treino A');
    expect(q.treinoDoDia(terca)?.treino.nome, 'Treino B');
    expect(q.treinoDoDia(domingo), isNull);
  });

  test('registrar treino atualiza a sugestão seguinte', () async {
    var q = await repo.carregar();
    final a = q.treinos.first;
    final supino = a.exercicios.first;
    await repo.registrarSessao(
      treinoId: a.treino.id,
      inicio: DateTime.now(),
      series: [
        for (var n = 1; n <= 4; n++)
          (exercicioId: supino.exercicio.id, numero: n, repeticoes: 10, cargaKg: 40.0),
      ],
    );
    q = await repo.carregar();
    expect(q.treinos.first.exercicios.first.sugestao.cargaKg, 42.5);
    expect(q.feitoEm(a.treino.id, hojeLocal()), isTrue);
    // Crucifixo não entrou nesta sessão: continua usando a anterior.
    expect(q.treinos.first.exercicios[1].sugestao.cargaKg, 14);
  });

  test('editar treino troca os exercícios e reaproveita pelo nome', () async {
    final a = (await repo.carregar()).treinos.first;
    await repo.salvarTreino(
      TreinosCompanion(nome: const Value('Treino A'), foco: const Value('Peito')),
      [(nome: 'supino reto', series: 5, repeticoes: 5, cargaInicial: null)],
      id: a.treino.id,
    );
    final q = await repo.carregar();
    final novo = q.treinos.first;
    expect(novo.exercicios, hasLength(1));
    expect(novo.exercicios.single.exercicio.nome, 'Supino reto');
    expect(q.exercicios.where((e) => e.nome.toLowerCase() == 'supino reto'), hasLength(1));
  });

  test('medidas: última, variação e regravar o mesmo dia substitui', () async {
    var q = await repo.carregar();
    expect(q.tiposMedida, ['Peso', 'Braço']);
    expect(q.ultima('Peso')?.valor, 74);
    expect(q.variacao('Peso'), closeTo(0.2, 0.001));

    await repo.salvarMedidas(hojeLocal(), [
      (tipo: 'Peso', valor: 74.6, unidade: 'kg'),
      (tipo: 'Panturrilha', valor: 38, unidade: 'cm'),
    ]);
    await repo.salvarMedidas(hojeLocal(), [(tipo: 'Peso', valor: 74.4, unidade: 'kg')]);
    q = await repo.carregar();
    expect(q.medidas['Peso'], hasLength(4));
    expect(q.ultima('Peso')?.valor, 74.4);
    expect(q.tiposMedida, ['Peso', 'Braço', 'Panturrilha']);

    await repo.excluirMedida(q.ultima('Panturrilha')!.id);
    expect((await repo.carregar()).tiposMedida, ['Peso', 'Braço']);
  });

  test('semear de novo não duplica a ficha', () async {
    await semearExemplo(db);
    expect((await repo.carregar()).treinos, hasLength(2));
  });

  group('treino intercalado (ciclo rotativo)', () {
    test('ciclo rotativo de 4 dias alterna treinos e descanso e repete sucessivamente', () async {
      final inicio = DateTime(2026, 11, 1); // Dia 1
      final ciclo = CicloTreino(
        ativo: true,
        dataInicio: inicio,
        passos: const [
          PassoCiclo(dia: 1, treinoId: 'treino_a', nome: 'Treino A', foco: 'Peito, tríceps e ombro'),
          PassoCiclo(dia: 2, treinoId: 'treino_b', nome: 'Treino B', foco: 'Costas, bíceps e ombro'),
          PassoCiclo(dia: 3, treinoId: 'treino_c', nome: 'Treino C', foco: 'Perna e ombro'),
          PassoCiclo(dia: 4, treinoId: null, nome: 'Descanso', foco: 'Recuperação muscular'),
        ],
      );

      // Dia 1 (01/11): Treino A
      expect(ciclo.passoNoDia(DateTime(2026, 11, 1))?.treinoId, 'treino_a');
      expect(ciclo.passoNoDia(DateTime(2026, 11, 1))?.isDescanso, isFalse);

      // Dia 2 (02/11): Treino B
      expect(ciclo.passoNoDia(DateTime(2026, 11, 2))?.treinoId, 'treino_b');

      // Dia 3 (03/11): Treino C
      expect(ciclo.passoNoDia(DateTime(2026, 11, 3))?.treinoId, 'treino_c');

      // Dia 4 (04/11): Descanso
      expect(ciclo.passoNoDia(DateTime(2026, 11, 4))?.isDescanso, isTrue);
      expect(ciclo.passoNoDia(DateTime(2026, 11, 4))?.treinoId, isNull);

      // Dia 5 (05/11): Dia 1 repete! (Treino A)
      expect(ciclo.passoNoDia(DateTime(2026, 11, 5))?.treinoId, 'treino_a');
      expect(ciclo.passoNoDia(DateTime(2026, 11, 5))?.dia, 1);

      // Dia 6 (06/11): Dia 2 repete! (Treino B)
      expect(ciclo.passoNoDia(DateTime(2026, 11, 6))?.treinoId, 'treino_b');

      // Dia 8 (08/11): Descanso repete!
      expect(ciclo.passoNoDia(DateTime(2026, 11, 8))?.isDescanso, isTrue);
    });

    test('salvar e carregar ciclo no banco respeita treino do dia e descanso', () async {
      final treinos = (await repo.carregar()).treinos;
      final tA = treinos[0];
      final tB = treinos[1];

      final hoje = hojeLocal();
      final ciclo = CicloTreino(
        ativo: true,
        dataInicio: hoje,
        passos: [
          PassoCiclo(dia: 1, treinoId: tA.treino.id, nome: 'Treino A', foco: 'Peito'),
          PassoCiclo(dia: 2, treinoId: tB.treino.id, nome: 'Treino B', foco: 'Costas'),
          const PassoCiclo(dia: 3, treinoId: null, nome: 'Descanso'),
        ],
      );

      await repo.salvarCiclo(ciclo);
      var q = await repo.carregar();
      expect(q.temCicloAtivo, isTrue);
      expect(q.ciclo?.totalDias, 3);

      // Hoje é o dia 1: Treino A
      expect(q.treinoDoDia(hoje)?.treino.id, tA.treino.id);

      // Amanhã é o dia 2: Treino B
      final amanha = somarDias(hoje, 1);
      expect(q.treinoDoDia(amanha)?.treino.id, tB.treino.id);

      // Depois de amanhã é o dia 3: Descanso (treinoDoDia == null)
      final depoisAmanha = somarDias(hoje, 2);
      expect(q.treinoDoDia(depoisAmanha), isNull);
      // Próximo treino a partir do descanso é o Treino A de novo!
      final prox = q.proximoTreino(depoisAmanha);
      expect(prox?.treino.treino.id, tA.treino.id);

      // Ajustar dia atual para o dia 2
      await repo.definirDiaAtualCiclo(2);
      q = await repo.carregar();
      expect(q.treinoDoDia(hoje)?.treino.id, tB.treino.id);

      // Desativar ciclo volta a usar dias da semana
      await repo.desativarCiclo();
      q = await repo.carregar();
      expect(q.temCicloAtivo, isFalse);
    });
  });
}
