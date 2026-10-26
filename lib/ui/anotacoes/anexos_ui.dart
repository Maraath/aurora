import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/tema.dart';
import '../../data/anotacoes_repo.dart';
import '../../data/banco.dart';
import '../../data/gravacao_nota.dart';
import '../formulario.dart';

/// "1:24".
String minSeg(Duration d) {
  final s = d.inSeconds;
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}

/// Barras de volume. [progresso] (0 a 1) pinta o que já tocou com a cor de destaque.
class OndaAudio extends StatelessWidget {
  const OndaAudio({super.key, required this.niveis, this.progresso, this.altura = 36, this.ativa});
  final List<double> niveis;
  final double? progresso;
  final double altura;

  /// Cor das barras (padrão: o que tocou em verde, o resto apagado).
  final Color? ativa;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return SizedBox(
      height: altura,
      child: CustomPaint(
        size: Size.infinite,
        painter: _PintorOnda(
          niveis: niveis,
          progresso: progresso ?? 0,
          tocou: ativa ?? c.accent,
          resto: c.muted.withValues(alpha: 0.32),
        ),
      ),
    );
  }
}

class _PintorOnda extends CustomPainter {
  _PintorOnda({required this.niveis, required this.progresso, required this.tocou, required this.resto});
  final List<double> niveis;
  final double progresso;
  final Color tocou;
  final Color resto;

  @override
  void paint(Canvas canvas, Size size) {
    if (niveis.isEmpty) return;
    final n = niveis.length;
    final passo = size.width / n;
    final largura = (passo * 0.6).clamp(1.5, 4.0);
    final p = Paint()..strokeCap = StrokeCap.round;
    for (var i = 0; i < n; i++) {
      final h = (size.height * (0.12 + 0.88 * niveis[i].clamp(0.0, 1.0))).clamp(largura, size.height);
      final x = passo * i + passo / 2;
      p
        ..color = (i + 0.5) / n <= progresso ? tocou : resto
        ..strokeWidth = largura;
      canvas.drawLine(
        Offset(x, (size.height - h) / 2 + largura / 2),
        Offset(x, (size.height + h) / 2 - largura / 2),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(_PintorOnda old) =>
      old.progresso != progresso || old.niveis != niveis || old.tocou != tocou || old.resto != resto;
}

/// Toca um áudio de nota: play/pausa, onda com o progresso (toque para pular),
/// tempo e velocidade. O arquivo vem do aparelho ou, se está na nuvem, é
/// baixado na primeira vez.
class PlayerAudio extends StatefulWidget {
  const PlayerAudio({super.key, required this.repo, required this.anexo, this.grande = false});
  final AnotacoesRepo repo;
  final AnexoNota anexo;
  final bool grande;

  @override
  State<PlayerAudio> createState() => _PlayerAudioState();
}

class _PlayerAudioState extends State<PlayerAudio> {
  AudioPlayer? _player;
  final _assinaturas = <StreamSubscription<Object?>>[];
  bool _tocando = false;
  bool _carregando = false;
  Duration _pos = Duration.zero;
  double _velocidade = 1;
  String? _aviso;

  Duration get _dur => widget.anexo.duracao;

  Future<AudioPlayer?> _preparar() async {
    if (_player != null) return _player;
    setState(() => _carregando = true);
    final cofre = widget.repo.cofreAudios;
    final ref = widget.anexo.refAudio;
    // No aparelho toca do arquivo; na web (sem pasta), dos bytes guardados no navegador.
    final pronto = await cofre.obter(ref);
    final caminho = pronto ? await cofre.caminho(ref) : null;
    final bytes = pronto && caminho == null ? await cofre.ler(ref) : null;
    if (!mounted) return null;
    if (caminho == null && bytes == null) {
      setState(() {
        _carregando = false;
        _aviso = !widget.anexo.naNuvem
            ? 'Áudio guardado em outro aparelho'
            : widget.repo.cofreAudios.armazem == null
            ? 'Entre na sua conta para ouvir'
            : 'Sem conexão para baixar o áudio';
      });
      return null;
    }
    final p = AudioPlayer();
    _assinaturas
      ..add(
        p.onPositionChanged.listen((d) {
          if (mounted) setState(() => _pos = d);
        }),
      )
      ..add(
        p.onPlayerComplete.listen((_) {
          if (mounted) {
            setState(() {
              _tocando = false;
              _pos = Duration.zero;
            });
          }
        }),
      );
    await p.setSource(
      caminho != null
          ? DeviceFileSource(caminho, mimeType: widget.anexo.formato)
          : BytesSource(bytes!, mimeType: widget.anexo.formato),
    );
    _player = p;
    if (mounted) setState(() => _carregando = false);
    return p;
  }

  Future<void> _alternar() async {
    final p = await _preparar();
    if (p == null) return;
    if (_tocando) {
      await p.pause();
    } else {
      await p.setPlaybackRate(_velocidade);
      await p.resume();
    }
    if (mounted) setState(() => _tocando = !_tocando);
  }

  Future<void> _pular(double fracao) async {
    final p = await _preparar();
    if (p == null) return;
    final alvo = _dur * fracao.clamp(0.0, 1.0);
    await p.seek(alvo);
    if (mounted) setState(() => _pos = alvo);
  }

  Future<void> _trocarVelocidade() async {
    final nova = _velocidade == 1 ? 1.5 : (_velocidade == 1.5 ? 2.0 : 1.0);
    setState(() => _velocidade = nova);
    if (_tocando) await _player?.setPlaybackRate(nova);
  }

  @override
  void dispose() {
    for (final a in _assinaturas) {
      a.cancel();
    }
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final grande = widget.grande;
    final progresso = _dur.inMilliseconds == 0 ? 0.0 : _pos.inMilliseconds / _dur.inMilliseconds;
    final botao = grande ? 50.0 : 38.0;
    return Container(
      padding: EdgeInsets.fromLTRB(grande ? 14 : 8, grande ? 14 : 8, 12, grande ? 14 : 8),
      decoration: BoxDecoration(color: c.surface2.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: _tocando ? 'Pausar o áudio' : 'Ouvir o áudio',
            child: Material(
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(gradient: c.gradiente),
                child: InkWell(
                  onTap: _carregando ? null : _alternar,
                  child: SizedBox(
                    width: botao,
                    height: botao,
                    child: _carregando
                        ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2, color: c.noAccent),
                          )
                        : Icon(
                            _tocando ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: c.noAccent,
                            size: grande ? 28 : 22,
                          ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _aviso != null
                ? Text(
                    _aviso!,
                    style: manrope(13, peso: FontWeight.w600, cor: c.muted),
                  )
                : LayoutBuilder(
                    builder: (context, box) => GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (d) => _pular(d.localPosition.dx / box.maxWidth),
                      child: OndaAudio(
                        niveis: lerOnda(widget.anexo.onda),
                        progresso: progresso,
                        altura: grande ? 44 : 28,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Text(
            _pos == Duration.zero ? minSeg(_dur) : '${minSeg(_pos)} / ${minSeg(_dur)}',
            style: manrope(
              12,
              peso: FontWeight.w600,
              cor: c.muted,
            ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
          ),
          if (grande) ...[
            const SizedBox(width: 6),
            TextButton(
              onPressed: _trocarVelocidade,
              style: TextButton.styleFrom(minimumSize: const Size(44, 36)),
              child: Text(
                '${_velocidade == 1.5 ? '1,5' : _velocidade.toStringAsFixed(0)}×',
                style: manrope(12, peso: FontWeight.w700, cor: c.text),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Áudios sendo transcritos agora (para mostrar "Transcrevendo…" em qualquer tela).
final transcrevendo = ValueNotifier<Set<String>>(const {});

/// Transcreve em segundo plano; devolve a mensagem do problema, se houve.
Future<String?> transcreverNoFundo(AnotacoesRepo repo, AnexoNota a) async {
  if (transcrevendo.value.contains(a.id)) return null;
  transcrevendo.value = {...transcrevendo.value, a.id};
  try {
    return await repo.tentarTranscrever(a);
  } finally {
    transcrevendo.value = {...transcrevendo.value}..remove(a.id);
  }
}

/// Folha de gravação: começa a gravar ao abrir. Devolve o áudio ao tocar em
/// Parar (nulo se cancelou).
Future<AudioGravado?> gravarAudio(BuildContext context, {GravadorDeNota Function()? gravador}) =>
    abrirFolha<AudioGravado>(context, (ctx) => _FolhaGravacao(gravador: gravador));

class _FolhaGravacao extends StatefulWidget {
  const _FolhaGravacao({this.gravador});
  final GravadorDeNota Function()? gravador;

  @override
  State<_FolhaGravacao> createState() => _FolhaGravacaoState();
}

class _FolhaGravacaoState extends State<_FolhaGravacao> {
  late final _controle = ControleGravacao(gravador: widget.gravador);

  @override
  void initState() {
    super.initState();
    _controle.addListener(_mudou);
    _controle.comecar();
  }

  void _mudou() => setState(() {});

  @override
  void dispose() {
    _controle
      ..removeListener(_mudou)
      ..dispose();
    super.dispose();
  }

  Future<void> _parar() async {
    final audio = await _controle.parar();
    if (mounted && audio != null) Navigator.pop(context, audio);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final ctl = _controle;
    final gravando = ctl.fase == FaseGravacao.gravando;
    final pausada = ctl.fase == FaseGravacao.pausada;
    final cor = gravando ? c.bad : (pausada ? c.warn : c.muted);
    final status = switch (ctl.fase) {
      FaseGravacao.gravando => 'Gravando',
      FaseGravacao.pausada => 'Pausado',
      FaseGravacao.pronta => 'Salvando…',
      FaseGravacao.parada => ctl.aviso == null ? 'Preparando o microfone…' : 'Microfone indisponível',
    };
    final barras = [...List.filled(ControleGravacao.barrasAoVivo - ctl.recentes.length, 0.03), ...ctl.recentes];
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: c.line, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: cor,
                    shape: BoxShape.circle,
                    boxShadow: gravando ? [BoxShadow(color: cor.withValues(alpha: 0.7), blurRadius: 10)] : null,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  status,
                  style: manrope(13, peso: FontWeight.w700, cor: cor),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    await ctl.cancelar();
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
                  child: Text(
                    'Cancelar',
                    style: manrope(14, peso: FontWeight.w700, cor: c.muted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                minSeg(ctl.tempo),
                style: sora(44).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            ),
            const SizedBox(height: 14),
            OndaAudio(niveis: barras, progresso: 1, altura: 56, ativa: gravando ? c.accent : c.violeta),
            const SizedBox(height: 14),
            Text(
              ctl.aviso ?? 'Fale à vontade (até 10 minutos). A Aurora transcreve quando você terminar.',
              textAlign: TextAlign.center,
              style: manrope(13, cor: ctl.aviso == null ? c.muted : c.bad, altura: 1.4),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Redondo(
                  dica: pausada ? 'Continuar' : 'Pausar',
                  icone: pausada ? Icons.mic_rounded : Icons.pause_rounded,
                  aoTocar: gravando || pausada ? ctl.alternarPausa : null,
                ),
                const SizedBox(width: 26),
                _Redondo(
                  dica: 'Parar e salvar',
                  icone: Icons.stop_rounded,
                  principal: true,
                  aoTocar: gravando || pausada ? _parar : null,
                ),
                const SizedBox(width: 26 + 52),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Redondo extends StatelessWidget {
  const _Redondo({required this.dica, required this.icone, required this.aoTocar, this.principal = false});
  final String dica;
  final IconData icone;
  final VoidCallback? aoTocar;
  final bool principal;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final tam = principal ? 70.0 : 52.0;
    return Tooltip(
      message: dica,
      child: Opacity(
        opacity: aoTocar == null ? 0.45 : 1,
        child: Material(
          shape: CircleBorder(side: principal ? BorderSide.none : BorderSide(color: c.line)),
          clipBehavior: Clip.antiAlias,
          color: principal ? Colors.transparent : c.surface2,
          child: Ink(
            decoration: principal ? BoxDecoration(gradient: c.gradiente) : null,
            child: InkWell(
              onTap: aoTocar,
              child: SizedBox(
                width: tam,
                height: tam,
                child: Icon(
                  icone,
                  size: principal ? 30 : 22,
                  color: principal ? c.noAccent : c.text,
                  semanticLabel: dica,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Foto de uma nota (miniatura nas listas, inteira ao abrir), com a versão na
/// chave do cache como no Shape. Sem imagem: o aviso de onde ela está.
class ImagemAnexo extends StatefulWidget {
  const ImagemAnexo({
    super.key,
    required this.repo,
    required this.anexo,
    this.miniatura = true,
    this.ajuste = BoxFit.cover,
  });
  final AnotacoesRepo repo;
  final AnexoNota anexo;
  final bool miniatura;
  final BoxFit ajuste;

  @override
  State<ImagemAnexo> createState() => _ImagemAnexoState();
}

class _ImagemAnexoState extends State<ImagemAnexo> {
  late Future<File?> _arquivo = _buscar();

  Future<File?> _buscar() => widget.repo.cofreFotos.obter(widget.anexo.refFoto, miniatura: widget.miniatura);

  @override
  void didUpdateWidget(ImagemAnexo antigo) {
    super.didUpdateWidget(antigo);
    if (antigo.anexo.hash != widget.anexo.hash || antigo.anexo.naNuvem != widget.anexo.naNuvem) _arquivo = _buscar();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final aviso = Container(
      color: c.surface2,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.anexo.naNuvem ? Icons.cloud_off_rounded : Icons.devices_other_rounded, color: c.muted, size: 22),
          const SizedBox(height: 4),
          Text(
            widget.anexo.naNuvem ? 'Sem conexão para baixar a foto' : 'Foto guardada em outro aparelho',
            textAlign: TextAlign.center,
            style: manrope(11, peso: FontWeight.w600, cor: c.muted, altura: 1.25),
          ),
        ],
      ),
    );
    return FutureBuilder<File?>(
      future: _arquivo,
      builder: (context, snap) {
        final f = snap.data;
        if (f == null) return snap.connectionState == ConnectionState.done ? aviso : ColoredBox(color: c.surface2);
        return Image(
          image: _ArquivoComVersao(f, widget.anexo.hash ?? ''),
          fit: widget.ajuste,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => aviso,
        );
      },
    );
  }
}

/// FileImage com a versão (hash) na chave do cache de imagens.
class _ArquivoComVersao extends FileImage {
  const _ArquivoComVersao(super.file, this.versao);
  final String versao;

  @override
  bool operator ==(Object other) =>
      other is _ArquivoComVersao && other.file.path == file.path && other.versao == versao && other.scale == scale;

  @override
  int get hashCode => Object.hash(file.path, versao, scale);
}

/// Câmera ou galeria no celular; no computador, o seletor de arquivos.
Future<Uint8List?> escolherImagem(BuildContext context) async {
  final picker = ImagePicker();
  var origem = ImageSource.gallery;
  if (picker.supportsImageSource(ImageSource.camera)) {
    final escolha = await abrirFolha<ImageSource>(context, (ctx) {
      final c = ctx.cores;
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Foto na nota', style: sora(20)),
              const SizedBox(height: 12),
              ListTile(
                leading: Icon(Icons.photo_camera_outlined, color: c.accent),
                title: Text('Tirar foto', style: manrope(15, peso: FontWeight.w600)),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library_outlined, color: c.violeta),
                title: Text('Escolher da galeria', style: manrope(15, peso: FontWeight.w600)),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );
    });
    if (escolha == null) return null;
    origem = escolha;
  }
  final arquivo = await picker.pickImage(source: origem, requestFullMetadata: false);
  return arquivo?.readAsBytes();
}

/// Fotos dependem de arquivos no aparelho: na versão web ainda não. Áudios
/// funcionam em todo lugar (na web ficam no IndexedDB, ver DiscoAudiosNavegador).
const fotosDisponiveis = !kIsWeb;
