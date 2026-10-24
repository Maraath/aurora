import 'package:flutter/material.dart';

import '../core/tema.dart';
import 'componentes.dart';
import 'em_breve.dart';
import 'shell.dart';

class MaisPage extends StatelessWidget {
  const MaisPage({super.key, required this.ir});
  final ValueChanged<Secao> ir;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TituloPagina('Mais'),
        const SizedBox(height: 18),
        const TituloSecao('Rotina'),
        _Linha(
          icone: Icons.monitor_heart_outlined,
          fundo: c.accentSoft,
          frente: c.accent,
          titulo: 'Saúde',
          detalhe: 'Treino (com medidas e exercícios) e alimentação',
          aoTocar: () => ir(Secao.saude),
        ),
        const SizedBox(height: 10),
        _Linha(
          icone: Icons.notifications_none_rounded,
          fundo: c.tealSoft,
          frente: c.teal,
          titulo: 'Lembretes',
          detalhe: 'Avisos com hora e as automações do dia',
          aoTocar: () => ir(Secao.lembretes),
        ),
        const SizedBox(height: 18),
        const TituloSecao('Planos'),
        _Linha(
          icone: Icons.flag_outlined,
          fundo: c.accentSoft,
          frente: c.violeta,
          titulo: 'Metas',
          detalhe: 'Progresso e ritmo de cada objetivo',
          aoTocar: () => ir(Secao.metas),
        ),
        const SizedBox(height: 10),
        _Linha(
          icone: Icons.folder_outlined,
          fundo: c.surface2,
          frente: c.text,
          titulo: 'Projetos',
          detalhe: 'Etapas e linha do tempo',
          aoTocar: () => ir(Secao.projetos),
        ),
        const SizedBox(height: 10),
        _Linha(
          icone: Icons.sticky_note_2_outlined,
          fundo: c.badSoft,
          frente: c.bad,
          titulo: 'Anotações',
          detalhe: 'Notas, listas e ideias em áudio',
          aoTocar: () => ir(Secao.anotacoes),
        ),
        const SizedBox(height: 18),
        _Linha(
          icone: Icons.person_outline_rounded,
          fundo: c.surface2,
          frente: c.text,
          titulo: 'Conta e sincronização',
          detalhe: 'Entrar para usar no celular e no PC',
          aoTocar: () => ir(Secao.conta),
        ),
      ],
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha({
    required this.icone,
    required this.fundo,
    required this.frente,
    required this.titulo,
    required this.detalhe,
    required this.aoTocar,
  });

  final IconData icone;
  final Color fundo;
  final Color frente;
  final String titulo;
  final String detalhe;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Cartao(
      raio: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      aoTocar: aoTocar,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: fundo, borderRadius: BorderRadius.circular(12)),
            child: Icon(icone, size: 20, color: frente),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: manrope(15, peso: FontWeight.w600)),
                Text(detalhe, style: manrope(12, cor: c.muted)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: c.muted),
        ],
      ),
    );
  }
}
