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

  /// "aaaa-mm-dd" da ocorrência, no fuso do aparelho.
  TextColumn get dia => text()();
}

@TableIndex(name: 'registro_habito_dia', columns: {#habitoId, #dia}, unique: true)
class RegistrosHabito extends Table with Sincronizavel {
  TextColumn get habitoId => text().references(Habitos, #id)();

  /// "aaaa-mm-dd" no fuso do aparelho.
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

  /// "aaaa-mm-dd" do vencimento da ocorrência, no fuso do aparelho.
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

  /// "Me despertar": no Android toca como despertador (tela cheia, som de
  /// alarme que repete, mesmo no silencioso). Nos outros, aviso comum.
  BoolColumn get despertar => boolean().withDefault(const Constant(false))();

  /// Item ligado (ex.: 'tarefa', 'transacao') e o id dele.
  TextColumn get itemTipo => text().nullable()();
  TextColumn get itemId => text().nullable()();
}

/// Compromisso: tem dia e hora marcados (e às vezes um lugar). Repetição é
/// REGRA (RRULE, como nos lembretes); editar vale para a série inteira.
class Compromissos extends Table with Sincronizavel {
  TextColumn get titulo => text()();

  /// Começo (instante). No dia inteiro, a meia-noite do dia no fuso do aparelho.
  DateTimeColumn get inicio => dateTime()();
  DateTimeColumn get fim => dateTime().nullable()();
  BoolColumn get diaInteiro => boolean().withDefault(const Constant(false))();
  TextColumn get local => text().nullable()();
  TextColumn get regraRepeticao => text().nullable()();

  /// Minutos de antecedência do aviso; nulo = sem aviso.
  IntColumn get avisoAntesMin => integer().nullable()();
  BoolColumn get despertar => boolean().withDefault(const Constant(false))();
  TextColumn get notas => text().nullable()();
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

  /// "aaaa-mm-dd" no fuso do aparelho.
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
  /// "aaaa-mm-dd" no fuso do aparelho.
  TextColumn get dia => text()();
  TextColumn get tipo => text()();
  RealColumn get valor => real()();
  TextColumn get unidade => text()();
}

/// Foto do check-in de shape: uma por dia e ângulo ('frente', 'costas',
/// 'lado'). Id natural. A linha sempre sincroniza; a imagem, só se [naNuvem]
/// (ver lib/data/fotos/). No aparelho: `<suporte>/fotos/<id>.webp` e
/// `<suporte>/miniaturas/<id>.webp`; na nuvem, o balde PRIVADO "fotos", em
/// `<user_id>/fotos/<id>.webp` e `<user_id>/miniaturas/<id>.webp`.
@DataClassName('FotoShape')
@TableIndex(name: 'foto_shape_dia_angulo', columns: {#dia, #angulo}, unique: true)
class FotosShape extends Table with Sincronizavel {
  /// "aaaa-mm-dd" no fuso do aparelho.
  TextColumn get dia => text()();
  TextColumn get angulo => text()();

  /// Nome do arquivo no aparelho (`<id>.webp`). Antes da v11 era um JPEG solto.
  TextColumn get arquivo => text()();

  /// SHA-256 da foto inteira (WebP). Muda quando a foto é trocada: é por ele que
  /// cada aparelho sabe se a cópia local está atual.
  TextColumn get hash => text().nullable()();

  /// A imagem está no balde da nuvem (senão só no aparelho que a tirou).
  BoolColumn get naNuvem => boolean().withDefault(const Constant(false))();
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
  /// "aaaa-mm-dd" no fuso do aparelho.
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

/// Rotina agendada do assistente. Modelos prontos usam id natural (um por
/// modelo, igual em todos os aparelhos); 'personalizada' manda [pedido] à IA.
@DataClassName('Automacao')
class Automacoes extends Table with Sincronizavel {
  TextColumn get nome => text()();
  TextColumn get modelo => text()();

  /// Bits de segunda (1) a domingo (64).
  IntColumn get diasSemana => integer().withDefault(const Constant(127))();

  /// "HH:mm".
  TextColumn get horario => text()();
  BoolColumn get ativa => boolean().withDefault(const Constant(false))();
  TextColumn get pedido => text().nullable()();

  /// "aaaa-mm-dd HH:mm" da última ocorrência executada (em qualquer aparelho).
  TextColumn get ultimaExecucao => text().nullable()();
}

/// Pasta de anotações ("Ideias", "Trabalho"). Nota sem pasta aparece só em "Todas".
@DataClassName('PastaNota')
class PastasNotas extends Table with Sincronizavel {
  TextColumn get nome => text()();
  IntColumn get ordem => integer().withDefault(const Constant(0))();
}

/// Como a nota foi criada (muda o ícone e o que o editor mostra primeiro).
enum TipoNota { texto, lista, foto, audio }

/// Anotação. As caixinhas ficam em [itens], em JSON (`[{"t": "Ovos", "f": true}]`):
/// a nota é editada inteira e, como nas outras tabelas, a versão mais nova vence.
class Notas extends Table with Sincronizavel {
  TextColumn get pastaId => text().nullable().references(PastasNotas, #id)();
  TextColumn get tipo => textEnum<TipoNota>().withDefault(Constant(TipoNota.texto.name))();
  TextColumn get titulo => text().withDefault(const Constant(''))();
  TextColumn get texto => text().withDefault(const Constant(''))();
  TextColumn get itens => text().nullable()();
  BoolColumn get fixada => boolean().withDefault(const Constant(false))();
}

/// Foto ou áudio de uma nota. Como as fotos do Shape: a LINHA sempre
/// sincroniza; o arquivo só se [naNuvem]. Fotos usam o mesmo CofreFotos
/// (`<suporte>/fotos/<id>.webp`, balde "fotos"); áudios, o CofreAudios
/// (`<suporte>/audios/<id>.<ext>`, balde privado "audios").
@DataClassName('AnexoNota')
class AnexosNota extends Table with Sincronizavel {
  TextColumn get notaId => text().references(Notas, #id)();

  /// 'foto' ou 'audio'.
  TextColumn get tipo => text()();
  TextColumn get hash => text().nullable()();
  BoolColumn get naNuvem => boolean().withDefault(const Constant(false))();

  /// Tipo do arquivo de áudio ("audio/mp4", "audio/flac", "audio/wav").
  TextColumn get formato => text().nullable()();
  IntColumn get duracaoMs => integer().nullable()();

  /// Volume do áudio em 48 dígitos de 0 a 9, para desenhar a onda sem abrir o arquivo.
  TextColumn get onda => text().nullable()();

  /// Texto do áudio: nulo até transcrever; vazio se não havia fala.
  TextColumn get transcricao => text().nullable()();
  IntColumn get ordem => integer().withDefault(const Constant(0))();
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
  Compromissos,
  Exercicios,
  Treinos,
  ItensTreino,
  SessoesTreino,
  SeriesFeitas,
  Medidas,
  FotosShape,
  Alimentos,
  AlvosDieta,
  RegistrosAlimentacao,
  MensagensAssistente,
  Automacoes,
  PastasNotas,
  Notas,
  AnexosNota,
  Preferencias,
])
class BancoAurora extends _$BancoAurora {
  /// `--dart-define=AURORA_BANCO=outro` abre um banco separado (para testar
  /// um aparelho novo sem mexer nos dados de verdade).
  BancoAurora([QueryExecutor? executor])
      : super(executor ??
            driftDatabase(
              name: const String.fromEnvironment('AURORA_BANCO', defaultValue: 'aurora'),
              // Na web (PWA): SQLite em Wasm, guardado no OPFS/IndexedDB do navegador (web/sqlite3.wasm).
              web: DriftWebOptions(
                sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                driftWorker: Uri.parse('drift_worker.js'),
              ),
            ));

  @override
  int get schemaVersion => 14;

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
          if (de < 9) await m.createTable(automacoes);
          if (de < 10) {
            // Pode já existir: um app mais antigo que abre o banco depois de
            // um mais novo volta o número da versão sem desfazer as tabelas.
            await m.createTable(fotosShape); // CREATE TABLE IF NOT EXISTS
            await customStatement('CREATE UNIQUE INDEX IF NOT EXISTS foto_shape_dia_angulo '
                'ON fotos_shape (dia, angulo)');
          }
          if (de < 11) {
            // Também aguenta rodar de novo (ver acima): a tabela criada no
            // passo anterior já vem com as colunas.
            if (!await _temColuna('fotos_shape', 'hash')) await m.addColumn(fotosShape, fotosShape.hash);
            if (!await _temColuna('fotos_shape', 'na_nuvem')) await m.addColumn(fotosShape, fotosShape.naNuvem);
          }
          if (de < 12) {
            // Idempotente como o passo 11 (o app dev e o instalado dividem o banco).
            if (!await _temColuna('lembretes', 'despertar')) await m.addColumn(lembretes, lembretes.despertar);
          }
          if (de < 13) {
            // CREATE TABLE IF NOT EXISTS: aguenta rodar de novo (ver o passo 10).
            await m.createTable(pastasNotas);
            await m.createTable(notas);
            await m.createTable(anexosNota);
          }
          if (de < 14) {
            // CREATE TABLE IF NOT EXISTS: aguenta rodar de novo (ver o passo 10).
            await m.createTable(compromissos);
          }
        },
        beforeOpen: (detalhes) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<bool> _temColuna(String tabela, String coluna) async {
    final colunas = await customSelect('PRAGMA table_info($tabela)').get();
    return colunas.any((c) => c.read<String>('name') == coluna);
  }

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
