import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../core/relogio.dart';
import 'banco.dart';
import 'fotos/cofre.dart';
import 'fotos/compressao.dart';
import 'observar.dart';

enum AnguloShape {
  frente('Frente'),
  costas('Costas'),
  lado('Lado');

  const AnguloShape(this.rotulo);
  final String rotulo;

  static AnguloShape? de(String nome) => values.where((a) => a.name == nome).firstOrNull;
}

/// As fotos de um dia ("Check-in de 17 de outubro").
class CheckinShape {
  const CheckinShape(this.dia, this.fotos);

  /// "aaaa-mm-dd" no fuso do aparelho.
  final String dia;
  final Map<AnguloShape, FotoShape> fotos;

  DateTime get data => DateTime.parse(dia);
}

extension RefFotoShape on FotoShape {
  RefFoto get ref => (id: id, hash: hash, naNuvem: naNuvem);
}

/// Fotos do Shape. As imagens passam pelo [CofreFotos] (compressão, cópia no
/// aparelho, nuvem); aqui ficam as linhas de `fotos_shape`, que sempre
/// sincronizam (os outros aparelhos mostram "Foto guardada em outro aparelho"
/// quando a imagem não foi para a nuvem).
class ShapeRepo {
  ShapeRepo(this.db, {CofreFotos? cofre}) : cofre = cofre ?? CofreFotos(db);
  final BancoAurora db;
  final CofreFotos cofre;

  /// Check-ins, do mais recente para o mais antigo.
  Stream<List<CheckinShape>> observarCheckins() => observar(db, [db.fotosShape], carregar);

  Future<List<CheckinShape>> carregar() async {
    final porDia = <String, Map<AnguloShape, FotoShape>>{};
    for (final f in await fotosAtivas()) {
      final a = AnguloShape.de(f.angulo);
      if (a != null) (porDia[f.dia] ??= {})[a] = f;
    }
    return [for (final e in porDia.entries) CheckinShape(e.key, e.value)];
  }

  Future<List<FotoShape>> fotosAtivas() =>
      (db.select(db.fotosShape)
            ..where((f) => f.apagadoEm.isNull())
            ..orderBy([(f) => OrderingTerm(expression: f.dia, mode: OrderingMode.desc)]))
          .get();

  /// Guarda a foto de [angulo] no dia [dia] (data no fuso do aparelho); se já havia
  /// uma, é trocada (mesmo id, hash novo). No modo "Sincronizar", fica marcada
  /// para subir na próxima sincronização.
  Future<void> salvarFoto(DateTime dia, AnguloShape angulo, Uint8List bytes) async {
    final foto = await comprimirFoto(bytes);
    final chave = chaveData(dia);
    final id = idNatural('foto_shape', [chave, angulo.name]);
    final antiga = await _foto(id);
    await cofre.guardar(id, foto);
    await db
        .into(db.fotosShape)
        .insert(
          FotosShapeCompanion.insert(
            id: Value(id),
            dia: chave,
            angulo: angulo.name,
            arquivo: '$id.webp',
            hash: Value(foto.hash),
          ),
          onConflict: DoUpdate(
            (_) => FotosShapeCompanion(
              arquivo: Value('$id.webp'),
              hash: Value(foto.hash),
              naNuvem: const Value(false),
              apagadoEm: const Value(null),
              atualizadoEm: Value(DateTime.now()),
            ),
            target: [db.fotosShape.dia, db.fotosShape.angulo],
          ),
        );
    if (await cofre.modo() == ModoFotos.nuvem) {
      await cofre.marcarParaEnviar(id);
    } else if (antiga != null && antiga.apagadoEm == null && antiga.naNuvem) {
      // A versão antiga ficou na nuvem; neste modo a nova não sobe, então a
      // antiga sai de lá para não mostrar foto desatualizada nos outros aparelhos.
      await cofre.apagarDaNuvem(id);
    }
  }

  /// Apaga a foto aqui e, se estava na nuvem, de lá também.
  Future<void> apagarFoto(FotoShape foto) async {
    final agora = DateTime.now();
    await (db.update(db.fotosShape)..where((f) => f.id.equals(foto.id))).write(
      FotosShapeCompanion(apagadoEm: Value(agora), atualizadoEm: Value(agora)),
    );
    await cofre.apagarLocal(foto.id);
    await cofre.esquecerEnvio(foto.id);
    if (foto.naNuvem) await cofre.apagarDaNuvem(foto.id);
  }

  /// "Enviar para a nuvem": sobe esta foto agora (vale também no modo "Só
  /// neste aparelho"). Lança o erro se não der (sem login, sem internet).
  Future<void> enviarParaNuvem(FotoShape foto) async {
    await cofre.enviarAgora(foto.ref);
    await _marcarNuvem(foto.id, true);
  }

  /// Tira a foto da nuvem, garantindo antes uma cópia inteira neste aparelho
  /// (senão ela se perderia). Devolve falso se não conseguiu a cópia.
  Future<bool> tirarDaNuvem(FotoShape foto) async {
    if (!foto.naNuvem) return true;
    final inteira = await cofre.obter(foto.ref);
    final mini = await cofre.obter(foto.ref, miniatura: true);
    if (inteira == null || mini == null) return false;
    await cofre.apagarDaNuvem(foto.id);
    await _marcarNuvem(foto.id, false);
    return true;
  }

  /// Fotos com imagem neste aparelho que ainda não estão na nuvem.
  Future<List<FotoShape>> paraEnviar() async => [
    for (final f in await fotosAtivas())
      if (!f.naNuvem && await cofre.local(f.ref) != null) f,
  ];

  Future<void> _marcarNuvem(String id, bool naNuvem) =>
      (db.update(db.fotosShape)..where((f) => f.id.equals(id))).write(
        FotosShapeCompanion(naNuvem: Value(naNuvem), atualizadoEm: Value(DateTime.now())),
      );

  Future<FotoShape?> _foto(String id) => (db.select(db.fotosShape)..where((f) => f.id.equals(id))).getSingleOrNull();

  /// Uma vez por aparelho: fotos de antes da v11 (JPEG de 1600 px em
  /// `<suporte>/shape/<arquivo>`) viram WebP de 1080 px com miniatura, e a
  /// pasta antiga some. Nenhuma estava na nuvem nova.
  Future<void> converterFotosAntigas({Future<Directory> Function()? pastaAntiga}) async {
    if (kIsWeb) return; // fotos antigas só existem nos apps instalados
    final pasta = await (pastaAntiga ?? () async => Directory('${(await getApplicationSupportDirectory()).path}/shape'))();
    if (!await pasta.exists()) return;
    final antigas = await (db.select(db.fotosShape)..where((f) => f.hash.isNull() & f.apagadoEm.isNull())).get();
    for (final f in antigas) {
      final arquivo = File('${pasta.path}/${f.arquivo}');
      if (!await arquivo.exists()) continue; // tirada em outro aparelho
      try {
        final nova = await comprimirFoto(await arquivo.readAsBytes());
        await cofre.guardar(f.id, nova);
        await (db.update(db.fotosShape)..where((l) => l.id.equals(f.id))).write(
          FotosShapeCompanion(
            arquivo: Value('${f.id}.webp'),
            hash: Value(nova.hash),
            naNuvem: const Value(false),
            atualizadoEm: Value(DateTime.now()),
          ),
        );
      } catch (e) {
        debugPrint('Shape: não converti ${f.arquivo}: $e');
        return; // tenta de novo na próxima abertura, sem apagar a pasta antiga
      }
    }
    await pasta.delete(recursive: true);
    await (db.delete(db.preferencias)..where((p) => p.chave.like('shape_enviada:%'))).go();
  }
}
