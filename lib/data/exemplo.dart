import 'package:drift/drift.dart';

import '../core/relogio.dart';
import 'banco.dart';

/// Preenche o banco com os dados de exemplo do protótipo na primeira abertura.
/// As datas são relativas a hoje para a tela Visão sempre ter o que mostrar.
Future<void> semearExemplo(BancoAurora db) async {
  await _etapa1(db);
  await _etapa2(db);
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
