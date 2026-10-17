import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/comandos.dart' show normalizar;
import '../../core/formato.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/alimentacao_repo.dart';
import '../../data/banco.dart';
import '../../data/catalogo_taco.dart';
import '../componentes.dart';
import '../formulario.dart';
import 'form_alimento.dart';

/// Registrar o que comeu numa refeição do [dia].
Future<void> abrirFormRegistro(BuildContext context,
    {required DateTime dia, required List<Alimento> alimentos, Refeicao? refeicao}) {
  final repo = AlimentacaoRepo(AuroraEscopo.de(context).db);
  return abrirFolha<void>(
    context,
    (_) => _FormRegistro(
      repo: repo,
      dia: dia,
      alimentos: alimentos,
      refeicao: refeicao ?? Refeicao.pelaHora(agoraSP().hour),
    ),
  );
}

class _FormRegistro extends StatefulWidget {
  const _FormRegistro({required this.repo, required this.dia, required this.alimentos, required this.refeicao});
  final AlimentacaoRepo repo;
  final DateTime dia;
  final List<Alimento> alimentos;
  final Refeicao refeicao;

  @override
  State<_FormRegistro> createState() => _FormRegistroState();
}

class _FormRegistroState extends State<_FormRegistro> {
  final _busca = TextEditingController();
  final _quantidade = TextEditingController(text: '100');
  late List<Alimento> _alimentos = widget.alimentos;
  late Refeicao _refeicao = widget.refeicao;
  Alimento? _escolhido;
  bool _emPorcoes = false;
  String? _erro;
  CatalogoTaco? _taco;

  @override
  void initState() {
    super.initState();
    widget.repo.catalogo().then((c) {
      if (mounted) setState(() => _taco = c);
    });
  }

  /// Da TACO, sem repetir o que já está na lista da pessoa.
  List<ItemCatalogo> get _daTaco {
    final taco = _taco;
    if (taco == null || _busca.text.trim().length < 2) return const [];
    final meus = {for (final a in _alimentos) normalizar(a.nome)};
    return taco.buscar(_busca.text, limite: 12).where((i) => !meus.contains(normalizar(i.nome))).take(6).toList();
  }

  Future<void> _escolherDaTaco(ItemCatalogo item) async {
    final a = await widget.repo.doCatalogo(item);
    _alimentos = await widget.repo.listarAlimentos();
    if (mounted) _escolher(a);
  }

  @override
  void dispose() {
    _busca.dispose();
    _quantidade.dispose();
    super.dispose();
  }

  List<Alimento> get _filtrados {
    final b = normalizar(_busca.text.trim());
    if (b.isEmpty) return _alimentos.take(8).toList();
    return _alimentos.where((a) => normalizar(a.nome).contains(b)).take(8).toList();
  }

  double? get _gramas {
    final q = lerNumero(_quantidade.text);
    if (q == null || q <= 0) return null;
    final a = _escolhido;
    return _emPorcoes && a?.porcaoGramas != null ? q * a!.porcaoGramas! : q;
  }

  void _escolher(Alimento a) => setState(() {
        _escolhido = a;
        _erro = null;
        // Com porção caseira, começa contando "1 porção".
        _emPorcoes = a.porcaoGramas != null;
        _quantidade.text = _emPorcoes ? '1' : '100';
      });

  Future<void> _cadastrar() async {
    final id = await abrirFormAlimento(context, nomeInicial: _busca.text.trim());
    if (id == null) return;
    _alimentos = await widget.repo.listarAlimentos();
    final novo = _alimentos.where((a) => a.id == id).firstOrNull;
    if (novo != null && mounted) _escolher(novo);
  }

  Future<void> _salvar() async {
    final a = _escolhido;
    final g = _gramas;
    if (a == null) {
      setState(() => _erro = 'Escolha o alimento.');
      return;
    }
    if (g == null) {
      setState(() => _erro = 'Informe a quantidade.');
      return;
    }
    await widget.repo.registrar(dia: widget.dia, refeicao: _refeicao, alimento: a, gramas: g);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final a = _escolhido;
    final g = _gramas;
    final n = a == null || g == null ? null : Nutrientes.de(a, g);

    return Folha(
      titulo: 'O que você comeu?',
      textoSalvar: 'Registrar',
      aoSalvar: _salvar,
      campos: [
        Campo(
          rotulo: 'Refeição',
          child: GrupoChips<Refeicao>(
            opcoes: Refeicao.values,
            selecionado: _refeicao,
            rotulo: (r) => r.rotulo,
            aoEscolher: (r) => setState(() => _refeicao = r),
          ),
        ),
        if (a == null)
          Campo(
            rotulo: 'Alimento',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CampoTexto(
                  controle: _busca,
                  dica: 'Buscar nos seus alimentos',
                  autofoco: true,
                  aoMudar: (_) => setState(() => _erro = null),
                ),
                const SizedBox(height: 8),
                for (final x in _filtrados)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Cartao(
                      raio: 14,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      aoTocar: () => _escolher(x),
                      child: Row(children: [
                        Expanded(child: Text(x.nome, style: manrope(14, peso: FontWeight.w600))),
                        Text('${numero(x.kcal.roundToDouble())} kcal/100 g', style: manrope(12, cor: c.muted)),
                      ]),
                    ),
                  ),
                if (_daTaco.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('DA TACO', style: rotulo(c.accent)),
                  const SizedBox(height: 6),
                  for (final x in _daTaco)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Cartao(
                        raio: 14,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        aoTocar: () => _escolherDaTaco(x),
                        child: Row(children: [
                          Expanded(child: Text(x.nome, style: manrope(14))),
                          const SizedBox(width: 8),
                          Text('${numero(x.kcal)} kcal/100 g', style: manrope(12, cor: c.muted)),
                        ]),
                      ),
                    ),
                  Text(fonteTaco, style: manrope(11, cor: c.muted)),
                ],
                if (_alimentos.isEmpty && _busca.text.trim().isEmpty)
                  Text('Busque um alimento: os seus e os ${_taco?.itens.length ?? 591} da TACO.',
                      style: manrope(13, cor: c.muted)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _cadastrar,
                    icon: Icon(Icons.add_rounded, size: 18, color: c.accent),
                    label: Text(
                      _busca.text.trim().isEmpty ? 'Cadastrar alimento' : 'Cadastrar “${_busca.text.trim()}”',
                      style: manrope(13, peso: FontWeight.w700, cor: c.accent),
                    ),
                  ),
                ),
              ],
            ),
          )
        else ...[
          Cartao(
            raio: 14,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(children: [
              Expanded(child: Text(a.nome, style: manrope(15, peso: FontWeight.w700))),
              TextButton(
                onPressed: () => setState(() => _escolhido = null),
                child: Text('Trocar', style: manrope(13, peso: FontWeight.w700, cor: c.accent)),
              ),
            ]),
          ),
          Campo(
            rotulo: 'Quantidade',
            child: Row(children: [
              SizedBox(
                width: 100,
                child: CampoTexto(
                  controle: _quantidade,
                  dica: '0',
                  decimal: true,
                  aoMudar: (_) => setState(() => _erro = null),
                ),
              ),
              const SizedBox(width: 10),
              if (a.porcaoGramas != null)
                Expanded(
                  child: Segmentos<bool>(
                    opcoes: const [false, true],
                    selecionado: _emPorcoes,
                    rotulo: (p) => p ? '${a.porcaoNome} (${numero(a.porcaoGramas!)} g)' : 'gramas',
                    aoEscolher: (p) => setState(() {
                      _emPorcoes = p;
                      _quantidade.text = p ? '1' : numero(a.porcaoGramas!);
                    }),
                  ),
                )
              else
                Text('gramas', style: manrope(13, cor: c.muted)),
            ]),
          ),
          if (n != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: c.accentSoft, borderRadius: BorderRadius.circular(14)),
              child: Text(
                '${numero(n.kcal.roundToDouble())} kcal · P ${numero(_um(n.proteina))} g · '
                'C ${numero(_um(n.carboidrato))} g · G ${numero(_um(n.gordura))} g'
                '${_emPorcoes ? ' · ${numero(g!)} g' : ''}',
                style: manrope(14, peso: FontWeight.w700),
              ),
            ),
        ],
        if (_erro != null) Text(_erro!, style: manrope(13, peso: FontWeight.w600, cor: c.bad)),
      ],
    );
  }

  static double _um(double v) => (v * 10).roundToDouble() / 10;
}
