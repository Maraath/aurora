import 'package:aurora/core/formato.dart';
import 'package:aurora/core/notificacoes.dart';
import 'package:aurora/core/relogio.dart';
import 'package:aurora/data/assistente_repo.dart';
import 'package:aurora/data/automacoes_repo.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/exemplo.dart';
import 'package:aurora/data/servico_automacoes.dart';
import 'package:aurora/data/textos_automacao.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late BancoAurora db;
  late AutomacoesRepo repo;

  setUpAll(() async {
    iniciarRelogio();
    await initializeDateFormatting('pt_BR');
  });

  setUp(() async {
    db = BancoAurora(NativeDatabase.memory());
    repo = AutomacoesRepo(db);
    await semearExemplo(db);
    await repo.garantirModelos();
  });

  tearDown(() => db.close());

  Future<Automacao> modelo(ModeloAutomacao m) async =>
      (await repo.listar()).firstWhere((a) => a.modelo == m.name);

  Future<Automacao> ligar(ModeloAutomacao m) async {
    await repo.alternar(await modelo(m), true);
    return modelo(m);
  }

  // Sexta, 16/10/2026.
  DateTime sp(int dia, int hora, [int minuto = 0]) => diaSP(2026, 10, dia, hora, minuto);

  test('modelos nascem desligados, um de cada, com o mesmo id em qualquer aparelho', () async {
    await repo.garantirModelos();
    final lista = await repo.listar();
    expect(lista.map((a) => a.modelo), [
      'briefing', 'atrasadas', 'dinheiroSemana', 'metasDomingo', 'habitosSemana',
    ]);
    expect(lista.every((a) => !a.ativa), isTrue);

    final outro = BancoAurora(NativeDatabase.memory());
    await AutomacoesRepo(outro).garantirModelos();
    expect((await AutomacoesRepo(outro).listar()).map((a) => a.id), lista.map((a) => a.id));
    await outro.close();
  });

  group('quando roda', () {
    test('janela de 12 horas e marca de execução', () async {
      final b = await ligar(ModeloAutomacao.briefing);
      expect(pendente(b, sp(16, 6, 59)), isNull); // a de ontem passou de 12 h
      final o = pendente(b, sp(16, 7, 30));
      expect(o?.dia, DateTime(2026, 10, 16));
      expect(pendente(b, sp(16, 19, 30)), isNull); // 12h30 depois: velha demais

      await repo.marcarExecutada(b, o!.dia);
      expect(pendente(await modelo(ModeloAutomacao.briefing), sp(16, 8)), isNull);
      // No dia seguinte roda de novo.
      expect(pendente(await modelo(ModeloAutomacao.briefing), sp(17, 7, 1))?.dia, DateTime(2026, 10, 17));
    });

    test('respeita os dias da semana', () async {
      final atr = await ligar(ModeloAutomacao.atrasadas); // dias úteis 08:00
      expect(pendente(atr, sp(18, 9)), isNull); // domingo
      expect(pendente(atr, sp(19, 8, 5))?.dia, DateTime(2026, 10, 19)); // segunda
      final dinheiro = await ligar(ModeloAutomacao.dinheiroSemana); // sexta 18:00
      expect(pendente(dinheiro, sp(16, 18, 1)), isNotNull);
      expect(descreverAgenda(dinheiro), 'Toda sexta às 18:00');
    });

    test('desligada não roda', () async {
      expect(pendente(await modelo(ModeloAutomacao.briefing), sp(16, 7, 30)), isNull);
    });
  });

  group('execução', () {
    test('grava o texto na conversa e marca; chave geral desligada não roda', () async {
      await ligar(ModeloAutomacao.briefing);
      final agora = agoraSP();
      final b = await modelo(ModeloAutomacao.briefing);
      // Força a ocorrência de hoje para "agora".
      await repo.salvar(
          AutomacoesCompanion(horario: Value(horaDe(agora.hour, agora.minute)), diasSemana: const Value(127)),
          id: b.id);

      await repo.definirLigadas(false);
      expect(await executarPendentes(db, agora: agora), 0);

      await repo.definirLigadas(true);
      expect(await executarPendentes(db, agora: agora), 1);
      expect(await executarPendentes(db, agora: agora), 0); // não repete

      final conversa = await AssistenteRepo(db).carregarConversa();
      expect(conversa.single.papel, PapelMensagem.aurora);
      expect(conversa.single.texto, startsWith('Briefing do dia · '));
      expect(conversa.single.texto, contains('Hábitos: Cardio e Estudo.'));
    });

    test('personalizada vai para a IA', () async {
      String? pedidoRecebido;
      final assistente = AssistenteRepo(db, ia: () => ({required pedido, required contexto, required historico}) async {
            pedidoRecebido = pedido;
            return const RespostaIa('Sua semana foi boa.', []);
          });
      await repo.salvar(AutomacoesCompanion.insert(
        nome: 'Semana de treino',
        modelo: 'personalizada',
        horario: '08:00',
        ativa: const Value(true),
        pedido: const Value('Como foi minha semana de treino?'),
      ));
      final a = (await repo.listar()).last;
      await executarAutomacao(db, a, agora: agoraSP(), assistente: assistente);
      expect(pedidoRecebido, 'Semana de treino: Como foi minha semana de treino?');
      expect((await assistente.carregarConversa()).last.texto, 'Sua semana foi boa.');
    });
  });

  group('textos', () {
    test('atrasadas lista com os dias de atraso', () async {
      final t = await gerarTexto(ModeloAutomacao.atrasadas, db, agoraSP());
      expect(t, contains('Testes Estágios (38 dias)'));
      expect(t, contains('Pagar faculdade (4 dias)'));
    });

    test('dinheiro, metas e hábitos montam sem erro', () async {
      final agora = agoraSP();
      expect(await gerarTexto(ModeloAutomacao.dinheiroSemana, db, agora), contains('Saldo em conta: R\$ 703,18.'));
      expect(await gerarTexto(ModeloAutomacao.metasDomingo, db, agora), contains('Shape 80kg'));
      expect(await gerarTexto(ModeloAutomacao.habitosSemana, db, agora), startsWith('Semana dos hábitos: 0% feito.'));
    });
  });

  test('avisos do aparelho para as automações ligadas', () async {
    await ligar(ModeloAutomacao.briefing);
    await ligar(ModeloAutomacao.dinheiroSemana);
    final avisos = avisosDeAutomacoes(await repo.listar(), sp(16, 12), dias: 7);
    // Briefing: 17 a 23 (7) · dinheiro: sexta 16 às 18h e 23 (2).
    expect(avisos.where((a) => a.titulo == 'Briefing do dia'), hasLength(7));
    expect(avisos.where((a) => a.titulo == 'Revisão do dinheiro'), hasLength(2));
    expect(avisos.first.corpo, 'Pronto no assistente do Aurora.');
  });
}
