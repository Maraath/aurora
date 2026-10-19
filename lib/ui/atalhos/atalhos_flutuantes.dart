import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/assistente_repo.dart';
import '../../data/banco.dart';
import '../../data/financas_repo.dart';
import '../../data/habitos_repo.dart';
import '../assistente/assistente_page.dart';
import '../financas/form_lancamento.dart';
import '../habitos/form_habito.dart';
import '../lembretes/form_lembrete.dart';
import '../tarefas/form_tarefa.dart';
import '../vidro.dart';
import 'captura.dart';

enum _Painel { nenhum, mais, captura, habitos, chat }

/// Controle dos atalhos de fora (Shell, busca): abrir o mini chat já com uma
/// pergunta, por exemplo.
class ControleAtalhos {
  _AtalhosFlutuantesState? _estado;

  /// Abre o mini chat; com [pergunta], manda antes para a Aurora.
  Future<void> perguntar([String pergunta = '']) async => _estado?._perguntar(pergunta);
}

/// Atalhos do canto inferior direito (computador): Buscar
/// (Ctrl+K), Tema, Mini chat com a Aurora e o botão + de ação rápida. Fica por
/// cima de todas as telas; os painéis abrem à esquerda dos botões.
class AtalhosFlutuantes extends StatefulWidget {
  const AtalhosFlutuantes({
    super.key,
    required this.aoBuscar,
    required this.aoAbrirAssistente,
    this.controle,
  });

  final VoidCallback aoBuscar;

  /// Abre a área Assistente em tela cheia.
  final VoidCallback aoAbrirAssistente;
  final ControleAtalhos? controle;

  @override
  State<AtalhosFlutuantes> createState() => _AtalhosFlutuantesState();
}

class _AtalhosFlutuantesState extends State<AtalhosFlutuantes> {
  _Painel _painel = _Painel.nenhum;
  StreamSubscription<List<MensagemAssistente>>? _conversa;
  BancoAurora? _db;

  /// Última mensagem vista; resposta nova da Aurora depois dela acende o ponto.
  String? _vistaAte;
  String? _ultimaAurora;

  @override
  void initState() {
    super.initState();
    widget.controle?._estado = this;
    HardwareKeyboard.instance.addHandler(_tecla);
  }

  @override
  void didUpdateWidget(AtalhosFlutuantes antigo) {
    super.didUpdateWidget(antigo);
    if (antigo.controle != widget.controle) {
      antigo.controle?._estado = null;
      widget.controle?._estado = this;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = AuroraEscopo.de(context).db;
    if (db == _db) return;
    _db = db;
    _conversa?.cancel();
    var primeira = true;
    _conversa = AssistenteRepo(db).observarConversa().listen((lista) {
      final ultima = lista.where((m) => m.papel == PapelMensagem.aurora).lastOrNull?.id;
      if (!mounted) return;
      setState(() {
        _ultimaAurora = ultima;
        // Ao abrir o app, o que já estava lá conta como visto.
        if (primeira || _painel == _Painel.chat) _vistaAte = _ultimaAurora;
        primeira = false;
      });
    });
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_tecla);
    _conversa?.cancel();
    if (widget.controle?._estado == this) widget.controle?._estado = null;
    super.dispose();
  }

  bool get _naFrente => ModalRoute.of(context)?.isCurrent ?? true;

  /// Teclado: Ctrl+K busca, Esc fecha o painel, e as letras do menu +.
  bool _tecla(KeyEvent e) {
    if (e is! KeyDownEvent || !mounted || !_naFrente) return false;
    final k = e.logicalKey;
    final ctrl = HardwareKeyboard.instance.isControlPressed || HardwareKeyboard.instance.isMetaPressed;
    if (ctrl && k == LogicalKeyboardKey.keyK) {
      _fechar();
      widget.aoBuscar();
      return true;
    }
    if (k == LogicalKeyboardKey.escape && _painel != _Painel.nenhum) {
      _fechar();
      return true;
    }
    if (_painel == _Painel.mais && !ctrl) {
      final acao = {
        LogicalKeyboardKey.keyQ: () => _abrir(_Painel.captura),
        LogicalKeyboardKey.keyT: _novaTarefa,
        LogicalKeyboardKey.keyL: _novoLancamento,
        LogicalKeyboardKey.keyR: _novoLembrete,
        LogicalKeyboardKey.keyH: () => _abrir(_Painel.habitos),
      }[k];
      if (acao != null) {
        acao();
        return true;
      }
    }
    return false;
  }

  void _abrir(_Painel p) => setState(() {
        _painel = _painel == p ? _Painel.nenhum : p;
        if (_painel == _Painel.chat) _vistaAte = _ultimaAurora;
      });

  void _fechar() {
    if (_painel != _Painel.nenhum) setState(() => _painel = _Painel.nenhum);
  }

  Future<void> _perguntar(String pergunta) async {
    setState(() {
      _painel = _Painel.chat;
      _vistaAte = _ultimaAurora;
    });
    if (pergunta.trim().isNotEmpty) await AssistenteRepo(_db!).enviar(pergunta);
  }

  Future<void> _novaTarefa() async {
    _fechar();
    await abrirFormTarefa(context);
  }

  Future<void> _novoLancamento() async {
    _fechar();
    final q = await FinancasRepo(_db!).carregar();
    if (!mounted) return;
    await abrirFormLancamento(context, contas: q.contas, contaPrincipalId: q.contaPrincipalId);
  }

  Future<void> _novoLembrete() async {
    _fechar();
    await abrirFormLembrete(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final escopo = AuroraEscopo.de(context);
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final tamanho = MediaQuery.sizeOf(context);
    final modal = _painel == _Painel.mais || _painel == _Painel.captura || _painel == _Painel.habitos;
    final novidade = _ultimaAurora != null && _ultimaAurora != _vistaAte && _painel != _Painel.chat;

    final Widget? painel = switch (_painel) {
      _Painel.nenhum => null,
      _Painel.mais => SizedBox(
          width: 290,
          child: _MenuMais(
            aoCaptura: () => _abrir(_Painel.captura),
            aoTarefa: _novaTarefa,
            aoLancamento: _novoLancamento,
            aoLembrete: _novoLembrete,
            aoHabito: () => _abrir(_Painel.habitos),
          ),
        ),
      _Painel.captura => SizedBox(
          width: 420,
          child: PainelCaptura(aoFechar: _fechar, aoPerguntar: _perguntar),
        ),
      _Painel.habitos => SizedBox(width: 320, child: _PainelHabitos(aoFechar: _fechar)),
      _Painel.chat => SizedBox(
          width: 390,
          height: (tamanho.height - 56).clamp(320.0, 580.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 14, 14),
            child: AssistentePage(
              compacto: true,
              aoFechar: _fechar,
              aoExpandir: () {
                _fechar();
                widget.aoAbrirAssistente();
              },
            ),
          ),
        ),
    };

    final cantos = BorderRadius.circular(20);
    return Stack(fit: StackFit.expand, children: [
      // Clique fora fecha o menu (o chat fica aberto enquanto se usa a tela).
      if (modal) Positioned.fill(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: _fechar)),
      if (painel != null)
        Positioned(
          right: 92,
          bottom: 28,
          child: _Surgir(
            key: ValueKey(_painel),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: escuro ? null : c.surface,
                borderRadius: cantos,
                border: escuro ? null : Border.all(color: c.line),
                boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 40, offset: Offset(0, 8))],
              ),
              child: Material(
                type: MaterialType.transparency,
                child: escuro ? Vidro(tipo: TipoVidro.folha, raio: cantos, child: painel) : painel,
              ),
            ),
          ),
        ),
      Positioned(
        right: 28,
        bottom: 28,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _BotaoDock(
            icone: Icons.search_rounded,
            dica: 'Buscar em tudo (Ctrl+K)',
            aoTocar: () {
              _fechar();
              widget.aoBuscar();
            },
          ),
          const SizedBox(height: 12),
          _BotaoDock(
            icone: Icons.contrast_rounded,
            dica: 'Alternar modo claro e escuro',
            aoTocar: escopo.alternarTema,
          ),
          const SizedBox(height: 12),
          _BotaoDock(
            icone: Icons.chat_bubble_outline_rounded,
            dica: 'Conversar com a Aurora',
            ativo: _painel == _Painel.chat,
            ponto: novidade,
            aoTocar: () => _abrir(_Painel.chat),
          ),
          const SizedBox(height: 12),
          _BotaoMais(
            aberto: modal,
            aoTocar: () => modal ? _fechar() : _abrir(_Painel.mais),
          ),
        ]),
      ),
    ]);
  }
}


/// Painel entrando com fade e subida curta (sem animação com "reduzir movimento").
class _Surgir extends StatelessWidget {
  const _Surgir({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      builder: (_, t, filho) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 8 * (1 - t)), child: filho),
      ),
      child: child,
    );
  }
}

/// Guarda se o mouse está em cima e se o botão está apertado, para animar.
/// O aperto dura pelo menos 110 ms, para o toque rápido (celular) também
/// mostrar a mola. Não intercepta o toque: o InkWell de dentro continua
/// recebendo o clique.
class _Reativo extends StatefulWidget {
  const _Reativo({required this.builder});
  final Widget Function(BuildContext context, bool emCima, bool apertado) builder;

  @override
  State<_Reativo> createState() => _ReativoState();
}

class _ReativoState extends State<_Reativo> {
  bool _emCima = false, _apertado = false;
  DateTime _desde = DateTime(2000);

  void _apertar() {
    _desde = DateTime.now();
    setState(() => _apertado = true);
  }

  Future<void> _soltar() async {
    final falta = const Duration(milliseconds: 110) - DateTime.now().difference(_desde);
    if (falta > Duration.zero) await Future<void>.delayed(falta);
    if (mounted) setState(() => _apertado = false);
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (_) => setState(() => _emCima = true),
        onExit: (_) => setState(() => _emCima = false),
        child: Listener(
          onPointerDown: (_) => _apertar(),
          onPointerUp: (_) => _soltar(),
          onPointerCancel: (_) => _soltar(),
          child: widget.builder(context, _emCima, _apertado),
        ),
      );
}

/// Durações das animações dos atalhos (zero com "reduzir movimento").
bool _semMovimento(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Escala com mola: afunda rápido ao apertar e volta passando um pouco.
Widget _escala(BuildContext context, {required bool emCima, required bool apertado, required double crescer, required Widget child}) {
  final parado = _semMovimento(context);
  return AnimatedScale(
    scale: parado ? 1 : (apertado ? .9 : (emCima ? crescer : 1)),
    duration: parado ? Duration.zero : Duration(milliseconds: apertado ? 90 : 260),
    curve: apertado ? Curves.easeOut : Curves.easeOutBack,
    child: child,
  );
}

class _BotaoDock extends StatelessWidget {
  const _BotaoDock({
    required this.icone,
    required this.dica,
    required this.aoTocar,
    this.ativo = false,
    this.ponto = false,
  });
  final IconData icone;
  final String dica;
  final VoidCallback aoTocar;
  final bool ativo, ponto;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final escuro = Theme.of(context).brightness == Brightness.dark;
    return _Reativo(builder: (context, emCima, apertado) {
      final aceso = ativo || emCima;
      final borda = ativo
          ? c.accent.withValues(alpha: .45)
          : emCima
              ? c.accent.withValues(alpha: .3)
              : (escuro ? Colors.white.withValues(alpha: .09) : c.line);
      final conteudo = Material(
        color: ativo ? c.accentSoft : (emCima ? c.accent.withValues(alpha: .07) : (escuro ? Colors.transparent : c.surface)),
        shape: CircleBorder(side: BorderSide(color: borda)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          splashColor: c.accent.withValues(alpha: .18),
          child: SizedBox(
            width: 44,
            height: 44,
            child: AnimatedSlide(
              // O ícone sobe um tico com o mouse em cima.
              offset: emCima && !apertado && !_semMovimento(context) ? const Offset(0, -.05) : Offset.zero,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: Icon(icone, size: 20, color: ativo ? c.accent : (aceso ? c.text : c.muted)),
            ),
          ),
        ),
      );
      return _escala(context, emCima: emCima, apertado: apertado, crescer: 1.1, child: _corpo(context, conteudo, escuro, emCima));
    });
  }

  Widget _corpo(BuildContext context, Widget conteudo, bool escuro, bool emCima) {
    final c = context.cores;
    return Tooltip(
      message: dica,
      preferBelow: false,
      verticalOffset: 0,
      margin: const EdgeInsets.only(right: 56),
      child: Semantics(
        button: true,
        label: dica,
        child: Stack(clipBehavior: Clip.none, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                const BoxShadow(color: Color(0x59000000), blurRadius: 20, offset: Offset(0, 6)),
                // Halo verde suave com o mouse em cima.
                BoxShadow(color: c.accent.withValues(alpha: emCima ? .22 : 0), blurRadius: 18),
              ],
            ),
            child: escuro
                ? Vidro(tipo: TipoVidro.barra, raio: BorderRadius.circular(22), borda: false, child: conteudo)
                : conteudo,
          ),
          if (ponto)
            Positioned(
              top: 1,
              right: 1,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: c.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: c.bg, width: 2),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

class _BotaoMais extends StatelessWidget {
  const _BotaoMais({required this.aberto, required this.aoTocar});
  final bool aberto;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final semAnimar = _semMovimento(context);
    return _Reativo(
      builder: (context, emCima, apertado) => _escala(
        context,
        emCima: emCima,
        apertado: apertado,
        crescer: 1.08,
        child: Tooltip(
          message: 'Ação rápida',
          preferBelow: false,
          child: Semantics(
            button: true,
            label: 'Ação rápida',
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: c.gradiente,
                boxShadow: [
                  BoxShadow(
                    color: c.gradFim.withValues(alpha: emCima ? .5 : .28),
                    blurRadius: emCima ? 30 : 22,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                type: MaterialType.transparency,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: aoTocar,
                  splashColor: Colors.white.withValues(alpha: .25),
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    // Aberto: o + vira x. Com o mouse em cima, dá um giro curto.
                    child: AnimatedRotation(
                      turns: (aberto ? .125 : 0) + (emCima && !semAnimar ? .25 : 0),
                      duration: semAnimar ? Duration.zero : const Duration(milliseconds: 320),
                      curve: Curves.easeOutBack,
                      child: Icon(Icons.add_rounded, size: 28, color: c.noAccent),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuMais extends StatelessWidget {
  const _MenuMais({
    required this.aoCaptura,
    required this.aoTarefa,
    required this.aoLancamento,
    required this.aoLembrete,
    required this.aoHabito,
  });
  final VoidCallback aoCaptura, aoTarefa, aoLancamento, aoLembrete, aoHabito;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _Opcao(icone: Icons.bolt_rounded, cor: c.accent, titulo: 'Captura rápida', sub: 'escreva, a Aurora organiza', tecla: 'Q', aoTocar: aoCaptura),
        _Opcao(icone: Icons.task_alt_rounded, cor: c.violeta, titulo: 'Nova tarefa', sub: 'criar aqui mesmo', tecla: 'T', aoTocar: aoTarefa),
        _Opcao(icone: Icons.attach_money_rounded, cor: c.teal, titulo: 'Novo lançamento', sub: 'gasto ou receita', tecla: 'L', aoTocar: aoLancamento),
        _Opcao(icone: Icons.notifications_none_rounded, cor: c.warn, titulo: 'Novo lembrete', sub: 'com hora para avisar', tecla: 'R', aoTocar: aoLembrete),
        _Opcao(icone: Icons.repeat_rounded, cor: c.bad, titulo: 'Marcar hábito', sub: 'feito hoje', tecla: 'H', aoTocar: aoHabito),
      ]),
    );
  }
}

class _Opcao extends StatelessWidget {
  const _Opcao({
    required this.icone,
    required this.cor,
    required this.titulo,
    required this.sub,
    required this.tecla,
    required this.aoTocar,
  });
  final IconData icone;
  final Color cor;
  final String titulo, sub, tecla;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return _Reativo(builder: (context, emCima, apertado) {
      final parado = _semMovimento(context);
      final dur = parado ? Duration.zero : const Duration(milliseconds: 200);
      return AnimatedScale(
        // Apertar afunda a linha toda um pouco.
        scale: apertado && !parado ? .97 : 1,
        duration: parado ? Duration.zero : Duration(milliseconds: apertado ? 90 : 240),
        curve: apertado ? Curves.easeOut : Curves.easeOutBack,
        child: AnimatedContainer(
          duration: dur,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: emCima ? cor.withValues(alpha: .07) : Colors.transparent,
            border: Border.all(color: emCima ? cor.withValues(alpha: .22) : Colors.transparent),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: aoTocar,
              borderRadius: BorderRadius.circular(14),
              hoverColor: Colors.transparent,
              splashColor: cor.withValues(alpha: .16),
              highlightColor: cor.withValues(alpha: .08),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(children: [
                  // Ícone cresce e gira de leve; a caixa dele acende na cor da opção.
                  AnimatedScale(
                    scale: emCima && !parado ? 1.12 : 1,
                    duration: parado ? Duration.zero : const Duration(milliseconds: 260),
                    curve: Curves.easeOutBack,
                    child: AnimatedRotation(
                      turns: emCima && !parado ? -.02 : 0,
                      duration: parado ? Duration.zero : const Duration(milliseconds: 260),
                      curve: Curves.easeOutBack,
                      child: AnimatedContainer(
                        duration: dur,
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: cor.withValues(alpha: emCima ? .24 : .14),
                          borderRadius: BorderRadius.circular(11),
                          boxShadow: [BoxShadow(color: cor.withValues(alpha: emCima ? .3 : 0), blurRadius: 14)],
                        ),
                        child: Icon(icone, size: 19, color: cor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    // O texto anda 3 px para a direita.
                    child: AnimatedSlide(
                      offset: emCima && !parado ? const Offset(.02, 0) : Offset.zero,
                      duration: dur,
                      curve: Curves.easeOut,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(titulo, style: manrope(14, peso: FontWeight.w700, cor: c.text)),
                        Text(sub, style: manrope(12, cor: emCima ? c.text.withValues(alpha: .75) : c.muted)),
                      ]),
                    ),
                  ),
                  AnimatedContainer(
                    duration: dur,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: emCima ? cor.withValues(alpha: .14) : Colors.transparent,
                      border: Border.all(color: emCima ? cor.withValues(alpha: .5) : c.line),
                    ),
                    child: Text(tecla, style: manrope(11, peso: FontWeight.w700, cor: emCima ? cor : c.muted)),
                  ),
                ]),
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// "Marcar hábito": os hábitos de hoje, cada um com o seu visto.
class _PainelHabitos extends StatelessWidget {
  const _PainelHabitos({required this.aoFechar});
  final VoidCallback aoFechar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final db = AuroraEscopo.de(context).db;
    final repo = HabitosRepo(db);
    final hoje = hojeSP();
    return Padding(
      padding: const EdgeInsets.all(14),
      child: StreamBuilder<QuadroHabitos>(
        stream: repo.observarQuadro(),
        builder: (context, snap) {
          final q = snap.data;
          final doDia = q?.doDia(hoje) ?? const <Habito>[];
          return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(child: Text('Hábitos de hoje', style: sora(15))),
              IconButton(
                tooltip: 'Fechar',
                onPressed: aoFechar,
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.close_rounded, size: 19, color: c.muted),
              ),
            ]),
            const SizedBox(height: 6),
            if (q != null && doDia.isEmpty) ...[
              Text('Nenhum hábito para hoje.', style: manrope(13, cor: c.muted)),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () async {
                    aoFechar();
                    final metas = await (db.select(db.metas)..where((m) => m.apagadoEm.isNull())).get();
                    if (context.mounted) await abrirFormHabito(context, metas: metas);
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Criar hábito'),
                ),
              ),
            ],
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView(shrinkWrap: true, children: [
                for (final h in doDia)
                  _LinhaHabito(
                    nome: h.nome,
                    horario: h.horario,
                    feito: q!.feito(h.id, hoje),
                    aoTocar: () => repo.alternar(h.id, hoje, !q.feito(h.id, hoje)),
                  ),
              ]),
            ),
          ]);
        },
      ),
    );
  }
}

class _LinhaHabito extends StatelessWidget {
  const _LinhaHabito({required this.nome, required this.horario, required this.feito, required this.aoTocar});
  final String nome;
  final String? horario;
  final bool feito;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Semantics(
      button: true,
      checked: feito,
      label: nome,
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
          child: Row(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: feito ? c.teal : Colors.transparent,
                border: Border.all(color: feito ? c.teal : c.line, width: 2),
              ),
              child: feito ? Icon(Icons.check_rounded, size: 14, color: c.noAccent) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(nome,
                  style: manrope(14, peso: FontWeight.w600, cor: feito ? c.muted : c.text).copyWith(
                    decoration: feito ? TextDecoration.lineThrough : null,
                  )),
            ),
            if (horario != null) Text(horario!, style: manrope(12, cor: c.muted)),
          ]),
        ),
      ),
    );
  }
}
