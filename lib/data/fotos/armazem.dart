import 'dart:io' hide BytesBuilder;
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/nuvem.dart';

/// Onde as imagens das fotos ficam na nuvem (Supabase no app, memória nos
/// testes). [id] é o id da foto; cada uma tem a inteira e a miniatura.
abstract class ArmazemFotos {
  Future<void> enviar(String id, {required Uint8List completa, required Uint8List miniatura});

  /// Nulo se não existe lá.
  Future<Uint8List?> baixar(String id, {bool miniatura = false});

  /// Apaga a inteira e a miniatura de cada id (os que não existem são ignorados).
  Future<void> apagar(List<String> ids);
}

/// Balde PRIVADO "fotos" do Supabase. Cada conta só enxerga a própria pasta
/// (políticas em supabase/migrations/20261019140000_fotos_privadas.sql):
///   {user_id}/fotos/{id}.webp       foto inteira
///   {user_id}/miniaturas/{id}.webp  miniatura
/// A leitura é por URL assinada que vale 1 hora, nunca por URL pública.
class ArmazemSupabase implements ArmazemFotos {
  ArmazemSupabase(this.cliente, this.usuarioId);
  final SupabaseClient cliente;
  final String usuarioId;

  static const validadeUrl = Duration(hours: 1);
  static const _tipo = 'image/webp';

  StorageFileApi get _balde => cliente.storage.from('fotos');

  String caminho(String id, {bool miniatura = false}) =>
      '$usuarioId/${miniatura ? 'miniaturas' : 'fotos'}/$id.webp';

  @override
  Future<void> enviar(String id, {required Uint8List completa, required Uint8List miniatura}) async {
    const opcoes = FileOptions(contentType: _tipo, upsert: true, cacheControl: '3600');
    await _balde.uploadBinary(caminho(id, miniatura: true), miniatura, fileOptions: opcoes);
    await _balde.uploadBinary(caminho(id), completa, fileOptions: opcoes);
  }

  @override
  Future<Uint8List?> baixar(String id, {bool miniatura = false}) async {
    final String url;
    try {
      url = await _balde.createSignedUrl(caminho(id, miniatura: miniatura), validadeUrl.inSeconds);
    } on StorageException catch (e) {
      if (e.statusCode == '400' || e.statusCode == '404') return null; // não está lá
      rethrow;
    }
    final http = HttpClient()..connectionTimeout = const Duration(seconds: 15);
    try {
      final resposta = await (await http.getUrl(Uri.parse(url))).close();
      if (resposta.statusCode == 404 || resposta.statusCode == 400) return null;
      if (resposta.statusCode != 200) throw HttpException('Erro ${resposta.statusCode} ao baixar a foto');
      final bytes = BytesBuilder(copy: false);
      await for (final parte in resposta) {
        bytes.add(parte);
      }
      return bytes.takeBytes();
    } finally {
      http.close();
    }
  }

  @override
  Future<void> apagar(List<String> ids) async {
    if (ids.isEmpty) return;
    await _balde.remove([
      for (final id in ids) ...[caminho(id), caminho(id, miniatura: true)],
    ]);
  }
}

/// O armazém da conta conectada agora, ou nulo sem login (ou nos testes).
ArmazemFotos? armazemDaConta() {
  final cliente = nuvem;
  final usuario = cliente?.auth.currentUser;
  if (cliente == null || usuario == null) return null;
  return ArmazemSupabase(cliente, usuario.id);
}
