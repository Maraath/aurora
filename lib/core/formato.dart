import 'package:intl/intl.dart';

final _brl = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$', decimalDigits: 2);

/// Dinheiro é guardado em centavos (inteiro). 70318 → "R$ 703,18".
String reais(int centavos) => _brl.format(centavos / 100).replaceAll(' ', ' ');

/// Lê o que a pessoa digitou ("1.234,56", "35", "35.9") como número.
/// Com vírgula, pontos são separador de milhar; sem vírgula, o ponto é decimal.
double? lerNumero(String texto) {
  var t = texto.trim().replaceAll(RegExp(r'[R$\s]'), '');
  if (t.isEmpty) return null;
  if (t.contains(',')) t = t.replaceAll('.', '').replaceAll(',', '.');
  return double.tryParse(t);
}

/// "35,90" → 3590. Nulo se não for um número.
int? lerCentavos(String texto) {
  final v = lerNumero(texto);
  return v == null ? null : (v * 100).round();
}

/// 3590 → "35,90" (para preencher campos de valor).
String centavosParaCampo(int centavos) =>
    NumberFormat('#,##0.00', 'pt_BR').format(centavos / 100);

/// 74.0 → "74", 74.5 → "74,5".
String numero(double v) {
  if (v == v.roundToDouble()) return v.toInt().toString();
  return NumberFormat('#,##0.#', 'pt_BR').format(v);
}

/// "QUINTA-FEIRA · 15 DE OUTUBRO"
String dataCabecalho(DateTime d) =>
    DateFormat("EEEE '·' d 'de' MMMM", 'pt_BR').format(d).toUpperCase();

/// "Outubro"
String nomeDoMes(DateTime d) {
  final m = DateFormat('MMMM', 'pt_BR').format(d);
  return m[0].toUpperCase() + m.substring(1);
}

/// "31 dez"
String diaMesCurto(DateTime d) =>
    DateFormat('d MMM', 'pt_BR').format(d).replaceAll('.', '');

/// "21:00"
String hora(DateTime d) => DateFormat('HH:mm').format(d);

String horaDe(int h, int m) => '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

/// "sex, 18 out"
String diaSemanaCurto(DateTime d) =>
    DateFormat("EEE',' d MMM", 'pt_BR').format(d).replaceAll('.', '').toLowerCase();

/// "hoje", "amanhã", "ontem", "sex, 18 out" (datas de calendário).
String diaRelativo(DateTime data, DateTime hoje) {
  final n = DateTime.utc(data.year, data.month, data.day)
      .difference(DateTime.utc(hoje.year, hoje.month, hoje.day))
      .inDays;
  return switch (n) {
    0 => 'hoje',
    1 => 'amanhã',
    -1 => 'ontem',
    _ => diaSemanaCurto(data),
  };
}

/// Rótulo curto dos lembretes: "HOJE", "AMANHÃ", "SEX 16", "SEG 9/11".
String rotuloDiaLembrete(DateTime data, DateTime hoje) {
  final rel = diaRelativo(data, hoje);
  if (rel == 'hoje' || rel == 'amanhã') return rel.toUpperCase();
  final semana = DateFormat('EEE', 'pt_BR').format(data).replaceAll('.', '').toUpperCase();
  return data.month == hoje.month && data.year == hoje.year
      ? '$semana ${data.day}'
      : '$semana ${data.day}/${data.month}';
}

/// "OUT"
String mesCurto(DateTime d) =>
    DateFormat('MMM', 'pt_BR').format(d).replaceAll('.', '').toUpperCase();

/// "31 de dezembro"
String diaMesLongo(DateTime d) => DateFormat("d 'de' MMMM", 'pt_BR').format(d);

/// "outubro de 2026"
String mesAno(DateTime d) => DateFormat("MMMM 'de' y", 'pt_BR').format(d);

String saudacao(DateTime d) {
  if (d.hour >= 5 && d.hour < 12) return 'Bom dia';
  if (d.hour >= 12 && d.hour < 18) return 'Boa tarde';
  return 'Boa noite';
}
