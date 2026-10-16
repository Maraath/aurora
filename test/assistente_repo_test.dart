import 'package:aurora/core/relogio.dart';
import 'package:aurora/data/assistente_repo.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/exemplo.dart';
import 'package:aurora/data/financas_repo.dart';
import 'package:aurora/data/habitos_repo.dart';
import 'package:aurora/data/saude_repo.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late BancoAurora db;
  late AssistenteRepo repo;

  setUpAll(() async {
    iniciarRelogio();
    await initializeDateFormatting('pt_BR');
  });

  setUp(() async {
    db = BancoAurora(NativeDatabase.memory());
    repo = AssistenteRepo(db);
    await semearExemplo(db);
  });

  tearDown(() => db.close());

  Future<MensagemAssistente> ultima() async => (await repo.carregarConversa()).last;

  test('gasto entra no saldo e pode ser desfeito', () async {
    await repo.enviar('gastei 35 no mercado');
    final conversa = await repo.carregarConversa();
    expect(conversa.map((m) => m.papel), [PapelMensagem.eu, PapelMensagem.aurora]);
    expect(conversa.last.texto, contains('R\$ 35,00'));
    var q = await FinancasRepo(db).carregar();
    expect(q.saldoCentavos, 70318 - 3500);
    expect(q.mes(hojeSP()).categorias.single.nome, 'Mercado');

    await repo.desfazer(conversa.last);
    q = await FinancasRepo(db).carregar();
    expect(q.saldoCentavos, 70318);
    final depois = await repo.carregarConversa();
    expect(depois[1].desfeita, isTrue);
    expect(depois.last.texto, 'Desfeito.');
  });

  test('lembrete é gravado e aparece na resposta', () async {
    await repo.enviar('me lembra de ligar pro dentista amanhã às 10h');
    final r = await ultima();
    expect(r.itemTipo, 'lembrete');
    final l = await (db.select(db.lembretes)..where((l) => l.id.equals(r.itemId!))).getSingle();
    expect(l.texto, 'Ligar pro dentista');
    expect(emSP(l.quando).hour, 10);
    expect(dataSP(l.quando), hojeSP().add(const Duration(days: 1)));
  });

  test('hábito pelo nome, sem acento nem maiúscula', () async {
    await repo.enviar('Fiz o cardio');
    expect((await ultima()).texto, startsWith('Marquei Cardio como feito hoje. Falta: Estudo.'));
    final q = await HabitosRepo(db).carregar();
    final cardio = q.habitos.firstWhere((h) => h.nome == 'Cardio');
    expect(q.feito(cardio.id, hojeSP()), isTrue);

    await repo.enviar('fiz natação');
    expect((await ultima()).texto, contains('Não achei um hábito chamado “natação”'));
  });

  test('medida e tarefa', () async {
    await repo.enviar('pesei 74,5');
    expect((await SaudeRepo(db).carregar()).ultima('Peso')?.valor, 74.5);
    expect((await ultima()).texto, contains('+0,5 kg'));

    await repo.enviar('tarefa: revisar currículo');
    final t = await (db.select(db.tarefas)..where((t) => t.titulo.equals('Revisar currículo'))).getSingle();
    expect(t.prazo, isNull);
  });

  test('resumos usam os dados do app', () async {
    await repo.enviar('Resumo do meu dia');
    expect((await ultima()).texto, contains('Hábitos por fazer: Cardio, Estudo.'));
    await repo.enviar('como estão meus gastos?');
    expect((await ultima()).texto, contains('Saldo em conta: R\$ 703,18'));
  });

  group('com IA', () {
    test('responde e executa os comandos que propôs', () async {
      String? contextoRecebido;
      final comIa = AssistenteRepo(db, ia: () => ({required pedido, required contexto, required historico}) async {
            contextoRecebido = contexto;
            return const RespostaIa('Vou anotar o almoço e te lembrar da consulta.',
                ['gastei 42 no restaurante', 'me lembra de marcar consulta amanhã às 9h', 'frase que não é comando']);
          });
      await comIa.enviar('almocei fora, deu 42 conto, e preciso marcar consulta amanhã');
      final conversa = await comIa.carregarConversa();
      expect(conversa.first.naFila, isFalse);
      expect(conversa.map((m) => m.papel),
          [PapelMensagem.eu, PapelMensagem.aurora, PapelMensagem.aurora, PapelMensagem.aurora]);
      expect(conversa[2].itemTipo, 'transacao');
      expect(conversa[3].itemTipo, 'lembrete');
      expect((await FinancasRepo(db).carregar()).mes(hojeSP()).saiuCentavos, 4200);
      // O resumo é montado antes de executar os comandos da IA.
      expect(contextoRecebido, contains('saldo em conta R\$ 703,18'));
      expect(contextoRecebido, contains('Shape 80kg'));
    });

    test('sem conexão: fica na fila, avisa uma vez e responde depois', () async {
      var online = false;
      final comIa = AssistenteRepo(db, ia: () => ({required pedido, required contexto, required historico}) async {
            if (!online) throw const ErroIa('sem rede', semConexao: true);
            return const RespostaIa('Agora sim.', []);
          });
      await comIa.enviar('me sugere um treino de pernas');
      var conversa = await comIa.carregarConversa();
      expect(conversa.first.naFila, isTrue);
      expect(conversa.last.texto, startsWith('Sem conexão'));

      online = true;
      await comIa.processarFila();
      conversa = await comIa.carregarConversa();
      expect(conversa.first.naFila, isFalse);
      expect(conversa.last.texto, 'Agora sim.');
    });

    test('limite do dia aparece na conversa', () async {
      final comIa = AssistenteRepo(db, ia: () => ({required pedido, required contexto, required historico}) async {
            throw const ErroIa('Você chegou ao limite de 60 pedidos à IA hoje.');
          });
      await comIa.enviar('o que acha da minha semana?');
      expect((await comIa.carregarConversa()).last.texto, contains('limite de 60'));
      expect(await comIa.tamanhoDaFila(), 1);
    });
  });

  test('o que não é comando vai para a fila', () async {
    await repo.enviar('me sugere um treino de pernas');
    final conversa = await repo.carregarConversa();
    expect(conversa.first.naFila, isTrue);
    expect(conversa.last.papel, PapelMensagem.sistema);
    expect(await repo.tamanhoDaFila(), 1);
  });
}
