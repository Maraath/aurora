import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/tema.dart';

/// Moldura da janela no Windows: sem a barra de título do sistema, o céu vai
/// até o topo, com um fio de aurora na borda de cima e botões próprios.
///
/// Arrastar, duplo clique para maximizar, menu da janela e os snap layouts
/// (passar o mouse no maximizar) seguem nativos: o runner
/// (`windows/runner/flutter_window.cpp`) diz ao Windows onde fica cada parte
/// da faixa de cima. As medidas daqui são as mesmas de lá.
const alturaBarraJanela = 32.0;
const larguraBotaoJanela = 46.0;

/// Só no app de Windows de verdade (nos testes a janela não existe).
final bool molduraPropria =
    !kIsWeb && Platform.isWindows && !Platform.environment.containsKey('FLUTTER_TEST');

/// Estado da janela, que chega do runner pelo canal `aurora/janela`.
class JanelaWindows {
  JanelaWindows._() {
    canal.setMethodCallHandler((chamada) async {
      switch (chamada.method) {
        case 'maximizada':
          maximizada.value = chamada.arguments as bool;
        case 'ativa':
          ativa.value = chamada.arguments as bool;
        case 'botaoMax':
          botaoMax.value = EstadoBotao.values[chamada.arguments as int];
      }
    });
    canal.invokeMapMethod<String, Object?>('estado').then((e) {
      maximizada.value = e?['maximizada'] as bool? ?? false;
      ativa.value = e?['ativa'] as bool? ?? true;
    }).catchError((_) {});
  }

  static final instancia = JanelaWindows._();

  static const canal = MethodChannel('aurora/janela');

  final maximizada = ValueNotifier(false);
  final ativa = ValueNotifier(true);

  /// O maximizar é tratado pelo Windows (por causa dos snap layouts); o
  /// Flutter só desenha o estado que o runner manda.
  final botaoMax = ValueNotifier(EstadoBotao.normal);

  Future<void> minimizar() => canal.invokeMethod('minimizar');
  Future<void> alternarMaximizar() => canal.invokeMethod('alternarMaximizar');
  Future<void> fechar() => canal.invokeMethod('fechar');
  Future<void> tema({required bool escuro}) => canal.invokeMethod('tema', escuro);
}

enum EstadoBotao { normal, emCima, apertado }

/// Envolve o app (no `builder` do MaterialApp): o conteúdo ganha a altura da
/// barra no `padding` de cima do MediaQuery, então tudo que usa SafeArea
/// (telas, folhas, bloqueio) começa abaixo dela; o céu de cada tela continua
/// indo até o topo.
class MolduraJanela extends StatefulWidget {
  const MolduraJanela({super.key, required this.child, this.ativa});

  final Widget child;

  /// Liga a moldura fora do Windows (testes).
  final bool? ativa;

  @override
  State<MolduraJanela> createState() => _MolduraJanelaState();
}

class _MolduraJanelaState extends State<MolduraJanela> {
  bool? _escuroAvisado;

  bool get _ativa => widget.ativa ?? molduraPropria;

  @override
  Widget build(BuildContext context) {
    if (!_ativa) return widget.child;
    // A borda da janela e o menu do sistema acompanham o tema do app.
    final escuro = Theme.of(context).brightness == Brightness.dark;
    if (_escuroAvisado != escuro) {
      _escuroAvisado = escuro;
      JanelaWindows.instancia.tema(escuro: escuro).catchError((_) {});
    }
    final mq = MediaQuery.of(context);
    final topo = mq.padding.top + alturaBarraJanela;
    return Stack(
      fit: StackFit.expand,
      children: [
        MediaQuery(
          data: mq.copyWith(
            padding: mq.padding.copyWith(top: topo),
            viewPadding: mq.viewPadding.copyWith(top: mq.viewPadding.top + alturaBarraJanela),
          ),
          child: widget.child,
        ),
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: alturaBarraJanela,
          child: BarraJanela(),
        ),
      ],
    );
  }
}

/// Fio de aurora na borda de cima e os botões minimizar, maximizar e fechar.
/// O resto da faixa é transparente: lá o Windows trata o arrastar.
class BarraJanela extends StatelessWidget {
  const BarraJanela({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final janela = JanelaWindows.instancia;
    return ValueListenableBuilder<bool>(
      valueListenable: janela.ativa,
      builder: (context, ativa, _) => Stack(
        children: [
          // Verde do oxigênio → turquesa → violeta → magenta. Esmaece com a
          // janela em segundo plano, como a barra do sistema.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 2,
            child: Opacity(
              opacity: ativa ? 1 : 0.4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [c.accentFill, c.teal, c.violeta, c.bad]),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _BotaoJanela(
                  tipo: _Tipo.minimizar,
                  rotulo: 'Minimizar',
                  ativa: ativa,
                  aoTocar: janela.minimizar,
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: janela.maximizada,
                  builder: (context, maximizada, _) => ValueListenableBuilder<EstadoBotao>(
                    valueListenable: janela.botaoMax,
                    builder: (context, estado, _) => _BotaoJanela(
                      tipo: maximizada ? _Tipo.restaurar : _Tipo.maximizar,
                      rotulo: maximizada ? 'Restaurar' : 'Maximizar',
                      ativa: ativa,
                      estado: estado,
                      aoTocar: janela.alternarMaximizar,
                    ),
                  ),
                ),
                _BotaoJanela(
                  tipo: _Tipo.fechar,
                  rotulo: 'Fechar',
                  ativa: ativa,
                  aoTocar: janela.fechar,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _Tipo { minimizar, maximizar, restaurar, fechar }

class _BotaoJanela extends StatefulWidget {
  const _BotaoJanela({
    required this.tipo,
    required this.rotulo,
    required this.ativa,
    required this.aoTocar,
    this.estado,
  });

  final _Tipo tipo;
  final String rotulo;
  final bool ativa;
  final Future<void> Function() aoTocar;

  /// Estado vindo do Windows (só o maximizar); os outros usam o mouse daqui.
  final EstadoBotao? estado;

  @override
  State<_BotaoJanela> createState() => _BotaoJanelaState();
}

class _BotaoJanelaState extends State<_BotaoJanela> {
  var _emCima = false;
  var _apertado = false;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final estado = widget.estado ??
        (_apertado
            ? EstadoBotao.apertado
            : _emCima
                ? EstadoBotao.emCima
                : EstadoBotao.normal);
    final fechar = widget.tipo == _Tipo.fechar;
    final destaque = estado != EstadoBotao.normal;
    final fundo = !destaque
        ? Colors.transparent
        : fechar
            ? (estado == EstadoBotao.apertado ? c.bad.withValues(alpha: 0.8) : c.bad)
            : c.text.withValues(alpha: estado == EstadoBotao.apertado ? 0.14 : 0.08);
    final cor = fechar && destaque ? c.noAccent : (widget.ativa || destaque ? c.text : c.muted);
    final semMovimento = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return Semantics(
      button: true,
      label: widget.rotulo,
      onTap: () => widget.aoTocar(),
      excludeSemantics: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _emCima = true),
        onExit: (_) => setState(() {
          _emCima = false;
          _apertado = false;
        }),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _apertado = true),
          onTapCancel: () => setState(() => _apertado = false),
          onTap: () {
            setState(() => _apertado = false);
            widget.aoTocar().catchError((_) {});
          },
          child: AnimatedContainer(
            duration: semMovimento ? Duration.zero : const Duration(milliseconds: 120),
            width: larguraBotaoJanela,
            height: alturaBarraJanela,
            color: fundo,
            child: CustomPaint(painter: _DesenhoBotao(widget.tipo, cor)),
          ),
        ),
      ),
    );
  }
}

/// Traços finos de 10 px, como os do Windows.
class _DesenhoBotao extends CustomPainter {
  _DesenhoBotao(this.tipo, this.cor);

  final _Tipo tipo;
  final Color cor;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = cor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..isAntiAlias = tipo == _Tipo.fechar;
    final x = (size.width / 2 - 5).roundToDouble() + 0.5;
    final y = (size.height / 2 - 5).roundToDouble() + 0.5;
    switch (tipo) {
      case _Tipo.minimizar:
        canvas.drawLine(Offset(x, y + 5), Offset(x + 10, y + 5), p);
      case _Tipo.maximizar:
        canvas.drawRRect(RRect.fromLTRBR(x, y, x + 9, y + 9, const Radius.circular(1.5)), p);
      case _Tipo.restaurar:
        canvas.drawRRect(RRect.fromLTRBR(x, y + 2, x + 7, y + 9, const Radius.circular(1.5)), p);
        canvas.drawPath(
          Path()
            ..moveTo(x + 2, y + 2)
            ..lineTo(x + 2, y)
            ..lineTo(x + 9, y)
            ..lineTo(x + 9, y + 7)
            ..lineTo(x + 7, y + 7),
          p,
        );
      case _Tipo.fechar:
        canvas.drawLine(Offset(x, y), Offset(x + 9, y + 9), p);
        canvas.drawLine(Offset(x + 9, y), Offset(x, y + 9), p);
    }
  }

  @override
  bool shouldRepaint(_DesenhoBotao old) => old.tipo != tipo || old.cor != cor;
}
