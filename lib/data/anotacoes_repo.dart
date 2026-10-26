import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../core/comandos.dart' show normalizar;
import 'banco.dart';
import 'fotos/cofre.dart';
import 'fotos/cofre_audios.dart';
import 'fotos/compressao.dart';
import 'gravacao_nota.dart';
import 'ia/protocolo.dart' show ErroIa;
import 'ia/voz.dart' show TranscreverIa, transcricaoDaNuvem;
import 'observar.dart';

/// Uma caixinha da lista de uma nota.
class ItemLista {
  const ItemLista(this.texto, {this.feito = false});
  final String texto;
  final bool feito;

  ItemLista copiar({String? texto, bool? feito}) => ItemLista(texto ?? this.texto, feito: feito ?? this.feito);

  Map<String, dynamic> paraJson() => {'t': texto, 'f': feito};
}

/// Lê a coluna `itens` (JSON). Texto quebrado vira lista vazia.
List<ItemLista> lerItens(String? json) {
  if (json == null || json.isEmpty) return const [];
  try {
    final lista = jsonDecode(json);
    if (lista is! List) return const [];
    return [
      for (final i in lista)
        if (i is Map) ItemLista('${i['t'] ?? ''}', feito: i['f'] == true),
    ];
  } on FormatException {
    return const [];
  }
}

String? gravarItens(List<ItemLista> itens) => itens.isEmpty ? null : jsonEncode([for (final i in itens) i.paraJson()]);

extension RefAnexo on AnexoNota {
  RefFoto get refFoto => (id: id, hash: hash, naNuvem: naNuvem);
  RefAudio get refAudio => (id: id, hash: hash, naNuvem: naNuvem, formato: formato ?? 'audio/wav');
  bool get ehFoto => tipo == 'foto';
  bool get ehAudio => tipo == 'audio';
  Duration get duracao => Duration(milliseconds: duracaoMs ?? 0);
}

/// Uma nota com as caixinhas já lidas e os anexos (em ordem).
class NotaCompleta {
  const NotaCompleta(this.nota, this.itens, this.anexos);
  final Nota nota;
  final List<ItemLista> itens;
  final List<AnexoNota> anexos;

  String get id => nota.id;
  List<AnexoNota> get fotos => [for (final a in anexos) if (a.ehFoto) a];
  List<AnexoNota> get audios => [for (final a in anexos) if (a.ehAudio) a];

  /// O título, ou o começo do texto/transcrição, ou o tipo.
  String get tituloVisivel {
    final t = nota.titulo.trim();
    if (t.isNotEmpty) return t;
    final primeira = previaCompleta.split('\n').first.trim();
    if (primeira.isNotEmpty) return primeira.length > 60 ? '${primeira.substring(0, 60)}…' : primeira;
    return switch (nota.tipo) {
      TipoNota.lista => 'Lista sem título',
      TipoNota.audio => 'Nota de áudio',
      TipoNota.foto => 'Foto',
      TipoNota.texto => 'Nota sem título',
    };
  }

  /// Texto da prévia: o texto, senão as caixinhas, senão a transcrição.
  String get previaCompleta {
    final texto = nota.texto.trim();
    if (texto.isNotEmpty) return texto;
    final itensTexto = [for (final i in itens) if (i.texto.trim().isNotEmpty) i.texto.trim()].join(', ');
    if (itensTexto.isNotEmpty) return itensTexto;
    return [for (final a in audios) if ((a.transcricao ?? '').isNotEmpty) a.transcricao!].join(' ');
  }

  int get feitos => itens.where((i) => i.feito).length;
  int get itensComTexto => itens.where((i) => i.texto.trim().isNotEmpty).length;

  bool get vazia =>
      nota.titulo.trim().isEmpty && nota.texto.trim().isEmpty && itensComTexto == 0 && anexos.isEmpty;

  /// Tudo o que a busca olha: título, texto, caixinhas e transcrições.
  String get textoParaBusca => [
        nota.titulo,
        nota.texto,
        for (final i in itens) i.texto,
        for (final a in audios) a.transcricao ?? '',
      ].join(' ');
}

class QuadroNotas {
  const QuadroNotas(this.pastas, this.notas);
  final List<PastaNota> pastas;

  /// Fixadas primeiro; dentro de cada grupo, a editada por último primeiro.
  final List<NotaCompleta> notas;

  PastaNota? pasta(String? id) => id == null ? null : pastas.where((p) => p.id == id).firstOrNull;
  NotaCompleta? nota(String id) => notas.where((n) => n.id == id).firstOrNull;
}

/// Filtro da lista: todas, uma pasta ou só as com áudio.
sealed class FiltroNotas {
  const FiltroNotas();
}

class TodasAsNotas extends FiltroNotas {
  const TodasAsNotas();
  @override
  bool operator ==(Object other) => other is TodasAsNotas;
  @override
  int get hashCode => 1;
}

class SoAudios extends FiltroNotas {
  const SoAudios();
  @override
  bool operator ==(Object other) => other is SoAudios;
  @override
  int get hashCode => 2;
}

class NaPasta extends FiltroNotas {
  const NaPasta(this.id);
  final String id;
  @override
  bool operator ==(Object other) => other is NaPasta && other.id == id;
  @override
  int get hashCode => id.hashCode;
}

/// Notas que passam no filtro e no termo de busca (ignora acentos).
List<NotaCompleta> filtrarNotas(List<NotaCompleta> notas, FiltroNotas filtro, String termo) {
  final t = normalizar(termo.trim());
  return [
    for (final n in notas)
      if (switch (filtro) {
            TodasAsNotas() => true,
            SoAudios() => n.audios.isNotEmpty,
            NaPasta(:final id) => n.nota.pastaId == id,
          } &&
          (t.isEmpty || normalizar(n.textoParaBusca).contains(t)))
        n,
  ];
}

/// Anotações: pastas, notas e anexos. Fotos passam pelo [CofreFotos] (as mesmas
/// regras do Shape) e áudios pelo [CofreAudios]; o modo "Onde guardar" é o
/// mesmo para os dois.
class AnotacoesRepo {
  AnotacoesRepo(this.db, {CofreFotos? cofreFotos, CofreAudios? cofreAudios, TranscreverIa? Function()? transcrever})
      : cofreFotos = cofreFotos ?? CofreFotos(db),
        cofreAudios = cofreAudios ?? CofreAudios(db),
        _transcrever = transcrever ?? (() => transcricaoDaNuvem(uso: 'nota'));

  final BancoAurora db;
  final CofreFotos cofreFotos;
  final CofreAudios cofreAudios;
  final TranscreverIa? Function() _transcrever;

  Stream<QuadroNotas> observarQuadro() => observar(db, [db.pastasNotas, db.notas, db.anexosNota], carregar);

  Future<QuadroNotas> carregar() async {
    final pastas = await (db.select(db.pastasNotas)
          ..where((p) => p.apagadoEm.isNull())
          ..orderBy([(p) => OrderingTerm.asc(p.ordem), (p) => OrderingTerm.asc(p.criadoEm)]))
        .get();
    final notas = await (db.select(db.notas)
          ..where((n) => n.apagadoEm.isNull())
          ..orderBy([(n) => OrderingTerm.desc(n.fixada), (n) => OrderingTerm.desc(n.atualizadoEm)]))
        .get();
    final anexos = <String, List<AnexoNota>>{};
    for (final a in await (db.select(db.anexosNota)
          ..where((a) => a.apagadoEm.isNull())
          ..orderBy([(a) => OrderingTerm.asc(a.ordem), (a) => OrderingTerm.asc(a.criadoEm)]))
        .get()) {
      (anexos[a.notaId] ??= []).add(a);
    }
    return QuadroNotas(pastas, [for (final n in notas) NotaCompleta(n, lerItens(n.itens), anexos[n.id] ?? const [])]);
  }

  Future<NotaCompleta?> nota(String id) async => (await carregar()).nota(id);

  // ---------- notas ----------

  Future<String> criarNota({
    TipoNota tipo = TipoNota.texto,
    String? pastaId,
    String titulo = '',
    String texto = '',
    List<ItemLista> itens = const [],
  }) async {
    final linha = await db.into(db.notas).insertReturning(NotasCompanion.insert(
          tipo: Value(tipo),
          pastaId: Value(pastaId),
          titulo: Value(titulo),
          texto: Value(texto),
          itens: Value(gravarItens(itens)),
        ));
    return linha.id;
  }

  Future<void> salvarNota(
    String id, {
    String? titulo,
    String? texto,
    List<ItemLista>? itens,
    Value<String?> pastaId = const Value.absent(),
    bool? fixada,
  }) =>
      (db.update(db.notas)..where((n) => n.id.equals(id))).write(NotasCompanion(
        titulo: titulo == null ? const Value.absent() : Value(titulo),
        texto: texto == null ? const Value.absent() : Value(texto),
        itens: itens == null ? const Value.absent() : Value(gravarItens(itens)),
        pastaId: pastaId,
        fixada: fixada == null ? const Value.absent() : Value(fixada),
        atualizadoEm: Value(DateTime.now()),
      ));

  /// Manda para a lixeira (some da lista). Os anexos ficam até a limpeza da
  /// sincronização ([limparApagadas]), para o "Desfazer" trazer tudo de volta.
  Future<void> apagarNota(String id) {
    final agora = DateTime.now();
    return (db.update(db.notas)..where((n) => n.id.equals(id)))
        .write(NotasCompanion(apagadoEm: Value(agora), atualizadoEm: Value(agora)));
  }

  Future<void> desfazerApagar(String id) => (db.update(db.notas)..where((n) => n.id.equals(id)))
      .write(NotasCompanion(apagadoEm: const Value(null), atualizadoEm: Value(DateTime.now())));

  /// Nota criada e largada em branco: some sem perguntar.
  Future<bool> descartarSeVazia(String id) async {
    final n = await nota(id);
    if (n == null || !n.vazia) return false;
    await apagarNota(id);
    return true;
  }

  // ---------- pastas ----------

  Future<String> criarPasta(String nome) async {
    final ordem = await db.select(db.pastasNotas).get().then((l) => l.length);
    return (await db.into(db.pastasNotas)
            .insertReturning(PastasNotasCompanion.insert(nome: nome.trim(), ordem: Value(ordem))))
        .id;
  }

  Future<void> renomearPasta(String id, String nome) => (db.update(db.pastasNotas)..where((p) => p.id.equals(id)))
      .write(PastasNotasCompanion(nome: Value(nome.trim()), atualizadoEm: Value(DateTime.now())));

  /// Apaga a pasta; as notas dela continuam, sem pasta.
  Future<void> apagarPasta(String id) => db.transaction(() async {
        final agora = DateTime.now();
        await (db.update(db.notas)..where((n) => n.pastaId.equals(id)))
            .write(NotasCompanion(pastaId: const Value(null), atualizadoEm: Value(agora)));
        await (db.update(db.pastasNotas)..where((p) => p.id.equals(id)))
            .write(PastasNotasCompanion(apagadoEm: Value(agora), atualizadoEm: Value(agora)));
      });

  // ---------- anexos ----------

  Future<int> _proximaOrdem(String notaId) async =>
      (await (db.select(db.anexosNota)..where((a) => a.notaId.equals(notaId))).get()).length;

  Future<void> _tocarNota(String notaId) => (db.update(db.notas)..where((n) => n.id.equals(notaId)))
      .write(NotasCompanion(atualizadoEm: Value(DateTime.now())));

  /// Foto comprimida (sem metadados, 1080 px) como no Shape.
  Future<AnexoNota> adicionarFoto(String notaId, Uint8List bytes) async {
    final foto = await comprimirFoto(bytes);
    final linha = await db.into(db.anexosNota).insertReturning(AnexosNotaCompanion.insert(
          notaId: notaId,
          tipo: 'foto',
          hash: Value(foto.hash),
          ordem: Value(await _proximaOrdem(notaId)),
        ));
    await cofreFotos.guardar(linha.id, foto);
    if (await cofreFotos.modo() == ModoFotos.nuvem) await cofreFotos.marcarParaEnviar(linha.id);
    await _tocarNota(notaId);
    return linha;
  }

  Future<AnexoNota> adicionarAudio(String notaId, AudioGravado audio) async {
    final linha = await db.into(db.anexosNota).insertReturning(AnexosNotaCompanion.insert(
          notaId: notaId,
          tipo: 'audio',
          formato: Value(audio.formato),
          duracaoMs: Value(audio.duracao.inMilliseconds),
          onda: Value(audio.onda),
          ordem: Value(await _proximaOrdem(notaId)),
        ));
    final hash = await cofreAudios.guardar(linha.id, audio.formato, audio.bytes);
    await (db.update(db.anexosNota)..where((a) => a.id.equals(linha.id))).write(AnexosNotaCompanion(hash: Value(hash)));
    if (await cofreFotos.modo() == ModoFotos.nuvem) await cofreAudios.marcarParaEnviar(linha.id);
    await _tocarNota(notaId);
    return linha.copyWith(hash: Value(hash));
  }

  Future<void> apagarAnexo(AnexoNota a) async {
    final agora = DateTime.now();
    await (db.update(db.anexosNota)..where((x) => x.id.equals(a.id)))
        .write(AnexosNotaCompanion(apagadoEm: Value(agora), atualizadoEm: Value(agora)));
    await _apagarArquivos(a);
    await _tocarNota(a.notaId);
  }

  Future<void> _apagarArquivos(AnexoNota a) async {
    if (a.ehFoto) {
      await cofreFotos.apagarLocal(a.id);
      await cofreFotos.esquecerEnvio(a.id);
      if (a.naNuvem) await cofreFotos.apagarDaNuvem(a.id);
    } else {
      final formato = a.formato ?? 'audio/wav';
      await cofreAudios.apagarLocal(a.id, formato);
      await cofreAudios.esquecerEnvio(a.id);
      if (a.naNuvem) await cofreAudios.apagarDaNuvem(a.id, formato);
    }
  }

  /// "Enviar para a nuvem" de um anexo (vale também no modo só no aparelho).
  Future<void> enviarParaNuvem(AnexoNota a) async {
    if (a.ehFoto) {
      await cofreFotos.enviarAgora(a.refFoto);
    } else {
      await cofreAudios.enviarAgora(a.refAudio);
    }
    await (db.update(db.anexosNota)..where((x) => x.id.equals(a.id)))
        .write(AnexosNotaCompanion(naNuvem: const Value(true), atualizadoEm: Value(DateTime.now())));
  }

  /// Transcreve o áudio (precisa de conta e internet) e guarda o texto. Lança
  /// [ErroIa] ou [StateError] com a mensagem para a pessoa.
  Future<String> transcrever(AnexoNota a) async {
    final transcrever = _transcrever();
    if (transcrever == null) throw StateError('Para transcrever, entre na sua conta (em Conta).');
    final bytes = await cofreAudios.ler(a.refAudio);
    if (bytes == null) throw StateError('O áudio não está neste aparelho.');
    final texto = await transcrever(bytes, a.formato ?? 'audio/wav');
    await (db.update(db.anexosNota)..where((x) => x.id.equals(a.id)))
        .write(AnexosNotaCompanion(transcricao: Value(texto), atualizadoEm: Value(DateTime.now())));
    return texto;
  }

  /// Transcreve sem lançar erro (logo depois de gravar). Devolve a mensagem do
  /// problema, se houve.
  Future<String?> tentarTranscrever(AnexoNota a) async {
    try {
      await transcrever(a);
      return null;
    } on ErroIa catch (e) {
      return e.semConexao ? 'Sem internet: a transcrição fica para depois.' : e.mensagem;
    } on StateError catch (e) {
      return e.message;
    } catch (e) {
      debugPrint('Anotações: transcrição falhou: $e');
      return 'Não deu para transcrever agora.';
    }
  }

  // ---------- sincronização dos arquivos ----------

  /// Fotos das notas ativas (para a sincronização das fotos e o cache).
  Future<List<AnexoNota>> fotosAtivas() =>
      (db.select(db.anexosNota)..where((a) => a.apagadoEm.isNull() & a.tipo.equals('foto'))).get();

  Future<List<AnexoNota>> audiosAtivos() =>
      (db.select(db.anexosNota)..where((a) => a.apagadoEm.isNull() & a.tipo.equals('audio'))).get();

  /// Anexos de notas apagadas há mais de um dia saem de vez (aqui e na nuvem).
  Future<void> limparApagadas() async {
    final limite = DateTime.now().subtract(const Duration(days: 1));
    final apagadas = await (db.select(db.notas)
          ..where((n) => n.apagadoEm.isNotNull() & n.apagadoEm.isSmallerThanValue(limite)))
        .get();
    if (apagadas.isEmpty) return;
    final anexos = await (db.select(db.anexosNota)
          ..where((a) => a.apagadoEm.isNull() & a.notaId.isIn([for (final n in apagadas) n.id])))
        .get();
    for (final a in anexos) {
      await apagarAnexo(a);
    }
  }

  /// Áudios: exclusões e envios pendentes, e arquivos que sobraram. Fotos vão
  /// pelo SincronizadorFotos (o mesmo cofre do Shape).
  Future<({int enviados, int apagados})> sincronizarAudios() async {
    await limparApagadas();
    final armazem = cofreAudios.armazem;
    var enviados = 0, apagados = 0;
    if (armazem != null) {
      final apagar = await cofreAudios.pendentesApagar();
      if (apagar.isNotEmpty) {
        await armazem.apagar(apagar);
        for (final a in apagar) {
          await cofreAudios.apagamentoFeito(a.id);
        }
        apagados = apagar.length;
      }
      final ativos = {for (final a in await audiosAtivos()) a.id: a};
      for (final id in await cofreAudios.pendentesEnviar()) {
        final a = ativos[id];
        if (a == null) {
          await cofreAudios.esquecerEnvio(id);
          continue;
        }
        try {
          await enviarParaNuvem(a);
          enviados++;
        } on StateError catch (e) {
          debugPrint('Áudios: não enviei $id: ${e.message}');
          await cofreAudios.esquecerEnvio(id);
        }
      }
    }
    await cofreAudios.limparSobras({for (final a in await audiosAtivos()) a.id});
    return (enviados: enviados, apagados: apagados);
  }
}
