import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app.dart';
import '../../core/area_segura.dart';
import '../../core/atualizacao.dart';
import '../../core/formato.dart';
import '../../core/login_google.dart';
import '../../core/nuvem.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/catalogo_taco.dart' show fonteTaco;
import '../../data/servico_sync.dart';
import '../../data/sincronizacao.dart';
import '../atualizacao_ui.dart';
import '../bloqueio_ui.dart';
import '../componentes.dart';
import '../em_breve.dart';
import '../formulario.dart';
import '../janela/moldura_janela.dart';
import 'efeitos_config.dart';
import 'fala_config.dart';
import 'fotos_config.dart';

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
  final _codigo = TextEditingController();
  _Modo _modo = _Modo.entrar;
  bool _ocupado = false;
  String? _erro;
  String? _aviso;

  /// E-mail esperando confirmação (nulo = formulário normal).
  String? _verificando;

  /// Senha digitada no cadastro, só na memória: o "Já confirmei" entra direto.
  String? _senhaPendente;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    _codigo.dispose();
    super.dispose();
  }

  void _pedirConfirmacao(String email, String senha, String aviso) {
    _verificando = email;
    _senhaPendente = senha;
    _aviso = aviso;
    _codigo.clear();
  }

  void _sairDaConfirmacao() {
    _verificando = null;
    _senhaPendente = null;
    _codigo.clear();
  }

  /// Ação com o indicador de "ocupado" e o erro traduzido.
  Future<void> _executar(Future<void> Function() acao) async {
    setState(() {
      _ocupado = true;
      _erro = null;
      _aviso = null;
    });
    try {
      await acao();
    } catch (e) {
      _erro = mensagemDeErro(e);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  /// Depois de abrir o link do e-mail: entra com a senha do cadastro.
  Future<void> _jaConfirmei() async {
    final cliente = nuvem, email = _verificando, senha = _senhaPendente;
    if (cliente == null || email == null) return;
    if (senha == null) {
      setState(() {
        _sairDaConfirmacao();
        _aviso = 'Agora entre com o seu e-mail e senha.';
      });
      return;
    }
    await _executar(() async {
      await cliente.auth.signInWithPassword(email: email, password: senha);
      _sairDaConfirmacao();
    });
  }

  /// Quando o e-mail traz um código numérico (com serviço de e-mail próprio
  /// o modelo mostra `{{ .Token }}`), confirma por ele e já entra.
  Future<void> _verificarCodigo() async {
    final cliente = nuvem, email = _verificando;
    if (cliente == null || email == null) return;
    final codigo = _codigo.text.replaceAll(RegExp(r'\D'), '');
    if (codigo.length < 6) {
      setState(() => _erro = 'Digite os números do código que chegou no seu e-mail.');
      return;
    }
    await _executar(() async {
      await cliente.auth.verifyOTP(type: OtpType.signup, email: email, token: codigo);
      _sairDaConfirmacao();
    });
  }

  Future<void> _reenviar() async {
    final cliente = nuvem, email = _verificando;
    if (cliente == null || email == null) return;
    await _executar(() async {
      await cliente.auth.resend(type: OtpType.signup, email: email, emailRedirectTo: urlConfirmado);
      _aviso = 'Mandamos um e-mail novo para $email.';
    });
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
        final r = await cliente.auth.signUp(email: email, password: senha, emailRedirectTo: urlConfirmado);
        if (r.session == null) {
          _modo = _Modo.entrar;
          _pedirConfirmacao(email, senha, 'Conta criada. Mandamos um e-mail de confirmação para $email.');
        }
      }
      _senha.clear();
    } catch (e) {
      // Tentou entrar sem ter confirmado o e-mail: vai direto para a confirmação.
      if (e is AuthException && e.message.toLowerCase().contains('email not confirmed')) {
        _pedirConfirmacao(email, senha, 'Falta confirmar o e-mail. Abra o link que mandamos para $email, '
            'ou peça um novo.');
        _senha.clear();
      } else {
        _erro = mensagemDeErro(e);
      }
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
              if (usuario != null) return _logado(c, usuario);
              return _verificando == null ? _formulario(c) : _formularioCodigo(c);
            },
          ),
        const SizedBox(height: 28),
        SecaoFotos(db: AuroraEscopo.de(context).db),
        const SizedBox(height: 28),
        SecaoBloqueio(db: AuroraEscopo.de(context).db),
        const SizedBox(height: 28),
        SecaoRespostaFalada(db: AuroraEscopo.de(context).db),
        const SizedBox(height: 28),
        SecaoEfeitos(db: AuroraEscopo.de(context).db),
        if (molduraPropria) ...[
          const SizedBox(height: 28),
          SecaoBandejaWindows(db: AuroraEscopo.de(context).db),
        ],
        const SizedBox(height: 28),
        _Versao(),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => showLicensePage(
              context: context,
              applicationName: 'Aurora',
              applicationLegalese: 'Alimentos: $fonteTaco.',
            ),
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4)),
            child: Text('Licenças', style: manrope(13, peso: FontWeight.w600, cor: c.muted)),
          ),
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
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: _ocupado
              ? const Padding(
                  padding: EdgeInsets.all(10),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5)),
                )
              : TextButton(
                  onPressed: () => _excluirConta(usuario),
                  child: Text('Excluir conta', style: manrope(13, peso: FontWeight.w600, cor: c.bad)),
                ),
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
              : 'Sincronizado ${diaRelativo(DateTime(ultima.year, ultima.month, ultima.day), hojeLocal())} às ${hora(ultima)}.',
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

  Future<void> _excluirConta(User usuario) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => const _ConfirmarExclusao(),
    );
    final cliente = nuvem;
    if (ok != true || cliente == null) return;
    await _executar(() async {
      await excluirConta(cliente);
      await sairDoGoogle();
      _aviso = 'Conta excluída. Os dados deste aparelho continuam aqui, só offline.';
    });
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

  /// Depois do cadastro: confirmar pelo link do e-mail (ou por um código).
  Widget _formularioCodigo(AuroraCores c) {
    final carregando = const Padding(
      padding: EdgeInsets.all(10),
      child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Cartao(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CONFIRME O SEU E-MAIL', style: rotulo(c.accent)),
              const SizedBox(height: 6),
              Text(_verificando!, style: sora(18)),
              const SizedBox(height: 8),
              Text(
                'Abra o e-mail que mandamos e toque no link de confirmação. Quando aparecer '
                '"E-mail confirmado", volte aqui e toque em Já confirmei. '
                'Se não chegar, olhe no spam ou peça outro.',
                style: manrope(13, cor: c.muted, altura: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (_ocupado)
              carregando
            else ...[
              BotaoPilula(texto: 'Já confirmei', aoTocar: _jaConfirmei),
              BotaoPilula(texto: 'Reenviar e-mail', principal: false, aoTocar: _reenviar),
            ],
            TextButton(
              onPressed: () => setState(() {
                _sairDaConfirmacao();
                _erro = null;
                _aviso = null;
              }),
              child: Text('Usar outro e-mail', style: manrope(13, peso: FontWeight.w600, cor: c.muted)),
            ),
          ],
        ),
        if (_aviso != null) ...[
          const SizedBox(height: 12),
          Text(_aviso!, style: manrope(13, peso: FontWeight.w600, cor: c.teal, altura: 1.4)),
        ],
        if (_erro != null) ...[
          const SizedBox(height: 12),
          Text(_erro!, style: manrope(13, peso: FontWeight.w600, cor: c.bad, altura: 1.4)),
        ],
        const SizedBox(height: 22),
        Text('O e-mail trouxe um código numérico?', style: manrope(13, peso: FontWeight.w700)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: CampoTexto(
              controle: _codigo,
              dica: '123456',
              numerico: true,
              aoMudar: (_) => setState(() => _erro = null),
            ),
          ),
          const SizedBox(width: 10),
          BotaoPilula(texto: 'Confirmar código', principal: false, aoTocar: _verificarCodigo),
        ]),
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

/// Confirmação de excluir a conta: diz o que some e pede para digitar EXCLUIR.
class _ConfirmarExclusao extends StatefulWidget {
  const _ConfirmarExclusao();

  @override
  State<_ConfirmarExclusao> createState() => _ConfirmarExclusaoState();
}

class _ConfirmarExclusaoState extends State<_ConfirmarExclusao> {
  final _texto = TextEditingController();

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  bool get _liberado => _texto.text.trim().toUpperCase() == 'EXCLUIR';

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return AlertDialog(
      backgroundColor: c.surface,
      title: Text('Excluir a conta?', style: sora(18)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Isto apaga para sempre, da nuvem: o seu login, todos os dados sincronizados '
              '(tarefas, hábitos, finanças, treinos, medidas, alimentação, metas, projetos, '
              'automações e a conversa do assistente) e as fotos do Shape. Não tem como desfazer.',
              style: manrope(14, cor: c.text, altura: 1.5),
            ),
            const SizedBox(height: 10),
            Text(
              'Os dados deste aparelho continuam aqui e o app segue funcionando offline. Para '
              'apagá-los também, desinstale o app.',
              style: manrope(13, cor: c.muted, altura: 1.5),
            ),
            const SizedBox(height: 14),
            Campo(
              rotulo: 'Digite EXCLUIR para confirmar',
              child: CampoTexto(controle: _texto, dica: 'EXCLUIR', aoMudar: (_) => setState(() {})),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        TextButton(
          onPressed: _liberado ? () => Navigator.pop(context, true) : null,
          child: Text('Excluir para sempre',
              style: TextStyle(color: _liberado ? c.bad : c.muted, fontWeight: FontWeight.w700)),
        ),
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
    if (kIsWeb) {
      // Web: atualiza sozinha (Service Worker). As medidas ajudam a acertar o
      // safe-area de cada iPhone (mande uma captura desta linha).
      final medidas = medidasDaTela();
      return Text('Aurora (web)${medidas == null ? '' : '\n$medidas'}',
          style: manrope(12, cor: c.muted, altura: 1.5));
    }
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
