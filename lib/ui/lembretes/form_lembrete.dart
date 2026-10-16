import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/recorrencia.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/lembretes_repo.dart';
import '../formulario.dart';

Future<void> abrirFormLembrete(BuildContext context, {Lembrete? lembrete}) {
  final repo = LembretesRepo(AuroraEscopo.de(context).db);
  return abrirFolha<void>(context, (_) => _FormLembrete(repo: repo, lembrete: lembrete));
}

class _FormLembrete extends StatefulWidget {
  const _FormLembrete({required this.repo, required this.lembrete});
  final LembretesRepo repo;
  final Lembrete? lembrete;

  @override
  State<_FormLembrete> createState() => _FormLembreteState();
}

class _FormLembreteState extends State<_FormLembrete> {
  late final TextEditingController _texto;
  late DateTime? _data;
  late TimeOfDay? _hora;
  late OpcaoRepeticao _repetir;
  Regra? _regraAtual;
  String? _erro;
  final _hoje = hojeSP();

  bool get _ligadoAItem => widget.lembrete?.itemTipo != null;

  @override
  void initState() {
    super.initState();
    final l = widget.lembrete;
    _texto = TextEditingController(text: l?.texto ?? '');
    if (l != null) {
      final q = emSP(l.quando);
      _data = DateTime(q.year, q.month, q.day);
      _hora = TimeOfDay(hour: q.hour, minute: q.minute);
    } else {
      _data = _hoje;
      final agora = agoraSP();
      _hora = TimeOfDay(hour: (agora.hour + 1) % 24, minute: 0);
    }
    _regraAtual = Regra.ler(l?.regraRepeticao);
    _repetir = OpcaoRepeticao.de(_regraAtual);
  }

  @override
  void dispose() {
    _texto.dispose();
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
    final quando = instanteSP(data, hora.hour, hora.minute);
    final regra = _repetir.regra(data, _regraAtual);
    if (regra == null && !quando.isAfter(agoraSP())) {
      setState(() => _erro = 'Esse horário já passou. Escolha outro ou repita.');
      return;
    }
    await widget.repo.salvar(
      LembretesCompanion(
        texto: Value(texto),
        quando: Value(quando),
        regraRepeticao: Value(regra?.rrule),
        ativo: const Value(true),
      ),
      id: widget.lembrete?.id,
    );
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
      if (_repetir == OpcaoRepeticao.personalizada) OpcaoRepeticao.personalizada,
    ];
    return Folha(
      titulo: widget.lembrete == null ? 'Novo lembrete' : 'Editar lembrete',
      textoSalvar: 'Salvar lembrete',
      aoSalvar: _salvar,
      aoExcluir: widget.lembrete == null ? null : _excluir,
      campos: [
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
          rotulo: 'Quando',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EscolhaData(
                data: _data,
                hoje: _hoje,
                permiteSemData: false,
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
      ],
    );
  }
}
