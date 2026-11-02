import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Despertador (Android): lembrete marcado com "Me despertar" toca como alarme.
/// Abre em tela cheia (até com o celular bloqueado), usa o som de alarme do
/// aparelho no canal de ALARME (toca mesmo no silencioso), repete o som até
/// alguém parar e tem "Parar" e "Adiar" no próprio aviso. Nos outros sistemas
/// o lembrete vira um aviso comum.

/// Chave do Navigator do app: o despertador abre a tela dele por cima de tudo.
final chaveNavegador = GlobalKey<NavigatorState>();

const _prefixo = 'despertador:';

/// Ids a partir daqui são adiamentos: o reagendamento geral não apaga.
const idAdiadoBase = 900000;

const minutosAdiar = 10;

/// Para de tocar sozinho depois disso (o aviso some; não fica tocando a noite toda).
const _tocaPorMs = 15 * 60 * 1000;

/// FLAG_INSISTENT do Android: o som repete até o aviso ser tocado ou removido.
const _insistente = 4;

String payloadDespertador(String titulo) => '$_prefixo${jsonEncode({'titulo': titulo})}';

/// Título do lembrete se o payload é de despertador; nulo se é outro aviso.
String? tituloDoDespertador(String? payload) {
  if (payload == null || !payload.startsWith(_prefixo)) return null;
  try {
    return (jsonDecode(payload.substring(_prefixo.length)) as Map<String, dynamic>)['titulo'] as String?;
  } on FormatException {
    return 'Lembrete';
  }
}

final detalhesDespertador = NotificationDetails(
  android: AndroidNotificationDetails(
    'despertador',
    'Despertador',
    channelDescription: 'Lembretes marcados com "Me despertar": tela cheia e som de alarme',
    importance: Importance.max,
    priority: Priority.max,
    category: AndroidNotificationCategory.alarm,
    fullScreenIntent: true,
    audioAttributesUsage: AudioAttributesUsage.alarm,
    // O toque de alarme escolhido no aparelho.
    sound: const UriAndroidNotificationSound('content://settings/system/alarm_alert'),
    enableVibration: true,
    vibrationPattern: Int64List.fromList([0, 800, 600, 800]),
    ongoing: true,
    autoCancel: false,
    visibility: NotificationVisibility.public,
    timeoutAfter: _tocaPorMs,
    additionalFlags: Int32List.fromList([_insistente]),
    actions: const [
      // Parar: o plugin tira o aviso (e o som) sem abrir o app.
      AndroidNotificationAction('parar', 'Parar', cancelNotification: true),
      // Adiar: abre o app, que agenda de novo daqui a alguns minutos.
      AndroidNotificationAction('adiar', 'Adiar $minutosAdiar min', cancelNotification: true, showsUserInterface: true),
    ],
  ),
);

/// Avisa o Android (MainActivity): o app só fica por cima do bloqueio enquanto
/// esta tela está aberta. Fora dela, celular travado não mostra nada do Aurora.
const _canalBloqueio = MethodChannel('aurora/despertador');

Future<void> _avisarSistema(String metodo) async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  try {
    await _canalBloqueio.invokeMethod<void>(metodo);
  } catch (e) {
    debugPrint('Despertador: $metodo ($e)');
  }
}

/// Telas abertas agora: dois alarmes podem se empilhar.
var _telasAbertas = 0;

/// Há alarme na tela: o bloqueio do app (PIN) sai da frente até ele fechar, senão
/// ninguém veria os botões. A tela é opaca e sem voltar: o resto do app não aparece.
final alarmeNaTela = ValueNotifier<bool>(false);

/// Tela do despertador: hora grande, o lembrete e Parar / Adiar.
class TelaDespertador extends StatefulWidget {
  const TelaDespertador({super.key, required this.titulo, required this.aoParar, required this.aoAdiar});
  final String titulo;
  final VoidCallback aoParar;
  final VoidCallback aoAdiar;

  @override
  State<TelaDespertador> createState() => _TelaDespertadorState();
}

class _TelaDespertadorState extends State<TelaDespertador> with SingleTickerProviderStateMixin {
  late final _pulso = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);

  var _fechada = false;

  @override
  void initState() {
    super.initState();
    _telasAbertas++;
    unawaited(_avisarSistema('aberta'));
    // Depois do quadro: o aviso reconstrói o bloqueio, acima desta tela.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_fechada) alarmeNaTela.value = true;
    });
  }

  /// Fecha uma vez só: ao tocar num botão (antes de sair da tela, para o bloqueio
  /// voltar no mesmo quadro) ou se a tela sumir de outro jeito.
  void _fechar() {
    if (_fechada) return;
    _fechada = true;
    if (--_telasAbertas == 0) {
      unawaited(_avisarSistema('fechada'));
      scheduleMicrotask(() => alarmeNaTela.value = false);
    }
  }

  @override
  void dispose() {
    _fechar();
    _pulso.dispose();
    super.dispose();
  }

  void _sair(VoidCallback acao) {
    _fechar();
    acao();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final agora = TimeOfDay.now();
    final hora = '${agora.hour.toString().padLeft(2, '0')}:${agora.minute.toString().padLeft(2, '0')}';
    final parado = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return PopScope(
      // Voltar não desliga o alarme sem querer: tem de escolher Parar ou Adiar.
      canPop: false,
      child: Scaffold(
        backgroundColor: tema.colorScheme.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const Spacer(),
                AnimatedBuilder(
                  animation: _pulso,
                  builder: (context, filho) =>
                      Transform.scale(scale: parado ? 1 : 1 + 0.08 * _pulso.value, child: filho),
                  child: Icon(Icons.alarm, size: 72, color: tema.colorScheme.primary),
                ),
                const SizedBox(height: 18),
                Text(hora, style: tema.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Text(
                  widget.titulo,
                  textAlign: TextAlign.center,
                  style: tema.textTheme.headlineSmall,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: () => _sair(widget.aoParar),
                    child: const Text('Parar', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => _sair(widget.aoAdiar),
                    child: const Text('Adiar $minutosAdiar min', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
