import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/atualizacao.dart';
import '../../core/formato.dart';
import '../../core/login_google.dart';
import '../../core/nuvem.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/servico_sync.dart';
import '../../data/sincronizacao.dart';
import '../atualizacao_ui.dart';
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

  Future<void> _google() async {
    setState(() {
      _ocupado = true;
      _erro = null;
      _aviso = null;
    });
    try {
      await entrarComGoogle();
    } on LoginCancelado {
      // A pessoa desistiu: nada a mostrar.
    } catch (e) {
      _erro = mensagemDeErro(e);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _sair() async {
    try {
      await sairDoGoogle();
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
        const SizedBox(height: 28),
        _Versao(),
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
                'Seus dados ficam neste aparelho e vão para a nuvem sozinhos: ao abrir o app, '
                'alguns segundos depois de cada mudança e a cada 2 minutos.',
                style: manrope(13, cor: c.muted, altura: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ValueListenableBuilder<EstadoSync>(
          valueListenable: ServicoSync.instancia.estado,
          builder: (context, e, _) => _estadoSync(c, e),
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

  Widget _estadoSync(AuroraCores c, EstadoSync e) {
    if (e.fase == FaseSync.escolher) {
      return Cartao(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('PRIMEIRA SINCRONIZAÇÃO', style: rotulo(c.warn)),
            const SizedBox(height: 8),
            Text(
              'Esta conta já tem dados na nuvem e este aparelho também tem os seus. '
              'Se este aparelho só tem os dados de exemplo, use os da nuvem.',
              style: manrope(14, altura: 1.5),
            ),
            const SizedBox(height: 14),
            Wrap(spacing: 10, runSpacing: 10, children: [
              BotaoPilula(texto: 'Usar os dados da nuvem', aoTocar: _usarNuvem),
              BotaoPilula(
                texto: 'Juntar os dois',
                principal: false,
                aoTocar: () => ServicoSync.instancia.escolher(EscolhaPrimeiraVez.juntar),
              ),
            ]),
          ],
        ),
      );
    }
    final ultima = e.ultima;
    final (texto, cor) = switch (e.fase) {
      FaseSync.sincronizando => ('Sincronizando…', c.accent),
      FaseSync.erro => ('Não sincronizou: ${e.mensagem}', c.bad),
      _ => (
          ultima == null
              ? 'Ainda não sincronizou.'
              : 'Sincronizado ${diaRelativo(DateTime(ultima.year, ultima.month, ultima.day), hojeSP())} às ${hora(ultima)}.',
          c.muted
        ),
    };
    return Row(
      children: [
        Expanded(child: Text(texto, style: manrope(13, peso: FontWeight.w600, cor: cor, altura: 1.4))),
        const SizedBox(width: 10),
        if (e.fase == FaseSync.sincronizando)
          const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
        else
          BotaoPilula(texto: 'Sincronizar agora', principal: false, aoTocar: ServicoSync.instancia.sincronizar),
      ],
    );
  }

  Future<void> _usarNuvem() async {
    final c = context.cores;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text('Usar os dados da nuvem?', style: sora(18)),
        content: Text(
          'Os dados deste aparelho (tarefas, hábitos, finanças, treinos, medidas e a conversa do '
          'assistente) serão apagados daqui e trocados pelos que estão na sua conta.',
          style: manrope(14, cor: c.text, altura: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Trocar pelos da nuvem', style: TextStyle(color: c.bad)),
          ),
        ],
      ),
    );
    if (ok == true) await ServicoSync.instancia.escolher(EscolhaPrimeiraVez.usarNuvem);
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
        _BotaoGoogle(ocupado: _ocupado, aoTocar: _google),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: Divider(color: c.line)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('ou com e-mail', style: manrope(12, cor: c.muted)),
          ),
          Expanded(child: Divider(color: c.line)),
        ]),
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

/// Botão "Continuar com Google" (branco, como pede a identidade do Google).
class _BotaoGoogle extends StatelessWidget {
  const _BotaoGoogle({required this.ocupado, required this.aoTocar});
  final bool ocupado;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Material(
      color: Colors.white,
      shape: StadiumBorder(side: BorderSide(color: c.line)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: ocupado ? null : aoTocar,
        child: SizedBox(
          height: 48,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('G', style: sora(20, cor: const Color(0xFF4285F4))),
            const SizedBox(width: 12),
            Text('Continuar com Google', style: manrope(15, peso: FontWeight.w700, cor: const Color(0xFF1F1F1F))),
          ]),
        ),
      ),
    );
  }
}

/// Versão instalada e, no app instalado do Windows, "Procurar atualização".
class _Versao extends StatefulWidget {
  @override
  State<_Versao> createState() => _VersaoState();
}

class _VersaoState extends State<_Versao> {
  String? _texto;
  bool _procurando = false;

  Future<void> _procurar() async {
    setState(() {
      _procurando = true;
      _texto = null;
    });
    final a = await Atualizador.instancia.verificar();
    if (!mounted) return;
    setState(() {
      _procurando = false;
      if (a == null) _texto = 'Você já está na versão mais nova.';
    });
    if (a != null) await mostrarAtualizacao(context, a);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final at = Atualizador.instancia;
    if (!at.suportado) return const SizedBox.shrink();
    return Row(children: [
      Expanded(
        child: Text(
          _texto ?? (at.versaoAtual.isEmpty ? 'Aurora' : 'Aurora ${at.versaoAtual}'),
          style: manrope(13, cor: c.muted),
        ),
      ),
      if (_procurando)
        const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
      else
        BotaoPilula(texto: 'Procurar atualização', principal: false, aoTocar: _procurar),
    ]);
  }
}
