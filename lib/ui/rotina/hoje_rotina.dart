import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/compromissos_repo.dart';
import '../../data/habitos_repo.dart';
import '../../data/lembretes_repo.dart';
import '../../data/rotina_repo.dart';
import '../../data/tarefas_repo.dart';
import '../componentes.dart';
import '../habitos/linha_habito.dart';
import '../visao/foco.dart';
import 'form_rotina.dart';
import 'linhas_rotina.dart';
import 'sala_foco.dart';
import 'todos_lembretes.dart';

/// A partir desta largura o Timeblocking fica em duas colunas (5/12 e 7/12).
const larguraTimeblocking = 900.0;

const _chaveDuracoes = 'timeblocking_duracoes_v1';
const _opcoesDuracao = [25, 30, 45, 60, 90];

/// Indica se o app está rodando em dispositivo móvel (Android ou iOS).
bool get ehAparelhoMovel =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

enum ModoHoje {
  timeblocking('Timeblocking', Icons.view_timeline_outlined),
  foco('Foco Imersivo', Icons.timelapse_rounded);

  const ModoHoje(this.rotulo, this.icone);
  final String rotulo;
  final IconData icone;
}

/// Rotina › Hoje: Timeblocking interativo do dia (capacidade diária, caixa de
/// tarefas/hábitos para encaixar, linha do tempo com auto-distribuição) e a
/// Sala de Foco Imersivo.
class HojeRotina extends StatefulWidget {
  const HojeRotina({
    super.key,
    required this.verCalendario,
    this.modoInicial = ModoHoje.timeblocking,
    this.ocultarCabecalho = false,
    this.modo,
    this.aoMudarModo,
  });

  final VoidCallback verCalendario;
  final ModoHoje modoInicial;
  final bool ocultarCabecalho;
  final ModoHoje? modo;
  final ValueChanged<ModoHoje>? aoMudarModo;

  @override
  State<HojeRotina> createState() => _HojeRotinaState();
}

class _HojeRotinaState extends State<HojeRotina> {
  RotinaRepo? _repo;
  Stream<QuadroRotina>? _quadro;
  late ModoHoje _modo = widget.modoInicial;
  Map<String, int> _duracoes = {};

  ModoHoje get _modoAtual => widget.modo ?? _modo;

  void _mostrarAvisoFocoExclusivoPc() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.desktop_windows_rounded, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'O Foco Imersivo é exclusivo para PC para manter seu celular leve e economizar bateria.',
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _definirModo(ModoHoje m) {
    if (m == ModoHoje.foco && ehAparelhoMovel) {
      _mostrarAvisoFocoExclusivoPc();
      return;
    }
    if (widget.aoMudarModo != null) {
      widget.aoMudarModo!(m);
    } else {
      setState(() => _modo = m);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = AuroraEscopo.de(context).db;
    if (_repo?.db != db) {
      _repo = RotinaRepo(db);
      _quadro = _repo!.observarQuadro();
      _carregarDuracoes(db);
      ControleFoco.instancia.carregarPreferencias(db);
    }
  }

  Future<void> _carregarDuracoes(BancoAurora db) async {
    final raw = await db.preferencia(_chaveDuracoes);
    if (raw == null || raw.isEmpty) return;
    try {
      final mapa = jsonDecode(raw) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _duracoes = {
          for (final e in mapa.entries)
            if (e.value is num) e.key: (e.value as num).toInt(),
        };
      });
    } catch (_) {}
  }

  int _duracaoItem(String chave, {int padrao = 45}) =>
      _duracoes[chave] ?? padrao;

  Future<void> _ciclarDuracao(String chave, {int padrao = 45}) async {
    final atual = _duracaoItem(chave, padrao: padrao);
    final idx = _opcoesDuracao.indexOf(atual);
    final proximo = _opcoesDuracao[(idx + 1) % _opcoesDuracao.length];
    setState(() => _duracoes[chave] = proximo);
    final db = _repo?.db;
    if (db != null) {
      await db.salvarPreferencia(_chaveDuracoes, jsonEncode(_duracoes));
    }
  }

  /// Agenda uma tarefa num horário específico de hoje.
  Future<void> _agendarTarefa(
    OcorrenciaTarefa o,
    DateTime hoje,
    int hora,
    int minuto,
  ) async {
    final db = _repo!.db;
    final instante = instanteLocal(hoje, hora, minuto);
    await (db.update(db.tarefas)..where((t) => t.id.equals(o.tarefa.id))).write(
      TarefasCompanion(
        prazo: Value(instante),
        prazoTemHora: const Value(true),
        atualizadoEm: Value(DateTime.now()),
      ),
    );
  }

  /// Tira a tarefa da grade horária de hoje (mantém a data, mas sem hora fixa).
  Future<void> _desagendarTarefa(OcorrenciaTarefa o, DateTime hoje) async {
    final db = _repo!.db;
    await (db.update(db.tarefas)..where((t) => t.id.equals(o.tarefa.id))).write(
      TarefasCompanion(
        prazo: Value(instanteLocal(hoje)),
        prazoTemHora: const Value(false),
        atualizadoEm: Value(DateTime.now()),
      ),
    );
  }

  /// Agenda um hábito num horário "HH:mm".
  Future<void> _agendarHabito(Habito h, int hora, int minuto) async {
    final db = _repo!.db;
    final hh = hora.toString().padLeft(2, '0');
    final mm = minuto.toString().padLeft(2, '0');
    await (db.update(db.habitos)..where((x) => x.id.equals(h.id))).write(
      HabitosCompanion(
        horario: Value('$hh:$mm'),
        atualizadoEm: Value(DateTime.now()),
      ),
    );
  }

  /// Tira o hábito da grade horária (volta para sem horário fixo).
  Future<void> _desagendarHabito(Habito h) async {
    final db = _repo!.db;
    await (db.update(db.habitos)..where((x) => x.id.equals(h.id))).write(
      HabitosCompanion(
        horario: const Value(null),
        atualizadoEm: Value(DateTime.now()),
      ),
    );
  }

  /// Encontra o próximo horário livre na linha do tempo de hoje.
  ({int hora, int minuto}) _proximoSlotLivre(
    _DadosTimeblocking d,
    int duracaoMin,
  ) {
    final ocupados = <_Intervalo>[
      for (final b in d.blocosAgendados) _Intervalo(b.inicioMin, b.fimMin),
    ]..sort((a, b) => a.inicio.compareTo(b.inicio));

    // Começa a procurar a partir da próxima meia hora depois de agora (ou 08:00).
    final agoraMin = d.agora.hour * 60 + d.agora.minute;
    var candidato = math.max(8 * 60, ((agoraMin + 29) ~/ 30) * 30);
    if (candidato > 21 * 60) candidato = 9 * 60;

    for (final o in ocupados) {
      if (candidato + duracaoMin <= o.inicio) break;
      if (candidato < o.fim) {
        candidato = ((o.fim + 14) ~/ 15) * 15;
      }
    }
    candidato = candidato.clamp(6 * 60, 22 * 60);
    return (hora: candidato ~/ 60, minuto: candidato % 60);
  }

  /// Encaixa automaticamente todas as tarefas e hábitos sem horário nos
  /// melhores intervalos livres do dia.
  Future<void> _autoDistribuir(_DadosTimeblocking d) async {
    final pendentesTarefas = d.tarefasSemHora.where((t) => !t.feita).toList();
    final pendentesHabitos = d.habitosSemHora
        .where((h) => !d.q.habitos.feito(h.id, d.hoje))
        .toList();

    if (pendentesTarefas.isEmpty && pendentesHabitos.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Todos os itens pendentes de hoje já estão encaixados na grade!',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final ocupados = <_Intervalo>[
      for (final b in d.blocosAgendados) _Intervalo(b.inicioMin, b.fimMin),
    ]..sort((a, b) => a.inicio.compareTo(b.inicio));

    final agoraMin = d.agora.hour * 60 + d.agora.minute;
    var cursor = math.max(8 * 60, ((agoraMin + 29) ~/ 30) * 30);
    if (cursor > 20 * 60) cursor = 9 * 60;

    int acharVaga(int duracao) {
      var c = cursor;
      for (final o in ocupados) {
        if (c + duracao <= o.inicio) break;
        if (c < o.fim) c = ((o.fim + 14) ~/ 15) * 15;
      }
      c = c.clamp(6 * 60, 22 * 60 + 30);
      ocupados
        ..add(_Intervalo(c, c + duracao))
        ..sort((a, b) => a.inicio.compareTo(b.inicio));
      cursor = c + duracao + 15; // 15 min de respiro entre blocos
      return c;
    }

    for (final t in pendentesTarefas) {
      final dur = _duracaoItem('t:${t.tarefa.id}', padrao: 45);
      final inicio = acharVaga(dur);
      await _agendarTarefa(t, d.hoje, inicio ~/ 60, inicio % 60);
    }
    for (final h in pendentesHabitos) {
      final padrao = h.tipo == TipoHabito.duracao && h.alvo != null
          ? h.alvo!
          : 30;
      final dur = _duracaoItem('h:${h.id}', padrao: padrao);
      final inicio = acharVaga(dur);
      await _agendarHabito(h, inicio ~/ 60, inicio % 60);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Aurora distribuiu seus blocos nos intervalos livres de hoje!',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _iniciarFocoNoItem({
    required String titulo,
    required String detalhe,
    required int minutos,
  }) {
    if (ehAparelhoMovel) {
      _mostrarAvisoFocoExclusivoPc();
      return;
    }
    ControleFoco.instancia.prepararItem(
      titulo: titulo,
      detalhe: detalhe,
      minutos: minutos,
    );
    _definirModo(ModoHoje.foco);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuadroRotina>(
      stream: _quadro,
      builder: (context, snap) {
        if (snap.hasError)
          return Text('Não consegui ler a rotina: ${snap.error}');
        final q = snap.data;
        if (q == null) return const SizedBox(height: 200);
        return _conteudo(context, q);
      },
    );
  }

  Widget _conteudo(BuildContext context, QuadroRotina q) {
    final agora = agoraLocal();
    final hoje = dataLocal(agora);
    final d = _DadosTimeblocking(
      q: q,
      hoje: hoje,
      agora: agora,
      lerDuracao: _duracaoItem,
    );

    final itensParaSalaFoco = <({String titulo, String detalhe, int minutos})>[
      for (final b in d.blocosAgendados)
        if (!b.feito &&
            (b.tipo == _TipoBloco.tarefa || b.tipo == _TipoBloco.habito))
          (
            titulo: b.titulo,
            detalhe: '${b.horarioFormatado} · ${b.subtitulo}',
            minutos: b.duracaoMin,
          ),
      for (final t in d.tarefasSemHora)
        if (!t.feita)
          (
            titulo: t.tarefa.titulo,
            detalhe: t.atrasada ? 'Tarefa atrasada' : 'Tarefa para hoje',
            minutos: _duracaoItem('t:${t.tarefa.id}', padrao: 45),
          ),
      for (final h in d.habitosSemHora)
        if (!q.habitos.feito(h.id, hoje))
          (
            titulo: h.nome,
            detalhe: 'Hábito de hoje',
            minutos: _duracaoItem(
              'h:${h.id}',
              padrao: h.tipo == TipoHabito.duracao && h.alvo != null
                  ? h.alvo!
                  : 30,
            ),
          ),
    ];

    final modoAtual = ehAparelhoMovel ? ModoHoje.timeblocking : _modoAtual;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.ocultarCabecalho) ...[
          _Cabecalho(hoje: hoje, modo: modoAtual, aoMudarModo: _definirModo),
          const SizedBox(height: 16),
        ],
        if (modoAtual == ModoHoje.foco)
          SalaFocoImersivo(
            itensDisponiveis: itensParaSalaFoco,
            aoVoltarParaGrade: () => _definirModo(ModoHoje.timeblocking),
          )
        else
          LayoutBuilder(
            builder: (context, box) {
              final largo = box.maxWidth >= larguraTimeblocking;
              final colunaEsquerda = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CartaoCapacidade(
                    dados: d,
                    verCalendario: widget.verCalendario,
                    verLembretes: () => abrirTodosLembretes(context),
                  ),
                  const SizedBox(height: 14),
                  _PainelParaEncaixar(
                    dados: d,
                    db: _repo!.db,
                    lerDuracao: _duracaoItem,
                    aoCiclarDuracao: _ciclarDuracao,
                    aoEncaixarTarefa: (t) {
                      final dur = _duracaoItem('t:${t.tarefa.id}', padrao: 45);
                      final slot = _proximoSlotLivre(d, dur);
                      _agendarTarefa(t, hoje, slot.hora, slot.minuto);
                    },
                    aoEncaixarHabito: (h) {
                      final padrao =
                          h.tipo == TipoHabito.duracao && h.alvo != null
                          ? h.alvo!
                          : 30;
                      final dur = _duracaoItem('h:${h.id}', padrao: padrao);
                      final slot = _proximoSlotLivre(d, dur);
                      _agendarHabito(h, slot.hora, slot.minuto);
                    },
                    aoFocar: _iniciarFocoNoItem,
                  ),
                ],
              );

              final colunaDireita = _PainelLinhaDoTempo(
                dados: d,
                db: _repo!.db,
                aoAutoDistribuir: () => _autoDistribuir(d),
                aoFocarBloco: (b) => _iniciarFocoNoItem(
                  titulo: b.titulo,
                  detalhe: '${b.horarioFormatado} · ${b.subtitulo}',
                  minutos: b.duracaoMin,
                ),
                aoDesagendarBloco: (b) {
                  if (b.ocorrenciaTarefa != null) {
                    _desagendarTarefa(b.ocorrenciaTarefa!, hoje);
                  } else if (b.habito != null) {
                    _desagendarHabito(b.habito!);
                  }
                },
                aoEncaixarNoHorario: (horaSlot, minSlot) async {
                  final pendenteTarefa = d.tarefasSemHora
                      .where((t) => !t.feita)
                      .firstOrNull;
                  if (pendenteTarefa != null) {
                    await _agendarTarefa(
                      pendenteTarefa,
                      hoje,
                      horaSlot,
                      minSlot,
                    );
                    return;
                  }
                  final pendenteHabito = d.habitosSemHora
                      .where((h) => !q.habitos.feito(h.id, hoje))
                      .firstOrNull;
                  if (pendenteHabito != null) {
                    await _agendarHabito(pendenteHabito, horaSlot, minSlot);
                    return;
                  }
                  if (context.mounted) {
                    await abrirFormRotina(context, tipo: TipoRotina.tarefa);
                  }
                },
              );

              if (largo) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: colunaEsquerda),
                    const SizedBox(width: 16),
                    Expanded(flex: 7, child: colunaDireita),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  colunaEsquerda,
                  const SizedBox(height: 16),
                  colunaDireita,
                ],
              );
            },
          ),
      ],
    );
  }
}

class _Intervalo {
  const _Intervalo(this.inicio, this.fim);
  final int inicio;
  final int fim;
}

enum _TipoBloco { compromisso, tarefa, habito, lembrete }

class _BlocoAgenda {
  const _BlocoAgenda({
    required this.tipo,
    required this.titulo,
    required this.subtitulo,
    required this.inicioMin,
    required this.duracaoMin,
    required this.feito,
    this.ocorrenciaCompromisso,
    this.ocorrenciaTarefa,
    this.habito,
    this.lembreteDoDia,
  });

  final _TipoBloco tipo;
  final String titulo;
  final String subtitulo;
  final int inicioMin;
  final int duracaoMin;
  final bool feito;

  final OcorrenciaCompromisso? ocorrenciaCompromisso;
  final OcorrenciaTarefa? ocorrenciaTarefa;
  final Habito? habito;
  final LembreteDoDia? lembreteDoDia;

  int get fimMin => inicioMin + duracaoMin;

  String get horaInicio => _fmtMin(inicioMin);
  String get horaFim => _fmtMin(fimMin);
  String get horarioFormatado =>
      tipo == _TipoBloco.lembrete ? horaInicio : '$horaInicio — $horaFim';

  static String _fmtMin(int totalMin) {
    final h = (totalMin ~/ 60) % 24;
    final m = totalMin % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}

class _DadosTimeblocking {
  _DadosTimeblocking({
    required this.q,
    required this.hoje,
    required this.agora,
    required int Function(String chave, {int padrao}) lerDuracao,
  }) : compromissos = q.compromissos.doDia(hoje),
       fazer = q.fazer(hoje),
       habitos = q.habitos.doDia(hoje),
       lembretes = q.lembretesDoDia(hoje) {
    for (final c in compromissos) {
      if (c.diaInteiro) {
        compromissosDiaInteiro.add(c);
      } else {
        final ini = emLocal(c.inicio);
        final iniMin = ini.hour * 60 + ini.minute;
        final fimMin = c.fim != null
            ? (emLocal(c.fim!).hour * 60 + emLocal(c.fim!).minute)
            : iniMin + 60;
        final dur = math.max(15, fimMin - iniMin);
        blocosAgendados.add(
          _BlocoAgenda(
            tipo: _TipoBloco.compromisso,
            titulo: c.compromisso.titulo,
            subtitulo: c.compromisso.local ?? 'Compromisso fixo',
            inicioMin: iniMin,
            duracaoMin: dur,
            feito: c.terminou(agora),
            ocorrenciaCompromisso: c,
          ),
        );
      }
    }

    for (final t in fazer) {
      final h = t.horario;
      if (h != null && t.dia == hoje) {
        final iniMin = h.hora * 60 + h.minuto;
        final dur = lerDuracao('t:${t.tarefa.id}', padrao: 45);
        blocosAgendados.add(
          _BlocoAgenda(
            tipo: _TipoBloco.tarefa,
            titulo: t.tarefa.titulo,
            subtitulo: t.objetivo != null
                ? t.objetivo!.nome
                : 'Bloco de foco · Tarefa',
            inicioMin: iniMin,
            duracaoMin: dur,
            feito: t.feita,
            ocorrenciaTarefa: t,
          ),
        );
      } else {
        tarefasSemHora.add(t);
      }
    }

    for (final h in habitos) {
      final partes = h.horario?.split(':');
      final feito = q.habitos.feito(h.id, hoje);
      if (partes != null && partes.length == 2) {
        final hh = int.tryParse(partes[0]);
        final mm = int.tryParse(partes[1]);
        if (hh != null && mm != null) {
          final padrao = h.tipo == TipoHabito.duracao && h.alvo != null
              ? h.alvo!
              : 30;
          final dur = lerDuracao('h:${h.id}', padrao: padrao);
          blocosAgendados.add(
            _BlocoAgenda(
              tipo: _TipoBloco.habito,
              titulo: h.nome,
              subtitulo: detalheHabito(
                h,
                sequencia: q.habitos.sequencia(h, hoje),
              ),
              inicioMin: hh * 60 + mm,
              duracaoMin: dur,
              feito: feito,
              habito: h,
            ),
          );
          continue;
        }
      }
      habitosSemHora.add(h);
    }

    for (final l in lembretes) {
      final t = emLocal(l.toque);
      blocosAgendados.add(
        _BlocoAgenda(
          tipo: _TipoBloco.lembrete,
          titulo: l.lembrete.texto,
          subtitulo: l.lembrete.despertar
              ? 'Lembrete · Despertador'
              : 'Lembrete',
          inicioMin: t.hour * 60 + t.minute,
          duracaoMin: 15,
          feito: !l.toque.isAfter(agora),
          lembreteDoDia: l,
        ),
      );
    }

    blocosAgendados.sort((a, b) => a.inicioMin.compareTo(b.inicioMin));
  }

  final QuadroRotina q;
  final DateTime hoje;
  final DateTime agora;
  final List<OcorrenciaCompromisso> compromissos;
  final List<OcorrenciaTarefa> fazer;
  final List<Habito> habitos;
  final List<LembreteDoDia> lembretes;

  final List<OcorrenciaCompromisso> compromissosDiaInteiro = [];
  final List<_BlocoAgenda> blocosAgendados = [];
  final List<OcorrenciaTarefa> tarefasSemHora = [];
  final List<Habito> habitosSemHora = [];

  int get fazerFeitas => fazer.where((o) => o.feita).length;
  int get habitosFeitos =>
      habitos.where((h) => q.habitos.feito(h.id, hoje)).length;
  int get atrasadas => fazer.where((o) => o.atrasada && !o.feita).length;

  int get minutosCompromissos => blocosAgendados
      .where((b) => b.tipo == _TipoBloco.compromisso)
      .fold(0, (s, b) => s + b.duracaoMin);

  int get minutosFocoAgendados => blocosAgendados
      .where((b) => b.tipo == _TipoBloco.tarefa || b.tipo == _TipoBloco.habito)
      .fold(0, (s, b) => s + b.duracaoMin);

  int get totalMinutosPlanejados => minutosCompromissos + minutosFocoAgendados;

  /// Capacidade diária saudável de referência (6 horas = 360 min).
  static const capacidadeAlvoMin = 360;

  int get minutosLivres =>
      math.max(0, capacidadeAlvoMin - totalMinutosPlanejados);

  /// Maior janela livre entre 08:00 e 20:00 para a sugestão da Aurora.
  ({int inicioMin, int fimMin, int duracaoMin}) get melhorJanelaLivre {
    var cursor = math.max(
      8 * 60,
      ((agora.hour * 60 + agora.minute + 29) ~/ 30) * 30,
    );
    if (cursor >= 19 * 60) cursor = 8 * 60;
    const limite = 20 * 60;

    var melhorIni = cursor;
    var melhorFim = cursor + 60;
    var maiorDur = 0;

    for (final b in blocosAgendados) {
      if (b.fimMin <= cursor) continue;
      if (b.inicioMin > cursor) {
        final fimJanela = math.min(b.inicioMin, limite);
        final dur = fimJanela - cursor;
        if (dur > maiorDur) {
          maiorDur = dur;
          melhorIni = cursor;
          melhorFim = fimJanela;
        }
      }
      cursor = math.max(cursor, b.fimMin);
      if (cursor >= limite) break;
    }
    if (cursor < limite && limite - cursor > maiorDur) {
      maiorDur = limite - cursor;
      melhorIni = cursor;
      melhorFim = limite;
    }
    return (
      inicioMin: melhorIni,
      fimMin: melhorFim,
      duracaoMin: math.max(30, maiorDur),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({
    required this.hoje,
    required this.modo,
    required this.aoMudarModo,
  });

  final DateTime hoje;
  final ModoHoje modo;
  final ValueChanged<ModoHoje> aoMudarModo;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hoje', style: sora(24)),
                  Text(
                    '${DateFormat('EEEE', 'pt_BR').format(hoje).capitalizar()}, ${diaMesLongo(hoje)}',
                    style: manrope(13, cor: c.muted),
                  ),
                ],
              ),
            ),
            BotaoNovoRotina(aoTocar: () => abrirFormRotina(context)),
          ],
        ),
        const SizedBox(height: 14),
        SubAbas<ModoHoje>(
          opcoes: ModoHoje.values,
          selecionado: modo,
          rotulo: (m) => m.rotulo,
          icone: (m) => m.icone,
          desabilitado: (m) => m == ModoHoje.foco && ehAparelhoMovel,
          aoTocarDesabilitado: (m) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.desktop_windows_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'O Foco Imersivo é exclusivo para PC para manter seu celular leve e economizar bateria.',
                      ),
                    ),
                  ],
                ),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 4),
              ),
            );
          },
          sufixo: (m) => m == ModoHoje.foco
              ? Tooltip(
                  message: ehAparelhoMovel
                      ? 'Exclusivo no PC · Para não pesar no celular'
                      : 'Esse recurso é melhor aproveitado no PC',
                  triggerMode: TooltipTriggerMode.tap,
                  waitDuration: const Duration(milliseconds: 200),
                  showDuration: const Duration(seconds: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.desktop_windows_outlined,
                        size: 14,
                        color: ehAparelhoMovel
                            ? c.muted.withValues(alpha: 0.40)
                            : (modo == ModoHoje.foco ? c.accent : c.muted),
                      ),
                      if (ehAparelhoMovel) ...[
                        const SizedBox(width: 4),
                        Text(
                          'Só PC',
                          style: manrope(
                            11,
                            peso: FontWeight.w700,
                            cor: c.muted.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : null,
          aoEscolher: aoMudarModo,
        ),
      ],
    );
  }
}

/// "+ Novo" da Rotina: abre a folha única no tipo tarefa.
class BotaoNovoRotina extends StatelessWidget {
  const BotaoNovoRotina({super.key, required this.aoTocar});
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Semantics(
      button: true,
      label: 'Novo na rotina',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(gradient: c.gradiente),
          child: InkWell(
            onTap: aoTocar,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 20, color: c.noAccent),
                  const SizedBox(width: 6),
                  Text(
                    'Novo',
                    style: manrope(14, peso: FontWeight.w700, cor: c.noAccent),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CartaoCapacidade extends StatelessWidget {
  const _CartaoCapacidade({
    required this.dados,
    required this.verCalendario,
    required this.verLembretes,
  });

  final _DadosTimeblocking dados;
  final VoidCallback verCalendario;
  final VoidCallback verLembretes;

  String _fmtDuracao(int min) {
    final h = min ~/ 60;
    final m = min % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h 00m';
    return '${h}h ${m.toString().padLeft(2, '0')}m';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final planejado = dados.totalMinutosPlanejados;
    final alvo = _DadosTimeblocking.capacidadeAlvoMin;
    final (rotuloEstado, corEstado) = planejado <= alvo
        ? ('Dia Equilibrado', c.teal)
        : (planejado <= 480
              ? ('Dia Intenso', c.warn)
              : ('Dia Sobrecarregado', c.bad));

    final fracFixa = (dados.minutosCompromissos / alvo).clamp(0.0, 1.0);
    final fracFoco = (dados.minutosFocoAgendados / alvo).clamp(
      0.0,
      1.0 - fracFixa,
    );

    final totalItens = dados.fazer.length + dados.habitos.length;
    final feitosItens = dados.fazerFeitas + dados.habitosFeitos;

    return Cartao(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'CAPACIDADE DO SEU DIA',
                  style: manrope(
                    11,
                    peso: FontWeight.w800,
                    cor: c.teal,
                    espaco: 1.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: corEstado.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: corEstado.withValues(alpha: 0.35)),
                ),
                child: Text(
                  rotuloEstado,
                  style: manrope(11.5, peso: FontWeight.w700, cor: corEstado),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(_fmtDuracao(planejado), style: sora(24)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'planejadas · ${_fmtDuracao(dados.minutosLivres)} livres de 6h',
                  style: manrope(12.5, cor: c.muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Barra segmentada de ocupação do dia
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  if (fracFixa > 0)
                    Expanded(
                      flex: (fracFixa * 1000).round().clamp(1, 1000),
                      child: ColoredBox(color: c.corCompromisso),
                    ),
                  if (fracFoco > 0)
                    Expanded(
                      flex: (fracFoco * 1000).round().clamp(1, 1000),
                      child: ColoredBox(color: c.corHabito),
                    ),
                  if (1.0 - fracFixa - fracFoco > 0)
                    Expanded(
                      flex: ((1.0 - fracFixa - fracFoco) * 1000).round().clamp(
                        1,
                        1000,
                      ),
                      child: ColoredBox(color: c.surface2),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _LegendaPonto(
                cor: c.corCompromisso,
                texto:
                    'Compromissos (${_fmtDuracao(dados.minutosCompromissos)})',
              ),
              _LegendaPonto(
                cor: c.corHabito,
                texto:
                    'Blocos Focados (${_fmtDuracao(dados.minutosFocoAgendados)})',
              ),
              _LegendaPonto(
                cor: c.muted,
                texto: '$feitosItens/$totalItens concluídos hoje',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: c.line.withValues(alpha: 0.6)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _AtalhoPequeno(
                icone: Icons.calendar_month_rounded,
                texto: 'Ver no calendário',
                aoTocar: verCalendario,
              ),
              _AtalhoPequeno(
                icone: Icons.notifications_none_rounded,
                texto: 'Todos os lembretes',
                aoTocar: verLembretes,
              ),
              if (dados.atrasadas > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: c.bad.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    dados.atrasadas == 1
                        ? '1 atrasada'
                        : '${dados.atrasadas} atrasadas',
                    style: manrope(12, peso: FontWeight.w700, cor: c.bad),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendaPonto extends StatelessWidget {
  const _LegendaPonto({required this.cor, required this.texto});
  final Color cor;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(texto, style: manrope(11.5, cor: c.muted)),
      ],
    );
  }
}

class _AtalhoPequeno extends StatelessWidget {
  const _AtalhoPequeno({
    required this.icone,
    required this.texto,
    required this.aoTocar,
  });

  final IconData icone;
  final String texto;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Material(
      color: c.surface2.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone, size: 15, color: c.muted),
              const SizedBox(width: 5),
              Text(
                texto,
                style: manrope(12, peso: FontWeight.w600, cor: c.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PainelParaEncaixar extends StatelessWidget {
  const _PainelParaEncaixar({
    required this.dados,
    required this.db,
    required this.lerDuracao,
    required this.aoCiclarDuracao,
    required this.aoEncaixarTarefa,
    required this.aoEncaixarHabito,
    required this.aoFocar,
  });

  final _DadosTimeblocking dados;
  final BancoAurora db;
  final int Function(String chave, {int padrao}) lerDuracao;
  final void Function(String chave, {int padrao}) aoCiclarDuracao;
  final ValueChanged<OcorrenciaTarefa> aoEncaixarTarefa;
  final ValueChanged<Habito> aoEncaixarHabito;
  final void Function({
    required String titulo,
    required String detalhe,
    required int minutos,
  })
  aoFocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final hoje = dados.hoje;
    final janela = dados.melhorJanelaLivre;
    final iniJanela = _BlocoAgenda._fmtMin(janela.inicioMin);
    final fimJanela = _BlocoAgenda._fmtMin(janela.fimMin);

    final semItens =
        dados.tarefasSemHora.isEmpty && dados.habitosSemHora.isEmpty;

    return Cartao(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tarefas e Hábitos de Hoje', style: sora(16)),
                    const SizedBox(height: 2),
                    Text(
                      'Toque em "+ Encaixar" para agendar na grade ou inicie o foco',
                      style: manrope(12, cor: c.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _AtalhoPequeno(
                icone: Icons.add_rounded,
                texto: 'Nova',
                aoTocar: () =>
                    abrirFormRotina(context, tipo: TipoRotina.tarefa),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (semItens)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Text(
                'Tudo encaixado na linha do tempo! Use "+ Novo" se quiser criar mais itens.',
                textAlign: TextAlign.center,
                style: manrope(13, cor: c.muted),
              ),
            ),
          for (final o in dados.tarefasSemHora)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ItemCaixaTimeblocking(
                titulo: o.tarefa.titulo,
                subtitulo: o.atrasada
                    ? 'Tarefa atrasada'
                    : (o.objetivo != null ? o.objetivo!.nome : 'Tarefa'),
                corTipo: o.atrasada ? c.bad : c.corTarefa,
                feito: o.feita,
                quadrado: true,
                duracaoMin: lerDuracao('t:${o.tarefa.id}', padrao: 45),
                aoAlternarFeito: () => TarefasRepo(db).alternar(o, !o.feita),
                aoCiclarDuracao: () =>
                    aoCiclarDuracao('t:${o.tarefa.id}', padrao: 45),
                aoEncaixar: () => aoEncaixarTarefa(o),
                aoFocar: () => aoFocar(
                  titulo: o.tarefa.titulo,
                  detalhe: 'Tarefa de hoje',
                  minutos: lerDuracao('t:${o.tarefa.id}', padrao: 45),
                ),
                aoEditar: () => abrirFormRotina(context, item: o.tarefa),
              ),
            ),
          for (final h in dados.habitosSemHora)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ItemCaixaTimeblocking(
                titulo: h.nome,
                subtitulo: detalheHabito(
                  h,
                  sequencia: dados.q.habitos.sequencia(h, hoje),
                ),
                corTipo: c.corHabito,
                feito: dados.q.habitos.feito(h.id, hoje),
                quadrado: false,
                duracaoMin: lerDuracao(
                  'h:${h.id}',
                  padrao: h.tipo == TipoHabito.duracao && h.alvo != null
                      ? h.alvo!
                      : 30,
                ),
                aoAlternarFeito: () => HabitosRepo(db)
                    .alternar(h.id, hoje, !dados.q.habitos.feito(h.id, hoje)),
                aoCiclarDuracao: () => aoCiclarDuracao(
                  'h:${h.id}',
                  padrao: h.tipo == TipoHabito.duracao && h.alvo != null
                      ? h.alvo!
                      : 30,
                ),
                aoEncaixar: () => aoEncaixarHabito(h),
                aoFocar: () => aoFocar(
                  titulo: h.nome,
                  detalhe: 'Hábito de hoje',
                  minutos: lerDuracao(
                    'h:${h.id}',
                    padrao: h.tipo == TipoHabito.duracao && h.alvo != null
                        ? h.alvo!
                        : 30,
                  ),
                ),
                aoEditar: () => abrirFormRotina(context, item: h),
              ),
            ),
          const SizedBox(height: 8),
          Divider(height: 1, color: c.line.withValues(alpha: 0.6)),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: c.gradiente,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  'AI',
                  style: manrope(10, peso: FontWeight.w800, cor: c.noAccent),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Dica da Aurora: janela livre entre $iniJanela e $fimJanela (${janela.duracaoMin} min disponíveis).',
                  style: manrope(12, cor: c.muted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemCaixaTimeblocking extends StatelessWidget {
  const _ItemCaixaTimeblocking({
    required this.titulo,
    required this.subtitulo,
    required this.corTipo,
    required this.feito,
    required this.quadrado,
    required this.duracaoMin,
    required this.aoAlternarFeito,
    required this.aoCiclarDuracao,
    required this.aoEncaixar,
    required this.aoFocar,
    required this.aoEditar,
  });

  final String titulo;
  final String subtitulo;
  final Color corTipo;
  final bool feito;
  final bool quadrado;
  final int duracaoMin;
  final VoidCallback aoAlternarFeito;
  final VoidCallback aoCiclarDuracao;
  final VoidCallback aoEncaixar;
  final VoidCallback aoFocar;
  final VoidCallback aoEditar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Opacity(
      opacity: feito ? 0.55 : 1,
      child: Cartao(
        sombra: false,
        raio: 14,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        aoTocar: aoEditar,
        child: Row(
          children: [
            GestureDetector(
              onTap: aoAlternarFeito,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: MarcaConcluir(
                  feito: feito,
                  cor: corTipo,
                  quadrado: quadrado,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: manrope(14, peso: FontWeight.w600).copyWith(
                      decoration: feito ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: aoCiclarDuracao,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: corTipo.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$duracaoMin min',
                            style: manrope(
                              11,
                              peso: FontWeight.w700,
                              cor: corTipo,
                            ),
                          ),
                        ),
                      ),
                      Text(subtitulo, style: manrope(11.5, cor: c.muted)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              tooltip: 'Focar em $titulo',
              onPressed: aoFocar,
              icon: Icon(
                Icons.play_circle_outline_rounded,
                size: 20,
                color: c.accent,
              ),
              visualDensity: VisualDensity.compact,
            ),
            Semantics(
              button: true,
              label: 'Encaixar $titulo',
              child: Material(
                color: c.teal.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: aoEncaixar,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    child: Text(
                      '+ Encaixar',
                      style: manrope(11.5, peso: FontWeight.w700, cor: c.teal),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PainelLinhaDoTempo extends StatelessWidget {
  const _PainelLinhaDoTempo({
    required this.dados,
    required this.db,
    required this.aoAutoDistribuir,
    required this.aoFocarBloco,
    required this.aoDesagendarBloco,
    required this.aoEncaixarNoHorario,
  });

  final _DadosTimeblocking dados;
  final BancoAurora db;
  final VoidCallback aoAutoDistribuir;
  final ValueChanged<_BlocoAgenda> aoFocarBloco;
  final ValueChanged<_BlocoAgenda> aoDesagendarBloco;
  final void Function(int hora, int minuto) aoEncaixarNoHorario;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final agoraMin = dados.agora.hour * 60 + dados.agora.minute;
    final blocos = dados.blocosAgendados;

    // Monta a sequência da linha do tempo com marcador "Agora" e janelas livres.
    final elementos = <Widget>[];
    var mostrouAgora = false;

    for (final comp in dados.compromissosDiaInteiro) {
      elementos.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: LinhaCompromisso(
            ocorrencia: comp,
            agora: dados.agora,
            aoEditar: () =>
                abrirFormCompromisso(context, compromisso: comp.compromisso),
          ),
        ),
      );
    }

    var cursorMin = 8 * 60;
    for (final b in blocos) {
      if (!mostrouAgora && agoraMin <= b.inicioMin) {
        elementos.add(_MarcadorAgora(horaTexto: hora(dados.agora)));
        mostrouAgora = true;
      }

      if (b.inicioMin - cursorMin >= 45 && b.inicioMin >= 8 * 60) {
        final durLivre = b.inicioMin - cursorMin;
        final hSlot = cursorMin ~/ 60;
        final mSlot = cursorMin % 60;
        elementos.add(
          _FaixaIntervaloLivre(
            horarioInicio: _BlocoAgenda._fmtMin(cursorMin),
            duracaoMin: durLivre,
            aoTocar: () => aoEncaixarNoHorario(hSlot, mSlot),
          ),
        );
      }

      elementos.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _CartaoBlocoLinha(
            bloco: b,
            hoje: dados.hoje,
            db: db,
            aoFocar: () => aoFocarBloco(b),
            aoDesagendar: () => aoDesagendarBloco(b),
          ),
        ),
      );

      cursorMin = math.max(cursorMin, b.fimMin);
    }

    if (!mostrouAgora) {
      elementos.add(_MarcadorAgora(horaTexto: hora(dados.agora)));
    }

    if (blocos.isEmpty) {
      elementos.add(
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: _FaixaIntervaloLivre(
            horarioInicio: '09:00',
            duracaoMin: 180,
            aoTocar: () => aoEncaixarNoHorario(9, 0),
          ),
        ),
      );
    }

    return Cartao(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('Linha do Tempo de Hoje', style: sora(16)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: c.surface2,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        DateFormat(
                          'EEEE',
                          'pt_BR',
                        ).format(dados.hoje).capitalizar(),
                        style: manrope(
                          11.5,
                          peso: FontWeight.w600,
                          cor: c.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Semantics(
                button: true,
                label: 'Auto-Distribuir por IA',
                child: Material(
                  color: c.teal.withValues(alpha: 0.14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: c.teal.withValues(alpha: 0.35)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: aoAutoDistribuir,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt_rounded, size: 16, color: c.teal),
                          const SizedBox(width: 4),
                          Text(
                            'Auto-Distribuir por IA',
                            style: manrope(
                              12,
                              peso: FontWeight.w700,
                              cor: c.teal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: c.line.withValues(alpha: 0.6)),
          const SizedBox(height: 14),
          ...elementos,
        ],
      ),
    );
  }
}

class _MarcadorAgora extends StatelessWidget {
  const _MarcadorAgora({required this.horaTexto});
  final String horaTexto;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 46,
            child: Text(
              horaTexto,
              style: manrope(12, peso: FontWeight.w800, cor: c.bad),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: c.bad, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(height: 1.5, color: c.bad.withValues(alpha: 0.55)),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: c.bad.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Agora',
              style: manrope(10.5, peso: FontWeight.w700, cor: c.bad),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaixaIntervaloLivre extends StatelessWidget {
  const _FaixaIntervaloLivre({
    required this.horarioInicio,
    required this.duracaoMin,
    required this.aoTocar,
  });

  final String horarioInicio;
  final int duracaoMin;
  final VoidCallback aoTocar;

  String get _rotuloDuracao {
    if (duracaoMin < 60) return '$duracaoMin min';
    final h = duracaoMin ~/ 60;
    final m = duracaoMin % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 46,
            child: Text(horarioInicio, style: manrope(12, cor: c.muted)),
          ),
          Expanded(
            child: Material(
              color: c.surface2.withValues(alpha: 0.30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: c.line),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: aoTocar,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Intervalo livre ($_rotuloDuracao)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: manrope(12, cor: c.muted),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '+ Encaixar',
                        style: manrope(
                          11.5,
                          peso: FontWeight.w700,
                          cor: c.teal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartaoBlocoLinha extends StatelessWidget {
  const _CartaoBlocoLinha({
    required this.bloco,
    required this.hoje,
    required this.db,
    required this.aoFocar,
    required this.aoDesagendar,
  });

  final _BlocoAgenda bloco;
  final DateTime hoje;
  final BancoAurora db;
  final VoidCallback aoFocar;
  final VoidCallback aoDesagendar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final (cor, etiqueta) = switch (bloco.tipo) {
      _TipoBloco.compromisso => (c.corCompromisso, 'Compromisso'),
      _TipoBloco.tarefa => (c.corTarefa, 'Bloco de Foco'),
      _TipoBloco.habito => (c.corHabito, 'Hábito'),
      _TipoBloco.lembrete => (c.corLembrete, 'Lembrete'),
    };

    void editar() {
      if (bloco.ocorrenciaCompromisso != null) {
        abrirFormCompromisso(
          context,
          compromisso: bloco.ocorrenciaCompromisso!.compromisso,
        );
      } else if (bloco.ocorrenciaTarefa != null) {
        abrirFormRotina(context, item: bloco.ocorrenciaTarefa!.tarefa);
      } else if (bloco.habito != null) {
        abrirFormRotina(context, item: bloco.habito!);
      } else if (bloco.lembreteDoDia != null) {
        abrirFormRotina(context, item: bloco.lembreteDoDia!.lembrete);
      }
    }

    void alternarConclusao() {
      if (bloco.ocorrenciaTarefa != null) {
        TarefasRepo(db).alternar(bloco.ocorrenciaTarefa!, !bloco.feito);
      } else if (bloco.habito != null) {
        HabitosRepo(db).alternar(bloco.habito!.id, hoje, !bloco.feito);
      } else if (bloco.lembreteDoDia != null) {
        final l = bloco.lembreteDoDia!.lembrete;
        LembretesRepo(db).alternarAtivo(l.id, !l.ativo);
      }
    }

    final podeFocar =
        bloco.tipo == _TipoBloco.tarefa || bloco.tipo == _TipoBloco.habito;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 46,
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              bloco.horaInicio,
              style: manrope(12, peso: FontWeight.w700, cor: c.muted),
            ),
          ),
        ),
        Expanded(
          child: Opacity(
            opacity: bloco.feito ? 0.6 : 1,
            child: Cartao(
              sombra: false,
              raio: 14,
              padding: EdgeInsets.zero,
              aoTocar: editar,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: cor,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(14),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                        child: Row(
                          children: [
                            if (podeFocar)
                              GestureDetector(
                                onTap: alternarConclusao,
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: MarcaConcluir(
                                    feito: bloco.feito,
                                    cor: cor,
                                    quadrado: bloco.tipo == _TipoBloco.tarefa,
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        bloco.titulo,
                                        style:
                                            manrope(
                                              14,
                                              peso: FontWeight.w700,
                                            ).copyWith(
                                              decoration:
                                                  bloco.feito && podeFocar
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: cor.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          etiqueta,
                                          style: manrope(
                                            10.5,
                                            peso: FontWeight.w700,
                                            cor: cor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${bloco.horarioFormatado} · ${bloco.duracaoMin} min · ${bloco.subtitulo}',
                                    style: manrope(11.5, cor: c.muted),
                                  ),
                                ],
                              ),
                            ),
                            if (podeFocar && !bloco.feito) ...[
                              const SizedBox(width: 6),
                              Semantics(
                                button: true,
                                label: 'Iniciar foco em ${bloco.titulo}',
                                child: Material(
                                  color: c.teal,
                                  borderRadius: BorderRadius.circular(8),
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    onTap: aoFocar,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 6,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.play_arrow_rounded,
                                            size: 14,
                                            color: c.noAccent,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            'Focar',
                                            style: manrope(
                                              11.5,
                                              peso: FontWeight.w800,
                                              cor: c.noAccent,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Tooltip(
                                message: 'Tirar do horário',
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: aoDesagendar,
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 16,
                                      color: c.muted,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

extension on String {
  String capitalizar() => isEmpty ? this : this[0].toUpperCase() + substring(1);
}
