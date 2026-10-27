import '../core/formato.dart';
import '../core/relogio.dart';
import 'alimentacao_repo.dart';
import 'banco.dart';
import 'compromissos_repo.dart';
import 'financas_repo.dart';
import 'habitos_repo.dart';
import 'objetivos_repo.dart';
import 'saude_repo.dart';
import 'tarefas_repo.dart';

/// Resumo em texto dos dados do app, mandado junto com cada pergunta à IA.
/// É montado no aparelho (a IA não lê o banco) e fica curto de propósito.
Future<String> montarContexto(BancoAurora db) async {
  final agora = agoraLocal();
  final hoje = dataLocal(agora);
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
    return '${o.tarefa.titulo} ($quando${o.atrasada ? ', atrasada' : ''}${o.objetivo == null ? '' : ', objetivo ${o.objetivo!.nome}'})';
  }

  final abertas = tarefas.pendentes.take(15).map(tarefa).toList();
  l.add('Tarefas em aberto (${tarefas.abertas}, ${tarefas.atrasadas} atrasadas): '
      '${abertas.isEmpty ? 'nenhuma' : abertas.join('; ')}.');

  final compromissos = (await CompromissosRepo(db).carregar()).porDia(hoje, somarDias(hoje, 1));
  final agenda = [
    for (final d in [hoje, somarDias(hoje, 1)])
      for (final o in compromissos[d] ?? const <OcorrenciaCompromisso>[])
        '${o.compromisso.titulo} (${diaRelativo(d, hoje)} ${o.horario.toLowerCase()}'
            '${o.compromisso.local == null ? '' : ', ${o.compromisso.local}'})',
  ];
  if (agenda.isNotEmpty) l.add('Compromissos de hoje e amanhã: ${agenda.join('; ')}.');

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

  final objetivos = await ObjetivosRepo(db).carregar();
  if (objetivos.isNotEmpty) {
    l.add('Objetivos: ${objetivos.map((p) {
      final o = p.objetivo;
      final medida = p.temNumero
          ? '${valorMeta(o.valorAtual, o.unidade)} de ${valorMeta(o.valorAlvo, o.unidade)}'
          : '${p.feitas} de ${p.total} etapas';
      return '${o.nome}: $medida'
          '${o.dataAlvo == null ? '' : ' até ${diaMesCurto(dataLocal(o.dataAlvo!))}'}, ${p.estado.rotulo.toLowerCase()}';
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

  final comida = await AlimentacaoRepo(db).carregarDia(hoje);
  final t = comida.total;
  final a = comida.alvo;
  String g(double v) => numero(v.roundToDouble());
  if (a != null || comida.registros.isNotEmpty) {
    l.add('Alimentação hoje (dia de ${comida.tipo == TipoDia.treino ? 'treino' : 'descanso'}): '
        '${g(t.kcal)} kcal, proteína ${g(t.proteina)} g, carboidrato ${g(t.carboidrato)} g, gordura ${g(t.gordura)} g'
        '${a == null ? '' : '; alvo ${g(a.kcal)} kcal, P ${g(a.proteina)} g, C ${g(a.carboidrato)} g, G ${g(a.gordura)} g'}.');
  }
  if (comida.alimentos.isNotEmpty) {
    l.add('Alimentos cadastrados: ${comida.alimentos.take(40).map((x) => x.nome).join(', ')}.');
  }

  return l.join('\n');
}
