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

/// Chave de dia "aaaa-mm-dd" de um instante, no fuso de São Paulo.
String chaveDia(DateTime instante) => chaveData(dataSP(instante));

/// Chave "aaaa-mm-dd" de uma data de calendário (sem conversão de fuso).
String chaveData(DateTime data) {
  String dois(int n) => n.toString().padLeft(2, '0');
  return '${data.year}-${dois(data.month)}-${dois(data.day)}';
}

/// Data de calendário (sem hora) de um instante em São Paulo.
/// Use para comparar dias; para gravar no banco converta com [instanteSP].
DateTime dataSP(DateTime instante) {
  final d = emSP(instante);
  return DateTime(d.year, d.month, d.day);
}

/// Hoje, como data de calendário de São Paulo.
DateTime hojeSP() => dataSP(DateTime.now());

/// Converte data de calendário + hora em um instante de São Paulo.
tz.TZDateTime instanteSP(DateTime data, [int hora = 0, int minuto = 0]) =>
    diaSP(data.year, data.month, data.day, hora, minuto);

int diasEntre(DateTime a, DateTime b) =>
    DateTime.utc(b.year, b.month, b.day).difference(DateTime.utc(a.year, a.month, a.day)).inDays;
