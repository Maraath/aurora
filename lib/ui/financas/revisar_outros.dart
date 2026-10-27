import 'package:flutter/material.dart';

import '../../core/categorias.dart';
import '../../core/comandos.dart';
import '../../core/formato.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/financas_repo.dart';
import '../formulario.dart';

/// Revisão do que ficou em "Outros": cada lançamento do mês aparece com as
/// categorias que a Aurora sugere pelo nome (e as que a pessoa mais usa), e um
/// toque troca a categoria. É como a lista de categorias aprende com o uso.
Future<void> abrirRevisarOutros(
  BuildContext context, {
  required FinancasRepo repo,
  required List<Movimento> movimentos,
}) =>
    abrirFolha<void>(context, (_) => _RevisarOutros(repo: repo, movimentos: movimentos));

class _RevisarOutros extends StatefulWidget {
  const _RevisarOutros({required this.repo, required this.movimentos});

  final FinancasRepo repo;
  final List<Movimento> movimentos;

  @override
  State<_RevisarOutros> createState() => _RevisarOutrosState();
}

class _RevisarOutrosState extends State<_RevisarOutros> {
  /// O que ainda está em "Outros" (some conforme a pessoa escolhe).
  late List<Movimento> _pendentes = [...widget.movimentos];

  /// Categorias mais usadas, para completar as sugestões.
  List<String> _usadas = const [];

  /// Lançamento com a lista inteira aberta (id).
  String? _aberta;

  int get _totalCentavos => _pendentes.fold(0, (s, m) => s + m.valorCentavos);

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
  }

  Future<void> _carregarCategorias() async {
    try {
      final usadas = await widget.repo.categoriasMaisUsadas(TipoTransacao.saida);
      if (mounted) setState(() => _usadas = usadas);
    } catch (e) {
      debugPrint('Finanças: não li as categorias mais usadas ($e)');
    }
  }

  /// Sugestões de um lançamento: o que o nome indica e, depois, as categorias
  /// que a pessoa mais usa (até 4, sem "Outros").
  List<String> _sugestoes(Movimento m) {
    final lista = <String>[];
    final peloNome = categoriaGasto(m.nome);
    if (peloNome != 'Outros') lista.add(peloNome);
    for (final nome in _usadas) {
      if (lista.length == 4) break;
      if (nome != 'Outros' && nome != peloNome) lista.add(nome);
    }
    return lista;
  }

  Future<void> _aplicar(Movimento m, String categoria) async {
    try {
      await widget.repo.definirCategoria(m.transacao, categoria);
    } catch (e) {
      debugPrint('Finanças: não troquei a categoria ($e)');
      return;
    }
    if (!mounted) return;
    setState(() {
      _pendentes = [for (final x in _pendentes) if (x.transacao.id != m.transacao.id) x];
      if (_aberta == m.transacao.id) _aberta = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final quantos = _pendentes.length;
    return Folha(
      titulo: 'O que caiu em Outros',
      textoSalvar: 'Pronto',
      aoSalvar: () => Navigator.pop(context),
      campos: [
        if (quantos > 0)
          Text(
            '$quantos ${quantos == 1 ? 'lançamento' : 'lançamentos'} · ${reais(_totalCentavos)}. '
            'Toque na categoria certa: a Aurora já sugere pelo nome.',
            style: manrope(13, cor: c.muted, altura: 1.4),
          ),
        if (quantos == 0)
          Text(
            'Tudo categorizado. 🤍',
            style: manrope(14, peso: FontWeight.w600, cor: c.teal),
          ),
        for (final m in _pendentes) _linha(context, m),
      ],
    );
  }

  Widget _linha(BuildContext context, Movimento m) {
    final c = context.cores;
    final aberta = _aberta == m.transacao.id;
    final opcoes = aberta ? nomesCategorias(TipoCategoria.saida) : _sugestoes(m);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(
              child: Text(m.nome, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: manrope(14, peso: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            Text(reais(m.valorCentavos), style: manrope(14, peso: FontWeight.w700)),
          ]),
          const SizedBox(height: 2),
          Text(diaMesCurto(m.dia), style: manrope(12, cor: c.muted)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final nome in opcoes)
              OpcaoChip(
                texto: nome,
                selecionado: false,
                aoTocar: () => _aplicar(m, nome),
              ),
            OpcaoChip(
              texto: aberta ? 'Menos' : 'Outra…',
              selecionado: aberta,
              aoTocar: () => setState(() => _aberta = aberta ? null : m.transacao.id),
            ),
          ]),
        ],
      ),
    );
  }
}
