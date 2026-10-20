import 'package:flutter/material.dart';

import '../../core/tema.dart';
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

/// Navegação de segundo nível (dentro de uma aba): pílulas pequenas com ícone,
/// alinhadas à esquerda, para não competir com os `Segmentos` da área.
/// Rola de lado se não couber.
class SubAbas<T> extends StatelessWidget {
  const SubAbas({
    super.key,
    required this.opcoes,
    required this.selecionado,
    required this.rotulo,
    required this.aoEscolher,
    this.icone,
  });

  final List<T> opcoes;
  final T selecionado;
  final String Function(T) rotulo;
  final IconData Function(T)? icone;
  final ValueChanged<T> aoEscolher;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final semMovimento = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final duracao = semMovimento ? Duration.zero : const Duration(milliseconds: 180);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < opcoes.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _pilula(c, opcoes[i], duracao),
          ],
        ],
      ),
    );
  }

  Widget _pilula(AuroraCores c, T o, Duration duracao) {
    final ativo = o == selecionado;
    final cor = ativo ? c.accent : c.muted;
    return Semantics(
      selected: ativo,
      button: true,
      child: AnimatedContainer(
        duration: duracao,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: ativo ? c.accentSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: ativo ? c.accent.withValues(alpha: 0.45) : c.line),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => aoEscolher(o),
            customBorder: const StadiumBorder(),
            hoverColor: c.teal.withValues(alpha: 0.10),
            splashColor: c.violeta.withValues(alpha: 0.14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icone != null) ...[Icon(icone!(o), size: 16, color: cor), const SizedBox(width: 6)],
                  Text(
                    rotulo(o),
                    style: manrope(13, peso: ativo ? FontWeight.w700 : FontWeight.w600, cor: ativo ? c.text : c.muted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
