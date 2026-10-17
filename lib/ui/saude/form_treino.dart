import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/saude_repo.dart';
import '../formulario.dart';
import 'biblioteca_ui.dart';

Future<void> abrirFormTreino(BuildContext context, {TreinoCompleto? treino}) {
  final repo = SaudeRepo(AuroraEscopo.de(context).db);
  return abrirFolha<void>(context, (_) => _FormTreino(repo: repo, treino: treino));
}

class _Linha {
  _Linha({String nome = '', int series = 3, int reps = 10, double? carga})
      : nome = TextEditingController(text: nome),
        series = TextEditingController(text: '$series'),
        reps = TextEditingController(text: '$reps'),
        carga = TextEditingController(text: carga == null ? '' : numero(carga));
  final TextEditingController nome;
  final TextEditingController series;
  final TextEditingController reps;
  final TextEditingController carga;

  /// Da biblioteca: arquivo da animação e grupo (vale enquanto o nome não mudar).
  String? midia;
  String? grupo;
  String? nomeDaBiblioteca;

  String? get midiaValida => nome.text.trim() == nomeDaBiblioteca ? midia : null;

  void dispose() {
    nome.dispose();
    series.dispose();
    reps.dispose();
    carga.dispose();
  }
}

class _FormTreino extends StatefulWidget {
  const _FormTreino({required this.repo, required this.treino});
  final SaudeRepo repo;
  final TreinoCompleto? treino;

  @override
  State<_FormTreino> createState() => _FormTreinoState();
}

class _FormTreinoState extends State<_FormTreino> {
  late final TextEditingController _nome;
  late final TextEditingController _foco;
  late int _dias;
  late final List<_Linha> _linhas;
  String? _erro;

  @override
  void initState() {
    super.initState();
    final t = widget.treino;
    _nome = TextEditingController(text: t?.treino.nome ?? '');
    _foco = TextEditingController(text: t?.treino.foco ?? '');
    _dias = t?.treino.diasSemana ?? 0;
    _linhas = t == null
        ? [_Linha()]
        : [
            for (final e in t.exercicios)
              _Linha(
                nome: e.exercicio.nome,
                series: e.item.series,
                reps: e.item.repeticoes,
                carga: e.item.cargaInicial,
              )
                ..midia = e.exercicio.midia
                ..grupo = e.exercicio.grupo
                ..nomeDaBiblioteca = e.exercicio.nome,
          ];
  }

  @override
  void dispose() {
    _nome.dispose();
    _foco.dispose();
    for (final l in _linhas) {
      l.dispose();
    }
    super.dispose();
  }

  Future<void> _salvar() async {
    final nome = _nome.text.trim();
    if (nome.isEmpty) {
      setState(() => _erro = 'Dê um nome para o treino (ex.: Treino A).');
      return;
    }
    final itens = [
      for (final l in _linhas)
        if (l.nome.text.trim().isNotEmpty)
          (
            nome: l.nome.text.trim(),
            series: (int.tryParse(l.series.text.trim()) ?? 3).clamp(1, 20),
            repeticoes: (int.tryParse(l.reps.text.trim()) ?? 10).clamp(1, 100),
            cargaInicial: lerNumero(l.carga.text),
          ),
    ];
    if (itens.isEmpty) {
      setState(() => _erro = 'Adicione pelo menos um exercício.');
      return;
    }
    await widget.repo.salvarTreino(
      TreinosCompanion(
        nome: Value(nome),
        foco: Value(_foco.text.trim().isEmpty ? null : _foco.text.trim()),
        diasSemana: Value(_dias),
      ),
      itens,
      id: widget.treino?.treino.id,
      biblioteca: {
        for (final l in _linhas)
          if (l.midiaValida != null) l.nome.text.trim().toLowerCase(): (l.midiaValida!, l.grupo ?? ''),
      },
    );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _daBiblioteca(_Linha l) async {
    final e = await escolherDaBiblioteca(context, busca: l.nome.text.trim());
    if (e == null || !mounted) return;
    setState(() {
      l.nome.text = e.nome;
      l.midia = e.arquivo;
      l.grupo = e.grupo;
      l.nomeDaBiblioteca = e.nome;
    });
  }

  Future<void> _excluir() async {
    final c = context.cores;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text('Excluir treino?', style: sora(18)),
        content: Text('“${widget.treino!.titulo}” sai da ficha. O histórico de cargas continua.',
            style: manrope(14, cor: c.text, altura: 1.4)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Excluir', style: TextStyle(color: c.bad)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await widget.repo.excluirTreino(widget.treino!.treino.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Folha(
      titulo: widget.treino == null ? 'Novo treino' : 'Editar treino',
      textoSalvar: 'Salvar treino',
      aoSalvar: _salvar,
      aoExcluir: widget.treino == null ? null : _excluir,
      campos: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Campo(
                rotulo: 'Nome',
                child: CampoTexto(
                  controle: _nome,
                  dica: 'Treino A',
                  autofoco: widget.treino == null,
                  aoMudar: (_) => setState(() => _erro = null),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: Campo(rotulo: 'Foco', child: CampoTexto(controle: _foco, dica: 'Peito e tríceps')),
            ),
          ],
        ),
        Campo(
          rotulo: 'Em quais dias',
          acao: TextButton(
            onPressed: () => setState(() => _dias = 0),
            child: Text('Sem dia fixo', style: manrope(12, peso: FontWeight.w700, cor: c.accent)),
          ),
          child: SeletorDias(dias: _dias, aoMudar: (d) => setState(() => _dias = d)),
        ),
        Campo(
          rotulo: 'Exercícios',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < _linhas.length; i++) _exercicio(c, i),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _linhas.add(_Linha())),
                  icon: Icon(Icons.add_rounded, size: 18, color: c.accent),
                  label: Text('Exercício', style: manrope(13, peso: FontWeight.w700, cor: c.accent)),
                ),
              ),
            ],
          ),
        ),
        Text('A carga inicial só vale até o primeiro treino; depois o Aurora sugere pelo histórico.',
            style: manrope(12, cor: c.muted, altura: 1.4)),
        if (_erro != null) Text(_erro!, style: manrope(13, peso: FontWeight.w600, cor: c.bad)),
      ],
    );
  }

  Widget _exercicio(AuroraCores c, int i) {
    final l = _linhas[i];
    Widget pequeno(TextEditingController controle, String dica, String sufixo, {bool decimal = false}) =>
        Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: 60,
            child: CampoTexto(controle: controle, dica: dica, numerico: !decimal, decimal: decimal),
          ),
          const SizedBox(width: 4),
          Text(sufixo, style: manrope(12, cor: c.muted)),
        ]);

    return Container(
      key: ObjectKey(l),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
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
              child: CampoTexto(
                controle: l.nome,
                dica: 'Ex.: Supino reto',
                aoMudar: (_) => setState(() {}),
              ),
            ),
            IconButton(
              tooltip: 'Escolher da biblioteca',
              onPressed: () => _daBiblioteca(l),
              icon: Icon(
                l.midiaValida != null ? Icons.play_circle_rounded : Icons.video_library_outlined,
                color: l.midiaValida != null ? c.teal : c.accent,
              ),
            ),
            IconButton(
              tooltip: 'Tirar exercício',
              onPressed: _linhas.length == 1
                  ? null
                  : () {
                      final removida = _linhas[i];
                      setState(() => _linhas.removeAt(i));
                      WidgetsBinding.instance.addPostFrameCallback((_) => removida.dispose());
                    },
              icon: Icon(Icons.close_rounded, color: c.muted),
            ),
          ]),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              pequeno(l.series, '3', 'séries'),
              pequeno(l.reps, '10', 'reps'),
              pequeno(l.carga, '0', 'kg no início', decimal: true),
            ],
          ),
        ],
      ),
    );
  }
}
