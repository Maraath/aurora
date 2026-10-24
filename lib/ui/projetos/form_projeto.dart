import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/projetos_repo.dart';
import '../formulario.dart';

Future<void> abrirFormProjeto(BuildContext context, {Projeto? projeto}) async {
  final db = AuroraEscopo.de(context).db;
  final metas = await (db.select(db.metas)..where((m) => m.apagadoEm.isNull())).get();
  if (!context.mounted) return;
  await abrirFolha<void>(
    context,
    (_) => _FormProjeto(repo: ProjetosRepo(db), projeto: projeto, metas: metas),
  );
}

class _FormProjeto extends StatefulWidget {
  const _FormProjeto({required this.repo, required this.projeto, required this.metas});
  final ProjetosRepo repo;
  final Projeto? projeto;
  final List<Meta> metas;

  @override
  State<_FormProjeto> createState() => _FormProjetoState();
}

class _FormProjetoState extends State<_FormProjeto> {
  final _hoje = hojeLocal();
  late final TextEditingController _nome;
  late DateTime _inicio;
  late DateTime _fim;
  String? _metaId;
  late bool _arquivado;
  final List<TextEditingController> _etapas = [];
  String? _erro;

  bool get _novo => widget.projeto == null;

  @override
  void initState() {
    super.initState();
    final p = widget.projeto;
    _nome = TextEditingController(text: p?.nome ?? '');
    _inicio = p == null ? _hoje : dataLocal(p.inicio);
    _fim = p == null ? somarDias(_hoje, 90) : dataLocal(p.fim);
    _metaId = p?.metaId;
    _arquivado = p?.status == 'arquivado';
    if (_novo) _etapas.addAll([TextEditingController(), TextEditingController()]);
  }

  @override
  void dispose() {
    _nome.dispose();
    for (final c in _etapas) {
      c.dispose();
    }
    super.dispose();
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
    if (nome.isEmpty) {
      setState(() => _erro = 'Dê um nome para o projeto.');
      return;
    }
    if (!_fim.isAfter(_inicio)) {
      setState(() => _erro = 'O fim precisa ser depois do início.');
      return;
    }
    final dados = ProjetosCompanion(
      nome: Value(nome),
      inicio: Value(instanteLocal(_inicio)),
      fim: Value(instanteLocal(_fim)),
      metaId: Value(_metaId),
      status: Value(_arquivado ? 'arquivado' : 'ativo'),
    );
    final id = await widget.repo.salvar(dados, id: widget.projeto?.id);
    for (final c in _etapas) {
      final t = c.text.trim();
      if (t.isNotEmpty) await widget.repo.novaEtapa(id, t);
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _excluir() async {
    final c = context.cores;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text('Excluir projeto?', style: sora(18)),
        content: Text('“${widget.projeto!.nome}” sai da lista. As etapas continuam como tarefas.',
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
    await widget.repo.excluir(widget.projeto!.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    Widget data(String rotulo, DateTime valor, ValueChanged<DateTime> aoMudar) => Expanded(
          child: Campo(
            rotulo: rotulo,
            child: OpcaoChip(
              texto: diaMesCurto(valor) + (valor.year != _hoje.year ? ' ${valor.year}' : ''),
              selecionado: true,
              aoTocar: () async {
                final d = await _escolherData(valor);
                if (d != null) setState(() => aoMudar(d));
              },
            ),
          ),
        );

    return Folha(
      titulo: _novo ? 'Novo projeto' : 'Editar projeto',
      textoSalvar: 'Salvar projeto',
      aoSalvar: _salvar,
      aoExcluir: _novo ? null : _excluir,
      campos: [
        Campo(
          rotulo: 'Nome do projeto',
          child: CampoTexto(
            controle: _nome,
            dica: 'Ex.: Estágio, Mudança, Shape 80kg',
            autofoco: _novo,
            aoMudar: (_) => setState(() => _erro = null),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            data('Começa', _inicio, (d) => _inicio = d),
            const SizedBox(width: 10),
            data('Termina', _fim, (d) => _fim = d),
          ],
        ),
        Text('${diasEntre(_inicio, _fim)} dias de projeto.', style: manrope(12, cor: c.muted)),
        if (widget.metas.isNotEmpty)
          Campo(
            rotulo: 'Ligar a uma meta',
            child: GrupoChips<String?>(
              opcoes: [null, ...widget.metas.map((m) => m.id)],
              selecionado: _metaId,
              rotulo: (id) => id == null ? 'Nenhuma' : widget.metas.firstWhere((m) => m.id == id).nome,
              aoEscolher: (id) => setState(() => _metaId = id),
            ),
          ),
        if (_novo)
          Campo(
            rotulo: 'Primeiras etapas (viram tarefas)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < _etapas.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: CampoTexto(controle: _etapas[i], dica: i == 0 ? 'Ex.: Pesquisar vagas' : 'Outra etapa'),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => setState(() => _etapas.add(TextEditingController())),
                    icon: Icon(Icons.add_rounded, size: 18, color: c.accent),
                    label: Text('Etapa', style: manrope(13, peso: FontWeight.w700, cor: c.accent)),
                  ),
                ),
              ],
            ),
          )
        else
          LinhaInterruptor(
            titulo: 'Arquivado',
            detalhe: 'sai da linha do tempo, mas continua salvo',
            valor: _arquivado,
            aoMudar: (v) => setState(() => _arquivado = v),
          ),
        if (_erro != null) Text(_erro!, style: manrope(13, peso: FontWeight.w600, cor: c.bad)),
      ],
    );
  }
}
