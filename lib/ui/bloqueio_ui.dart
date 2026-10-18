import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/bloqueio.dart';
import '../core/tema.dart';
import '../data/banco.dart';
import 'ceu_estrelado.dart';
import 'componentes.dart';

/// Cobre o app com a tela de bloqueio ao abrir e ao voltar depois de
/// [ServicoBloqueio.tolerancia] fora dele.
class PortaoBloqueio extends StatefulWidget {
  const PortaoBloqueio({super.key, required this.db, required this.child});
  final BancoAurora db;
  final Widget child;

  @override
  State<PortaoBloqueio> createState() => _PortaoBloqueioState();
}

class _PortaoBloqueioState extends State<PortaoBloqueio> with WidgetsBindingObserver {
  late final _servico = ServicoBloqueio(widget.db);
  ModoBloqueio _modo = ModoBloqueio.nenhum;
  bool _carregado = false;
  bool _travado = false;
  DateTime? _saiuEm;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ServicoBloqueio.mudou.addListener(_recarregar);
    _carregar(travar: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ServicoBloqueio.mudou.removeListener(_recarregar);
    super.dispose();
  }

  Future<void> _carregar({required bool travar}) async {
    final modo = await _servico.modo();
    if (!mounted) return;
    setState(() {
      _modo = modo;
      _carregado = true;
      if (travar) _travado = modo != ModoBloqueio.nenhum;
      if (modo == ModoBloqueio.nenhum) _travado = false;
    });
  }

  // Mudou na tela de Conta: quem mudou acabou de se identificar, não trava.
  void _recarregar() => _carregar(travar: false);

  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    if (_modo == ModoBloqueio.nenhum || _travado || _ServicoPedido.ativo) return;
    if (estado == AppLifecycleState.paused || estado == AppLifecycleState.hidden) {
      _saiuEm ??= DateTime.now();
    } else if (estado == AppLifecycleState.resumed) {
      final saiu = _saiuEm;
      _saiuEm = null;
      if (saiu != null && DateTime.now().difference(saiu) >= ServicoBloqueio.tolerancia) {
        setState(() => _travado = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Até ler a preferência, não mostra os dados (evita um piscar do app aberto).
    if (!_carregado) return ColoredBox(color: context.cores.bg);
    return Stack(children: [
      Offstage(offstage: _travado, child: TickerMode(enabled: !_travado, child: widget.child)),
      if (_travado)
        TelaBloqueio(
          servico: _servico,
          modo: _modo,
          aoDesbloquear: () => setState(() => _travado = false),
        ),
    ]);
  }
}

/// Marca que um pedido de biometria está aberto: o diálogo do sistema tira o
/// app de foco e isso não pode contar como "saiu do app".
class _ServicoPedido {
  static bool ativo = false;
}

Future<bool> _pedirBiometria(ServicoBloqueio servico) async {
  _ServicoPedido.ativo = true;
  try {
    return await servico.autenticar();
  } finally {
    _ServicoPedido.ativo = false;
  }
}

class TelaBloqueio extends StatefulWidget {
  const TelaBloqueio({super.key, required this.servico, required this.modo, required this.aoDesbloquear});
  final ServicoBloqueio servico;
  final ModoBloqueio modo;
  final VoidCallback aoDesbloquear;

  @override
  State<TelaBloqueio> createState() => _TelaBloqueioState();
}

class _TelaBloqueioState extends State<TelaBloqueio> {
  @override
  void initState() {
    super.initState();
    if (widget.modo == ModoBloqueio.biometria) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _biometria());
    }
  }

  Future<void> _biometria() async {
    if (await _pedirBiometria(widget.servico)) widget.aoDesbloquear();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Material(
      color: c.bg,
      child: CeuEstrelado(
        child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LogoAurora(tamanho: 56),
                  const SizedBox(height: 18),
                  Text('Aurora bloqueado', style: sora(22)),
                  const SizedBox(height: 6),
                  Text(
                    widget.modo == ModoBloqueio.pin
                        ? 'Digite o seu PIN para continuar.'
                        : 'Use a biometria do aparelho para continuar.',
                    textAlign: TextAlign.center,
                    style: manrope(14, cor: c.muted),
                  ),
                  const SizedBox(height: 24),
                  if (widget.modo == ModoBloqueio.pin)
                    TecladoPin(
                      aoConferir: (pin) async {
                        final ok = await widget.servico.conferirPin(pin);
                        if (ok) widget.aoDesbloquear();
                        return ok ? null : 'PIN incorreto.';
                      },
                    )
                  else
                    BotaoPilula(texto: 'Desbloquear', aoTocar: _biometria),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}

/// Bolinhas do PIN e teclado numérico (clique, toque ou teclado do PC).
/// [aoConferir] devolve nulo se deu certo, ou a mensagem de erro.
class TecladoPin extends StatefulWidget {
  const TecladoPin({super.key, required this.aoConferir, this.limitarTentativas = true});
  final Future<String?> Function(String pin) aoConferir;
  final bool limitarTentativas;

  @override
  State<TecladoPin> createState() => _TecladoPinState();
}

class _TecladoPinState extends State<TecladoPin> {
  String _pin = '';
  String? _erro;
  int _erradas = 0;
  DateTime? _liberaEm;
  Timer? _relogio;
  final _foco = FocusNode();

  @override
  void dispose() {
    _relogio?.cancel();
    _foco.dispose();
    super.dispose();
  }

  bool get _esperando => _liberaEm != null && DateTime.now().isBefore(_liberaEm!);

  void _digitar(String d) {
    if (_esperando || _pin.length >= 6) return;
    setState(() {
      _pin += d;
      _erro = null;
    });
  }

  void _apagar() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _confirmar() async {
    if (_esperando) return;
    if (!ServicoBloqueio.pinValido(_pin)) {
      setState(() => _erro = 'O PIN tem de 4 a 6 números.');
      return;
    }
    final erro = await widget.aoConferir(_pin);
    if (!mounted || erro == null) return;
    setState(() {
      _pin = '';
      _erro = erro;
      if (widget.limitarTentativas && ++_erradas >= ServicoBloqueio.tentativas) {
        _erradas = 0;
        _liberaEm = DateTime.now().add(ServicoBloqueio.espera);
        _relogio?.cancel();
        _relogio = Timer.periodic(const Duration(seconds: 1), (t) {
          if (!_esperando) t.cancel();
          if (mounted) setState(() {});
        });
      }
    });
  }

  /// Números da fileira de cima e do teclado numérico.
  static final _digitos = {
    LogicalKeyboardKey.digit0: '0', LogicalKeyboardKey.numpad0: '0',
    LogicalKeyboardKey.digit1: '1', LogicalKeyboardKey.numpad1: '1',
    LogicalKeyboardKey.digit2: '2', LogicalKeyboardKey.numpad2: '2',
    LogicalKeyboardKey.digit3: '3', LogicalKeyboardKey.numpad3: '3',
    LogicalKeyboardKey.digit4: '4', LogicalKeyboardKey.numpad4: '4',
    LogicalKeyboardKey.digit5: '5', LogicalKeyboardKey.numpad5: '5',
    LogicalKeyboardKey.digit6: '6', LogicalKeyboardKey.numpad6: '6',
    LogicalKeyboardKey.digit7: '7', LogicalKeyboardKey.numpad7: '7',
    LogicalKeyboardKey.digit8: '8', LogicalKeyboardKey.numpad8: '8',
    LogicalKeyboardKey.digit9: '9', LogicalKeyboardKey.numpad9: '9',
  };

  KeyEventResult _tecla(FocusNode _, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final k = e.logicalKey;
    final digito = _digitos[k] ?? e.character;
    if (digito != null && RegExp(r'^\d$').hasMatch(digito)) {
      _digitar(digito);
    } else if (k == LogicalKeyboardKey.backspace) {
      _apagar();
    } else if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.numpadEnter) {
      _confirmar();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final faltam = _esperando ? _liberaEm!.difference(DateTime.now()).inSeconds + 1 : 0;
    Widget tecla(String rotulo, VoidCallback? aoTocar, {IconData? icone}) => Padding(
          padding: const EdgeInsets.all(6),
          child: Material(
            color: c.surface,
            shape: CircleBorder(side: BorderSide(color: c.line)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: aoTocar,
              child: SizedBox(
                width: 64,
                height: 64,
                child: Center(
                  child: icone != null
                      ? Icon(icone, color: c.text, semanticLabel: rotulo)
                      : Text(rotulo, style: sora(22)),
                ),
              ),
            ),
          ),
        );

    return Focus(
      focusNode: _foco,
      autofocus: true,
      onKeyEvent: _tecla,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 6; i++)
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _pin.length ? c.accent : Colors.transparent,
                    border: Border.all(color: i < _pin.length ? c.accent : (i < 4 ? c.muted : c.line), width: 2),
                  ),
                ),
            ],
          ),
          SizedBox(
            height: 34,
            child: Center(
              child: Text(
                _esperando ? 'Muitas tentativas. Espere $faltam s.' : (_erro ?? ''),
                style: manrope(13, peso: FontWeight.w600, cor: c.bad),
              ),
            ),
          ),
          for (final linha in const [['1', '2', '3'], ['4', '5', '6'], ['7', '8', '9']])
            Row(mainAxisSize: MainAxisSize.min, children: [for (final d in linha) tecla(d, () => _digitar(d))]),
          Row(mainAxisSize: MainAxisSize.min, children: [
            tecla('Apagar', _apagar, icone: Icons.backspace_outlined),
            tecla('0', () => _digitar('0')),
            tecla('Confirmar', _confirmar, icone: Icons.check_rounded),
          ]),
        ],
      ),
    );
  }
}

/// Seção "Bloqueio do app" da tela de Conta: desligado, PIN ou biometria.
class SecaoBloqueio extends StatefulWidget {
  const SecaoBloqueio({super.key, required this.db});
  final BancoAurora db;

  @override
  State<SecaoBloqueio> createState() => _SecaoBloqueioState();
}

class _SecaoBloqueioState extends State<SecaoBloqueio> {
  late final _servico = ServicoBloqueio(widget.db);
  ModoBloqueio? _modo;
  bool _temBiometria = false;
  String? _aviso;

  @override
  void initState() {
    super.initState();
    _ler();
  }

  Future<void> _ler() async {
    final modo = await _servico.modo();
    final bio = await _servico.biometriaDisponivel();
    if (!mounted) return;
    setState(() {
      _modo = modo;
      _temBiometria = bio;
    });
  }

  /// Antes de trocar ou desligar, quem está mexendo confirma que é o dono.
  Future<bool> _confirmarAtual() async {
    return switch (_modo) {
      ModoBloqueio.pin => await _dialogoPin(
            titulo: 'Digite o PIN atual',
            aoConferir: (pin) async => await _servico.conferirPin(pin) ? null : 'PIN incorreto.',
          ) !=
          null,
      ModoBloqueio.biometria => await _pedirBiometria(_servico),
      _ => true,
    };
  }

  Future<void> _escolher(ModoBloqueio novo) async {
    if (novo == _modo) return;
    setState(() => _aviso = null);
    if (novo == ModoBloqueio.biometria && !_temBiometria) {
      setState(() => _aviso = 'Este aparelho não tem biometria nem Windows Hello configurados.');
      return;
    }
    if (!await _confirmarAtual()) return;
    switch (novo) {
      case ModoBloqueio.nenhum:
        await _servico.desligar();
      case ModoBloqueio.pin:
        final pin = await _criarPin();
        if (pin == null) return;
        await _servico.ativarPin(pin);
      case ModoBloqueio.biometria:
        if (!await _pedirBiometria(_servico)) return;
        await _servico.ativarBiometria();
    }
    await _ler();
    if (mounted) {
      setState(() => _aviso = switch (novo) {
            ModoBloqueio.nenhum => 'Bloqueio desligado.',
            ModoBloqueio.pin => 'PIN ativado. O Aurora pede o PIN ao abrir.',
            ModoBloqueio.biometria => 'Biometria ativada. O Aurora pede a biometria ao abrir.',
          });
    }
  }

  /// Pede o PIN novo duas vezes.
  Future<String?> _criarPin() async {
    final primeiro = await _dialogoPin(
      titulo: 'Crie um PIN de 4 a 6 números',
      aoConferir: (pin) async => null,
      limitar: false,
    );
    if (primeiro == null || !mounted) return null;
    return _dialogoPin(
      titulo: 'Digite o PIN de novo',
      aoConferir: (pin) async => pin == primeiro ? null : 'Os PINs não são iguais.',
      limitar: false,
    );
  }

  Future<String?> _dialogoPin({
    required String titulo,
    required Future<String?> Function(String) aoConferir,
    bool limitar = true,
  }) {
    final c = context.cores;
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text(titulo, style: sora(18), textAlign: TextAlign.center),
        content: TecladoPin(
          limitarTentativas: limitar,
          aoConferir: (pin) async {
            final erro = await aoConferir(pin);
            if (erro == null && ctx.mounted) Navigator.pop(ctx, pin);
            return erro;
          },
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final modo = _modo;
    if (modo == null) return const SizedBox.shrink();
    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('BLOQUEIO DO APP', style: rotulo(c.accent)),
          const SizedBox(height: 6),
          Text(
            'Pede o PIN ou a biometria ao abrir o Aurora e ao voltar depois de 1 minuto fora. '
            'Vale só para este aparelho.',
            style: manrope(13, cor: c.muted, altura: 1.5),
          ),
          const SizedBox(height: 14),
          Segmentos<ModoBloqueio>(
            opcoes: ModoBloqueio.values,
            selecionado: modo,
            rotulo: (m) => switch (m) {
              ModoBloqueio.nenhum => 'Desligado',
              ModoBloqueio.pin => 'PIN',
              ModoBloqueio.biometria => 'Biometria',
            },
            aoEscolher: _escolher,
          ),
          if (_aviso != null) ...[
            const SizedBox(height: 10),
            Text(_aviso!, style: manrope(13, peso: FontWeight.w600, cor: c.teal, altura: 1.4)),
          ],
        ],
      ),
    );
  }
}
