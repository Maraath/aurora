import 'package:flutter/widgets.dart';

import 'area_segura_stub.dart' if (dart.library.js_interop) 'area_segura_web.dart';

export 'area_segura_stub.dart' if (dart.library.js_interop) 'area_segura_web.dart'
    show definirCorDaBorda, medidasDaTela;

/// Web (PWA no iPhone): o Flutter na web não recebe o safe-area (notch,
/// Dynamic Island, indicador de início) e o MediaQuery fica com padding zero.
/// O index.html mede `env(safe-area-inset-*)` e aqui ele entra no MediaQuery,
/// como num app instalado: o céu vai até a borda e o SafeArea de cada tela
/// (cabeçalho, barra de baixo) desvia do que o sistema cobre.
/// Nos apps instalados não faz nada.
class AreaSeguraWeb extends StatelessWidget {
  const AreaSeguraWeb({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      ListenableBuilder(listenable: avisoAreaSegura, builder: (context, _) => _comArea(context));

  Widget _comArea(BuildContext context) {
    final mq = MediaQuery.of(context);
    final area = areaSeguraDoNavegador();
    if (area == EdgeInsets.zero || mq.viewPadding != EdgeInsets.zero) return child;
    // Com o teclado aberto o indicador de início fica atrás dele: a margem de baixo some.
    final padding = EdgeInsets.fromLTRB(
      area.left,
      area.top,
      area.right,
      (area.bottom - mq.viewInsets.bottom).clamp(0.0, area.bottom),
    );
    return MediaQuery(data: mq.copyWith(padding: padding, viewPadding: area), child: child);
  }
}
