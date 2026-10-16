import 'package:flutter/material.dart';

import '../app.dart';
import '../core/tema.dart';
import 'componentes.dart';
import 'em_breve.dart';
import 'mais_page.dart';
import 'visao/visao_page.dart';

enum Secao { visao, tarefas, habitos, financas, mais, metas, lembretes, projetos, assistente }

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
        Secao.metas || Secao.lembretes || Secao.projetos => Secao.mais,
        _ => _secao,
      };

  Widget _pagina() => switch (_secao) {
        Secao.visao => VisaoPage(ir: _ir),
        Secao.mais => MaisPage(ir: _ir),
        Secao.tarefas => const EmBreve(
            titulo: 'Tarefas',
            fase: 'Fase 2',
            descricao: 'Criar, repetir e concluir tarefas, com prioridade, prazo e calendário.'),
        Secao.habitos => const EmBreve(
            titulo: 'Hábitos e saúde',
            fase: 'Fase 2',
            descricao: 'Rotina do dia, semana com progresso e calendário. Treino e medidas chegam na Fase 4.'),
        Secao.financas => const EmBreve(
            titulo: 'Finanças',
            fase: 'Fase 3',
            descricao: 'Contas e cartões, contas a pagar, recorrentes, parceladas e para onde foi o dinheiro.'),
        Secao.metas => EmBreve(
            titulo: 'Metas',
            fase: 'Fase 3',
            descricao: 'Progresso, ritmo necessário por semana e tarefas ligadas a cada meta.',
            voltar: () => _ir(Secao.mais)),
        Secao.lembretes => EmBreve(
            titulo: 'Lembretes',
            fase: 'Fase 2',
            descricao: 'A seguir, hoje, esta semana e recorrentes, com notificação no aparelho.',
            voltar: () => _ir(Secao.mais)),
        Secao.projetos => EmBreve(
            titulo: 'Projetos',
            fase: 'Fase 5 (V2)',
            descricao: 'Linha do tempo por mês, etapas e status de cada projeto.',
            voltar: () => _ir(Secao.mais)),
        Secao.assistente => const EmBreve(
            titulo: 'Assistente',
            fase: 'Fase 5 (V2)',
            descricao: 'Peça em linguagem natural: "me lembra de pagar a faculdade todo dia 11", '
                '"gastei 35 no mercado". Sem internet, comandos rápidos funcionam e o resto vai para a fila.'),
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
