import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/compromissos_repo.dart';
import '../../data/lembretes_repo.dart';
import '../../data/rotina_repo.dart';
import '../../data/tarefas_repo.dart';
import '../calendario.dart';
import '../componentes.dart';
import '../formulario.dart';
import '../tarefas/linha_tarefa.dart';
import 'form_rotina.dart';
import 'linhas_rotina.dart';

enum _Vista {
  mes('Mês', Icons.calendar_view_month_rounded),
  semana('Semana', Icons.view_week_rounded);

  const _Vista(this.rotulo, this.icone);
  final String rotulo;
  final IconData icone;
}

/// Tipos que o calendário mostra (hábitos ficam em Hoje e Hábitos).
enum _Tipo { compromisso, tarefa, lembrete }

/// Um item num dia do calendário.
class _ItemCal {
  const _ItemCal(this.tipo, this.titulo, this.momento, {this.compromisso, this.tarefa, this.lembrete});
  final _Tipo tipo;
  final String titulo;

  /// Com hora; nulo = dia todo / sem hora.
  final DateTime? momento;
  final OcorrenciaCompromisso? compromisso;
  final OcorrenciaTarefa? tarefa;
  final LembreteDoDia? lembrete;
}

/// A partir desta largura o painel do dia fica ao lado da grade.
const _larguraPainelAoLado = 980.0;

/// A partir desta largura o mês mostra os compromissos dentro das células.
const _larguraMesCheio = 640.0;

/// Rotina › Calendário: mês ou semana com compromissos, tarefas com data e
/// lembretes; tocar num dia abre o painel dele, com atalhos para criar ali.
class CalendarioRotina extends StatefulWidget {
  const CalendarioRotina({super.key});

  @override
  State<CalendarioRotina> createState() => _CalendarioRotinaState();
}

class _CalendarioRotinaState extends State<CalendarioRotina> {
  RotinaRepo? _repo;
  Stream<QuadroRotina>? _quadro;
  var _vista = _Vista.mes;
  late DateTime _dia = hojeLocal();
  late DateTime _mes = DateTime(_dia.year, _dia.month, 1);
  final _mostrar = {..._Tipo.values};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = AuroraEscopo.de(context).db;
    if (_repo?.db != db) {
      _repo = RotinaRepo(db);
      _quadro = _repo!.observarQuadro();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuadroRotina>(
      stream: _quadro,
      builder: (context, snap) {
        if (snap.hasError) return Text('Não consegui ler o calendário: ${snap.error}');
        final q = snap.data;
        if (q == null) return const SizedBox(height: 200);
        return LayoutBuilder(builder: (context, box) => _conteudo(context, q, box.maxWidth));
      },
    );
  }

  DateTime _segunda(DateTime d) => somarDias(d, -(d.weekday - 1));

  /// Itens de cada dia do período, já filtrados.
  Map<DateTime, List<_ItemCal>> _itens(QuadroRotina q, DateTime de, DateTime ate) {
    final agora = agoraLocal();
    final mapa = <DateTime, List<_ItemCal>>{};
    void add(DateTime d, _ItemCal i) => mapa.putIfAbsent(d, () => []).add(i);
    if (_mostrar.contains(_Tipo.compromisso)) {
      q.compromissos.porDia(de, ate).forEach((d, l) {
        for (final o in l) {
          add(d, _ItemCal(_Tipo.compromisso, o.compromisso.titulo, o.diaInteiro ? null : o.inicio, compromisso: o));
        }
      });
    }
    if (_mostrar.contains(_Tipo.tarefa)) {
      q.tarefas.porDia(de, ate, agora).forEach((d, l) {
        for (final o in l) {
          add(d, _ItemCal(_Tipo.tarefa, o.tarefa.titulo, o.horario == null ? null : o.momento, tarefa: o));
        }
      });
    }
    if (_mostrar.contains(_Tipo.lembrete)) {
      for (var d = de; !d.isAfter(ate); d = somarDias(d, 1)) {
        for (final l in q.lembretesDoDia(d)) {
          add(d, _ItemCal(_Tipo.lembrete, l.lembrete.texto, l.toque, lembrete: l));
        }
      }
    }
    for (final l in mapa.values) {
      l.sort((a, b) {
        if ((a.momento == null) != (b.momento == null)) return a.momento == null ? -1 : 1;
        final c = a.momento == null ? 0 : a.momento!.compareTo(b.momento!);
        return c != 0 ? c : a.tipo.index.compareTo(b.tipo.index);
      });
    }
    return mapa;
  }

  void _navegar(int n) => setState(() {
        if (_vista == _Vista.mes) {
          _mes = DateTime(_mes.year, _mes.month + n, 1);
        } else {
          _dia = somarDias(_dia, 7 * n);
          _mes = DateTime(_dia.year, _dia.month, 1);
        }
      });

  Widget _conteudo(BuildContext context, QuadroRotina q, double largura) {
    final c = context.cores;
    final hoje = hojeLocal();
    final DateTime de, ate;
    if (_vista == _Vista.mes) {
      de = _segunda(_mes);
      ate = somarDias(_segunda(DateTime(_mes.year, _mes.month + 1, 0)), 6);
    } else {
      de = _segunda(_dia);
      ate = somarDias(de, 6);
    }
    final itens = _itens(q, de, ate);
    final doDia = (_vista == _Vista.mes && (_dia.isBefore(de) || _dia.isAfter(ate)))
        ? _itens(q, _dia, _dia)[_dia] ?? const <_ItemCal>[]
        : itens[_dia] ?? const <_ItemCal>[];

    final String titulo;
    if (_vista == _Vista.mes) {
      final t = mesAno(_mes);
      titulo = t[0].toUpperCase() + t.substring(1);
    } else {
      final fim = somarDias(de, 6);
      titulo = de.month == fim.month
          ? '${de.day} a ${fim.day} de ${DateFormat('MMMM', 'pt_BR').format(fim)}'
          : '${de.day} de ${DateFormat('MMM', 'pt_BR').format(de)} a ${fim.day} de ${DateFormat('MMM', 'pt_BR').format(fim)}';
    }

    final grade = _vista == _Vista.mes
        ? (largura >= _larguraMesCheio ? _MesCheio(mes: _mes, hoje: hoje, dia: _dia, itens: itens, aoEscolher: _escolher) : _mesCompacto(q, hoje, itens))
        : (largura >= _larguraMesCheio
            ? _GradeSemana(inicio: de, hoje: hoje, dia: _dia, itens: itens, aoEscolher: _escolher, aoAbrir: _abrir)
            : _listaSemana(context, de, hoje, itens));
    final painel = _Painel(dia: _dia, hoje: hoje, itens: doDia, aoAbrir: _abrir, repo: _repo!);
    final aoLado = largura >= _larguraPainelAoLado;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _BotaoNav(icone: Icons.chevron_left_rounded, dica: _vista == _Vista.mes ? 'Mês anterior' : 'Semana anterior', aoTocar: () => _navegar(-1)),
            _BotaoNav(icone: Icons.chevron_right_rounded, dica: _vista == _Vista.mes ? 'Próximo mês' : 'Próxima semana', aoTocar: () => _navegar(1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(titulo, style: sora(18)),
            ),
            TextButton(
              onPressed: () => setState(() {
                _dia = hoje;
                _mes = DateTime(hoje.year, hoje.month, 1);
              }),
              child: Text('Hoje', style: manrope(13, peso: FontWeight.w700, cor: c.accent)),
            ),
            SubAbas<_Vista>(
              opcoes: _Vista.values,
              selecionado: _vista,
              rotulo: (v) => v.rotulo,
              icone: (v) => v.icone,
              aoEscolher: (v) => setState(() {
                _vista = v;
                _mes = DateTime(_dia.year, _dia.month, 1);
              }),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (t, nome, icone, cor) in [
              (_Tipo.compromisso, 'Compromissos', Icons.event_rounded, c.corCompromisso),
              (_Tipo.tarefa, 'Tarefas', Icons.check_box_outlined, c.corTarefa),
              (_Tipo.lembrete, 'Lembretes', Icons.notifications_none_rounded, c.corLembrete),
            ])
              FilterChip(
                selected: _mostrar.contains(t),
                showCheckmark: false,
                avatar: Icon(icone, size: 16, color: cor),
                label: Text(nome, style: manrope(12.5, peso: FontWeight.w600)),
                side: BorderSide(color: _mostrar.contains(t) ? cor : c.line),
                backgroundColor: Colors.transparent,
                selectedColor: cor.withValues(alpha: 0.14),
                shape: const StadiumBorder(),
                onSelected: (v) => setState(() => v ? _mostrar.add(t) : _mostrar.remove(t)),
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (aoLado)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: grade),
              const SizedBox(width: 14),
              SizedBox(width: 330, child: painel),
            ],
          )
        else ...[
          grade,
          if (_vista == _Vista.mes || largura >= _larguraMesCheio) ...[const SizedBox(height: 14), painel],
        ],
      ],
    );
  }

  void _escolher(DateTime d) => setState(() {
        _dia = d;
        if (_vista == _Vista.mes && (d.month != _mes.month || d.year != _mes.year)) {
          _mes = DateTime(d.year, d.month, 1);
        }
      });

  void _abrir(_ItemCal i) {
    switch (i.tipo) {
      case _Tipo.compromisso:
        abrirFormCompromisso(context, compromisso: i.compromisso!.compromisso);
      case _Tipo.tarefa:
        abrirFormRotina(context, item: i.tarefa!.tarefa);
      case _Tipo.lembrete:
        abrirFormRotina(context, item: i.lembrete!.lembrete);
    }
  }

  /// Mês em tela estreita: o calendário compacto com pontinhos coloridos.
  Widget _mesCompacto(QuadroRotina q, DateTime hoje, Map<DateTime, List<_ItemCal>> itens) {
    final c = context.cores;
    Color cor(_Tipo t) => switch (t) {
          _Tipo.compromisso => c.corCompromisso,
          _Tipo.tarefa => c.corTarefa,
          _Tipo.lembrete => c.corLembrete,
        };
    return Cartao(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
      child: CalendarioMes(
        mes: _mes,
        hoje: hoje,
        selecionado: _dia,
        aoSelecionar: _escolher,
        aoMudarMes: (m) => setState(() => _mes = m),
        marcador: (d) {
          final l = itens[d];
          if (l == null || l.isEmpty) return null;
          final tipos = [for (final t in _Tipo.values) if (l.any((i) => i.tipo == t)) t];
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final t in tipos) Padding(padding: const EdgeInsets.symmetric(horizontal: 1), child: Ponto(cor(t))),
            ],
          );
        },
      ),
    );
  }

  /// Semana em tela estreita: lista por dia.
  Widget _listaSemana(BuildContext context, DateTime inicio, DateTime hoje, Map<DateTime, List<_ItemCal>> itens) {
    final c = context.cores;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < 7; i++) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 12, 2, 6),
            child: Row(children: [
              Text(dataPorExtenso(somarDias(inicio, i), hoje),
                  style: manrope(14, peso: FontWeight.w700, cor: somarDias(inicio, i) == hoje ? c.accent : c.text)),
              const SizedBox(width: 8),
              Text((itens[somarDias(inicio, i)] ?? const []).isEmpty ? 'livre' : '${itens[somarDias(inicio, i)]!.length}',
                  style: manrope(12, cor: c.muted)),
            ]),
          ),
          for (final it in itens[somarDias(inicio, i)] ?? const <_ItemCal>[])
            Padding(padding: const EdgeInsets.only(bottom: 8), child: _linha(context, it, hoje)),
        ],
      ],
    );
  }

  Widget _linha(BuildContext context, _ItemCal i, DateTime hoje) => _linhaItem(context, i, hoje, _abrir, _repo!);
}

/// A linha de cada tipo (painel do dia e lista da semana).
Widget _linhaItem(BuildContext context, _ItemCal i, DateTime hoje, void Function(_ItemCal) abrir, RotinaRepo repo) {
  switch (i.tipo) {
    case _Tipo.compromisso:
      return LinhaCompromisso(
        ocorrencia: i.compromisso!,
        agora: agoraLocal(),
        mostrarEstado: i.compromisso!.dia == hoje,
        aoEditar: () => abrir(i),
      );
    case _Tipo.tarefa:
      final o = i.tarefa!;
      return LinhaTarefa(
        ocorrencia: o,
        hoje: hoje,
        aoAlternar: () => TarefasRepo(repo.db).alternar(o, !o.feita),
        aoEditar: () => abrir(i),
      );
    case _Tipo.lembrete:
      final l = i.lembrete!;
      return LinhaLembrete(
        visto: l.visto,
        toque: l.toque,
        hoje: hoje,
        aoAlternar: () => LembretesRepo(repo.db).alternarAtivo(l.lembrete.id, !l.lembrete.ativo),
        aoEditar: () => abrir(i),
      );
  }
}

class _BotaoNav extends StatelessWidget {
  const _BotaoNav({required this.icone, required this.dica, required this.aoTocar});
  final IconData icone;
  final String dica;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Tooltip(
      message: dica,
      child: Material(
        color: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: c.line)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          child: SizedBox(width: 36, height: 36, child: Icon(icone, color: c.text)),
        ),
      ),
    );
  }
}

/// Mês em tela larga: cada célula mostra até 2 compromissos com hora e os
/// contadores de tarefas (☐) e lembretes (sino).
class _MesCheio extends StatelessWidget {
  const _MesCheio({required this.mes, required this.hoje, required this.dia, required this.itens, required this.aoEscolher});
  final DateTime mes;
  final DateTime hoje;
  final DateTime dia;
  final Map<DateTime, List<_ItemCal>> itens;
  final ValueChanged<DateTime> aoEscolher;

  static const _semana = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'];

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final inicio = somarDias(mes, -(mes.weekday - 1));
    final ultimo = DateTime(mes.year, mes.month + 1, 0);
    final semanas = ((ultimo.difference(inicio).inDays + 1) / 7).ceil();
    return Column(
      children: [
        Row(children: [
          for (final s in _semana)
            Expanded(child: Center(child: Text(s, style: manrope(11, peso: FontWeight.w700, cor: c.muted)))),
        ]),
        const SizedBox(height: 6),
        for (var w = 0; w < semanas; w++)
          Row(children: [
            for (var d = 0; d < 7; d++) Expanded(child: _celula(context, somarDias(inicio, w * 7 + d))),
          ]),
      ],
    );
  }

  Widget _celula(BuildContext context, DateTime d) {
    final c = context.cores;
    final l = itens[d] ?? const <_ItemCal>[];
    final comps = l.where((i) => i.tipo == _Tipo.compromisso).toList();
    final nt = l.where((i) => i.tipo == _Tipo.tarefa).length;
    final nl = l.where((i) => i.tipo == _Tipo.lembrete).length;
    final fora = d.month != mes.month;
    final sel = d == dia;
    final ehHoje = d == hoje;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Opacity(
        opacity: fora ? 0.4 : 1,
        child: Semantics(
          button: true,
          selected: sel,
          label: 'Dia ${d.day}',
          child: Material(
            color: sel ? c.violeta.withValues(alpha: 0.10) : c.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: sel ? c.violeta : c.line, width: sel ? 1.5 : 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => aoEscolher(d),
              child: SizedBox(
                height: 96,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: ehHoje ? BoxDecoration(shape: BoxShape.circle, gradient: c.gradiente) : null,
                          child: Text('${d.day}', style: sora(12, cor: ehHoje ? c.noAccent : c.text)),
                        ),
                      ),
                      const SizedBox(height: 2),
                      for (final i in comps.take(2))
                        Container(
                          margin: const EdgeInsets.only(bottom: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: c.corCompromisso.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(5),
                            border: Border(left: BorderSide(color: c.corCompromisso, width: 2)),
                          ),
                          child: Text(
                            '${i.momento == null ? '' : '${hora(emLocal(i.momento!))} '}${i.titulo}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: manrope(10.5, peso: FontWeight.w600),
                          ),
                        ),
                      if (comps.length > 2)
                        Text('+${comps.length - 2}', style: manrope(10.5, peso: FontWeight.w700, cor: c.muted)),
                      const Spacer(),
                      Row(children: [
                        if (nt > 0) ...[
                          Icon(Icons.check_box_outlined, size: 12, color: c.corTarefa),
                          Text('$nt', style: manrope(10.5, peso: FontWeight.w700, cor: c.corTarefa)),
                          const SizedBox(width: 6),
                        ],
                        if (nl > 0) ...[
                          Icon(Icons.notifications_none_rounded, size: 12, color: c.corLembrete),
                          Text('$nl', style: manrope(10.5, peso: FontWeight.w700, cor: c.corLembrete)),
                        ],
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Semana em tela larga: grade de horas (7h às 23h), compromissos em blocos,
/// tarefas e lembretes com hora como etiquetas, uma linha "dia todo" e a
/// linha do agora.
class _GradeSemana extends StatelessWidget {
  const _GradeSemana({
    required this.inicio,
    required this.hoje,
    required this.dia,
    required this.itens,
    required this.aoEscolher,
    required this.aoAbrir,
  });
  final DateTime inicio;
  final DateTime hoje;
  final DateTime dia;
  final Map<DateTime, List<_ItemCal>> itens;
  final ValueChanged<DateTime> aoEscolher;
  final void Function(_ItemCal) aoAbrir;

  static const _h0 = 7, _h1 = 24;
  static const _px = 40.0;

  double _y(DateTime m) {
    final l = emLocal(m);
    final min = (l.hour * 60 + l.minute - _h0 * 60).clamp(0, (_h1 - _h0) * 60 - 20);
    return min / 60 * _px;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final dias = [for (var i = 0; i < 7; i++) somarDias(inicio, i)];
    final altura = (_h1 - _h0) * _px;
    final agora = agoraLocal();
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Cabeçalho dos dias.
          Row(children: [
            const SizedBox(width: 44),
            for (final d in dias)
              Expanded(
                child: InkWell(
                  onTap: () => aoEscolher(d),
                  child: Container(
                    color: d == dia ? c.violeta.withValues(alpha: 0.10) : null,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(children: [
                      Text(DateFormat('EEE', 'pt_BR').format(d).replaceAll('.', '').toUpperCase(),
                          style: manrope(10.5, peso: FontWeight.w700, cor: c.muted)),
                      const SizedBox(height: 2),
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: d == hoje ? BoxDecoration(shape: BoxShape.circle, gradient: c.gradiente) : null,
                        child: Text('${d.day}', style: sora(15, cor: d == hoje ? c.noAccent : c.text)),
                      ),
                    ]),
                  ),
                ),
              ),
          ]),
          Divider(height: 1, color: c.line),
          // Dia todo (compromissos de dia inteiro e tarefas sem hora).
          IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SizedBox(
                width: 44,
                child: Padding(
                  padding: const EdgeInsets.only(right: 6, top: 4),
                  child: Text('dia\ntodo', textAlign: TextAlign.right, style: manrope(10, cor: c.muted)),
                ),
              ),
              for (final d in dias)
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 28),
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(border: Border(left: BorderSide(color: c.line))),
                    child: Column(children: [
                      for (final i in (itens[d] ?? const <_ItemCal>[]).where((i) => i.momento == null))
                        _Etiqueta(item: i, aoTocar: () => aoAbrir(i)),
                    ]),
                  ),
                ),
            ]),
          ),
          Divider(height: 1, color: c.line),
          // Horas.
          SizedBox(
            height: altura,
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SizedBox(
                width: 44,
                child: Stack(children: [
                  for (var h = _h0 + 1; h < _h1; h++)
                    Positioned(
                      top: (h - _h0) * _px - 7,
                      right: 6,
                      child: Text('${h.toString().padLeft(2, '0')}:00', style: manrope(10, cor: c.muted)),
                    ),
                ]),
              ),
              for (final d in dias)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: d == hoje ? c.accent.withValues(alpha: 0.03) : null,
                      border: Border(left: BorderSide(color: c.line)),
                    ),
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        for (var h = 1; h < _h1 - _h0; h++)
                          Positioned(top: h * _px, left: 0, right: 0, child: Container(height: 1, color: c.line)),
                        for (final i in (itens[d] ?? const <_ItemCal>[]).where((i) => i.momento != null))
                          if (i.tipo == _Tipo.compromisso)
                            Positioned(
                              top: _y(i.momento!),
                              left: 3,
                              right: 3,
                              height: (((i.compromisso!.fim ?? i.momento!.add(const Duration(hours: 1)))
                                                  .difference(i.momento!)
                                                  .inMinutes /
                                              60 *
                                              _px) -
                                          2)
                                      .clamp(22, altura - _y(i.momento!))
                                      .toDouble(),
                              child: _Bloco(item: i, aoTocar: () => aoAbrir(i)),
                            )
                          else
                            Positioned(
                              top: _y(i.momento!),
                              left: 3,
                              right: 3,
                              child: _Etiqueta(item: i, aoTocar: () => aoAbrir(i), comHora: true),
                            ),
                        if (d == hoje && agora.hour >= _h0)
                          Positioned(
                            top: _y(agora),
                            left: 0,
                            right: 0,
                            child: Container(height: 2, color: c.bad),
                          ),
                      ],
                    ),
                  ),
                ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _Bloco extends StatelessWidget {
  const _Bloco({required this.item, required this.aoTocar});
  final _ItemCal item;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final o = item.compromisso!;
    return Semantics(
      button: true,
      label: 'Compromisso ${item.titulo}',
      excludeSemantics: true,
      child: Material(
        color: Color.alphaBlend(c.corCompromisso.withValues(alpha: 0.25), c.surface),
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          child: Container(
            decoration: BoxDecoration(border: Border(left: BorderSide(color: c.corCompromisso, width: 3))),
            padding: const EdgeInsets.fromLTRB(5, 3, 4, 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.titulo, maxLines: 1, overflow: TextOverflow.ellipsis, style: manrope(11, peso: FontWeight.w700)),
                Text(o.horario, maxLines: 1, style: manrope(10, cor: c.muted)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({required this.item, required this.aoTocar, this.comHora = false});
  final _ItemCal item;
  final VoidCallback aoTocar;
  final bool comHora;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final (cor, icone) = switch (item.tipo) {
      _Tipo.compromisso => (c.corCompromisso, Icons.event_rounded),
      _Tipo.tarefa => (c.corTarefa, Icons.check_box_outlined),
      _Tipo.lembrete => (c.corLembrete, Icons.notifications_none_rounded),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: item.tipo == _Tipo.compromisso ? cor.withValues(alpha: 0.22) : c.surface2,
        borderRadius: BorderRadius.circular(6),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(children: [
              Icon(icone, size: 11, color: cor),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  comHora && item.momento != null ? '${hora(emLocal(item.momento!))} ${item.titulo}' : item.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: manrope(10.5, peso: FontWeight.w600, cor: item.tipo == _Tipo.compromisso ? c.text : cor),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Painel do dia escolhido: os itens por tipo e atalhos para criar naquele dia.
class _Painel extends StatelessWidget {
  const _Painel({required this.dia, required this.hoje, required this.itens, required this.aoAbrir, required this.repo});
  final DateTime dia;
  final DateTime hoje;
  final List<_ItemCal> itens;
  final void Function(_ItemCal) aoAbrir;
  final RotinaRepo repo;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    Widget grupo(_Tipo t, String nome) {
      final l = itens.where((i) => i.tipo == t).toList();
      if (l.isEmpty) return const SizedBox.shrink();
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(padding: const EdgeInsets.only(top: 10, bottom: 6), child: Text(nome.toUpperCase(), style: rotulo(c.muted))),
        for (final i in l)
          Padding(padding: const EdgeInsets.only(bottom: 8), child: _linhaItem(context, i, hoje, aoAbrir, repo)),
      ]);
    }

    final podeCriar = !dia.isBefore(hoje);
    return Cartao(
      padding: const EdgeInsets.all(14),
      sombra: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(dataPorExtenso(dia, hoje), style: sora(16)),
          Text(
            itens.isEmpty ? 'Dia livre' : (itens.length == 1 ? '1 item' : '${itens.length} itens'),
            style: manrope(12, cor: c.muted),
          ),
          if (itens.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(children: [
                Icon(Icons.beach_access_rounded, color: c.muted),
                const SizedBox(height: 6),
                Text('Nada marcado para este dia.', style: manrope(13, cor: c.muted)),
              ]),
            ),
          grupo(_Tipo.compromisso, 'Compromissos'),
          grupo(_Tipo.tarefa, 'Tarefas'),
          grupo(_Tipo.lembrete, 'Lembretes'),
          if (podeCriar) ...[
            const SizedBox(height: 10),
            BotaoPilula(
              texto: 'Compromisso neste dia',
              aoTocar: () => abrirFormRotina(context, tipo: TipoRotina.compromisso, dia: dia),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: BotaoPilula(
                  texto: 'Tarefa',
                  principal: false,
                  aoTocar: () => abrirFormRotina(context, tipo: TipoRotina.tarefa, dia: dia),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: BotaoPilula(
                  texto: 'Lembrete',
                  principal: false,
                  aoTocar: () => abrirFormRotina(context, tipo: TipoRotina.lembrete, dia: dia),
                ),
              ),
            ]),
          ],
        ],
      ),
    );
  }
}
