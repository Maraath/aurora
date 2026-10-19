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
import 'package:drift/drift.dart' show Value;
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
      final comIa = AssistenteRepo(db, ia: () => (mensagens, contexto, {reserva = false}) async* {
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
      final comIa = AssistenteRepo(db, ia: () => (mensagens, contexto, {reserva = false}) async* {
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
      final comIa = AssistenteRepo(db, ia: () => (mensagens, contexto, {reserva = false}) async* {
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
      final comIa = AssistenteRepo(db, ia: () => (mensagens, contexto, {reserva = false}) async* {
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

    group('limite por minuto', () {
      const cheio = ErroIa('A IA chegou ao limite de pedidos por minuto. Tente de novo em instantes.');
      final esperas = AssistenteRepo.esperasLimite;
      setUp(() => AssistenteRepo.esperasLimite = const [Duration.zero, Duration.zero, Duration.zero]);
      tearDown(() => AssistenteRepo.esperasLimite = esperas);

      test('depois de uma ferramenta: tenta de novo no modelo reserva e termina', () async {
        final reservas = <bool>[];
        final comIa = AssistenteRepo(db, ia: () => (mensagens, contexto, {reserva = false}) async* {
              reservas.add(reserva);
              if (mensagens.last['role'] == 'user') {
                yield const FerramentaIa(id: 'c', nome: 'consultar', entrada: {'area': 'financas'});
              } else if (!reserva) {
                throw cheio;
              } else {
                yield const TextoIa('Tudo certo.');
              }
            });
        await comIa.enviar('exclua os lançamentos de internet e netflix');
        expect(reservas, [false, false, true], reason: 'a volta que bateu no limite vai para a reserva');
        final conversa = await comIa.carregarConversa();
        expect(conversa.last.texto, 'Tudo certo.');
        expect(conversa.where((m) => m.papel == PapelMensagem.sistema), isEmpty);
      });

      test('limite que não passa: avisa que não terminou e o feito fica', () async {
        var chamadas = 0;
        final comIa = AssistenteRepo(db, ia: () => (mensagens, contexto, {reserva = false}) async* {
              chamadas++;
              if (mensagens.last['role'] == 'user') {
                yield const FerramentaIa(id: 'c', nome: 'consultar', entrada: {'area': 'tarefas'});
              } else {
                throw cheio;
              }
            });
        await comIa.enviar('o que tenho pra hoje?');
        expect(chamadas, 1 + 1 + AssistenteRepo.esperasLimite.length);
        expect((await comIa.carregarConversa()).last.texto, startsWith('A IA não conseguiu terminar a resposta'));
      });

      test('no primeiro pedido também tenta de novo, e o limite do dia não', () async {
        var chamadas = 0;
        final comIa = AssistenteRepo(db, ia: () => (mensagens, contexto, {reserva = false}) async* {
              chamadas++;
              if (chamadas == 1) throw cheio;
              yield const TextoIa('Oi!');
            });
        await comIa.enviar('oi');
        expect(chamadas, 2);
        expect((await comIa.carregarConversa()).last.texto, 'Oi!');

        var doDia = 0;
        final semCota = AssistenteRepo(db, ia: () => (mensagens, contexto, {reserva = false}) async* {
              doDia++;
              throw const ErroIa('Você chegou ao limite de 60 pedidos à IA hoje.');
            });
        await semCota.enviar('e agora?');
        expect(doDia, 1);
      });
    });

    test('limite do dia aparece na conversa', () async {
      final comIa = AssistenteRepo(db, ia: () => (mensagens, contexto, {reserva = false}) async* {
            throw const ErroIa('Você chegou ao limite de 60 pedidos à IA hoje.');
          });
      await comIa.enviar('o que acha da minha semana?');
      expect((await comIa.carregarConversa()).last.texto, contains('limite de 60'));
      expect(await comIa.tamanhoDaFila(), 1);
    });

    test('com IA, o resumo do dia vai para ela', () async {
      var chamou = false;
      final comIa = AssistenteRepo(db, ia: () => (mensagens, contexto, {reserva = false}) async* {
            chamou = true;
            yield const TextoIa('Seu dia está tranquilo.');
          });
      await comIa.enviar('Resumo do meu dia');
      expect(chamou, isTrue);
      expect((await comIa.carregarConversa()).last.texto, 'Seu dia está tranquilo.');
    });
  });

  group('agente: alterar e excluir', () {
    /// Perguntas de confirmação feitas pelo agente de teste.
    final perguntas = <String>[];
    setUp(perguntas.clear);

    /// IA de teste: na primeira volta pede [ferramenta]; na segunda devolve o
    /// resultado como texto (para o teste ler) e guarda a etapa mostrada.
    (AssistenteRepo, List<String?>) agente(String ferramenta, Map<String, Object?> entrada, {bool confirmar = true}) {
      final etapas = <String?>[];
      final repo = AssistenteRepo(db,
          confirmar: (p) async {
            perguntas.add(p);
            return confirmar;
          },
          ia: () => (mensagens, contexto, {reserva = false}) async* {
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
          ia: () => (mensagens, contexto, {reserva = false}) async* {
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

    String dataIso(DateTime d) => '${d.year}-${'${d.month}'.padLeft(2, '0')}-${'${d.day}'.padLeft(2, '0')}';
    Future<String> ultimoTexto(AssistenteRepo r) async => (await r.carregarConversa()).last.texto;
    Future<MensagemAssistente> avisoDesfazer(AssistenteRepo r) async =>
        (await r.carregarConversa()).lastWhere((m) => m.itemTipo == 'restaurar');

    /// Gasto de R$ 200 em Educação, registrado como pela conversa.
    Future<Transacao> gastoEducacao() async {
      await repo.enviar('gastei 200 na educação');
      return (db.select(db.transacoes)..where((t) => t.valorCentavos.equals(20000))).getSingle();
    }

    test('editar lançamento: só muda o que veio, com desfazer', () async {
      final t = await gastoEducacao();
      final saldo = (await FinancasRepo(db).carregar()).saldoCentavos;
      final (r, etapas) = agente('editar_lancamento', {'id': t.id, 'valor': 150, 'categoria': 'cursos'});
      await r.enviar('na verdade o gasto de educação foi 150, categoria cursos');
      var depois = await (db.select(db.transacoes)..where((x) => x.id.equals(t.id))).getSingle();
      expect(depois.valorCentavos, 15000);
      expect(depois.categoria, 'Cursos');
      expect(depois.descricao, t.descricao, reason: 'descrição não veio');
      expect(etapas.single, 'Atualizando seus dados...');
      expect(perguntas, isEmpty, reason: 'editar não pede confirmação');
      expect((await FinancasRepo(db).carregar()).saldoCentavos, saldo + 5000);

      await r.desfazer(await avisoDesfazer(r));
      depois = await (db.select(db.transacoes)..where((x) => x.id.equals(t.id))).getSingle();
      expect((depois.valorCentavos, depois.categoria), (20000, t.categoria));
      expect((await FinancasRepo(db).carregar()).saldoCentavos, saldo);
    });

    test('excluir lançamento: confirma, apaga e desfazer traz de volta', () async {
      final t = await gastoEducacao();
      final saldo = (await FinancasRepo(db).carregar()).saldoCentavos;
      final (r, etapas) = agente('excluir_item', {'tipo': 'lancamento', 'id': t.id});
      await r.enviar('exclui o gasto de educação');
      expect(perguntas.single, allOf(contains('Excluir o gasto'), contains('R\$ 200,00')));
      expect(etapas.single, 'Excluindo...');
      expect((await FinancasRepo(db).carregar()).saldoCentavos, saldo + 20000);
      expect(await ultimoTexto(r), startsWith('text|Excluí o gasto'));

      await r.desfazer(await avisoDesfazer(r));
      expect((await FinancasRepo(db).carregar()).saldoCentavos, saldo);
    });

    test('excluir lançamento cancelado não apaga', () async {
      final t = await gastoEducacao();
      final (r, _) = agente('excluir_item', {'tipo': 'lancamento', 'id': t.id}, confirmar: false);
      await r.enviar('exclui o gasto de educação');
      final x = await (db.select(db.transacoes)..where((x) => x.id.equals(t.id))).getSingle();
      expect(x.apagadoEm, isNull);
      expect(await ultimoTexto(r), contains('cancelou'));
    });

    test('editar tarefa: título, prazo com hora e concluir; desfazer volta tudo', () async {
      final t = await (db.select(db.tarefas)..where((x) => x.titulo.equals('Testes Estágios'))).getSingle();
      final amanha = hojeSP().add(const Duration(days: 1));
      final (r, _) = agente('editar_tarefa',
          {'id': t.id, 'titulo': 'testes do estágio', 'data': dataIso(amanha), 'hora': '15:00', 'concluida': true});
      await r.enviar('muda a tarefa');
      var x = await (db.select(db.tarefas)..where((x) => x.id.equals(t.id))).getSingle();
      expect(x.titulo, 'Testes do estágio');
      expect(dataSP(x.prazo!), amanha);
      expect(emSP(x.prazo!).hour, 15);
      expect(x.prazoTemHora, isTrue);
      expect(x.feitaEm, isNotNull);
      expect(await ultimoTexto(r), allOf(contains('amanhã às 15:00'), contains('marcada como feita')));

      await r.desfazer(await avisoDesfazer(r));
      x = await (db.select(db.tarefas)..where((x) => x.id.equals(t.id))).getSingle();
      expect((x.titulo, x.prazo, x.prazoTemHora, x.feitaEm), (t.titulo, t.prazo, t.prazoTemHora, null));
    });

    test('tarefa: excluir com confirmação e desfazer', () async {
      final t = await (db.select(db.tarefas)..where((x) => x.titulo.equals('Testes Estágios'))).getSingle();
      final (r, _) = agente('excluir_item', {'tipo': 'tarefa', 'id': t.id});
      await r.enviar('apaga a tarefa testes estágios');
      expect(perguntas.single, 'Excluir a tarefa “Testes Estágios”?');
      Future<DateTime?> apagada() async =>
          (await (db.select(db.tarefas)..where((x) => x.id.equals(t.id))).getSingle()).apagadoEm;
      expect(await apagada(), isNotNull);
      await r.desfazer(await avisoDesfazer(r));
      expect(await apagada(), isNull);
    });

    test('editar lembrete: hora e repetição; desfazer volta', () async {
      final l = await (db.select(db.lembretes)..where((x) => x.texto.equals('Entregar documentos do estágio')))
          .getSingle();
      final (r, _) = agente('editar_lembrete', {'id': l.id, 'hora': '16:30', 'repeticao': 'toda terça'});
      await r.enviar('muda o lembrete dos documentos');
      var x = await (db.select(db.lembretes)..where((x) => x.id.equals(l.id))).getSingle();
      expect(emSP(x.quando).hour, 16);
      expect(emSP(x.quando).minute, 30);
      expect(x.regraRepeticao, contains('BYDAY=TU'));
      expect(x.texto, l.texto);

      await r.desfazer(await avisoDesfazer(r));
      x = await (db.select(db.lembretes)..where((x) => x.id.equals(l.id))).getSingle();
      expect((x.quando, x.regraRepeticao), (l.quando, null));
    });

    test('lembrete: excluir com confirmação; repetição que não entende volta erro', () async {
      final l = await (db.select(db.lembretes)..where((x) => x.texto.equals('Entregar documentos do estágio')))
          .getSingle();
      var (r, _) = agente('editar_lembrete', {'id': l.id, 'repeticao': 'quando der vontade'});
      await r.enviar('muda o lembrete');
      expect(await ultimoTexto(r), allOf(startsWith('error-text|'), contains('Não entendi a repetição')));

      (r, _) = agente('excluir_item', {'tipo': 'lembrete', 'id': l.id});
      await r.enviar('apaga o lembrete dos documentos');
      expect(perguntas.single, startsWith('Excluir o lembrete “Entregar documentos do estágio”'));
      final x = await (db.select(db.lembretes)..where((x) => x.id.equals(l.id))).getSingle();
      expect(x.apagadoEm, isNotNull);
    });

    test('editar treino troca exercícios e dias; desfazer traz a lista antiga', () async {
      final saude = SaudeRepo(db);
      final antes = (await saude.carregar()).treinos.firstWhere((t) => t.treino.nome == 'Treino A');
      final nomesAntes = antes.exercicios.map((x) => x.exercicio.nome).toList();
      final (r, _) = agente('editar_treino', {
        'id': antes.treino.id,
        'dias': ['ter', 'sex'],
        'exercicios': [
          {'nome': 'supino inclinado', 'series': 4, 'repeticoes': 8, 'carga': 30},
          {'nome': 'tríceps corda', 'series': 3, 'repeticoes': 12},
        ],
      });
      await r.enviar('troca o treino A');
      var t = (await saude.carregar()).treinos.firstWhere((t) => t.treino.id == antes.treino.id);
      expect(t.exercicios.map((x) => x.exercicio.nome), ['Supino inclinado', 'Tríceps corda']);
      expect(t.exercicios.first.item.series, 4);
      expect(t.treino.diasSemana, 2 | 16);
      expect(t.treino.foco, antes.treino.foco, reason: 'foco não veio');

      await r.desfazer(await avisoDesfazer(r));
      t = (await saude.carregar()).treinos.firstWhere((t) => t.treino.id == antes.treino.id);
      expect(t.exercicios.map((x) => x.exercicio.nome), nomesAntes);
      expect(t.treino.diasSemana, antes.treino.diasSemana);
    });

    test('treino: excluir com confirmação e desfazer', () async {
      final saude = SaudeRepo(db);
      final a = (await saude.carregar()).treinos.firstWhere((t) => t.treino.nome == 'Treino A').treino;
      final (r, _) = agente('excluir_item', {'tipo': 'treino', 'id': a.id});
      await r.enviar('apaga o treino A');
      expect(perguntas.single, contains('Excluir o Treino A da ficha'));
      expect((await saude.carregar()).treinos.any((t) => t.treino.id == a.id), isFalse);
      await r.desfazer(await avisoDesfazer(r));
      expect((await saude.carregar()).treinos.any((t) => t.treino.id == a.id), isTrue);
    });

    test('id que não existe: editar volta erro e excluir nem pergunta', () async {
      var (r, _) = agente('editar_tarefa', {'id': 'nao-existe', 'titulo': 'x'});
      await r.enviar('muda a tarefa');
      expect(await ultimoTexto(r), allOf(startsWith('error-text|'), contains('Não achei')));

      (r, _) = agente('excluir_item', {'tipo': 'lancamento', 'id': 'nao-existe'});
      await r.enviar('apaga o gasto');
      expect(perguntas, isEmpty);
      expect(await ultimoTexto(r), startsWith('error-text|'));
    });

    group('conta fixa já paga', () {
      /// "Netflix" de R$ 50 todo mês, vencendo hoje e já paga (como no app).
      Future<Transacao> netflix() async {
        final financas = FinancasRepo(db);
        final hoje = hojeSP();
        final venc = instanteSP(hoje, 9);
        final id = await financas.salvar(
          TransacoesCompanion.insert(
            descricao: 'Netflix',
            valorCentavos: 5000,
            tipo: TipoTransacao.saida,
            data: venc,
            vencimento: Value(venc),
            categoria: const Value('Lazer'),
            regraRepeticao: Value('FREQ=MONTHLY;BYMONTHDAY=${hoje.day}'),
            contaId: Value((await financas.carregar()).contaPrincipalId),
          ),
          pagarPrimeira: true,
        );
        return (db.select(db.transacoes)..where((t) => t.id.equals(id))).getSingle();
      }

      Future<int> saldo() async => (await FinancasRepo(db).carregar()).saldoCentavos;
      Future<int> pagos(String id) async => (await FinancasRepo(db).pagamentosDe(id)).length;

      test('excluir só encerra, diz isso e não finge excluir de novo', () async {
        final t = await netflix();
        final antes = await saldo();
        var (r, _) = agente('excluir_item', {'tipo': 'lancamento', 'id': t.id});
        await r.enviar('exclui a netflix');
        expect(perguntas.single, allOf(startsWith('Encerrar o gasto “Netflix”'), contains('continua no extrato')));
        expect(await ultimoTexto(r), allOf(contains('Encerrei'), contains('continua no extrato')));
        expect((await saldo(), await pagos(t.id)), (antes, 1), reason: 'o pagamento fica');

        perguntas.clear();
        (r, _) = agente('excluir_item', {'tipo': 'lancamento', 'id': t.id});
        await r.enviar('exclui a netflix de novo');
        expect(perguntas, isEmpty, reason: 'não há o que excluir: nem pergunta');
        expect(await ultimoTexto(r), allOf(startsWith('error-text|'), contains('já está encerrada'), contains('apagar_pagos')));
      });

      test('apagar_pagos apaga a conta e os pagamentos; desfazer traz tudo', () async {
        final t = await netflix();
        final antes = await saldo();
        final (r, _) = agente('excluir_item', {'tipo': 'lancamento', 'id': t.id, 'apagar_pagos': true});
        await r.enviar('apaga netflix e os pagamentos, era teste');
        expect(perguntas.single, allOf(startsWith('Apagar de vez o gasto “Netflix”'), contains('R\$ 50,00')));
        expect(await saldo(), antes + 5000);
        expect(await pagos(t.id), 0);
        final x = await (db.select(db.transacoes)..where((x) => x.id.equals(t.id))).getSingle();
        expect(x.apagadoEm, isNotNull);
        expect(await ultimoTexto(r), contains('Apaguei de vez'));

        await r.desfazer(await avisoDesfazer(r));
        expect((await saldo(), await pagos(t.id)), (antes, 1));
      });

      test('marcar_pagamento desfaz o pagamento do mês e a conta continua', () async {
        final t = await netflix();
        final antes = await saldo();
        final (r, _) = agente('marcar_pagamento', {'id': t.id, 'pago': false});
        await r.enviar('desfaz o pagamento da netflix');
        expect(perguntas, isEmpty);
        expect(await saldo(), antes + 5000);
        expect(await pagos(t.id), 0);
        expect(await ultimoTexto(r), contains('Desfiz o pagamento de “Netflix”'));
        final x = await (db.select(db.transacoes)..where((x) => x.id.equals(t.id))).getSingle();
        expect((x.apagadoEm, x.regraRepeticao), (null, t.regraRepeticao));

        final aviso = (await r.carregarConversa()).lastWhere((m) => m.itemTipo == 'pagamento');
        await r.desfazer(aviso);
        expect((await saldo(), await pagos(t.id)), (antes, 1));
      });

      test('consultar financas mostra a fixa com o id e o que foi pago', () async {
        final t = await netflix();
        final texto = await consultar(db, 'financas');
        expect(texto, allOf(contains('Contas fixas e parceladas'), contains('Netflix'), contains('pagas: R\$ 50,00'),
            contains('(id ${t.id})')));
      });
    });

    test('buscar e consultar devolvem os ids', () async {
      final t = await gastoEducacao();
      final tarefa = await (db.select(db.tarefas)..where((x) => x.titulo.equals('Testes Estágios'))).getSingle();
      final lembrete = await (db.select(db.lembretes)..where((x) => x.texto.equals('Academia'))).getSingle();
      final treino = await (db.select(db.treinos)..where((x) => x.nome.equals('Treino B'))).getSingle();

      final (r, _) = agente('buscar', {'termo': 'educação'});
      await r.enviar('acha o gasto de educação');
      expect(await ultimoTexto(r), contains('(id ${t.id})'));

      expect(await consultar(db, 'financas'), contains('(id ${t.id})'));
      expect(await consultar(db, 'tarefas'), contains('(id ${tarefa.id})'));
      expect(await consultar(db, 'lembretes'), contains('(id ${lembrete.id})'));
      expect(await consultar(db, 'treino'), contains('(id ${treino.id})'));
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
