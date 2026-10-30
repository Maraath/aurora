import 'package:aurora/core/comandos.dart';
import 'package:aurora/core/notificacoes.dart';
import 'package:aurora/core/recorrencia.dart';
import 'package:aurora/core/relogio.dart';
import 'package:aurora/data/assistente_repo.dart';
import 'package:aurora/data/banco.dart';
import 'package:aurora/data/compromissos_repo.dart';
import 'package:aurora/data/conversao_tarefas.dart';
import 'package:aurora/data/ia/ferramentas_ia.dart';
import 'package:aurora/data/rotina_repo.dart';
import 'package:aurora/ui/visao/foco.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late BancoAurora db;

  setUpAll(() async {
    iniciarRelogio();
    await initializeDateFormatting('pt_BR');
  });
  setUp(() => db = BancoAurora(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('regra anual', () {
    test('lê, escreve e repete no mesmo dia e mês', () {
      expect(Regra.ler('FREQ=YEARLY'), const Regra.anual());
      expect(const Regra.anual().rrule, 'FREQ=YEARLY');
      expect(const Regra.anual().descricao, 'Todo ano');
      final inicio = DateTime(2026, 10, 29);
      expect(const Regra.anual().ocorreEm(DateTime(2027, 10, 29), inicio), isTrue);
      expect(const Regra.anual().ocorreEm(DateTime(2027, 10, 28), inicio), isFalse);
      expect(const Regra.anual().ocorreEm(DateTime(2025, 10, 29), inicio), isFalse);
    });

    test('29 de fevereiro cai no dia 28 nos anos comuns', () {
      final inicio = DateTime(2028, 2, 29);
      expect(const Regra.anual().ocorreEm(DateTime(2029, 2, 28), inicio), isTrue);
      expect(const Regra.anual().ocorreEm(DateTime(2032, 2, 29), inicio), isTrue);
    });
  });

  Compromisso compromisso({
    required DateTime inicio,
    DateTime? fim,
    bool diaInteiro = false,
    String? regra,
    int? aviso = 30,
  }) =>
      Compromisso(
        id: 'c1',
        criadoEm: DateTime(2026),
        atualizadoEm: DateTime(2026),
        titulo: 'Dentista',
        inicio: inicio,
        fim: fim,
        diaInteiro: diaInteiro,
        regraRepeticao: regra,
        avisoAntesMin: aviso,
        despertar: false,
      );

  group('compromisso', () {
    test('ocorrências repetem pela regra e mantêm a duração', () {
      final c = compromisso(
        inicio: instanteLocal(DateTime(2026, 10, 26), 9),
        fim: instanteLocal(DateTime(2026, 10, 26), 10, 30),
        regra: const Regra.semanal(1).rrule, // toda segunda
      );
      final l = ocorrenciasCompromisso(c, DateTime(2026, 10, 26), DateTime(2026, 11, 9)).toList();
      expect([for (final o in l) o.dia], [DateTime(2026, 10, 26), DateTime(2026, 11, 2), DateTime(2026, 11, 9)]);
      expect(l.last.horario, '09:00–10:30');
      final q = QuadroCompromissos([c]);
      expect(q.doDia(DateTime(2026, 11, 2)), hasLength(1));
      expect(q.doDia(DateTime(2026, 11, 3)), isEmpty);
    });

    test('agora, terminou e dia inteiro', () {
      final o = ocorrenciasCompromisso(
        compromisso(inicio: instanteLocal(DateTime(2026, 10, 26), 12), fim: instanteLocal(DateTime(2026, 10, 26), 14)),
        DateTime(2026, 10, 26),
        DateTime(2026, 10, 26),
      ).single;
      expect(o.emAndamento(instanteLocal(DateTime(2026, 10, 26), 13)), isTrue);
      expect(o.terminou(instanteLocal(DateTime(2026, 10, 26), 13)), isFalse);
      expect(o.terminou(instanteLocal(DateTime(2026, 10, 26), 14)), isTrue);
      final inteiro = ocorrenciasCompromisso(
        compromisso(inicio: instanteLocal(DateTime(2026, 10, 29)), diaInteiro: true),
        DateTime(2026, 10, 29),
        DateTime(2026, 10, 29),
      ).single;
      expect(inteiro.horario, 'Dia todo');
      expect(inteiro.emAndamento(instanteLocal(DateTime(2026, 10, 29), 20)), isTrue);
    });

    test('aviso sai X minutos antes; dia inteiro conta das 09:00; sem aviso, nada', () {
      final agora = instanteLocal(DateTime(2026, 10, 26), 8);
      final avisos = avisosDeCompromissos([
        compromisso(inicio: instanteLocal(DateTime(2026, 10, 26), 9), aviso: 30),
      ], agora);
      expect(avisos.single.quando, instanteLocal(DateTime(2026, 10, 26), 8, 30));
      expect(avisos.single.corpo, startsWith('Compromisso em 30 min'));

      final vespera = avisosDeCompromissos([
        compromisso(inicio: instanteLocal(DateTime(2026, 10, 29)), diaInteiro: true, aviso: 1440),
      ], agora);
      expect(vespera.single.quando, instanteLocal(DateTime(2026, 10, 28), 9));

      expect(avisosDeCompromissos([compromisso(inicio: instanteLocal(DateTime(2026, 10, 26), 9), aviso: null)], agora),
          isEmpty);
      // O que já passou não é agendado.
      expect(avisosDeCompromissos([compromisso(inicio: instanteLocal(DateTime(2026, 10, 26), 8, 10))], agora), isEmpty);
    });
  });

  group('conversão das tarefas repetidas', () {
    test('semanal vira hábito com o histórico e o aviso; mensal vira lembrete; roda uma vez só', () async {
      final segunda = DateTime(2026, 10, 19);
      final semanal = await db.into(db.tarefas).insertReturning(TarefasCompanion.insert(
            titulo: 'Levar o lixo',
            prazo: Value(instanteLocal(segunda, 20)),
            prazoTemHora: const Value(true),
            regraRepeticao: Value(const Regra.semanal(1 | 4).rrule), // seg e qua
          ));
      await db.into(db.conclusoesTarefa).insert(
          ConclusoesTarefaCompanion.insert(tarefaId: semanal.id, dia: chaveData(segunda)));
      await db.into(db.lembretes).insert(LembretesCompanion.insert(
            texto: 'Levar o lixo',
            quando: instanteLocal(segunda, 20),
            regraRepeticao: Value(const Regra.semanal(1 | 4).rrule),
            itemTipo: const Value('tarefa'),
            itemId: Value(semanal.id),
          ));
      final mensal = await db.into(db.tarefas).insertReturning(TarefasCompanion.insert(
            titulo: 'Pagar o condomínio',
            prazo: Value(instanteLocal(DateTime(2026, 10, 10))),
            regraRepeticao: Value(Regra.mensal(10).rrule),
          ));
      await db.into(db.tarefas).insert(TarefasCompanion.insert(titulo: 'Comum'));

      expect(await converterTarefasRepetidas(db), 2);
      expect(await converterTarefasRepetidas(db), 0);

      final habito = await (db.select(db.habitos)..where((h) => h.apagadoEm.isNull())).getSingle();
      expect(habito.id, idNatural('habito_de_tarefa', [semanal.id]));
      expect(habito.nome, 'Levar o lixo');
      expect(habito.diasSemana, 1 | 4);
      expect(habito.horario, '20:00');
      final registros = await db.select(db.registrosHabito).get();
      expect(registros.single.dia, chaveData(segunda));
      final lembretes = await (db.select(db.lembretes)..where((l) => l.apagadoEm.isNull())).get();
      final ligado = lembretes.firstWhere((l) => l.itemTipo == 'habito');
      expect(ligado.itemId, habito.id);
      final solto = lembretes.firstWhere((l) => l.itemTipo == null);
      expect(solto.texto, 'Pagar o condomínio');
      expect(solto.regraRepeticao, Regra.mensal(10).rrule);

      final tarefas = await (db.select(db.tarefas)..where((t) => t.apagadoEm.isNull())).get();
      expect([for (final t in tarefas) t.titulo], ['Comum']);
      expect(mensal.id, isNot(semanal.id));
    });
  });

  group('comando rápido', () {
    final hoje = DateTime(2026, 10, 16);
    final agora = DateTime(2026, 10, 16, 16);
    Comando? ler(String t) => interpretar(t, hoje: hoje, agora: agora);

    test('compromisso: dentista amanhã às 9', () {
      final c = ler('compromisso: dentista amanhã às 9') as CmdCompromisso;
      expect(c.titulo, 'Dentista');
      expect(c.dia, DateTime(2026, 10, 17));
      expect(c.hora, 9);
      expect(c.diaInteiro, isFalse);
    });

    test('agenda sem hora vira dia inteiro', () {
      final c = ler('agenda aniversário do Pedro dia 29') as CmdCompromisso;
      expect(c.titulo, 'Aniversário do Pedro');
      expect(c.diaInteiro, isTrue);
    });

    test('"marca …" sem compromisso continua sendo hábito', () {
      expect(ler('marca beber água como feito'), isA<CmdHabito>());
    });
  });

  group('assistente', () {
    test('cria, consulta, edita e desfaz um compromisso', () async {
      final ia = FerramentasIa(db, AssistenteRepo(db));
      final amanha = somarDias(hojeLocal(), 1);
      final criar = await ia.executar('criar_compromisso', {
        'titulo': 'reunião com o cliente',
        'data': chaveData(amanha),
        'hora': '14:00',
        'fim': '15:30',
        'local': 'Online',
        'repeticao': 'semana',
      });
      expect(criar.erro, isFalse, reason: criar.paraIa);
      final c = await db.select(db.compromissos).getSingle();
      expect(c.titulo, 'Reunião com o cliente');
      expect(c.avisoAntesMin, 30);
      expect(c.fim!.difference(c.inicio), const Duration(minutes: 90));
      expect(Regra.ler(c.regraRepeticao), Regra.semanal(bitDoDiaDaSemana(amanha)));

      final lista = await consultar(db, 'compromissos');
      expect(lista, contains('(id ${c.id})'));

      final editar = await ia.executar('editar_compromisso', {'id': c.id, 'hora': '16:00', 'aviso_min': -1});
      expect(editar.erro, isFalse, reason: editar.paraIa);
      final editado = await db.select(db.compromissos).getSingle();
      expect(emLocal(editado.inicio).hour, 16);
      expect(editado.fim!.difference(editado.inicio), const Duration(minutes: 90));
      expect(editado.avisoAntesMin, isNull);

      expect(await ia.perguntaDeExclusao('excluir_item', {'tipo': 'compromisso', 'id': c.id}), contains('todas as repetições'));
      final excluir = await ia.executar('excluir_item', {'tipo': 'compromisso', 'id': c.id});
      expect(excluir.erro, isFalse);
      expect((await RotinaRepo(db).carregar()).compromissos.todos, isEmpty);
      // "Desfazer" traz de volta como era antes da exclusão.
      await restaurar(db, excluir.aviso!.itemId!);
      expect((await CompromissosRepo(db).carregar()).todos.single.id, c.id);
    });
  });

  group('foco imersivo', () {
    test('personaliza os minutos de pomodoro, imersão e pausa e vincula o Spotify', () async {
      final foco = ControleFoco.instancia;
      await foco.carregarPreferencias(db);

      await foco.salvarTodosTempos(pomodoro: 35, imersao: 75, pausa: 10, db: db);
      expect(foco.minutosDe(ModoFoco.pomodoro), 35);
      expect(foco.minutosDe(ModoFoco.imersao), 75);
      expect(foco.minutosDe(ModoFoco.pausa), 10);

      foco.selecionarModo(ModoFoco.imersao);
      expect(foco.mostrador, '75:00');

      await foco.definirMinutosModo(ModoFoco.imersao, 80, db: db);
      expect(foco.minutosDe(ModoFoco.imersao), 80);
      expect(foco.mostrador, '80:00');

      // Links de playlists do YouTube nos segmentos
      expect(foco.urlYoutubeDe(SegmentoAudioFoco.lofi), contains('youtube.com'));
      await foco.definirUrlYoutube(
        SegmentoAudioFoco.lofi,
        'https://www.youtube.com/playlist?list=PL123',
        db: db,
      );
      expect(foco.urlYoutubeDe(SegmentoAudioFoco.lofi), 'https://www.youtube.com/playlist?list=PL123');

      // Vínculo com o Spotify
      await foco.vincularSpotify(
        nome: 'Minha Playlist Foco',
        url: 'https://open.spotify.com/playlist/abc',
        db: db,
      );
      expect(foco.spotifyVinculado, isTrue);
      expect(foco.spotifyNome, 'Minha Playlist Foco');
      expect(foco.spotifyUrl, 'https://open.spotify.com/playlist/abc');

      await foco.desvincularSpotify(db: db);
      expect(foco.spotifyVinculado, isFalse);

      // Volta aos valores padrão para não interferir em outros testes
      await foco.salvarTodosTempos(pomodoro: 25, imersao: 50, pausa: 5, db: db);
      foco.selecionarModo(ModoFoco.pomodoro);
    });
  });
}
