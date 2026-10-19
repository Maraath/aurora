import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthState;

import '../../app.dart';
import '../../core/nuvem.dart';
import '../../core/tema.dart';
import '../../data/assistente_repo.dart';
import '../../data/banco.dart';
import '../vidro.dart';

/// Chat com o assistente, organizado assim:
/// conversa rolando no meio, campo de mensagem fixo embaixo, mensagens novas
/// entrando com fade e subida de 10 px (0,3 s), a resposta da IA aparecendo aos
/// poucos e um indicador "pensando" com orbe pulsando e texto que alterna.
/// Cores e fontes do Aurora.
class AssistentePage extends StatefulWidget {
  const AssistentePage({super.key, this.compacto = false, this.aoExpandir, this.aoFechar});

  /// Mini chat (janela flutuante do canto): cabeçalho pequeno com expandir e
  /// fechar, e letras um pouco menores. A conversa é a mesma da área Assistente.
  final bool compacto;
  final VoidCallback? aoExpandir;
  final VoidCallback? aoFechar;

  @override
  State<AssistentePage> createState() => _AssistentePageState();
}

class _AssistentePageState extends State<AssistentePage> {
  AssistenteRepo? _repo;
  Stream<List<MensagemAssistente>>? _conversa;
  final _texto = TextEditingController();
  final _foco = FocusNode();
  final _rolagem = ScrollController();
  String _nome = '';
  StreamSubscription<AuthState>? _login;

  /// Mensagens que já estavam na tela ao abrir: estas não animam.
  Set<String>? _jaVistas;
  int _ultimoTotal = -1;

  bool get _conectada => nuvem?.auth.currentSession != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = AuroraEscopo.de(context).db;
    if (_repo?.db != db) {
      _repo = AssistenteRepo(db);
      _conversa = _repo!.observarConversa();
      db.preferencia('nome').then((n) {
        if (mounted) setState(() => _nome = n ?? '');
      });
      // Pedidos que esperavam na fila seguem para a IA ao abrir a tela e ao entrar na conta.
      _repo!.processarFila();
      _login?.cancel();
      _login = nuvem?.auth.onAuthStateChange.listen((_) {
        if (!mounted) return;
        setState(() {});
        _repo!.processarFila();
      });
    }
    AssistenteRepo.pensando.addListener(_irAoFim);
  }

  @override
  void dispose() {
    AssistenteRepo.pensando.removeListener(_irAoFim);
    _login?.cancel();
    _texto.dispose();
    _foco.dispose();
    _rolagem.dispose();
    super.dispose();
  }

  Future<void> _enviar([String? texto]) async {
    final t = (texto ?? _texto.text).trim();
    if (t.isEmpty) return;
    _texto.clear();
    setState(() {});
    await _repo!.enviar(t);
    _foco.requestFocus();
  }

  /// Desce até a última mensagem (suave) quando a conversa cresce.
  void _irAoFim() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_rolagem.hasClients) return;
      _rolagem.animateTo(
        _rolagem.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _limpar() async {
    final c = context.cores;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text('Limpar a conversa?', style: sora(18)),
        content: Text('O que o assistente criou (gastos, lembretes, tarefas) continua no app.',
            style: manrope(14, cor: c.text, altura: 1.4)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Limpar')),
        ],
      ),
    );
    if (ok == true) await _repo!.limparConversa();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MensagemAssistente>>(
      stream: _conversa,
      builder: (context, snap) {
        final conversa = snap.data ?? const <MensagemAssistente>[];
        if (snap.hasData) _jaVistas ??= {for (final m in conversa) m.id};
        if (conversa.length != _ultimoTotal) {
          _ultimoTotal = conversa.length;
          _irAoFim();
        }
        final fila = conversa.where((m) => m.naFila).length;
        final corpo = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.compacto)
              _CabecalhoMini(
                conectada: _conectada,
                fila: fila,
                aoLimpar: conversa.isEmpty ? null : _limpar,
                aoExpandir: widget.aoExpandir,
                aoFechar: widget.aoFechar,
              )
            else
              _Cabecalho(
                conectada: _conectada,
                fila: fila,
                aoLimpar: conversa.isEmpty ? null : _limpar,
              ),
            SizedBox(height: widget.compacto ? Espaco.sm : Espaco.md),
            Expanded(
              child: conversa.isEmpty
                  ? _Boasvindas(nome: _nome, conectada: _conectada, aoEscolher: _enviar, compacto: widget.compacto)
                  : ListView.builder(
                      controller: _rolagem,
                      padding: const EdgeInsets.only(top: Espaco.sm, bottom: Espaco.lg),
                      itemCount: conversa.length + 1,
                      itemBuilder: (context, i) {
                        if (i == conversa.length) {
                          return ValueListenableBuilder<bool>(
                            valueListenable: AssistenteRepo.pensando,
                            builder: (context, pensando, _) => AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: pensando ? const _Pensando() : const SizedBox.shrink(),
                            ),
                          );
                        }
                        final m = conversa[i];
                        final nova = !(_jaVistas?.contains(m.id) ?? true);
                        final anterior = i > 0 ? conversa[i - 1].papel : null;
                        return _Entrada(
                          key: ValueKey(m.id),
                          animar: nova,
                          child: Padding(
                            // Mais espaço quando muda quem fala.
                            padding: EdgeInsets.only(top: anterior != null && anterior != m.papel ? Espaco.lg : Espaco.sm),
                            child: _Mensagem(
                              mensagem: m,
                              digitar: nova && m.papel == PapelMensagem.aurora,
                              aoEscrever: _irAoFim,
                              aoDesfazer: m.itemId != null && !m.desfeita ? () => _repo!.desfazer(m) : null,
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (conversa.isNotEmpty) ...[
              _Sugestoes(aoEscolher: _enviar),
              const SizedBox(height: Espaco.sm + 4),
            ],
            _Compositor(
              controle: _texto,
              foco: _foco,
              aoEnviar: _enviar,
              aoMudar: () => setState(() {}),
              autofocus: widget.compacto,
            ),
          ],
        );
        if (!widget.compacto) return corpo;
        // Na janela pequena, letras 8% menores (as medidas seguem as da área).
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(.92)),
          child: corpo,
        );
      },
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.conectada, required this.fila, this.aoLimpar});
  final bool conectada;
  final int fila;
  final VoidCallback? aoLimpar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final cor = conectada ? c.teal : c.warn;
    return Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Assistente', style: sora(26)),
          const SizedBox(height: Espaco.xs),
          Row(children: [
            Container(width: 7, height: 7, decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(
              (conectada ? 'IA conectada' : 'Comandos rápidos, sem IA') + (fila == 0 ? '' : ' · $fila na fila'),
              style: manrope(13, peso: FontWeight.w500, cor: c.muted),
            ),
          ]),
        ]),
      ),
      if (aoLimpar != null)
        IconButton(
          tooltip: 'Limpar conversa',
          onPressed: aoLimpar,
          icon: Icon(Icons.delete_sweep_outlined, color: c.muted),
        ),
    ]);
  }
}

/// Cabeçalho do mini chat: orbe, nome, estado e os botões de limpar, abrir em
/// tela cheia e fechar.
class _CabecalhoMini extends StatelessWidget {
  const _CabecalhoMini({
    required this.conectada,
    required this.fila,
    this.aoLimpar,
    this.aoExpandir,
    this.aoFechar,
  });
  final bool conectada;
  final int fila;
  final VoidCallback? aoLimpar, aoExpandir, aoFechar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    Widget botao(IconData icone, String dica, VoidCallback? acao) => IconButton(
          tooltip: dica,
          onPressed: acao,
          visualDensity: VisualDensity.compact,
          icon: Icon(icone, size: 19, color: c.muted),
        );
    return Row(children: [
      ValueListenableBuilder<bool>(
        valueListenable: AssistenteRepo.pensando,
        builder: (_, pensando, _) => _Orbe(tamanho: 30, pulsando: pensando),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Aurora', style: sora(15)),
          Text(
            (conectada ? 'IA conectada' : 'Comandos rápidos, sem IA') + (fila == 0 ? '' : ' · $fila na fila'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: manrope(11, peso: FontWeight.w500, cor: conectada ? c.teal : c.warn),
          ),
        ]),
      ),
      if (aoLimpar != null) botao(Icons.delete_sweep_outlined, 'Limpar conversa', aoLimpar),
      if (aoExpandir != null) botao(Icons.open_in_full_rounded, 'Abrir o Assistente em tela cheia', aoExpandir),
      if (aoFechar != null) botao(Icons.close_rounded, 'Fechar', aoFechar),
    ]);
  }
}

/// Conversa vazia: saudação no centro e sugestões para começar.
class _Boasvindas extends StatelessWidget {
  const _Boasvindas({required this.nome, required this.conectada, required this.aoEscolher, this.compacto = false});
  final String nome;
  final bool conectada;
  final ValueChanged<String> aoEscolher;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _Orbe(tamanho: compacto ? 40 : 56, pulsando: true),
            SizedBox(height: compacto ? Espaco.md : Espaco.lg),
            Text(nome.isEmpty ? 'Como posso ajudar?' : 'Oi, $nome. Como posso ajudar?',
                textAlign: TextAlign.center, style: sora(compacto ? 18 : 22)),
            const SizedBox(height: Espaco.sm),
            Text(
              conectada
                  ? 'Anoto gastos, crio lembretes e tarefas, marco hábitos, registro medidas e resumo seu dia. '
                      'Pergunte o que quiser sobre sua rotina.'
                  : 'Gastos, lembretes, tarefas, hábitos, medidas e resumos funcionam agora, mesmo sem internet. '
                      'Para perguntas livres, entre na conta em Mais › Conta.',
              textAlign: TextAlign.center,
              style: manrope(14, cor: c.muted, altura: 1.6),
            ),
            const SizedBox(height: Espaco.lg),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: Espaco.sm,
              runSpacing: Espaco.sm,
              children: [
                for (final s in compacto ? sugestoesAssistente.take(4) : sugestoesAssistente)
                  _Chip(texto: s, aoTocar: () => aoEscolher(s)),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}

class _Sugestoes extends StatelessWidget {
  const _Sugestoes({required this.aoEscolher});
  final ValueChanged<String> aoEscolher;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: sugestoesAssistente.length,
          separatorBuilder: (_, _) => const SizedBox(width: Espaco.sm),
          itemBuilder: (_, i) => _Chip(texto: sugestoesAssistente[i], aoTocar: () => aoEscolher(sugestoesAssistente[i])),
        ),
      );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.texto, required this.aoTocar});
  final String texto;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Material(
      color: c.surface,
      shape: StadiumBorder(side: BorderSide(color: c.line)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: aoTocar,
        hoverColor: c.surface2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(texto, style: manrope(13, peso: FontWeight.w600, cor: c.text)),
        ),
      ),
    );
  }
}

/// Mensagem nova entra com fade e subida de 10 px em 0,3 s.
class _Entrada extends StatelessWidget {
  const _Entrada({super.key, required this.animar, required this.child});
  final bool animar;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!animar || (MediaQuery.maybeDisableAnimationsOf(context) ?? false)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, t, filho) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 10 * (1 - t)), child: filho),
      ),
      child: child,
    );
  }
}

class _Mensagem extends StatelessWidget {
  const _Mensagem({required this.mensagem, required this.digitar, required this.aoEscrever, this.aoDesfazer});
  final MensagemAssistente mensagem;
  final bool digitar;
  final VoidCallback aoEscrever;
  final VoidCallback? aoDesfazer;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final m = mensagem;
    final escuro = Theme.of(context).brightness == Brightness.dark;

    switch (m.papel) {
      case PapelMensagem.sistema:
        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: c.warn.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(m.texto, textAlign: TextAlign.center, style: manrope(12, cor: c.warn, altura: 1.45)),
          ),
        );

      case PapelMensagem.eu:
        // Balão do usuário: à direita, neutro, canto de baixo à direita mais fechado.
        return Align(
          alignment: Alignment.centerRight,
          child: FractionallySizedBox(
            widthFactor: .78,
            alignment: Alignment.centerRight,
            child: Align(
              alignment: Alignment.centerRight,
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: escuro ? Colors.white.withValues(alpha: .07) : c.text.withValues(alpha: .05),
                    border: Border.all(color: escuro ? Colors.white.withValues(alpha: .05) : c.text.withValues(alpha: .06)),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(6),
                    ),
                  ),
                  child: Text(m.texto, style: manrope(15, cor: c.text, altura: 1.55)),
                ),
                // Na fila: só avisa quando a IA não está trabalhando nele agora.
                if (m.naFila)
                  ValueListenableBuilder<bool>(
                    valueListenable: AssistenteRepo.pensando,
                    builder: (_, pensando, _) => pensando
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(top: 6, right: 4),
                            child: Text('Na fila da IA: vai quando houver internet',
                                style: manrope(11, peso: FontWeight.w600, cor: c.warn)),
                          ),
                  ),
              ]),
            ),
          ),
        );

      case PapelMensagem.aurora:
        // Resposta: orbe da Aurora e o texto solto, sem balão pesado.
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(padding: EdgeInsets.only(top: 2), child: _Orbe(tamanho: 28)),
          const SizedBox(width: Espaco.md - 4),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _TextoDigitado(
                texto: m.texto,
                animar: digitar,
                aoCrescer: aoEscrever,
                estilo: manrope(15, cor: m.desfeita ? c.muted : c.text, altura: 1.65)
                    .copyWith(decoration: m.desfeita ? TextDecoration.lineThrough : null),
              ),
              if (aoDesfazer != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: InkWell(
                    onTap: aoDesfazer,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.undo_rounded, size: 15, color: c.muted),
                        const SizedBox(width: 4),
                        Text('Desfazer', style: manrope(12, peso: FontWeight.w600, cor: c.muted)),
                      ]),
                    ),
                  ),
                ),
            ]),
          ),
        ]);
    }
  }
}

/// Trechos entre `**` em negrito (o único markdown que a Aurora usa). Durante a
/// digitação, um `**` ainda sem par já deixa o resto em negrito até fechar.
List<TextSpan> comNegrito(String texto) {
  final partes = texto.split('**');
  return [
    for (var i = 0; i < partes.length; i++)
      if (partes[i].isNotEmpty)
        TextSpan(text: partes[i], style: i.isOdd ? const TextStyle(fontWeight: FontWeight.w800) : null),
  ];
}

/// Texto da resposta escrito aos poucos (2 letras a cada 15 ms), com
/// cursor piscando enquanto escreve.
class _TextoDigitado extends StatefulWidget {
  const _TextoDigitado({required this.texto, required this.animar, required this.estilo, required this.aoCrescer});
  final String texto;
  final bool animar;
  final TextStyle estilo;
  final VoidCallback aoCrescer;

  @override
  State<_TextoDigitado> createState() => _TextoDigitadoState();
}

class _TextoDigitadoState extends State<_TextoDigitado> {
  late int _mostrado = widget.animar ? 0 : widget.texto.length;
  Timer? _relogio;

  @override
  void initState() {
    super.initState();
    _escrever();
  }

  /// A resposta chega aos poucos (stream): quando o texto cresce, a digitação
  /// continua de onde parou.
  @override
  void didUpdateWidget(_TextoDigitado antigo) {
    super.didUpdateWidget(antigo);
    if (_mostrado > widget.texto.length) _mostrado = widget.texto.length;
    if (widget.animar && _relogio?.isActive != true) _escrever();
    if (!widget.animar) _mostrado = widget.texto.length;
  }

  void _escrever() {
    if (_mostrado >= widget.texto.length) return;
    _relogio?.cancel();
    _relogio = Timer.periodic(const Duration(milliseconds: 15), (t) {
      if (!mounted) return t.cancel();
      // Atrasada demais em relação ao que já chegou? Escreve mais rápido.
      final falta = widget.texto.length - _mostrado;
      setState(() => _mostrado = math.min(_mostrado + (falta > 200 ? 8 : 2), widget.texto.length));
      if (_mostrado % 40 < 8) widget.aoCrescer();
      if (_mostrado >= widget.texto.length) {
        t.cancel();
        widget.aoCrescer();
      }
    });
  }

  @override
  void dispose() {
    _relogio?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final escrevendo = _mostrado < widget.texto.length;
    return Text.rich(TextSpan(children: [
      ...comNegrito(widget.texto.substring(0, _mostrado)),
      if (escrevendo) WidgetSpan(alignment: PlaceholderAlignment.middle, child: _Cursor(cor: context.cores.accent)),
    ]), style: widget.estilo);
  }
}

class _Cursor extends StatefulWidget {
  const _Cursor({required this.cor});
  final Color cor;

  @override
  State<_Cursor> createState() => _CursorState();
}

class _CursorState extends State<_Cursor> with SingleTickerProviderStateMixin {
  late final _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _anim,
        child: Container(width: 2, height: 16, margin: const EdgeInsets.only(left: 2), color: widget.cor),
      );
}

/// Orbe da Aurora: círculo com o degradê da marca e o logo; pulsando, ganha
/// dois halos que respiram (1,5 s e 2 s).
class _Orbe extends StatefulWidget {
  const _Orbe({required this.tamanho, this.pulsando = false});
  final double tamanho;
  final bool pulsando;

  @override
  State<_Orbe> createState() => _OrbeState();
}

class _OrbeState extends State<_Orbe> with SingleTickerProviderStateMixin {
  late final _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 6000));

  @override
  void initState() {
    super.initState();
    if (widget.pulsando) _anim.repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final t = widget.tamanho;
    final nucleo = Container(
      width: t,
      height: t,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c.gradIni, c.gradFim]),
      ),
      padding: EdgeInsets.all(t * .18),
      child: ClipOval(child: Image.asset('assets/icone/aurora.png', fit: BoxFit.cover)),
    );
    if (!widget.pulsando || (MediaQuery.maybeDisableAnimationsOf(context) ?? false)) return nucleo;
    return SizedBox(
      width: t * 1.6,
      height: t * 1.6,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          // Duas ondas com períodos diferentes (2 s e 1,5 s) dentro de um ciclo de 6 s.
          double onda(double periodo) => (math.sin(_anim.value * 6 / periodo * 2 * math.pi) + 1) / 2;
          final a = onda(2), b = onda(1.5);
          return Stack(alignment: Alignment.center, children: [
            Container(
              width: t * (1 + .15 * a) * 1.35,
              height: t * (1 + .15 * a) * 1.35,
              decoration: BoxDecoration(shape: BoxShape.circle, color: c.gradFim.withValues(alpha: .10 + .10 * a)),
            ),
            Container(
              width: t * (1 + .10 * b) * 1.12,
              height: t * (1 + .10 * b) * 1.12,
              decoration: BoxDecoration(shape: BoxShape.circle, color: c.gradIni.withValues(alpha: .15 + .15 * b)),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: c.gradIni.withValues(alpha: .3 + .2 * a), blurRadius: 12 + 8 * a)],
              ),
              child: nucleo,
            ),
          ]);
        },
      ),
    );
  }
}

/// "Pensando...": orbe pulsando, texto que alterna a cada 3,5 s e três pontos
/// que sobem e descem em sequência.
class _Pensando extends StatefulWidget {
  const _Pensando();

  @override
  State<_Pensando> createState() => _PensandoState();
}

class _PensandoState extends State<_Pensando> with SingleTickerProviderStateMixin {
  static const _frases = ['Pensando...', 'Refletindo...', 'Elaborando...'];
  int _frase = 0;
  Timer? _troca;
  late final _pontos = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();

  @override
  void initState() {
    super.initState();
    _troca = Timer.periodic(const Duration(milliseconds: 3500), (_) {
      if (mounted) setState(() => _frase = (_frase + 1) % _frases.length);
    });
  }

  @override
  void dispose() {
    _troca?.cancel();
    _pontos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Padding(
      padding: const EdgeInsets.only(top: Espaco.lg),
      child: Row(children: [
        const _Orbe(tamanho: 28, pulsando: true),
        const SizedBox(width: Espaco.sm),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(_frases[_frase], key: ValueKey(_frase), style: manrope(14, peso: FontWeight.w500, cor: c.muted)),
        ),
        const SizedBox(width: 8),
        AnimatedBuilder(
          animation: _pontos,
          builder: (context, _) => Row(children: [
            for (var i = 0; i < 3; i++) _ponto(c, (_pontos.value - i * .16 / 1.1) % 1),
          ]),
        ),
      ]),
    );
  }

  /// Um ponto: opacidade .25 → .9 e sobe 2 px no meio do ciclo (como o c3-dot).
  Widget _ponto(AuroraCores c, double fase) {
    final meio = math.sin(fase * math.pi); // 0 → 1 → 0
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      transform: Matrix4.translationValues(0, -2 * meio, 0),
      width: 6,
      height: 6,
      decoration: BoxDecoration(shape: BoxShape.circle, color: c.muted.withValues(alpha: .25 + .65 * meio)),
    );
  }
}

/// Campo de mensagem fixo embaixo: limpo, cresce até 5 linhas; Enter envia e
/// Shift+Enter quebra a linha; o botão de enviar acende quando há texto.
class _Compositor extends StatelessWidget {
  const _Compositor({
    required this.controle,
    required this.foco,
    required this.aoEnviar,
    required this.aoMudar,
    this.autofocus = false,
  });
  final TextEditingController controle;
  final FocusNode foco;
  final Future<void> Function([String?]) aoEnviar;
  final VoidCallback aoMudar;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final temTexto = controle.text.trim().isNotEmpty;
    return ContornoAtivo(
      foco: foco,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 6, 6, 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: CallbackShortcuts(
                bindings: {
                  const SingleActivator(LogicalKeyboardKey.enter): () => aoEnviar(),
                  const SingleActivator(LogicalKeyboardKey.numpadEnter): () => aoEnviar(),
                },
                child: TextField(
                  controller: controle,
                  focusNode: foco,
                  autofocus: autofocus,
                  minLines: 1,
                  maxLines: 5,
                  onChanged: (_) => aoMudar(),
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.multiline,
                  style: manrope(15, cor: c.text, altura: 1.5),
                  cursorColor: c.accent,
                  decoration: InputDecoration(
                    hintText: 'Peça algo ao Aurora…',
                    hintStyle: manrope(15, cor: c.muted),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: Espaco.sm),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: temTexto ? c.gradiente : null,
              color: temTexto ? null : c.surface2,
            ),
            child: Material(
              type: MaterialType.transparency,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: temTexto ? () => aoEnviar() : null,
                child: Tooltip(
                  message: 'Enviar',
                  child: Icon(Icons.arrow_upward_rounded, size: 20, color: temTexto ? c.noAccent : c.muted),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

/// Caixa do compositor: borda fina que acende (com halo) quando o campo tem foco.
class ContornoAtivo extends StatefulWidget {
  const ContornoAtivo({super.key, required this.foco, required this.child});
  final FocusNode foco;
  final Widget child;

  @override
  State<ContornoAtivo> createState() => _ContornoAtivoState();
}

class _ContornoAtivoState extends State<ContornoAtivo> {
  @override
  void initState() {
    super.initState();
    widget.foco.addListener(_mudou);
  }

  @override
  void dispose() {
    widget.foco.removeListener(_mudou);
    super.dispose();
  }

  void _mudou() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final ativo = widget.foco.hasFocus;
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final cantos = BorderRadius.circular(24);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        // No escuro o campo é vidro (abaixo); a borda e o brilho do foco ficam aqui.
        color: escuro ? null : c.surface,
        borderRadius: cantos,
        border: Border.all(
            color: ativo ? c.accent.withValues(alpha: .7) : (escuro ? Colors.white.withValues(alpha: .1) : c.line)),
        boxShadow: [
          if (!escuro) ...sombraCartao(context),
          if (ativo) BoxShadow(color: c.accent.withValues(alpha: .14), spreadRadius: 3),
        ],
      ),
      child: escuro ? Vidro(raio: cantos, borda: false, child: widget.child) : widget.child,
    );
  }
}
