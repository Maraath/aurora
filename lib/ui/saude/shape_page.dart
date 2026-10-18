import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/nuvem.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/shape_repo.dart';
import '../componentes.dart';
import '../em_breve.dart';
import '../formulario.dart';
import 'comparar_shape.dart';

/// Escolhe uma foto e devolve os bytes (nulo se a pessoa desistir).
typedef EscolherFoto = Future<Uint8List?> Function(BuildContext context, AnguloShape angulo);

/// Saúde › Treino › Shape: o check-in de fotos do dia (frente, costas e lado)
/// e o histórico, para comparar a evolução.
class ShapePage extends StatefulWidget {
  const ShapePage({super.key, this.repo, this.escolher});

  /// Nos testes: repositório com pasta temporária e escolha de foto falsa.
  final ShapeRepo? repo;
  final EscolherFoto? escolher;

  @override
  State<ShapePage> createState() => _ShapePageState();
}

class _ShapePageState extends State<ShapePage> {
  ShapeRepo? _repo;
  Stream<List<CheckinShape>>? _checkins;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repo = widget.repo ?? ShapeRepo(AuroraEscopo.de(context).db);
    if (_repo?.db != repo.db) {
      _repo = repo;
      _checkins = repo.observarCheckins();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CheckinShape>>(
      stream: _checkins,
      builder: (context, snap) {
        if (snap.hasError) return Text('Não consegui ler as fotos: ${snap.error}');
        final lista = snap.data;
        if (lista == null) return const SizedBox(height: 200);
        return _conteudo(context, lista);
      },
    );
  }

  Widget _conteudo(BuildContext context, List<CheckinShape> checkins) {
    final c = context.cores;
    final hoje = hojeSP();
    final chaveHoje = chaveData(hoje);
    final deHoje = checkins.where((k) => k.dia == chaveHoje).firstOrNull ?? CheckinShape(chaveHoje, const {});
    final anteriores = checkins.where((k) => k.dia != chaveHoje).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TituloPagina('Shape'),
        const SizedBox(height: 4),
        Text(
          'Fotos de frente, costas e lado para ver a evolução. Onde elas ficam você escolhe em Conta › Fotos.',
          style: manrope(13, cor: c.muted, altura: 1.4),
        ),
        const SizedBox(height: 18),
        Cartao(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(tituloCheckin(deHoje.data, hoje), style: sora(18)),
              const SizedBox(height: 2),
              Text(
                deHoje.fotos.length == 3
                    ? 'Check-in completo. Toque numa foto para trocar ou apagar.'
                    : 'Toque numa vaga para enviar a foto.',
                style: manrope(12, cor: c.muted),
              ),
              const SizedBox(height: 14),
              _TrioFotos(repo: _repo!, checkin: deHoje, aoTocar: (a) => _tocarVaga(deHoje, a), grande: true),
            ],
          ),
        ),
        const SizedBox(height: 14),
        BotaoPilula(texto: 'Comparar evolução', principal: checkins.length >= 2, aoTocar: () => _comparar(checkins)),
        const SizedBox(height: 22),
        const TituloSecao('Histórico'),
        if (anteriores.isEmpty) const Vazio('Os check-ins dos dias anteriores aparecem aqui.'),
        ..._linhaDoTempo(context, anteriores, hoje),
      ],
    );
  }

  /// Check-ins anteriores agrupados por mês, numa linha do tempo.
  List<Widget> _linhaDoTempo(BuildContext context, List<CheckinShape> lista, DateTime hoje) {
    final c = context.cores;
    final itens = <Widget>[];
    String? mes;
    for (var i = 0; i < lista.length; i++) {
      final k = lista[i];
      final m = k.dia.substring(0, 7);
      if (m != mes) {
        mes = m;
        itens.add(
          Padding(
            padding: EdgeInsets.only(top: itens.isEmpty ? 0 : 10, bottom: 10),
            child: Text(
              mesAno(k.data).toUpperCase(),
              style: manrope(11, peso: FontWeight.w800, cor: c.muted, espaco: 1.2),
            ),
          ),
        );
      }
      final ultimo = i == lista.length - 1;
      itens.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Trilho da linha do tempo.
              SizedBox(
                width: 18,
                child: Column(
                  children: [
                    const SizedBox(height: 22),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
                    ),
                    if (!ultimo) Expanded(child: Container(width: 2, color: c.line)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Cartao(
                    raio: 18,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(tituloCheckin(k.data, hoje), style: manrope(15, peso: FontWeight.w700)),
                            ),
                            Text(diaRelativo(k.data, hoje), style: manrope(12, cor: c.muted)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _TrioFotos(repo: _repo!, checkin: k, aoTocar: (a) => _tocarVaga(k, a)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return itens;
  }

  Future<void> _tocarVaga(CheckinShape k, AnguloShape a) async {
    final foto = k.fotos[a];
    if (foto == null) return _enviar(k.data, a);
    final aqui = await _repo!.cofre.local(foto.ref) != null;
    if (!mounted) return;
    final acao = await abrirFolha<String>(
      context,
      (ctx) => _FolhaFoto(repo: _repo!, foto: foto, angulo: a, podeEnviar: aqui && !foto.naNuvem),
    );
    if (!mounted || acao == null) return;
    if (acao == 'trocar') await _enviar(k.data, a);
    if (acao == 'apagar') await _repo!.apagarFoto(foto);
    if (acao == 'nuvem') await _enviarParaNuvem(foto);
  }

  Future<void> _enviarParaNuvem(FotoShape foto) async {
    final aviso = ScaffoldMessenger.of(context);
    try {
      await _repo!.enviarParaNuvem(foto);
      aviso.showSnackBar(const SnackBar(content: Text('Foto enviada para a nuvem.')));
    } catch (e) {
      aviso.showSnackBar(SnackBar(
        content: Text(e is StateError ? e.message : 'Não consegui enviar agora: ${mensagemDeErro(e)}'),
      ));
    }
  }

  Future<void> _enviar(DateTime dia, AnguloShape a) async {
    final bytes = await (widget.escolher ?? escolherFotoDoAparelho)(context, a);
    if (bytes == null || !mounted) return;
    try {
      await _repo!.salvarFoto(dia, a, bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não consegui usar essa imagem: $e')));
    }
  }

  void _comparar(List<CheckinShape> checkins) {
    if (checkins.length < 2) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Faça check-ins em pelo menos dois dias para comparar.')));
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => CompararShapePage(repo: _repo!, checkins: checkins),
      ),
    );
  }
}

/// "Check-in de 17 de outubro" (com o ano, se não for o atual).
String tituloCheckin(DateTime dia, DateTime hoje) =>
    'Check-in de ${diaMesLongo(dia)}${dia.year == hoje.year ? '' : ' de ${dia.year}'}';

/// Câmera ou galeria no celular; no computador, o seletor de arquivos.
Future<Uint8List?> escolherFotoDoAparelho(BuildContext context, AnguloShape angulo) async {
  final picker = ImagePicker();
  var origem = ImageSource.gallery;
  if (picker.supportsImageSource(ImageSource.camera)) {
    final escolha = await abrirFolha<ImageSource>(context, (ctx) => _FolhaOrigem(angulo: angulo));
    if (escolha == null) return null;
    origem = escolha;
  }
  final arquivo = await picker.pickImage(source: origem, requestFullMetadata: false);
  return arquivo?.readAsBytes();
}

/// As três vagas (frente, costas, lado), lado a lado.
class _TrioFotos extends StatelessWidget {
  const _TrioFotos({required this.repo, required this.checkin, required this.aoTocar, this.grande = false});
  final ShapeRepo repo;
  final CheckinShape checkin;
  final ValueChanged<AnguloShape> aoTocar;
  final bool grande;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (final a in AnguloShape.values) ...[
        if (a.index > 0) SizedBox(width: grande ? 12 : 8),
        Expanded(
          child: VagaFoto(repo: repo, angulo: a, foto: checkin.fotos[a], aoTocar: () => aoTocar(a), compacta: !grande),
        ),
      ],
    ],
  );
}

/// Silhueta de cada ângulo para a vaga vazia.
IconData iconeAngulo(AnguloShape a) => switch (a) {
  AnguloShape.frente => Icons.accessibility_new_rounded,
  AnguloShape.costas => Icons.accessibility_rounded,
  AnguloShape.lado => Icons.directions_walk_rounded,
};

/// Uma vaga de foto (3:4). Vazia: silhueta na cor de destaque e "Enviar";
/// cheia: a prévia, com o ângulo em cima.
class VagaFoto extends StatelessWidget {
  const VagaFoto({
    super.key,
    required this.repo,
    required this.angulo,
    required this.foto,
    required this.aoTocar,
    this.compacta = false,
  });

  final ShapeRepo repo;
  final AnguloShape angulo;
  final FotoShape? foto;
  final VoidCallback aoTocar;
  final bool compacta;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final raio = BorderRadius.circular(compacta ? 12 : 16);
    final vazia = foto == null;
    return Semantics(
      button: true,
      label: vazia ? 'Enviar foto de ${angulo.rotulo.toLowerCase()}' : 'Foto de ${angulo.rotulo.toLowerCase()}',
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Material(
          color: vazia ? c.accentSoft : c.surface2,
          shape: RoundedRectangleBorder(
            borderRadius: raio,
            side: BorderSide(color: vazia ? c.accent.withValues(alpha: 0.35) : c.line),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: aoTocar,
            child: ExcludeSemantics(
              child: vazia
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(iconeAngulo(angulo), size: compacta ? 28 : 44, color: c.accent),
                        SizedBox(height: compacta ? 4 : 8),
                        Text(
                          angulo.rotulo,
                          style: manrope(compacta ? 11 : 13, peso: FontWeight.w700, cor: c.text),
                        ),
                        if (!compacta) ...[
                          const SizedBox(height: 2),
                          Text(
                            '+ Enviar',
                            style: manrope(12, peso: FontWeight.w700, cor: c.accent),
                          ),
                        ],
                      ],
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        ImagemShape(repo: repo, foto: foto!, miniatura: compacta, larguraCache: compacta ? 240 : 480),
                        Positioned(
                          left: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xAA06061A),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              angulo.rotulo,
                              style: manrope(10, peso: FontWeight.w700, cor: const Color(0xFFEEF0FB)),
                            ),
                          ),
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

/// A imagem da foto, cortada para preencher (cover). [miniatura] no histórico e
/// em grades pequenas; a inteira nas vagas grandes e quando a pessoa abre a foto (a
/// miniatura de 300 px fica borrada ampliada). Vem da cópia do aparelho
/// ou, se está na nuvem, é baixada uma vez e guardada. Sem imagem: "Foto
/// guardada em outro aparelho" (não foi para a nuvem), "Entre na sua conta" ou
/// "Sem conexão".
class ImagemShape extends StatefulWidget {
  const ImagemShape({super.key, required this.repo, required this.foto, this.miniatura = false, this.larguraCache});
  final ShapeRepo repo;
  final FotoShape foto;
  final bool miniatura;
  final int? larguraCache;

  @override
  State<ImagemShape> createState() => _ImagemShapeState();
}

class _ImagemShapeState extends State<ImagemShape> {
  late Future<File?> _arquivo = _buscar();

  Future<File?> _buscar() => widget.repo.cofre.obter(widget.foto.ref, miniatura: widget.miniatura);

  @override
  void didUpdateWidget(ImagemShape antigo) {
    super.didUpdateWidget(antigo);
    if (antigo.foto.hash != widget.foto.hash ||
        antigo.foto.naNuvem != widget.foto.naNuvem ||
        antigo.miniatura != widget.miniatura) {
      _arquivo = _buscar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final emOutro = !widget.foto.naNuvem;
    final semConta = widget.repo.cofre.armazem == null;
    final aviso = LayoutBuilder(
      builder: (context, box) {
        final pequeno = box.maxWidth < 120;
        return Container(
          color: c.surface2,
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(emOutro ? Icons.devices_other_rounded : Icons.cloud_off_rounded,
                color: c.muted, size: pequeno ? 20 : 30),
            const SizedBox(height: 6),
            Text(
              emOutro
                  ? 'Foto guardada em outro aparelho'
                  : semConta
                      ? 'Entre na sua conta para ver a foto'
                      : 'Sem conexão para baixar a foto',
              textAlign: TextAlign.center,
              style: manrope(pequeno ? 9.5 : 12, peso: FontWeight.w600, cor: c.muted, altura: 1.25),
            ),
          ]),
        );
      },
    );
    return FutureBuilder<File?>(
      future: _arquivo,
      builder: (context, snap) {
        final f = snap.data;
        if (f == null) return snap.connectionState == ConnectionState.done ? aviso : const SizedBox();
        final dpr = MediaQuery.devicePixelRatioOf(context);
        return Image(
          image: ResizeImage.resizeIfNeeded(
            widget.larguraCache == null ? null : (widget.larguraCache! * dpr).round(),
            null,
            _ArquivoVersionado(f, widget.foto.hash ?? ''),
          ),
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => aviso,
        );
      },
    );
  }
}

/// Arquivo de foto com a versão (hash) na chave do cache de imagens: a foto
/// trocada fica no mesmo caminho (`<id>.webp`), e o FileImage comum, que só
/// compara o caminho, continuaria mostrando a versão antiga da memória.
class _ArquivoVersionado extends FileImage {
  const _ArquivoVersionado(super.file, this.versao);
  final String versao;

  @override
  bool operator ==(Object other) =>
      other is _ArquivoVersionado && other.file.path == file.path && other.versao == versao && other.scale == scale;

  @override
  int get hashCode => Object.hash(file.path, versao, scale);
}

class _FolhaOrigem extends StatelessWidget {
  const _FolhaOrigem({required this.angulo});
  final AnguloShape angulo;

  @override
  Widget build(BuildContext context) => _FolhaOpcoes(
    titulo: 'Foto de ${angulo.rotulo.toLowerCase()}',
    opcoes: [
      (Icons.photo_camera_outlined, 'Tirar foto', ImageSource.camera, false),
      (Icons.photo_library_outlined, 'Escolher da galeria', ImageSource.gallery, false),
    ],
  );
}

/// Foto já enviada: ver a foto inteira, onde ela está guardada, trocar,
/// enviar para a nuvem ou apagar.
class _FolhaFoto extends StatelessWidget {
  const _FolhaFoto({required this.repo, required this.foto, required this.angulo, required this.podeEnviar});
  final ShapeRepo repo;
  final FotoShape foto;
  final AnguloShape angulo;

  /// A imagem está neste aparelho e ainda não está na nuvem.
  final bool podeEnviar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return _FolhaOpcoes(
      titulo: '${angulo.rotulo} · ${diaMesLongo(DateTime.parse(foto.dia))}',
      topo: Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.45),
            child: AspectRatio(aspectRatio: 3 / 4, child: ImagemShape(repo: repo, foto: foto)),
          ),
        ),
        const SizedBox(height: 10),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(foto.naNuvem ? Icons.cloud_done_outlined : Icons.phone_android_rounded, size: 16, color: c.muted),
          const SizedBox(width: 6),
          Text(foto.naNuvem ? 'Na nuvem' : 'Só neste aparelho', style: manrope(12.5, cor: c.muted)),
        ]),
      ]),
      opcoes: [
        (Icons.swap_horiz_rounded, 'Trocar foto', 'trocar', false),
        if (podeEnviar) (Icons.cloud_upload_outlined, 'Enviar para a nuvem', 'nuvem', false),
        (Icons.delete_outline_rounded, 'Apagar foto', 'apagar', true),
      ],
    );
  }
}

class _FolhaOpcoes<T> extends StatelessWidget {
  const _FolhaOpcoes({required this.titulo, required this.opcoes, this.topo});
  final String titulo;
  final List<(IconData, String, T, bool)> opcoes;
  final Widget? topo;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: c.line, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 14),
            Text(titulo, style: sora(20)),
            const SizedBox(height: 14),
            if (topo != null) ...[Center(child: topo), const SizedBox(height: 14)],
            for (final (icone, texto, valor, perigo) in opcoes)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Cartao(
                  raio: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  aoTocar: () => Navigator.pop(context, valor),
                  child: Row(
                    children: [
                      Icon(icone, color: perigo ? c.bad : c.accent),
                      const SizedBox(width: 12),
                      Text(
                        texto,
                        style: manrope(15, peso: FontWeight.w600, cor: perigo ? c.bad : c.text),
                      ),
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
