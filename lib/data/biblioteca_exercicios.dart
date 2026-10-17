import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../core/comandos.dart' show normalizar;
import '../core/nuvem.dart';
import 'catalogo_taco.dart' show casaBusca, palavrasBusca;

/// Um exercício da biblioteca (lista em assets/exercicios.json; a animação
/// fica no Supabase Storage e é baixada na primeira vez que se abre).
class ItemExercicio {
  const ItemExercicio({
    required this.id,
    required this.nome,
    required this.grupo,
    required this.arquivo,
    required this.kb,
  });

  final String id;
  final String nome;
  final String grupo;

  /// Nome do arquivo WebP no balde "exercicios" (vai em Exercicios.midia).
  final String arquivo;
  final int kb;

  factory ItemExercicio.json(Map<String, dynamic> j) => ItemExercicio(
        id: j['id'] as String,
        nome: j['n'] as String,
        grupo: j['g'] as String,
        arquivo: j['a'] as String,
        kb: (j['kb'] as num).toInt(),
      );
}

class BibliotecaExercicios {
  BibliotecaExercicios._(this.itens) : _palavras = [for (final i in itens) palavrasBusca(i.nome)];

  final List<ItemExercicio> itens;
  final List<List<String>> _palavras;

  static BibliotecaExercicios? _carregada;

  static Future<BibliotecaExercicios> carregar() async =>
      _carregada ??= deTexto(await rootBundle.loadString('assets/exercicios.json'));

  static BibliotecaExercicios deTexto(String json) {
    final dados = jsonDecode(json) as Map<String, dynamic>;
    return BibliotecaExercicios._([
      for (final j in dados['exercicios'] as List) ItemExercicio.json(j as Map<String, dynamic>),
    ]);
  }

  /// Grupos musculares em ordem alfabética.
  List<String> get grupos => (itens.map((i) => i.grupo).toSet().toList()..sort());

  /// Busca por palavras (sem acento, sem plural), opcionalmente num [grupo].
  List<ItemExercicio> buscar(String texto, {String? grupo, int limite = 60}) {
    final buscadas = palavrasBusca(texto);
    final achados = [
      for (var i = 0; i < itens.length; i++)
        if ((grupo == null || itens[i].grupo == grupo) && (buscadas.isEmpty || casaBusca(buscadas, _palavras[i])))
          itens[i],
    ]..sort((a, b) => a.nome.length.compareTo(b.nome.length));
    return achados.take(limite).toList();
  }

  /// Exercício com o mesmo nome (sem acento/maiúscula), para ligar os antigos.
  ItemExercicio? porNome(String nome) {
    final alvo = normalizar(nome.trim());
    return itens.where((i) => normalizar(i.nome) == alvo).firstOrNull;
  }

  ItemExercicio? porArquivo(String arquivo) => itens.where((i) => i.arquivo == arquivo).firstOrNull;
}

/// Pasta das animações no balde "exercicios". Se as animações forem
/// regeradas com outro formato, enviar numa pasta nova (ex.: "v2") e trocar
/// aqui: as cópias antigas guardadas nos aparelhos não se misturam.
const pastaAnimacoes = 'exercicios_webp';

/// URL pública da animação no balde "exercicios".
String urlAnimacao(String arquivo) =>
    '$supabaseUrl/storage/v1/object/public/exercicios/$pastaAnimacoes/$arquivo';

/// A animação no aparelho: baixa na primeira vez e depois usa a cópia local
/// (funciona offline). Nulo se não der para baixar agora.
Future<File?> animacaoExercicio(String arquivo) async {
  try {
    final pasta = Directory('${(await getApplicationSupportDirectory()).path}/exercicios/$pastaAnimacoes');
    final arquivoLocal = File('${pasta.path}/$arquivo');
    if (await arquivoLocal.exists() && await arquivoLocal.length() > 0) return arquivoLocal;
    final r = await http.get(Uri.parse(urlAnimacao(arquivo))).timeout(const Duration(seconds: 30));
    if (r.statusCode != 200) return null;
    await pasta.create(recursive: true);
    // Grava num temporário e renomeia: um download interrompido não vira arquivo quebrado.
    final temp = File('${arquivoLocal.path}.parcial');
    await temp.writeAsBytes(r.bodyBytes, flush: true);
    return await temp.rename(arquivoLocal.path);
  } catch (e) {
    debugPrint('Animação $arquivo indisponível: $e');
    return null;
  }
}
