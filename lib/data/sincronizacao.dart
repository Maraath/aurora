import 'package:drift/drift.dart';

import 'banco.dart';

/// Sincronização com a nuvem.
///
/// Cada aparelho guarda tudo localmente. A sincronização:
///  1. ENVIA as linhas alteradas desde o último envio (`atualizado_em`);
///  2. BAIXA as linhas que o servidor recebeu desde a última vez (`servidor_em`,
///     o relógio do servidor), aplicando só as que forem mais novas que a cópia local.
/// No servidor, um gatilho ignora envios mais velhos que a versão guardada:
/// a edição mais recente vence. Exclusões são `apagado_em`, então também viajam.
///
/// O servidor fica atrás de [RemotoSync] (Supabase no app, memória nos testes).

/// Tabelas sincronizadas, pais antes dos filhos (por causa das chaves locais).
List<TableInfo<Table, dynamic>> tabelasSincronizadas(BancoAurora db) => [
      db.metas,
      db.projetos,
      db.tarefas,
      db.habitos,
      db.conclusoesTarefa,
      db.registrosHabito,
      db.contasFinanceiras,
      db.transacoes,
      db.pagamentosTransacao,
      db.lembretes,
      db.compromissos,
      db.exercicios,
      db.treinos,
      db.itensTreino,
      db.sessoesTreino,
      db.seriesFeitas,
      db.medidas,
      db.fotosShape,
      db.alimentos,
      db.alvosDieta,
      db.registrosAlimentacao,
      db.mensagensAssistente,
      db.automacoes,
      db.pastasNotas,
      db.notas,
      db.anexosNota,
    ];

/// Tabelas com chave natural (além do id), para não duplicar registros antigos.
const _chavesNaturais = {
  'conclusoes_tarefa': ['tarefa_id', 'dia'],
  'registros_habito': ['habito_id', 'dia'],
  'pagamentos_transacao': ['transacao_id', 'vencimento'],
  'medidas': ['dia', 'tipo'],
  'fotos_shape': ['dia', 'angulo'],
  'alvos_dieta': ['tipo_dia'],
};

/// Chave das tabelas no servidor (migração 20261020120000_chave_por_conta).
/// Ids de chave natural (automações prontas, medidas, fotos do Shape, alvos da
/// dieta, TACO) são iguais em todas as contas: com a chave só no id, o envio de
/// uma conta nova batia na linha de outra pessoa e caía na RLS.
const chaveNoServidor = 'user_id,id';

/// Posição na fila de mudanças do servidor: (servidor_em, id).
class Cursor {
  const Cursor(this.servidorEm, this.id);
  final String servidorEm;
  final String id;

  static Cursor? ler(String? texto) {
    if (texto == null) return null;
    final i = texto.indexOf('|');
    return i < 0 ? null : Cursor(texto.substring(0, i), texto.substring(i + 1));
  }

  @override
  String toString() => '$servidorEm|$id';
}

abstract class RemotoSync {
  /// Envia linhas (formato do servidor, sem user_id/servidor_em).
  Future<void> enviar(String tabela, List<Map<String, dynamic>> linhas);

  /// Linhas com (servidor_em, id) depois de [depois], em ordem, até [limite].
  Future<List<Map<String, dynamic>>> baixar(String tabela, Cursor? depois, int limite);

  /// A conta já tem dados na nuvem?
  Future<bool> temDados();
}

enum EscolhaPrimeiraVez { juntar, usarNuvem }

class PrecisaEscolher implements Exception {
  const PrecisaEscolher();
}

class ResultadoSync {
  const ResultadoSync({required this.enviadas, required this.recebidas});
  final int enviadas;
  final int recebidas;
}

class Sincronizador {
  Sincronizador(this.db, this.remoto, {required this.usuarioId});
  final BancoAurora db;
  final RemotoSync remoto;
  final String usuarioId;

  static const _lote = 200;

  /// Sincroniza. Na primeira vez desta conta neste aparelho, se houver dados
  /// dos dois lados, lança [PrecisaEscolher] (a pessoa decide com [escolher]).
  Future<ResultadoSync> sincronizar() async {
    if (await db.preferencia('sync_usuario') != usuarioId) {
      final local = await _temDadosLocais();
      final nuvem = await remoto.temDados();
      if (local && nuvem) throw const PrecisaEscolher();
      await _comecarDoZero();
    }
    final enviadas = await _enviar();
    final recebidas = await _baixar();
    await db.salvarPreferencia('sync_ultima', DateTime.now().toIso8601String());
    return ResultadoSync(enviadas: enviadas, recebidas: recebidas);
  }

  /// Primeira vez com dados dos dois lados: juntar tudo, ou trocar os dados
  /// deste aparelho pelos da nuvem.
  Future<ResultadoSync> escolher(EscolhaPrimeiraVez escolha) async {
    if (escolha == EscolhaPrimeiraVez.usarNuvem) await _apagarLocais();
    await _comecarDoZero();
    return sincronizar();
  }

  Future<void> _comecarDoZero() async {
    await db.salvarPreferencia('sync_usuario', usuarioId);
    await db.salvarPreferencia('sync_enviado', '0');
    await (db.delete(db.preferencias)..where((p) => p.chave.like('sync_baixado_%'))).go();
  }

  Future<bool> _temDadosLocais() async {
    for (final t in tabelasSincronizadas(db)) {
      final r = await db.customSelect('SELECT 1 FROM ${t.actualTableName} LIMIT 1').get();
      if (r.isNotEmpty) return true;
    }
    return false;
  }

  Future<void> _apagarLocais() => db.transaction(() async {
        for (final t in tabelasSincronizadas(db).reversed) {
          await db.customStatement('DELETE FROM ${t.actualTableName}');
        }
        db.notifyUpdates({for (final t in tabelasSincronizadas(db)) TableUpdate.onTable(t)});
      });

  // ------------------------------------------------------------------ envio

  Future<int> _enviar() async {
    final desde = int.tryParse(await db.preferencia('sync_enviado') ?? '') ?? 0;
    // Começo DESTE envio, um segundo antes: o que mudar durante o envio vai na próxima.
    final marco = DateTime.now().millisecondsSinceEpoch ~/ 1000 - 1;
    var total = 0;
    for (final t in tabelasSincronizadas(db)) {
      final linhas = await db
          .customSelect('SELECT * FROM ${t.actualTableName} WHERE atualizado_em > ?',
              variables: [Variable<int>(desde)])
          .get();
      final convertidas = [for (final l in linhas) paraServidor(t, l.data)];
      for (var i = 0; i < convertidas.length; i += _lote) {
        await remoto.enviar(t.actualTableName,
            convertidas.sublist(i, i + _lote > convertidas.length ? convertidas.length : i + _lote));
      }
      total += convertidas.length;
    }
    await db.salvarPreferencia('sync_enviado', '$marco');
    return total;
  }

  // ---------------------------------------------------------------- recebimento

  Future<int> _baixar() async {
    var total = 0;
    for (final t in tabelasSincronizadas(db)) {
      final chave = 'sync_baixado_${t.actualTableName}';
      final salvo = Cursor.ler(await db.preferencia(chave));
      // Recomeça 30 s antes do último visto: pega linhas gravadas "atrasadas"
      // no servidor. Reaplicar é inofensivo.
      var cursor = salvo == null
          ? null
          : Cursor(
              DateTime.parse(salvo.servidorEm).subtract(const Duration(seconds: 30)).toUtc().toIso8601String(),
              '');
      Cursor? maisNovo = salvo;
      while (true) {
        final lote = await remoto.baixar(t.actualTableName, cursor, _lote);
        if (lote.isEmpty) break;
        total += await _aplicar(t, lote);
        final ultima = lote.last;
        cursor = Cursor(ultima['servidor_em'] as String, ultima['id'] as String);
        if (maisNovo == null ||
            DateTime.parse(cursor.servidorEm).isAfter(DateTime.parse(maisNovo.servidorEm))) {
          maisNovo = cursor;
        }
        if (lote.length < _lote) break;
      }
      if (maisNovo != null) await db.salvarPreferencia(chave, '$maisNovo');
    }
    return total;
  }

  /// Aplica as linhas do servidor que forem mais novas que as locais.
  Future<int> _aplicar(TableInfo<Table, dynamic> t, List<Map<String, dynamic>> lote) async {
    final nome = t.actualTableName;
    final colunas = [for (final c in t.$columns) c.name];
    var aplicadas = 0;
    await db.transaction(() async {
      // As linhas podem chegar antes dos "pais"; confere as chaves só no fim.
      await db.customStatement('PRAGMA defer_foreign_keys = ON');
      for (final s in lote) {
        final local = paraLocal(t, s);
        final atual = await db.customSelect('SELECT atualizado_em FROM $nome WHERE id = ?',
            variables: [Variable<String>(local['id'] as String)]).getSingleOrNull();
        // Local mais nova, ou a mesma versão (reenvio, margem de 30 s): nada a fazer.
        if (atual != null && atual.read<int>('atualizado_em') >= (local['atualizado_em'] as int)) continue;

        final natural = _chavesNaturais[nome];
        if (natural != null) {
          await db.customStatement(
            'DELETE FROM $nome WHERE ${natural.map((c) => '$c = ?').join(' AND ')} AND id <> ?',
            [for (final c in natural) local[c], local['id']],
          );
        }
        await db.customStatement(
          'INSERT INTO $nome (${colunas.join(', ')}) VALUES (${List.filled(colunas.length, '?').join(', ')}) '
          'ON CONFLICT(id) DO UPDATE SET ${colunas.where((c) => c != 'id').map((c) => '$c = excluded.$c').join(', ')}',
          [for (final c in colunas) local[c]],
        );
        aplicadas++;
      }
    });
    if (aplicadas > 0) db.notifyUpdates({TableUpdate.onTable(t)});
    return aplicadas;
  }
}

/// Linha local (datas em segundos, booleanos 0/1) → formato do servidor.
Map<String, dynamic> paraServidor(TableInfo<Table, dynamic> t, Map<String, dynamic> linha) => {
      for (final c in t.$columns)
        c.name: switch ((c.type, linha[c.name])) {
          (_, null) => null,
          (DriftSqlType.dateTime, final int s) =>
            DateTime.fromMillisecondsSinceEpoch(s * 1000, isUtc: true).toIso8601String(),
          (DriftSqlType.bool, final int b) => b != 0,
          (_, final v) => v,
        },
    };

/// Linha do servidor → valores para gravar localmente.
Map<String, dynamic> paraLocal(TableInfo<Table, dynamic> t, Map<String, dynamic> linha) => {
      for (final c in t.$columns)
        c.name: switch ((c.type, linha[c.name])) {
          (_, null) => null,
          (DriftSqlType.dateTime, final String iso) => DateTime.parse(iso).millisecondsSinceEpoch ~/ 1000,
          (DriftSqlType.bool, final bool b) => b ? 1 : 0,
          (DriftSqlType.double, final num n) => n.toDouble(),
          (DriftSqlType.int || DriftSqlType.bigInt, final num n) => n.toInt(),
          (_, final v) => v,
        },
    };
