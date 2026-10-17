import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

import '../data/banco.dart';

/// Como o app se protege ao abrir (e ao voltar depois de um tempo fora).
enum ModoBloqueio { nenhum, pin, biometria }

/// Bloqueio do app com PIN próprio ou com a biometria do aparelho (digital,
/// rosto ou Windows Hello; na falta dela o aparelho oferece o próprio PIN).
/// Tudo fica só neste aparelho: as preferências não vão para a nuvem e o PIN
/// é guardado como hash com sal, nunca como foi digitado.
class ServicoBloqueio {
  ServicoBloqueio(this.db, {LocalAuthentication? auth}) : _auth = auth ?? LocalAuthentication();

  final BancoAurora db;
  final LocalAuthentication _auth;

  static const _chaveModo = 'bloqueio_modo';
  static const _chavePin = 'bloqueio_pin';
  static const _chaveSal = 'bloqueio_sal';

  /// Avisa o portão do bloqueio quando o modo muda na tela de Conta.
  static final mudou = ValueNotifier<int>(0);

  /// Tempo fora do app que pede o desbloqueio de novo.
  static const tolerancia = Duration(minutes: 1);

  /// Tentativas erradas seguidas antes de esperar [espera].
  static const tentativas = 5;
  static const espera = Duration(seconds: 30);

  Future<ModoBloqueio> modo() async {
    final valor = await db.preferencia(_chaveModo);
    return ModoBloqueio.values.where((m) => m.name == valor).firstOrNull ?? ModoBloqueio.nenhum;
  }

  /// PIN de 4 a 6 dígitos.
  static bool pinValido(String pin) => RegExp(r'^\d{4,6}$').hasMatch(pin);

  Future<void> ativarPin(String pin) async {
    if (!pinValido(pin)) throw ArgumentError('O PIN precisa ter de 4 a 6 números.');
    final sal = base64Encode(List<int>.generate(16, (_) => Random.secure().nextInt(256)));
    await db.salvarPreferencia(_chaveSal, sal);
    await db.salvarPreferencia(_chavePin, _resumo(sal, pin));
    await db.salvarPreferencia(_chaveModo, ModoBloqueio.pin.name);
    mudou.value++;
  }

  Future<void> ativarBiometria() async {
    await db.salvarPreferencia(_chaveModo, ModoBloqueio.biometria.name);
    await db.salvarPreferencia(_chavePin, '');
    mudou.value++;
  }

  Future<void> desligar() async {
    await db.salvarPreferencia(_chaveModo, ModoBloqueio.nenhum.name);
    await db.salvarPreferencia(_chavePin, '');
    mudou.value++;
  }

  Future<bool> conferirPin(String pin) async {
    final sal = await db.preferencia(_chaveSal);
    final guardado = await db.preferencia(_chavePin);
    if (sal == null || guardado == null || guardado.isEmpty) return false;
    return _resumo(sal, pin) == guardado;
  }

  /// O aparelho tem biometria (ou PIN/senha do sistema) para o app usar?
  Future<bool> biometriaDisponivel() async {
    if (kIsWeb) return false;
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Pede a biometria do aparelho. Falso se a pessoa cancelou ou falhou.
  Future<bool> autenticar() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Desbloquear o Aurora',
        persistAcrossBackgrounding: true,
      );
    } catch (e) {
      debugPrint('Bloqueio: biometria falhou ($e)');
      return false;
    }
  }

  static String _resumo(String sal, String pin) =>
      sha256.convert(utf8.encode('aurora:$sal:$pin')).toString();
}
