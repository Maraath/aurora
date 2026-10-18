import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Lado maior da foto inteira: nítida para comparar, leve para guardar e
/// sincronizar (~150 a 300 KB em WebP).
const ladoMaximoFoto = 1080;

/// Lado maior da miniatura usada em listas e grades.
const ladoMiniatura = 300;

/// Qualidade do WebP com perda (escala do próprio codificador, 0 a 100).
const qualidadeFoto = 80;
const qualidadeMiniatura = 72;

/// Foto pronta para guardar: inteira, miniatura e o SHA-256 da inteira.
class FotoComprimida {
  const FotoComprimida(this.completa, this.miniatura, this.hash);
  final Uint8List completa;
  final Uint8List miniatura;
  final String hash;
}

/// Gira conforme o EXIF (a foto fica de pé), apaga todos os metadados (GPS,
/// modelo do aparelho, data...), reduz e grava em WebP, nas duas medidas. O
/// WebP sai do pacote `image`, em Dart puro: funciona igual no Windows, no
/// Android e no iOS. Roda fora da linha da interface.
Future<FotoComprimida> comprimirFoto(Uint8List bytes) => compute(_comprimir, bytes);

FotoComprimida _comprimir(Uint8List bytes) {
  final original = img.decodeImage(bytes);
  if (original == null) throw const FormatException('Arquivo não é uma imagem.');
  final dePe = img.bakeOrientation(original);
  final completa = _gravar(_reduzir(dePe, ladoMaximoFoto), qualidadeFoto);
  final miniatura = _gravar(_reduzir(dePe, ladoMiniatura), qualidadeMiniatura);
  return FotoComprimida(completa, miniatura, sha256.convert(completa).toString());
}

img.Image _reduzir(img.Image foto, int lado) {
  final maior = foto.width > foto.height ? foto.width : foto.height;
  if (maior <= lado) return foto.clone();
  return foto.width >= foto.height
      ? img.copyResize(foto, width: lado, interpolation: img.Interpolation.average)
      : img.copyResize(foto, height: lado, interpolation: img.Interpolation.average);
}

Uint8List _gravar(img.Image foto, int qualidade) {
  foto.exif.clear();
  foto.iccProfile = null;
  return img.encodeWebP(foto, lossless: false, quality: qualidade);
}
