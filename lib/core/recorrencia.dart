/// Regras de repetição no padrão RRULE de calendário (subconjunto):
/// `FREQ=DAILY`, `FREQ=WEEKLY;BYDAY=MO,WE,FR`, `FREQ=MONTHLY;BYMONTHDAY=11`,
/// com `INTERVAL=n` opcional.
///
/// Uma regra NUNCA vira uma linha por dia no banco: as ocorrências são
/// calculadas a partir da data inicial (o "prazo" ou "quando" do item).
library;

enum Frequencia { diaria, semanal, mensal }

const _siglas = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
const _nomesDia = ['segunda', 'terça', 'quarta', 'quinta', 'sexta', 'sábado', 'domingo'];
const _curtosDia = ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];

/// Bits de segunda (1) a domingo (64), igual a `Habitos.diasSemana`.
const todosOsDias = 127;
const diasUteis = 31;

int bitDoDiaDaSemana(DateTime d) => 1 << (d.weekday - 1);

class Regra {
  const Regra._(this.frequencia, {this.intervalo = 1, this.dias = 0, this.diaDoMes});

  const Regra.diaria({int intervalo = 1}) : this._(Frequencia.diaria, intervalo: intervalo);

  /// [dias]: bits de segunda (1) a domingo (64).
  const Regra.semanal(int dias, {int intervalo = 1})
      : this._(Frequencia.semanal, dias: dias, intervalo: intervalo);

  const Regra.mensal(int diaDoMes, {int intervalo = 1})
      : this._(Frequencia.mensal, diaDoMes: diaDoMes, intervalo: intervalo);

  final Frequencia frequencia;
  final int intervalo;
  final int dias;
  final int? diaDoMes;

  /// Lê uma regra RRULE. Retorna nulo para texto vazio ou não suportado.
  static Regra? ler(String? texto) {
    if (texto == null || texto.trim().isEmpty) return null;
    final partes = <String, String>{};
    for (final p in texto.replaceFirst('RRULE:', '').split(';')) {
      final i = p.indexOf('=');
      if (i > 0) partes[p.substring(0, i).toUpperCase()] = p.substring(i + 1).toUpperCase();
    }
    final intervalo = int.tryParse(partes['INTERVAL'] ?? '') ?? 1;
    switch (partes['FREQ']) {
      case 'DAILY':
        return Regra.diaria(intervalo: intervalo);
      case 'WEEKLY':
        var bits = 0;
        for (final s in (partes['BYDAY'] ?? '').split(',')) {
          final i = _siglas.indexOf(s.trim());
          if (i >= 0) bits |= 1 << i;
        }
        return Regra.semanal(bits, intervalo: intervalo);
      case 'MONTHLY':
        final dia = int.tryParse(partes['BYMONTHDAY'] ?? '');
        return dia == null ? null : Regra.mensal(dia, intervalo: intervalo);
    }
    return null;
  }

  String get rrule {
    final intervaloTxt = intervalo > 1 ? ';INTERVAL=$intervalo' : '';
    return switch (frequencia) {
      Frequencia.diaria => 'FREQ=DAILY$intervaloTxt',
      Frequencia.semanal =>
        'FREQ=WEEKLY;BYDAY=${[for (var i = 0; i < 7; i++) if (dias & (1 << i) != 0) _siglas[i]].join(',')}$intervaloTxt',
      Frequencia.mensal => 'FREQ=MONTHLY;BYMONTHDAY=$diaDoMes$intervaloTxt',
    };
  }

  @override
  String toString() => rrule;

  @override
  bool operator ==(Object other) => other is Regra && other.rrule == rrule;

  @override
  int get hashCode => rrule.hashCode;

  /// A regra gera uma ocorrência no [dia], contando a partir de [inicio]?
  /// Só a data importa (ano, mês, dia); as horas são ignoradas.
  bool ocorreEm(DateTime dia, DateTime inicio) {
    final d = _soData(dia);
    final i = _soData(inicio);
    if (d.isBefore(i)) return false;
    switch (frequencia) {
      case Frequencia.diaria:
        return _diasEntre(i, d) % intervalo == 0;
      case Frequencia.semanal:
        final bits = dias == 0 ? bitDoDiaDaSemana(i) : dias;
        if (bits & bitDoDiaDaSemana(d) == 0) return false;
        final semanas = _diasEntre(_segunda(i), _segunda(d)) ~/ 7;
        return semanas % intervalo == 0;
      case Frequencia.mensal:
        final meses = (d.year - i.year) * 12 + d.month - i.month;
        if (meses % intervalo != 0) return false;
        // Dia 31 em mês curto cai no último dia do mês.
        final ultimo = DateTime(d.year, d.month + 1, 0).day;
        final alvo = (diaDoMes ?? i.day).clamp(1, ultimo);
        return d.day == alvo;
    }
  }

  /// Datas (sem hora) das ocorrências entre [de] e [ate], inclusive.
  Iterable<DateTime> ocorrencias(DateTime inicio, DateTime de, DateTime ate) sync* {
    var d = _soData(de);
    final fim = _soData(ate);
    final i = _soData(inicio);
    if (d.isBefore(i)) d = i;
    while (!d.isAfter(fim)) {
      if (ocorreEm(d, i)) yield d;
      d = DateTime(d.year, d.month, d.day + 1);
    }
  }

  /// Primeira ocorrência no dia [aPartirDe] ou depois (procura até ~2 anos).
  DateTime? proxima(DateTime inicio, DateTime aPartirDe) {
    final de = _soData(aPartirDe);
    for (final d in ocorrencias(inicio, de, DateTime(de.year + 2, de.month, de.day))) {
      return d;
    }
    return null;
  }

  /// Texto curto para a interface: "Todo dia", "Dias úteis", "Toda sexta",
  /// "Seg, qua e sex", "Todo dia 9".
  String get descricao {
    final cada = intervalo > 1;
    switch (frequencia) {
      case Frequencia.diaria:
        return cada ? 'A cada $intervalo dias' : 'Todo dia';
      case Frequencia.semanal:
        if (cada) return 'A cada $intervalo semanas';
        return descreverDias(dias);
      case Frequencia.mensal:
        return cada ? 'A cada $intervalo meses, dia $diaDoMes' : 'Todo dia $diaDoMes';
    }
  }
}

/// "Todo dia", "Dias úteis", "Fim de semana", "Toda sexta", "Seg, qua e sex".
String descreverDias(int dias) {
  if (dias == todosOsDias) return 'Todo dia';
  if (dias == diasUteis) return 'Dias úteis';
  if (dias == 96) return 'Fim de semana';
  final escolhidos = [for (var i = 0; i < 7; i++) if (dias & (1 << i) != 0) i];
  if (escolhidos.isEmpty) return 'Nenhum dia';
  if (escolhidos.length == 1) {
    final i = escolhidos.single;
    return '${i >= 5 ? 'Todo' : 'Toda'} ${_nomesDia[i]}';
  }
  final nomes = [for (final i in escolhidos) _curtosDia[i]];
  final texto = '${nomes.sublist(0, nomes.length - 1).join(', ')} e ${nomes.last}';
  return texto[0].toUpperCase() + texto.substring(1);
}

DateTime _soData(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime _segunda(DateTime d) => DateTime(d.year, d.month, d.day - (d.weekday - 1));

/// Diferença em dias de calendário (imune ao horário de verão).
int _diasEntre(DateTime a, DateTime b) =>
    DateTime.utc(b.year, b.month, b.day).difference(DateTime.utc(a.year, a.month, a.day)).inDays;
