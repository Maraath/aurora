import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/formato.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/visao_repo.dart';
import '../componentes.dart';
import '../shell.dart';

/// Cor do dinheiro fora de Finanças (contas que vencem hoje na linha do dia).
const _azulDinheiro = Color(0xFF8FD3FF);
const _azulDinheiroClaro = Color(0xFF2B6FA8);

enum _Vista { dia, semana }

/// Horizonte (rumo A do estudo de 03/11/2026), no topo da Visão: o dia vira um
/// arco no céu, das 06h às 24h. O que já passou fica aceso em degradê, o que
/// falta fica tracejado, cada item com hora é uma estrela na cor do tipo
/// (cheia quando feito, só o contorno quando falta) e um ponto brilhante marca
/// agora. O pico do ícone fica no horizonte. A aba Semana troca o desenho por
/// cortinas de aurora, uma por dia, com a altura do que cada dia tem marcado.
/// Embaixo do horizonte, uma faixa só: a seguir, o dia em números, o que ficou
/// para trás e o que falta pagar.
class HorizonteDoDia extends StatefulWidget {
  const HorizonteDoDia({super.key, required this.resumo, required this.irRotina});

  final ResumoVisao resumo;
  final ValueChanged<AbaRotina> irRotina;

  @override
  State<HorizonteDoDia> createState() => _HorizonteDoDiaState();
}

class _HorizonteDoDiaState extends State<HorizonteDoDia> {
  _Vista _vista = _Vista.dia;
  Timer? _minuto;

  @override
  void initState() {
    super.initState();
    // O ponto de "agora" anda sozinho, uma vez por minuto.
    _minuto = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _minuto?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final agora = agoraLocal();
    final r = widget.resumo;
    final comHora = [for (final i in r.linha) if (i.hora != null) i];
    final feitos = r.linha.where((i) => i.feito).length;

    return LayoutBuilder(
      builder: (context, box) {
        final largo = box.maxWidth >= 700;
        final altura = largo ? 290.0 : 200.0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _vista == _Vista.dia ? 'HORIZONTE DE HOJE' : 'PRÓXIMOS 7 DIAS',
                    style: rotulo(c.muted),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: Segmentos<_Vista>(
                    opcoes: _Vista.values,
                    selecionado: _vista,
                    rotulo: (v) => v == _Vista.dia ? 'Dia' : 'Semana',
                    aoEscolher: (v) => setState(() => _vista = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Espaco.sm),
            Semantics(
              label: _vista == _Vista.dia
                  ? 'Horizonte de hoje: $feitos de ${r.linha.length} feitos, ${comHora.length} com horário'
                  : 'Próximos 7 dias: ${r.semana.map((d) => '${diaSemanaCurto(d.dia)} ${d.total}').join(', ')}',
              child: GestureDetector(
                onTap: () => widget.irRotina(_vista == _Vista.dia ? AbaRotina.hoje : AbaRotina.calendario),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: SizedBox(
                    key: ValueKey(_vista),
                    height: altura,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _vista == _Vista.dia
                          ? _PintorArco(
                              itens: comHora,
                              agora: agora,
                              cores: c,
                              escuro: Theme.of(context).brightness == Brightness.dark,
                              rotulos: largo,
                            )
                          : _PintorSemana(
                              semana: r.semana,
                              cores: c,
                              escuro: Theme.of(context).brightness == Brightness.dark,
                              rotulos: largo,
                            ),
                    ),
                  ),
                ),
              ),
            ),
            _FaixaDoChao(resumo: r, agora: agora, feitos: feitos, largo: largo, irRotina: widget.irRotina),
          ],
        );
      },
    );
  }
}

Color _corDoItem(AuroraCores c, ItemLinha i, bool escuro) {
  if (i.atrasado) return c.bad;
  return switch (i.tipo) {
    TipoItemLinha.compromisso => c.corCompromisso,
    TipoItemLinha.tarefa => c.corTarefa,
    TipoItemLinha.lembrete => c.corLembrete,
    TipoItemLinha.habito => c.corHabito,
    TipoItemLinha.conta => escuro ? _azulDinheiro : _azulDinheiroClaro,
  };
}

double _horas(DateTime d) => d.hour + d.minute / 60;

/// "Qua" (de "qua, 4 nov").
String _diaCurto(DateTime d) {
  final s = diaSemanaCurto(d).split(',').first.trim();
  return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

/// Prende entre 0 e [max] (se não cabe, encosta no 0).
double _limitar(double v, double max) => v > max ? math.max(0.0, max) : math.max(0.0, v);

TextPainter _texto(String s, TextStyle estilo, {TextSpan? antes}) => TextPainter(
      text: TextSpan(children: [?antes, TextSpan(text: s, style: estilo)]),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: 180);

/// Chão, montanha e horizonte: comuns às duas vistas.
void _pintarChao(Canvas canvas, Size size, double cy, AuroraCores c, bool escuro) {
  final w = size.width;
  final h = size.height;
  final chao = Rect.fromLTWH(0, cy, w, h - cy);
  canvas.drawRect(
    chao,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [c.surface.withValues(alpha: escuro ? .55 : .7), c.surface.withValues(alpha: 0)],
      ).createShader(chao),
  );
  final contorno = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = c.violeta.withValues(alpha: escuro ? .28 : .35);
  final massa = Paint()..color = escuro ? const Color(0xFF0C0B22) : c.surface2;
  final morro = Path()
    ..moveTo(w * .05, cy)
    ..quadraticBezierTo(w * .14, cy - h * .07, w * .25, cy)
    ..close();
  // O pico do ícone (como o Kirkjufell): subida, cume torto e descida longa.
  final pico = Path()
    ..moveTo(w * .54, cy)
    ..lineTo(w * .60, cy - h * .12)
    ..quadraticBezierTo(w * .625, cy - h * .20, w * .648, cy - h * .185)
    ..lineTo(w * .69, cy - h * .07)
    ..lineTo(w * .73, cy)
    ..close();
  for (final p in [morro, pico]) {
    canvas.drawPath(p, massa);
    canvas.drawPath(p, contorno);
  }
  final linha = Rect.fromLTWH(0, cy - 1, w, 2);
  canvas.drawLine(
    Offset(0, cy),
    Offset(w, cy),
    Paint()
      ..strokeWidth = 1.3
      ..shader = LinearGradient(
        colors: [
          c.violeta.withValues(alpha: 0),
          c.violeta.withValues(alpha: .6),
          c.violeta.withValues(alpha: 0),
        ],
      ).createShader(linha),
  );
}

class _PintorArco extends CustomPainter {
  _PintorArco({
    required this.itens,
    required this.agora,
    required this.cores,
    required this.escuro,
    required this.rotulos,
  });

  final List<ItemLinha> itens;
  final DateTime agora;
  final AuroraCores cores;
  final bool escuro;
  final bool rotulos;

  @override
  void paint(Canvas canvas, Size size) {
    final c = cores;
    final w = size.width;
    final h = size.height;
    final cy = h - (rotulos ? 38 : 30);
    final cx = w / 2;
    final rx = w / 2 - (rotulos ? 110 : 24);
    final ry = cy - (rotulos ? 38 : 34);
    Offset pt(double hh) {
      final t = ((hh - 6) / 18).clamp(0.0, 1.0);
      final a = math.pi * (1 - t);
      return Offset(cx + rx * math.cos(a), cy - ry * math.sin(a));
    }

    double angulo(double hh) => math.pi * (1 - ((hh - 6) / 18).clamp(0.0, 1.0));

    _pintarChao(canvas, size, cy, c, escuro);

    // O que falta: tracejado.
    final tracejado = Paint()
      ..color = c.muted.withValues(alpha: .38)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (var x = 6.0; x < 24; x += .32) {
      canvas.drawLine(pt(x), pt(math.min(x + .08, 24)), tracejado);
    }

    // O que passou: aceso, com brilho.
    final hAgora = _horas(agora);
    if (hAgora > 6) {
      final passado = Path()..moveTo(pt(6).dx, pt(6).dy);
      for (var x = 6.0; x < hAgora; x += .1) {
        final p = pt(x);
        passado.lineTo(p.dx, p.dy);
      }
      final pa = pt(hAgora);
      passado.lineTo(pa.dx, pa.dy);
      final caixa = Rect.fromLTRB(cx - rx, 0, cx + rx, cy);
      final grad = LinearGradient(colors: [c.gradIni, c.gradFim]).createShader(caixa);
      canvas.drawPath(
        passado,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round
          ..shader = grad
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
          ..color = Colors.white.withValues(alpha: escuro ? .45 : .25),
      );
      canvas.drawPath(
        passado,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..shader = grad,
      );
    }

    // Horas no horizonte.
    final estiloHora = manrope(rotulos ? 11 : 10, cor: c.muted, peso: FontWeight.w500);
    for (final hh in rotulos ? [6, 9, 12, 15, 18, 21, 24] : [6, 12, 18, 24]) {
      final tp = _texto('${hh.toString().padLeft(2, '0')}h', estiloHora);
      tp.paint(canvas, Offset(pt(hh.toDouble()).dx - tp.width / 2, cy + 6));
    }

    // Itens: os próximos 4 pendentes sempre levam nome; com espaço, todos.
    final pendentesFuturos = [
      for (final i in itens)
        if (!i.feito && _horas(i.hora!) >= hAgora) i,
    ].take(4).toSet();
    final todosComNome = rotulos && itens.length <= 12;
    for (var k = 0; k < itens.length; k++) {
      final i = itens[k];
      final hh = _horas(i.hora!);
      final p = pt(hh);
      final cor = _corDoItem(c, i, escuro);
      if (i.feito) {
        canvas.drawCircle(p, 9, Paint()..color = cor.withValues(alpha: .35)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
        canvas.drawCircle(p, rotulos ? 5 : 4, Paint()..color = cor);
      } else {
        canvas.drawCircle(p, rotulos ? 5 : 4, Paint()..color = c.bg);
        canvas.drawCircle(
          p,
          rotulos ? 5 : 4,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8
            ..color = cor,
        );
      }
      if (!(todosComNome || pendentesFuturos.contains(i))) continue;
      // Rótulo: alterna fora/dentro do arco para não encostar no vizinho.
      final fora = k.isOdd;
      final a = angulo(hh);
      final co = math.cos(a);
      final d = fora ? 17.0 : -17.0;
      var lx = p.dx + co * d * 1.15;
      var ly = p.dy - math.sin(a) * d;
      final tp = _texto(
        i.titulo,
        manrope(rotulos ? 12.5 : 11, peso: FontWeight.w600, cor: i.feito ? c.muted : c.text),
        antes: TextSpan(text: '${hora(i.hora!)}  ', style: manrope(rotulos ? 11 : 10, cor: c.muted)),
      );
      var ancora = co > .3 ? 1 : (co < -.3 ? -1 : 0); // 1 começa, -1 termina, 0 meio
      if (!fora && ancora != 0) ancora = -ancora;
      if (ancora == 0) {
        lx -= tp.width / 2;
        ly += fora ? -tp.height - 2 : 4;
      } else {
        if (ancora < 0) lx -= tp.width;
        ly -= tp.height / 2;
      }
      lx = _limitar(lx, w - tp.width);
      tp.paint(canvas, Offset(lx, ly));
    }

    // Agora: ponto brilhante, linha até o horizonte e o horário.
    if (hAgora >= 6) {
      final s = pt(hAgora);
      canvas.drawLine(
        Offset(s.dx, s.dy + 10),
        Offset(s.dx, cy),
        Paint()
          ..color = c.accent.withValues(alpha: .35)
          ..strokeWidth = 1,
      );
      canvas.drawCircle(
        s,
        rotulos ? 20 : 15,
        Paint()
          ..shader = RadialGradient(
            colors: [Colors.white.withValues(alpha: .95), c.accent.withValues(alpha: .55), c.accent.withValues(alpha: 0)],
            stops: const [0, .3, 1],
          ).createShader(Rect.fromCircle(center: s, radius: rotulos ? 20 : 15)),
      );
      canvas.drawCircle(s, rotulos ? 4.5 : 3.5, Paint()..color = escuro ? Colors.white : c.accent);
      final tp = _texto('agora · ${hora(agora)}', manrope(rotulos ? 12 : 11, peso: FontWeight.w700, cor: c.accent));
      tp.paint(canvas, Offset(_limitar(s.dx - tp.width / 2, w - tp.width), math.max(0.0, s.dy - (rotulos ? 26 : 20) - tp.height)));
    }

    if (itens.isEmpty) {
      final tp = _texto('Nada com horário hoje', manrope(13, cor: c.muted));
      tp.paint(canvas, Offset(cx - tp.width / 2, cy - ry * .45));
    }
  }

  @override
  bool shouldRepaint(_PintorArco old) =>
      old.itens != itens || old.agora != agora || old.cores != cores || old.escuro != escuro || old.rotulos != rotulos;
}

/// Semana: uma cortina de aurora por dia, com a altura do que o dia tem.
class _PintorSemana extends CustomPainter {
  _PintorSemana({required this.semana, required this.cores, required this.escuro, required this.rotulos});

  final List<DiaSemana> semana;
  final AuroraCores cores;
  final bool escuro;
  final bool rotulos;

  @override
  void paint(Canvas canvas, Size size) {
    final c = cores;
    final w = size.width;
    final h = size.height;
    final cy = h - (rotulos ? 38 : 30);
    final rx = w / 2 - (rotulos ? 110 : 24);
    _pintarChao(canvas, size, cy, c, escuro);
    if (semana.isEmpty) return;
    final maior = semana.map((d) => d.total).fold<int>(1, math.max);
    final vao = 2 * rx / semana.length;
    final larg = vao * .42;
    final alturaMax = cy - (rotulos ? 40 : 30);
    for (var i = 0; i < semana.length; i++) {
      final d = semana[i];
      final hoje = i == 0;
      final x = w / 2 - rx + vao * (i + .5);
      final alt = math.max(6.0, alturaMax * d.total / maior);
      final caixa = Rect.fromLTWH(x - larg / 2, cy - alt, larg, alt);
      final rr = RRect.fromRectAndRadius(caixa, Radius.circular(larg / 2));
      final grad = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          c.accentFill.withValues(alpha: hoje ? .95 : .7),
          c.teal.withValues(alpha: hoje ? .5 : .3),
          c.gradFim.withValues(alpha: 0),
        ],
        stops: const [0, .55, 1],
      ).createShader(caixa);
      if (hoje) {
        canvas.drawRRect(
          rr.inflate(4),
          Paint()
            ..color = c.accent.withValues(alpha: .22)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
      }
      canvas.drawRRect(rr, Paint()..shader = grad);
      // Dobras da cortina.
      final dobra = Paint()
        ..color = Colors.white.withValues(alpha: .08)
        ..strokeWidth = 1;
      for (var k = 1; k < 4; k++) {
        final dx = caixa.left + larg * k / 4;
        canvas.drawLine(Offset(dx, caixa.top + 6), Offset(dx, cy), dobra);
      }
      final dia = _texto(
        hoje ? 'Hoje' : _diaCurto(d.dia),
        manrope(rotulos ? 11.5 : 10, peso: hoje ? FontWeight.w700 : FontWeight.w500, cor: hoje ? c.accent : c.muted),
      );
      dia.paint(canvas, Offset(x - dia.width / 2, cy + 6));
      if (d.total > 0) {
        final n = _texto('${d.total}', manrope(rotulos ? 12 : 10.5, peso: FontWeight.w600, cor: c.text));
        n.paint(canvas, Offset(x - n.width / 2, cy - alt - n.height - 4));
      }
    }
  }

  @override
  bool shouldRepaint(_PintorSemana old) =>
      old.semana != semana || old.cores != cores || old.escuro != escuro || old.rotulos != rotulos;
}

/// A faixa embaixo do horizonte: sem cartões, separada por fios.
class _FaixaDoChao extends StatelessWidget {
  const _FaixaDoChao({
    required this.resumo,
    required this.agora,
    required this.feitos,
    required this.largo,
    required this.irRotina,
  });

  final ResumoVisao resumo;
  final DateTime agora;
  final int feitos;
  final bool largo;
  final ValueChanged<AbaRotina> irRotina;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final r = resumo;
    final proximo = r.linha.where((i) => !i.feito && i.hora != null && i.hora!.isAfter(agora)).firstOrNull;
    final blocos = <Widget>[
      _Bloco(
        titulo: 'A seguir',
        grande: proximo == null ? '—' : hora(proximo.hora!),
        miudo: proximo == null ? null : 'em ${_falta(proximo.hora!.difference(agora))}',
        linha: proximo?.titulo ?? 'Nada mais com horário hoje',
        aoTocar: () => irRotina(AbaRotina.hoje),
      ),
      _Bloco(
        titulo: 'Hoje',
        grande: '$feitos',
        miudo: 'de ${r.linha.length}',
        linha: 'Hábitos ${r.habitosFeitos} de ${r.habitos.length}',
        aoTocar: () => irRotina(AbaRotina.hoje),
      ),
      if (r.tarefasAtrasadas > 0)
        _Bloco(
          titulo: 'Ficou para trás',
          corRotulo: c.bad,
          grande: '${r.tarefasAtrasadas}',
          miudo: r.tarefasAtrasadas == 1 ? 'tarefa' : 'tarefas',
          linha: 'Resolver ou remarcar',
          aoTocar: () => irRotina(AbaRotina.hoje),
        ),
      if (r.aPagarCentavos > 0)
        _Bloco(
          titulo: 'A pagar',
          grande: reais(r.aPagarCentavos),
          linha: r.contasAPagar == 1 ? '1 conta' : '${r.contasAPagar} contas',
        ),
    ];
    final fio = c.line.withValues(alpha: .8);
    if (largo) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < blocos.length; i++) ...[
              if (i > 0) VerticalDivider(width: 1, thickness: 1, color: fio),
              Expanded(child: blocos[i]),
            ],
          ],
        ),
      );
    }
    return Wrap(
      children: [
        for (final b in blocos)
          FractionallySizedBox(widthFactor: .5, child: b),
      ],
    );
  }

  static String _falta(Duration d) {
    final m = d.inMinutes.clamp(0, 24 * 60);
    if (m < 60) return '$m min';
    final h = m ~/ 60;
    final resto = m % 60;
    return resto == 0 ? '$h h' : '$h h $resto min';
  }
}

class _Bloco extends StatelessWidget {
  const _Bloco({
    required this.titulo,
    required this.grande,
    required this.linha,
    this.miudo,
    this.corRotulo,
    this.aoTocar,
  });

  final String titulo;
  final String grande;
  final String? miudo;
  final String linha;
  final Color? corRotulo;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final conteudo = Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(titulo.toUpperCase(), style: rotulo(corRotulo ?? c.muted)),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: grande, style: sora(24, cor: c.text, espaco: -.5)),
                if (miudo != null) TextSpan(text: '  $miudo', style: manrope(13, cor: c.muted)),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(linha, style: manrope(13, cor: c.muted), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
    if (aoTocar == null) return conteudo;
    return InkWell(onTap: aoTocar, borderRadius: BorderRadius.circular(12), child: conteudo);
  }
}
