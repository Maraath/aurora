import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show MaterialPageRoute;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../data/automacoes_repo.dart';
import '../data/banco.dart';
import '../data/compromissos_repo.dart';
import '../data/lembretes_repo.dart';
import '../ui/janela/moldura_janela.dart';
import 'avisos_push.dart';
import 'despertador.dart';
import 'nuvem.dart';
import 'recorrencia.dart';
import 'relogio.dart';

/// Um aviso a agendar no aparelho.
class AvisoPlanejado {
  const AvisoPlanejado({required this.quando, required this.titulo, required this.corpo, this.despertar = false});
  final DateTime quando;
  final String titulo;
  final String corpo;

  /// "Me despertar": no Android toca como despertador (lib/core/despertador.dart).
  final bool despertar;
}

/// Quais avisos disparam nos próximos [dias], em ordem, no máximo [limite]
/// (o iOS aceita até 64 agendados por app).
///
/// Pula lembretes desligados, os de itens apagados, os de tarefas sem
/// repetição já concluídas e as ocorrências já feitas (tarefa recorrente
/// concluída ou hábito marcado naquele dia).
List<AvisoPlanejado> planejarAvisos({
  required List<Lembrete> lembretes,
  required Map<String, Tarefa> tarefas,
  required Set<String> habitos,
  required Map<String, Set<String>> tarefasFeitasNoDia,
  required Map<String, Set<String>> habitosFeitosNoDia,
  required DateTime agora,
  int dias = 14,
  int limite = 60,
}) {
  final fim = agora.add(Duration(days: dias));
  final avisos = <AvisoPlanejado>[];
  for (final l in lembretes) {
    if (!l.ativo || l.apagadoEm != null) continue;
    Tarefa? tarefa;
    if (l.itemTipo == 'tarefa') {
      tarefa = tarefas[l.itemId];
      if (tarefa == null) continue;
      if (tarefa.regraRepeticao == null && tarefa.feitaEm != null) continue;
    }
    if (l.itemTipo == 'habito' && !habitos.contains(l.itemId)) continue;

    for (final quando in ocorrenciasLembrete(l, agora, limite: dias + 1)) {
      if (quando.isAfter(fim)) break;
      final dia = chaveDia(quando);
      if (l.itemTipo == 'tarefa' && (tarefasFeitasNoDia[l.itemId]?.contains(dia) ?? false)) continue;
      if (l.itemTipo == 'habito' && (habitosFeitosNoDia[dia]?.contains(l.itemId) ?? false)) continue;
      avisos.add(AvisoPlanejado(
        quando: quando,
        titulo: l.texto,
        corpo: switch (l.itemTipo) {
          'tarefa' => 'Tarefa${tarefa?.regraRepeticao != null ? ' · ${Regra.ler(tarefa!.regraRepeticao)!.descricao.toLowerCase()}' : ''}',
          'habito' => 'Hábito de hoje',
          _ => 'Lembrete',
        },
        despertar: l.despertar,
      ));
    }
  }
  avisos.sort((a, b) => a.quando.compareTo(b.quando));
  return avisos.take(limite).toList();
}

/// Avisos dos compromissos nos próximos [dias]: cada ocorrência avisa
/// `avisoAntesMin` minutos antes (sem aviso quando é nulo). No dia inteiro,
/// a conta parte das 09:00 do dia ("1 dia antes" = 09:00 da véspera).
List<AvisoPlanejado> avisosDeCompromissos(List<Compromisso> compromissos, DateTime agora, {int dias = 14}) {
  final hoje = dataLocal(agora);
  final avisos = <AvisoPlanejado>[];
  for (final c in compromissos) {
    final antes = c.avisoAntesMin;
    if (antes == null || c.apagadoEm != null) continue;
    // O aviso de "1 dia antes" de um compromisso daqui a [dias] + 1 ainda cai na janela.
    for (final o in ocorrenciasCompromisso(c, hoje, somarDias(hoje, dias + 1))) {
      final base = o.diaInteiro ? instanteLocal(o.dia, 9) : o.inicio;
      final quando = base.subtract(Duration(minutes: antes));
      if (!quando.isAfter(agora) || quando.isAfter(agora.add(Duration(days: dias)))) continue;
      avisos.add(AvisoPlanejado(
        quando: quando,
        titulo: c.titulo,
        corpo: [
          if (antes == 0) 'Compromisso agora' else 'Compromisso ${_falta(antes)}',
          o.horario,
          ?c.local,
        ].join(' · '),
        despertar: c.despertar,
      ));
    }
  }
  return avisos;
}

/// "em 15 min", "em 1 h", "amanhã".
String _falta(int minutos) => switch (minutos) {
      1440 => 'amanhã',
      >= 60 when minutos % 60 == 0 => 'em ${minutos ~/ 60} h',
      _ => 'em $minutos min',
    };

/// Avisos das automações ligadas nos próximos [dias] (com a chave geral ligada).
List<AvisoPlanejado> avisosDeAutomacoes(List<Automacao> automacoes, DateTime agora, {int dias = 14}) => [
      for (final a in automacoes)
        if (a.ativa && a.apagadoEm == null)
          for (final quando in proximasOcorrencias(a, agora, dias: dias))
            AvisoPlanejado(
              quando: quando,
              titulo: a.nome,
              corpo: ModeloAutomacao.de(a.modelo) == ModeloAutomacao.personalizada
                  ? 'A Aurora está respondendo: ${a.pedido ?? ''}'
                  : 'Pronto no assistente do Aurora.',
            ),
    ];

/// Agenda os avisos no sistema (Windows, Android, iOS) e reagenda quando
/// lembretes, tarefas ou hábitos mudam.
class Notificador {
  Notificador._();
  static final instancia = Notificador._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _pronto = false;
  bool _exato = false;
  Timer? _espera;
  StreamSubscription<void>? _escuta;

  /// Web (PWA): o navegador não agenda aviso local. A agenda vai para o servidor
  /// (substituir_avisos), que manda por Web Push na hora (AvisosPush).
  bool _web = false;

  Future<void> iniciar(BancoAurora db) async {
    if (kIsWeb) {
      _web = true;
      _pronto = true;
      await reagendar(db);
      _ouvirMudancas(db);
      // Ao entrar na conta (ou trocar), a agenda vai para a conta nova.
      nuvem?.auth.onAuthStateChange.listen((_) => reagendar(db));
      unawaited(AvisosPush.renovar());
      return;
    }
    try {
      _pronto = await _plugin.initialize(
            settings: const InitializationSettings(
              android: AndroidInitializationSettings('@mipmap/ic_launcher'),
              iOS: DarwinInitializationSettings(),
              windows: WindowsInitializationSettings(
                appName: 'Aurora',
                appUserModelId: 'BrAppAurora.Aurora',
                guid: '6f1d6b7e-3c2a-4f0e-9a51-8d2b7c4e1a90',
              ),
            ),
            onDidReceiveNotificationResponse: _aoResponder,
          ) ??
          false;
      final android = _android;
      if (android != null) {
        await android.requestNotificationsPermission();
        _exato = await android.canScheduleExactNotifications() ?? false;
      }
      // O despertador abriu o app (tela cheia com o celular bloqueado, ou
      // "Adiar" com o app fechado): trata como se tivesse tocado agora.
      final abertura = await _plugin.getNotificationAppLaunchDetails();
      final resposta = abertura?.notificationResponse;
      if ((abertura?.didNotificationLaunchApp ?? false) && resposta != null) _aoResponder(resposta);
    } catch (e) {
      debugPrint('Notificações indisponíveis: $e');
      _pronto = false;
    }
    if (!_pronto) return;

    await reagendar(db);
    _ouvirMudancas(db);
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  /// Ao ligar "Me despertar": no Android 14+ a tela cheia por cima do bloqueio
  /// precisa ser liberada nas configurações; e o horário exato, se faltar.
  Future<void> pedirPermissoesDespertador() async {
    // Sem o plugin iniciado (web, testes) não há o que pedir.
    if (!_pronto || _web) return;
    final android = _android;
    if (android == null) return;
    try {
      await android.requestFullScreenIntentPermission();
      if (!(await android.canScheduleExactNotifications() ?? false)) {
        await android.requestExactAlarmsPermission();
      }
      _exato = await android.canScheduleExactNotifications() ?? false;
    } catch (e) {
      debugPrint('Despertador: permissões ($e)');
    }
  }

  /// Toque no aviso, num botão dele ou abertura em tela cheia.
  void _aoResponder(NotificationResponse r) {
    if (molduraPropria) {
      unawaited(JanelaWindows.instancia.restaurar());
    }
    final titulo = tituloDoDespertador(r.payload);
    if (titulo == null) return;
    final id = r.id;
    switch (r.actionId) {
      case 'parar':
        if (id != null) _plugin.cancel(id: id);
      case 'adiar':
        _adiar(titulo, id);
      default:
        _abrirDespertador(titulo, id);
    }
  }

  /// Mostra a tela do despertador (espera o app terminar de abrir).
  void _abrirDespertador(String titulo, int? id, [int tentativas = 0]) {
    final navegador = chaveNavegador.currentState;
    if (navegador == null) {
      if (tentativas < 50) {
        Timer(const Duration(milliseconds: 200), () => _abrirDespertador(titulo, id, tentativas + 1));
      }
      return;
    }
    navegador.push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => TelaDespertador(
        titulo: titulo,
        aoParar: () {
          if (id != null) _plugin.cancel(id: id);
        },
        aoAdiar: () => _adiar(titulo, id),
      ),
    ));
  }

  /// Para o som e toca de novo daqui a [minutosAdiar] minutos.
  Future<void> _adiar(String titulo, int? id) async {
    if (id != null) await _plugin.cancel(id: id);
    final quando = tz.TZDateTime.now(fusoLocal).add(const Duration(minutes: minutosAdiar));
    try {
      await _plugin.zonedSchedule(
        id: idAdiadoBase + quando.millisecondsSinceEpoch ~/ 1000 % 90000,
        title: titulo,
        body: 'Adiado $minutosAdiar min',
        scheduledDate: quando,
        notificationDetails: detalhesDespertador,
        payload: payloadDespertador(titulo),
        androidScheduleMode:
            _exato ? AndroidScheduleMode.alarmClock : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Despertador: falha ao adiar ($e)');
    }
  }

  void _ouvirMudancas(BancoAurora db) {
    _escuta = db
        .tableUpdates(TableUpdateQuery.onAllTables([
          db.lembretes,
          db.tarefas,
          db.conclusoesTarefa,
          db.habitos,
          db.registrosHabito,
          db.compromissos,
          db.automacoes,
        ]))
        .listen((_) {
      _espera?.cancel();
      _espera = Timer(const Duration(milliseconds: 800), () => reagendar(db));
    });
  }

  /// Uma rodada por vez. No Windows o plugin chama o sistema direto em C++
  /// (FFI) e um erro lá DERRUBA o app (abort(), não vira exceção no Dart): duas
  /// rodadas cruzadas (a IA grava um lembrete e a sincronização chega junto)
  /// faziam uma tirar da agenda o aviso que a outra mexia. Pedido no meio de
  /// uma rodada vira uma rodada nova logo depois.
  Future<void>? _rodando;
  bool _deNovo = false;

  Future<void> reagendar(BancoAurora db) async {
    if (!_pronto) return;
    if (_rodando != null) {
      _deNovo = true;
      return _rodando;
    }
    try {
      do {
        _deNovo = false;
        await (_rodando = _reagendarAgora(db));
      } while (_deNovo);
    } finally {
      _rodando = null;
    }
  }

  static const _detalhesComuns = NotificationDetails(
    android: AndroidNotificationDetails(
      'lembretes',
      'Lembretes',
      channelDescription: 'Lembretes, tarefas e hábitos no horário',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
    windows: WindowsNotificationDetails(),
  );

  /// Folga para um aviso: o Windows recusa (e o app cai) horário que já
  /// passou, e um aviso pode vencer no meio do agendamento.
  static const _folga = Duration(seconds: 30);

  Future<void> _reagendarAgora(BancoAurora db) async {
    final agora = agoraLocal();
    final lembretes = await (db.select(db.lembretes)..where((l) => l.apagadoEm.isNull())).get();
    final tarefas = {
      for (final t in await (db.select(db.tarefas)..where((t) => t.apagadoEm.isNull())).get()) t.id: t,
    };
    final habitos = {
      for (final h in await (db.select(db.habitos)..where((h) => h.apagadoEm.isNull())).get()) h.id,
    };
    final hoje = chaveDia(agora);
    final conclusoes = await (db.select(db.conclusoesTarefa)
          ..where((c) => c.apagadoEm.isNull() & c.dia.isBiggerOrEqualValue(hoje)))
        .get();
    final registros = await (db.select(db.registrosHabito)
          ..where((r) => r.feito & r.apagadoEm.isNull() & r.dia.isBiggerOrEqualValue(hoje)))
        .get();
    final tarefasFeitas = <String, Set<String>>{};
    for (final c in conclusoes) {
      tarefasFeitas.putIfAbsent(c.tarefaId, () => {}).add(c.dia);
    }
    final habitosFeitos = <String, Set<String>>{};
    for (final r in registros) {
      habitosFeitos.putIfAbsent(r.dia, () => {}).add(r.habitoId);
    }

    final automacoes = AutomacoesRepo(db);
    final avisos = [
      ...planejarAvisos(
        lembretes: lembretes,
        tarefas: tarefas,
        habitos: habitos,
        tarefasFeitasNoDia: tarefasFeitas,
        habitosFeitosNoDia: habitosFeitos,
        agora: agora,
      ),
      ...avisosDeCompromissos(
        await (db.select(db.compromissos)..where((c) => c.apagadoEm.isNull())).get(),
        agora,
      ),
      if (await automacoes.ligadas()) ...avisosDeAutomacoes(await automacoes.listar(), agora),
    ]..sort((a, b) => a.quando.compareTo(b.quando));
    if (avisos.length > 60) avisos.removeRange(60, avisos.length);

    if (_web) return _enviarAgenda(avisos);
    try {
      final android = _android;
      if (android != null) {
        // Android: tira só a agenda antiga; despertadores adiados (ids a partir de
        // idAdiadoBase) continuam marcados.
        for (final p in await _plugin.pendingNotificationRequests()) {
          if (p.id < idAdiadoBase) await _plugin.cancel(id: p.id);
        }
      } else {
        await _plugin.cancelAll();
      }
      var agendados = 0;
      for (var i = 0; i < avisos.length; i++) {
        final a = avisos[i];
        // Conferido na hora de agendar (o relógio andou desde o planejamento).
        if (!a.quando.isAfter(DateTime.now().add(_folga))) continue;
        agendados++;
        final despertador = a.despertar && android != null;
        await _plugin.zonedSchedule(
          id: i + 1,
          title: a.titulo,
          body: a.corpo,
          scheduledDate: tz.TZDateTime.from(a.quando, fusoLocal),
          notificationDetails: despertador ? detalhesDespertador : _detalhesComuns,
          payload: despertador ? payloadDespertador(a.titulo) : null,
          // alarmClock: o Android trata como despertador de verdade (ícone de
          // alarme na barra, toca mesmo com a economia de bateria).
          androidScheduleMode: !_exato
              ? AndroidScheduleMode.inexactAllowWhileIdle
              : despertador
                  ? AndroidScheduleMode.alarmClock
                  : AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
      debugPrint('Aurora: $agendados avisos agendados.');
    } catch (e) {
      debugPrint('Falha ao agendar avisos: $e');
    }
  }

  /// Web: troca a agenda da conta no servidor. Sem conta não há para quem
  /// mandar; sem internet, a próxima mudança (ou abertura) manda de novo.
  Future<void> _enviarAgenda(List<AvisoPlanejado> avisos) async {
    final cliente = nuvem;
    if (cliente == null || cliente.auth.currentUser == null) return;
    try {
      await cliente.rpc('substituir_avisos', params: {
        'avisos': [
          for (final a in avisos)
            {'quando': a.quando.toUtc().toIso8601String(), 'titulo': a.titulo, 'corpo': a.corpo},
        ],
      });
      debugPrint('Aurora: agenda de ${avisos.length} avisos enviada ao servidor.');
    } catch (e) {
      debugPrint('Falha ao enviar a agenda de avisos: $e');
    }
  }

  /// Mostra um aviso agora (para testar se as notificações aparecem).
  Future<void> testar() async {
    if (!_pronto || _web) return;
    await _plugin.show(
      id: 0,
      title: 'Aurora',
      body: 'As notificações estão funcionando.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails('lembretes', 'Lembretes'),
        iOS: DarwinNotificationDetails(),
        windows: WindowsNotificationDetails(),
      ),
    );
  }

  Future<void> parar() async {
    _espera?.cancel();
    await _escuta?.cancel();
  }
}
