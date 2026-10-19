import 'package:aurora/core/relogio.dart';
import 'package:aurora/data/assistente_repo.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/exemplo.dart';
import 'package:aurora/data/financas_repo.dart';
import 'package:aurora/data/alimentacao_repo.dart';
import 'package:aurora/data/habitos_repo.dart';
import 'package:aurora/data/ia/ferramentas_ia.dart' show consultar, telaPedidaPelaIa;
import 'package:aurora/data/metas_repo.dart';
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
    test('texto chega aos poucos, ferramentas rodam no aparelho e a IA continua', () async {
      final chamadas = <List<Map<String, Object?>>>[];
      final contextos = <String>[];
      final amanha = hojeSP().add(const Duration(days: 1));
      final dataAmanha = '${amanha.year}-${'${amanha.month}'.padLeft(2, '0')}-${'${amanha.day}'.padLeft(2, '0')}';
      final comIa = AssistenteRepo(db, ia: () => (mensagens, contexto) async* {
            chamadas.add([...mensagens]);
            contextos.add(contexto);
            if (mensagens.last['role'] == 'user') {
              yield const TextoIa('Vou anotar ');
              yield const TextoIa('o almoço.');
              yield const FerramentaIa(id: 'c1', nome: 'registrar_lancamento', entrada: {
                'tipo': 'gasto',
                'valor': 42,
                'descricao': 'restaurante',
              });
              yield FerramentaIa(id: 'c2', nome: 'criar_lembrete', entrada: {
                'texto': 'marcar consulta',
                'data': dataAmanha,
                'hora': '09:00',
              });
              yield const FerramentaIa(id: 'c3', nome: 'marcar_habito', entrada: {'nome': 'Natação'});
              yield const FimIa('tool-calls');
            } else {
              yield const TextoIa('Pronto! Anotei e agendei.');
              yield const FimIa('stop');
            }
          });
      await comIa.enviar('almocei fora, deu 42 conto, e preciso marcar consulta amanhã');

      final conversa = await comIa.carregarConversa();
      expect(conversa.first.naFila, isFalse);
      expect(conversa.map((m) => m.papel),
          [PapelMensagem.eu, PapelMensagem.aurora, PapelMensagem.aurora, PapelMensagem.aurora, PapelMensagem.aurora]);
      expect(conversa[1].texto, 'Vou anotar o almoço.', reason: 'os pedaços do stream viram uma mensagem só');
      expect(conversa[2].itemTipo, 'transacao');
      expect(conversa[3].itemTipo, 'lembrete');
      expect(conversa.last.texto, 'Pronto! Anotei e agendei.');
      expect((await FinancasRepo(db).carregar()).mes(hojeSP()).saiuCentavos, 4200);

      // Segunda chamada: a conversa + a resposta com as chamadas + os resultados.
      expect(chamadas, hasLength(2));
      final volta = chamadas[1];
      expect(volta[volta.length - 2]['role'], 'assistant');
      expect((volta[volta.length - 2]['content'] as List).where((p) => (p as Map)['type'] == 'tool-call'), hasLength(3));
      final resultados = volta.last['content'] as List;
      expect(volta.last['role'], 'tool');
      expect(resultados.map((r) => ((r as Map)['output'] as Map)['type']), ['text', 'text', 'error-text'],
          reason: 'hábito que não existe volta como erro para a IA explicar');
      expect(contextos.first, contains('saldo em conta R\$ 703,18'));
      expect(contextos.last, contains('saiu R\$ 42,00'), reason: 'o resumo é refeito depois das ferramentas');
    });

    test('abrir_tela avisa a Shell e consultar devolve dados do aparelho', () async {
      final comIa = AssistenteRepo(db, ia: () => (mensagens, contexto) async* {
            if (mensagens.last['role'] == 'user') {
              yield const FerramentaIa(id: 'a', nome: 'abrir_tela', entrada: {'tela': 'shape'});
              yield const FerramentaIa(id: 'b', nome: 'consultar', entrada: {'area': 'habitos', 'periodo_dias': 7});
            } else {
              final r = ((mensagens.last['content'] as List)[1] as Map)['output'] as Map;
              yield TextoIa('${r['value']}');
            }
          });
      String? tela;
      void ouvir() => tela = telaPedidaPelaIa.value;
      telaPedidaPelaIa.addListener(ouvir);
      addTearDown(() => telaPedidaPelaIa.removeListener(ouvir));
      await comIa.enviar('mostra minhas fotos e como foram meus hábitos');
      expect(tela, 'shape');
      expect((await comIa.carregarConversa()).last.texto, contains('Cardio: feito'));
    });

    test('sem conexão: fica na fila, avisa uma vez e responde depois', () async {
      var online = false;
      final comIa = AssistenteRepo(db, ia: () => (mensagens, contexto) async* {
            if (!online) throw const ErroIa('sem rede', semConexao: true);
            yield const TextoIa('Agora sim.');
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

    test('resposta que cai no meio fica e ganha um aviso', () async {
      final comIa = AssistenteRepo(db, ia: () => (mensagens, contexto) async* {
            yield const TextoIa('Começando a responder');
            throw const ErroIa('A conexão com a IA caiu no meio da resposta.', semConexao: true);
          });
      await comIa.enviar('me explica progressão de carga');
      final conversa = await comIa.carregarConversa();
      expect(conversa[1].texto, 'Começando a responder');
      expect(conversa.last.papel, PapelMensagem.sistema);
      expect(conversa.last.texto, contains('parou no meio'));
      expect(await comIa.tamanhoDaFila(), 0);
    });

    test('limite do dia aparece na conversa', () async {
      final comIa = AssistenteRepo(db, ia: () => (mensagens, contexto) async* {
            throw const ErroIa('Você chegou ao limite de 60 pedidos à IA hoje.');
          });
      await comIa.enviar('o que acha da minha semana?');
      expect((await comIa.carregarConversa()).last.texto, contains('limite de 60'));
      expect(await comIa.tamanhoDaFila(), 1);
    });

    test('com IA, o resumo do dia vai para ela', () async {
      var chamou = false;
      final comIa = AssistenteRepo(db, ia: () => (mensagens, contexto) async* {
            chamou = true;
            yield const TextoIa('Seu dia está tranquilo.');
          });
      await comIa.enviar('Resumo do meu dia');
      expect(chamou, isTrue);
      expect((await comIa.carregarConversa()).last.texto, 'Seu dia está tranquilo.');
    });
  });

  group('agente: alterar e excluir', () {
    /// IA de teste: na primeira volta pede [ferramenta]; na segunda devolve o
    /// resultado como texto (para o teste ler) e guarda a etapa mostrada.
    (AssistenteRepo, List<String?>) agente(String ferramenta, Map<String, Object?> entrada, {bool confirmar = true}) {
      final etapas = <String?>[];
      final perguntas = <String>[];
      final repo = AssistenteRepo(db,
          confirmar: (p) async {
            perguntas.add(p);
            return confirmar;
          },
          ia: () => (mensagens, contexto) async* {
                if (mensagens.last['role'] == 'user') {
                  yield FerramentaIa(id: 'x', nome: ferramenta, entrada: entrada);
                } else {
                  etapas.add(AssistenteRepo.etapa.value);
                  final r = ((mensagens.last['content'] as List).single as Map)['output'] as Map;
                  yield TextoIa('${r['type']}|${r['value']}');
                }
              });
      return (repo, etapas);
    }

    test('excluir medida: pede confirmação, apaga e dá para desfazer', () async {
      final saude = SaudeRepo(db);
      final peso = (await saude.carregar()).medidas['Peso']!.first;
      final perguntas = <String>[];
      final etapas = <String?>[];
      final repo = AssistenteRepo(db,
          confirmar: (p) async {
            perguntas.add(p);
            return true;
          },
          ia: () => (mensagens, contexto) async* {
                if (mensagens.last['role'] == 'user') {
                  yield FerramentaIa(id: 'x', nome: 'excluir_registro_shape', entrada: {'tipo': 'medida', 'id': peso.id});
                } else {
                  etapas.add(AssistenteRepo.etapa.value);
                  yield const TextoIa('Pronto.');
                }
              });
      await repo.enviar('apaga meu peso mais antigo');
      expect(perguntas.single, contains('Excluir a medida Peso'));
      expect(etapas.single, 'Excluindo...');
      expect((await saude.carregar()).medidas['Peso']!.any((m) => m.id == peso.id), isFalse);
      final aviso = (await repo.carregarConversa()).firstWhere((m) => m.itemTipo == 'medida_excluida');
      await repo.desfazer(aviso);
      expect((await saude.carregar()).medidas['Peso']!.any((m) => m.id == peso.id), isTrue);
    });

    test('excluir cancelado: nada some e a IA fica sabendo', () async {
      final saude = SaudeRepo(db);
      final peso = (await saude.carregar()).medidas['Peso']!.first;
      final (repo, _) = agente('excluir_registro_shape', {'tipo': 'medida', 'id': peso.id}, confirmar: false);
      await repo.enviar('apaga meu peso mais antigo');
      expect((await saude.carregar()).medidas['Peso']!.any((m) => m.id == peso.id), isTrue);
      expect((await repo.carregarConversa()).last.texto, contains('cancelou'));
    });

    test('excluir com id que não existe não pergunta nada', () async {
      final (repo, _) = agente('excluir_registro_shape', {'tipo': 'foto', 'id': 'nao-existe'});
      await repo.enviar('apaga minha foto');
      expect((await repo.carregarConversa()).last.texto, startsWith('error-text|'));
    });

    test('meta de dieta muda só o que veio e desfazer volta', () async {
      final alimentacao = AlimentacaoRepo(db);
      final antes = await alimentacao.alvo(TipoDia.treino);
      final (repo, _) = agente('atualizar_metas', {'alvo': 'dieta', 'kcal': 2500});
      await repo.enviar('muda minha meta de calorias para 2500');
      for (final t in TipoDia.values) {
        expect((await alimentacao.alvo(t))!.kcal, 2500);
      }
      expect((await alimentacao.alvo(TipoDia.treino))!.proteina, antes?.proteina ?? 0, reason: 'proteína não mudou');
      final aviso = (await repo.carregarConversa()).firstWhere((m) => m.itemTipo == 'alvo_dieta');
      await repo.desfazer(aviso);
      expect((await alimentacao.alvo(TipoDia.treino))?.kcal, antes?.kcal);
    });

    test('meta do app pelo nome, com desfazer', () async {
      final metas = MetasRepo(db);
      final shape = (await metas.carregar()).firstWhere((p) => p.meta.nome.contains('Shape')).meta;
      final (repo, _) = agente('atualizar_metas', {'alvo': 'meta', 'nome_meta': 'shape 80', 'valor_atual': 77});
      await repo.enviar('atualiza minha meta de shape para 77');
      expect((await metas.carregar()).firstWhere((p) => p.meta.id == shape.id).meta.valorAtual, 77);
      final aviso = (await repo.carregarConversa()).firstWhere((m) => m.itemTipo == 'meta');
      await repo.desfazer(aviso);
      expect((await metas.carregar()).firstWhere((p) => p.meta.id == shape.id).meta.valorAtual, shape.valorAtual);
    });

    test('meta que não existe volta como erro com a lista', () async {
      final (repo, _) = agente('atualizar_metas', {'alvo': 'meta', 'nome_meta': 'viagem ao japão', 'valor_atual': 1});
      await repo.enviar('atualiza a meta da viagem');
      expect((await repo.carregarConversa()).last.texto, allOf(startsWith('error-text|'), contains('As metas são')));
    });

    test('consultar medidas traz os ids para excluir', () async {
      final texto = await consultar(db, 'medidas', dias: 60);
      final peso = (await SaudeRepo(db).carregar()).medidas['Peso']!.first;
      expect(texto, contains('(id ${peso.id})'));
      expect(await consultar(db, 'shape'), contains('Nenhuma foto'));
    });
  });

  group('janela de memória', () {
    MensagemAssistente m(PapelMensagem p, String texto, {int n = 0}) => MensagemAssistente(
          id: '$n',
          criadoEm: DateTime(2026),
          atualizadoEm: DateTime(2026),
          papel: p,
          texto: texto,
          naFila: false,
          desfeita: false,
        );

    test('junta mensagens seguidas, pula avisos e começa na pessoa', () {
      final r = mensagensParaIa([
        m(PapelMensagem.aurora, 'Bom dia!'),
        m(PapelMensagem.eu, 'gastei 10 no café'),
        m(PapelMensagem.aurora, 'Anotei R\$ 10,00.'),
        m(PapelMensagem.sistema, 'Desfeito.'),
        m(PapelMensagem.aurora, 'Mais algo?'),
        m(PapelMensagem.eu, 'não'),
      ]);
      expect(r.map((x) => x['role']), ['user', 'assistant', 'user']);
      expect(r[1]['content'], 'Anotei R\$ 10,00.\nMais algo?');
    });

    test('guarda só o fim da conversa dentro do limite', () {
      final conversa = [
        for (var i = 0; i < 100; i++) m(i.isEven ? PapelMensagem.eu : PapelMensagem.aurora, 'mensagem $i ${'x' * 100}', n: i),
      ];
      final r = mensagensParaIa(conversa, maxCaracteres: 1200);
      expect(r.length, lessThan(12));
      expect(r.first['role'], 'user');
      expect(r.last['content'], startsWith('mensagem 99'));
      expect(mensagensParaIa(conversa, maxMensagens: 6), hasLength(6));
      expect(mensagensParaIa(conversa, maxMensagens: 5), hasLength(4), reason: 'corta no limite e começa na pessoa');
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
