import 'package:intl/intl.dart';

final _brl = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$', decimalDigits: 2);

/// Dinheiro é guardado em centavos (inteiro). 70318 → "R$ 703,18".
String reais(int centavos) => _brl.format(centavos / 100).replaceAll(' ', ' ');

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

String saudacao(DateTime d) {
  if (d.hour >= 5 && d.hour < 12) return 'Bom dia';
  if (d.hour >= 12 && d.hour < 18) return 'Boa tarde';
  return 'Boa noite';
}
