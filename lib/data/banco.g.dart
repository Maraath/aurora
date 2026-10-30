// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banco.dart';

// ignore_for_file: type=lint
class $ObjetivosTable extends Objetivos
    with TableInfo<$ObjetivosTable, Objetivo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ObjetivosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _descricaoMeta = const VerificationMeta(
    'descricao',
  );
  @override
  late final GeneratedColumn<String> descricao = GeneratedColumn<String>(
    'descricao',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _valorInicialMeta = const VerificationMeta(
    'valorInicial',
  );
  @override
  late final GeneratedColumn<double> valorInicial = GeneratedColumn<double>(
    'valor_inicial',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  static const VerificationMeta _inicioMeta = const VerificationMeta('inicio');
  @override
  late final GeneratedColumn<DateTime> inicio = GeneratedColumn<DateTime>(
    'inicio',
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
  static const VerificationMeta _corMeta = const VerificationMeta('cor');
  @override
  late final GeneratedColumn<String> cor = GeneratedColumn<String>(
    'cor',
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
    nome,
    descricao,
    unidade,
    valorInicial,
    valorAtual,
    valorAlvo,
    dataAlvo,
    inicio,
    status,
    cor,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'objetivos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Objetivo> instance, {
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
    if (data.containsKey('descricao')) {
      context.handle(
        _descricaoMeta,
        descricao.isAcceptableOrUnknown(data['descricao']!, _descricaoMeta),
      );
    }
    if (data.containsKey('unidade')) {
      context.handle(
        _unidadeMeta,
        unidade.isAcceptableOrUnknown(data['unidade']!, _unidadeMeta),
      );
    }
    if (data.containsKey('valor_inicial')) {
      context.handle(
        _valorInicialMeta,
        valorInicial.isAcceptableOrUnknown(
          data['valor_inicial']!,
          _valorInicialMeta,
        ),
      );
    }
    if (data.containsKey('valor_atual')) {
      context.handle(
        _valorAtualMeta,
        valorAtual.isAcceptableOrUnknown(data['valor_atual']!, _valorAtualMeta),
      );
    }
    if (data.containsKey('valor_alvo')) {
      context.handle(
        _valorAlvoMeta,
        valorAlvo.isAcceptableOrUnknown(data['valor_alvo']!, _valorAlvoMeta),
      );
    }
    if (data.containsKey('data_alvo')) {
      context.handle(
        _dataAlvoMeta,
        dataAlvo.isAcceptableOrUnknown(data['data_alvo']!, _dataAlvoMeta),
      );
    }
    if (data.containsKey('inicio')) {
      context.handle(
        _inicioMeta,
        inicio.isAcceptableOrUnknown(data['inicio']!, _inicioMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('cor')) {
      context.handle(
        _corMeta,
        cor.isAcceptableOrUnknown(data['cor']!, _corMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Objetivo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Objetivo(
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
      descricao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descricao'],
      ),
      unidade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unidade'],
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
      dataAlvo: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_alvo'],
      ),
      inicio: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}inicio'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      cor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cor'],
      ),
    );
  }

  @override
  $ObjetivosTable createAlias(String alias) {
    return $ObjetivosTable(attachedDatabase, alias);
  }
}

class Objetivo extends DataClass implements Insertable<Objetivo> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? apagadoEm;
  final String nome;
  final String? descricao;
  final String unidade;
  final double valorInicial;
  final double valorAtual;
  final double valorAlvo;
  final DateTime? dataAlvo;
  final DateTime? inicio;
  final String status;
  final String? cor;
  const Objetivo({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.apagadoEm,
    required this.nome,
    this.descricao,
    required this.unidade,
    required this.valorInicial,
    required this.valorAtual,
    required this.valorAlvo,
    this.dataAlvo,
    this.inicio,
    required this.status,
    this.cor,
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
    if (!nullToAbsent || descricao != null) {
      map['descricao'] = Variable<String>(descricao);
    }
    map['unidade'] = Variable<String>(unidade);
    map['valor_inicial'] = Variable<double>(valorInicial);
    map['valor_atual'] = Variable<double>(valorAtual);
    map['valor_alvo'] = Variable<double>(valorAlvo);
    if (!nullToAbsent || dataAlvo != null) {
      map['data_alvo'] = Variable<DateTime>(dataAlvo);
    }
    if (!nullToAbsent || inicio != null) {
      map['inicio'] = Variable<DateTime>(inicio);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || cor != null) {
      map['cor'] = Variable<String>(cor);
    }
    return map;
  }

  ObjetivosCompanion toCompanion(bool nullToAbsent) {
    return ObjetivosCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      apagadoEm: apagadoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(apagadoEm),
      nome: Value(nome),
      descricao: descricao == null && nullToAbsent
          ? const Value.absent()
          : Value(descricao),
      unidade: Value(unidade),
      valorInicial: Value(valorInicial),
      valorAtual: Value(valorAtual),
      valorAlvo: Value(valorAlvo),
      dataAlvo: dataAlvo == null && nullToAbsent
          ? const Value.absent()
          : Value(dataAlvo),
      inicio: inicio == null && nullToAbsent
          ? const Value.absent()
          : Value(inicio),
      status: Value(status),
      cor: cor == null && nullToAbsent ? const Value.absent() : Value(cor),
    );
  }

  factory Objetivo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Objetivo(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      apagadoEm: serializer.fromJson<DateTime?>(json['apagadoEm']),
      nome: serializer.fromJson<String>(json['nome']),
      descricao: serializer.fromJson<String?>(json['descricao']),
      unidade: serializer.fromJson<String>(json['unidade']),
      valorInicial: serializer.fromJson<double>(json['valorInicial']),
      valorAtual: serializer.fromJson<double>(json['valorAtual']),
      valorAlvo: serializer.fromJson<double>(json['valorAlvo']),
      dataAlvo: serializer.fromJson<DateTime?>(json['dataAlvo']),
      inicio: serializer.fromJson<DateTime?>(json['inicio']),
      status: serializer.fromJson<String>(json['status']),
      cor: serializer.fromJson<String?>(json['cor']),
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
      'descricao': serializer.toJson<String?>(descricao),
      'unidade': serializer.toJson<String>(unidade),
      'valorInicial': serializer.toJson<double>(valorInicial),
      'valorAtual': serializer.toJson<double>(valorAtual),
      'valorAlvo': serializer.toJson<double>(valorAlvo),
      'dataAlvo': serializer.toJson<DateTime?>(dataAlvo),
      'inicio': serializer.toJson<DateTime?>(inicio),
      'status': serializer.toJson<String>(status),
      'cor': serializer.toJson<String?>(cor),
    };
  }

  Objetivo copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> apagadoEm = const Value.absent(),
    String? nome,
    Value<String?> descricao = const Value.absent(),
    String? unidade,
    double? valorInicial,
    double? valorAtual,
    double? valorAlvo,
    Value<DateTime?> dataAlvo = const Value.absent(),
    Value<DateTime?> inicio = const Value.absent(),
    String? status,
    Value<String?> cor = const Value.absent(),
  }) => Objetivo(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    apagadoEm: apagadoEm.present ? apagadoEm.value : this.apagadoEm,
    nome: nome ?? this.nome,
    descricao: descricao.present ? descricao.value : this.descricao,
    unidade: unidade ?? this.unidade,
    valorInicial: valorInicial ?? this.valorInicial,
    valorAtual: valorAtual ?? this.valorAtual,
    valorAlvo: valorAlvo ?? this.valorAlvo,
    dataAlvo: dataAlvo.present ? dataAlvo.value : this.dataAlvo,
    inicio: inicio.present ? inicio.value : this.inicio,
    status: status ?? this.status,
    cor: cor.present ? cor.value : this.cor,
  );
  Objetivo copyWithCompanion(ObjetivosCompanion data) {
    return Objetivo(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      apagadoEm: data.apagadoEm.present ? data.apagadoEm.value : this.apagadoEm,
      nome: data.nome.present ? data.nome.value : this.nome,
      descricao: data.descricao.present ? data.descricao.value : this.descricao,
      unidade: data.unidade.present ? data.unidade.value : this.unidade,
      valorInicial: data.valorInicial.present
          ? data.valorInicial.value
          : this.valorInicial,
      valorAtual: data.valorAtual.present
          ? data.valorAtual.value
          : this.valorAtual,
      valorAlvo: data.valorAlvo.present ? data.valorAlvo.value : this.valorAlvo,
      dataAlvo: data.dataAlvo.present ? data.dataAlvo.value : this.dataAlvo,
      inicio: data.inicio.present ? data.inicio.value : this.inicio,
      status: data.status.present ? data.status.value : this.status,
      cor: data.cor.present ? data.cor.value : this.cor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Objetivo(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('nome: $nome, ')
          ..write('descricao: $descricao, ')
          ..write('unidade: $unidade, ')
          ..write('valorInicial: $valorInicial, ')
          ..write('valorAtual: $valorAtual, ')
          ..write('valorAlvo: $valorAlvo, ')
          ..write('dataAlvo: $dataAlvo, ')
          ..write('inicio: $inicio, ')
          ..write('status: $status, ')
          ..write('cor: $cor')
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
    descricao,
    unidade,
    valorInicial,
    valorAtual,
    valorAlvo,
    dataAlvo,
    inicio,
    status,
    cor,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Objetivo &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.apagadoEm == this.apagadoEm &&
          other.nome == this.nome &&
          other.descricao == this.descricao &&
          other.unidade == this.unidade &&
          other.valorInicial == this.valorInicial &&
          other.valorAtual == this.valorAtual &&
          other.valorAlvo == this.valorAlvo &&
          other.dataAlvo == this.dataAlvo &&
          other.inicio == this.inicio &&
          other.status == this.status &&
          other.cor == this.cor);
}

class ObjetivosCompanion extends UpdateCompanion<Objetivo> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> apagadoEm;
  final Value<String> nome;
  final Value<String?> descricao;
  final Value<String> unidade;
  final Value<double> valorInicial;
  final Value<double> valorAtual;
  final Value<double> valorAlvo;
  final Value<DateTime?> dataAlvo;
  final Value<DateTime?> inicio;
  final Value<String> status;
  final Value<String?> cor;
  final Value<int> rowid;
  const ObjetivosCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    this.nome = const Value.absent(),
    this.descricao = const Value.absent(),
    this.unidade = const Value.absent(),
    this.valorInicial = const Value.absent(),
    this.valorAtual = const Value.absent(),
    this.valorAlvo = const Value.absent(),
    this.dataAlvo = const Value.absent(),
    this.inicio = const Value.absent(),
    this.status = const Value.absent(),
    this.cor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ObjetivosCompanion.insert({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    required String nome,
    this.descricao = const Value.absent(),
    this.unidade = const Value.absent(),
    this.valorInicial = const Value.absent(),
    this.valorAtual = const Value.absent(),
    this.valorAlvo = const Value.absent(),
    this.dataAlvo = const Value.absent(),
    this.inicio = const Value.absent(),
    this.status = const Value.absent(),
    this.cor = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : nome = Value(nome);
  static Insertable<Objetivo> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? apagadoEm,
    Expression<String>? nome,
    Expression<String>? descricao,
    Expression<String>? unidade,
    Expression<double>? valorInicial,
    Expression<double>? valorAtual,
    Expression<double>? valorAlvo,
    Expression<DateTime>? dataAlvo,
    Expression<DateTime>? inicio,
    Expression<String>? status,
    Expression<String>? cor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (apagadoEm != null) 'apagado_em': apagadoEm,
      if (nome != null) 'nome': nome,
      if (descricao != null) 'descricao': descricao,
      if (unidade != null) 'unidade': unidade,
      if (valorInicial != null) 'valor_inicial': valorInicial,
      if (valorAtual != null) 'valor_atual': valorAtual,
      if (valorAlvo != null) 'valor_alvo': valorAlvo,
      if (dataAlvo != null) 'data_alvo': dataAlvo,
      if (inicio != null) 'inicio': inicio,
      if (status != null) 'status': status,
      if (cor != null) 'cor': cor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ObjetivosCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? apagadoEm,
    Value<String>? nome,
    Value<String?>? descricao,
    Value<String>? unidade,
    Value<double>? valorInicial,
    Value<double>? valorAtual,
    Value<double>? valorAlvo,
    Value<DateTime?>? dataAlvo,
    Value<DateTime?>? inicio,
    Value<String>? status,
    Value<String?>? cor,
    Value<int>? rowid,
  }) {
    return ObjetivosCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      apagadoEm: apagadoEm ?? this.apagadoEm,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      unidade: unidade ?? this.unidade,
      valorInicial: valorInicial ?? this.valorInicial,
      valorAtual: valorAtual ?? this.valorAtual,
      valorAlvo: valorAlvo ?? this.valorAlvo,
      dataAlvo: dataAlvo ?? this.dataAlvo,
      inicio: inicio ?? this.inicio,
      status: status ?? this.status,
      cor: cor ?? this.cor,
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
    if (descricao.present) {
      map['descricao'] = Variable<String>(descricao.value);
    }
    if (unidade.present) {
      map['unidade'] = Variable<String>(unidade.value);
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
    if (dataAlvo.present) {
      map['data_alvo'] = Variable<DateTime>(dataAlvo.value);
    }
    if (inicio.present) {
      map['inicio'] = Variable<DateTime>(inicio.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (cor.present) {
      map['cor'] = Variable<String>(cor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObjetivosCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('nome: $nome, ')
          ..write('descricao: $descricao, ')
          ..write('unidade: $unidade, ')
          ..write('valorInicial: $valorInicial, ')
          ..write('valorAtual: $valorAtual, ')
          ..write('valorAlvo: $valorAlvo, ')
          ..write('dataAlvo: $dataAlvo, ')
          ..write('inicio: $inicio, ')
          ..write('status: $status, ')
          ..write('cor: $cor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EtapasTable extends Etapas with TableInfo<$EtapasTable, Etapa> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EtapasTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _objetivoIdMeta = const VerificationMeta(
    'objetivoId',
  );
  @override
  late final GeneratedColumn<String> objetivoId = GeneratedColumn<String>(
    'objetivo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES objetivos (id)',
    ),
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
  static const VerificationMeta _concluidaMeta = const VerificationMeta(
    'concluida',
  );
  @override
  late final GeneratedColumn<bool> concluida = GeneratedColumn<bool>(
    'concluida',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("concluida" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _ordemMeta = const VerificationMeta('ordem');
  @override
  late final GeneratedColumn<int> ordem = GeneratedColumn<int>(
    'ordem',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _concluidaEmMeta = const VerificationMeta(
    'concluidaEm',
  );
  @override
  late final GeneratedColumn<DateTime> concluidaEm = GeneratedColumn<DateTime>(
    'concluida_em',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    objetivoId,
    titulo,
    concluida,
    ordem,
    concluidaEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'etapas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Etapa> instance, {
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
    if (data.containsKey('objetivo_id')) {
      context.handle(
        _objetivoIdMeta,
        objetivoId.isAcceptableOrUnknown(data['objetivo_id']!, _objetivoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_objetivoIdMeta);
    }
    if (data.containsKey('titulo')) {
      context.handle(
        _tituloMeta,
        titulo.isAcceptableOrUnknown(data['titulo']!, _tituloMeta),
      );
    } else if (isInserting) {
      context.missing(_tituloMeta);
    }
    if (data.containsKey('concluida')) {
      context.handle(
        _concluidaMeta,
        concluida.isAcceptableOrUnknown(data['concluida']!, _concluidaMeta),
      );
    }
    if (data.containsKey('ordem')) {
      context.handle(
        _ordemMeta,
        ordem.isAcceptableOrUnknown(data['ordem']!, _ordemMeta),
      );
    }
    if (data.containsKey('concluida_em')) {
      context.handle(
        _concluidaEmMeta,
        concluidaEm.isAcceptableOrUnknown(
          data['concluida_em']!,
          _concluidaEmMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Etapa map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Etapa(
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
      objetivoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}objetivo_id'],
      )!,
      titulo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titulo'],
      )!,
      concluida: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}concluida'],
      )!,
      ordem: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordem'],
      )!,
      concluidaEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}concluida_em'],
      ),
    );
  }

  @override
  $EtapasTable createAlias(String alias) {
    return $EtapasTable(attachedDatabase, alias);
  }
}

class Etapa extends DataClass implements Insertable<Etapa> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? apagadoEm;
  final String objetivoId;
  final String titulo;
  final bool concluida;
  final int ordem;
  final DateTime? concluidaEm;
  const Etapa({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.apagadoEm,
    required this.objetivoId,
    required this.titulo,
    required this.concluida,
    required this.ordem,
    this.concluidaEm,
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
    map['objetivo_id'] = Variable<String>(objetivoId);
    map['titulo'] = Variable<String>(titulo);
    map['concluida'] = Variable<bool>(concluida);
    map['ordem'] = Variable<int>(ordem);
    if (!nullToAbsent || concluidaEm != null) {
      map['concluida_em'] = Variable<DateTime>(concluidaEm);
    }
    return map;
  }

  EtapasCompanion toCompanion(bool nullToAbsent) {
    return EtapasCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      apagadoEm: apagadoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(apagadoEm),
      objetivoId: Value(objetivoId),
      titulo: Value(titulo),
      concluida: Value(concluida),
      ordem: Value(ordem),
      concluidaEm: concluidaEm == null && nullToAbsent
          ? const Value.absent()
          : Value(concluidaEm),
    );
  }

  factory Etapa.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Etapa(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      apagadoEm: serializer.fromJson<DateTime?>(json['apagadoEm']),
      objetivoId: serializer.fromJson<String>(json['objetivoId']),
      titulo: serializer.fromJson<String>(json['titulo']),
      concluida: serializer.fromJson<bool>(json['concluida']),
      ordem: serializer.fromJson<int>(json['ordem']),
      concluidaEm: serializer.fromJson<DateTime?>(json['concluidaEm']),
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
      'objetivoId': serializer.toJson<String>(objetivoId),
      'titulo': serializer.toJson<String>(titulo),
      'concluida': serializer.toJson<bool>(concluida),
      'ordem': serializer.toJson<int>(ordem),
      'concluidaEm': serializer.toJson<DateTime?>(concluidaEm),
    };
  }

  Etapa copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> apagadoEm = const Value.absent(),
    String? objetivoId,
    String? titulo,
    bool? concluida,
    int? ordem,
    Value<DateTime?> concluidaEm = const Value.absent(),
  }) => Etapa(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    apagadoEm: apagadoEm.present ? apagadoEm.value : this.apagadoEm,
    objetivoId: objetivoId ?? this.objetivoId,
    titulo: titulo ?? this.titulo,
    concluida: concluida ?? this.concluida,
    ordem: ordem ?? this.ordem,
    concluidaEm: concluidaEm.present ? concluidaEm.value : this.concluidaEm,
  );
  Etapa copyWithCompanion(EtapasCompanion data) {
    return Etapa(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      apagadoEm: data.apagadoEm.present ? data.apagadoEm.value : this.apagadoEm,
      objetivoId: data.objetivoId.present
          ? data.objetivoId.value
          : this.objetivoId,
      titulo: data.titulo.present ? data.titulo.value : this.titulo,
      concluida: data.concluida.present ? data.concluida.value : this.concluida,
      ordem: data.ordem.present ? data.ordem.value : this.ordem,
      concluidaEm: data.concluidaEm.present
          ? data.concluidaEm.value
          : this.concluidaEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Etapa(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('objetivoId: $objetivoId, ')
          ..write('titulo: $titulo, ')
          ..write('concluida: $concluida, ')
          ..write('ordem: $ordem, ')
          ..write('concluidaEm: $concluidaEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    objetivoId,
    titulo,
    concluida,
    ordem,
    concluidaEm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Etapa &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.apagadoEm == this.apagadoEm &&
          other.objetivoId == this.objetivoId &&
          other.titulo == this.titulo &&
          other.concluida == this.concluida &&
          other.ordem == this.ordem &&
          other.concluidaEm == this.concluidaEm);
}

class EtapasCompanion extends UpdateCompanion<Etapa> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> apagadoEm;
  final Value<String> objetivoId;
  final Value<String> titulo;
  final Value<bool> concluida;
  final Value<int> ordem;
  final Value<DateTime?> concluidaEm;
  final Value<int> rowid;
  const EtapasCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    this.objetivoId = const Value.absent(),
    this.titulo = const Value.absent(),
    this.concluida = const Value.absent(),
    this.ordem = const Value.absent(),
    this.concluidaEm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EtapasCompanion.insert({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    required String objetivoId,
    required String titulo,
    this.concluida = const Value.absent(),
    this.ordem = const Value.absent(),
    this.concluidaEm = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : objetivoId = Value(objetivoId),
       titulo = Value(titulo);
  static Insertable<Etapa> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? apagadoEm,
    Expression<String>? objetivoId,
    Expression<String>? titulo,
    Expression<bool>? concluida,
    Expression<int>? ordem,
    Expression<DateTime>? concluidaEm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (apagadoEm != null) 'apagado_em': apagadoEm,
      if (objetivoId != null) 'objetivo_id': objetivoId,
      if (titulo != null) 'titulo': titulo,
      if (concluida != null) 'concluida': concluida,
      if (ordem != null) 'ordem': ordem,
      if (concluidaEm != null) 'concluida_em': concluidaEm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EtapasCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? apagadoEm,
    Value<String>? objetivoId,
    Value<String>? titulo,
    Value<bool>? concluida,
    Value<int>? ordem,
    Value<DateTime?>? concluidaEm,
    Value<int>? rowid,
  }) {
    return EtapasCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      apagadoEm: apagadoEm ?? this.apagadoEm,
      objetivoId: objetivoId ?? this.objetivoId,
      titulo: titulo ?? this.titulo,
      concluida: concluida ?? this.concluida,
      ordem: ordem ?? this.ordem,
      concluidaEm: concluidaEm ?? this.concluidaEm,
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
    if (objetivoId.present) {
      map['objetivo_id'] = Variable<String>(objetivoId.value);
    }
    if (titulo.present) {
      map['titulo'] = Variable<String>(titulo.value);
    }
    if (concluida.present) {
      map['concluida'] = Variable<bool>(concluida.value);
    }
    if (ordem.present) {
      map['ordem'] = Variable<int>(ordem.value);
    }
    if (concluidaEm.present) {
      map['concluida_em'] = Variable<DateTime>(concluidaEm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EtapasCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('objetivoId: $objetivoId, ')
          ..write('titulo: $titulo, ')
          ..write('concluida: $concluida, ')
          ..write('ordem: $ordem, ')
          ..write('concluidaEm: $concluidaEm, ')
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
  static const VerificationMeta _objetivoIdMeta = const VerificationMeta(
    'objetivoId',
  );
  @override
  late final GeneratedColumn<String> objetivoId = GeneratedColumn<String>(
    'objetivo_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES objetivos (id)',
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
    objetivoId,
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
    if (data.containsKey('objetivo_id')) {
      context.handle(
        _objetivoIdMeta,
        objetivoId.isAcceptableOrUnknown(data['objetivo_id']!, _objetivoIdMeta),
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
      objetivoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}objetivo_id'],
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

  /// Etapa de um objetivo.
  final String? objetivoId;
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
    this.objetivoId,
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
    if (!nullToAbsent || objetivoId != null) {
      map['objetivo_id'] = Variable<String>(objetivoId);
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
      objetivoId: objetivoId == null && nullToAbsent
          ? const Value.absent()
          : Value(objetivoId),
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
      objetivoId: serializer.fromJson<String?>(json['objetivoId']),
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
      'objetivoId': serializer.toJson<String?>(objetivoId),
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
    Value<String?> objetivoId = const Value.absent(),
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
    objetivoId: objetivoId.present ? objetivoId.value : this.objetivoId,
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
      objetivoId: data.objetivoId.present
          ? data.objetivoId.value
          : this.objetivoId,
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
          ..write('objetivoId: $objetivoId')
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
    objetivoId,
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
          other.objetivoId == this.objetivoId);
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
  final Value<String?> objetivoId;
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
    this.objetivoId = const Value.absent(),
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
    this.objetivoId = const Value.absent(),
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
    Expression<String>? objetivoId,
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
      if (objetivoId != null) 'objetivo_id': objetivoId,
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
    Value<String?>? objetivoId,
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
      objetivoId: objetivoId ?? this.objetivoId,
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
    if (objetivoId.present) {
      map['objetivo_id'] = Variable<String>(objetivoId.value);
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
          ..write('objetivoId: $objetivoId, ')
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

  /// "aaaa-mm-dd" da ocorrência, no fuso do aparelho.
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
  static const VerificationMeta _objetivoIdMeta = const VerificationMeta(
    'objetivoId',
  );
  @override
  late final GeneratedColumn<String> objetivoId = GeneratedColumn<String>(
    'objetivo_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES objetivos (id)',
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
    objetivoId,
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
    if (data.containsKey('objetivo_id')) {
      context.handle(
        _objetivoIdMeta,
        objetivoId.isAcceptableOrUnknown(data['objetivo_id']!, _objetivoIdMeta),
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
      objetivoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}objetivo_id'],
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
  final String? objetivoId;
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
    this.objetivoId,
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
    if (!nullToAbsent || objetivoId != null) {
      map['objetivo_id'] = Variable<String>(objetivoId);
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
      objetivoId: objetivoId == null && nullToAbsent
          ? const Value.absent()
          : Value(objetivoId),
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
      objetivoId: serializer.fromJson<String?>(json['objetivoId']),
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
      'objetivoId': serializer.toJson<String?>(objetivoId),
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
    Value<String?> objetivoId = const Value.absent(),
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
    objetivoId: objetivoId.present ? objetivoId.value : this.objetivoId,
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
      objetivoId: data.objetivoId.present
          ? data.objetivoId.value
          : this.objetivoId,
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
          ..write('objetivoId: $objetivoId')
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
    objetivoId,
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
          other.objetivoId == this.objetivoId);
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
  final Value<String?> objetivoId;
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
    this.objetivoId = const Value.absent(),
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
    this.objetivoId = const Value.absent(),
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
    Expression<String>? objetivoId,
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
      if (objetivoId != null) 'objetivo_id': objetivoId,
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
    Value<String?>? objetivoId,
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
      objetivoId: objetivoId ?? this.objetivoId,
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
    if (objetivoId.present) {
      map['objetivo_id'] = Variable<String>(objetivoId.value);
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
          ..write('objetivoId: $objetivoId, ')
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

  /// "aaaa-mm-dd" no fuso do aparelho.
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
    with TableInfo<$ContasFinanceirasTable, ContaFinanceira> {
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
    Insertable<ContaFinanceira> instance, {
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
  ContaFinanceira map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContaFinanceira(
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

class ContaFinanceira extends DataClass implements Insertable<ContaFinanceira> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? apagadoEm;
  final String nome;
  final TipoConta tipo;
  final int saldoInicialCentavos;
  final int? diaFechamento;
  final int? diaVencimento;
  const ContaFinanceira({
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

  factory ContaFinanceira.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContaFinanceira(
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

  ContaFinanceira copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> apagadoEm = const Value.absent(),
    String? nome,
    TipoConta? tipo,
    int? saldoInicialCentavos,
    Value<int?> diaFechamento = const Value.absent(),
    Value<int?> diaVencimento = const Value.absent(),
  }) => ContaFinanceira(
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
  ContaFinanceira copyWithCompanion(ContasFinanceirasCompanion data) {
    return ContaFinanceira(
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
    return (StringBuffer('ContaFinanceira(')
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
      (other is ContaFinanceira &&
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

class ContasFinanceirasCompanion extends UpdateCompanion<ContaFinanceira> {
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
  static Insertable<ContaFinanceira> custom({
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
    with TableInfo<$TransacoesTable, Transacao> {
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
  static const VerificationMeta _contaDestinoIdMeta = const VerificationMeta(
    'contaDestinoId',
  );
  @override
  late final GeneratedColumn<String> contaDestinoId = GeneratedColumn<String>(
    'conta_destino_id',
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
    contaDestinoId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transacoes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transacao> instance, {
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
    if (data.containsKey('conta_destino_id')) {
      context.handle(
        _contaDestinoIdMeta,
        contaDestinoId.isAcceptableOrUnknown(
          data['conta_destino_id']!,
          _contaDestinoIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transacao map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transacao(
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
      contaDestinoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conta_destino_id'],
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

class Transacao extends DataClass implements Insertable<Transacao> {
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

  /// Transferência: conta que recebe (ex.: pagamento da fatura de um cartão).
  /// Transferências não contam como gasto nem como entrada do mês.
  final String? contaDestinoId;
  const Transacao({
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
    this.contaDestinoId,
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
    if (!nullToAbsent || contaDestinoId != null) {
      map['conta_destino_id'] = Variable<String>(contaDestinoId);
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
      contaDestinoId: contaDestinoId == null && nullToAbsent
          ? const Value.absent()
          : Value(contaDestinoId),
    );
  }

  factory Transacao.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transacao(
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
      contaDestinoId: serializer.fromJson<String?>(json['contaDestinoId']),
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
      'contaDestinoId': serializer.toJson<String?>(contaDestinoId),
    };
  }

  Transacao copyWith({
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
    Value<String?> contaDestinoId = const Value.absent(),
  }) => Transacao(
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
    contaDestinoId: contaDestinoId.present
        ? contaDestinoId.value
        : this.contaDestinoId,
  );
  Transacao copyWithCompanion(TransacoesCompanion data) {
    return Transacao(
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
      contaDestinoId: data.contaDestinoId.present
          ? data.contaDestinoId.value
          : this.contaDestinoId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transacao(')
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
          ..write('contaDestinoId: $contaDestinoId')
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
    contaDestinoId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transacao &&
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
          other.contaId == this.contaId &&
          other.contaDestinoId == this.contaDestinoId);
}

class TransacoesCompanion extends UpdateCompanion<Transacao> {
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
  final Value<String?> contaDestinoId;
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
    this.contaDestinoId = const Value.absent(),
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
    this.contaDestinoId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : descricao = Value(descricao),
       valorCentavos = Value(valorCentavos),
       tipo = Value(tipo),
       data = Value(data);
  static Insertable<Transacao> custom({
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
    Expression<String>? contaDestinoId,
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
      if (contaDestinoId != null) 'conta_destino_id': contaDestinoId,
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
    Value<String?>? contaDestinoId,
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
      contaDestinoId: contaDestinoId ?? this.contaDestinoId,
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
    if (contaDestinoId.present) {
      map['conta_destino_id'] = Variable<String>(contaDestinoId.value);
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
          ..write('contaDestinoId: $contaDestinoId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PagamentosTransacaoTable extends PagamentosTransacao
    with TableInfo<$PagamentosTransacaoTable, PagamentoTransacao> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PagamentosTransacaoTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _transacaoIdMeta = const VerificationMeta(
    'transacaoId',
  );
  @override
  late final GeneratedColumn<String> transacaoId = GeneratedColumn<String>(
    'transacao_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transacoes (id)',
    ),
  );
  static const VerificationMeta _vencimentoMeta = const VerificationMeta(
    'vencimento',
  );
  @override
  late final GeneratedColumn<String> vencimento = GeneratedColumn<String>(
    'vencimento',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pagoEmMeta = const VerificationMeta('pagoEm');
  @override
  late final GeneratedColumn<DateTime> pagoEm = GeneratedColumn<DateTime>(
    'pago_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    transacaoId,
    vencimento,
    pagoEm,
    valorCentavos,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pagamentos_transacao';
  @override
  VerificationContext validateIntegrity(
    Insertable<PagamentoTransacao> instance, {
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
    if (data.containsKey('transacao_id')) {
      context.handle(
        _transacaoIdMeta,
        transacaoId.isAcceptableOrUnknown(
          data['transacao_id']!,
          _transacaoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transacaoIdMeta);
    }
    if (data.containsKey('vencimento')) {
      context.handle(
        _vencimentoMeta,
        vencimento.isAcceptableOrUnknown(data['vencimento']!, _vencimentoMeta),
      );
    } else if (isInserting) {
      context.missing(_vencimentoMeta);
    }
    if (data.containsKey('pago_em')) {
      context.handle(
        _pagoEmMeta,
        pagoEm.isAcceptableOrUnknown(data['pago_em']!, _pagoEmMeta),
      );
    } else if (isInserting) {
      context.missing(_pagoEmMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PagamentoTransacao map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PagamentoTransacao(
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
      transacaoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transacao_id'],
      )!,
      vencimento: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vencimento'],
      )!,
      pagoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}pago_em'],
      )!,
      valorCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valor_centavos'],
      )!,
    );
  }

  @override
  $PagamentosTransacaoTable createAlias(String alias) {
    return $PagamentosTransacaoTable(attachedDatabase, alias);
  }
}

class PagamentoTransacao extends DataClass
    implements Insertable<PagamentoTransacao> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? apagadoEm;
  final String transacaoId;

  /// "aaaa-mm-dd" do vencimento da ocorrência, no fuso do aparelho.
  final String vencimento;
  final DateTime pagoEm;

  /// Valor pago nesta ocorrência (editar a regra depois não muda o passado).
  final int valorCentavos;
  const PagamentoTransacao({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.apagadoEm,
    required this.transacaoId,
    required this.vencimento,
    required this.pagoEm,
    required this.valorCentavos,
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
    map['transacao_id'] = Variable<String>(transacaoId);
    map['vencimento'] = Variable<String>(vencimento);
    map['pago_em'] = Variable<DateTime>(pagoEm);
    map['valor_centavos'] = Variable<int>(valorCentavos);
    return map;
  }

  PagamentosTransacaoCompanion toCompanion(bool nullToAbsent) {
    return PagamentosTransacaoCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      apagadoEm: apagadoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(apagadoEm),
      transacaoId: Value(transacaoId),
      vencimento: Value(vencimento),
      pagoEm: Value(pagoEm),
      valorCentavos: Value(valorCentavos),
    );
  }

  factory PagamentoTransacao.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PagamentoTransacao(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      apagadoEm: serializer.fromJson<DateTime?>(json['apagadoEm']),
      transacaoId: serializer.fromJson<String>(json['transacaoId']),
      vencimento: serializer.fromJson<String>(json['vencimento']),
      pagoEm: serializer.fromJson<DateTime>(json['pagoEm']),
      valorCentavos: serializer.fromJson<int>(json['valorCentavos']),
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
      'transacaoId': serializer.toJson<String>(transacaoId),
      'vencimento': serializer.toJson<String>(vencimento),
      'pagoEm': serializer.toJson<DateTime>(pagoEm),
      'valorCentavos': serializer.toJson<int>(valorCentavos),
    };
  }

  PagamentoTransacao copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> apagadoEm = const Value.absent(),
    String? transacaoId,
    String? vencimento,
    DateTime? pagoEm,
    int? valorCentavos,
  }) => PagamentoTransacao(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    apagadoEm: apagadoEm.present ? apagadoEm.value : this.apagadoEm,
    transacaoId: transacaoId ?? this.transacaoId,
    vencimento: vencimento ?? this.vencimento,
    pagoEm: pagoEm ?? this.pagoEm,
    valorCentavos: valorCentavos ?? this.valorCentavos,
  );
  PagamentoTransacao copyWithCompanion(PagamentosTransacaoCompanion data) {
    return PagamentoTransacao(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      apagadoEm: data.apagadoEm.present ? data.apagadoEm.value : this.apagadoEm,
      transacaoId: data.transacaoId.present
          ? data.transacaoId.value
          : this.transacaoId,
      vencimento: data.vencimento.present
          ? data.vencimento.value
          : this.vencimento,
      pagoEm: data.pagoEm.present ? data.pagoEm.value : this.pagoEm,
      valorCentavos: data.valorCentavos.present
          ? data.valorCentavos.value
          : this.valorCentavos,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PagamentoTransacao(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('transacaoId: $transacaoId, ')
          ..write('vencimento: $vencimento, ')
          ..write('pagoEm: $pagoEm, ')
          ..write('valorCentavos: $valorCentavos')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    transacaoId,
    vencimento,
    pagoEm,
    valorCentavos,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PagamentoTransacao &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.apagadoEm == this.apagadoEm &&
          other.transacaoId == this.transacaoId &&
          other.vencimento == this.vencimento &&
          other.pagoEm == this.pagoEm &&
          other.valorCentavos == this.valorCentavos);
}

class PagamentosTransacaoCompanion extends UpdateCompanion<PagamentoTransacao> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> apagadoEm;
  final Value<String> transacaoId;
  final Value<String> vencimento;
  final Value<DateTime> pagoEm;
  final Value<int> valorCentavos;
  final Value<int> rowid;
  const PagamentosTransacaoCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    this.transacaoId = const Value.absent(),
    this.vencimento = const Value.absent(),
    this.pagoEm = const Value.absent(),
    this.valorCentavos = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PagamentosTransacaoCompanion.insert({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    required String transacaoId,
    required String vencimento,
    required DateTime pagoEm,
    required int valorCentavos,
    this.rowid = const Value.absent(),
  }) : transacaoId = Value(transacaoId),
       vencimento = Value(vencimento),
       pagoEm = Value(pagoEm),
       valorCentavos = Value(valorCentavos);
  static Insertable<PagamentoTransacao> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? apagadoEm,
    Expression<String>? transacaoId,
    Expression<String>? vencimento,
    Expression<DateTime>? pagoEm,
    Expression<int>? valorCentavos,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (apagadoEm != null) 'apagado_em': apagadoEm,
      if (transacaoId != null) 'transacao_id': transacaoId,
      if (vencimento != null) 'vencimento': vencimento,
      if (pagoEm != null) 'pago_em': pagoEm,
      if (valorCentavos != null) 'valor_centavos': valorCentavos,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PagamentosTransacaoCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? apagadoEm,
    Value<String>? transacaoId,
    Value<String>? vencimento,
    Value<DateTime>? pagoEm,
    Value<int>? valorCentavos,
    Value<int>? rowid,
  }) {
    return PagamentosTransacaoCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      apagadoEm: apagadoEm ?? this.apagadoEm,
      transacaoId: transacaoId ?? this.transacaoId,
      vencimento: vencimento ?? this.vencimento,
      pagoEm: pagoEm ?? this.pagoEm,
      valorCentavos: valorCentavos ?? this.valorCentavos,
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
    if (transacaoId.present) {
      map['transacao_id'] = Variable<String>(transacaoId.value);
    }
    if (vencimento.present) {
      map['vencimento'] = Variable<String>(vencimento.value);
    }
    if (pagoEm.present) {
      map['pago_em'] = Variable<DateTime>(pagoEm.value);
    }
    if (valorCentavos.present) {
      map['valor_centavos'] = Variable<int>(valorCentavos.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PagamentosTransacaoCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('transacaoId: $transacaoId, ')
          ..write('vencimento: $vencimento, ')
          ..write('pagoEm: $pagoEm, ')
          ..write('valorCentavos: $valorCentavos, ')
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
  static const VerificationMeta _despertarMeta = const VerificationMeta(
    'despertar',
  );
  @override
  late final GeneratedColumn<bool> despertar = GeneratedColumn<bool>(
    'despertar',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("despertar" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    despertar,
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
    if (data.containsKey('despertar')) {
      context.handle(
        _despertarMeta,
        despertar.isAcceptableOrUnknown(data['despertar']!, _despertarMeta),
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
      despertar: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}despertar'],
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

  /// "Me despertar": no Android toca como despertador (tela cheia, som de
  /// alarme que repete, mesmo no silencioso). Nos outros, aviso comum.
  final bool despertar;

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
    required this.despertar,
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
    map['despertar'] = Variable<bool>(despertar);
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
      despertar: Value(despertar),
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
      despertar: serializer.fromJson<bool>(json['despertar']),
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
      'despertar': serializer.toJson<bool>(despertar),
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
    bool? despertar,
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
    despertar: despertar ?? this.despertar,
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
      despertar: data.despertar.present ? data.despertar.value : this.despertar,
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
          ..write('despertar: $despertar, ')
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
    despertar,
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
          other.despertar == this.despertar &&
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
  final Value<bool> despertar;
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
    this.despertar = const Value.absent(),
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
    this.despertar = const Value.absent(),
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
    Expression<bool>? despertar,
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
      if (despertar != null) 'despertar': despertar,
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
    Value<bool>? despertar,
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
      despertar: despertar ?? this.despertar,
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
    if (despertar.present) {
      map['despertar'] = Variable<bool>(despertar.value);
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
          ..write('despertar: $despertar, ')
          ..write('itemTipo: $itemTipo, ')
          ..write('itemId: $itemId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompromissosTable extends Compromissos
    with TableInfo<$CompromissosTable, Compromisso> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompromissosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _inicioMeta = const VerificationMeta('inicio');
  @override
  late final GeneratedColumn<DateTime> inicio = GeneratedColumn<DateTime>(
    'inicio',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fimMeta = const VerificationMeta('fim');
  @override
  late final GeneratedColumn<DateTime> fim = GeneratedColumn<DateTime>(
    'fim',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diaInteiroMeta = const VerificationMeta(
    'diaInteiro',
  );
  @override
  late final GeneratedColumn<bool> diaInteiro = GeneratedColumn<bool>(
    'dia_inteiro',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dia_inteiro" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _localMeta = const VerificationMeta('local');
  @override
  late final GeneratedColumn<String> local = GeneratedColumn<String>(
    'local',
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
  static const VerificationMeta _avisoAntesMinMeta = const VerificationMeta(
    'avisoAntesMin',
  );
  @override
  late final GeneratedColumn<int> avisoAntesMin = GeneratedColumn<int>(
    'aviso_antes_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _despertarMeta = const VerificationMeta(
    'despertar',
  );
  @override
  late final GeneratedColumn<bool> despertar = GeneratedColumn<bool>(
    'despertar',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("despertar" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    titulo,
    inicio,
    fim,
    diaInteiro,
    local,
    regraRepeticao,
    avisoAntesMin,
    despertar,
    notas,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'compromissos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Compromisso> instance, {
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
    if (data.containsKey('inicio')) {
      context.handle(
        _inicioMeta,
        inicio.isAcceptableOrUnknown(data['inicio']!, _inicioMeta),
      );
    } else if (isInserting) {
      context.missing(_inicioMeta);
    }
    if (data.containsKey('fim')) {
      context.handle(
        _fimMeta,
        fim.isAcceptableOrUnknown(data['fim']!, _fimMeta),
      );
    }
    if (data.containsKey('dia_inteiro')) {
      context.handle(
        _diaInteiroMeta,
        diaInteiro.isAcceptableOrUnknown(data['dia_inteiro']!, _diaInteiroMeta),
      );
    }
    if (data.containsKey('local')) {
      context.handle(
        _localMeta,
        local.isAcceptableOrUnknown(data['local']!, _localMeta),
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
    if (data.containsKey('aviso_antes_min')) {
      context.handle(
        _avisoAntesMinMeta,
        avisoAntesMin.isAcceptableOrUnknown(
          data['aviso_antes_min']!,
          _avisoAntesMinMeta,
        ),
      );
    }
    if (data.containsKey('despertar')) {
      context.handle(
        _despertarMeta,
        despertar.isAcceptableOrUnknown(data['despertar']!, _despertarMeta),
      );
    }
    if (data.containsKey('notas')) {
      context.handle(
        _notasMeta,
        notas.isAcceptableOrUnknown(data['notas']!, _notasMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Compromisso map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Compromisso(
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
      inicio: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}inicio'],
      )!,
      fim: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fim'],
      ),
      diaInteiro: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dia_inteiro'],
      )!,
      local: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local'],
      ),
      regraRepeticao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}regra_repeticao'],
      ),
      avisoAntesMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}aviso_antes_min'],
      ),
      despertar: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}despertar'],
      )!,
      notas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notas'],
      ),
    );
  }

  @override
  $CompromissosTable createAlias(String alias) {
    return $CompromissosTable(attachedDatabase, alias);
  }
}

class Compromisso extends DataClass implements Insertable<Compromisso> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? apagadoEm;
  final String titulo;

  /// Começo (instante). No dia inteiro, a meia-noite do dia no fuso do aparelho.
  final DateTime inicio;
  final DateTime? fim;
  final bool diaInteiro;
  final String? local;
  final String? regraRepeticao;

  /// Minutos de antecedência do aviso; nulo = sem aviso.
  final int? avisoAntesMin;
  final bool despertar;
  final String? notas;
  const Compromisso({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.apagadoEm,
    required this.titulo,
    required this.inicio,
    this.fim,
    required this.diaInteiro,
    this.local,
    this.regraRepeticao,
    this.avisoAntesMin,
    required this.despertar,
    this.notas,
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
    map['inicio'] = Variable<DateTime>(inicio);
    if (!nullToAbsent || fim != null) {
      map['fim'] = Variable<DateTime>(fim);
    }
    map['dia_inteiro'] = Variable<bool>(diaInteiro);
    if (!nullToAbsent || local != null) {
      map['local'] = Variable<String>(local);
    }
    if (!nullToAbsent || regraRepeticao != null) {
      map['regra_repeticao'] = Variable<String>(regraRepeticao);
    }
    if (!nullToAbsent || avisoAntesMin != null) {
      map['aviso_antes_min'] = Variable<int>(avisoAntesMin);
    }
    map['despertar'] = Variable<bool>(despertar);
    if (!nullToAbsent || notas != null) {
      map['notas'] = Variable<String>(notas);
    }
    return map;
  }

  CompromissosCompanion toCompanion(bool nullToAbsent) {
    return CompromissosCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      apagadoEm: apagadoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(apagadoEm),
      titulo: Value(titulo),
      inicio: Value(inicio),
      fim: fim == null && nullToAbsent ? const Value.absent() : Value(fim),
      diaInteiro: Value(diaInteiro),
      local: local == null && nullToAbsent
          ? const Value.absent()
          : Value(local),
      regraRepeticao: regraRepeticao == null && nullToAbsent
          ? const Value.absent()
          : Value(regraRepeticao),
      avisoAntesMin: avisoAntesMin == null && nullToAbsent
          ? const Value.absent()
          : Value(avisoAntesMin),
      despertar: Value(despertar),
      notas: notas == null && nullToAbsent
          ? const Value.absent()
          : Value(notas),
    );
  }

  factory Compromisso.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Compromisso(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      apagadoEm: serializer.fromJson<DateTime?>(json['apagadoEm']),
      titulo: serializer.fromJson<String>(json['titulo']),
      inicio: serializer.fromJson<DateTime>(json['inicio']),
      fim: serializer.fromJson<DateTime?>(json['fim']),
      diaInteiro: serializer.fromJson<bool>(json['diaInteiro']),
      local: serializer.fromJson<String?>(json['local']),
      regraRepeticao: serializer.fromJson<String?>(json['regraRepeticao']),
      avisoAntesMin: serializer.fromJson<int?>(json['avisoAntesMin']),
      despertar: serializer.fromJson<bool>(json['despertar']),
      notas: serializer.fromJson<String?>(json['notas']),
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
      'inicio': serializer.toJson<DateTime>(inicio),
      'fim': serializer.toJson<DateTime?>(fim),
      'diaInteiro': serializer.toJson<bool>(diaInteiro),
      'local': serializer.toJson<String?>(local),
      'regraRepeticao': serializer.toJson<String?>(regraRepeticao),
      'avisoAntesMin': serializer.toJson<int?>(avisoAntesMin),
      'despertar': serializer.toJson<bool>(despertar),
      'notas': serializer.toJson<String?>(notas),
    };
  }

  Compromisso copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> apagadoEm = const Value.absent(),
    String? titulo,
    DateTime? inicio,
    Value<DateTime?> fim = const Value.absent(),
    bool? diaInteiro,
    Value<String?> local = const Value.absent(),
    Value<String?> regraRepeticao = const Value.absent(),
    Value<int?> avisoAntesMin = const Value.absent(),
    bool? despertar,
    Value<String?> notas = const Value.absent(),
  }) => Compromisso(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    apagadoEm: apagadoEm.present ? apagadoEm.value : this.apagadoEm,
    titulo: titulo ?? this.titulo,
    inicio: inicio ?? this.inicio,
    fim: fim.present ? fim.value : this.fim,
    diaInteiro: diaInteiro ?? this.diaInteiro,
    local: local.present ? local.value : this.local,
    regraRepeticao: regraRepeticao.present
        ? regraRepeticao.value
        : this.regraRepeticao,
    avisoAntesMin: avisoAntesMin.present
        ? avisoAntesMin.value
        : this.avisoAntesMin,
    despertar: despertar ?? this.despertar,
    notas: notas.present ? notas.value : this.notas,
  );
  Compromisso copyWithCompanion(CompromissosCompanion data) {
    return Compromisso(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      apagadoEm: data.apagadoEm.present ? data.apagadoEm.value : this.apagadoEm,
      titulo: data.titulo.present ? data.titulo.value : this.titulo,
      inicio: data.inicio.present ? data.inicio.value : this.inicio,
      fim: data.fim.present ? data.fim.value : this.fim,
      diaInteiro: data.diaInteiro.present
          ? data.diaInteiro.value
          : this.diaInteiro,
      local: data.local.present ? data.local.value : this.local,
      regraRepeticao: data.regraRepeticao.present
          ? data.regraRepeticao.value
          : this.regraRepeticao,
      avisoAntesMin: data.avisoAntesMin.present
          ? data.avisoAntesMin.value
          : this.avisoAntesMin,
      despertar: data.despertar.present ? data.despertar.value : this.despertar,
      notas: data.notas.present ? data.notas.value : this.notas,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Compromisso(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('titulo: $titulo, ')
          ..write('inicio: $inicio, ')
          ..write('fim: $fim, ')
          ..write('diaInteiro: $diaInteiro, ')
          ..write('local: $local, ')
          ..write('regraRepeticao: $regraRepeticao, ')
          ..write('avisoAntesMin: $avisoAntesMin, ')
          ..write('despertar: $despertar, ')
          ..write('notas: $notas')
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
    inicio,
    fim,
    diaInteiro,
    local,
    regraRepeticao,
    avisoAntesMin,
    despertar,
    notas,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Compromisso &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.apagadoEm == this.apagadoEm &&
          other.titulo == this.titulo &&
          other.inicio == this.inicio &&
          other.fim == this.fim &&
          other.diaInteiro == this.diaInteiro &&
          other.local == this.local &&
          other.regraRepeticao == this.regraRepeticao &&
          other.avisoAntesMin == this.avisoAntesMin &&
          other.despertar == this.despertar &&
          other.notas == this.notas);
}

class CompromissosCompanion extends UpdateCompanion<Compromisso> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> apagadoEm;
  final Value<String> titulo;
  final Value<DateTime> inicio;
  final Value<DateTime?> fim;
  final Value<bool> diaInteiro;
  final Value<String?> local;
  final Value<String?> regraRepeticao;
  final Value<int?> avisoAntesMin;
  final Value<bool> despertar;
  final Value<String?> notas;
  final Value<int> rowid;
  const CompromissosCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    this.titulo = const Value.absent(),
    this.inicio = const Value.absent(),
    this.fim = const Value.absent(),
    this.diaInteiro = const Value.absent(),
    this.local = const Value.absent(),
    this.regraRepeticao = const Value.absent(),
    this.avisoAntesMin = const Value.absent(),
    this.despertar = const Value.absent(),
    this.notas = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompromissosCompanion.insert({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    required String titulo,
    required DateTime inicio,
    this.fim = const Value.absent(),
    this.diaInteiro = const Value.absent(),
    this.local = const Value.absent(),
    this.regraRepeticao = const Value.absent(),
    this.avisoAntesMin = const Value.absent(),
    this.despertar = const Value.absent(),
    this.notas = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : titulo = Value(titulo),
       inicio = Value(inicio);
  static Insertable<Compromisso> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? apagadoEm,
    Expression<String>? titulo,
    Expression<DateTime>? inicio,
    Expression<DateTime>? fim,
    Expression<bool>? diaInteiro,
    Expression<String>? local,
    Expression<String>? regraRepeticao,
    Expression<int>? avisoAntesMin,
    Expression<bool>? despertar,
    Expression<String>? notas,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (apagadoEm != null) 'apagado_em': apagadoEm,
      if (titulo != null) 'titulo': titulo,
      if (inicio != null) 'inicio': inicio,
      if (fim != null) 'fim': fim,
      if (diaInteiro != null) 'dia_inteiro': diaInteiro,
      if (local != null) 'local': local,
      if (regraRepeticao != null) 'regra_repeticao': regraRepeticao,
      if (avisoAntesMin != null) 'aviso_antes_min': avisoAntesMin,
      if (despertar != null) 'despertar': despertar,
      if (notas != null) 'notas': notas,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompromissosCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? apagadoEm,
    Value<String>? titulo,
    Value<DateTime>? inicio,
    Value<DateTime?>? fim,
    Value<bool>? diaInteiro,
    Value<String?>? local,
    Value<String?>? regraRepeticao,
    Value<int?>? avisoAntesMin,
    Value<bool>? despertar,
    Value<String?>? notas,
    Value<int>? rowid,
  }) {
    return CompromissosCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      apagadoEm: apagadoEm ?? this.apagadoEm,
      titulo: titulo ?? this.titulo,
      inicio: inicio ?? this.inicio,
      fim: fim ?? this.fim,
      diaInteiro: diaInteiro ?? this.diaInteiro,
      local: local ?? this.local,
      regraRepeticao: regraRepeticao ?? this.regraRepeticao,
      avisoAntesMin: avisoAntesMin ?? this.avisoAntesMin,
      despertar: despertar ?? this.despertar,
      notas: notas ?? this.notas,
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
    if (inicio.present) {
      map['inicio'] = Variable<DateTime>(inicio.value);
    }
    if (fim.present) {
      map['fim'] = Variable<DateTime>(fim.value);
    }
    if (diaInteiro.present) {
      map['dia_inteiro'] = Variable<bool>(diaInteiro.value);
    }
    if (local.present) {
      map['local'] = Variable<String>(local.value);
    }
    if (regraRepeticao.present) {
      map['regra_repeticao'] = Variable<String>(regraRepeticao.value);
    }
    if (avisoAntesMin.present) {
      map['aviso_antes_min'] = Variable<int>(avisoAntesMin.value);
    }
    if (despertar.present) {
      map['despertar'] = Variable<bool>(despertar.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompromissosCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('titulo: $titulo, ')
          ..write('inicio: $inicio, ')
          ..write('fim: $fim, ')
          ..write('diaInteiro: $diaInteiro, ')
          ..write('local: $local, ')
          ..write('regraRepeticao: $regraRepeticao, ')
          ..write('avisoAntesMin: $avisoAntesMin, ')
          ..write('despertar: $despertar, ')
          ..write('notas: $notas, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciciosTable extends Exercicios
    with TableInfo<$ExerciciosTable, Exercicio> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciciosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _grupoMeta = const VerificationMeta('grupo');
  @override
  late final GeneratedColumn<String> grupo = GeneratedColumn<String>(
    'grupo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _midiaMeta = const VerificationMeta('midia');
  @override
  late final GeneratedColumn<String> midia = GeneratedColumn<String>(
    'midia',
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
    nome,
    grupo,
    midia,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercicios';
  @override
  VerificationContext validateIntegrity(
    Insertable<Exercicio> instance, {
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
    if (data.containsKey('grupo')) {
      context.handle(
        _grupoMeta,
        grupo.isAcceptableOrUnknown(data['grupo']!, _grupoMeta),
      );
    }
    if (data.containsKey('midia')) {
      context.handle(
        _midiaMeta,
        midia.isAcceptableOrUnknown(data['midia']!, _midiaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exercicio map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exercicio(
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
      grupo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grupo'],
      ),
      midia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}midia'],
      ),
    );
  }

  @override
  $ExerciciosTable createAlias(String alias) {
    return $ExerciciosTable(attachedDatabase, alias);
  }
}

class Exercicio extends DataClass implements Insertable<Exercicio> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? apagadoEm;
  final String nome;
  final String? grupo;
  final String? midia;
  const Exercicio({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.apagadoEm,
    required this.nome,
    this.grupo,
    this.midia,
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
    if (!nullToAbsent || grupo != null) {
      map['grupo'] = Variable<String>(grupo);
    }
    if (!nullToAbsent || midia != null) {
      map['midia'] = Variable<String>(midia);
    }
    return map;
  }

  ExerciciosCompanion toCompanion(bool nullToAbsent) {
    return ExerciciosCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      apagadoEm: apagadoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(apagadoEm),
      nome: Value(nome),
      grupo: grupo == null && nullToAbsent
          ? const Value.absent()
          : Value(grupo),
      midia: midia == null && nullToAbsent
          ? const Value.absent()
          : Value(midia),
    );
  }

  factory Exercicio.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exercicio(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      apagadoEm: serializer.fromJson<DateTime?>(json['apagadoEm']),
      nome: serializer.fromJson<String>(json['nome']),
      grupo: serializer.fromJson<String?>(json['grupo']),
      midia: serializer.fromJson<String?>(json['midia']),
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
      'grupo': serializer.toJson<String?>(grupo),
      'midia': serializer.toJson<String?>(midia),
    };
  }

  Exercicio copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> apagadoEm = const Value.absent(),
    String? nome,
    Value<String?> grupo = const Value.absent(),
    Value<String?> midia = const Value.absent(),
  }) => Exercicio(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    apagadoEm: apagadoEm.present ? apagadoEm.value : this.apagadoEm,
    nome: nome ?? this.nome,
    grupo: grupo.present ? grupo.value : this.grupo,
    midia: midia.present ? midia.value : this.midia,
  );
  Exercicio copyWithCompanion(ExerciciosCompanion data) {
    return Exercicio(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      apagadoEm: data.apagadoEm.present ? data.apagadoEm.value : this.apagadoEm,
      nome: data.nome.present ? data.nome.value : this.nome,
      grupo: data.grupo.present ? data.grupo.value : this.grupo,
      midia: data.midia.present ? data.midia.value : this.midia,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exercicio(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('nome: $nome, ')
          ..write('grupo: $grupo, ')
          ..write('midia: $midia')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, criadoEm, atualizadoEm, apagadoEm, nome, grupo, midia);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercicio &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.apagadoEm == this.apagadoEm &&
          other.nome == this.nome &&
          other.grupo == this.grupo &&
          other.midia == this.midia);
}

class ExerciciosCompanion extends UpdateCompanion<Exercicio> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> apagadoEm;
  final Value<String> nome;
  final Value<String?> grupo;
  final Value<String?> midia;
  final Value<int> rowid;
  const ExerciciosCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    this.nome = const Value.absent(),
    this.grupo = const Value.absent(),
    this.midia = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciciosCompanion.insert({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    required String nome,
    this.grupo = const Value.absent(),
    this.midia = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : nome = Value(nome);
  static Insertable<Exercicio> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? apagadoEm,
    Expression<String>? nome,
    Expression<String>? grupo,
    Expression<String>? midia,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (apagadoEm != null) 'apagado_em': apagadoEm,
      if (nome != null) 'nome': nome,
      if (grupo != null) 'grupo': grupo,
      if (midia != null) 'midia': midia,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciciosCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? apagadoEm,
    Value<String>? nome,
    Value<String?>? grupo,
    Value<String?>? midia,
    Value<int>? rowid,
  }) {
    return ExerciciosCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      apagadoEm: apagadoEm ?? this.apagadoEm,
      nome: nome ?? this.nome,
      grupo: grupo ?? this.grupo,
      midia: midia ?? this.midia,
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
    if (grupo.present) {
      map['grupo'] = Variable<String>(grupo.value);
    }
    if (midia.present) {
      map['midia'] = Variable<String>(midia.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciciosCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('nome: $nome, ')
          ..write('grupo: $grupo, ')
          ..write('midia: $midia, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TreinosTable extends Treinos with TableInfo<$TreinosTable, Treino> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TreinosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _focoMeta = const VerificationMeta('foco');
  @override
  late final GeneratedColumn<String> foco = GeneratedColumn<String>(
    'foco',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
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
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ordemMeta = const VerificationMeta('ordem');
  @override
  late final GeneratedColumn<int> ordem = GeneratedColumn<int>(
    'ordem',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    nome,
    foco,
    diasSemana,
    ordem,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'treinos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Treino> instance, {
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
    if (data.containsKey('foco')) {
      context.handle(
        _focoMeta,
        foco.isAcceptableOrUnknown(data['foco']!, _focoMeta),
      );
    }
    if (data.containsKey('dias_semana')) {
      context.handle(
        _diasSemanaMeta,
        diasSemana.isAcceptableOrUnknown(data['dias_semana']!, _diasSemanaMeta),
      );
    }
    if (data.containsKey('ordem')) {
      context.handle(
        _ordemMeta,
        ordem.isAcceptableOrUnknown(data['ordem']!, _ordemMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Treino map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Treino(
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
      foco: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foco'],
      ),
      diasSemana: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dias_semana'],
      )!,
      ordem: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordem'],
      )!,
    );
  }

  @override
  $TreinosTable createAlias(String alias) {
    return $TreinosTable(attachedDatabase, alias);
  }
}

class Treino extends DataClass implements Insertable<Treino> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? apagadoEm;
  final String nome;
  final String? foco;

  /// Bits de segunda (1) a domingo (64), como em Habitos. 0 = sem dia fixo.
  final int diasSemana;
  final int ordem;
  const Treino({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.apagadoEm,
    required this.nome,
    this.foco,
    required this.diasSemana,
    required this.ordem,
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
    if (!nullToAbsent || foco != null) {
      map['foco'] = Variable<String>(foco);
    }
    map['dias_semana'] = Variable<int>(diasSemana);
    map['ordem'] = Variable<int>(ordem);
    return map;
  }

  TreinosCompanion toCompanion(bool nullToAbsent) {
    return TreinosCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      apagadoEm: apagadoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(apagadoEm),
      nome: Value(nome),
      foco: foco == null && nullToAbsent ? const Value.absent() : Value(foco),
      diasSemana: Value(diasSemana),
      ordem: Value(ordem),
    );
  }

  factory Treino.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Treino(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      apagadoEm: serializer.fromJson<DateTime?>(json['apagadoEm']),
      nome: serializer.fromJson<String>(json['nome']),
      foco: serializer.fromJson<String?>(json['foco']),
      diasSemana: serializer.fromJson<int>(json['diasSemana']),
      ordem: serializer.fromJson<int>(json['ordem']),
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
      'foco': serializer.toJson<String?>(foco),
      'diasSemana': serializer.toJson<int>(diasSemana),
      'ordem': serializer.toJson<int>(ordem),
    };
  }

  Treino copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> apagadoEm = const Value.absent(),
    String? nome,
    Value<String?> foco = const Value.absent(),
    int? diasSemana,
    int? ordem,
  }) => Treino(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    apagadoEm: apagadoEm.present ? apagadoEm.value : this.apagadoEm,
    nome: nome ?? this.nome,
    foco: foco.present ? foco.value : this.foco,
    diasSemana: diasSemana ?? this.diasSemana,
    ordem: ordem ?? this.ordem,
  );
  Treino copyWithCompanion(TreinosCompanion data) {
    return Treino(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      apagadoEm: data.apagadoEm.present ? data.apagadoEm.value : this.apagadoEm,
      nome: data.nome.present ? data.nome.value : this.nome,
      foco: data.foco.present ? data.foco.value : this.foco,
      diasSemana: data.diasSemana.present
          ? data.diasSemana.value
          : this.diasSemana,
      ordem: data.ordem.present ? data.ordem.value : this.ordem,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Treino(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('nome: $nome, ')
          ..write('foco: $foco, ')
          ..write('diasSemana: $diasSemana, ')
          ..write('ordem: $ordem')
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
    foco,
    diasSemana,
    ordem,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Treino &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.apagadoEm == this.apagadoEm &&
          other.nome == this.nome &&
          other.foco == this.foco &&
          other.diasSemana == this.diasSemana &&
          other.ordem == this.ordem);
}

class TreinosCompanion extends UpdateCompanion<Treino> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> apagadoEm;
  final Value<String> nome;
  final Value<String?> foco;
  final Value<int> diasSemana;
  final Value<int> ordem;
  final Value<int> rowid;
  const TreinosCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    this.nome = const Value.absent(),
    this.foco = const Value.absent(),
    this.diasSemana = const Value.absent(),
    this.ordem = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TreinosCompanion.insert({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    required String nome,
    this.foco = const Value.absent(),
    this.diasSemana = const Value.absent(),
    this.ordem = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : nome = Value(nome);
  static Insertable<Treino> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? apagadoEm,
    Expression<String>? nome,
    Expression<String>? foco,
    Expression<int>? diasSemana,
    Expression<int>? ordem,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (apagadoEm != null) 'apagado_em': apagadoEm,
      if (nome != null) 'nome': nome,
      if (foco != null) 'foco': foco,
      if (diasSemana != null) 'dias_semana': diasSemana,
      if (ordem != null) 'ordem': ordem,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TreinosCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? apagadoEm,
    Value<String>? nome,
    Value<String?>? foco,
    Value<int>? diasSemana,
    Value<int>? ordem,
    Value<int>? rowid,
  }) {
    return TreinosCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      apagadoEm: apagadoEm ?? this.apagadoEm,
      nome: nome ?? this.nome,
      foco: foco ?? this.foco,
      diasSemana: diasSemana ?? this.diasSemana,
      ordem: ordem ?? this.ordem,
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
    if (foco.present) {
      map['foco'] = Variable<String>(foco.value);
    }
    if (diasSemana.present) {
      map['dias_semana'] = Variable<int>(diasSemana.value);
    }
    if (ordem.present) {
      map['ordem'] = Variable<int>(ordem.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TreinosCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('nome: $nome, ')
          ..write('foco: $foco, ')
          ..write('diasSemana: $diasSemana, ')
          ..write('ordem: $ordem, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItensTreinoTable extends ItensTreino
    with TableInfo<$ItensTreinoTable, ItemTreino> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItensTreinoTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _treinoIdMeta = const VerificationMeta(
    'treinoId',
  );
  @override
  late final GeneratedColumn<String> treinoId = GeneratedColumn<String>(
    'treino_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES treinos (id)',
    ),
  );
  static const VerificationMeta _exercicioIdMeta = const VerificationMeta(
    'exercicioId',
  );
  @override
  late final GeneratedColumn<String> exercicioId = GeneratedColumn<String>(
    'exercicio_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercicios (id)',
    ),
  );
  static const VerificationMeta _ordemMeta = const VerificationMeta('ordem');
  @override
  late final GeneratedColumn<int> ordem = GeneratedColumn<int>(
    'ordem',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _seriesMeta = const VerificationMeta('series');
  @override
  late final GeneratedColumn<int> series = GeneratedColumn<int>(
    'series',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _repeticoesMeta = const VerificationMeta(
    'repeticoes',
  );
  @override
  late final GeneratedColumn<int> repeticoes = GeneratedColumn<int>(
    'repeticoes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _cargaInicialMeta = const VerificationMeta(
    'cargaInicial',
  );
  @override
  late final GeneratedColumn<double> cargaInicial = GeneratedColumn<double>(
    'carga_inicial',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    treinoId,
    exercicioId,
    ordem,
    series,
    repeticoes,
    cargaInicial,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'itens_treino';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemTreino> instance, {
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
    if (data.containsKey('treino_id')) {
      context.handle(
        _treinoIdMeta,
        treinoId.isAcceptableOrUnknown(data['treino_id']!, _treinoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_treinoIdMeta);
    }
    if (data.containsKey('exercicio_id')) {
      context.handle(
        _exercicioIdMeta,
        exercicioId.isAcceptableOrUnknown(
          data['exercicio_id']!,
          _exercicioIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exercicioIdMeta);
    }
    if (data.containsKey('ordem')) {
      context.handle(
        _ordemMeta,
        ordem.isAcceptableOrUnknown(data['ordem']!, _ordemMeta),
      );
    }
    if (data.containsKey('series')) {
      context.handle(
        _seriesMeta,
        series.isAcceptableOrUnknown(data['series']!, _seriesMeta),
      );
    }
    if (data.containsKey('repeticoes')) {
      context.handle(
        _repeticoesMeta,
        repeticoes.isAcceptableOrUnknown(data['repeticoes']!, _repeticoesMeta),
      );
    }
    if (data.containsKey('carga_inicial')) {
      context.handle(
        _cargaInicialMeta,
        cargaInicial.isAcceptableOrUnknown(
          data['carga_inicial']!,
          _cargaInicialMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemTreino map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemTreino(
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
      treinoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}treino_id'],
      )!,
      exercicioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercicio_id'],
      )!,
      ordem: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordem'],
      )!,
      series: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}series'],
      )!,
      repeticoes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeticoes'],
      )!,
      cargaInicial: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carga_inicial'],
      ),
    );
  }

  @override
  $ItensTreinoTable createAlias(String alias) {
    return $ItensTreinoTable(attachedDatabase, alias);
  }
}

class ItemTreino extends DataClass implements Insertable<ItemTreino> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? apagadoEm;
  final String treinoId;
  final String exercicioId;
  final int ordem;
  final int series;

  /// Repetições alvo por série (a carga sobe quando todas chegam nelas).
  final int repeticoes;

  /// Carga para começar quando ainda não há histórico (kg).
  final double? cargaInicial;
  const ItemTreino({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.apagadoEm,
    required this.treinoId,
    required this.exercicioId,
    required this.ordem,
    required this.series,
    required this.repeticoes,
    this.cargaInicial,
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
    map['treino_id'] = Variable<String>(treinoId);
    map['exercicio_id'] = Variable<String>(exercicioId);
    map['ordem'] = Variable<int>(ordem);
    map['series'] = Variable<int>(series);
    map['repeticoes'] = Variable<int>(repeticoes);
    if (!nullToAbsent || cargaInicial != null) {
      map['carga_inicial'] = Variable<double>(cargaInicial);
    }
    return map;
  }

  ItensTreinoCompanion toCompanion(bool nullToAbsent) {
    return ItensTreinoCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      apagadoEm: apagadoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(apagadoEm),
      treinoId: Value(treinoId),
      exercicioId: Value(exercicioId),
      ordem: Value(ordem),
      series: Value(series),
      repeticoes: Value(repeticoes),
      cargaInicial: cargaInicial == null && nullToAbsent
          ? const Value.absent()
          : Value(cargaInicial),
    );
  }

  factory ItemTreino.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemTreino(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      apagadoEm: serializer.fromJson<DateTime?>(json['apagadoEm']),
      treinoId: serializer.fromJson<String>(json['treinoId']),
      exercicioId: serializer.fromJson<String>(json['exercicioId']),
      ordem: serializer.fromJson<int>(json['ordem']),
      series: serializer.fromJson<int>(json['series']),
      repeticoes: serializer.fromJson<int>(json['repeticoes']),
      cargaInicial: serializer.fromJson<double?>(json['cargaInicial']),
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
      'treinoId': serializer.toJson<String>(treinoId),
      'exercicioId': serializer.toJson<String>(exercicioId),
      'ordem': serializer.toJson<int>(ordem),
      'series': serializer.toJson<int>(series),
      'repeticoes': serializer.toJson<int>(repeticoes),
      'cargaInicial': serializer.toJson<double?>(cargaInicial),
    };
  }

  ItemTreino copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> apagadoEm = const Value.absent(),
    String? treinoId,
    String? exercicioId,
    int? ordem,
    int? series,
    int? repeticoes,
    Value<double?> cargaInicial = const Value.absent(),
  }) => ItemTreino(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    apagadoEm: apagadoEm.present ? apagadoEm.value : this.apagadoEm,
    treinoId: treinoId ?? this.treinoId,
    exercicioId: exercicioId ?? this.exercicioId,
    ordem: ordem ?? this.ordem,
    series: series ?? this.series,
    repeticoes: repeticoes ?? this.repeticoes,
    cargaInicial: cargaInicial.present ? cargaInicial.value : this.cargaInicial,
  );
  ItemTreino copyWithCompanion(ItensTreinoCompanion data) {
    return ItemTreino(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      apagadoEm: data.apagadoEm.present ? data.apagadoEm.value : this.apagadoEm,
      treinoId: data.treinoId.present ? data.treinoId.value : this.treinoId,
      exercicioId: data.exercicioId.present
          ? data.exercicioId.value
          : this.exercicioId,
      ordem: data.ordem.present ? data.ordem.value : this.ordem,
      series: data.series.present ? data.series.value : this.series,
      repeticoes: data.repeticoes.present
          ? data.repeticoes.value
          : this.repeticoes,
      cargaInicial: data.cargaInicial.present
          ? data.cargaInicial.value
          : this.cargaInicial,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemTreino(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('treinoId: $treinoId, ')
          ..write('exercicioId: $exercicioId, ')
          ..write('ordem: $ordem, ')
          ..write('series: $series, ')
          ..write('repeticoes: $repeticoes, ')
          ..write('cargaInicial: $cargaInicial')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    treinoId,
    exercicioId,
    ordem,
    series,
    repeticoes,
    cargaInicial,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemTreino &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.apagadoEm == this.apagadoEm &&
          other.treinoId == this.treinoId &&
          other.exercicioId == this.exercicioId &&
          other.ordem == this.ordem &&
          other.series == this.series &&
          other.repeticoes == this.repeticoes &&
          other.cargaInicial == this.cargaInicial);
}

class ItensTreinoCompanion extends UpdateCompanion<ItemTreino> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> apagadoEm;
  final Value<String> treinoId;
  final Value<String> exercicioId;
  final Value<int> ordem;
  final Value<int> series;
  final Value<int> repeticoes;
  final Value<double?> cargaInicial;
  final Value<int> rowid;
  const ItensTreinoCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    this.treinoId = const Value.absent(),
    this.exercicioId = const Value.absent(),
    this.ordem = const Value.absent(),
    this.series = const Value.absent(),
    this.repeticoes = const Value.absent(),
    this.cargaInicial = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItensTreinoCompanion.insert({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    required String treinoId,
    required String exercicioId,
    this.ordem = const Value.absent(),
    this.series = const Value.absent(),
    this.repeticoes = const Value.absent(),
    this.cargaInicial = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : treinoId = Value(treinoId),
       exercicioId = Value(exercicioId);
  static Insertable<ItemTreino> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? apagadoEm,
    Expression<String>? treinoId,
    Expression<String>? exercicioId,
    Expression<int>? ordem,
    Expression<int>? series,
    Expression<int>? repeticoes,
    Expression<double>? cargaInicial,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (apagadoEm != null) 'apagado_em': apagadoEm,
      if (treinoId != null) 'treino_id': treinoId,
      if (exercicioId != null) 'exercicio_id': exercicioId,
      if (ordem != null) 'ordem': ordem,
      if (series != null) 'series': series,
      if (repeticoes != null) 'repeticoes': repeticoes,
      if (cargaInicial != null) 'carga_inicial': cargaInicial,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItensTreinoCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? apagadoEm,
    Value<String>? treinoId,
    Value<String>? exercicioId,
    Value<int>? ordem,
    Value<int>? series,
    Value<int>? repeticoes,
    Value<double?>? cargaInicial,
    Value<int>? rowid,
  }) {
    return ItensTreinoCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      apagadoEm: apagadoEm ?? this.apagadoEm,
      treinoId: treinoId ?? this.treinoId,
      exercicioId: exercicioId ?? this.exercicioId,
      ordem: ordem ?? this.ordem,
      series: series ?? this.series,
      repeticoes: repeticoes ?? this.repeticoes,
      cargaInicial: cargaInicial ?? this.cargaInicial,
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
    if (treinoId.present) {
      map['treino_id'] = Variable<String>(treinoId.value);
    }
    if (exercicioId.present) {
      map['exercicio_id'] = Variable<String>(exercicioId.value);
    }
    if (ordem.present) {
      map['ordem'] = Variable<int>(ordem.value);
    }
    if (series.present) {
      map['series'] = Variable<int>(series.value);
    }
    if (repeticoes.present) {
      map['repeticoes'] = Variable<int>(repeticoes.value);
    }
    if (cargaInicial.present) {
      map['carga_inicial'] = Variable<double>(cargaInicial.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItensTreinoCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('treinoId: $treinoId, ')
          ..write('exercicioId: $exercicioId, ')
          ..write('ordem: $ordem, ')
          ..write('series: $series, ')
          ..write('repeticoes: $repeticoes, ')
          ..write('cargaInicial: $cargaInicial, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessoesTreinoTable extends SessoesTreino
    with TableInfo<$SessoesTreinoTable, SessaoTreino> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessoesTreinoTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _treinoIdMeta = const VerificationMeta(
    'treinoId',
  );
  @override
  late final GeneratedColumn<String> treinoId = GeneratedColumn<String>(
    'treino_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES treinos (id)',
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
  static const VerificationMeta _inicioMeta = const VerificationMeta('inicio');
  @override
  late final GeneratedColumn<DateTime> inicio = GeneratedColumn<DateTime>(
    'inicio',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fimMeta = const VerificationMeta('fim');
  @override
  late final GeneratedColumn<DateTime> fim = GeneratedColumn<DateTime>(
    'fim',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    treinoId,
    dia,
    inicio,
    fim,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessoes_treino';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessaoTreino> instance, {
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
    if (data.containsKey('treino_id')) {
      context.handle(
        _treinoIdMeta,
        treinoId.isAcceptableOrUnknown(data['treino_id']!, _treinoIdMeta),
      );
    }
    if (data.containsKey('dia')) {
      context.handle(
        _diaMeta,
        dia.isAcceptableOrUnknown(data['dia']!, _diaMeta),
      );
    } else if (isInserting) {
      context.missing(_diaMeta);
    }
    if (data.containsKey('inicio')) {
      context.handle(
        _inicioMeta,
        inicio.isAcceptableOrUnknown(data['inicio']!, _inicioMeta),
      );
    } else if (isInserting) {
      context.missing(_inicioMeta);
    }
    if (data.containsKey('fim')) {
      context.handle(
        _fimMeta,
        fim.isAcceptableOrUnknown(data['fim']!, _fimMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessaoTreino map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessaoTreino(
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
      treinoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}treino_id'],
      ),
      dia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dia'],
      )!,
      inicio: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}inicio'],
      )!,
      fim: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fim'],
      ),
    );
  }

  @override
  $SessoesTreinoTable createAlias(String alias) {
    return $SessoesTreinoTable(attachedDatabase, alias);
  }
}

class SessaoTreino extends DataClass implements Insertable<SessaoTreino> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? apagadoEm;
  final String? treinoId;

  /// "aaaa-mm-dd" no fuso do aparelho.
  final String dia;
  final DateTime inicio;
  final DateTime? fim;
  const SessaoTreino({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.apagadoEm,
    this.treinoId,
    required this.dia,
    required this.inicio,
    this.fim,
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
    if (!nullToAbsent || treinoId != null) {
      map['treino_id'] = Variable<String>(treinoId);
    }
    map['dia'] = Variable<String>(dia);
    map['inicio'] = Variable<DateTime>(inicio);
    if (!nullToAbsent || fim != null) {
      map['fim'] = Variable<DateTime>(fim);
    }
    return map;
  }

  SessoesTreinoCompanion toCompanion(bool nullToAbsent) {
    return SessoesTreinoCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      apagadoEm: apagadoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(apagadoEm),
      treinoId: treinoId == null && nullToAbsent
          ? const Value.absent()
          : Value(treinoId),
      dia: Value(dia),
      inicio: Value(inicio),
      fim: fim == null && nullToAbsent ? const Value.absent() : Value(fim),
    );
  }

  factory SessaoTreino.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessaoTreino(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      apagadoEm: serializer.fromJson<DateTime?>(json['apagadoEm']),
      treinoId: serializer.fromJson<String?>(json['treinoId']),
      dia: serializer.fromJson<String>(json['dia']),
      inicio: serializer.fromJson<DateTime>(json['inicio']),
      fim: serializer.fromJson<DateTime?>(json['fim']),
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
      'treinoId': serializer.toJson<String?>(treinoId),
      'dia': serializer.toJson<String>(dia),
      'inicio': serializer.toJson<DateTime>(inicio),
      'fim': serializer.toJson<DateTime?>(fim),
    };
  }

  SessaoTreino copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> apagadoEm = const Value.absent(),
    Value<String?> treinoId = const Value.absent(),
    String? dia,
    DateTime? inicio,
    Value<DateTime?> fim = const Value.absent(),
  }) => SessaoTreino(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    apagadoEm: apagadoEm.present ? apagadoEm.value : this.apagadoEm,
    treinoId: treinoId.present ? treinoId.value : this.treinoId,
    dia: dia ?? this.dia,
    inicio: inicio ?? this.inicio,
    fim: fim.present ? fim.value : this.fim,
  );
  SessaoTreino copyWithCompanion(SessoesTreinoCompanion data) {
    return SessaoTreino(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      apagadoEm: data.apagadoEm.present ? data.apagadoEm.value : this.apagadoEm,
      treinoId: data.treinoId.present ? data.treinoId.value : this.treinoId,
      dia: data.dia.present ? data.dia.value : this.dia,
      inicio: data.inicio.present ? data.inicio.value : this.inicio,
      fim: data.fim.present ? data.fim.value : this.fim,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessaoTreino(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('treinoId: $treinoId, ')
          ..write('dia: $dia, ')
          ..write('inicio: $inicio, ')
          ..write('fim: $fim')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    treinoId,
    dia,
    inicio,
    fim,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessaoTreino &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.apagadoEm == this.apagadoEm &&
          other.treinoId == this.treinoId &&
          other.dia == this.dia &&
          other.inicio == this.inicio &&
          other.fim == this.fim);
}

class SessoesTreinoCompanion extends UpdateCompanion<SessaoTreino> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> apagadoEm;
  final Value<String?> treinoId;
  final Value<String> dia;
  final Value<DateTime> inicio;
  final Value<DateTime?> fim;
  final Value<int> rowid;
  const SessoesTreinoCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    this.treinoId = const Value.absent(),
    this.dia = const Value.absent(),
    this.inicio = const Value.absent(),
    this.fim = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessoesTreinoCompanion.insert({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    this.treinoId = const Value.absent(),
    required String dia,
    required DateTime inicio,
    this.fim = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : dia = Value(dia),
       inicio = Value(inicio);
  static Insertable<SessaoTreino> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? apagadoEm,
    Expression<String>? treinoId,
    Expression<String>? dia,
    Expression<DateTime>? inicio,
    Expression<DateTime>? fim,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (apagadoEm != null) 'apagado_em': apagadoEm,
      if (treinoId != null) 'treino_id': treinoId,
      if (dia != null) 'dia': dia,
      if (inicio != null) 'inicio': inicio,
      if (fim != null) 'fim': fim,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessoesTreinoCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? apagadoEm,
    Value<String?>? treinoId,
    Value<String>? dia,
    Value<DateTime>? inicio,
    Value<DateTime?>? fim,
    Value<int>? rowid,
  }) {
    return SessoesTreinoCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      apagadoEm: apagadoEm ?? this.apagadoEm,
      treinoId: treinoId ?? this.treinoId,
      dia: dia ?? this.dia,
      inicio: inicio ?? this.inicio,
      fim: fim ?? this.fim,
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
    if (treinoId.present) {
      map['treino_id'] = Variable<String>(treinoId.value);
    }
    if (dia.present) {
      map['dia'] = Variable<String>(dia.value);
    }
    if (inicio.present) {
      map['inicio'] = Variable<DateTime>(inicio.value);
    }
    if (fim.present) {
      map['fim'] = Variable<DateTime>(fim.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessoesTreinoCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('treinoId: $treinoId, ')
          ..write('dia: $dia, ')
          ..write('inicio: $inicio, ')
          ..write('fim: $fim, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SeriesFeitasTable extends SeriesFeitas
    with TableInfo<$SeriesFeitasTable, SerieFeita> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeriesFeitasTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessaoIdMeta = const VerificationMeta(
    'sessaoId',
  );
  @override
  late final GeneratedColumn<String> sessaoId = GeneratedColumn<String>(
    'sessao_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessoes_treino (id)',
    ),
  );
  static const VerificationMeta _exercicioIdMeta = const VerificationMeta(
    'exercicioId',
  );
  @override
  late final GeneratedColumn<String> exercicioId = GeneratedColumn<String>(
    'exercicio_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercicios (id)',
    ),
  );
  static const VerificationMeta _numeroMeta = const VerificationMeta('numero');
  @override
  late final GeneratedColumn<int> numero = GeneratedColumn<int>(
    'numero',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repeticoesMeta = const VerificationMeta(
    'repeticoes',
  );
  @override
  late final GeneratedColumn<int> repeticoes = GeneratedColumn<int>(
    'repeticoes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cargaKgMeta = const VerificationMeta(
    'cargaKg',
  );
  @override
  late final GeneratedColumn<double> cargaKg = GeneratedColumn<double>(
    'carga_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    sessaoId,
    exercicioId,
    numero,
    repeticoes,
    cargaKg,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'series_feitas';
  @override
  VerificationContext validateIntegrity(
    Insertable<SerieFeita> instance, {
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
    if (data.containsKey('sessao_id')) {
      context.handle(
        _sessaoIdMeta,
        sessaoId.isAcceptableOrUnknown(data['sessao_id']!, _sessaoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessaoIdMeta);
    }
    if (data.containsKey('exercicio_id')) {
      context.handle(
        _exercicioIdMeta,
        exercicioId.isAcceptableOrUnknown(
          data['exercicio_id']!,
          _exercicioIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exercicioIdMeta);
    }
    if (data.containsKey('numero')) {
      context.handle(
        _numeroMeta,
        numero.isAcceptableOrUnknown(data['numero']!, _numeroMeta),
      );
    } else if (isInserting) {
      context.missing(_numeroMeta);
    }
    if (data.containsKey('repeticoes')) {
      context.handle(
        _repeticoesMeta,
        repeticoes.isAcceptableOrUnknown(data['repeticoes']!, _repeticoesMeta),
      );
    } else if (isInserting) {
      context.missing(_repeticoesMeta);
    }
    if (data.containsKey('carga_kg')) {
      context.handle(
        _cargaKgMeta,
        cargaKg.isAcceptableOrUnknown(data['carga_kg']!, _cargaKgMeta),
      );
    } else if (isInserting) {
      context.missing(_cargaKgMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SerieFeita map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SerieFeita(
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
      sessaoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sessao_id'],
      )!,
      exercicioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercicio_id'],
      )!,
      numero: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}numero'],
      )!,
      repeticoes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeticoes'],
      )!,
      cargaKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carga_kg'],
      )!,
    );
  }

  @override
  $SeriesFeitasTable createAlias(String alias) {
    return $SeriesFeitasTable(attachedDatabase, alias);
  }
}

class SerieFeita extends DataClass implements Insertable<SerieFeita> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? apagadoEm;
  final String sessaoId;
  final String exercicioId;
  final int numero;
  final int repeticoes;
  final double cargaKg;
  const SerieFeita({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.apagadoEm,
    required this.sessaoId,
    required this.exercicioId,
    required this.numero,
    required this.repeticoes,
    required this.cargaKg,
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
    map['sessao_id'] = Variable<String>(sessaoId);
    map['exercicio_id'] = Variable<String>(exercicioId);
    map['numero'] = Variable<int>(numero);
    map['repeticoes'] = Variable<int>(repeticoes);
    map['carga_kg'] = Variable<double>(cargaKg);
    return map;
  }

  SeriesFeitasCompanion toCompanion(bool nullToAbsent) {
    return SeriesFeitasCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      apagadoEm: apagadoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(apagadoEm),
      sessaoId: Value(sessaoId),
      exercicioId: Value(exercicioId),
      numero: Value(numero),
      repeticoes: Value(repeticoes),
      cargaKg: Value(cargaKg),
    );
  }

  factory SerieFeita.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SerieFeita(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      apagadoEm: serializer.fromJson<DateTime?>(json['apagadoEm']),
      sessaoId: serializer.fromJson<String>(json['sessaoId']),
      exercicioId: serializer.fromJson<String>(json['exercicioId']),
      numero: serializer.fromJson<int>(json['numero']),
      repeticoes: serializer.fromJson<int>(json['repeticoes']),
      cargaKg: serializer.fromJson<double>(json['cargaKg']),
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
      'sessaoId': serializer.toJson<String>(sessaoId),
      'exercicioId': serializer.toJson<String>(exercicioId),
      'numero': serializer.toJson<int>(numero),
      'repeticoes': serializer.toJson<int>(repeticoes),
      'cargaKg': serializer.toJson<double>(cargaKg),
    };
  }

  SerieFeita copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> apagadoEm = const Value.absent(),
    String? sessaoId,
    String? exercicioId,
    int? numero,
    int? repeticoes,
    double? cargaKg,
  }) => SerieFeita(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    apagadoEm: apagadoEm.present ? apagadoEm.value : this.apagadoEm,
    sessaoId: sessaoId ?? this.sessaoId,
    exercicioId: exercicioId ?? this.exercicioId,
    numero: numero ?? this.numero,
    repeticoes: repeticoes ?? this.repeticoes,
    cargaKg: cargaKg ?? this.cargaKg,
  );
  SerieFeita copyWithCompanion(SeriesFeitasCompanion data) {
    return SerieFeita(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      apagadoEm: data.apagadoEm.present ? data.apagadoEm.value : this.apagadoEm,
      sessaoId: data.sessaoId.present ? data.sessaoId.value : this.sessaoId,
      exercicioId: data.exercicioId.present
          ? data.exercicioId.value
          : this.exercicioId,
      numero: data.numero.present ? data.numero.value : this.numero,
      repeticoes: data.repeticoes.present
          ? data.repeticoes.value
          : this.repeticoes,
      cargaKg: data.cargaKg.present ? data.cargaKg.value : this.cargaKg,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SerieFeita(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('sessaoId: $sessaoId, ')
          ..write('exercicioId: $exercicioId, ')
          ..write('numero: $numero, ')
          ..write('repeticoes: $repeticoes, ')
          ..write('cargaKg: $cargaKg')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    sessaoId,
    exercicioId,
    numero,
    repeticoes,
    cargaKg,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SerieFeita &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.apagadoEm == this.apagadoEm &&
          other.sessaoId == this.sessaoId &&
          other.exercicioId == this.exercicioId &&
          other.numero == this.numero &&
          other.repeticoes == this.repeticoes &&
          other.cargaKg == this.cargaKg);
}

class SeriesFeitasCompanion extends UpdateCompanion<SerieFeita> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> apagadoEm;
  final Value<String> sessaoId;
  final Value<String> exercicioId;
  final Value<int> numero;
  final Value<int> repeticoes;
  final Value<double> cargaKg;
  final Value<int> rowid;
  const SeriesFeitasCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    this.sessaoId = const Value.absent(),
    this.exercicioId = const Value.absent(),
    this.numero = const Value.absent(),
    this.repeticoes = const Value.absent(),
    this.cargaKg = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeriesFeitasCompanion.insert({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    required String sessaoId,
    required String exercicioId,
    required int numero,
    required int repeticoes,
    required double cargaKg,
    this.rowid = const Value.absent(),
  }) : sessaoId = Value(sessaoId),
       exercicioId = Value(exercicioId),
       numero = Value(numero),
       repeticoes = Value(repeticoes),
       cargaKg = Value(cargaKg);
  static Insertable<SerieFeita> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? apagadoEm,
    Expression<String>? sessaoId,
    Expression<String>? exercicioId,
    Expression<int>? numero,
    Expression<int>? repeticoes,
    Expression<double>? cargaKg,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (apagadoEm != null) 'apagado_em': apagadoEm,
      if (sessaoId != null) 'sessao_id': sessaoId,
      if (exercicioId != null) 'exercicio_id': exercicioId,
      if (numero != null) 'numero': numero,
      if (repeticoes != null) 'repeticoes': repeticoes,
      if (cargaKg != null) 'carga_kg': cargaKg,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeriesFeitasCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? apagadoEm,
    Value<String>? sessaoId,
    Value<String>? exercicioId,
    Value<int>? numero,
    Value<int>? repeticoes,
    Value<double>? cargaKg,
    Value<int>? rowid,
  }) {
    return SeriesFeitasCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      apagadoEm: apagadoEm ?? this.apagadoEm,
      sessaoId: sessaoId ?? this.sessaoId,
      exercicioId: exercicioId ?? this.exercicioId,
      numero: numero ?? this.numero,
      repeticoes: repeticoes ?? this.repeticoes,
      cargaKg: cargaKg ?? this.cargaKg,
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
    if (sessaoId.present) {
      map['sessao_id'] = Variable<String>(sessaoId.value);
    }
    if (exercicioId.present) {
      map['exercicio_id'] = Variable<String>(exercicioId.value);
    }
    if (numero.present) {
      map['numero'] = Variable<int>(numero.value);
    }
    if (repeticoes.present) {
      map['repeticoes'] = Variable<int>(repeticoes.value);
    }
    if (cargaKg.present) {
      map['carga_kg'] = Variable<double>(cargaKg.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeriesFeitasCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('sessaoId: $sessaoId, ')
          ..write('exercicioId: $exercicioId, ')
          ..write('numero: $numero, ')
          ..write('repeticoes: $repeticoes, ')
          ..write('cargaKg: $cargaKg, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedidasTable extends Medidas with TableInfo<$MedidasTable, Medida> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedidasTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _diaMeta = const VerificationMeta('dia');
  @override
  late final GeneratedColumn<String> dia = GeneratedColumn<String>(
    'dia',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<double> valor = GeneratedColumn<double>(
    'valor',
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    dia,
    tipo,
    valor,
    unidade,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medidas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Medida> instance, {
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
    if (data.containsKey('dia')) {
      context.handle(
        _diaMeta,
        dia.isAcceptableOrUnknown(data['dia']!, _diaMeta),
      );
    } else if (isInserting) {
      context.missing(_diaMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    if (data.containsKey('unidade')) {
      context.handle(
        _unidadeMeta,
        unidade.isAcceptableOrUnknown(data['unidade']!, _unidadeMeta),
      );
    } else if (isInserting) {
      context.missing(_unidadeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Medida map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Medida(
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
      dia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dia'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valor'],
      )!,
      unidade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unidade'],
      )!,
    );
  }

  @override
  $MedidasTable createAlias(String alias) {
    return $MedidasTable(attachedDatabase, alias);
  }
}

class Medida extends DataClass implements Insertable<Medida> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? apagadoEm;

  /// "aaaa-mm-dd" no fuso do aparelho.
  final String dia;
  final String tipo;
  final double valor;
  final String unidade;
  const Medida({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.apagadoEm,
    required this.dia,
    required this.tipo,
    required this.valor,
    required this.unidade,
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
    map['dia'] = Variable<String>(dia);
    map['tipo'] = Variable<String>(tipo);
    map['valor'] = Variable<double>(valor);
    map['unidade'] = Variable<String>(unidade);
    return map;
  }

  MedidasCompanion toCompanion(bool nullToAbsent) {
    return MedidasCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      apagadoEm: apagadoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(apagadoEm),
      dia: Value(dia),
      tipo: Value(tipo),
      valor: Value(valor),
      unidade: Value(unidade),
    );
  }

  factory Medida.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Medida(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      apagadoEm: serializer.fromJson<DateTime?>(json['apagadoEm']),
      dia: serializer.fromJson<String>(json['dia']),
      tipo: serializer.fromJson<String>(json['tipo']),
      valor: serializer.fromJson<double>(json['valor']),
      unidade: serializer.fromJson<String>(json['unidade']),
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
      'dia': serializer.toJson<String>(dia),
      'tipo': serializer.toJson<String>(tipo),
      'valor': serializer.toJson<double>(valor),
      'unidade': serializer.toJson<String>(unidade),
    };
  }

  Medida copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> apagadoEm = const Value.absent(),
    String? dia,
    String? tipo,
    double? valor,
    String? unidade,
  }) => Medida(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    apagadoEm: apagadoEm.present ? apagadoEm.value : this.apagadoEm,
    dia: dia ?? this.dia,
    tipo: tipo ?? this.tipo,
    valor: valor ?? this.valor,
    unidade: unidade ?? this.unidade,
  );
  Medida copyWithCompanion(MedidasCompanion data) {
    return Medida(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      apagadoEm: data.apagadoEm.present ? data.apagadoEm.value : this.apagadoEm,
      dia: data.dia.present ? data.dia.value : this.dia,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      valor: data.valor.present ? data.valor.value : this.valor,
      unidade: data.unidade.present ? data.unidade.value : this.unidade,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Medida(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('dia: $dia, ')
          ..write('tipo: $tipo, ')
          ..write('valor: $valor, ')
          ..write('unidade: $unidade')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    dia,
    tipo,
    valor,
    unidade,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medida &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.apagadoEm == this.apagadoEm &&
          other.dia == this.dia &&
          other.tipo == this.tipo &&
          other.valor == this.valor &&
          other.unidade == this.unidade);
}

class MedidasCompanion extends UpdateCompanion<Medida> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> apagadoEm;
  final Value<String> dia;
  final Value<String> tipo;
  final Value<double> valor;
  final Value<String> unidade;
  final Value<int> rowid;
  const MedidasCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    this.dia = const Value.absent(),
    this.tipo = const Value.absent(),
    this.valor = const Value.absent(),
    this.unidade = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedidasCompanion.insert({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    required String dia,
    required String tipo,
    required double valor,
    required String unidade,
    this.rowid = const Value.absent(),
  }) : dia = Value(dia),
       tipo = Value(tipo),
       valor = Value(valor),
       unidade = Value(unidade);
  static Insertable<Medida> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? apagadoEm,
    Expression<String>? dia,
    Expression<String>? tipo,
    Expression<double>? valor,
    Expression<String>? unidade,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (apagadoEm != null) 'apagado_em': apagadoEm,
      if (dia != null) 'dia': dia,
      if (tipo != null) 'tipo': tipo,
      if (valor != null) 'valor': valor,
      if (unidade != null) 'unidade': unidade,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedidasCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? apagadoEm,
    Value<String>? dia,
    Value<String>? tipo,
    Value<double>? valor,
    Value<String>? unidade,
    Value<int>? rowid,
  }) {
    return MedidasCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      apagadoEm: apagadoEm ?? this.apagadoEm,
      dia: dia ?? this.dia,
      tipo: tipo ?? this.tipo,
      valor: valor ?? this.valor,
      unidade: unidade ?? this.unidade,
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
    if (dia.present) {
      map['dia'] = Variable<String>(dia.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (valor.present) {
      map['valor'] = Variable<double>(valor.value);
    }
    if (unidade.present) {
      map['unidade'] = Variable<String>(unidade.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedidasCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('dia: $dia, ')
          ..write('tipo: $tipo, ')
          ..write('valor: $valor, ')
          ..write('unidade: $unidade, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FotosShapeTable extends FotosShape
    with TableInfo<$FotosShapeTable, FotoShape> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FotosShapeTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _diaMeta = const VerificationMeta('dia');
  @override
  late final GeneratedColumn<String> dia = GeneratedColumn<String>(
    'dia',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _anguloMeta = const VerificationMeta('angulo');
  @override
  late final GeneratedColumn<String> angulo = GeneratedColumn<String>(
    'angulo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arquivoMeta = const VerificationMeta(
    'arquivo',
  );
  @override
  late final GeneratedColumn<String> arquivo = GeneratedColumn<String>(
    'arquivo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hashMeta = const VerificationMeta('hash');
  @override
  late final GeneratedColumn<String> hash = GeneratedColumn<String>(
    'hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _naNuvemMeta = const VerificationMeta(
    'naNuvem',
  );
  @override
  late final GeneratedColumn<bool> naNuvem = GeneratedColumn<bool>(
    'na_nuvem',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("na_nuvem" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    dia,
    angulo,
    arquivo,
    hash,
    naNuvem,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fotos_shape';
  @override
  VerificationContext validateIntegrity(
    Insertable<FotoShape> instance, {
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
    if (data.containsKey('dia')) {
      context.handle(
        _diaMeta,
        dia.isAcceptableOrUnknown(data['dia']!, _diaMeta),
      );
    } else if (isInserting) {
      context.missing(_diaMeta);
    }
    if (data.containsKey('angulo')) {
      context.handle(
        _anguloMeta,
        angulo.isAcceptableOrUnknown(data['angulo']!, _anguloMeta),
      );
    } else if (isInserting) {
      context.missing(_anguloMeta);
    }
    if (data.containsKey('arquivo')) {
      context.handle(
        _arquivoMeta,
        arquivo.isAcceptableOrUnknown(data['arquivo']!, _arquivoMeta),
      );
    } else if (isInserting) {
      context.missing(_arquivoMeta);
    }
    if (data.containsKey('hash')) {
      context.handle(
        _hashMeta,
        hash.isAcceptableOrUnknown(data['hash']!, _hashMeta),
      );
    }
    if (data.containsKey('na_nuvem')) {
      context.handle(
        _naNuvemMeta,
        naNuvem.isAcceptableOrUnknown(data['na_nuvem']!, _naNuvemMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FotoShape map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FotoShape(
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
      dia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dia'],
      )!,
      angulo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}angulo'],
      )!,
      arquivo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arquivo'],
      )!,
      hash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hash'],
      ),
      naNuvem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}na_nuvem'],
      )!,
    );
  }

  @override
  $FotosShapeTable createAlias(String alias) {
    return $FotosShapeTable(attachedDatabase, alias);
  }
}

class FotoShape extends DataClass implements Insertable<FotoShape> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? apagadoEm;

  /// "aaaa-mm-dd" no fuso do aparelho.
  final String dia;
  final String angulo;

  /// Nome do arquivo no aparelho (`<id>.webp`). Antes da v11 era um JPEG solto.
  final String arquivo;

  /// SHA-256 da foto inteira (WebP). Muda quando a foto é trocada: é por ele que
  /// cada aparelho sabe se a cópia local está atual.
  final String? hash;

  /// A imagem está no balde da nuvem (senão só no aparelho que a tirou).
  final bool naNuvem;
  const FotoShape({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.apagadoEm,
    required this.dia,
    required this.angulo,
    required this.arquivo,
    this.hash,
    required this.naNuvem,
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
    map['dia'] = Variable<String>(dia);
    map['angulo'] = Variable<String>(angulo);
    map['arquivo'] = Variable<String>(arquivo);
    if (!nullToAbsent || hash != null) {
      map['hash'] = Variable<String>(hash);
    }
    map['na_nuvem'] = Variable<bool>(naNuvem);
    return map;
  }

  FotosShapeCompanion toCompanion(bool nullToAbsent) {
    return FotosShapeCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      apagadoEm: apagadoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(apagadoEm),
      dia: Value(dia),
      angulo: Value(angulo),
      arquivo: Value(arquivo),
      hash: hash == null && nullToAbsent ? const Value.absent() : Value(hash),
      naNuvem: Value(naNuvem),
    );
  }

  factory FotoShape.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FotoShape(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      apagadoEm: serializer.fromJson<DateTime?>(json['apagadoEm']),
      dia: serializer.fromJson<String>(json['dia']),
      angulo: serializer.fromJson<String>(json['angulo']),
      arquivo: serializer.fromJson<String>(json['arquivo']),
      hash: serializer.fromJson<String?>(json['hash']),
      naNuvem: serializer.fromJson<bool>(json['naNuvem']),
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
      'dia': serializer.toJson<String>(dia),
      'angulo': serializer.toJson<String>(angulo),
      'arquivo': serializer.toJson<String>(arquivo),
      'hash': serializer.toJson<String?>(hash),
      'naNuvem': serializer.toJson<bool>(naNuvem),
    };
  }

  FotoShape copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> apagadoEm = const Value.absent(),
    String? dia,
    String? angulo,
    String? arquivo,
    Value<String?> hash = const Value.absent(),
    bool? naNuvem,
  }) => FotoShape(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    apagadoEm: apagadoEm.present ? apagadoEm.value : this.apagadoEm,
    dia: dia ?? this.dia,
    angulo: angulo ?? this.angulo,
    arquivo: arquivo ?? this.arquivo,
    hash: hash.present ? hash.value : this.hash,
    naNuvem: naNuvem ?? this.naNuvem,
  );
  FotoShape copyWithCompanion(FotosShapeCompanion data) {
    return FotoShape(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      apagadoEm: data.apagadoEm.present ? data.apagadoEm.value : this.apagadoEm,
      dia: data.dia.present ? data.dia.value : this.dia,
      angulo: data.angulo.present ? data.angulo.value : this.angulo,
      arquivo: data.arquivo.present ? data.arquivo.value : this.arquivo,
      hash: data.hash.present ? data.hash.value : this.hash,
      naNuvem: data.naNuvem.present ? data.naNuvem.value : this.naNuvem,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FotoShape(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('dia: $dia, ')
          ..write('angulo: $angulo, ')
          ..write('arquivo: $arquivo, ')
          ..write('hash: $hash, ')
          ..write('naNuvem: $naNuvem')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    dia,
    angulo,
    arquivo,
    hash,
    naNuvem,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FotoShape &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.apagadoEm == this.apagadoEm &&
          other.dia == this.dia &&
          other.angulo == this.angulo &&
          other.arquivo == this.arquivo &&
          other.hash == this.hash &&
          other.naNuvem == this.naNuvem);
}

class FotosShapeCompanion extends UpdateCompanion<FotoShape> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> apagadoEm;
  final Value<String> dia;
  final Value<String> angulo;
  final Value<String> arquivo;
  final Value<String?> hash;
  final Value<bool> naNuvem;
  final Value<int> rowid;
  const FotosShapeCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    this.dia = const Value.absent(),
    this.angulo = const Value.absent(),
    this.arquivo = const Value.absent(),
    this.hash = const Value.absent(),
    this.naNuvem = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FotosShapeCompanion.insert({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    required String dia,
    required String angulo,
    required String arquivo,
    this.hash = const Value.absent(),
    this.naNuvem = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : dia = Value(dia),
       angulo = Value(angulo),
       arquivo = Value(arquivo);
  static Insertable<FotoShape> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? apagadoEm,
    Expression<String>? dia,
    Expression<String>? angulo,
    Expression<String>? arquivo,
    Expression<String>? hash,
    Expression<bool>? naNuvem,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (apagadoEm != null) 'apagado_em': apagadoEm,
      if (dia != null) 'dia': dia,
      if (angulo != null) 'angulo': angulo,
      if (arquivo != null) 'arquivo': arquivo,
      if (hash != null) 'hash': hash,
      if (naNuvem != null) 'na_nuvem': naNuvem,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FotosShapeCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? apagadoEm,
    Value<String>? dia,
    Value<String>? angulo,
    Value<String>? arquivo,
    Value<String?>? hash,
    Value<bool>? naNuvem,
    Value<int>? rowid,
  }) {
    return FotosShapeCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      apagadoEm: apagadoEm ?? this.apagadoEm,
      dia: dia ?? this.dia,
      angulo: angulo ?? this.angulo,
      arquivo: arquivo ?? this.arquivo,
      hash: hash ?? this.hash,
      naNuvem: naNuvem ?? this.naNuvem,
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
    if (dia.present) {
      map['dia'] = Variable<String>(dia.value);
    }
    if (angulo.present) {
      map['angulo'] = Variable<String>(angulo.value);
    }
    if (arquivo.present) {
      map['arquivo'] = Variable<String>(arquivo.value);
    }
    if (hash.present) {
      map['hash'] = Variable<String>(hash.value);
    }
    if (naNuvem.present) {
      map['na_nuvem'] = Variable<bool>(naNuvem.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FotosShapeCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('dia: $dia, ')
          ..write('angulo: $angulo, ')
          ..write('arquivo: $arquivo, ')
          ..write('hash: $hash, ')
          ..write('naNuvem: $naNuvem, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlimentosTable extends Alimentos
    with TableInfo<$AlimentosTable, Alimento> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlimentosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<double> kcal = GeneratedColumn<double>(
    'kcal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinaMeta = const VerificationMeta(
    'proteina',
  );
  @override
  late final GeneratedColumn<double> proteina = GeneratedColumn<double>(
    'proteina',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _carboidratoMeta = const VerificationMeta(
    'carboidrato',
  );
  @override
  late final GeneratedColumn<double> carboidrato = GeneratedColumn<double>(
    'carboidrato',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _gorduraMeta = const VerificationMeta(
    'gordura',
  );
  @override
  late final GeneratedColumn<double> gordura = GeneratedColumn<double>(
    'gordura',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _porcaoNomeMeta = const VerificationMeta(
    'porcaoNome',
  );
  @override
  late final GeneratedColumn<String> porcaoNome = GeneratedColumn<String>(
    'porcao_nome',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _porcaoGramasMeta = const VerificationMeta(
    'porcaoGramas',
  );
  @override
  late final GeneratedColumn<double> porcaoGramas = GeneratedColumn<double>(
    'porcao_gramas',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _origemMeta = const VerificationMeta('origem');
  @override
  late final GeneratedColumn<String> origem = GeneratedColumn<String>(
    'origem',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pessoal'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    nome,
    kcal,
    proteina,
    carboidrato,
    gordura,
    porcaoNome,
    porcaoGramas,
    origem,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alimentos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Alimento> instance, {
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
    if (data.containsKey('kcal')) {
      context.handle(
        _kcalMeta,
        kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta),
      );
    } else if (isInserting) {
      context.missing(_kcalMeta);
    }
    if (data.containsKey('proteina')) {
      context.handle(
        _proteinaMeta,
        proteina.isAcceptableOrUnknown(data['proteina']!, _proteinaMeta),
      );
    }
    if (data.containsKey('carboidrato')) {
      context.handle(
        _carboidratoMeta,
        carboidrato.isAcceptableOrUnknown(
          data['carboidrato']!,
          _carboidratoMeta,
        ),
      );
    }
    if (data.containsKey('gordura')) {
      context.handle(
        _gorduraMeta,
        gordura.isAcceptableOrUnknown(data['gordura']!, _gorduraMeta),
      );
    }
    if (data.containsKey('porcao_nome')) {
      context.handle(
        _porcaoNomeMeta,
        porcaoNome.isAcceptableOrUnknown(data['porcao_nome']!, _porcaoNomeMeta),
      );
    }
    if (data.containsKey('porcao_gramas')) {
      context.handle(
        _porcaoGramasMeta,
        porcaoGramas.isAcceptableOrUnknown(
          data['porcao_gramas']!,
          _porcaoGramasMeta,
        ),
      );
    }
    if (data.containsKey('origem')) {
      context.handle(
        _origemMeta,
        origem.isAcceptableOrUnknown(data['origem']!, _origemMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Alimento map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Alimento(
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
      kcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal'],
      )!,
      proteina: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}proteina'],
      )!,
      carboidrato: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carboidrato'],
      )!,
      gordura: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gordura'],
      )!,
      porcaoNome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}porcao_nome'],
      ),
      porcaoGramas: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}porcao_gramas'],
      ),
      origem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origem'],
      )!,
    );
  }

  @override
  $AlimentosTable createAlias(String alias) {
    return $AlimentosTable(attachedDatabase, alias);
  }
}

class Alimento extends DataClass implements Insertable<Alimento> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? apagadoEm;
  final String nome;
  final double kcal;
  final double proteina;
  final double carboidrato;
  final double gordura;

  /// Porção caseira opcional: "1 ovo" = 50 g.
  final String? porcaoNome;
  final double? porcaoGramas;
  final String origem;
  const Alimento({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.apagadoEm,
    required this.nome,
    required this.kcal,
    required this.proteina,
    required this.carboidrato,
    required this.gordura,
    this.porcaoNome,
    this.porcaoGramas,
    required this.origem,
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
    map['kcal'] = Variable<double>(kcal);
    map['proteina'] = Variable<double>(proteina);
    map['carboidrato'] = Variable<double>(carboidrato);
    map['gordura'] = Variable<double>(gordura);
    if (!nullToAbsent || porcaoNome != null) {
      map['porcao_nome'] = Variable<String>(porcaoNome);
    }
    if (!nullToAbsent || porcaoGramas != null) {
      map['porcao_gramas'] = Variable<double>(porcaoGramas);
    }
    map['origem'] = Variable<String>(origem);
    return map;
  }

  AlimentosCompanion toCompanion(bool nullToAbsent) {
    return AlimentosCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      apagadoEm: apagadoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(apagadoEm),
      nome: Value(nome),
      kcal: Value(kcal),
      proteina: Value(proteina),
      carboidrato: Value(carboidrato),
      gordura: Value(gordura),
      porcaoNome: porcaoNome == null && nullToAbsent
          ? const Value.absent()
          : Value(porcaoNome),
      porcaoGramas: porcaoGramas == null && nullToAbsent
          ? const Value.absent()
          : Value(porcaoGramas),
      origem: Value(origem),
    );
  }

  factory Alimento.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Alimento(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      apagadoEm: serializer.fromJson<DateTime?>(json['apagadoEm']),
      nome: serializer.fromJson<String>(json['nome']),
      kcal: serializer.fromJson<double>(json['kcal']),
      proteina: serializer.fromJson<double>(json['proteina']),
      carboidrato: serializer.fromJson<double>(json['carboidrato']),
      gordura: serializer.fromJson<double>(json['gordura']),
      porcaoNome: serializer.fromJson<String?>(json['porcaoNome']),
      porcaoGramas: serializer.fromJson<double?>(json['porcaoGramas']),
      origem: serializer.fromJson<String>(json['origem']),
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
      'kcal': serializer.toJson<double>(kcal),
      'proteina': serializer.toJson<double>(proteina),
      'carboidrato': serializer.toJson<double>(carboidrato),
      'gordura': serializer.toJson<double>(gordura),
      'porcaoNome': serializer.toJson<String?>(porcaoNome),
      'porcaoGramas': serializer.toJson<double?>(porcaoGramas),
      'origem': serializer.toJson<String>(origem),
    };
  }

  Alimento copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> apagadoEm = const Value.absent(),
    String? nome,
    double? kcal,
    double? proteina,
    double? carboidrato,
    double? gordura,
    Value<String?> porcaoNome = const Value.absent(),
    Value<double?> porcaoGramas = const Value.absent(),
    String? origem,
  }) => Alimento(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    apagadoEm: apagadoEm.present ? apagadoEm.value : this.apagadoEm,
    nome: nome ?? this.nome,
    kcal: kcal ?? this.kcal,
    proteina: proteina ?? this.proteina,
    carboidrato: carboidrato ?? this.carboidrato,
    gordura: gordura ?? this.gordura,
    porcaoNome: porcaoNome.present ? porcaoNome.value : this.porcaoNome,
    porcaoGramas: porcaoGramas.present ? porcaoGramas.value : this.porcaoGramas,
    origem: origem ?? this.origem,
  );
  Alimento copyWithCompanion(AlimentosCompanion data) {
    return Alimento(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      apagadoEm: data.apagadoEm.present ? data.apagadoEm.value : this.apagadoEm,
      nome: data.nome.present ? data.nome.value : this.nome,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      proteina: data.proteina.present ? data.proteina.value : this.proteina,
      carboidrato: data.carboidrato.present
          ? data.carboidrato.value
          : this.carboidrato,
      gordura: data.gordura.present ? data.gordura.value : this.gordura,
      porcaoNome: data.porcaoNome.present
          ? data.porcaoNome.value
          : this.porcaoNome,
      porcaoGramas: data.porcaoGramas.present
          ? data.porcaoGramas.value
          : this.porcaoGramas,
      origem: data.origem.present ? data.origem.value : this.origem,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Alimento(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('nome: $nome, ')
          ..write('kcal: $kcal, ')
          ..write('proteina: $proteina, ')
          ..write('carboidrato: $carboidrato, ')
          ..write('gordura: $gordura, ')
          ..write('porcaoNome: $porcaoNome, ')
          ..write('porcaoGramas: $porcaoGramas, ')
          ..write('origem: $origem')
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
    kcal,
    proteina,
    carboidrato,
    gordura,
    porcaoNome,
    porcaoGramas,
    origem,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Alimento &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.apagadoEm == this.apagadoEm &&
          other.nome == this.nome &&
          other.kcal == this.kcal &&
          other.proteina == this.proteina &&
          other.carboidrato == this.carboidrato &&
          other.gordura == this.gordura &&
          other.porcaoNome == this.porcaoNome &&
          other.porcaoGramas == this.porcaoGramas &&
          other.origem == this.origem);
}

class AlimentosCompanion extends UpdateCompanion<Alimento> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> apagadoEm;
  final Value<String> nome;
  final Value<double> kcal;
  final Value<double> proteina;
  final Value<double> carboidrato;
  final Value<double> gordura;
  final Value<String?> porcaoNome;
  final Value<double?> porcaoGramas;
  final Value<String> origem;
  final Value<int> rowid;
  const AlimentosCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    this.nome = const Value.absent(),
    this.kcal = const Value.absent(),
    this.proteina = const Value.absent(),
    this.carboidrato = const Value.absent(),
    this.gordura = const Value.absent(),
    this.porcaoNome = const Value.absent(),
    this.porcaoGramas = const Value.absent(),
    this.origem = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlimentosCompanion.insert({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    required String nome,
    required double kcal,
    this.proteina = const Value.absent(),
    this.carboidrato = const Value.absent(),
    this.gordura = const Value.absent(),
    this.porcaoNome = const Value.absent(),
    this.porcaoGramas = const Value.absent(),
    this.origem = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : nome = Value(nome),
       kcal = Value(kcal);
  static Insertable<Alimento> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? apagadoEm,
    Expression<String>? nome,
    Expression<double>? kcal,
    Expression<double>? proteina,
    Expression<double>? carboidrato,
    Expression<double>? gordura,
    Expression<String>? porcaoNome,
    Expression<double>? porcaoGramas,
    Expression<String>? origem,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (apagadoEm != null) 'apagado_em': apagadoEm,
      if (nome != null) 'nome': nome,
      if (kcal != null) 'kcal': kcal,
      if (proteina != null) 'proteina': proteina,
      if (carboidrato != null) 'carboidrato': carboidrato,
      if (gordura != null) 'gordura': gordura,
      if (porcaoNome != null) 'porcao_nome': porcaoNome,
      if (porcaoGramas != null) 'porcao_gramas': porcaoGramas,
      if (origem != null) 'origem': origem,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlimentosCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? apagadoEm,
    Value<String>? nome,
    Value<double>? kcal,
    Value<double>? proteina,
    Value<double>? carboidrato,
    Value<double>? gordura,
    Value<String?>? porcaoNome,
    Value<double?>? porcaoGramas,
    Value<String>? origem,
    Value<int>? rowid,
  }) {
    return AlimentosCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      apagadoEm: apagadoEm ?? this.apagadoEm,
      nome: nome ?? this.nome,
      kcal: kcal ?? this.kcal,
      proteina: proteina ?? this.proteina,
      carboidrato: carboidrato ?? this.carboidrato,
      gordura: gordura ?? this.gordura,
      porcaoNome: porcaoNome ?? this.porcaoNome,
      porcaoGramas: porcaoGramas ?? this.porcaoGramas,
      origem: origem ?? this.origem,
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
    if (kcal.present) {
      map['kcal'] = Variable<double>(kcal.value);
    }
    if (proteina.present) {
      map['proteina'] = Variable<double>(proteina.value);
    }
    if (carboidrato.present) {
      map['carboidrato'] = Variable<double>(carboidrato.value);
    }
    if (gordura.present) {
      map['gordura'] = Variable<double>(gordura.value);
    }
    if (porcaoNome.present) {
      map['porcao_nome'] = Variable<String>(porcaoNome.value);
    }
    if (porcaoGramas.present) {
      map['porcao_gramas'] = Variable<double>(porcaoGramas.value);
    }
    if (origem.present) {
      map['origem'] = Variable<String>(origem.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlimentosCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('nome: $nome, ')
          ..write('kcal: $kcal, ')
          ..write('proteina: $proteina, ')
          ..write('carboidrato: $carboidrato, ')
          ..write('gordura: $gordura, ')
          ..write('porcaoNome: $porcaoNome, ')
          ..write('porcaoGramas: $porcaoGramas, ')
          ..write('origem: $origem, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlvosDietaTable extends AlvosDieta
    with TableInfo<$AlvosDietaTable, AlvoDieta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlvosDietaTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _tipoDiaMeta = const VerificationMeta(
    'tipoDia',
  );
  @override
  late final GeneratedColumn<String> tipoDia = GeneratedColumn<String>(
    'tipo_dia',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<double> kcal = GeneratedColumn<double>(
    'kcal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinaMeta = const VerificationMeta(
    'proteina',
  );
  @override
  late final GeneratedColumn<double> proteina = GeneratedColumn<double>(
    'proteina',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _carboidratoMeta = const VerificationMeta(
    'carboidrato',
  );
  @override
  late final GeneratedColumn<double> carboidrato = GeneratedColumn<double>(
    'carboidrato',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _gorduraMeta = const VerificationMeta(
    'gordura',
  );
  @override
  late final GeneratedColumn<double> gordura = GeneratedColumn<double>(
    'gordura',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    tipoDia,
    kcal,
    proteina,
    carboidrato,
    gordura,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alvos_dieta';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlvoDieta> instance, {
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
    if (data.containsKey('tipo_dia')) {
      context.handle(
        _tipoDiaMeta,
        tipoDia.isAcceptableOrUnknown(data['tipo_dia']!, _tipoDiaMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoDiaMeta);
    }
    if (data.containsKey('kcal')) {
      context.handle(
        _kcalMeta,
        kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta),
      );
    } else if (isInserting) {
      context.missing(_kcalMeta);
    }
    if (data.containsKey('proteina')) {
      context.handle(
        _proteinaMeta,
        proteina.isAcceptableOrUnknown(data['proteina']!, _proteinaMeta),
      );
    }
    if (data.containsKey('carboidrato')) {
      context.handle(
        _carboidratoMeta,
        carboidrato.isAcceptableOrUnknown(
          data['carboidrato']!,
          _carboidratoMeta,
        ),
      );
    }
    if (data.containsKey('gordura')) {
      context.handle(
        _gorduraMeta,
        gordura.isAcceptableOrUnknown(data['gordura']!, _gorduraMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlvoDieta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlvoDieta(
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
      tipoDia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_dia'],
      )!,
      kcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal'],
      )!,
      proteina: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}proteina'],
      )!,
      carboidrato: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carboidrato'],
      )!,
      gordura: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gordura'],
      )!,
    );
  }

  @override
  $AlvosDietaTable createAlias(String alias) {
    return $AlvosDietaTable(attachedDatabase, alias);
  }
}

class AlvoDieta extends DataClass implements Insertable<AlvoDieta> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? apagadoEm;
  final String tipoDia;
  final double kcal;
  final double proteina;
  final double carboidrato;
  final double gordura;
  const AlvoDieta({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.apagadoEm,
    required this.tipoDia,
    required this.kcal,
    required this.proteina,
    required this.carboidrato,
    required this.gordura,
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
    map['tipo_dia'] = Variable<String>(tipoDia);
    map['kcal'] = Variable<double>(kcal);
    map['proteina'] = Variable<double>(proteina);
    map['carboidrato'] = Variable<double>(carboidrato);
    map['gordura'] = Variable<double>(gordura);
    return map;
  }

  AlvosDietaCompanion toCompanion(bool nullToAbsent) {
    return AlvosDietaCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      apagadoEm: apagadoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(apagadoEm),
      tipoDia: Value(tipoDia),
      kcal: Value(kcal),
      proteina: Value(proteina),
      carboidrato: Value(carboidrato),
      gordura: Value(gordura),
    );
  }

  factory AlvoDieta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlvoDieta(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      apagadoEm: serializer.fromJson<DateTime?>(json['apagadoEm']),
      tipoDia: serializer.fromJson<String>(json['tipoDia']),
      kcal: serializer.fromJson<double>(json['kcal']),
      proteina: serializer.fromJson<double>(json['proteina']),
      carboidrato: serializer.fromJson<double>(json['carboidrato']),
      gordura: serializer.fromJson<double>(json['gordura']),
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
      'tipoDia': serializer.toJson<String>(tipoDia),
      'kcal': serializer.toJson<double>(kcal),
      'proteina': serializer.toJson<double>(proteina),
      'carboidrato': serializer.toJson<double>(carboidrato),
      'gordura': serializer.toJson<double>(gordura),
    };
  }

  AlvoDieta copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> apagadoEm = const Value.absent(),
    String? tipoDia,
    double? kcal,
    double? proteina,
    double? carboidrato,
    double? gordura,
  }) => AlvoDieta(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    apagadoEm: apagadoEm.present ? apagadoEm.value : this.apagadoEm,
    tipoDia: tipoDia ?? this.tipoDia,
    kcal: kcal ?? this.kcal,
    proteina: proteina ?? this.proteina,
    carboidrato: carboidrato ?? this.carboidrato,
    gordura: gordura ?? this.gordura,
  );
  AlvoDieta copyWithCompanion(AlvosDietaCompanion data) {
    return AlvoDieta(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      apagadoEm: data.apagadoEm.present ? data.apagadoEm.value : this.apagadoEm,
      tipoDia: data.tipoDia.present ? data.tipoDia.value : this.tipoDia,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      proteina: data.proteina.present ? data.proteina.value : this.proteina,
      carboidrato: data.carboidrato.present
          ? data.carboidrato.value
          : this.carboidrato,
      gordura: data.gordura.present ? data.gordura.value : this.gordura,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlvoDieta(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('tipoDia: $tipoDia, ')
          ..write('kcal: $kcal, ')
          ..write('proteina: $proteina, ')
          ..write('carboidrato: $carboidrato, ')
          ..write('gordura: $gordura')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    tipoDia,
    kcal,
    proteina,
    carboidrato,
    gordura,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlvoDieta &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.apagadoEm == this.apagadoEm &&
          other.tipoDia == this.tipoDia &&
          other.kcal == this.kcal &&
          other.proteina == this.proteina &&
          other.carboidrato == this.carboidrato &&
          other.gordura == this.gordura);
}

class AlvosDietaCompanion extends UpdateCompanion<AlvoDieta> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> apagadoEm;
  final Value<String> tipoDia;
  final Value<double> kcal;
  final Value<double> proteina;
  final Value<double> carboidrato;
  final Value<double> gordura;
  final Value<int> rowid;
  const AlvosDietaCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    this.tipoDia = const Value.absent(),
    this.kcal = const Value.absent(),
    this.proteina = const Value.absent(),
    this.carboidrato = const Value.absent(),
    this.gordura = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlvosDietaCompanion.insert({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    required String tipoDia,
    required double kcal,
    this.proteina = const Value.absent(),
    this.carboidrato = const Value.absent(),
    this.gordura = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : tipoDia = Value(tipoDia),
       kcal = Value(kcal);
  static Insertable<AlvoDieta> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? apagadoEm,
    Expression<String>? tipoDia,
    Expression<double>? kcal,
    Expression<double>? proteina,
    Expression<double>? carboidrato,
    Expression<double>? gordura,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (apagadoEm != null) 'apagado_em': apagadoEm,
      if (tipoDia != null) 'tipo_dia': tipoDia,
      if (kcal != null) 'kcal': kcal,
      if (proteina != null) 'proteina': proteina,
      if (carboidrato != null) 'carboidrato': carboidrato,
      if (gordura != null) 'gordura': gordura,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlvosDietaCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? apagadoEm,
    Value<String>? tipoDia,
    Value<double>? kcal,
    Value<double>? proteina,
    Value<double>? carboidrato,
    Value<double>? gordura,
    Value<int>? rowid,
  }) {
    return AlvosDietaCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      apagadoEm: apagadoEm ?? this.apagadoEm,
      tipoDia: tipoDia ?? this.tipoDia,
      kcal: kcal ?? this.kcal,
      proteina: proteina ?? this.proteina,
      carboidrato: carboidrato ?? this.carboidrato,
      gordura: gordura ?? this.gordura,
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
    if (tipoDia.present) {
      map['tipo_dia'] = Variable<String>(tipoDia.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<double>(kcal.value);
    }
    if (proteina.present) {
      map['proteina'] = Variable<double>(proteina.value);
    }
    if (carboidrato.present) {
      map['carboidrato'] = Variable<double>(carboidrato.value);
    }
    if (gordura.present) {
      map['gordura'] = Variable<double>(gordura.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlvosDietaCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('tipoDia: $tipoDia, ')
          ..write('kcal: $kcal, ')
          ..write('proteina: $proteina, ')
          ..write('carboidrato: $carboidrato, ')
          ..write('gordura: $gordura, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RegistrosAlimentacaoTable extends RegistrosAlimentacao
    with TableInfo<$RegistrosAlimentacaoTable, RegistroAlimentacao> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RegistrosAlimentacaoTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _diaMeta = const VerificationMeta('dia');
  @override
  late final GeneratedColumn<String> dia = GeneratedColumn<String>(
    'dia',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refeicaoMeta = const VerificationMeta(
    'refeicao',
  );
  @override
  late final GeneratedColumn<String> refeicao = GeneratedColumn<String>(
    'refeicao',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _alimentoIdMeta = const VerificationMeta(
    'alimentoId',
  );
  @override
  late final GeneratedColumn<String> alimentoId = GeneratedColumn<String>(
    'alimento_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES alimentos (id)',
    ),
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
  static const VerificationMeta _gramasMeta = const VerificationMeta('gramas');
  @override
  late final GeneratedColumn<double> gramas = GeneratedColumn<double>(
    'gramas',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<double> kcal = GeneratedColumn<double>(
    'kcal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinaMeta = const VerificationMeta(
    'proteina',
  );
  @override
  late final GeneratedColumn<double> proteina = GeneratedColumn<double>(
    'proteina',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _carboidratoMeta = const VerificationMeta(
    'carboidrato',
  );
  @override
  late final GeneratedColumn<double> carboidrato = GeneratedColumn<double>(
    'carboidrato',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _gorduraMeta = const VerificationMeta(
    'gordura',
  );
  @override
  late final GeneratedColumn<double> gordura = GeneratedColumn<double>(
    'gordura',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    dia,
    refeicao,
    alimentoId,
    nome,
    gramas,
    kcal,
    proteina,
    carboidrato,
    gordura,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'registros_alimentacao';
  @override
  VerificationContext validateIntegrity(
    Insertable<RegistroAlimentacao> instance, {
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
    if (data.containsKey('dia')) {
      context.handle(
        _diaMeta,
        dia.isAcceptableOrUnknown(data['dia']!, _diaMeta),
      );
    } else if (isInserting) {
      context.missing(_diaMeta);
    }
    if (data.containsKey('refeicao')) {
      context.handle(
        _refeicaoMeta,
        refeicao.isAcceptableOrUnknown(data['refeicao']!, _refeicaoMeta),
      );
    } else if (isInserting) {
      context.missing(_refeicaoMeta);
    }
    if (data.containsKey('alimento_id')) {
      context.handle(
        _alimentoIdMeta,
        alimentoId.isAcceptableOrUnknown(data['alimento_id']!, _alimentoIdMeta),
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
    if (data.containsKey('gramas')) {
      context.handle(
        _gramasMeta,
        gramas.isAcceptableOrUnknown(data['gramas']!, _gramasMeta),
      );
    } else if (isInserting) {
      context.missing(_gramasMeta);
    }
    if (data.containsKey('kcal')) {
      context.handle(
        _kcalMeta,
        kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta),
      );
    } else if (isInserting) {
      context.missing(_kcalMeta);
    }
    if (data.containsKey('proteina')) {
      context.handle(
        _proteinaMeta,
        proteina.isAcceptableOrUnknown(data['proteina']!, _proteinaMeta),
      );
    }
    if (data.containsKey('carboidrato')) {
      context.handle(
        _carboidratoMeta,
        carboidrato.isAcceptableOrUnknown(
          data['carboidrato']!,
          _carboidratoMeta,
        ),
      );
    }
    if (data.containsKey('gordura')) {
      context.handle(
        _gorduraMeta,
        gordura.isAcceptableOrUnknown(data['gordura']!, _gorduraMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RegistroAlimentacao map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RegistroAlimentacao(
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
      dia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dia'],
      )!,
      refeicao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}refeicao'],
      )!,
      alimentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alimento_id'],
      ),
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      gramas: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gramas'],
      )!,
      kcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal'],
      )!,
      proteina: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}proteina'],
      )!,
      carboidrato: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carboidrato'],
      )!,
      gordura: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gordura'],
      )!,
    );
  }

  @override
  $RegistrosAlimentacaoTable createAlias(String alias) {
    return $RegistrosAlimentacaoTable(attachedDatabase, alias);
  }
}

class RegistroAlimentacao extends DataClass
    implements Insertable<RegistroAlimentacao> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? apagadoEm;

  /// "aaaa-mm-dd" no fuso do aparelho.
  final String dia;

  /// 'cafe', 'almoco', 'lanche', 'jantar' ou 'ceia'.
  final String refeicao;
  final String? alimentoId;
  final String nome;
  final double gramas;
  final double kcal;
  final double proteina;
  final double carboidrato;
  final double gordura;
  const RegistroAlimentacao({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.apagadoEm,
    required this.dia,
    required this.refeicao,
    this.alimentoId,
    required this.nome,
    required this.gramas,
    required this.kcal,
    required this.proteina,
    required this.carboidrato,
    required this.gordura,
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
    map['dia'] = Variable<String>(dia);
    map['refeicao'] = Variable<String>(refeicao);
    if (!nullToAbsent || alimentoId != null) {
      map['alimento_id'] = Variable<String>(alimentoId);
    }
    map['nome'] = Variable<String>(nome);
    map['gramas'] = Variable<double>(gramas);
    map['kcal'] = Variable<double>(kcal);
    map['proteina'] = Variable<double>(proteina);
    map['carboidrato'] = Variable<double>(carboidrato);
    map['gordura'] = Variable<double>(gordura);
    return map;
  }

  RegistrosAlimentacaoCompanion toCompanion(bool nullToAbsent) {
    return RegistrosAlimentacaoCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      apagadoEm: apagadoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(apagadoEm),
      dia: Value(dia),
      refeicao: Value(refeicao),
      alimentoId: alimentoId == null && nullToAbsent
          ? const Value.absent()
          : Value(alimentoId),
      nome: Value(nome),
      gramas: Value(gramas),
      kcal: Value(kcal),
      proteina: Value(proteina),
      carboidrato: Value(carboidrato),
      gordura: Value(gordura),
    );
  }

  factory RegistroAlimentacao.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RegistroAlimentacao(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      apagadoEm: serializer.fromJson<DateTime?>(json['apagadoEm']),
      dia: serializer.fromJson<String>(json['dia']),
      refeicao: serializer.fromJson<String>(json['refeicao']),
      alimentoId: serializer.fromJson<String?>(json['alimentoId']),
      nome: serializer.fromJson<String>(json['nome']),
      gramas: serializer.fromJson<double>(json['gramas']),
      kcal: serializer.fromJson<double>(json['kcal']),
      proteina: serializer.fromJson<double>(json['proteina']),
      carboidrato: serializer.fromJson<double>(json['carboidrato']),
      gordura: serializer.fromJson<double>(json['gordura']),
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
      'dia': serializer.toJson<String>(dia),
      'refeicao': serializer.toJson<String>(refeicao),
      'alimentoId': serializer.toJson<String?>(alimentoId),
      'nome': serializer.toJson<String>(nome),
      'gramas': serializer.toJson<double>(gramas),
      'kcal': serializer.toJson<double>(kcal),
      'proteina': serializer.toJson<double>(proteina),
      'carboidrato': serializer.toJson<double>(carboidrato),
      'gordura': serializer.toJson<double>(gordura),
    };
  }

  RegistroAlimentacao copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> apagadoEm = const Value.absent(),
    String? dia,
    String? refeicao,
    Value<String?> alimentoId = const Value.absent(),
    String? nome,
    double? gramas,
    double? kcal,
    double? proteina,
    double? carboidrato,
    double? gordura,
  }) => RegistroAlimentacao(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    apagadoEm: apagadoEm.present ? apagadoEm.value : this.apagadoEm,
    dia: dia ?? this.dia,
    refeicao: refeicao ?? this.refeicao,
    alimentoId: alimentoId.present ? alimentoId.value : this.alimentoId,
    nome: nome ?? this.nome,
    gramas: gramas ?? this.gramas,
    kcal: kcal ?? this.kcal,
    proteina: proteina ?? this.proteina,
    carboidrato: carboidrato ?? this.carboidrato,
    gordura: gordura ?? this.gordura,
  );
  RegistroAlimentacao copyWithCompanion(RegistrosAlimentacaoCompanion data) {
    return RegistroAlimentacao(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      apagadoEm: data.apagadoEm.present ? data.apagadoEm.value : this.apagadoEm,
      dia: data.dia.present ? data.dia.value : this.dia,
      refeicao: data.refeicao.present ? data.refeicao.value : this.refeicao,
      alimentoId: data.alimentoId.present
          ? data.alimentoId.value
          : this.alimentoId,
      nome: data.nome.present ? data.nome.value : this.nome,
      gramas: data.gramas.present ? data.gramas.value : this.gramas,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      proteina: data.proteina.present ? data.proteina.value : this.proteina,
      carboidrato: data.carboidrato.present
          ? data.carboidrato.value
          : this.carboidrato,
      gordura: data.gordura.present ? data.gordura.value : this.gordura,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RegistroAlimentacao(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('dia: $dia, ')
          ..write('refeicao: $refeicao, ')
          ..write('alimentoId: $alimentoId, ')
          ..write('nome: $nome, ')
          ..write('gramas: $gramas, ')
          ..write('kcal: $kcal, ')
          ..write('proteina: $proteina, ')
          ..write('carboidrato: $carboidrato, ')
          ..write('gordura: $gordura')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    dia,
    refeicao,
    alimentoId,
    nome,
    gramas,
    kcal,
    proteina,
    carboidrato,
    gordura,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RegistroAlimentacao &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.apagadoEm == this.apagadoEm &&
          other.dia == this.dia &&
          other.refeicao == this.refeicao &&
          other.alimentoId == this.alimentoId &&
          other.nome == this.nome &&
          other.gramas == this.gramas &&
          other.kcal == this.kcal &&
          other.proteina == this.proteina &&
          other.carboidrato == this.carboidrato &&
          other.gordura == this.gordura);
}

class RegistrosAlimentacaoCompanion
    extends UpdateCompanion<RegistroAlimentacao> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> apagadoEm;
  final Value<String> dia;
  final Value<String> refeicao;
  final Value<String?> alimentoId;
  final Value<String> nome;
  final Value<double> gramas;
  final Value<double> kcal;
  final Value<double> proteina;
  final Value<double> carboidrato;
  final Value<double> gordura;
  final Value<int> rowid;
  const RegistrosAlimentacaoCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    this.dia = const Value.absent(),
    this.refeicao = const Value.absent(),
    this.alimentoId = const Value.absent(),
    this.nome = const Value.absent(),
    this.gramas = const Value.absent(),
    this.kcal = const Value.absent(),
    this.proteina = const Value.absent(),
    this.carboidrato = const Value.absent(),
    this.gordura = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RegistrosAlimentacaoCompanion.insert({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    required String dia,
    required String refeicao,
    this.alimentoId = const Value.absent(),
    required String nome,
    required double gramas,
    required double kcal,
    this.proteina = const Value.absent(),
    this.carboidrato = const Value.absent(),
    this.gordura = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : dia = Value(dia),
       refeicao = Value(refeicao),
       nome = Value(nome),
       gramas = Value(gramas),
       kcal = Value(kcal);
  static Insertable<RegistroAlimentacao> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? apagadoEm,
    Expression<String>? dia,
    Expression<String>? refeicao,
    Expression<String>? alimentoId,
    Expression<String>? nome,
    Expression<double>? gramas,
    Expression<double>? kcal,
    Expression<double>? proteina,
    Expression<double>? carboidrato,
    Expression<double>? gordura,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (apagadoEm != null) 'apagado_em': apagadoEm,
      if (dia != null) 'dia': dia,
      if (refeicao != null) 'refeicao': refeicao,
      if (alimentoId != null) 'alimento_id': alimentoId,
      if (nome != null) 'nome': nome,
      if (gramas != null) 'gramas': gramas,
      if (kcal != null) 'kcal': kcal,
      if (proteina != null) 'proteina': proteina,
      if (carboidrato != null) 'carboidrato': carboidrato,
      if (gordura != null) 'gordura': gordura,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RegistrosAlimentacaoCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? apagadoEm,
    Value<String>? dia,
    Value<String>? refeicao,
    Value<String?>? alimentoId,
    Value<String>? nome,
    Value<double>? gramas,
    Value<double>? kcal,
    Value<double>? proteina,
    Value<double>? carboidrato,
    Value<double>? gordura,
    Value<int>? rowid,
  }) {
    return RegistrosAlimentacaoCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      apagadoEm: apagadoEm ?? this.apagadoEm,
      dia: dia ?? this.dia,
      refeicao: refeicao ?? this.refeicao,
      alimentoId: alimentoId ?? this.alimentoId,
      nome: nome ?? this.nome,
      gramas: gramas ?? this.gramas,
      kcal: kcal ?? this.kcal,
      proteina: proteina ?? this.proteina,
      carboidrato: carboidrato ?? this.carboidrato,
      gordura: gordura ?? this.gordura,
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
    if (dia.present) {
      map['dia'] = Variable<String>(dia.value);
    }
    if (refeicao.present) {
      map['refeicao'] = Variable<String>(refeicao.value);
    }
    if (alimentoId.present) {
      map['alimento_id'] = Variable<String>(alimentoId.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (gramas.present) {
      map['gramas'] = Variable<double>(gramas.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<double>(kcal.value);
    }
    if (proteina.present) {
      map['proteina'] = Variable<double>(proteina.value);
    }
    if (carboidrato.present) {
      map['carboidrato'] = Variable<double>(carboidrato.value);
    }
    if (gordura.present) {
      map['gordura'] = Variable<double>(gordura.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RegistrosAlimentacaoCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('dia: $dia, ')
          ..write('refeicao: $refeicao, ')
          ..write('alimentoId: $alimentoId, ')
          ..write('nome: $nome, ')
          ..write('gramas: $gramas, ')
          ..write('kcal: $kcal, ')
          ..write('proteina: $proteina, ')
          ..write('carboidrato: $carboidrato, ')
          ..write('gordura: $gordura, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MensagensAssistenteTable extends MensagensAssistente
    with TableInfo<$MensagensAssistenteTable, MensagemAssistente> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MensagensAssistenteTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<PapelMensagem, String> papel =
      GeneratedColumn<String>(
        'papel',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PapelMensagem>($MensagensAssistenteTable.$converterpapel);
  static const VerificationMeta _textoMeta = const VerificationMeta('texto');
  @override
  late final GeneratedColumn<String> texto = GeneratedColumn<String>(
    'texto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _naFilaMeta = const VerificationMeta('naFila');
  @override
  late final GeneratedColumn<bool> naFila = GeneratedColumn<bool>(
    'na_fila',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("na_fila" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _desfeitaMeta = const VerificationMeta(
    'desfeita',
  );
  @override
  late final GeneratedColumn<bool> desfeita = GeneratedColumn<bool>(
    'desfeita',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("desfeita" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    papel,
    texto,
    naFila,
    itemTipo,
    itemId,
    desfeita,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mensagens_assistente';
  @override
  VerificationContext validateIntegrity(
    Insertable<MensagemAssistente> instance, {
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
    if (data.containsKey('na_fila')) {
      context.handle(
        _naFilaMeta,
        naFila.isAcceptableOrUnknown(data['na_fila']!, _naFilaMeta),
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
    if (data.containsKey('desfeita')) {
      context.handle(
        _desfeitaMeta,
        desfeita.isAcceptableOrUnknown(data['desfeita']!, _desfeitaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MensagemAssistente map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MensagemAssistente(
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
      papel: $MensagensAssistenteTable.$converterpapel.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}papel'],
        )!,
      ),
      texto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}texto'],
      )!,
      naFila: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}na_fila'],
      )!,
      itemTipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_tipo'],
      ),
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      ),
      desfeita: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}desfeita'],
      )!,
    );
  }

  @override
  $MensagensAssistenteTable createAlias(String alias) {
    return $MensagensAssistenteTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PapelMensagem, String, String> $converterpapel =
      const EnumNameConverter<PapelMensagem>(PapelMensagem.values);
}

class MensagemAssistente extends DataClass
    implements Insertable<MensagemAssistente> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? apagadoEm;
  final PapelMensagem papel;
  final String texto;
  final bool naFila;

  /// O que um comando rápido criou ('transacao', 'lembrete', 'tarefa',
  /// 'habito', 'medida') e o id, para o botão Desfazer.
  final String? itemTipo;
  final String? itemId;
  final bool desfeita;
  const MensagemAssistente({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.apagadoEm,
    required this.papel,
    required this.texto,
    required this.naFila,
    this.itemTipo,
    this.itemId,
    required this.desfeita,
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
    {
      map['papel'] = Variable<String>(
        $MensagensAssistenteTable.$converterpapel.toSql(papel),
      );
    }
    map['texto'] = Variable<String>(texto);
    map['na_fila'] = Variable<bool>(naFila);
    if (!nullToAbsent || itemTipo != null) {
      map['item_tipo'] = Variable<String>(itemTipo);
    }
    if (!nullToAbsent || itemId != null) {
      map['item_id'] = Variable<String>(itemId);
    }
    map['desfeita'] = Variable<bool>(desfeita);
    return map;
  }

  MensagensAssistenteCompanion toCompanion(bool nullToAbsent) {
    return MensagensAssistenteCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      apagadoEm: apagadoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(apagadoEm),
      papel: Value(papel),
      texto: Value(texto),
      naFila: Value(naFila),
      itemTipo: itemTipo == null && nullToAbsent
          ? const Value.absent()
          : Value(itemTipo),
      itemId: itemId == null && nullToAbsent
          ? const Value.absent()
          : Value(itemId),
      desfeita: Value(desfeita),
    );
  }

  factory MensagemAssistente.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MensagemAssistente(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      apagadoEm: serializer.fromJson<DateTime?>(json['apagadoEm']),
      papel: $MensagensAssistenteTable.$converterpapel.fromJson(
        serializer.fromJson<String>(json['papel']),
      ),
      texto: serializer.fromJson<String>(json['texto']),
      naFila: serializer.fromJson<bool>(json['naFila']),
      itemTipo: serializer.fromJson<String?>(json['itemTipo']),
      itemId: serializer.fromJson<String?>(json['itemId']),
      desfeita: serializer.fromJson<bool>(json['desfeita']),
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
      'papel': serializer.toJson<String>(
        $MensagensAssistenteTable.$converterpapel.toJson(papel),
      ),
      'texto': serializer.toJson<String>(texto),
      'naFila': serializer.toJson<bool>(naFila),
      'itemTipo': serializer.toJson<String?>(itemTipo),
      'itemId': serializer.toJson<String?>(itemId),
      'desfeita': serializer.toJson<bool>(desfeita),
    };
  }

  MensagemAssistente copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> apagadoEm = const Value.absent(),
    PapelMensagem? papel,
    String? texto,
    bool? naFila,
    Value<String?> itemTipo = const Value.absent(),
    Value<String?> itemId = const Value.absent(),
    bool? desfeita,
  }) => MensagemAssistente(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    apagadoEm: apagadoEm.present ? apagadoEm.value : this.apagadoEm,
    papel: papel ?? this.papel,
    texto: texto ?? this.texto,
    naFila: naFila ?? this.naFila,
    itemTipo: itemTipo.present ? itemTipo.value : this.itemTipo,
    itemId: itemId.present ? itemId.value : this.itemId,
    desfeita: desfeita ?? this.desfeita,
  );
  MensagemAssistente copyWithCompanion(MensagensAssistenteCompanion data) {
    return MensagemAssistente(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      apagadoEm: data.apagadoEm.present ? data.apagadoEm.value : this.apagadoEm,
      papel: data.papel.present ? data.papel.value : this.papel,
      texto: data.texto.present ? data.texto.value : this.texto,
      naFila: data.naFila.present ? data.naFila.value : this.naFila,
      itemTipo: data.itemTipo.present ? data.itemTipo.value : this.itemTipo,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      desfeita: data.desfeita.present ? data.desfeita.value : this.desfeita,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MensagemAssistente(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('papel: $papel, ')
          ..write('texto: $texto, ')
          ..write('naFila: $naFila, ')
          ..write('itemTipo: $itemTipo, ')
          ..write('itemId: $itemId, ')
          ..write('desfeita: $desfeita')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    papel,
    texto,
    naFila,
    itemTipo,
    itemId,
    desfeita,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MensagemAssistente &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.apagadoEm == this.apagadoEm &&
          other.papel == this.papel &&
          other.texto == this.texto &&
          other.naFila == this.naFila &&
          other.itemTipo == this.itemTipo &&
          other.itemId == this.itemId &&
          other.desfeita == this.desfeita);
}

class MensagensAssistenteCompanion extends UpdateCompanion<MensagemAssistente> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> apagadoEm;
  final Value<PapelMensagem> papel;
  final Value<String> texto;
  final Value<bool> naFila;
  final Value<String?> itemTipo;
  final Value<String?> itemId;
  final Value<bool> desfeita;
  final Value<int> rowid;
  const MensagensAssistenteCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    this.papel = const Value.absent(),
    this.texto = const Value.absent(),
    this.naFila = const Value.absent(),
    this.itemTipo = const Value.absent(),
    this.itemId = const Value.absent(),
    this.desfeita = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MensagensAssistenteCompanion.insert({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    required PapelMensagem papel,
    required String texto,
    this.naFila = const Value.absent(),
    this.itemTipo = const Value.absent(),
    this.itemId = const Value.absent(),
    this.desfeita = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : papel = Value(papel),
       texto = Value(texto);
  static Insertable<MensagemAssistente> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? apagadoEm,
    Expression<String>? papel,
    Expression<String>? texto,
    Expression<bool>? naFila,
    Expression<String>? itemTipo,
    Expression<String>? itemId,
    Expression<bool>? desfeita,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (apagadoEm != null) 'apagado_em': apagadoEm,
      if (papel != null) 'papel': papel,
      if (texto != null) 'texto': texto,
      if (naFila != null) 'na_fila': naFila,
      if (itemTipo != null) 'item_tipo': itemTipo,
      if (itemId != null) 'item_id': itemId,
      if (desfeita != null) 'desfeita': desfeita,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MensagensAssistenteCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? apagadoEm,
    Value<PapelMensagem>? papel,
    Value<String>? texto,
    Value<bool>? naFila,
    Value<String?>? itemTipo,
    Value<String?>? itemId,
    Value<bool>? desfeita,
    Value<int>? rowid,
  }) {
    return MensagensAssistenteCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      apagadoEm: apagadoEm ?? this.apagadoEm,
      papel: papel ?? this.papel,
      texto: texto ?? this.texto,
      naFila: naFila ?? this.naFila,
      itemTipo: itemTipo ?? this.itemTipo,
      itemId: itemId ?? this.itemId,
      desfeita: desfeita ?? this.desfeita,
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
    if (papel.present) {
      map['papel'] = Variable<String>(
        $MensagensAssistenteTable.$converterpapel.toSql(papel.value),
      );
    }
    if (texto.present) {
      map['texto'] = Variable<String>(texto.value);
    }
    if (naFila.present) {
      map['na_fila'] = Variable<bool>(naFila.value);
    }
    if (itemTipo.present) {
      map['item_tipo'] = Variable<String>(itemTipo.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (desfeita.present) {
      map['desfeita'] = Variable<bool>(desfeita.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MensagensAssistenteCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('papel: $papel, ')
          ..write('texto: $texto, ')
          ..write('naFila: $naFila, ')
          ..write('itemTipo: $itemTipo, ')
          ..write('itemId: $itemId, ')
          ..write('desfeita: $desfeita, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AutomacoesTable extends Automacoes
    with TableInfo<$AutomacoesTable, Automacao> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AutomacoesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _modeloMeta = const VerificationMeta('modelo');
  @override
  late final GeneratedColumn<String> modelo = GeneratedColumn<String>(
    'modelo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ativaMeta = const VerificationMeta('ativa');
  @override
  late final GeneratedColumn<bool> ativa = GeneratedColumn<bool>(
    'ativa',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ativa" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pedidoMeta = const VerificationMeta('pedido');
  @override
  late final GeneratedColumn<String> pedido = GeneratedColumn<String>(
    'pedido',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ultimaExecucaoMeta = const VerificationMeta(
    'ultimaExecucao',
  );
  @override
  late final GeneratedColumn<String> ultimaExecucao = GeneratedColumn<String>(
    'ultima_execucao',
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
    nome,
    modelo,
    diasSemana,
    horario,
    ativa,
    pedido,
    ultimaExecucao,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'automacoes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Automacao> instance, {
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
    if (data.containsKey('modelo')) {
      context.handle(
        _modeloMeta,
        modelo.isAcceptableOrUnknown(data['modelo']!, _modeloMeta),
      );
    } else if (isInserting) {
      context.missing(_modeloMeta);
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
    } else if (isInserting) {
      context.missing(_horarioMeta);
    }
    if (data.containsKey('ativa')) {
      context.handle(
        _ativaMeta,
        ativa.isAcceptableOrUnknown(data['ativa']!, _ativaMeta),
      );
    }
    if (data.containsKey('pedido')) {
      context.handle(
        _pedidoMeta,
        pedido.isAcceptableOrUnknown(data['pedido']!, _pedidoMeta),
      );
    }
    if (data.containsKey('ultima_execucao')) {
      context.handle(
        _ultimaExecucaoMeta,
        ultimaExecucao.isAcceptableOrUnknown(
          data['ultima_execucao']!,
          _ultimaExecucaoMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Automacao map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Automacao(
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
      modelo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modelo'],
      )!,
      diasSemana: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dias_semana'],
      )!,
      horario: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}horario'],
      )!,
      ativa: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ativa'],
      )!,
      pedido: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pedido'],
      ),
      ultimaExecucao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ultima_execucao'],
      ),
    );
  }

  @override
  $AutomacoesTable createAlias(String alias) {
    return $AutomacoesTable(attachedDatabase, alias);
  }
}

class Automacao extends DataClass implements Insertable<Automacao> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? apagadoEm;
  final String nome;
  final String modelo;

  /// Bits de segunda (1) a domingo (64).
  final int diasSemana;

  /// "HH:mm".
  final String horario;
  final bool ativa;
  final String? pedido;

  /// "aaaa-mm-dd HH:mm" da última ocorrência executada (em qualquer aparelho).
  final String? ultimaExecucao;
  const Automacao({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.apagadoEm,
    required this.nome,
    required this.modelo,
    required this.diasSemana,
    required this.horario,
    required this.ativa,
    this.pedido,
    this.ultimaExecucao,
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
    map['modelo'] = Variable<String>(modelo);
    map['dias_semana'] = Variable<int>(diasSemana);
    map['horario'] = Variable<String>(horario);
    map['ativa'] = Variable<bool>(ativa);
    if (!nullToAbsent || pedido != null) {
      map['pedido'] = Variable<String>(pedido);
    }
    if (!nullToAbsent || ultimaExecucao != null) {
      map['ultima_execucao'] = Variable<String>(ultimaExecucao);
    }
    return map;
  }

  AutomacoesCompanion toCompanion(bool nullToAbsent) {
    return AutomacoesCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      apagadoEm: apagadoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(apagadoEm),
      nome: Value(nome),
      modelo: Value(modelo),
      diasSemana: Value(diasSemana),
      horario: Value(horario),
      ativa: Value(ativa),
      pedido: pedido == null && nullToAbsent
          ? const Value.absent()
          : Value(pedido),
      ultimaExecucao: ultimaExecucao == null && nullToAbsent
          ? const Value.absent()
          : Value(ultimaExecucao),
    );
  }

  factory Automacao.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Automacao(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      apagadoEm: serializer.fromJson<DateTime?>(json['apagadoEm']),
      nome: serializer.fromJson<String>(json['nome']),
      modelo: serializer.fromJson<String>(json['modelo']),
      diasSemana: serializer.fromJson<int>(json['diasSemana']),
      horario: serializer.fromJson<String>(json['horario']),
      ativa: serializer.fromJson<bool>(json['ativa']),
      pedido: serializer.fromJson<String?>(json['pedido']),
      ultimaExecucao: serializer.fromJson<String?>(json['ultimaExecucao']),
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
      'modelo': serializer.toJson<String>(modelo),
      'diasSemana': serializer.toJson<int>(diasSemana),
      'horario': serializer.toJson<String>(horario),
      'ativa': serializer.toJson<bool>(ativa),
      'pedido': serializer.toJson<String?>(pedido),
      'ultimaExecucao': serializer.toJson<String?>(ultimaExecucao),
    };
  }

  Automacao copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> apagadoEm = const Value.absent(),
    String? nome,
    String? modelo,
    int? diasSemana,
    String? horario,
    bool? ativa,
    Value<String?> pedido = const Value.absent(),
    Value<String?> ultimaExecucao = const Value.absent(),
  }) => Automacao(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    apagadoEm: apagadoEm.present ? apagadoEm.value : this.apagadoEm,
    nome: nome ?? this.nome,
    modelo: modelo ?? this.modelo,
    diasSemana: diasSemana ?? this.diasSemana,
    horario: horario ?? this.horario,
    ativa: ativa ?? this.ativa,
    pedido: pedido.present ? pedido.value : this.pedido,
    ultimaExecucao: ultimaExecucao.present
        ? ultimaExecucao.value
        : this.ultimaExecucao,
  );
  Automacao copyWithCompanion(AutomacoesCompanion data) {
    return Automacao(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      apagadoEm: data.apagadoEm.present ? data.apagadoEm.value : this.apagadoEm,
      nome: data.nome.present ? data.nome.value : this.nome,
      modelo: data.modelo.present ? data.modelo.value : this.modelo,
      diasSemana: data.diasSemana.present
          ? data.diasSemana.value
          : this.diasSemana,
      horario: data.horario.present ? data.horario.value : this.horario,
      ativa: data.ativa.present ? data.ativa.value : this.ativa,
      pedido: data.pedido.present ? data.pedido.value : this.pedido,
      ultimaExecucao: data.ultimaExecucao.present
          ? data.ultimaExecucao.value
          : this.ultimaExecucao,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Automacao(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('nome: $nome, ')
          ..write('modelo: $modelo, ')
          ..write('diasSemana: $diasSemana, ')
          ..write('horario: $horario, ')
          ..write('ativa: $ativa, ')
          ..write('pedido: $pedido, ')
          ..write('ultimaExecucao: $ultimaExecucao')
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
    modelo,
    diasSemana,
    horario,
    ativa,
    pedido,
    ultimaExecucao,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Automacao &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.apagadoEm == this.apagadoEm &&
          other.nome == this.nome &&
          other.modelo == this.modelo &&
          other.diasSemana == this.diasSemana &&
          other.horario == this.horario &&
          other.ativa == this.ativa &&
          other.pedido == this.pedido &&
          other.ultimaExecucao == this.ultimaExecucao);
}

class AutomacoesCompanion extends UpdateCompanion<Automacao> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> apagadoEm;
  final Value<String> nome;
  final Value<String> modelo;
  final Value<int> diasSemana;
  final Value<String> horario;
  final Value<bool> ativa;
  final Value<String?> pedido;
  final Value<String?> ultimaExecucao;
  final Value<int> rowid;
  const AutomacoesCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    this.nome = const Value.absent(),
    this.modelo = const Value.absent(),
    this.diasSemana = const Value.absent(),
    this.horario = const Value.absent(),
    this.ativa = const Value.absent(),
    this.pedido = const Value.absent(),
    this.ultimaExecucao = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AutomacoesCompanion.insert({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    required String nome,
    required String modelo,
    this.diasSemana = const Value.absent(),
    required String horario,
    this.ativa = const Value.absent(),
    this.pedido = const Value.absent(),
    this.ultimaExecucao = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : nome = Value(nome),
       modelo = Value(modelo),
       horario = Value(horario);
  static Insertable<Automacao> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? apagadoEm,
    Expression<String>? nome,
    Expression<String>? modelo,
    Expression<int>? diasSemana,
    Expression<String>? horario,
    Expression<bool>? ativa,
    Expression<String>? pedido,
    Expression<String>? ultimaExecucao,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (apagadoEm != null) 'apagado_em': apagadoEm,
      if (nome != null) 'nome': nome,
      if (modelo != null) 'modelo': modelo,
      if (diasSemana != null) 'dias_semana': diasSemana,
      if (horario != null) 'horario': horario,
      if (ativa != null) 'ativa': ativa,
      if (pedido != null) 'pedido': pedido,
      if (ultimaExecucao != null) 'ultima_execucao': ultimaExecucao,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AutomacoesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? apagadoEm,
    Value<String>? nome,
    Value<String>? modelo,
    Value<int>? diasSemana,
    Value<String>? horario,
    Value<bool>? ativa,
    Value<String?>? pedido,
    Value<String?>? ultimaExecucao,
    Value<int>? rowid,
  }) {
    return AutomacoesCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      apagadoEm: apagadoEm ?? this.apagadoEm,
      nome: nome ?? this.nome,
      modelo: modelo ?? this.modelo,
      diasSemana: diasSemana ?? this.diasSemana,
      horario: horario ?? this.horario,
      ativa: ativa ?? this.ativa,
      pedido: pedido ?? this.pedido,
      ultimaExecucao: ultimaExecucao ?? this.ultimaExecucao,
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
    if (modelo.present) {
      map['modelo'] = Variable<String>(modelo.value);
    }
    if (diasSemana.present) {
      map['dias_semana'] = Variable<int>(diasSemana.value);
    }
    if (horario.present) {
      map['horario'] = Variable<String>(horario.value);
    }
    if (ativa.present) {
      map['ativa'] = Variable<bool>(ativa.value);
    }
    if (pedido.present) {
      map['pedido'] = Variable<String>(pedido.value);
    }
    if (ultimaExecucao.present) {
      map['ultima_execucao'] = Variable<String>(ultimaExecucao.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AutomacoesCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('nome: $nome, ')
          ..write('modelo: $modelo, ')
          ..write('diasSemana: $diasSemana, ')
          ..write('horario: $horario, ')
          ..write('ativa: $ativa, ')
          ..write('pedido: $pedido, ')
          ..write('ultimaExecucao: $ultimaExecucao, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PastasNotasTable extends PastasNotas
    with TableInfo<$PastasNotasTable, PastaNota> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PastasNotasTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _ordemMeta = const VerificationMeta('ordem');
  @override
  late final GeneratedColumn<int> ordem = GeneratedColumn<int>(
    'ordem',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    nome,
    ordem,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pastas_notas';
  @override
  VerificationContext validateIntegrity(
    Insertable<PastaNota> instance, {
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
    if (data.containsKey('ordem')) {
      context.handle(
        _ordemMeta,
        ordem.isAcceptableOrUnknown(data['ordem']!, _ordemMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PastaNota map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PastaNota(
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
      ordem: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordem'],
      )!,
    );
  }

  @override
  $PastasNotasTable createAlias(String alias) {
    return $PastasNotasTable(attachedDatabase, alias);
  }
}

class PastaNota extends DataClass implements Insertable<PastaNota> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? apagadoEm;
  final String nome;
  final int ordem;
  const PastaNota({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.apagadoEm,
    required this.nome,
    required this.ordem,
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
    map['ordem'] = Variable<int>(ordem);
    return map;
  }

  PastasNotasCompanion toCompanion(bool nullToAbsent) {
    return PastasNotasCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      apagadoEm: apagadoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(apagadoEm),
      nome: Value(nome),
      ordem: Value(ordem),
    );
  }

  factory PastaNota.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PastaNota(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      apagadoEm: serializer.fromJson<DateTime?>(json['apagadoEm']),
      nome: serializer.fromJson<String>(json['nome']),
      ordem: serializer.fromJson<int>(json['ordem']),
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
      'ordem': serializer.toJson<int>(ordem),
    };
  }

  PastaNota copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> apagadoEm = const Value.absent(),
    String? nome,
    int? ordem,
  }) => PastaNota(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    apagadoEm: apagadoEm.present ? apagadoEm.value : this.apagadoEm,
    nome: nome ?? this.nome,
    ordem: ordem ?? this.ordem,
  );
  PastaNota copyWithCompanion(PastasNotasCompanion data) {
    return PastaNota(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      apagadoEm: data.apagadoEm.present ? data.apagadoEm.value : this.apagadoEm,
      nome: data.nome.present ? data.nome.value : this.nome,
      ordem: data.ordem.present ? data.ordem.value : this.ordem,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PastaNota(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('nome: $nome, ')
          ..write('ordem: $ordem')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, criadoEm, atualizadoEm, apagadoEm, nome, ordem);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PastaNota &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.apagadoEm == this.apagadoEm &&
          other.nome == this.nome &&
          other.ordem == this.ordem);
}

class PastasNotasCompanion extends UpdateCompanion<PastaNota> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> apagadoEm;
  final Value<String> nome;
  final Value<int> ordem;
  final Value<int> rowid;
  const PastasNotasCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    this.nome = const Value.absent(),
    this.ordem = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PastasNotasCompanion.insert({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    required String nome,
    this.ordem = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : nome = Value(nome);
  static Insertable<PastaNota> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? apagadoEm,
    Expression<String>? nome,
    Expression<int>? ordem,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (apagadoEm != null) 'apagado_em': apagadoEm,
      if (nome != null) 'nome': nome,
      if (ordem != null) 'ordem': ordem,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PastasNotasCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? apagadoEm,
    Value<String>? nome,
    Value<int>? ordem,
    Value<int>? rowid,
  }) {
    return PastasNotasCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      apagadoEm: apagadoEm ?? this.apagadoEm,
      nome: nome ?? this.nome,
      ordem: ordem ?? this.ordem,
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
    if (ordem.present) {
      map['ordem'] = Variable<int>(ordem.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PastasNotasCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('nome: $nome, ')
          ..write('ordem: $ordem, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotasTable extends Notas with TableInfo<$NotasTable, Nota> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotasTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _pastaIdMeta = const VerificationMeta(
    'pastaId',
  );
  @override
  late final GeneratedColumn<String> pastaId = GeneratedColumn<String>(
    'pasta_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pastas_notas (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoNota, String> tipo =
      GeneratedColumn<String>(
        'tipo',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(TipoNota.texto.name),
      ).withConverter<TipoNota>($NotasTable.$convertertipo);
  static const VerificationMeta _tituloMeta = const VerificationMeta('titulo');
  @override
  late final GeneratedColumn<String> titulo = GeneratedColumn<String>(
    'titulo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _textoMeta = const VerificationMeta('texto');
  @override
  late final GeneratedColumn<String> texto = GeneratedColumn<String>(
    'texto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _itensMeta = const VerificationMeta('itens');
  @override
  late final GeneratedColumn<String> itens = GeneratedColumn<String>(
    'itens',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fixadaMeta = const VerificationMeta('fixada');
  @override
  late final GeneratedColumn<bool> fixada = GeneratedColumn<bool>(
    'fixada',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("fixada" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    pastaId,
    tipo,
    titulo,
    texto,
    itens,
    fixada,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Nota> instance, {
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
    if (data.containsKey('pasta_id')) {
      context.handle(
        _pastaIdMeta,
        pastaId.isAcceptableOrUnknown(data['pasta_id']!, _pastaIdMeta),
      );
    }
    if (data.containsKey('titulo')) {
      context.handle(
        _tituloMeta,
        titulo.isAcceptableOrUnknown(data['titulo']!, _tituloMeta),
      );
    }
    if (data.containsKey('texto')) {
      context.handle(
        _textoMeta,
        texto.isAcceptableOrUnknown(data['texto']!, _textoMeta),
      );
    }
    if (data.containsKey('itens')) {
      context.handle(
        _itensMeta,
        itens.isAcceptableOrUnknown(data['itens']!, _itensMeta),
      );
    }
    if (data.containsKey('fixada')) {
      context.handle(
        _fixadaMeta,
        fixada.isAcceptableOrUnknown(data['fixada']!, _fixadaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Nota map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Nota(
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
      pastaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pasta_id'],
      ),
      tipo: $NotasTable.$convertertipo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tipo'],
        )!,
      ),
      titulo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titulo'],
      )!,
      texto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}texto'],
      )!,
      itens: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}itens'],
      ),
      fixada: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}fixada'],
      )!,
    );
  }

  @override
  $NotasTable createAlias(String alias) {
    return $NotasTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoNota, String, String> $convertertipo =
      const EnumNameConverter<TipoNota>(TipoNota.values);
}

class Nota extends DataClass implements Insertable<Nota> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? apagadoEm;
  final String? pastaId;
  final TipoNota tipo;
  final String titulo;
  final String texto;
  final String? itens;
  final bool fixada;
  const Nota({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.apagadoEm,
    this.pastaId,
    required this.tipo,
    required this.titulo,
    required this.texto,
    this.itens,
    required this.fixada,
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
    if (!nullToAbsent || pastaId != null) {
      map['pasta_id'] = Variable<String>(pastaId);
    }
    {
      map['tipo'] = Variable<String>($NotasTable.$convertertipo.toSql(tipo));
    }
    map['titulo'] = Variable<String>(titulo);
    map['texto'] = Variable<String>(texto);
    if (!nullToAbsent || itens != null) {
      map['itens'] = Variable<String>(itens);
    }
    map['fixada'] = Variable<bool>(fixada);
    return map;
  }

  NotasCompanion toCompanion(bool nullToAbsent) {
    return NotasCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      apagadoEm: apagadoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(apagadoEm),
      pastaId: pastaId == null && nullToAbsent
          ? const Value.absent()
          : Value(pastaId),
      tipo: Value(tipo),
      titulo: Value(titulo),
      texto: Value(texto),
      itens: itens == null && nullToAbsent
          ? const Value.absent()
          : Value(itens),
      fixada: Value(fixada),
    );
  }

  factory Nota.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Nota(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      apagadoEm: serializer.fromJson<DateTime?>(json['apagadoEm']),
      pastaId: serializer.fromJson<String?>(json['pastaId']),
      tipo: $NotasTable.$convertertipo.fromJson(
        serializer.fromJson<String>(json['tipo']),
      ),
      titulo: serializer.fromJson<String>(json['titulo']),
      texto: serializer.fromJson<String>(json['texto']),
      itens: serializer.fromJson<String?>(json['itens']),
      fixada: serializer.fromJson<bool>(json['fixada']),
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
      'pastaId': serializer.toJson<String?>(pastaId),
      'tipo': serializer.toJson<String>(
        $NotasTable.$convertertipo.toJson(tipo),
      ),
      'titulo': serializer.toJson<String>(titulo),
      'texto': serializer.toJson<String>(texto),
      'itens': serializer.toJson<String?>(itens),
      'fixada': serializer.toJson<bool>(fixada),
    };
  }

  Nota copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> apagadoEm = const Value.absent(),
    Value<String?> pastaId = const Value.absent(),
    TipoNota? tipo,
    String? titulo,
    String? texto,
    Value<String?> itens = const Value.absent(),
    bool? fixada,
  }) => Nota(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    apagadoEm: apagadoEm.present ? apagadoEm.value : this.apagadoEm,
    pastaId: pastaId.present ? pastaId.value : this.pastaId,
    tipo: tipo ?? this.tipo,
    titulo: titulo ?? this.titulo,
    texto: texto ?? this.texto,
    itens: itens.present ? itens.value : this.itens,
    fixada: fixada ?? this.fixada,
  );
  Nota copyWithCompanion(NotasCompanion data) {
    return Nota(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      apagadoEm: data.apagadoEm.present ? data.apagadoEm.value : this.apagadoEm,
      pastaId: data.pastaId.present ? data.pastaId.value : this.pastaId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      titulo: data.titulo.present ? data.titulo.value : this.titulo,
      texto: data.texto.present ? data.texto.value : this.texto,
      itens: data.itens.present ? data.itens.value : this.itens,
      fixada: data.fixada.present ? data.fixada.value : this.fixada,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Nota(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('pastaId: $pastaId, ')
          ..write('tipo: $tipo, ')
          ..write('titulo: $titulo, ')
          ..write('texto: $texto, ')
          ..write('itens: $itens, ')
          ..write('fixada: $fixada')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    pastaId,
    tipo,
    titulo,
    texto,
    itens,
    fixada,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Nota &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.apagadoEm == this.apagadoEm &&
          other.pastaId == this.pastaId &&
          other.tipo == this.tipo &&
          other.titulo == this.titulo &&
          other.texto == this.texto &&
          other.itens == this.itens &&
          other.fixada == this.fixada);
}

class NotasCompanion extends UpdateCompanion<Nota> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> apagadoEm;
  final Value<String?> pastaId;
  final Value<TipoNota> tipo;
  final Value<String> titulo;
  final Value<String> texto;
  final Value<String?> itens;
  final Value<bool> fixada;
  final Value<int> rowid;
  const NotasCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    this.pastaId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.titulo = const Value.absent(),
    this.texto = const Value.absent(),
    this.itens = const Value.absent(),
    this.fixada = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotasCompanion.insert({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    this.pastaId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.titulo = const Value.absent(),
    this.texto = const Value.absent(),
    this.itens = const Value.absent(),
    this.fixada = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<Nota> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? apagadoEm,
    Expression<String>? pastaId,
    Expression<String>? tipo,
    Expression<String>? titulo,
    Expression<String>? texto,
    Expression<String>? itens,
    Expression<bool>? fixada,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (apagadoEm != null) 'apagado_em': apagadoEm,
      if (pastaId != null) 'pasta_id': pastaId,
      if (tipo != null) 'tipo': tipo,
      if (titulo != null) 'titulo': titulo,
      if (texto != null) 'texto': texto,
      if (itens != null) 'itens': itens,
      if (fixada != null) 'fixada': fixada,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotasCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? apagadoEm,
    Value<String?>? pastaId,
    Value<TipoNota>? tipo,
    Value<String>? titulo,
    Value<String>? texto,
    Value<String?>? itens,
    Value<bool>? fixada,
    Value<int>? rowid,
  }) {
    return NotasCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      apagadoEm: apagadoEm ?? this.apagadoEm,
      pastaId: pastaId ?? this.pastaId,
      tipo: tipo ?? this.tipo,
      titulo: titulo ?? this.titulo,
      texto: texto ?? this.texto,
      itens: itens ?? this.itens,
      fixada: fixada ?? this.fixada,
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
    if (pastaId.present) {
      map['pasta_id'] = Variable<String>(pastaId.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(
        $NotasTable.$convertertipo.toSql(tipo.value),
      );
    }
    if (titulo.present) {
      map['titulo'] = Variable<String>(titulo.value);
    }
    if (texto.present) {
      map['texto'] = Variable<String>(texto.value);
    }
    if (itens.present) {
      map['itens'] = Variable<String>(itens.value);
    }
    if (fixada.present) {
      map['fixada'] = Variable<bool>(fixada.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotasCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('pastaId: $pastaId, ')
          ..write('tipo: $tipo, ')
          ..write('titulo: $titulo, ')
          ..write('texto: $texto, ')
          ..write('itens: $itens, ')
          ..write('fixada: $fixada, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnexosNotaTable extends AnexosNota
    with TableInfo<$AnexosNotaTable, AnexoNota> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnexosNotaTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _notaIdMeta = const VerificationMeta('notaId');
  @override
  late final GeneratedColumn<String> notaId = GeneratedColumn<String>(
    'nota_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES notas (id)',
    ),
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hashMeta = const VerificationMeta('hash');
  @override
  late final GeneratedColumn<String> hash = GeneratedColumn<String>(
    'hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _naNuvemMeta = const VerificationMeta(
    'naNuvem',
  );
  @override
  late final GeneratedColumn<bool> naNuvem = GeneratedColumn<bool>(
    'na_nuvem',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("na_nuvem" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _formatoMeta = const VerificationMeta(
    'formato',
  );
  @override
  late final GeneratedColumn<String> formato = GeneratedColumn<String>(
    'formato',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _duracaoMsMeta = const VerificationMeta(
    'duracaoMs',
  );
  @override
  late final GeneratedColumn<int> duracaoMs = GeneratedColumn<int>(
    'duracao_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ondaMeta = const VerificationMeta('onda');
  @override
  late final GeneratedColumn<String> onda = GeneratedColumn<String>(
    'onda',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transcricaoMeta = const VerificationMeta(
    'transcricao',
  );
  @override
  late final GeneratedColumn<String> transcricao = GeneratedColumn<String>(
    'transcricao',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ordemMeta = const VerificationMeta('ordem');
  @override
  late final GeneratedColumn<int> ordem = GeneratedColumn<int>(
    'ordem',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    notaId,
    tipo,
    hash,
    naNuvem,
    formato,
    duracaoMs,
    onda,
    transcricao,
    ordem,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'anexos_nota';
  @override
  VerificationContext validateIntegrity(
    Insertable<AnexoNota> instance, {
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
    if (data.containsKey('nota_id')) {
      context.handle(
        _notaIdMeta,
        notaId.isAcceptableOrUnknown(data['nota_id']!, _notaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_notaIdMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('hash')) {
      context.handle(
        _hashMeta,
        hash.isAcceptableOrUnknown(data['hash']!, _hashMeta),
      );
    }
    if (data.containsKey('na_nuvem')) {
      context.handle(
        _naNuvemMeta,
        naNuvem.isAcceptableOrUnknown(data['na_nuvem']!, _naNuvemMeta),
      );
    }
    if (data.containsKey('formato')) {
      context.handle(
        _formatoMeta,
        formato.isAcceptableOrUnknown(data['formato']!, _formatoMeta),
      );
    }
    if (data.containsKey('duracao_ms')) {
      context.handle(
        _duracaoMsMeta,
        duracaoMs.isAcceptableOrUnknown(data['duracao_ms']!, _duracaoMsMeta),
      );
    }
    if (data.containsKey('onda')) {
      context.handle(
        _ondaMeta,
        onda.isAcceptableOrUnknown(data['onda']!, _ondaMeta),
      );
    }
    if (data.containsKey('transcricao')) {
      context.handle(
        _transcricaoMeta,
        transcricao.isAcceptableOrUnknown(
          data['transcricao']!,
          _transcricaoMeta,
        ),
      );
    }
    if (data.containsKey('ordem')) {
      context.handle(
        _ordemMeta,
        ordem.isAcceptableOrUnknown(data['ordem']!, _ordemMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnexoNota map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnexoNota(
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
      notaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nota_id'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      hash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hash'],
      ),
      naNuvem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}na_nuvem'],
      )!,
      formato: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}formato'],
      ),
      duracaoMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duracao_ms'],
      ),
      onda: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}onda'],
      ),
      transcricao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcricao'],
      ),
      ordem: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordem'],
      )!,
    );
  }

  @override
  $AnexosNotaTable createAlias(String alias) {
    return $AnexosNotaTable(attachedDatabase, alias);
  }
}

class AnexoNota extends DataClass implements Insertable<AnexoNota> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? apagadoEm;
  final String notaId;

  /// 'foto' ou 'audio'.
  final String tipo;
  final String? hash;
  final bool naNuvem;

  /// Tipo do arquivo de áudio ("audio/mp4", "audio/flac", "audio/wav").
  final String? formato;
  final int? duracaoMs;

  /// Volume do áudio em 48 dígitos de 0 a 9, para desenhar a onda sem abrir o arquivo.
  final String? onda;

  /// Texto do áudio: nulo até transcrever; vazio se não havia fala.
  final String? transcricao;
  final int ordem;
  const AnexoNota({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.apagadoEm,
    required this.notaId,
    required this.tipo,
    this.hash,
    required this.naNuvem,
    this.formato,
    this.duracaoMs,
    this.onda,
    this.transcricao,
    required this.ordem,
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
    map['nota_id'] = Variable<String>(notaId);
    map['tipo'] = Variable<String>(tipo);
    if (!nullToAbsent || hash != null) {
      map['hash'] = Variable<String>(hash);
    }
    map['na_nuvem'] = Variable<bool>(naNuvem);
    if (!nullToAbsent || formato != null) {
      map['formato'] = Variable<String>(formato);
    }
    if (!nullToAbsent || duracaoMs != null) {
      map['duracao_ms'] = Variable<int>(duracaoMs);
    }
    if (!nullToAbsent || onda != null) {
      map['onda'] = Variable<String>(onda);
    }
    if (!nullToAbsent || transcricao != null) {
      map['transcricao'] = Variable<String>(transcricao);
    }
    map['ordem'] = Variable<int>(ordem);
    return map;
  }

  AnexosNotaCompanion toCompanion(bool nullToAbsent) {
    return AnexosNotaCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      apagadoEm: apagadoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(apagadoEm),
      notaId: Value(notaId),
      tipo: Value(tipo),
      hash: hash == null && nullToAbsent ? const Value.absent() : Value(hash),
      naNuvem: Value(naNuvem),
      formato: formato == null && nullToAbsent
          ? const Value.absent()
          : Value(formato),
      duracaoMs: duracaoMs == null && nullToAbsent
          ? const Value.absent()
          : Value(duracaoMs),
      onda: onda == null && nullToAbsent ? const Value.absent() : Value(onda),
      transcricao: transcricao == null && nullToAbsent
          ? const Value.absent()
          : Value(transcricao),
      ordem: Value(ordem),
    );
  }

  factory AnexoNota.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnexoNota(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      apagadoEm: serializer.fromJson<DateTime?>(json['apagadoEm']),
      notaId: serializer.fromJson<String>(json['notaId']),
      tipo: serializer.fromJson<String>(json['tipo']),
      hash: serializer.fromJson<String?>(json['hash']),
      naNuvem: serializer.fromJson<bool>(json['naNuvem']),
      formato: serializer.fromJson<String?>(json['formato']),
      duracaoMs: serializer.fromJson<int?>(json['duracaoMs']),
      onda: serializer.fromJson<String?>(json['onda']),
      transcricao: serializer.fromJson<String?>(json['transcricao']),
      ordem: serializer.fromJson<int>(json['ordem']),
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
      'notaId': serializer.toJson<String>(notaId),
      'tipo': serializer.toJson<String>(tipo),
      'hash': serializer.toJson<String?>(hash),
      'naNuvem': serializer.toJson<bool>(naNuvem),
      'formato': serializer.toJson<String?>(formato),
      'duracaoMs': serializer.toJson<int?>(duracaoMs),
      'onda': serializer.toJson<String?>(onda),
      'transcricao': serializer.toJson<String?>(transcricao),
      'ordem': serializer.toJson<int>(ordem),
    };
  }

  AnexoNota copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> apagadoEm = const Value.absent(),
    String? notaId,
    String? tipo,
    Value<String?> hash = const Value.absent(),
    bool? naNuvem,
    Value<String?> formato = const Value.absent(),
    Value<int?> duracaoMs = const Value.absent(),
    Value<String?> onda = const Value.absent(),
    Value<String?> transcricao = const Value.absent(),
    int? ordem,
  }) => AnexoNota(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    apagadoEm: apagadoEm.present ? apagadoEm.value : this.apagadoEm,
    notaId: notaId ?? this.notaId,
    tipo: tipo ?? this.tipo,
    hash: hash.present ? hash.value : this.hash,
    naNuvem: naNuvem ?? this.naNuvem,
    formato: formato.present ? formato.value : this.formato,
    duracaoMs: duracaoMs.present ? duracaoMs.value : this.duracaoMs,
    onda: onda.present ? onda.value : this.onda,
    transcricao: transcricao.present ? transcricao.value : this.transcricao,
    ordem: ordem ?? this.ordem,
  );
  AnexoNota copyWithCompanion(AnexosNotaCompanion data) {
    return AnexoNota(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      apagadoEm: data.apagadoEm.present ? data.apagadoEm.value : this.apagadoEm,
      notaId: data.notaId.present ? data.notaId.value : this.notaId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      hash: data.hash.present ? data.hash.value : this.hash,
      naNuvem: data.naNuvem.present ? data.naNuvem.value : this.naNuvem,
      formato: data.formato.present ? data.formato.value : this.formato,
      duracaoMs: data.duracaoMs.present ? data.duracaoMs.value : this.duracaoMs,
      onda: data.onda.present ? data.onda.value : this.onda,
      transcricao: data.transcricao.present
          ? data.transcricao.value
          : this.transcricao,
      ordem: data.ordem.present ? data.ordem.value : this.ordem,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnexoNota(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('notaId: $notaId, ')
          ..write('tipo: $tipo, ')
          ..write('hash: $hash, ')
          ..write('naNuvem: $naNuvem, ')
          ..write('formato: $formato, ')
          ..write('duracaoMs: $duracaoMs, ')
          ..write('onda: $onda, ')
          ..write('transcricao: $transcricao, ')
          ..write('ordem: $ordem')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    apagadoEm,
    notaId,
    tipo,
    hash,
    naNuvem,
    formato,
    duracaoMs,
    onda,
    transcricao,
    ordem,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnexoNota &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.apagadoEm == this.apagadoEm &&
          other.notaId == this.notaId &&
          other.tipo == this.tipo &&
          other.hash == this.hash &&
          other.naNuvem == this.naNuvem &&
          other.formato == this.formato &&
          other.duracaoMs == this.duracaoMs &&
          other.onda == this.onda &&
          other.transcricao == this.transcricao &&
          other.ordem == this.ordem);
}

class AnexosNotaCompanion extends UpdateCompanion<AnexoNota> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> apagadoEm;
  final Value<String> notaId;
  final Value<String> tipo;
  final Value<String?> hash;
  final Value<bool> naNuvem;
  final Value<String?> formato;
  final Value<int?> duracaoMs;
  final Value<String?> onda;
  final Value<String?> transcricao;
  final Value<int> ordem;
  final Value<int> rowid;
  const AnexosNotaCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    this.notaId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.hash = const Value.absent(),
    this.naNuvem = const Value.absent(),
    this.formato = const Value.absent(),
    this.duracaoMs = const Value.absent(),
    this.onda = const Value.absent(),
    this.transcricao = const Value.absent(),
    this.ordem = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnexosNotaCompanion.insert({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.apagadoEm = const Value.absent(),
    required String notaId,
    required String tipo,
    this.hash = const Value.absent(),
    this.naNuvem = const Value.absent(),
    this.formato = const Value.absent(),
    this.duracaoMs = const Value.absent(),
    this.onda = const Value.absent(),
    this.transcricao = const Value.absent(),
    this.ordem = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : notaId = Value(notaId),
       tipo = Value(tipo);
  static Insertable<AnexoNota> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? apagadoEm,
    Expression<String>? notaId,
    Expression<String>? tipo,
    Expression<String>? hash,
    Expression<bool>? naNuvem,
    Expression<String>? formato,
    Expression<int>? duracaoMs,
    Expression<String>? onda,
    Expression<String>? transcricao,
    Expression<int>? ordem,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (apagadoEm != null) 'apagado_em': apagadoEm,
      if (notaId != null) 'nota_id': notaId,
      if (tipo != null) 'tipo': tipo,
      if (hash != null) 'hash': hash,
      if (naNuvem != null) 'na_nuvem': naNuvem,
      if (formato != null) 'formato': formato,
      if (duracaoMs != null) 'duracao_ms': duracaoMs,
      if (onda != null) 'onda': onda,
      if (transcricao != null) 'transcricao': transcricao,
      if (ordem != null) 'ordem': ordem,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnexosNotaCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? apagadoEm,
    Value<String>? notaId,
    Value<String>? tipo,
    Value<String?>? hash,
    Value<bool>? naNuvem,
    Value<String?>? formato,
    Value<int?>? duracaoMs,
    Value<String?>? onda,
    Value<String?>? transcricao,
    Value<int>? ordem,
    Value<int>? rowid,
  }) {
    return AnexosNotaCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      apagadoEm: apagadoEm ?? this.apagadoEm,
      notaId: notaId ?? this.notaId,
      tipo: tipo ?? this.tipo,
      hash: hash ?? this.hash,
      naNuvem: naNuvem ?? this.naNuvem,
      formato: formato ?? this.formato,
      duracaoMs: duracaoMs ?? this.duracaoMs,
      onda: onda ?? this.onda,
      transcricao: transcricao ?? this.transcricao,
      ordem: ordem ?? this.ordem,
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
    if (notaId.present) {
      map['nota_id'] = Variable<String>(notaId.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (hash.present) {
      map['hash'] = Variable<String>(hash.value);
    }
    if (naNuvem.present) {
      map['na_nuvem'] = Variable<bool>(naNuvem.value);
    }
    if (formato.present) {
      map['formato'] = Variable<String>(formato.value);
    }
    if (duracaoMs.present) {
      map['duracao_ms'] = Variable<int>(duracaoMs.value);
    }
    if (onda.present) {
      map['onda'] = Variable<String>(onda.value);
    }
    if (transcricao.present) {
      map['transcricao'] = Variable<String>(transcricao.value);
    }
    if (ordem.present) {
      map['ordem'] = Variable<int>(ordem.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnexosNotaCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('apagadoEm: $apagadoEm, ')
          ..write('notaId: $notaId, ')
          ..write('tipo: $tipo, ')
          ..write('hash: $hash, ')
          ..write('naNuvem: $naNuvem, ')
          ..write('formato: $formato, ')
          ..write('duracaoMs: $duracaoMs, ')
          ..write('onda: $onda, ')
          ..write('transcricao: $transcricao, ')
          ..write('ordem: $ordem, ')
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
  late final $ObjetivosTable objetivos = $ObjetivosTable(this);
  late final $EtapasTable etapas = $EtapasTable(this);
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
  late final $PagamentosTransacaoTable pagamentosTransacao =
      $PagamentosTransacaoTable(this);
  late final $LembretesTable lembretes = $LembretesTable(this);
  late final $CompromissosTable compromissos = $CompromissosTable(this);
  late final $ExerciciosTable exercicios = $ExerciciosTable(this);
  late final $TreinosTable treinos = $TreinosTable(this);
  late final $ItensTreinoTable itensTreino = $ItensTreinoTable(this);
  late final $SessoesTreinoTable sessoesTreino = $SessoesTreinoTable(this);
  late final $SeriesFeitasTable seriesFeitas = $SeriesFeitasTable(this);
  late final $MedidasTable medidas = $MedidasTable(this);
  late final $FotosShapeTable fotosShape = $FotosShapeTable(this);
  late final $AlimentosTable alimentos = $AlimentosTable(this);
  late final $AlvosDietaTable alvosDieta = $AlvosDietaTable(this);
  late final $RegistrosAlimentacaoTable registrosAlimentacao =
      $RegistrosAlimentacaoTable(this);
  late final $MensagensAssistenteTable mensagensAssistente =
      $MensagensAssistenteTable(this);
  late final $AutomacoesTable automacoes = $AutomacoesTable(this);
  late final $PastasNotasTable pastasNotas = $PastasNotasTable(this);
  late final $NotasTable notas = $NotasTable(this);
  late final $AnexosNotaTable anexosNota = $AnexosNotaTable(this);
  late final $PreferenciasTable preferencias = $PreferenciasTable(this);
  late final Index conclusaoTarefaDia = Index(
    'conclusao_tarefa_dia',
    'CREATE UNIQUE INDEX conclusao_tarefa_dia ON conclusoes_tarefa (tarefa_id, dia)',
  );
  late final Index registroHabitoDia = Index(
    'registro_habito_dia',
    'CREATE UNIQUE INDEX registro_habito_dia ON registros_habito (habito_id, dia)',
  );
  late final Index pagamentoTransacaoVenc = Index(
    'pagamento_transacao_venc',
    'CREATE UNIQUE INDEX pagamento_transacao_venc ON pagamentos_transacao (transacao_id, vencimento)',
  );
  late final Index medidaDiaTipo = Index(
    'medida_dia_tipo',
    'CREATE UNIQUE INDEX medida_dia_tipo ON medidas (dia, tipo)',
  );
  late final Index fotoShapeDiaAngulo = Index(
    'foto_shape_dia_angulo',
    'CREATE UNIQUE INDEX foto_shape_dia_angulo ON fotos_shape (dia, angulo)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    objetivos,
    etapas,
    tarefas,
    conclusoesTarefa,
    habitos,
    registrosHabito,
    contasFinanceiras,
    transacoes,
    pagamentosTransacao,
    lembretes,
    compromissos,
    exercicios,
    treinos,
    itensTreino,
    sessoesTreino,
    seriesFeitas,
    medidas,
    fotosShape,
    alimentos,
    alvosDieta,
    registrosAlimentacao,
    mensagensAssistente,
    automacoes,
    pastasNotas,
    notas,
    anexosNota,
    preferencias,
    conclusaoTarefaDia,
    registroHabitoDia,
    pagamentoTransacaoVenc,
    medidaDiaTipo,
    fotoShapeDiaAngulo,
  ];
}

typedef $$ObjetivosTableCreateCompanionBuilder = ObjetivosCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  required String nome,
  Value<String?> descricao,
  Value<String> unidade,
  Value<double> valorInicial,
  Value<double> valorAtual,
  Value<double> valorAlvo,
  Value<DateTime?> dataAlvo,
  Value<DateTime?> inicio,
  Value<String> status,
  Value<String?> cor,
  Value<int> rowid,
});
typedef $$ObjetivosTableUpdateCompanionBuilder = ObjetivosCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  Value<String> nome,
  Value<String?> descricao,
  Value<String> unidade,
  Value<double> valorInicial,
  Value<double> valorAtual,
  Value<double> valorAlvo,
  Value<DateTime?> dataAlvo,
  Value<DateTime?> inicio,
  Value<String> status,
  Value<String?> cor,
  Value<int> rowid,
});

final class $$ObjetivosTableReferences
    extends BaseReferences<_$BancoAurora, $ObjetivosTable, Objetivo> {
  $$ObjetivosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EtapasTable, List<Etapa>> _etapasRefsTable(
    _$BancoAurora db,
  ) => MultiTypedResultKey.fromTable(
    db.etapas,
    aliasName: 'objetivos__id__etapas__objetivo_id',
  );

  $$EtapasTableProcessedTableManager get etapasRefs {
    final manager = $$EtapasTableTableManager(
      $_db,
      $_db.etapas,
    ).filter((f) => f.objetivoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_etapasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TarefasTable, List<Tarefa>> _tarefasRefsTable(
    _$BancoAurora db,
  ) => MultiTypedResultKey.fromTable(
    db.tarefas,
    aliasName: 'objetivos__id__tarefas__objetivo_id',
  );

  $$TarefasTableProcessedTableManager get tarefasRefs {
    final manager = $$TarefasTableTableManager(
      $_db,
      $_db.tarefas,
    ).filter((f) => f.objetivoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tarefasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HabitosTable, List<Habito>> _habitosRefsTable(
    _$BancoAurora db,
  ) => MultiTypedResultKey.fromTable(
    db.habitos,
    aliasName: 'objetivos__id__habitos__objetivo_id',
  );

  $$HabitosTableProcessedTableManager get habitosRefs {
    final manager = $$HabitosTableTableManager(
      $_db,
      $_db.habitos,
    ).filter((f) => f.objetivoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_habitosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ObjetivosTableFilterComposer
    extends Composer<_$BancoAurora, $ObjetivosTable> {
  $$ObjetivosTableFilterComposer({
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

  ColumnFilters<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unidade => $composableBuilder(
    column: $table.unidade,
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

  ColumnFilters<DateTime> get dataAlvo => $composableBuilder(
    column: $table.dataAlvo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get inicio => $composableBuilder(
    column: $table.inicio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cor => $composableBuilder(
    column: $table.cor,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> etapasRefs(
    Expression<bool> Function($$EtapasTableFilterComposer f) f,
  ) {
    final $$EtapasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.etapas,
      getReferencedColumn: (t) => t.objetivoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EtapasTableFilterComposer(
            $db: $db,
            $table: $db.etapas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tarefasRefs(
    Expression<bool> Function($$TarefasTableFilterComposer f) f,
  ) {
    final $$TarefasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tarefas,
      getReferencedColumn: (t) => t.objetivoId,
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
      getReferencedColumn: (t) => t.objetivoId,
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

class $$ObjetivosTableOrderingComposer
    extends Composer<_$BancoAurora, $ObjetivosTable> {
  $$ObjetivosTableOrderingComposer({
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

  ColumnOrderings<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unidade => $composableBuilder(
    column: $table.unidade,
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

  ColumnOrderings<DateTime> get dataAlvo => $composableBuilder(
    column: $table.dataAlvo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get inicio => $composableBuilder(
    column: $table.inicio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cor => $composableBuilder(
    column: $table.cor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ObjetivosTableAnnotationComposer
    extends Composer<_$BancoAurora, $ObjetivosTable> {
  $$ObjetivosTableAnnotationComposer({
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

  GeneratedColumn<String> get descricao =>
      $composableBuilder(column: $table.descricao, builder: (column) => column);

  GeneratedColumn<String> get unidade =>
      $composableBuilder(column: $table.unidade, builder: (column) => column);

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

  GeneratedColumn<DateTime> get dataAlvo =>
      $composableBuilder(column: $table.dataAlvo, builder: (column) => column);

  GeneratedColumn<DateTime> get inicio =>
      $composableBuilder(column: $table.inicio, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get cor =>
      $composableBuilder(column: $table.cor, builder: (column) => column);

  Expression<T> etapasRefs<T extends Object>(
    Expression<T> Function($$EtapasTableAnnotationComposer a) f,
  ) {
    final $$EtapasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.etapas,
      getReferencedColumn: (t) => t.objetivoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EtapasTableAnnotationComposer(
            $db: $db,
            $table: $db.etapas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tarefasRefs<T extends Object>(
    Expression<T> Function($$TarefasTableAnnotationComposer a) f,
  ) {
    final $$TarefasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tarefas,
      getReferencedColumn: (t) => t.objetivoId,
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
      getReferencedColumn: (t) => t.objetivoId,
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

class $$ObjetivosTableTableManager
    extends
        RootTableManager<
          _$BancoAurora,
          $ObjetivosTable,
          Objetivo,
          $$ObjetivosTableFilterComposer,
          $$ObjetivosTableOrderingComposer,
          $$ObjetivosTableAnnotationComposer,
          $$ObjetivosTableCreateCompanionBuilder,
          $$ObjetivosTableUpdateCompanionBuilder,
          (Objetivo, $$ObjetivosTableReferences),
          Objetivo,
          PrefetchHooks Function({
            bool etapasRefs,
            bool tarefasRefs,
            bool habitosRefs,
          })
        > {
  $$ObjetivosTableTableManager(_$BancoAurora db, $ObjetivosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ObjetivosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ObjetivosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ObjetivosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String?> descricao = const Value.absent(),
                Value<String> unidade = const Value.absent(),
                Value<double> valorInicial = const Value.absent(),
                Value<double> valorAtual = const Value.absent(),
                Value<double> valorAlvo = const Value.absent(),
                Value<DateTime?> dataAlvo = const Value.absent(),
                Value<DateTime?> inicio = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> cor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ObjetivosCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                nome: nome,
                descricao: descricao,
                unidade: unidade,
                valorInicial: valorInicial,
                valorAtual: valorAtual,
                valorAlvo: valorAlvo,
                dataAlvo: dataAlvo,
                inicio: inicio,
                status: status,
                cor: cor,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                required String nome,
                Value<String?> descricao = const Value.absent(),
                Value<String> unidade = const Value.absent(),
                Value<double> valorInicial = const Value.absent(),
                Value<double> valorAtual = const Value.absent(),
                Value<double> valorAlvo = const Value.absent(),
                Value<DateTime?> dataAlvo = const Value.absent(),
                Value<DateTime?> inicio = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> cor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ObjetivosCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                nome: nome,
                descricao: descricao,
                unidade: unidade,
                valorInicial: valorInicial,
                valorAtual: valorAtual,
                valorAlvo: valorAlvo,
                dataAlvo: dataAlvo,
                inicio: inicio,
                status: status,
                cor: cor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ObjetivosTable, Objetivo>(table),
                  $$ObjetivosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({etapasRefs = false, tarefasRefs = false, habitosRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (etapasRefs) db.etapas,
                    if (tarefasRefs) db.tarefas,
                    if (habitosRefs) db.habitos,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (etapasRefs)
                        await $_getPrefetchedData<
                          Objetivo,
                          $ObjetivosTable,
                          Etapa
                        >(
                          currentTable: table,
                          referencedTable: $$ObjetivosTableReferences
                              ._etapasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ObjetivosTableReferences(
                                db,
                                table,
                                p0,
                              ).etapasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.objetivoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tarefasRefs)
                        await $_getPrefetchedData<
                          Objetivo,
                          $ObjetivosTable,
                          Tarefa
                        >(
                          currentTable: table,
                          referencedTable: $$ObjetivosTableReferences
                              ._tarefasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ObjetivosTableReferences(
                                db,
                                table,
                                p0,
                              ).tarefasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.objetivoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (habitosRefs)
                        await $_getPrefetchedData<
                          Objetivo,
                          $ObjetivosTable,
                          Habito
                        >(
                          currentTable: table,
                          referencedTable: $$ObjetivosTableReferences
                              ._habitosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ObjetivosTableReferences(
                                db,
                                table,
                                p0,
                              ).habitosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.objetivoId == item.id,
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

typedef $$ObjetivosTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $ObjetivosTable,
      Objetivo,
      $$ObjetivosTableFilterComposer,
      $$ObjetivosTableOrderingComposer,
      $$ObjetivosTableAnnotationComposer,
      $$ObjetivosTableCreateCompanionBuilder,
      $$ObjetivosTableUpdateCompanionBuilder,
      (Objetivo, $$ObjetivosTableReferences),
      Objetivo,
      PrefetchHooks Function({
        bool etapasRefs,
        bool tarefasRefs,
        bool habitosRefs,
      })
    >;
typedef $$EtapasTableCreateCompanionBuilder = EtapasCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  required String objetivoId,
  required String titulo,
  Value<bool> concluida,
  Value<int> ordem,
  Value<DateTime?> concluidaEm,
  Value<int> rowid,
});
typedef $$EtapasTableUpdateCompanionBuilder = EtapasCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  Value<String> objetivoId,
  Value<String> titulo,
  Value<bool> concluida,
  Value<int> ordem,
  Value<DateTime?> concluidaEm,
  Value<int> rowid,
});

final class $$EtapasTableReferences
    extends BaseReferences<_$BancoAurora, $EtapasTable, Etapa> {
  $$EtapasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ObjetivosTable _objetivoIdTable(_$BancoAurora db) =>
      db.objetivos.createAlias('etapas__objetivo_id__objetivos__id');

  $$ObjetivosTableProcessedTableManager get objetivoId {
    final $_column = $_itemColumn<String>('objetivo_id')!;

    final manager = $$ObjetivosTableTableManager(
      $_db,
      $_db.objetivos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_objetivoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EtapasTableFilterComposer
    extends Composer<_$BancoAurora, $EtapasTable> {
  $$EtapasTableFilterComposer({
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

  ColumnFilters<bool> get concluida => $composableBuilder(
    column: $table.concluida,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordem => $composableBuilder(
    column: $table.ordem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get concluidaEm => $composableBuilder(
    column: $table.concluidaEm,
    builder: (column) => ColumnFilters(column),
  );

  $$ObjetivosTableFilterComposer get objetivoId {
    final $$ObjetivosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objetivoId,
      referencedTable: $db.objetivos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjetivosTableFilterComposer(
            $db: $db,
            $table: $db.objetivos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EtapasTableOrderingComposer
    extends Composer<_$BancoAurora, $EtapasTable> {
  $$EtapasTableOrderingComposer({
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

  ColumnOrderings<bool> get concluida => $composableBuilder(
    column: $table.concluida,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordem => $composableBuilder(
    column: $table.ordem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get concluidaEm => $composableBuilder(
    column: $table.concluidaEm,
    builder: (column) => ColumnOrderings(column),
  );

  $$ObjetivosTableOrderingComposer get objetivoId {
    final $$ObjetivosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objetivoId,
      referencedTable: $db.objetivos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjetivosTableOrderingComposer(
            $db: $db,
            $table: $db.objetivos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EtapasTableAnnotationComposer
    extends Composer<_$BancoAurora, $EtapasTable> {
  $$EtapasTableAnnotationComposer({
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

  GeneratedColumn<bool> get concluida =>
      $composableBuilder(column: $table.concluida, builder: (column) => column);

  GeneratedColumn<int> get ordem =>
      $composableBuilder(column: $table.ordem, builder: (column) => column);

  GeneratedColumn<DateTime> get concluidaEm => $composableBuilder(
    column: $table.concluidaEm,
    builder: (column) => column,
  );

  $$ObjetivosTableAnnotationComposer get objetivoId {
    final $$ObjetivosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objetivoId,
      referencedTable: $db.objetivos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjetivosTableAnnotationComposer(
            $db: $db,
            $table: $db.objetivos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EtapasTableTableManager
    extends
        RootTableManager<
          _$BancoAurora,
          $EtapasTable,
          Etapa,
          $$EtapasTableFilterComposer,
          $$EtapasTableOrderingComposer,
          $$EtapasTableAnnotationComposer,
          $$EtapasTableCreateCompanionBuilder,
          $$EtapasTableUpdateCompanionBuilder,
          (Etapa, $$EtapasTableReferences),
          Etapa,
          PrefetchHooks Function({bool objetivoId})
        > {
  $$EtapasTableTableManager(_$BancoAurora db, $EtapasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EtapasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EtapasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EtapasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                Value<String> objetivoId = const Value.absent(),
                Value<String> titulo = const Value.absent(),
                Value<bool> concluida = const Value.absent(),
                Value<int> ordem = const Value.absent(),
                Value<DateTime?> concluidaEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EtapasCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                objetivoId: objetivoId,
                titulo: titulo,
                concluida: concluida,
                ordem: ordem,
                concluidaEm: concluidaEm,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                required String objetivoId,
                required String titulo,
                Value<bool> concluida = const Value.absent(),
                Value<int> ordem = const Value.absent(),
                Value<DateTime?> concluidaEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EtapasCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                objetivoId: objetivoId,
                titulo: titulo,
                concluida: concluida,
                ordem: ordem,
                concluidaEm: concluidaEm,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EtapasTable, Etapa>(table),
                  $$EtapasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({objetivoId = false}) {
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
                    if (objetivoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.objetivoId,
                        referencedTable: $$EtapasTableReferences
                            ._objetivoIdTable(db),
                        referencedColumn: $$EtapasTableReferences
                            ._objetivoIdTable(db)
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

typedef $$EtapasTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $EtapasTable,
      Etapa,
      $$EtapasTableFilterComposer,
      $$EtapasTableOrderingComposer,
      $$EtapasTableAnnotationComposer,
      $$EtapasTableCreateCompanionBuilder,
      $$EtapasTableUpdateCompanionBuilder,
      (Etapa, $$EtapasTableReferences),
      Etapa,
      PrefetchHooks Function({bool objetivoId})
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
  Value<String?> objetivoId,
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
  Value<String?> objetivoId,
  Value<int> rowid,
});

final class $$TarefasTableReferences
    extends BaseReferences<_$BancoAurora, $TarefasTable, Tarefa> {
  $$TarefasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ObjetivosTable _objetivoIdTable(_$BancoAurora db) =>
      db.objetivos.createAlias('tarefas__objetivo_id__objetivos__id');

  $$ObjetivosTableProcessedTableManager? get objetivoId {
    final $_column = $_itemColumn<String>('objetivo_id');
    if ($_column == null) return null;
    final manager = $$ObjetivosTableTableManager(
      $_db,
      $_db.objetivos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_objetivoIdTable($_db));
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

  $$ObjetivosTableFilterComposer get objetivoId {
    final $$ObjetivosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objetivoId,
      referencedTable: $db.objetivos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjetivosTableFilterComposer(
            $db: $db,
            $table: $db.objetivos,
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

  $$ObjetivosTableOrderingComposer get objetivoId {
    final $$ObjetivosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objetivoId,
      referencedTable: $db.objetivos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjetivosTableOrderingComposer(
            $db: $db,
            $table: $db.objetivos,
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

  $$ObjetivosTableAnnotationComposer get objetivoId {
    final $$ObjetivosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objetivoId,
      referencedTable: $db.objetivos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjetivosTableAnnotationComposer(
            $db: $db,
            $table: $db.objetivos,
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
          PrefetchHooks Function({bool objetivoId, bool conclusoesTarefaRefs})
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
                Value<String?> objetivoId = const Value.absent(),
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
                objetivoId: objetivoId,
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
                Value<String?> objetivoId = const Value.absent(),
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
                objetivoId: objetivoId,
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
              ({objetivoId = false, conclusoesTarefaRefs = false}) {
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
                        if (objetivoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.objetivoId,
                            referencedTable: $$TarefasTableReferences
                                ._objetivoIdTable(db),
                            referencedColumn: $$TarefasTableReferences
                                ._objetivoIdTable(db)
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
      PrefetchHooks Function({bool objetivoId, bool conclusoesTarefaRefs})
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
  Value<String?> objetivoId,
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
  Value<String?> objetivoId,
  Value<int> rowid,
});

final class $$HabitosTableReferences
    extends BaseReferences<_$BancoAurora, $HabitosTable, Habito> {
  $$HabitosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ObjetivosTable _objetivoIdTable(_$BancoAurora db) =>
      db.objetivos.createAlias('habitos__objetivo_id__objetivos__id');

  $$ObjetivosTableProcessedTableManager? get objetivoId {
    final $_column = $_itemColumn<String>('objetivo_id');
    if ($_column == null) return null;
    final manager = $$ObjetivosTableTableManager(
      $_db,
      $_db.objetivos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_objetivoIdTable($_db));
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

  $$ObjetivosTableFilterComposer get objetivoId {
    final $$ObjetivosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objetivoId,
      referencedTable: $db.objetivos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjetivosTableFilterComposer(
            $db: $db,
            $table: $db.objetivos,
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

  $$ObjetivosTableOrderingComposer get objetivoId {
    final $$ObjetivosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objetivoId,
      referencedTable: $db.objetivos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjetivosTableOrderingComposer(
            $db: $db,
            $table: $db.objetivos,
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

  $$ObjetivosTableAnnotationComposer get objetivoId {
    final $$ObjetivosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objetivoId,
      referencedTable: $db.objetivos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjetivosTableAnnotationComposer(
            $db: $db,
            $table: $db.objetivos,
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
          PrefetchHooks Function({bool objetivoId, bool registrosHabitoRefs})
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
                Value<String?> objetivoId = const Value.absent(),
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
                objetivoId: objetivoId,
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
                Value<String?> objetivoId = const Value.absent(),
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
                objetivoId: objetivoId,
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
              ({objetivoId = false, registrosHabitoRefs = false}) {
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
                        if (objetivoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.objetivoId,
                            referencedTable: $$HabitosTableReferences
                                ._objetivoIdTable(db),
                            referencedColumn: $$HabitosTableReferences
                                ._objetivoIdTable(db)
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
      PrefetchHooks Function({bool objetivoId, bool registrosHabitoRefs})
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
          ContaFinanceira
        > {
  $$ContasFinanceirasTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TransacoesTable, List<Transacao>>
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

  static MultiTypedResultKey<$TransacoesTable, List<Transacao>>
  _transferenciasRecebidasTable(_$BancoAurora db) =>
      MultiTypedResultKey.fromTable(
        db.transacoes,
        aliasName: 'contas_financeiras__id__transacoes__conta_destino_id',
      );

  $$TransacoesTableProcessedTableManager get transferenciasRecebidas {
    final manager = $$TransacoesTableTableManager(
      $_db,
      $_db.transacoes,
    ).filter((f) => f.contaDestinoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transferenciasRecebidasTable($_db),
    );
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

  Expression<bool> transferenciasRecebidas(
    Expression<bool> Function($$TransacoesTableFilterComposer f) f,
  ) {
    final $$TransacoesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transacoes,
      getReferencedColumn: (t) => t.contaDestinoId,
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

  Expression<T> transferenciasRecebidas<T extends Object>(
    Expression<T> Function($$TransacoesTableAnnotationComposer a) f,
  ) {
    final $$TransacoesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transacoes,
      getReferencedColumn: (t) => t.contaDestinoId,
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
          ContaFinanceira,
          $$ContasFinanceirasTableFilterComposer,
          $$ContasFinanceirasTableOrderingComposer,
          $$ContasFinanceirasTableAnnotationComposer,
          $$ContasFinanceirasTableCreateCompanionBuilder,
          $$ContasFinanceirasTableUpdateCompanionBuilder,
          (ContaFinanceira, $$ContasFinanceirasTableReferences),
          ContaFinanceira,
          PrefetchHooks Function({
            bool transacoesRefs,
            bool transferenciasRecebidas,
          })
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
                  e.readTable<$ContasFinanceirasTable, ContaFinanceira>(table),
                  $$ContasFinanceirasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({transacoesRefs = false, transferenciasRecebidas = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transacoesRefs) db.transacoes,
                    if (transferenciasRecebidas) db.transacoes,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transacoesRefs)
                        await $_getPrefetchedData<
                          ContaFinanceira,
                          $ContasFinanceirasTable,
                          Transacao
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
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.contaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transferenciasRecebidas)
                        await $_getPrefetchedData<
                          ContaFinanceira,
                          $ContasFinanceirasTable,
                          Transacao
                        >(
                          currentTable: table,
                          referencedTable: $$ContasFinanceirasTableReferences
                              ._transferenciasRecebidasTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ContasFinanceirasTableReferences(
                                db,
                                table,
                                p0,
                              ).transferenciasRecebidas,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.contaDestinoId == item.id,
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

typedef $$ContasFinanceirasTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $ContasFinanceirasTable,
      ContaFinanceira,
      $$ContasFinanceirasTableFilterComposer,
      $$ContasFinanceirasTableOrderingComposer,
      $$ContasFinanceirasTableAnnotationComposer,
      $$ContasFinanceirasTableCreateCompanionBuilder,
      $$ContasFinanceirasTableUpdateCompanionBuilder,
      (ContaFinanceira, $$ContasFinanceirasTableReferences),
      ContaFinanceira,
      PrefetchHooks Function({
        bool transacoesRefs,
        bool transferenciasRecebidas,
      })
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
  Value<String?> contaDestinoId,
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
  Value<String?> contaDestinoId,
  Value<int> rowid,
});

final class $$TransacoesTableReferences
    extends BaseReferences<_$BancoAurora, $TransacoesTable, Transacao> {
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

  static $ContasFinanceirasTable _contaDestinoIdTable(_$BancoAurora db) => db
      .contasFinanceiras
      .createAlias('transacoes__conta_destino_id__contas_financeiras__id');

  $$ContasFinanceirasTableProcessedTableManager? get contaDestinoId {
    final $_column = $_itemColumn<String>('conta_destino_id');
    if ($_column == null) return null;
    final manager = $$ContasFinanceirasTableTableManager(
      $_db,
      $_db.contasFinanceiras,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contaDestinoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $PagamentosTransacaoTable,
    List<PagamentoTransacao>
  >
  _pagamentosTransacaoRefsTable(_$BancoAurora db) =>
      MultiTypedResultKey.fromTable(
        db.pagamentosTransacao,
        aliasName: 'transacoes__id__pagamentos_transacao__transacao_id',
      );

  $$PagamentosTransacaoTableProcessedTableManager get pagamentosTransacaoRefs {
    final manager = $$PagamentosTransacaoTableTableManager(
      $_db,
      $_db.pagamentosTransacao,
    ).filter((f) => f.transacaoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _pagamentosTransacaoRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
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

  $$ContasFinanceirasTableFilterComposer get contaDestinoId {
    final $$ContasFinanceirasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaDestinoId,
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

  Expression<bool> pagamentosTransacaoRefs(
    Expression<bool> Function($$PagamentosTransacaoTableFilterComposer f) f,
  ) {
    final $$PagamentosTransacaoTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pagamentosTransacao,
      getReferencedColumn: (t) => t.transacaoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagamentosTransacaoTableFilterComposer(
            $db: $db,
            $table: $db.pagamentosTransacao,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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

  $$ContasFinanceirasTableOrderingComposer get contaDestinoId {
    final $$ContasFinanceirasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaDestinoId,
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

  $$ContasFinanceirasTableAnnotationComposer get contaDestinoId {
    final $$ContasFinanceirasTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.contaDestinoId,
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

  Expression<T> pagamentosTransacaoRefs<T extends Object>(
    Expression<T> Function($$PagamentosTransacaoTableAnnotationComposer a) f,
  ) {
    final $$PagamentosTransacaoTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.pagamentosTransacao,
          getReferencedColumn: (t) => t.transacaoId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PagamentosTransacaoTableAnnotationComposer(
                $db: $db,
                $table: $db.pagamentosTransacao,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TransacoesTableTableManager
    extends
        RootTableManager<
          _$BancoAurora,
          $TransacoesTable,
          Transacao,
          $$TransacoesTableFilterComposer,
          $$TransacoesTableOrderingComposer,
          $$TransacoesTableAnnotationComposer,
          $$TransacoesTableCreateCompanionBuilder,
          $$TransacoesTableUpdateCompanionBuilder,
          (Transacao, $$TransacoesTableReferences),
          Transacao,
          PrefetchHooks Function({
            bool contaId,
            bool contaDestinoId,
            bool pagamentosTransacaoRefs,
          })
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
                Value<String?> contaDestinoId = const Value.absent(),
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
                contaDestinoId: contaDestinoId,
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
                Value<String?> contaDestinoId = const Value.absent(),
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
                contaDestinoId: contaDestinoId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TransacoesTable, Transacao>(table),
                  $$TransacoesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                contaId = false,
                contaDestinoId = false,
                pagamentosTransacaoRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (pagamentosTransacaoRefs) db.pagamentosTransacao,
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
                        if (contaDestinoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.contaDestinoId,
                            referencedTable: $$TransacoesTableReferences
                                ._contaDestinoIdTable(db),
                            referencedColumn: $$TransacoesTableReferences
                                ._contaDestinoIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (pagamentosTransacaoRefs)
                        await $_getPrefetchedData<
                          Transacao,
                          $TransacoesTable,
                          PagamentoTransacao
                        >(
                          currentTable: table,
                          referencedTable: $$TransacoesTableReferences
                              ._pagamentosTransacaoRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransacoesTableReferences(
                                db,
                                table,
                                p0,
                              ).pagamentosTransacaoRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.transacaoId == item.id,
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

typedef $$TransacoesTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $TransacoesTable,
      Transacao,
      $$TransacoesTableFilterComposer,
      $$TransacoesTableOrderingComposer,
      $$TransacoesTableAnnotationComposer,
      $$TransacoesTableCreateCompanionBuilder,
      $$TransacoesTableUpdateCompanionBuilder,
      (Transacao, $$TransacoesTableReferences),
      Transacao,
      PrefetchHooks Function({
        bool contaId,
        bool contaDestinoId,
        bool pagamentosTransacaoRefs,
      })
    >;
typedef $$PagamentosTransacaoTableCreateCompanionBuilder =
    PagamentosTransacaoCompanion Function({
      Value<String> id,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<DateTime?> apagadoEm,
      required String transacaoId,
      required String vencimento,
      required DateTime pagoEm,
      required int valorCentavos,
      Value<int> rowid,
    });
typedef $$PagamentosTransacaoTableUpdateCompanionBuilder =
    PagamentosTransacaoCompanion Function({
      Value<String> id,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<DateTime?> apagadoEm,
      Value<String> transacaoId,
      Value<String> vencimento,
      Value<DateTime> pagoEm,
      Value<int> valorCentavos,
      Value<int> rowid,
    });

final class $$PagamentosTransacaoTableReferences
    extends
        BaseReferences<
          _$BancoAurora,
          $PagamentosTransacaoTable,
          PagamentoTransacao
        > {
  $$PagamentosTransacaoTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TransacoesTable _transacaoIdTable(_$BancoAurora db) => db.transacoes
      .createAlias('pagamentos_transacao__transacao_id__transacoes__id');

  $$TransacoesTableProcessedTableManager get transacaoId {
    final $_column = $_itemColumn<String>('transacao_id')!;

    final manager = $$TransacoesTableTableManager(
      $_db,
      $_db.transacoes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transacaoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PagamentosTransacaoTableFilterComposer
    extends Composer<_$BancoAurora, $PagamentosTransacaoTable> {
  $$PagamentosTransacaoTableFilterComposer({
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

  ColumnFilters<String> get vencimento => $composableBuilder(
    column: $table.vencimento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pagoEm => $composableBuilder(
    column: $table.pagoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valorCentavos => $composableBuilder(
    column: $table.valorCentavos,
    builder: (column) => ColumnFilters(column),
  );

  $$TransacoesTableFilterComposer get transacaoId {
    final $$TransacoesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transacaoId,
      referencedTable: $db.transacoes,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$PagamentosTransacaoTableOrderingComposer
    extends Composer<_$BancoAurora, $PagamentosTransacaoTable> {
  $$PagamentosTransacaoTableOrderingComposer({
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

  ColumnOrderings<String> get vencimento => $composableBuilder(
    column: $table.vencimento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pagoEm => $composableBuilder(
    column: $table.pagoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valorCentavos => $composableBuilder(
    column: $table.valorCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransacoesTableOrderingComposer get transacaoId {
    final $$TransacoesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transacaoId,
      referencedTable: $db.transacoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransacoesTableOrderingComposer(
            $db: $db,
            $table: $db.transacoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PagamentosTransacaoTableAnnotationComposer
    extends Composer<_$BancoAurora, $PagamentosTransacaoTable> {
  $$PagamentosTransacaoTableAnnotationComposer({
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

  GeneratedColumn<String> get vencimento => $composableBuilder(
    column: $table.vencimento,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get pagoEm =>
      $composableBuilder(column: $table.pagoEm, builder: (column) => column);

  GeneratedColumn<int> get valorCentavos => $composableBuilder(
    column: $table.valorCentavos,
    builder: (column) => column,
  );

  $$TransacoesTableAnnotationComposer get transacaoId {
    final $$TransacoesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transacaoId,
      referencedTable: $db.transacoes,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$PagamentosTransacaoTableTableManager
    extends
        RootTableManager<
          _$BancoAurora,
          $PagamentosTransacaoTable,
          PagamentoTransacao,
          $$PagamentosTransacaoTableFilterComposer,
          $$PagamentosTransacaoTableOrderingComposer,
          $$PagamentosTransacaoTableAnnotationComposer,
          $$PagamentosTransacaoTableCreateCompanionBuilder,
          $$PagamentosTransacaoTableUpdateCompanionBuilder,
          (PagamentoTransacao, $$PagamentosTransacaoTableReferences),
          PagamentoTransacao,
          PrefetchHooks Function({bool transacaoId})
        > {
  $$PagamentosTransacaoTableTableManager(
    _$BancoAurora db,
    $PagamentosTransacaoTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PagamentosTransacaoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PagamentosTransacaoTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PagamentosTransacaoTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                Value<String> transacaoId = const Value.absent(),
                Value<String> vencimento = const Value.absent(),
                Value<DateTime> pagoEm = const Value.absent(),
                Value<int> valorCentavos = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PagamentosTransacaoCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                transacaoId: transacaoId,
                vencimento: vencimento,
                pagoEm: pagoEm,
                valorCentavos: valorCentavos,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                required String transacaoId,
                required String vencimento,
                required DateTime pagoEm,
                required int valorCentavos,
                Value<int> rowid = const Value.absent(),
              }) => PagamentosTransacaoCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                transacaoId: transacaoId,
                vencimento: vencimento,
                pagoEm: pagoEm,
                valorCentavos: valorCentavos,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PagamentosTransacaoTable, PagamentoTransacao>(
                    table,
                  ),
                  $$PagamentosTransacaoTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transacaoId = false}) {
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
                    if (transacaoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.transacaoId,
                        referencedTable: $$PagamentosTransacaoTableReferences
                            ._transacaoIdTable(db),
                        referencedColumn: $$PagamentosTransacaoTableReferences
                            ._transacaoIdTable(db)
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

typedef $$PagamentosTransacaoTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $PagamentosTransacaoTable,
      PagamentoTransacao,
      $$PagamentosTransacaoTableFilterComposer,
      $$PagamentosTransacaoTableOrderingComposer,
      $$PagamentosTransacaoTableAnnotationComposer,
      $$PagamentosTransacaoTableCreateCompanionBuilder,
      $$PagamentosTransacaoTableUpdateCompanionBuilder,
      (PagamentoTransacao, $$PagamentosTransacaoTableReferences),
      PagamentoTransacao,
      PrefetchHooks Function({bool transacaoId})
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
  Value<bool> despertar,
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
  Value<bool> despertar,
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

  ColumnFilters<bool> get despertar => $composableBuilder(
    column: $table.despertar,
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

  ColumnOrderings<bool> get despertar => $composableBuilder(
    column: $table.despertar,
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

  GeneratedColumn<bool> get despertar =>
      $composableBuilder(column: $table.despertar, builder: (column) => column);

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
                Value<bool> despertar = const Value.absent(),
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
                despertar: despertar,
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
                Value<bool> despertar = const Value.absent(),
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
                despertar: despertar,
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
typedef $$CompromissosTableCreateCompanionBuilder =
    CompromissosCompanion Function({
      Value<String> id,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<DateTime?> apagadoEm,
      required String titulo,
      required DateTime inicio,
      Value<DateTime?> fim,
      Value<bool> diaInteiro,
      Value<String?> local,
      Value<String?> regraRepeticao,
      Value<int?> avisoAntesMin,
      Value<bool> despertar,
      Value<String?> notas,
      Value<int> rowid,
    });
typedef $$CompromissosTableUpdateCompanionBuilder =
    CompromissosCompanion Function({
      Value<String> id,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<DateTime?> apagadoEm,
      Value<String> titulo,
      Value<DateTime> inicio,
      Value<DateTime?> fim,
      Value<bool> diaInteiro,
      Value<String?> local,
      Value<String?> regraRepeticao,
      Value<int?> avisoAntesMin,
      Value<bool> despertar,
      Value<String?> notas,
      Value<int> rowid,
    });

class $$CompromissosTableFilterComposer
    extends Composer<_$BancoAurora, $CompromissosTable> {
  $$CompromissosTableFilterComposer({
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

  ColumnFilters<DateTime> get inicio => $composableBuilder(
    column: $table.inicio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fim => $composableBuilder(
    column: $table.fim,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get diaInteiro => $composableBuilder(
    column: $table.diaInteiro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get local => $composableBuilder(
    column: $table.local,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get regraRepeticao => $composableBuilder(
    column: $table.regraRepeticao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avisoAntesMin => $composableBuilder(
    column: $table.avisoAntesMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get despertar => $composableBuilder(
    column: $table.despertar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CompromissosTableOrderingComposer
    extends Composer<_$BancoAurora, $CompromissosTable> {
  $$CompromissosTableOrderingComposer({
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

  ColumnOrderings<DateTime> get inicio => $composableBuilder(
    column: $table.inicio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fim => $composableBuilder(
    column: $table.fim,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get diaInteiro => $composableBuilder(
    column: $table.diaInteiro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get local => $composableBuilder(
    column: $table.local,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get regraRepeticao => $composableBuilder(
    column: $table.regraRepeticao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avisoAntesMin => $composableBuilder(
    column: $table.avisoAntesMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get despertar => $composableBuilder(
    column: $table.despertar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompromissosTableAnnotationComposer
    extends Composer<_$BancoAurora, $CompromissosTable> {
  $$CompromissosTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get inicio =>
      $composableBuilder(column: $table.inicio, builder: (column) => column);

  GeneratedColumn<DateTime> get fim =>
      $composableBuilder(column: $table.fim, builder: (column) => column);

  GeneratedColumn<bool> get diaInteiro => $composableBuilder(
    column: $table.diaInteiro,
    builder: (column) => column,
  );

  GeneratedColumn<String> get local =>
      $composableBuilder(column: $table.local, builder: (column) => column);

  GeneratedColumn<String> get regraRepeticao => $composableBuilder(
    column: $table.regraRepeticao,
    builder: (column) => column,
  );

  GeneratedColumn<int> get avisoAntesMin => $composableBuilder(
    column: $table.avisoAntesMin,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get despertar =>
      $composableBuilder(column: $table.despertar, builder: (column) => column);

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);
}

class $$CompromissosTableTableManager
    extends
        RootTableManager<
          _$BancoAurora,
          $CompromissosTable,
          Compromisso,
          $$CompromissosTableFilterComposer,
          $$CompromissosTableOrderingComposer,
          $$CompromissosTableAnnotationComposer,
          $$CompromissosTableCreateCompanionBuilder,
          $$CompromissosTableUpdateCompanionBuilder,
          (
            Compromisso,
            BaseReferences<_$BancoAurora, $CompromissosTable, Compromisso>,
          ),
          Compromisso,
          PrefetchHooks Function()
        > {
  $$CompromissosTableTableManager(_$BancoAurora db, $CompromissosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompromissosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompromissosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompromissosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                Value<String> titulo = const Value.absent(),
                Value<DateTime> inicio = const Value.absent(),
                Value<DateTime?> fim = const Value.absent(),
                Value<bool> diaInteiro = const Value.absent(),
                Value<String?> local = const Value.absent(),
                Value<String?> regraRepeticao = const Value.absent(),
                Value<int?> avisoAntesMin = const Value.absent(),
                Value<bool> despertar = const Value.absent(),
                Value<String?> notas = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompromissosCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                titulo: titulo,
                inicio: inicio,
                fim: fim,
                diaInteiro: diaInteiro,
                local: local,
                regraRepeticao: regraRepeticao,
                avisoAntesMin: avisoAntesMin,
                despertar: despertar,
                notas: notas,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                required String titulo,
                required DateTime inicio,
                Value<DateTime?> fim = const Value.absent(),
                Value<bool> diaInteiro = const Value.absent(),
                Value<String?> local = const Value.absent(),
                Value<String?> regraRepeticao = const Value.absent(),
                Value<int?> avisoAntesMin = const Value.absent(),
                Value<bool> despertar = const Value.absent(),
                Value<String?> notas = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompromissosCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                titulo: titulo,
                inicio: inicio,
                fim: fim,
                diaInteiro: diaInteiro,
                local: local,
                regraRepeticao: regraRepeticao,
                avisoAntesMin: avisoAntesMin,
                despertar: despertar,
                notas: notas,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CompromissosTable, Compromisso>(table),
                  BaseReferences<
                    _$BancoAurora,
                    $CompromissosTable,
                    Compromisso
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CompromissosTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $CompromissosTable,
      Compromisso,
      $$CompromissosTableFilterComposer,
      $$CompromissosTableOrderingComposer,
      $$CompromissosTableAnnotationComposer,
      $$CompromissosTableCreateCompanionBuilder,
      $$CompromissosTableUpdateCompanionBuilder,
      (
        Compromisso,
        BaseReferences<_$BancoAurora, $CompromissosTable, Compromisso>,
      ),
      Compromisso,
      PrefetchHooks Function()
    >;
typedef $$ExerciciosTableCreateCompanionBuilder = ExerciciosCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  required String nome,
  Value<String?> grupo,
  Value<String?> midia,
  Value<int> rowid,
});
typedef $$ExerciciosTableUpdateCompanionBuilder = ExerciciosCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  Value<String> nome,
  Value<String?> grupo,
  Value<String?> midia,
  Value<int> rowid,
});

final class $$ExerciciosTableReferences
    extends BaseReferences<_$BancoAurora, $ExerciciosTable, Exercicio> {
  $$ExerciciosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ItensTreinoTable, List<ItemTreino>>
  _itensTreinoRefsTable(_$BancoAurora db) => MultiTypedResultKey.fromTable(
    db.itensTreino,
    aliasName: 'exercicios__id__itens_treino__exercicio_id',
  );

  $$ItensTreinoTableProcessedTableManager get itensTreinoRefs {
    final manager = $$ItensTreinoTableTableManager(
      $_db,
      $_db.itensTreino,
    ).filter((f) => f.exercicioId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_itensTreinoRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SeriesFeitasTable, List<SerieFeita>>
  _seriesFeitasRefsTable(_$BancoAurora db) => MultiTypedResultKey.fromTable(
    db.seriesFeitas,
    aliasName: 'exercicios__id__series_feitas__exercicio_id',
  );

  $$SeriesFeitasTableProcessedTableManager get seriesFeitasRefs {
    final manager = $$SeriesFeitasTableTableManager(
      $_db,
      $_db.seriesFeitas,
    ).filter((f) => f.exercicioId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_seriesFeitasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExerciciosTableFilterComposer
    extends Composer<_$BancoAurora, $ExerciciosTable> {
  $$ExerciciosTableFilterComposer({
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

  ColumnFilters<String> get grupo => $composableBuilder(
    column: $table.grupo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get midia => $composableBuilder(
    column: $table.midia,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> itensTreinoRefs(
    Expression<bool> Function($$ItensTreinoTableFilterComposer f) f,
  ) {
    final $$ItensTreinoTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itensTreino,
      getReferencedColumn: (t) => t.exercicioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItensTreinoTableFilterComposer(
            $db: $db,
            $table: $db.itensTreino,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> seriesFeitasRefs(
    Expression<bool> Function($$SeriesFeitasTableFilterComposer f) f,
  ) {
    final $$SeriesFeitasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.seriesFeitas,
      getReferencedColumn: (t) => t.exercicioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesFeitasTableFilterComposer(
            $db: $db,
            $table: $db.seriesFeitas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExerciciosTableOrderingComposer
    extends Composer<_$BancoAurora, $ExerciciosTable> {
  $$ExerciciosTableOrderingComposer({
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

  ColumnOrderings<String> get grupo => $composableBuilder(
    column: $table.grupo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get midia => $composableBuilder(
    column: $table.midia,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExerciciosTableAnnotationComposer
    extends Composer<_$BancoAurora, $ExerciciosTable> {
  $$ExerciciosTableAnnotationComposer({
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

  GeneratedColumn<String> get grupo =>
      $composableBuilder(column: $table.grupo, builder: (column) => column);

  GeneratedColumn<String> get midia =>
      $composableBuilder(column: $table.midia, builder: (column) => column);

  Expression<T> itensTreinoRefs<T extends Object>(
    Expression<T> Function($$ItensTreinoTableAnnotationComposer a) f,
  ) {
    final $$ItensTreinoTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itensTreino,
      getReferencedColumn: (t) => t.exercicioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItensTreinoTableAnnotationComposer(
            $db: $db,
            $table: $db.itensTreino,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> seriesFeitasRefs<T extends Object>(
    Expression<T> Function($$SeriesFeitasTableAnnotationComposer a) f,
  ) {
    final $$SeriesFeitasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.seriesFeitas,
      getReferencedColumn: (t) => t.exercicioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesFeitasTableAnnotationComposer(
            $db: $db,
            $table: $db.seriesFeitas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExerciciosTableTableManager
    extends
        RootTableManager<
          _$BancoAurora,
          $ExerciciosTable,
          Exercicio,
          $$ExerciciosTableFilterComposer,
          $$ExerciciosTableOrderingComposer,
          $$ExerciciosTableAnnotationComposer,
          $$ExerciciosTableCreateCompanionBuilder,
          $$ExerciciosTableUpdateCompanionBuilder,
          (Exercicio, $$ExerciciosTableReferences),
          Exercicio,
          PrefetchHooks Function({bool itensTreinoRefs, bool seriesFeitasRefs})
        > {
  $$ExerciciosTableTableManager(_$BancoAurora db, $ExerciciosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciciosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciciosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciciosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String?> grupo = const Value.absent(),
                Value<String?> midia = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciciosCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                nome: nome,
                grupo: grupo,
                midia: midia,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                required String nome,
                Value<String?> grupo = const Value.absent(),
                Value<String?> midia = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciciosCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                nome: nome,
                grupo: grupo,
                midia: midia,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExerciciosTable, Exercicio>(table),
                  $$ExerciciosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({itensTreinoRefs = false, seriesFeitasRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (itensTreinoRefs) db.itensTreino,
                    if (seriesFeitasRefs) db.seriesFeitas,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (itensTreinoRefs)
                        await $_getPrefetchedData<
                          Exercicio,
                          $ExerciciosTable,
                          ItemTreino
                        >(
                          currentTable: table,
                          referencedTable: $$ExerciciosTableReferences
                              ._itensTreinoRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExerciciosTableReferences(
                                db,
                                table,
                                p0,
                              ).itensTreinoRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exercicioId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (seriesFeitasRefs)
                        await $_getPrefetchedData<
                          Exercicio,
                          $ExerciciosTable,
                          SerieFeita
                        >(
                          currentTable: table,
                          referencedTable: $$ExerciciosTableReferences
                              ._seriesFeitasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExerciciosTableReferences(
                                db,
                                table,
                                p0,
                              ).seriesFeitasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exercicioId == item.id,
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

typedef $$ExerciciosTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $ExerciciosTable,
      Exercicio,
      $$ExerciciosTableFilterComposer,
      $$ExerciciosTableOrderingComposer,
      $$ExerciciosTableAnnotationComposer,
      $$ExerciciosTableCreateCompanionBuilder,
      $$ExerciciosTableUpdateCompanionBuilder,
      (Exercicio, $$ExerciciosTableReferences),
      Exercicio,
      PrefetchHooks Function({bool itensTreinoRefs, bool seriesFeitasRefs})
    >;
typedef $$TreinosTableCreateCompanionBuilder = TreinosCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  required String nome,
  Value<String?> foco,
  Value<int> diasSemana,
  Value<int> ordem,
  Value<int> rowid,
});
typedef $$TreinosTableUpdateCompanionBuilder = TreinosCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  Value<String> nome,
  Value<String?> foco,
  Value<int> diasSemana,
  Value<int> ordem,
  Value<int> rowid,
});

final class $$TreinosTableReferences
    extends BaseReferences<_$BancoAurora, $TreinosTable, Treino> {
  $$TreinosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ItensTreinoTable, List<ItemTreino>>
  _itensTreinoRefsTable(_$BancoAurora db) => MultiTypedResultKey.fromTable(
    db.itensTreino,
    aliasName: 'treinos__id__itens_treino__treino_id',
  );

  $$ItensTreinoTableProcessedTableManager get itensTreinoRefs {
    final manager = $$ItensTreinoTableTableManager(
      $_db,
      $_db.itensTreino,
    ).filter((f) => f.treinoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_itensTreinoRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessoesTreinoTable, List<SessaoTreino>>
  _sessoesTreinoRefsTable(_$BancoAurora db) => MultiTypedResultKey.fromTable(
    db.sessoesTreino,
    aliasName: 'treinos__id__sessoes_treino__treino_id',
  );

  $$SessoesTreinoTableProcessedTableManager get sessoesTreinoRefs {
    final manager = $$SessoesTreinoTableTableManager(
      $_db,
      $_db.sessoesTreino,
    ).filter((f) => f.treinoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessoesTreinoRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TreinosTableFilterComposer
    extends Composer<_$BancoAurora, $TreinosTable> {
  $$TreinosTableFilterComposer({
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

  ColumnFilters<String> get foco => $composableBuilder(
    column: $table.foco,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diasSemana => $composableBuilder(
    column: $table.diasSemana,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordem => $composableBuilder(
    column: $table.ordem,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> itensTreinoRefs(
    Expression<bool> Function($$ItensTreinoTableFilterComposer f) f,
  ) {
    final $$ItensTreinoTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itensTreino,
      getReferencedColumn: (t) => t.treinoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItensTreinoTableFilterComposer(
            $db: $db,
            $table: $db.itensTreino,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessoesTreinoRefs(
    Expression<bool> Function($$SessoesTreinoTableFilterComposer f) f,
  ) {
    final $$SessoesTreinoTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessoesTreino,
      getReferencedColumn: (t) => t.treinoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessoesTreinoTableFilterComposer(
            $db: $db,
            $table: $db.sessoesTreino,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TreinosTableOrderingComposer
    extends Composer<_$BancoAurora, $TreinosTable> {
  $$TreinosTableOrderingComposer({
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

  ColumnOrderings<String> get foco => $composableBuilder(
    column: $table.foco,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diasSemana => $composableBuilder(
    column: $table.diasSemana,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordem => $composableBuilder(
    column: $table.ordem,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TreinosTableAnnotationComposer
    extends Composer<_$BancoAurora, $TreinosTable> {
  $$TreinosTableAnnotationComposer({
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

  GeneratedColumn<String> get foco =>
      $composableBuilder(column: $table.foco, builder: (column) => column);

  GeneratedColumn<int> get diasSemana => $composableBuilder(
    column: $table.diasSemana,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ordem =>
      $composableBuilder(column: $table.ordem, builder: (column) => column);

  Expression<T> itensTreinoRefs<T extends Object>(
    Expression<T> Function($$ItensTreinoTableAnnotationComposer a) f,
  ) {
    final $$ItensTreinoTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itensTreino,
      getReferencedColumn: (t) => t.treinoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItensTreinoTableAnnotationComposer(
            $db: $db,
            $table: $db.itensTreino,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessoesTreinoRefs<T extends Object>(
    Expression<T> Function($$SessoesTreinoTableAnnotationComposer a) f,
  ) {
    final $$SessoesTreinoTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessoesTreino,
      getReferencedColumn: (t) => t.treinoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessoesTreinoTableAnnotationComposer(
            $db: $db,
            $table: $db.sessoesTreino,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TreinosTableTableManager
    extends
        RootTableManager<
          _$BancoAurora,
          $TreinosTable,
          Treino,
          $$TreinosTableFilterComposer,
          $$TreinosTableOrderingComposer,
          $$TreinosTableAnnotationComposer,
          $$TreinosTableCreateCompanionBuilder,
          $$TreinosTableUpdateCompanionBuilder,
          (Treino, $$TreinosTableReferences),
          Treino,
          PrefetchHooks Function({bool itensTreinoRefs, bool sessoesTreinoRefs})
        > {
  $$TreinosTableTableManager(_$BancoAurora db, $TreinosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TreinosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TreinosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TreinosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String?> foco = const Value.absent(),
                Value<int> diasSemana = const Value.absent(),
                Value<int> ordem = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TreinosCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                nome: nome,
                foco: foco,
                diasSemana: diasSemana,
                ordem: ordem,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                required String nome,
                Value<String?> foco = const Value.absent(),
                Value<int> diasSemana = const Value.absent(),
                Value<int> ordem = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TreinosCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                nome: nome,
                foco: foco,
                diasSemana: diasSemana,
                ordem: ordem,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TreinosTable, Treino>(table),
                  $$TreinosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({itensTreinoRefs = false, sessoesTreinoRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (itensTreinoRefs) db.itensTreino,
                    if (sessoesTreinoRefs) db.sessoesTreino,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (itensTreinoRefs)
                        await $_getPrefetchedData<
                          Treino,
                          $TreinosTable,
                          ItemTreino
                        >(
                          currentTable: table,
                          referencedTable: $$TreinosTableReferences
                              ._itensTreinoRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TreinosTableReferences(
                                db,
                                table,
                                p0,
                              ).itensTreinoRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.treinoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sessoesTreinoRefs)
                        await $_getPrefetchedData<
                          Treino,
                          $TreinosTable,
                          SessaoTreino
                        >(
                          currentTable: table,
                          referencedTable: $$TreinosTableReferences
                              ._sessoesTreinoRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TreinosTableReferences(
                                db,
                                table,
                                p0,
                              ).sessoesTreinoRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.treinoId == item.id,
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

typedef $$TreinosTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $TreinosTable,
      Treino,
      $$TreinosTableFilterComposer,
      $$TreinosTableOrderingComposer,
      $$TreinosTableAnnotationComposer,
      $$TreinosTableCreateCompanionBuilder,
      $$TreinosTableUpdateCompanionBuilder,
      (Treino, $$TreinosTableReferences),
      Treino,
      PrefetchHooks Function({bool itensTreinoRefs, bool sessoesTreinoRefs})
    >;
typedef $$ItensTreinoTableCreateCompanionBuilder =
    ItensTreinoCompanion Function({
      Value<String> id,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<DateTime?> apagadoEm,
      required String treinoId,
      required String exercicioId,
      Value<int> ordem,
      Value<int> series,
      Value<int> repeticoes,
      Value<double?> cargaInicial,
      Value<int> rowid,
    });
typedef $$ItensTreinoTableUpdateCompanionBuilder =
    ItensTreinoCompanion Function({
      Value<String> id,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<DateTime?> apagadoEm,
      Value<String> treinoId,
      Value<String> exercicioId,
      Value<int> ordem,
      Value<int> series,
      Value<int> repeticoes,
      Value<double?> cargaInicial,
      Value<int> rowid,
    });

final class $$ItensTreinoTableReferences
    extends BaseReferences<_$BancoAurora, $ItensTreinoTable, ItemTreino> {
  $$ItensTreinoTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TreinosTable _treinoIdTable(_$BancoAurora db) =>
      db.treinos.createAlias('itens_treino__treino_id__treinos__id');

  $$TreinosTableProcessedTableManager get treinoId {
    final $_column = $_itemColumn<String>('treino_id')!;

    final manager = $$TreinosTableTableManager(
      $_db,
      $_db.treinos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_treinoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExerciciosTable _exercicioIdTable(_$BancoAurora db) =>
      db.exercicios.createAlias('itens_treino__exercicio_id__exercicios__id');

  $$ExerciciosTableProcessedTableManager get exercicioId {
    final $_column = $_itemColumn<String>('exercicio_id')!;

    final manager = $$ExerciciosTableTableManager(
      $_db,
      $_db.exercicios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exercicioIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ItensTreinoTableFilterComposer
    extends Composer<_$BancoAurora, $ItensTreinoTable> {
  $$ItensTreinoTableFilterComposer({
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

  ColumnFilters<int> get ordem => $composableBuilder(
    column: $table.ordem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get series => $composableBuilder(
    column: $table.series,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repeticoes => $composableBuilder(
    column: $table.repeticoes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cargaInicial => $composableBuilder(
    column: $table.cargaInicial,
    builder: (column) => ColumnFilters(column),
  );

  $$TreinosTableFilterComposer get treinoId {
    final $$TreinosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.treinoId,
      referencedTable: $db.treinos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreinosTableFilterComposer(
            $db: $db,
            $table: $db.treinos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciciosTableFilterComposer get exercicioId {
    final $$ExerciciosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exercicioId,
      referencedTable: $db.exercicios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciciosTableFilterComposer(
            $db: $db,
            $table: $db.exercicios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItensTreinoTableOrderingComposer
    extends Composer<_$BancoAurora, $ItensTreinoTable> {
  $$ItensTreinoTableOrderingComposer({
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

  ColumnOrderings<int> get ordem => $composableBuilder(
    column: $table.ordem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get series => $composableBuilder(
    column: $table.series,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeticoes => $composableBuilder(
    column: $table.repeticoes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cargaInicial => $composableBuilder(
    column: $table.cargaInicial,
    builder: (column) => ColumnOrderings(column),
  );

  $$TreinosTableOrderingComposer get treinoId {
    final $$TreinosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.treinoId,
      referencedTable: $db.treinos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreinosTableOrderingComposer(
            $db: $db,
            $table: $db.treinos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciciosTableOrderingComposer get exercicioId {
    final $$ExerciciosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exercicioId,
      referencedTable: $db.exercicios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciciosTableOrderingComposer(
            $db: $db,
            $table: $db.exercicios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItensTreinoTableAnnotationComposer
    extends Composer<_$BancoAurora, $ItensTreinoTable> {
  $$ItensTreinoTableAnnotationComposer({
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

  GeneratedColumn<int> get ordem =>
      $composableBuilder(column: $table.ordem, builder: (column) => column);

  GeneratedColumn<int> get series =>
      $composableBuilder(column: $table.series, builder: (column) => column);

  GeneratedColumn<int> get repeticoes => $composableBuilder(
    column: $table.repeticoes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cargaInicial => $composableBuilder(
    column: $table.cargaInicial,
    builder: (column) => column,
  );

  $$TreinosTableAnnotationComposer get treinoId {
    final $$TreinosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.treinoId,
      referencedTable: $db.treinos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreinosTableAnnotationComposer(
            $db: $db,
            $table: $db.treinos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciciosTableAnnotationComposer get exercicioId {
    final $$ExerciciosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exercicioId,
      referencedTable: $db.exercicios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciciosTableAnnotationComposer(
            $db: $db,
            $table: $db.exercicios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItensTreinoTableTableManager
    extends
        RootTableManager<
          _$BancoAurora,
          $ItensTreinoTable,
          ItemTreino,
          $$ItensTreinoTableFilterComposer,
          $$ItensTreinoTableOrderingComposer,
          $$ItensTreinoTableAnnotationComposer,
          $$ItensTreinoTableCreateCompanionBuilder,
          $$ItensTreinoTableUpdateCompanionBuilder,
          (ItemTreino, $$ItensTreinoTableReferences),
          ItemTreino,
          PrefetchHooks Function({bool treinoId, bool exercicioId})
        > {
  $$ItensTreinoTableTableManager(_$BancoAurora db, $ItensTreinoTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItensTreinoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItensTreinoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItensTreinoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                Value<String> treinoId = const Value.absent(),
                Value<String> exercicioId = const Value.absent(),
                Value<int> ordem = const Value.absent(),
                Value<int> series = const Value.absent(),
                Value<int> repeticoes = const Value.absent(),
                Value<double?> cargaInicial = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItensTreinoCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                treinoId: treinoId,
                exercicioId: exercicioId,
                ordem: ordem,
                series: series,
                repeticoes: repeticoes,
                cargaInicial: cargaInicial,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                required String treinoId,
                required String exercicioId,
                Value<int> ordem = const Value.absent(),
                Value<int> series = const Value.absent(),
                Value<int> repeticoes = const Value.absent(),
                Value<double?> cargaInicial = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItensTreinoCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                treinoId: treinoId,
                exercicioId: exercicioId,
                ordem: ordem,
                series: series,
                repeticoes: repeticoes,
                cargaInicial: cargaInicial,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ItensTreinoTable, ItemTreino>(table),
                  $$ItensTreinoTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({treinoId = false, exercicioId = false}) {
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
                    if (treinoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.treinoId,
                        referencedTable: $$ItensTreinoTableReferences
                            ._treinoIdTable(db),
                        referencedColumn: $$ItensTreinoTableReferences
                            ._treinoIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (exercicioId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.exercicioId,
                        referencedTable: $$ItensTreinoTableReferences
                            ._exercicioIdTable(db),
                        referencedColumn: $$ItensTreinoTableReferences
                            ._exercicioIdTable(db)
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

typedef $$ItensTreinoTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $ItensTreinoTable,
      ItemTreino,
      $$ItensTreinoTableFilterComposer,
      $$ItensTreinoTableOrderingComposer,
      $$ItensTreinoTableAnnotationComposer,
      $$ItensTreinoTableCreateCompanionBuilder,
      $$ItensTreinoTableUpdateCompanionBuilder,
      (ItemTreino, $$ItensTreinoTableReferences),
      ItemTreino,
      PrefetchHooks Function({bool treinoId, bool exercicioId})
    >;
typedef $$SessoesTreinoTableCreateCompanionBuilder =
    SessoesTreinoCompanion Function({
      Value<String> id,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<DateTime?> apagadoEm,
      Value<String?> treinoId,
      required String dia,
      required DateTime inicio,
      Value<DateTime?> fim,
      Value<int> rowid,
    });
typedef $$SessoesTreinoTableUpdateCompanionBuilder =
    SessoesTreinoCompanion Function({
      Value<String> id,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<DateTime?> apagadoEm,
      Value<String?> treinoId,
      Value<String> dia,
      Value<DateTime> inicio,
      Value<DateTime?> fim,
      Value<int> rowid,
    });

final class $$SessoesTreinoTableReferences
    extends BaseReferences<_$BancoAurora, $SessoesTreinoTable, SessaoTreino> {
  $$SessoesTreinoTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TreinosTable _treinoIdTable(_$BancoAurora db) =>
      db.treinos.createAlias('sessoes_treino__treino_id__treinos__id');

  $$TreinosTableProcessedTableManager? get treinoId {
    final $_column = $_itemColumn<String>('treino_id');
    if ($_column == null) return null;
    final manager = $$TreinosTableTableManager(
      $_db,
      $_db.treinos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_treinoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SeriesFeitasTable, List<SerieFeita>>
  _seriesFeitasRefsTable(_$BancoAurora db) => MultiTypedResultKey.fromTable(
    db.seriesFeitas,
    aliasName: 'sessoes_treino__id__series_feitas__sessao_id',
  );

  $$SeriesFeitasTableProcessedTableManager get seriesFeitasRefs {
    final manager = $$SeriesFeitasTableTableManager(
      $_db,
      $_db.seriesFeitas,
    ).filter((f) => f.sessaoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_seriesFeitasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessoesTreinoTableFilterComposer
    extends Composer<_$BancoAurora, $SessoesTreinoTable> {
  $$SessoesTreinoTableFilterComposer({
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

  ColumnFilters<DateTime> get inicio => $composableBuilder(
    column: $table.inicio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fim => $composableBuilder(
    column: $table.fim,
    builder: (column) => ColumnFilters(column),
  );

  $$TreinosTableFilterComposer get treinoId {
    final $$TreinosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.treinoId,
      referencedTable: $db.treinos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreinosTableFilterComposer(
            $db: $db,
            $table: $db.treinos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> seriesFeitasRefs(
    Expression<bool> Function($$SeriesFeitasTableFilterComposer f) f,
  ) {
    final $$SeriesFeitasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.seriesFeitas,
      getReferencedColumn: (t) => t.sessaoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesFeitasTableFilterComposer(
            $db: $db,
            $table: $db.seriesFeitas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessoesTreinoTableOrderingComposer
    extends Composer<_$BancoAurora, $SessoesTreinoTable> {
  $$SessoesTreinoTableOrderingComposer({
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

  ColumnOrderings<DateTime> get inicio => $composableBuilder(
    column: $table.inicio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fim => $composableBuilder(
    column: $table.fim,
    builder: (column) => ColumnOrderings(column),
  );

  $$TreinosTableOrderingComposer get treinoId {
    final $$TreinosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.treinoId,
      referencedTable: $db.treinos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreinosTableOrderingComposer(
            $db: $db,
            $table: $db.treinos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessoesTreinoTableAnnotationComposer
    extends Composer<_$BancoAurora, $SessoesTreinoTable> {
  $$SessoesTreinoTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get inicio =>
      $composableBuilder(column: $table.inicio, builder: (column) => column);

  GeneratedColumn<DateTime> get fim =>
      $composableBuilder(column: $table.fim, builder: (column) => column);

  $$TreinosTableAnnotationComposer get treinoId {
    final $$TreinosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.treinoId,
      referencedTable: $db.treinos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreinosTableAnnotationComposer(
            $db: $db,
            $table: $db.treinos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> seriesFeitasRefs<T extends Object>(
    Expression<T> Function($$SeriesFeitasTableAnnotationComposer a) f,
  ) {
    final $$SeriesFeitasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.seriesFeitas,
      getReferencedColumn: (t) => t.sessaoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesFeitasTableAnnotationComposer(
            $db: $db,
            $table: $db.seriesFeitas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessoesTreinoTableTableManager
    extends
        RootTableManager<
          _$BancoAurora,
          $SessoesTreinoTable,
          SessaoTreino,
          $$SessoesTreinoTableFilterComposer,
          $$SessoesTreinoTableOrderingComposer,
          $$SessoesTreinoTableAnnotationComposer,
          $$SessoesTreinoTableCreateCompanionBuilder,
          $$SessoesTreinoTableUpdateCompanionBuilder,
          (SessaoTreino, $$SessoesTreinoTableReferences),
          SessaoTreino,
          PrefetchHooks Function({bool treinoId, bool seriesFeitasRefs})
        > {
  $$SessoesTreinoTableTableManager(_$BancoAurora db, $SessoesTreinoTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessoesTreinoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessoesTreinoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessoesTreinoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                Value<String?> treinoId = const Value.absent(),
                Value<String> dia = const Value.absent(),
                Value<DateTime> inicio = const Value.absent(),
                Value<DateTime?> fim = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessoesTreinoCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                treinoId: treinoId,
                dia: dia,
                inicio: inicio,
                fim: fim,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                Value<String?> treinoId = const Value.absent(),
                required String dia,
                required DateTime inicio,
                Value<DateTime?> fim = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessoesTreinoCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                treinoId: treinoId,
                dia: dia,
                inicio: inicio,
                fim: fim,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessoesTreinoTable, SessaoTreino>(table),
                  $$SessoesTreinoTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({treinoId = false, seriesFeitasRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (seriesFeitasRefs) db.seriesFeitas,
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
                        if (treinoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.treinoId,
                            referencedTable: $$SessoesTreinoTableReferences
                                ._treinoIdTable(db),
                            referencedColumn: $$SessoesTreinoTableReferences
                                ._treinoIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (seriesFeitasRefs)
                        await $_getPrefetchedData<
                          SessaoTreino,
                          $SessoesTreinoTable,
                          SerieFeita
                        >(
                          currentTable: table,
                          referencedTable: $$SessoesTreinoTableReferences
                              ._seriesFeitasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessoesTreinoTableReferences(
                                db,
                                table,
                                p0,
                              ).seriesFeitasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessaoId == item.id,
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

typedef $$SessoesTreinoTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $SessoesTreinoTable,
      SessaoTreino,
      $$SessoesTreinoTableFilterComposer,
      $$SessoesTreinoTableOrderingComposer,
      $$SessoesTreinoTableAnnotationComposer,
      $$SessoesTreinoTableCreateCompanionBuilder,
      $$SessoesTreinoTableUpdateCompanionBuilder,
      (SessaoTreino, $$SessoesTreinoTableReferences),
      SessaoTreino,
      PrefetchHooks Function({bool treinoId, bool seriesFeitasRefs})
    >;
typedef $$SeriesFeitasTableCreateCompanionBuilder =
    SeriesFeitasCompanion Function({
      Value<String> id,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<DateTime?> apagadoEm,
      required String sessaoId,
      required String exercicioId,
      required int numero,
      required int repeticoes,
      required double cargaKg,
      Value<int> rowid,
    });
typedef $$SeriesFeitasTableUpdateCompanionBuilder =
    SeriesFeitasCompanion Function({
      Value<String> id,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<DateTime?> apagadoEm,
      Value<String> sessaoId,
      Value<String> exercicioId,
      Value<int> numero,
      Value<int> repeticoes,
      Value<double> cargaKg,
      Value<int> rowid,
    });

final class $$SeriesFeitasTableReferences
    extends BaseReferences<_$BancoAurora, $SeriesFeitasTable, SerieFeita> {
  $$SeriesFeitasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessoesTreinoTable _sessaoIdTable(_$BancoAurora db) => db
      .sessoesTreino
      .createAlias('series_feitas__sessao_id__sessoes_treino__id');

  $$SessoesTreinoTableProcessedTableManager get sessaoId {
    final $_column = $_itemColumn<String>('sessao_id')!;

    final manager = $$SessoesTreinoTableTableManager(
      $_db,
      $_db.sessoesTreino,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessaoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExerciciosTable _exercicioIdTable(_$BancoAurora db) =>
      db.exercicios.createAlias('series_feitas__exercicio_id__exercicios__id');

  $$ExerciciosTableProcessedTableManager get exercicioId {
    final $_column = $_itemColumn<String>('exercicio_id')!;

    final manager = $$ExerciciosTableTableManager(
      $_db,
      $_db.exercicios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exercicioIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SeriesFeitasTableFilterComposer
    extends Composer<_$BancoAurora, $SeriesFeitasTable> {
  $$SeriesFeitasTableFilterComposer({
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

  ColumnFilters<int> get numero => $composableBuilder(
    column: $table.numero,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repeticoes => $composableBuilder(
    column: $table.repeticoes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cargaKg => $composableBuilder(
    column: $table.cargaKg,
    builder: (column) => ColumnFilters(column),
  );

  $$SessoesTreinoTableFilterComposer get sessaoId {
    final $$SessoesTreinoTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessaoId,
      referencedTable: $db.sessoesTreino,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessoesTreinoTableFilterComposer(
            $db: $db,
            $table: $db.sessoesTreino,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciciosTableFilterComposer get exercicioId {
    final $$ExerciciosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exercicioId,
      referencedTable: $db.exercicios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciciosTableFilterComposer(
            $db: $db,
            $table: $db.exercicios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SeriesFeitasTableOrderingComposer
    extends Composer<_$BancoAurora, $SeriesFeitasTable> {
  $$SeriesFeitasTableOrderingComposer({
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

  ColumnOrderings<int> get numero => $composableBuilder(
    column: $table.numero,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeticoes => $composableBuilder(
    column: $table.repeticoes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cargaKg => $composableBuilder(
    column: $table.cargaKg,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessoesTreinoTableOrderingComposer get sessaoId {
    final $$SessoesTreinoTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessaoId,
      referencedTable: $db.sessoesTreino,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessoesTreinoTableOrderingComposer(
            $db: $db,
            $table: $db.sessoesTreino,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciciosTableOrderingComposer get exercicioId {
    final $$ExerciciosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exercicioId,
      referencedTable: $db.exercicios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciciosTableOrderingComposer(
            $db: $db,
            $table: $db.exercicios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SeriesFeitasTableAnnotationComposer
    extends Composer<_$BancoAurora, $SeriesFeitasTable> {
  $$SeriesFeitasTableAnnotationComposer({
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

  GeneratedColumn<int> get numero =>
      $composableBuilder(column: $table.numero, builder: (column) => column);

  GeneratedColumn<int> get repeticoes => $composableBuilder(
    column: $table.repeticoes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cargaKg =>
      $composableBuilder(column: $table.cargaKg, builder: (column) => column);

  $$SessoesTreinoTableAnnotationComposer get sessaoId {
    final $$SessoesTreinoTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessaoId,
      referencedTable: $db.sessoesTreino,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessoesTreinoTableAnnotationComposer(
            $db: $db,
            $table: $db.sessoesTreino,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciciosTableAnnotationComposer get exercicioId {
    final $$ExerciciosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exercicioId,
      referencedTable: $db.exercicios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciciosTableAnnotationComposer(
            $db: $db,
            $table: $db.exercicios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SeriesFeitasTableTableManager
    extends
        RootTableManager<
          _$BancoAurora,
          $SeriesFeitasTable,
          SerieFeita,
          $$SeriesFeitasTableFilterComposer,
          $$SeriesFeitasTableOrderingComposer,
          $$SeriesFeitasTableAnnotationComposer,
          $$SeriesFeitasTableCreateCompanionBuilder,
          $$SeriesFeitasTableUpdateCompanionBuilder,
          (SerieFeita, $$SeriesFeitasTableReferences),
          SerieFeita,
          PrefetchHooks Function({bool sessaoId, bool exercicioId})
        > {
  $$SeriesFeitasTableTableManager(_$BancoAurora db, $SeriesFeitasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeriesFeitasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeriesFeitasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeriesFeitasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                Value<String> sessaoId = const Value.absent(),
                Value<String> exercicioId = const Value.absent(),
                Value<int> numero = const Value.absent(),
                Value<int> repeticoes = const Value.absent(),
                Value<double> cargaKg = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeriesFeitasCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                sessaoId: sessaoId,
                exercicioId: exercicioId,
                numero: numero,
                repeticoes: repeticoes,
                cargaKg: cargaKg,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                required String sessaoId,
                required String exercicioId,
                required int numero,
                required int repeticoes,
                required double cargaKg,
                Value<int> rowid = const Value.absent(),
              }) => SeriesFeitasCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                sessaoId: sessaoId,
                exercicioId: exercicioId,
                numero: numero,
                repeticoes: repeticoes,
                cargaKg: cargaKg,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SeriesFeitasTable, SerieFeita>(table),
                  $$SeriesFeitasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessaoId = false, exercicioId = false}) {
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
                    if (sessaoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessaoId,
                        referencedTable: $$SeriesFeitasTableReferences
                            ._sessaoIdTable(db),
                        referencedColumn: $$SeriesFeitasTableReferences
                            ._sessaoIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (exercicioId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.exercicioId,
                        referencedTable: $$SeriesFeitasTableReferences
                            ._exercicioIdTable(db),
                        referencedColumn: $$SeriesFeitasTableReferences
                            ._exercicioIdTable(db)
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

typedef $$SeriesFeitasTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $SeriesFeitasTable,
      SerieFeita,
      $$SeriesFeitasTableFilterComposer,
      $$SeriesFeitasTableOrderingComposer,
      $$SeriesFeitasTableAnnotationComposer,
      $$SeriesFeitasTableCreateCompanionBuilder,
      $$SeriesFeitasTableUpdateCompanionBuilder,
      (SerieFeita, $$SeriesFeitasTableReferences),
      SerieFeita,
      PrefetchHooks Function({bool sessaoId, bool exercicioId})
    >;
typedef $$MedidasTableCreateCompanionBuilder = MedidasCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  required String dia,
  required String tipo,
  required double valor,
  required String unidade,
  Value<int> rowid,
});
typedef $$MedidasTableUpdateCompanionBuilder = MedidasCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  Value<String> dia,
  Value<String> tipo,
  Value<double> valor,
  Value<String> unidade,
  Value<int> rowid,
});

class $$MedidasTableFilterComposer
    extends Composer<_$BancoAurora, $MedidasTable> {
  $$MedidasTableFilterComposer({
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

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unidade => $composableBuilder(
    column: $table.unidade,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MedidasTableOrderingComposer
    extends Composer<_$BancoAurora, $MedidasTable> {
  $$MedidasTableOrderingComposer({
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

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unidade => $composableBuilder(
    column: $table.unidade,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedidasTableAnnotationComposer
    extends Composer<_$BancoAurora, $MedidasTable> {
  $$MedidasTableAnnotationComposer({
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

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<double> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);

  GeneratedColumn<String> get unidade =>
      $composableBuilder(column: $table.unidade, builder: (column) => column);
}

class $$MedidasTableTableManager
    extends
        RootTableManager<
          _$BancoAurora,
          $MedidasTable,
          Medida,
          $$MedidasTableFilterComposer,
          $$MedidasTableOrderingComposer,
          $$MedidasTableAnnotationComposer,
          $$MedidasTableCreateCompanionBuilder,
          $$MedidasTableUpdateCompanionBuilder,
          (Medida, BaseReferences<_$BancoAurora, $MedidasTable, Medida>),
          Medida,
          PrefetchHooks Function()
        > {
  $$MedidasTableTableManager(_$BancoAurora db, $MedidasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedidasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedidasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedidasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                Value<String> dia = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<double> valor = const Value.absent(),
                Value<String> unidade = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedidasCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                dia: dia,
                tipo: tipo,
                valor: valor,
                unidade: unidade,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                required String dia,
                required String tipo,
                required double valor,
                required String unidade,
                Value<int> rowid = const Value.absent(),
              }) => MedidasCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                dia: dia,
                tipo: tipo,
                valor: valor,
                unidade: unidade,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MedidasTable, Medida>(table),
                  BaseReferences<_$BancoAurora, $MedidasTable, Medida>(
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

typedef $$MedidasTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $MedidasTable,
      Medida,
      $$MedidasTableFilterComposer,
      $$MedidasTableOrderingComposer,
      $$MedidasTableAnnotationComposer,
      $$MedidasTableCreateCompanionBuilder,
      $$MedidasTableUpdateCompanionBuilder,
      (Medida, BaseReferences<_$BancoAurora, $MedidasTable, Medida>),
      Medida,
      PrefetchHooks Function()
    >;
typedef $$FotosShapeTableCreateCompanionBuilder = FotosShapeCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  required String dia,
  required String angulo,
  required String arquivo,
  Value<String?> hash,
  Value<bool> naNuvem,
  Value<int> rowid,
});
typedef $$FotosShapeTableUpdateCompanionBuilder = FotosShapeCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  Value<String> dia,
  Value<String> angulo,
  Value<String> arquivo,
  Value<String?> hash,
  Value<bool> naNuvem,
  Value<int> rowid,
});

class $$FotosShapeTableFilterComposer
    extends Composer<_$BancoAurora, $FotosShapeTable> {
  $$FotosShapeTableFilterComposer({
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

  ColumnFilters<String> get angulo => $composableBuilder(
    column: $table.angulo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arquivo => $composableBuilder(
    column: $table.arquivo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hash => $composableBuilder(
    column: $table.hash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get naNuvem => $composableBuilder(
    column: $table.naNuvem,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FotosShapeTableOrderingComposer
    extends Composer<_$BancoAurora, $FotosShapeTable> {
  $$FotosShapeTableOrderingComposer({
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

  ColumnOrderings<String> get angulo => $composableBuilder(
    column: $table.angulo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arquivo => $composableBuilder(
    column: $table.arquivo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hash => $composableBuilder(
    column: $table.hash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get naNuvem => $composableBuilder(
    column: $table.naNuvem,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FotosShapeTableAnnotationComposer
    extends Composer<_$BancoAurora, $FotosShapeTable> {
  $$FotosShapeTableAnnotationComposer({
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

  GeneratedColumn<String> get angulo =>
      $composableBuilder(column: $table.angulo, builder: (column) => column);

  GeneratedColumn<String> get arquivo =>
      $composableBuilder(column: $table.arquivo, builder: (column) => column);

  GeneratedColumn<String> get hash =>
      $composableBuilder(column: $table.hash, builder: (column) => column);

  GeneratedColumn<bool> get naNuvem =>
      $composableBuilder(column: $table.naNuvem, builder: (column) => column);
}

class $$FotosShapeTableTableManager
    extends
        RootTableManager<
          _$BancoAurora,
          $FotosShapeTable,
          FotoShape,
          $$FotosShapeTableFilterComposer,
          $$FotosShapeTableOrderingComposer,
          $$FotosShapeTableAnnotationComposer,
          $$FotosShapeTableCreateCompanionBuilder,
          $$FotosShapeTableUpdateCompanionBuilder,
          (
            FotoShape,
            BaseReferences<_$BancoAurora, $FotosShapeTable, FotoShape>,
          ),
          FotoShape,
          PrefetchHooks Function()
        > {
  $$FotosShapeTableTableManager(_$BancoAurora db, $FotosShapeTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FotosShapeTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FotosShapeTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FotosShapeTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                Value<String> dia = const Value.absent(),
                Value<String> angulo = const Value.absent(),
                Value<String> arquivo = const Value.absent(),
                Value<String?> hash = const Value.absent(),
                Value<bool> naNuvem = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FotosShapeCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                dia: dia,
                angulo: angulo,
                arquivo: arquivo,
                hash: hash,
                naNuvem: naNuvem,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                required String dia,
                required String angulo,
                required String arquivo,
                Value<String?> hash = const Value.absent(),
                Value<bool> naNuvem = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FotosShapeCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                dia: dia,
                angulo: angulo,
                arquivo: arquivo,
                hash: hash,
                naNuvem: naNuvem,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FotosShapeTable, FotoShape>(table),
                  BaseReferences<_$BancoAurora, $FotosShapeTable, FotoShape>(
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

typedef $$FotosShapeTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $FotosShapeTable,
      FotoShape,
      $$FotosShapeTableFilterComposer,
      $$FotosShapeTableOrderingComposer,
      $$FotosShapeTableAnnotationComposer,
      $$FotosShapeTableCreateCompanionBuilder,
      $$FotosShapeTableUpdateCompanionBuilder,
      (FotoShape, BaseReferences<_$BancoAurora, $FotosShapeTable, FotoShape>),
      FotoShape,
      PrefetchHooks Function()
    >;
typedef $$AlimentosTableCreateCompanionBuilder = AlimentosCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  required String nome,
  required double kcal,
  Value<double> proteina,
  Value<double> carboidrato,
  Value<double> gordura,
  Value<String?> porcaoNome,
  Value<double?> porcaoGramas,
  Value<String> origem,
  Value<int> rowid,
});
typedef $$AlimentosTableUpdateCompanionBuilder = AlimentosCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  Value<String> nome,
  Value<double> kcal,
  Value<double> proteina,
  Value<double> carboidrato,
  Value<double> gordura,
  Value<String?> porcaoNome,
  Value<double?> porcaoGramas,
  Value<String> origem,
  Value<int> rowid,
});

final class $$AlimentosTableReferences
    extends BaseReferences<_$BancoAurora, $AlimentosTable, Alimento> {
  $$AlimentosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $RegistrosAlimentacaoTable,
    List<RegistroAlimentacao>
  >
  _registrosAlimentacaoRefsTable(_$BancoAurora db) =>
      MultiTypedResultKey.fromTable(
        db.registrosAlimentacao,
        aliasName: 'alimentos__id__registros_alimentacao__alimento_id',
      );

  $$RegistrosAlimentacaoTableProcessedTableManager
  get registrosAlimentacaoRefs {
    final manager = $$RegistrosAlimentacaoTableTableManager(
      $_db,
      $_db.registrosAlimentacao,
    ).filter((f) => f.alimentoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _registrosAlimentacaoRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AlimentosTableFilterComposer
    extends Composer<_$BancoAurora, $AlimentosTable> {
  $$AlimentosTableFilterComposer({
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

  ColumnFilters<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteina => $composableBuilder(
    column: $table.proteina,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carboidrato => $composableBuilder(
    column: $table.carboidrato,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gordura => $composableBuilder(
    column: $table.gordura,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get porcaoNome => $composableBuilder(
    column: $table.porcaoNome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get porcaoGramas => $composableBuilder(
    column: $table.porcaoGramas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origem => $composableBuilder(
    column: $table.origem,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> registrosAlimentacaoRefs(
    Expression<bool> Function($$RegistrosAlimentacaoTableFilterComposer f) f,
  ) {
    final $$RegistrosAlimentacaoTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.registrosAlimentacao,
      getReferencedColumn: (t) => t.alimentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegistrosAlimentacaoTableFilterComposer(
            $db: $db,
            $table: $db.registrosAlimentacao,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AlimentosTableOrderingComposer
    extends Composer<_$BancoAurora, $AlimentosTable> {
  $$AlimentosTableOrderingComposer({
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

  ColumnOrderings<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteina => $composableBuilder(
    column: $table.proteina,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carboidrato => $composableBuilder(
    column: $table.carboidrato,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gordura => $composableBuilder(
    column: $table.gordura,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get porcaoNome => $composableBuilder(
    column: $table.porcaoNome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get porcaoGramas => $composableBuilder(
    column: $table.porcaoGramas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origem => $composableBuilder(
    column: $table.origem,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlimentosTableAnnotationComposer
    extends Composer<_$BancoAurora, $AlimentosTable> {
  $$AlimentosTableAnnotationComposer({
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

  GeneratedColumn<double> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<double> get proteina =>
      $composableBuilder(column: $table.proteina, builder: (column) => column);

  GeneratedColumn<double> get carboidrato => $composableBuilder(
    column: $table.carboidrato,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gordura =>
      $composableBuilder(column: $table.gordura, builder: (column) => column);

  GeneratedColumn<String> get porcaoNome => $composableBuilder(
    column: $table.porcaoNome,
    builder: (column) => column,
  );

  GeneratedColumn<double> get porcaoGramas => $composableBuilder(
    column: $table.porcaoGramas,
    builder: (column) => column,
  );

  GeneratedColumn<String> get origem =>
      $composableBuilder(column: $table.origem, builder: (column) => column);

  Expression<T> registrosAlimentacaoRefs<T extends Object>(
    Expression<T> Function($$RegistrosAlimentacaoTableAnnotationComposer a) f,
  ) {
    final $$RegistrosAlimentacaoTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.registrosAlimentacao,
          getReferencedColumn: (t) => t.alimentoId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RegistrosAlimentacaoTableAnnotationComposer(
                $db: $db,
                $table: $db.registrosAlimentacao,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AlimentosTableTableManager
    extends
        RootTableManager<
          _$BancoAurora,
          $AlimentosTable,
          Alimento,
          $$AlimentosTableFilterComposer,
          $$AlimentosTableOrderingComposer,
          $$AlimentosTableAnnotationComposer,
          $$AlimentosTableCreateCompanionBuilder,
          $$AlimentosTableUpdateCompanionBuilder,
          (Alimento, $$AlimentosTableReferences),
          Alimento,
          PrefetchHooks Function({bool registrosAlimentacaoRefs})
        > {
  $$AlimentosTableTableManager(_$BancoAurora db, $AlimentosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlimentosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlimentosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlimentosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<double> kcal = const Value.absent(),
                Value<double> proteina = const Value.absent(),
                Value<double> carboidrato = const Value.absent(),
                Value<double> gordura = const Value.absent(),
                Value<String?> porcaoNome = const Value.absent(),
                Value<double?> porcaoGramas = const Value.absent(),
                Value<String> origem = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlimentosCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                nome: nome,
                kcal: kcal,
                proteina: proteina,
                carboidrato: carboidrato,
                gordura: gordura,
                porcaoNome: porcaoNome,
                porcaoGramas: porcaoGramas,
                origem: origem,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                required String nome,
                required double kcal,
                Value<double> proteina = const Value.absent(),
                Value<double> carboidrato = const Value.absent(),
                Value<double> gordura = const Value.absent(),
                Value<String?> porcaoNome = const Value.absent(),
                Value<double?> porcaoGramas = const Value.absent(),
                Value<String> origem = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlimentosCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                nome: nome,
                kcal: kcal,
                proteina: proteina,
                carboidrato: carboidrato,
                gordura: gordura,
                porcaoNome: porcaoNome,
                porcaoGramas: porcaoGramas,
                origem: origem,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AlimentosTable, Alimento>(table),
                  $$AlimentosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({registrosAlimentacaoRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (registrosAlimentacaoRefs) db.registrosAlimentacao,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (registrosAlimentacaoRefs)
                    await $_getPrefetchedData<
                      Alimento,
                      $AlimentosTable,
                      RegistroAlimentacao
                    >(
                      currentTable: table,
                      referencedTable: $$AlimentosTableReferences
                          ._registrosAlimentacaoRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AlimentosTableReferences(
                            db,
                            table,
                            p0,
                          ).registrosAlimentacaoRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.alimentoId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AlimentosTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $AlimentosTable,
      Alimento,
      $$AlimentosTableFilterComposer,
      $$AlimentosTableOrderingComposer,
      $$AlimentosTableAnnotationComposer,
      $$AlimentosTableCreateCompanionBuilder,
      $$AlimentosTableUpdateCompanionBuilder,
      (Alimento, $$AlimentosTableReferences),
      Alimento,
      PrefetchHooks Function({bool registrosAlimentacaoRefs})
    >;
typedef $$AlvosDietaTableCreateCompanionBuilder = AlvosDietaCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  required String tipoDia,
  required double kcal,
  Value<double> proteina,
  Value<double> carboidrato,
  Value<double> gordura,
  Value<int> rowid,
});
typedef $$AlvosDietaTableUpdateCompanionBuilder = AlvosDietaCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  Value<String> tipoDia,
  Value<double> kcal,
  Value<double> proteina,
  Value<double> carboidrato,
  Value<double> gordura,
  Value<int> rowid,
});

class $$AlvosDietaTableFilterComposer
    extends Composer<_$BancoAurora, $AlvosDietaTable> {
  $$AlvosDietaTableFilterComposer({
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

  ColumnFilters<String> get tipoDia => $composableBuilder(
    column: $table.tipoDia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteina => $composableBuilder(
    column: $table.proteina,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carboidrato => $composableBuilder(
    column: $table.carboidrato,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gordura => $composableBuilder(
    column: $table.gordura,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AlvosDietaTableOrderingComposer
    extends Composer<_$BancoAurora, $AlvosDietaTable> {
  $$AlvosDietaTableOrderingComposer({
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

  ColumnOrderings<String> get tipoDia => $composableBuilder(
    column: $table.tipoDia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteina => $composableBuilder(
    column: $table.proteina,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carboidrato => $composableBuilder(
    column: $table.carboidrato,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gordura => $composableBuilder(
    column: $table.gordura,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlvosDietaTableAnnotationComposer
    extends Composer<_$BancoAurora, $AlvosDietaTable> {
  $$AlvosDietaTableAnnotationComposer({
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

  GeneratedColumn<String> get tipoDia =>
      $composableBuilder(column: $table.tipoDia, builder: (column) => column);

  GeneratedColumn<double> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<double> get proteina =>
      $composableBuilder(column: $table.proteina, builder: (column) => column);

  GeneratedColumn<double> get carboidrato => $composableBuilder(
    column: $table.carboidrato,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gordura =>
      $composableBuilder(column: $table.gordura, builder: (column) => column);
}

class $$AlvosDietaTableTableManager
    extends
        RootTableManager<
          _$BancoAurora,
          $AlvosDietaTable,
          AlvoDieta,
          $$AlvosDietaTableFilterComposer,
          $$AlvosDietaTableOrderingComposer,
          $$AlvosDietaTableAnnotationComposer,
          $$AlvosDietaTableCreateCompanionBuilder,
          $$AlvosDietaTableUpdateCompanionBuilder,
          (
            AlvoDieta,
            BaseReferences<_$BancoAurora, $AlvosDietaTable, AlvoDieta>,
          ),
          AlvoDieta,
          PrefetchHooks Function()
        > {
  $$AlvosDietaTableTableManager(_$BancoAurora db, $AlvosDietaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlvosDietaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlvosDietaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlvosDietaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                Value<String> tipoDia = const Value.absent(),
                Value<double> kcal = const Value.absent(),
                Value<double> proteina = const Value.absent(),
                Value<double> carboidrato = const Value.absent(),
                Value<double> gordura = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlvosDietaCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                tipoDia: tipoDia,
                kcal: kcal,
                proteina: proteina,
                carboidrato: carboidrato,
                gordura: gordura,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                required String tipoDia,
                required double kcal,
                Value<double> proteina = const Value.absent(),
                Value<double> carboidrato = const Value.absent(),
                Value<double> gordura = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlvosDietaCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                tipoDia: tipoDia,
                kcal: kcal,
                proteina: proteina,
                carboidrato: carboidrato,
                gordura: gordura,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AlvosDietaTable, AlvoDieta>(table),
                  BaseReferences<_$BancoAurora, $AlvosDietaTable, AlvoDieta>(
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

typedef $$AlvosDietaTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $AlvosDietaTable,
      AlvoDieta,
      $$AlvosDietaTableFilterComposer,
      $$AlvosDietaTableOrderingComposer,
      $$AlvosDietaTableAnnotationComposer,
      $$AlvosDietaTableCreateCompanionBuilder,
      $$AlvosDietaTableUpdateCompanionBuilder,
      (AlvoDieta, BaseReferences<_$BancoAurora, $AlvosDietaTable, AlvoDieta>),
      AlvoDieta,
      PrefetchHooks Function()
    >;
typedef $$RegistrosAlimentacaoTableCreateCompanionBuilder =
    RegistrosAlimentacaoCompanion Function({
      Value<String> id,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<DateTime?> apagadoEm,
      required String dia,
      required String refeicao,
      Value<String?> alimentoId,
      required String nome,
      required double gramas,
      required double kcal,
      Value<double> proteina,
      Value<double> carboidrato,
      Value<double> gordura,
      Value<int> rowid,
    });
typedef $$RegistrosAlimentacaoTableUpdateCompanionBuilder =
    RegistrosAlimentacaoCompanion Function({
      Value<String> id,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<DateTime?> apagadoEm,
      Value<String> dia,
      Value<String> refeicao,
      Value<String?> alimentoId,
      Value<String> nome,
      Value<double> gramas,
      Value<double> kcal,
      Value<double> proteina,
      Value<double> carboidrato,
      Value<double> gordura,
      Value<int> rowid,
    });

final class $$RegistrosAlimentacaoTableReferences
    extends
        BaseReferences<
          _$BancoAurora,
          $RegistrosAlimentacaoTable,
          RegistroAlimentacao
        > {
  $$RegistrosAlimentacaoTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AlimentosTable _alimentoIdTable(_$BancoAurora db) => db.alimentos
      .createAlias('registros_alimentacao__alimento_id__alimentos__id');

  $$AlimentosTableProcessedTableManager? get alimentoId {
    final $_column = $_itemColumn<String>('alimento_id');
    if ($_column == null) return null;
    final manager = $$AlimentosTableTableManager(
      $_db,
      $_db.alimentos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_alimentoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RegistrosAlimentacaoTableFilterComposer
    extends Composer<_$BancoAurora, $RegistrosAlimentacaoTable> {
  $$RegistrosAlimentacaoTableFilterComposer({
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

  ColumnFilters<String> get refeicao => $composableBuilder(
    column: $table.refeicao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gramas => $composableBuilder(
    column: $table.gramas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteina => $composableBuilder(
    column: $table.proteina,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carboidrato => $composableBuilder(
    column: $table.carboidrato,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gordura => $composableBuilder(
    column: $table.gordura,
    builder: (column) => ColumnFilters(column),
  );

  $$AlimentosTableFilterComposer get alimentoId {
    final $$AlimentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.alimentoId,
      referencedTable: $db.alimentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlimentosTableFilterComposer(
            $db: $db,
            $table: $db.alimentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RegistrosAlimentacaoTableOrderingComposer
    extends Composer<_$BancoAurora, $RegistrosAlimentacaoTable> {
  $$RegistrosAlimentacaoTableOrderingComposer({
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

  ColumnOrderings<String> get refeicao => $composableBuilder(
    column: $table.refeicao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gramas => $composableBuilder(
    column: $table.gramas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteina => $composableBuilder(
    column: $table.proteina,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carboidrato => $composableBuilder(
    column: $table.carboidrato,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gordura => $composableBuilder(
    column: $table.gordura,
    builder: (column) => ColumnOrderings(column),
  );

  $$AlimentosTableOrderingComposer get alimentoId {
    final $$AlimentosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.alimentoId,
      referencedTable: $db.alimentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlimentosTableOrderingComposer(
            $db: $db,
            $table: $db.alimentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RegistrosAlimentacaoTableAnnotationComposer
    extends Composer<_$BancoAurora, $RegistrosAlimentacaoTable> {
  $$RegistrosAlimentacaoTableAnnotationComposer({
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

  GeneratedColumn<String> get refeicao =>
      $composableBuilder(column: $table.refeicao, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<double> get gramas =>
      $composableBuilder(column: $table.gramas, builder: (column) => column);

  GeneratedColumn<double> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<double> get proteina =>
      $composableBuilder(column: $table.proteina, builder: (column) => column);

  GeneratedColumn<double> get carboidrato => $composableBuilder(
    column: $table.carboidrato,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gordura =>
      $composableBuilder(column: $table.gordura, builder: (column) => column);

  $$AlimentosTableAnnotationComposer get alimentoId {
    final $$AlimentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.alimentoId,
      referencedTable: $db.alimentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlimentosTableAnnotationComposer(
            $db: $db,
            $table: $db.alimentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RegistrosAlimentacaoTableTableManager
    extends
        RootTableManager<
          _$BancoAurora,
          $RegistrosAlimentacaoTable,
          RegistroAlimentacao,
          $$RegistrosAlimentacaoTableFilterComposer,
          $$RegistrosAlimentacaoTableOrderingComposer,
          $$RegistrosAlimentacaoTableAnnotationComposer,
          $$RegistrosAlimentacaoTableCreateCompanionBuilder,
          $$RegistrosAlimentacaoTableUpdateCompanionBuilder,
          (RegistroAlimentacao, $$RegistrosAlimentacaoTableReferences),
          RegistroAlimentacao,
          PrefetchHooks Function({bool alimentoId})
        > {
  $$RegistrosAlimentacaoTableTableManager(
    _$BancoAurora db,
    $RegistrosAlimentacaoTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RegistrosAlimentacaoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RegistrosAlimentacaoTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RegistrosAlimentacaoTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                Value<String> dia = const Value.absent(),
                Value<String> refeicao = const Value.absent(),
                Value<String?> alimentoId = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<double> gramas = const Value.absent(),
                Value<double> kcal = const Value.absent(),
                Value<double> proteina = const Value.absent(),
                Value<double> carboidrato = const Value.absent(),
                Value<double> gordura = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RegistrosAlimentacaoCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                dia: dia,
                refeicao: refeicao,
                alimentoId: alimentoId,
                nome: nome,
                gramas: gramas,
                kcal: kcal,
                proteina: proteina,
                carboidrato: carboidrato,
                gordura: gordura,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                required String dia,
                required String refeicao,
                Value<String?> alimentoId = const Value.absent(),
                required String nome,
                required double gramas,
                required double kcal,
                Value<double> proteina = const Value.absent(),
                Value<double> carboidrato = const Value.absent(),
                Value<double> gordura = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RegistrosAlimentacaoCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                dia: dia,
                refeicao: refeicao,
                alimentoId: alimentoId,
                nome: nome,
                gramas: gramas,
                kcal: kcal,
                proteina: proteina,
                carboidrato: carboidrato,
                gordura: gordura,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RegistrosAlimentacaoTable, RegistroAlimentacao>(
                    table,
                  ),
                  $$RegistrosAlimentacaoTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({alimentoId = false}) {
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
                    if (alimentoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.alimentoId,
                        referencedTable: $$RegistrosAlimentacaoTableReferences
                            ._alimentoIdTable(db),
                        referencedColumn: $$RegistrosAlimentacaoTableReferences
                            ._alimentoIdTable(db)
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

typedef $$RegistrosAlimentacaoTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $RegistrosAlimentacaoTable,
      RegistroAlimentacao,
      $$RegistrosAlimentacaoTableFilterComposer,
      $$RegistrosAlimentacaoTableOrderingComposer,
      $$RegistrosAlimentacaoTableAnnotationComposer,
      $$RegistrosAlimentacaoTableCreateCompanionBuilder,
      $$RegistrosAlimentacaoTableUpdateCompanionBuilder,
      (RegistroAlimentacao, $$RegistrosAlimentacaoTableReferences),
      RegistroAlimentacao,
      PrefetchHooks Function({bool alimentoId})
    >;
typedef $$MensagensAssistenteTableCreateCompanionBuilder =
    MensagensAssistenteCompanion Function({
      Value<String> id,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<DateTime?> apagadoEm,
      required PapelMensagem papel,
      required String texto,
      Value<bool> naFila,
      Value<String?> itemTipo,
      Value<String?> itemId,
      Value<bool> desfeita,
      Value<int> rowid,
    });
typedef $$MensagensAssistenteTableUpdateCompanionBuilder =
    MensagensAssistenteCompanion Function({
      Value<String> id,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<DateTime?> apagadoEm,
      Value<PapelMensagem> papel,
      Value<String> texto,
      Value<bool> naFila,
      Value<String?> itemTipo,
      Value<String?> itemId,
      Value<bool> desfeita,
      Value<int> rowid,
    });

class $$MensagensAssistenteTableFilterComposer
    extends Composer<_$BancoAurora, $MensagensAssistenteTable> {
  $$MensagensAssistenteTableFilterComposer({
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

  ColumnWithTypeConverterFilters<PapelMensagem, PapelMensagem, String>
  get papel => $composableBuilder(
    column: $table.papel,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get texto => $composableBuilder(
    column: $table.texto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get naFila => $composableBuilder(
    column: $table.naFila,
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

  ColumnFilters<bool> get desfeita => $composableBuilder(
    column: $table.desfeita,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MensagensAssistenteTableOrderingComposer
    extends Composer<_$BancoAurora, $MensagensAssistenteTable> {
  $$MensagensAssistenteTableOrderingComposer({
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

  ColumnOrderings<String> get papel => $composableBuilder(
    column: $table.papel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get texto => $composableBuilder(
    column: $table.texto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get naFila => $composableBuilder(
    column: $table.naFila,
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

  ColumnOrderings<bool> get desfeita => $composableBuilder(
    column: $table.desfeita,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MensagensAssistenteTableAnnotationComposer
    extends Composer<_$BancoAurora, $MensagensAssistenteTable> {
  $$MensagensAssistenteTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<PapelMensagem, String> get papel =>
      $composableBuilder(column: $table.papel, builder: (column) => column);

  GeneratedColumn<String> get texto =>
      $composableBuilder(column: $table.texto, builder: (column) => column);

  GeneratedColumn<bool> get naFila =>
      $composableBuilder(column: $table.naFila, builder: (column) => column);

  GeneratedColumn<String> get itemTipo =>
      $composableBuilder(column: $table.itemTipo, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<bool> get desfeita =>
      $composableBuilder(column: $table.desfeita, builder: (column) => column);
}

class $$MensagensAssistenteTableTableManager
    extends
        RootTableManager<
          _$BancoAurora,
          $MensagensAssistenteTable,
          MensagemAssistente,
          $$MensagensAssistenteTableFilterComposer,
          $$MensagensAssistenteTableOrderingComposer,
          $$MensagensAssistenteTableAnnotationComposer,
          $$MensagensAssistenteTableCreateCompanionBuilder,
          $$MensagensAssistenteTableUpdateCompanionBuilder,
          (
            MensagemAssistente,
            BaseReferences<
              _$BancoAurora,
              $MensagensAssistenteTable,
              MensagemAssistente
            >,
          ),
          MensagemAssistente,
          PrefetchHooks Function()
        > {
  $$MensagensAssistenteTableTableManager(
    _$BancoAurora db,
    $MensagensAssistenteTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MensagensAssistenteTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MensagensAssistenteTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MensagensAssistenteTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                Value<PapelMensagem> papel = const Value.absent(),
                Value<String> texto = const Value.absent(),
                Value<bool> naFila = const Value.absent(),
                Value<String?> itemTipo = const Value.absent(),
                Value<String?> itemId = const Value.absent(),
                Value<bool> desfeita = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MensagensAssistenteCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                papel: papel,
                texto: texto,
                naFila: naFila,
                itemTipo: itemTipo,
                itemId: itemId,
                desfeita: desfeita,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                required PapelMensagem papel,
                required String texto,
                Value<bool> naFila = const Value.absent(),
                Value<String?> itemTipo = const Value.absent(),
                Value<String?> itemId = const Value.absent(),
                Value<bool> desfeita = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MensagensAssistenteCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                papel: papel,
                texto: texto,
                naFila: naFila,
                itemTipo: itemTipo,
                itemId: itemId,
                desfeita: desfeita,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MensagensAssistenteTable, MensagemAssistente>(
                    table,
                  ),
                  BaseReferences<
                    _$BancoAurora,
                    $MensagensAssistenteTable,
                    MensagemAssistente
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MensagensAssistenteTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $MensagensAssistenteTable,
      MensagemAssistente,
      $$MensagensAssistenteTableFilterComposer,
      $$MensagensAssistenteTableOrderingComposer,
      $$MensagensAssistenteTableAnnotationComposer,
      $$MensagensAssistenteTableCreateCompanionBuilder,
      $$MensagensAssistenteTableUpdateCompanionBuilder,
      (
        MensagemAssistente,
        BaseReferences<
          _$BancoAurora,
          $MensagensAssistenteTable,
          MensagemAssistente
        >,
      ),
      MensagemAssistente,
      PrefetchHooks Function()
    >;
typedef $$AutomacoesTableCreateCompanionBuilder = AutomacoesCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  required String nome,
  required String modelo,
  Value<int> diasSemana,
  required String horario,
  Value<bool> ativa,
  Value<String?> pedido,
  Value<String?> ultimaExecucao,
  Value<int> rowid,
});
typedef $$AutomacoesTableUpdateCompanionBuilder = AutomacoesCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  Value<String> nome,
  Value<String> modelo,
  Value<int> diasSemana,
  Value<String> horario,
  Value<bool> ativa,
  Value<String?> pedido,
  Value<String?> ultimaExecucao,
  Value<int> rowid,
});

class $$AutomacoesTableFilterComposer
    extends Composer<_$BancoAurora, $AutomacoesTable> {
  $$AutomacoesTableFilterComposer({
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

  ColumnFilters<String> get modelo => $composableBuilder(
    column: $table.modelo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diasSemana => $composableBuilder(
    column: $table.diasSemana,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get horario => $composableBuilder(
    column: $table.horario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ativa => $composableBuilder(
    column: $table.ativa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pedido => $composableBuilder(
    column: $table.pedido,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ultimaExecucao => $composableBuilder(
    column: $table.ultimaExecucao,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AutomacoesTableOrderingComposer
    extends Composer<_$BancoAurora, $AutomacoesTable> {
  $$AutomacoesTableOrderingComposer({
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

  ColumnOrderings<String> get modelo => $composableBuilder(
    column: $table.modelo,
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

  ColumnOrderings<bool> get ativa => $composableBuilder(
    column: $table.ativa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pedido => $composableBuilder(
    column: $table.pedido,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ultimaExecucao => $composableBuilder(
    column: $table.ultimaExecucao,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AutomacoesTableAnnotationComposer
    extends Composer<_$BancoAurora, $AutomacoesTable> {
  $$AutomacoesTableAnnotationComposer({
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

  GeneratedColumn<String> get modelo =>
      $composableBuilder(column: $table.modelo, builder: (column) => column);

  GeneratedColumn<int> get diasSemana => $composableBuilder(
    column: $table.diasSemana,
    builder: (column) => column,
  );

  GeneratedColumn<String> get horario =>
      $composableBuilder(column: $table.horario, builder: (column) => column);

  GeneratedColumn<bool> get ativa =>
      $composableBuilder(column: $table.ativa, builder: (column) => column);

  GeneratedColumn<String> get pedido =>
      $composableBuilder(column: $table.pedido, builder: (column) => column);

  GeneratedColumn<String> get ultimaExecucao => $composableBuilder(
    column: $table.ultimaExecucao,
    builder: (column) => column,
  );
}

class $$AutomacoesTableTableManager
    extends
        RootTableManager<
          _$BancoAurora,
          $AutomacoesTable,
          Automacao,
          $$AutomacoesTableFilterComposer,
          $$AutomacoesTableOrderingComposer,
          $$AutomacoesTableAnnotationComposer,
          $$AutomacoesTableCreateCompanionBuilder,
          $$AutomacoesTableUpdateCompanionBuilder,
          (
            Automacao,
            BaseReferences<_$BancoAurora, $AutomacoesTable, Automacao>,
          ),
          Automacao,
          PrefetchHooks Function()
        > {
  $$AutomacoesTableTableManager(_$BancoAurora db, $AutomacoesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AutomacoesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AutomacoesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AutomacoesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String> modelo = const Value.absent(),
                Value<int> diasSemana = const Value.absent(),
                Value<String> horario = const Value.absent(),
                Value<bool> ativa = const Value.absent(),
                Value<String?> pedido = const Value.absent(),
                Value<String?> ultimaExecucao = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AutomacoesCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                nome: nome,
                modelo: modelo,
                diasSemana: diasSemana,
                horario: horario,
                ativa: ativa,
                pedido: pedido,
                ultimaExecucao: ultimaExecucao,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                required String nome,
                required String modelo,
                Value<int> diasSemana = const Value.absent(),
                required String horario,
                Value<bool> ativa = const Value.absent(),
                Value<String?> pedido = const Value.absent(),
                Value<String?> ultimaExecucao = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AutomacoesCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                nome: nome,
                modelo: modelo,
                diasSemana: diasSemana,
                horario: horario,
                ativa: ativa,
                pedido: pedido,
                ultimaExecucao: ultimaExecucao,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AutomacoesTable, Automacao>(table),
                  BaseReferences<_$BancoAurora, $AutomacoesTable, Automacao>(
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

typedef $$AutomacoesTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $AutomacoesTable,
      Automacao,
      $$AutomacoesTableFilterComposer,
      $$AutomacoesTableOrderingComposer,
      $$AutomacoesTableAnnotationComposer,
      $$AutomacoesTableCreateCompanionBuilder,
      $$AutomacoesTableUpdateCompanionBuilder,
      (Automacao, BaseReferences<_$BancoAurora, $AutomacoesTable, Automacao>),
      Automacao,
      PrefetchHooks Function()
    >;
typedef $$PastasNotasTableCreateCompanionBuilder =
    PastasNotasCompanion Function({
      Value<String> id,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<DateTime?> apagadoEm,
      required String nome,
      Value<int> ordem,
      Value<int> rowid,
    });
typedef $$PastasNotasTableUpdateCompanionBuilder =
    PastasNotasCompanion Function({
      Value<String> id,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<DateTime?> apagadoEm,
      Value<String> nome,
      Value<int> ordem,
      Value<int> rowid,
    });

final class $$PastasNotasTableReferences
    extends BaseReferences<_$BancoAurora, $PastasNotasTable, PastaNota> {
  $$PastasNotasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$NotasTable, List<Nota>> _notasRefsTable(
    _$BancoAurora db,
  ) => MultiTypedResultKey.fromTable(
    db.notas,
    aliasName: 'pastas_notas__id__notas__pasta_id',
  );

  $$NotasTableProcessedTableManager get notasRefs {
    final manager = $$NotasTableTableManager(
      $_db,
      $_db.notas,
    ).filter((f) => f.pastaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_notasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PastasNotasTableFilterComposer
    extends Composer<_$BancoAurora, $PastasNotasTable> {
  $$PastasNotasTableFilterComposer({
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

  ColumnFilters<int> get ordem => $composableBuilder(
    column: $table.ordem,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> notasRefs(
    Expression<bool> Function($$NotasTableFilterComposer f) f,
  ) {
    final $$NotasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notas,
      getReferencedColumn: (t) => t.pastaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotasTableFilterComposer(
            $db: $db,
            $table: $db.notas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PastasNotasTableOrderingComposer
    extends Composer<_$BancoAurora, $PastasNotasTable> {
  $$PastasNotasTableOrderingComposer({
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

  ColumnOrderings<int> get ordem => $composableBuilder(
    column: $table.ordem,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PastasNotasTableAnnotationComposer
    extends Composer<_$BancoAurora, $PastasNotasTable> {
  $$PastasNotasTableAnnotationComposer({
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

  GeneratedColumn<int> get ordem =>
      $composableBuilder(column: $table.ordem, builder: (column) => column);

  Expression<T> notasRefs<T extends Object>(
    Expression<T> Function($$NotasTableAnnotationComposer a) f,
  ) {
    final $$NotasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notas,
      getReferencedColumn: (t) => t.pastaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotasTableAnnotationComposer(
            $db: $db,
            $table: $db.notas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PastasNotasTableTableManager
    extends
        RootTableManager<
          _$BancoAurora,
          $PastasNotasTable,
          PastaNota,
          $$PastasNotasTableFilterComposer,
          $$PastasNotasTableOrderingComposer,
          $$PastasNotasTableAnnotationComposer,
          $$PastasNotasTableCreateCompanionBuilder,
          $$PastasNotasTableUpdateCompanionBuilder,
          (PastaNota, $$PastasNotasTableReferences),
          PastaNota,
          PrefetchHooks Function({bool notasRefs})
        > {
  $$PastasNotasTableTableManager(_$BancoAurora db, $PastasNotasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PastasNotasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PastasNotasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PastasNotasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<int> ordem = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PastasNotasCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                nome: nome,
                ordem: ordem,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                required String nome,
                Value<int> ordem = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PastasNotasCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                nome: nome,
                ordem: ordem,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PastasNotasTable, PastaNota>(table),
                  $$PastasNotasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({notasRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (notasRefs) db.notas],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (notasRefs)
                    await $_getPrefetchedData<
                      PastaNota,
                      $PastasNotasTable,
                      Nota
                    >(
                      currentTable: table,
                      referencedTable: $$PastasNotasTableReferences
                          ._notasRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PastasNotasTableReferences(db, table, p0).notasRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.pastaId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PastasNotasTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $PastasNotasTable,
      PastaNota,
      $$PastasNotasTableFilterComposer,
      $$PastasNotasTableOrderingComposer,
      $$PastasNotasTableAnnotationComposer,
      $$PastasNotasTableCreateCompanionBuilder,
      $$PastasNotasTableUpdateCompanionBuilder,
      (PastaNota, $$PastasNotasTableReferences),
      PastaNota,
      PrefetchHooks Function({bool notasRefs})
    >;
typedef $$NotasTableCreateCompanionBuilder = NotasCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  Value<String?> pastaId,
  Value<TipoNota> tipo,
  Value<String> titulo,
  Value<String> texto,
  Value<String?> itens,
  Value<bool> fixada,
  Value<int> rowid,
});
typedef $$NotasTableUpdateCompanionBuilder = NotasCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  Value<String?> pastaId,
  Value<TipoNota> tipo,
  Value<String> titulo,
  Value<String> texto,
  Value<String?> itens,
  Value<bool> fixada,
  Value<int> rowid,
});

final class $$NotasTableReferences
    extends BaseReferences<_$BancoAurora, $NotasTable, Nota> {
  $$NotasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PastasNotasTable _pastaIdTable(_$BancoAurora db) =>
      db.pastasNotas.createAlias('notas__pasta_id__pastas_notas__id');

  $$PastasNotasTableProcessedTableManager? get pastaId {
    final $_column = $_itemColumn<String>('pasta_id');
    if ($_column == null) return null;
    final manager = $$PastasNotasTableTableManager(
      $_db,
      $_db.pastasNotas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pastaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AnexosNotaTable, List<AnexoNota>>
  _anexosNotaRefsTable(_$BancoAurora db) => MultiTypedResultKey.fromTable(
    db.anexosNota,
    aliasName: 'notas__id__anexos_nota__nota_id',
  );

  $$AnexosNotaTableProcessedTableManager get anexosNotaRefs {
    final manager = $$AnexosNotaTableTableManager(
      $_db,
      $_db.anexosNota,
    ).filter((f) => f.notaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_anexosNotaRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NotasTableFilterComposer extends Composer<_$BancoAurora, $NotasTable> {
  $$NotasTableFilterComposer({
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

  ColumnWithTypeConverterFilters<TipoNota, TipoNota, String> get tipo =>
      $composableBuilder(
        column: $table.tipo,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get texto => $composableBuilder(
    column: $table.texto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itens => $composableBuilder(
    column: $table.itens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get fixada => $composableBuilder(
    column: $table.fixada,
    builder: (column) => ColumnFilters(column),
  );

  $$PastasNotasTableFilterComposer get pastaId {
    final $$PastasNotasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pastaId,
      referencedTable: $db.pastasNotas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PastasNotasTableFilterComposer(
            $db: $db,
            $table: $db.pastasNotas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> anexosNotaRefs(
    Expression<bool> Function($$AnexosNotaTableFilterComposer f) f,
  ) {
    final $$AnexosNotaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.anexosNota,
      getReferencedColumn: (t) => t.notaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AnexosNotaTableFilterComposer(
            $db: $db,
            $table: $db.anexosNota,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotasTableOrderingComposer
    extends Composer<_$BancoAurora, $NotasTable> {
  $$NotasTableOrderingComposer({
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

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get texto => $composableBuilder(
    column: $table.texto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itens => $composableBuilder(
    column: $table.itens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get fixada => $composableBuilder(
    column: $table.fixada,
    builder: (column) => ColumnOrderings(column),
  );

  $$PastasNotasTableOrderingComposer get pastaId {
    final $$PastasNotasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pastaId,
      referencedTable: $db.pastasNotas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PastasNotasTableOrderingComposer(
            $db: $db,
            $table: $db.pastasNotas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotasTableAnnotationComposer
    extends Composer<_$BancoAurora, $NotasTable> {
  $$NotasTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<TipoNota, String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get titulo =>
      $composableBuilder(column: $table.titulo, builder: (column) => column);

  GeneratedColumn<String> get texto =>
      $composableBuilder(column: $table.texto, builder: (column) => column);

  GeneratedColumn<String> get itens =>
      $composableBuilder(column: $table.itens, builder: (column) => column);

  GeneratedColumn<bool> get fixada =>
      $composableBuilder(column: $table.fixada, builder: (column) => column);

  $$PastasNotasTableAnnotationComposer get pastaId {
    final $$PastasNotasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pastaId,
      referencedTable: $db.pastasNotas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PastasNotasTableAnnotationComposer(
            $db: $db,
            $table: $db.pastasNotas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> anexosNotaRefs<T extends Object>(
    Expression<T> Function($$AnexosNotaTableAnnotationComposer a) f,
  ) {
    final $$AnexosNotaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.anexosNota,
      getReferencedColumn: (t) => t.notaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AnexosNotaTableAnnotationComposer(
            $db: $db,
            $table: $db.anexosNota,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotasTableTableManager
    extends
        RootTableManager<
          _$BancoAurora,
          $NotasTable,
          Nota,
          $$NotasTableFilterComposer,
          $$NotasTableOrderingComposer,
          $$NotasTableAnnotationComposer,
          $$NotasTableCreateCompanionBuilder,
          $$NotasTableUpdateCompanionBuilder,
          (Nota, $$NotasTableReferences),
          Nota,
          PrefetchHooks Function({bool pastaId, bool anexosNotaRefs})
        > {
  $$NotasTableTableManager(_$BancoAurora db, $NotasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                Value<String?> pastaId = const Value.absent(),
                Value<TipoNota> tipo = const Value.absent(),
                Value<String> titulo = const Value.absent(),
                Value<String> texto = const Value.absent(),
                Value<String?> itens = const Value.absent(),
                Value<bool> fixada = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotasCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                pastaId: pastaId,
                tipo: tipo,
                titulo: titulo,
                texto: texto,
                itens: itens,
                fixada: fixada,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                Value<String?> pastaId = const Value.absent(),
                Value<TipoNota> tipo = const Value.absent(),
                Value<String> titulo = const Value.absent(),
                Value<String> texto = const Value.absent(),
                Value<String?> itens = const Value.absent(),
                Value<bool> fixada = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotasCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                pastaId: pastaId,
                tipo: tipo,
                titulo: titulo,
                texto: texto,
                itens: itens,
                fixada: fixada,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NotasTable, Nota>(table),
                  $$NotasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pastaId = false, anexosNotaRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (anexosNotaRefs) db.anexosNota],
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
                    if (pastaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.pastaId,
                        referencedTable: $$NotasTableReferences._pastaIdTable(
                          db,
                        ),
                        referencedColumn: $$NotasTableReferences
                            ._pastaIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (anexosNotaRefs)
                    await $_getPrefetchedData<Nota, $NotasTable, AnexoNota>(
                      currentTable: table,
                      referencedTable: $$NotasTableReferences
                          ._anexosNotaRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$NotasTableReferences(db, table, p0).anexosNotaRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.notaId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$NotasTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $NotasTable,
      Nota,
      $$NotasTableFilterComposer,
      $$NotasTableOrderingComposer,
      $$NotasTableAnnotationComposer,
      $$NotasTableCreateCompanionBuilder,
      $$NotasTableUpdateCompanionBuilder,
      (Nota, $$NotasTableReferences),
      Nota,
      PrefetchHooks Function({bool pastaId, bool anexosNotaRefs})
    >;
typedef $$AnexosNotaTableCreateCompanionBuilder = AnexosNotaCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  required String notaId,
  required String tipo,
  Value<String?> hash,
  Value<bool> naNuvem,
  Value<String?> formato,
  Value<int?> duracaoMs,
  Value<String?> onda,
  Value<String?> transcricao,
  Value<int> ordem,
  Value<int> rowid,
});
typedef $$AnexosNotaTableUpdateCompanionBuilder = AnexosNotaCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<DateTime?> apagadoEm,
  Value<String> notaId,
  Value<String> tipo,
  Value<String?> hash,
  Value<bool> naNuvem,
  Value<String?> formato,
  Value<int?> duracaoMs,
  Value<String?> onda,
  Value<String?> transcricao,
  Value<int> ordem,
  Value<int> rowid,
});

final class $$AnexosNotaTableReferences
    extends BaseReferences<_$BancoAurora, $AnexosNotaTable, AnexoNota> {
  $$AnexosNotaTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $NotasTable _notaIdTable(_$BancoAurora db) =>
      db.notas.createAlias('anexos_nota__nota_id__notas__id');

  $$NotasTableProcessedTableManager get notaId {
    final $_column = $_itemColumn<String>('nota_id')!;

    final manager = $$NotasTableTableManager(
      $_db,
      $_db.notas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_notaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AnexosNotaTableFilterComposer
    extends Composer<_$BancoAurora, $AnexosNotaTable> {
  $$AnexosNotaTableFilterComposer({
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

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hash => $composableBuilder(
    column: $table.hash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get naNuvem => $composableBuilder(
    column: $table.naNuvem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get formato => $composableBuilder(
    column: $table.formato,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duracaoMs => $composableBuilder(
    column: $table.duracaoMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get onda => $composableBuilder(
    column: $table.onda,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transcricao => $composableBuilder(
    column: $table.transcricao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordem => $composableBuilder(
    column: $table.ordem,
    builder: (column) => ColumnFilters(column),
  );

  $$NotasTableFilterComposer get notaId {
    final $$NotasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.notaId,
      referencedTable: $db.notas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotasTableFilterComposer(
            $db: $db,
            $table: $db.notas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnexosNotaTableOrderingComposer
    extends Composer<_$BancoAurora, $AnexosNotaTable> {
  $$AnexosNotaTableOrderingComposer({
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

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hash => $composableBuilder(
    column: $table.hash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get naNuvem => $composableBuilder(
    column: $table.naNuvem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formato => $composableBuilder(
    column: $table.formato,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duracaoMs => $composableBuilder(
    column: $table.duracaoMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get onda => $composableBuilder(
    column: $table.onda,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcricao => $composableBuilder(
    column: $table.transcricao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordem => $composableBuilder(
    column: $table.ordem,
    builder: (column) => ColumnOrderings(column),
  );

  $$NotasTableOrderingComposer get notaId {
    final $$NotasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.notaId,
      referencedTable: $db.notas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotasTableOrderingComposer(
            $db: $db,
            $table: $db.notas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnexosNotaTableAnnotationComposer
    extends Composer<_$BancoAurora, $AnexosNotaTable> {
  $$AnexosNotaTableAnnotationComposer({
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

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get hash =>
      $composableBuilder(column: $table.hash, builder: (column) => column);

  GeneratedColumn<bool> get naNuvem =>
      $composableBuilder(column: $table.naNuvem, builder: (column) => column);

  GeneratedColumn<String> get formato =>
      $composableBuilder(column: $table.formato, builder: (column) => column);

  GeneratedColumn<int> get duracaoMs =>
      $composableBuilder(column: $table.duracaoMs, builder: (column) => column);

  GeneratedColumn<String> get onda =>
      $composableBuilder(column: $table.onda, builder: (column) => column);

  GeneratedColumn<String> get transcricao => $composableBuilder(
    column: $table.transcricao,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ordem =>
      $composableBuilder(column: $table.ordem, builder: (column) => column);

  $$NotasTableAnnotationComposer get notaId {
    final $$NotasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.notaId,
      referencedTable: $db.notas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotasTableAnnotationComposer(
            $db: $db,
            $table: $db.notas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnexosNotaTableTableManager
    extends
        RootTableManager<
          _$BancoAurora,
          $AnexosNotaTable,
          AnexoNota,
          $$AnexosNotaTableFilterComposer,
          $$AnexosNotaTableOrderingComposer,
          $$AnexosNotaTableAnnotationComposer,
          $$AnexosNotaTableCreateCompanionBuilder,
          $$AnexosNotaTableUpdateCompanionBuilder,
          (AnexoNota, $$AnexosNotaTableReferences),
          AnexoNota,
          PrefetchHooks Function({bool notaId})
        > {
  $$AnexosNotaTableTableManager(_$BancoAurora db, $AnexosNotaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnexosNotaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnexosNotaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnexosNotaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                Value<String> notaId = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String?> hash = const Value.absent(),
                Value<bool> naNuvem = const Value.absent(),
                Value<String?> formato = const Value.absent(),
                Value<int?> duracaoMs = const Value.absent(),
                Value<String?> onda = const Value.absent(),
                Value<String?> transcricao = const Value.absent(),
                Value<int> ordem = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnexosNotaCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                notaId: notaId,
                tipo: tipo,
                hash: hash,
                naNuvem: naNuvem,
                formato: formato,
                duracaoMs: duracaoMs,
                onda: onda,
                transcricao: transcricao,
                ordem: ordem,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> apagadoEm = const Value.absent(),
                required String notaId,
                required String tipo,
                Value<String?> hash = const Value.absent(),
                Value<bool> naNuvem = const Value.absent(),
                Value<String?> formato = const Value.absent(),
                Value<int?> duracaoMs = const Value.absent(),
                Value<String?> onda = const Value.absent(),
                Value<String?> transcricao = const Value.absent(),
                Value<int> ordem = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnexosNotaCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                apagadoEm: apagadoEm,
                notaId: notaId,
                tipo: tipo,
                hash: hash,
                naNuvem: naNuvem,
                formato: formato,
                duracaoMs: duracaoMs,
                onda: onda,
                transcricao: transcricao,
                ordem: ordem,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AnexosNotaTable, AnexoNota>(table),
                  $$AnexosNotaTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({notaId = false}) {
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
                    if (notaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.notaId,
                        referencedTable: $$AnexosNotaTableReferences
                            ._notaIdTable(db),
                        referencedColumn: $$AnexosNotaTableReferences
                            ._notaIdTable(db)
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

typedef $$AnexosNotaTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoAurora,
      $AnexosNotaTable,
      AnexoNota,
      $$AnexosNotaTableFilterComposer,
      $$AnexosNotaTableOrderingComposer,
      $$AnexosNotaTableAnnotationComposer,
      $$AnexosNotaTableCreateCompanionBuilder,
      $$AnexosNotaTableUpdateCompanionBuilder,
      (AnexoNota, $$AnexosNotaTableReferences),
      AnexoNota,
      PrefetchHooks Function({bool notaId})
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
  $$ObjetivosTableTableManager get objetivos =>
      $$ObjetivosTableTableManager(_db, _db.objetivos);
  $$EtapasTableTableManager get etapas =>
      $$EtapasTableTableManager(_db, _db.etapas);
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
  $$PagamentosTransacaoTableTableManager get pagamentosTransacao =>
      $$PagamentosTransacaoTableTableManager(_db, _db.pagamentosTransacao);
  $$LembretesTableTableManager get lembretes =>
      $$LembretesTableTableManager(_db, _db.lembretes);
  $$CompromissosTableTableManager get compromissos =>
      $$CompromissosTableTableManager(_db, _db.compromissos);
  $$ExerciciosTableTableManager get exercicios =>
      $$ExerciciosTableTableManager(_db, _db.exercicios);
  $$TreinosTableTableManager get treinos =>
      $$TreinosTableTableManager(_db, _db.treinos);
  $$ItensTreinoTableTableManager get itensTreino =>
      $$ItensTreinoTableTableManager(_db, _db.itensTreino);
  $$SessoesTreinoTableTableManager get sessoesTreino =>
      $$SessoesTreinoTableTableManager(_db, _db.sessoesTreino);
  $$SeriesFeitasTableTableManager get seriesFeitas =>
      $$SeriesFeitasTableTableManager(_db, _db.seriesFeitas);
  $$MedidasTableTableManager get medidas =>
      $$MedidasTableTableManager(_db, _db.medidas);
  $$FotosShapeTableTableManager get fotosShape =>
      $$FotosShapeTableTableManager(_db, _db.fotosShape);
  $$AlimentosTableTableManager get alimentos =>
      $$AlimentosTableTableManager(_db, _db.alimentos);
  $$AlvosDietaTableTableManager get alvosDieta =>
      $$AlvosDietaTableTableManager(_db, _db.alvosDieta);
  $$RegistrosAlimentacaoTableTableManager get registrosAlimentacao =>
      $$RegistrosAlimentacaoTableTableManager(_db, _db.registrosAlimentacao);
  $$MensagensAssistenteTableTableManager get mensagensAssistente =>
      $$MensagensAssistenteTableTableManager(_db, _db.mensagensAssistente);
  $$AutomacoesTableTableManager get automacoes =>
      $$AutomacoesTableTableManager(_db, _db.automacoes);
  $$PastasNotasTableTableManager get pastasNotas =>
      $$PastasNotasTableTableManager(_db, _db.pastasNotas);
  $$NotasTableTableManager get notas =>
      $$NotasTableTableManager(_db, _db.notas);
  $$AnexosNotaTableTableManager get anexosNota =>
      $$AnexosNotaTableTableManager(_db, _db.anexosNota);
  $$PreferenciasTableTableManager get preferencias =>
      $$PreferenciasTableTableManager(_db, _db.preferencias);
}
