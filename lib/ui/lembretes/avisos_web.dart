import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/avisos_push.dart';
import '../../core/nuvem.dart';
import '../../core/tema.dart';
import '../componentes.dart';

/// Lembretes (só na web): liga os avisos deste aparelho por Web Push. No iPhone
/// só funciona com o Aurora na tela de início e com a conta conectada.
class CartaoAvisosWeb extends StatefulWidget {
  const CartaoAvisosWeb({super.key});

  @override
  State<CartaoAvisosWeb> createState() => _CartaoAvisosWebState();
}

class _CartaoAvisosWebState extends State<CartaoAvisosWeb> {
  EstadoAvisos? _estado;
  String? _mensagem;
  bool _ocupado = false;
  StreamSubscription<Object?>? _conta;

  @override
  void initState() {
    super.initState();
    AvisosPush.mudou.addListener(_ler);
    _conta = nuvem?.auth.onAuthStateChange.listen((_) => _ler());
    _ler();
  }

  @override
  void dispose() {
    AvisosPush.mudou.removeListener(_ler);
    _conta?.cancel();
    super.dispose();
  }

  Future<void> _ler() async {
    final e = await AvisosPush.estado();
    if (mounted) setState(() => _estado = e);
  }

  // Sem espera antes de AvisosPush.ativar(): o iPhone só mostra o pedido de
  // permissão se ele sair direto do toque.
  void _ativar() {
    setState(() {
      _ocupado = true;
      _mensagem = null;
    });
    AvisosPush.ativar().then((erro) {
      if (!mounted) return;
      setState(() {
        _ocupado = false;
        _mensagem = erro ?? 'Pronto! Os lembretes vão chegar neste aparelho.';
      });
    });
  }

  Future<void> _testar() async {
    setState(() => _ocupado = true);
    try {
      await AvisosPush.testar();
      _mensagem = 'Teste enviado: o aviso chega em até 1 minuto.';
    } catch (_) {
      _mensagem = 'Sem conexão com o servidor. Tente de novo com internet.';
    }
    if (mounted) setState(() => _ocupado = false);
  }

  Future<void> _desligar() async {
    setState(() => _ocupado = true);
    await AvisosPush.desativar();
    if (mounted) {
      setState(() {
        _ocupado = false;
        _mensagem = 'Avisos desligados neste aparelho.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final estado = _estado;
    if (estado == null) return const SizedBox.shrink();
    final logado = AvisosPush.logado;
    final (texto, acoes) = switch (estado) {
      EstadoAvisos.instalar => (
          'No iPhone, os avisos só chegam com o Aurora na tela de início: no Safari, toque em '
              'Compartilhar › Adicionar à Tela de Início e abra pelo ícone.',
          <Widget>[],
        ),
      EstadoAvisos.semSuporte => ('Este navegador não recebe avisos do Aurora.', <Widget>[]),
      EstadoAvisos.negado => (
          'Os avisos foram recusados neste aparelho. Para ligar: Ajustes › Notificações › Aurora '
              '(no computador, nas permissões do site).',
          <Widget>[],
        ),
      _ when !logado => (
          'Para os lembretes tocarem neste aparelho, entre na sua conta em Mais › Conta: '
              'é o servidor dela que manda os avisos na hora.',
          <Widget>[],
        ),
      EstadoAvisos.desligado => (
          'Os lembretes ainda não tocam neste aparelho. Ative para receber os avisos na hora, '
              'mesmo com o Aurora fechado.',
          <Widget>[BotaoPilula(texto: 'Ativar avisos', aoTocar: _ativar)],
        ),
      EstadoAvisos.ativo => (
          'Avisos ligados: lembretes, tarefas e hábitos com aviso tocam neste aparelho, mesmo com o '
              'Aurora fechado (precisa de internet na hora).',
          <Widget>[
            BotaoPilula(texto: 'Mandar um teste', principal: false, aoTocar: _testar),
            BotaoPilula(texto: 'Desligar', principal: false, aoTocar: _desligar),
          ],
        ),
    };
    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Icon(estado == EstadoAvisos.ativo ? Icons.notifications_active_outlined : Icons.notifications_off_outlined,
                size: 18, color: estado == EstadoAvisos.ativo ? c.accent : c.warn),
            const SizedBox(width: 8),
            Text('AVISOS NESTE APARELHO', style: rotulo(c.accent)),
          ]),
          const SizedBox(height: 8),
          Text(texto, style: manrope(13, cor: c.muted, altura: 1.5)),
          if (acoes.isNotEmpty) ...[
            const SizedBox(height: 14),
            if (_ocupado)
              const Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5)),
              )
            else
              Wrap(spacing: 8, runSpacing: 8, children: acoes),
          ],
          if (_mensagem != null) ...[
            const SizedBox(height: 10),
            Text(_mensagem!, style: manrope(12, cor: c.text, altura: 1.5)),
          ],
        ],
      ),
    );
  }
}
