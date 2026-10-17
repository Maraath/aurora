import 'package:flutter/material.dart';

import '../../core/formato.dart';
import '../../core/tema.dart';
import '../../data/saude_repo.dart';
import '../componentes.dart';
import 'biblioteca_ui.dart';

/// "TREINO DE HOJE" do protótipo: exercícios, séries e carga sugerida.
/// Em dia de descanso mostra o próximo treino.
class CartaoTreinoDoDia extends StatelessWidget {
  const CartaoTreinoDoDia({
    super.key,
    required this.quadro,
    required this.hoje,
    required this.aoComecar,
    required this.aoAbrirFicha,
  });

  final QuadroSaude quadro;
  final DateTime hoje;
  final ValueChanged<TreinoCompleto> aoComecar;
  final VoidCallback aoAbrirFicha;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    if (quadro.treinos.isEmpty) {
      return CartaoNovo(
        titulo: '+ Montar ficha de treino',
        detalhe: 'Diga o que treinar em cada dia. A carga de cada exercício passa a ser '
            'sugerida pelo seu último treino.',
        aoTocar: aoAbrirFicha,
      );
    }
    final deHoje = quadro.treinoDoDia(hoje);
    final proximo = deHoje == null ? quadro.proximoTreino(hoje) : null;
    final treino = deHoje ?? proximo?.treino ?? quadro.treinos.first;
    final feito = quadro.feitoEm(treino.treino.id, hoje);

    final String rotuloTopo;
    if (deHoje != null) {
      rotuloTopo = 'TREINO DE HOJE';
    } else if (proximo != null) {
      rotuloTopo = 'HOJE É DESCANSO · PRÓXIMO ${diaRelativo(proximo.dia, hoje).toUpperCase()}';
    } else {
      rotuloTopo = 'TREINO';
    }

    return Cartao(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(rotuloTopo, style: rotulo(c.accent))),
              if (feito)
                Text('feito hoje', style: manrope(12, peso: FontWeight.w700, cor: c.teal))
              else
                InkWell(
                  onTap: aoAbrirFicha,
                  child: Text('ver ficha', style: manrope(12, peso: FontWeight.w700, cor: c.muted)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(treino.titulo, style: sora(18)),
          const SizedBox(height: 4),
          for (final e in treino.exercicios) LinhaExercicio(exercicio: e),
          const SizedBox(height: 8),
          Text('A carga sugerida vem do seu último treino.', style: manrope(12, cor: c.muted)),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: BotaoPilula(
              texto: feito ? 'Registrar outro treino' : 'Começar treino',
              principal: !feito,
              aoTocar: () => aoComecar(treino),
            ),
          ),
        ],
      ),
    );
  }
}

/// Exercício com plano e carga sugerida (verde-água), separado por uma linha.
class LinhaExercicio extends StatelessWidget {
  const LinhaExercicio({super.key, required this.exercicio});
  final ExercicioDoTreino exercicio;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final e = exercicio;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: c.line))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.exercicio.nome, style: manrope(14, peso: FontWeight.w600)),
                Text(e.plano, style: manrope(12, cor: c.muted)),
              ],
            ),
          ),
          if (e.exercicio.midia != null)
            IconButton(
              tooltip: 'Ver o movimento',
              visualDensity: VisualDensity.compact,
              onPressed: () => verExercicio(context,
                  nome: e.exercicio.nome, arquivo: e.exercicio.midia!, grupo: e.exercicio.grupo),
              icon: Icon(Icons.play_circle_outline_rounded, color: c.accent),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(e.sugestao.texto, style: manrope(14, peso: FontWeight.w700, cor: c.teal)),
              if (e.sugestao.subiu)
                Text('subiu', style: manrope(11, peso: FontWeight.w700, cor: c.teal)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Peso e Braço (ou as duas primeiras medidas) com a variação desde o registro anterior.
class BlocosMedidas extends StatelessWidget {
  const BlocosMedidas({super.key, required this.quadro, required this.aoTocar});
  final QuadroSaude quadro;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final tipos = quadro.tiposMedida.isEmpty ? ['Peso', 'Braço'] : quadro.tiposMedida;
    return Row(
      children: [
        for (var i = 0; i < 2 && i < tipos.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: _bloco(context, tipos[i])),
        ],
        if (tipos.length == 1) ...[const SizedBox(width: 10), const Expanded(child: SizedBox())],
      ],
    );
  }

  Widget _bloco(BuildContext context, String tipo) {
    final c = context.cores;
    final m = quadro.ultima(tipo);
    final v = quadro.variacao(tipo);
    return Cartao(
      raio: 16,
      padding: const EdgeInsets.all(14),
      aoTocar: aoTocar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tipo, style: manrope(12, peso: FontWeight.w600, cor: c.muted)),
          const SizedBox(height: 4),
          Text(m == null ? '—' : '${numero(m.valor)} ${m.unidade}', style: sora(24)),
          Text(
            m == null
                ? 'toque para registrar'
                : (v == null || v == 0 ? 'sem mudança' : '${v > 0 ? '+' : '−'}${numero(v.abs())} ${m.unidade}'),
            style: manrope(12, cor: c.muted),
          ),
        ],
      ),
    );
  }
}
