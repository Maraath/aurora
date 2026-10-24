import 'package:aurora/core/relogio.dart';
import 'package:aurora/data/automacoes_repo.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/exemplo.dart';
import 'package:aurora/data/habitos_repo.dart';
import 'package:aurora/data/saude_repo.dart';
import 'package:aurora/data/sincronizacao.dart';
import 'package:aurora/data/tarefas_repo.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Servidor em memória com as mesmas regras do Supabase: servidor_em a cada
/// gravação, "edição mais antiga é ignorada" e RLS por conta ([usuario] faz o
/// papel de auth.uid()). [chave] é a chave primária das tabelas: a de hoje
/// ([chaveNoServidor], por conta) ou a antiga, só o id.
class ServidorFalso implements RemotoSync {
  ServidorFalso({this.chave = chaveNoServidor});
  final String chave;
  var usuario = 'u1';
  final tabelas = <String, Map<String, Map<String, dynamic>>>{};
  var _relogio = DateTime.utc(2026, 1, 1);
  int envios = 0;

  String _agora() => (_relogio = _relogio.add(const Duration(microseconds: 1))).toIso8601String();

  String _chaveDe(String id) => chave == 'id' ? id : '$usuario|$id';

  Iterable<Map<String, dynamic>> _visiveis(String tabela) =>
      (tabelas[tabela]?.values ?? const <Map<String, dynamic>>[]).where((l) => l['user_id'] == usuario);

  @override
  Future<void> enviar(String tabela, List<Map<String, dynamic>> linhas) async {
    envios++;
    final t = tabelas.putIfAbsent(tabela, () => {});
    for (final l in linhas) {
      final k = _chaveDe(l['id'] as String);
      final atual = t[k];
      // Upsert que cai na linha de outra conta: o "dono altera" (USING) recusa.
      if (atual != null && atual['user_id'] != usuario) {
        throw StateError('new row violates row-level security policy (USING expression) for table "$tabela"');
      }
      if (atual != null &&
          DateTime.parse(l['atualizado_em'] as String).isBefore(DateTime.parse(atual['atualizado_em'] as String))) {
        continue;
      }
      t[k] = {...l, 'user_id': usuario, 'servidor_em': _agora()};
    }
  }

  @override
  Future<List<Map<String, dynamic>>> baixar(String tabela, Cursor? depois, int limite) async {
    final linhas = _visiveis(tabela).toList()
      ..sort((a, b) {
        final c = (a['servidor_em'] as String).compareTo(b['servidor_em'] as String);
        return c != 0 ? c : (a['id'] as String).compareTo(b['id'] as String);
      });
    return linhas
        .where((l) {
          if (depois == null) return true;
          final c = DateTime.parse(l['servidor_em'] as String).compareTo(DateTime.parse(depois.servidorEm));
          return c > 0 || (c == 0 && (l['id'] as String).compareTo(depois.id) > 0);
        })
        .take(limite)
        .toList();
  }

  @override
  Future<bool> temDados() async => tabelas.keys.any((t) => _visiveis(t).isNotEmpty);
}

void main() {
  late ServidorFalso servidor;
  late BancoAurora pc;
  late BancoAurora celular;

  setUpAll(() async {
    iniciarRelogio();
    await initializeDateFormatting('pt_BR');
  });

  setUp(() async {
    servidor = ServidorFalso();
    pc = BancoAurora(NativeDatabase.memory());
    celular = BancoAurora(NativeDatabase.memory());
  });

  tearDown(() async {
    await pc.close();
    await celular.close();
  });

  Sincronizador sync(BancoAurora db) => Sincronizador(db, servidor, usuarioId: 'u1');

  /// Dados de exemplo "criados há uma hora". As datas locais têm precisão de
  /// segundos; sem isso o teste faria tudo no mesmo segundo, o que no uso
  /// real não acontece (entre baixar e editar passam segundos).
  Future<void> semearAntigo(BancoAurora db) async {
    await semearExemplo(db);
    for (final t in tabelasSincronizadas(db)) {
      await db.customStatement(
          'UPDATE ${t.actualTableName} SET atualizado_em = atualizado_em - 3600, criado_em = criado_em - 3600');
    }
  }

  Future<List<String>> titulos(BancoAurora db) async =>
      (await (db.select(db.tarefas)..where((t) => t.apagadoEm.isNull())).get()).map((t) => t.titulo).toList()
        ..sort();

  test('o que um aparelho cria aparece no outro', () async {
    await semearAntigo(pc);
    final r = await sync(pc).sincronizar();
    expect(r.enviadas, greaterThan(20));

    await sync(celular).sincronizar(); // celular vazio: só baixa
    expect(await titulos(celular), await titulos(pc));
    expect((await celular.select(celular.medidas).get()).length, 5);
    expect((await celular.select(celular.itensTreino).get()).length, 6);
  });

  test('edição e exclusão viajam; a mais recente vence', () async {
    await semearAntigo(pc);
    await sync(pc).sincronizar();
    await sync(celular).sincronizar();

    final tarefa = (await pc.select(pc.tarefas).get()).firstWhere((t) => t.titulo == 'Testes Estágios');
    // Celular renomeia; depois o PC (mais tarde) renomeia de novo, e exclui outra.
    await (celular.update(celular.tarefas)..where((t) => t.id.equals(tarefa.id))).write(TarefasCompanion(
        titulo: const Value('Testes (celular)'), atualizadoEm: Value(DateTime.now().add(const Duration(seconds: 2)))));
    await (pc.update(pc.tarefas)..where((t) => t.id.equals(tarefa.id))).write(TarefasCompanion(
        titulo: const Value('Testes (PC)'), atualizadoEm: Value(DateTime.now().add(const Duration(seconds: 5)))));
    final outra = (await pc.select(pc.tarefas).get()).firstWhere((t) => t.titulo == 'Fórmula Mágica');
    await TarefasRepo(pc).excluir(outra.id);

    await sync(pc).sincronizar();
    await sync(celular).sincronizar(); // envia a versão velha (ignorada) e baixa a do PC
    await sync(pc).sincronizar();

    for (final db in [pc, celular]) {
      final t = await (db.select(db.tarefas)..where((x) => x.id.equals(tarefa.id))).getSingle();
      expect(t.titulo, 'Testes (PC)');
      expect(await titulos(db), isNot(contains('Fórmula Mágica')));
    }
  });

  test('hábito marcado nos dois aparelhos no mesmo dia não duplica', () async {
    await semearAntigo(pc);
    await sync(pc).sincronizar();
    await sync(celular).sincronizar();

    final cardio = (await HabitosRepo(pc).carregar()).habitos.firstWhere((h) => h.nome == 'Cardio');
    await HabitosRepo(pc).alternar(cardio.id, hojeLocal(), true);
    await HabitosRepo(celular).alternar(cardio.id, hojeLocal(), true);
    await sync(pc).sincronizar();
    await sync(celular).sincronizar();
    await sync(pc).sincronizar();

    for (final db in [pc, celular]) {
      final registros = await db.select(db.registrosHabito).get();
      expect(registros, hasLength(1));
      expect((await HabitosRepo(db).carregar()).feito(cardio.id, hojeLocal()), isTrue);
    }
  });

  test('primeira vez com dados dos dois lados pede escolha; "usar a nuvem" troca os dados', () async {
    await semearAntigo(pc);
    await sync(pc).sincronizar();
    await semearAntigo(celular); // celular com seus próprios dados de exemplo

    await expectLater(sync(celular).sincronizar(), throwsA(isA<PrecisaEscolher>()));
    await sync(celular).escolher(EscolhaPrimeiraVez.usarNuvem);
    expect(await titulos(celular), await titulos(pc));
    final idsPc = (await pc.select(pc.tarefas).get()).map((t) => t.id).toSet();
    final idsCel = (await celular.select(celular.tarefas).get()).map((t) => t.id).toSet();
    expect(idsCel, idsPc);
  });

  test('sem mudanças, a segunda sincronização não reenvia nada', () async {
    await semearAntigo(pc);
    await sync(pc).sincronizar();
    final r = await sync(pc).sincronizar();
    expect(r.enviadas, 0);
  });

  test('conversão de linhas: datas e booleanos', () async {
    await semearAntigo(pc);
    final linha = (await pc.customSelect('SELECT * FROM lembretes LIMIT 1').get()).single.data;
    final s = paraServidor(pc.lembretes, linha);
    expect(s['quando'], isA<String>());
    expect(s['ativo'], isTrue);
    final volta = paraLocal(pc.lembretes, s);
    expect(volta['quando'], linha['quando']);
    expect(volta['ativo'], 1);
  });

  group('duas contas no mesmo servidor', () {
    // Caso real (20/10/2026): conta nova no iPhone, "new row violates row-level
    // security policy (USING expression) for table automacoes". As automações
    // prontas têm id fixo (idNatural pelo modelo), igual ao das do dono; medidas
    // do mesmo dia também.
    Future<void> criarDados(BancoAurora db) async {
      await AutomacoesRepo(db).garantirModelos();
      await SaudeRepo(db).salvarMedidas(hojeLocal(), [(tipo: 'peso', valor: 80, unidade: 'kg')]);
    }

    Future<void> sincronizarComo(ServidorFalso s, BancoAurora db, String conta) async {
      s.usuario = conta;
      await Sincronizador(db, s, usuarioId: conta).sincronizar();
    }

    test('com a chave só no id, a conta nova cai na RLS (a causa)', () async {
      final antigo = ServidorFalso(chave: 'id');
      await criarDados(pc);
      await criarDados(celular);
      await sincronizarComo(antigo, pc, 'dono');
      await expectLater(sincronizarComo(antigo, celular, 'nova'), throwsA(isA<StateError>()));
    });

    test('com a chave por conta, as duas sincronizam e cada uma só vê o que é seu', () async {
      expect(chaveNoServidor, 'user_id,id');
      await criarDados(pc);
      await criarDados(celular);
      await sincronizarComo(servidor, pc, 'dono');
      await sincronizarComo(servidor, celular, 'nova');

      // A nova liga o briefing; o do dono continua desligado.
      final briefing = (await AutomacoesRepo(celular).listar()).firstWhere((a) => a.modelo == 'briefing');
      await AutomacoesRepo(celular).alternar(briefing, true);
      await sincronizarComo(servidor, celular, 'nova');
      await sincronizarComo(servidor, pc, 'dono');

      final doDono = (await AutomacoesRepo(pc).listar()).firstWhere((a) => a.modelo == 'briefing');
      expect(doDono.ativa, isFalse);
      expect(servidor.tabelas['automacoes']!.length, 2 * (ModeloAutomacao.values.length - 1));
      expect(servidor.tabelas['medidas']!.length, 2);
    });
  });
}
