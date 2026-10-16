import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/metas_repo.dart';
import '../formulario.dart';

Future<void> abrirFormMeta(BuildContext context, {Meta? meta}) {
  final repo = MetasRepo(AuroraEscopo.de(context).db);
  return abrirFolha<void>(context, (_) => _FormMeta(repo: repo, meta: meta));
}

class _FormMeta extends StatefulWidget {
  const _FormMeta({required this.repo, required this.meta});
  final MetasRepo repo;
  final Meta? meta;

  @override
  State<_FormMeta> createState() => _FormMetaState();
}

class _FormMetaState extends State<_FormMeta> {
  late final TextEditingController _nome;
  late final TextEditingController _outra;
  late final TextEditingController _atual;
  late final TextEditingController _alvo;
  late String _unidade;
  DateTime? _data;
  String? _erro;
  final _hoje = hojeSP();

  bool get _outraUnidade => !unidadesMeta.contains(_unidade);
  String get _unidadeFinal => _outraUnidade ? _outra.text.trim() : _unidade;

  @override
  void initState() {
    super.initState();
    final m = widget.meta;
    _unidade = m == null ? unidadesMeta.first : m.unidade;
    _nome = TextEditingController(text: m?.nome ?? '');
    _outra = TextEditingController(text: _outraUnidade ? _unidade : '');
    _atual = TextEditingController(text: m == null ? '' : valorParaCampo(m.valorAtual, m.unidade));
    _alvo = TextEditingController(text: m == null ? '' : valorParaCampo(m.valorAlvo, m.unidade));
    _data = m?.dataAlvo == null ? null : dataSP(m!.dataAlvo!);
  }

  @override
  void dispose() {
    _nome.dispose();
    _outra.dispose();
    _atual.dispose();
    _alvo.dispose();
    super.dispose();
  }

  double? get _vAtual => lerValorMeta(_atual.text, _unidadeFinal);
  double? get _vAlvo => lerValorMeta(_alvo.text, _unidadeFinal);

  String get _previa {
    final atual = _vAtual, alvo = _vAlvo, data = _data;
    if (atual == null || alvo == null || data == null) {
      return 'Preencha os valores e a data para ver quanto você precisa avançar por semana.';
    }
    if (atual == alvo) return 'O alvo precisa ser diferente do valor de hoje.';
    return ritmoMeta(atual: atual, alvo: alvo, unidade: _unidadeFinal, dataAlvo: data, hoje: _hoje) ??
        'Escolha uma data depois de hoje.';
  }

  Future<void> _salvar() async {
    final nome = _nome.text.trim();
    final atual = _vAtual, alvo = _vAlvo;
    String? erro;
    if (nome.isEmpty) {
      erro = 'Dê um nome para a meta.';
    } else if (_outraUnidade && _unidadeFinal.isEmpty) {
      erro = 'Diga qual é a unidade (ex.: horas, cursos).';
    } else if (atual == null || alvo == null) {
      erro = 'Preencha onde você está hoje e aonde quer chegar.';
    } else if (atual == alvo && widget.meta == null) {
      erro = 'O alvo precisa ser diferente do valor de hoje.';
    } else if (_data != null && !_data!.isAfter(_hoje) && widget.meta == null) {
      erro = 'Escolha uma data depois de hoje.';
    }
    if (erro != null) {
      setState(() => _erro = erro);
      return;
    }
    final m = widget.meta;
    final dataAlvo = _data == null ? null : instanteSP(_data!);
    if (m == null) {
      await widget.repo.salvar(MetasCompanion.insert(
        nome: nome,
        valorInicial: atual!,
        valorAtual: atual,
        valorAlvo: alvo!,
        unidade: Value(_unidadeFinal),
        dataAlvo: Value(dataAlvo),
      ));
    } else {
      // Mudar a unidade de/para R$ muda a escala gravada do valor inicial.
      final inicial = ehDinheiro(m.unidade) == ehDinheiro(_unidadeFinal)
          ? m.valorInicial
          : (ehDinheiro(_unidadeFinal) ? m.valorInicial * 100 : m.valorInicial / 100);
      await widget.repo.salvar(
        MetasCompanion(
          nome: Value(nome),
          valorInicial: Value(inicial),
          valorAtual: Value(atual!),
          valorAlvo: Value(alvo!),
          unidade: Value(_unidadeFinal),
          dataAlvo: Value(dataAlvo),
          status: Value(m.status == 'concluida' && atual != alvo ? 'ativa' : m.status),
        ),
        id: m.id,
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
        title: Text('Excluir meta?', style: sora(18)),
        content: Text('“${widget.meta!.nome}” sai da lista. Tarefas e hábitos ligados continuam.',
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
    await widget.repo.excluir(widget.meta!.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final editando = widget.meta != null;
    Widget numeroCampo(String rotulo, TextEditingController controle) => Expanded(
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
      titulo: editando ? 'Editar meta' : 'Nova meta',
      textoSalvar: 'Salvar meta',
      aoSalvar: _salvar,
      aoExcluir: editando ? _excluir : null,
      campos: [
        Campo(
          rotulo: 'Nome da meta',
          child: CampoTexto(
            controle: _nome,
            dica: 'Ex.: Reserva de emergência',
            autofoco: !editando,
            aoMudar: (_) => setState(() => _erro = null),
          ),
        ),
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
        Campo(
          rotulo: 'Até quando',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OpcaoChip(
                texto: _data == null ? 'Escolher data' : diaMesLongo(_data!),
                selecionado: _data != null,
                aoTocar: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _data ?? DateTime(_hoje.year, 12, 31),
                    firstDate: _hoje,
                    lastDate: DateTime(_hoje.year + 10),
                    locale: const Locale('pt', 'BR'),
                  );
                  if (d != null) setState(() => _data = DateTime(d.year, d.month, d.day));
                },
              ),
              if (_data != null)
                OpcaoChip(texto: 'Sem prazo', selecionado: false, aoTocar: () => setState(() => _data = null)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: c.accentSoft, borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('RITMO NECESSÁRIO', style: rotulo(c.accent)),
              const SizedBox(height: 4),
              Text(_previa, style: manrope(14, altura: 1.5)),
            ],
          ),
        ),
        if (_erro != null) Text(_erro!, style: manrope(13, peso: FontWeight.w600, cor: c.bad)),
      ],
    );
  }
}
