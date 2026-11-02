import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Onde guardar segredos deste aparelho (sistema no app, memória nos testes).
abstract class CofreTexto {
  Future<String?> ler(String chave);
  Future<void> gravar(String chave, String valor);
  Future<void> apagar(String chave);
}

/// Cofre do sistema: DPAPI no Windows, Keystore no Android, Keychain no iOS. Na web
/// não existe equivalente, por isso nada aqui é usado no navegador.
class CofreSistema implements CofreTexto {
  // resetOnError falso: com o padrão, um erro passageiro de leitura apagaria tudo,
  // inclusive a chave do banco, e o banco não abriria mais.
  static const _cofre = FlutterSecureStorage(aOptions: AndroidOptions(resetOnError: false));

  @override
  Future<String?> ler(String chave) => _cofre.read(key: chave);

  @override
  Future<void> gravar(String chave, String valor) => _cofre.write(key: chave, value: valor);

  @override
  Future<void> apagar(String chave) => _cofre.delete(key: chave);
}

/// Onde o Supabase guarda a sessão por padrão, nas preferências.
String chaveSessaoAntiga(String url) => 'sb-${Uri.parse(url).host.split('.').first}-auth-token';

/// Sessão da conta no cofre do sistema. Quem já estava conectado continua: a sessão
/// antiga (preferências, em texto aberto) passa para o cofre na primeira abertura.
/// Sem cofre funcionando, segue nas preferências: desconectar seria pior.
class SessaoSegura extends LocalStorage {
  SessaoSegura(this.cofre, this.antiga);
  final CofreTexto cofre;
  final LocalStorage antiga;

  static const _chave = 'aurora_sessao';

  String? _sessao;
  var _noCofre = false;

  @override
  Future<void> initialize() async {
    await antiga.initialize();
    final velha = await antiga.accessToken();
    try {
      if (velha == null) {
        _sessao = await cofre.ler(_chave);
      } else {
        // Se existe nas preferências, é a mais nova (o cofre pode ter falhado antes).
        await cofre.gravar(_chave, velha);
        if (await cofre.ler(_chave) != velha) throw StateError('o cofre não guardou a sessão');
        await antiga.removePersistedSession();
        _sessao = velha;
      }
      _noCofre = true;
    } catch (e) {
      debugPrint('Sessão: cofre indisponível ($e)');
      _sessao = velha;
      _noCofre = false;
    }
  }

  @override
  Future<bool> hasAccessToken() async => _sessao != null;

  @override
  Future<String?> accessToken() async => _sessao;

  @override
  Future<void> persistSession(String persistSessionString) async {
    _sessao = persistSessionString;
    if (_noCofre) {
      try {
        await cofre.gravar(_chave, persistSessionString);
        return;
      } catch (e) {
        debugPrint('Sessão: não gravei no cofre ($e)');
        _noCofre = false;
      }
    }
    await antiga.persistSession(persistSessionString);
  }

  @override
  Future<void> removePersistedSession() async {
    _sessao = null;
    await antiga.removePersistedSession();
    try {
      await cofre.apagar(_chave);
    } catch (e) {
      debugPrint('Sessão: não apaguei do cofre ($e)');
    }
  }
}
