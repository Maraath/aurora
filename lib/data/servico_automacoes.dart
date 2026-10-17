import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/relogio.dart';
import 'assistente_repo.dart';
import 'automacoes_repo.dart';
import 'banco.dart';
import 'textos_automacao.dart';

/// Executa uma automação: monta o texto (ou manda o pedido para a IA) e
/// grava na conversa do assistente. Com [marcar], registra a ocorrência como
/// feita (sincroniza, e o outro aparelho não repete).
Future<void> executarAutomacao(
  BancoAurora db,
  Automacao a, {
  required DateTime agora,
  DateTime? dia,
  bool marcar = true,
  AssistenteRepo? assistente,
}) async {
  final modelo = ModeloAutomacao.de(a.modelo);
  final quando = dia ?? dataSP(agora);
  final repoAssistente = assistente ?? AssistenteRepo(db);
  // Marca antes: se a IA demorar, o minuto seguinte não roda de novo.
  if (marcar) await AutomacoesRepo(db).marcarExecutada(a, quando);
  if (modelo == ModeloAutomacao.personalizada) {
    final pedido = a.pedido?.trim() ?? '';
    if (pedido.isNotEmpty) await repoAssistente.pedidoDaAutomacao(a.nome, pedido);
    return;
  }
  final texto = await gerarTexto(modelo, db, agora);
  await repoAssistente.mensagemDaAutomacao(tituloExecucao(a, quando), texto);
}

/// Roda as automações pendentes. Retorna quantas rodaram.
Future<int> executarPendentes(BancoAurora db, {required DateTime agora, AssistenteRepo? assistente}) async {
  final repo = AutomacoesRepo(db);
  if (!await repo.ligadas()) return 0;
  var n = 0;
  for (final a in await repo.listar()) {
    final o = pendente(a, agora);
    if (o == null) continue;
    await executarAutomacao(db, a, agora: agora, dia: o.dia, assistente: assistente);
    n++;
  }
  return n;
}

/// Confere a cada minuto (com o app aberto) e ao abrir o app.
class ServicoAutomacoes {
  ServicoAutomacoes._();
  static final instancia = ServicoAutomacoes._();

  Timer? _relogio;
  bool _rodando = false;

  Future<void> iniciar(BancoAurora db) async {
    await AutomacoesRepo(db).garantirModelos();
    await _verificar(db);
    _relogio?.cancel();
    _relogio = Timer.periodic(const Duration(minutes: 1), (_) => _verificar(db));
  }

  Future<void> _verificar(BancoAurora db) async {
    if (_rodando) return;
    _rodando = true;
    try {
      final n = await executarPendentes(db, agora: agoraSP());
      if (n > 0) debugPrint('Automações: $n executada(s).');
    } catch (e) {
      debugPrint('Automações falharam: $e');
    } finally {
      _rodando = false;
    }
  }

  void parar() => _relogio?.cancel();
}
