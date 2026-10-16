import 'dart:async';

import 'package:flutter/foundation.dart';

/// Timer de foco (25 min). Fica fora da tela para não zerar ao trocar de aba.
class ControleFoco extends ChangeNotifier {
  ControleFoco._();
  static final instancia = ControleFoco._();

  static const duracao = Duration(minutes: 25);

  int indice = 0;
  Duration restante = duracao;
  Timer? _timer;

  bool get focando => _timer != null;

  void alternar() {
    if (focando) {
      _parar();
    } else {
      restante = duracao;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        restante -= const Duration(seconds: 1);
        if (restante <= Duration.zero) _parar();
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void proximo() {
    _parar();
    indice++;
    notifyListeners();
  }

  void _parar() {
    _timer?.cancel();
    _timer = null;
    restante = duracao;
  }

  String get rotulo {
    if (!focando) return 'Começar foco';
    final m = restante.inMinutes.toString().padLeft(2, '0');
    final s = (restante.inSeconds % 60).toString().padLeft(2, '0');
    return 'Focando · $m:$s';
  }
}
