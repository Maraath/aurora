/// Converte a TACO (4ª edição, NEPA/Unicamp) para assets/taco.json.
///
/// Uso: extrair docs/taco/Taco-4a-Edicao.xlsx (é um zip) numa pasta e rodar
///   `dart run tool/taco/converter.dart <pasta-extraida>`
///
/// Aba 1 ("CMVCol taco3"): A = número, B = descrição, D = energia (kcal),
/// F = proteína, G = lipídeos, I = carboidrato, J = fibra (g por 100 g).
/// "Tr" (traço) e "NA" (não aplicável) viram 0; sem energia, o item é pulado.
library;

import 'dart:convert';
import 'dart:io';

import 'ler_xlsx.dart';

// ---------------------------------------------------------------- itens crus
//
// A TACO traz muitos alimentos "crus" que ninguém come assim (é a análise de
// laboratório). Para montar dieta:
//  1. carnes, pescados e ovos crus saem;
//  2. saem os crus que têm versão preparada na tabela (arroz cru → fica o cozido);
//  3. os comidos crus ficam sem o sufixo: frutas e castanhas sempre (mesmo com
//     "suco" na tabela), saladas, e as verduras de salada que também têm versão cozida;
//  4. os que só existem crus mas se cozinham antes de comer ficam como "peso cru"
//     (sem eles o app não teria macarrão; sem o aviso, as calorias enganariam).

final _sufixoCru = RegExp(r', (cru|crua|crus|cruas)$');
const _gruposSemCru = {'Carnes e derivados', 'Pescados e frutos do mar', 'Ovos e derivados'};

/// Fruta e castanha se comem cruas, mesmo havendo "suco" ou "ralado" na tabela.
const _gruposComidosCrus = {'Frutas e derivados', 'Nozes e sementes'};
const _salada = ['Cenoura', 'Beterraba', 'Repolho', 'Couve,', 'Almeirão', 'Espinafre'];
const _pesoCru = ['Macarrão', 'Canjica', 'Grão-de-bico', 'Guandu', 'Milho, verde'];

String _base(String nome) => nome.substring(0, nome.lastIndexOf(','));

String ajustarCrus(List<Map<String, Object>> itens) {
  // Bases que têm alguma versão não crua (cozida, assada, torrada, suco...).
  final preparadas = {
    for (final i in itens)
      if (!_sufixoCru.hasMatch(i['n'] as String) && (i['n'] as String).contains(','))
        _base(i['n'] as String),
  };
  final removidos = <String>[], semSufixo = <String>[], pesoCru = <String>[];
  // "cru" no meio do nome ("Macarrão, trigo, cru, com ovos") vai para o fim.
  for (final i in itens) {
    final nome = i['n'] as String;
    if (nome.contains(', cru, ')) i['n'] = '${nome.replaceFirst(', cru, ', ', ')}, cru';
  }
  itens.removeWhere((i) {
    final nome = i['n'] as String;
    if (!_sufixoCru.hasMatch(nome)) return false;
    final base = nome.replaceFirst(_sufixoCru, '');
    if (_gruposSemCru.contains(i['g'])) {
      removidos.add(nome);
      return true;
    }
    if (_pesoCru.any(base.startsWith)) {
      i['n'] = '$base, peso cru';
      pesoCru.add(nome);
      return false;
    }
    if (preparadas.contains(base) && !_gruposComidosCrus.contains(i['g']) && !_salada.any(base.startsWith)) {
      removidos.add(nome);
      return true;
    }
    i['n'] = base;
    semSufixo.add(nome);
    return false;
  });
  final nomes = itens.map((i) => i['n']).toList();
  final repetidos = nomes.where((n) => nomes.where((m) => m == n).length > 1).toSet();
  return [
    'Crus: ${removidos.length} removidos, ${semSufixo.length} sem o sufixo, ${pesoCru.length} como "peso cru".',
    'Removidos fora de carnes/pescados/ovos: '
        '${removidos.where((n) => !n.startsWith('Frango') && !n.startsWith('Carne') && !n.startsWith('Porco')).join(' | ')}',
    'Peso cru: ${pesoCru.join(' | ')}',
    if (repetidos.isNotEmpty) 'ATENÇÃO, nomes repetidos: ${repetidos.join(' | ')}',
  ].join('\n');
}

// ------------------------------------------------------------- por unidade
//
// A TACO dá valores por 100 g; ninguém pesa um ovo. Pesos MÉDIOS aproximados
// de uma unidade (medidas caseiras usuais), aplicados a quem começa com o
// prefixo. São pontos de partida: no app a pessoa ajusta o peso da unidade.

const _unidades = <(String, String, double)>[
  ('Ovo, de galinha, inteiro', '1 ovo', 50),
  ('Ovo, de galinha, clara', '1 clara', 30),
  ('Ovo, de galinha, gema', '1 gema', 17),
  ('Banana, prata', '1 banana', 70),
  ('Banana, nanica', '1 banana', 100),
  ('Banana, maçã', '1 banana', 65),
  ('Banana, ouro', '1 banana', 40),
  ('Banana, da terra', '1 banana', 140),
  ('Banana, pacova', '1 banana', 120),
  ('Maçã', '1 maçã', 130),
  ('Pêra', '1 pera', 130),
  ('Pêssego, Aurora', '1 pêssego', 110),
  ('Kiwi', '1 kiwi', 75),
  ('Caqui', '1 caqui', 110),
  ('Goiaba, branca', '1 goiaba', 170),
  ('Goiaba, vermelha', '1 goiaba', 170),
  ('Manga, Haden', '1 manga', 300),
  ('Manga, Palmer', '1 manga', 300),
  ('Manga, Tommy Atkins', '1 manga', 300),
  ('Mamão, Papaia', '1/2 mamão', 150),
  ('Ameixa', '1 ameixa', 45),
  ('Figo', '1 figo', 50),
  ('Carambola', '1 carambola', 130),
  ('Morango', '1 morango', 12),
  ('Uva, Itália', '1 uva', 8),
  ('Uva, Rubi', '1 uva', 8),
  ('Acerola', '1 acerola', 12),
  ('Jabuticaba', '1 jabuticaba', 6),
  ('Caju', '1 caju', 100),
  ('Nêspera', '1 nêspera', 30),
  ('Limão, tahiti', '1 limão', 65),
  ('Maracujá', '1 maracujá (polpa)', 50),
  ('Pão, trigo, francês', '1 pão', 50),
  ('Pão, trigo, forma', '1 fatia', 25),
  ('Pão, aveia, forma', '1 fatia', 25),
  ('Pão, glúten, forma', '1 fatia', 25),
  ('Pão, milho, forma', '1 fatia', 25),
  ('Pão, de soja', '1 fatia', 25),
  ('Pão, de queijo, assado', '1 pão de queijo', 20),
  ('Biscoito, doce, maisena', '1 biscoito', 5),
  ('Biscoito, doce, recheado', '1 biscoito', 15),
  ('Biscoito, salgado, cream cracker', '1 biscoito', 6),
  ('Coxinha de frango', '1 coxinha', 80),
  ('Empada', '1 empada', 45),
  ('Hambúrguer, bovino', '1 hambúrguer', 56),
  ('Queijo, minas, frescal', '1 fatia', 30),
  ('Queijo, minas, meia cura', '1 fatia', 20),
  ('Iogurte, natural', '1 pote', 170),
];

/// Laranjas e tangerinas: vários nomes, mesma unidade (os sucos ficam de fora).
(String, double)? _unidadeDe(String nome) {
  // Sucos, polpas e doces de fruta (em calda, em pasta, cascão) não vêm por unidade.
  if (RegExp(r'suco|polpa|calda|doce em|doce, cascão').hasMatch(nome)) return null;
  if (nome.startsWith('Laranja')) return ('1 laranja', 140);
  if (nome.startsWith('Tangerina')) return ('1 tangerina', 135);
  if (nome.startsWith('Mexerica')) return ('1 mexerica', 110);
  for (final (prefixo, unidade, gramas) in _unidades) {
    if (nome.startsWith(prefixo)) return (unidade, gramas);
  }
  return null;
}

String adicionarUnidades(List<Map<String, Object>> itens) {
  final com = <String>[];
  for (final i in itens) {
    final u = _unidadeDe(i['n'] as String);
    if (u == null) continue;
    i['u'] = u.$1;
    i['ug'] = u.$2;
    com.add('${i['n']} = ${u.$1} (${u.$2.round()} g)');
  }
  return 'Com unidade: ${com.length}\n  ${com.join('\n  ')}';
}

void main(List<String> args) {
  final linhas = lerAba(args.first, 1);
  String cel(List<String> l, int i) => i < l.length ? l[i].trim() : '';
  double? num_(String s) => s == 'Tr' || s == 'NA' || s == '*' || s.isEmpty ? null : double.tryParse(s);
  double um(double v) => (v * 10).roundToDouble() / 10;

  var grupo = '';
  final itens = <Map<String, Object>>[];
  final vistos = <int>{};
  var pulados = 0;
  for (final l in linhas) {
    final a = cel(l, 0), b = cel(l, 1);
    final codigo = int.tryParse(a);
    if (codigo == null) {
      // Linha de grupo: texto na coluna A e o resto vazio.
      // A planilha repete o cabeçalho ("Número do / Alimento") a cada página: não é grupo.
      final cabecalho = a.startsWith('Número') || a == 'Alimento' || b.startsWith('Descrição');
      if (a.isNotEmpty && b.isEmpty && !cabecalho && !a.startsWith('†') && a.length < 60) grupo = a;
      continue;
    }
    if (b.isEmpty || !vistos.add(codigo)) continue;
    final kcal = num_(cel(l, 3));
    if (kcal == null) {
      pulados++;
      continue;
    }
    itens.add({
      'c': codigo,
      'n': b.replaceAll(RegExp(r'\s+'), ' '),
      'g': grupo,
      'k': kcal.roundToDouble(),
      'p': um(num_(cel(l, 5)) ?? 0),
      'l': um(num_(cel(l, 6)) ?? 0),
      'cb': um(num_(cel(l, 8)) ?? 0),
      'f': um(num_(cel(l, 9)) ?? 0),
    });
  }

  final relatorio = '${ajustarCrus(itens)}\n${adicionarUnidades(itens)}';

  final saida = File('assets/taco.json');
  saida.createSync(recursive: true);
  saida.writeAsStringSync(jsonEncode({
    'fonte': 'Tabela Brasileira de Composição de Alimentos (TACO), 4ª edição revisada e ampliada, '
        'NEPA/Unicamp, 2011',
    'alimentos': itens,
  }));
  final grupos = itens.map((i) => i['g']).toSet();
  stdout.writeln('${itens.length} alimentos em ${grupos.length} grupos; $pulados sem energia pulados.');
  stdout.writeln(relatorio);
  stdout.writeln('grupos: ${grupos.join(' | ')}');
  for (final i in [itens.first, itens[itens.length ~/ 2], itens.last]) {
    stdout.writeln(i);
  }
}
