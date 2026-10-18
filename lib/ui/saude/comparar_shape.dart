import 'package:flutter/material.dart';

import '../../core/formato.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/shape_repo.dart';
import '../ceu_estrelado.dart';
import '../componentes.dart';
import '../formulario.dart';
import 'shape_page.dart';

/// Comparar evolução: duas datas lado a lado, no mesmo ângulo.
class CompararShapePage extends StatefulWidget {
  const CompararShapePage({super.key, required this.repo, required this.checkins});
  final ShapeRepo repo;

  /// Do mais recente para o mais antigo (como vem do repositório).
  final List<CheckinShape> checkins;

  @override
  State<CompararShapePage> createState() => _CompararShapePageState();
}

class _CompararShapePageState extends State<CompararShapePage> {
  AnguloShape _angulo = AnguloShape.frente;

  // Começa comparando o primeiro check-in com o último.
  late String _diaA = widget.checkins.last.dia;
  late String _diaB = widget.checkins.first.dia;

  CheckinShape _checkin(String dia) => widget.checkins.firstWhere((k) => k.dia == dia);

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final hoje = hojeSP();
    final a = _checkin(_diaA), b = _checkin(_diaB);
    final dias = diasEntre(a.data, b.data).abs();
    final largo = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      body: CeuEstrelado(
        child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: ListView(
              padding: largo
                  ? const EdgeInsets.fromLTRB(Espaco.xl, Espaco.lg, Espaco.xl, Espaco.xxl)
                  : const EdgeInsets.fromLTRB(20, Espaco.md, 20, Espaco.xl),
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Comparar evolução', style: sora(24))),
                    BotaoRedondo(
                      icone: Icons.close_rounded,
                      dica: 'Fechar',
                      aoTocar: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  dias == 0 ? 'Mesmo dia nos dois lados.' : '$dias ${dias == 1 ? 'dia' : 'dias'} entre as fotos.',
                  style: manrope(13, cor: c.muted),
                ),
                const SizedBox(height: Espaco.lg),
                Segmentos<AnguloShape>(
                  opcoes: AnguloShape.values,
                  selecionado: _angulo,
                  rotulo: (x) => x.rotulo,
                  aoEscolher: (x) => setState(() => _angulo = x),
                ),
                const SizedBox(height: Espaco.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _lado(context, 'Data A', a, hoje, (d) => setState(() => _diaA = d))),
                    SizedBox(width: largo ? 16 : 10),
                    Expanded(child: _lado(context, 'Data B', b, hoje, (d) => setState(() => _diaB = d))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _lado(BuildContext context, String rotulo, CheckinShape k, DateTime hoje, ValueChanged<String> trocar) {
    final c = context.cores;
    final foto = k.fotos[_angulo];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SeletorData(
          rotulo: rotulo,
          dia: k.data,
          aoTocar: () async {
            final d = await abrirFolha<String>(
              context,
              (_) => _FolhaDatas(titulo: rotulo, checkins: widget.checkins, atual: k.dia),
            );
            if (d != null) trocar(d);
          },
        ),
        const SizedBox(height: 10),
        AspectRatio(
          aspectRatio: 3 / 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AnimatedSwitcher(
              duration: (MediaQuery.maybeDisableAnimationsOf(context) ?? false)
                  ? Duration.zero
                  : const Duration(milliseconds: 200),
              child: foto == null
                  ? Container(
                      key: ValueKey('vazio${k.dia}${_angulo.name}'),
                      color: c.surface2,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(iconeAngulo(_angulo), size: 36, color: c.muted),
                          const SizedBox(height: 8),
                          Text(
                            'Sem foto de ${_angulo.rotulo.toLowerCase()} neste dia',
                            textAlign: TextAlign.center,
                            style: manrope(12, cor: c.muted),
                          ),
                        ],
                      ),
                    )
                  : SizedBox.expand(
                      key: ValueKey(foto.arquivo),
                      child: ImagemShape(repo: widget.repo, arquivo: foto.arquivo),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          diaRelativo(k.data, hoje),
          textAlign: TextAlign.center,
          style: manrope(12, cor: c.muted),
        ),
      ],
    );
  }
}

class _SeletorData extends StatelessWidget {
  const _SeletorData({required this.rotulo, required this.dia, required this.aoTocar});
  final String rotulo;
  final DateTime dia;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Cartao(
      raio: 14,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      aoTocar: aoTocar,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rotulo.toUpperCase(),
                  style: manrope(10, peso: FontWeight.w800, cor: c.muted),
                ),
                const SizedBox(height: 2),
                Text(
                  dataCurtaComAno(dia),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: manrope(14, peso: FontWeight.w700),
                ),
              ],
            ),
          ),
          Icon(Icons.expand_more_rounded, color: c.muted),
        ],
      ),
    );
  }
}

/// "3 de out. de 2026".
String dataCurtaComAno(DateTime d) => '${diaMesCurto(d)} de ${d.year}';

class _FolhaDatas extends StatelessWidget {
  const _FolhaDatas({required this.titulo, required this.checkins, required this.atual});
  final String titulo;
  final List<CheckinShape> checkins;
  final String atual;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final hoje = hojeSP();
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          children: [
            Text(titulo, style: sora(20)),
            const SizedBox(height: 12),
            for (final k in checkins)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Cartao(
                  raio: 14,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  cor: k.dia == atual ? c.accentSoft : null,
                  aoTocar: () => Navigator.pop(context, k.dia),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(tituloCheckin(k.data, hoje), style: manrope(14, peso: FontWeight.w600)),
                      ),
                      Text('${k.fotos.length}/3', style: manrope(12, cor: c.muted)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
