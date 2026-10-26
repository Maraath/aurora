import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../core/notificacoes.dart';
import '../../core/recorrencia.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/compromissos_repo.dart';
import '../formulario.dart';
import 'contexto_form.dart';

/// Repetições de compromisso (a regra sai da data escolhida).
enum RepeticaoCompromisso {
  nao('Não repete'),
  semana('Toda semana'),
  quinzena('A cada 2 semanas'),
  mes('Todo mês'),
  ano('Todo ano'),
  outra('Personalizada');

  const RepeticaoCompromisso(this.rotulo);
  final String rotulo;

  Regra? regra(DateTime dia, Regra? atual) => switch (this) {
        nao => null,
        semana => Regra.semanal(bitDoDiaDaSemana(dia)),
        quinzena => Regra.semanal(bitDoDiaDaSemana(dia), intervalo: 2),
        mes => Regra.mensal(dia.day),
        ano => const Regra.anual(),
        outra => atual,
      };

  static RepeticaoCompromisso de(Regra? r) {
    if (r == null) return nao;
    final umDia = r.dias != 0 && r.dias & (r.dias - 1) == 0;
    if (r.frequencia == Frequencia.semanal && umDia && r.intervalo <= 2) {
      return r.intervalo == 1 ? semana : quinzena;
    }
    if (r.intervalo == 1 && r.frequencia == Frequencia.mensal) return mes;
    if (r.intervalo == 1 && r.frequencia == Frequencia.anual) return ano;
    return outra;
  }
}

/// Antecedência do aviso, em minutos (nulo = sem aviso).
const avisosCompromisso = <(int?, String)>[
  (null, 'Sem aviso'),
  (0, 'Na hora'),
  (15, '15 min antes'),
  (30, '30 min antes'),
  (60, '1 h antes'),
  (1440, '1 dia antes'),
];

class FormCompromisso extends StatefulWidget {
  const FormCompromisso({
    super.key,
    required this.repo,
    required this.compromisso,
    this.contexto = const ContextoForm(),
  });

  final CompromissosRepo repo;
  final Compromisso? compromisso;
  final ContextoForm contexto;

  @override
  State<FormCompromisso> createState() => _FormCompromissoState();
}

class _FormCompromissoState extends State<FormCompromisso> {
  late final TextEditingController _titulo;
  late final TextEditingController _local;
  late DateTime _data;
  late TimeOfDay _inicio;
  TimeOfDay? _fim;
  late bool _diaInteiro;
  late RepeticaoCompromisso _repetir;
  Regra? _regraAtual;
  int? _aviso;
  late bool _despertar;
  String? _erro;
  final _hoje = hojeLocal();

  ContextoForm get _ctx => widget.contexto;

  @override
  void initState() {
    super.initState();
    final c = widget.compromisso;
    _titulo = _ctx.titulo ?? TextEditingController(text: c?.titulo ?? '');
    _local = TextEditingController(text: c?.local ?? '');
    if (c != null) {
      final i = emLocal(c.inicio);
      _data = DateTime(i.year, i.month, i.day);
      _inicio = TimeOfDay(hour: i.hour, minute: i.minute);
      if (c.fim != null) {
        final f = emLocal(c.fim!);
        _fim = TimeOfDay(hour: f.hour, minute: f.minute);
      }
      _diaInteiro = c.diaInteiro;
      _aviso = c.avisoAntesMin;
      _despertar = c.despertar;
    } else {
      final data = _ctx.data;
      _data = data == null || data.isBefore(_hoje) ? _hoje : data;
      final agora = agoraLocal();
      _inicio = _ctx.hora ?? TimeOfDay(hour: (agora.hour + 1) % 24, minute: 0);
      _fim = TimeOfDay(hour: (_inicio.hour + 1) % 24, minute: _inicio.minute);
      _diaInteiro = false;
      _aviso = 30;
      _despertar = false;
    }
    _regraAtual = Regra.ler(c?.regraRepeticao);
    _repetir = RepeticaoCompromisso.de(_regraAtual);
  }

  @override
  void dispose() {
    if (_ctx.titulo == null) _titulo.dispose();
    _local.dispose();
    super.dispose();
  }

  Future<void> _mudarDespertar(bool v) async {
    setState(() => _despertar = v);
    if (v) await Notificador.instancia.pedirPermissoesDespertador();
  }

  Future<void> _salvar() async {
    final titulo = _titulo.text.trim();
    if (titulo.isEmpty) {
      setState(() => _erro = 'Dê um nome para o compromisso.');
      return;
    }
    final inicio = _diaInteiro ? instanteLocal(_data) : instanteLocal(_data, _inicio.hour, _inicio.minute);
    DateTime? fim;
    if (!_diaInteiro && _fim != null) {
      fim = instanteLocal(_data, _fim!.hour, _fim!.minute);
      // Termina "antes" de começar: passa da meia-noite.
      if (!fim.isAfter(inicio)) fim = instanteLocal(somarDias(_data, 1), _fim!.hour, _fim!.minute);
    }
    final local = _local.text.trim();
    final id = await widget.repo.salvar(
      CompromissosCompanion(
        titulo: Value(titulo),
        inicio: Value(inicio),
        fim: Value(fim),
        diaInteiro: Value(_diaInteiro),
        local: Value(local.isEmpty ? null : local),
        regraRepeticao: Value(_repetir.regra(_data, _regraAtual)?.rrule),
        avisoAntesMin: Value(_aviso),
        despertar: Value(_aviso != null && _despertar),
      ),
      id: widget.compromisso?.id,
    );
    await _ctx.aoSalvo?.call(id);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _excluir() async {
    final c = context.cores;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text('Excluir compromisso?', style: sora(18)),
        content: Text(
          widget.compromisso!.regraRepeticao != null
              ? '“${widget.compromisso!.titulo}” e todas as repetições saem da agenda.'
              : '“${widget.compromisso!.titulo}” sai da agenda.',
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
    await widget.repo.excluir(widget.compromisso!.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final opcoesRepetir = [
      for (final o in RepeticaoCompromisso.values)
        if (o != RepeticaoCompromisso.outra || _repetir == RepeticaoCompromisso.outra) o,
    ];
    return Folha(
      titulo: _ctx.tituloFolha ?? (widget.compromisso == null ? 'Novo compromisso' : 'Editar compromisso'),
      textoSalvar: 'Salvar compromisso',
      aoSalvar: _salvar,
      aoExcluir: widget.compromisso == null ? null : _excluir,
      campos: [
        ?_ctx.cabecalho,
        Campo(
          rotulo: 'Compromisso',
          child: CampoTexto(
            controle: _titulo,
            dica: 'Ex.: Dentista',
            erro: _erro,
            autofoco: widget.compromisso == null,
            aoMudar: (_) => setState(() => _erro = null),
          ),
        ),
        Campo(
          rotulo: 'Dia',
          child: EscolhaData(
            data: _data,
            hoje: _hoje,
            permiteSemData: false,
            permitePassado: widget.compromisso != null,
            marcado: _ctx.marcado,
            aoMudar: (d) => setState(() => _data = d ?? _hoje),
          ),
        ),
        LinhaInterruptor(
          titulo: 'Dia inteiro',
          detalhe: 'aniversário, viagem, feriado',
          valor: _diaInteiro,
          aoMudar: (v) => setState(() => _diaInteiro = v),
        ),
        if (!_diaInteiro)
          Wrap(
            spacing: 18,
            runSpacing: 10,
            children: [
              CampoHorario(
                rotulo: 'Começa',
                valor: _inicio,
                opcional: false,
                aoMudar: (h) => setState(() {
                  // Andar o começo leva o fim junto (mesma duração).
                  if (h != null && _fim != null) {
                    final dur = (_fim!.hour * 60 + _fim!.minute) - (_inicio.hour * 60 + _inicio.minute);
                    final novo = (h.hour * 60 + h.minute + dur) % 1440;
                    _fim = TimeOfDay(hour: novo ~/ 60, minute: novo % 60);
                  }
                  _inicio = h ?? _inicio;
                }),
              ),
              CampoHorario(
                rotulo: 'Termina',
                valor: _fim,
                aoMudar: (h) => setState(() => _fim = h),
              ),
            ],
          ),
        Campo(
          rotulo: 'Local (opcional)',
          child: CampoTexto(controle: _local, dica: 'Endereço, sala ou link da reunião'),
        ),
        Campo(
          rotulo: 'Repetir',
          child: GrupoChips<RepeticaoCompromisso>(
            opcoes: opcoesRepetir,
            selecionado: _repetir,
            rotulo: (o) => o == RepeticaoCompromisso.outra ? (_regraAtual?.descricao ?? o.rotulo) : o.rotulo,
            aoEscolher: (o) => setState(() => _repetir = o),
          ),
        ),
        Campo(
          rotulo: 'Me avisar',
          child: GrupoChips<int?>(
            opcoes: [for (final (m, _) in avisosCompromisso) m],
            selecionado: _aviso,
            rotulo: (m) => avisosCompromisso.firstWhere((a) => a.$1 == m).$2,
            aoEscolher: (m) => setState(() => _aviso = m),
          ),
        ),
        if (_aviso != null)
          LinhaInterruptor(
            titulo: 'Me despertar',
            detalhe: 'no Android o aviso toca como despertador, mesmo no silencioso',
            valor: _despertar,
            aoMudar: _mudarDespertar,
          ),
      ],
    );
  }
}
