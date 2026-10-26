import 'package:flutter/material.dart';

import '../core/formato.dart';
import '../core/tema.dart';

/// Calendário de um mês, semana começando na segunda. [marcador] desenha o
/// indicador de cada dia (pontos, progresso).
class CalendarioMes extends StatelessWidget {
  const CalendarioMes({
    super.key,
    required this.mes,
    required this.hoje,
    required this.aoMudarMes,
    required this.marcador,
    this.selecionado,
    this.aoSelecionar,
    this.habilitado,
  });

  /// Dias que podem ser escolhidos (os outros ficam apagados); nulo = todos.
  final bool Function(DateTime dia)? habilitado;

  /// Qualquer dia do mês mostrado.
  final DateTime mes;
  final DateTime hoje;
  final DateTime? selecionado;
  final ValueChanged<DateTime>? aoSelecionar;
  final ValueChanged<DateTime> aoMudarMes;
  final Widget? Function(DateTime dia) marcador;

  static const _semana = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final primeiro = DateTime(mes.year, mes.month, 1);
    final diasNoMes = DateTime(mes.year, mes.month + 1, 0).day;
    final vazios = primeiro.weekday - 1;
    final celulas = vazios + diasNoMes;
    final linhas = (celulas / 7).ceil();
    final titulo = mesAno(primeiro);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(titulo[0].toUpperCase() + titulo.substring(1), style: sora(16)),
            ),
            IconButton(
              tooltip: 'Mês anterior',
              onPressed: () => aoMudarMes(DateTime(mes.year, mes.month - 1, 1)),
              icon: Icon(Icons.chevron_left_rounded, color: c.text),
            ),
            IconButton(
              tooltip: 'Próximo mês',
              onPressed: () => aoMudarMes(DateTime(mes.year, mes.month + 1, 1)),
              icon: Icon(Icons.chevron_right_rounded, color: c.text),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final l in _semana)
              Expanded(
                child: Center(
                  child: Text(l, style: manrope(11, peso: FontWeight.w700, cor: c.muted)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        for (var linha = 0; linha < linhas; linha++)
          Row(
            children: [
              for (var col = 0; col < 7; col++)
                Expanded(child: _celula(context, linha * 7 + col - vazios + 1, diasNoMes)),
            ],
          ),
      ],
    );
  }

  Widget _celula(BuildContext context, int n, int diasNoMes) {
    if (n < 1 || n > diasNoMes) return const SizedBox(height: 48);
    final c = context.cores;
    final dia = DateTime(mes.year, mes.month, n);
    final ehHoje = dia == hoje;
    final ehSelecionado = dia == selecionado;
    final marca = marcador(dia);
    final pode = habilitado?.call(dia) ?? true;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Opacity(
        opacity: pode ? 1 : 0.3,
        child: Material(
        color: ehSelecionado ? c.accentSoft : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: ehHoje ? BorderSide(color: c.accent, width: 1.5) : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoSelecionar == null || !pode ? null : () => aoSelecionar!(dia),
          child: SizedBox(
            height: 44,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$n',
                    style: manrope(14,
                        peso: ehHoje || ehSelecionado ? FontWeight.w700 : FontWeight.w500,
                        cor: ehSelecionado || ehHoje ? c.accent : c.text)),
                const SizedBox(height: 3),
                SizedBox(height: 6, child: marca),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

/// Bolinha de 6 px.
class Ponto extends StatelessWidget {
  const Ponto(this.cor, {super.key});
  final Color cor;

  @override
  Widget build(BuildContext context) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
      );
}
