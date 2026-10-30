import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/tema.dart';
import '../componentes.dart';
import '../formulario.dart';
import '../vidro.dart';
import '../visao/foco.dart';

/// Sala de Foco Imersivo: timer circular com os 3 modos configuráveis
/// (Pomodoro, Imersão e Pausa), ajuste livre de minutos, segmentos de áudio
/// com links de playlists no YouTube e integração/vínculo com o Spotify.
class SalaFocoImersivo extends StatefulWidget {
  const SalaFocoImersivo({
    super.key,
    this.itensDisponiveis = const [],
    this.aoVoltarParaGrade,
  });

  /// Tarefas e hábitos pendentes de hoje para alternar caso nenhum tenha sido
  /// fixado pelo Timeblocking.
  final List<({String titulo, String detalhe, int minutos})> itensDisponiveis;

  /// Callback opcional para voltar à grade de Timeblocking.
  final VoidCallback? aoVoltarParaGrade;

  @override
  State<SalaFocoImersivo> createState() => _SalaFocoImersivoState();
}

class _SalaFocoImersivoState extends State<SalaFocoImersivo> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = AuroraEscopo.de(context).db;
    ControleFoco.instancia.carregarPreferencias(db);
  }

  ({String titulo, String detalhe}) _itemAtual(ControleFoco foco) {
    if (foco.itemSelecionado != null) return foco.itemSelecionado!;
    final lista = widget.itensDisponiveis;
    if (lista.isEmpty) {
      return (titulo: 'Sessão de foco livre', detalhe: 'Sem tarefa específica selecionada');
    }
    final idx = foco.indice % lista.length;
    return (titulo: lista[idx].titulo, detalhe: lista[idx].detalhe);
  }

  Future<void> _abrirYoutube(SegmentoAudioFoco s) async {
    final foco = ControleFoco.instancia;
    final abriu = await foco.abrirSegmentoYoutube(s);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          abriu
              ? 'Abrindo playlist "${s.titulo}" no YouTube...'
              : 'Playlist "${s.titulo}" selecionada (${foco.urlYoutubeDe(s)}).',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _abrirSpotify() async {
    final foco = ControleFoco.instancia;
    final abriu = await foco.abrirSpotify();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          abriu
              ? 'Abrindo "${foco.spotifyNome}" no Spotify...'
              : 'Spotify pronto: ${foco.spotifyNome} (${foco.spotifyUrl}).',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final db = AuroraEscopo.de(context).db;

    return ListenableBuilder(
      listenable: ControleFoco.instancia,
      builder: (context, _) {
        final foco = ControleFoco.instancia;
        final item = _itemAtual(foco);
        final minAtual = foco.minutosDe(foco.modo);

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cartão Principal do Timer
                _CartaoImersao(
                  child: Column(
                    children: [
                      // Seletor das 3 opções: Pomodoro, Imersão e Pausa
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          for (final m in ModoFoco.values)
                            _PilulaModoFoco(
                              modo: m,
                              minutos: foco.minutosDe(m),
                              ativo: foco.modo == m,
                              aoTocar: () => foco.selecionarModo(m),
                            ),
                          Semantics(
                            button: true,
                            label: 'Personalizar minutos',
                            child: InkWell(
                              borderRadius: BorderRadius.circular(999),
                              onTap: () => abrirPersonalizarTemposFoco(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: c.line),
                                  color: c.surface2.withValues(alpha: 0.45),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.tune_rounded, size: 15, color: c.accent),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Personalizar minutos',
                                      style: manrope(12, peso: FontWeight.w700, cor: c.accent),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Ajuste rápido de minutos para o modo selecionado
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _BotaoAjusteMinuto(
                            rotulo: '-5',
                            dica: 'Diminuir 5 minutos',
                            aoTocar: () => foco.definirMinutosModo(foco.modo, minAtual - 5, db: db),
                          ),
                          _BotaoAjusteMinuto(
                            rotulo: '-1',
                            dica: 'Diminuir 1 minuto',
                            aoTocar: () => foco.definirMinutosModo(foco.modo, minAtual - 1, db: db),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => abrirPersonalizarTemposFoco(context),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${foco.modo.rotulo}: $minAtual min',
                                    style: manrope(12.5, peso: FontWeight.w700, cor: c.muted),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.edit_outlined, size: 14, color: c.muted),
                                ],
                              ),
                            ),
                          ),
                          _BotaoAjusteMinuto(
                            rotulo: '+1',
                            dica: 'Aumentar 1 minuto',
                            aoTocar: () => foco.definirMinutosModo(foco.modo, minAtual + 1, db: db),
                          ),
                          _BotaoAjusteMinuto(
                            rotulo: '+5',
                            dica: 'Aumentar 5 minutos',
                            aoTocar: () => foco.definirMinutosModo(foco.modo, minAtual + 5, db: db),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Tarefa em foco agora
                      Text(
                        'EM FOCO AGORA',
                        style: manrope(11, peso: FontWeight.w800, cor: c.teal, espaco: 1.4),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.titulo,
                        textAlign: TextAlign.center,
                        style: sora(22, altura: 1.2),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.detalhe,
                        textAlign: TextAlign.center,
                        style: manrope(13, cor: c.muted),
                      ),

                      const SizedBox(height: 24),

                      // Anel Circular do Timer
                      SizedBox(
                        width: 230,
                        height: 230,
                        child: CustomPaint(
                          painter: _PintorAnelFoco(
                            progresso: foco.progresso,
                            corTrilho: c.surface2,
                            gradIni: c.gradIni,
                            gradMeio: c.teal,
                            gradFim: c.violeta,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  foco.mostrador,
                                  style: sora(44, espaco: -1),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  foco.focando
                                      ? 'Focando (${foco.modo.rotulo})'
                                      : 'Pronto · ${foco.modo.rotulo}',
                                  style: manrope(12.5, peso: FontWeight.w600, cor: c.muted),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Botões de Ação do Timer
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          BotaoPilula(
                            texto: foco.focando ? 'Pausar foco' : 'Começar foco',
                            aoTocar: foco.alternar,
                          ),
                          BotaoRedondo(
                            icone: Icons.refresh_rounded,
                            dica: 'Reiniciar timer',
                            aoTocar: foco.reiniciar,
                          ),
                          if (widget.itensDisponiveis.length > 1 || foco.itemSelecionado != null)
                            BotaoPilula(
                              texto: 'Trocar tarefa',
                              principal: false,
                              aoTocar: foco.proximo,
                            ),
                        ],
                      ),

                      const SizedBox(height: 26),
                      Divider(height: 1, color: c.line.withValues(alpha: 0.6)),
                      const SizedBox(height: 20),

                      // Seção de Música de Foco: Playlists no YouTube + Spotify
                      Row(
                        children: [
                          Icon(Icons.queue_music_rounded, size: 18, color: c.violeta),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Música e Ambiente de Foco', style: sora(15)),
                                Text(
                                  'Playlists de concentração no YouTube ou sua conta do Spotify',
                                  style: manrope(12, cor: c.muted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Grade dos 4 segmentos com links do YouTube
                      LayoutBuilder(
                        builder: (context, box) {
                          final estreito = box.maxWidth < 520;
                          final cartoes = [
                            for (final s in SegmentoAudioFoco.values)
                              _CartaoSegmentoYoutube(
                                segmento: s,
                                ativo: foco.segmentoAtivo == s,
                                url: foco.urlYoutubeDe(s),
                                aoAbrir: () => _abrirYoutube(s),
                                aoEditarUrl: () => abrirEditarLinkYoutube(context, s),
                              ),
                          ];
                          if (estreito) {
                            return Column(
                              children: [
                                for (var i = 0; i < cartoes.length; i++) ...[
                                  if (i > 0) const SizedBox(height: 8),
                                  cartoes[i],
                                ],
                              ],
                            );
                          }
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(child: cartoes[0]),
                                  const SizedBox(width: 10),
                                  Expanded(child: cartoes[1]),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(child: cartoes[2]),
                                  const SizedBox(width: 10),
                                  Expanded(child: cartoes[3]),
                                ],
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 14),

                      // Cartão de Vínculo com o Spotify
                      _CartaoSpotify(
                        vinculado: foco.spotifyVinculado,
                        nome: foco.spotifyNome,
                        url: foco.spotifyUrl,
                        aoVincularOuEditar: () => abrirVinculoSpotifyFoco(context),
                        aoAbrirSpotify: _abrirSpotify,
                        aoDesvincular: () => foco.desvincularSpotify(db: db),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Resumo das sessões de foco do dia
                LinhaContadores([
                  Contador(
                    valor: _formatarMinutos(foco.minutosFocadosHoje),
                    rotulo: 'Tempo focado hoje',
                    cor: c.teal,
                  ),
                  Contador(
                    valor: '${foco.sessoesHoje}',
                    rotulo: 'Ciclos concluídos',
                    cor: c.accent,
                  ),
                  Contador(
                    valor: '${foco.minutosDe(ModoFoco.pomodoro)}/${foco.minutosDe(ModoFoco.imersao)}m',
                    rotulo: 'Pomodoro / Imersão',
                    cor: c.violeta,
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatarMinutos(int min) {
    if (min < 60) return '$min min';
    final h = min ~/ 60;
    final m = min % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}

class _CartaoImersao extends StatelessWidget {
  const _CartaoImersao({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final raio = BorderRadius.circular(24);
    return Vidro(
      raio: raio,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      c.gradIni.withValues(alpha: 0.10),
                      c.violeta.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(22), child: child),
        ],
      ),
    );
  }
}

class _PilulaModoFoco extends StatelessWidget {
  const _PilulaModoFoco({
    required this.modo,
    required this.minutos,
    required this.ativo,
    required this.aoTocar,
  });

  final ModoFoco modo;
  final int minutos;
  final bool ativo;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Semantics(
      selected: ativo,
      button: true,
      label: '${modo.rotulo} ($minutos min)',
      child: Material(
        color: ativo ? c.accentSoft : c.surface2.withValues(alpha: 0.5),
        shape: StadiumBorder(
          side: BorderSide(
            color: ativo ? c.accent : c.line,
            width: ativo ? 1.4 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(
              '${modo.rotulo} · $minutos min',
              style: manrope(
                12.5,
                peso: ativo ? FontWeight.w700 : FontWeight.w600,
                cor: ativo ? c.text : c.muted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BotaoAjusteMinuto extends StatelessWidget {
  const _BotaoAjusteMinuto({
    required this.rotulo,
    required this.dica,
    required this.aoTocar,
  });

  final String rotulo;
  final String dica;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Tooltip(
      message: dica,
      child: Material(
        color: c.surface2,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              rotulo,
              style: manrope(12, peso: FontWeight.w700, cor: c.text),
            ),
          ),
        ),
      ),
    );
  }
}

class _CartaoSegmentoYoutube extends StatelessWidget {
  const _CartaoSegmentoYoutube({
    required this.segmento,
    required this.ativo,
    required this.url,
    required this.aoAbrir,
    required this.aoEditarUrl,
  });

  final SegmentoAudioFoco segmento;
  final bool ativo;
  final String url;
  final VoidCallback aoAbrir;
  final VoidCallback aoEditarUrl;

  IconData get _icone => switch (segmento) {
        SegmentoAudioFoco.binaural => Icons.graphic_eq_rounded,
        SegmentoAudioFoco.chuva => Icons.water_drop_outlined,
        SegmentoAudioFoco.lofi => Icons.headphones_rounded,
        SegmentoAudioFoco.ruido => Icons.waves_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    const corYt = Color(0xFFFF4E45);
    return Cartao(
      sombra: false,
      raio: 16,
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      cor: ativo ? c.accentSoft : c.surface2.withValues(alpha: 0.45),
      aoTocar: aoAbrir,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: corYt.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icone, size: 19, color: corYt),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  segmento.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: manrope(13.5, peso: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.play_circle_fill_rounded, size: 13, color: corYt),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'YouTube · ${segmento.subtitulo}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: manrope(11.5, cor: c.muted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Trocar link de ${segmento.titulo}',
            onPressed: aoEditarUrl,
            icon: Icon(Icons.link_rounded, size: 18, color: c.muted),
          ),
        ],
      ),
    );
  }
}

class _CartaoSpotify extends StatelessWidget {
  const _CartaoSpotify({
    required this.vinculado,
    required this.nome,
    required this.url,
    required this.aoVincularOuEditar,
    required this.aoAbrirSpotify,
    required this.aoDesvincular,
  });

  final bool vinculado;
  final String nome;
  final String url;
  final VoidCallback aoVincularOuEditar;
  final VoidCallback aoAbrirSpotify;
  final VoidCallback aoDesvincular;

  static const _verdeSpotify = Color(0xFF1DB954);

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _verdeSpotify.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _verdeSpotify.withValues(alpha: 0.35)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _verdeSpotify.withValues(alpha: 0.20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.library_music_rounded, color: _verdeSpotify, size: 20),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          vinculado ? 'Spotify vinculado' : 'Spotify',
                          style: sora(14, cor: vinculado ? _verdeSpotify : c.text),
                        ),
                        if (vinculado) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded, size: 15, color: _verdeSpotify),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vinculado
                          ? nome
                          : 'Vincule sua conta ou playlist de foco favorita do Spotify',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: manrope(12, cor: c.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!vinculado)
            Semantics(
              button: true,
              label: 'Vincular Spotify',
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _verdeSpotify,
                  foregroundColor: Colors.black,
                  textStyle: manrope(12.5, peso: FontWeight.w700),
                ),
                onPressed: aoVincularOuEditar,
                icon: const Icon(Icons.link_rounded, size: 16),
                label: const Text('Vincular Spotify'),
              ),
            )
          else
            Wrap(
              spacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _verdeSpotify,
                    foregroundColor: Colors.black,
                    textStyle: manrope(12.5, peso: FontWeight.w700),
                  ),
                  onPressed: aoAbrirSpotify,
                  icon: const Icon(Icons.open_in_new_rounded, size: 15),
                  label: const Text('Ouvir no Spotify'),
                ),
                IconButton(
                  tooltip: 'Trocar playlist do Spotify',
                  onPressed: aoVincularOuEditar,
                  icon: Icon(Icons.edit_outlined, size: 18, color: c.muted),
                ),
                IconButton(
                  tooltip: 'Desvincular Spotify',
                  onPressed: aoDesvincular,
                  icon: Icon(Icons.link_off_rounded, size: 18, color: c.bad),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PintorAnelFoco extends CustomPainter {
  const _PintorAnelFoco({
    required this.progresso,
    required this.corTrilho,
    required this.gradIni,
    required this.gradMeio,
    required this.gradFim,
  });

  final double progresso;
  final Color corTrilho;
  final Color gradIni;
  final Color gradMeio;
  final Color gradFim;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final raio = (math.min(size.width, size.height) - 14) / 2;
    final retangulo = Rect.fromCircle(center: centro, radius: raio);

    final trilho = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = corTrilho;
    canvas.drawCircle(centro, raio, trilho);

    final arco = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [gradIni, gradMeio, gradFim, gradIni],
      ).createShader(retangulo);

    // Quando está pronto (progresso 0), mostra o anel cheio pronto para rodar.
    final fracao = progresso <= 0 ? 1.0 : (1.0 - progresso).clamp(0.02, 1.0);
    canvas.drawArc(
      retangulo,
      -math.pi / 2,
      2 * math.pi * fracao,
      false,
      arco,
    );
  }

  @override
  bool shouldRepaint(covariant _PintorAnelFoco old) =>
      old.progresso != progresso || old.corTrilho != corTrilho;
}

/// Folha para alterar livremente os minutos de Pomodoro, Imersão e Pausa.
Future<void> abrirPersonalizarTemposFoco(BuildContext context) {
  final foco = ControleFoco.instancia;
  final db = AuroraEscopo.de(context).db;
  final ctrlPomodoro = TextEditingController(text: '${foco.minutosDe(ModoFoco.pomodoro)}');
  final ctrlImersao = TextEditingController(text: '${foco.minutosDe(ModoFoco.imersao)}');
  final ctrlPausa = TextEditingController(text: '${foco.minutosDe(ModoFoco.pausa)}');

  return abrirFolha(
    context,
    (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        String? erro;
        Future<void> salvar() async {
          final p = int.tryParse(ctrlPomodoro.text.trim());
          final i = int.tryParse(ctrlImersao.text.trim());
          final b = int.tryParse(ctrlPausa.text.trim());
          if (p == null || p < 1 || i == null || i < 1 || b == null || b < 1) {
            setState(() => erro = 'Informe um número de minutos válido (mínimo 1).');
            return;
          }
          await foco.salvarTodosTempos(pomodoro: p, imersao: i, pausa: b, db: db);
          if (ctx.mounted) Navigator.pop(ctx);
        }

        return Folha(
          titulo: 'Tempos de foco (minutos)',
          textoSalvar: 'Salvar tempos',
          aoSalvar: salvar,
          campos: [
            Campo(
              rotulo: 'Pomodoro (minutos)',
              child: CampoTexto(
                controle: ctrlPomodoro,
                dica: 'Ex.: 25',
                numerico: true,
                autofoco: true,
              ),
            ),
            Campo(
              rotulo: 'Imersão (minutos)',
              child: CampoTexto(
                controle: ctrlImersao,
                dica: 'Ex.: 50',
                numerico: true,
              ),
            ),
            Campo(
              rotulo: 'Pausa (minutos)',
              child: CampoTexto(
                controle: ctrlPausa,
                dica: 'Ex.: 5',
                numerico: true,
                erro: erro,
              ),
            ),
          ],
        );
      },
    ),
  );
}

/// Folha para vincular uma playlist ou conta do Spotify ao foco.
Future<void> abrirVinculoSpotifyFoco(BuildContext context) {
  final foco = ControleFoco.instancia;
  final db = AuroraEscopo.de(context).db;
  final ctrlNome = TextEditingController(text: foco.spotifyNome);
  final ctrlUrl = TextEditingController(text: foco.spotifyUrl);

  return abrirFolha(
    context,
    (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        final c = ctx.cores;
        return Folha(
          titulo: 'Vincular Spotify',
          textoSalvar: 'Vincular ao Spotify',
          aoSalvar: () async {
            await foco.vincularSpotify(
              nome: ctrlNome.text,
              url: ctrlUrl.text,
              db: db,
            );
            if (ctx.mounted) Navigator.pop(ctx);
          },
          campos: [
            Campo(
              rotulo: 'Playlists oficiais de foco do Spotify',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (nome, url) in sugestoesSpotifyFoco)
                    ActionChip(
                      label: Text(nome, style: manrope(12, peso: FontWeight.w600)),
                      backgroundColor: c.surface2,
                      onPressed: () {
                        setState(() {
                          ctrlNome.text = nome;
                          ctrlUrl.text = url;
                        });
                      },
                    ),
                ],
              ),
            ),
            Campo(
              rotulo: 'Nome da sua playlist ou perfil',
              child: CampoTexto(
                controle: ctrlNome,
                dica: 'Ex.: Meu Foco no Spotify',
              ),
            ),
            Campo(
              rotulo: 'Link da playlist ou conta no Spotify',
              child: CampoTexto(
                controle: ctrlUrl,
                dica: 'https://open.spotify.com/playlist/...',
              ),
            ),
          ],
        );
      },
    ),
  );
}

/// Folha para editar o link de playlist do YouTube de um segmento de foco.
Future<void> abrirEditarLinkYoutube(BuildContext context, SegmentoAudioFoco segmento) {
  final foco = ControleFoco.instancia;
  final db = AuroraEscopo.de(context).db;
  final ctrlUrl = TextEditingController(text: foco.urlYoutubeDe(segmento));

  return abrirFolha(
    context,
    (ctx) => Folha(
      titulo: 'Playlist do YouTube · ${segmento.titulo}',
      textoSalvar: 'Salvar link',
      aoSalvar: () async {
        await foco.definirUrlYoutube(segmento, ctrlUrl.text, db: db);
        if (ctx.mounted) Navigator.pop(ctx);
      },
      campos: [
        Campo(
          rotulo: 'Link do vídeo ou playlist no YouTube',
          child: CampoTexto(
            controle: ctrlUrl,
            dica: segmento.urlPadrao,
            autofoco: true,
          ),
        ),
      ],
    ),
  );
}
