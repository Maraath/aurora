import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/recorrencia.dart';
import '../../core/tema.dart';
import '../../data/automacoes_repo.dart';
import '../../data/banco.dart';
import '../formulario.dart';

/// Edita uma automação, ou cria uma personalizada (pedido à IA no horário).
Future<void> abrirFormAutomacao(BuildContext context, {Automacao? automacao}) {
  final repo = AutomacoesRepo(AuroraEscopo.de(context).db);
  return abrirFolha<void>(context, (_) => _FormAutomacao(repo: repo, automacao: automacao));
}

class _FormAutomacao extends StatefulWidget {
  const _FormAutomacao({required this.repo, required this.automacao});
  final AutomacoesRepo repo;
  final Automacao? automacao;

  @override
  State<_FormAutomacao> createState() => _FormAutomacaoState();
}

class _FormAutomacaoState extends State<_FormAutomacao> {
  late final _nome = TextEditingController(text: widget.automacao?.nome ?? '');
  late final _pedido = TextEditingController(text: widget.automacao?.pedido ?? '');
  late int _dias = widget.automacao?.diasSemana ?? todosOsDias;
  late TimeOfDay _hora = () {
    final h = lerHorario(widget.automacao?.horario ?? '09:00');
    return TimeOfDay(hour: h.hora, minute: h.minuto);
  }();
  String? _erro;

  Automacao? get _a => widget.automacao;
  bool get _personalizada => _a == null || ModeloAutomacao.de(_a!.modelo) == ModeloAutomacao.personalizada;

  @override
  void dispose() {
    _nome.dispose();
    _pedido.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final nome = _nome.text.trim();
    final pedido = _pedido.text.trim();
    if (nome.isEmpty) {
      setState(() => _erro = 'Dê um nome para a automação.');
      return;
    }
    if (_personalizada && pedido.isEmpty) {
      setState(() => _erro = 'Escreva o que a Aurora deve responder no horário.');
      return;
    }
    if (_dias == 0) {
      setState(() => _erro = 'Escolha pelo menos um dia.');
      return;
    }
    final dados = AutomacoesCompanion(
      nome: Value(nome),
      diasSemana: Value(_dias),
      horario: Value(horaDe(_hora.hour, _hora.minute)),
      pedido: Value(_personalizada ? pedido : _a?.pedido),
      // Criar ou mudar o horário liga a automação: é o que se espera ao salvar.
      ativa: const Value(true),
      modelo: Value(_a?.modelo ?? ModeloAutomacao.personalizada.name),
    );
    await widget.repo.salvar(dados, id: _a?.id);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _excluir() async {
    await widget.repo.excluir(_a!.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Folha(
      titulo: _a == null ? 'Nova automação' : 'Editar automação',
      textoSalvar: 'Salvar e ligar',
      aoSalvar: _salvar,
      aoExcluir: _a != null && _personalizada ? _excluir : null,
      campos: [
        if (!_personalizada)
          Text(ModeloAutomacao.de(_a!.modelo).descricao, style: manrope(13, cor: c.muted, altura: 1.4)),
        Campo(
          rotulo: 'Nome',
          child: CampoTexto(
            controle: _nome,
            dica: 'Ex.: Semana de treino',
            autofoco: _a == null,
            aoMudar: (_) => setState(() => _erro = null),
          ),
        ),
        if (_personalizada)
          Campo(
            rotulo: 'O que a Aurora deve responder',
            child: CampoTexto(
              controle: _pedido,
              dica: 'Ex.: Como foi minha semana de treino e alimentação?',
              aoMudar: (_) => setState(() => _erro = null),
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
          rotulo: 'Horário',
          valor: _hora,
          opcional: false,
          aoMudar: (h) => setState(() => _hora = h ?? _hora),
        ),
        if (_personalizada)
          Text('Precisa da conta conectada (a IA responde pela nuvem). Sem internet, o pedido espera na fila.',
              style: manrope(12, cor: c.muted, altura: 1.4)),
        if (_erro != null) Text(_erro!, style: manrope(13, peso: FontWeight.w600, cor: c.bad)),
      ],
    );
  }
}
