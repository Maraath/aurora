import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Fora da web o próprio Flutter já recebe o safe-area do sistema.
EdgeInsets areaSeguraDoNavegador() => EdgeInsets.zero;

final Listenable avisoAreaSegura = ValueNotifier<int>(0);

void definirCorDaBorda(Color cor) {}

String? medidasDaTela() => null;
