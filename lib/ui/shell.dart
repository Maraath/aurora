import 'package:flutter/material.dart';

import '../app.dart';
import '../core/tema.dart';
import 'componentes.dart';
import 'alimentacao/alimentacao_page.dart';
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

enum Secao {
  visao,
  tarefas,
  habitos,
  financas,
  mais,
  metas,
  lembretes,
  projetos,
  assistente,
  treino,
  medidas,
  alimentacao,
  automacoes,
  biblioteca,
  conta,
}

class _ItemNav {
  const _ItemNav(this.secao, this.rotulo, this.icone);
  final Secao secao;
  final String rotulo;
  final IconData icone;
}

const _itensNav = [
  _ItemNav(Secao.visao, 'Visão', Icons.home_outlined),
  _ItemNav(Secao.tarefas, 'Tarefas', Icons.check_box_outlined),
  _ItemNav(Secao.habitos, 'Hábitos', Icons.monitor_heart_outlined),
  _ItemNav(Secao.financas, 'Finanças', Icons.credit_card_outlined),
  _ItemNav(Secao.mais, 'Mais', Icons.grid_view_rounded),
];

/// A partir desta largura a barra de navegação vai para a lateral.
const larguraDesktop = 840.0;

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  Secao _secao = Secao.visao;

  void _ir(Secao s) => setState(() => _secao = s);

  /// Metas, Lembretes e Projetos ficam dentro de "Mais".
  Secao get _secaoDaBarra => switch (_secao) {
        Secao.metas || Secao.lembretes || Secao.projetos || Secao.conta || Secao.automacoes => Secao.mais,
        Secao.treino || Secao.medidas || Secao.alimentacao || Secao.biblioteca => Secao.habitos,
        _ => _secao,
      };

  Widget _pagina() => switch (_secao) {
        Secao.visao => VisaoPage(ir: _ir),
        Secao.mais => MaisPage(ir: _ir),
        Secao.tarefas => const TarefasPage(),
        Secao.habitos => HabitosPage(ir: _ir),
        Secao.treino => FichaPage(
            voltar: () => _ir(Secao.habitos), abrirBiblioteca: () => _ir(Secao.biblioteca)),
        Secao.biblioteca => BibliotecaPage(voltar: () => _ir(Secao.treino)),
        Secao.medidas => MedidasPage(voltar: () => _ir(Secao.habitos)),
        Secao.alimentacao => AlimentacaoPage(voltar: () => _ir(Secao.habitos)),
        Secao.financas => const FinancasPage(),
        Secao.metas => MetasPage(voltar: () => _ir(Secao.mais)),
        Secao.lembretes => LembretesPage(voltar: () => _ir(Secao.mais)),
        Secao.projetos => ProjetosPage(voltar: () => _ir(Secao.mais)),
        Secao.assistente => const AssistentePage(),
        Secao.conta => ContaPage(voltar: () => _ir(Secao.mais)),
        Secao.automacoes => AutomacoesPage(
            voltar: () => _ir(Secao.mais), abrirAssistente: () => _ir(Secao.assistente)),
      };

  @override
  Widget build(BuildContext context) {
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
                child: KeyedSubtree(key: ValueKey(_secao), child: _pagina()),
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
            _BarraLateral(atual: _secaoDaBarra, ir: _ir),
            VerticalDivider(width: 1, thickness: 1, color: c.line),
            Expanded(child: conteudo),
          ],
        ),
      );
    }
    return Scaffold(
      body: conteudo,
      bottomNavigationBar: _BarraInferior(atual: _secaoDaBarra, ir: _ir),
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
  const _BotaoNav({required this.item, required this.ativo, required this.aoTocar, this.horizontal = false});

  final _ItemNav item;
  final bool ativo;
  final VoidCallback aoTocar;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final cor = ativo ? c.accent : c.muted;
    final icone = Icon(item.icone, size: 22, color: cor);
    final texto = Text(item.rotulo,
        style: manrope(horizontal ? 14 : 11, peso: FontWeight.w700, cor: cor));
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
            padding: horizontal ? const EdgeInsets.symmetric(horizontal: 14) : EdgeInsets.zero,
            child: horizontal
                ? Row(children: [icone, const SizedBox(width: 12), texto])
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [icone, const SizedBox(height: 3), texto],
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
              for (final item in _itensNav)
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

class _BarraLateral extends StatelessWidget {
  const _BarraLateral({required this.atual, required this.ir});
  final Secao atual;
  final ValueChanged<Secao> ir;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Container(
      width: 232,
      color: c.surface,
      padding: const EdgeInsets.fromLTRB(14, 24, 14, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 28),
            child: Row(children: [
              const LogoAurora(),
              const SizedBox(width: 10),
              Text('Aurora', style: sora(18, espaco: 0.7)),
            ]),
          ),
          for (final item in _itensNav)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _BotaoNav(
                item: item,
                ativo: atual == item.secao,
                horizontal: true,
                aoTocar: () => ir(item.secao),
              ),
            ),
        ],
      ),
    );
  }
}
