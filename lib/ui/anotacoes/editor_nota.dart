import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/formato.dart';
import '../../core/tema.dart';
import '../../data/anotacoes_repo.dart';
import '../../data/banco.dart';
import '../../data/gravacao_nota.dart';
import '../ceu_estrelado.dart';
import '../componentes.dart';
import 'anexos_ui.dart';

/// Editor de uma nota: título, texto, caixinhas, áudios (com a transcrição) e
/// fotos. Salva sozinho meio segundo depois de cada mudança. Nota largada em
/// branco some ao fechar.
class EditorNota extends StatefulWidget {
  const EditorNota({
    super.key,
    required this.repo,
    required this.id,
    this.aoFechar,
    this.focarTitulo = false,
    this.gravador,
    this.escolherFoto,
  });

  final AnotacoesRepo repo;
  final String id;

  /// Botão X (painel ao lado); nulo quando a nota ocupa a tela (o voltar fecha).
  final VoidCallback? aoFechar;
  final bool focarTitulo;

  /// Nos testes: microfone e seletor de foto falsos.
  final GravadorDeNota Function()? gravador;
  final Future<Uint8List?> Function(BuildContext)? escolherFoto;

  @override
  State<EditorNota> createState() => _EditorNotaState();
}

class _ItemEditavel {
  _ItemEditavel(ItemLista i) : controle = TextEditingController(text: i.texto), feito = i.feito;
  final TextEditingController controle;
  final foco = FocusNode();
  bool feito;

  ItemLista get item => ItemLista(controle.text, feito: feito);

  void dispose() {
    controle.dispose();
    foco.dispose();
  }
}

class _EditorNotaState extends State<EditorNota> {
  AnotacoesRepo get _repo => widget.repo;
  final _titulo = TextEditingController();
  final _texto = TextEditingController();
  final _focoTitulo = FocusNode();
  final _focoTexto = FocusNode();
  final List<_ItemEditavel> _itens = [];
  StreamSubscription<QuadroNotas>? _assinatura;
  QuadroNotas? _quadro;
  NotaCompleta? _nota;
  Timer? _espera;
  bool _pendente = false;
  bool _carregada = false;

  @override
  void initState() {
    super.initState();
    _assinatura = _repo.observarQuadro().listen(_recebeu);
  }

  void _recebeu(QuadroNotas q) {
    final n = q.nota(widget.id);
    if (!mounted) return;
    if (!_carregada && n != null) {
      _carregada = true;
      _titulo.text = n.nota.titulo;
      _texto.text = n.nota.texto;
      _itens.addAll([for (final i in n.itens) _ItemEditavel(i)]);
      if (widget.focarTitulo) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (n.nota.tipo == TipoNota.lista && _itens.isNotEmpty) {
            _itens.first.foco.requestFocus();
          } else {
            _focoTitulo.requestFocus();
          }
        });
      }
    }
    setState(() {
      _quadro = q;
      _nota = n;
    });
  }

  @override
  void dispose() {
    _assinatura?.cancel();
    _espera?.cancel();
    final repo = _repo, id = widget.id;
    final salvar = _pendente ? _salvarAgora() : Future<void>.value();
    salvar.then((_) => repo.descartarSeVazia(id)).ignore();
    _titulo.dispose();
    _texto.dispose();
    _focoTitulo.dispose();
    _focoTexto.dispose();
    for (final i in _itens) {
      i.dispose();
    }
    super.dispose();
  }

  void _mudou() {
    _pendente = true;
    _espera?.cancel();
    _espera = Timer(const Duration(milliseconds: 500), _salvarAgora);
    if (mounted) setState(() {});
  }

  Future<void> _salvarAgora() async {
    _espera?.cancel();
    if (!_pendente) return;
    _pendente = false;
    await _repo.salvarNota(
      widget.id,
      titulo: _titulo.text,
      texto: _texto.text,
      itens: [for (final i in _itens) i.item],
    );
  }

  // ---------- caixinhas ----------

  void _novoItem({int? depois}) {
    final novo = _ItemEditavel(const ItemLista(''));
    setState(() => _itens.insert(depois == null ? _itens.length : depois + 1, novo));
    WidgetsBinding.instance.addPostFrameCallback((_) => novo.foco.requestFocus());
    _mudou();
  }

  void _tirarItem(_ItemEditavel i) {
    final pos = _itens.indexOf(i);
    setState(() => _itens.remove(i));
    i.dispose();
    if (pos > 0) _itens[pos - 1].foco.requestFocus();
    _mudou();
  }

  // ---------- ações ----------

  Future<void> _gravar() async {
    await _salvarAgora();
    if (!mounted) return;
    final audio = await gravarAudio(context, gravador: widget.gravador);
    if (audio == null || !mounted) return;
    final anexo = await _repo.adicionarAudio(widget.id, audio);
    final erro = await transcreverNoFundo(_repo, anexo);
    if (erro != null && mounted) _avisar(erro);
  }

  Future<void> _foto() async {
    final bytes = await (widget.escolherFoto ?? escolherImagem)(context);
    if (bytes == null || !mounted) return;
    try {
      await _repo.adicionarFoto(widget.id, bytes);
    } catch (e) {
      if (mounted) _avisar('Não consegui usar essa imagem.');
    }
  }

  Future<void> _escolherPasta() async {
    final quadro = _quadro;
    if (quadro == null) return;
    final escolha = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.cores.surface,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text('Mover para a pasta', style: sora(18)),
            ),
            ListTile(
              leading: const Icon(Icons.inbox_outlined),
              title: const Text('Sem pasta'),
              onTap: () => Navigator.pop(ctx, ''),
            ),
            for (final p in quadro.pastas)
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(p.nome),
                selected: p.id == _nota?.nota.pastaId,
                onTap: () => Navigator.pop(ctx, p.id),
              ),
            ListTile(
              leading: const Icon(Icons.create_new_folder_outlined),
              title: const Text('Nova pasta…'),
              onTap: () => Navigator.pop(ctx, '+'),
            ),
          ],
        ),
      ),
    );
    if (escolha == null || !mounted) return;
    var id = escolha;
    if (escolha == '+') {
      final nome = await pedirNomePasta(context);
      if (nome == null) return;
      id = await _repo.criarPasta(nome);
    }
    await _repo.salvarNota(widget.id, pastaId: Value(id.isEmpty ? null : id));
  }

  Future<void> _apagar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.cores.surface,
        title: Text('Apagar esta nota?', style: sora(18)),
        content: Text(
          'A nota sai da lista, com as fotos e os áudios dela.',
          style: manrope(14, cor: ctx.cores.text, altura: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Apagar', style: TextStyle(color: ctx.cores.bad)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _salvarAgora();
    final repo = _repo, id = widget.id;
    await repo.apagarNota(id);
    if (!mounted) return;
    final aviso = ScaffoldMessenger.of(context);
    _fechar();
    aviso.showSnackBar(
      SnackBar(
        content: const Text('Nota apagada.'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(label: 'Desfazer', onPressed: () => repo.desfazerApagar(id)),
      ),
    );
  }

  void _fechar() {
    if (widget.aoFechar != null) {
      widget.aoFechar!();
    } else {
      Navigator.maybePop(context);
    }
  }

  void _avisar(String texto) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto), behavior: SnackBarBehavior.floating));

  Future<void> _abrirFoto(AnexoNota a) async {
    final acao = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final c = ctx.cores;
        return Dialog(
          backgroundColor: c.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720, maxHeight: 640),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: ImagemAnexo(repo: _repo, anexo: a, miniatura: false, ajuste: BoxFit.contain),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 4,
                    children: [
                      if (!a.naNuvem)
                        TextButton.icon(
                          onPressed: () => Navigator.pop(ctx, 'nuvem'),
                          icon: const Icon(Icons.cloud_upload_outlined),
                          label: const Text('Enviar para a nuvem'),
                        ),
                      TextButton.icon(
                        onPressed: () => Navigator.pop(ctx, 'apagar'),
                        icon: Icon(Icons.delete_outline_rounded, color: c.bad),
                        label: Text('Tirar da nota', style: TextStyle(color: c.bad)),
                      ),
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted) return;
    if (acao == 'apagar') await _repo.apagarAnexo(a);
    if (acao == 'nuvem') await _enviarParaNuvem(a);
  }

  Future<void> _enviarParaNuvem(AnexoNota a) async {
    try {
      await _repo.enviarParaNuvem(a);
      if (mounted) _avisar(a.ehFoto ? 'Foto enviada para a nuvem.' : 'Áudio enviado para a nuvem.');
    } on StateError catch (e) {
      if (mounted) _avisar(e.message);
    } catch (_) {
      if (mounted) _avisar('Não consegui enviar agora. Tente de novo com internet.');
    }
  }

  Future<void> _opcoesAudio(AnexoNota a) async {
    final c = context.cores;
    final acao = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: c.surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            if ((a.transcricao ?? '').isNotEmpty)
              ListTile(
                leading: const Icon(Icons.notes_rounded),
                title: const Text('Copiar a transcrição para o texto'),
                onTap: () => Navigator.pop(ctx, 'copiar'),
              ),
            ListTile(
              leading: const Icon(Icons.refresh_rounded),
              title: const Text('Transcrever de novo'),
              onTap: () => Navigator.pop(ctx, 'transcrever'),
            ),
            if (!a.naNuvem)
              ListTile(
                leading: const Icon(Icons.cloud_upload_outlined),
                title: const Text('Enviar para a nuvem'),
                onTap: () => Navigator.pop(ctx, 'nuvem'),
              ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: c.bad),
              title: Text('Apagar o áudio', style: TextStyle(color: c.bad)),
              onTap: () => Navigator.pop(ctx, 'apagar'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!mounted || acao == null) return;
    switch (acao) {
      case 'copiar':
        final t = a.transcricao!.trim();
        _texto.text = _texto.text.trim().isEmpty ? t : '${_texto.text.trimRight()}\n\n$t';
        _mudou();
      case 'transcrever':
        final erro = await transcreverNoFundo(_repo, a);
        if (erro != null && mounted) _avisar(erro);
      case 'nuvem':
        await _enviarParaNuvem(a);
      case 'apagar':
        await _repo.apagarAnexo(a);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final n = _nota;
    if (n == null) {
      return Center(
        // Recém-criada ainda pode não ter chegado: só avisa se já tinha aberto.
        child: Text(_carregada ? 'Esta nota foi apagada.' : '', style: manrope(14, cor: c.muted)),
      );
    }
    final pasta = _quadro?.pasta(n.nota.pastaId);
    final atualizada = n.nota.atualizadoEm.toLocal();
    // Tela estreita (celular): botões mais juntos para caber numa linha.
    final estreita = MediaQuery.sizeOf(context).width < 560;
    final barra = Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: IconButtonTheme(
        data: IconButtonThemeData(
          style: estreita
              ? IconButton.styleFrom(visualDensity: VisualDensity.compact, minimumSize: const Size(40, 44))
              : null,
        ),
        child: Row(
          children: [
            if (widget.aoFechar != null)
              IconButton(
                tooltip: 'Fechar a nota',
                onPressed: _fechar,
                icon: Icon(Icons.close_rounded, color: c.text),
              )
            else
              IconButton(
                tooltip: 'Voltar',
                onPressed: _fechar,
                icon: Icon(Icons.chevron_left_rounded, size: 28, color: c.text),
              ),
            const SizedBox(width: 4),
            Flexible(
              child: ActionChip(
                avatar: Icon(Icons.folder_outlined, size: 16, color: c.accent),
                label: Text(pasta?.nome ?? 'Sem pasta', overflow: TextOverflow.ellipsis),
                labelStyle: manrope(12, peso: FontWeight.w600, cor: c.text),
                backgroundColor: c.surface2,
                side: BorderSide.none,
                shape: const StadiumBorder(),
                onPressed: _escolherPasta,
              ),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Caixinha de lista',
              onPressed: () => _novoItem(),
              icon: Icon(Icons.checklist_rounded, color: c.teal),
            ),
            if (anexosDisponiveis) ...[
              IconButton(
                tooltip: 'Foto',
                onPressed: _foto,
                icon: Icon(Icons.image_outlined, color: c.warn),
              ),
              IconButton(
                tooltip: 'Gravar áudio',
                onPressed: _gravar,
                icon: Icon(Icons.mic_none_rounded, color: c.bad),
              ),
            ],
            IconButton(
              tooltip: n.nota.fixada ? 'Desafixar' : 'Fixar no topo',
              onPressed: () => _repo.salvarNota(widget.id, fixada: !n.nota.fixada),
              icon: Icon(
                n.nota.fixada ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                color: n.nota.fixada ? c.warn : c.muted,
              ),
            ),
            IconButton(
              tooltip: 'Apagar nota',
              onPressed: _apagar,
              icon: Icon(Icons.delete_outline_rounded, color: c.muted),
            ),
          ],
        ),
      ),
    );

    final campos = InputDecoration(
      border: InputBorder.none,
      isDense: true,
      contentPadding: EdgeInsets.zero,
      hintStyle: manrope(15, cor: c.muted),
    );
    final corpo = ListView(
      padding: const EdgeInsets.fromLTRB(28, 4, 28, 40),
      children: [
        Center(
          child: Text(
            '${diaMesLongo(atualizada)} de ${atualizada.year} às ${hora(atualizada)}'
            '${_pendente ? ' · salvando…' : ' · salva'}',
            style: manrope(12, cor: c.muted),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _titulo,
          focusNode: _focoTitulo,
          onChanged: (_) => _mudou(),
          textCapitalization: TextCapitalization.sentences,
          style: sora(24),
          cursorColor: c.accent,
          maxLines: null,
          decoration: campos.copyWith(
            hintText: 'Título',
            hintStyle: sora(24, cor: c.muted.withValues(alpha: 0.6)),
          ),
          onSubmitted: (_) => _focoTexto.requestFocus(),
        ),
        const SizedBox(height: 12),
        for (final a in n.audios) ...[
          _BlocoAudio(repo: _repo, anexo: a, aoOpcoes: () => _opcoesAudio(a)),
          const SizedBox(height: 14),
        ],
        TextField(
          controller: _texto,
          focusNode: _focoTexto,
          onChanged: (_) => _mudou(),
          textCapitalization: TextCapitalization.sentences,
          style: manrope(15, cor: c.text, altura: 1.6),
          cursorColor: c.accent,
          maxLines: null,
          minLines: n.nota.tipo == TipoNota.lista || n.nota.tipo == TipoNota.audio ? 1 : 3,
          keyboardType: TextInputType.multiline,
          decoration: campos.copyWith(
            hintText: n.nota.tipo == TipoNota.lista ? 'Uma observação (opcional)' : 'Escreva aqui…',
          ),
        ),
        if (_itens.isNotEmpty || n.nota.tipo == TipoNota.lista) ...[
          const SizedBox(height: 10),
          for (var i = 0; i < _itens.length; i++) _linhaItem(c, i),
          _NovoItem(aoTocar: () => _novoItem()),
        ],
        if (n.fotos.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final f in n.fotos)
                Semantics(
                  button: true,
                  label: 'Abrir a foto',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _abrirFoto(f),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 180,
                        height: 130,
                        child: ImagemAnexo(repo: _repo, anexo: f),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        barra,
        Divider(height: 1, color: c.line),
        Expanded(child: corpo),
      ],
    );
  }

  Widget _linhaItem(AuroraCores c, int pos) {
    final it = _itens[pos];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Semantics(
            checked: it.feito,
            label: it.controle.text.isEmpty ? 'Caixinha' : it.controle.text,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                setState(() => it.feito = !it.feito);
                _mudou();
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: MarcaConcluir(feito: it.feito),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.backspace): () {
                  if (it.controle.text.isEmpty) _tirarItem(it);
                },
              },
              child: TextField(
                controller: it.controle,
                focusNode: it.foco,
                onChanged: (_) => _mudou(),
                onSubmitted: (_) => _novoItem(depois: pos),
                // Sem isto o Enter mandaria o foco para o botão X, e a primeira
                // letra do próximo item se perderia até o item novo aparecer.
                onEditingComplete: () {},
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
                style: manrope(
                  15,
                  cor: it.feito ? c.muted : c.text,
                  peso: FontWeight.w500,
                ).copyWith(decoration: it.feito ? TextDecoration.lineThrough : null),
                cursorColor: c.accent,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: 'Item',
                  hintStyle: manrope(15, cor: c.muted),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Tirar o item',
            onPressed: () => _tirarItem(it),
            icon: Icon(Icons.close_rounded, size: 18, color: c.muted),
          ),
        ],
      ),
    );
  }
}

class _NovoItem extends StatelessWidget {
  const _NovoItem({required this.aoTocar});
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: aoTocar,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          children: [
            Icon(Icons.add_rounded, color: c.muted, size: 22),
            const SizedBox(width: 12),
            Text('Novo item', style: manrope(15, cor: c.muted)),
          ],
        ),
      ),
    );
  }
}

/// Player do áudio e, embaixo, a transcrição (ou o estado dela).
class _BlocoAudio extends StatelessWidget {
  const _BlocoAudio({required this.repo, required this.anexo, required this.aoOpcoes});
  final AnotacoesRepo repo;
  final AnexoNota anexo;
  final VoidCallback aoOpcoes;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: PlayerAudio(repo: repo, anexo: anexo, grande: true),
            ),
            IconButton(
              tooltip: 'Opções do áudio',
              onPressed: aoOpcoes,
              icon: Icon(Icons.more_vert_rounded, color: c.muted),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(anexo.naNuvem ? Icons.cloud_done_outlined : Icons.smartphone_rounded, size: 14, color: c.muted),
            const SizedBox(width: 6),
            Text(anexo.naNuvem ? 'Na nuvem' : 'Só neste aparelho', style: manrope(12, cor: c.muted)),
          ],
        ),
        const SizedBox(height: 10),
        ValueListenableBuilder<Set<String>>(
          valueListenable: transcrevendo,
          builder: (context, ids, _) {
            final t = anexo.transcricao;
            if (ids.contains(anexo.id)) {
              return Row(
                children: [
                  SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: c.violeta)),
                  const SizedBox(width: 10),
                  Text('Transcrevendo…', style: manrope(14, cor: c.muted)),
                ],
              );
            }
            if (t == null) {
              return Row(
                children: [
                  Expanded(
                    child: Text('Ainda sem transcrição.', style: manrope(14, cor: c.muted)),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final erro = await transcreverNoFundo(repo, anexo);
                      if (erro != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
                      }
                    },
                    icon: Icon(Icons.auto_awesome_rounded, size: 18, color: c.accent),
                    label: Text(
                      'Transcrever',
                      style: manrope(13, peso: FontWeight.w700, cor: c.text),
                    ),
                  ),
                ],
              );
            }
            if (t.isEmpty) return Text('Não ouvi fala neste áudio.', style: manrope(14, cor: c.muted));
            return Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.violeta.withValues(alpha: 0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TRANSCRIÇÃO', style: rotulo(c.violeta)),
                  const SizedBox(height: 6),
                  SelectableText(t, style: manrope(15, cor: c.text, altura: 1.6)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Pede o nome de uma pasta (nova ou renomeada).
Future<String?> pedirNomePasta(BuildContext context, {String inicial = ''}) async {
  final controle = TextEditingController(text: inicial);
  final nome = await showDialog<String>(
    context: context,
    builder: (ctx) {
      final c = ctx.cores;
      return AlertDialog(
        backgroundColor: c.surface,
        title: Text(inicial.isEmpty ? 'Nova pasta' : 'Renomear pasta', style: sora(18)),
        content: TextField(
          controller: controle,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Ideias, Trabalho, Receitas…'),
          onSubmitted: (t) => Navigator.pop(ctx, t),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, controle.text), child: const Text('Salvar')),
        ],
      );
    },
  );
  controle.dispose();
  final t = nome?.trim();
  return t == null || t.isEmpty ? null : t;
}

/// A nota ocupando a tela (celular e "Lista" no celular).
class PaginaNota extends StatelessWidget {
  const PaginaNota({super.key, required this.repo, required this.id, this.focarTitulo = false});
  final AnotacoesRepo repo;
  final String id;
  final bool focarTitulo;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.cores.bg,
    body: CeuEstrelado(
      child: SafeArea(
        child: EditorNota(repo: repo, id: id, focarTitulo: focarTitulo),
      ),
    ),
  );
}
