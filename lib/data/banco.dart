import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

part 'banco.g.dart';

const _uuid = Uuid();

/// Id calculado a partir da chave natural (UUID v5). Registros que dois
/// aparelhos podem criar sozinhos ("Cardio feito em 16/10") ganham o MESMO id
/// nos dois, e a sincronização não duplica.
String idNatural(String tipo, List<String> chave) =>
    _uuid.v5(Namespace.url.value, 'aurora:$tipo:${chave.join('|')}');

/// Campos que todo registro sincronizável leva. `apagadoEm` marca exclusão
/// sem apagar a linha, para a sincronização (V2) não perder nada.
mixin Sincronizavel on Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  DateTimeColumn get criadoEm => dateTime().clientDefault(DateTime.now)();
  DateTimeColumn get atualizadoEm => dateTime().clientDefault(DateTime.now)();
  DateTimeColumn get apagadoEm => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

enum Prioridade { alta, media, baixa }

enum TipoHabito { marcar, duracao, quantidade }

enum TipoConta { corrente, poupanca, cartao }

enum TipoTransacao { entrada, saida }

/// Recorrências são REGRAS que geram ocorrências, nunca uma linha por dia.
/// `regraRepeticao` usa o padrão RRULE de calendário, por exemplo:
/// `FREQ=DAILY`, `FREQ=WEEKLY;BYDAY=MO,WE,FR`, `FREQ=MONTHLY;BYMONTHDAY=11`.

/// Com unidade "R$", os valores da meta ficam em centavos (como todo dinheiro).
class Metas extends Table with Sincronizavel {
  TextColumn get nome => text()();
  RealColumn get valorInicial => real()();
  RealColumn get valorAtual => real()();
  RealColumn get valorAlvo => real()();
  TextColumn get unidade => text().withDefault(const Constant(''))();
  DateTimeColumn get dataAlvo => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('ativa'))();
}

/// Projeto: metas vistas no tempo. As etapas são as tarefas com `projetoId`.
class Projetos extends Table with Sincronizavel {
  TextColumn get nome => text()();
  DateTimeColumn get inicio => dateTime()();
  DateTimeColumn get fim => dateTime()();
  TextColumn get metaId => text().nullable().references(Metas, #id)();

  /// 'ativo' ou 'arquivado'.
  TextColumn get status => text().withDefault(const Constant('ativo'))();
}

class Tarefas extends Table with Sincronizavel {
  TextColumn get titulo => text()();
  TextColumn get notas => text().nullable()();
  DateTimeColumn get prazo => dateTime().nullable()();
  BoolColumn get prazoTemHora => boolean().withDefault(const Constant(false))();
  TextColumn get prioridade =>
      textEnum<Prioridade>().withDefault(Constant(Prioridade.media.name))();
  DateTimeColumn get feitaEm => dateTime().nullable()();
  TextColumn get regraRepeticao => text().nullable()();
  TextColumn get metaId => text().nullable().references(Metas, #id)();

  /// Etapa de um projeto.
  TextColumn get projetoId => text().nullable().references(Projetos, #id)();
}

class Habitos extends Table with Sincronizavel {
  TextColumn get nome => text()();
  TextColumn get tipo =>
      textEnum<TipoHabito>().withDefault(Constant(TipoHabito.marcar.name))();

  /// Bits de segunda (1) a domingo (64). 127 = todos os dias.
  IntColumn get diasSemana => integer().withDefault(const Constant(127))();

  /// "HH:mm" ou nulo quando não tem horário.
  TextColumn get horario => text().nullable()();

  /// Minutos (duração) ou quantidade, conforme o tipo.
  IntColumn get alvo => integer().nullable()();

  /// Unidade da quantidade ("copos", "páginas").
  TextColumn get unidade => text().nullable()();
  TextColumn get metaId => text().nullable().references(Metas, #id)();
}

/// Conclusão de UMA ocorrência de tarefa recorrente. A regra continua gerando
/// as próximas; só o que foi feito vira linha.
@TableIndex(name: 'conclusao_tarefa_dia', columns: {#tarefaId, #dia}, unique: true)
class ConclusoesTarefa extends Table with Sincronizavel {
  TextColumn get tarefaId => text().references(Tarefas, #id)();

  /// "aaaa-mm-dd" da ocorrência, no fuso de São Paulo.
  TextColumn get dia => text()();
}

@TableIndex(name: 'registro_habito_dia', columns: {#habitoId, #dia}, unique: true)
class RegistrosHabito extends Table with Sincronizavel {
  TextColumn get habitoId => text().references(Habitos, #id)();

  /// "aaaa-mm-dd" no fuso de São Paulo.
  TextColumn get dia => text()();
  BoolColumn get feito => boolean().withDefault(const Constant(true))();
  IntColumn get valor => integer().nullable()();
}

@DataClassName('ContaFinanceira')
class ContasFinanceiras extends Table with Sincronizavel {
  TextColumn get nome => text()();
  TextColumn get tipo => textEnum<TipoConta>()();
  IntColumn get saldoInicialCentavos => integer().withDefault(const Constant(0))();
  IntColumn get diaFechamento => integer().nullable()();
  IntColumn get diaVencimento => integer().nullable()();
}

/// Uma transação é única (sem regra) ou uma REGRA mensal: recorrente (sem fim)
/// ou parcelada (`parcelaNumero` é a parcela do primeiro vencimento e
/// `parcelaTotal` o total). Nas regras, `valorCentavos` é o valor de cada
/// ocorrência, e o pagamento de cada uma vira uma linha em PagamentosTransacao.
///
/// Únicas: com `vencimento` = conta a pagar (ou a receber) até ter `pagoEm`;
/// sem vencimento = movimento já feito em `data` (`pagoEm` igual a `data`).
@DataClassName('Transacao')
class Transacoes extends Table with Sincronizavel {
  TextColumn get descricao => text()();
  IntColumn get valorCentavos => integer()();
  TextColumn get tipo => textEnum<TipoTransacao>()();
  DateTimeColumn get data => dateTime()();
  DateTimeColumn get vencimento => dateTime().nullable()();
  DateTimeColumn get pagoEm => dateTime().nullable()();
  TextColumn get categoria => text().nullable()();
  TextColumn get regraRepeticao => text().nullable()();
  IntColumn get parcelaNumero => integer().nullable()();
  IntColumn get parcelaTotal => integer().nullable()();
  TextColumn get contaId => text().nullable().references(ContasFinanceiras, #id)();

  /// Transferência: conta que recebe (ex.: pagamento da fatura de um cartão).
  /// Transferências não contam como gasto nem como entrada do mês.
  @ReferenceName('transferenciasRecebidas')
  TextColumn get contaDestinoId => text().nullable().references(ContasFinanceiras, #id)();
}

/// Pagamento (ou recebimento) de UMA ocorrência de transação recorrente ou
/// parcelada. A regra continua gerando as próximas; só o que foi pago vira linha.
@TableIndex(name: 'pagamento_transacao_venc', columns: {#transacaoId, #vencimento}, unique: true)
@DataClassName('PagamentoTransacao')
class PagamentosTransacao extends Table with Sincronizavel {
  TextColumn get transacaoId => text().references(Transacoes, #id)();

  /// "aaaa-mm-dd" do vencimento da ocorrência, no fuso de São Paulo.
  TextColumn get vencimento => text()();
  DateTimeColumn get pagoEm => dateTime()();

  /// Valor pago nesta ocorrência (editar a regra depois não muda o passado).
  IntColumn get valorCentavos => integer()();
}

class Lembretes extends Table with Sincronizavel {
  TextColumn get texto => text()();
  DateTimeColumn get quando => dateTime()();
  TextColumn get regraRepeticao => text().nullable()();
  IntColumn get notificarAntesMin => integer().withDefault(const Constant(0))();

  /// O sino: desligado, o lembrete continua salvo mas não notifica.
  BoolColumn get ativo => boolean().withDefault(const Constant(true))();

  /// Item ligado (ex.: 'tarefa', 'transacao') e o id dele.
  TextColumn get itemTipo => text().nullable()();
  TextColumn get itemId => text().nullable()();
}

/// Exercício do catálogo pessoal. [midia] fica para a biblioteca de GIFs do
/// dono (convertidos para WebP/MP4 curto), que vem depois.
class Exercicios extends Table with Sincronizavel {
  TextColumn get nome => text()();
  TextColumn get grupo => text().nullable()();
  TextColumn get midia => text().nullable()();
}

/// Um treino da ficha ("Treino A · Peito e tríceps") e os dias em que cai.
class Treinos extends Table with Sincronizavel {
  TextColumn get nome => text()();
  TextColumn get foco => text().nullable()();

  /// Bits de segunda (1) a domingo (64), como em Habitos. 0 = sem dia fixo.
  IntColumn get diasSemana => integer().withDefault(const Constant(0))();
  IntColumn get ordem => integer().withDefault(const Constant(0))();
}

/// Exercício dentro de um treino, com o que se planeja fazer.
@DataClassName('ItemTreino')
class ItensTreino extends Table with Sincronizavel {
  TextColumn get treinoId => text().references(Treinos, #id)();
  TextColumn get exercicioId => text().references(Exercicios, #id)();
  IntColumn get ordem => integer().withDefault(const Constant(0))();
  IntColumn get series => integer().withDefault(const Constant(3))();

  /// Repetições alvo por série (a carga sobe quando todas chegam nelas).
  IntColumn get repeticoes => integer().withDefault(const Constant(10))();

  /// Carga para começar quando ainda não há histórico (kg).
  RealColumn get cargaInicial => real().nullable()();
}

/// Um treino feito num dia.
@DataClassName('SessaoTreino')
class SessoesTreino extends Table with Sincronizavel {
  TextColumn get treinoId => text().nullable().references(Treinos, #id)();

  /// "aaaa-mm-dd" no fuso de São Paulo.
  TextColumn get dia => text()();
  DateTimeColumn get inicio => dateTime()();
  DateTimeColumn get fim => dateTime().nullable()();
}

/// Série feita numa sessão: é daqui que sai a carga sugerida do próximo treino.
@DataClassName('SerieFeita')
class SeriesFeitas extends Table with Sincronizavel {
  TextColumn get sessaoId => text().references(SessoesTreino, #id)();
  TextColumn get exercicioId => text().references(Exercicios, #id)();
  IntColumn get numero => integer()();
  IntColumn get repeticoes => integer()();
  RealColumn get cargaKg => real()();
}

/// Medida do corpo: uma linha por medida e dia ("peso" 74 kg, "braço" 37 cm).
/// Nomes livres permitem qualquer outra medida.
@TableIndex(name: 'medida_dia_tipo', columns: {#dia, #tipo}, unique: true)
class Medidas extends Table with Sincronizavel {
  /// "aaaa-mm-dd" no fuso de São Paulo.
  TextColumn get dia => text()();
  TextColumn get tipo => text()();
  RealColumn get valor => real()();
  TextColumn get unidade => text()();
}

/// Alimento com valores por 100 g. [origem] 'pessoal' (cadastrado pela
/// pessoa); no futuro, 'catalogo' para uma tabela importada (ex.: TACO).
class Alimentos extends Table with Sincronizavel {
  TextColumn get nome => text()();
  RealColumn get kcal => real()();
  RealColumn get proteina => real().withDefault(const Constant(0))();
  RealColumn get carboidrato => real().withDefault(const Constant(0))();
  RealColumn get gordura => real().withDefault(const Constant(0))();

  /// Porção caseira opcional: "1 ovo" = 50 g.
  TextColumn get porcaoNome => text().nullable()();
  RealColumn get porcaoGramas => real().nullable()();
  TextColumn get origem => text().withDefault(const Constant('pessoal'))();
}

/// Alvo diário por tipo de dia ('treino' ou 'descanso'). Id natural.
@DataClassName('AlvoDieta')
class AlvosDieta extends Table with Sincronizavel {
  TextColumn get tipoDia => text()();
  RealColumn get kcal => real()();
  RealColumn get proteina => real().withDefault(const Constant(0))();
  RealColumn get carboidrato => real().withDefault(const Constant(0))();
  RealColumn get gordura => real().withDefault(const Constant(0))();
}

/// O que foi comido. Os valores ficam gravados (corrigir o alimento depois
/// não reescreve o passado).
@DataClassName('RegistroAlimentacao')
class RegistrosAlimentacao extends Table with Sincronizavel {
  /// "aaaa-mm-dd" no fuso de São Paulo.
  TextColumn get dia => text()();

  /// 'cafe', 'almoco', 'lanche', 'jantar' ou 'ceia'.
  TextColumn get refeicao => text()();
  TextColumn get alimentoId => text().nullable().references(Alimentos, #id)();
  TextColumn get nome => text()();
  RealColumn get gramas => real()();
  RealColumn get kcal => real()();
  RealColumn get proteina => real().withDefault(const Constant(0))();
  RealColumn get carboidrato => real().withDefault(const Constant(0))();
  RealColumn get gordura => real().withDefault(const Constant(0))();
}

enum PapelMensagem { eu, aurora, sistema }

/// Conversa com o assistente. Pedidos que só a IA responde ficam com
/// `naFila` até a IA (na nuvem) estar disponível.
@DataClassName('MensagemAssistente')
class MensagensAssistente extends Table with Sincronizavel {
  TextColumn get papel => textEnum<PapelMensagem>()();
  TextColumn get texto => text()();
  BoolColumn get naFila => boolean().withDefault(const Constant(false))();

  /// O que um comando rápido criou ('transacao', 'lembrete', 'tarefa',
  /// 'habito', 'medida') e o id, para o botão Desfazer.
  TextColumn get itemTipo => text().nullable()();
  TextColumn get itemId => text().nullable()();
  BoolColumn get desfeita => boolean().withDefault(const Constant(false))();
}

/// Preferências do aparelho (tema etc.). Não sincroniza.
class Preferencias extends Table {
  TextColumn get chave => text()();
  TextColumn get valor => text()();

  @override
  Set<Column<Object>> get primaryKey => {chave};
}

@DriftDatabase(tables: [
  Metas,
  Projetos,
  Tarefas,
  ConclusoesTarefa,
  Habitos,
  RegistrosHabito,
  ContasFinanceiras,
  Transacoes,
  PagamentosTransacao,
  Lembretes,
  Exercicios,
  Treinos,
  ItensTreino,
  SessoesTreino,
  SeriesFeitas,
  Medidas,
  Alimentos,
  AlvosDieta,
  RegistrosAlimentacao,
  MensagensAssistente,
  Preferencias,
])
class BancoAurora extends _$BancoAurora {
  BancoAurora([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'aurora'));

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, de, para) async {
          if (de < 2) {
            await m.addColumn(habitos, habitos.unidade);
            await m.addColumn(lembretes, lembretes.ativo);
            await m.createTable(conclusoesTarefa);
            await m.createIndex(conclusaoTarefaDia);
          }
          if (de < 3) {
            await m.addColumn(transacoes, transacoes.contaDestinoId);
            await m.createTable(pagamentosTransacao);
            await m.createIndex(pagamentoTransacaoVenc);
          }
          if (de < 4) {
            await m.createTable(exercicios);
            await m.createTable(treinos);
            await m.createTable(itensTreino);
            await m.createTable(sessoesTreino);
            await m.createTable(seriesFeitas);
            await m.createTable(medidas);
            await m.createIndex(medidaDiaTipo);
          }
          if (de < 5) {
            await m.createTable(mensagensAssistente);
          }
          if (de < 6) await _idsNaturais();
          if (de < 7) {
            await m.createTable(projetos);
            await m.addColumn(tarefas, tarefas.projetoId);
          }
          if (de < 8) {
            await m.createTable(alimentos);
            await m.createTable(alvosDieta);
            await m.createTable(registrosAlimentacao);
          }
        },
        beforeOpen: (detalhes) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// v6: registros com chave natural passam a usar o id calculado (idNatural).
  Future<void> _idsNaturais() async {
    for (final (tabela, tipo, colunas) in const [
      ('conclusoes_tarefa', 'conclusao_tarefa', ['tarefa_id', 'dia']),
      ('registros_habito', 'registro_habito', ['habito_id', 'dia']),
      ('pagamentos_transacao', 'pagamento_transacao', ['transacao_id', 'vencimento']),
      ('medidas', 'medida', ['dia', 'tipo']),
    ]) {
      final linhas = await customSelect('SELECT id, ${colunas.join(', ')} FROM $tabela').get();
      for (final l in linhas) {
        final novo = idNatural(tipo, [for (final c in colunas) l.read<String>(c)]);
        await customStatement('UPDATE $tabela SET id = ? WHERE id = ?', [novo, l.read<String>('id')]);
      }
    }
  }

  Future<String?> preferencia(String chave) async {
    final linha = await (select(preferencias)..where((p) => p.chave.equals(chave)))
        .getSingleOrNull();
    return linha?.valor;
  }

  Future<void> salvarPreferencia(String chave, String valor) =>
      into(preferencias).insertOnConflictUpdate(
          PreferenciasCompanion.insert(chave: chave, valor: valor));
}
