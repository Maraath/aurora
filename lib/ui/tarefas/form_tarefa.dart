import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/tarefas_repo.dart';
import '../formulario.dart';
import '../rotina/contexto_form.dart';
import '../rotina/form_rotina.dart';

/// Abre o formulário de nova tarefa ou de edição de [tarefa] (a folha única da
/// Rotina, já no tipo tarefa). Etapa de projeto não troca de tipo.
Future<void> abrirFormTarefa(BuildContext context,
        {Tarefa? tarefa, DateTime? dataInicial, String? projetoInicial}) =>
    abrirFormRotina(
      context,
      tipo: TipoRotina.tarefa,
      item: tarefa,
      dia: dataInicial,
      projetoInicial: projetoInicial,
      trocarTipo: projetoInicial == null,
    );

class FormTarefa extends StatefulWidget {
  const FormTarefa({
    super.key,
    required this.repo,
    required this.tarefa,
    required this.metas,
    required this.projetos,
    this.projetoInicial,
    required this.avisarInicial,
    this.contexto = const ContextoForm(),
  });

  final TarefasRepo repo;
  final Tarefa? tarefa;
  final List<Meta> metas;
  final List<Projeto> projetos;
  final String? projetoInicial;
  final bool avisarInicial;
  final ContextoForm contexto;

  @override
  State<FormTarefa> createState() => _FormTarefaState();
}

class _FormTarefaState extends State<FormTarefa> {
  late final TextEditingController _titulo;
  late DateTime? _data;
  TimeOfDay? _hora;
  String? _metaId;
  String? _projetoId;
  late bool _avisar;
  String? _erro;
  final _hoje = hojeLocal();

  ContextoForm get _ctx => widget.contexto;

  @override
  void initState() {
    super.initState();
    final t = widget.tarefa;
    _titulo = _ctx.titulo ?? TextEditingController(text: t?.titulo ?? '');
    if (t?.prazo != null) {
      final p = emLocal(t!.prazo!);
      _data = DateTime(p.year, p.month, p.day);
      if (t.prazoTemHora) _hora = TimeOfDay(hour: p.hour, minute: p.minute);
    } else {
      _data = t == null ? (_ctx.data ?? _hoje) : null;
      if (t == null) _hora = _ctx.hora;
    }
    _metaId = t?.metaId;
    _projetoId = t?.projetoId ?? widget.projetoInicial;
    _avisar = widget.avisarInicial;
  }

  @override
  void dispose() {
    if (_ctx.titulo == null) _titulo.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final titulo = _titulo.text.trim();
    if (titulo.isEmpty) {
      setState(() => _erro = 'Dê um nome para a tarefa.');
      return;
    }
    // Tarefa não repete (o que repete é hábito ou lembrete); a prioridade saiu
    // da tela e fica como está no banco.
    final data = _data;
    final dados = TarefasCompanion(
      titulo: Value(titulo),
      prazo: Value(data == null ? null : instanteLocal(data, _hora?.hour ?? 0, _hora?.minute ?? 0)),
      prazoTemHora: Value(data != null && _hora != null),
      metaId: Value(_metaId),
      projetoId: Value(_projetoId),
    );
    final id = await widget.repo.salvar(dados, id: widget.tarefa?.id, avisar: _avisar && data != null);
    await _ctx.aoSalvo?.call(id);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _excluir() async {
    final c = context.cores;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text('Excluir tarefa?', style: sora(18)),
        content: Text('“${widget.tarefa!.titulo}” sai da lista.', style: manrope(14, cor: c.text)),
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
    return Folha(
      titulo: _ctx.tituloFolha ?? (widget.tarefa == null ? 'Nova tarefa' : 'Editar tarefa'),
      textoSalvar: 'Salvar tarefa',
      aoSalvar: _salvar,
      aoExcluir: widget.tarefa == null ? null : _excluir,
      campos: [
        ?_ctx.cabecalho,
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EscolhaData(
                data: _data,
                hoje: _hoje,
                marcado: _ctx.marcado,
                aoMudar: (d) => setState(() => _data = d),
              ),
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
          detalhe: _data == null
              ? 'escolha uma data para ser avisado'
              : 'cria um lembrete no horário (ou às 09:00)',
          valor: _avisar,
          aoMudar: (v) => setState(() => _avisar = v),
        ),
      ],
    );
  }
}
