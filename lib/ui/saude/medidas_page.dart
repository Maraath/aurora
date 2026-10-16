import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/saude_repo.dart';
import '../componentes.dart';
import '../em_breve.dart';
import '../formulario.dart';
import 'form_medidas.dart';

class MedidasPage extends StatefulWidget {
  const MedidasPage({super.key, this.voltar});
  final VoidCallback? voltar;

  @override
  State<MedidasPage> createState() => _MedidasPageState();
}

class _MedidasPageState extends State<MedidasPage> {
  SaudeRepo? _repo;
  Stream<QuadroSaude>? _quadro;
  String? _tipo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = AuroraEscopo.de(context).db;
    if (_repo?.db != db) {
      _repo = SaudeRepo(db);
      _quadro = _repo!.observarQuadro();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuadroSaude>(
      stream: _quadro,
      builder: (context, snap) {
        if (snap.hasError) return Text('Não consegui ler as medidas: ${snap.error}');
        final q = snap.data;
        if (q == null) return const SizedBox(height: 200);
        return _conteudo(context, q);
      },
    );
  }

  Widget _conteudo(BuildContext context, QuadroSaude q) {
    final c = context.cores;
    final tipos = q.tiposMedida;
    final tipo = tipos.contains(_tipo) ? _tipo! : tipos.firstOrNull;
    final lista = tipo == null ? const <Medida>[] : q.medidas[tipo]!;
    final hoje = hojeSP();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TituloPagina(
          'Medidas',
          voltar: widget.voltar,
          acao: BotaoRedondo(
            icone: Icons.add_rounded,
            dica: 'Registrar medidas',
            preenchido: true,
            aoTocar: () => abrirFormMedidas(context, q),
          ),
        ),
        const SizedBox(height: 18),
        if (tipo == null)
          CartaoNovo(
            titulo: '+ Registrar medidas',
            detalhe: 'Peso, braço, cintura ou qualquer outra. O gráfico mostra a evolução.',
            aoTocar: () => abrirFormMedidas(context, q),
          )
        else ...[
          GrupoChips<String>(
            opcoes: tipos,
            selecionado: tipo,
            rotulo: (t) => t,
            aoEscolher: (t) => setState(() => _tipo = t),
          ),
          const SizedBox(height: 14),
          Cartao(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tipo, style: manrope(12, peso: FontWeight.w600, cor: c.muted)),
                const SizedBox(height: 2),
                Text('${numero(lista.last.valor)} ${lista.last.unidade}', style: sora(30)),
                Text(_resumo(lista), style: manrope(12, cor: c.muted)),
                const SizedBox(height: 16),
                _Grafico(medidas: lista),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const TituloSecao('Registros'),
          Cartao(
            raio: 16,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = lista.length - 1; i >= 0; i--) ...[
                  if (i < lista.length - 1) Divider(height: 1, color: c.line),
                  _linha(context, lista, i, hoje),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text('Toque num registro para excluí-lo.', style: manrope(12, cor: c.muted)),
        ],
      ],
    );
  }

  String _resumo(List<Medida> l) {
    if (l.length < 2) return 'primeiro registro';
    final dif = l.last.valor - l.first.valor;
    final desde = diaMesCurto(DateTime.parse(l.first.dia));
    if (dif == 0) return 'igual desde $desde';
    return '${dif > 0 ? '+' : '−'}${numero(dif.abs())} ${l.last.unidade} desde $desde';
  }

  Widget _linha(BuildContext context, List<Medida> l, int i, DateTime hoje) {
    final c = context.cores;
    final m = l[i];
    final dif = i == 0 ? null : m.valor - l[i - 1].valor;
    return InkWell(
      onTap: () => _excluir(m),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(diaRelativo(DateTime.parse(m.dia), hoje), style: manrope(14)),
            ),
            if (dif != null && dif != 0)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text('${dif > 0 ? '+' : '−'}${numero(dif.abs())}',
                    style: manrope(12, cor: c.muted)),
              ),
            Text('${numero(m.valor)} ${m.unidade}', style: manrope(14, peso: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Future<void> _excluir(Medida m) async {
    final c = context.cores;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text('Excluir registro?', style: sora(18)),
        content: Text('${m.tipo}: ${numero(m.valor)} ${m.unidade} em ${diaMesCurto(DateTime.parse(m.dia))}.',
            style: manrope(14, cor: c.text)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Excluir', style: TextStyle(color: c.bad)),
          ),
        ],
      ),
    );
    if (ok == true) await _repo!.excluirMedida(m.id);
  }
}

/// Linha da evolução no tempo (eixo x em dias, para espaçar certo).
class _Grafico extends StatelessWidget {
  const _Grafico({required this.medidas});
  final List<Medida> medidas;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    if (medidas.length < 2) {
      return Text('Registre mais uma vez para ver o gráfico.', style: manrope(13, cor: c.muted));
    }
    final inicio = DateTime.parse(medidas.first.dia);
    final pontos = [
      for (final m in medidas)
        FlSpot(diasEntre(inicio, DateTime.parse(m.dia)).toDouble(), m.valor),
    ];
    final valores = medidas.map((m) => m.valor);
    final menor = valores.reduce((a, b) => a < b ? a : b);
    final maior = valores.reduce((a, b) => a > b ? a : b);
    final folga = ((maior - menor) * 0.3).clamp(0.5, double.infinity);
    final ultimoX = pontos.last.x;

    return SizedBox(
      height: 170,
      child: LineChart(
        LineChartData(
          minY: menor - folga,
          maxY: maior + folga,
          minX: 0,
          maxX: ultimoX == 0 ? 1 : ultimoX,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(color: c.line, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (v, meta) => v == meta.max || v == meta.min
                    ? const SizedBox()
                    : Text(numero(double.parse(v.toStringAsFixed(1))), style: manrope(10, cor: c.muted)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: ultimoX <= 0 ? 1 : ultimoX,
                getTitlesWidget: (v, meta) => Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(diaMesCurto(inicio.add(Duration(days: v.round()))),
                      style: manrope(10, peso: FontWeight.w700, cor: c.muted)),
                ),
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => c.surface2,
              getTooltipItems: (spots) => [
                for (final s in spots)
                  LineTooltipItem(
                    '${numero(s.y)} ${medidas.first.unidade}\n${diaMesCurto(inicio.add(Duration(days: s.x.round())))}',
                    manrope(12, peso: FontWeight.w700, cor: c.text),
                  ),
              ],
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: pontos,
              color: c.accent,
              barWidth: 3,
              isCurved: false,
              dotData: FlDotData(
                getDotPainter: (_, _, _, _) =>
                    FlDotCirclePainter(radius: 4, color: c.accent, strokeWidth: 0),
              ),
              belowBarData: BarAreaData(show: true, color: c.accentSoft),
            ),
          ],
        ),
      ),
    );
  }
}
