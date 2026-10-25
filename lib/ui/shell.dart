import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'icone_ia.dart';
import '../app.dart';
import '../core/area_segura.dart';
import '../core/tema.dart';
import '../data/anotacoes_repo.dart' show NotaCompleta;
import '../data/assistente_repo.dart';
import '../data/banco.dart';
import '../data/busca.dart';
import '../data/exemplo.dart';
import '../data/financas_repo.dart';
import '../data/ia/ferramentas_ia.dart' show telaPedidaPelaIa;
import '../data/tarefas_repo.dart';
import 'atalhos/atalhos_flutuantes.dart';
import 'atalhos/busca_ui.dart';
import 'componentes.dart';
import 'alimentacao/alimentacao_page.dart';
import 'anotacoes/anotacoes_page.dart';
import 'financas/form_lancamento.dart';
import 'habitos/form_habito.dart';
import 'lembretes/form_lembrete.dart';
import 'metas/form_meta.dart';
import 'projetos/form_projeto.dart';
import 'tarefas/form_tarefa.dart';
import 'atualizacao_ui.dart';
import 'boas_vindas_page.dart';
import 'ceu_estrelado.dart';
import 'assistente/assistente_page.dart';
import 'automacoes/automacoes_page.dart';
import 'conta/conta_page.dart';
import 'financas/financas_page.dart';
import 'habitos/habitos_page.dart';
import 'lembretes/lembretes_page.dart';
import 'menu_dock.dart';
import 'metas/metas_page.dart';
import 'projetos/projetos_page.dart';
import 'saude/treino_page.dart';
import 'vidro.dart';
import 'tarefas/tarefas_page.dart';
import 'visao/visao_page.dart';

/// Áreas do app. Cada uma aparece direto no menu lateral (computador) e na
/// barra rolável de baixo (celular), e organiza o conteúdo em abas no topo.
enum Secao { visao, assistente, tarefas, habitos, saude, lembretes, metas, projetos, anotacoes, financas, conta }

class _ItemNav {
  const _ItemNav(this.secao, this.rotulo, this.icone);
  final Secao secao;
  final String rotulo;
  final IconData icone;
}

/// Barra de baixo (celular): todas as áreas, 5 por página, na ordem de uso.
/// O assistente fica fora, na orbe ao lado da barra.
const _paginasBarra = [
  [
    _ItemNav(Secao.visao, 'Visão', Icons.home_outlined),
    _ItemNav(Secao.tarefas, 'Tarefas', Icons.check_box_outlined),
    _ItemNav(Secao.financas, 'Finanças', Icons.account_balance_wallet_outlined),
    _ItemNav(Secao.habitos, 'Hábitos', Icons.repeat_rounded),
    _ItemNav(Secao.saude, 'Saúde', Icons.monitor_heart_outlined),
  ],
  [
    _ItemNav(Secao.metas, 'Metas', Icons.flag_outlined),
    _ItemNav(Secao.lembretes, 'Lembretes', Icons.notifications_none_rounded),
    _ItemNav(Secao.projetos, 'Projetos', Icons.folder_outlined),
    _ItemNav(Secao.anotacoes, 'Anotações', Icons.sticky_note_2_outlined),
    _ItemNav(Secao.conta, 'Conta', Icons.person_outline_rounded),
  ],
];

/// Menu lateral (computador), em grupos: início, rotina, planos.
const _gruposLateral = [
  [_ItemNav(Secao.assistente, 'Assistente', iconeIa), _ItemNav(Secao.visao, 'Visão', Icons.home_outlined)],
  [
    _ItemNav(Secao.tarefas, 'Tarefas', Icons.check_box_outlined),
    _ItemNav(Secao.habitos, 'Hábitos', Icons.repeat_rounded),
    _ItemNav(Secao.saude, 'Saúde', Icons.monitor_heart_outlined),
    _ItemNav(Secao.lembretes, 'Lembretes', Icons.notifications_none_rounded),
  ],
  [
    _ItemNav(Secao.metas, 'Metas', Icons.flag_outlined),
    _ItemNav(Secao.projetos, 'Projetos', Icons.folder_outlined),
    _ItemNav(Secao.anotacoes, 'Anotações', Icons.sticky_note_2_outlined),
    _ItemNav(Secao.financas, 'Finanças', Icons.account_balance_wallet_outlined),
  ],
];
const _itemConta = _ItemNav(Secao.conta, 'Conta e sincronização', Icons.person_outline_rounded);

/// A partir desta largura a barra de navegação vai para a lateral.
const larguraDesktop = 840.0;

/// Abas das áreas que juntam várias telas. Medidas e Exercícios ficam dentro
/// de Treino (ver TreinoPage).
const abasSaude = ['Treino', 'Alimentação'];
const abasLembretes = ['Lembretes', 'Automações'];

class Shell extends StatefulWidget {
  const Shell({super.key, this.primeiraVez = false});

  /// Aparelho novo: mostra as boas-vindas antes de tudo.
  final bool primeiraVez;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  Secao _secao = Secao.visao;
  int _abaSaude = 0;
  SubTreino _subTreino = SubTreino.ficha;
  int _abaLembretes = 0;
  late bool _boasVindas = widget.primeiraVez;

  Future<void> _sairDasBoasVindas(String nome, Secao destino) async {
    final db = AuroraEscopo.de(context).db;
    if (nome.isNotEmpty) await db.salvarPreferencia('nome', nome);
    await db.salvarPreferencia(chaveInicio, DateTime.now().toIso8601String());
    if (!mounted) return;
    setState(() {
      _boasVindas = false;
      _secao = destino;
    });
  }

  @override
  void initState() {
    super.initState();
    // App instalado no Windows: confere se saiu versão nova.
    WidgetsBinding.instance.addPostFrameCallback((_) => oferecerAtualizacao(context));
    telaPedidaPelaIa.addListener(_abrirTelaDaIa);
  }

  @override
  void dispose() {
    telaPedidaPelaIa.removeListener(_abrirTelaDaIa);
    super.dispose();
  }

  /// A IA pediu para mostrar uma tela ("mostre minhas fotos do shape").
  void _abrirTelaDaIa() {
    final tela = telaPedidaPelaIa.value;
    if (tela == null || !mounted) return;
    setState(() {
      switch (tela) {
        case 'treino' || 'medidas' || 'exercicios' || 'shape':
          _secao = Secao.saude;
          _abaSaude = 0;
          _subTreino = switch (tela) {
            'medidas' => SubTreino.medidas,
            'exercicios' => SubTreino.exercicios,
            'shape' => SubTreino.shape,
            _ => SubTreino.ficha,
          };
        case 'alimentacao':
          _secao = Secao.saude;
          _abaSaude = 1;
        case 'lembretes' || 'automacoes':
          _secao = Secao.lembretes;
          _abaLembretes = tela == 'automacoes' ? 1 : 0;
        default:
          _secao = Secao.values.firstWhere((s) => s.name == tela, orElse: () => _secao);
      }
    });
  }

  void _ir(Secao s) => setState(() => _secao = s);

  final _atalhos = ControleAtalhos();

  /// "Ir para" da busca: as áreas e as abas mais procuradas.
  List<AtalhoArea> get _areasDaBusca => [
    for (final g in _gruposLateral)
      for (final i in g) AtalhoArea(i.rotulo, i.icone, () => _ir(i.secao)),
    AtalhoArea(
      'Alimentação',
      Icons.restaurant_rounded,
      () => setState(() {
        _secao = Secao.saude;
        _abaSaude = 1;
      }),
    ),
    for (final s in [SubTreino.medidas, SubTreino.exercicios, SubTreino.shape])
      AtalhoArea(
        s.rotulo,
        s.icone,
        () => setState(() {
          _secao = Secao.saude;
          _abaSaude = 0;
          _subTreino = s;
        }),
      ),
    AtalhoArea(
      'Automações',
      Icons.bolt_rounded,
      () => setState(() {
        _secao = Secao.lembretes;
        _abaLembretes = 1;
      }),
    ),
    AtalhoArea(_itemConta.rotulo, _itemConta.icone, () => _ir(Secao.conta)),
  ];

  void _buscar() {
    final desktop = MediaQuery.sizeOf(context).width >= larguraDesktop;
    abrirBusca(
      context,
      areas: _areasDaBusca,
      aoAbrir: _abrirResultado,
      aoPerguntar: (t) async {
        if (desktop) return _atalhos.perguntar(t);
        _ir(Secao.assistente);
        await AssistenteRepo(AuroraEscopo.de(context).db).enviar(t);
      },
      aoNovaTarefa: (t) async {
        await TarefasRepo(AuroraEscopo.de(context).db)
            .salvar(TarefasCompanion.insert(titulo: t, prazo: const Value(null)), avisar: false);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Criei a tarefa “$t”, sem data.'), behavior: SnackBarBehavior.floating));
      },
    );
  }

  /// Resultado escolhido na busca: vai para a área e abre o item para editar.
  Future<void> _abrirResultado(ResultadoBusca r) async {
    final db = AuroraEscopo.de(context).db;
    switch (r.tipo) {
      case TipoResultado.tarefa:
        _ir(Secao.tarefas);
        await abrirFormTarefa(context, tarefa: r.item as Tarefa);
      case TipoResultado.lembrete:
        setState(() {
          _secao = Secao.lembretes;
          _abaLembretes = 0;
        });
        await abrirFormLembrete(context, lembrete: r.item as Lembrete);
      case TipoResultado.transacao:
        _ir(Secao.financas);
        final q = await FinancasRepo(db).carregar();
        if (!mounted) return;
        await abrirFormLancamento(
          context,
          transacao: r.item as Transacao,
          contas: q.contas,
          contaPrincipalId: q.contaPrincipalId,
        );
      case TipoResultado.categoria:
        _ir(Secao.financas);
      case TipoResultado.habito:
        _ir(Secao.habitos);
        final metas = await (db.select(db.metas)..where((m) => m.apagadoEm.isNull())).get();
        if (!mounted) return;
        await abrirFormHabito(context, habito: r.item as Habito, metas: metas);
      case TipoResultado.meta:
        _ir(Secao.metas);
        await abrirFormMeta(context, meta: r.item as Meta);
      case TipoResultado.projeto:
        _ir(Secao.projetos);
        await abrirFormProjeto(context, projeto: r.item as Projeto);
      case TipoResultado.nota:
        _ir(Secao.anotacoes);
        pedidoAbrirNota.value = (r.item as NotaCompleta).id;
      case TipoResultado.treino || TipoResultado.exercicio:
        setState(() {
          _secao = Secao.saude;
          _abaSaude = 0;
          _subTreino = r.tipo == TipoResultado.treino ? SubTreino.ficha : SubTreino.exercicios;
        });
    }
  }

  Widget _pagina(bool desktop) => switch (_secao) {
    Secao.visao => VisaoPage(ir: _ir),
    Secao.tarefas => const TarefasPage(),
    Secao.habitos => const HabitosPage(),
    Secao.saude => AbasArea(
      abas: abasSaude,
      atual: _abaSaude,
      aoEscolher: (i) => setState(() => _abaSaude = i),
      child: _abaSaude == 0
          ? TreinoPage(sub: _subTreino, aoEscolher: (s) => setState(() => _subTreino = s))
          : const AlimentacaoPage(),
    ),
    Secao.lembretes => AbasArea(
      abas: abasLembretes,
      atual: _abaLembretes,
      aoEscolher: (i) => setState(() => _abaLembretes = i),
      child: _abaLembretes == 0 ? const LembretesPage() : AutomacoesPage(abrirAssistente: () => _ir(Secao.assistente)),
    ),
    Secao.financas => const FinancasPage(),
    Secao.metas => const MetasPage(),
    Secao.projetos => const ProjetosPage(),
    Secao.anotacoes => const AnotacoesPage(),
    Secao.assistente => const AssistentePage(),
    Secao.conta => const ContaPage(),
  };

  @override
  Widget build(BuildContext context) {
    if (_boasVindas) {
      return BoasVindasPage(
        aoComecar: (nome) => _sairDasBoasVindas(nome, Secao.visao),
        aoEntrar: () => _sairDasBoasVindas('', Secao.conta),
      );
    }
    final desktop = MediaQuery.sizeOf(context).width >= larguraDesktop;

    // No computador, assistente, tema e busca ficam nos atalhos do canto; o
    // cabeçalho só existe no celular.
    final cabecalho = desktop ? null : _Cabecalho(buscar: _buscar);
    final pagina = AnimatedSwitcher(
      duration: const Duration(milliseconds: 160),
      child: KeyedSubtree(key: ValueKey((_secao, _abaSaude, _abaLembretes)), child: _pagina(desktop)),
    );
    // No celular o conteúdo passa por baixo da barra de vidro (extendBody): a
    // margem de baixo soma a altura da barra, que o Scaffold põe no MediaQuery.
    Widget conteudo(BuildContext ctx) {
      final barra = desktop ? 0.0 : MediaQuery.paddingOf(ctx).bottom;
      return SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            // Anotações usa a largura da janela (mural e colunas da Lista).
            constraints: BoxConstraints(maxWidth: _secao == Secao.anotacoes ? 1320 : 820),
            // O assistente e as anotações ocupam a altura toda (rolam por dentro,
            // com o campo ou os botões fixos); as outras áreas rolam inteiras.
            child: _secao == Secao.assistente || _secao == Secao.anotacoes
                ? Padding(
                    padding: desktop
                        ? const EdgeInsets.fromLTRB(Espaco.xl, Espaco.lg, Espaco.xl, Espaco.lg)
                        : EdgeInsets.fromLTRB(20, Espaco.md, 20, Espaco.md + barra),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (cabecalho != null) ...[cabecalho, const SizedBox(height: Espaco.md)],
                        Expanded(child: pagina),
                      ],
                    ),
                  )
                : ListView(
                    padding: desktop
                        ? const EdgeInsets.fromLTRB(Espaco.xl, Espaco.lg, Espaco.xl, Espaco.xxl)
                        : EdgeInsets.fromLTRB(20, Espaco.md, 20, Espaco.xl + barra),
                    children: [
                      if (cabecalho != null) ...[cabecalho, const SizedBox(height: Espaco.lg)],
                      pagina,
                    ],
                  ),
          ),
        ),
      );
    }

    // Um BackdropGroup para a tela toda: barra e cartões de vidro leem o fundo
    // uma vez só por quadro.
    if (desktop) {
      // O céu fica atrás da janela inteira; o menu é vidro por cima dele.
      return BackdropGroup(
        child: Scaffold(
          body: CeuEstrelado(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _BarraLateral(atual: _secao, ir: _ir),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, box) => Stack(
                      children: [
                        // Janela estreita: o conteúdo abre espaço à direita para
                        // não ficar por baixo dos atalhos.
                        Padding(
                          padding: EdgeInsets.only(right: box.maxWidth < 1000 ? 76 : 0),
                          child: Builder(builder: conteudo),
                        ),
                        Positioned.fill(
                          child: AtalhosFlutuantes(
                            controle: _atalhos,
                            aoBuscar: _buscar,
                            aoAbrirAssistente: () => _ir(Secao.assistente),
                            assistenteNaTela: () => _secao == Secao.assistente,
                            aoNovaNota: (tipo) {
                              _ir(Secao.anotacoes);
                              pedidoNovaNota.value = tipo;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return BackdropGroup(
      child: Scaffold(
        extendBody: true,
        body: CeuEstrelado(child: Builder(builder: conteudo)),
        bottomNavigationBar: _BarraFlutuante(atual: _secao, ir: _ir),
      ),
    );
  }
}

/// Área com abas no topo (Saúde, Lembretes), com "voltar" opcional.
class AbasArea extends StatelessWidget {
  const AbasArea({
    super.key,
    required this.abas,
    required this.atual,
    required this.aoEscolher,
    required this.child,
    this.voltar,
  });

  final List<String> abas;
  final int atual;
  final ValueChanged<int> aoEscolher;
  final Widget child;
  final VoidCallback? voltar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (voltar != null)
              IconButton(
                onPressed: voltar,
                tooltip: 'Voltar',
                icon: Icon(Icons.chevron_left_rounded, size: 28, color: c.text),
              ),
            Expanded(
              child: Segmentos<int>(
                opcoes: [for (var i = 0; i < abas.length; i++) i],
                selecionado: atual,
                rotulo: (i) => abas[i],
                aoEscolher: aoEscolher,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        child,
      ],
    );
  }
}

/// Cabeçalho do celular: logo, busca e tema (o assistente é a orbe ao lado da barra).
class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.buscar});

  final VoidCallback buscar;

  @override
  Widget build(BuildContext context) {
    final escopo = AuroraEscopo.de(context);
    final escuro = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        const LogoAurora(),
        const SizedBox(width: 10),
        Text('Aurora', style: sora(18, espaco: 0.7)),
        const Spacer(),
        BotaoRedondo(icone: Icons.search_rounded, dica: 'Buscar em tudo', aoTocar: buscar),
        const SizedBox(width: 8),
        BotaoRedondo(
          icone: escuro ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          dica: 'Alternar modo claro e escuro',
          aoTocar: escopo.alternarTema,
        ),
      ],
    );
  }
}

/// Barra do celular (variação C, 25/10/2026): pílula de vidro flutuante só com
/// ícones, 5 por página (arrasta de lado para as outras), a área ativa num
/// círculo com o degradê da aurora e, embaixo, o nome dela e os pontinhos das
/// páginas. À direita, a orbe da Aurora abre o assistente.
class _BarraFlutuante extends StatefulWidget {
  const _BarraFlutuante({required this.atual, required this.ir});
  final Secao atual;
  final ValueChanged<Secao> ir;

  @override
  State<_BarraFlutuante> createState() => _BarraFlutuanteState();
}

class _BarraFlutuanteState extends State<_BarraFlutuante> {
  late int _pagina = _paginaDe(widget.atual) ?? 0;
  late final _paginas = PageController(initialPage: _pagina);

  static int? _paginaDe(Secao s) {
    for (var p = 0; p < _paginasBarra.length; p++) {
      if (_paginasBarra[p].any((i) => i.secao == s)) return p;
    }
    return null;
  }

  @override
  void didUpdateWidget(_BarraFlutuante antigo) {
    super.didUpdateWidget(antigo);
    // Foi para uma área da outra página (pela busca, por exemplo): a barra acompanha.
    final p = _paginaDe(widget.atual);
    if (p != null && p != _pagina && _paginas.hasClients) {
      _pagina = p;
      final parado = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
      parado
          ? _paginas.jumpToPage(p)
          : _paginas.animateToPage(p, duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
    }
  }

  @override
  void dispose() {
    _paginas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final escuro = Theme.of(context).brightness == Brightness.dark;
    if (kIsWeb) {
      // iPhone (tela de início): a faixa abaixo da página continua o céu.
      WidgetsBinding.instance.addPostFrameCallback((_) => definirCorDaBorda(c.bg));
    }
    final rotuloAtivo = [
      for (final pg in _paginasBarra)
        for (final i in pg)
          if (i.secao == widget.atual) i.rotulo,
    ].firstOrNull;
    final pilula = Vidro(
      tipo: TipoVidro.barra,
      raio: BorderRadius.circular(34),
      cor: escuro ? null : c.surface,
      child: SizedBox(
        height: 68,
        child: PageView(
          controller: _paginas,
          onPageChanged: (p) => setState(() => _pagina = p),
          children: [
            for (final pg in _paginasBarra)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (final item in pg)
                      _IconeBarra(item: item, ativo: item.secao == widget.atual, aoTocar: () => widget.ir(item.secao)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
    // O conteúdo rola por baixo da barra: um esmaecido do céu atrás dela deixa
    // o nome e os pontinhos legíveis sem cobrir a tela com uma faixa.
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.bg.withValues(alpha: 0), c.bg.withValues(alpha: 0.82), c.bg.withValues(alpha: 0.95)],
          stops: const [0, 0.45, 1],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(14, 16, 14, MediaQuery.paddingOf(context).bottom > 0 ? 2 : 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(34),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: escuro ? 0.45 : 0.12),
                            blurRadius: 26,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: pilula,
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 18,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (rotuloAtivo != null) ...[
                            Text(
                              rotuloAtivo,
                              style: manrope(11, peso: FontWeight.w700, cor: c.text),
                            ),
                            const SizedBox(width: 8),
                          ],
                          for (var p = 0; p < _paginasBarra.length; p++)
                            Semantics(
                              button: true,
                              selected: p == _pagina,
                              label: 'Página ${p + 1} do menu',
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _paginas.animateToPage(
                                  p,
                                  duration: const Duration(milliseconds: 280),
                                  curve: Curves.easeOutCubic,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: p == _pagina ? 20 : 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: p == _pagina ? c.text : c.muted.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _OrbeAurora(ativa: widget.atual == Secao.assistente, aoTocar: () => widget.ir(Secao.assistente)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ícone da barra: o ativo ganha um círculo com o degradê da aurora.
class _IconeBarra extends StatelessWidget {
  const _IconeBarra({required this.item, required this.ativo, required this.aoTocar});
  final _ItemNav item;
  final bool ativo;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final parado = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return Tooltip(
      message: item.rotulo,
      child: Semantics(
        button: true,
        selected: ativo,
        label: item.rotulo,
        excludeSemantics: true,
        child: AnimatedScale(
          scale: ativo ? 1.06 : 1,
          duration: parado ? Duration.zero : const Duration(milliseconds: 200),
          child: Material(
            type: MaterialType.transparency,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: Ink(
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: ativo ? c.gradiente : null),
              child: InkWell(
                onTap: aoTocar,
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: Icon(item.icone, size: 24, color: ativo ? c.noAccent : c.muted),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A orbe da Aurora ao lado da barra: abre o assistente.
class _OrbeAurora extends StatelessWidget {
  const _OrbeAurora({required this.ativa, required this.aoTocar});
  final bool ativa;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final escuro = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: 'Abrir a Aurora',
      child: Semantics(
        button: true,
        selected: ativa,
        label: 'Abrir a Aurora (assistente)',
        excludeSemantics: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ativa ? c.accent : (escuro ? Colors.white.withValues(alpha: 0.10) : c.line)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: escuro ? 0.45 : 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
              BoxShadow(color: c.teal.withValues(alpha: escuro ? 0.22 : 0.10), blurRadius: 22),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: Ink(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(0, -0.2),
                  colors: escuro
                      ? [c.teal.withValues(alpha: 0.30), c.gradFim.withValues(alpha: 0.18), c.surface]
                      : [c.accent.withValues(alpha: 0.28), c.gradFim.withValues(alpha: 0.20), c.surface],
                  stops: const [0, 0.45, 0.8],
                ),
              ),
              child: InkWell(
                onTap: aoTocar,
                child: SizedBox(
                  width: 68,
                  height: 68,
                  child: CustomPaint(painter: _FaiscasOrbe([c.accent, c.teal, c.violeta])),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pontinhos de luz espalhados dentro da orbe (sempre nos mesmos lugares).
class _FaiscasOrbe extends CustomPainter {
  _FaiscasOrbe(this.cores);
  final List<Color> cores;

  @override
  void paint(Canvas canvas, Size size) {
    var x = 17;
    final p = Paint();
    for (var k = 0; k < 18; k++) {
      x = (x * 9301 + 49297) % 233280;
      final px = 0.2 + (x / 233280) * 0.6;
      x = (x * 9301 + 49297) % 233280;
      final py = 0.2 + (x / 233280) * 0.6;
      p.color = cores[k % cores.length].withValues(alpha: 0.45 + (k % 3) * 0.2);
      canvas.drawCircle(Offset(px * size.width, py * size.height), k % 4 == 0 ? 1.6 : 1.1, p);
    }
  }

  @override
  bool shouldRepaint(_FaiscasOrbe old) => old.cores != cores;
}

/// Menu lateral (computador): dock só de ícones flutuando. Os ícones
/// crescem com mola perto do mouse e o nome aparece ao lado (ver MenuDock).
class _BarraLateral extends StatelessWidget {
  const _BarraLateral({required this.atual, required this.ir});
  final Secao atual;
  final ValueChanged<Secao> ir;

  @override
  Widget build(BuildContext context) {
    final itens = <ItemDock>[];
    for (var g = 0; g < _gruposLateral.length; g++) {
      for (var i = 0; i < _gruposLateral[g].length; i++) {
        final item = _gruposLateral[g][i];
        itens.add(
          ItemDock(
            icone: item.icone,
            rotulo: item.rotulo,
            ativo: atual == item.secao,
            aoTocar: () => ir(item.secao),
            espacoAntes: g > 0 && i == 0 ? 16 : 0,
          ),
        );
      }
    }
    itens.add(
      ItemDock(
        icone: _itemConta.icone,
        rotulo: _itemConta.rotulo,
        ativo: atual == _itemConta.secao,
        aoTocar: () => ir(_itemConta.secao),
        espacoAntes: 16,
      ),
    );
    // Sem painel, fundo nem borda. Os ícones flutuam sobre o
    // céu, numa coluna de 72 px centralizada na vertical (sem o logo: o primeiro
    // item já é o da Aurora, o assistente). A faixa fica reservada para o
    // conteúdo não passar por baixo dos ícones em janelas estreitas.
    return SizedBox(
      width: 72,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: MenuDock(itens: itens),
        ),
      ),
    );
  }
}
