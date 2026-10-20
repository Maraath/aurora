import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/tema.dart';
import 'data/banco.dart';
import 'ui/barra_rolagem.dart';
import 'ui/bloqueio_ui.dart';
import 'ui/janela/moldura_janela.dart';
import 'ui/shell.dart';

/// Dá acesso ao banco e ao tema em qualquer tela: `AuroraEscopo.de(context)`.
class AuroraEscopo extends InheritedWidget {
  const AuroraEscopo({
    super.key,
    required this.db,
    required this.escuro,
    required super.child,
  });

  final BancoAurora db;
  final ValueNotifier<bool> escuro;

  static AuroraEscopo de(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuroraEscopo>()!;

  void alternarTema() {
    escuro.value = !escuro.value;
    db.salvarPreferencia('tema', escuro.value ? 'escuro' : 'claro');
  }

  @override
  bool updateShouldNotify(AuroraEscopo old) => db != old.db || escuro != old.escuro;
}

class AuroraApp extends StatelessWidget {
  const AuroraApp({super.key, required this.db, required this.escuro, this.primeiraVez = false});

  final BancoAurora db;
  final ValueNotifier<bool> escuro;
  final bool primeiraVez;

  @override
  Widget build(BuildContext context) {
    return AuroraEscopo(
      db: db,
      escuro: escuro,
      child: ValueListenableBuilder<bool>(
        valueListenable: escuro,
        builder: (context, ehEscuro, _) => MaterialApp(
          title: 'Aurora',
          scrollBehavior: const RolagemAurora(),
          debugShowCheckedModeBanner: false,
          theme: temaAurora(Brightness.light),
          darkTheme: temaAurora(Brightness.dark),
          themeMode: ehEscuro ? ThemeMode.dark : ThemeMode.light,
          locale: const Locale('pt', 'BR'),
          supportedLocales: const [Locale('pt', 'BR')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Shell(primeiraVez: primeiraVez),
          // O bloqueio cobre tudo, inclusive diálogos abertos; a moldura da
          // janela (Windows) fica por cima até do bloqueio.
          builder: (context, filho) => MolduraJanela(child: PortaoBloqueio(db: db, child: filho!)),
        ),
      ),
    );
  }
}
