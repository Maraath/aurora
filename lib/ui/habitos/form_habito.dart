import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../core/recorrencia.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/habitos_repo.dart';
import '../formulario.dart';
import '../rotina/contexto_form.dart';
import '../rotina/form_rotina.dart';

/// Abre o formulário de novo hábito ou de edição de [habito] (a folha única da
/// Rotina, já no tipo hábito). Os objetivos e o aviso a folha lê sozinha.
Future<void> abrirFormHabito(BuildContext context,
        {Habito? habito, List<Objetivo> objetivos = const [], bool avisar = false}) =>
    abrirFormRotina(context, tipo: TipoRotina.habito, item: habito);

class FormHabito extends StatefulWidget {
  const FormHabito({
    super.key,
    required this.repo,
    required this.habito,
    required this.objetivos,
    required this.avisarInicial,
    this.contexto = const ContextoForm(),
  });

  final HabitosRepo repo;
  final Habito? habito;
  final List<Objetivo> objetivos;
  final bool avisarInicial;
  final ContextoForm contexto;

  @override
  State<FormHabito> createState() => _FormHabitoState();
}

class _FormHabitoState extends State<FormHabito> {
  late final TextEditingController _nome;
  late final TextEditingController _alvo;
  late final TextEditingController _unidade;
  late TipoHabito _tipo;
  late int _dias;
  TimeOfDay? _hora;
  String? _objetivoId;
  late bool _avisar;
  String? _erro;

  ContextoForm get _ctx => widget.contexto;

  @override
  void initState() {
    super.initState();
    final h = widget.habito;
    _nome = _ctx.titulo ?? TextEditingController(text: h?.nome ?? '');
    _tipo = h?.tipo ?? TipoHabito.marcar;
    _alvo = TextEditingController(text: '${h?.alvo ?? (_tipo == TipoHabito.quantidade ? 8 : 30)}');
    _unidade = TextEditingController(text: h?.unidade ?? '');
    _dias = h?.diasSemana ?? todosOsDias;
    if (h?.horario != null) {
      final p = h!.horario!.split(':');
      _hora = TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
    } else if (h == null) {
      _hora = _ctx.hora;
    }
    _objetivoId = h?.objetivoId;
    _avisar = widget.avisarInicial;
  }

  @override
  void dispose() {
    if (_ctx.titulo == null) _nome.dispose();
    _alvo.dispose();
    _unidade.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final nome = _nome.text.trim();
    if (nome.isEmpty) {
      setState(() => _erro = 'Dê um nome para o hábito.');
      return;
    }
    if (_dias == 0) {
      setState(() => _erro = 'Escolha pelo menos um dia.');
      return;
    }
    final alvo = int.tryParse(_alvo.text.trim());
    final dados = HabitosCompanion(
      nome: Value(nome),
      tipo: Value(_tipo),
      diasSemana: Value(_dias),
      horario: Value(_hora == null
          ? null
          : '${_hora!.hour.toString().padLeft(2, '0')}:${_hora!.minute.toString().padLeft(2, '0')}'),
      alvo: Value(_tipo == TipoHabito.marcar ? null : (alvo == null || alvo < 1 ? 1 : alvo)),
      unidade: Value(_tipo == TipoHabito.quantidade && _unidade.text.trim().isNotEmpty
          ? _unidade.text.trim()
          : null),
      objetivoId: Value(_objetivoId),
    );
    final id = await widget.repo.salvar(dados, id: widget.habito?.id, avisar: _avisar);
    await _ctx.aoSalvo?.call(id);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _excluir() async {
    final c = context.cores;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text('Excluir hábito?', style: sora(18)),
        content: Text('“${widget.habito!.nome}” sai da rotina.', style: manrope(14, cor: c.text)),
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
    await widget.repo.excluir(widget.habito!.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    Widget alvo(String sufixo, {bool comUnidade = false}) => Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              Text('Alvo por dia', style: manrope(13, cor: c.muted)),
              const SizedBox(width: 10),
              SizedBox(
                width: 80,
                child: CampoTexto(controle: _alvo, dica: '1', numerico: true),
              ),
              const SizedBox(width: 10),
              if (comUnidade)
                Expanded(child: CampoTexto(controle: _unidade, dica: 'copos, páginas…'))
              else
                Text(sufixo, style: manrope(13, cor: c.muted)),
            ],
          ),
        );

    return Folha(
      titulo: _ctx.tituloFolha ?? (widget.habito == null ? 'Novo hábito' : 'Editar hábito'),
      textoSalvar: 'Salvar hábito',
      aoSalvar: _salvar,
      aoExcluir: widget.habito == null ? null : _excluir,
      campos: [
        ?_ctx.cabecalho,
        Campo(
          rotulo: 'Qual hábito?',
          child: CampoTexto(
            controle: _nome,
            dica: 'Ex.: Beber água, Ler, Alongar',
            erro: _erro,
            autofoco: widget.habito == null,
            aoMudar: (_) => setState(() => _erro = null),
          ),
        ),
        Campo(
          rotulo: 'Como medir',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GradeChips(filhos: [
                for (final (t, texto, dica) in [
                  (TipoHabito.marcar, 'Marcar', 'feito ou não'),
                  (TipoHabito.duracao, 'Duração', 'minutos'),
                  (TipoHabito.quantidade, 'Quantidade', 'copos, páginas'),
                ])
                  OpcaoChip(
                    texto: texto,
                    dica: dica,
                    quadrado: true,
                    selecionado: _tipo == t,
                    aoTocar: () => setState(() => _tipo = t),
                  ),
              ]),
              if (_tipo == TipoHabito.duracao) alvo('minutos'),
              if (_tipo == TipoHabito.quantidade) alvo('', comUnidade: true),
            ],
          ),
        ),
        Campo(
          rotulo: 'Em quais dias',
          acao: Row(mainAxisSize: MainAxisSize.min, children: [
            TextButton(
              onPressed: () => setState(() => _dias = todosOsDias),
              child: Text('Todo dia', style: manrope(12, peso: FontWeight.w700, cor: c.accent)),
            ),
            TextButton(
              onPressed: () => setState(() => _dias = diasUteis),
              child: Text('Dias úteis', style: manrope(12, peso: FontWeight.w700, cor: c.accent)),
            ),
          ]),
          child: SeletorDias(dias: _dias, aoMudar: (d) => setState(() => _dias = d)),
        ),
        CampoHorario(
          rotulo: 'Horário (opcional)',
          valor: _hora,
          aoMudar: (h) => setState(() => _hora = h),
        ),
        if (widget.objetivos.isNotEmpty)
          Campo(
            rotulo: 'Ligar a um objetivo',
            child: GrupoChips<String?>(
              opcoes: [null, ...widget.objetivos.map((o) => o.id)],
              selecionado: _objetivoId,
              rotulo: (id) =>
                  id == null ? 'Nenhum' : widget.objetivos.firstWhere((o) => o.id == id).nome,
              aoEscolher: (id) => setState(() => _objetivoId = id),
            ),
          ),
        LinhaInterruptor(
          titulo: 'Me avisar',
          detalhe: 'lembrete nos dias escolhidos, no horário (ou às 08:00)',
          valor: _avisar,
          aoMudar: (v) => setState(() => _avisar = v),
        ),
      ],
    );
  }
}
