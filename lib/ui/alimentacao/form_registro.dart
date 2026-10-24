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
      refeicao: refeicao ?? Refeicao.pelaHora(agoraLocal().hour),
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

  /// + e − nas unidades (meia unidade se descer de 1).
  void _passo(int delta) => setState(() {
        final q = lerNumero(_quantidade.text) ?? 0;
        final novo = delta > 0 ? q.floorToDouble() + 1 : (q > 1 ? q.ceilToDouble() - 1 : 0.5);
        _quantidade.text = numero(novo);
        _erro = null;
      });

  /// Cria ou ajusta a unidade do alimento ("1 maçã" = 150 g). Vale daqui para frente.
  Future<void> _ajustarUnidade(Alimento a) async {
    final c = context.cores;
    final nome = TextEditingController(text: a.porcaoNome ?? '1 unidade');
    final gramas = TextEditingController(text: a.porcaoGramas == null ? '' : numero(a.porcaoGramas!));
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text('Peso de uma unidade', style: sora(18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('${a.nome}. Se puder, pese uma vez; o Aurora usa esse peso daqui para frente.',
                style: manrope(13, cor: c.muted, altura: 1.4)),
            const SizedBox(height: 12),
            CampoTexto(controle: nome, dica: '1 unidade'),
            const SizedBox(height: 8),
            Row(children: [
              SizedBox(width: 100, child: CampoTexto(controle: gramas, dica: 'g', decimal: true, autofoco: true)),
              const SizedBox(width: 8),
              Text('gramas cada', style: manrope(13, cor: c.muted)),
            ]),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Salvar')),
        ],
      ),
    );
    final g = lerNumero(gramas.text);
    final n = nome.text.trim().isEmpty ? '1 unidade' : nome.text.trim();
    nome.dispose();
    gramas.dispose();
    if (ok != true || g == null || g <= 0) return;
    await widget.repo.definirPorcao(a.id, n, g);
    _alimentos = await widget.repo.listarAlimentos();
    final atualizado = _alimentos.where((x) => x.id == a.id).firstOrNull;
    if (atualizado == null || !mounted) return;
    setState(() {
      final jaEmUnidades = _emPorcoes;
      _escolhido = atualizado;
      _emPorcoes = true;
      // Já contando unidades: mantém o número; vindo de gramas: começa em 1.
      if (!jaEmUnidades) _quantidade.text = '1';
    });
  }

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
                  Text('Busque um alimento: os seus e os da TACO.',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (a.porcaoGramas != null) ...[
                  Segmentos<bool>(
                    opcoes: const [true, false],
                    selecionado: _emPorcoes,
                    rotulo: (p) => p ? 'Unidades' : 'Gramas',
                    aoEscolher: (p) => setState(() {
                      if (p == _emPorcoes) return;
                      // Troca mantendo a mesma quantidade comida.
                      final g = _gramas;
                      _emPorcoes = p;
                      _quantidade.text = p
                          ? numero(g == null ? 1 : ((g / a.porcaoGramas!) * 2).round() / 2)
                          : numero(g ?? a.porcaoGramas!);
                    }),
                  ),
                  const SizedBox(height: 10),
                ],
                Row(children: [
                  if (_emPorcoes)
                    IconButton.filledTonal(
                      tooltip: 'Uma a menos',
                      onPressed: () => _passo(-1),
                      icon: const Icon(Icons.remove_rounded),
                    ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: _emPorcoes ? 70 : 100,
                    child: CampoTexto(
                      controle: _quantidade,
                      dica: '0',
                      decimal: true,
                      aoMudar: (_) => setState(() => _erro = null),
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (_emPorcoes)
                    IconButton.filledTonal(
                      tooltip: 'Uma a mais',
                      onPressed: () => _passo(1),
                      icon: const Icon(Icons.add_rounded),
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _emPorcoes ? '× ${a.porcaoNome} (≈ ${numero(a.porcaoGramas!)} g cada)' : 'gramas',
                      style: manrope(13, cor: c.muted),
                    ),
                  ),
                ]),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => _ajustarUnidade(a),
                    icon: Icon(a.porcaoGramas == null ? Icons.tag_rounded : Icons.tune_rounded,
                        size: 18, color: c.accent),
                    label: Text(
                      a.porcaoGramas == null ? 'Contar por unidade' : 'Ajustar peso da unidade',
                      style: manrope(13, peso: FontWeight.w700, cor: c.accent),
                    ),
                  ),
                ),
              ],
            ),
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
