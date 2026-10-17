import 'package:flutter/material.dart';

import '../app.dart';
import '../core/tema.dart';
import '../data/exemplo.dart';
import 'componentes.dart';
import 'alimentacao/alimentacao_page.dart';
import 'atualizacao_ui.dart';
import 'boas_vindas_page.dart';
import 'assistente/assistente_page.dart';
import 'automacoes/automacoes_page.dart';
import 'conta/conta_page.dart';
import 'financas/financas_page.dart';
import 'habitos/habitos_page.dart';
import 'lembretes/lembretes_page.dart';
import 'mais_page.dart';
import 'metas/metas_page.dart';
import 'projetos/projetos_page.dart';
import 'saude/biblioteca_ui.dart';
import 'saude/ficha_page.dart';
import 'saude/medidas_page.dart';
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

/// Abas das áreas que juntam várias telas.
const abasSaude = ['Treino', 'Alimentação', 'Medidas', 'Exercícios'];
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
            child: switch (_abaSaude) {
              0 => const FichaPage(),
              1 => const AlimentacaoPage(),
              2 => const MedidasPage(),
              _ => const BibliotecaPage(),
            },
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
    final c = context.cores;
    final desktop = MediaQuery.sizeOf(context).width >= larguraDesktop;

    final conteudo = SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, desktop ? 40 : 28),
            children: [
              _Cabecalho(
                mostrarLogo: !desktop,
                assistenteAtivo: _secao == Secao.assistente,
                abrirAssistente: () => _ir(Secao.assistente),
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: KeyedSubtree(
                  key: ValueKey((_secao, _abaSaude, _abaLembretes)),
                  child: _pagina(desktop),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (desktop) {
      return Scaffold(
        body: Row(
          children: [
            _BarraLateral(atual: _secaoDaBarra(true), ir: _ir),
            VerticalDivider(width: 1, thickness: 1, color: c.line),
            Expanded(child: conteudo),
          ],
        ),
      );
    }
    return Scaffold(
      body: conteudo,
      bottomNavigationBar: _BarraInferior(atual: _secaoDaBarra(false), ir: _ir),
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
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.line)),
      ),
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

/// Menu lateral estreito, só de ícones: o nome da área
/// aparece ao passar o mouse. Grupos separados por um traço; Conta embaixo.
class _BarraLateral extends StatelessWidget {
  const _BarraLateral({required this.atual, required this.ir});
  final Secao atual;
  final ValueChanged<Secao> ir;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Container(
      width: 72,
      color: c.surface,
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        children: [
          const Tooltip(message: 'Aurora', child: LogoAurora(tamanho: 34)),
          const SizedBox(height: 18),
          for (var g = 0; g < _gruposLateral.length; g++) ...[
            if (g > 0)
              Container(
                width: 24,
                height: 1,
                margin: const EdgeInsets.symmetric(vertical: 10),
                color: c.line,
              ),
            for (final item in _gruposLateral[g])
              _IconeLateral(item: item, ativo: atual == item.secao, aoTocar: () => ir(item.secao)),
          ],
          const Spacer(),
          _IconeLateral(item: _itemConta, ativo: atual == _itemConta.secao, aoTocar: () => ir(_itemConta.secao)),
        ],
      ),
    );
  }
}

class _IconeLateral extends StatelessWidget {
  const _IconeLateral({required this.item, required this.ativo, required this.aoTocar});
  final _ItemNav item;
  final bool ativo;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Tooltip(
        message: item.rotulo,
        preferBelow: false,
        verticalOffset: 0,
        margin: const EdgeInsets.only(left: 64),
        child: Semantics(
          label: item.rotulo,
          selected: ativo,
          button: true,
          child: Material(
            color: ativo ? c.accentSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: aoTocar,
              child: SizedBox(
                width: 48,
                height: 44,
                child: Icon(item.icone, size: 22, color: ativo ? c.accent : c.muted),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
