import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/nuvem.dart';
import '../../core/tema.dart';
import '../componentes.dart';
import '../em_breve.dart';
import '../formulario.dart';

/// Conta na nuvem. Opcional: sem conta, o app funciona offline como sempre.
class ContaPage extends StatefulWidget {
  const ContaPage({super.key, this.voltar});
  final VoidCallback? voltar;

  @override
  State<ContaPage> createState() => _ContaPageState();
}

enum _Modo { entrar, criar }

class _ContaPageState extends State<ContaPage> {
  final _email = TextEditingController();
  final _senha = TextEditingController();
  _Modo _modo = _Modo.entrar;
  bool _ocupado = false;
  String? _erro;
  String? _aviso;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    final cliente = nuvem;
    if (cliente == null) return;
    final email = _email.text.trim();
    final senha = _senha.text;
    if (email.isEmpty || senha.isEmpty) {
      setState(() => _erro = 'Preencha e-mail e senha.');
      return;
    }
    setState(() {
      _ocupado = true;
      _erro = null;
      _aviso = null;
    });
    try {
      if (_modo == _Modo.entrar) {
        await cliente.auth.signInWithPassword(email: email, password: senha);
      } else {
        final r = await cliente.auth.signUp(email: email, password: senha);
        if (r.session == null) {
          _aviso = 'Conta criada. Abra o e-mail de confirmação que o Supabase enviou e depois toque em Entrar.';
          _modo = _Modo.entrar;
        }
      }
      _senha.clear();
    } catch (e) {
      _erro = mensagemDeErro(e);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _sair() async {
    try {
      await nuvem?.auth.signOut();
    } catch (e) {
      if (mounted) setState(() => _erro = mensagemDeErro(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final cliente = nuvem;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TituloPagina('Conta e sincronização', voltar: widget.voltar),
        const SizedBox(height: 18),
        if (cliente == null)
          const Vazio('A nuvem não pôde ser iniciada neste aparelho. O app continua funcionando offline.')
        else
          StreamBuilder<AuthState>(
            stream: cliente.auth.onAuthStateChange,
            builder: (context, _) {
              final usuario = cliente.auth.currentUser;
              return usuario == null ? _formulario(c) : _logado(c, usuario);
            },
          ),
      ],
    );
  }

  Widget _logado(AuroraCores c, User usuario) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Cartao(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CONECTADO', style: rotulo(c.teal)),
              const SizedBox(height: 6),
              Text(usuario.email ?? '', style: sora(18)),
              const SizedBox(height: 8),
              Text(
                'A sincronização entre aparelhos e a IA do assistente chegam nos próximos passos. '
                'Seus dados continuam guardados neste aparelho.',
                style: manrope(13, cor: c.muted, altura: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: BotaoPilula(texto: 'Sair da conta', principal: false, aoTocar: _sair),
        ),
        if (_erro != null) ...[
          const SizedBox(height: 10),
          Text(_erro!, style: manrope(13, peso: FontWeight.w600, cor: c.bad)),
        ],
      ],
    );
  }

  Widget _formulario(AuroraCores c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'A conta é opcional. Com ela, seus dados vão para a nuvem e aparecem no celular e no PC, '
          'e o assistente passa a responder com IA. Sem ela, tudo continua só neste aparelho.',
          style: manrope(14, cor: c.text, altura: 1.5),
        ),
        const SizedBox(height: 16),
        Segmentos<_Modo>(
          opcoes: _Modo.values,
          selecionado: _modo,
          rotulo: (m) => m == _Modo.entrar ? 'Entrar' : 'Criar conta',
          aoEscolher: (m) => setState(() {
            _modo = m;
            _erro = null;
          }),
        ),
        const SizedBox(height: 16),
        Campo(
          rotulo: 'E-mail',
          child: CampoTexto(
            controle: _email,
            dica: 'voce@exemplo.com',
            email: true,
            aoMudar: (_) => setState(() => _erro = null),
          ),
        ),
        const SizedBox(height: 12),
        Campo(
          rotulo: _modo == _Modo.criar ? 'Senha (pelo menos 6 caracteres)' : 'Senha',
          child: CampoTexto(
            controle: _senha,
            dica: '••••••',
            senha: true,
            aoMudar: (_) => setState(() => _erro = null),
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: _ocupado
              ? const Padding(
                  padding: EdgeInsets.all(10),
                  child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)),
                )
              : BotaoPilula(texto: _modo == _Modo.entrar ? 'Entrar' : 'Criar conta', aoTocar: _confirmar),
        ),
        if (_aviso != null) ...[
          const SizedBox(height: 12),
          Text(_aviso!, style: manrope(13, peso: FontWeight.w600, cor: c.teal, altura: 1.4)),
        ],
        if (_erro != null) ...[
          const SizedBox(height: 12),
          Text(_erro!, style: manrope(13, peso: FontWeight.w600, cor: c.bad, altura: 1.4)),
        ],
      ],
    );
  }
}
