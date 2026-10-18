import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../core/comandos.dart' show normalizar;

/// Fonte do catálogo, mostrada no app.
const fonteTaco = 'Tabela Brasileira de Composição de Alimentos (TACO), 4ª ed., NEPA/Unicamp, 2011';

/// Um alimento da TACO (valores por 100 g).
class ItemCatalogo {
  const ItemCatalogo({
    required this.codigo,
    required this.nome,
    required this.grupo,
    required this.kcal,
    required this.proteina,
    required this.carboidrato,
    required this.gordura,
    this.porcaoNome,
    this.porcaoGramas,
  });

  /// Unidade com peso médio aproximado ("1 ovo" = 50 g), quando faz sentido.
  final String? porcaoNome;
  final double? porcaoGramas;

  final int codigo;
  final String nome;
  final String grupo;
  final double kcal;
  final double proteina;
  final double carboidrato;
  final double gordura;

  factory ItemCatalogo.json(Map<String, dynamic> j) => ItemCatalogo(
        codigo: j['c'] as int,
        nome: j['n'] as String,
        grupo: j['g'] as String,
        kcal: (j['k'] as num).toDouble(),
        proteina: (j['p'] as num).toDouble(),
        carboidrato: (j['cb'] as num).toDouble(),
        gordura: (j['l'] as num).toDouble(),
        porcaoNome: j['u'] as String?,
        porcaoGramas: (j['ug'] as num?)?.toDouble(),
      );
}

/// Palavras de busca: sem acento, sem plural simples e sem "de/da/do/com".
/// "ovos cozidos" → [ovo, cozido]; "pães" → [pao].
List<String> palavrasBusca(String texto) => [
      for (final p in normalizar(texto).split(RegExp(r'[^a-z0-9]+')))
        if (p.length > 1 && !const {'de', 'da', 'do', 'das', 'dos', 'com', 'em', 'e'}.contains(p))
          p.endsWith('oes') || p.endsWith('aes')
              ? '${p.substring(0, p.length - 3)}ao'
              : (p.endsWith('s') && p.length > 3 ? p.substring(0, p.length - 1) : p),
    ];

/// Cada palavra buscada começa alguma palavra do nome (ou o contrário).
bool casaBusca(List<String> buscadas, List<String> doNome) =>
    buscadas.isNotEmpty && buscadas.every((b) => doNome.any((p) => p.startsWith(b) || b.startsWith(p)));

/// O catálogo, carregado uma vez do asset do app.
class CatalogoTaco {
  CatalogoTaco._(this.itens) : _palavras = [for (final i in itens) palavrasBusca(i.nome)];

  final List<ItemCatalogo> itens;
  final List<List<String>> _palavras;

  static CatalogoTaco? _carregado;

  static Future<CatalogoTaco> carregar() async =>
      _carregado ??= deTexto(await rootBundle.loadString('assets/taco.json'));

  /// Para testes (lê o JSON direto).
  static CatalogoTaco deTexto(String json) {
    final dados = jsonDecode(json) as Map<String, dynamic>;
    return CatalogoTaco._([
      for (final j in dados['alimentos'] as List) ItemCatalogo.json(j as Map<String, dynamic>),
    ]);
  }

  /// Itens que casam com [texto], os de nome mais curto primeiro (os mais
  /// "genéricos": "Ovo, de galinha, inteiro, cozido" antes das variações).
  List<ItemCatalogo> buscar(String texto, {int limite = 8}) {
    final buscadas = palavrasBusca(texto);
    if (buscadas.isEmpty) return const [];
    final achados = [
      for (var i = 0; i < itens.length; i++)
        if (casaBusca(buscadas, _palavras[i])) itens[i],
    ]..sort((a, b) => a.nome.length.compareTo(b.nome.length));
    return achados.take(limite).toList();
  }

  ItemCatalogo? porCodigo(int codigo) => itens.where((i) => i.codigo == codigo).firstOrNull;
}
