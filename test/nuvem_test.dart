import 'package:aurora/core/nuvem.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('erros da confirmação por código saem em português', () {
    expect(mensagemDeErro(const AuthException('Email not confirmed')),
        'Confirme o e-mail primeiro: abra o link que mandamos.');
    expect(mensagemDeErro(const AuthException('Token has expired or is invalid')),
        'Código errado ou vencido. Confira os números ou peça um novo.');
    expect(mensagemDeErro(const AuthException('For security purposes, you can only request this after 42 seconds.')),
        'Espere alguns segundos antes de pedir de novo.');
    expect(mensagemDeErro(const AuthException('Invalid login credentials')), 'E-mail ou senha incorretos.');
  });

  test('limite de e-mails do projeto não parece culpa de quem tenta', () {
    final porCodigo = mensagemDeErro(
        const AuthException('email rate limit exceeded', statusCode: '429', code: 'over_email_send_rate_limit'));
    expect(porCodigo, contains('e-mails demais nesta hora'));
    expect(mensagemDeErro(const AuthException('Email rate limit exceeded')), porCodigo);
    expect(mensagemDeErro(const AuthException('Request rate limit reached')),
        'Muitas tentativas. Espere um pouco e tente de novo.');
  });
}
