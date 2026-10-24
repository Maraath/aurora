import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/anotacoes_repo.dart';
import '../../data/banco.dart';
import '../../data/gravacao_nota.dart';
import '../componentes.dart';
import '../formulario.dart';
import '../vidro.dart';
import 'anexos_ui.dart';
import 'editor_nota.dart';

/// Pedido de outra parte do app (o "+" dos atalhos): abrir Anotações já
/// criando uma nota deste tipo.
final pedidoNovaNota = ValueNotifier<TipoNota?>(null);

/// Pedido da busca (Ctrl+K): abrir esta nota.
final pedidoAbrirNota = ValueNotifier<String?>(null);

/// Mural (cartões lado a lado) ou Lista (pastas, notas e a nota aberta em
/// colunas). Fica na preferência `anotacoes_vista`, por aparelho.
enum VistaNotas {
  mural('Mural', Icons.dashboard_outlined),
  lista('Lista', Icons.view_list_rounded);

  const VistaNotas(this.rotulo, this.icone);
  final String rotulo;
  final IconData icone;
}

/// A partir desta largura a Lista mostra as três colunas e a nota abre ao lado.
const larguraNotasLarga = 900.0;

IconData iconeTipoNota(TipoNota t) => switch (t) {
  TipoNota.texto => Icons.notes_rounded,
  TipoNota.lista => Icons.checklist_rounded,
  TipoNota.foto => Icons.image_outlined,
  TipoNota.audio => Icons.graphic_eq_rounded,
};

Color corTipoNota(AuroraCores c, TipoNota t) => switch (t) {
  TipoNota.texto => c.violeta,
  TipoNota.lista => c.teal,
  TipoNota.foto => c.warn,
  TipoNota.audio => c.bad,
};

/// "14:32" (hoje), "ontem", "segunda", "20 out".
String quandoNota(DateTime instante, DateTime hoje) {
  final dia = dataLocal(instante);
  final dias = diasEntre(dia, hoje);
  if (dias == 0) return hora(emLocal(instante));
  if (dias == 1) return 'ontem';
  if (dias > 1 && dias < 7) {
    const nomes = ['segunda', 'terça', 'quarta', 'quinta', 'sexta', 'sábado', 'domingo'];
    return nomes[dia.weekday - 1];
  }
  return diaMesCurto(dia);
}

class AnotacoesPage extends StatefulWidget {
  const AnotacoesPage({super.key, this.voltar, this.repo, this.gravador, this.escolherFoto});
  final VoidCallback? voltar;

  /// Nos testes: repositório, microfone e seletor de foto falsos.
  final AnotacoesRepo? repo;
  final GravadorDeNota Function()? gravador;
  final Future<Uint8List?> Function(BuildContext)? escolherFoto;

  @override
  State<AnotacoesPage> createState() => _AnotacoesPageState();
}

class _AnotacoesPageState extends State<AnotacoesPage> {
  AnotacoesRepo? _repo;
  Stream<QuadroNotas>? _quadro;
  VistaNotas _vista = VistaNotas.mural;
  FiltroNotas _filtro = const TodasAsNotas();
  final _busca = TextEditingController();
  bool _buscaAberta = false;
  String? _aberta;
  bool _abertaApareceu = false;
  bool _focarAberta = false;
  final _menuNova = MenuController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_repo != null) return;
    final db = AuroraEscopo.de(context).db;
    _repo = widget.repo ?? AnotacoesRepo(db);
    _quadro = _repo!.observarQuadro();
    db.preferencia('anotacoes_vista').then((v) {
      if (mounted && v == VistaNotas.lista.name) setState(() => _vista = VistaNotas.lista);
    });
    pedidoNovaNota.addListener(_atenderPedido);
    pedidoAbrirNota.addListener(_atenderPedido);
    HardwareKeyboard.instance.addHandler(_teclaNoMenu);
    WidgetsBinding.instance.addPostFrameCallback((_) => _atenderPedido());
  }

  /// Com o menu "Nova nota" aberto (computador), N, L, F e A escolhem o tipo.
  bool _teclaNoMenu(KeyEvent e) {
    if (e is! KeyDownEvent || !mounted || !_menuNova.isOpen) return false;
    final tipo = {
      LogicalKeyboardKey.keyN: TipoNota.texto,
      LogicalKeyboardKey.keyL: TipoNota.lista,
      LogicalKeyboardKey.keyF: TipoNota.foto,
      LogicalKeyboardKey.keyA: TipoNota.audio,
    }[e.logicalKey];
    if (tipo == null) return false;
    _menuNova.close();
    _nova(tipo);
    return true;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_teclaNoMenu);
    pedidoNovaNota.removeListener(_atenderPedido);
    pedidoAbrirNota.removeListener(_atenderPedido);
    _busca.dispose();
    super.dispose();
  }

  void _atenderPedido() {
    if (!mounted) return;
    final tipo = pedidoNovaNota.value;
    if (tipo != null) {
      pedidoNovaNota.value = null;
      _nova(tipo);
    }
    final id = pedidoAbrirNota.value;
    if (id != null) {
      pedidoAbrirNota.value = null;
      _abrir(id);
    }
  }

  bool get _larga => MediaQuery.sizeOf(context).width >= larguraNotasLarga;

  void _trocarVista(VistaNotas v) {
    setState(() {
      _vista = v;
      if (v == VistaNotas.mural) _aberta = null;
    });
    AuroraEscopo.de(context).db.salvarPreferencia('anotacoes_vista', v.name);
  }

  String? get _pastaDoFiltro => switch (_filtro) {
    NaPasta(:final id) => id,
    _ => null,
  };

  Future<void> _abrir(String id, {bool focar = false}) async {
    if (_larga) {
      setState(() {
        _aberta = id;
        _abertaApareceu = false;
        _focarAberta = focar;
      });
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PaginaNota(repo: _repo!, id: id, focarTitulo: focar),
      ),
    );
  }

  Future<void> _nova(TipoNota tipo) async {
    final repo = _repo!;
    if (!anexosDisponiveis && (tipo == TipoNota.foto || tipo == TipoNota.audio)) {
      _avisar('Fotos e áudios nas notas ainda não funcionam na versão web.');
      return;
    }
    switch (tipo) {
      case TipoNota.texto:
        await _abrir(await repo.criarNota(pastaId: _pastaDoFiltro), focar: true);
      case TipoNota.lista:
        await _abrir(
          await repo.criarNota(tipo: TipoNota.lista, pastaId: _pastaDoFiltro, itens: const [ItemLista('')]),
          focar: true,
        );
      case TipoNota.foto:
        final bytes = await (widget.escolherFoto ?? escolherImagem)(context);
        if (bytes == null || !mounted) return;
        final id = await repo.criarNota(tipo: TipoNota.foto, pastaId: _pastaDoFiltro);
        try {
          await repo.adicionarFoto(id, bytes);
        } catch (_) {
          await repo.apagarNota(id);
          _avisar('Não consegui usar essa imagem.');
          return;
        }
        await _abrir(id, focar: true);
      case TipoNota.audio:
        await _gravarNova();
    }
  }

  Future<void> _gravarNova() async {
    if (!anexosDisponiveis) return _avisar('Áudios nas notas ainda não funcionam na versão web.');
    final audio = await gravarAudio(context, gravador: widget.gravador);
    if (audio == null || !mounted) return;
    final repo = _repo!;
    final id = await repo.criarNota(tipo: TipoNota.audio, pastaId: _pastaDoFiltro);
    final anexo = await repo.adicionarAudio(id, audio);
    unawaited(_abrir(id));
    final erro = await transcreverNoFundo(repo, anexo);
    if (erro != null && mounted) _avisar(erro);
  }

  Future<void> _escolherTipoNoCelular() async {
    final tipo = await abrirFolha<TipoNota>(
      context,
      (ctx) => SafeArea(
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
                  decoration: BoxDecoration(color: ctx.cores.line, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 12),
              GradeTiposNota(teclas: false, aoEscolher: (t) => Navigator.pop(ctx, t)),
            ],
          ),
        ),
      ),
    );
    if (tipo != null && mounted) await _nova(tipo);
  }

  Future<void> _novaPasta() async {
    final nome = await pedirNomePasta(context);
    if (nome == null) return;
    final id = await _repo!.criarPasta(nome);
    if (mounted) setState(() => _filtro = NaPasta(id));
  }

  Future<void> _menuPasta(PastaNota p) async {
    final acao = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.cores.surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline_rounded),
              title: Text('Renomear “${p.nome}”'),
              onTap: () => Navigator.pop(ctx, 'renomear'),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: ctx.cores.bad),
              title: Text('Apagar a pasta', style: TextStyle(color: ctx.cores.bad)),
              subtitle: const Text('As notas dela continuam, sem pasta.'),
              onTap: () => Navigator.pop(ctx, 'apagar'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!mounted || acao == null) return;
    if (acao == 'renomear') {
      final nome = await pedirNomePasta(context, inicial: p.nome);
      if (nome != null) await _repo!.renomearPasta(p.id, nome);
    } else {
      await _repo!.apagarPasta(p.id);
      if (mounted && _filtro == NaPasta(p.id)) setState(() => _filtro = const TodasAsNotas());
    }
  }

  Future<void> _alternarItem(NotaCompleta n, int i) => _repo!.salvarNota(
    n.id,
    itens: [for (var k = 0; k < n.itens.length; k++) k == i ? n.itens[k].copiar(feito: !n.itens[k].feito) : n.itens[k]],
  );

  void _avisar(String texto) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto), behavior: SnackBarBehavior.floating));

  // ---------------------------------------------------------------- tela

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuadroNotas>(
      stream: _quadro,
      builder: (context, snap) {
        final q = snap.data;
        if (q == null) return const SizedBox.shrink();
        // Filtro numa pasta que sumiu (apagada em outro aparelho): volta para Todas.
        final filtro = _filtro is NaPasta && q.pasta((_filtro as NaPasta).id) == null ? const TodasAsNotas() : _filtro;
        final notas = filtrarNotas(q.notas, filtro, _busca.text);
        // Nota aberta que sumiu (apagada aqui ou em outro aparelho): fecha o
        // painel. Recém-criada ainda pode não ter chegado na lista: espera aparecer.
        if (_aberta != null) {
          if (q.nota(_aberta!) != null) {
            _abertaApareceu = true;
          } else if (_abertaApareceu) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _aberta = null);
            });
          }
        }
        final larga = _larga;
        final corpo = _vista == VistaNotas.lista && larga
            ? _listaLarga(q, filtro, notas)
            : _vista == VistaNotas.lista
            ? _listaEstreita(q, filtro, notas)
            : _mural(q, filtro, notas);
        return CallbackShortcuts(
          bindings: {const SingleActivator(LogicalKeyboardKey.keyN, control: true): () => _nova(TipoNota.texto)},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _cabecalho(larga),
              if (!larga && _buscaAberta) ...[const SizedBox(height: 12), _campoBusca(autofoco: true)],
              const SizedBox(height: 16),
              Expanded(
                child: _vista == VistaNotas.mural && larga && _aberta != null
                    ? Stack(
                        children: [
                          Positioned.fill(child: corpo),
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: () => setState(() => _aberta = null),
                              child: const ColoredBox(color: Color(0x66020610)),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(width: 540, child: _painel(_editorAberto(), folha: true)),
                          ),
                        ],
                      )
                    : corpo,
              ),
              if (!larga) ...[const SizedBox(height: 12), _botoesDeBaixo()],
            ],
          ),
        );
      },
    );
  }

  Widget _editorAberto() => EditorNota(
    key: ValueKey(_aberta),
    repo: _repo!,
    id: _aberta!,
    focarTitulo: _focarAberta,
    aoFechar: () => setState(() => _aberta = null),
    gravador: widget.gravador,
    escolherFoto: widget.escolherFoto,
  );

  Widget _cabecalho(bool larga) {
    final c = context.cores;
    return Row(
      children: [
        if (widget.voltar != null)
          IconButton(
            onPressed: widget.voltar,
            tooltip: 'Voltar',
            icon: Icon(Icons.chevron_left_rounded, size: 28, color: c.text),
          ),
        Flexible(
          child: Text('Anotações', style: sora(26), overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 16),
        _VerComo(atual: _vista, compacto: !larga, aoEscolher: _trocarVista),
        const Spacer(),
        if (larga)
          SizedBox(width: 260, child: _campoBusca())
        else
          IconButton(
            tooltip: 'Buscar nas notas',
            onPressed: () => setState(() {
              _buscaAberta = !_buscaAberta;
              if (!_buscaAberta) _busca.clear();
            }),
            icon: Icon(_buscaAberta ? Icons.close_rounded : Icons.search_rounded, color: c.text),
          ),
        if (larga) ...[
          const SizedBox(width: 12),
          _BotaoGravar(aoTocar: _gravarNova),
          const SizedBox(width: 10),
          MenuAnchor(
            controller: _menuNova,
            alignmentOffset: const Offset(-210, 8),
            style: MenuStyle(
              backgroundColor: WidgetStatePropertyAll(c.surface),
              padding: const WidgetStatePropertyAll(EdgeInsets.all(14)),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                  side: BorderSide(color: c.line),
                ),
              ),
            ),
            menuChildren: [
              SizedBox(
                width: 340,
                child: GradeTiposNota(
                  aoEscolher: (t) {
                    _menuNova.close();
                    _nova(t);
                  },
                ),
              ),
            ],
            builder: (context, ctl, _) =>
                _BotaoNovaNota(aberto: ctl.isOpen, aoTocar: () => ctl.isOpen ? ctl.close() : ctl.open()),
          ),
        ],
      ],
    );
  }

  Widget _campoBusca({bool autofoco = false}) {
    final c = context.cores;
    return TextField(
      controller: _busca,
      autofocus: autofoco,
      onChanged: (_) => setState(() {}),
      style: manrope(14, cor: c.text),
      cursorColor: c.accent,
      decoration: InputDecoration(
        hintText: 'Buscar nas notas e áudios',
        hintStyle: manrope(14, cor: c.muted),
        prefixIcon: Icon(Icons.search_rounded, size: 20, color: c.muted),
        isDense: true,
        filled: true,
        fillColor: c.surface2.withValues(alpha: 0.7),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(Raio.controle), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _botoesDeBaixo() => Row(
    children: [
      Expanded(child: _BotaoGravar(aoTocar: _gravarNova)),
      const SizedBox(width: 12),
      Expanded(child: _BotaoNovaNota(aberto: false, aoTocar: _escolherTipoNoCelular)),
    ],
  );

  /// Painel da nota aberta: folha de vidro sobre o mural, ou a 3ª coluna da Lista.
  Widget _painel(Widget filho, {bool folha = false}) {
    final c = context.cores;
    final cantos = BorderRadius.circular(22);
    if (Theme.of(context).brightness == Brightness.dark) {
      return Vidro(tipo: folha ? TipoVidro.folha : TipoVidro.cartao, raio: cantos, child: filho);
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: cantos,
        border: Border.all(color: c.line),
        boxShadow: folha ? sombraCartao(context) : null,
      ),
      child: ClipRRect(borderRadius: cantos, child: filho),
    );
  }

  // ---------------------------------------------------------------- mural

  Widget _mural(QuadroNotas q, FiltroNotas filtro, List<NotaCompleta> notas) {
    final fixadas = [
      for (final n in notas)
        if (n.nota.fixada) n,
    ];
    final outras = [
      for (final n in notas)
        if (!n.nota.fixada) n,
    ];
    final hoje = hojeLocal();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ChipsPastas(
          quadro: q,
          filtro: filtro,
          aoEscolher: (f) => setState(() => _filtro = f),
          aoNovaPasta: _novaPasta,
          aoMenu: _menuPasta,
        ),
        const SizedBox(height: 14),
        Expanded(
          child: notas.isEmpty
              ? _vazio(q)
              : SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (fixadas.isNotEmpty) ...[
                        _RotuloGrupo(texto: 'Fixadas', fixadas: true),
                        _Colunas(
                          filhos: [for (final n in fixadas) _cartao(q, n, hoje)],
                          pesos: [for (final n in fixadas) _altura(n)],
                        ),
                      ],
                      if (outras.isNotEmpty) ...[
                        if (fixadas.isNotEmpty) const _RotuloGrupo(texto: 'Outras'),
                        _Colunas(
                          filhos: [for (final n in outras) _cartao(q, n, hoje)],
                          pesos: [for (final n in outras) _altura(n)],
                        ),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  /// Altura aproximada do cartão, para distribuir nas colunas sem buracos grandes.
  double _altura(NotaCompleta n) =>
      70 +
      (n.fotos.isEmpty ? 0 : 120) +
      (n.audios.isEmpty ? 0 : 50) +
      (n.nota.texto.trim().isEmpty ? 0 : ((n.nota.texto.length / 38).ceil().clamp(1, 6) * 20)) +
      (n.itens.length.clamp(0, 5) * 24);

  Widget _cartao(QuadroNotas q, NotaCompleta n, DateTime hoje) => _CartaoNota(
    repo: _repo!,
    nota: n,
    pasta: q.pasta(n.nota.pastaId)?.nome,
    quando: quandoNota(n.nota.atualizadoEm, hoje),
    aoAbrir: () => _abrir(n.id),
    aoAlternarItem: (i) => _alternarItem(n, i),
  );

  Widget _vazio(QuadroNotas q) {
    final semNada = q.notas.isEmpty;
    return Align(
      alignment: Alignment.topCenter,
      child: Vazio(
        semNada
            ? 'Nenhuma nota ainda. Toque em “Nova nota” para escrever ou fazer uma lista, ou em “Gravar áudio” para guardar uma ideia falando.'
            : 'Nenhuma nota encontrada aqui.',
      ),
    );
  }

  // ---------------------------------------------------------------- lista

  Widget _listaLarga(QuadroNotas q, FiltroNotas filtro, List<NotaCompleta> notas) {
    final c = context.cores;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 220,
          child: _painel(
            _ColunaPastas(
              quadro: q,
              filtro: filtro,
              aoEscolher: (f) => setState(() => _filtro = f),
              aoNovaPasta: _novaPasta,
              aoMenu: _menuPasta,
            ),
          ),
        ),
        const SizedBox(width: 14),
        SizedBox(width: 340, child: _painel(_linhas(q, notas, padding: const EdgeInsets.all(12)))),
        const SizedBox(width: 14),
        Expanded(
          child: _painel(
            _aberta == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sticky_note_2_outlined, size: 34, color: c.muted),
                        const SizedBox(height: 8),
                        Text('Escolha uma nota ou crie uma nova.', style: manrope(14, cor: c.muted)),
                      ],
                    ),
                  )
                : _editorAberto(),
          ),
        ),
      ],
    );
  }

  Widget _listaEstreita(QuadroNotas q, FiltroNotas filtro, List<NotaCompleta> notas) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _ChipsPastas(
        quadro: q,
        filtro: filtro,
        aoEscolher: (f) => setState(() => _filtro = f),
        aoNovaPasta: _novaPasta,
        aoMenu: _menuPasta,
      ),
      const SizedBox(height: 12),
      Expanded(child: notas.isEmpty ? _vazio(q) : _linhas(q, notas, cartoes: true)),
    ],
  );

  /// Notas em linhas, com "Fixadas" em cima.
  Widget _linhas(
    QuadroNotas q,
    List<NotaCompleta> notas, {
    EdgeInsets padding = EdgeInsets.zero,
    bool cartoes = false,
  }) {
    final hoje = hojeLocal();
    if (notas.isEmpty && !cartoes) {
      return Center(
        child: Text('Nenhuma nota aqui.', style: manrope(14, cor: context.cores.muted)),
      );
    }
    final fixadas = [
      for (final n in notas)
        if (n.nota.fixada) n,
    ];
    final outras = [
      for (final n in notas)
        if (!n.nota.fixada) n,
    ];
    Widget linha(NotaCompleta n) => _LinhaNota(
      nota: n,
      quando: quandoNota(n.nota.atualizadoEm, hoje),
      selecionada: _larga && _aberta == n.id,
      aoAbrir: () => _abrir(n.id),
    );
    Widget grupo(List<NotaCompleta> l) => cartoes
        ? Cartao(
            raio: 16,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Column(children: [for (final n in l) linha(n)]),
          )
        : Column(children: [for (final n in l) linha(n)]);
    return ListView(
      padding: padding.copyWith(bottom: padding.bottom + 16),
      children: [
        if (fixadas.isNotEmpty) ...[const _RotuloGrupo(texto: 'Fixadas', fixadas: true), grupo(fixadas)],
        if (outras.isNotEmpty) ...[if (fixadas.isNotEmpty) const _RotuloGrupo(texto: 'Outras'), grupo(outras)],
      ],
    );
  }
}

// ==================================================================== peças

class _VerComo extends StatelessWidget {
  const _VerComo({required this.atual, required this.aoEscolher, this.compacto = false});
  final VistaNotas atual;
  final ValueChanged<VistaNotas> aoEscolher;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final cantos = BorderRadius.circular(12);
    final trilho = Padding(
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!compacto)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('Ver como', style: manrope(12, cor: c.muted)),
            ),
          for (final v in VistaNotas.values)
            Semantics(
              selected: v == atual,
              button: true,
              label: 'Ver como ${v.rotulo}',
              child: Material(
                type: MaterialType.transparency,
                borderRadius: BorderRadius.circular(9),
                clipBehavior: Clip.antiAlias,
                child: Ink(
                  decoration: v == atual
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(9),
                          gradient: LinearGradient(
                            colors: [c.gradIni.withValues(alpha: 0.20), c.gradFim.withValues(alpha: 0.22)],
                          ),
                          border: Border.all(color: c.violeta.withValues(alpha: 0.45), width: 0.6),
                        )
                      : null,
                  child: InkWell(
                    onTap: () => aoEscolher(v),
                    hoverColor: c.teal.withValues(alpha: 0.10),
                    child: SizedBox(
                      height: 36,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ExcludeSemantics(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(v.icone, size: 16, color: v == atual ? c.text : c.muted),
                              // Celular: só o ícone (o nome fica no leitor de tela).
                              if (!compacto) ...[
                                const SizedBox(width: 5),
                                Text(
                                  v.rotulo,
                                  style: manrope(12, peso: FontWeight.w700, cor: v == atual ? c.text : c.muted),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    if (Theme.of(context).brightness == Brightness.dark) return Vidro(raio: cantos, cor: c.surface2, child: trilho);
    return DecoratedBox(
      decoration: BoxDecoration(color: c.surface2, borderRadius: cantos),
      child: trilho,
    );
  }
}

class _BotaoGravar extends StatelessWidget {
  const _BotaoGravar({required this.aoTocar});
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Material(
      color: c.surface.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.55 : 1),
      shape: StadiumBorder(side: BorderSide(color: c.violeta.withValues(alpha: 0.55))),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: aoTocar,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mic_none_rounded, size: 20, color: c.bad),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Gravar áudio',
                  overflow: TextOverflow.ellipsis,
                  style: manrope(14, peso: FontWeight.w700, cor: c.text),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BotaoNovaNota extends StatelessWidget {
  const _BotaoNovaNota({required this.aberto, required this.aoTocar});
  final bool aberto;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Material(
      color: Colors.transparent,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(gradient: c.gradiente),
        child: InkWell(
          onTap: aoTocar,
          child: Container(
            height: 44,
            alignment: Alignment.center,
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit_note_rounded, size: 22, color: c.noAccent),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Nova nota',
                    overflow: TextOverflow.ellipsis,
                    style: manrope(14, peso: FontWeight.w700, cor: c.noAccent),
                  ),
                ),
                const SizedBox(width: 2),
                AnimatedRotation(
                  turns: aberto ? 0.5 : 0,
                  duration: const Duration(milliseconds: 160),
                  child: Icon(Icons.expand_more_rounded, size: 20, color: c.noAccent),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "O que você quer criar?": Nota, Lista, Foto e Áudio em cartões 2 × 2, com
/// as letras N, L, F e A no teclado.
class GradeTiposNota extends StatelessWidget {
  const GradeTiposNota({super.key, required this.aoEscolher, this.teclas = true});
  final ValueChanged<TipoNota> aoEscolher;

  /// Mostra a letra de cada tipo (computador; no celular não há teclado).
  final bool teclas;

  static const _opcoes = [
    (TipoNota.texto, 'Nota', 'Texto livre, para ideias e anotações', 'N'),
    (TipoNota.lista, 'Lista', 'Caixinhas para ir marcando', 'L'),
    (TipoNota.foto, 'Foto', 'Uma foto com legenda', 'F'),
    (TipoNota.audio, 'Áudio', 'Grave e a Aurora transcreve', 'A'),
  ];

  Widget _cartaoTipo(AuroraCores c, (TipoNota, String, String, String) opcao) {
    final (tipo, nome, detalhe, tecla) = opcao;
    return _TipoNota(
      icone: tipo == TipoNota.audio ? Icons.mic_none_rounded : iconeTipoNota(tipo),
      cor: corTipoNota(c, tipo),
      nome: nome,
      detalhe: anexosDisponiveis || tipo == TipoNota.texto || tipo == TipoNota.lista
          ? detalhe
          : 'Ainda não na versão web',
      tecla: teclas ? tecla : null,
      aoTocar: () => aoEscolher(tipo),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    // As letras do teclado são tratadas pela tela (_teclaNoMenu), só no computador.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
          child: Text('O que você quer criar?', style: sora(16)),
        ),
        // Linhas fixas em vez de GridView: o menu do computador mede a largura
        // do conteúdo, o que uma grade rolável não deixa.
        for (var l = 0; l < 2; l++) ...[
          if (l > 0) const SizedBox(height: 10),
          SizedBox(
            height: 124,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var k = 0; k < 2; k++) ...[
                  if (k > 0) const SizedBox(width: 10),
                  Expanded(child: _cartaoTipo(c, _opcoes[l * 2 + k])),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TipoNota extends StatelessWidget {
  const _TipoNota({
    required this.icone,
    required this.cor,
    required this.nome,
    required this.detalhe,
    required this.tecla,
    required this.aoTocar,
  });
  final IconData icone;
  final Color cor;
  final String nome;
  final String detalhe;
  final String? tecla;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Material(
      color: c.surface2.withValues(alpha: 0.6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: c.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: aoTocar,
        hoverColor: cor.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: cor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icone, color: cor, size: 22),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nome, style: manrope(14, peso: FontWeight.w700)),
                      Text(
                        detalhe,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: manrope(12, cor: c.muted, altura: 1.3),
                      ),
                    ],
                  ),
                ],
              ),
              if (tecla != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      tecla!,
                      style: manrope(11, peso: FontWeight.w700, cor: c.muted),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chips das pastas (Mural e Lista no celular): Todas, cada pasta, Áudios e "+".
/// Segurar (ou botão direito) numa pasta abre renomear/apagar.
class _ChipsPastas extends StatelessWidget {
  const _ChipsPastas({
    required this.quadro,
    required this.filtro,
    required this.aoEscolher,
    required this.aoNovaPasta,
    required this.aoMenu,
  });
  final QuadroNotas quadro;
  final FiltroNotas filtro;
  final ValueChanged<FiltroNotas> aoEscolher;
  final VoidCallback aoNovaPasta;
  final ValueChanged<PastaNota> aoMenu;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    Widget chip(String rotulo, FiltroNotas f, {IconData? icone, Color? corIcone, PastaNota? pasta}) {
      final sel = f == filtro;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onLongPress: pasta == null ? null : () => aoMenu(pasta),
          onSecondaryTap: pasta == null ? null : () => aoMenu(pasta),
          child: ChoiceChip(
            selected: sel,
            showCheckmark: false,
            avatar: icone == null ? null : Icon(icone, size: 16, color: corIcone ?? c.muted),
            label: Text(rotulo),
            labelStyle: manrope(13, peso: FontWeight.w700, cor: sel ? c.text : c.muted),
            backgroundColor: c.surface2.withValues(alpha: 0.6),
            selectedColor: c.violeta.withValues(alpha: 0.18),
            side: BorderSide(color: sel ? c.violeta.withValues(alpha: 0.55) : c.line),
            shape: const StadiumBorder(),
            onSelected: (_) => aoEscolher(f),
          ),
        ),
      );
    }

    final audios = quadro.notas.where((n) => n.audios.isNotEmpty).length;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip('Todas · ${quadro.notas.length}', const TodasAsNotas()),
          for (final p in quadro.pastas)
            chip(p.nome, NaPasta(p.id), icone: Icons.folder_outlined, corIcone: c.accent, pasta: p),
          if (audios > 0) chip('Áudios · $audios', const SoAudios(), icone: Icons.graphic_eq_rounded, corIcone: c.bad),
          IconButton(
            tooltip: 'Nova pasta',
            onPressed: aoNovaPasta,
            icon: Icon(Icons.create_new_folder_outlined, color: c.muted, size: 22),
          ),
        ],
      ),
    );
  }
}

/// Coluna das pastas na Lista larga.
class _ColunaPastas extends StatelessWidget {
  const _ColunaPastas({
    required this.quadro,
    required this.filtro,
    required this.aoEscolher,
    required this.aoNovaPasta,
    required this.aoMenu,
  });
  final QuadroNotas quadro;
  final FiltroNotas filtro;
  final ValueChanged<FiltroNotas> aoEscolher;
  final VoidCallback aoNovaPasta;
  final ValueChanged<PastaNota> aoMenu;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    Widget linha(String nome, IconData icone, Color cor, int qtd, FiltroNotas f, {PastaNota? pasta}) {
      final sel = f == filtro;
      return Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: sel
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [c.gradIni.withValues(alpha: 0.14), c.gradFim.withValues(alpha: 0.17)],
                    ),
                    border: Border.all(color: c.violeta.withValues(alpha: 0.5), width: 0.7),
                  )
                : null,
            child: InkWell(
              onTap: () => aoEscolher(f),
              onLongPress: pasta == null ? null : () => aoMenu(pasta),
              onSecondaryTap: pasta == null ? null : () => aoMenu(pasta),
              hoverColor: c.teal.withValues(alpha: 0.08),
              child: SizedBox(
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Icon(icone, size: 18, color: sel ? c.accent : cor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          nome,
                          overflow: TextOverflow.ellipsis,
                          style: manrope(14, peso: FontWeight.w600),
                        ),
                      ),
                      Text('$qtd', style: manrope(12, cor: c.muted)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    int contar(bool Function(NotaCompleta) teste) => quadro.notas.where(teste).length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text('PASTAS', style: rotulo(c.muted)),
              ),
            ),
            IconButton(
              tooltip: 'Nova pasta',
              onPressed: aoNovaPasta,
              icon: Icon(Icons.create_new_folder_outlined, size: 20, color: c.muted),
            ),
          ],
        ),
        linha('Todas as notas', Icons.sticky_note_2_outlined, c.muted, quadro.notas.length, const TodasAsNotas()),
        for (final p in quadro.pastas)
          linha(p.nome, Icons.folder_outlined, c.muted, contar((n) => n.nota.pastaId == p.id), NaPasta(p.id), pasta: p),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 6),
          child: Text('FILTROS', style: rotulo(c.muted)),
        ),
        linha('Áudios', Icons.graphic_eq_rounded, c.bad, contar((n) => n.audios.isNotEmpty), const SoAudios()),
      ],
    );
  }
}

class _RotuloGrupo extends StatelessWidget {
  const _RotuloGrupo({required this.texto, this.fixadas = false});
  final String texto;
  final bool fixadas;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 10),
      child: Row(
        children: [
          if (fixadas) ...[Icon(Icons.push_pin_rounded, size: 14, color: c.warn), const SizedBox(width: 6)],
          Text(texto.toUpperCase(), style: rotulo(c.muted)),
        ],
      ),
    );
  }
}

/// Mural: distribui os cartões em colunas (sempre na mais curta), como cartões
/// de anotações num quadro.
class _Colunas extends StatelessWidget {
  const _Colunas({required this.filhos, required this.pesos});
  final List<Widget> filhos;
  final List<double> pesos;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final n = box.maxWidth >= 1000 ? 4 : (box.maxWidth >= 680 ? 3 : 2);
      final colunas = List.generate(n, (_) => <Widget>[]);
      final alturas = List.filled(n, 0.0);
      for (var i = 0; i < filhos.length; i++) {
        var menor = 0;
        for (var k = 1; k < n; k++) {
          if (alturas[k] < alturas[menor] - 1) menor = k;
        }
        colunas[menor].add(Padding(padding: const EdgeInsets.only(bottom: 12), child: filhos[i]));
        alturas[menor] += pesos[i] + 12;
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var k = 0; k < n; k++) ...[
              if (k > 0) const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: colunas[k]),
              ),
            ],
          ],
        ),
      );
    },
  );
}

class _CartaoNota extends StatelessWidget {
  const _CartaoNota({
    required this.repo,
    required this.nota,
    required this.pasta,
    required this.quando,
    required this.aoAbrir,
    required this.aoAlternarItem,
  });
  final AnotacoesRepo repo;
  final NotaCompleta nota;
  final String? pasta;
  final String quando;
  final VoidCallback aoAbrir;
  final ValueChanged<int> aoAlternarItem;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final n = nota;
    final texto = n.nota.texto.trim();
    final previa = texto.isNotEmpty
        ? texto
        : (n.itens.isEmpty ? [for (final a in n.audios) a.transcricao ?? ''].join(' ').trim() : '');
    final itens = n.itens.where((i) => i.texto.trim().isNotEmpty).take(5).toList();
    return Semantics(
      button: true,
      label: 'Abrir a nota ${n.tituloVisivel}',
      child: Cartao(
        raio: 18,
        padding: EdgeInsets.zero,
        aoTocar: aoAbrir,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (n.fotos.isNotEmpty)
              SizedBox(
                height: 120,
                child: ImagemAnexo(repo: repo, anexo: n.fotos.first),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      if (n.nota.fixada) ...[
                        Icon(Icons.push_pin_rounded, size: 14, color: c.warn),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(n.tituloVisivel, maxLines: 2, overflow: TextOverflow.ellipsis, style: sora(15)),
                      ),
                    ],
                  ),
                  for (final a in n.audios.take(1)) ...[const SizedBox(height: 10), PlayerAudio(repo: repo, anexo: a)],
                  if (previa.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      previa,
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                      style: manrope(13, cor: c.muted, altura: 1.5),
                    ),
                  ],
                  if (itens.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    for (final it in itens)
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => aoAlternarItem(n.itens.indexOf(it)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: it.feito ? c.teal : Colors.transparent,
                                  border: Border.all(color: it.feito ? c.teal : c.muted, width: 1.6),
                                ),
                                child: it.feito ? Icon(Icons.check_rounded, size: 11, color: c.noAccent) : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  it.texto,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: manrope(
                                    13,
                                    cor: it.feito ? c.muted : c.text,
                                  ).copyWith(decoration: it.feito ? TextDecoration.lineThrough : null),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (n.itensComTexto > itens.length)
                      Padding(
                        padding: const EdgeInsets.only(top: 2, left: 24),
                        child: Text('+ ${n.itensComTexto - itens.length} itens', style: manrope(12, cor: c.muted)),
                      ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.folder_outlined, size: 13, color: c.accent),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          pasta ?? 'Sem pasta',
                          overflow: TextOverflow.ellipsis,
                          style: manrope(11, cor: c.muted),
                        ),
                      ),
                      if (n.fotos.length > 1 || (n.fotos.isNotEmpty && n.audios.isNotEmpty)) ...[
                        Icon(Icons.attach_file_rounded, size: 13, color: c.muted),
                        Text('${n.anexos.length}', style: manrope(11, cor: c.muted)),
                        const SizedBox(width: 8),
                      ],
                      Text(quando, style: manrope(11, cor: c.muted)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinhaNota extends StatelessWidget {
  const _LinhaNota({required this.nota, required this.quando, required this.selecionada, required this.aoAbrir});
  final NotaCompleta nota;
  final String quando;
  final bool selecionada;
  final VoidCallback aoAbrir;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final n = nota;
    final tipo = n.nota.tipo;
    Widget etiqueta(IconData icone, String texto, Color cor) => Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 12, color: cor),
          const SizedBox(width: 4),
          Text(
            texto,
            style: manrope(11, peso: FontWeight.w700, cor: cor),
          ),
        ],
      ),
    );
    final duracao = n.audios.fold(Duration.zero, (s, a) => s + a.duracao);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: selecionada
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [c.gradIni.withValues(alpha: 0.14), c.gradFim.withValues(alpha: 0.17)],
                  ),
                  border: Border.all(color: c.violeta.withValues(alpha: 0.5), width: 0.7),
                )
              : null,
          child: InkWell(
            onTap: aoAbrir,
            hoverColor: c.teal.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(10)),
                    child: Icon(iconeTipoNota(tipo), size: 18, color: corTipoNota(c, tipo)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                n.tituloVisivel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: manrope(14, peso: FontWeight.w700),
                              ),
                            ),
                            if (n.nota.fixada) Icon(Icons.push_pin_rounded, size: 13, color: c.warn),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '$quando  ',
                                style: manrope(13, peso: FontWeight.w600, cor: c.text.withValues(alpha: 0.8)),
                              ),
                              TextSpan(
                                text: n.previaCompleta.replaceAll('\n', ' '),
                                style: manrope(13, cor: c.muted),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (n.itens.isNotEmpty || n.audios.isNotEmpty || n.fotos.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              if (n.itensComTexto > 0)
                                etiqueta(Icons.check_rounded, '${n.feitos}/${n.itensComTexto}', c.teal),
                              if (n.audios.isNotEmpty) etiqueta(Icons.graphic_eq_rounded, minSeg(duracao), c.bad),
                              if (n.fotos.isNotEmpty) etiqueta(Icons.image_outlined, '${n.fotos.length}', c.warn),
                            ],
                          ),
                        ],
                      ],
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
