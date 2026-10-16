import 'package:drift/drift.dart' show BooleanExpressionOperators, Value;
import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/recorrencia.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/tarefas_repo.dart';
import '../formulario.dart';

/// Abre o formulário de nova tarefa ou de edição de [tarefa].
Future<void> abrirFormTarefa(BuildContext context,
    {Tarefa? tarefa, DateTime? dataInicial, String? projetoInicial}) async {
  final db = AuroraEscopo.de(context).db;
  final repo = TarefasRepo(db);
  final metas = await (db.select(db.metas)..where((m) => m.apagadoEm.isNull())).get();
  final projetos = await (db.select(db.projetos)
        ..where((p) => p.apagadoEm.isNull() & p.status.equals('ativo')))
      .get();
  final avisar = tarefa != null && await repo.temLembrete(tarefa.id);
  if (!context.mounted) return;
  await abrirFolha<void>(
    context,
    (_) => _FormTarefa(
      repo: repo,
      tarefa: tarefa,
      metas: metas,
      projetos: projetos,
      projetoInicial: projetoInicial,
      avisarInicial: avisar,
      dataInicial: dataInicial,
    ),
  );
}

class _FormTarefa extends StatefulWidget {
  const _FormTarefa({
    required this.repo,
    required this.tarefa,
    required this.metas,
    required this.projetos,
    this.projetoInicial,
    required this.avisarInicial,
    this.dataInicial,
  });

  final TarefasRepo repo;
  final Tarefa? tarefa;
  final List<Meta> metas;
  final List<Projeto> projetos;
  final String? projetoInicial;
  final bool avisarInicial;
  final DateTime? dataInicial;

  @override
  State<_FormTarefa> createState() => _FormTarefaState();
}

class _FormTarefaState extends State<_FormTarefa> {
  late final TextEditingController _titulo;
  late DateTime? _data;
  TimeOfDay? _hora;
  late Prioridade _prioridade;
  late OpcaoRepeticao _repetir;
  Regra? _regraAtual;
  String? _metaId;
  String? _projetoId;
  late bool _avisar;
  String? _erro;
  final _hoje = hojeSP();

  @override
  void initState() {
    super.initState();
    final t = widget.tarefa;
    _titulo = TextEditingController(text: t?.titulo ?? '');
    if (t?.prazo != null) {
      final p = emSP(t!.prazo!);
      _data = DateTime(p.year, p.month, p.day);
      if (t.prazoTemHora) _hora = TimeOfDay(hour: p.hour, minute: p.minute);
    } else {
      _data = t == null ? (widget.dataInicial ?? _hoje) : null;
    }
    _prioridade = t?.prioridade ?? Prioridade.media;
    _regraAtual = Regra.ler(t?.regraRepeticao);
    _repetir = OpcaoRepeticao.de(_regraAtual);
    _metaId = t?.metaId;
    _projetoId = t?.projetoId ?? widget.projetoInicial;
    _avisar = widget.avisarInicial;
  }

  @override
  void dispose() {
    _titulo.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final titulo = _titulo.text.trim();
    if (titulo.isEmpty) {
      setState(() => _erro = 'Dê um nome para a tarefa.');
      return;
    }
    // Repetir precisa de uma data de início.
    var data = _data;
    if (data == null && _repetir != OpcaoRepeticao.nao) data = _hoje;
    final regra = data == null ? null : _repetir.regra(data, _regraAtual);
    final dados = TarefasCompanion(
      titulo: Value(titulo),
      prazo: Value(data == null ? null : instanteSP(data, _hora?.hour ?? 0, _hora?.minute ?? 0)),
      prazoTemHora: Value(data != null && _hora != null),
      prioridade: Value(_prioridade),
      regraRepeticao: Value(regra?.rrule),
      metaId: Value(_metaId),
      projetoId: Value(_projetoId),
    );
    await widget.repo.salvar(dados, id: widget.tarefa?.id, avisar: _avisar && data != null);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _excluir() async {
    final c = context.cores;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text('Excluir tarefa?', style: sora(18)),
        content: Text(
          widget.tarefa!.regraRepeticao != null
              ? 'A tarefa e todas as repetições saem da lista.'
              : '“${widget.tarefa!.titulo}” sai da lista.',
          style: manrope(14, cor: c.text),
        ),
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
    await widget.repo.excluir(widget.tarefa!.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final opcoesRepetir = [
      ...OpcaoRepeticao.padrao,
      if (_repetir == OpcaoRepeticao.personalizada) OpcaoRepeticao.personalizada,
    ];
    return Folha(
      titulo: widget.tarefa == null ? 'Nova tarefa' : 'Editar tarefa',
      textoSalvar: 'Salvar tarefa',
      aoSalvar: _salvar,
      aoExcluir: widget.tarefa == null ? null : _excluir,
      campos: [
        Campo(
          rotulo: 'O que precisa ser feito?',
          child: CampoTexto(
            controle: _titulo,
            dica: 'Ex.: Renovar a matrícula',
            erro: _erro,
            autofoco: widget.tarefa == null,
            aoMudar: (_) => setState(() => _erro = null),
          ),
        ),
        Campo(
          rotulo: 'Quando',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EscolhaData(data: _data, hoje: _hoje, aoMudar: (d) => setState(() => _data = d)),
              if (_data != null) ...[
                const SizedBox(height: 10),
                CampoHorario(
                  rotulo: 'Horário (opcional)',
                  valor: _hora,
                  aoMudar: (h) => setState(() => _hora = h),
                ),
              ],
            ],
          ),
        ),
        Campo(
          rotulo: 'Prioridade',
          child: GradeChips(filhos: [
            for (final (p, texto, cor) in [
              (Prioridade.alta, 'Alta', c.bad),
              (Prioridade.media, 'Média', c.warn),
              (Prioridade.baixa, 'Baixa', c.muted),
            ])
              OpcaoChip(
                texto: texto,
                cor: cor,
                quadrado: true,
                selecionado: _prioridade == p,
                aoTocar: () => setState(() => _prioridade = p),
              ),
          ]),
        ),
        Campo(
          rotulo: 'Repetir',
          child: GrupoChips<OpcaoRepeticao>(
            opcoes: opcoesRepetir,
            selecionado: _repetir,
            rotulo: (o) => o == OpcaoRepeticao.personalizada
                ? (_regraAtual?.descricao ?? o.rotulo)
                : o.rotulo,
            aoEscolher: (o) => setState(() => _repetir = o),
          ),
        ),
        if (widget.metas.isNotEmpty)
          Campo(
            rotulo: 'Ligar a uma meta',
            child: GrupoChips<String?>(
              opcoes: [null, ...widget.metas.map((m) => m.id)],
              selecionado: _metaId,
              rotulo: (id) => id == null
                  ? 'Nenhuma'
                  : widget.metas.firstWhere((m) => m.id == id).nome,
              aoEscolher: (id) => setState(() => _metaId = id),
            ),
          ),
        if (widget.projetos.isNotEmpty)
          Campo(
            rotulo: 'Etapa de um projeto',
            child: GrupoChips<String?>(
              opcoes: [null, ...widget.projetos.map((p) => p.id)],
              selecionado: _projetoId,
              rotulo: (id) => id == null
                  ? 'Nenhum'
                  : widget.projetos.firstWhere((p) => p.id == id).nome,
              aoEscolher: (id) => setState(() => _projetoId = id),
            ),
          ),
        LinhaInterruptor(
          titulo: 'Me avisar',
          detalhe: _data == null && _repetir == OpcaoRepeticao.nao
              ? 'escolha uma data para ser avisado'
              : 'cria um lembrete no horário (ou às 09:00)',
          valor: _avisar,
          aoMudar: (v) => setState(() => _avisar = v),
        ),
      ],
    );
  }
}
