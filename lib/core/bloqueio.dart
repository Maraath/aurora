import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart' show sha256;
import 'package:cryptography/cryptography.dart' as cripto;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../data/banco.dart';

/// Android: com bloqueio ligado, a tela não aparece na lista de apps recentes nem
/// em capturas (MainActivity).
Future<void> protegerTela(bool ligar) async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  try {
    await const MethodChannel('aurora/privacidade').invokeMethod<void>('protegerTela', ligar);
  } catch (e) {
    debugPrint('Bloqueio: proteger a tela ($e)');
  }
}

/// Como o app se protege ao abrir (e ao voltar depois de um tempo fora).
enum ModoBloqueio { nenhum, pin, biometria }

/// Bloqueio do app com PIN próprio ou com a biometria do aparelho (digital,
/// rosto ou Windows Hello; na falta dela o aparelho oferece o próprio PIN).
/// Tudo fica só neste aparelho: as preferências não vão para a nuvem e o PIN
/// é guardado como hash lento com sal (PBKDF2), nunca como foi digitado. Isto
/// esconde a tela: quem copiar o arquivo do banco lê os dados sem passar por aqui.
class ServicoBloqueio {
  ServicoBloqueio(this.db, {LocalAuthentication? auth}) : _auth = auth ?? LocalAuthentication();

  final BancoAurora db;
  final LocalAuthentication _auth;

  static const _chaveModo = 'bloqueio_modo';
  static const _chavePin = 'bloqueio_pin';
  static const _chaveSal = 'bloqueio_sal';
  static const _chaveErros = 'bloqueio_erros';
  static const _chaveLibera = 'bloqueio_libera_em';

  /// Avisa o portão do bloqueio quando o modo muda na tela de Conta.
  static final mudou = ValueNotifier<int>(0);

  /// Tempo fora do app que pede o desbloqueio de novo.
  static const tolerancia = Duration(minutes: 1);

  /// Sem tocar em nada por este tempo, o computador trava.
  static const inatividade = Duration(minutes: 10);

  /// Tentativas erradas seguidas antes de esperar [espera]; cada erro depois
  /// disso dobra a espera, até [esperaMaxima].
  static const tentativas = 5;
  static const espera = Duration(seconds: 30);
  static const esperaMaxima = Duration(hours: 1);

  /// Voltas do PBKDF2 (menos nos testes).
  @visibleForTesting
  static int iteracoes = 100000;

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
    await db.salvarPreferencia(_chavePin, await _resumo(sal, pin, iteracoes));
    await db.salvarPreferencia(_chaveModo, ModoBloqueio.pin.name);
    await zerarErros();
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
    final partes = guardado.split(':');
    if (partes.length == 3 && partes.first == 'v2') {
      return await _resumo(sal, pin, int.parse(partes[1])) == guardado;
    }
    // PIN de antes do PBKDF2: confere e já troca pelo formato novo.
    final antigo = sha256.convert(utf8.encode('aurora:$sal:$pin')).toString();
    if (antigo != guardado) return false;
    await db.salvarPreferencia(_chavePin, await _resumo(sal, pin, iteracoes));
    return true;
  }

  /// Quanto falta para poder tentar de novo (zero = pode). Fica no banco: fechar
  /// e abrir o app não dá tentativas novas.
  Future<Duration> esperaRestante() async {
    final libera = DateTime.tryParse(await db.preferencia(_chaveLibera) ?? '');
    final falta = libera?.difference(DateTime.now()) ?? Duration.zero;
    return falta.isNegative ? Duration.zero : falta;
  }

  /// Conta um erro e devolve quanto esperar (zero enquanto há tentativas).
  Future<Duration> registrarErro() async {
    final erros = (int.tryParse(await db.preferencia(_chaveErros) ?? '') ?? 0) + 1;
    await db.salvarPreferencia(_chaveErros, '$erros');
    if (erros < tentativas) return Duration.zero;
    final segundos = espera.inSeconds * pow(2, min(erros - tentativas, 12));
    final tempo = Duration(seconds: min(segundos.toInt(), esperaMaxima.inSeconds));
    await db.salvarPreferencia(_chaveLibera, DateTime.now().add(tempo).toIso8601String());
    return tempo;
  }

  Future<void> zerarErros() async {
    await db.salvarPreferencia(_chaveErros, '0');
    await db.salvarPreferencia(_chaveLibera, '');
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

  static Future<String> _resumo(String sal, String pin, int voltas) async {
    final chave = await cripto.Pbkdf2(macAlgorithm: cripto.Hmac.sha256(), iterations: voltas, bits: 256)
        .deriveKey(secretKey: cripto.SecretKey(utf8.encode(pin)), nonce: base64Decode(sal));
    return 'v2:$voltas:${base64Encode(await chave.extractBytes())}';
  }
}
