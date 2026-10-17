import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/tema.dart';
import '../../data/biblioteca_exercicios.dart';
import '../componentes.dart';
import '../em_breve.dart';
import '../formulario.dart';

/// A animação do exercício: baixa na primeira vez e depois vem do aparelho.
class AnimacaoExercicio extends StatefulWidget {
  const AnimacaoExercicio({super.key, required this.arquivo, this.tamanho = 280});
  final String arquivo;
  final double tamanho;

  @override
  State<AnimacaoExercicio> createState() => _AnimacaoExercicioState();
}

class _AnimacaoExercicioState extends State<AnimacaoExercicio> {
  late Future<File?> _arquivo = animacaoExercicio(widget.arquivo);

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Container(
      width: widget.tamanho,
      height: widget.tamanho,
      clipBehavior: Clip.antiAlias,
      // As animações têm fundo branco: o quadro fica branco nos dois temas.
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: FutureBuilder<File?>(
        future: _arquivo,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2.5));
          }
          final f = snap.data;
          if (f == null) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.wifi_off_rounded, color: Colors.black45),
                const SizedBox(height: 8),
                Text('Sem conexão: a animação aparece quando a internet voltar.',
                    textAlign: TextAlign.center, style: manrope(12, cor: Colors.black54)),
                TextButton(
                  onPressed: () => setState(() => _arquivo = animacaoExercicio(widget.arquivo)),
                  child: Text('Tentar de novo', style: manrope(12, peso: FontWeight.w700, cor: c.accentFill)),
                ),
              ]),
            );
          }
          return Image.file(f, fit: BoxFit.contain, gaplessPlayback: true, semanticLabel: 'Animação do exercício');
        },
      ),
    );
  }
}

/// Folha com a animação de um exercício.
Future<void> verExercicio(BuildContext context, {required String nome, required String arquivo, String? grupo}) {
  final c = context.cores;
  return abrirFolha<void>(
    context,
    (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(nome, textAlign: TextAlign.center, style: sora(18)),
            if (grupo != null) ...[
              const SizedBox(height: 4),
              Text(grupo, style: manrope(13, cor: c.muted)),
            ],
            const SizedBox(height: 16),
            AnimacaoExercicio(arquivo: arquivo, tamanho: 300),
            const SizedBox(height: 12),
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar')),
          ],
        ),
      ),
    ),
  );
}

/// Escolher um exercício da biblioteca (para a ficha de treino).
Future<ItemExercicio?> escolherDaBiblioteca(BuildContext context, {String busca = ''}) =>
    abrirFolha<ItemExercicio>(context, (_) => _Seletor(buscaInicial: busca, escolher: true));

/// Página da biblioteca (Hábitos › Ficha de treino › Biblioteca).
class BibliotecaPage extends StatelessWidget {
  const BibliotecaPage({super.key, this.voltar});
  final VoidCallback? voltar;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TituloPagina('Biblioteca de exercícios', voltar: voltar),
          const SizedBox(height: 14),
          const _Seletor(buscaInicial: '', escolher: false),
        ],
      );
}

class _Seletor extends StatefulWidget {
  const _Seletor({required this.buscaInicial, required this.escolher});
  final String buscaInicial;

  /// Na folha de escolha, tocar escolhe; na página, tocar mostra a animação.
  final bool escolher;

  @override
  State<_Seletor> createState() => _SeletorState();
}

class _SeletorState extends State<_Seletor> {
  late final _busca = TextEditingController(text: widget.buscaInicial);
  BibliotecaExercicios? _biblioteca;
  String? _grupo;

  @override
  void initState() {
    super.initState();
    BibliotecaExercicios.carregar().then((b) {
      if (mounted) setState(() => _biblioteca = b);
    });
  }

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final b = _biblioteca;
    final lista = b == null ? const <ItemExercicio>[] : b.buscar(_busca.text, grupo: _grupo);
    final conteudo = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.escolher) ...[
          Text('Escolher exercício', style: sora(20)),
          const SizedBox(height: 12),
        ],
        CampoTexto(
          controle: _busca,
          dica: 'Buscar: supino, rosca, agachamento…',
          autofoco: widget.escolher,
          aoMudar: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        if (b != null)
          SizedBox(
            height: 40,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              for (final g in [null, ...b.grupos])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: OpcaoChip(
                    texto: g ?? 'Todos',
                    selecionado: _grupo == g,
                    aoTocar: () => setState(() => _grupo = g),
                  ),
                ),
            ]),
          ),
        const SizedBox(height: 10),
        if (b == null)
          const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
        else if (lista.isEmpty)
          const Vazio('Nenhum exercício com esse nome. Tente outra palavra ou outro grupo.')
        else
          for (final e in lista)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Cartao(
                raio: 14,
                padding: const EdgeInsets.fromLTRB(14, 6, 4, 6),
                aoTocar: widget.escolher
                    ? () => Navigator.pop(context, e)
                    : () => verExercicio(context, nome: e.nome, arquivo: e.arquivo, grupo: e.grupo),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(e.nome, style: manrope(14, peso: FontWeight.w600)),
                      Text(e.grupo, style: manrope(12, cor: c.muted)),
                    ]),
                  ),
                  IconButton(
                    tooltip: 'Ver o movimento',
                    onPressed: () => verExercicio(context, nome: e.nome, arquivo: e.arquivo, grupo: e.grupo),
                    icon: Icon(Icons.play_circle_outline_rounded, color: c.accent),
                  ),
                ]),
              ),
            ),
        if (b != null && lista.length == 60)
          Text('Mostrando 60. Refine a busca ou escolha um grupo.', style: manrope(12, cor: c.muted)),
      ],
    );
    if (!widget.escolher) return conteudo;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
      child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), child: conteudo),
    );
  }
}
