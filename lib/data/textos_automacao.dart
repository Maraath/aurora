import '../core/formato.dart';
import '../core/relogio.dart';
import 'alimentacao_repo.dart';
import 'automacoes_repo.dart';
import 'banco.dart';
import 'financas_repo.dart';
import 'habitos_repo.dart';
import 'lembretes_repo.dart';
import 'objetivos_repo.dart';
import 'saude_repo.dart';
import 'tarefas_repo.dart';

/// Texto de um modelo pronto, montado só com os dados do app (sem IA).
/// [agora] no fuso do aparelho. Personalizada não passa por aqui (vai para a IA).
Future<String> gerarTexto(ModeloAutomacao modelo, BancoAurora db, DateTime agora) => switch (modelo) {
      ModeloAutomacao.briefing => _briefing(db, agora),
      ModeloAutomacao.atrasadas => _atrasadas(db, agora),
      ModeloAutomacao.dinheiroSemana => _dinheiroSemana(db, agora),
      ModeloAutomacao.metasDomingo => _metasDomingo(db, agora),
      ModeloAutomacao.habitosSemana => _habitosSemana(db, agora),
      ModeloAutomacao.personalizada => Future.value(''),
    };

String _lista(Iterable<String> itens) {
  final l = itens.toList();
  if (l.length <= 1) return l.join();
  return '${l.sublist(0, l.length - 1).join(', ')} e ${l.last}';
}

String _dias(int n) => '$n ${n == 1 ? 'dia' : 'dias'}';

Future<String> _briefing(BancoAurora db, DateTime agora) async {
  final hoje = dataLocal(agora);
  final nome = await db.preferencia('nome');
  final linhas = <String>['${saudacao(agora)}${nome == null || nome.isEmpty ? '' : ', $nome'}! Seu ${diaSemanaCurto(hoje)}:'];

  final saude = await SaudeRepo(db).carregar();
  final treino = saude.treinoDoDia(hoje);
  if (treino != null) linhas.add('• Treino: ${treino.titulo}.');

  final habitos = await HabitosRepo(db).carregar();
  final doDia = habitos.doDia(hoje).where((h) => !habitos.feito(h.id, hoje)).map((h) => h.nome);
  if (doDia.isNotEmpty) linhas.add('• Hábitos: ${_lista(doDia)}.');

  final tarefas = await TarefasRepo(db).carregar();
  final deHoje = tarefas.pendentes.where((o) => o.dia == hoje).map((o) {
    final h = o.horario;
    return h == null ? o.tarefa.titulo : '${o.tarefa.titulo} às ${horaDe(h.hora, h.minuto)}';
  });
  if (deHoje.isNotEmpty) linhas.add('• Tarefas de hoje: ${_lista(deHoje)}.');
  if (tarefas.atrasadas > 0) {
    linhas.add('• ${tarefas.atrasadas} ${tarefas.atrasadas == 1 ? 'tarefa atrasada' : 'tarefas atrasadas'}.');
  }

  final lembretes = (await LembretesRepo(db).carregar())
      .todos
      .where((l) => l.lembrete.ativo && l.proxima != null && dataLocal(l.proxima!) == hoje)
      .map((l) => '${hora(emLocal(l.proxima!))} ${l.lembrete.texto}');
  if (lembretes.isNotEmpty) linhas.add('• Lembretes: ${_lista(lembretes)}.');

  final financas = await FinancasRepo(db).carregar();
  final mes = financas.mes(hoje);
  final vencemHoje = mes.aPagar.where((o) => !o.paga && o.vencimento == hoje).map((o) => '${o.nome} ${reais(o.valorCentavos)}');
  final atrasadas = mes.aPagar.where((o) => o.atrasada(hoje)).toList();
  if (vencemHoje.isNotEmpty) linhas.add('• Vence hoje: ${_lista(vencemHoje)}.');
  if (atrasadas.isNotEmpty) {
    linhas.add('• Contas atrasadas: ${atrasadas.length} '
        '(${reais(atrasadas.fold(0, (s, o) => s + o.valorCentavos))}).');
  }

  final comida = await AlimentacaoRepo(db).carregarDia(hoje);
  if (comida.alvo != null) {
    linhas.add('• Alvo de hoje (dia de ${comida.tipo == TipoDia.treino ? 'treino' : 'descanso'}): '
        '${comida.alvo!.kcal.round()} kcal, ${comida.alvo!.proteina.round()} g de proteína.');
  }

  final emRisco = (await ObjetivosRepo(db).carregar())
      .where((p) => p.estado == EstadoObjetivo.emRisco || p.estado == EstadoObjetivo.parada)
      .map((p) => '${p.objetivo.nome} (${p.estado.rotulo.toLowerCase()})');
  if (emRisco.isNotEmpty) linhas.add('• Atenção nos objetivos: ${_lista(emRisco)}.');

  if (linhas.length == 1) linhas.add('Nada marcado para hoje. Bom dia livre!');
  return linhas.join('\n');
}

Future<String> _atrasadas(BancoAurora db, DateTime agora) async {
  final hoje = dataLocal(agora);
  final atrasadas = (await TarefasRepo(db).carregar()).atuais.where((o) => o.atrasada).toList()
    ..sort((a, b) => (a.dia ?? hoje).compareTo(b.dia ?? hoje));
  if (atrasadas.isEmpty) return 'Nenhuma tarefa atrasada. Bom começo de dia!';
  final itens = [
    for (final o in atrasadas.take(8))
      '• ${o.tarefa.titulo} (${o.dia == null || o.dia == hoje ? 'hoje' : _dias(diasEntre(o.dia!, hoje))})',
  ];
  return [
    '${atrasadas.length} ${atrasadas.length == 1 ? 'tarefa atrasada' : 'tarefas atrasadas'}:',
    ...itens,
    if (atrasadas.length > 8) '• e mais ${atrasadas.length - 8}.',
    'Para cada uma: faça agora, mude a data ou exclua se não faz mais sentido.',
  ].join('\n');
}

Future<String> _dinheiroSemana(BancoAurora db, DateTime agora) async {
  final hoje = dataLocal(agora);
  final segunda = somarDias(hoje, -(hoje.weekday - 1));
  final q = await FinancasRepo(db).carregar();
  var entrou = 0, saiu = 0;
  final cats = <String, int>{};
  for (final m in q.movimentos) {
    if (m.transferencia || m.dia.isBefore(segunda) || m.dia.isAfter(hoje)) continue;
    if (m.entrada) {
      entrou += m.valorCentavos;
    } else {
      saiu += m.valorCentavos;
      cats.update(m.categoria, (v) => v + m.valorCentavos, ifAbsent: () => m.valorCentavos);
    }
  }
  final top = (cats.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).take(3);
  final proximas = <Ocorrencia>[];
  for (final t in q.transacoes) {
    if (t.contaDestinoId != null || t.tipo != TipoTransacao.saida) continue;
    proximas.addAll(q
        .ocorrencias(t, somarDias(hoje, 1), somarDias(hoje, 7))
        .where((o) => !o.paga));
  }
  proximas.sort((a, b) => a.vencimento.compareTo(b.vencimento));
  return [
    'Semana desde ${diaMesCurto(segunda)}: entrou ${reais(entrou)} e saiu ${reais(saiu)}.',
    if (top.isNotEmpty) 'Para onde foi: ${_lista(top.map((e) => '${e.key} ${reais(e.value)}'))}.',
    if (proximas.isNotEmpty)
      'Próximos 7 dias: ${_lista(proximas.take(6).map((o) => '${o.nome} ${reais(o.valorCentavos)} (${diaSemanaCurto(o.vencimento)})'))}.'
    else
      'Nenhuma conta nos próximos 7 dias.',
    'Saldo em conta: ${reais(q.saldoCentavos)}.',
  ].join('\n');
}

Future<String> _metasDomingo(BancoAurora db, DateTime agora) async {
  final hoje = dataLocal(agora);
  final objetivos = await ObjetivosRepo(db).carregar();
  final q = await FinancasRepo(db).carregar();
  final mes = q.mes(hoje);
  return [
    if (objetivos.isEmpty) 'Você ainda não tem objetivos. Que tal criar um em Objetivos?',
    for (final p in objetivos.where((p) => p.estado != EstadoObjetivo.concluida))
      '• ${p.objetivo.nome}: ${(p.progresso * 100).round()}% (${p.estado.rotulo.toLowerCase()})'
          '${p.ritmo == null ? '' : '. ${p.ritmo}'}',
    'Mês até agora: entrou ${reais(mes.entrouCentavos)}, saiu ${reais(mes.saiuCentavos)}'
        '${mes.contasAbertas > 0 ? ', faltam ${reais(mes.faltaPagarCentavos)} em contas' : ''}.',
  ].join('\n');
}

Future<String> _habitosSemana(BancoAurora db, DateTime agora) async {
  final hoje = dataLocal(agora);
  final segunda = somarDias(hoje, -(hoje.weekday - 1));
  final q = await HabitosRepo(db).carregar();
  if (q.habitos.isEmpty) return 'Você ainda não tem hábitos. Crie um em Hábitos.';
  final linhas = <String>[];
  var feitosTotal = 0, previstosTotal = 0;
  final taxas = <String, double>{};
  for (final h in q.habitos) {
    var previstos = 0, feitos = 0;
    for (var d = segunda; !d.isAfter(hoje); d = somarDias(d, 1)) {
      if (!q.doDia(d).contains(h)) continue;
      previstos++;
      if (q.feito(h.id, d)) feitos++;
    }
    if (previstos == 0) continue;
    feitosTotal += feitos;
    previstosTotal += previstos;
    taxas[h.nome] = feitos / previstos;
    linhas.add('• ${h.nome}: $feitos de $previstos');
  }
  if (previstosTotal == 0) return 'Nenhum hábito previsto nesta semana.';
  final ordem = taxas.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  return [
    'Semana dos hábitos: ${(feitosTotal / previstosTotal * 100).round()}% feito.',
    ...linhas,
    if (ordem.length > 1 && ordem.first.value > ordem.last.value)
      'Destaque: ${ordem.first.key}. Para a próxima semana: ${ordem.last.key}.',
  ].join('\n');
}
