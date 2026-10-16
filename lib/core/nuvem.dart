import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Projeto do Supabase. A chave `anon` foi feita para ficar no app: o que
/// protege os dados são as regras de RLS no banco. A chave de serviço e a da
/// IA NUNCA ficam aqui; elas vivem só nos segredos da Edge Function.
const supabaseUrl = 'https://fhmhmdzbujqhkdsfnbtx.supabase.co';
const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZobWhtZHpidWpxaGtkc2ZuYnR4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTIxNzkyMjAsImV4cCI6MjEwNzc1NTIyMH0.L4c8wzk3bZGO3eX8tmjC8JuZtXa5Agwmiys36AT8lok';

/// Liga o cliente da nuvem. Funciona sem internet (só lê a sessão salva);
/// se algo der errado, o app segue offline.
Future<bool> iniciarNuvem() async {
  try {
    await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseAnonKey);
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

/// Traduz os erros mais comuns do login para português.
String mensagemDeErro(Object e) {
  if (e is AuthException) {
    final m = e.message.toLowerCase();
    if (m.contains('invalid login credentials')) return 'E-mail ou senha incorretos.';
    if (m.contains('email not confirmed')) {
      return 'Confirme o e-mail primeiro: abra o link que o Supabase enviou.';
    }
    if (m.contains('already registered')) return 'Já existe uma conta com esse e-mail. Use Entrar.';
    if (m.contains('password should be')) return 'A senha precisa ter pelo menos 6 caracteres.';
    if (m.contains('rate limit')) return 'Muitas tentativas. Espere um pouco e tente de novo.';
    if (m.contains('invalid') && m.contains('email')) return 'Esse e-mail não parece válido.';
    return e.message;
  }
  final t = e.toString().toLowerCase();
  if (t.contains('socket') || t.contains('failed host lookup') || t.contains('clientexception')) {
    return 'Sem conexão com a internet.';
  }
  return 'Algo deu errado: $e';
}
