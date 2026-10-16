// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banco.dart';

// ignore_for_file: type=lint
class $MetasTable extends Metas with TableInfo<$MetasTable, Meta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _apagadoEmMeta = const VerificationMeta(
    'apagadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> apagadoEm = GeneratedColumn<DateTime>(
    'apagado_em',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorInicialMeta = const VerificationMeta(
    'valorInicial',
  );
  @override
  late final GeneratedColumn<double> valorInicial = GeneratedColumn<double>(
    'valor_inicial',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorAtualMeta = const VerificationMeta(
    'valorAtual',
  );
  @override
  late final GeneratedColumn<double> valorAtual = GeneratedColumn<double>(
    'valor_atual',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorAlvoMeta = const VerificationMeta(
    'valorAlvo',
  );
  @override
  late final GeneratedColumn<double> valorAlvo = GeneratedColumn<double>(
    'valor_alvo',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unidadeMeta = const VerificationMeta(
    'unidade',
  );
  @override
  late final GeneratedColumn<String> unidade = GeneratedColumn<String>(
    'unidade',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dataAlvoMeta = const VerificationMeta(
    'dataAlvo',
  );
  @override
  late final GeneratedColumn<DateTime> dataAlvo = GeneratedColumn<DateTime>(
    'data_alvo',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ativa'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    nome,
    valorInicial,
    valorAtual,
    valorAlvo,
    unidade,
    dataAlvo,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Meta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    }
    if (data.containsKey('apagado_em')) {
      context.handle(
        _apagadoEmMeta,
        apagadoEm.isAcceptableOrUnknown(data['apagado_em']!, _apagadoEmMeta),
      );
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('valor_inicial')) {
      context.handle(
        _valorInicialMeta,
        valorInicial.isAcceptableOrUnknown(
          data['valor_inicial']!,
          _valorInicialMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_valorInicialMeta);
    }
    if (data.containsKey('valor_atual')) {
      context.handle(
        _valorAtualMeta,
        valorAtual.isAcceptableOrUnknown(data['valor_atual']!, _valorAtualMeta),
      );
    } else if (isInserting) {
      context.missing(_valorAtualMeta);
    }
    if (data.containsKey('valor_alvo')) {
      context.handle(
        _valorAlvoMeta,
        valorAlvo.isAcceptableOrUnknown(data['valor_alvo']!, _valorAlvoMeta),
      );
    } else if (isInserting) {
      context.missing(_valorAlvoMeta);
    }
    if (data.containsKey('unidade')) {
      context.handle(
        _unidadeMeta,
        unidade.isAcceptableOrUnknown(data['unidade']!, _unidadeMeta),
      );
    }
    if (data.containsKey('data_alvo')) {
      context.handle(
        _dataAlvoMeta,
        dataAlvo.isAcceptableOrUnknown(data['data_alvo']!, _dataAlvoMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Meta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Meta(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      apagadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}apagado_em'],
      ),
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      valorInicial: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valor_inicial'],
      )!,
      valorAtual: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valor_atual'],
      )!,
      valorAlvo: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valor_alvo'],
      )!,
      unidade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unidade'],
      )!,
      dataAlvo: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_alvo'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $MetasTable createAlias(String alias) {
    return $MetasTable(attachedDatabase, alias);
  }
}

class Meta extends DataClass implements Insertable<Meta> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? apagadoEm;
  final String nome;
  final double valorInicial;
  final double valorAtual;
  final double valorAlvo;
  final String unidade;
  final DateTime? dataAlvo;
  final String status;
  const Meta({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.apagadoEm,
    required this.nome,
    required this.valorInicial,
    required this.valorAtual,
    required this.valorAlvo,
    required this.unidade,
    this.dataAlvo,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    if (!nullToAbsent || apagadoEm != null) {
      map['apagado_em'] = Variable<DateTime>(apagadoEm);
    }
    map['nome'] = Variable<String>(nome);
    map['valor_inicial'] = Variable<double>(valorInicial);
    map['valor_atual'] = Variable<double>(valorAtual);
    map['valor_alvo'] = Variable<double>(valorAlvo);
    map['unidade'] = Variable<String>(unidade);
    if (!nullToAbsent || dataAlvo != null) {
      map['data_alvo'] = Variable<DateTime>(dataAlvo);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  MetasCompanion toCompanion(bool nullToAbsent) {
    return MetasCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      apagadoEm: apagadoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(apagadoEm),
      nome: Value(nome),
      valorInicial: Value(valorInicial),
      valorAtual: Value(valorAtual),
      valorAlvo: Value(valorAlvo),
      unidade: Value(unidade),
      dataAlvo: dataAlvo == null && nullToAbsent
          ? const Value.absent()
          : Value(dataAlvo),
      status: Value(status),
    );
  }

  factory Meta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Meta(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      apagadoEm: serializer.fromJson<DateTime?>(json['apagadoEm']),
      nome: serializer.fromJson<String>(json['nome']),
      valorInicial: serializer.fromJson<double>(json['valorInicial']),
      valorAtual: serializer.fromJson<double>(json['valorAtual']),
      valorAlvo: serializer.fromJson<double>(json['valorAlvo']),
      unidade: serializer.fromJson<String>(json['unidade']),
      dataAlvo: serializer.fromJson<DateTime?>(json['dataAlvo']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'apagadoEm': serializer.toJson<DateTime?>(apagadoEm),
      'nome': serializer.toJson<String>(nome),
      'valorInicial': serializer.toJson<double>(valorInicial),
      'valorAtual': serializer.toJson<double>(valorAtual),
      'valorAlvo': serializer.toJson<double>(valorAlvo),
      'unidade': serializer.toJson<String>(unidade),
      'dataAlvo': serializer.toJson<DateTime?>(dataAlvo),
      'status': serializer.toJson<String>(status),
    };
  }

  Meta copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> apagadoEm = const Value.absent(),
    String? nome,
    double? valorInicial,
    double? valorAtual,
    double? valorAlvo,
    String? unidade,
    Value<DateTime?> dataAlvo = const Value.absent(),
    String? status,
  }) => Meta(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    apagadoEm: apagadoEm.present ? apagadoEm.value : this.apagadoEm,
    nome: nome ?? this.nome,
    valorInicial: valorInicial ?? this.valorInicial,
    valorAtual: valorAtual ?? this.valorAtual,
    valorAlvo: valorAlvo ?? this.valorAlvo,
    unidade: unidade ?? this.unidade,
    dataAlvo: dataAlvo.present ? dataAlvo.value : this.dataAlvo,
    status: status ?? this.status,
  );
  Meta copyWithCompanion(MetasCompanion data) {
    return Meta(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      apagadoEm: data.apagadoEm.present ? data.apagadoEm.value : this.apagadoEm,
      nome: data.nome.present ? data.nome.value : this.nome,
      valorInicial: data.valorInicial.present
          ? data.valorInicial.value
          : this.valorInicial,
      valorAtual: data.valorAtual.present
          ? data.valorAtual.value
          : this.valorAtual,
      valorAlvo: data.valorAlvo.present ? data.valorAlvo.value : this.valorAlvo,
      unidade: data.unidade.present ? data.unidade.value : this.unidade,
      dataAlvo: data.dataAlvo.present ? data.dataAlvo.value : this.dataAlvo,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Meta(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('nome: $nome, ')
          ..write('valorInicial: $valorInicial, ')
          ..write('valorAtual: $valorAtual, ')
          ..write('valorAlvo: $valorAlvo, ')
          ..write('unidade: $unidade, ')
          ..write('dataAlvo: $dataAlvo, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    nome,
    valorInicial,
    valorAtual,
    valorAlvo,
    unidade,
    dataAlvo,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Meta &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.apagadoEm == this.apagadoEm &&
          other.nome == this.nome &&
          other.valorInicial == this.valorInicial &&
          other.valorAtual == this.valorAtual &&
          other.valorAlvo == this.valorAlvo &&
          other.unidade == this.unidade &&
          other.dataAlvo == this.dataAlvo &&
          other.status == this.status);
}

class MetasCompanion extends UpdateCompanion<Meta> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> apagadoEm;
  final Value<String> nome;
  final Value<double> valorInicial;
  final Value<double> valorAtual;
  final Value<double> valorAlvo;
  final Value<String> unidade;
  final Value<DateTime?> dataAlvo;
  final Value<String> status;
  final Value<int> rowid;
  const MetasCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    this.nome = const Value.absent(),
    this.valorInicial = const Value.absent(),
    this.valorAtual = const Value.absent(),
    this.valorAlvo = const Value.absent(),
    this.unidade = const Value.absent(),
    this.dataAlvo = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetasCompanion.insert({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    required String nome,
    required double valorInicial,
    required double valorAtual,
    required double valorAlvo,
    this.unidade = const Value.absent(),
    this.dataAlvo = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : nome = Value(nome),
       valorInicial = Value(valorInicial),
       valorAtual = Value(valorAtual),
       valorAlvo = Value(valorAlvo);
  static Insertable<Meta> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? apagadoEm,
    Expression<String>? nome,
    Expression<double>? valorInicial,
    Expression<double>? valorAtual,
    Expression<double>? valorAlvo,
    Expression<String>? unidade,
    Expression<DateTime>? dataAlvo,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (apagadoEm != null) 'apagado_em': apagadoEm,
      if (nome != null) 'nome': nome,
      if (valorInicial != null) 'valor_inicial': valorInicial,
      if (valorAtual != null) 'valor_atual': valorAtual,
      if (valorAlvo != null) 'valor_alvo': valorAlvo,
      if (unidade != null) 'unidade': unidade,
      if (dataAlvo != null) 'data_alvo': dataAlvo,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetasCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? apagadoEm,
    Value<String>? nome,
    Value<double>? valorInicial,
    Value<double>? valorAtual,
    Value<double>? valorAlvo,
    Value<String>? unidade,
    Value<DateTime?>? dataAlvo,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return MetasCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      apagadoEm: apagadoEm ?? this.apagadoEm,
      nome: nome ?? this.nome,
      valorInicial: valorInicial ?? this.valorInicial,
      valorAtual: valorAtual ?? this.valorAtual,
      valorAlvo: valorAlvo ?? this.valorAlvo,
      unidade: unidade ?? this.unidade,
      dataAlvo: dataAlvo ?? this.dataAlvo,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (apagadoEm.present) {
      map['apagado_em'] = Variable<DateTime>(apagadoEm.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (valorInicial.present) {
      map['valor_inicial'] = Variable<double>(valorInicial.value);
    }
    if (valorAtual.present) {
      map['valor_atual'] = Variable<double>(valorAtual.value);
    }
    if (valorAlvo.present) {
      map['valor_alvo'] = Variable<double>(valorAlvo.value);
    }
    if (unidade.present) {
      map['unidade'] = Variable<String>(unidade.value);
    }
    if (dataAlvo.present) {
      map['data_alvo'] = Variable<DateTime>(dataAlvo.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetasCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('nome: $nome, ')
          ..write('valorInicial: $valorInicial, ')
          ..write('valorAtual: $valorAtual, ')
          ..write('valorAlvo: $valorAlvo, ')
          ..write('unidade: $unidade, ')
          ..write('dataAlvo: $dataAlvo, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TarefasTable extends Tarefas with TableInfo<$TarefasTable, Tarefa> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TarefasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _apagadoEmMeta = const VerificationMeta(
    'apagadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> apagadoEm = GeneratedColumn<DateTime>(
    'apagado_em',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tituloMeta = const VerificationMeta('titulo');
  @override
  late final GeneratedColumn<String> titulo = GeneratedColumn<String>(
    'titulo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
    'notas',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _prazoMeta = const VerificationMeta('prazo');
  @override
  late final GeneratedColumn<DateTime> prazo = GeneratedColumn<DateTime>(
    'prazo',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _prazoTemHoraMeta = const VerificationMeta(
    'prazoTemHora',
  );
  @override
  late final GeneratedColumn<bool> prazoTemHora = GeneratedColumn<bool>(
    'prazo_tem_hora',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("prazo_tem_hora" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Prioridade, String> prioridade =
      GeneratedColumn<String>(
        'prioridade',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(Prioridade.media.name),
      ).withConverter<Prioridade>($TarefasTable.$converterprioridade);
  static const VerificationMeta _feitaEmMeta = const VerificationMeta(
    'feitaEm',
  );
  @override
  late final GeneratedColumn<DateTime> feitaEm = GeneratedColumn<DateTime>(
    'feita_em',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _regraRepeticaoMeta = const VerificationMeta(
    'regraRepeticao',
  );
  @override
  late final GeneratedColumn<String> regraRepeticao = GeneratedColumn<String>(
    'regra_repeticao',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metaIdMeta = const VerificationMeta('metaId');
  @override
  late final GeneratedColumn<String> metaId = GeneratedColumn<String>(
    'meta_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES metas (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    titulo,
    notas,
    prazo,
    prazoTemHora,
    prioridade,
    feitaEm,
    regraRepeticao,
    metaId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tarefas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tarefa> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    }
    if (data.containsKey('apagado_em')) {
      context.handle(
        _apagadoEmMeta,
        apagadoEm.isAcceptableOrUnknown(data['apagado_em']!, _apagadoEmMeta),
      );
    }
    if (data.containsKey('titulo')) {
      context.handle(
        _tituloMeta,
        titulo.isAcceptableOrUnknown(data['titulo']!, _tituloMeta),
      );
    } else if (isInserting) {
      context.missing(_tituloMeta);
    }
    if (data.containsKey('notas')) {
      context.handle(
        _notasMeta,
        notas.isAcceptableOrUnknown(data['notas']!, _notasMeta),
      );
    }
    if (data.containsKey('prazo')) {
      context.handle(
        _prazoMeta,
        prazo.isAcceptableOrUnknown(data['prazo']!, _prazoMeta),
      );
    }
    if (data.containsKey('prazo_tem_hora')) {
      context.handle(
        _prazoTemHoraMeta,
        prazoTemHora.isAcceptableOrUnknown(
          data['prazo_tem_hora']!,
          _prazoTemHoraMeta,
        ),
      );
    }
    if (data.containsKey('feita_em')) {
      context.handle(
        _feitaEmMeta,
        feitaEm.isAcceptableOrUnknown(data['feita_em']!, _feitaEmMeta),
      );
    }
    if (data.containsKey('regra_repeticao')) {
      context.handle(
        _regraRepeticaoMeta,
        regraRepeticao.isAcceptableOrUnknown(
          data['regra_repeticao']!,
          _regraRepeticaoMeta,
        ),
      );
    }
    if (data.containsKey('meta_id')) {
      context.handle(
        _metaIdMeta,
        metaId.isAcceptableOrUnknown(data['meta_id']!, _metaIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tarefa map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tarefa(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      apagadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}apagado_em'],
      ),
      titulo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titulo'],
      )!,
      notas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notas'],
      ),
      prazo: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}prazo'],
      ),
      prazoTemHora: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}prazo_tem_hora'],
      )!,
      prioridade: $TarefasTable.$converterprioridade.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}prioridade'],
        )!,
      ),
      feitaEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}feita_em'],
      ),
      regraRepeticao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}regra_repeticao'],
      ),
      metaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meta_id'],
      ),
    );
  }

  @override
  $TarefasTable createAlias(String alias) {
    return $TarefasTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Prioridade, String, String> $converterprioridade =
      const EnumNameConverter<Prioridade>(Prioridade.values);
}

class Tarefa extends DataClass implements Insertable<Tarefa> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? apagadoEm;
  final String titulo;
  final String? notas;
  final DateTime? prazo;
  final bool prazoTemHora;
  final Prioridade prioridade;
  final DateTime? feitaEm;
  final String? regraRepeticao;
  final String? metaId;
  const Tarefa({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.apagadoEm,
    required this.titulo,
    this.notas,
    this.prazo,
    required this.prazoTemHora,
    required this.prioridade,
    this.feitaEm,
    this.regraRepeticao,
    this.metaId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    if (!nullToAbsent || apagadoEm != null) {
      map['apagado_em'] = Variable<DateTime>(apagadoEm);
    }
    map['titulo'] = Variable<String>(titulo);
    if (!nullToAbsent || notas != null) {
      map['notas'] = Variable<String>(notas);
    }
    if (!nullToAbsent || prazo != null) {
      map['prazo'] = Variable<DateTime>(prazo);
    }
    map['prazo_tem_hora'] = Variable<bool>(prazoTemHora);
    {
      map['prioridade'] = Variable<String>(
        $TarefasTable.$converterprioridade.toSql(prioridade),
      );
    }
    if (!nullToAbsent || feitaEm != null) {
      map['feita_em'] = Variable<DateTime>(feitaEm);
    }
    if (!nullToAbsent || regraRepeticao != null) {
      map['regra_repeticao'] = Variable<String>(regraRepeticao);
    }
    if (!nullToAbsent || metaId != null) {
      map['meta_id'] = Variable<String>(metaId);
    }
    return map;
  }

  TarefasCompanion toCompanion(bool nullToAbsent) {
    return TarefasCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      apagadoEm: apagadoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(apagadoEm),
      titulo: Value(titulo),
      notas: notas == null && nullToAbsent
          ? const Value.absent()
          : Value(notas),
      prazo: prazo == null && nullToAbsent
          ? const Value.absent()
          : Value(prazo),
      prazoTemHora: Value(prazoTemHora),
      prioridade: Value(prioridade),
      feitaEm: feitaEm == null && nullToAbsent
          ? const Value.absent()
          : Value(feitaEm),
      regraRepeticao: regraRepeticao == null && nullToAbsent
          ? const Value.absent()
          : Value(regraRepeticao),
      metaId: metaId == null && nullToAbsent
          ? const Value.absent()
          : Value(metaId),
    );
  }

  factory Tarefa.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tarefa(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      apagadoEm: serializer.fromJson<DateTime?>(json['apagadoEm']),
      titulo: serializer.fromJson<String>(json['titulo']),
      notas: serializer.fromJson<String?>(json['notas']),
      prazo: serializer.fromJson<DateTime?>(json['prazo']),
      prazoTemHora: serializer.fromJson<bool>(json['prazoTemHora']),
      prioridade: $TarefasTable.$converterprioridade.fromJson(
        serializer.fromJson<String>(json['prioridade']),
      ),
      feitaEm: serializer.fromJson<DateTime?>(json['feitaEm']),
      regraRepeticao: serializer.fromJson<String?>(json['regraRepeticao']),
      metaId: serializer.fromJson<String?>(json['metaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'apagadoEm': serializer.toJson<DateTime?>(apagadoEm),
      'titulo': serializer.toJson<String>(titulo),
      'notas': serializer.toJson<String?>(notas),
      'prazo': serializer.toJson<DateTime?>(prazo),
      'prazoTemHora': serializer.toJson<bool>(prazoTemHora),
      'prioridade': serializer.toJson<String>(
        $TarefasTable.$converterprioridade.toJson(prioridade),
      ),
      'feitaEm': serializer.toJson<DateTime?>(feitaEm),
      'regraRepeticao': serializer.toJson<String?>(regraRepeticao),
      'metaId': serializer.toJson<String?>(metaId),
    };
  }

  Tarefa copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> apagadoEm = const Value.absent(),
    String? titulo,
    Value<String?> notas = const Value.absent(),
    Value<DateTime?> prazo = const Value.absent(),
    bool? prazoTemHora,
    Prioridade? prioridade,
    Value<DateTime?> feitaEm = const Value.absent(),
    Value<String?> regraRepeticao = const Value.absent(),
    Value<String?> metaId = const Value.absent(),
  }) => Tarefa(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    apagadoEm: apagadoEm.present ? apagadoEm.value : this.apagadoEm,
    titulo: titulo ?? this.titulo,
    notas: notas.present ? notas.value : this.notas,
    prazo: prazo.present ? prazo.value : this.prazo,
    prazoTemHora: prazoTemHora ?? this.prazoTemHora,
    prioridade: prioridade ?? this.prioridade,
    feitaEm: feitaEm.present ? feitaEm.value : this.feitaEm,
    regraRepeticao: regraRepeticao.present
        ? regraRepeticao.value
        : this.regraRepeticao,
    metaId: metaId.present ? metaId.value : this.metaId,
  );
  Tarefa copyWithCompanion(TarefasCompanion data) {
    return Tarefa(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      apagadoEm: data.apagadoEm.present ? data.apagadoEm.value : this.apagadoEm,
      titulo: data.titulo.present ? data.titulo.value : this.titulo,
      notas: data.notas.present ? data.notas.value : this.notas,
      prazo: data.prazo.present ? data.prazo.value : this.prazo,
      prazoTemHora: data.prazoTemHora.present
          ? data.prazoTemHora.value
          : this.prazoTemHora,
      prioridade: data.prioridade.present
          ? data.prioridade.value
          : this.prioridade,
      feitaEm: data.feitaEm.present ? data.feitaEm.value : this.feitaEm,
      regraRepeticao: data.regraRepeticao.present
          ? data.regraRepeticao.value
          : this.regraRepeticao,
      metaId: data.metaId.present ? data.metaId.value : this.metaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tarefa(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('titulo: $titulo, ')
          ..write('notas: $notas, ')
          ..write('prazo: $prazo, ')
          ..write('prazoTemHora: $prazoTemHora, ')
          ..write('prioridade: $prioridade, ')
          ..write('feitaEm: $feitaEm, ')
          ..write('regraRepeticao: $regraRepeticao, ')
          ..write('metaId: $metaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    titulo,
    notas,
    prazo,
    prazoTemHora,
    prioridade,
    feitaEm,
    regraRepeticao,
    metaId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tarefa &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.apagadoEm == this.apagadoEm &&
          other.titulo == this.titulo &&
          other.notas == this.notas &&
          other.prazo == this.prazo &&
          other.prazoTemHora == this.prazoTemHora &&
          other.prioridade == this.prioridade &&
          other.feitaEm == this.feitaEm &&
          other.regraRepeticao == this.regraRepeticao &&
          other.metaId == this.metaId);
}

class TarefasCompanion extends UpdateCompanion<Tarefa> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> apagadoEm;
  final Value<String> titulo;
  final Value<String?> notas;
  final Value<DateTime?> prazo;
  final Value<bool> prazoTemHora;
  final Value<Prioridade> prioridade;
  final Value<DateTime?> feitaEm;
  final Value<String?> regraRepeticao;
  final Value<String?> metaId;
  final Value<int> rowid;
  const TarefasCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    this.titulo = const Value.absent(),
    this.notas = const Value.absent(),
    this.prazo = const Value.absent(),
    this.prazoTemHora = const Value.absent(),
    this.prioridade = const Value.absent(),
    this.feitaEm = const Value.absent(),
    this.regraRepeticao = const Value.absent(),
    this.metaId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TarefasCompanion.insert({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    required String titulo,
    this.notas = const Value.absent(),
    this.prazo = const Value.absent(),
    this.prazoTemHora = const Value.absent(),
    this.prioridade = const Value.absent(),
    this.feitaEm = const Value.absent(),
    this.regraRepeticao = const Value.absent(),
    this.metaId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : titulo = Value(titulo);
  static Insertable<Tarefa> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? apagadoEm,
    Expression<String>? titulo,
    Expression<String>? notas,
    Expression<DateTime>? prazo,
    Expression<bool>? prazoTemHora,
    Expression<String>? prioridade,
    Expression<DateTime>? feitaEm,
    Expression<String>? regraRepeticao,
    Expression<String>? metaId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (apagadoEm != null) 'apagado_em': apagadoEm,
      if (titulo != null) 'titulo': titulo,
      if (notas != null) 'notas': notas,
      if (prazo != null) 'prazo': prazo,
      if (prazoTemHora != null) 'prazo_tem_hora': prazoTemHora,
      if (prioridade != null) 'prioridade': prioridade,
      if (feitaEm != null) 'feita_em': feitaEm,
      if (regraRepeticao != null) 'regra_repeticao': regraRepeticao,
      if (metaId != null) 'meta_id': metaId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TarefasCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? apagadoEm,
    Value<String>? titulo,
    Value<String?>? notas,
    Value<DateTime?>? prazo,
    Value<bool>? prazoTemHora,
    Value<Prioridade>? prioridade,
    Value<DateTime?>? feitaEm,
    Value<String?>? regraRepeticao,
    Value<String?>? metaId,
    Value<int>? rowid,
  }) {
    return TarefasCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      apagadoEm: apagadoEm ?? this.apagadoEm,
      titulo: titulo ?? this.titulo,
      notas: notas ?? this.notas,
      prazo: prazo ?? this.prazo,
      prazoTemHora: prazoTemHora ?? this.prazoTemHora,
      prioridade: prioridade ?? this.prioridade,
      feitaEm: feitaEm ?? this.feitaEm,
      regraRepeticao: regraRepeticao ?? this.regraRepeticao,
      metaId: metaId ?? this.metaId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (apagadoEm.present) {
      map['apagado_em'] = Variable<DateTime>(apagadoEm.value);
    }
    if (titulo.present) {
      map['titulo'] = Variable<String>(titulo.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    if (prazo.present) {
      map['prazo'] = Variable<DateTime>(prazo.value);
    }
    if (prazoTemHora.present) {
      map['prazo_tem_hora'] = Variable<bool>(prazoTemHora.value);
    }
    if (prioridade.present) {
      map['prioridade'] = Variable<String>(
        $TarefasTable.$converterprioridade.toSql(prioridade.value),
      );
    }
    if (feitaEm.present) {
      map['feita_em'] = Variable<DateTime>(feitaEm.value);
    }
    if (regraRepeticao.present) {
      map['regra_repeticao'] = Variable<String>(regraRepeticao.value);
    }
    if (metaId.present) {
      map['meta_id'] = Variable<String>(metaId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TarefasCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('titulo: $titulo, ')
          ..write('notas: $notas, ')
          ..write('prazo: $prazo, ')
          ..write('prazoTemHora: $prazoTemHora, ')
          ..write('prioridade: $prioridade, ')
          ..write('feitaEm: $feitaEm, ')
          ..write('regraRepeticao: $regraRepeticao, ')
          ..write('metaId: $metaId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConclusoesTarefaTable extends ConclusoesTarefa
    with TableInfo<$ConclusoesTarefaTable, ConclusoesTarefaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConclusoesTarefaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _apagadoEmMeta = const VerificationMeta(
    'apagadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> apagadoEm = GeneratedColumn<DateTime>(
    'apagado_em',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tarefaIdMeta = const VerificationMeta(
    'tarefaId',
  );
  @override
  late final GeneratedColumn<String> tarefaId = GeneratedColumn<String>(
    'tarefa_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tarefas (id)',
    ),
  );
  static const VerificationMeta _diaMeta = const VerificationMeta('dia');
  @override
  late final GeneratedColumn<String> dia = GeneratedColumn<String>(
    'dia',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    tarefaId,
    dia,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conclusoes_tarefa';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConclusoesTarefaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    }
    if (data.containsKey('apagado_em')) {
      context.handle(
        _apagadoEmMeta,
        apagadoEm.isAcceptableOrUnknown(data['apagado_em']!, _apagadoEmMeta),
      );
    }
    if (data.containsKey('tarefa_id')) {
      context.handle(
        _tarefaIdMeta,
        tarefaId.isAcceptableOrUnknown(data['tarefa_id']!, _tarefaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tarefaIdMeta);
    }
    if (data.containsKey('dia')) {
      context.handle(
        _diaMeta,
        dia.isAcceptableOrUnknown(data['dia']!, _diaMeta),
      );
    } else if (isInserting) {
      context.missing(_diaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConclusoesTarefaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConclusoesTarefaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      apagadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}apagado_em'],
      ),
      tarefaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tarefa_id'],
      )!,
      dia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dia'],
      )!,
    );
  }

  @override
  $ConclusoesTarefaTable createAlias(String alias) {
    return $ConclusoesTarefaTable(attachedDatabase, alias);
  }
}

class ConclusoesTarefaData extends DataClass
    implements Insertable<ConclusoesTarefaData> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? apagadoEm;
  final String tarefaId;

  /// "aaaa-mm-dd" da ocorrência, no fuso de São Paulo.
  final String dia;
  const ConclusoesTarefaData({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.apagadoEm,
    required this.tarefaId,
    required this.dia,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    if (!nullToAbsent || apagadoEm != null) {
      map['apagado_em'] = Variable<DateTime>(apagadoEm);
    }
    map['tarefa_id'] = Variable<String>(tarefaId);
    map['dia'] = Variable<String>(dia);
    return map;
  }

  ConclusoesTarefaCompanion toCompanion(bool nullToAbsent) {
    return ConclusoesTarefaCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      apagadoEm: apagadoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(apagadoEm),
      tarefaId: Value(tarefaId),
      dia: Value(dia),
    );
  }

  factory ConclusoesTarefaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConclusoesTarefaData(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      apagadoEm: serializer.fromJson<DateTime?>(json['apagadoEm']),
      tarefaId: serializer.fromJson<String>(json['tarefaId']),
      dia: serializer.fromJson<String>(json['dia']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'apagadoEm': serializer.toJson<DateTime?>(apagadoEm),
      'tarefaId': serializer.toJson<String>(tarefaId),
      'dia': serializer.toJson<String>(dia),
    };
  }

  ConclusoesTarefaData copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> apagadoEm = const Value.absent(),
    String? tarefaId,
    String? dia,
  }) => ConclusoesTarefaData(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    apagadoEm: apagadoEm.present ? apagadoEm.value : this.apagadoEm,
    tarefaId: tarefaId ?? this.tarefaId,
    dia: dia ?? this.dia,
  );
  ConclusoesTarefaData copyWithCompanion(ConclusoesTarefaCompanion data) {
    return ConclusoesTarefaData(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      apagadoEm: data.apagadoEm.present ? data.apagadoEm.value : this.apagadoEm,
      tarefaId: data.tarefaId.present ? data.tarefaId.value : this.tarefaId,
      dia: data.dia.present ? data.dia.value : this.dia,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConclusoesTarefaData(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('tarefaId: $tarefaId, ')
          ..write('dia: $dia')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, criadoEm, atualizadoEm, apagadoEm, tarefaId, dia);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConclusoesTarefaData &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.apagadoEm == this.apagadoEm &&
          other.tarefaId == this.tarefaId &&
          other.dia == this.dia);
}

class ConclusoesTarefaCompanion extends UpdateCompanion<ConclusoesTarefaData> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> apagadoEm;
  final Value<String> tarefaId;
  final Value<String> dia;
  final Value<int> rowid;
  const ConclusoesTarefaCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    this.tarefaId = const Value.absent(),
    this.dia = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConclusoesTarefaCompanion.insert({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    required String tarefaId,
    required String dia,
    this.rowid = const Value.absent(),
  }) : tarefaId = Value(tarefaId),
       dia = Value(dia);
  static Insertable<ConclusoesTarefaData> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? apagadoEm,
    Expression<String>? tarefaId,
    Expression<String>? dia,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (apagadoEm != null) 'apagado_em': apagadoEm,
      if (tarefaId != null) 'tarefa_id': tarefaId,
      if (dia != null) 'dia': dia,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConclusoesTarefaCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? apagadoEm,
    Value<String>? tarefaId,
    Value<String>? dia,
    Value<int>? rowid,
  }) {
    return ConclusoesTarefaCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      apagadoEm: apagadoEm ?? this.apagadoEm,
      tarefaId: tarefaId ?? this.tarefaId,
      dia: dia ?? this.dia,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (apagadoEm.present) {
      map['apagado_em'] = Variable<DateTime>(apagadoEm.value);
    }
    if (tarefaId.present) {
      map['tarefa_id'] = Variable<String>(tarefaId.value);
    }
    if (dia.present) {
      map['dia'] = Variable<String>(dia.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConclusoesTarefaCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('tarefaId: $tarefaId, ')
          ..write('dia: $dia, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitosTable extends Habitos with TableInfo<$HabitosTable, Habito> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _apagadoEmMeta = const VerificationMeta(
    'apagadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> apagadoEm = GeneratedColumn<DateTime>(
    'apagado_em',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoHabito, String> tipo =
      GeneratedColumn<String>(
        'tipo',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(TipoHabito.marcar.name),
      ).withConverter<TipoHabito>($HabitosTable.$convertertipo);
  static const VerificationMeta _diasSemanaMeta = const VerificationMeta(
    'diasSemana',
  );
  @override
  late final GeneratedColumn<int> diasSemana = GeneratedColumn<int>(
    'dias_semana',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(127),
  );
  static const VerificationMeta _horarioMeta = const VerificationMeta(
    'horario',
  );
  @override
  late final GeneratedColumn<String> horario = GeneratedColumn<String>(
    'horario',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alvoMeta = const VerificationMeta('alvo');
  @override
  late final GeneratedColumn<int> alvo = GeneratedColumn<int>(
    'alvo',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unidadeMeta = const VerificationMeta(
    'unidade',
  );
  @override
  late final GeneratedColumn<String> unidade = GeneratedColumn<String>(
    'unidade',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metaIdMeta = const VerificationMeta('metaId');
  @override
  late final GeneratedColumn<String> metaId = GeneratedColumn<String>(
    'meta_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES metas (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    nome,
    tipo,
    diasSemana,
    horario,
    alvo,
    unidade,
    metaId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habitos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Habito> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    }
    if (data.containsKey('apagado_em')) {
      context.handle(
        _apagadoEmMeta,
        apagadoEm.isAcceptableOrUnknown(data['apagado_em']!, _apagadoEmMeta),
      );
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('dias_semana')) {
      context.handle(
        _diasSemanaMeta,
        diasSemana.isAcceptableOrUnknown(data['dias_semana']!, _diasSemanaMeta),
      );
    }
    if (data.containsKey('horario')) {
      context.handle(
        _horarioMeta,
        horario.isAcceptableOrUnknown(data['horario']!, _horarioMeta),
      );
    }
    if (data.containsKey('alvo')) {
      context.handle(
        _alvoMeta,
        alvo.isAcceptableOrUnknown(data['alvo']!, _alvoMeta),
      );
    }
    if (data.containsKey('unidade')) {
      context.handle(
        _unidadeMeta,
        unidade.isAcceptableOrUnknown(data['unidade']!, _unidadeMeta),
      );
    }
    if (data.containsKey('meta_id')) {
      context.handle(
        _metaIdMeta,
        metaId.isAcceptableOrUnknown(data['meta_id']!, _metaIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Habito map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Habito(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      apagadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}apagado_em'],
      ),
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      tipo: $HabitosTable.$convertertipo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tipo'],
        )!,
      ),
      diasSemana: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dias_semana'],
      )!,
      horario: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}horario'],
      ),
      alvo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}alvo'],
      ),
      unidade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unidade'],
      ),
      metaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meta_id'],
      ),
    );
  }

  @override
  $HabitosTable createAlias(String alias) {
    return $HabitosTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoHabito, String, String> $convertertipo =
      const EnumNameConverter<TipoHabito>(TipoHabito.values);
}

class Habito extends DataClass implements Insertable<Habito> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? apagadoEm;
  final String nome;
  final TipoHabito tipo;

  /// Bits de segunda (1) a domingo (64). 127 = todos os dias.
  final int diasSemana;

  /// "HH:mm" ou nulo quando não tem horário.
  final String? horario;

  /// Minutos (duração) ou quantidade, conforme o tipo.
  final int? alvo;

  /// Unidade da quantidade ("copos", "páginas").
  final String? unidade;
  final String? metaId;
  const Habito({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.apagadoEm,
    required this.nome,
    required this.tipo,
    required this.diasSemana,
    this.horario,
    this.alvo,
    this.unidade,
    this.metaId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    if (!nullToAbsent || apagadoEm != null) {
      map['apagado_em'] = Variable<DateTime>(apagadoEm);
    }
    map['nome'] = Variable<String>(nome);
    {
      map['tipo'] = Variable<String>($HabitosTable.$convertertipo.toSql(tipo));
    }
    map['dias_semana'] = Variable<int>(diasSemana);
    if (!nullToAbsent || horario != null) {
      map['horario'] = Variable<String>(horario);
    }
    if (!nullToAbsent || alvo != null) {
      map['alvo'] = Variable<int>(alvo);
    }
    if (!nullToAbsent || unidade != null) {
      map['unidade'] = Variable<String>(unidade);
    }
    if (!nullToAbsent || metaId != null) {
      map['meta_id'] = Variable<String>(metaId);
    }
    return map;
  }

  HabitosCompanion toCompanion(bool nullToAbsent) {
    return HabitosCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      apagadoEm: apagadoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(apagadoEm),
      nome: Value(nome),
      tipo: Value(tipo),
      diasSemana: Value(diasSemana),
      horario: horario == null && nullToAbsent
          ? const Value.absent()
          : Value(horario),
      alvo: alvo == null && nullToAbsent ? const Value.absent() : Value(alvo),
      unidade: unidade == null && nullToAbsent
          ? const Value.absent()
          : Value(unidade),
      metaId: metaId == null && nullToAbsent
          ? const Value.absent()
          : Value(metaId),
    );
  }

  factory Habito.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Habito(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      apagadoEm: serializer.fromJson<DateTime?>(json['apagadoEm']),
      nome: serializer.fromJson<String>(json['nome']),
      tipo: $HabitosTable.$convertertipo.fromJson(
        serializer.fromJson<String>(json['tipo']),
      ),
      diasSemana: serializer.fromJson<int>(json['diasSemana']),
      horario: serializer.fromJson<String?>(json['horario']),
      alvo: serializer.fromJson<int?>(json['alvo']),
      unidade: serializer.fromJson<String?>(json['unidade']),
      metaId: serializer.fromJson<String?>(json['metaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'apagadoEm': serializer.toJson<DateTime?>(apagadoEm),
      'nome': serializer.toJson<String>(nome),
      'tipo': serializer.toJson<String>(
        $HabitosTable.$convertertipo.toJson(tipo),
      ),
      'diasSemana': serializer.toJson<int>(diasSemana),
      'horario': serializer.toJson<String?>(horario),
      'alvo': serializer.toJson<int?>(alvo),
      'unidade': serializer.toJson<String?>(unidade),
      'metaId': serializer.toJson<String?>(metaId),
    };
  }

  Habito copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> apagadoEm = const Value.absent(),
    String? nome,
    TipoHabito? tipo,
    int? diasSemana,
    Value<String?> horario = const Value.absent(),
    Value<int?> alvo = const Value.absent(),
    Value<String?> unidade = const Value.absent(),
    Value<String?> metaId = const Value.absent(),
  }) => Habito(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    apagadoEm: apagadoEm.present ? apagadoEm.value : this.apagadoEm,
    nome: nome ?? this.nome,
    tipo: tipo ?? this.tipo,
    diasSemana: diasSemana ?? this.diasSemana,
    horario: horario.present ? horario.value : this.horario,
    alvo: alvo.present ? alvo.value : this.alvo,
    unidade: unidade.present ? unidade.value : this.unidade,
    metaId: metaId.present ? metaId.value : this.metaId,
  );
  Habito copyWithCompanion(HabitosCompanion data) {
    return Habito(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      apagadoEm: data.apagadoEm.present ? data.apagadoEm.value : this.apagadoEm,
      nome: data.nome.present ? data.nome.value : this.nome,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      diasSemana: data.diasSemana.present
          ? data.diasSemana.value
          : this.diasSemana,
      horario: data.horario.present ? data.horario.value : this.horario,
      alvo: data.alvo.present ? data.alvo.value : this.alvo,
      unidade: data.unidade.present ? data.unidade.value : this.unidade,
      metaId: data.metaId.present ? data.metaId.value : this.metaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Habito(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('nome: $nome, ')
          ..write('tipo: $tipo, ')
          ..write('diasSemana: $diasSemana, ')
          ..write('horario: $horario, ')
          ..write('alvo: $alvo, ')
          ..write('unidade: $unidade, ')
          ..write('metaId: $metaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    nome,
    tipo,
    diasSemana,
    horario,
    alvo,
    unidade,
    metaId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Habito &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.apagadoEm == this.apagadoEm &&
          other.nome == this.nome &&
          other.tipo == this.tipo &&
          other.diasSemana == this.diasSemana &&
          other.horario == this.horario &&
          other.alvo == this.alvo &&
          other.unidade == this.unidade &&
          other.metaId == this.metaId);
}

class HabitosCompanion extends UpdateCompanion<Habito> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> apagadoEm;
  final Value<String> nome;
  final Value<TipoHabito> tipo;
  final Value<int> diasSemana;
  final Value<String?> horario;
  final Value<int?> alvo;
  final Value<String?> unidade;
  final Value<String?> metaId;
  final Value<int> rowid;
  const HabitosCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    this.nome = const Value.absent(),
    this.tipo = const Value.absent(),
    this.diasSemana = const Value.absent(),
    this.horario = const Value.absent(),
    this.alvo = const Value.absent(),
    this.unidade = const Value.absent(),
    this.metaId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitosCompanion.insert({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    required String nome,
    this.tipo = const Value.absent(),
    this.diasSemana = const Value.absent(),
    this.horario = const Value.absent(),
    this.alvo = const Value.absent(),
    this.unidade = const Value.absent(),
    this.metaId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : nome = Value(nome);
  static Insertable<Habito> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? apagadoEm,
    Expression<String>? nome,
    Expression<String>? tipo,
    Expression<int>? diasSemana,
    Expression<String>? horario,
    Expression<int>? alvo,
    Expression<String>? unidade,
    Expression<String>? metaId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (apagadoEm != null) 'apagado_em': apagadoEm,
      if (nome != null) 'nome': nome,
      if (tipo != null) 'tipo': tipo,
      if (diasSemana != null) 'dias_semana': diasSemana,
      if (horario != null) 'horario': horario,
      if (alvo != null) 'alvo': alvo,
      if (unidade != null) 'unidade': unidade,
      if (metaId != null) 'meta_id': metaId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitosCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? apagadoEm,
    Value<String>? nome,
    Value<TipoHabito>? tipo,
    Value<int>? diasSemana,
    Value<String?>? horario,
    Value<int?>? alvo,
    Value<String?>? unidade,
    Value<String?>? metaId,
    Value<int>? rowid,
  }) {
    return HabitosCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      apagadoEm: apagadoEm ?? this.apagadoEm,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      diasSemana: diasSemana ?? this.diasSemana,
      horario: horario ?? this.horario,
      alvo: alvo ?? this.alvo,
      unidade: unidade ?? this.unidade,
      metaId: metaId ?? this.metaId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (apagadoEm.present) {
      map['apagado_em'] = Variable<DateTime>(apagadoEm.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(
        $HabitosTable.$convertertipo.toSql(tipo.value),
      );
    }
    if (diasSemana.present) {
      map['dias_semana'] = Variable<int>(diasSemana.value);
    }
    if (horario.present) {
      map['horario'] = Variable<String>(horario.value);
    }
    if (alvo.present) {
      map['alvo'] = Variable<int>(alvo.value);
    }
    if (unidade.present) {
      map['unidade'] = Variable<String>(unidade.value);
    }
    if (metaId.present) {
      map['meta_id'] = Variable<String>(metaId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitosCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('nome: $nome, ')
          ..write('tipo: $tipo, ')
          ..write('diasSemana: $diasSemana, ')
          ..write('horario: $horario, ')
          ..write('alvo: $alvo, ')
          ..write('unidade: $unidade, ')
          ..write('metaId: $metaId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RegistrosHabitoTable extends RegistrosHabito
    with TableInfo<$RegistrosHabitoTable, RegistrosHabitoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RegistrosHabitoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _apagadoEmMeta = const VerificationMeta(
    'apagadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> apagadoEm = GeneratedColumn<DateTime>(
    'apagado_em',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _habitoIdMeta = const VerificationMeta(
    'habitoId',
  );
  @override
  late final GeneratedColumn<String> habitoId = GeneratedColumn<String>(
    'habito_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES habitos (id)',
    ),
  );
  static const VerificationMeta _diaMeta = const VerificationMeta('dia');
  @override
  late final GeneratedColumn<String> dia = GeneratedColumn<String>(
    'dia',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feitoMeta = const VerificationMeta('feito');
  @override
  late final GeneratedColumn<bool> feito = GeneratedColumn<bool>(
    'feito',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("feito" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<int> valor = GeneratedColumn<int>(
    'valor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    habitoId,
    dia,
    feito,
    valor,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'registros_habito';
  @override
  VerificationContext validateIntegrity(
    Insertable<RegistrosHabitoData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    }
    if (data.containsKey('apagado_em')) {
      context.handle(
        _apagadoEmMeta,
        apagadoEm.isAcceptableOrUnknown(data['apagado_em']!, _apagadoEmMeta),
      );
    }
    if (data.containsKey('habito_id')) {
      context.handle(
        _habitoIdMeta,
        habitoId.isAcceptableOrUnknown(data['habito_id']!, _habitoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitoIdMeta);
    }
    if (data.containsKey('dia')) {
      context.handle(
        _diaMeta,
        dia.isAcceptableOrUnknown(data['dia']!, _diaMeta),
      );
    } else if (isInserting) {
      context.missing(_diaMeta);
    }
    if (data.containsKey('feito')) {
      context.handle(
        _feitoMeta,
        feito.isAcceptableOrUnknown(data['feito']!, _feitoMeta),
      );
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RegistrosHabitoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RegistrosHabitoData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      apagadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}apagado_em'],
      ),
      habitoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habito_id'],
      )!,
      dia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dia'],
      )!,
      feito: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}feito'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valor'],
      ),
    );
  }

  @override
  $RegistrosHabitoTable createAlias(String alias) {
    return $RegistrosHabitoTable(attachedDatabase, alias);
  }
}

class RegistrosHabitoData extends DataClass
    implements Insertable<RegistrosHabitoData> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? apagadoEm;
  final String habitoId;

  /// "aaaa-mm-dd" no fuso de São Paulo.
  final String dia;
  final bool feito;
  final int? valor;
  const RegistrosHabitoData({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.apagadoEm,
    required this.habitoId,
    required this.dia,
    required this.feito,
    this.valor,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    if (!nullToAbsent || apagadoEm != null) {
      map['apagado_em'] = Variable<DateTime>(apagadoEm);
    }
    map['habito_id'] = Variable<String>(habitoId);
    map['dia'] = Variable<String>(dia);
    map['feito'] = Variable<bool>(feito);
    if (!nullToAbsent || valor != null) {
      map['valor'] = Variable<int>(valor);
    }
    return map;
  }

  RegistrosHabitoCompanion toCompanion(bool nullToAbsent) {
    return RegistrosHabitoCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      apagadoEm: apagadoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(apagadoEm),
      habitoId: Value(habitoId),
      dia: Value(dia),
      feito: Value(feito),
      valor: valor == null && nullToAbsent
          ? const Value.absent()
          : Value(valor),
    );
  }

  factory RegistrosHabitoData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RegistrosHabitoData(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      apagadoEm: serializer.fromJson<DateTime?>(json['apagadoEm']),
      habitoId: serializer.fromJson<String>(json['habitoId']),
      dia: serializer.fromJson<String>(json['dia']),
      feito: serializer.fromJson<bool>(json['feito']),
      valor: serializer.fromJson<int?>(json['valor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'apagadoEm': serializer.toJson<DateTime?>(apagadoEm),
      'habitoId': serializer.toJson<String>(habitoId),
      'dia': serializer.toJson<String>(dia),
      'feito': serializer.toJson<bool>(feito),
      'valor': serializer.toJson<int?>(valor),
    };
  }

  RegistrosHabitoData copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> apagadoEm = const Value.absent(),
    String? habitoId,
    String? dia,
    bool? feito,
    Value<int?> valor = const Value.absent(),
  }) => RegistrosHabitoData(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    apagadoEm: apagadoEm.present ? apagadoEm.value : this.apagadoEm,
    habitoId: habitoId ?? this.habitoId,
    dia: dia ?? this.dia,
    feito: feito ?? this.feito,
    valor: valor.present ? valor.value : this.valor,
  );
  RegistrosHabitoData copyWithCompanion(RegistrosHabitoCompanion data) {
    return RegistrosHabitoData(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      apagadoEm: data.apagadoEm.present ? data.apagadoEm.value : this.apagadoEm,
      habitoId: data.habitoId.present ? data.habitoId.value : this.habitoId,
      dia: data.dia.present ? data.dia.value : this.dia,
      feito: data.feito.present ? data.feito.value : this.feito,
      valor: data.valor.present ? data.valor.value : this.valor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RegistrosHabitoData(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('habitoId: $habitoId, ')
          ..write('dia: $dia, ')
          ..write('feito: $feito, ')
          ..write('valor: $valor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    habitoId,
    dia,
    feito,
    valor,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RegistrosHabitoData &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.apagadoEm == this.apagadoEm &&
          other.habitoId == this.habitoId &&
          other.dia == this.dia &&
          other.feito == this.feito &&
          other.valor == this.valor);
}

class RegistrosHabitoCompanion extends UpdateCompanion<RegistrosHabitoData> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> apagadoEm;
  final Value<String> habitoId;
  final Value<String> dia;
  final Value<bool> feito;
  final Value<int?> valor;
  final Value<int> rowid;
  const RegistrosHabitoCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    this.habitoId = const Value.absent(),
    this.dia = const Value.absent(),
    this.feito = const Value.absent(),
    this.valor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RegistrosHabitoCompanion.insert({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    required String habitoId,
    required String dia,
    this.feito = const Value.absent(),
    this.valor = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : habitoId = Value(habitoId),
       dia = Value(dia);
  static Insertable<RegistrosHabitoData> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? apagadoEm,
    Expression<String>? habitoId,
    Expression<String>? dia,
    Expression<bool>? feito,
    Expression<int>? valor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (apagadoEm != null) 'apagado_em': apagadoEm,
      if (habitoId != null) 'habito_id': habitoId,
      if (dia != null) 'dia': dia,
      if (feito != null) 'feito': feito,
      if (valor != null) 'valor': valor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RegistrosHabitoCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? apagadoEm,
    Value<String>? habitoId,
    Value<String>? dia,
    Value<bool>? feito,
    Value<int?>? valor,
    Value<int>? rowid,
  }) {
    return RegistrosHabitoCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      apagadoEm: apagadoEm ?? this.apagadoEm,
      habitoId: habitoId ?? this.habitoId,
      dia: dia ?? this.dia,
      feito: feito ?? this.feito,
      valor: valor ?? this.valor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (apagadoEm.present) {
      map['apagado_em'] = Variable<DateTime>(apagadoEm.value);
    }
    if (habitoId.present) {
      map['habito_id'] = Variable<String>(habitoId.value);
    }
    if (dia.present) {
      map['dia'] = Variable<String>(dia.value);
    }
    if (feito.present) {
      map['feito'] = Variable<bool>(feito.value);
    }
    if (valor.present) {
      map['valor'] = Variable<int>(valor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RegistrosHabitoCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('habitoId: $habitoId, ')
          ..write('dia: $dia, ')
          ..write('feito: $feito, ')
          ..write('valor: $valor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContasFinanceirasTable extends ContasFinanceiras
    with TableInfo<$ContasFinanceirasTable, ContasFinanceira> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContasFinanceirasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _apagadoEmMeta = const VerificationMeta(
    'apagadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> apagadoEm = GeneratedColumn<DateTime>(
    'apagado_em',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoConta, String> tipo =
      GeneratedColumn<String>(
        'tipo',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TipoConta>($ContasFinanceirasTable.$convertertipo);
  static const VerificationMeta _saldoInicialCentavosMeta =
      const VerificationMeta('saldoInicialCentavos');
  @override
  late final GeneratedColumn<int> saldoInicialCentavos = GeneratedColumn<int>(
    'saldo_inicial_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _diaFechamentoMeta = const VerificationMeta(
    'diaFechamento',
  );
  @override
  late final GeneratedColumn<int> diaFechamento = GeneratedColumn<int>(
    'dia_fechamento',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diaVencimentoMeta = const VerificationMeta(
    'diaVencimento',
  );
  @override
  late final GeneratedColumn<int> diaVencimento = GeneratedColumn<int>(
    'dia_vencimento',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    nome,
    tipo,
    saldoInicialCentavos,
    diaFechamento,
    diaVencimento,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contas_financeiras';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContasFinanceira> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    }
    if (data.containsKey('apagado_em')) {
      context.handle(
        _apagadoEmMeta,
        apagadoEm.isAcceptableOrUnknown(data['apagado_em']!, _apagadoEmMeta),
      );
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('saldo_inicial_centavos')) {
      context.handle(
        _saldoInicialCentavosMeta,
        saldoInicialCentavos.isAcceptableOrUnknown(
          data['saldo_inicial_centavos']!,
          _saldoInicialCentavosMeta,
        ),
      );
    }
    if (data.containsKey('dia_fechamento')) {
      context.handle(
        _diaFechamentoMeta,
        diaFechamento.isAcceptableOrUnknown(
          data['dia_fechamento']!,
          _diaFechamentoMeta,
        ),
      );
    }
    if (data.containsKey('dia_vencimento')) {
      context.handle(
        _diaVencimentoMeta,
        diaVencimento.isAcceptableOrUnknown(
          data['dia_vencimento']!,
          _diaVencimentoMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContasFinanceira map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContasFinanceira(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      apagadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}apagado_em'],
      ),
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      tipo: $ContasFinanceirasTable.$convertertipo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tipo'],
        )!,
      ),
      saldoInicialCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}saldo_inicial_centavos'],
      )!,
      diaFechamento: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dia_fechamento'],
      ),
      diaVencimento: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dia_vencimento'],
      ),
    );
  }

  @override
  $ContasFinanceirasTable createAlias(String alias) {
    return $ContasFinanceirasTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoConta, String, String> $convertertipo =
      const EnumNameConverter<TipoConta>(TipoConta.values);
}

class ContasFinanceira extends DataClass
    implements Insertable<ContasFinanceira> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? apagadoEm;
  final String nome;
  final TipoConta tipo;
  final int saldoInicialCentavos;
  final int? diaFechamento;
  final int? diaVencimento;
  const ContasFinanceira({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.apagadoEm,
    required this.nome,
    required this.tipo,
    required this.saldoInicialCentavos,
    this.diaFechamento,
    this.diaVencimento,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    if (!nullToAbsent || apagadoEm != null) {
      map['apagado_em'] = Variable<DateTime>(apagadoEm);
    }
    map['nome'] = Variable<String>(nome);
    {
      map['tipo'] = Variable<String>(
        $ContasFinanceirasTable.$convertertipo.toSql(tipo),
      );
    }
    map['saldo_inicial_centavos'] = Variable<int>(saldoInicialCentavos);
    if (!nullToAbsent || diaFechamento != null) {
      map['dia_fechamento'] = Variable<int>(diaFechamento);
    }
    if (!nullToAbsent || diaVencimento != null) {
      map['dia_vencimento'] = Variable<int>(diaVencimento);
    }
    return map;
  }

  ContasFinanceirasCompanion toCompanion(bool nullToAbsent) {
    return ContasFinanceirasCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      apagadoEm: apagadoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(apagadoEm),
      nome: Value(nome),
      tipo: Value(tipo),
      saldoInicialCentavos: Value(saldoInicialCentavos),
      diaFechamento: diaFechamento == null && nullToAbsent
          ? const Value.absent()
          : Value(diaFechamento),
      diaVencimento: diaVencimento == null && nullToAbsent
          ? const Value.absent()
          : Value(diaVencimento),
    );
  }

  factory ContasFinanceira.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContasFinanceira(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      apagadoEm: serializer.fromJson<DateTime?>(json['apagadoEm']),
      nome: serializer.fromJson<String>(json['nome']),
      tipo: $ContasFinanceirasTable.$convertertipo.fromJson(
        serializer.fromJson<String>(json['tipo']),
      ),
      saldoInicialCentavos: serializer.fromJson<int>(
        json['saldoInicialCentavos'],
      ),
      diaFechamento: serializer.fromJson<int?>(json['diaFechamento']),
      diaVencimento: serializer.fromJson<int?>(json['diaVencimento']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'apagadoEm': serializer.toJson<DateTime?>(apagadoEm),
      'nome': serializer.toJson<String>(nome),
      'tipo': serializer.toJson<String>(
        $ContasFinanceirasTable.$convertertipo.toJson(tipo),
      ),
      'saldoInicialCentavos': serializer.toJson<int>(saldoInicialCentavos),
      'diaFechamento': serializer.toJson<int?>(diaFechamento),
      'diaVencimento': serializer.toJson<int?>(diaVencimento),
    };
  }

  ContasFinanceira copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> apagadoEm = const Value.absent(),
    String? nome,
    TipoConta? tipo,
    int? saldoInicialCentavos,
    Value<int?> diaFechamento = const Value.absent(),
    Value<int?> diaVencimento = const Value.absent(),
  }) => ContasFinanceira(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    apagadoEm: apagadoEm.present ? apagadoEm.value : this.apagadoEm,
    nome: nome ?? this.nome,
    tipo: tipo ?? this.tipo,
    saldoInicialCentavos: saldoInicialCentavos ?? this.saldoInicialCentavos,
    diaFechamento: diaFechamento.present
        ? diaFechamento.value
        : this.diaFechamento,
    diaVencimento: diaVencimento.present
        ? diaVencimento.value
        : this.diaVencimento,
  );
  ContasFinanceira copyWithCompanion(ContasFinanceirasCompanion data) {
    return ContasFinanceira(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      apagadoEm: data.apagadoEm.present ? data.apagadoEm.value : this.apagadoEm,
      nome: data.nome.present ? data.nome.value : this.nome,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      saldoInicialCentavos: data.saldoInicialCentavos.present
          ? data.saldoInicialCentavos.value
          : this.saldoInicialCentavos,
      diaFechamento: data.diaFechamento.present
          ? data.diaFechamento.value
          : this.diaFechamento,
      diaVencimento: data.diaVencimento.present
          ? data.diaVencimento.value
          : this.diaVencimento,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContasFinanceira(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('nome: $nome, ')
          ..write('tipo: $tipo, ')
          ..write('saldoInicialCentavos: $saldoInicialCentavos, ')
          ..write('diaFechamento: $diaFechamento, ')
          ..write('diaVencimento: $diaVencimento')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    nome,
    tipo,
    saldoInicialCentavos,
    diaFechamento,
    diaVencimento,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContasFinanceira &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.apagadoEm == this.apagadoEm &&
          other.nome == this.nome &&
          other.tipo == this.tipo &&
          other.saldoInicialCentavos == this.saldoInicialCentavos &&
          other.diaFechamento == this.diaFechamento &&
          other.diaVencimento == this.diaVencimento);
}

class ContasFinanceirasCompanion extends UpdateCompanion<ContasFinanceira> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> apagadoEm;
  final Value<String> nome;
  final Value<TipoConta> tipo;
  final Value<int> saldoInicialCentavos;
  final Value<int?> diaFechamento;
  final Value<int?> diaVencimento;
  final Value<int> rowid;
  const ContasFinanceirasCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    this.nome = const Value.absent(),
    this.tipo = const Value.absent(),
    this.saldoInicialCentavos = const Value.absent(),
    this.diaFechamento = const Value.absent(),
    this.diaVencimento = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContasFinanceirasCompanion.insert({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    required String nome,
    required TipoConta tipo,
    this.saldoInicialCentavos = const Value.absent(),
    this.diaFechamento = const Value.absent(),
    this.diaVencimento = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : nome = Value(nome),
       tipo = Value(tipo);
  static Insertable<ContasFinanceira> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? apagadoEm,
    Expression<String>? nome,
    Expression<String>? tipo,
    Expression<int>? saldoInicialCentavos,
    Expression<int>? diaFechamento,
    Expression<int>? diaVencimento,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (apagadoEm != null) 'apagado_em': apagadoEm,
      if (nome != null) 'nome': nome,
      if (tipo != null) 'tipo': tipo,
      if (saldoInicialCentavos != null)
        'saldo_inicial_centavos': saldoInicialCentavos,
      if (diaFechamento != null) 'dia_fechamento': diaFechamento,
      if (diaVencimento != null) 'dia_vencimento': diaVencimento,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContasFinanceirasCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? apagadoEm,
    Value<String>? nome,
    Value<TipoConta>? tipo,
    Value<int>? saldoInicialCentavos,
    Value<int?>? diaFechamento,
    Value<int?>? diaVencimento,
    Value<int>? rowid,
  }) {
    return ContasFinanceirasCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      apagadoEm: apagadoEm ?? this.apagadoEm,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      saldoInicialCentavos: saldoInicialCentavos ?? this.saldoInicialCentavos,
      diaFechamento: diaFechamento ?? this.diaFechamento,
      diaVencimento: diaVencimento ?? this.diaVencimento,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (apagadoEm.present) {
      map['apagado_em'] = Variable<DateTime>(apagadoEm.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(
        $ContasFinanceirasTable.$convertertipo.toSql(tipo.value),
      );
    }
    if (saldoInicialCentavos.present) {
      map['saldo_inicial_centavos'] = Variable<int>(saldoInicialCentavos.value);
    }
    if (diaFechamento.present) {
      map['dia_fechamento'] = Variable<int>(diaFechamento.value);
    }
    if (diaVencimento.present) {
      map['dia_vencimento'] = Variable<int>(diaVencimento.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContasFinanceirasCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('nome: $nome, ')
          ..write('tipo: $tipo, ')
          ..write('saldoInicialCentavos: $saldoInicialCentavos, ')
          ..write('diaFechamento: $diaFechamento, ')
          ..write('diaVencimento: $diaVencimento, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransacoesTable extends Transacoes
    with TableInfo<$TransacoesTable, Transacoe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransacoesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _apagadoEmMeta = const VerificationMeta(
    'apagadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> apagadoEm = GeneratedColumn<DateTime>(
    'apagado_em',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descricaoMeta = const VerificationMeta(
    'descricao',
  );
  @override
  late final GeneratedColumn<String> descricao = GeneratedColumn<String>(
    'descricao',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorCentavosMeta = const VerificationMeta(
    'valorCentavos',
  );
  @override
  late final GeneratedColumn<int> valorCentavos = GeneratedColumn<int>(
    'valor_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoTransacao, String> tipo =
      GeneratedColumn<String>(
        'tipo',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TipoTransacao>($TransacoesTable.$convertertipo);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<DateTime> data = GeneratedColumn<DateTime>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vencimentoMeta = const VerificationMeta(
    'vencimento',
  );
  @override
  late final GeneratedColumn<DateTime> vencimento = GeneratedColumn<DateTime>(
    'vencimento',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pagoEmMeta = const VerificationMeta('pagoEm');
  @override
  late final GeneratedColumn<DateTime> pagoEm = GeneratedColumn<DateTime>(
    'pago_em',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoriaMeta = const VerificationMeta(
    'categoria',
  );
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
    'categoria',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _regraRepeticaoMeta = const VerificationMeta(
    'regraRepeticao',
  );
  @override
  late final GeneratedColumn<String> regraRepeticao = GeneratedColumn<String>(
    'regra_repeticao',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parcelaNumeroMeta = const VerificationMeta(
    'parcelaNumero',
  );
  @override
  late final GeneratedColumn<int> parcelaNumero = GeneratedColumn<int>(
    'parcela_numero',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parcelaTotalMeta = const VerificationMeta(
    'parcelaTotal',
  );
  @override
  late final GeneratedColumn<int> parcelaTotal = GeneratedColumn<int>(
    'parcela_total',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contaIdMeta = const VerificationMeta(
    'contaId',
  );
  @override
  late final GeneratedColumn<String> contaId = GeneratedColumn<String>(
    'conta_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contas_financeiras (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    descricao,
    valorCentavos,
    tipo,
    data,
    vencimento,
    pagoEm,
    categoria,
    regraRepeticao,
    parcelaNumero,
    parcelaTotal,
    contaId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transacoes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transacoe> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    }
    if (data.containsKey('apagado_em')) {
      context.handle(
        _apagadoEmMeta,
        apagadoEm.isAcceptableOrUnknown(data['apagado_em']!, _apagadoEmMeta),
      );
    }
    if (data.containsKey('descricao')) {
      context.handle(
        _descricaoMeta,
        descricao.isAcceptableOrUnknown(data['descricao']!, _descricaoMeta),
      );
    } else if (isInserting) {
      context.missing(_descricaoMeta);
    }
    if (data.containsKey('valor_centavos')) {
      context.handle(
        _valorCentavosMeta,
        valorCentavos.isAcceptableOrUnknown(
          data['valor_centavos']!,
          _valorCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_valorCentavosMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('vencimento')) {
      context.handle(
        _vencimentoMeta,
        vencimento.isAcceptableOrUnknown(data['vencimento']!, _vencimentoMeta),
      );
    }
    if (data.containsKey('pago_em')) {
      context.handle(
        _pagoEmMeta,
        pagoEm.isAcceptableOrUnknown(data['pago_em']!, _pagoEmMeta),
      );
    }
    if (data.containsKey('categoria')) {
      context.handle(
        _categoriaMeta,
        categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta),
      );
    }
    if (data.containsKey('regra_repeticao')) {
      context.handle(
        _regraRepeticaoMeta,
        regraRepeticao.isAcceptableOrUnknown(
          data['regra_repeticao']!,
          _regraRepeticaoMeta,
        ),
      );
    }
    if (data.containsKey('parcela_numero')) {
      context.handle(
        _parcelaNumeroMeta,
        parcelaNumero.isAcceptableOrUnknown(
          data['parcela_numero']!,
          _parcelaNumeroMeta,
        ),
      );
    }
    if (data.containsKey('parcela_total')) {
      context.handle(
        _parcelaTotalMeta,
        parcelaTotal.isAcceptableOrUnknown(
          data['parcela_total']!,
          _parcelaTotalMeta,
        ),
      );
    }
    if (data.containsKey('conta_id')) {
      context.handle(
        _contaIdMeta,
        contaId.isAcceptableOrUnknown(data['conta_id']!, _contaIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transacoe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transacoe(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      apagadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}apagado_em'],
      ),
      descricao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descricao'],
      )!,
      valorCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valor_centavos'],
      )!,
      tipo: $TransacoesTable.$convertertipo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tipo'],
        )!,
      ),
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data'],
      )!,
      vencimento: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}vencimento'],
      ),
      pagoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}pago_em'],
      ),
      categoria: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categoria'],
      ),
      regraRepeticao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}regra_repeticao'],
      ),
      parcelaNumero: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parcela_numero'],
      ),
      parcelaTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parcela_total'],
      ),
      contaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conta_id'],
      ),
    );
  }

  @override
  $TransacoesTable createAlias(String alias) {
    return $TransacoesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoTransacao, String, String> $convertertipo =
      const EnumNameConverter<TipoTransacao>(TipoTransacao.values);
}

class Transacoe extends DataClass implements Insertable<Transacoe> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? apagadoEm;
  final String descricao;
  final int valorCentavos;
  final TipoTransacao tipo;
  final DateTime data;
  final DateTime? vencimento;
  final DateTime? pagoEm;
  final String? categoria;
  final String? regraRepeticao;
  final int? parcelaNumero;
  final int? parcelaTotal;
  final String? contaId;
  const Transacoe({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.apagadoEm,
    required this.descricao,
    required this.valorCentavos,
    required this.tipo,
    required this.data,
    this.vencimento,
    this.pagoEm,
    this.categoria,
    this.regraRepeticao,
    this.parcelaNumero,
    this.parcelaTotal,
    this.contaId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    if (!nullToAbsent || apagadoEm != null) {
      map['apagado_em'] = Variable<DateTime>(apagadoEm);
    }
    map['descricao'] = Variable<String>(descricao);
    map['valor_centavos'] = Variable<int>(valorCentavos);
    {
      map['tipo'] = Variable<String>(
        $TransacoesTable.$convertertipo.toSql(tipo),
      );
    }
    map['data'] = Variable<DateTime>(data);
    if (!nullToAbsent || vencimento != null) {
      map['vencimento'] = Variable<DateTime>(vencimento);
    }
    if (!nullToAbsent || pagoEm != null) {
      map['pago_em'] = Variable<DateTime>(pagoEm);
    }
    if (!nullToAbsent || categoria != null) {
      map['categoria'] = Variable<String>(categoria);
    }
    if (!nullToAbsent || regraRepeticao != null) {
      map['regra_repeticao'] = Variable<String>(regraRepeticao);
    }
    if (!nullToAbsent || parcelaNumero != null) {
      map['parcela_numero'] = Variable<int>(parcelaNumero);
    }
    if (!nullToAbsent || parcelaTotal != null) {
      map['parcela_total'] = Variable<int>(parcelaTotal);
    }
    if (!nullToAbsent || contaId != null) {
      map['conta_id'] = Variable<String>(contaId);
    }
    return map;
  }

  TransacoesCompanion toCompanion(bool nullToAbsent) {
    return TransacoesCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      apagadoEm: apagadoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(apagadoEm),
      descricao: Value(descricao),
      valorCentavos: Value(valorCentavos),
      tipo: Value(tipo),
      data: Value(data),
      vencimento: vencimento == null && nullToAbsent
          ? const Value.absent()
          : Value(vencimento),
      pagoEm: pagoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(pagoEm),
      categoria: categoria == null && nullToAbsent
          ? const Value.absent()
          : Value(categoria),
      regraRepeticao: regraRepeticao == null && nullToAbsent
          ? const Value.absent()
          : Value(regraRepeticao),
      parcelaNumero: parcelaNumero == null && nullToAbsent
          ? const Value.absent()
          : Value(parcelaNumero),
      parcelaTotal: parcelaTotal == null && nullToAbsent
          ? const Value.absent()
          : Value(parcelaTotal),
      contaId: contaId == null && nullToAbsent
          ? const Value.absent()
          : Value(contaId),
    );
  }

  factory Transacoe.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transacoe(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      apagadoEm: serializer.fromJson<DateTime?>(json['apagadoEm']),
      descricao: serializer.fromJson<String>(json['descricao']),
      valorCentavos: serializer.fromJson<int>(json['valorCentavos']),
      tipo: $TransacoesTable.$convertertipo.fromJson(
        serializer.fromJson<String>(json['tipo']),
      ),
      data: serializer.fromJson<DateTime>(json['data']),
      vencimento: serializer.fromJson<DateTime?>(json['vencimento']),
      pagoEm: serializer.fromJson<DateTime?>(json['pagoEm']),
      categoria: serializer.fromJson<String?>(json['categoria']),
      regraRepeticao: serializer.fromJson<String?>(json['regraRepeticao']),
      parcelaNumero: serializer.fromJson<int?>(json['parcelaNumero']),
      parcelaTotal: serializer.fromJson<int?>(json['parcelaTotal']),
      contaId: serializer.fromJson<String?>(json['contaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'apagadoEm': serializer.toJson<DateTime?>(apagadoEm),
      'descricao': serializer.toJson<String>(descricao),
      'valorCentavos': serializer.toJson<int>(valorCentavos),
      'tipo': serializer.toJson<String>(
        $TransacoesTable.$convertertipo.toJson(tipo),
      ),
      'data': serializer.toJson<DateTime>(data),
      'vencimento': serializer.toJson<DateTime?>(vencimento),
      'pagoEm': serializer.toJson<DateTime?>(pagoEm),
      'categoria': serializer.toJson<String?>(categoria),
      'regraRepeticao': serializer.toJson<String?>(regraRepeticao),
      'parcelaNumero': serializer.toJson<int?>(parcelaNumero),
      'parcelaTotal': serializer.toJson<int?>(parcelaTotal),
      'contaId': serializer.toJson<String?>(contaId),
    };
  }

  Transacoe copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> apagadoEm = const Value.absent(),
    String? descricao,
    int? valorCentavos,
    TipoTransacao? tipo,
    DateTime? data,
    Value<DateTime?> vencimento = const Value.absent(),
    Value<DateTime?> pagoEm = const Value.absent(),
    Value<String?> categoria = const Value.absent(),
    Value<String?> regraRepeticao = const Value.absent(),
    Value<int?> parcelaNumero = const Value.absent(),
    Value<int?> parcelaTotal = const Value.absent(),
    Value<String?> contaId = const Value.absent(),
  }) => Transacoe(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    apagadoEm: apagadoEm.present ? apagadoEm.value : this.apagadoEm,
    descricao: descricao ?? this.descricao,
    valorCentavos: valorCentavos ?? this.valorCentavos,
    tipo: tipo ?? this.tipo,
    data: data ?? this.data,
    vencimento: vencimento.present ? vencimento.value : this.vencimento,
    pagoEm: pagoEm.present ? pagoEm.value : this.pagoEm,
    categoria: categoria.present ? categoria.value : this.categoria,
    regraRepeticao: regraRepeticao.present
        ? regraRepeticao.value
        : this.regraRepeticao,
    parcelaNumero: parcelaNumero.present
        ? parcelaNumero.value
        : this.parcelaNumero,
    parcelaTotal: parcelaTotal.present ? parcelaTotal.value : this.parcelaTotal,
    contaId: contaId.present ? contaId.value : this.contaId,
  );
  Transacoe copyWithCompanion(TransacoesCompanion data) {
    return Transacoe(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      apagadoEm: data.apagadoEm.present ? data.apagadoEm.value : this.apagadoEm,
      descricao: data.descricao.present ? data.descricao.value : this.descricao,
      valorCentavos: data.valorCentavos.present
          ? data.valorCentavos.value
          : this.valorCentavos,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      data: data.data.present ? data.data.value : this.data,
      vencimento: data.vencimento.present
          ? data.vencimento.value
          : this.vencimento,
      pagoEm: data.pagoEm.present ? data.pagoEm.value : this.pagoEm,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      regraRepeticao: data.regraRepeticao.present
          ? data.regraRepeticao.value
          : this.regraRepeticao,
      parcelaNumero: data.parcelaNumero.present
          ? data.parcelaNumero.value
          : this.parcelaNumero,
      parcelaTotal: data.parcelaTotal.present
          ? data.parcelaTotal.value
          : this.parcelaTotal,
      contaId: data.contaId.present ? data.contaId.value : this.contaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transacoe(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('descricao: $descricao, ')
          ..write('valorCentavos: $valorCentavos, ')
          ..write('tipo: $tipo, ')
          ..write('data: $data, ')
          ..write('vencimento: $vencimento, ')
          ..write('pagoEm: $pagoEm, ')
          ..write('categoria: $categoria, ')
          ..write('regraRepeticao: $regraRepeticao, ')
          ..write('parcelaNumero: $parcelaNumero, ')
          ..write('parcelaTotal: $parcelaTotal, ')
          ..write('contaId: $contaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    descricao,
    valorCentavos,
    tipo,
    data,
    vencimento,
    pagoEm,
    categoria,
    regraRepeticao,
    parcelaNumero,
    parcelaTotal,
    contaId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transacoe &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.apagadoEm == this.apagadoEm &&
          other.descricao == this.descricao &&
          other.valorCentavos == this.valorCentavos &&
          other.tipo == this.tipo &&
          other.data == this.data &&
          other.vencimento == this.vencimento &&
          other.pagoEm == this.pagoEm &&
          other.categoria == this.categoria &&
          other.regraRepeticao == this.regraRepeticao &&
          other.parcelaNumero == this.parcelaNumero &&
          other.parcelaTotal == this.parcelaTotal &&
          other.contaId == this.contaId);
}

class TransacoesCompanion extends UpdateCompanion<Transacoe> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> apagadoEm;
  final Value<String> descricao;
  final Value<int> valorCentavos;
  final Value<TipoTransacao> tipo;
  final Value<DateTime> data;
  final Value<DateTime?> vencimento;
  final Value<DateTime?> pagoEm;
  final Value<String?> categoria;
  final Value<String?> regraRepeticao;
  final Value<int?> parcelaNumero;
  final Value<int?> parcelaTotal;
  final Value<String?> contaId;
  final Value<int> rowid;
  const TransacoesCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    this.descricao = const Value.absent(),
    this.valorCentavos = const Value.absent(),
    this.tipo = const Value.absent(),
    this.data = const Value.absent(),
    this.vencimento = const Value.absent(),
    this.pagoEm = const Value.absent(),
    this.categoria = const Value.absent(),
    this.regraRepeticao = const Value.absent(),
    this.parcelaNumero = const Value.absent(),
    this.parcelaTotal = const Value.absent(),
    this.contaId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransacoesCompanion.insert({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    required String descricao,
    required int valorCentavos,
    required TipoTransacao tipo,
    required DateTime data,
    this.vencimento = const Value.absent(),
    this.pagoEm = const Value.absent(),
    this.categoria = const Value.absent(),
    this.regraRepeticao = const Value.absent(),
    this.parcelaNumero = const Value.absent(),
    this.parcelaTotal = const Value.absent(),
    this.contaId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : descricao = Value(descricao),
       valorCentavos = Value(valorCentavos),
       tipo = Value(tipo),
       data = Value(data);
  static Insertable<Transacoe> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? apagadoEm,
    Expression<String>? descricao,
    Expression<int>? valorCentavos,
    Expression<String>? tipo,
    Expression<DateTime>? data,
    Expression<DateTime>? vencimento,
    Expression<DateTime>? pagoEm,
    Expression<String>? categoria,
    Expression<String>? regraRepeticao,
    Expression<int>? parcelaNumero,
    Expression<int>? parcelaTotal,
    Expression<String>? contaId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (apagadoEm != null) 'apagado_em': apagadoEm,
      if (descricao != null) 'descricao': descricao,
      if (valorCentavos != null) 'valor_centavos': valorCentavos,
      if (tipo != null) 'tipo': tipo,
      if (data != null) 'data': data,
      if (vencimento != null) 'vencimento': vencimento,
      if (pagoEm != null) 'pago_em': pagoEm,
      if (categoria != null) 'categoria': categoria,
      if (regraRepeticao != null) 'regra_repeticao': regraRepeticao,
      if (parcelaNumero != null) 'parcela_numero': parcelaNumero,
      if (parcelaTotal != null) 'parcela_total': parcelaTotal,
      if (contaId != null) 'conta_id': contaId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransacoesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? apagadoEm,
    Value<String>? descricao,
    Value<int>? valorCentavos,
    Value<TipoTransacao>? tipo,
    Value<DateTime>? data,
    Value<DateTime?>? vencimento,
    Value<DateTime?>? pagoEm,
    Value<String?>? categoria,
    Value<String?>? regraRepeticao,
    Value<int?>? parcelaNumero,
    Value<int?>? parcelaTotal,
    Value<String?>? contaId,
    Value<int>? rowid,
  }) {
    return TransacoesCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      apagadoEm: apagadoEm ?? this.apagadoEm,
      descricao: descricao ?? this.descricao,
      valorCentavos: valorCentavos ?? this.valorCentavos,
      tipo: tipo ?? this.tipo,
      data: data ?? this.data,
      vencimento: vencimento ?? this.vencimento,
      pagoEm: pagoEm ?? this.pagoEm,
      categoria: categoria ?? this.categoria,
      regraRepeticao: regraRepeticao ?? this.regraRepeticao,
      parcelaNumero: parcelaNumero ?? this.parcelaNumero,
      parcelaTotal: parcelaTotal ?? this.parcelaTotal,
      contaId: contaId ?? this.contaId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (apagadoEm.present) {
      map['apagado_em'] = Variable<DateTime>(apagadoEm.value);
    }
    if (descricao.present) {
      map['descricao'] = Variable<String>(descricao.value);
    }
    if (valorCentavos.present) {
      map['valor_centavos'] = Variable<int>(valorCentavos.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(
        $TransacoesTable.$convertertipo.toSql(tipo.value),
      );
    }
    if (data.present) {
      map['data'] = Variable<DateTime>(data.value);
    }
    if (vencimento.present) {
      map['vencimento'] = Variable<DateTime>(vencimento.value);
    }
    if (pagoEm.present) {
      map['pago_em'] = Variable<DateTime>(pagoEm.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (regraRepeticao.present) {
      map['regra_repeticao'] = Variable<String>(regraRepeticao.value);
    }
    if (parcelaNumero.present) {
      map['parcela_numero'] = Variable<int>(parcelaNumero.value);
    }
    if (parcelaTotal.present) {
      map['parcela_total'] = Variable<int>(parcelaTotal.value);
    }
    if (contaId.present) {
      map['conta_id'] = Variable<String>(contaId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransacoesCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('descricao: $descricao, ')
          ..write('valorCentavos: $valorCentavos, ')
          ..write('tipo: $tipo, ')
          ..write('data: $data, ')
          ..write('vencimento: $vencimento, ')
          ..write('pagoEm: $pagoEm, ')
          ..write('categoria: $categoria, ')
          ..write('regraRepeticao: $regraRepeticao, ')
          ..write('parcelaNumero: $parcelaNumero, ')
          ..write('parcelaTotal: $parcelaTotal, ')
          ..write('contaId: $contaId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LembretesTable extends Lembretes
    with TableInfo<$LembretesTable, Lembrete> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LembretesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _apagadoEmMeta = const VerificationMeta(
    'apagadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> apagadoEm = GeneratedColumn<DateTime>(
    'apagado_em',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _textoMeta = const VerificationMeta('texto');
  @override
  late final GeneratedColumn<String> texto = GeneratedColumn<String>(
    'texto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quandoMeta = const VerificationMeta('quando');
  @override
  late final GeneratedColumn<DateTime> quando = GeneratedColumn<DateTime>(
    'quando',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _regraRepeticaoMeta = const VerificationMeta(
    'regraRepeticao',
  );
  @override
  late final GeneratedColumn<String> regraRepeticao = GeneratedColumn<String>(
    'regra_repeticao',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notificarAntesMinMeta = const VerificationMeta(
    'notificarAntesMin',
  );
  @override
  late final GeneratedColumn<int> notificarAntesMin = GeneratedColumn<int>(
    'notificar_antes_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ativoMeta = const VerificationMeta('ativo');
  @override
  late final GeneratedColumn<bool> ativo = GeneratedColumn<bool>(
    'ativo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ativo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _itemTipoMeta = const VerificationMeta(
    'itemTipo',
  );
  @override
  late final GeneratedColumn<String> itemTipo = GeneratedColumn<String>(
    'item_tipo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    texto,
    quando,
    regraRepeticao,
    notificarAntesMin,
    ativo,
    itemTipo,
    itemId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lembretes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Lembrete> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    }
    if (data.containsKey('apagado_em')) {
      context.handle(
        _apagadoEmMeta,
        apagadoEm.isAcceptableOrUnknown(data['apagado_em']!, _apagadoEmMeta),
      );
    }
    if (data.containsKey('texto')) {
      context.handle(
        _textoMeta,
        texto.isAcceptableOrUnknown(data['texto']!, _textoMeta),
      );
    } else if (isInserting) {
      context.missing(_textoMeta);
    }
    if (data.containsKey('quando')) {
      context.handle(
        _quandoMeta,
        quando.isAcceptableOrUnknown(data['quando']!, _quandoMeta),
      );
    } else if (isInserting) {
      context.missing(_quandoMeta);
    }
    if (data.containsKey('regra_repeticao')) {
      context.handle(
        _regraRepeticaoMeta,
        regraRepeticao.isAcceptableOrUnknown(
          data['regra_repeticao']!,
          _regraRepeticaoMeta,
        ),
      );
    }
    if (data.containsKey('notificar_antes_min')) {
      context.handle(
        _notificarAntesMinMeta,
        notificarAntesMin.isAcceptableOrUnknown(
          data['notificar_antes_min']!,
          _notificarAntesMinMeta,
        ),
      );
    }
    if (data.containsKey('ativo')) {
      context.handle(
        _ativoMeta,
        ativo.isAcceptableOrUnknown(data['ativo']!, _ativoMeta),
      );
    }
    if (data.containsKey('item_tipo')) {
      context.handle(
        _itemTipoMeta,
        itemTipo.isAcceptableOrUnknown(data['item_tipo']!, _itemTipoMeta),
      );
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Lembrete map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Lembrete(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      apagadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}apagado_em'],
      ),
      texto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}texto'],
      )!,
      quando: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}quando'],
      )!,
      regraRepeticao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}regra_repeticao'],
      ),
      notificarAntesMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notificar_antes_min'],
      )!,
      ativo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ativo'],
      )!,
      itemTipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_tipo'],
      ),
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      ),
    );
  }

  @override
  $LembretesTable createAlias(String alias) {
    return $LembretesTable(attachedDatabase, alias);
  }
}

class Lembrete extends DataClass implements Insertable<Lembrete> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? apagadoEm;
  final String texto;
  final DateTime quando;
  final String? regraRepeticao;
  final int notificarAntesMin;

  /// O sino: desligado, o lembrete continua salvo mas não notifica.
  final bool ativo;

  /// Item ligado (ex.: 'tarefa', 'transacao') e o id dele.
  final String? itemTipo;
  final String? itemId;
  const Lembrete({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.apagadoEm,
    required this.texto,
    required this.quando,
    this.regraRepeticao,
    required this.notificarAntesMin,
    required this.ativo,
    this.itemTipo,
    this.itemId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    if (!nullToAbsent || apagadoEm != null) {
      map['apagado_em'] = Variable<DateTime>(apagadoEm);
    }
    map['texto'] = Variable<String>(texto);
    map['quando'] = Variable<DateTime>(quando);
    if (!nullToAbsent || regraRepeticao != null) {
      map['regra_repeticao'] = Variable<String>(regraRepeticao);
    }
    map['notificar_antes_min'] = Variable<int>(notificarAntesMin);
    map['ativo'] = Variable<bool>(ativo);
    if (!nullToAbsent || itemTipo != null) {
      map['item_tipo'] = Variable<String>(itemTipo);
    }
    if (!nullToAbsent || itemId != null) {
      map['item_id'] = Variable<String>(itemId);
    }
    return map;
  }

  LembretesCompanion toCompanion(bool nullToAbsent) {
    return LembretesCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      apagadoEm: apagadoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(apagadoEm),
      texto: Value(texto),
      quando: Value(quando),
      regraRepeticao: regraRepeticao == null && nullToAbsent
          ? const Value.absent()
          : Value(regraRepeticao),
      notificarAntesMin: Value(notificarAntesMin),
      ativo: Value(ativo),
      itemTipo: itemTipo == null && nullToAbsent
          ? const Value.absent()
          : Value(itemTipo),
      itemId: itemId == null && nullToAbsent
          ? const Value.absent()
          : Value(itemId),
    );
  }

  factory Lembrete.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Lembrete(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      apagadoEm: serializer.fromJson<DateTime?>(json['apagadoEm']),
      texto: serializer.fromJson<String>(json['texto']),
      quando: serializer.fromJson<DateTime>(json['quando']),
      regraRepeticao: serializer.fromJson<String?>(json['regraRepeticao']),
      notificarAntesMin: serializer.fromJson<int>(json['notificarAntesMin']),
      ativo: serializer.fromJson<bool>(json['ativo']),
      itemTipo: serializer.fromJson<String?>(json['itemTipo']),
      itemId: serializer.fromJson<String?>(json['itemId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'apagadoEm': serializer.toJson<DateTime?>(apagadoEm),
      'texto': serializer.toJson<String>(texto),
      'quando': serializer.toJson<DateTime>(quando),
      'regraRepeticao': serializer.toJson<String?>(regraRepeticao),
      'notificarAntesMin': serializer.toJson<int>(notificarAntesMin),
      'ativo': serializer.toJson<bool>(ativo),
      'itemTipo': serializer.toJson<String?>(itemTipo),
      'itemId': serializer.toJson<String?>(itemId),
    };
  }

  Lembrete copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> apagadoEm = const Value.absent(),
    String? texto,
    DateTime? quando,
    Value<String?> regraRepeticao = const Value.absent(),
    int? notificarAntesMin,
    bool? ativo,
    Value<String?> itemTipo = const Value.absent(),
    Value<String?> itemId = const Value.absent(),
  }) => Lembrete(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    apagadoEm: apagadoEm.present ? apagadoEm.value : this.apagadoEm,
    texto: texto ?? this.texto,
    quando: quando ?? this.quando,
    regraRepeticao: regraRepeticao.present
        ? regraRepeticao.value
        : this.regraRepeticao,
    notificarAntesMin: notificarAntesMin ?? this.notificarAntesMin,
    ativo: ativo ?? this.ativo,
    itemTipo: itemTipo.present ? itemTipo.value : this.itemTipo,
    itemId: itemId.present ? itemId.value : this.itemId,
  );
  Lembrete copyWithCompanion(LembretesCompanion data) {
    return Lembrete(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      apagadoEm: data.apagadoEm.present ? data.apagadoEm.value : this.apagadoEm,
      texto: data.texto.present ? data.texto.value : this.texto,
      quando: data.quando.present ? data.quando.value : this.quando,
      regraRepeticao: data.regraRepeticao.present
          ? data.regraRepeticao.value
          : this.regraRepeticao,
      notificarAntesMin: data.notificarAntesMin.present
          ? data.notificarAntesMin.value
          : this.notificarAntesMin,
      ativo: data.ativo.present ? data.ativo.value : this.ativo,
      itemTipo: data.itemTipo.present ? data.itemTipo.value : this.itemTipo,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Lembrete(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('texto: $texto, ')
          ..write('quando: $quando, ')
          ..write('regraRepeticao: $regraRepeticao, ')
          ..write('notificarAntesMin: $notificarAntesMin, ')
          ..write('ativo: $ativo, ')
          ..write('itemTipo: $itemTipo, ')
          ..write('itemId: $itemId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    texto,
    quando,
    regraRepeticao,
    notificarAntesMin,
    ativo,
    itemTipo,
    itemId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lembrete &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.apagadoEm == this.apagadoEm &&
          other.texto == this.texto &&
          other.quando == this.quando &&
          other.regraRepeticao == this.regraRepeticao &&
          other.notificarAntesMin == this.notificarAntesMin &&
          other.ativo == this.ativo &&
          other.itemTipo == this.itemTipo &&
          other.itemId == this.itemId);
}

class LembretesCompanion extends UpdateCompanion<Lembrete> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> apagadoEm;
  final Value<String> texto;
  final Value<DateTime> quando;
  final Value<String?> regraRepeticao;
  final Value<int> notificarAntesMin;
  final Value<bool> ativo;
  final Value<String?> itemTipo;
  final Value<String?> itemId;
  final Value<int> rowid;
  const LembretesCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    this.texto = const Value.absent(),
    this.quando = const Value.absent(),
    this.regraRepeticao = const Value.absent(),
    this.notificarAntesMin = const Value.absent(),
    this.ativo = const Value.absent(),
    this.itemTipo = const Value.absent(),
    this.itemId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LembretesCompanion.insert({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    required String texto,
    required DateTime quando,
    this.regraRepeticao = const Value.absent(),
    this.notificarAntesMin = const Value.absent(),
    this.ativo = const Value.absent(),
    this.itemTipo = const Value.absent(),
    this.itemId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : texto = Value(texto),
       quando = Value(quando);
  static Insertable<Lembrete> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? apagadoEm,
    Expression<String>? texto,
    Expression<DateTime>? quando,
    Expression<String>? regraRepeticao,
    Expression<int>? notificarAntesMin,
    Expression<bool>? ativo,
    Expression<String>? itemTipo,
    Expression<String>? itemId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (apagadoEm != null) 'apagado_em': apagadoEm,
      if (texto != null) 'texto': texto,
      if (quando != null) 'quando': quando,
      if (regraRepeticao != null) 'regra_repeticao': regraRepeticao,
      if (notificarAntesMin != null) 'notificar_antes_min': notificarAntesMin,
      if (ativo != null) 'ativo': ativo,
      if (itemTipo != null) 'item_tipo': itemTipo,
      if (itemId != null) 'item_id': itemId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LembretesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? apagadoEm,
    Value<String>? texto,
    Value<DateTime>? quando,
    Value<String?>? regraRepeticao,
    Value<int>? notificarAntesMin,
    Value<bool>? ativo,
    Value<String?>? itemTipo,
    Value<String?>? itemId,
    Value<int>? rowid,
  }) {
    return LembretesCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      apagadoEm: apagadoEm ?? this.apagadoEm,
      texto: texto ?? this.texto,
      quando: quando ?? this.quando,
      regraRepeticao: regraRepeticao ?? this.regraRepeticao,
      notificarAntesMin: notificarAntesMin ?? this.notificarAntesMin,
      ativo: ativo ?? this.ativo,
      itemTipo: itemTipo ?? this.itemTipo,
      itemId: itemId ?? this.itemId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (apagadoEm.present) {
      map['apagado_em'] = Variable<DateTime>(apagadoEm.value);
    }
    if (texto.present) {
      map['texto'] = Variable<String>(texto.value);
    }
    if (quando.present) {
      map['quando'] = Variable<DateTime>(quando.value);
    }
    if (regraRepeticao.present) {
      map['regra_repeticao'] = Variable<String>(regraRepeticao.value);
    }
    if (notificarAntesMin.present) {
      map['notificar_antes_min'] = Variable<int>(notificarAntesMin.value);
    }
    if (ativo.present) {
      map['ativo'] = Variable<bool>(ativo.value);
    }
    if (itemTipo.present) {
      map['item_tipo'] = Variable<String>(itemTipo.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LembretesCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('texto: $texto, ')
          ..write('quando: $quando, ')
          ..write('regraRepeticao: $regraRepeticao, ')
          ..write('notificarAntesMin: $notificarAntesMin, ')
          ..write('ativo: $ativo, ')
          ..write('itemTipo: $itemTipo, ')
          ..write('itemId: $itemId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PreferenciasTable extends Preferencias
    with TableInfo<$PreferenciasTable, Preferencia> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreferenciasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chaveMeta = const VerificationMeta('chave');
  @override
  late final GeneratedColumn<String> chave = GeneratedColumn<String>(
    'chave',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<String> valor = GeneratedColumn<String>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [chave, valor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preferencias';
  @override
  VerificationContext validateIntegrity(
    Insertable<Preferencia> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chave')) {
      context.handle(
        _chaveMeta,
        chave.isAcceptableOrUnknown(data['chave']!, _chaveMeta),
      );
    } else if (isInserting) {
      context.missing(_chaveMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chave};
  @override
  Preferencia map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Preferencia(
      chave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chave'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valor'],
      )!,
    );
  }

  @override
  $PreferenciasTable createAlias(String alias) {
    return $PreferenciasTable(attachedDatabase, alias);
  }
}

class Preferencia extends DataClass implements Insertable<Preferencia> {
  final String chave;
  final String valor;
  const Preferencia({required this.chave, required this.valor});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chave'] = Variable<String>(chave);
    map['valor'] = Variable<String>(valor);
    return map;
  }

  PreferenciasCompanion toCompanion(bool nullToAbsent) {
    return PreferenciasCompanion(chave: Value(chave), valor: Value(valor));
  }

  factory Preferencia.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Preferencia(
      chave: serializer.fromJson<String>(json['chave']),
      valor: serializer.fromJson<String>(json['valor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chave': serializer.toJson<String>(chave),
      'valor': serializer.toJson<String>(valor),
    };
  }

  Preferencia copyWith({String? chave, String? valor}) =>
      Preferencia(chave: chave ?? this.chave, valor: valor ?? this.valor);
  Preferencia copyWithCompanion(PreferenciasCompanion data) {
    return Preferencia(
      chave: data.chave.present ? data.chave.value : this.chave,
      valor: data.valor.present ? data.valor.value : this.valor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Preferencia(')
          ..write('chave: $chave, ')
          ..write('valor: $valor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chave, valor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Preferencia &&
          other.chave == this.chave &&
          other.valor == this.valor);
}

class PreferenciasCompanion extends UpdateCompanion<Preferencia> {
  final Value<String> chave;
  final Value<String> valor;
  final Value<int> rowid;
  const PreferenciasCompanion({
    this.chave = const Value.absent(),
    this.valor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreferenciasCompanion.insert({
    required String chave,
    required String valor,
    this.rowid = const Value.absent(),
  }) : chave = Value(chave),
       valor = Value(valor);
  static Insertable<Preferencia> custom({
    Expression<String>? chave,
    Expression<String>? valor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chave != null) 'chave': chave,
      if (valor != null) 'valor': valor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PreferenciasCompanion copyWith({
    Value<String>? chave,
    Value<String>? valor,
    Value<int>? rowid,
  }) {
    return PreferenciasCompanion(
      chave: chave ?? this.chave,
      valor: valor ?? this.valor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chave.present) {
      map['chave'] = Variable<String>(chave.value);
    }
    if (valor.present) {
      map['valor'] = Variable<String>(valor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreferenciasCompanion(')
          ..write('chave: $chave, ')
          ..write('valor: $valor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$BancoAurora extends GeneratedDatabase {
  _$BancoAurora(QueryExecutor e) : super(e);
  $BancoAuroraManager get managers => $BancoAuroraManager(this);
  late final $MetasTable metas = $MetasTable(this);
  late final $TarefasTable tarefas = $TarefasTable(this);
  late final $ConclusoesTarefaTable conclusoesTarefa = $ConclusoesTarefaTable(
    this,
  );
  late final $HabitosTable habitos = $HabitosTable(this);
  late final $RegistrosHabitoTable registrosHabito = $RegistrosHabitoTable(
    this,
  );
  late final $ContasFinanceirasTable contasFinanceiras =
      $ContasFinanceirasTable(this);
  late final $TransacoesTable transacoes = $TransacoesTable(this);
  late final $LembretesTable lembretes = $LembretesTable(this);
  late final $PreferenciasTable preferencias = $PreferenciasTable(this);
  late final Index conclusaoTarefaDia = Index(
    'conclusao_tarefa_dia',
    'CREATE UNIQUE INDEX conclusao_tarefa_dia ON conclusoes_tarefa (tarefa_id, dia)',
  );
  late final Index registroHabitoDia = Index(
    'registro_habito_dia',
    'CREATE UNIQUE INDEX registro_habito_dia ON registros_habito (habito_id, dia)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    metas,
    tarefas,
    conclusoesTarefa,
    habitos,
    registrosHabito,
    contasFinanceiras,
    transacoes,
    lembretes,
    preferencias,
    conclusaoTarefaDia,
    registroHabitoDia,
  ];
}

typedef $$MetasTableCreateCompanionBuilder = MetasCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  required String nome,
  required double valorInicial,
  required double valorAtual,
  required double valorAlvo,
  Value<String> unidade,
  Value<DateTime?> dataAlvo,
  Value<String> status,
  Value<int> rowid,
});
typedef $$MetasTableUpdateCompanionBuilder = MetasCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  Value<String> nome,
  Value<double> valorInicial,
  Value<double> valorAtual,
  Value<double> valorAlvo,
  Value<String> unidade,
  Value<DateTime?> dataAlvo,
  Value<String> status,
  Value<int> rowid,
});

final class $$MetasTableReferences
    extends BaseReferences<_$BancoAurora, $MetasTable, Meta> {
  $$MetasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TarefasTable, List<Tarefa>> _tarefasRefsTable(
    _$BancoAurora db,
  ) => MultiTypedResultKey.fromTable(
    db.tarefas,
    aliasName: 'metas__id__tarefas__meta_id',
  );

  $$TarefasTableProcessedTableManager get tarefasRefs {
    final manager = $$TarefasTableTableManager(
      $_db,
      $_db.tarefas,
    ).filter((f) => f.metaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tarefasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HabitosTable, List<Habito>> _habitosRefsTable(
    _$BancoAurora db,
  ) => MultiTypedResultKey.fromTable(
    db.habitos,
    aliasName: 'metas__id__habitos__meta_id',
  );

  $$HabitosTableProcessedTableManager get habitosRefs {
    final manager = $$HabitosTableTableManager(
      $_db,
      $_db.habitos,
    ).filter((f) => f.metaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_habitosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MetasTableFilterComposer extends Composer<_$BancoAurora, $MetasTable> {
  $$MetasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get apagadoEm => $composableBuilder(
    column: $table.apagadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valorInicial => $composableBuilder(
    column: $table.valorInicial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valorAtual => $composableBuilder(
    column: $table.valorAtual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valorAlvo => $composableBuilder(
    column: $table.valorAlvo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unidade => $composableBuilder(
    column: $table.unidade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataAlvo => $composableBuilder(
    column: $table.dataAlvo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tarefasRefs(
    Expression<bool> Function($$TarefasTableFilterComposer f) f,
  ) {
    final $$TarefasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tarefas,
      getReferencedColumn: (t) => t.metaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TarefasTableFilterComposer(
            $db: $db,
            $table: $db.tarefas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> habitosRefs(
    Expression<bool> Function($$HabitosTableFilterComposer f) f,
  ) {
    final $$HabitosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitos,
      getReferencedColumn: (t) => t.metaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitosTableFilterComposer(
            $db: $db,
            $table: $db.habitos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MetasTableOrderingComposer
    extends Composer<_$BancoAurora, $MetasTable> {
  $$MetasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get apagadoEm => $composableBuilder(
    column: $table.apagadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valorInicial => $composableBuilder(
    column: $table.valorInicial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valorAtual => $composableBuilder(
    column: $table.valorAtual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valorAlvo => $composableBuilder(
    column: $table.valorAlvo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unidade => $composableBuilder(
    column: $table.unidade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataAlvo => $composableBuilder(
    column: $table.dataAlvo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetasTableAnnotationComposer
    extends Composer<_$BancoAurora, $MetasTable> {
  $$MetasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get apagadoEm =>
      $composableBuilder(column: $table.apagadoEm, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<double> get valorInicial => $composableBuilder(
    column: $table.valorInicial,
    builder: (column) => column,
  );

  GeneratedColumn<double> get valorAtual => $composableBuilder(
    column: $table.valorAtual,
    builder: (column) => column,
  );

  GeneratedColumn<double> get valorAlvo =>
      $composableBuilder(column: $table.valorAlvo, builder: (column) => column);

  GeneratedColumn<String> get unidade =>
      $composableBuilder(column: $table.unidade, builder: (column) => column);

  GeneratedColumn<DateTime> get dataAlvo =>
      $composableBuilder(column: $table.dataAlvo, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  Expression<T> tarefasRefs<T extends Object>(
    Expression<T> Function($$TarefasTableAnnotationComposer a) f,
  ) {
    final $$TarefasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tarefas,
      getReferencedColumn: (t) => t.metaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TarefasTableAnnotationComposer(
            $db: $db,
            $table: $db.tarefas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> habitosRefs<T extends Object>(
    Expression<T> Function($$HabitosTableAnnotationComposer a) f,
  ) {
    final $$HabitosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitos,
      getReferencedColumn: (t) => t.metaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitosTableAnnotationComposer(
            $db: $db,
            $table: $db.habitos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MetasTableTableManager
    extends
        RootTableManager<
          _$BancoAurora,
          $MetasTable,
          Meta,
          $$MetasTableFilterComposer,
          $$MetasTableOrderingComposer,
          $$MetasTableAnnotationComposer,
          $$MetasTableCreateCompanionBuilder,
          $$MetasTableUpdateCompanionBuilder,
          (Meta, $$MetasTableReferences),
          Meta,
          PrefetchHooks Function({bool tarefasRefs, bool habitosRefs})
        > {
  $$MetasTableTableManager(_$BancoAurora db, $MetasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<double> valorInicial = const Value.absent(),
                Value<double> valorAtual = const Value.absent(),
                Value<double> valorAlvo = const Value.absent(),
                Value<String> unidade = const Value.absent(),
                Value<DateTime?> dataAlvo = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MetasCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                nome: nome,
                valorInicial: valorInicial,
                valorAtual: valorAtual,
                valorAlvo: valorAlvo,
                unidade: unidade,
                dataAlvo: dataAlvo,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                required String nome,
                required double valorInicial,
                required double valorAtual,
                required double valorAlvo,
                Value<String> unidade = const Value.absent(),
                Value<DateTime?> dataAlvo = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MetasCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                nome: nome,
                valorInicial: valorInicial,
                valorAtual: valorAtual,
                valorAlvo: valorAlvo,
                unidade: unidade,
                dataAlvo: dataAlvo,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MetasTable, Meta>(table),
                  $$MetasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tarefasRefs = false, habitosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (tarefasRefs) db.tarefas,
                if (habitosRefs) db.habitos,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tarefasRefs)
                    await $_getPrefetchedData<Meta, $MetasTable, Tarefa>(
                      currentTable: table,
                      referencedTable: $$MetasTableReferences._tarefasRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$MetasTableReferences(db, table, p0).tarefasRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.metaId == item.id),
                      typedResults: items,
                    ),
                  if (habitosRefs)
                    await $_getPrefetchedData<Meta, $MetasTable, Habito>(
                      currentTable: table,
                      referencedTable: $$MetasTableReferences._habitosRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$MetasTableReferences(db, table, p0).habitosRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.metaId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MetasTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $MetasTable,
      Meta,
      $$MetasTableFilterComposer,
      $$MetasTableOrderingComposer,
      $$MetasTableAnnotationComposer,
      $$MetasTableCreateCompanionBuilder,
      $$MetasTableUpdateCompanionBuilder,
      (Meta, $$MetasTableReferences),
      Meta,
      PrefetchHooks Function({bool tarefasRefs, bool habitosRefs})
    >;
typedef $$TarefasTableCreateCompanionBuilder = TarefasCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  required String titulo,
  Value<String?> notas,
  Value<DateTime?> prazo,
  Value<bool> prazoTemHora,
  Value<Prioridade> prioridade,
  Value<DateTime?> feitaEm,
  Value<String?> regraRepeticao,
  Value<String?> metaId,
  Value<int> rowid,
});
typedef $$TarefasTableUpdateCompanionBuilder = TarefasCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  Value<String> titulo,
  Value<String?> notas,
  Value<DateTime?> prazo,
  Value<bool> prazoTemHora,
  Value<Prioridade> prioridade,
  Value<DateTime?> feitaEm,
  Value<String?> regraRepeticao,
  Value<String?> metaId,
  Value<int> rowid,
});

final class $$TarefasTableReferences
    extends BaseReferences<_$BancoAurora, $TarefasTable, Tarefa> {
  $$TarefasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MetasTable _metaIdTable(_$BancoAurora db) =>
      db.metas.createAlias('tarefas__meta_id__metas__id');

  $$MetasTableProcessedTableManager? get metaId {
    final $_column = $_itemColumn<String>('meta_id');
    if ($_column == null) return null;
    final manager = $$MetasTableTableManager(
      $_db,
      $_db.metas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_metaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ConclusoesTarefaTable, List<ConclusoesTarefaData>>
  _conclusoesTarefaRefsTable(_$BancoAurora db) => MultiTypedResultKey.fromTable(
    db.conclusoesTarefa,
    aliasName: 'tarefas__id__conclusoes_tarefa__tarefa_id',
  );

  $$ConclusoesTarefaTableProcessedTableManager get conclusoesTarefaRefs {
    final manager = $$ConclusoesTarefaTableTableManager(
      $_db,
      $_db.conclusoesTarefa,
    ).filter((f) => f.tarefaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _conclusoesTarefaRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TarefasTableFilterComposer
    extends Composer<_$BancoAurora, $TarefasTable> {
  $$TarefasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get apagadoEm => $composableBuilder(
    column: $table.apagadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get prazo => $composableBuilder(
    column: $table.prazo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get prazoTemHora => $composableBuilder(
    column: $table.prazoTemHora,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Prioridade, Prioridade, String>
  get prioridade => $composableBuilder(
    column: $table.prioridade,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get feitaEm => $composableBuilder(
    column: $table.feitaEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get regraRepeticao => $composableBuilder(
    column: $table.regraRepeticao,
    builder: (column) => ColumnFilters(column),
  );

  $$MetasTableFilterComposer get metaId {
    final $$MetasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.metaId,
      referencedTable: $db.metas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MetasTableFilterComposer(
            $db: $db,
            $table: $db.metas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> conclusoesTarefaRefs(
    Expression<bool> Function($$ConclusoesTarefaTableFilterComposer f) f,
  ) {
    final $$ConclusoesTarefaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conclusoesTarefa,
      getReferencedColumn: (t) => t.tarefaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConclusoesTarefaTableFilterComposer(
            $db: $db,
            $table: $db.conclusoesTarefa,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TarefasTableOrderingComposer
    extends Composer<_$BancoAurora, $TarefasTable> {
  $$TarefasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get apagadoEm => $composableBuilder(
    column: $table.apagadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get prazo => $composableBuilder(
    column: $table.prazo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get prazoTemHora => $composableBuilder(
    column: $table.prazoTemHora,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prioridade => $composableBuilder(
    column: $table.prioridade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get feitaEm => $composableBuilder(
    column: $table.feitaEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get regraRepeticao => $composableBuilder(
    column: $table.regraRepeticao,
    builder: (column) => ColumnOrderings(column),
  );

  $$MetasTableOrderingComposer get metaId {
    final $$MetasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.metaId,
      referencedTable: $db.metas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MetasTableOrderingComposer(
            $db: $db,
            $table: $db.metas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TarefasTableAnnotationComposer
    extends Composer<_$BancoAurora, $TarefasTable> {
  $$TarefasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get apagadoEm =>
      $composableBuilder(column: $table.apagadoEm, builder: (column) => column);

  GeneratedColumn<String> get titulo =>
      $composableBuilder(column: $table.titulo, builder: (column) => column);

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);

  GeneratedColumn<DateTime> get prazo =>
      $composableBuilder(column: $table.prazo, builder: (column) => column);

  GeneratedColumn<bool> get prazoTemHora => $composableBuilder(
    column: $table.prazoTemHora,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Prioridade, String> get prioridade =>
      $composableBuilder(
        column: $table.prioridade,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get feitaEm =>
      $composableBuilder(column: $table.feitaEm, builder: (column) => column);

  GeneratedColumn<String> get regraRepeticao => $composableBuilder(
    column: $table.regraRepeticao,
    builder: (column) => column,
  );

  $$MetasTableAnnotationComposer get metaId {
    final $$MetasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.metaId,
      referencedTable: $db.metas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MetasTableAnnotationComposer(
            $db: $db,
            $table: $db.metas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> conclusoesTarefaRefs<T extends Object>(
    Expression<T> Function($$ConclusoesTarefaTableAnnotationComposer a) f,
  ) {
    final $$ConclusoesTarefaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conclusoesTarefa,
      getReferencedColumn: (t) => t.tarefaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConclusoesTarefaTableAnnotationComposer(
            $db: $db,
            $table: $db.conclusoesTarefa,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TarefasTableTableManager
    extends
        RootTableManager<
          _$BancoAurora,
          $TarefasTable,
          Tarefa,
          $$TarefasTableFilterComposer,
          $$TarefasTableOrderingComposer,
          $$TarefasTableAnnotationComposer,
          $$TarefasTableCreateCompanionBuilder,
          $$TarefasTableUpdateCompanionBuilder,
          (Tarefa, $$TarefasTableReferences),
          Tarefa,
          PrefetchHooks Function({bool metaId, bool conclusoesTarefaRefs})
        > {
  $$TarefasTableTableManager(_$BancoAurora db, $TarefasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TarefasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TarefasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TarefasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                Value<String> titulo = const Value.absent(),
                Value<String?> notas = const Value.absent(),
                Value<DateTime?> prazo = const Value.absent(),
                Value<bool> prazoTemHora = const Value.absent(),
                Value<Prioridade> prioridade = const Value.absent(),
                Value<DateTime?> feitaEm = const Value.absent(),
                Value<String?> regraRepeticao = const Value.absent(),
                Value<String?> metaId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TarefasCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                titulo: titulo,
                notas: notas,
                prazo: prazo,
                prazoTemHora: prazoTemHora,
                prioridade: prioridade,
                feitaEm: feitaEm,
                regraRepeticao: regraRepeticao,
                metaId: metaId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                required String titulo,
                Value<String?> notas = const Value.absent(),
                Value<DateTime?> prazo = const Value.absent(),
                Value<bool> prazoTemHora = const Value.absent(),
                Value<Prioridade> prioridade = const Value.absent(),
                Value<DateTime?> feitaEm = const Value.absent(),
                Value<String?> regraRepeticao = const Value.absent(),
                Value<String?> metaId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TarefasCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                titulo: titulo,
                notas: notas,
                prazo: prazo,
                prazoTemHora: prazoTemHora,
                prioridade: prioridade,
                feitaEm: feitaEm,
                regraRepeticao: regraRepeticao,
                metaId: metaId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TarefasTable, Tarefa>(table),
                  $$TarefasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({metaId = false, conclusoesTarefaRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (conclusoesTarefaRefs) db.conclusoesTarefa,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (metaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.metaId,
                            referencedTable: $$TarefasTableReferences
                                ._metaIdTable(db),
                            referencedColumn: $$TarefasTableReferences
                                ._metaIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (conclusoesTarefaRefs)
                        await $_getPrefetchedData<
                          Tarefa,
                          $TarefasTable,
                          ConclusoesTarefaData
                        >(
                          currentTable: table,
                          referencedTable: $$TarefasTableReferences
                              ._conclusoesTarefaRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TarefasTableReferences(
                                db,
                                table,
                                p0,
                              ).conclusoesTarefaRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tarefaId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TarefasTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $TarefasTable,
      Tarefa,
      $$TarefasTableFilterComposer,
      $$TarefasTableOrderingComposer,
      $$TarefasTableAnnotationComposer,
      $$TarefasTableCreateCompanionBuilder,
      $$TarefasTableUpdateCompanionBuilder,
      (Tarefa, $$TarefasTableReferences),
      Tarefa,
      PrefetchHooks Function({bool metaId, bool conclusoesTarefaRefs})
    >;
typedef $$ConclusoesTarefaTableCreateCompanionBuilder =
    ConclusoesTarefaCompanion Function({
      Value<String> id,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<DateTime?> apagadoEm,
      required String tarefaId,
      required String dia,
      Value<int> rowid,
    });
typedef $$ConclusoesTarefaTableUpdateCompanionBuilder =
    ConclusoesTarefaCompanion Function({
      Value<String> id,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<DateTime?> apagadoEm,
      Value<String> tarefaId,
      Value<String> dia,
      Value<int> rowid,
    });

final class $$ConclusoesTarefaTableReferences
    extends
        BaseReferences<
          _$BancoAurora,
          $ConclusoesTarefaTable,
          ConclusoesTarefaData
        > {
  $$ConclusoesTarefaTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TarefasTable _tarefaIdTable(_$BancoAurora db) =>
      db.tarefas.createAlias('conclusoes_tarefa__tarefa_id__tarefas__id');

  $$TarefasTableProcessedTableManager get tarefaId {
    final $_column = $_itemColumn<String>('tarefa_id')!;

    final manager = $$TarefasTableTableManager(
      $_db,
      $_db.tarefas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tarefaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ConclusoesTarefaTableFilterComposer
    extends Composer<_$BancoAurora, $ConclusoesTarefaTable> {
  $$ConclusoesTarefaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get apagadoEm => $composableBuilder(
    column: $table.apagadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dia => $composableBuilder(
    column: $table.dia,
    builder: (column) => ColumnFilters(column),
  );

  $$TarefasTableFilterComposer get tarefaId {
    final $$TarefasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tarefaId,
      referencedTable: $db.tarefas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TarefasTableFilterComposer(
            $db: $db,
            $table: $db.tarefas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConclusoesTarefaTableOrderingComposer
    extends Composer<_$BancoAurora, $ConclusoesTarefaTable> {
  $$ConclusoesTarefaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get apagadoEm => $composableBuilder(
    column: $table.apagadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dia => $composableBuilder(
    column: $table.dia,
    builder: (column) => ColumnOrderings(column),
  );

  $$TarefasTableOrderingComposer get tarefaId {
    final $$TarefasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tarefaId,
      referencedTable: $db.tarefas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TarefasTableOrderingComposer(
            $db: $db,
            $table: $db.tarefas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConclusoesTarefaTableAnnotationComposer
    extends Composer<_$BancoAurora, $ConclusoesTarefaTable> {
  $$ConclusoesTarefaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get apagadoEm =>
      $composableBuilder(column: $table.apagadoEm, builder: (column) => column);

  GeneratedColumn<String> get dia =>
      $composableBuilder(column: $table.dia, builder: (column) => column);

  $$TarefasTableAnnotationComposer get tarefaId {
    final $$TarefasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tarefaId,
      referencedTable: $db.tarefas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TarefasTableAnnotationComposer(
            $db: $db,
            $table: $db.tarefas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConclusoesTarefaTableTableManager
    extends
        RootTableManager<
          _$BancoAurora,
          $ConclusoesTarefaTable,
          ConclusoesTarefaData,
          $$ConclusoesTarefaTableFilterComposer,
          $$ConclusoesTarefaTableOrderingComposer,
          $$ConclusoesTarefaTableAnnotationComposer,
          $$ConclusoesTarefaTableCreateCompanionBuilder,
          $$ConclusoesTarefaTableUpdateCompanionBuilder,
          (ConclusoesTarefaData, $$ConclusoesTarefaTableReferences),
          ConclusoesTarefaData,
          PrefetchHooks Function({bool tarefaId})
        > {
  $$ConclusoesTarefaTableTableManager(
    _$BancoAurora db,
    $ConclusoesTarefaTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConclusoesTarefaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConclusoesTarefaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConclusoesTarefaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                Value<String> tarefaId = const Value.absent(),
                Value<String> dia = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConclusoesTarefaCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                tarefaId: tarefaId,
                dia: dia,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                required String tarefaId,
                required String dia,
                Value<int> rowid = const Value.absent(),
              }) => ConclusoesTarefaCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                tarefaId: tarefaId,
                dia: dia,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ConclusoesTarefaTable, ConclusoesTarefaData>(
                    table,
                  ),
                  $$ConclusoesTarefaTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tarefaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tarefaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.tarefaId,
                        referencedTable: $$ConclusoesTarefaTableReferences
                            ._tarefaIdTable(db),
                        referencedColumn: $$ConclusoesTarefaTableReferences
                            ._tarefaIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ConclusoesTarefaTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $ConclusoesTarefaTable,
      ConclusoesTarefaData,
      $$ConclusoesTarefaTableFilterComposer,
      $$ConclusoesTarefaTableOrderingComposer,
      $$ConclusoesTarefaTableAnnotationComposer,
      $$ConclusoesTarefaTableCreateCompanionBuilder,
      $$ConclusoesTarefaTableUpdateCompanionBuilder,
      (ConclusoesTarefaData, $$ConclusoesTarefaTableReferences),
      ConclusoesTarefaData,
      PrefetchHooks Function({bool tarefaId})
    >;
typedef $$HabitosTableCreateCompanionBuilder = HabitosCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  required String nome,
  Value<TipoHabito> tipo,
  Value<int> diasSemana,
  Value<String?> horario,
  Value<int?> alvo,
  Value<String?> unidade,
  Value<String?> metaId,
  Value<int> rowid,
});
typedef $$HabitosTableUpdateCompanionBuilder = HabitosCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  Value<String> nome,
  Value<TipoHabito> tipo,
  Value<int> diasSemana,
  Value<String?> horario,
  Value<int?> alvo,
  Value<String?> unidade,
  Value<String?> metaId,
  Value<int> rowid,
});

final class $$HabitosTableReferences
    extends BaseReferences<_$BancoAurora, $HabitosTable, Habito> {
  $$HabitosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MetasTable _metaIdTable(_$BancoAurora db) =>
      db.metas.createAlias('habitos__meta_id__metas__id');

  $$MetasTableProcessedTableManager? get metaId {
    final $_column = $_itemColumn<String>('meta_id');
    if ($_column == null) return null;
    final manager = $$MetasTableTableManager(
      $_db,
      $_db.metas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_metaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RegistrosHabitoTable, List<RegistrosHabitoData>>
  _registrosHabitoRefsTable(_$BancoAurora db) => MultiTypedResultKey.fromTable(
    db.registrosHabito,
    aliasName: 'habitos__id__registros_habito__habito_id',
  );

  $$RegistrosHabitoTableProcessedTableManager get registrosHabitoRefs {
    final manager = $$RegistrosHabitoTableTableManager(
      $_db,
      $_db.registrosHabito,
    ).filter((f) => f.habitoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _registrosHabitoRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HabitosTableFilterComposer
    extends Composer<_$BancoAurora, $HabitosTable> {
  $$HabitosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get apagadoEm => $composableBuilder(
    column: $table.apagadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoHabito, TipoHabito, String> get tipo =>
      $composableBuilder(
        column: $table.tipo,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get diasSemana => $composableBuilder(
    column: $table.diasSemana,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get horario => $composableBuilder(
    column: $table.horario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get alvo => $composableBuilder(
    column: $table.alvo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unidade => $composableBuilder(
    column: $table.unidade,
    builder: (column) => ColumnFilters(column),
  );

  $$MetasTableFilterComposer get metaId {
    final $$MetasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.metaId,
      referencedTable: $db.metas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MetasTableFilterComposer(
            $db: $db,
            $table: $db.metas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> registrosHabitoRefs(
    Expression<bool> Function($$RegistrosHabitoTableFilterComposer f) f,
  ) {
    final $$RegistrosHabitoTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.registrosHabito,
      getReferencedColumn: (t) => t.habitoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegistrosHabitoTableFilterComposer(
            $db: $db,
            $table: $db.registrosHabito,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitosTableOrderingComposer
    extends Composer<_$BancoAurora, $HabitosTable> {
  $$HabitosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get apagadoEm => $composableBuilder(
    column: $table.apagadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diasSemana => $composableBuilder(
    column: $table.diasSemana,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get horario => $composableBuilder(
    column: $table.horario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get alvo => $composableBuilder(
    column: $table.alvo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unidade => $composableBuilder(
    column: $table.unidade,
    builder: (column) => ColumnOrderings(column),
  );

  $$MetasTableOrderingComposer get metaId {
    final $$MetasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.metaId,
      referencedTable: $db.metas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MetasTableOrderingComposer(
            $db: $db,
            $table: $db.metas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitosTableAnnotationComposer
    extends Composer<_$BancoAurora, $HabitosTable> {
  $$HabitosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get apagadoEm =>
      $composableBuilder(column: $table.apagadoEm, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TipoHabito, String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<int> get diasSemana => $composableBuilder(
    column: $table.diasSemana,
    builder: (column) => column,
  );

  GeneratedColumn<String> get horario =>
      $composableBuilder(column: $table.horario, builder: (column) => column);

  GeneratedColumn<int> get alvo =>
      $composableBuilder(column: $table.alvo, builder: (column) => column);

  GeneratedColumn<String> get unidade =>
      $composableBuilder(column: $table.unidade, builder: (column) => column);

  $$MetasTableAnnotationComposer get metaId {
    final $$MetasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.metaId,
      referencedTable: $db.metas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MetasTableAnnotationComposer(
            $db: $db,
            $table: $db.metas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> registrosHabitoRefs<T extends Object>(
    Expression<T> Function($$RegistrosHabitoTableAnnotationComposer a) f,
  ) {
    final $$RegistrosHabitoTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.registrosHabito,
      getReferencedColumn: (t) => t.habitoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegistrosHabitoTableAnnotationComposer(
            $db: $db,
            $table: $db.registrosHabito,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitosTableTableManager
    extends
        RootTableManager<
          _$BancoAurora,
          $HabitosTable,
          Habito,
          $$HabitosTableFilterComposer,
          $$HabitosTableOrderingComposer,
          $$HabitosTableAnnotationComposer,
          $$HabitosTableCreateCompanionBuilder,
          $$HabitosTableUpdateCompanionBuilder,
          (Habito, $$HabitosTableReferences),
          Habito,
          PrefetchHooks Function({bool metaId, bool registrosHabitoRefs})
        > {
  $$HabitosTableTableManager(_$BancoAurora db, $HabitosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<TipoHabito> tipo = const Value.absent(),
                Value<int> diasSemana = const Value.absent(),
                Value<String?> horario = const Value.absent(),
                Value<int?> alvo = const Value.absent(),
                Value<String?> unidade = const Value.absent(),
                Value<String?> metaId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitosCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                nome: nome,
                tipo: tipo,
                diasSemana: diasSemana,
                horario: horario,
                alvo: alvo,
                unidade: unidade,
                metaId: metaId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                required String nome,
                Value<TipoHabito> tipo = const Value.absent(),
                Value<int> diasSemana = const Value.absent(),
                Value<String?> horario = const Value.absent(),
                Value<int?> alvo = const Value.absent(),
                Value<String?> unidade = const Value.absent(),
                Value<String?> metaId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitosCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                nome: nome,
                tipo: tipo,
                diasSemana: diasSemana,
                horario: horario,
                alvo: alvo,
                unidade: unidade,
                metaId: metaId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HabitosTable, Habito>(table),
                  $$HabitosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({metaId = false, registrosHabitoRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (registrosHabitoRefs) db.registrosHabito,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (metaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.metaId,
                            referencedTable: $$HabitosTableReferences
                                ._metaIdTable(db),
                            referencedColumn: $$HabitosTableReferences
                                ._metaIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (registrosHabitoRefs)
                        await $_getPrefetchedData<
                          Habito,
                          $HabitosTable,
                          RegistrosHabitoData
                        >(
                          currentTable: table,
                          referencedTable: $$HabitosTableReferences
                              ._registrosHabitoRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HabitosTableReferences(
                                db,
                                table,
                                p0,
                              ).registrosHabitoRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.habitoId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$HabitosTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $HabitosTable,
      Habito,
      $$HabitosTableFilterComposer,
      $$HabitosTableOrderingComposer,
      $$HabitosTableAnnotationComposer,
      $$HabitosTableCreateCompanionBuilder,
      $$HabitosTableUpdateCompanionBuilder,
      (Habito, $$HabitosTableReferences),
      Habito,
      PrefetchHooks Function({bool metaId, bool registrosHabitoRefs})
    >;
typedef $$RegistrosHabitoTableCreateCompanionBuilder =
    RegistrosHabitoCompanion Function({
      Value<String> id,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<DateTime?> apagadoEm,
      required String habitoId,
      required String dia,
      Value<bool> feito,
      Value<int?> valor,
      Value<int> rowid,
    });
typedef $$RegistrosHabitoTableUpdateCompanionBuilder =
    RegistrosHabitoCompanion Function({
      Value<String> id,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<DateTime?> apagadoEm,
      Value<String> habitoId,
      Value<String> dia,
      Value<bool> feito,
      Value<int?> valor,
      Value<int> rowid,
    });

final class $$RegistrosHabitoTableReferences
    extends
        BaseReferences<
          _$BancoAurora,
          $RegistrosHabitoTable,
          RegistrosHabitoData
        > {
  $$RegistrosHabitoTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $HabitosTable _habitoIdTable(_$BancoAurora db) =>
      db.habitos.createAlias('registros_habito__habito_id__habitos__id');

  $$HabitosTableProcessedTableManager get habitoId {
    final $_column = $_itemColumn<String>('habito_id')!;

    final manager = $$HabitosTableTableManager(
      $_db,
      $_db.habitos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_habitoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RegistrosHabitoTableFilterComposer
    extends Composer<_$BancoAurora, $RegistrosHabitoTable> {
  $$RegistrosHabitoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get apagadoEm => $composableBuilder(
    column: $table.apagadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dia => $composableBuilder(
    column: $table.dia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get feito => $composableBuilder(
    column: $table.feito,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );

  $$HabitosTableFilterComposer get habitoId {
    final $$HabitosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitoId,
      referencedTable: $db.habitos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitosTableFilterComposer(
            $db: $db,
            $table: $db.habitos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RegistrosHabitoTableOrderingComposer
    extends Composer<_$BancoAurora, $RegistrosHabitoTable> {
  $$RegistrosHabitoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get apagadoEm => $composableBuilder(
    column: $table.apagadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dia => $composableBuilder(
    column: $table.dia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get feito => $composableBuilder(
    column: $table.feito,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );

  $$HabitosTableOrderingComposer get habitoId {
    final $$HabitosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitoId,
      referencedTable: $db.habitos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitosTableOrderingComposer(
            $db: $db,
            $table: $db.habitos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RegistrosHabitoTableAnnotationComposer
    extends Composer<_$BancoAurora, $RegistrosHabitoTable> {
  $$RegistrosHabitoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get apagadoEm =>
      $composableBuilder(column: $table.apagadoEm, builder: (column) => column);

  GeneratedColumn<String> get dia =>
      $composableBuilder(column: $table.dia, builder: (column) => column);

  GeneratedColumn<bool> get feito =>
      $composableBuilder(column: $table.feito, builder: (column) => column);

  GeneratedColumn<int> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);

  $$HabitosTableAnnotationComposer get habitoId {
    final $$HabitosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitoId,
      referencedTable: $db.habitos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitosTableAnnotationComposer(
            $db: $db,
            $table: $db.habitos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RegistrosHabitoTableTableManager
    extends
        RootTableManager<
          _$BancoAurora,
          $RegistrosHabitoTable,
          RegistrosHabitoData,
          $$RegistrosHabitoTableFilterComposer,
          $$RegistrosHabitoTableOrderingComposer,
          $$RegistrosHabitoTableAnnotationComposer,
          $$RegistrosHabitoTableCreateCompanionBuilder,
          $$RegistrosHabitoTableUpdateCompanionBuilder,
          (RegistrosHabitoData, $$RegistrosHabitoTableReferences),
          RegistrosHabitoData,
          PrefetchHooks Function({bool habitoId})
        > {
  $$RegistrosHabitoTableTableManager(
    _$BancoAurora db,
    $RegistrosHabitoTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RegistrosHabitoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RegistrosHabitoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RegistrosHabitoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                Value<String> habitoId = const Value.absent(),
                Value<String> dia = const Value.absent(),
                Value<bool> feito = const Value.absent(),
                Value<int?> valor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RegistrosHabitoCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                habitoId: habitoId,
                dia: dia,
                feito: feito,
                valor: valor,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                required String habitoId,
                required String dia,
                Value<bool> feito = const Value.absent(),
                Value<int?> valor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RegistrosHabitoCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                habitoId: habitoId,
                dia: dia,
                feito: feito,
                valor: valor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RegistrosHabitoTable, RegistrosHabitoData>(
                    table,
                  ),
                  $$RegistrosHabitoTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (habitoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.habitoId,
                        referencedTable: $$RegistrosHabitoTableReferences
                            ._habitoIdTable(db),
                        referencedColumn: $$RegistrosHabitoTableReferences
                            ._habitoIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RegistrosHabitoTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $RegistrosHabitoTable,
      RegistrosHabitoData,
      $$RegistrosHabitoTableFilterComposer,
      $$RegistrosHabitoTableOrderingComposer,
      $$RegistrosHabitoTableAnnotationComposer,
      $$RegistrosHabitoTableCreateCompanionBuilder,
      $$RegistrosHabitoTableUpdateCompanionBuilder,
      (RegistrosHabitoData, $$RegistrosHabitoTableReferences),
      RegistrosHabitoData,
      PrefetchHooks Function({bool habitoId})
    >;
typedef $$ContasFinanceirasTableCreateCompanionBuilder =
    ContasFinanceirasCompanion Function({
      Value<String> id,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<DateTime?> apagadoEm,
      required String nome,
      required TipoConta tipo,
      Value<int> saldoInicialCentavos,
      Value<int?> diaFechamento,
      Value<int?> diaVencimento,
      Value<int> rowid,
    });
typedef $$ContasFinanceirasTableUpdateCompanionBuilder =
    ContasFinanceirasCompanion Function({
      Value<String> id,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<DateTime?> apagadoEm,
      Value<String> nome,
      Value<TipoConta> tipo,
      Value<int> saldoInicialCentavos,
      Value<int?> diaFechamento,
      Value<int?> diaVencimento,
      Value<int> rowid,
    });

final class $$ContasFinanceirasTableReferences
    extends
        BaseReferences<
          _$BancoAurora,
          $ContasFinanceirasTable,
          ContasFinanceira
        > {
  $$ContasFinanceirasTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TransacoesTable, List<Transacoe>>
  _transacoesRefsTable(_$BancoAurora db) => MultiTypedResultKey.fromTable(
    db.transacoes,
    aliasName: 'contas_financeiras__id__transacoes__conta_id',
  );

  $$TransacoesTableProcessedTableManager get transacoesRefs {
    final manager = $$TransacoesTableTableManager(
      $_db,
      $_db.transacoes,
    ).filter((f) => f.contaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_transacoesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ContasFinanceirasTableFilterComposer
    extends Composer<_$BancoAurora, $ContasFinanceirasTable> {
  $$ContasFinanceirasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get apagadoEm => $composableBuilder(
    column: $table.apagadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoConta, TipoConta, String> get tipo =>
      $composableBuilder(
        column: $table.tipo,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get saldoInicialCentavos => $composableBuilder(
    column: $table.saldoInicialCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diaFechamento => $composableBuilder(
    column: $table.diaFechamento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diaVencimento => $composableBuilder(
    column: $table.diaVencimento,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transacoesRefs(
    Expression<bool> Function($$TransacoesTableFilterComposer f) f,
  ) {
    final $$TransacoesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transacoes,
      getReferencedColumn: (t) => t.contaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransacoesTableFilterComposer(
            $db: $db,
            $table: $db.transacoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ContasFinanceirasTableOrderingComposer
    extends Composer<_$BancoAurora, $ContasFinanceirasTable> {
  $$ContasFinanceirasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get apagadoEm => $composableBuilder(
    column: $table.apagadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get saldoInicialCentavos => $composableBuilder(
    column: $table.saldoInicialCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diaFechamento => $composableBuilder(
    column: $table.diaFechamento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diaVencimento => $composableBuilder(
    column: $table.diaVencimento,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContasFinanceirasTableAnnotationComposer
    extends Composer<_$BancoAurora, $ContasFinanceirasTable> {
  $$ContasFinanceirasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get apagadoEm =>
      $composableBuilder(column: $table.apagadoEm, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TipoConta, String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<int> get saldoInicialCentavos => $composableBuilder(
    column: $table.saldoInicialCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get diaFechamento => $composableBuilder(
    column: $table.diaFechamento,
    builder: (column) => column,
  );

  GeneratedColumn<int> get diaVencimento => $composableBuilder(
    column: $table.diaVencimento,
    builder: (column) => column,
  );

  Expression<T> transacoesRefs<T extends Object>(
    Expression<T> Function($$TransacoesTableAnnotationComposer a) f,
  ) {
    final $$TransacoesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transacoes,
      getReferencedColumn: (t) => t.contaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransacoesTableAnnotationComposer(
            $db: $db,
            $table: $db.transacoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ContasFinanceirasTableTableManager
    extends
        RootTableManager<
          _$BancoAurora,
          $ContasFinanceirasTable,
          ContasFinanceira,
          $$ContasFinanceirasTableFilterComposer,
          $$ContasFinanceirasTableOrderingComposer,
          $$ContasFinanceirasTableAnnotationComposer,
          $$ContasFinanceirasTableCreateCompanionBuilder,
          $$ContasFinanceirasTableUpdateCompanionBuilder,
          (ContasFinanceira, $$ContasFinanceirasTableReferences),
          ContasFinanceira,
          PrefetchHooks Function({bool transacoesRefs})
        > {
  $$ContasFinanceirasTableTableManager(
    _$BancoAurora db,
    $ContasFinanceirasTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContasFinanceirasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContasFinanceirasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContasFinanceirasTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<TipoConta> tipo = const Value.absent(),
                Value<int> saldoInicialCentavos = const Value.absent(),
                Value<int?> diaFechamento = const Value.absent(),
                Value<int?> diaVencimento = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContasFinanceirasCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                nome: nome,
                tipo: tipo,
                saldoInicialCentavos: saldoInicialCentavos,
                diaFechamento: diaFechamento,
                diaVencimento: diaVencimento,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                required String nome,
                required TipoConta tipo,
                Value<int> saldoInicialCentavos = const Value.absent(),
                Value<int?> diaFechamento = const Value.absent(),
                Value<int?> diaVencimento = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContasFinanceirasCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                nome: nome,
                tipo: tipo,
                saldoInicialCentavos: saldoInicialCentavos,
                diaFechamento: diaFechamento,
                diaVencimento: diaVencimento,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ContasFinanceirasTable, ContasFinanceira>(table),
                  $$ContasFinanceirasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transacoesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (transacoesRefs) db.transacoes],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transacoesRefs)
                    await $_getPrefetchedData<
                      ContasFinanceira,
                      $ContasFinanceirasTable,
                      Transacoe
                    >(
                      currentTable: table,
                      referencedTable: $$ContasFinanceirasTableReferences
                          ._transacoesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ContasFinanceirasTableReferences(
                            db,
                            table,
                            p0,
                          ).transacoesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.contaId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ContasFinanceirasTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $ContasFinanceirasTable,
      ContasFinanceira,
      $$ContasFinanceirasTableFilterComposer,
      $$ContasFinanceirasTableOrderingComposer,
      $$ContasFinanceirasTableAnnotationComposer,
      $$ContasFinanceirasTableCreateCompanionBuilder,
      $$ContasFinanceirasTableUpdateCompanionBuilder,
      (ContasFinanceira, $$ContasFinanceirasTableReferences),
      ContasFinanceira,
      PrefetchHooks Function({bool transacoesRefs})
    >;
typedef $$TransacoesTableCreateCompanionBuilder = TransacoesCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  required String descricao,
  required int valorCentavos,
  required TipoTransacao tipo,
  required DateTime data,
  Value<DateTime?> vencimento,
  Value<DateTime?> pagoEm,
  Value<String?> categoria,
  Value<String?> regraRepeticao,
  Value<int?> parcelaNumero,
  Value<int?> parcelaTotal,
  Value<String?> contaId,
  Value<int> rowid,
});
typedef $$TransacoesTableUpdateCompanionBuilder = TransacoesCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  Value<String> descricao,
  Value<int> valorCentavos,
  Value<TipoTransacao> tipo,
  Value<DateTime> data,
  Value<DateTime?> vencimento,
  Value<DateTime?> pagoEm,
  Value<String?> categoria,
  Value<String?> regraRepeticao,
  Value<int?> parcelaNumero,
  Value<int?> parcelaTotal,
  Value<String?> contaId,
  Value<int> rowid,
});

final class $$TransacoesTableReferences
    extends BaseReferences<_$BancoAurora, $TransacoesTable, Transacoe> {
  $$TransacoesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ContasFinanceirasTable _contaIdTable(_$BancoAurora db) => db
      .contasFinanceiras
      .createAlias('transacoes__conta_id__contas_financeiras__id');

  $$ContasFinanceirasTableProcessedTableManager? get contaId {
    final $_column = $_itemColumn<String>('conta_id');
    if ($_column == null) return null;
    final manager = $$ContasFinanceirasTableTableManager(
      $_db,
      $_db.contasFinanceiras,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransacoesTableFilterComposer
    extends Composer<_$BancoAurora, $TransacoesTable> {
  $$TransacoesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get apagadoEm => $composableBuilder(
    column: $table.apagadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valorCentavos => $composableBuilder(
    column: $table.valorCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoTransacao, TipoTransacao, String>
  get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get vencimento => $composableBuilder(
    column: $table.vencimento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pagoEm => $composableBuilder(
    column: $table.pagoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get regraRepeticao => $composableBuilder(
    column: $table.regraRepeticao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parcelaNumero => $composableBuilder(
    column: $table.parcelaNumero,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parcelaTotal => $composableBuilder(
    column: $table.parcelaTotal,
    builder: (column) => ColumnFilters(column),
  );

  $$ContasFinanceirasTableFilterComposer get contaId {
    final $$ContasFinanceirasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaId,
      referencedTable: $db.contasFinanceiras,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContasFinanceirasTableFilterComposer(
            $db: $db,
            $table: $db.contasFinanceiras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransacoesTableOrderingComposer
    extends Composer<_$BancoAurora, $TransacoesTable> {
  $$TransacoesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get apagadoEm => $composableBuilder(
    column: $table.apagadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valorCentavos => $composableBuilder(
    column: $table.valorCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get vencimento => $composableBuilder(
    column: $table.vencimento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pagoEm => $composableBuilder(
    column: $table.pagoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get regraRepeticao => $composableBuilder(
    column: $table.regraRepeticao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parcelaNumero => $composableBuilder(
    column: $table.parcelaNumero,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parcelaTotal => $composableBuilder(
    column: $table.parcelaTotal,
    builder: (column) => ColumnOrderings(column),
  );

  $$ContasFinanceirasTableOrderingComposer get contaId {
    final $$ContasFinanceirasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaId,
      referencedTable: $db.contasFinanceiras,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContasFinanceirasTableOrderingComposer(
            $db: $db,
            $table: $db.contasFinanceiras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransacoesTableAnnotationComposer
    extends Composer<_$BancoAurora, $TransacoesTable> {
  $$TransacoesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get apagadoEm =>
      $composableBuilder(column: $table.apagadoEm, builder: (column) => column);

  GeneratedColumn<String> get descricao =>
      $composableBuilder(column: $table.descricao, builder: (column) => column);

  GeneratedColumn<int> get valorCentavos => $composableBuilder(
    column: $table.valorCentavos,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TipoTransacao, String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<DateTime> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get vencimento => $composableBuilder(
    column: $table.vencimento,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get pagoEm =>
      $composableBuilder(column: $table.pagoEm, builder: (column) => column);

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<String> get regraRepeticao => $composableBuilder(
    column: $table.regraRepeticao,
    builder: (column) => column,
  );

  GeneratedColumn<int> get parcelaNumero => $composableBuilder(
    column: $table.parcelaNumero,
    builder: (column) => column,
  );

  GeneratedColumn<int> get parcelaTotal => $composableBuilder(
    column: $table.parcelaTotal,
    builder: (column) => column,
  );

  $$ContasFinanceirasTableAnnotationComposer get contaId {
    final $$ContasFinanceirasTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.contaId,
          referencedTable: $db.contasFinanceiras,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ContasFinanceirasTableAnnotationComposer(
                $db: $db,
                $table: $db.contasFinanceiras,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$TransacoesTableTableManager
    extends
        RootTableManager<
          _$BancoAurora,
          $TransacoesTable,
          Transacoe,
          $$TransacoesTableFilterComposer,
          $$TransacoesTableOrderingComposer,
          $$TransacoesTableAnnotationComposer,
          $$TransacoesTableCreateCompanionBuilder,
          $$TransacoesTableUpdateCompanionBuilder,
          (Transacoe, $$TransacoesTableReferences),
          Transacoe,
          PrefetchHooks Function({bool contaId})
        > {
  $$TransacoesTableTableManager(_$BancoAurora db, $TransacoesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransacoesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransacoesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransacoesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                Value<String> descricao = const Value.absent(),
                Value<int> valorCentavos = const Value.absent(),
                Value<TipoTransacao> tipo = const Value.absent(),
                Value<DateTime> data = const Value.absent(),
                Value<DateTime?> vencimento = const Value.absent(),
                Value<DateTime?> pagoEm = const Value.absent(),
                Value<String?> categoria = const Value.absent(),
                Value<String?> regraRepeticao = const Value.absent(),
                Value<int?> parcelaNumero = const Value.absent(),
                Value<int?> parcelaTotal = const Value.absent(),
                Value<String?> contaId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransacoesCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                descricao: descricao,
                valorCentavos: valorCentavos,
                tipo: tipo,
                data: data,
                vencimento: vencimento,
                pagoEm: pagoEm,
                categoria: categoria,
                regraRepeticao: regraRepeticao,
                parcelaNumero: parcelaNumero,
                parcelaTotal: parcelaTotal,
                contaId: contaId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                required String descricao,
                required int valorCentavos,
                required TipoTransacao tipo,
                required DateTime data,
                Value<DateTime?> vencimento = const Value.absent(),
                Value<DateTime?> pagoEm = const Value.absent(),
                Value<String?> categoria = const Value.absent(),
                Value<String?> regraRepeticao = const Value.absent(),
                Value<int?> parcelaNumero = const Value.absent(),
                Value<int?> parcelaTotal = const Value.absent(),
                Value<String?> contaId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransacoesCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                descricao: descricao,
                valorCentavos: valorCentavos,
                tipo: tipo,
                data: data,
                vencimento: vencimento,
                pagoEm: pagoEm,
                categoria: categoria,
                regraRepeticao: regraRepeticao,
                parcelaNumero: parcelaNumero,
                parcelaTotal: parcelaTotal,
                contaId: contaId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TransacoesTable, Transacoe>(table),
                  $$TransacoesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({contaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (contaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.contaId,
                        referencedTable: $$TransacoesTableReferences
                            ._contaIdTable(db),
                        referencedColumn: $$TransacoesTableReferences
                            ._contaIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TransacoesTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $TransacoesTable,
      Transacoe,
      $$TransacoesTableFilterComposer,
      $$TransacoesTableOrderingComposer,
      $$TransacoesTableAnnotationComposer,
      $$TransacoesTableCreateCompanionBuilder,
      $$TransacoesTableUpdateCompanionBuilder,
      (Transacoe, $$TransacoesTableReferences),
      Transacoe,
      PrefetchHooks Function({bool contaId})
    >;
typedef $$LembretesTableCreateCompanionBuilder = LembretesCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  required String texto,
  required DateTime quando,
  Value<String?> regraRepeticao,
  Value<int> notificarAntesMin,
  Value<bool> ativo,
  Value<String?> itemTipo,
  Value<String?> itemId,
  Value<int> rowid,
});
typedef $$LembretesTableUpdateCompanionBuilder = LembretesCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  Value<String> texto,
  Value<DateTime> quando,
  Value<String?> regraRepeticao,
  Value<int> notificarAntesMin,
  Value<bool> ativo,
  Value<String?> itemTipo,
  Value<String?> itemId,
  Value<int> rowid,
});

class $$LembretesTableFilterComposer
    extends Composer<_$BancoAurora, $LembretesTable> {
  $$LembretesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get apagadoEm => $composableBuilder(
    column: $table.apagadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get texto => $composableBuilder(
    column: $table.texto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get quando => $composableBuilder(
    column: $table.quando,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get regraRepeticao => $composableBuilder(
    column: $table.regraRepeticao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notificarAntesMin => $composableBuilder(
    column: $table.notificarAntesMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ativo => $composableBuilder(
    column: $table.ativo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemTipo => $composableBuilder(
    column: $table.itemTipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LembretesTableOrderingComposer
    extends Composer<_$BancoAurora, $LembretesTable> {
  $$LembretesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get apagadoEm => $composableBuilder(
    column: $table.apagadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get texto => $composableBuilder(
    column: $table.texto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get quando => $composableBuilder(
    column: $table.quando,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get regraRepeticao => $composableBuilder(
    column: $table.regraRepeticao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notificarAntesMin => $composableBuilder(
    column: $table.notificarAntesMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ativo => $composableBuilder(
    column: $table.ativo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemTipo => $composableBuilder(
    column: $table.itemTipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LembretesTableAnnotationComposer
    extends Composer<_$BancoAurora, $LembretesTable> {
  $$LembretesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get apagadoEm =>
      $composableBuilder(column: $table.apagadoEm, builder: (column) => column);

  GeneratedColumn<String> get texto =>
      $composableBuilder(column: $table.texto, builder: (column) => column);

  GeneratedColumn<DateTime> get quando =>
      $composableBuilder(column: $table.quando, builder: (column) => column);

  GeneratedColumn<String> get regraRepeticao => $composableBuilder(
    column: $table.regraRepeticao,
    builder: (column) => column,
  );

  GeneratedColumn<int> get notificarAntesMin => $composableBuilder(
    column: $table.notificarAntesMin,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get ativo =>
      $composableBuilder(column: $table.ativo, builder: (column) => column);

  GeneratedColumn<String> get itemTipo =>
      $composableBuilder(column: $table.itemTipo, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);
}

class $$LembretesTableTableManager
    extends
        RootTableManager<
          _$BancoAurora,
          $LembretesTable,
          Lembrete,
          $$LembretesTableFilterComposer,
          $$LembretesTableOrderingComposer,
          $$LembretesTableAnnotationComposer,
          $$LembretesTableCreateCompanionBuilder,
          $$LembretesTableUpdateCompanionBuilder,
          (Lembrete, BaseReferences<_$BancoAurora, $LembretesTable, Lembrete>),
          Lembrete,
          PrefetchHooks Function()
        > {
  $$LembretesTableTableManager(_$BancoAurora db, $LembretesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LembretesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LembretesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LembretesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                Value<String> texto = const Value.absent(),
                Value<DateTime> quando = const Value.absent(),
                Value<String?> regraRepeticao = const Value.absent(),
                Value<int> notificarAntesMin = const Value.absent(),
                Value<bool> ativo = const Value.absent(),
                Value<String?> itemTipo = const Value.absent(),
                Value<String?> itemId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LembretesCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                texto: texto,
                quando: quando,
                regraRepeticao: regraRepeticao,
                notificarAntesMin: notificarAntesMin,
                ativo: ativo,
                itemTipo: itemTipo,
                itemId: itemId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                required String texto,
                required DateTime quando,
                Value<String?> regraRepeticao = const Value.absent(),
                Value<int> notificarAntesMin = const Value.absent(),
                Value<bool> ativo = const Value.absent(),
                Value<String?> itemTipo = const Value.absent(),
                Value<String?> itemId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LembretesCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                texto: texto,
                quando: quando,
                regraRepeticao: regraRepeticao,
                notificarAntesMin: notificarAntesMin,
                ativo: ativo,
                itemTipo: itemTipo,
                itemId: itemId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LembretesTable, Lembrete>(table),
                  BaseReferences<_$BancoAurora, $LembretesTable, Lembrete>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LembretesTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $LembretesTable,
      Lembrete,
      $$LembretesTableFilterComposer,
      $$LembretesTableOrderingComposer,
      $$LembretesTableAnnotationComposer,
      $$LembretesTableCreateCompanionBuilder,
      $$LembretesTableUpdateCompanionBuilder,
      (Lembrete, BaseReferences<_$BancoAurora, $LembretesTable, Lembrete>),
      Lembrete,
      PrefetchHooks Function()
    >;
typedef $$PreferenciasTableCreateCompanionBuilder =
    PreferenciasCompanion Function({
      required String chave,
      required String valor,
      Value<int> rowid,
    });
typedef $$PreferenciasTableUpdateCompanionBuilder =
    PreferenciasCompanion Function({
      Value<String> chave,
      Value<String> valor,
      Value<int> rowid,
    });

class $$PreferenciasTableFilterComposer
    extends Composer<_$BancoAurora, $PreferenciasTable> {
  $$PreferenciasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get chave => $composableBuilder(
    column: $table.chave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PreferenciasTableOrderingComposer
    extends Composer<_$BancoAurora, $PreferenciasTable> {
  $$PreferenciasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get chave => $composableBuilder(
    column: $table.chave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PreferenciasTableAnnotationComposer
    extends Composer<_$BancoAurora, $PreferenciasTable> {
  $$PreferenciasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get chave =>
      $composableBuilder(column: $table.chave, builder: (column) => column);

  GeneratedColumn<String> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);
}

class $$PreferenciasTableTableManager
    extends
        RootTableManager<
          _$BancoAurora,
          $PreferenciasTable,
          Preferencia,
          $$PreferenciasTableFilterComposer,
          $$PreferenciasTableOrderingComposer,
          $$PreferenciasTableAnnotationComposer,
          $$PreferenciasTableCreateCompanionBuilder,
          $$PreferenciasTableUpdateCompanionBuilder,
          (
            Preferencia,
            BaseReferences<_$BancoAurora, $PreferenciasTable, Preferencia>,
          ),
          Preferencia,
          PrefetchHooks Function()
        > {
  $$PreferenciasTableTableManager(_$BancoAurora db, $PreferenciasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreferenciasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreferenciasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreferenciasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> chave = const Value.absent(),
            Value<String> valor = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => PreferenciasCompanion(chave: chave, valor: valor, rowid: rowid),
          createCompanionCallback:
              ({
                required String chave,
                required String valor,
                Value<int> rowid = const Value.absent(),
              }) => PreferenciasCompanion.insert(
                chave: chave,
                valor: valor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PreferenciasTable, Preferencia>(table),
                  BaseReferences<
                    _$BancoAurora,
                    $PreferenciasTable,
                    Preferencia
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PreferenciasTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $PreferenciasTable,
      Preferencia,
      $$PreferenciasTableFilterComposer,
      $$PreferenciasTableOrderingComposer,
      $$PreferenciasTableAnnotationComposer,
      $$PreferenciasTableCreateCompanionBuilder,
      $$PreferenciasTableUpdateCompanionBuilder,
      (
        Preferencia,
        BaseReferences<_$BancoAurora, $PreferenciasTable, Preferencia>,
      ),
      Preferencia,
      PrefetchHooks Function()
    >;

class $BancoAuroraManager {
  final _$BancoAurora _db;
  $BancoAuroraManager(this._db);
  $$MetasTableTableManager get metas =>
      $$MetasTableTableManager(_db, _db.metas);
  $$TarefasTableTableManager get tarefas =>
      $$TarefasTableTableManager(_db, _db.tarefas);
  $$ConclusoesTarefaTableTableManager get conclusoesTarefa =>
      $$ConclusoesTarefaTableTableManager(_db, _db.conclusoesTarefa);
  $$HabitosTableTableManager get habitos =>
      $$HabitosTableTableManager(_db, _db.habitos);
  $$RegistrosHabitoTableTableManager get registrosHabito =>
      $$RegistrosHabitoTableTableManager(_db, _db.registrosHabito);
  $$ContasFinanceirasTableTableManager get contasFinanceiras =>
      $$ContasFinanceirasTableTableManager(_db, _db.contasFinanceiras);
  $$TransacoesTableTableManager get transacoes =>
      $$TransacoesTableTableManager(_db, _db.transacoes);
  $$LembretesTableTableManager get lembretes =>
      $$LembretesTableTableManager(_db, _db.lembretes);
  $$PreferenciasTableTableManager get preferencias =>
      $$PreferenciasTableTableManager(_db, _db.preferencias);
}
