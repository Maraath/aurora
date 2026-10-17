import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../data/automacoes_repo.dart';
import '../data/banco.dart';
import '../data/lembretes_repo.dart';
import 'recorrencia.dart';
import 'relogio.dart';

/// Um aviso a agendar no aparelho.
class AvisoPlanejado {
  const AvisoPlanejado({required this.quando, required this.titulo, required this.corpo});
  final DateTime quando;
  final String titulo;
  final String corpo;
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
      ));
    }
  }
  avisos.sort((a, b) => a.quando.compareTo(b.quando));
  return avisos.take(limite).toList();
}

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

  Future<void> iniciar(BancoAurora db) async {
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
          ) ??
          false;
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        await android.requestNotificationsPermission();
        _exato = await android.canScheduleExactNotifications() ?? false;
      }
    } catch (e) {
      debugPrint('Notificações indisponíveis: $e');
      _pronto = false;
    }
    if (!_pronto) return;

    await reagendar(db);
    _escuta = db
        .tableUpdates(TableUpdateQuery.onAllTables([
          db.lembretes,
          db.tarefas,
          db.conclusoesTarefa,
          db.habitos,
          db.registrosHabito,
          db.automacoes,
        ]))
        .listen((_) {
      _espera?.cancel();
      _espera = Timer(const Duration(milliseconds: 800), () => reagendar(db));
    });
  }

  Future<void> reagendar(BancoAurora db) async {
    if (!_pronto) return;
    final agora = agoraSP();
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
      if (await automacoes.ligadas()) ...avisosDeAutomacoes(await automacoes.listar(), agora),
    ]..sort((a, b) => a.quando.compareTo(b.quando));
    if (avisos.length > 60) avisos.removeRange(60, avisos.length);

    try {
      await _plugin.cancelAll();
      for (var i = 0; i < avisos.length; i++) {
        final a = avisos[i];
        await _plugin.zonedSchedule(
          id: i + 1,
          title: a.titulo,
          body: a.corpo,
          scheduledDate: tz.TZDateTime.from(a.quando, fusoSP),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'lembretes',
              'Lembretes',
              channelDescription: 'Lembretes, tarefas e hábitos no horário',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
            windows: WindowsNotificationDetails(),
          ),
          androidScheduleMode: _exato
              ? AndroidScheduleMode.exactAllowWhileIdle
              : AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
      debugPrint('Aurora: ${avisos.length} avisos agendados.');
    } catch (e) {
      debugPrint('Falha ao agendar avisos: $e');
    }
  }

  /// Mostra um aviso agora (para testar se as notificações aparecem).
  Future<void> testar() async {
    if (!_pronto) return;
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
