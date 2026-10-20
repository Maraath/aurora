import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'nuvem.dart';

/// Clientes OAuth do Google (projeto do dono no Google Cloud). IDs de cliente
/// são públicos; a chave secreta do cliente Web fica só no painel do Supabase.
const googleClienteWeb = '595805157725-auuvkhg8oo8chanob7ml7ib33scrfr6k.apps.googleusercontent.com';

/// O Android é validado pelo nome do pacote + SHA-1 da chave; o ID fica aqui
/// só como referência (o login nativo usa o cliente Web como "servidor").
const googleClienteAndroid = '595805157725-b52r4rtb7fta8iin1e2q3h3f6kj5mpia.apps.googleusercontent.com';

/// Porta local do login no desktop. Tem de estar nas Redirect URLs do
/// Supabase como "http://localhost:47361/**".
const portaLoginDesktop = 47361;

class LoginCancelado implements Exception {
  const LoginCancelado();
}

/// Entra com Google: nativo no Android/iOS; pelo navegador no Windows.
Future<void> entrarComGoogle() async {
  final cliente = nuvem;
  if (cliente == null) throw const AuthException('A nuvem não está disponível.');
  if (kIsWeb) {
    // Navegador (PWA): a página vai ao Google e volta para ela mesma; o supabase_flutter
    // lê o código na volta. A volta tem de estar nas Redirect URLs do Supabase.
    await cliente.auth.signInWithOAuth(OAuthProvider.google, redirectTo: '${Uri.base.origin}${Uri.base.path}');
  } else if (Platform.isAndroid || Platform.isIOS) {
    await _nativo(cliente);
  } else {
    await _peloNavegador(cliente);
  }
}

bool _iniciado = false;

Future<void> _nativo(SupabaseClient cliente) async {
  final google = GoogleSignIn.instance;
  if (!_iniciado) {
    await google.initialize(serverClientId: googleClienteWeb);
    _iniciado = true;
  }
  final GoogleSignInAccount conta;
  try {
    conta = await google.authenticate(scopeHint: const ['email', 'profile']);
  } on GoogleSignInException catch (e) {
    if (e.code == GoogleSignInExceptionCode.canceled) throw const LoginCancelado();
    rethrow;
  }
  final idToken = conta.authentication.idToken;
  if (idToken == null) throw const AuthException('O Google não devolveu o token de login.');
  await cliente.auth.signInWithIdToken(provider: OAuthProvider.google, idToken: idToken);
}

/// Desktop: abre o login do Google no navegador e recebe a volta numa porta
/// local; o código recebido vira a sessão (fluxo PKCE do Supabase).
Future<void> _peloNavegador(SupabaseClient cliente) async {
  final servidor = await HttpServer.bind(InternetAddress.loopbackIPv4, portaLoginDesktop);
  try {
    final abriu = await cliente.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'http://localhost:$portaLoginDesktop/',
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
    if (!abriu) throw const AuthException('Não consegui abrir o navegador.');

    final pedido = await servidor.first.timeout(const Duration(minutes: 5));
    final params = pedido.uri.queryParameters;
    final ok = params['code'] != null;
    pedido.response
      ..statusCode = 200
      ..headers.contentType = ContentType.html
      ..write('<!doctype html><meta charset="utf-8"><title>Aurora</title>'
          '<body style="font-family:sans-serif;background:#060B18;color:#E9EFFC;text-align:center;padding-top:20vh">'
          '<h2>${ok ? 'Pronto! Você entrou no Aurora.' : 'O login não foi concluído.'}</h2>'
          '<p>${ok ? 'Pode fechar esta aba e voltar ao app.' : 'Volte ao app e tente de novo.'}</p></body>');
    await pedido.response.close();

    if (!ok) {
      final erro = params['error_description'] ?? params['error'];
      if (erro == null || erro.contains('access_denied')) throw const LoginCancelado();
      throw AuthException(erro);
    }
    await cliente.auth.exchangeCodeForSession(params['code']!);
  } on TimeoutException {
    throw const LoginCancelado();
  } finally {
    await servidor.close(force: true);
  }
}

/// Sair também da conta Google no aparelho (no Android, para poder trocar de conta).
Future<void> sairDoGoogle() async {
  if (kIsWeb || !(Platform.isAndroid || Platform.isIOS) || !_iniciado) return;
  try {
    await GoogleSignIn.instance.signOut();
  } catch (_) {}
}
