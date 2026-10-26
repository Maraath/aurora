import 'package:flutter/material.dart';

import '../../core/tema.dart';
import '../componentes.dart';
import 'biblioteca_ui.dart';
import 'ficha_page.dart';
import 'medidas_page.dart';
import 'shape_page.dart';

/// Subseções de Saúde › Treino.
enum SubTreino {
  ficha('Ficha', Icons.fitness_center_rounded),
  medidas('Medidas', Icons.straighten_rounded),
  exercicios('Exercícios', Icons.video_library_outlined),
  shape('Shape', Icons.photo_camera_front_outlined);

  const SubTreino(this.rotulo, this.icone);
  final String rotulo;
  final IconData icone;
}

/// Saúde › Treino: a ficha, as medidas, a biblioteca de exercícios e o Shape
/// (fotos de evolução) num lugar só. A subseção fica com quem chama (a Shell),
/// para não se perder ao passar por Alimentação e voltar.
class TreinoPage extends StatelessWidget {
  const TreinoPage({super.key, required this.sub, required this.aoEscolher});

  final SubTreino sub;
  final ValueChanged<SubTreino> aoEscolher;

  @override
  Widget build(BuildContext context) {
    final semMovimento = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SubAbas<SubTreino>(
          opcoes: SubTreino.values,
          selecionado: sub,
          rotulo: (s) => s.rotulo,
          icone: (s) => s.icone,
          aoEscolher: aoEscolher,
        ),
        const SizedBox(height: Espaco.lg),
        // Troca suave: a subseção nova entra com fade e sobe 8 px.
        AnimatedSwitcher(
          duration: semMovimento ? Duration.zero : const Duration(milliseconds: 240),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          layoutBuilder: (atual, anteriores) =>
              Stack(alignment: Alignment.topCenter, children: [...anteriores, ?atual]),
          transitionBuilder: (filho, animacao) => FadeTransition(
            opacity: animacao,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, 0.015), end: Offset.zero).animate(animacao),
              child: filho,
            ),
          ),
          child: KeyedSubtree(
            key: ValueKey(sub),
            child: switch (sub) {
              SubTreino.ficha => const FichaPage(),
              SubTreino.medidas => const MedidasPage(),
              SubTreino.exercicios => const BibliotecaPage(),
              SubTreino.shape => const ShapePage(),
            },
          ),
        ),
      ],
    );
  }
}
