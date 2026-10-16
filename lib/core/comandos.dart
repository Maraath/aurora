/// Comandos rápidos do assistente, entendidos por regras (sem IA e sem
/// internet): "gastei 35 no mercado", "me lembra de ligar pro dentista amanhã
/// às 10h", "fiz o cardio", "pesei 74,5". O que não casar com nenhuma regra
/// vai para a fila da IA.
library;

import 'formato.dart';
import 'recorrencia.dart';

sealed class Comando {
  const Comando();
}

/// Gasto (ou entrada) já feito, que entra no saldo.
class CmdDinheiro extends Comando {
  const CmdDinheiro({
    required this.centavos,
    required this.descricao,
    required this.categoria,
    required this.dia,
    this.entrada = false,
  });
  final int centavos;
  final String descricao;
  final String categoria;
  final DateTime dia;
  final bool entrada;
}

class CmdLembrete extends Comando {
  const CmdLembrete({
    required this.texto,
    required this.dia,
    required this.hora,
    required this.minuto,
    this.regra,
  });
  final String texto;
  final DateTime dia;
  final int hora;
  final int minuto;
  final Regra? regra;
}

class CmdTarefa extends Comando {
  const CmdTarefa({required this.titulo, this.dia, this.hora, this.minuto = 0});
  final String titulo;
  final DateTime? dia;
  final int? hora;
  final int minuto;
}

/// Marcar um hábito como feito hoje (o nome é procurado entre os hábitos).
class CmdHabito extends Comando {
  const CmdHabito(this.nome);
  final String nome;
}

class CmdMedida extends Comando {
  const CmdMedida({required this.tipo, required this.valor, required this.unidade});
  final String tipo;
  final double valor;
  final String unidade;
}

class CmdResumoDia extends Comando {
  const CmdResumoDia();
}

class CmdResumoFinancas extends Comando {
  const CmdResumoFinancas();
}

/// Minúsculas e sem acento, com o MESMO tamanho do original (as posições
/// encontradas aqui servem para recortar o texto original).
String normalizar(String s) {
  const de = 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ';
  const para = 'aaaaaeeeeiiiiooooouuuucaaaaaeeeeiiiiooooouuuuc';
  final b = StringBuffer();
  for (final ch in s.split('')) {
    final i = de.indexOf(ch);
    b.write(i >= 0 ? para[i] : ch.toLowerCase());
  }
  return b.toString();
}

const _valor = r'(\d{1,3}(?:\.\d{3})+(?:,\d{1,2})?|\d+(?:[.,]\d{1,2})?)';

/// Entende [texto]. [hoje] é a data de calendário e [agora] o horário atual
/// (ambos de São Paulo). Nulo = não é comando rápido.
Comando? interpretar(String texto, {required DateTime hoje, required DateTime agora}) {
  final original = texto.trim().replaceAll(RegExp(r'[.!?]+$'), '').replaceAll(RegExp(r'\s+'), ' ');
  if (original.isEmpty) return null;
  final n = normalizar(original);

  return _dinheiro(original, n, hoje) ??
      _lembrete(original, n, hoje, agora) ??
      _tarefa(original, n, hoje, agora) ??
      _medida(n) ??
      _habito(original, n) ??
      _resumo(n);
}

// ------------------------------------------------------------------ dinheiro

Comando? _dinheiro(String o, String n, DateTime hoje) {
  final m = RegExp('^(?:eu )?(gastei|paguei|comprei|recebi|ganhei|entrou|entraram) '
          '(?:r\\\$ ?)?$_valor(?: ?(?:reais|real|conto|pila))?'
          '(?: (?:com|no|na|nos|nas|em|de|do|da|pro|pra|para o|para a|pelo|pela))? ?(.*)\$')
      .firstMatch(n);
  if (m == null) return null;
  final centavos = lerCentavos(m.group(2)!);
  if (centavos == null || centavos <= 0) return null;
  final entrada = const {'recebi', 'ganhei', 'entrou', 'entraram'}.contains(m.group(1));

  final ini = n.length - m.group(3)!.length;
  var resto = o.substring(ini);
  var restoN = n.substring(ini);
  var dia = hoje;
  final quando = RegExp(r'\b(hoje|ontem|anteontem)\b').firstMatch(restoN);
  if (quando != null) {
    dia = switch (quando.group(1)) {
      'ontem' => hoje.subtract(const Duration(days: 1)),
      'anteontem' => hoje.subtract(const Duration(days: 2)),
      _ => hoje,
    };
    resto = _recortar(resto, quando.start, quando.end);
    restoN = _recortar(restoN, quando.start, quando.end);
  }
  final descricao = _capitalizar(_limparLigacoes(resto));
  return CmdDinheiro(
    centavos: centavos,
    descricao: descricao.isEmpty ? (entrada ? 'Entrada' : 'Gasto') : descricao,
    categoria: entrada ? categoriaEntrada(restoN) : categoriaGasto(restoN),
    dia: dia,
    entrada: entrada,
  );
}

/// Categoria pelo que se escreveu (as mesmas de Finanças).
String categoriaGasto(String texto) {
  final t = normalizar(texto);
  bool tem(List<String> palavras) => palavras.any((p) => RegExp('\\b$p').hasMatch(t));
  if (tem(['mercado', 'supermercado', 'feira', 'padaria', 'acougue', 'hortifruti'])) return 'Mercado';
  if (tem(['uber', '99', 'onibus', 'metro', 'gasolina', 'combustivel', 'estacionamento', 'pedagio', 'taxi', 'passagem'])) {
    return 'Transporte';
  }
  if (tem(['farmacia', 'remedio', 'medico', 'consulta', 'exame', 'dentista', 'academia', 'suplemento'])) {
    return 'Saúde';
  }
  if (tem(['aluguel', 'condominio', 'luz', 'energia', 'agua', 'gas', 'internet', 'iptu'])) return 'Moradia';
  if (tem(['faculdade', 'curso', 'livro', 'escola', 'mensalidade'])) return 'Educação';
  if (tem(['netflix', 'spotify', 'icloud', 'assinatura', 'celular', 'plano', 'streaming'])) return 'Serviços';
  if (tem(['cinema', 'bar', 'restaurante', 'lanche', 'ifood', 'pizza', 'show', 'jogo', 'viagem', 'cerveja'])) {
    return 'Lazer';
  }
  return 'Outros';
}

String categoriaEntrada(String texto) {
  final t = normalizar(texto);
  if (RegExp(r'\b(salario|pagamento do mes)').hasMatch(t)) return 'Salário';
  if (RegExp(r'\b(freela|freelance|job|bico|projeto)').hasMatch(t)) return 'Freela';
  return 'Outros';
}

// ----------------------------------------------------------------- lembrete

Comando? _lembrete(String o, String n, DateTime hoje, DateTime agora) {
  final m = RegExp(r'^(?:me )?(?:lembr(?:ar|e|a)(?:-me)?|avis(?:ar|e|a)(?:-me)?) (?:me )?'
          r'(?:(?:de|que|para|pra) )?(.+)$')
      .firstMatch(n);
  if (m == null) return null;
  final ini = n.length - m.group(1)!.length;
  final q = _Quando.extrair(o.substring(ini), n.substring(ini), hoje);
  final texto = _capitalizar(_limparLigacoes(q.resto));
  if (texto.isEmpty) return null;

  final temHora = q.hora != null || q.periodo != null;
  final hora = q.hora ?? q.periodo ?? 9;
  final minuto = q.hora == null ? 0 : q.minuto;
  final passou = hora * 60 + minuto <= agora.hour * 60 + agora.minute;
  var dia = q.dia;
  final regra = q.regra;
  if (regra != null) {
    // Primeira ocorrência a partir de hoje (hoje só se o horário ainda não passou).
    final inicio = regra.ocorreEm(hoje, hoje) && !passou ? hoje : hoje.add(const Duration(days: 1));
    dia = regra.proxima(inicio, inicio) ?? inicio;
  } else {
    // Sem dia: hoje se o horário ainda vem; senão amanhã (às 09:00 sem horário).
    dia ??= temHora && !passou ? hoje : hoje.add(const Duration(days: 1));
  }
  return CmdLembrete(texto: texto, dia: dia, hora: hora, minuto: minuto, regra: regra);
}

// ------------------------------------------------------------------- tarefa

Comando? _tarefa(String o, String n, DateTime hoje, DateTime agora) {
  final m = RegExp(r'^(?:(?:nova )?tarefa:? |(?:adicion|cri|anot|coloc|bot)(?:a|e|ar) (?:a |uma )?(?:nova )?tarefa:? '
          r'(?:(?:de|para|pra) )?)(.+)$')
      .firstMatch(n);
  if (m == null) return null;
  final ini = n.length - m.group(1)!.length;
  final q = _Quando.extrair(o.substring(ini), n.substring(ini), hoje);
  final titulo = _capitalizar(_limparLigacoes(q.resto));
  if (titulo.isEmpty) return null;
  return CmdTarefa(
    titulo: titulo,
    dia: q.dia ?? (q.hora != null ? hoje : null),
    hora: q.hora ?? q.periodo,
    minuto: q.hora == null ? 0 : q.minuto,
  );
}

// ------------------------------------------------------------------- medida

const _nomesMedida = {
  'peso': ('Peso', 'kg'),
  'braco': ('Braço', 'cm'),
  'cintura': ('Cintura', 'cm'),
  'quadril': ('Quadril', 'cm'),
  'peito': ('Peito', 'cm'),
  'coxa': ('Coxa', 'cm'),
  'panturrilha': ('Panturrilha', 'cm'),
  'abdomen': ('Abdômen', 'cm'),
};

Comando? _medida(String n) {
  final peso = RegExp('^(?:pesei|peso|to pesando|estou pesando|tô pesando) (?:de )?$_valor ?(?:kg|quilos?)?(?: hoje)?\$')
      .firstMatch(n);
  if (peso != null) {
    final v = lerNumero(peso.group(1)!);
    return v == null ? null : CmdMedida(tipo: 'Peso', valor: v, unidade: 'kg');
  }
  final outra = RegExp('^(?:medi )?(?:o |a |meu |minha )?(${_nomesMedida.keys.join('|')}) '
          '(?:(?:de|com|esta com|ta com|deu) )?$_valor ?(cm|kg)?(?: hoje)?\$')
      .firstMatch(n);
  if (outra == null) return null;
  final (tipo, unidade) = _nomesMedida[outra.group(1)]!;
  final v = lerNumero(outra.group(2)!);
  return v == null ? null : CmdMedida(tipo: tipo, valor: v, unidade: outra.group(3) ?? unidade);
}

// ------------------------------------------------------------------- hábito

Comando? _habito(String o, String n) {
  final m = RegExp(r'^(?:ja )?(?:fiz|terminei|conclui|completei|marca|marque|marcar) '
          r'(?:(?:o|a|os|as|meu|minha) )?(.+?)(?: (?:como )?feit[oa]s?)?(?: (?:de )?hoje)?$')
      .firstMatch(n);
  if (m == null) return null;
  final ini = n.indexOf(m.group(1)!, n.indexOf(" "));
  final nome = o.substring(ini, ini + m.group(1)!.length).trim();
  return nome.isEmpty ? null : CmdHabito(nome);
}

// ------------------------------------------------------------------- resumo

Comando? _resumo(String n) {
  if (RegExp(r'\b(gastos?|financas|dinheiro|saldo|contas? a pagar|quanto gastei)\b').hasMatch(n)) {
    return const CmdResumoFinancas();
  }
  if (RegExp(r'\b(resumo|meu dia|o dia de hoje|briefing|o que tenho (?:pra|para) hoje)\b').hasMatch(n)) {
    return const CmdResumoDia();
  }
  return null;
}

// ------------------------------------------------------------- data e hora

const _diasSemana = {
  'segunda': 1, 'terca': 2, 'quarta': 3, 'quinta': 4, 'sexta': 5, 'sabado': 6, 'domingo': 7,
};

/// Data, hora e repetição tiradas de um texto; [resto] é o que sobra.
class _Quando {
  _Quando(this.resto);
  String resto;
  DateTime? dia;
  int? hora;
  int minuto = 0;

  /// Hora sugerida por "de manhã", "à tarde", "à noite" (sem horário exato).
  int? periodo;
  Regra? regra;

  static _Quando extrair(String o, String n, DateTime hoje) {
    final q = _Quando(o);
    var t = n;

    void tirar(Match m) {
      q.resto = _recortar(q.resto, m.start, m.end);
      t = _recortar(t, m.start, m.end);
    }

    final sem = r'(segunda|terca|quarta|quinta|sexta|sabado|domingo)(?:-feira)?';

    // Repetição.
    Match? r;
    if ((r = RegExp(r'\b(?:todo|cada) (?:mes )?(?:no )?dia (\d{1,2})\b').firstMatch(t)) != null) {
      final d = int.parse(r!.group(1)!);
      if (d >= 1 && d <= 31) q.regra = Regra.mensal(d);
      tirar(r);
    } else if ((r = RegExp(r'\b(?:todos os dias|todo dia|diariamente)\b').firstMatch(t)) != null) {
      q.regra = const Regra.diaria();
      tirar(r!);
    } else if ((r = RegExp(r'\b(?:em )?dias uteis\b').firstMatch(t)) != null) {
      q.regra = const Regra.semanal(diasUteis);
      tirar(r!);
    } else if ((r = RegExp('\\b(?:toda|todo|todas as|todos os) $sem(?:s)?(?:(?:,| e) $sem(?:s)?)*').firstMatch(t)) !=
        null) {
      var bits = 0;
      for (final d in RegExp(sem).allMatches(r!.group(0)!)) {
        bits |= 1 << (_diasSemana[d.group(1)]! - 1);
      }
      q.regra = Regra.semanal(bits);
      tirar(r);
    } else if ((r = RegExp(r'\b(?:todo mes|mensalmente)\b').firstMatch(t)) != null) {
      q.regra = Regra.mensal(hoje.day);
      tirar(r!);
    }

    // Dia.
    Match? d;
    if ((d = RegExp(r'\bdepois de amanha\b').firstMatch(t)) != null) {
      q.dia = hoje.add(const Duration(days: 2));
      tirar(d!);
    } else if ((d = RegExp(r'\bamanha\b').firstMatch(t)) != null) {
      q.dia = hoje.add(const Duration(days: 1));
      tirar(d!);
    } else if ((d = RegExp(r'\bhoje\b').firstMatch(t)) != null) {
      q.dia = hoje;
      tirar(d!);
    } else if ((d = RegExp(r'\b(?:no )?dia (\d{1,2})(?:/(\d{1,2}))?\b').firstMatch(t)) != null) {
      q.dia = _proximoDiaDoMes(hoje, int.parse(d!.group(1)!), d.group(2) == null ? null : int.parse(d.group(2)!));
      tirar(d);
    } else if ((d = RegExp(r'\b(?:em |no |na )?(\d{1,2})/(\d{1,2})\b').firstMatch(t)) != null) {
      q.dia = _proximoDiaDoMes(hoje, int.parse(d!.group(1)!), int.parse(d.group(2)!));
      tirar(d);
    } else if (q.regra == null && (d = RegExp('\\b(?:na |no |nesta |neste |essa |esse |proxima |proximo )?$sem').firstMatch(t)) != null) {
      final alvo = _diasSemana[d!.group(1)]!;
      var dif = (alvo - hoje.weekday) % 7;
      if (dif == 0) dif = 7;
      q.dia = hoje.add(Duration(days: dif));
      tirar(d);
    }

    // Hora.
    Match? h;
    if ((h = RegExp(r'\b(?:as |a |ao |por volta das )?(\d{1,2})(?::(\d{2})|h(\d{2})?|(?= horas?))(?: ?horas?)?\b').firstMatch(t)) !=
        null) {
      final hh = int.parse(h!.group(1)!);
      final mm = int.tryParse(h.group(2) ?? h.group(3) ?? '') ?? 0;
      if (hh < 24 && mm < 60) {
        q.hora = hh;
        q.minuto = mm;
        tirar(h);
      }
    } else if ((h = RegExp(r'\bas (\d{1,2})\b').firstMatch(t)) != null) {
      final hh = int.parse(h!.group(1)!);
      if (hh < 24) {
        q.hora = hh;
        tirar(h);
      }
    } else if ((h = RegExp(r'\b(?:ao )?meio-dia\b').firstMatch(t)) != null) {
      q.hora = 12;
      tirar(h!);
    }
    Match? p;
    if ((p = RegExp(r'\b(?:de|pela|a|na) (manha|tarde|noite)\b').firstMatch(t)) != null) {
      final per = p!.group(1);
      if (q.hora == null) {
        q.periodo = switch (per) { 'manha' => 9, 'tarde' => 15, _ => 20 };
      } else if (per != 'manha' && q.hora! < 12) {
        q.hora = q.hora! + 12; // "às 8 da noite"
      }
      tirar(p);
    } else if ((p = RegExp(r'\bda (manha|tarde|noite)\b').firstMatch(t)) != null) {
      if (q.hora != null && p!.group(1) != 'manha' && q.hora! < 12) q.hora = q.hora! + 12;
      tirar(p!);
    }
    return q;
  }
}

/// Próxima data com aquele dia (e mês, se dado) a partir de hoje.
DateTime _proximoDiaDoMes(DateTime hoje, int dia, int? mes) {
  if (mes != null) {
    var d = DateTime(hoje.year, mes, dia);
    if (d.isBefore(hoje)) d = DateTime(hoje.year + 1, mes, dia);
    return d;
  }
  var d = DateTime(hoje.year, hoje.month, dia);
  if (d.isBefore(hoje)) d = DateTime(hoje.year, hoje.month + 1, dia);
  return d;
}

String _recortar(String s, int inicio, int fim) =>
    '${s.substring(0, inicio)} ${s.substring(fim)}'.replaceAll(RegExp(r'\s+'), ' ');

/// Tira espaços e conectivos soltos nas pontas ("de", "às", vírgulas).
String _limparLigacoes(String s) {
  var t = s.trim();
  final pontas = RegExp(r'^(?:,|e|de|do|da|para|pra|as|às|a|o|no|na|em)\s+|\s+(?:,|e|de|do|da|para|pra|as|às|a|o|no|na|em)$',
      caseSensitive: false);
  String antes;
  do {
    antes = t;
    t = t.replaceAll(pontas, '').replaceAll(RegExp(r'^[,\s]+|[,\s]+$'), '').trim();
  } while (t != antes);
  return t;
}

String _capitalizar(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
