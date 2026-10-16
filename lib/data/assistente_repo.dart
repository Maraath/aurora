import 'package:drift/drift.dart';

import '../core/comandos.dart';
import '../core/formato.dart';
import '../core/relogio.dart';
import 'banco.dart';
import 'financas_repo.dart';
import 'habitos_repo.dart';
import 'lembretes_repo.dart';
import 'observar.dart';
import 'saude_repo.dart';
import 'tarefas_repo.dart';
import 'visao_repo.dart';

/// Frases de exemplo mostradas como atalhos na conversa.
const sugestoesAssistente = [
  'Resumo do meu dia',
  'Como estão meus gastos?',
  'Me lembra de ligar pro dentista amanhã às 10h',
  'Gastei 35 no mercado',
  'Fiz o cardio',
  'Pesei 74,5',
];

class Resposta {
  const Resposta(this.texto, {this.itemTipo, this.itemId});
  final String texto;
  final String? itemTipo;
  final String? itemId;
}

class AssistenteRepo {
  AssistenteRepo(this.db);
  final BancoAurora db;

  Stream<List<MensagemAssistente>> observarConversa() =>
      observar(db, [db.mensagensAssistente], carregarConversa);

  Future<List<MensagemAssistente>> carregarConversa() =>
      (db.select(db.mensagensAssistente)
            ..where((m) => m.apagadoEm.isNull())
            ..orderBy([(m) => OrderingTerm(expression: m.criadoEm)]))
          .get();

  Future<int> tamanhoDaFila() async =>
      (await (db.select(db.mensagensAssistente)
                ..where((m) => m.apagadoEm.isNull() & m.naFila.equals(true)))
              .get())
          .length;

  /// Registra o pedido, executa se for comando rápido e responde. O que não
  /// for comando fica na fila da IA.
  Future<void> enviar(String texto) async {
    final limpo = texto.trim();
    if (limpo.isEmpty) return;
    final agora = agoraSP();
    final hoje = dataSP(agora);
    final comando = interpretar(limpo, hoje: hoje, agora: agora);

    await db.transaction(() async {
      await _gravar(PapelMensagem.eu, limpo, naFila: comando == null);
      if (comando == null) {
        await _gravar(PapelMensagem.sistema,
            'A IA ainda não está conectada. Guardei este pedido e respondo quando ela estiver. '
            'Enquanto isso, comandos rápidos funcionam: gastos, lembretes, tarefas, hábitos e medidas.');
        return;
      }
      final r = await _executar(comando, hoje, agora);
      await _gravar(PapelMensagem.aurora, r.texto, itemTipo: r.itemTipo, itemId: r.itemId);
    });
  }

  /// A conversa é ordenada por `criadoEm`; o relógio pode repetir o mesmo
  /// instante entre a pergunta e a resposta, então ele só anda para a frente.
  static DateTime _ultimo = DateTime(2000);

  Future<void> _gravar(PapelMensagem papel, String texto,
      {bool naFila = false, String? itemTipo, String? itemId}) {
    var agora = DateTime.now();
    if (!agora.isAfter(_ultimo)) agora = _ultimo.add(const Duration(microseconds: 1));
    _ultimo = agora;
    return db.into(db.mensagensAssistente).insert(MensagensAssistenteCompanion.insert(
          papel: papel,
          texto: texto,
          naFila: Value(naFila),
          itemTipo: Value(itemTipo),
          itemId: Value(itemId),
          criadoEm: Value(agora),
        ));
  }

  Future<Resposta> _executar(Comando c, DateTime hoje, DateTime agora) async {
    switch (c) {
      case CmdDinheiro():
        final financas = FinancasRepo(db);
        final q = await financas.carregar();
        final instante = c.dia == hoje ? DateTime.now() : instanteSP(c.dia, 12);
        final id = await financas.salvar(TransacoesCompanion.insert(
          descricao: c.descricao,
          valorCentavos: c.centavos,
          tipo: c.entrada ? TipoTransacao.entrada : TipoTransacao.saida,
          data: instante,
          pagoEm: Value(instante),
          categoria: Value(c.categoria),
          contaId: Value(q.contaPrincipalId),
        ));
        final quando = c.dia == hoje ? 'hoje' : diaRelativo(c.dia, hoje);
        return Resposta(
          c.entrada
              ? 'Anotei a entrada de ${reais(c.centavos)} (“${c.descricao}”, ${c.categoria}), $quando.'
              : 'Anotei ${reais(c.centavos)} em “${c.descricao}” (${c.categoria}), $quando. '
                  'O saldo em Finanças já foi atualizado.',
          itemTipo: 'transacao',
          itemId: id,
        );

      case CmdLembrete():
        final l = await db.into(db.lembretes).insertReturning(LembretesCompanion.insert(
              texto: c.texto,
              quando: instanteSP(c.dia, c.hora, c.minuto),
              regraRepeticao: Value(c.regra?.rrule),
            ));
        final quando = c.regra != null
            ? '${c.regra!.descricao.toLowerCase()} às ${horaDe(c.hora, c.minuto)}, a partir de ${diaRelativo(c.dia, hoje)}'
            : '${diaRelativo(c.dia, hoje)} às ${horaDe(c.hora, c.minuto)}';
        return Resposta('Pronto: lembrete “${c.texto}” $quando. Está em Mais › Lembretes.',
            itemTipo: 'lembrete', itemId: l.id);

      case CmdTarefa():
        final prazo = c.dia == null ? null : instanteSP(c.dia!, c.hora ?? 0, c.minuto);
        final id = await TarefasRepo(db).salvar(
          TarefasCompanion.insert(
            titulo: c.titulo,
            prazo: Value(prazo),
            prazoTemHora: Value(c.dia != null && c.hora != null),
          ),
          avisar: false,
        );
        final quando = c.dia == null
            ? 'sem data'
            : '${diaRelativo(c.dia!, hoje)}${c.hora == null ? '' : ' às ${horaDe(c.hora!, c.minuto)}'}';
        return Resposta('Criei a tarefa “${c.titulo}”, $quando.', itemTipo: 'tarefa', itemId: id);

      case CmdHabito():
        final habitos = HabitosRepo(db);
        final q = await habitos.carregar();
        final h = _acharHabito(q.habitos, c.nome);
        if (h == null) {
          final nomes = q.habitos.map((h) => h.nome).join(', ');
          return Resposta('Não achei um hábito chamado “${c.nome}”.'
              '${nomes.isEmpty ? ' Você ainda não tem hábitos.' : ' Os seus são: $nomes.'}');
        }
        if (q.feito(h.id, hoje)) return Resposta('${h.nome} já estava marcado como feito hoje.');
        await habitos.alternar(h.id, hoje, true);
        final faltam = q.doDia(hoje).where((x) => x.id != h.id && !q.feito(x.id, hoje)).map((x) => x.nome);
        return Resposta(
          'Marquei ${h.nome} como feito hoje.${faltam.isEmpty ? ' Rotina de hoje completa.' : ' Falta: ${faltam.join(', ')}.'}',
          itemTipo: 'habito',
          itemId: '${h.id}|${chaveData(hoje)}',
        );

      case CmdMedida():
        final saude = SaudeRepo(db);
        final antes = (await saude.carregar()).ultima(c.tipo);
        await saude.salvarMedidas(hoje, [(tipo: c.tipo, valor: c.valor, unidade: c.unidade)]);
        final m = (await saude.carregar()).ultima(c.tipo)!;
        final dif = antes == null || antes.dia == m.dia ? null : c.valor - antes.valor;
        return Resposta(
          'Anotei ${c.tipo.toLowerCase()} ${numero(c.valor)} ${c.unidade} hoje'
          '${dif == null || dif == 0 ? '.' : ' (${dif > 0 ? '+' : '−'}${numero(dif.abs())} ${c.unidade} desde ${diaMesCurto(DateTime.parse(antes!.dia))}).'}',
          itemTipo: 'medida',
          itemId: m.id,
        );

      case CmdResumoDia():
        return Resposta(await _resumoDia(hoje));

      case CmdResumoFinancas():
        return Resposta(await _resumoFinancas(hoje));
    }
  }

  Habito? _acharHabito(List<Habito> habitos, String nome) {
    final alvo = normalizar(nome);
    for (final h in habitos) {
      if (normalizar(h.nome) == alvo) return h;
    }
    for (final h in habitos) {
      final n = normalizar(h.nome);
      if (n.contains(alvo) || alvo.contains(n)) return h;
    }
    return null;
  }

  Future<String> _resumoDia(DateTime hoje) async {
    final r = await VisaoRepo(db).carregar();
    final partes = <String>[];
    final faltam = r.habitos.where((h) => !h.feito).map((h) => h.habito.nome).toList();
    partes.add(r.habitos.isEmpty
        ? 'Nenhum hábito para hoje.'
        : (faltam.isEmpty ? 'Hábitos de hoje: todos feitos.' : 'Hábitos por fazer: ${faltam.join(', ')}.'));
    if (r.tarefasHoje.isNotEmpty) {
      final itens = r.tarefasHoje.map((o) {
        final h = o.horario;
        return h == null ? o.tarefa.titulo : '${o.tarefa.titulo} às ${horaDe(h.hora, h.minuto)}';
      });
      partes.add('Tarefas de hoje: ${itens.join(', ')}.');
    }
    if (r.tarefasAtrasadas > 0) {
      partes.add('${r.tarefasAtrasadas} ${r.tarefasAtrasadas == 1 ? 'tarefa atrasada' : 'tarefas atrasadas'}.');
    }
    if (r.contasAPagar > 0) {
      partes.add('${reais(r.aPagarCentavos)} em ${r.contasAPagar} ${r.contasAPagar == 1 ? 'conta' : 'contas'} a pagar.');
    }
    final treino = (await SaudeRepo(db).carregar()).treinoDoDia(hoje);
    if (treino != null) partes.add('Treino de hoje: ${treino.titulo}.');
    return 'Seu dia: ${partes.join(' ')}';
  }

  Future<String> _resumoFinancas(DateTime hoje) async {
    final q = await FinancasRepo(db).carregar();
    final mes = q.mes(hoje);
    final atrasadas = mes.aPagar.where((o) => o.atrasada(hoje)).toList();
    final partes = [
      'Em ${nomeDoMes(hoje).toLowerCase()} entrou ${reais(mes.entrouCentavos)} e saiu ${reais(mes.saiuCentavos)}.',
      if (mes.categorias.isNotEmpty)
        'O maior gasto foi ${mes.categorias.first.nome} (${reais(mes.categorias.first.centavos)}).',
      if (mes.contasAbertas > 0)
        'Faltam ${reais(mes.faltaPagarCentavos)} em ${mes.contasAbertas} '
            '${mes.contasAbertas == 1 ? 'conta' : 'contas'}'
            '${atrasadas.isEmpty ? '' : ', ${atrasadas.length} atrasada${atrasadas.length == 1 ? '' : 's'} (${atrasadas.map((o) => o.nome).join(', ')})'}.',
      'Saldo em conta: ${reais(q.saldoCentavos)}'
          '${mes.faltaPagarCentavos > 0 ? '; depois das contas sobram ${reais(q.saldoCentavos - mes.faltaPagarCentavos)}' : ''}.',
    ];
    return partes.join(' ');
  }

  /// Desfaz o que um comando criou.
  Future<void> desfazer(MensagemAssistente m) async {
    final id = m.itemId;
    if (id == null || m.desfeita) return;
    switch (m.itemTipo) {
      case 'transacao':
        final t = await (db.select(db.transacoes)..where((t) => t.id.equals(id))).getSingleOrNull();
        if (t != null) await FinancasRepo(db).excluir(t);
      case 'lembrete':
        await LembretesRepo(db).excluir(id);
      case 'tarefa':
        await TarefasRepo(db).excluir(id);
      case 'habito':
        final [habitoId, dia] = id.split('|');
        await HabitosRepo(db).alternar(habitoId, DateTime.parse(dia), false);
      case 'medida':
        await SaudeRepo(db).excluirMedida(id);
    }
    await (db.update(db.mensagensAssistente)..where((x) => x.id.equals(m.id)))
        .write(MensagensAssistenteCompanion(desfeita: const Value(true), atualizadoEm: Value(DateTime.now())));
    await _gravar(PapelMensagem.sistema, 'Desfeito.');
  }

  /// Apaga a conversa (os itens criados continuam).
  Future<void> limparConversa() {
    final agora = DateTime.now();
    return (db.update(db.mensagensAssistente)..where((m) => m.apagadoEm.isNull()))
        .write(MensagensAssistenteCompanion(apagadoEm: Value(agora), atualizadoEm: Value(agora)));
  }
}
