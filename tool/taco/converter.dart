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

  final saida = File('assets/taco.json');
  saida.createSync(recursive: true);
  saida.writeAsStringSync(jsonEncode({
    'fonte': 'Tabela Brasileira de Composição de Alimentos (TACO), 4ª edição revisada e ampliada, '
        'NEPA/Unicamp, 2011',
    'alimentos': itens,
  }));
  final grupos = itens.map((i) => i['g']).toSet();
  stdout.writeln('${itens.length} alimentos em ${grupos.length} grupos; $pulados sem energia pulados.');
  stdout.writeln('grupos: ${grupos.join(' | ')}');
  for (final i in [itens.first, itens[itens.length ~/ 2], itens.last]) {
    stdout.writeln(i);
  }
}
