import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Fuso usado quando o do aparelho não pode ser lido (testes, plataforma sem
/// suporte, nome desconhecido).
const fusoPadrao = 'America/Sao_Paulo';

/// Fuso em que todas as datas do app são interpretadas: o do aparelho
/// ([fusoDoAparelho]), lido ao abrir e de novo ao voltar ao app.
late tz.Location fusoLocal;

var _baseCarregada = false;

/// Prepara o relógio no fuso [nome] (IANA, como "Europe/Lisbon"). Nome
/// desconhecido cai no [fusoPadrao]. Os testes chamam sem nome.
void iniciarRelogio([String nome = fusoPadrao]) {
  if (!_baseCarregada) {
    tzdata.initializeTimeZones();
    _baseCarregada = true;
  }
  fusoLocal = _localizar(nome);
}

tz.Location _localizar(String nome) {
  try {
    return tz.getLocation(nome);
  } catch (_) {
    debugPrint('Relógio: fuso "$nome" desconhecido, usando $fusoPadrao');
    return tz.getLocation(fusoPadrao);
  }
}

/// Nome IANA do fuso configurado no aparelho (no Windows, convertido do fuso do
/// sistema). Se não der para ler, o [fusoPadrao].
Future<String> fusoDoAparelho() async {
  try {
    final info = await FlutterTimezone.getLocalTimezone();
    return info.identifier;
  } catch (e) {
    debugPrint('Relógio: não leu o fuso do aparelho ($e)');
    return fusoPadrao;
  }
}

/// Relê o fuso do aparelho (a pessoa viajou ou trocou o fuso no sistema).
/// Devolve verdadeiro se mudou.
Future<bool> atualizarFusoDoAparelho() async {
  final nome = await fusoDoAparelho();
  final novo = _localizar(nome);
  if (novo.name == fusoLocal.name) return false;
  debugPrint('Relógio: fuso mudou de ${fusoLocal.name} para ${novo.name}');
  fusoLocal = novo;
  return true;
}

/// Agora, no fuso do aparelho.
tz.TZDateTime agoraLocal() => tz.TZDateTime.now(fusoLocal);

/// Converte um instante (como vem do banco) para o fuso do aparelho.
tz.TZDateTime emLocal(DateTime instante) => tz.TZDateTime.from(instante, fusoLocal);

/// Meia-noite de um dia no fuso do aparelho.
tz.TZDateTime diaLocal(int ano, int mes, int dia, [int hora = 0, int minuto = 0]) =>
    tz.TZDateTime(fusoLocal, ano, mes, dia, hora, minuto);

/// Início do dia (00:00), no fuso do aparelho, do instante dado.
tz.TZDateTime inicioDoDia(DateTime instante) {
  final d = emLocal(instante);
  return diaLocal(d.year, d.month, d.day);
}

/// Chave de dia "aaaa-mm-dd" de um instante, no fuso do aparelho.
String chaveDia(DateTime instante) => chaveData(dataLocal(instante));

/// Chave "aaaa-mm-dd" de uma data de calendário (sem conversão de fuso).
String chaveData(DateTime data) {
  String dois(int n) => n.toString().padLeft(2, '0');
  return '${data.year}-${dois(data.month)}-${dois(data.day)}';
}

/// Data de calendário (sem hora) de um instante no fuso do aparelho.
/// Use para comparar dias; para gravar no banco converta com [instanteLocal].
DateTime dataLocal(DateTime instante) {
  final d = emLocal(instante);
  return DateTime(d.year, d.month, d.day);
}

/// Hoje, como data de calendário do fuso do aparelho.
DateTime hojeLocal() => dataLocal(DateTime.now());

/// Converte data de calendário + hora em um instante no fuso do aparelho.
tz.TZDateTime instanteLocal(DateTime data, [int hora = 0, int minuto = 0]) =>
    diaLocal(data.year, data.month, data.day, hora, minuto);

int diasEntre(DateTime a, DateTime b) =>
    DateTime.utc(b.year, b.month, b.day).difference(DateTime.utc(a.year, a.month, a.day)).inDays;
