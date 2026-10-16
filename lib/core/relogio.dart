import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Todas as datas do app são interpretadas no fuso America/Sao_Paulo,
/// independente do fuso configurado no aparelho.
late final tz.Location fusoSP;

void iniciarRelogio() {
  tzdata.initializeTimeZones();
  fusoSP = tz.getLocation('America/Sao_Paulo');
}

/// Agora, no horário de São Paulo.
tz.TZDateTime agoraSP() => tz.TZDateTime.now(fusoSP);

/// Converte um instante (como vem do banco) para o horário de São Paulo.
tz.TZDateTime emSP(DateTime instante) => tz.TZDateTime.from(instante, fusoSP);

/// Meia-noite de um dia em São Paulo.
tz.TZDateTime diaSP(int ano, int mes, int dia, [int hora = 0, int minuto = 0]) =>
    tz.TZDateTime(fusoSP, ano, mes, dia, hora, minuto);

/// Início do dia (00:00) em São Paulo do instante dado.
tz.TZDateTime inicioDoDia(DateTime instante) {
  final d = emSP(instante);
  return diaSP(d.year, d.month, d.day);
}

/// Chave de dia "aaaa-mm-dd", usada nos registros diários (ex.: hábitos).
String chaveDia(DateTime instante) {
  final d = emSP(instante);
  String dois(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${dois(d.month)}-${dois(d.day)}';
}
