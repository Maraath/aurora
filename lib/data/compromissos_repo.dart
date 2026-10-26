import 'package:drift/drift.dart';

import '../core/formato.dart';
import '../core/recorrencia.dart';
import '../core/relogio.dart';
import 'banco.dart';
import 'observar.dart';

/// Um dia de um compromisso (o próprio, ou uma das repetições da regra).
class OcorrenciaCompromisso {
  const OcorrenciaCompromisso({required this.compromisso, required this.dia, required this.inicio, this.fim});

  final Compromisso compromisso;

  /// Data de calendário (fuso do aparelho).
  final DateTime dia;

  /// Instantes desta ocorrência (no dia inteiro, a meia-noite do dia).
  final DateTime inicio;
  final DateTime? fim;

  bool get diaInteiro => compromisso.diaInteiro;
  Regra? get regra => Regra.ler(compromisso.regraRepeticao);

  /// Acontecendo agora (entre o começo e o fim; sem fim, a primeira hora).
  bool emAndamento(DateTime agora) {
    if (diaInteiro) return dataLocal(agora) == dia;
    final ate = fim ?? inicio.add(const Duration(hours: 1));
    return !agora.isBefore(inicio) && agora.isBefore(ate);
  }

  /// Já terminou (dia inteiro: o dia passou).
  bool terminou(DateTime agora) {
    if (diaInteiro) return dia.isBefore(dataLocal(agora));
    return !(fim ?? inicio.add(const Duration(hours: 1))).isAfter(agora);
  }

  /// "12:00–14:00", "19:30" ou "Dia todo".
  String get horario {
    if (diaInteiro) return 'Dia todo';
    final i = emLocal(inicio);
    if (fim == null) return hora(i);
    return '${hora(i)}–${hora(emLocal(fim!))}';
  }
}

/// Fotografia dos compromissos para as telas.
class QuadroCompromissos {
  const QuadroCompromissos(this.todos);
  final List<Compromisso> todos;

  /// Ocorrências de cada dia do período (datas de calendário, inclusive).
  Map<DateTime, List<OcorrenciaCompromisso>> porDia(DateTime de, DateTime ate) {
    final mapa = <DateTime, List<OcorrenciaCompromisso>>{};
    for (final c in todos) {
      for (final o in ocorrenciasCompromisso(c, de, ate)) {
        mapa.putIfAbsent(o.dia, () => []).add(o);
      }
    }
    for (final l in mapa.values) {
      l.sort(compararCompromissos);
    }
    return mapa;
  }

  List<OcorrenciaCompromisso> doDia(DateTime dia) => porDia(dia, dia)[dia] ?? const [];

  /// Próximas ocorrências que ainda não terminaram, em ordem.
  List<OcorrenciaCompromisso> proximos(DateTime agora, {int dias = 30}) {
    final hoje = dataLocal(agora);
    final mapa = porDia(hoje, somarDias(hoje, dias));
    return [
      for (final d in mapa.keys.toList()..sort())
        for (final o in mapa[d]!)
          if (!o.terminou(agora)) o,
    ];
  }
}

/// Dia inteiro primeiro, depois pela hora de começo.
int compararCompromissos(OcorrenciaCompromisso a, OcorrenciaCompromisso b) {
  if (a.diaInteiro != b.diaInteiro) return a.diaInteiro ? -1 : 1;
  final i = a.inicio.compareTo(b.inicio);
  return i != 0 ? i : a.compromisso.titulo.compareTo(b.compromisso.titulo);
}

/// Ocorrências de [c] entre as datas [de] e [ate] (inclusive). A duração da
/// primeira vale para as repetições.
Iterable<OcorrenciaCompromisso> ocorrenciasCompromisso(Compromisso c, DateTime de, DateTime ate) sync* {
  final base = emLocal(c.inicio);
  final primeiroDia = DateTime(base.year, base.month, base.day);
  final duracao = c.fim?.difference(c.inicio);
  final regra = Regra.ler(c.regraRepeticao);
  final dias = regra == null
      ? [if (!primeiroDia.isBefore(de) && !primeiroDia.isAfter(ate)) primeiroDia]
      : regra.ocorrencias(primeiroDia, de, ate);
  for (final d in dias) {
    final inicio = c.diaInteiro ? instanteLocal(d) : instanteLocal(d, base.hour, base.minute);
    yield OcorrenciaCompromisso(
      compromisso: c,
      dia: d,
      inicio: inicio,
      fim: duracao == null || c.diaInteiro ? null : inicio.add(duracao),
    );
  }
}

class CompromissosRepo {
  CompromissosRepo(this.db);
  final BancoAurora db;

  Stream<QuadroCompromissos> observarQuadro() => observar(db, [db.compromissos], carregar);

  Future<QuadroCompromissos> carregar() async => QuadroCompromissos(
        await (db.select(db.compromissos)..where((c) => c.apagadoEm.isNull())).get(),
      );

  /// Cria ou atualiza; devolve o id.
  Future<String> salvar(CompromissosCompanion dados, {String? id}) async {
    if (id == null) return (await db.into(db.compromissos).insertReturning(dados)).id;
    await (db.update(db.compromissos)..where((c) => c.id.equals(id)))
        .write(dados.copyWith(atualizadoEm: Value(DateTime.now())));
    return id;
  }

  Future<void> excluir(String id) {
    final agora = DateTime.now();
    return (db.update(db.compromissos)..where((c) => c.id.equals(id)))
        .write(CompromissosCompanion(apagadoEm: Value(agora), atualizadoEm: Value(agora)));
  }
}
