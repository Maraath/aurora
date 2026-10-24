import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/alimentacao_repo.dart';
import '../../data/banco.dart';
import '../../data/catalogo_taco.dart';
import '../componentes.dart';
import '../em_breve.dart';
import 'form_alimento.dart';
import 'form_alvos.dart';
import 'form_registro.dart';

String _g(double v) => numero((v * 10).roundToDouble() / 10);
String _kcal(double v) => numero(v.roundToDouble());

class AlimentacaoPage extends StatefulWidget {
  const AlimentacaoPage({super.key, this.voltar});
  final VoidCallback? voltar;

  @override
  State<AlimentacaoPage> createState() => _AlimentacaoPageState();
}

class _AlimentacaoPageState extends State<AlimentacaoPage> {
  AlimentacaoRepo? _repo;
  final _hoje = hojeLocal();
  late DateTime _dia = _hoje;
  Stream<DiaAlimentacao>? _stream;
  bool _verAlimentos = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = AuroraEscopo.de(context).db;
    if (_repo?.db != db) {
      _repo = AlimentacaoRepo(db);
      _stream = _repo!.observarDia(_dia);
    }
  }

  void _irPara(DateTime d) => setState(() {
        _dia = d;
        _stream = _repo!.observarDia(d);
      });

  Future<void> _alvos() async {
    final treino = await _repo!.alvo(TipoDia.treino);
    final descanso = await _repo!.alvo(TipoDia.descanso);
    if (mounted) await abrirFormAlvos(context, treino: treino, descanso: descanso);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DiaAlimentacao>(
      stream: _stream,
      builder: (context, snap) {
        if (snap.hasError) return Text('Não consegui ler a alimentação: ${snap.error}');
        final d = snap.data;
        if (d == null) return const SizedBox(height: 200);
        return _conteudo(context, d);
      },
    );
  }

  Widget _conteudo(BuildContext context, DiaAlimentacao d) {
    final c = context.cores;
    final refeicoes = [
      for (final r in Refeicao.values)
        if (r != Refeicao.ceia || d.daRefeicao(r).isNotEmpty) r,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TituloPagina(
          'Alimentação',
          voltar: widget.voltar,
          acao: BotaoRedondo(
            icone: Icons.add_rounded,
            dica: 'Registrar refeição',
            preenchido: true,
            aoTocar: () => abrirFormRegistro(context, dia: _dia, alimentos: d.alimentos),
          ),
        ),
        const SizedBox(height: 8),
        Row(children: [
          IconButton(
            tooltip: 'Dia anterior',
            onPressed: () => _irPara(somarDias(_dia, -1)),
            icon: Icon(Icons.chevron_left_rounded, color: c.muted),
          ),
          Flexible(
            child: Text(
              '${diaRelativo(_dia, _hoje).toUpperCase()} · ${d.tipo == TipoDia.treino ? 'TREINO' : 'DESCANSO'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: manrope(12, peso: FontWeight.w700, cor: c.muted, espaco: 1.2),
            ),
          ),
          IconButton(
            tooltip: 'Próximo dia',
            onPressed: () => _irPara(somarDias(_dia, 1)),
            icon: Icon(Icons.chevron_right_rounded, color: c.muted),
          ),
          const Spacer(),
          TextButton(
            onPressed: _alvos,
            child: Text('Alvos', style: manrope(13, peso: FontWeight.w700, cor: c.accent)),
          ),
        ]),
        const SizedBox(height: 8),
        ResumoAlimentacao(dia: d, aoDefinirAlvos: _alvos),
        const SizedBox(height: 18),
        for (final r in refeicoes) ...[
          _Refeicao(
            refeicao: r,
            registros: d.daRefeicao(r),
            alimentos: {for (final a in d.alimentos) a.id: a},
            aoAdicionar: () => abrirFormRegistro(context, dia: _dia, alimentos: d.alimentos, refeicao: r),
            aoExcluir: (x) => _excluir(x),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 6),
        TituloSecao(
          'Meus alimentos (${d.alimentos.length})',
          direita: TextButton(
            onPressed: () => setState(() => _verAlimentos = !_verAlimentos),
            child: Text(_verAlimentos ? 'Esconder' : 'Ver todos', style: manrope(12, peso: FontWeight.w700, cor: c.accent)),
          ),
        ),
        if (_verAlimentos)
          for (final a in d.alimentos)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Cartao(
                raio: 14,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                aoTocar: () => abrirFormAlimento(context, alimento: a),
                child: Row(children: [
                  Expanded(child: Text(a.nome, style: manrope(14, peso: FontWeight.w600))),
                  if (a.origem == 'taco') ...[
                    Etiqueta('TACO', cor: c.muted),
                    const SizedBox(width: 8),
                  ],
                  Text('${_kcal(a.kcal)} kcal · P ${_g(a.proteina)} · C ${_g(a.carboidrato)} · G ${_g(a.gordura)}',
                      style: manrope(12, cor: c.muted)),
                ]),
              ),
            ),
        CartaoNovo(
          titulo: '+ Novo alimento',
          detalhe: 'Para o que não está na TACO (marcas, receitas). Valores por 100 g, como no rótulo, '
              'e uma porção caseira opcional (1 ovo, 1 colher).',
          aoTocar: () => abrirFormAlimento(context),
        ),
        const SizedBox(height: 10),
        Text('Ao registrar, a busca inclui os alimentos da $fonteTaco. '
            'Os que você usa entram em "Meus alimentos" e podem ganhar porção caseira.',
            style: manrope(12, cor: c.muted, altura: 1.4)),
      ],
    );
  }

  Future<void> _excluir(RegistroAlimentacao r) async {
    final c = context.cores;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text('Tirar da refeição?', style: sora(18)),
        content: Text('${r.nome}, ${_g(r.gramas)} g (${_kcal(r.kcal)} kcal).', style: manrope(14, cor: c.text)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Tirar', style: TextStyle(color: c.bad)),
          ),
        ],
      ),
    );
    if (ok == true) await _repo!.excluirRegistro(r.id);
  }
}

/// Consumido x alvo: calorias e as três barras de macros.
class ResumoAlimentacao extends StatelessWidget {
  const ResumoAlimentacao({super.key, required this.dia, this.aoDefinirAlvos, this.compacto = false});
  final DiaAlimentacao dia;
  final VoidCallback? aoDefinirAlvos;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final t = dia.total;
    final a = dia.alvo;
    final falta = a == null ? null : a.kcal - t.kcal;

    Widget macro(String nome, double feito, double? alvo) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(child: Text(nome, style: manrope(12, cor: c.muted))),
              Text(alvo == null || alvo == 0 ? '${_g(feito)} g' : '${_g(feito)} de ${_g(alvo)} g',
                  style: manrope(12, cor: c.muted)),
            ]),
            if (alvo != null && alvo > 0) ...[
              const SizedBox(height: 4),
              BarraProgresso(fracao: feito / alvo, cor: feito > alvo * 1.1 ? c.warn : c.teal),
            ],
          ]),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(_kcal(t.kcal), style: sora(compacto ? 24 : 30)),
          const SizedBox(width: 6),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(a == null ? 'kcal' : 'de ${_kcal(a.kcal)} kcal',
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: manrope(13, cor: c.muted)),
            ),
          ),
          if (falta != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                falta >= 0 ? 'faltam ${_kcal(falta)}' : 'passou ${_kcal(-falta)}',
                style: manrope(12, peso: FontWeight.w700, cor: falta >= 0 ? c.teal : c.warn),
              ),
            ),
        ]),
        if (a != null) ...[
          const SizedBox(height: 6),
          BarraProgresso(fracao: t.kcal / a.kcal, cor: t.kcal > a.kcal * 1.05 ? c.warn : c.accent),
        ],
        macro('Proteína', t.proteina, a?.proteina),
        macro('Carboidrato', t.carboidrato, a?.carboidrato),
        macro('Gordura', t.gordura, a?.gordura),
        if (a == null && aoDefinirAlvos != null) ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: BotaoPilula(texto: 'Definir alvos', principal: false, aoTocar: aoDefinirAlvos!),
          ),
        ],
      ],
    );
  }
}

class _Refeicao extends StatelessWidget {
  const _Refeicao({
    required this.refeicao,
    required this.registros,
    required this.alimentos,
    required this.aoAdicionar,
    required this.aoExcluir,
  });
  final Refeicao refeicao;
  final List<RegistroAlimentacao> registros;
  final Map<String, Alimento> alimentos;

  /// "2 × 1 ovo" quando o peso fecha em unidades (ou meias); senão "100 g".
  String _quantidade(RegistroAlimentacao r) {
    final a = alimentos[r.alimentoId];
    final porcao = a?.porcaoGramas;
    if (porcao != null && porcao > 0) {
      final n = r.gramas / porcao;
      if (((n * 2) - (n * 2).round()).abs() < 0.01 && n >= 0.5) return '${numero(n)} × ${a!.porcaoNome}';
    }
    return '${_g(r.gramas)} g';
  }
  final VoidCallback aoAdicionar;
  final ValueChanged<RegistroAlimentacao> aoExcluir;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final kcal = registros.fold(0.0, (s, r) => s + r.kcal);
    return Cartao(
      raio: 16,
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(child: Text(refeicao.rotulo, style: manrope(15, peso: FontWeight.w700))),
            if (registros.isNotEmpty) Text('${_kcal(kcal)} kcal', style: manrope(13, cor: c.muted)),
            IconButton(
              tooltip: 'Adicionar em ${refeicao.rotulo}',
              onPressed: aoAdicionar,
              icon: Icon(Icons.add_circle_outline_rounded, color: c.accent),
            ),
          ]),
          for (final r in registros)
            InkWell(
              onTap: () => aoExcluir(r),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 6, 8, 6),
                child: Row(children: [
                  Expanded(child: Text(r.nome, style: manrope(14))),
                  Text(_quantidade(r), style: manrope(12, cor: c.muted)),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 64,
                    child: Text('${_kcal(r.kcal)} kcal',
                        textAlign: TextAlign.end, style: manrope(13, peso: FontWeight.w700)),
                  ),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

/// Resumo de hoje para a tela de Hábitos.
class CartaoAlimentacao extends StatelessWidget {
  const CartaoAlimentacao({super.key, required this.dia, required this.aoTocar});
  final DiaAlimentacao dia;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Cartao(
      padding: const EdgeInsets.all(16),
      aoTocar: aoTocar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(
              child: Text('ALIMENTAÇÃO HOJE · DIA DE ${dia.tipo == TipoDia.treino ? 'TREINO' : 'DESCANSO'}',
                  style: rotulo(c.accent)),
            ),
            Icon(Icons.chevron_right_rounded, color: c.muted),
          ]),
          const SizedBox(height: 8),
          if (dia.alvo == null && dia.registros.isEmpty)
            Text('Defina seus alvos e registre o que come; o Aurora soma o dia.',
                style: manrope(13, cor: c.muted, altura: 1.4))
          else
            ResumoAlimentacao(dia: dia, compacto: true),
        ],
      ),
    );
  }
}
