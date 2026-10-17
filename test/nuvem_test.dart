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
}
