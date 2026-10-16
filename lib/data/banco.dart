import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

part 'banco.g.dart';

const _uuid = Uuid();

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

class Metas extends Table with Sincronizavel {
  TextColumn get nome => text()();
  RealColumn get valorInicial => real()();
  RealColumn get valorAtual => real()();
  RealColumn get valorAlvo => real()();
  TextColumn get unidade => text().withDefault(const Constant(''))();
  DateTimeColumn get dataAlvo => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('ativa'))();
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

class ContasFinanceiras extends Table with Sincronizavel {
  TextColumn get nome => text()();
  TextColumn get tipo => textEnum<TipoConta>()();
  IntColumn get saldoInicialCentavos => integer().withDefault(const Constant(0))();
  IntColumn get diaFechamento => integer().nullable()();
  IntColumn get diaVencimento => integer().nullable()();
}

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

/// Preferências do aparelho (tema etc.). Não sincroniza.
class Preferencias extends Table {
  TextColumn get chave => text()();
  TextColumn get valor => text()();

  @override
  Set<Column<Object>> get primaryKey => {chave};
}

@DriftDatabase(tables: [
  Metas,
  Tarefas,
  ConclusoesTarefa,
  Habitos,
  RegistrosHabito,
  ContasFinanceiras,
  Transacoes,
  Lembretes,
  Preferencias,
])
class BancoAurora extends _$BancoAurora {
  BancoAurora([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'aurora'));

  @override
  int get schemaVersion => 2;

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
        },
        beforeOpen: (detalhes) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<String?> preferencia(String chave) async {
    final linha = await (select(preferencias)..where((p) => p.chave.equals(chave)))
        .getSingleOrNull();
    return linha?.valor;
  }

  Future<void> salvarPreferencia(String chave, String valor) =>
      into(preferencias).insertOnConflictUpdate(
          PreferenciasCompanion.insert(chave: chave, valor: valor));
}
