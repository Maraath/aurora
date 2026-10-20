import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// `auroraAreaSegura()` do web/index.html: [cima, direita, baixo, esquerda] em px CSS.
@JS('auroraAreaSegura')
external JSArray<JSNumber>? _medir();

EdgeInsets areaSeguraDoNavegador() {
  try {
    final v = _medir()?.toDart.map((n) => n.toDartDouble).toList();
    if (v == null || v.length != 4) return EdgeInsets.zero;
    return EdgeInsets.fromLTRB(v[3], v[0], v[1], v[2]);
  } catch (_) {
    return EdgeInsets.zero; // index.html antigo (sem a função)
  }
}

@JS('auroraCorDaBorda')
external void _corDaBorda(JSString cor);

@JS('auroraMedidasDaTela')
external JSString _medidas();

/// Cor do fundo da página: aparece na faixa de baixo que o iOS não deixa o app
/// desenhar (app na tela de início). A barra de baixo manda a cor dela.
void definirCorDaBorda(Color cor) {
  int canal(double v) => (v * 255).round().clamp(0, 255);
  try {
    _corDaBorda('rgb(${canal(cor.r)}, ${canal(cor.g)}, ${canal(cor.b)})'.toJS);
  } catch (_) {
    // index.html antigo
  }
}

/// Medidas da tela e margens do sistema, para o diagnóstico em Conta.
String? medidasDaTela() {
  try {
    return _medidas().toDart;
  } catch (_) {
    return null;
  }
}

/// Muda quando o index.html avisa (`auroraAreaMudou`): o iOS pode informar o
/// safe-area só depois da 1ª montagem, e girar a tela troca os lados.
final _mudou = ValueNotifier<int>(0);
var _ligado = false;

Listenable get avisoAreaSegura {
  if (!_ligado) {
    _ligado = true;
    try {
      globalContext.setProperty('auroraAreaMudou'.toJS, (() => _mudou.value++).toJS);
    } catch (_) {
      // sem window (não acontece no navegador)
    }
  }
  return _mudou;
}
