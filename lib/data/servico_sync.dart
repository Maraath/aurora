import 'dart:async';

import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/nuvem.dart';
import 'anotacoes_repo.dart';
import 'banco.dart';
import 'fotos_sync.dart';
import 'shape_repo.dart';
import 'sincronizacao.dart';

/// O servidor de verdade: as tabelas do Supabase, protegidas por RLS.
class RemotoSupabase implements RemotoSync {
  RemotoSupabase(this.cliente);
  final SupabaseClient cliente;

  @override
  Future<void> enviar(String tabela, List<Map<String, dynamic>> linhas) =>
      cliente.from(tabela).upsert(linhas, onConflict: chaveNoServidor);

  @override
  Future<List<Map<String, dynamic>>> baixar(String tabela, Cursor? depois, int limite) async {
    var consulta = cliente.from(tabela).select();
    if (depois != null) {
      final ts = depois.servidorEm;
      consulta = consulta.or('servidor_em.gt."$ts",and(servidor_em.eq."$ts",id.gt."${depois.id}")');
    }
    return consulta.order('servidor_em', ascending: true).order('id', ascending: true).limit(limite);
  }

  @override
  Future<bool> temDados() async {
    for (final t in const ['tarefas', 'habitos', 'transacoes', 'lembretes', 'metas', 'treinos', 'medidas']) {
      if ((await cliente.from(t).select('id').limit(1)).isNotEmpty) return true;
    }
    return false;
  }
}

enum FaseSync { semConta, ocioso, sincronizando, escolher, erro }

class EstadoSync {
  const EstadoSync(this.fase, {this.ultima, this.mensagem});
  final FaseSync fase;
  final DateTime? ultima;
  final String? mensagem;
}

/// Liga a sincronização ao login e às mudanças locais.
class ServicoSync {
  ServicoSync._();
  static final instancia = ServicoSync._();

  final estado = ValueNotifier(const EstadoSync(FaseSync.semConta));

  BancoAurora? _db;
  Timer? _periodico;
  Timer? _espera;
  StreamSubscription<AuthState>? _login;
  StreamSubscription<Object?>? _mudancas;
  bool _rodando = false;
  bool _deNovo = false;

  Future<void> iniciar(BancoAurora db) async {
    final cliente = nuvem;
    if (cliente == null) return;
    _db = db;
    final ultima = await db.preferencia('sync_ultima');
    estado.value = EstadoSync(
      cliente.auth.currentSession == null ? FaseSync.semConta : FaseSync.ocioso,
      ultima: ultima == null ? null : DateTime.tryParse(ultima),
    );

    _login = cliente.auth.onAuthStateChange.listen((e) {
      if (e.session == null) {
        _periodico?.cancel();
        estado.value = EstadoSync(FaseSync.semConta, ultima: estado.value.ultima);
        return;
      }
      if (e.event == AuthChangeEvent.signedIn || e.event == AuthChangeEvent.initialSession) {
        _periodico?.cancel();
        _periodico = Timer.periodic(const Duration(minutes: 2), (_) => sincronizar());
        sincronizar();
      }
    });

    // Mudou algo aqui? Envia uns segundos depois (junta várias mudanças seguidas).
    _mudancas = db.tableUpdates(TableUpdateQuery.onAllTables(tabelasSincronizadas(db))).listen((_) {
      if (_rodando || cliente.auth.currentSession == null) return;
      _espera?.cancel();
      _espera = Timer(const Duration(seconds: 5), sincronizar);
    });
  }

  Future<void> parar() async {
    _periodico?.cancel();
    _espera?.cancel();
    await _login?.cancel();
    await _mudancas?.cancel();
  }

  Sincronizador? _sincronizador() {
    final cliente = nuvem;
    final usuario = cliente?.auth.currentUser;
    final db = _db;
    if (cliente == null || usuario == null || db == null) return null;
    return Sincronizador(db, RemotoSupabase(cliente), usuarioId: usuario.id);
  }

  /// Imagens das fotos, depois das linhas (envios e exclusões pendentes; nada
  /// é baixado aqui). Uma falha não derruba o resto: tenta de novo depois.
  Future<void> _sincronizarFotos(Sincronizador s) async {
    try {
      final r = await SincronizadorFotos(ShapeRepo(s.db)).sincronizar();
      if (r.enviadas + r.apagadas > 0) debugPrint('Fotos: ${r.enviadas} enviadas, ${r.apagadas} apagadas da nuvem');
    } catch (e) {
      debugPrint('Shape: sincronização das fotos falhou: $e');
    }
    try {
      final r = await AnotacoesRepo(s.db).sincronizarAudios();
      if (r.enviados + r.apagados > 0) debugPrint('Áudios: ${r.enviados} enviados, ${r.apagados} apagados da nuvem');
    } catch (e) {
      debugPrint('Anotações: sincronização dos áudios falhou: $e');
    }
  }

  Future<void> sincronizar() => _executar((s) => s.sincronizar());

  /// Resposta da pessoa na primeira sincronização com dados dos dois lados.
  Future<void> escolher(EscolhaPrimeiraVez escolha) => _executar((s) => s.escolher(escolha));

  Future<void> _executar(Future<ResultadoSync> Function(Sincronizador) acao) async {
    final s = _sincronizador();
    if (s == null) return;
    if (_rodando) {
      _deNovo = true;
      return;
    }
    _rodando = true;
    estado.value = EstadoSync(FaseSync.sincronizando, ultima: estado.value.ultima);
    try {
      final r = await acao(s);
      debugPrint('Sincronização: ${r.enviadas} enviadas, ${r.recebidas} recebidas');
      await _sincronizarFotos(s);
      estado.value = EstadoSync(FaseSync.ocioso, ultima: DateTime.now());
    } on PrecisaEscolher {
      estado.value = EstadoSync(FaseSync.escolher, ultima: estado.value.ultima);
    } catch (e) {
      debugPrint('Sincronização falhou: $e');
      estado.value = EstadoSync(FaseSync.erro, ultima: estado.value.ultima, mensagem: mensagemDeErro(e));
    } finally {
      _rodando = false;
    }
    if (_deNovo && estado.value.fase != FaseSync.escolher) {
      _deNovo = false;
      unawaited(sincronizar());
    }
  }
}
