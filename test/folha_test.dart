import 'package:aurora/core/tema.dart';
import 'package:aurora/ui/formulario.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('botão da folha fica acima da barra de navegação do Android', (t) async {
    // Celular de borda a borda: 390 x 844 com 48 px de barra de navegação embaixo.
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    t.view.padding = const FakeViewPadding(top: 24, bottom: 48);
    t.view.viewPadding = const FakeViewPadding(top: 24, bottom: 48);
    addTearDown(t.view.reset);

    await t.pumpWidget(MaterialApp(
      theme: temaAurora(Brightness.dark),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => abrirFolha<void>(
                context,
                (_) => Folha(
                  titulo: 'Novo treino',
                  campos: [for (var i = 0; i < 3; i++) const SizedBox(height: 80)],
                  textoSalvar: 'Salvar treino',
                  aoSalvar: () {},
                ),
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    ));
    await t.tap(find.text('abrir'));
    await t.pumpAndSettle();

    final botao = t.getRect(find.text('Salvar treino'));
    expect(botao.bottom, lessThanOrEqualTo(844 - 48));
  });
}
