import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app.dart';
import '../../core/comandos.dart' show normalizar;
import '../../core/tema.dart';
import '../../data/busca.dart';
import '../vidro.dart';
import '../icone_ia.dart';

/// Área do app que aparece em "Ir para" (busca vazia ou que casa com o nome).
class AtalhoArea {
  const AtalhoArea(this.rotulo, this.icone, this.abrir);
  final String rotulo;
  final IconData icone;
  final VoidCallback abrir;
}

const _chaveRecentes = 'busca_recentes';

IconData iconeDoResultado(TipoResultado t) => switch (t) {
      TipoResultado.tarefa => Icons.task_alt_rounded,
      TipoResultado.lembrete => Icons.notifications_none_rounded,
      TipoResultado.compromisso => Icons.event_rounded,
      TipoResultado.transacao => Icons.receipt_long_outlined,
      TipoResultado.categoria => Icons.category_outlined,
      TipoResultado.habito => Icons.donut_large_rounded,
      TipoResultado.objetivo => Icons.flag_outlined,
      TipoResultado.exercicio => Icons.fitness_center_rounded,
      TipoResultado.treino => Icons.list_alt_rounded,
      TipoResultado.nota => Icons.sticky_note_2_outlined,
    };

String _tituloNavegando(TipoResultado t) => switch (t) {
      TipoResultado.tarefa => 'TAREFAS PENDENTES',
      TipoResultado.lembrete => 'LEMBRETES',
      TipoResultado.compromisso => 'COMPROMISSOS',
      TipoResultado.categoria => 'CATEGORIAS MAIS USADAS',
      TipoResultado.transacao => 'LANÇAMENTOS RECENTES',
      TipoResultado.habito => 'HÁBITOS',
      TipoResultado.objetivo => 'OBJETIVOS',
      TipoResultado.treino => 'TREINOS',
      TipoResultado.exercicio => 'EXERCÍCIOS',
      TipoResultado.nota => 'ANOTAÇÕES RECENTES',
    };

/// Busca em tudo (Ctrl+K): caixa no topo da tela, por cima de um véu escuro.
/// Setas escolhem, Enter abre, Esc fecha.
Future<void> abrirBusca(
  BuildContext context, {
  required List<AtalhoArea> areas,
  required ValueChanged<ResultadoBusca> aoAbrir,
  required ValueChanged<String> aoPerguntar,
  required ValueChanged<String> aoNovaTarefa,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fechar busca',
    barrierColor: const Color(0x8C04040E),
    transitionDuration: const Duration(milliseconds: 160),
    pageBuilder: (ctx, _, _) => _Busca(
      areas: areas,
      aoAbrir: aoAbrir,
      aoPerguntar: aoPerguntar,
      aoNovaTarefa: aoNovaTarefa,
    ),
    transitionBuilder: (ctx, anim, _, filho) {
      if (MediaQuery.maybeDisableAnimationsOf(ctx) ?? false) return filho;
      final t = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: t,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, -.02), end: Offset.zero).animate(t),
          child: filho,
        ),
      );
    },
  );
}

class _Item {
  const _Item({
    required this.icone,
    required this.titulo,
    required this.acao,
    this.detalhe,
    this.direita,
    this.grupo,
  });
  final IconData icone;
  final String titulo;
  final String? detalhe, direita;
  final VoidCallback acao;

  /// Título da seção (só no primeiro item de cada uma).
  final String? grupo;
}

class _Busca extends StatefulWidget {
  const _Busca({required this.areas, required this.aoAbrir, required this.aoPerguntar, required this.aoNovaTarefa});
  final List<AtalhoArea> areas;
  final ValueChanged<ResultadoBusca> aoAbrir;
  final ValueChanged<String> aoPerguntar, aoNovaTarefa;

  @override
  State<_Busca> createState() => _BuscaState();
}

class _BuscaState extends State<_Busca> {
  final _texto = TextEditingController();
  final _rolagem = ScrollController();
  GrupoBusca? _filtro;
  List<ResultadoBusca> _resultados = const [];
  List<String> _recentes = const [];
  int _sel = 0;
  Timer? _espera;
  int _pedido = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_recentes.isEmpty) {
      AuroraEscopo.de(context).db.preferencia(_chaveRecentes).then((v) {
        if (!mounted || v == null) return;
        try {
          setState(() => _recentes = (jsonDecode(v) as List).cast<String>());
        } catch (_) {}
      });
    }
  }

  @override
  void dispose() {
    _espera?.cancel();
    _texto.dispose();
    _rolagem.dispose();
    super.dispose();
  }

  void _mudou(String _) {
    _espera?.cancel();
    _espera = Timer(const Duration(milliseconds: 120), _buscar);
    setState(() => _sel = 0);
  }

  Future<void> _buscar() async {
    final pedido = ++_pedido;
    final navegar = _texto.text.trim().length < 2;
    final r = await buscarTudo(AuroraEscopo.de(context).db, _texto.text,
        grupo: _filtro, porGrupo: _filtro == null ? 4 : (navegar ? 8 : 12));
    if (!mounted || pedido != _pedido) return;
    setState(() {
      _resultados = r;
      _sel = 0;
    });
  }

  Future<void> _lembrar() async {
    final t = _texto.text.trim();
    if (t.length < 2) return;
    final lista = [t, ..._recentes.where((x) => normalizar(x) != normalizar(t))].take(5).toList();
    await AuroraEscopo.de(context).db.salvarPreferencia(_chaveRecentes, jsonEncode(lista));
  }

  /// Fecha a busca e depois faz [acao] (na tela de baixo).
  void _executar(VoidCallback acao) {
    _lembrar();
    Navigator.of(context).pop();
    acao();
  }

  List<_Item> _itens() {
    final t = _texto.text.trim();
    final itens = <_Item>[];
    // Filtro escolhido e nada escrito: lista o que há nesse grupo.
    if (t.length < 2 && _filtro != null) {
      TipoResultado? anterior;
      for (final r in _resultados.where((r) => r.tipo.grupo == _filtro)) {
        itens.add(_Item(
          grupo: r.tipo == anterior ? null : _tituloNavegando(r.tipo),
          icone: iconeDoResultado(r.tipo),
          titulo: r.titulo,
          detalhe: r.detalhe,
          direita: r.direita,
          acao: () => _executar(() => widget.aoAbrir(r)),
        ));
        anterior = r.tipo;
      }
      return itens;
    }
    if (t.length < 2) {
      for (var i = 0; i < _recentes.length; i++) {
        final r = _recentes[i];
        itens.add(_Item(
          grupo: i == 0 ? 'BUSCAS RECENTES' : null,
          icone: Icons.history_rounded,
          titulo: r,
          acao: () {
            _texto.text = r;
            _texto.selection = TextSelection.collapsed(offset: r.length);
            _mudou(r);
          },
        ));
      }
      for (var i = 0; i < widget.areas.length; i++) {
        final a = widget.areas[i];
        itens.add(_Item(grupo: i == 0 ? 'IR PARA' : null, icone: a.icone, titulo: a.rotulo, acao: () => _executar(a.abrir)));
      }
      return itens;
    }

    final areas = _filtro == null ? widget.areas.where((a) => trechoEncontrado(a.rotulo, t) != null).toList() : const [];
    for (var i = 0; i < areas.length; i++) {
      itens.add(_Item(
          grupo: i == 0 ? 'IR PARA' : null, icone: areas[i].icone, titulo: areas[i].rotulo, acao: () => _executar(areas[i].abrir)));
    }
    for (final g in GrupoBusca.values) {
      if (_filtro != null && _filtro != g) continue;
      final doGrupo = _resultados.where((r) => r.tipo.grupo == g).toList();
      for (var i = 0; i < doGrupo.length; i++) {
        final r = doGrupo[i];
        itens.add(_Item(
          grupo: i == 0 ? g.rotulo.toUpperCase() : null,
          icone: iconeDoResultado(r.tipo),
          titulo: r.titulo,
          detalhe: r.detalhe,
          direita: r.direita,
          acao: () => _executar(() => widget.aoAbrir(r)),
        ));
      }
    }
    itens.add(_Item(grupo: 'AÇÕES', icone: Icons.add_circle_outline_rounded, titulo: 'Nova tarefa “$t”', acao: () => _executar(() => widget.aoNovaTarefa(t))));
    itens.add(_Item(icone: iconeIa, titulo: 'Perguntar à Aurora: “$t”', acao: () => _executar(() => widget.aoPerguntar(t))));
    return itens;
  }

  void _mover(int passo, int total) {
    if (total == 0) return;
    setState(() => _sel = (_sel + passo) % total);
    // Mantém o escolhido à vista (cada linha tem uns 52 px).
    if (_rolagem.hasClients) {
      final alvo = (_sel * 52.0 - 120).clamp(0.0, _rolagem.position.maxScrollExtent);
      _rolagem.animateTo(alvo, duration: const Duration(milliseconds: 120), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final itens = _itens();
    if (_sel >= itens.length) _sel = 0;
    final termo = _texto.text.trim();
    final cantos = BorderRadius.circular(20);
    final altura = MediaQuery.sizeOf(context).height;
    // Celular (Android e iPhone, inclusive o app web no iPhone): sem dicas de
    // teclado, e o "Esc" vira um botão de fechar para tocar.
    final toque = defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;

    final caixa = Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 6, 12, 6),
        child: Row(children: [
          Icon(Icons.search_rounded, color: c.accent, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.arrowDown): () => _mover(1, itens.length),
                const SingleActivator(LogicalKeyboardKey.arrowUp): () => _mover(-1, itens.length),
                const SingleActivator(LogicalKeyboardKey.enter): () {
                  if (itens.isNotEmpty) itens[_sel].acao();
                },
                const SingleActivator(LogicalKeyboardKey.numpadEnter): () {
                  if (itens.isNotEmpty) itens[_sel].acao();
                },
              },
              child: TextField(
                controller: _texto,
                autofocus: true,
                onChanged: _mudou,
                style: manrope(16, cor: c.text),
                cursorColor: c.accent,
                decoration: InputDecoration(
                  hintText: 'Buscar tarefas, gastos, hábitos, lembretes…',
                  hintStyle: manrope(16, cor: c.muted),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          if (toque)
            IconButton(
              tooltip: 'Fechar a busca',
              icon: Icon(Icons.close_rounded, color: c.muted),
              onPressed: () => Navigator.of(context).pop(),
            )
          else
            _Tecla('Esc'),
        ]),
      ),
      Divider(height: 1, color: c.line),
      SizedBox(
        height: 46,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Row(children: [
            for (final g in [null, ...GrupoBusca.values])
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _Filtro(
                  texto: g?.rotulo ?? 'Tudo',
                  ativo: _filtro == g,
                  aoTocar: () {
                    setState(() => _filtro = g);
                    _buscar();
                  },
                ),
              ),
          ]),
        ),
      ),
      Flexible(
        child: itens.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Nada encontrado.', textAlign: TextAlign.center, style: manrope(14, cor: c.muted)),
              )
            : ListView.builder(
                controller: _rolagem,
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
                itemCount: itens.length,
                itemBuilder: (_, i) {
                  final it = itens[i];
                  return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    if (it.grupo != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
                        child: Text(it.grupo!, style: manrope(11, peso: FontWeight.w800, cor: c.muted, espaco: 1.4)),
                      ),
                    _Linha(item: it, termo: termo, ativo: i == _sel, aoPassar: () => setState(() => _sel = i)),
                  ]);
                },
              ),
      ),
      if (!toque) ...[
        Divider(height: 1, color: c.line),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Wrap(spacing: 16, runSpacing: 6, children: [
            _Dica(teclas: const ['↑', '↓'], texto: 'navegar'),
            _Dica(teclas: const ['Enter'], texto: 'abrir'),
            _Dica(teclas: const ['Esc'], texto: 'fechar'),
          ]),
        ),
      ],
    ]);

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, altura > 700 ? 80 : 24, 16, 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Material(
              type: MaterialType.transparency,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: escuro ? null : c.surface,
                  borderRadius: cantos,
                  border: escuro ? null : Border.all(color: c.line),
                  boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 60, offset: Offset(0, 20))],
                ),
                child: escuro ? Vidro(tipo: TipoVidro.folha, raio: cantos, child: caixa) : caixa,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha({required this.item, required this.termo, required this.ativo, required this.aoPassar});
  final _Item item;
  final String termo;
  final bool ativo;
  final VoidCallback aoPassar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final achado = trechoEncontrado(item.titulo, termo);
    final estilo = manrope(14, peso: FontWeight.w600, cor: c.text);
    final titulo = achado == null
        ? Text(item.titulo, maxLines: 1, overflow: TextOverflow.ellipsis, style: estilo)
        : Text.rich(
            TextSpan(style: estilo, children: [
              TextSpan(text: item.titulo.substring(0, achado.$1)),
              TextSpan(
                  text: item.titulo.substring(achado.$1, achado.$2),
                  style: estilo.copyWith(color: c.accent, fontWeight: FontWeight.w800)),
              TextSpan(text: item.titulo.substring(achado.$2)),
            ]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
    return MouseRegion(
      onEnter: (_) => aoPassar(),
      child: Material(
        color: ativo ? c.accent.withValues(alpha: .08) : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: ativo ? c.accent.withValues(alpha: .25) : Colors.transparent),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: item.acao,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(children: [
              IconeApp(item.icone, size: 20, color: ativo ? c.accent : c.muted),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  titulo,
                  if (item.detalhe != null)
                    Text(item.detalhe!, maxLines: 1, overflow: TextOverflow.ellipsis, style: manrope(12, cor: c.muted)),
                ]),
              ),
              if (item.direita != null) ...[
                const SizedBox(width: 12),
                Text(item.direita!, style: manrope(13, peso: FontWeight.w700, cor: c.muted)),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}

class _Filtro extends StatelessWidget {
  const _Filtro({required this.texto, required this.ativo, required this.aoTocar});
  final String texto;
  final bool ativo;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Semantics(
      button: true,
      selected: ativo,
      label: 'Filtro: $texto',
      excludeSemantics: true,
      child: Material(
        color: ativo ? c.accentSoft : Colors.transparent,
        shape: StadiumBorder(side: BorderSide(color: ativo ? c.accent.withValues(alpha: .45) : c.line)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            child: Text(texto, style: manrope(12, peso: FontWeight.w700, cor: ativo ? c.accent : c.muted)),
          ),
        ),
      ),
    );
  }
}

class _Tecla extends StatelessWidget {
  const _Tecla(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: c.line)),
      child: Text(texto, style: manrope(11, peso: FontWeight.w600, cor: c.muted)),
    );
  }
}

class _Dica extends StatelessWidget {
  const _Dica({required this.teclas, required this.texto});
  final List<String> teclas;
  final String texto;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        for (final t in teclas) Padding(padding: const EdgeInsets.only(right: 4), child: _Tecla(t)),
        const SizedBox(width: 2),
        Text(texto, style: manrope(12, cor: context.cores.muted)),
      ]);
}
