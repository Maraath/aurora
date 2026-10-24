import 'package:drift/drift.dart';

import '../core/formato.dart';
import '../core/recorrencia.dart';
import '../core/relogio.dart';
import 'banco.dart';
import 'observar.dart';

enum ModeloAutomacao {
  briefing('Briefing do dia', todosOsDias, '07:00',
      'Hábitos, tarefas, contas, treino e lembretes do dia, logo cedo.'),
  atrasadas('Atrasadas de manhã', diasUteis, '08:00',
      'Lista o que está atrasado para você decidir: fazer, reagendar ou largar.'),
  dinheiroSemana('Revisão do dinheiro', 16, '18:00',
      'Quanto entrou e saiu na semana, para onde foi e as contas dos próximos dias.'),
  metasDomingo('Metas e dinheiro no domingo', 64, '10:00',
      'Como estão as metas (ritmo, em risco, paradas) e o mês até agora.'),
  habitosSemana('Hábitos da semana', 64, '20:00',
      'Quanto de cada hábito foi feito na semana, o melhor e o que ficou para trás.'),
  personalizada('Personalizada', todosOsDias, '09:00', 'Um pedido seu para a IA no horário.');

  const ModeloAutomacao(this.nome, this.dias, this.horario, this.descricao);
  final String nome;
  final int dias;
  final String horario;
  final String descricao;

  static ModeloAutomacao de(String nome) =>
      values.firstWhere((m) => m.name == nome, orElse: () => personalizada);
}

/// Só a última ocorrência perdida é executada, e só se tiver até este tempo:
/// abrir o app à noite não despeja o briefing da manhã de três dias atrás.
const atrasoMaximo = Duration(hours: 12);

({int hora, int minuto}) lerHorario(String hhmm) {
  final p = hhmm.split(':');
  return (hora: int.tryParse(p.first) ?? 9, minuto: int.tryParse(p.length > 1 ? p[1] : '0') ?? 0);
}

/// "aaaa-mm-dd HH:mm" de uma ocorrência (para comparar com ultimaExecucao).
String chaveOcorrencia(DateTime dia, String horario) => '${chaveData(dia)} $horario';

/// Instante (fuso do aparelho) da ocorrência do dia, se a automação roda nesse dia.
DateTime? ocorrenciaNoDia(Automacao a, DateTime dia) {
  if (a.diasSemana & bitDoDiaDaSemana(dia) == 0) return null;
  final h = lerHorario(a.horario);
  return instanteLocal(dia, h.hora, h.minuto);
}

/// Última ocorrência em ou antes de [agora] (procura uma semana para trás).
({DateTime dia, DateTime quando})? ultimaOcorrencia(Automacao a, DateTime agora) {
  final hoje = dataLocal(agora);
  for (var i = 0; i <= 7; i++) {
    final dia = somarDias(hoje, -i);
    final q = ocorrenciaNoDia(a, dia);
    if (q != null && !q.isAfter(agora)) return (dia: dia, quando: q);
  }
  return null;
}

/// Próximas ocorrências depois de [agora], nos próximos [dias].
Iterable<DateTime> proximasOcorrencias(Automacao a, DateTime agora, {int dias = 14}) sync* {
  final hoje = dataLocal(agora);
  for (var i = 0; i <= dias; i++) {
    final q = ocorrenciaNoDia(a, somarDias(hoje, i));
    if (q != null && q.isAfter(agora)) yield q;
  }
}

/// A automação deve rodar agora? Ativa, com ocorrência recente ainda não executada.
({DateTime dia, DateTime quando})? pendente(Automacao a, DateTime agora) {
  if (!a.ativa || a.apagadoEm != null) return null;
  final o = ultimaOcorrencia(a, agora);
  if (o == null || agora.difference(o.quando) > atrasoMaximo) return null;
  final chave = chaveOcorrencia(o.dia, a.horario);
  final ultima = a.ultimaExecucao;
  if (ultima != null && ultima.compareTo(chave) >= 0) return null;
  return o;
}

/// "Todo dia às 07:00", "Dias úteis às 08:00", "Toda sexta às 18:00".
String descreverAgenda(Automacao a) => '${descreverDias(a.diasSemana)} às ${a.horario}';

class AutomacoesRepo {
  AutomacoesRepo(this.db);
  final BancoAurora db;

  static const _chaveLigadas = 'automacoes_ligadas';

  Stream<List<Automacao>> observarAutomacoes() => observar(db, [db.automacoes, db.preferencias], listar);

  /// Modelos primeiro (na ordem do enum), depois as personalizadas.
  Future<List<Automacao>> listar() async {
    final todas = await (db.select(db.automacoes)..where((a) => a.apagadoEm.isNull())).get();
    int ordem(Automacao a) => ModeloAutomacao.de(a.modelo).index;
    return todas..sort((a, b) {
        final c = ordem(a).compareTo(ordem(b));
        return c != 0 ? c : a.criadoEm.compareTo(b.criadoEm);
      });
  }

  /// Cria os modelos prontos que faltarem (desligados). O id vem do modelo,
  /// então dois aparelhos criam a MESMA linha e a sincronização não duplica.
  Future<void> garantirModelos() async {
    for (final m in ModeloAutomacao.values) {
      if (m == ModeloAutomacao.personalizada) continue;
      await db.into(db.automacoes).insert(
            AutomacoesCompanion.insert(
              id: Value(idNatural('automacao', [m.name])),
              nome: m.nome,
              modelo: m.name,
              diasSemana: Value(m.dias),
              horario: m.horario,
              // Data antiga: qualquer edição real (em qualquer aparelho) vence.
              criadoEm: Value(DateTime.utc(2026)),
              atualizadoEm: Value(DateTime.utc(2026)),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  /// Chave geral, por aparelho (padrão: ligada).
  Future<bool> ligadas() async => (await db.preferencia(_chaveLigadas)) != '0';
  /// Quem chama reagenda os avisos (Notificador.reagendar): preferências não
  /// disparam reagendamento sozinhas.
  Future<void> definirLigadas(bool v) => db.salvarPreferencia(_chaveLigadas, v ? '1' : '0');

  Future<void> salvar(AutomacoesCompanion dados, {String? id}) async {
    if (id == null) {
      await db.into(db.automacoes).insert(dados);
      return;
    }
    await (db.update(db.automacoes)..where((a) => a.id.equals(id)))
        .write(dados.copyWith(atualizadoEm: Value(DateTime.now())));
  }

  Future<void> alternar(Automacao a, bool ativa) => salvar(AutomacoesCompanion(ativa: Value(ativa)), id: a.id);

  Future<void> marcarExecutada(Automacao a, DateTime dia) => salvar(
      AutomacoesCompanion(ultimaExecucao: Value(chaveOcorrencia(dia, a.horario))), id: a.id);

  Future<void> excluir(String id) {
    final agora = DateTime.now();
    return (db.update(db.automacoes)..where((a) => a.id.equals(id)))
        .write(AutomacoesCompanion(apagadoEm: Value(agora), atualizadoEm: Value(agora)));
  }
}

/// "Briefing do dia · sex, 17 out" para o título da mensagem.
String tituloExecucao(Automacao a, DateTime dia) => '${a.nome} · ${diaSemanaCurto(dia)}';
