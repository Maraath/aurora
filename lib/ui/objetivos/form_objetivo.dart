import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/objetivos_repo.dart';
import '../formulario.dart';

Future<void> abrirFormObjetivo(BuildContext context, {Objetivo? objetivo}) {
  final repo = ObjetivosRepo(AuroraEscopo.de(context).db);
  return abrirFolha<void>(
    context,
    (_) => _FormObjetivo(repo: repo, objetivo: objetivo),
  );
}

class _FormObjetivo extends StatefulWidget {
  const _FormObjetivo({required this.repo, required this.objetivo});
  final ObjetivosRepo repo;
  final Objetivo? objetivo;

  @override
  State<_FormObjetivo> createState() => _FormObjetivoState();
}

class _FormObjetivoState extends State<_FormObjetivo> {
  late final TextEditingController _nome;
  late final TextEditingController _descricao;
  late final TextEditingController _outra;
  late final TextEditingController _atual;
  late final TextEditingController _alvo;
  late String _medir; // 'numero' | 'etapas' | 'ambos'
  late String _unidade;
  DateTime? _inicio;
  DateTime? _data;
  late String _cor;
  final List<TextEditingController> _etapas = [];
  String? _erro;
  final _hoje = hojeLocal();

  bool get _novo => widget.objetivo == null;
  bool get _temNumero => _medir == 'numero' || _medir == 'ambos';
  bool get _temEtapas => _medir == 'etapas' || _medir == 'ambos';
  bool get _outraUnidade => !unidadesMeta.contains(_unidade);
  String get _unidadeFinal => _outraUnidade ? _outra.text.trim() : _unidade;

  @override
  void initState() {
    super.initState();
    final o = widget.objetivo;
    _nome = TextEditingController(text: o?.nome ?? '');
    _descricao = TextEditingController(text: o?.descricao ?? '');
    _unidade = o == null
        ? unidadesMeta.first
        : (o.unidade.isEmpty ? unidadesMeta.first : o.unidade);
    _outra = TextEditingController(text: _outraUnidade ? _unidade : '');
    _medir = o == null ? 'numero' : (o.unidade.isEmpty ? 'etapas' : 'ambos');
    _atual = TextEditingController(
      text: o == null ? '' : valorParaCampo(o.valorAtual, o.unidade),
    );
    _alvo = TextEditingController(
      text: o == null ? '' : valorParaCampo(o.valorAlvo, o.unidade),
    );
    _inicio = o?.inicio == null ? null : dataLocal(o!.inicio!);
    _data = o?.dataAlvo == null ? null : dataLocal(o!.dataAlvo!);
    _cor = o?.cor ?? coresObjetivo.first;
    if (_novo)
      _etapas.addAll([TextEditingController(), TextEditingController()]);
  }

  @override
  void dispose() {
    _nome.dispose();
    _descricao.dispose();
    _outra.dispose();
    _atual.dispose();
    _alvo.dispose();
    for (final c in _etapas) {
      c.dispose();
    }
    super.dispose();
  }

  double? get _vAtual => lerValorMeta(_atual.text, _unidadeFinal);
  double? get _vAlvo => lerValorMeta(_alvo.text, _unidadeFinal);

  String get _previa {
    final atual = _vAtual, alvo = _vAlvo, data = _data;
    if (!_temNumero) return 'Etapas concluídas marcam o progresso.';
    if (atual == null || alvo == null || data == null) {
      return 'Preencha os valores e a data para ver quanto você precisa avançar por semana.';
    }
    if (atual == alvo) return 'O alvo precisa ser diferente do valor de hoje.';
    return ritmoMeta(
          atual: atual,
          alvo: alvo,
          unidade: _unidadeFinal,
          dataAlvo: data,
          hoje: _hoje,
        ) ??
        'Escolha uma data depois de hoje.';
  }

  Future<DateTime?> _escolherData(DateTime atual) async {
    final d = await showDatePicker(
      context: context,
      initialDate: atual,
      firstDate: DateTime(_hoje.year - 2),
      lastDate: DateTime(_hoje.year + 10),
      locale: const Locale('pt', 'BR'),
    );
    return d == null ? null : DateTime(d.year, d.month, d.day);
  }

  Future<void> _salvar() async {
    final nome = _nome.text.trim();
    final atual = _vAtual, alvo = _vAlvo;
    String? erro;
    if (nome.isEmpty) {
      erro = 'Dê um nome para o objetivo.';
    } else if (_temNumero && _outraUnidade && _unidadeFinal.isEmpty) {
      erro = 'Diga qual é a unidade (ex.: horas, cursos).';
    } else if (_temNumero && (atual == null || alvo == null)) {
      erro = 'Preencha onde você está hoje e aonde quer chegar.';
    } else if (_temNumero && atual == alvo && _novo) {
      erro = 'O alvo precisa ser diferente do valor de hoje.';
    } else if (_data != null && !_data!.isAfter(_hoje) && _novo) {
      erro = 'Escolha uma data depois de hoje.';
    }
    if (erro != null) {
      setState(() => _erro = erro);
      return;
    }

    final unidade = _temNumero ? _unidadeFinal : '';
    final vInicial = _temNumero ? (atual ?? 0.0) : 0.0;
    final vAtual = _temNumero ? (atual ?? 0.0) : 0.0;
    final vAlvo = _temNumero ? (alvo ?? 0.0) : 0.0;
    final dados = ObjetivosCompanion.insert(
      nome: nome,
      descricao: Value(
        _descricao.text.trim().isEmpty ? null : _descricao.text.trim(),
      ),
      unidade: Value(unidade),
      valorInicial: Value(vInicial),
      valorAtual: Value(vAtual),
      valorAlvo: Value(vAlvo),
      dataAlvo: Value(_data == null ? null : instanteLocal(_data!)),
      inicio: Value(_inicio == null ? null : instanteLocal(_inicio!)),
      cor: Value(_cor),
    );
    if (_novo) {
      final id = await widget.repo.salvar(dados);
      for (final c in _etapas) {
        final t = c.text.trim();
        if (t.isNotEmpty) await widget.repo.novaEtapa(id, t);
      }
    } else {
      final o = widget.objetivo!;
      // Mudar a unidade de/para R$ muda a escala gravada do valor inicial.
      final inicial = ehDinheiro(o.unidade) == ehDinheiro(unidade)
          ? o.valorInicial
          : (ehDinheiro(unidade) ? o.valorInicial * 100 : o.valorInicial / 100);
      await widget.repo.salvar(
        ObjetivosCompanion(
          nome: Value(nome),
          descricao: Value(
            _descricao.text.trim().isEmpty ? null : _descricao.text.trim(),
          ),
          unidade: Value(unidade),
          valorInicial: Value(_temNumero ? inicial : 0.0),
          valorAtual: Value(_temNumero ? (atual ?? 0.0) : 0.0),
          valorAlvo: Value(_temNumero ? (alvo ?? 0.0) : 0.0),
          dataAlvo: Value(_data == null ? null : instanteLocal(_data!)),
          inicio: Value(_inicio == null ? null : instanteLocal(_inicio!)),
          cor: Value(_cor),
          status: Value(
            o.status == 'concluida' && _temNumero && atual != alvo
                ? 'ativa'
                : o.status,
          ),
        ),
        id: o.id,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _excluir() async {
    final c = context.cores;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text('Excluir objetivo?', style: sora(18)),
        content: Text(
          '“${widget.objetivo!.nome}” sai da lista. Tarefas e hábitos ligados continuam.',
          style: manrope(14, cor: c.text, altura: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Excluir', style: TextStyle(color: c.bad)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await widget.repo.excluir(widget.objetivo!.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    Widget numeroCampo(String rotulo, TextEditingController controle) =>
        Expanded(
          child: Campo(
            rotulo: rotulo,
            child: CampoTexto(
              controle: controle,
              dica: '0',
              decimal: true,
              aoMudar: (_) => setState(() => _erro = null),
            ),
          ),
        );

    return Folha(
      titulo: _novo ? 'Novo objetivo' : 'Editar objetivo',
      textoSalvar: 'Salvar objetivo',
      aoSalvar: _salvar,
      aoExcluir: _novo ? null : _excluir,
      campos: [
        Campo(
          rotulo: 'Nome',
          child: CampoTexto(
            controle: _nome,
            dica: 'Ex.: Shape 80kg, Reserva de emergência',
            autofoco: _novo,
            aoMudar: (_) => setState(() => _erro = null),
          ),
        ),
        Campo(
          rotulo: 'Descrição (opcional)',
          child: CampoTexto(
            controle: _descricao,
            dica: 'O porquê deste objetivo',
            aoMudar: (_) => setState(() => _erro = null),
          ),
        ),
        Campo(
          rotulo: 'Como medir o progresso?',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (v, t, d) in [
                ('numero', 'Número', 'um valor que avança'),
                ('etapas', 'Etapas', 'uma lista de passos'),
                ('ambos', 'Ambos', 'valor e etapas'),
              ])
                OpcaoChip(
                  texto: t,
                  dica: d,
                  selecionado: _medir == v,
                  aoTocar: () => setState(() => _medir = v),
                ),
            ],
          ),
        ),
        if (_temNumero) ...[
          Campo(
            rotulo: 'Medida',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final u in unidadesMeta)
                      OpcaoChip(
                        texto: u,
                        selecionado: _unidade == u,
                        aoTocar: () => setState(() => _unidade = u),
                      ),
                    OpcaoChip(
                      texto: 'Outra',
                      selecionado: _outraUnidade,
                      aoTocar: () => setState(() => _unidade = ''),
                    ),
                  ],
                ),
                if (_outraUnidade) ...[
                  const SizedBox(height: 8),
                  CampoTexto(
                    controle: _outra,
                    dica: 'Qual unidade? Ex.: horas, cursos',
                    aoMudar: (_) => setState(() => _erro = null),
                  ),
                ],
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              numeroCampo('Hoje estou em', _atual),
              const SizedBox(width: 10),
              numeroCampo('Quero chegar em', _alvo),
            ],
          ),
        ],
        if (_temEtapas && _novo)
          Campo(
            rotulo: 'Primeiras etapas do projeto',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < _etapas.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: CampoTexto(
                      controle: _etapas[i],
                      dica: i == 0 ? 'Ex.: Pesquisar vagas' : 'Outra etapa',
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () =>
                        setState(() => _etapas.add(TextEditingController())),
                    icon: Icon(Icons.add_rounded, size: 18, color: c.accent),
                    label: Text(
                      'Etapa',
                      style: manrope(13, peso: FontWeight.w700, cor: c.accent),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Campo(
                rotulo: 'Começa',
                child: OpcaoChip(
                  texto: _inicio == null
                      ? 'Hoje'
                      : diaMesCurto(_inicio!) +
                            (_inicio!.year != _hoje.year
                                ? ' ${_inicio!.year}'
                                : ''),
                  selecionado: _inicio != null,
                  aoTocar: () async {
                    final d = await _escolherData(_inicio ?? _hoje);
                    if (d != null) setState(() => _inicio = d);
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Campo(
                rotulo: 'Até quando',
                child: OpcaoChip(
                  texto: _data == null
                      ? 'Sem prazo'
                      : diaMesCurto(_data!) +
                            (_data!.year != _hoje.year
                                ? ' ${_data!.year}'
                                : ''),
                  selecionado: _data != null,
                  aoTocar: () async {
                    final d = await _escolherData(
                      _data ?? DateTime(_hoje.year, 12, 31),
                    );
                    if (d != null) setState(() => _data = d);
                  },
                ),
              ),
            ),
          ],
        ),
        if (_temNumero)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.accentSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('RITMO NECESSÁRIO', style: rotulo(c.accent)),
                const SizedBox(height: 4),
                Text(_previa, style: manrope(14, altura: 1.5)),
              ],
            ),
          ),
        Campo(
          rotulo: 'Cor',
          child: Row(
            children: [
              for (final cor in coresObjetivo)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => setState(() => _cor = cor),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: switch (cor) {
                          'teal' => c.teal,
                          'violeta' => c.violeta,
                          'warn' => c.warn,
                          _ => c.accent,
                        },
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _cor == cor ? c.text : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_erro != null)
          Text(
            _erro!,
            style: manrope(13, peso: FontWeight.w600, cor: c.bad),
          ),
      ],
    );
  }
}
