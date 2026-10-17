/// Leitura mínima de uma planilha .xlsx JÁ EXTRAÍDA (um .xlsx é um zip de XMLs).
library;

import 'dart:convert';
import 'dart:io';

import 'package:xml/xml.dart';

/// Linhas da [aba] (1 = primeira) como listas de texto; coluna A = índice 0.
List<List<String>> lerAba(String pastaExtraida, int aba) {
  String ler(String nome) => utf8.decode(File('$pastaExtraida/$nome').readAsBytesSync());

  final compartilhadas = <String>[];
  final arquivoTextos = File('$pastaExtraida/xl/sharedStrings.xml');
  if (arquivoTextos.existsSync()) {
    for (final si in XmlDocument.parse(ler('xl/sharedStrings.xml')).findAllElements('si')) {
      compartilhadas.add(si.findAllElements('t').map((t) => t.innerText).join());
    }
  }

  final linhas = <List<String>>[];
  for (final row in XmlDocument.parse(ler('xl/worksheets/sheet$aba.xml')).findAllElements('row')) {
    final cels = <String>[];
    for (final c in row.findElements('c')) {
      final col = _coluna(c.getAttribute('r')!.replaceAll(RegExp(r'[0-9]'), ''));
      while (cels.length < col) {
        cels.add('');
      }
      final v = c.findElements('v').firstOrNull?.innerText ??
          c.findAllElements('t').map((t) => t.innerText).join();
      cels.add(c.getAttribute('t') == 's' ? compartilhadas[int.parse(v)] : v);
    }
    linhas.add(cels);
  }
  return linhas;
}

int _coluna(String letras) {
  var n = 0;
  for (final ch in letras.codeUnits) {
    n = n * 26 + (ch - 64);
  }
  return n - 1;
}
