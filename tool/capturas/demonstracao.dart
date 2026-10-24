import 'dart:math';

import 'package:aurora/core/relogio.dart';
import 'package:aurora/data/alimentacao_repo.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/exemplo.dart';
import 'package:aurora/data/saude_repo.dart';
import 'package:drift/drift.dart';

/// Dados de demonstração para as capturas do README: três meses de finanças,
/// hábitos, tarefas, treinos, medidas e uma conversa com a Aurora. Só roda num
/// banco separado (tool/capturas/main.dart); o app nunca chama isto.
Future<void> semearDemonstracao(BancoAurora db) async {
  if (await db.preferencia('demonstracao') != null) return;
  final sorte = Random(7);
  final hoje = hojeSP();
  DateTime dia(int deslocamento) => hoje.add(Duration(days: deslocamento));
  DateTime as(int deslocamento, int hora, [int minuto = 0]) => instanteSP(dia(deslocamento), hora, minuto);

  await db.transaction(() async {
    // Metas
    final reserva = await db.into(db.metas).insertReturning(MetasCompanion.insert(
        nome: 'Reserva de emergência',
        criadoEm: Value(as(-150, 9)),
        valorInicial: 0,
        valorAtual: 620000,
        valorAlvo: 1000000,
        unidade: const Value('R\$'),
        dataAlvo: Value(instanteSP(DateTime(hoje.year, 12, 31)))));
    final corrida = await db.into(db.metas).insertReturning(MetasCompanion.insert(
        nome: 'Correr 10 km',
        criadoEm: Value(as(-75, 9)),
        valorInicial: 3,
        valorAtual: 7,
        valorAlvo: 10,
        unidade: const Value('km'),
        dataAlvo: Value(instanteSP(DateTime(hoje.year, 12, 15)))));
    await db.into(db.metas).insert(MetasCompanion.insert(
        nome: 'Ler 12 livros no ano',
        criadoEm: Value(as(-290, 9)),
        valorInicial: 0,
        valorAtual: 9,
        valorAlvo: 12,
        unidade: const Value('livros'),
        dataAlvo: Value(instanteSP(DateTime(hoje.year, 12, 31)))));

    // Projeto com etapas (etapas são tarefas)
    final projeto = await db.into(db.projetos).insertReturning(ProjetosCompanion.insert(
        nome: 'Lançar o portfólio', inicio: as(-21, 9), fim: as(18, 18)));
    final etapas = [
      ('Escolher os projetos em destaque', -18, true),
      ('Escrever os textos de cada projeto', -10, true),
      ('Tirar as capturas de tela', -1, true),
      ('Revisar o README', 0, false),
      ('Publicar e divulgar', 6, false),
    ];
    for (final (titulo, d, feita) in etapas) {
      await db.into(db.tarefas).insert(TarefasCompanion.insert(
          titulo: titulo,
          prazo: Value(as(d, 18)),
          projetoId: Value(projeto.id),
          feitaEm: Value(feita ? as(d, 17) : null)));
    }

    final mudanca = await db.into(db.projetos).insertReturning(ProjetosCompanion.insert(
        nome: 'Mudança de apartamento', inicio: as(-8, 9), fim: as(52, 18)));
    for (final (titulo, d, feita) in [
      ('Pesquisar transportadoras', -5, true),
      ('Separar o que doar', 9, false),
      ('Contratar a mudança', 20, false),
      ('Transferir internet e luz', 45, false),
    ]) {
      await db.into(db.tarefas).insert(TarefasCompanion.insert(
          titulo: titulo,
          prazo: Value(as(d, 18)),
          projetoId: Value(mudanca.id),
          feitaEm: Value(feita ? as(d, 17) : null)));
    }

    // Tarefas de hoje e dos próximos dias
    await db.batch((b) => b.insertAll(db.tarefas, [
          TarefasCompanion.insert(
              titulo: 'Reunião de planejamento',
              prazo: Value(as(0, 10)),
              prazoTemHora: const Value(true),
              prioridade: const Value(Prioridade.alta)),
          TarefasCompanion.insert(
              titulo: 'Pagar a fatura do cartão', prazo: Value(as(-1, 0)), prioridade: const Value(Prioridade.alta)),
          TarefasCompanion.insert(
              titulo: 'Estudar Flutter: animações', prazo: Value(as(0, 20)), prazoTemHora: const Value(true)),
          TarefasCompanion.insert(
              titulo: 'Corrida de 7 km no parque', prazo: Value(as(1, 7)), metaId: Value(corrida.id)),
          TarefasCompanion.insert(
              titulo: 'Comprar presente de aniversário',
              prazo: Value(as(3, 0)),
              prioridade: const Value(Prioridade.baixa)),
          TarefasCompanion.insert(
              titulo: 'Planejar a semana',
              prazo: Value(as((7 - hoje.weekday) % 7, 20)),
              prazoTemHora: const Value(true),
              regraRepeticao: const Value('FREQ=WEEKLY;BYDAY=SU')),
        ]));
    // Histórico de tarefas feitas (para a aba Análise)
    const feitas = [
      'Responder e-mails', 'Organizar a mesa', 'Revisar o orçamento', 'Ligar para o banco', 'Atualizar o currículo',
      'Agendar consulta', 'Trocar o filtro de água', 'Ler artigo sobre SQLite', 'Backup das fotos', 'Renovar a CNH',
    ];
    for (var i = 0; i < 26; i++) {
      final d = -1 - sorte.nextInt(27);
      await db.into(db.tarefas).insert(TarefasCompanion.insert(
          titulo: feitas[i % feitas.length],
          prazo: Value(as(d + sorte.nextInt(2), 18)),
          prioridade: Value(Prioridade.values[sorte.nextInt(3)]),
          feitaEm: Value(as(d, 9 + sorte.nextInt(10)))));
    }

    // Hábitos com dois meses de registros
    final habitos = [
      (HabitosCompanion.insert(nome: 'Meditar', horario: const Value('07:00')), 0.86, null),
      (
        HabitosCompanion.insert(
            nome: 'Beber água', tipo: const Value(TipoHabito.quantidade), alvo: const Value(8), unidade: const Value('copos')),
        0.9,
        8
      ),
      (HabitosCompanion.insert(nome: 'Leitura', tipo: const Value(TipoHabito.duracao), alvo: const Value(30)), 0.78, 30),
      (
        HabitosCompanion.insert(
            nome: 'Cardio',
            tipo: const Value(TipoHabito.duracao),
            alvo: const Value(30),
            diasSemana: const Value(1 | 4 | 16),
            metaId: Value(corrida.id)),
        0.88,
        35
      ),
    ];
    for (final (dados, chance, valor) in habitos) {
      final h = await db.into(db.habitos).insertReturning(dados.copyWith(criadoEm: Value(as(-61, 8))));
      for (var d = -60; d <= 0; d++) {
        final data = dia(d);
        if ((h.diasSemana >> (data.weekday - 1)) & 1 == 0) continue;
        if (d == 0 && h.nome != 'Meditar') continue; // hoje ainda pendente
        if (sorte.nextDouble() > chance) continue;
        await db.into(db.registrosHabito).insert(RegistrosHabitoCompanion.insert(
            habitoId: h.id,
            dia: chaveData(data),
            valor: Value(valor == null ? null : valor - sorte.nextInt(3))));
      }
    }

    // Lembretes
    await db.batch((b) => b.insertAll(db.lembretes, [
          LembretesCompanion.insert(
              texto: 'Tomar vitamina D', quando: as(1, 8), regraRepeticao: const Value('FREQ=DAILY')),
          LembretesCompanion.insert(
              texto: 'Revisar gastos da semana',
              quando: as((5 - hoje.weekday) % 7, 18),
              regraRepeticao: const Value('FREQ=WEEKLY;BYDAY=FR')),
          LembretesCompanion.insert(texto: 'Ligar para o dentista', quando: as(1, 10)),
          LembretesCompanion.insert(
              texto: 'Regar as plantas', quando: as(2, 19), regraRepeticao: const Value('FREQ=WEEKLY;BYDAY=TU,SA')),
        ]));

    // Finanças: contas, fixas com pagamentos, parcelada e gastos do dia a dia
    final corrente = await db.into(db.contasFinanceiras).insertReturning(ContasFinanceirasCompanion.insert(
        nome: 'Conta corrente', tipo: TipoConta.corrente, saldoInicialCentavos: const Value(420000)));
    await db.into(db.contasFinanceiras).insert(ContasFinanceirasCompanion.insert(
        nome: 'Reserva', tipo: TipoConta.poupanca, saldoInicialCentavos: Value(reserva.valorAtual.round())));

    final inicio = DateTime(hoje.year, hoje.month - 3, 1);
    Future<void> fixa(String nome, int centavos, int diaDoMes, String categoria,
        {TipoTransacao tipo = TipoTransacao.saida, int? parcelas}) async {
      final primeira = DateTime(inicio.year, inicio.month, diaDoMes);
      final t = await db.into(db.transacoes).insertReturning(TransacoesCompanion.insert(
          descricao: nome,
          valorCentavos: centavos,
          tipo: tipo,
          data: instanteSP(primeira),
          vencimento: Value(instanteSP(primeira)),
          categoria: Value(categoria),
          regraRepeticao: Value('FREQ=MONTHLY;BYMONTHDAY=$diaDoMes'),
          parcelaTotal: Value(parcelas),
          contaId: Value(corrente.id)));
      for (var m = 0;; m++) {
        final v = DateTime(primeira.year, primeira.month + m, diaDoMes);
        if (v.isAfter(hoje)) break;
        await db.into(db.pagamentosTransacao).insert(PagamentosTransacaoCompanion.insert(
            transacaoId: t.id, vencimento: chaveData(v), pagoEm: instanteSP(v, 9), valorCentavos: centavos));
      }
    }

    await fixa('Salário', 680000, 5, 'Salário', tipo: TipoTransacao.entrada);
    await fixa('Aluguel', 185000, 10, 'Moradia');
    await fixa('Condomínio', 42000, 10, 'Moradia');
    await fixa('Internet', 11990, 15, 'Serviços');
    await fixa('Streaming', 5590, 20, 'Serviços');
    await fixa('Academia', 11900, 8, 'Saúde');
    await fixa('Curso de inglês', 29900, 12, 'Educação', parcelas: 12);

    final variaveis = [
      ('Mercado', 'Mercado', 7, 18000, 46000),
      ('Feira', 'Mercado', 9, 4000, 9000),
      ('Uber', 'Transporte', 5, 1500, 4800),
      ('Combustível', 'Transporte', 12, 15000, 24000),
      ('Restaurante', 'Lazer', 8, 6000, 16000),
      ('Cinema', 'Lazer', 20, 4000, 7000),
      ('Farmácia', 'Saúde', 18, 2500, 9000),
      ('Livro', 'Educação', 25, 3500, 8000),
    ];
    final primeiroDia = diasEntre(inicio, hoje);
    for (final (nome, categoria, cada, minimo, maximo) in variaveis) {
      for (var d = -primeiroDia + sorte.nextInt(cada); d <= 0; d += cada - 1 + sorte.nextInt(3)) {
        final quando = as(d, 10 + sorte.nextInt(10), sorte.nextInt(60));
        await db.into(db.transacoes).insert(TransacoesCompanion.insert(
            descricao: nome,
            valorCentavos: minimo + sorte.nextInt(maximo - minimo),
            tipo: TipoTransacao.saida,
            data: quando,
            pagoEm: Value(quando),
            categoria: Value(categoria),
            contaId: Value(corrente.id)));
      }
    }
    for (final (d, valor) in [(-70, 120000), (-38, 85000), (-9, 150000)]) {
      final quando = as(d, 15);
      await db.into(db.transacoes).insert(TransacoesCompanion.insert(
          descricao: 'Projeto freelance',
          valorCentavos: valor,
          tipo: TipoTransacao.entrada,
          data: quando,
          pagoEm: Value(quando),
          categoria: const Value('Freela'),
          contaId: Value(corrente.id)));
    }

    // Saúde: ficha, quatro semanas de treinos com carga subindo e medidas
    final saude = SaudeRepo(db);
    final fichas = [
      (
        TreinosCompanion.insert(nome: 'Treino A', foco: const Value('Peito e tríceps'), diasSemana: const Value(1 | 8)),
        [('Supino reto', 4, 10, 30.0), ('Supino inclinado com halteres', 3, 12, 12.0), ('Tríceps na corda', 3, 12, 20.0)]
      ),
      (
        TreinosCompanion.insert(nome: 'Treino B', foco: const Value('Costas e bíceps'), diasSemana: const Value(2 | 16)),
        [('Puxada frontal', 4, 10, 35.0), ('Remada baixa', 3, 12, 30.0), ('Rosca direta', 3, 12, 10.0)]
      ),
      (
        TreinosCompanion.insert(nome: 'Treino C', foco: const Value('Pernas e ombros'), diasSemana: const Value(4)),
        [('Agachamento livre', 4, 10, 40.0), ('Leg press', 3, 12, 120.0), ('Desenvolvimento com halteres', 3, 12, 12.0)]
      ),
    ];
    for (final (dados, itens) in fichas) {
      final id = await saude.salvarTreino(dados, [
        for (final (nome, series, repeticoes, carga) in itens)
          (nome: nome, series: series, repeticoes: repeticoes, cargaInicial: carga),
      ]);
      final dias = dados.diasSemana.value;
      for (var d = -28; d < 0; d++) {
        final data = dia(d);
        if ((dias >> (data.weekday - 1)) & 1 == 0) continue;
        final semana = (d + 28) ~/ 7;
        await saude.registrarSessao(treinoId: id, inicio: as(d, 19), series: [
          for (final (nome, series, repeticoes, carga) in itens)
            for (var n = 1; n <= series; n++)
              (
                exercicioId: await saude.exercicioPorNome(nome),
                numero: n,
                repeticoes: repeticoes,
                cargaKg: carga + semana * (carga >= 30 ? 2.5 : 1.0),
              ),
        ]);
      }
    }
    for (var semana = 8; semana >= 0; semana--) {
      await saude.salvarMedidas(dia(-semana * 7), [
        (tipo: 'Peso', valor: double.parse((75.4 + semana * 0.35 + sorte.nextDouble() * 0.3).toStringAsFixed(1)), unidade: 'kg'),
        if (semana % 2 == 0)
          (tipo: 'Cintura', valor: double.parse((82.0 + semana * 0.4).toStringAsFixed(1)), unidade: 'cm'),
      ]);
    }

    // Alimentação de hoje
    final alimentacao = AlimentacaoRepo(db);
    await alimentacao.salvarAlvo(TipoDia.treino, const Nutrientes(2400, 160, 280, 70));
    await alimentacao.salvarAlvo(TipoDia.descanso, const Nutrientes(2100, 150, 220, 65));
    await db.batch((b) => b.insertAll(db.registrosAlimentacao, [
          RegistrosAlimentacaoCompanion.insert(
              dia: chaveData(hoje), refeicao: 'cafe', nome: 'Pão integral', gramas: 50, kcal: 125, proteina: const Value(4.7), carboidrato: const Value(24.9), gordura: const Value(1.7)),
          RegistrosAlimentacaoCompanion.insert(
              dia: chaveData(hoje), refeicao: 'cafe', nome: 'Ovo cozido', gramas: 100, kcal: 146, proteina: const Value(13.3), carboidrato: const Value(0.6), gordura: const Value(9.5)),
          RegistrosAlimentacaoCompanion.insert(
              dia: chaveData(hoje), refeicao: 'almoco', nome: 'Arroz integral cozido', gramas: 150, kcal: 186, proteina: const Value(3.9), carboidrato: const Value(38.7), gordura: const Value(1.5)),
          RegistrosAlimentacaoCompanion.insert(
              dia: chaveData(hoje), refeicao: 'almoco', nome: 'Feijão carioca cozido', gramas: 100, kcal: 76, proteina: const Value(4.8), carboidrato: const Value(13.6), gordura: const Value(0.5)),
          RegistrosAlimentacaoCompanion.insert(
              dia: chaveData(hoje), refeicao: 'almoco', nome: 'Frango, peito grelhado', gramas: 150, kcal: 239, proteina: const Value(48), carboidrato: const Value(0), gordura: const Value(3.8)),
        ]));

    // Conversa com a Aurora (valores calculados dos lançamentos acima)
    final mes = DateTime(hoje.year, hoje.month);
    final doMes = await (db.select(db.transacoes)
          ..where((t) =>
              t.tipo.equalsValue(TipoTransacao.saida) &
              t.regraRepeticao.isNull() &
              t.data.isBiggerOrEqualValue(instanteSP(mes))))
        .get();
    final porCategoria = <String, int>{};
    for (final t in doMes) {
      porCategoria[t.categoria!] = (porCategoria[t.categoria!] ?? 0) + t.valorCentavos;
    }
    final total = porCategoria.values.fold(0, (a, b) => a + b);
    final maiores = porCategoria.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    String reais(int c) {
      final inteiro = (c ~/ 100).toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+$)'), (_) => '.');
      return 'R\$ $inteiro,${(c % 100).toString().padLeft(2, '0')}';
    }

    final conversa = [
      (PapelMensagem.eu, 'gastei 42 no mercado', -1),
      (PapelMensagem.aurora, 'Pronto! Lancei **R\$ 42,00** em Mercado, hoje.', -1),
      (PapelMensagem.eu, 'como estão meus gastos do dia a dia este mês?', 0),
      (
        PapelMensagem.aurora,
        'Neste mês, fora as contas fixas, saíram **${reais(total)}**.\n\n'
            '• ${maiores[0].key}: ${reais(maiores[0].value)}\n'
            '• ${maiores[1].key}: ${reais(maiores[1].value)}\n'
            '• ${maiores[2].key}: ${reais(maiores[2].value)}\n\n'
            '${maiores[0].key} é a maior parte. Quer que eu monte um limite semanal para ela?',
        0
      ),
      (PapelMensagem.eu, 'me lembra de ligar para o dentista amanhã às 10', 1),
      (PapelMensagem.aurora, 'Combinado: lembrete **Ligar para o dentista** amanhã às 10:00.', 1),
    ];
    for (final (i, (papel, texto, _)) in conversa.indexed) {
      final quando = as(0, 9, 10 + i * 2);
      await db.into(db.mensagensAssistente).insert(MensagensAssistenteCompanion.insert(
          papel: papel, texto: texto, criadoEm: Value(quando), atualizadoEm: Value(quando)));
    }

    await db.salvarPreferencia('nome', 'Maraath');
    await db.salvarPreferencia(chaveInicio, DateTime.now().toIso8601String());
    await db.salvarPreferencia('demonstracao', DateTime.now().toIso8601String());
  });
}
