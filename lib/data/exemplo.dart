import 'package:drift/drift.dart';

import '../core/relogio.dart';
import 'banco.dart';
import 'saude_repo.dart';

/// Preferência gravada quando a pessoa passa pelas boas-vindas.
const chaveInicio = 'inicio';

/// Aparelho novo: nunca passou pelas boas-vindas nem recebeu os dados de
/// exemplo (que só existem nos aparelhos de antes da versão 1.0.3).
Future<bool> ehPrimeiraVez(BancoAurora db) async {
  // Em passos separados: na web compilada em WebAssembly, `await a == null && await b == null`
  // numa função de uma linha falhava na conferência de tipo e o app travava na abertura.
  final inicio = await db.preferencia(chaveInicio);
  if (inicio != null) return false;
  final semeado = await db.preferencia('exemplo_semeado');
  return semeado == null;
}

/// Dados de exemplo do protótipo. O app não os cria mais (cada pessoa começa
/// vazia); ficam para os testes. As datas são relativas a hoje.
Future<void> semearExemplo(BancoAurora db) async {
  await _etapa1(db);
  await _etapa2(db);
  await _etapa4(db);
}

/// Fase 4: ficha com Treino A e B, um treino A já feito (de onde saem as
/// cargas sugeridas do protótipo: 40, 14 e 25 kg) e medidas de peso e braço.
Future<void> _etapa4(BancoAurora db) async {
  if (await db.preferencia('exemplo_v4') != null) return;
  final saude = SaudeRepo(db);
  final hoje = hojeSP();
  DateTime antes(int dias) => hoje.subtract(Duration(days: dias));

  await db.transaction(() async {
    final a = await saude.salvarTreino(
      TreinosCompanion.insert(
          nome: 'Treino A', foco: const Value('Peito e tríceps'), diasSemana: const Value(1 | 8)),
      [
        (nome: 'Supino reto', series: 4, repeticoes: 10, cargaInicial: 30),
        (nome: 'Crucifixo com halteres', series: 3, repeticoes: 12, cargaInicial: 10),
        (nome: 'Tríceps na corda', series: 3, repeticoes: 12, cargaInicial: 20),
      ],
    );
    await saude.salvarTreino(
      TreinosCompanion.insert(
          nome: 'Treino B', foco: const Value('Costas e bíceps'), diasSemana: const Value(2 | 16)),
      [
        (nome: 'Puxada frontal', series: 4, repeticoes: 10, cargaInicial: 35),
        (nome: 'Remada baixa', series: 3, repeticoes: 12, cargaInicial: 30),
        (nome: 'Rosca direta', series: 3, repeticoes: 12, cargaInicial: 10),
      ],
    );

    final supino = await saude.exercicioPorNome('Supino reto');
    final crucifixo = await saude.exercicioPorNome('Crucifixo com halteres');
    final triceps = await saude.exercicioPorNome('Tríceps na corda');
    await saude.registrarSessao(
      treinoId: a,
      inicio: instanteSP(antes(3), 19),
      series: [
        for (var n = 1; n <= 4; n++) (exercicioId: supino, numero: n, repeticoes: 10, cargaKg: 37.5),
        for (var n = 1; n <= 3; n++)
          (exercicioId: crucifixo, numero: n, repeticoes: n == 3 ? 10 : 12, cargaKg: 14.0),
        for (var n = 1; n <= 3; n++) (exercicioId: triceps, numero: n, repeticoes: 12, cargaKg: 22.5),
      ],
    );

    await saude.salvarMedidas(antes(30), [
      (tipo: 'Peso', valor: 73.5, unidade: 'kg'),
      (tipo: 'Braço', valor: 36.5, unidade: 'cm'),
    ]);
    await saude.salvarMedidas(antes(14), [(tipo: 'Peso', valor: 73.8, unidade: 'kg')]);
    await saude.salvarMedidas(antes(2), [
      (tipo: 'Peso', valor: 74, unidade: 'kg'),
      (tipo: 'Braço', valor: 37, unidade: 'cm'),
    ]);
    await db.salvarPreferencia('exemplo_v4', DateTime.now().toIso8601String());
  });
}

/// Fase 2: lembretes do protótipo e uma tarefa recorrente.
Future<void> _etapa2(BancoAurora db) async {
  if (await db.preferencia('exemplo_v2') != null) return;
  final hoje = hojeSP();
  DateTime dia(int deslocamento, int hora) =>
      instanteSP(hoje.add(Duration(days: deslocamento)), hora);
  // Próxima data (a partir de hoje) que cai no dia da semana pedido (1 = segunda).
  DateTime proximo(int diaSemana, int hora) =>
      dia((diaSemana - hoje.weekday) % 7, hora);

  await db.transaction(() async {
    await db.batch((b) {
      b.insertAll(db.lembretes, [
        LembretesCompanion.insert(
            texto: 'Revisar gastos da semana',
            quando: proximo(DateTime.friday, 18),
            regraRepeticao: const Value('FREQ=WEEKLY;BYDAY=FR')),
        LembretesCompanion.insert(
            texto: 'Academia',
            quando: proximo(DateTime.monday, 19),
            regraRepeticao: const Value('FREQ=WEEKLY;BYDAY=MO,WE,FR')),
        LembretesCompanion.insert(
            texto: 'Pagar iCloud e Spotify',
            quando: instanteSP(DateTime(hoje.year, hoje.month, 9), 9),
            regraRepeticao: const Value('FREQ=MONTHLY;BYMONTHDAY=9')),
        LembretesCompanion.insert(
            texto: 'Entregar documentos do estágio', quando: dia(5, 14)),
      ]);
      b.insert(
          db.tarefas,
          TarefasCompanion.insert(
            titulo: 'Planejar a semana',
            prazo: Value(proximo(DateTime.sunday, 20)),
            prazoTemHora: const Value(true),
            regraRepeticao: const Value('FREQ=WEEKLY;BYDAY=SU'),
          ));
    });
    await db.salvarPreferencia('exemplo_v2', DateTime.now().toIso8601String());
  });
}

Future<void> _etapa1(BancoAurora db) async {
  if (await db.preferencia('exemplo_semeado') != null) return;

  final agora = agoraSP();
  final hoje = diaSP(agora.year, agora.month, agora.day);
  DateTime dia(int deslocamento, [int hora = 0, int minuto = 0]) =>
      diaSP(hoje.year, hoje.month, hoje.day + deslocamento, hora, minuto);

  await db.transaction(() async {
    final meta = await db.into(db.metas).insertReturning(MetasCompanion.insert(
          nome: 'Shape 80kg',
          valorInicial: 73.5,
          valorAtual: 74,
          valorAlvo: 80,
          unidade: const Value('kg'),
          dataAlvo: Value(diaSP(hoje.year, 12, 31)),
        ));

    await db.batch((b) {
      b.insertAll(db.habitos, [
        HabitosCompanion.insert(
            nome: 'Cardio', tipo: const Value(TipoHabito.duracao), alvo: const Value(30)),
        HabitosCompanion.insert(
            nome: 'Estudo', tipo: const Value(TipoHabito.duracao), alvo: const Value(60)),
      ]);

      b.insertAll(db.tarefas, [
        TarefasCompanion.insert(
            titulo: 'Fórmula Mágica',
            prazo: Value(dia(0, 21)),
            prazoTemHora: const Value(true),
            prioridade: const Value(Prioridade.alta)),
        TarefasCompanion.insert(
            titulo: 'Pagar faculdade',
            prazo: Value(dia(-4)),
            prioridade: const Value(Prioridade.alta)),
        TarefasCompanion.insert(
            titulo: 'Tribulus + creatina',
            prazo: Value(dia(-1)),
            metaId: Value(meta.id)),
        TarefasCompanion.insert(titulo: 'Testes Estágios', prazo: Value(dia(-38))),
        TarefasCompanion.insert(
            titulo: 'Revisar gastos da semana',
            prazo: Value(dia(2, 18)),
            prazoTemHora: const Value(true),
            prioridade: const Value(Prioridade.baixa)),
      ]);

      b.insert(
          db.lembretes,
          LembretesCompanion.insert(
              texto: 'Tomar vitamina',
              quando: dia(1, 8),
              regraRepeticao: const Value('FREQ=DAILY')));
    });

    final conta = await db.into(db.contasFinanceiras).insertReturning(
        ContasFinanceirasCompanion.insert(
            nome: 'Conta corrente',
            tipo: TipoConta.corrente,
            saldoInicialCentavos: const Value(70318)));

    TransacoesCompanion novaConta(String nome, int centavos, int venceEm,
            {int? parcela, int? total}) =>
        TransacoesCompanion.insert(
          descricao: nome,
          valorCentavos: centavos,
          tipo: TipoTransacao.saida,
          data: dia(venceEm),
          vencimento: Value(dia(venceEm)),
          categoria: const Value('Serviços'),
          parcelaNumero: Value(parcela),
          parcelaTotal: Value(total),
          contaId: Value(conta.id),
        );

    await db.batch((b) => b.insertAll(db.transacoes, [
          novaConta('iCloud', 1990, -6),
          novaConta('Spotify', 1290, -6),
          novaConta('Faculdade', 19000, -5, parcela: 2, total: 27),
        ]));

    await db.salvarPreferencia('nome', 'Maraath');
    await db.salvarPreferencia('exemplo_semeado', agora.toIso8601String());
  });
}
