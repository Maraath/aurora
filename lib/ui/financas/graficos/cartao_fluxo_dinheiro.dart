import 'package:flutter/material.dart';

import '../../../core/formato.dart';
import '../../../core/tema.dart';
import '../../../data/graficos_financas.dart';
import '../categorias_visual.dart';
import '../painel/cartao_painel.dart';

/// "Fluxo do dinheiro no mês": de onde veio (esquerda) para onde foi
/// (direita), com faixas proporcionais aos valores. A chave alterna entre só o
/// que já aconteceu e o mês inteiro com o que está agendado. Tocar numa
/// categoria destaca as faixas dela.
class CartaoFluxoDinheiro extends StatefulWidget {
  const CartaoFluxoDinheiro({super.key, required this.fato, required this.comPrevistos});

  /// Só o que já entrou e saiu.
  final FluxoDinheiro fato;

  /// Incluindo contas e recebimentos agendados do mês.
  final FluxoDinheiro comPrevistos;

  @override
  State<CartaoFluxoDinheiro> createState() => _CartaoFluxoDinheiroState();
}

class _CartaoFluxoDinheiroState extends State<CartaoFluxoDinheiro> {
  bool _previstos = false;
  String? _destaque;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final f = _previstos ? widget.comPrevistos : widget.fato;
    final chave = Semantics(
      button: true,
      toggled: _previstos,
      label: 'Incluir o que está agendado',
      child: InkWell(
        onTap: () => setState(() => _previstos = !_previstos),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _previstos ? c.accentSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _previstos ? c.accent.withValues(alpha: 0.45) : c.line),
          ),
          child: Text(_previstos ? 'Mês inteiro' : 'Só o que já aconteceu',
              style: manrope(12, peso: FontWeight.w700, cor: _previstos ? c.accent : c.muted)),
        ),
      ),
    );

    return CartaoPainel(
      titulo: 'Fluxo do dinheiro no mês',
      subtitulo: _previstos ? 'De onde vem e para onde vai, com o que está agendado' : 'De onde veio e para onde foi',
      acao: chave,
      child: f.vazio
          ? SizedBox(
              height: 120,
              child: Center(
                child: Text('O fluxo aparece quando houver lançamentos no mês.',
                    textAlign: TextAlign.center, style: manrope(14, cor: c.muted)),
              ),
            )
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              LayoutBuilder(builder: (context, box) {
                final altura = (f.destinos.length * 34.0).clamp(170.0, 290.0);
                final cores = {
                  for (final d in f.destinos) d.nome: _corDestino(context, d.nome),
                };
                return GestureDetector(
                  onTapUp: (e) {
                    final nome = _PintorFluxo.destinoEm(f, Size(box.maxWidth, altura), e.localPosition);
                    setState(() => _destaque = nome == _destaque ? null : nome);
                  },
                  child: CustomPaint(
                    size: Size(box.maxWidth, altura),
                    painter: _PintorFluxo(
                      fluxo: f,
                      cores: cores,
                      corOrigem: (n) => _corOrigem(context, n),
                      destaque: _destaque,
                      texto: c.text,
                      apagado: c.muted,
                      estiloNome: manrope(12, peso: FontWeight.w700, cor: c.text),
                      estiloValor: manrope(11, peso: FontWeight.w600, cor: c.muted),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 10),
              Text(
                f.sobraCentavos >= 0
                    ? 'Sobra do mês: ${reais(f.sobraCentavos)}'
                    : 'Saiu ${reais(-f.sobraCentavos)} a mais do que entrou: veio do saldo anterior.',
                style: manrope(13, peso: FontWeight.w700, cor: f.sobraCentavos >= 0 ? c.accent : c.bad),
              ),
            ]),
    );
  }

  Color _corDestino(BuildContext context, String nome) {
    final c = context.cores;
    if (nome == nomeSobra) return c.accent;
    if (nome == 'Outras') return c.muted;
    return visualDaCategoria(context, nome).cor;
  }

  Color _corOrigem(BuildContext context, String nome) {
    final c = context.cores;
    if (nome == nomeSaldoAnterior) return c.bad;
    return nome == 'Outras' ? c.muted : visualDaCategoria(context, nome).cor;
  }
}

class _PintorFluxo extends CustomPainter {
  _PintorFluxo({
    required this.fluxo,
    required this.cores,
    required this.corOrigem,
    required this.destaque,
    required this.texto,
    required this.apagado,
    required this.estiloNome,
    required this.estiloValor,
  });

  final FluxoDinheiro fluxo;
  final Map<String, Color> cores;
  final Color Function(String) corOrigem;
  final String? destaque;
  final Color texto, apagado;
  final TextStyle estiloNome, estiloValor;

  static const _barra = 9.0, _vao = 6.0;

  /// Largura reservada para os nomes de cada lado.
  static double _rotulo(Size s) => (s.width * 0.27).clamp(78.0, 140.0);

  /// Posição (topo, altura) de cada nó de uma coluna.
  static List<(double, double)> _nos(List<FatiaFluxo> lista, int total, double altura) {
    final livre = altura - _vao * (lista.length - 1);
    var y = 0.0;
    return [
      for (final f in lista)
        () {
          final h = (f.centavos / total * livre).clamp(3.0, altura);
          final r = (y, h);
          y += h + _vao;
          return r;
        }(),
    ];
  }

  /// Nome do destino na posição tocada (lado direito), se houver.
  static String? destinoEm(FluxoDinheiro f, Size s, Offset p) {
    if (p.dx < s.width / 2) return null;
    final nos = _nos(f.destinos, f.totalCentavos, s.height);
    for (var i = 0; i < nos.length; i++) {
      if (p.dy >= nos[i].$1 - _vao / 2 && p.dy <= nos[i].$1 + nos[i].$2 + _vao / 2) return f.destinos[i].nome;
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final total = fluxo.totalCentavos;
    if (total == 0) return;
    final rot = _rotulo(size);
    final xEsq = rot, xDir = size.width - rot - _barra;
    final esq = _nos(fluxo.origens, total, size.height);
    final dir = _nos(fluxo.destinos, total, size.height);
    final totalOrigens = fluxo.origens.fold(0, (s, f) => s + f.centavos);
    final totalDestinos = fluxo.destinos.fold(0, (s, f) => s + f.centavos);

    // Faixas: cada origem se divide entre os destinos na proporção deles.
    final usadoEsq = List.filled(esq.length, 0.0), usadoDir = List.filled(dir.length, 0.0);
    for (var i = 0; i < fluxo.origens.length; i++) {
      for (var j = 0; j < fluxo.destinos.length; j++) {
        final parte = fluxo.origens[i].centavos / totalOrigens * fluxo.destinos[j].centavos / totalDestinos;
        final hEsq = esq[i].$2 * (fluxo.destinos[j].centavos / totalDestinos);
        final hDir = dir[j].$2 * (fluxo.origens[i].centavos / totalOrigens);
        if (parte <= 0) continue;
        final y0 = esq[i].$1 + usadoEsq[i], y1 = dir[j].$1 + usadoDir[j];
        usadoEsq[i] += hEsq;
        usadoDir[j] += hDir;
        final meio = (xEsq + _barra + xDir) / 2;
        final caminho = Path()
          ..moveTo(xEsq + _barra, y0)
          ..cubicTo(meio, y0, meio, y1, xDir, y1)
          ..lineTo(xDir, y1 + hDir)
          ..cubicTo(meio, y1 + hDir, meio, y0 + hEsq, xEsq + _barra, y0 + hEsq)
          ..close();
        final nome = fluxo.destinos[j].nome;
        final apagar = destaque != null && destaque != nome;
        final cor = cores[nome] ?? apagado;
        canvas.drawPath(caminho, Paint()..color = cor.withValues(alpha: apagar ? 0.05 : (destaque == nome ? 0.42 : 0.2)));
      }
    }

    void no(double x, (double, double) n, Color cor) => canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(x, n.$1, _barra, n.$2), const Radius.circular(4)),
          Paint()..color = cor,
        );

    // Rótulos de uma coluna: centrados no nó, mas afastados uns dos outros
    // para não se sobreporem quando os nós são finos. Sem espaço para duas
    // linhas por rótulo, fica só uma ("Nome · R$ 10").
    void rotulos(List<FatiaFluxo> fatias, List<(double, double)> nos, double x, TextAlign alinhar) {
      final largura = rot - 10;
      final duasLinhas = fatias.length * 28.0 <= size.height;
      final pintores = [
        for (final f in fatias)
          TextPainter(
            text: TextSpan(
              children: duasLinhas
                  ? [TextSpan(text: '${f.nome}\n', style: estiloNome), TextSpan(text: reais(f.centavos), style: estiloValor)]
                  : [TextSpan(text: f.nome, style: estiloNome)],
            ),
            textAlign: alinhar,
            textDirection: TextDirection.ltr,
            maxLines: duasLinhas ? 2 : 1,
            ellipsis: '…',
          )..layout(maxWidth: largura),
      ];
      final topos = [for (var i = 0; i < nos.length; i++) nos[i].$1 + nos[i].$2 / 2 - pintores[i].height / 2];
      for (var i = 1; i < topos.length; i++) {
        topos[i] = topos[i] < topos[i - 1] + pintores[i - 1].height + 2 ? topos[i - 1] + pintores[i - 1].height + 2 : topos[i];
      }
      // Passou do fim: empurra de baixo para cima.
      var limite = size.height;
      for (var i = topos.length - 1; i >= 0; i--) {
        if (topos[i] + pintores[i].height > limite) topos[i] = limite - pintores[i].height;
        limite = topos[i] - 2;
      }
      for (var i = 0; i < pintores.length; i++) {
        final tp = pintores[i];
        final dx = alinhar == TextAlign.right ? x - tp.width : x;
        tp.paint(canvas, Offset(dx, topos[i].clamp(0, size.height - tp.height)));
      }
    }

    for (var i = 0; i < esq.length; i++) {
      no(xEsq, esq[i], corOrigem(fluxo.origens[i].nome));
    }
    for (var j = 0; j < dir.length; j++) {
      no(xDir, dir[j], cores[fluxo.destinos[j].nome] ?? apagado);
    }
    rotulos(fluxo.origens, esq, xEsq - 8, TextAlign.right);
    rotulos(fluxo.destinos, dir, xDir + _barra + 8, TextAlign.left);
  }

  @override
  bool shouldRepaint(_PintorFluxo antigo) => antigo.fluxo != fluxo || antigo.destaque != destaque || antigo.cores != cores;
}
