import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../core/notificacoes.dart';
import '../../core/recorrencia.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/lembretes_repo.dart';
import '../formulario.dart';
import '../rotina/contexto_form.dart';
import '../rotina/form_rotina.dart';

/// Abre o formulário de novo lembrete ou de edição de [lembrete] (a folha única
/// da Rotina, já no tipo lembrete). Lembrete criado por tarefa ou hábito não
/// troca de tipo: ele segue o item.
Future<void> abrirFormLembrete(BuildContext context, {Lembrete? lembrete}) => abrirFormRotina(
      context,
      tipo: TipoRotina.lembrete,
      item: lembrete,
      trocarTipo: lembrete?.itemTipo == null,
    );

class FormLembrete extends StatefulWidget {
  const FormLembrete({
    super.key,
    required this.repo,
    required this.lembrete,
    this.contexto = const ContextoForm(),
  });
  final LembretesRepo repo;
  final Lembrete? lembrete;
  final ContextoForm contexto;

  @override
  State<FormLembrete> createState() => _FormLembreteState();
}

class _FormLembreteState extends State<FormLembrete> {
  late final TextEditingController _texto;
  late DateTime? _data;
  late TimeOfDay? _hora;
  late OpcaoRepeticao _repetir;
  late bool _despertar;
  Regra? _regraAtual;
  String? _erro;
  final _hoje = hojeLocal();

  ContextoForm get _ctx => widget.contexto;
  bool get _ligadoAItem => widget.lembrete?.itemTipo != null;

  @override
  void initState() {
    super.initState();
    final l = widget.lembrete;
    _texto = _ctx.titulo ?? TextEditingController(text: l?.texto ?? '');
    if (l != null) {
      final q = emLocal(l.quando);
      _data = DateTime(q.year, q.month, q.day);
      _hora = TimeOfDay(hour: q.hour, minute: q.minute);
    } else {
      final data = _ctx.data;
      _data = data == null || data.isBefore(_hoje) ? _hoje : data;
      final agora = agoraLocal();
      _hora = _ctx.hora ?? TimeOfDay(hour: (agora.hour + 1) % 24, minute: 0);
    }
    _regraAtual = Regra.ler(l?.regraRepeticao);
    _repetir = OpcaoRepeticao.de(_regraAtual);
    _despertar = l?.despertar ?? false;
  }

  Future<void> _mudarDespertar(bool v) async {
    setState(() => _despertar = v);
    // Android 14+: tela cheia por cima do bloqueio precisa ser liberada à mão.
    if (v) await Notificador.instancia.pedirPermissoesDespertador();
  }

  @override
  void dispose() {
    if (_ctx.titulo == null) _texto.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final texto = _texto.text.trim();
    if (texto.isEmpty) {
      setState(() => _erro = 'Escreva do que lembrar.');
      return;
    }
    final data = _data ?? _hoje;
    final hora = _hora ?? const TimeOfDay(hour: 9, minute: 0);
    final quando = instanteLocal(data, hora.hour, hora.minute);
    final regra = _repetir.regra(data, _regraAtual);
    if (regra == null && !quando.isAfter(agoraLocal())) {
      setState(() => _erro = 'Esse horário já passou. Escolha outro ou repita.');
      return;
    }
    final id = await widget.repo.salvar(
      LembretesCompanion(
        texto: Value(texto),
        quando: Value(quando),
        regraRepeticao: Value(regra?.rrule),
        ativo: const Value(true),
        despertar: Value(_despertar),
      ),
      id: widget.lembrete?.id,
    );
    await _ctx.aoSalvo?.call(id);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _excluir() async {
    await widget.repo.excluir(widget.lembrete!.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final opcoes = [
      ...OpcaoRepeticao.padrao,
      OpcaoRepeticao.todoAno,
      if (_repetir == OpcaoRepeticao.personalizada) OpcaoRepeticao.personalizada,
    ];
    return Folha(
      titulo: _ctx.tituloFolha ?? (widget.lembrete == null ? 'Novo lembrete' : 'Editar lembrete'),
      textoSalvar: 'Salvar lembrete',
      aoSalvar: _salvar,
      aoExcluir: widget.lembrete == null ? null : _excluir,
      campos: [
        ?_ctx.cabecalho,
        if (_ligadoAItem)
          Text(
            'Este lembrete foi criado por ${widget.lembrete!.itemTipo == 'habito' ? 'um hábito' : 'uma tarefa'}. '
            'Mudar o item também muda o lembrete.',
            style: manrope(12, cor: c.muted, altura: 1.5),
          ),
        Campo(
          rotulo: 'Lembrar de quê?',
          child: CampoTexto(
            controle: _texto,
            dica: 'Ex.: Tomar vitamina',
            erro: _erro,
            autofoco: widget.lembrete == null,
            aoMudar: (_) => setState(() => _erro = null),
          ),
        ),
        Campo(
          rotulo: 'Em que dia',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EscolhaData(
                data: _data,
                hoje: _hoje,
                permiteSemData: false,
                permitePassado: widget.lembrete != null,
                calendarioAberto: widget.lembrete == null,
                marcado: _ctx.marcado,
                aoMudar: (d) => setState(() {
                  _data = d;
                  _erro = null;
                }),
              ),
              const SizedBox(height: 10),
              CampoHorario(
                rotulo: 'Horário',
                valor: _hora,
                opcional: false,
                aoMudar: (h) => setState(() {
                  _hora = h;
                  _erro = null;
                }),
              ),
            ],
          ),
        ),
        Campo(
          rotulo: 'Repetir',
          child: GrupoChips<OpcaoRepeticao>(
            opcoes: opcoes,
            selecionado: _repetir,
            rotulo: (o) => o == OpcaoRepeticao.nao
                ? 'Uma vez'
                : o == OpcaoRepeticao.personalizada
                    ? (_regraAtual?.descricao ?? o.rotulo)
                    : o.rotulo,
            aoEscolher: (o) => setState(() {
              _repetir = o;
              _erro = null;
            }),
          ),
        ),
        LinhaInterruptor(
          titulo: 'Me despertar',
          detalhe: 'no Android toca como despertador: tela cheia e som de alarme até você parar, '
              'mesmo no silencioso',
          valor: _despertar,
          aoMudar: _mudarDespertar,
        ),
      ],
    );
  }
}
