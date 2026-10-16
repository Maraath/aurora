import '../core/formato.dart';
import '../core/relogio.dart';
import 'banco.dart';
import 'financas_repo.dart';
import 'habitos_repo.dart';
import 'metas_repo.dart';
import 'saude_repo.dart';
import 'tarefas_repo.dart';

/// Resumo em texto dos dados do app, mandado junto com cada pergunta à IA.
/// É montado no aparelho (a IA não lê o banco) e fica curto de propósito.
Future<String> montarContexto(BancoAurora db) async {
  final agora = agoraSP();
  final hoje = dataSP(agora);
  final l = <String>[];
  final nome = await db.preferencia('nome');
  l.add('Hoje: ${dataCabecalho(hoje).toLowerCase()}, ${hora(agora)}.${nome == null ? '' : ' Nome: $nome.'}');

  final habitos = await HabitosRepo(db).carregar();
  final doDia = habitos.doDia(hoje);
  if (habitos.habitos.isNotEmpty) {
    l.add('Hábitos: ${habitos.habitos.map((h) => h.nome).join(', ')}.');
    l.add('Hábitos de hoje: ${doDia.isEmpty ? 'nenhum' : doDia.map((h) => '${h.nome} (${habitos.feito(h.id, hoje) ? 'feito' : 'pendente'})').join(', ')}.');
  }

  final tarefas = await TarefasRepo(db).carregar();
  String tarefa(OcorrenciaTarefa o) {
    final h = o.horario;
    final quando = o.dia == null
        ? 'sem data'
        : '${diaRelativo(o.dia!, hoje)}${h == null ? '' : ' ${horaDe(h.hora, h.minuto)}'}';
    return '${o.tarefa.titulo} ($quando${o.atrasada ? ', atrasada' : ''}${o.meta == null ? '' : ', meta ${o.meta!.nome}'})';
  }

  final abertas = tarefas.pendentes.take(15).map(tarefa).toList();
  l.add('Tarefas em aberto (${tarefas.abertas}, ${tarefas.atrasadas} atrasadas): '
      '${abertas.isEmpty ? 'nenhuma' : abertas.join('; ')}.');

  final financas = await FinancasRepo(db).carregar();
  final mes = financas.mes(hoje);
  l.add('Finanças de ${nomeDoMes(hoje).toLowerCase()}: saldo em conta ${reais(financas.saldoCentavos)}, '
      'entrou ${reais(mes.entrouCentavos)}, saiu ${reais(mes.saiuCentavos)}'
      '${financas.faturasCentavos > 0 ? ', faturas de cartão em aberto ${reais(financas.faturasCentavos)}' : ''}.');
  if (mes.categorias.isNotEmpty) {
    l.add('Gastos por categoria: ${mes.categorias.map((c) => '${c.nome} ${reais(c.centavos)}').join(', ')}.');
  }
  final contas = mes.aPagar.where((o) => !o.paga).toList();
  if (contas.isNotEmpty) {
    l.add('Contas a pagar: ${contas.take(12).map((o) => '${o.nome} ${reais(o.valorCentavos)} '
        '${o.atrasada(hoje) ? 'atrasada desde' : 'vence'} ${diaMesCurto(o.vencimento)}').join('; ')}.');
  }

  final metas = await MetasRepo(db).carregar();
  if (metas.isNotEmpty) {
    l.add('Metas: ${metas.map((p) {
      final m = p.meta;
      return '${m.nome}: ${valorMeta(m.valorAtual, m.unidade)} de ${valorMeta(m.valorAlvo, m.unidade)}'
          '${m.dataAlvo == null ? '' : ' até ${diaMesCurto(dataSP(m.dataAlvo!))}'}, ${p.estado.rotulo.toLowerCase()}';
    }).join('; ')}.');
  }

  final saude = await SaudeRepo(db).carregar();
  final treino = saude.treinoDoDia(hoje);
  if (saude.treinos.isNotEmpty) {
    l.add('Treino de hoje: ${treino == null ? 'descanso' : '${treino.titulo} (${treino.exercicios.map((e) => '${e.exercicio.nome} ${e.plano} ${e.sugestao.texto}').join(', ')})'}'
        '${treino != null && saude.feitoEm(treino.treino.id, hoje) ? ', já feito' : ''}.');
  }
  final medidas = [
    for (final t in saude.tiposMedida)
      if (saude.ultima(t) case final m?) '$t ${numero(m.valor)} ${m.unidade} (${diaMesCurto(DateTime.parse(m.dia))})',
  ];
  if (medidas.isNotEmpty) l.add('Medidas mais recentes: ${medidas.join(', ')}.');

  return l.join('\n');
}
