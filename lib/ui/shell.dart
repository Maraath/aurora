import 'package:flutter/material.dart';

import '../app.dart';
import '../core/tema.dart';
import '../data/exemplo.dart';
import 'componentes.dart';
import 'alimentacao/alimentacao_page.dart';
import 'atualizacao_ui.dart';
import 'boas_vindas_page.dart';
import 'ceu_estrelado.dart';
import 'assistente/assistente_page.dart';
import 'automacoes/automacoes_page.dart';
import 'conta/conta_page.dart';
import 'financas/financas_page.dart';
import 'habitos/habitos_page.dart';
import 'lembretes/lembretes_page.dart';
import 'mais_page.dart';
import 'menu_dock.dart';
import 'metas/metas_page.dart';
import 'projetos/projetos_page.dart';
import 'saude/treino_page.dart';
import 'vidro.dart';
import 'tarefas/tarefas_page.dart';
import 'visao/visao_page.dart';

/// Áreas do app. Cada uma aparece direto no menu lateral e
/// organiza o conteúdo em abas no topo; no celular, as que não cabem na barra
/// de baixo ficam em "Mais".
enum Secao {
  visao,
  assistente,
  tarefas,
  habitos,
  saude,
  lembretes,
  metas,
  projetos,
  financas,
  conta,
  mais,
}

class _ItemNav {
  const _ItemNav(this.secao, this.rotulo, this.icone);
  final Secao secao;
  final String rotulo;
  final IconData icone;
}

/// Barra de baixo (celular).
const _itensBarra = [
  _ItemNav(Secao.visao, 'Visão', Icons.home_outlined),
  _ItemNav(Secao.tarefas, 'Tarefas', Icons.check_box_outlined),
  _ItemNav(Secao.habitos, 'Hábitos', Icons.repeat_rounded),
  _ItemNav(Secao.financas, 'Finanças', Icons.account_balance_wallet_outlined),
  _ItemNav(Secao.mais, 'Mais', Icons.grid_view_rounded),
];

/// Menu lateral (computador), em grupos: início, rotina, planos.
const _gruposLateral = [
  [
    _ItemNav(Secao.assistente, 'Assistente', Icons.auto_awesome_outlined),
    _ItemNav(Secao.visao, 'Visão', Icons.home_outlined),
  ],
  [
    _ItemNav(Secao.tarefas, 'Tarefas', Icons.check_box_outlined),
    _ItemNav(Secao.habitos, 'Hábitos', Icons.repeat_rounded),
    _ItemNav(Secao.saude, 'Saúde', Icons.monitor_heart_outlined),
    _ItemNav(Secao.lembretes, 'Lembretes', Icons.notifications_none_rounded),
  ],
  [
    _ItemNav(Secao.metas, 'Metas', Icons.flag_outlined),
    _ItemNav(Secao.projetos, 'Projetos', Icons.folder_outlined),
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
  }

  void _ir(Secao s) => setState(() => _secao = s);

  /// No celular, as áreas fora da barra de baixo acendem "Mais".
  Secao _secaoDaBarra(bool desktop) {
    if (desktop) return _secao;
    return _itensBarra.any((i) => i.secao == _secao) ? _secao : Secao.mais;
  }

  /// "Voltar" só no celular, para retornar a "Mais".
  VoidCallback? _voltar(bool desktop) => desktop ? null : () => _ir(Secao.mais);

  Widget _pagina(bool desktop) => switch (_secao) {
        Secao.visao => VisaoPage(ir: _ir),
        Secao.mais => MaisPage(ir: _ir),
        Secao.tarefas => const TarefasPage(),
        Secao.habitos => const HabitosPage(),
        Secao.saude => AbasArea(
            abas: abasSaude,
            atual: _abaSaude,
            aoEscolher: (i) => setState(() => _abaSaude = i),
            voltar: _voltar(desktop),
            child: _abaSaude == 0
                ? TreinoPage(
                    sub: _subTreino,
                    aoEscolher: (s) => setState(() => _subTreino = s),
                  )
                : const AlimentacaoPage(),
          ),
        Secao.lembretes => AbasArea(
            abas: abasLembretes,
            atual: _abaLembretes,
            aoEscolher: (i) => setState(() => _abaLembretes = i),
            voltar: _voltar(desktop),
            child: _abaLembretes == 0
                ? const LembretesPage()
                : AutomacoesPage(abrirAssistente: () => _ir(Secao.assistente)),
          ),
        Secao.financas => const FinancasPage(),
        Secao.metas => MetasPage(voltar: _voltar(desktop)),
        Secao.projetos => ProjetosPage(voltar: _voltar(desktop)),
        Secao.assistente => const AssistentePage(),
        Secao.conta => ContaPage(voltar: _voltar(desktop)),
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

    final cabecalho = _Cabecalho(
      mostrarLogo: !desktop,
      assistenteAtivo: _secao == Secao.assistente,
      abrirAssistente: () => _ir(Secao.assistente),
    );
    final pagina = AnimatedSwitcher(
      duration: const Duration(milliseconds: 160),
      child: KeyedSubtree(
        key: ValueKey((_secao, _abaSaude, _abaLembretes)),
        child: _pagina(desktop),
      ),
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
          constraints: const BoxConstraints(maxWidth: 820),
          // O assistente ocupa a altura toda (conversa rolando e campo fixo
          // embaixo); as outras áreas rolam inteiras.
          child: _secao == Secao.assistente
              ? Padding(
                  padding: desktop
                      ? const EdgeInsets.fromLTRB(Espaco.xl, Espaco.lg, Espaco.xl, Espaco.lg)
                      : EdgeInsets.fromLTRB(20, Espaco.md, 20, Espaco.md + barra),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      cabecalho,
                      const SizedBox(height: Espaco.md),
                      Expanded(child: pagina),
                    ],
                  ),
                )
              : ListView(
                  padding: desktop
                      ? const EdgeInsets.fromLTRB(Espaco.xl, Espaco.lg, Espaco.xl, Espaco.xxl)
                      : EdgeInsets.fromLTRB(20, Espaco.md, 20, Espaco.xl + barra),
                  children: [cabecalho, const SizedBox(height: Espaco.lg), pagina],
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
                _BarraLateral(atual: _secaoDaBarra(true), ir: _ir),
                Expanded(child: Builder(builder: conteudo)),
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
        bottomNavigationBar: _BarraInferior(atual: _secaoDaBarra(false), ir: _ir),
      ),
    );
  }
}

/// Área com abas no topo (Saúde, Lembretes). No celular ganha "voltar" para "Mais".
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
        Row(children: [
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
        ]),
        const SizedBox(height: 20),
        child,
      ],
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({
    required this.mostrarLogo,
    required this.assistenteAtivo,
    required this.abrirAssistente,
  });

  final bool mostrarLogo;
  final bool assistenteAtivo;
  final VoidCallback abrirAssistente;

  @override
  Widget build(BuildContext context) {
    final escopo = AuroraEscopo.de(context);
    final escuro = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        if (mostrarLogo) ...[
          const LogoAurora(),
          const SizedBox(width: 10),
          Text('Aurora', style: sora(18, espaco: 0.7)),
        ],
        const Spacer(),
        BotaoRedondo(
          icone: Icons.auto_awesome_outlined,
          dica: 'Abrir assistente',
          ativo: assistenteAtivo,
          aoTocar: abrirAssistente,
        ),
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

class _BotaoNav extends StatelessWidget {
  const _BotaoNav({required this.item, required this.ativo, required this.aoTocar});

  final _ItemNav item;
  final bool ativo;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final cor = ativo ? c.accent : c.muted;
    return Semantics(
      selected: ativo,
      button: true,
      child: Material(
        color: ativo ? c.accentSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icone, size: 22, color: cor),
                const SizedBox(height: 3),
                Text(item.rotulo, style: manrope(11, peso: FontWeight.w700, cor: cor)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BarraInferior extends StatelessWidget {
  const _BarraInferior({required this.atual, required this.ir});
  final Secao atual;
  final ValueChanged<Secao> ir;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final escuro = Theme.of(context).brightness == Brightness.dark;
    return Vidro(
      tipo: TipoVidro.barra,
      lados: Border(top: BorderSide(color: escuro ? Colors.white.withValues(alpha: 0.09) : c.line)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          child: Row(
            children: [
              for (final item in _itensBarra)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _BotaoNav(
                        item: item, ativo: atual == item.secao, aoTocar: () => ir(item.secao)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
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
        itens.add(ItemDock(
          icone: item.icone,
          rotulo: item.rotulo,
          ativo: atual == item.secao,
          aoTocar: () => ir(item.secao),
          espacoAntes: g > 0 && i == 0 ? 16 : 0,
        ));
      }
    }
    itens.add(ItemDock(
      icone: _itemConta.icone,
      rotulo: _itemConta.rotulo,
      ativo: atual == _itemConta.secao,
      aoTocar: () => ir(_itemConta.secao),
      espacoAntes: 16,
    ));
    // Sem painel, fundo nem borda. Logo e ícones flutuam sobre o
    // céu, numa coluna de 72 px centralizada na vertical. A faixa fica reservada
    // para o conteúdo não passar por baixo dos ícones em janelas estreitas.
    return SizedBox(
      width: 72,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const LogoAurora(tamanho: 34),
            const SizedBox(height: 22),
            MenuDock(itens: itens),
          ]),
        ),
      ),
    );
  }
}
