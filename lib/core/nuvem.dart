import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Projeto do Supabase. A chave `anon` foi feita para ficar no app: o que
/// protege os dados são as regras de RLS no banco. A chave de serviço e a da
/// IA NUNCA ficam aqui; elas vivem só nos segredos da Edge Function.
const supabaseUrl = 'https://fhmhmdzbujqhkdsfnbtx.supabase.co';
const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZobWhtZHpidWpxaGtkc2ZuYnR4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTIxNzkyMjAsImV4cCI6MjEwNzc1NTIyMH0.L4c8wzk3bZGO3eX8tmjC8JuZtXa5Agwmiys36AT8lok';

/// Para onde o link de confirmação do cadastro leva: a imagem "E-mail
/// confirmado" no balde público (tool/paginas/gerar.ps1). Tem de estar nas
/// Redirect URLs do Supabase.
const urlConfirmado = '$supabaseUrl/storage/v1/object/public/atualizacoes/paginas/confirmado.png';

/// Liga o cliente da nuvem. Funciona sem internet (só lê a sessão salva);
/// se algo der errado, o app segue offline.
Future<bool> iniciarNuvem() async {
  try {
    await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseAnonKey);
    final auth = Supabase.instance.client.auth;
    debugPrint('Nuvem: sessão ao abrir = ${auth.currentSession != null}');
    auth.onAuthStateChange.listen(
      (e) => debugPrint('Nuvem: ${e.event.name} (sessão: ${e.session != null})'),
      onError: (Object e) => debugPrint('Nuvem: erro de sessão $e'),
    );
    return true;
  } catch (e) {
    debugPrint('Nuvem indisponível: $e');
    return false;
  }
}

/// Cliente, ou nulo se a nuvem não foi iniciada (testes, falha).
SupabaseClient? get nuvem {
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
}

/// Erro com a mensagem já pronta para a pessoa.
class ErroConta implements Exception {
  const ErroConta(this.mensagem);
  final String mensagem;
}

/// Exclui a conta de quem está logado (Edge Function "excluir-conta"): fotos,
/// dados da nuvem e o login. Depois sai da sessão. Os dados deste aparelho
/// ficam; o app segue funcionando offline.
Future<void> excluirConta(SupabaseClient cliente) async {
  try {
    await cliente.functions.invoke('excluir-conta');
  } on FunctionException catch (e) {
    final detalhes = e.details;
    throw ErroConta(detalhes is Map && detalhes['erro'] is String
        ? detalhes['erro'] as String
        : 'Não deu para excluir a conta (erro ${e.status}).');
  }
  try {
    await cliente.auth.signOut();
  } catch (_) {
    // A conta já não existe; o que importa é limpar a sessão local.
    await cliente.auth.signOut(scope: SignOutScope.local);
  }
}

/// Traduz os erros mais comuns do login para português.
String mensagemDeErro(Object e) {
  if (e is AuthException) {
    final m = e.message.toLowerCase();
    if (m.contains('invalid login credentials')) return 'E-mail ou senha incorretos.';
    if (m.contains('email not confirmed')) {
      return 'Confirme o e-mail primeiro: abra o link que mandamos.';
    }
    if (m.contains('expired') || (m.contains('token') && m.contains('invalid'))) {
      return 'Código errado ou vencido. Confira os números ou peça um novo.';
    }
    if (m.contains('security purposes') || m.contains('only request this after')) {
      return 'Espere alguns segundos antes de pedir de novo.';
    }
    if (m.contains('already registered')) return 'Já existe uma conta com esse e-mail. Use Entrar.';
    if (m.contains('password should be')) return 'A senha precisa ter pelo menos 6 caracteres.';
    // Limite de envio de e-mails do projeto inteiro (não é culpa de quem tenta):
    // com o serviço de e-mail padrão do Supabase são poucos por hora.
    if (e.code == 'over_email_send_rate_limit' || m.contains('email rate limit')) {
      return 'O Aurora mandou e-mails demais nesta hora e o envio pausou. Tente de novo mais tarde '
          'ou entre com o Google.';
    }
    if (m.contains('rate limit')) return 'Muitas tentativas. Espere um pouco e tente de novo.';
    if (m.contains('invalid') && m.contains('email')) return 'Esse e-mail não parece válido.';
    return e.message;
  }
  if (e is ErroConta) return e.mensagem;
  final t = e.toString().toLowerCase();
  if (t.contains('socket') || t.contains('failed host lookup') || t.contains('clientexception')) {
    return 'Sem conexão com a internet.';
  }
  return 'Algo deu errado: $e';
}
