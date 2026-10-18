import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../core/relogio.dart';
import 'banco.dart';
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

  /// "aaaa-mm-dd" no fuso de São Paulo.
  final String dia;
  final Map<AnguloShape, FotoShape> fotos;

  DateTime get data => DateTime.parse(dia);
}

/// Pasta das fotos no aparelho (fora de Documentos, junto dos outros dados do app).
Future<Directory> pastaShapePadrao() async => Directory('${(await getApplicationSupportDirectory()).path}/shape');

/// Lado maior da foto guardada: nítida para comparar, leve para sincronizar.
const ladoMaximoFoto = 1600;

/// Reduz e regrava em JPEG (já girada conforme o EXIF, que é descartado junto
/// com localização e outros metadados). Roda fora da linha da interface.
Future<Uint8List> comprimirFoto(Uint8List bytes) => compute(_comprimir, bytes);

Uint8List _comprimir(Uint8List bytes) {
  final original = img.decodeImage(bytes);
  if (original == null) throw const FormatException('Arquivo não é uma imagem.');
  var foto = img.bakeOrientation(original);
  final maior = foto.width > foto.height ? foto.width : foto.height;
  if (maior > ladoMaximoFoto) {
    foto = foto.width >= foto.height
        ? img.copyResize(foto, width: ladoMaximoFoto, interpolation: img.Interpolation.average)
        : img.copyResize(foto, height: ladoMaximoFoto, interpolation: img.Interpolation.average);
  }
  foto.exif.clear();
  return img.encodeJpg(foto, quality: 82);
}

class ShapeRepo {
  ShapeRepo(this.db, {Future<Directory> Function()? pasta}) : _pasta = pasta ?? pastaShapePadrao;
  final BancoAurora db;
  final Future<Directory> Function() _pasta;

  static const _uuid = Uuid();

  Future<File> arquivoLocal(String arquivo) async => File('${(await _pasta()).path}/$arquivo');

  /// Check-ins, do mais recente para o mais antigo.
  Stream<List<CheckinShape>> observarCheckins() => observar(db, [db.fotosShape], carregar);

  Future<List<CheckinShape>> carregar() async {
    final linhas =
        await (db.select(db.fotosShape)
              ..where((f) => f.apagadoEm.isNull())
              ..orderBy([(f) => OrderingTerm(expression: f.dia, mode: OrderingMode.desc)]))
            .get();
    final porDia = <String, Map<AnguloShape, FotoShape>>{};
    for (final f in linhas) {
      final a = AnguloShape.de(f.angulo);
      if (a != null) (porDia[f.dia] ??= {})[a] = f;
    }
    return [for (final e in porDia.entries) CheckinShape(e.key, e.value)];
  }

  /// Guarda a foto de [angulo] no dia [dia] (data de São Paulo). Se já havia
  /// uma, é trocada.
  Future<void> salvarFoto(DateTime dia, AnguloShape angulo, Uint8List bytes) async {
    final jpeg = await comprimirFoto(bytes);
    final arquivo = '${_uuid.v4()}.jpg';
    final destino = await arquivoLocal(arquivo);
    await destino.parent.create(recursive: true);
    await destino.writeAsBytes(jpeg, flush: true);

    final chave = chaveData(dia);
    final antiga = await _foto(chave, angulo);
    await db
        .into(db.fotosShape)
        .insert(
          FotosShapeCompanion.insert(
            id: Value(idNatural('foto_shape', [chave, angulo.name])),
            dia: chave,
            angulo: angulo.name,
            arquivo: arquivo,
          ),
          onConflict: DoUpdate(
            (_) => FotosShapeCompanion(
              arquivo: Value(arquivo),
              apagadoEm: const Value(null),
              atualizadoEm: Value(DateTime.now()),
            ),
            target: [db.fotosShape.dia, db.fotosShape.angulo],
          ),
        );
    if (antiga != null) await _apagarArquivo(antiga.arquivo);
  }

  Future<void> apagarFoto(FotoShape foto) async {
    final agora = DateTime.now();
    await (db.update(db.fotosShape)..where((f) => f.id.equals(foto.id))).write(
      FotosShapeCompanion(apagadoEm: Value(agora), atualizadoEm: Value(agora)),
    );
    await _apagarArquivo(foto.arquivo);
  }

  Future<FotoShape?> _foto(String dia, AnguloShape angulo) => (db.select(
    db.fotosShape,
  )..where((f) => f.dia.equals(dia) & f.angulo.equals(angulo.name) & f.apagadoEm.isNull())).getSingleOrNull();

  Future<void> _apagarArquivo(String arquivo) async {
    try {
      final f = await arquivoLocal(arquivo);
      if (await f.exists()) await f.delete();
      await (db.delete(db.preferencias)..where((p) => p.chave.like('shape_enviada:%:$arquivo'))).go();
    } catch (e) {
      debugPrint('Shape: não apaguei $arquivo: $e');
    }
  }

  /// Arquivos que alguma foto ainda usa.
  Future<Set<String>> arquivosEmUso() async {
    final linhas = await (db.select(db.fotosShape)..where((f) => f.apagadoEm.isNull())).get();
    return {for (final f in linhas) f.arquivo};
  }
}
