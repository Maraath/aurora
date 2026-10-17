import 'package:flutter/material.dart';

import '../core/tema.dart';
import 'componentes.dart';
import 'formulario.dart';

/// Primeira abertura num aparelho novo: o app começa vazio. Pede só o nome
/// (opcional, para a saudação) ou leva quem já usa o Aurora a entrar na conta.
class BoasVindasPage extends StatefulWidget {
  const BoasVindasPage({super.key, required this.aoComecar, required this.aoEntrar});

  final ValueChanged<String> aoComecar;
  final VoidCallback aoEntrar;

  @override
  State<BoasVindasPage> createState() => _BoasVindasPageState();
}

class _BoasVindasPageState extends State<BoasVindasPage> {
  final _nome = TextEditingController();

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  void _comecar() => widget.aoComecar(_nome.text.trim());

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(alignment: Alignment.centerLeft, child: LogoAurora(tamanho: 44)),
                  const SizedBox(height: 22),
                  Text('Boas-vindas ao Aurora', style: sora(26)),
                  const SizedBox(height: 10),
                  Text(
                    'Tarefas, hábitos, treino, alimentação, finanças e metas num lugar só. '
                    'Tudo começa vazio e fica neste aparelho; a conta é opcional.',
                    style: manrope(15, cor: c.muted, altura: 1.5),
                  ),
                  const SizedBox(height: 26),
                  Campo(
                    rotulo: 'Como quer ser chamado? (opcional)',
                    child: CampoTexto(controle: _nome, dica: 'Seu nome', autofoco: true),
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: BotaoPilula(texto: 'Começar', aoTocar: _comecar),
                  ),
                  const SizedBox(height: 28),
                  Divider(color: c.line),
                  const SizedBox(height: 14),
                  Text('Já usa o Aurora em outro aparelho?', style: manrope(14, peso: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    'Entre na sua conta e seus dados chegam pela nuvem.',
                    style: manrope(13, cor: c.muted, altura: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: BotaoPilula(texto: 'Entrar na minha conta', principal: false, aoTocar: widget.aoEntrar),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
