// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class SyncOutbox extends Table with TableInfo<SyncOutbox, SyncOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SyncOutbox(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _tableName$Meta = const VerificationMeta(
    'tableName\$',
  );
  late final GeneratedColumn<String> tableName$ = GeneratedColumn<String>(
    'table_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  late final GeneratedColumn<String> rowId = GeneratedColumn<String>(
    'row_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [seq, tableName$, rowId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('table_name')) {
      context.handle(
        _tableName$Meta,
        tableName$.isAcceptableOrUnknown(data['table_name']!, _tableName$Meta),
      );
    } else if (isInserting) {
      context.missing(_tableName$Meta);
    }
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rowIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  SyncOutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxData(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      tableName$: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_name'],
      )!,
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}row_id'],
      )!,
    );
  }

  @override
  SyncOutbox createAlias(String alias) {
    return SyncOutbox(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class SyncOutboxData extends DataClass implements Insertable<SyncOutboxData> {
  final int seq;
  final String tableName$;
  final String rowId;
  const SyncOutboxData({
    required this.seq,
    required this.tableName$,
    required this.rowId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['table_name'] = Variable<String>(tableName$);
    map['row_id'] = Variable<String>(rowId);
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      seq: Value(seq),
      tableName$: Value(tableName$),
      rowId: Value(rowId),
    );
  }

  factory SyncOutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxData(
      seq: serializer.fromJson<int>(json['seq']),
      tableName$: serializer.fromJson<String>(json['table_name']),
      rowId: serializer.fromJson<String>(json['row_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'table_name': serializer.toJson<String>(tableName$),
      'row_id': serializer.toJson<String>(rowId),
    };
  }

  SyncOutboxData copyWith({int? seq, String? tableName$, String? rowId}) =>
      SyncOutboxData(
        seq: seq ?? this.seq,
        tableName$: tableName$ ?? this.tableName$,
        rowId: rowId ?? this.rowId,
      );
  SyncOutboxData copyWithCompanion(SyncOutboxCompanion data) {
    return SyncOutboxData(
      seq: data.seq.present ? data.seq.value : this.seq,
      tableName$: data.tableName$.present
          ? data.tableName$.value
          : this.tableName$,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxData(')
          ..write('seq: $seq, ')
          ..write('tableName\$: ${tableName$}, ')
          ..write('rowId: $rowId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(seq, tableName$, rowId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxData &&
          other.seq == this.seq &&
          other.tableName$ == this.tableName$ &&
          other.rowId == this.rowId);
}

class SyncOutboxCompanion extends UpdateCompanion<SyncOutboxData> {
  final Value<int> seq;
  final Value<String> tableName$;
  final Value<String> rowId;
  const SyncOutboxCompanion({
    this.seq = const Value.absent(),
    this.tableName$ = const Value.absent(),
    this.rowId = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    this.seq = const Value.absent(),
    required String tableName$,
    required String rowId,
  }) : tableName$ = Value(tableName$),
       rowId = Value(rowId);
  static Insertable<SyncOutboxData> custom({
    Expression<int>? seq,
    Expression<String>? tableName$,
    Expression<String>? rowId,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (tableName$ != null) 'table_name': tableName$,
      if (rowId != null) 'row_id': rowId,
    });
  }

  SyncOutboxCompanion copyWith({
    Value<int>? seq,
    Value<String>? tableName$,
    Value<String>? rowId,
  }) {
    return SyncOutboxCompanion(
      seq: seq ?? this.seq,
      tableName$: tableName$ ?? this.tableName$,
      rowId: rowId ?? this.rowId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (tableName$.present) {
      map['table_name'] = Variable<String>(tableName$.value);
    }
    if (rowId.present) {
      map['row_id'] = Variable<String>(rowId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('seq: $seq, ')
          ..write('tableName\$: ${tableName$}, ')
          ..write('rowId: $rowId')
          ..write(')'))
        .toString();
  }
}

class SyncState extends Table with TableInfo<SyncState, SyncStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SyncState(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  SyncState createAlias(String alias) {
    return SyncState(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class SyncStateData extends DataClass implements Insertable<SyncStateData> {
  final String key;
  final String? value;
  const SyncStateData({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory SyncStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  SyncStateData copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
  }) => SyncStateData(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  SyncStateData copyWithCompanion(SyncStateCompanion data) {
    return SyncStateData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateData &&
          other.key == this.key &&
          other.value == this.value);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateData> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<SyncStateData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<int>? rowid,
  }) {
    return SyncStateCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products
    with TableInfo<$ProductsTable, ProductRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
    'sku',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitsPerBoxMeta = const VerificationMeta(
    'unitsPerBox',
  );
  @override
  late final GeneratedColumn<int> unitsPerBox = GeneratedColumn<int>(
    'units_per_box',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _stockUnitsMeta = const VerificationMeta(
    'stockUnits',
  );
  @override
  late final GeneratedColumn<int> stockUnits = GeneratedColumn<int>(
    'stock_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _avgCostRawMeta = const VerificationMeta(
    'avgCostRaw',
  );
  @override
  late final GeneratedColumn<int> avgCostRaw = GeneratedColumn<int>(
    'avg_cost_raw',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _suggestedPriceUnitCentsMeta =
      const VerificationMeta('suggestedPriceUnitCents');
  @override
  late final GeneratedColumn<int> suggestedPriceUnitCents =
      GeneratedColumn<int>(
        'suggested_price_unit_cents',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _suggestedPriceBoxCentsMeta =
      const VerificationMeta('suggestedPriceBoxCents');
  @override
  late final GeneratedColumn<int> suggestedPriceBoxCents = GeneratedColumn<int>(
    'suggested_price_box_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _minStockUnitsMeta = const VerificationMeta(
    'minStockUnits',
  );
  @override
  late final GeneratedColumn<int> minStockUnits = GeneratedColumn<int>(
    'min_stock_units',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    sku,
    unitsPerBox,
    stockUnits,
    avgCostRaw,
    suggestedPriceUnitCents,
    suggestedPriceBoxCents,
    isActive,
    minStockUnits,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
        _skuMeta,
        sku.isAcceptableOrUnknown(data['sku']!, _skuMeta),
      );
    }
    if (data.containsKey('units_per_box')) {
      context.handle(
        _unitsPerBoxMeta,
        unitsPerBox.isAcceptableOrUnknown(
          data['units_per_box']!,
          _unitsPerBoxMeta,
        ),
      );
    }
    if (data.containsKey('stock_units')) {
      context.handle(
        _stockUnitsMeta,
        stockUnits.isAcceptableOrUnknown(data['stock_units']!, _stockUnitsMeta),
      );
    }
    if (data.containsKey('avg_cost_raw')) {
      context.handle(
        _avgCostRawMeta,
        avgCostRaw.isAcceptableOrUnknown(
          data['avg_cost_raw']!,
          _avgCostRawMeta,
        ),
      );
    }
    if (data.containsKey('suggested_price_unit_cents')) {
      context.handle(
        _suggestedPriceUnitCentsMeta,
        suggestedPriceUnitCents.isAcceptableOrUnknown(
          data['suggested_price_unit_cents']!,
          _suggestedPriceUnitCentsMeta,
        ),
      );
    }
    if (data.containsKey('suggested_price_box_cents')) {
      context.handle(
        _suggestedPriceBoxCentsMeta,
        suggestedPriceBoxCents.isAcceptableOrUnknown(
          data['suggested_price_box_cents']!,
          _suggestedPriceBoxCentsMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('min_stock_units')) {
      context.handle(
        _minStockUnitsMeta,
        minStockUnits.isAcceptableOrUnknown(
          data['min_stock_units']!,
          _minStockUnitsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sku: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku'],
      ),
      unitsPerBox: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}units_per_box'],
      )!,
      stockUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock_units'],
      )!,
      avgCostRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}avg_cost_raw'],
      )!,
      suggestedPriceUnitCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}suggested_price_unit_cents'],
      )!,
      suggestedPriceBoxCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}suggested_price_box_cents'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      minStockUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_stock_units'],
      ),
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class ProductRow extends DataClass implements Insertable<ProductRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String name;
  final String? sku;

  /// Base units per box (1 = sold without boxes).
  final int unitsPerBox;

  /// Inventory in base units.
  final int stockUnits;

  /// Weighted average cost per base unit, 1/10.000 Bs.
  final int avgCostRaw;

  /// Suggested prices in centavos.
  final int suggestedPriceUnitCents;
  final int? suggestedPriceBoxCents;
  final bool isActive;

  /// v3: "stock bajo" threshold in base units; null = no alert.
  final int? minStockUnits;
  const ProductRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.name,
    this.sku,
    required this.unitsPerBox,
    required this.stockUnits,
    required this.avgCostRaw,
    required this.suggestedPriceUnitCents,
    this.suggestedPriceBoxCents,
    required this.isActive,
    this.minStockUnits,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || sku != null) {
      map['sku'] = Variable<String>(sku);
    }
    map['units_per_box'] = Variable<int>(unitsPerBox);
    map['stock_units'] = Variable<int>(stockUnits);
    map['avg_cost_raw'] = Variable<int>(avgCostRaw);
    map['suggested_price_unit_cents'] = Variable<int>(suggestedPriceUnitCents);
    if (!nullToAbsent || suggestedPriceBoxCents != null) {
      map['suggested_price_box_cents'] = Variable<int>(suggestedPriceBoxCents);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || minStockUnits != null) {
      map['min_stock_units'] = Variable<int>(minStockUnits);
    }
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
      sku: sku == null && nullToAbsent ? const Value.absent() : Value(sku),
      unitsPerBox: Value(unitsPerBox),
      stockUnits: Value(stockUnits),
      avgCostRaw: Value(avgCostRaw),
      suggestedPriceUnitCents: Value(suggestedPriceUnitCents),
      suggestedPriceBoxCents: suggestedPriceBoxCents == null && nullToAbsent
          ? const Value.absent()
          : Value(suggestedPriceBoxCents),
      isActive: Value(isActive),
      minStockUnits: minStockUnits == null && nullToAbsent
          ? const Value.absent()
          : Value(minStockUnits),
    );
  }

  factory ProductRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      sku: serializer.fromJson<String?>(json['sku']),
      unitsPerBox: serializer.fromJson<int>(json['unitsPerBox']),
      stockUnits: serializer.fromJson<int>(json['stockUnits']),
      avgCostRaw: serializer.fromJson<int>(json['avgCostRaw']),
      suggestedPriceUnitCents: serializer.fromJson<int>(
        json['suggestedPriceUnitCents'],
      ),
      suggestedPriceBoxCents: serializer.fromJson<int?>(
        json['suggestedPriceBoxCents'],
      ),
      isActive: serializer.fromJson<bool>(json['isActive']),
      minStockUnits: serializer.fromJson<int?>(json['minStockUnits']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'sku': serializer.toJson<String?>(sku),
      'unitsPerBox': serializer.toJson<int>(unitsPerBox),
      'stockUnits': serializer.toJson<int>(stockUnits),
      'avgCostRaw': serializer.toJson<int>(avgCostRaw),
      'suggestedPriceUnitCents': serializer.toJson<int>(
        suggestedPriceUnitCents,
      ),
      'suggestedPriceBoxCents': serializer.toJson<int?>(suggestedPriceBoxCents),
      'isActive': serializer.toJson<bool>(isActive),
      'minStockUnits': serializer.toJson<int?>(minStockUnits),
    };
  }

  ProductRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? name,
    Value<String?> sku = const Value.absent(),
    int? unitsPerBox,
    int? stockUnits,
    int? avgCostRaw,
    int? suggestedPriceUnitCents,
    Value<int?> suggestedPriceBoxCents = const Value.absent(),
    bool? isActive,
    Value<int?> minStockUnits = const Value.absent(),
  }) => ProductRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    sku: sku.present ? sku.value : this.sku,
    unitsPerBox: unitsPerBox ?? this.unitsPerBox,
    stockUnits: stockUnits ?? this.stockUnits,
    avgCostRaw: avgCostRaw ?? this.avgCostRaw,
    suggestedPriceUnitCents:
        suggestedPriceUnitCents ?? this.suggestedPriceUnitCents,
    suggestedPriceBoxCents: suggestedPriceBoxCents.present
        ? suggestedPriceBoxCents.value
        : this.suggestedPriceBoxCents,
    isActive: isActive ?? this.isActive,
    minStockUnits: minStockUnits.present
        ? minStockUnits.value
        : this.minStockUnits,
  );
  ProductRow copyWithCompanion(ProductsCompanion data) {
    return ProductRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      sku: data.sku.present ? data.sku.value : this.sku,
      unitsPerBox: data.unitsPerBox.present
          ? data.unitsPerBox.value
          : this.unitsPerBox,
      stockUnits: data.stockUnits.present
          ? data.stockUnits.value
          : this.stockUnits,
      avgCostRaw: data.avgCostRaw.present
          ? data.avgCostRaw.value
          : this.avgCostRaw,
      suggestedPriceUnitCents: data.suggestedPriceUnitCents.present
          ? data.suggestedPriceUnitCents.value
          : this.suggestedPriceUnitCents,
      suggestedPriceBoxCents: data.suggestedPriceBoxCents.present
          ? data.suggestedPriceBoxCents.value
          : this.suggestedPriceBoxCents,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      minStockUnits: data.minStockUnits.present
          ? data.minStockUnits.value
          : this.minStockUnits,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('unitsPerBox: $unitsPerBox, ')
          ..write('stockUnits: $stockUnits, ')
          ..write('avgCostRaw: $avgCostRaw, ')
          ..write('suggestedPriceUnitCents: $suggestedPriceUnitCents, ')
          ..write('suggestedPriceBoxCents: $suggestedPriceBoxCents, ')
          ..write('isActive: $isActive, ')
          ..write('minStockUnits: $minStockUnits')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    sku,
    unitsPerBox,
    stockUnits,
    avgCostRaw,
    suggestedPriceUnitCents,
    suggestedPriceBoxCents,
    isActive,
    minStockUnits,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.sku == this.sku &&
          other.unitsPerBox == this.unitsPerBox &&
          other.stockUnits == this.stockUnits &&
          other.avgCostRaw == this.avgCostRaw &&
          other.suggestedPriceUnitCents == this.suggestedPriceUnitCents &&
          other.suggestedPriceBoxCents == this.suggestedPriceBoxCents &&
          other.isActive == this.isActive &&
          other.minStockUnits == this.minStockUnits);
}

class ProductsCompanion extends UpdateCompanion<ProductRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> name;
  final Value<String?> sku;
  final Value<int> unitsPerBox;
  final Value<int> stockUnits;
  final Value<int> avgCostRaw;
  final Value<int> suggestedPriceUnitCents;
  final Value<int?> suggestedPriceBoxCents;
  final Value<bool> isActive;
  final Value<int?> minStockUnits;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.sku = const Value.absent(),
    this.unitsPerBox = const Value.absent(),
    this.stockUnits = const Value.absent(),
    this.avgCostRaw = const Value.absent(),
    this.suggestedPriceUnitCents = const Value.absent(),
    this.suggestedPriceBoxCents = const Value.absent(),
    this.isActive = const Value.absent(),
    this.minStockUnits = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String name,
    this.sku = const Value.absent(),
    this.unitsPerBox = const Value.absent(),
    this.stockUnits = const Value.absent(),
    this.avgCostRaw = const Value.absent(),
    this.suggestedPriceUnitCents = const Value.absent(),
    this.suggestedPriceBoxCents = const Value.absent(),
    this.isActive = const Value.absent(),
    this.minStockUnits = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name);
  static Insertable<ProductRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? name,
    Expression<String>? sku,
    Expression<int>? unitsPerBox,
    Expression<int>? stockUnits,
    Expression<int>? avgCostRaw,
    Expression<int>? suggestedPriceUnitCents,
    Expression<int>? suggestedPriceBoxCents,
    Expression<bool>? isActive,
    Expression<int>? minStockUnits,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (sku != null) 'sku': sku,
      if (unitsPerBox != null) 'units_per_box': unitsPerBox,
      if (stockUnits != null) 'stock_units': stockUnits,
      if (avgCostRaw != null) 'avg_cost_raw': avgCostRaw,
      if (suggestedPriceUnitCents != null)
        'suggested_price_unit_cents': suggestedPriceUnitCents,
      if (suggestedPriceBoxCents != null)
        'suggested_price_box_cents': suggestedPriceBoxCents,
      if (isActive != null) 'is_active': isActive,
      if (minStockUnits != null) 'min_stock_units': minStockUnits,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? name,
    Value<String?>? sku,
    Value<int>? unitsPerBox,
    Value<int>? stockUnits,
    Value<int>? avgCostRaw,
    Value<int>? suggestedPriceUnitCents,
    Value<int?>? suggestedPriceBoxCents,
    Value<bool>? isActive,
    Value<int?>? minStockUnits,
    Value<int>? rowid,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      unitsPerBox: unitsPerBox ?? this.unitsPerBox,
      stockUnits: stockUnits ?? this.stockUnits,
      avgCostRaw: avgCostRaw ?? this.avgCostRaw,
      suggestedPriceUnitCents:
          suggestedPriceUnitCents ?? this.suggestedPriceUnitCents,
      suggestedPriceBoxCents:
          suggestedPriceBoxCents ?? this.suggestedPriceBoxCents,
      isActive: isActive ?? this.isActive,
      minStockUnits: minStockUnits ?? this.minStockUnits,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (unitsPerBox.present) {
      map['units_per_box'] = Variable<int>(unitsPerBox.value);
    }
    if (stockUnits.present) {
      map['stock_units'] = Variable<int>(stockUnits.value);
    }
    if (avgCostRaw.present) {
      map['avg_cost_raw'] = Variable<int>(avgCostRaw.value);
    }
    if (suggestedPriceUnitCents.present) {
      map['suggested_price_unit_cents'] = Variable<int>(
        suggestedPriceUnitCents.value,
      );
    }
    if (suggestedPriceBoxCents.present) {
      map['suggested_price_box_cents'] = Variable<int>(
        suggestedPriceBoxCents.value,
      );
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (minStockUnits.present) {
      map['min_stock_units'] = Variable<int>(minStockUnits.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('unitsPerBox: $unitsPerBox, ')
          ..write('stockUnits: $stockUnits, ')
          ..write('avgCostRaw: $avgCostRaw, ')
          ..write('suggestedPriceUnitCents: $suggestedPriceUnitCents, ')
          ..write('suggestedPriceBoxCents: $suggestedPriceBoxCents, ')
          ..write('isActive: $isActive, ')
          ..write('minStockUnits: $minStockUnits, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchasesTable extends Purchases
    with TableInfo<$PurchasesTable, PurchaseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supplierMeta = const VerificationMeta(
    'supplier',
  );
  @override
  late final GeneratedColumn<String> supplier = GeneratedColumn<String>(
    'supplier',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _registeredByMeta = const VerificationMeta(
    'registeredBy',
  );
  @override
  late final GeneratedColumn<String> registeredBy = GeneratedColumn<String>(
    'registered_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voidedByMeta = const VerificationMeta(
    'voidedBy',
  );
  @override
  late final GeneratedColumn<String> voidedBy = GeneratedColumn<String>(
    'voided_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voidReasonMeta = const VerificationMeta(
    'voidReason',
  );
  @override
  late final GeneratedColumn<String> voidReason = GeneratedColumn<String>(
    'void_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalCentsMeta = const VerificationMeta(
    'totalCents',
  );
  @override
  late final GeneratedColumn<int> totalCents = GeneratedColumn<int>(
    'total_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    date,
    supplier,
    notes,
    registeredBy,
    voidedBy,
    voidReason,
    totalCents,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchases';
  @override
  VerificationContext validateIntegrity(
    Insertable<PurchaseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('supplier')) {
      context.handle(
        _supplierMeta,
        supplier.isAcceptableOrUnknown(data['supplier']!, _supplierMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('registered_by')) {
      context.handle(
        _registeredByMeta,
        registeredBy.isAcceptableOrUnknown(
          data['registered_by']!,
          _registeredByMeta,
        ),
      );
    }
    if (data.containsKey('voided_by')) {
      context.handle(
        _voidedByMeta,
        voidedBy.isAcceptableOrUnknown(data['voided_by']!, _voidedByMeta),
      );
    }
    if (data.containsKey('void_reason')) {
      context.handle(
        _voidReasonMeta,
        voidReason.isAcceptableOrUnknown(data['void_reason']!, _voidReasonMeta),
      );
    }
    if (data.containsKey('total_cents')) {
      context.handle(
        _totalCentsMeta,
        totalCents.isAcceptableOrUnknown(data['total_cents']!, _totalCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_totalCentsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PurchaseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      supplier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      registeredBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registered_by'],
      ),
      voidedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voided_by'],
      ),
      voidReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}void_reason'],
      ),
      totalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cents'],
      )!,
    );
  }

  @override
  $PurchasesTable createAlias(String alias) {
    return $PurchasesTable(attachedDatabase, alias);
  }
}

class PurchaseRow extends DataClass implements Insertable<PurchaseRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime date;
  final String? supplier;
  final String? notes;

  /// v8. Email of the account that registered it (see the entity).
  final String? registeredBy;

  /// v9. Who voided it and why. A voided document has `deleted_at` set:
  /// it stays visible in the history but counts nowhere.
  final String? voidedBy;
  final String? voidReason;
  final int totalCents;
  const PurchaseRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.date,
    this.supplier,
    this.notes,
    this.registeredBy,
    this.voidedBy,
    this.voidReason,
    required this.totalCents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || supplier != null) {
      map['supplier'] = Variable<String>(supplier);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || registeredBy != null) {
      map['registered_by'] = Variable<String>(registeredBy);
    }
    if (!nullToAbsent || voidedBy != null) {
      map['voided_by'] = Variable<String>(voidedBy);
    }
    if (!nullToAbsent || voidReason != null) {
      map['void_reason'] = Variable<String>(voidReason);
    }
    map['total_cents'] = Variable<int>(totalCents);
    return map;
  }

  PurchasesCompanion toCompanion(bool nullToAbsent) {
    return PurchasesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      date: Value(date),
      supplier: supplier == null && nullToAbsent
          ? const Value.absent()
          : Value(supplier),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      registeredBy: registeredBy == null && nullToAbsent
          ? const Value.absent()
          : Value(registeredBy),
      voidedBy: voidedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(voidedBy),
      voidReason: voidReason == null && nullToAbsent
          ? const Value.absent()
          : Value(voidReason),
      totalCents: Value(totalCents),
    );
  }

  factory PurchaseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      date: serializer.fromJson<DateTime>(json['date']),
      supplier: serializer.fromJson<String?>(json['supplier']),
      notes: serializer.fromJson<String?>(json['notes']),
      registeredBy: serializer.fromJson<String?>(json['registeredBy']),
      voidedBy: serializer.fromJson<String?>(json['voidedBy']),
      voidReason: serializer.fromJson<String?>(json['voidReason']),
      totalCents: serializer.fromJson<int>(json['totalCents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'date': serializer.toJson<DateTime>(date),
      'supplier': serializer.toJson<String?>(supplier),
      'notes': serializer.toJson<String?>(notes),
      'registeredBy': serializer.toJson<String?>(registeredBy),
      'voidedBy': serializer.toJson<String?>(voidedBy),
      'voidReason': serializer.toJson<String?>(voidReason),
      'totalCents': serializer.toJson<int>(totalCents),
    };
  }

  PurchaseRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    DateTime? date,
    Value<String?> supplier = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> registeredBy = const Value.absent(),
    Value<String?> voidedBy = const Value.absent(),
    Value<String?> voidReason = const Value.absent(),
    int? totalCents,
  }) => PurchaseRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    date: date ?? this.date,
    supplier: supplier.present ? supplier.value : this.supplier,
    notes: notes.present ? notes.value : this.notes,
    registeredBy: registeredBy.present ? registeredBy.value : this.registeredBy,
    voidedBy: voidedBy.present ? voidedBy.value : this.voidedBy,
    voidReason: voidReason.present ? voidReason.value : this.voidReason,
    totalCents: totalCents ?? this.totalCents,
  );
  PurchaseRow copyWithCompanion(PurchasesCompanion data) {
    return PurchaseRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      date: data.date.present ? data.date.value : this.date,
      supplier: data.supplier.present ? data.supplier.value : this.supplier,
      notes: data.notes.present ? data.notes.value : this.notes,
      registeredBy: data.registeredBy.present
          ? data.registeredBy.value
          : this.registeredBy,
      voidedBy: data.voidedBy.present ? data.voidedBy.value : this.voidedBy,
      voidReason: data.voidReason.present
          ? data.voidReason.value
          : this.voidReason,
      totalCents: data.totalCents.present
          ? data.totalCents.value
          : this.totalCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('date: $date, ')
          ..write('supplier: $supplier, ')
          ..write('notes: $notes, ')
          ..write('registeredBy: $registeredBy, ')
          ..write('voidedBy: $voidedBy, ')
          ..write('voidReason: $voidReason, ')
          ..write('totalCents: $totalCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    date,
    supplier,
    notes,
    registeredBy,
    voidedBy,
    voidReason,
    totalCents,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.date == this.date &&
          other.supplier == this.supplier &&
          other.notes == this.notes &&
          other.registeredBy == this.registeredBy &&
          other.voidedBy == this.voidedBy &&
          other.voidReason == this.voidReason &&
          other.totalCents == this.totalCents);
}

class PurchasesCompanion extends UpdateCompanion<PurchaseRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime> date;
  final Value<String?> supplier;
  final Value<String?> notes;
  final Value<String?> registeredBy;
  final Value<String?> voidedBy;
  final Value<String?> voidReason;
  final Value<int> totalCents;
  final Value<int> rowid;
  const PurchasesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.date = const Value.absent(),
    this.supplier = const Value.absent(),
    this.notes = const Value.absent(),
    this.registeredBy = const Value.absent(),
    this.voidedBy = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.totalCents = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchasesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required DateTime date,
    this.supplier = const Value.absent(),
    this.notes = const Value.absent(),
    this.registeredBy = const Value.absent(),
    this.voidedBy = const Value.absent(),
    this.voidReason = const Value.absent(),
    required int totalCents,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       date = Value(date),
       totalCents = Value(totalCents);
  static Insertable<PurchaseRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? date,
    Expression<String>? supplier,
    Expression<String>? notes,
    Expression<String>? registeredBy,
    Expression<String>? voidedBy,
    Expression<String>? voidReason,
    Expression<int>? totalCents,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (date != null) 'date': date,
      if (supplier != null) 'supplier': supplier,
      if (notes != null) 'notes': notes,
      if (registeredBy != null) 'registered_by': registeredBy,
      if (voidedBy != null) 'voided_by': voidedBy,
      if (voidReason != null) 'void_reason': voidReason,
      if (totalCents != null) 'total_cents': totalCents,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchasesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<DateTime>? date,
    Value<String?>? supplier,
    Value<String?>? notes,
    Value<String?>? registeredBy,
    Value<String?>? voidedBy,
    Value<String?>? voidReason,
    Value<int>? totalCents,
    Value<int>? rowid,
  }) {
    return PurchasesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      date: date ?? this.date,
      supplier: supplier ?? this.supplier,
      notes: notes ?? this.notes,
      registeredBy: registeredBy ?? this.registeredBy,
      voidedBy: voidedBy ?? this.voidedBy,
      voidReason: voidReason ?? this.voidReason,
      totalCents: totalCents ?? this.totalCents,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (supplier.present) {
      map['supplier'] = Variable<String>(supplier.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (registeredBy.present) {
      map['registered_by'] = Variable<String>(registeredBy.value);
    }
    if (voidedBy.present) {
      map['voided_by'] = Variable<String>(voidedBy.value);
    }
    if (voidReason.present) {
      map['void_reason'] = Variable<String>(voidReason.value);
    }
    if (totalCents.present) {
      map['total_cents'] = Variable<int>(totalCents.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchasesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('date: $date, ')
          ..write('supplier: $supplier, ')
          ..write('notes: $notes, ')
          ..write('registeredBy: $registeredBy, ')
          ..write('voidedBy: $voidedBy, ')
          ..write('voidReason: $voidReason, ')
          ..write('totalCents: $totalCents, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchaseLinesTable extends PurchaseLines
    with TableInfo<$PurchaseLinesTable, PurchaseLineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purchaseIdMeta = const VerificationMeta(
    'purchaseId',
  );
  @override
  late final GeneratedColumn<String> purchaseId = GeneratedColumn<String>(
    'purchase_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES purchases (id)',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Presentation, String>
  presentation = GeneratedColumn<String>(
    'presentation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<Presentation>($PurchaseLinesTable.$converterpresentation);
  static const VerificationMeta _unitsBaseMeta = const VerificationMeta(
    'unitsBase',
  );
  @override
  late final GeneratedColumn<int> unitsBase = GeneratedColumn<int>(
    'units_base',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineTotalCentsMeta = const VerificationMeta(
    'lineTotalCents',
  );
  @override
  late final GeneratedColumn<int> lineTotalCents = GeneratedColumn<int>(
    'line_total_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitCostRawMeta = const VerificationMeta(
    'unitCostRaw',
  );
  @override
  late final GeneratedColumn<int> unitCostRaw = GeneratedColumn<int>(
    'unit_cost_raw',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitsPerBoxMeta = const VerificationMeta(
    'unitsPerBox',
  );
  @override
  late final GeneratedColumn<int> unitsPerBox = GeneratedColumn<int>(
    'units_per_box',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiryFromMeta = const VerificationMeta(
    'expiryFrom',
  );
  @override
  late final GeneratedColumn<DateTime> expiryFrom = GeneratedColumn<DateTime>(
    'expiry_from',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiryToMeta = const VerificationMeta(
    'expiryTo',
  );
  @override
  late final GeneratedColumn<DateTime> expiryTo = GeneratedColumn<DateTime>(
    'expiry_to',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lotCodeMeta = const VerificationMeta(
    'lotCode',
  );
  @override
  late final GeneratedColumn<String> lotCode = GeneratedColumn<String>(
    'lot_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    purchaseId,
    productId,
    quantity,
    presentation,
    unitsBase,
    lineTotalCents,
    unitCostRaw,
    unitsPerBox,
    expiryFrom,
    expiryTo,
    lotCode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<PurchaseLineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('purchase_id')) {
      context.handle(
        _purchaseIdMeta,
        purchaseId.isAcceptableOrUnknown(data['purchase_id']!, _purchaseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_purchaseIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('units_base')) {
      context.handle(
        _unitsBaseMeta,
        unitsBase.isAcceptableOrUnknown(data['units_base']!, _unitsBaseMeta),
      );
    } else if (isInserting) {
      context.missing(_unitsBaseMeta);
    }
    if (data.containsKey('line_total_cents')) {
      context.handle(
        _lineTotalCentsMeta,
        lineTotalCents.isAcceptableOrUnknown(
          data['line_total_cents']!,
          _lineTotalCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lineTotalCentsMeta);
    }
    if (data.containsKey('unit_cost_raw')) {
      context.handle(
        _unitCostRawMeta,
        unitCostRaw.isAcceptableOrUnknown(
          data['unit_cost_raw']!,
          _unitCostRawMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitCostRawMeta);
    }
    if (data.containsKey('units_per_box')) {
      context.handle(
        _unitsPerBoxMeta,
        unitsPerBox.isAcceptableOrUnknown(
          data['units_per_box']!,
          _unitsPerBoxMeta,
        ),
      );
    }
    if (data.containsKey('expiry_from')) {
      context.handle(
        _expiryFromMeta,
        expiryFrom.isAcceptableOrUnknown(data['expiry_from']!, _expiryFromMeta),
      );
    }
    if (data.containsKey('expiry_to')) {
      context.handle(
        _expiryToMeta,
        expiryTo.isAcceptableOrUnknown(data['expiry_to']!, _expiryToMeta),
      );
    }
    if (data.containsKey('lot_code')) {
      context.handle(
        _lotCodeMeta,
        lotCode.isAcceptableOrUnknown(data['lot_code']!, _lotCodeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PurchaseLineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseLineRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      purchaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      presentation: $PurchaseLinesTable.$converterpresentation.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}presentation'],
        )!,
      ),
      unitsBase: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}units_base'],
      )!,
      lineTotalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_total_cents'],
      )!,
      unitCostRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_cost_raw'],
      )!,
      unitsPerBox: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}units_per_box'],
      ),
      expiryFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expiry_from'],
      ),
      expiryTo: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expiry_to'],
      ),
      lotCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lot_code'],
      ),
    );
  }

  @override
  $PurchaseLinesTable createAlias(String alias) {
    return $PurchaseLinesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Presentation, String, String>
  $converterpresentation = const EnumNameConverter<Presentation>(
    Presentation.values,
  );
}

class PurchaseLineRow extends DataClass implements Insertable<PurchaseLineRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String purchaseId;
  final String productId;
  final int quantity;
  final Presentation presentation;

  /// [quantity] converted to base units.
  final int unitsBase;
  final int lineTotalCents;

  /// Cost per base unit of this purchase, 1/10.000 Bs.
  final int unitCostRaw;

  /// Box size of this lot; null for loose units.
  final int? unitsPerBox;

  /// Expiry range (a box has from == to). Drives "por vencer" alerts.
  final DateTime? expiryFrom;
  final DateTime? expiryTo;
  final String? lotCode;
  const PurchaseLineRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.purchaseId,
    required this.productId,
    required this.quantity,
    required this.presentation,
    required this.unitsBase,
    required this.lineTotalCents,
    required this.unitCostRaw,
    this.unitsPerBox,
    this.expiryFrom,
    this.expiryTo,
    this.lotCode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['purchase_id'] = Variable<String>(purchaseId);
    map['product_id'] = Variable<String>(productId);
    map['quantity'] = Variable<int>(quantity);
    {
      map['presentation'] = Variable<String>(
        $PurchaseLinesTable.$converterpresentation.toSql(presentation),
      );
    }
    map['units_base'] = Variable<int>(unitsBase);
    map['line_total_cents'] = Variable<int>(lineTotalCents);
    map['unit_cost_raw'] = Variable<int>(unitCostRaw);
    if (!nullToAbsent || unitsPerBox != null) {
      map['units_per_box'] = Variable<int>(unitsPerBox);
    }
    if (!nullToAbsent || expiryFrom != null) {
      map['expiry_from'] = Variable<DateTime>(expiryFrom);
    }
    if (!nullToAbsent || expiryTo != null) {
      map['expiry_to'] = Variable<DateTime>(expiryTo);
    }
    if (!nullToAbsent || lotCode != null) {
      map['lot_code'] = Variable<String>(lotCode);
    }
    return map;
  }

  PurchaseLinesCompanion toCompanion(bool nullToAbsent) {
    return PurchaseLinesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      purchaseId: Value(purchaseId),
      productId: Value(productId),
      quantity: Value(quantity),
      presentation: Value(presentation),
      unitsBase: Value(unitsBase),
      lineTotalCents: Value(lineTotalCents),
      unitCostRaw: Value(unitCostRaw),
      unitsPerBox: unitsPerBox == null && nullToAbsent
          ? const Value.absent()
          : Value(unitsPerBox),
      expiryFrom: expiryFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(expiryFrom),
      expiryTo: expiryTo == null && nullToAbsent
          ? const Value.absent()
          : Value(expiryTo),
      lotCode: lotCode == null && nullToAbsent
          ? const Value.absent()
          : Value(lotCode),
    );
  }

  factory PurchaseLineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseLineRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      purchaseId: serializer.fromJson<String>(json['purchaseId']),
      productId: serializer.fromJson<String>(json['productId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      presentation: $PurchaseLinesTable.$converterpresentation.fromJson(
        serializer.fromJson<String>(json['presentation']),
      ),
      unitsBase: serializer.fromJson<int>(json['unitsBase']),
      lineTotalCents: serializer.fromJson<int>(json['lineTotalCents']),
      unitCostRaw: serializer.fromJson<int>(json['unitCostRaw']),
      unitsPerBox: serializer.fromJson<int?>(json['unitsPerBox']),
      expiryFrom: serializer.fromJson<DateTime?>(json['expiryFrom']),
      expiryTo: serializer.fromJson<DateTime?>(json['expiryTo']),
      lotCode: serializer.fromJson<String?>(json['lotCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'purchaseId': serializer.toJson<String>(purchaseId),
      'productId': serializer.toJson<String>(productId),
      'quantity': serializer.toJson<int>(quantity),
      'presentation': serializer.toJson<String>(
        $PurchaseLinesTable.$converterpresentation.toJson(presentation),
      ),
      'unitsBase': serializer.toJson<int>(unitsBase),
      'lineTotalCents': serializer.toJson<int>(lineTotalCents),
      'unitCostRaw': serializer.toJson<int>(unitCostRaw),
      'unitsPerBox': serializer.toJson<int?>(unitsPerBox),
      'expiryFrom': serializer.toJson<DateTime?>(expiryFrom),
      'expiryTo': serializer.toJson<DateTime?>(expiryTo),
      'lotCode': serializer.toJson<String?>(lotCode),
    };
  }

  PurchaseLineRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? purchaseId,
    String? productId,
    int? quantity,
    Presentation? presentation,
    int? unitsBase,
    int? lineTotalCents,
    int? unitCostRaw,
    Value<int?> unitsPerBox = const Value.absent(),
    Value<DateTime?> expiryFrom = const Value.absent(),
    Value<DateTime?> expiryTo = const Value.absent(),
    Value<String?> lotCode = const Value.absent(),
  }) => PurchaseLineRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    purchaseId: purchaseId ?? this.purchaseId,
    productId: productId ?? this.productId,
    quantity: quantity ?? this.quantity,
    presentation: presentation ?? this.presentation,
    unitsBase: unitsBase ?? this.unitsBase,
    lineTotalCents: lineTotalCents ?? this.lineTotalCents,
    unitCostRaw: unitCostRaw ?? this.unitCostRaw,
    unitsPerBox: unitsPerBox.present ? unitsPerBox.value : this.unitsPerBox,
    expiryFrom: expiryFrom.present ? expiryFrom.value : this.expiryFrom,
    expiryTo: expiryTo.present ? expiryTo.value : this.expiryTo,
    lotCode: lotCode.present ? lotCode.value : this.lotCode,
  );
  PurchaseLineRow copyWithCompanion(PurchaseLinesCompanion data) {
    return PurchaseLineRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      purchaseId: data.purchaseId.present
          ? data.purchaseId.value
          : this.purchaseId,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      presentation: data.presentation.present
          ? data.presentation.value
          : this.presentation,
      unitsBase: data.unitsBase.present ? data.unitsBase.value : this.unitsBase,
      lineTotalCents: data.lineTotalCents.present
          ? data.lineTotalCents.value
          : this.lineTotalCents,
      unitCostRaw: data.unitCostRaw.present
          ? data.unitCostRaw.value
          : this.unitCostRaw,
      unitsPerBox: data.unitsPerBox.present
          ? data.unitsPerBox.value
          : this.unitsPerBox,
      expiryFrom: data.expiryFrom.present
          ? data.expiryFrom.value
          : this.expiryFrom,
      expiryTo: data.expiryTo.present ? data.expiryTo.value : this.expiryTo,
      lotCode: data.lotCode.present ? data.lotCode.value : this.lotCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseLineRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('presentation: $presentation, ')
          ..write('unitsBase: $unitsBase, ')
          ..write('lineTotalCents: $lineTotalCents, ')
          ..write('unitCostRaw: $unitCostRaw, ')
          ..write('unitsPerBox: $unitsPerBox, ')
          ..write('expiryFrom: $expiryFrom, ')
          ..write('expiryTo: $expiryTo, ')
          ..write('lotCode: $lotCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    purchaseId,
    productId,
    quantity,
    presentation,
    unitsBase,
    lineTotalCents,
    unitCostRaw,
    unitsPerBox,
    expiryFrom,
    expiryTo,
    lotCode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseLineRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.purchaseId == this.purchaseId &&
          other.productId == this.productId &&
          other.quantity == this.quantity &&
          other.presentation == this.presentation &&
          other.unitsBase == this.unitsBase &&
          other.lineTotalCents == this.lineTotalCents &&
          other.unitCostRaw == this.unitCostRaw &&
          other.unitsPerBox == this.unitsPerBox &&
          other.expiryFrom == this.expiryFrom &&
          other.expiryTo == this.expiryTo &&
          other.lotCode == this.lotCode);
}

class PurchaseLinesCompanion extends UpdateCompanion<PurchaseLineRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> purchaseId;
  final Value<String> productId;
  final Value<int> quantity;
  final Value<Presentation> presentation;
  final Value<int> unitsBase;
  final Value<int> lineTotalCents;
  final Value<int> unitCostRaw;
  final Value<int?> unitsPerBox;
  final Value<DateTime?> expiryFrom;
  final Value<DateTime?> expiryTo;
  final Value<String?> lotCode;
  final Value<int> rowid;
  const PurchaseLinesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.purchaseId = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.presentation = const Value.absent(),
    this.unitsBase = const Value.absent(),
    this.lineTotalCents = const Value.absent(),
    this.unitCostRaw = const Value.absent(),
    this.unitsPerBox = const Value.absent(),
    this.expiryFrom = const Value.absent(),
    this.expiryTo = const Value.absent(),
    this.lotCode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchaseLinesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String purchaseId,
    required String productId,
    required int quantity,
    required Presentation presentation,
    required int unitsBase,
    required int lineTotalCents,
    required int unitCostRaw,
    this.unitsPerBox = const Value.absent(),
    this.expiryFrom = const Value.absent(),
    this.expiryTo = const Value.absent(),
    this.lotCode = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       purchaseId = Value(purchaseId),
       productId = Value(productId),
       quantity = Value(quantity),
       presentation = Value(presentation),
       unitsBase = Value(unitsBase),
       lineTotalCents = Value(lineTotalCents),
       unitCostRaw = Value(unitCostRaw);
  static Insertable<PurchaseLineRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? purchaseId,
    Expression<String>? productId,
    Expression<int>? quantity,
    Expression<String>? presentation,
    Expression<int>? unitsBase,
    Expression<int>? lineTotalCents,
    Expression<int>? unitCostRaw,
    Expression<int>? unitsPerBox,
    Expression<DateTime>? expiryFrom,
    Expression<DateTime>? expiryTo,
    Expression<String>? lotCode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (purchaseId != null) 'purchase_id': purchaseId,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (presentation != null) 'presentation': presentation,
      if (unitsBase != null) 'units_base': unitsBase,
      if (lineTotalCents != null) 'line_total_cents': lineTotalCents,
      if (unitCostRaw != null) 'unit_cost_raw': unitCostRaw,
      if (unitsPerBox != null) 'units_per_box': unitsPerBox,
      if (expiryFrom != null) 'expiry_from': expiryFrom,
      if (expiryTo != null) 'expiry_to': expiryTo,
      if (lotCode != null) 'lot_code': lotCode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchaseLinesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? purchaseId,
    Value<String>? productId,
    Value<int>? quantity,
    Value<Presentation>? presentation,
    Value<int>? unitsBase,
    Value<int>? lineTotalCents,
    Value<int>? unitCostRaw,
    Value<int?>? unitsPerBox,
    Value<DateTime?>? expiryFrom,
    Value<DateTime?>? expiryTo,
    Value<String?>? lotCode,
    Value<int>? rowid,
  }) {
    return PurchaseLinesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      purchaseId: purchaseId ?? this.purchaseId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      presentation: presentation ?? this.presentation,
      unitsBase: unitsBase ?? this.unitsBase,
      lineTotalCents: lineTotalCents ?? this.lineTotalCents,
      unitCostRaw: unitCostRaw ?? this.unitCostRaw,
      unitsPerBox: unitsPerBox ?? this.unitsPerBox,
      expiryFrom: expiryFrom ?? this.expiryFrom,
      expiryTo: expiryTo ?? this.expiryTo,
      lotCode: lotCode ?? this.lotCode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (purchaseId.present) {
      map['purchase_id'] = Variable<String>(purchaseId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (presentation.present) {
      map['presentation'] = Variable<String>(
        $PurchaseLinesTable.$converterpresentation.toSql(presentation.value),
      );
    }
    if (unitsBase.present) {
      map['units_base'] = Variable<int>(unitsBase.value);
    }
    if (lineTotalCents.present) {
      map['line_total_cents'] = Variable<int>(lineTotalCents.value);
    }
    if (unitCostRaw.present) {
      map['unit_cost_raw'] = Variable<int>(unitCostRaw.value);
    }
    if (unitsPerBox.present) {
      map['units_per_box'] = Variable<int>(unitsPerBox.value);
    }
    if (expiryFrom.present) {
      map['expiry_from'] = Variable<DateTime>(expiryFrom.value);
    }
    if (expiryTo.present) {
      map['expiry_to'] = Variable<DateTime>(expiryTo.value);
    }
    if (lotCode.present) {
      map['lot_code'] = Variable<String>(lotCode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseLinesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('presentation: $presentation, ')
          ..write('unitsBase: $unitsBase, ')
          ..write('lineTotalCents: $lineTotalCents, ')
          ..write('unitCostRaw: $unitCostRaw, ')
          ..write('unitsPerBox: $unitsPerBox, ')
          ..write('expiryFrom: $expiryFrom, ')
          ..write('expiryTo: $expiryTo, ')
          ..write('lotCode: $lotCode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SalesTable extends Sales with TableInfo<$SalesTable, SaleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _registeredByMeta = const VerificationMeta(
    'registeredBy',
  );
  @override
  late final GeneratedColumn<String> registeredBy = GeneratedColumn<String>(
    'registered_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voidedByMeta = const VerificationMeta(
    'voidedBy',
  );
  @override
  late final GeneratedColumn<String> voidedBy = GeneratedColumn<String>(
    'voided_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voidReasonMeta = const VerificationMeta(
    'voidReason',
  );
  @override
  late final GeneratedColumn<String> voidReason = GeneratedColumn<String>(
    'void_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalCentsMeta = const VerificationMeta(
    'totalCents',
  );
  @override
  late final GeneratedColumn<int> totalCents = GeneratedColumn<int>(
    'total_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profitCentsMeta = const VerificationMeta(
    'profitCents',
  );
  @override
  late final GeneratedColumn<int> profitCents = GeneratedColumn<int>(
    'profit_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    date,
    notes,
    registeredBy,
    voidedBy,
    voidReason,
    totalCents,
    profitCents,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('registered_by')) {
      context.handle(
        _registeredByMeta,
        registeredBy.isAcceptableOrUnknown(
          data['registered_by']!,
          _registeredByMeta,
        ),
      );
    }
    if (data.containsKey('voided_by')) {
      context.handle(
        _voidedByMeta,
        voidedBy.isAcceptableOrUnknown(data['voided_by']!, _voidedByMeta),
      );
    }
    if (data.containsKey('void_reason')) {
      context.handle(
        _voidReasonMeta,
        voidReason.isAcceptableOrUnknown(data['void_reason']!, _voidReasonMeta),
      );
    }
    if (data.containsKey('total_cents')) {
      context.handle(
        _totalCentsMeta,
        totalCents.isAcceptableOrUnknown(data['total_cents']!, _totalCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_totalCentsMeta);
    }
    if (data.containsKey('profit_cents')) {
      context.handle(
        _profitCentsMeta,
        profitCents.isAcceptableOrUnknown(
          data['profit_cents']!,
          _profitCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_profitCentsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      registeredBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registered_by'],
      ),
      voidedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voided_by'],
      ),
      voidReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}void_reason'],
      ),
      totalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cents'],
      )!,
      profitCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profit_cents'],
      )!,
    );
  }

  @override
  $SalesTable createAlias(String alias) {
    return $SalesTable(attachedDatabase, alias);
  }
}

class SaleRow extends DataClass implements Insertable<SaleRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime date;
  final String? notes;

  /// v8. Email of the account that registered it (see the entity).
  final String? registeredBy;

  /// v9. Who voided it and why. A voided document has `deleted_at` set:
  /// it stays visible in the history but counts nowhere.
  final String? voidedBy;
  final String? voidReason;
  final int totalCents;
  final int profitCents;
  const SaleRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.date,
    this.notes,
    this.registeredBy,
    this.voidedBy,
    this.voidReason,
    required this.totalCents,
    required this.profitCents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || registeredBy != null) {
      map['registered_by'] = Variable<String>(registeredBy);
    }
    if (!nullToAbsent || voidedBy != null) {
      map['voided_by'] = Variable<String>(voidedBy);
    }
    if (!nullToAbsent || voidReason != null) {
      map['void_reason'] = Variable<String>(voidReason);
    }
    map['total_cents'] = Variable<int>(totalCents);
    map['profit_cents'] = Variable<int>(profitCents);
    return map;
  }

  SalesCompanion toCompanion(bool nullToAbsent) {
    return SalesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      date: Value(date),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      registeredBy: registeredBy == null && nullToAbsent
          ? const Value.absent()
          : Value(registeredBy),
      voidedBy: voidedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(voidedBy),
      voidReason: voidReason == null && nullToAbsent
          ? const Value.absent()
          : Value(voidReason),
      totalCents: Value(totalCents),
      profitCents: Value(profitCents),
    );
  }

  factory SaleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      date: serializer.fromJson<DateTime>(json['date']),
      notes: serializer.fromJson<String?>(json['notes']),
      registeredBy: serializer.fromJson<String?>(json['registeredBy']),
      voidedBy: serializer.fromJson<String?>(json['voidedBy']),
      voidReason: serializer.fromJson<String?>(json['voidReason']),
      totalCents: serializer.fromJson<int>(json['totalCents']),
      profitCents: serializer.fromJson<int>(json['profitCents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'date': serializer.toJson<DateTime>(date),
      'notes': serializer.toJson<String?>(notes),
      'registeredBy': serializer.toJson<String?>(registeredBy),
      'voidedBy': serializer.toJson<String?>(voidedBy),
      'voidReason': serializer.toJson<String?>(voidReason),
      'totalCents': serializer.toJson<int>(totalCents),
      'profitCents': serializer.toJson<int>(profitCents),
    };
  }

  SaleRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    DateTime? date,
    Value<String?> notes = const Value.absent(),
    Value<String?> registeredBy = const Value.absent(),
    Value<String?> voidedBy = const Value.absent(),
    Value<String?> voidReason = const Value.absent(),
    int? totalCents,
    int? profitCents,
  }) => SaleRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    date: date ?? this.date,
    notes: notes.present ? notes.value : this.notes,
    registeredBy: registeredBy.present ? registeredBy.value : this.registeredBy,
    voidedBy: voidedBy.present ? voidedBy.value : this.voidedBy,
    voidReason: voidReason.present ? voidReason.value : this.voidReason,
    totalCents: totalCents ?? this.totalCents,
    profitCents: profitCents ?? this.profitCents,
  );
  SaleRow copyWithCompanion(SalesCompanion data) {
    return SaleRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      date: data.date.present ? data.date.value : this.date,
      notes: data.notes.present ? data.notes.value : this.notes,
      registeredBy: data.registeredBy.present
          ? data.registeredBy.value
          : this.registeredBy,
      voidedBy: data.voidedBy.present ? data.voidedBy.value : this.voidedBy,
      voidReason: data.voidReason.present
          ? data.voidReason.value
          : this.voidReason,
      totalCents: data.totalCents.present
          ? data.totalCents.value
          : this.totalCents,
      profitCents: data.profitCents.present
          ? data.profitCents.value
          : this.profitCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('registeredBy: $registeredBy, ')
          ..write('voidedBy: $voidedBy, ')
          ..write('voidReason: $voidReason, ')
          ..write('totalCents: $totalCents, ')
          ..write('profitCents: $profitCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    date,
    notes,
    registeredBy,
    voidedBy,
    voidReason,
    totalCents,
    profitCents,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.date == this.date &&
          other.notes == this.notes &&
          other.registeredBy == this.registeredBy &&
          other.voidedBy == this.voidedBy &&
          other.voidReason == this.voidReason &&
          other.totalCents == this.totalCents &&
          other.profitCents == this.profitCents);
}

class SalesCompanion extends UpdateCompanion<SaleRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime> date;
  final Value<String?> notes;
  final Value<String?> registeredBy;
  final Value<String?> voidedBy;
  final Value<String?> voidReason;
  final Value<int> totalCents;
  final Value<int> profitCents;
  final Value<int> rowid;
  const SalesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    this.registeredBy = const Value.absent(),
    this.voidedBy = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.totalCents = const Value.absent(),
    this.profitCents = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required DateTime date,
    this.notes = const Value.absent(),
    this.registeredBy = const Value.absent(),
    this.voidedBy = const Value.absent(),
    this.voidReason = const Value.absent(),
    required int totalCents,
    required int profitCents,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       date = Value(date),
       totalCents = Value(totalCents),
       profitCents = Value(profitCents);
  static Insertable<SaleRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? date,
    Expression<String>? notes,
    Expression<String>? registeredBy,
    Expression<String>? voidedBy,
    Expression<String>? voidReason,
    Expression<int>? totalCents,
    Expression<int>? profitCents,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (date != null) 'date': date,
      if (notes != null) 'notes': notes,
      if (registeredBy != null) 'registered_by': registeredBy,
      if (voidedBy != null) 'voided_by': voidedBy,
      if (voidReason != null) 'void_reason': voidReason,
      if (totalCents != null) 'total_cents': totalCents,
      if (profitCents != null) 'profit_cents': profitCents,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<DateTime>? date,
    Value<String?>? notes,
    Value<String?>? registeredBy,
    Value<String?>? voidedBy,
    Value<String?>? voidReason,
    Value<int>? totalCents,
    Value<int>? profitCents,
    Value<int>? rowid,
  }) {
    return SalesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      registeredBy: registeredBy ?? this.registeredBy,
      voidedBy: voidedBy ?? this.voidedBy,
      voidReason: voidReason ?? this.voidReason,
      totalCents: totalCents ?? this.totalCents,
      profitCents: profitCents ?? this.profitCents,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (registeredBy.present) {
      map['registered_by'] = Variable<String>(registeredBy.value);
    }
    if (voidedBy.present) {
      map['voided_by'] = Variable<String>(voidedBy.value);
    }
    if (voidReason.present) {
      map['void_reason'] = Variable<String>(voidReason.value);
    }
    if (totalCents.present) {
      map['total_cents'] = Variable<int>(totalCents.value);
    }
    if (profitCents.present) {
      map['profit_cents'] = Variable<int>(profitCents.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('registeredBy: $registeredBy, ')
          ..write('voidedBy: $voidedBy, ')
          ..write('voidReason: $voidReason, ')
          ..write('totalCents: $totalCents, ')
          ..write('profitCents: $profitCents, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SaleLinesTable extends SaleLines
    with TableInfo<$SaleLinesTable, SaleLineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sales (id)',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Presentation, String>
  presentation = GeneratedColumn<String>(
    'presentation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<Presentation>($SaleLinesTable.$converterpresentation);
  static const VerificationMeta _unitsBaseMeta = const VerificationMeta(
    'unitsBase',
  );
  @override
  late final GeneratedColumn<int> unitsBase = GeneratedColumn<int>(
    'units_base',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceCentsMeta = const VerificationMeta(
    'unitPriceCents',
  );
  @override
  late final GeneratedColumn<int> unitPriceCents = GeneratedColumn<int>(
    'unit_price_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _suggestedUnitPriceCentsMeta =
      const VerificationMeta('suggestedUnitPriceCents');
  @override
  late final GeneratedColumn<int> suggestedUnitPriceCents =
      GeneratedColumn<int>(
        'suggested_unit_price_cents',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _lineTotalCentsMeta = const VerificationMeta(
    'lineTotalCents',
  );
  @override
  late final GeneratedColumn<int> lineTotalCents = GeneratedColumn<int>(
    'line_total_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costAtSaleRawMeta = const VerificationMeta(
    'costAtSaleRaw',
  );
  @override
  late final GeneratedColumn<int> costAtSaleRaw = GeneratedColumn<int>(
    'cost_at_sale_raw',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costTotalCentsMeta = const VerificationMeta(
    'costTotalCents',
  );
  @override
  late final GeneratedColumn<int> costTotalCents = GeneratedColumn<int>(
    'cost_total_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profitCentsMeta = const VerificationMeta(
    'profitCents',
  );
  @override
  late final GeneratedColumn<int> profitCents = GeneratedColumn<int>(
    'profit_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    saleId,
    productId,
    quantity,
    presentation,
    unitsBase,
    unitPriceCents,
    suggestedUnitPriceCents,
    lineTotalCents,
    costAtSaleRaw,
    costTotalCents,
    profitCents,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleLineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('units_base')) {
      context.handle(
        _unitsBaseMeta,
        unitsBase.isAcceptableOrUnknown(data['units_base']!, _unitsBaseMeta),
      );
    } else if (isInserting) {
      context.missing(_unitsBaseMeta);
    }
    if (data.containsKey('unit_price_cents')) {
      context.handle(
        _unitPriceCentsMeta,
        unitPriceCents.isAcceptableOrUnknown(
          data['unit_price_cents']!,
          _unitPriceCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitPriceCentsMeta);
    }
    if (data.containsKey('suggested_unit_price_cents')) {
      context.handle(
        _suggestedUnitPriceCentsMeta,
        suggestedUnitPriceCents.isAcceptableOrUnknown(
          data['suggested_unit_price_cents']!,
          _suggestedUnitPriceCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_suggestedUnitPriceCentsMeta);
    }
    if (data.containsKey('line_total_cents')) {
      context.handle(
        _lineTotalCentsMeta,
        lineTotalCents.isAcceptableOrUnknown(
          data['line_total_cents']!,
          _lineTotalCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lineTotalCentsMeta);
    }
    if (data.containsKey('cost_at_sale_raw')) {
      context.handle(
        _costAtSaleRawMeta,
        costAtSaleRaw.isAcceptableOrUnknown(
          data['cost_at_sale_raw']!,
          _costAtSaleRawMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_costAtSaleRawMeta);
    }
    if (data.containsKey('cost_total_cents')) {
      context.handle(
        _costTotalCentsMeta,
        costTotalCents.isAcceptableOrUnknown(
          data['cost_total_cents']!,
          _costTotalCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_costTotalCentsMeta);
    }
    if (data.containsKey('profit_cents')) {
      context.handle(
        _profitCentsMeta,
        profitCents.isAcceptableOrUnknown(
          data['profit_cents']!,
          _profitCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_profitCentsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleLineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleLineRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      presentation: $SaleLinesTable.$converterpresentation.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}presentation'],
        )!,
      ),
      unitsBase: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}units_base'],
      )!,
      unitPriceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_cents'],
      )!,
      suggestedUnitPriceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}suggested_unit_price_cents'],
      )!,
      lineTotalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_total_cents'],
      )!,
      costAtSaleRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cost_at_sale_raw'],
      )!,
      costTotalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cost_total_cents'],
      )!,
      profitCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profit_cents'],
      )!,
    );
  }

  @override
  $SaleLinesTable createAlias(String alias) {
    return $SaleLinesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Presentation, String, String>
  $converterpresentation = const EnumNameConverter<Presentation>(
    Presentation.values,
  );
}

class SaleLineRow extends DataClass implements Insertable<SaleLineRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String saleId;
  final String productId;
  final int quantity;
  final Presentation presentation;
  final int unitsBase;

  /// Price charged per presentation, in centavos.
  final int unitPriceCents;

  /// Suggested price per presentation when the sale was made.
  final int suggestedUnitPriceCents;
  final int lineTotalCents;

  /// Average cost per base unit at the time of the sale, 1/10.000 Bs.
  final int costAtSaleRaw;
  final int costTotalCents;
  final int profitCents;
  const SaleLineRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.presentation,
    required this.unitsBase,
    required this.unitPriceCents,
    required this.suggestedUnitPriceCents,
    required this.lineTotalCents,
    required this.costAtSaleRaw,
    required this.costTotalCents,
    required this.profitCents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sale_id'] = Variable<String>(saleId);
    map['product_id'] = Variable<String>(productId);
    map['quantity'] = Variable<int>(quantity);
    {
      map['presentation'] = Variable<String>(
        $SaleLinesTable.$converterpresentation.toSql(presentation),
      );
    }
    map['units_base'] = Variable<int>(unitsBase);
    map['unit_price_cents'] = Variable<int>(unitPriceCents);
    map['suggested_unit_price_cents'] = Variable<int>(suggestedUnitPriceCents);
    map['line_total_cents'] = Variable<int>(lineTotalCents);
    map['cost_at_sale_raw'] = Variable<int>(costAtSaleRaw);
    map['cost_total_cents'] = Variable<int>(costTotalCents);
    map['profit_cents'] = Variable<int>(profitCents);
    return map;
  }

  SaleLinesCompanion toCompanion(bool nullToAbsent) {
    return SaleLinesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      saleId: Value(saleId),
      productId: Value(productId),
      quantity: Value(quantity),
      presentation: Value(presentation),
      unitsBase: Value(unitsBase),
      unitPriceCents: Value(unitPriceCents),
      suggestedUnitPriceCents: Value(suggestedUnitPriceCents),
      lineTotalCents: Value(lineTotalCents),
      costAtSaleRaw: Value(costAtSaleRaw),
      costTotalCents: Value(costTotalCents),
      profitCents: Value(profitCents),
    );
  }

  factory SaleLineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleLineRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      saleId: serializer.fromJson<String>(json['saleId']),
      productId: serializer.fromJson<String>(json['productId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      presentation: $SaleLinesTable.$converterpresentation.fromJson(
        serializer.fromJson<String>(json['presentation']),
      ),
      unitsBase: serializer.fromJson<int>(json['unitsBase']),
      unitPriceCents: serializer.fromJson<int>(json['unitPriceCents']),
      suggestedUnitPriceCents: serializer.fromJson<int>(
        json['suggestedUnitPriceCents'],
      ),
      lineTotalCents: serializer.fromJson<int>(json['lineTotalCents']),
      costAtSaleRaw: serializer.fromJson<int>(json['costAtSaleRaw']),
      costTotalCents: serializer.fromJson<int>(json['costTotalCents']),
      profitCents: serializer.fromJson<int>(json['profitCents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'saleId': serializer.toJson<String>(saleId),
      'productId': serializer.toJson<String>(productId),
      'quantity': serializer.toJson<int>(quantity),
      'presentation': serializer.toJson<String>(
        $SaleLinesTable.$converterpresentation.toJson(presentation),
      ),
      'unitsBase': serializer.toJson<int>(unitsBase),
      'unitPriceCents': serializer.toJson<int>(unitPriceCents),
      'suggestedUnitPriceCents': serializer.toJson<int>(
        suggestedUnitPriceCents,
      ),
      'lineTotalCents': serializer.toJson<int>(lineTotalCents),
      'costAtSaleRaw': serializer.toJson<int>(costAtSaleRaw),
      'costTotalCents': serializer.toJson<int>(costTotalCents),
      'profitCents': serializer.toJson<int>(profitCents),
    };
  }

  SaleLineRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? saleId,
    String? productId,
    int? quantity,
    Presentation? presentation,
    int? unitsBase,
    int? unitPriceCents,
    int? suggestedUnitPriceCents,
    int? lineTotalCents,
    int? costAtSaleRaw,
    int? costTotalCents,
    int? profitCents,
  }) => SaleLineRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    saleId: saleId ?? this.saleId,
    productId: productId ?? this.productId,
    quantity: quantity ?? this.quantity,
    presentation: presentation ?? this.presentation,
    unitsBase: unitsBase ?? this.unitsBase,
    unitPriceCents: unitPriceCents ?? this.unitPriceCents,
    suggestedUnitPriceCents:
        suggestedUnitPriceCents ?? this.suggestedUnitPriceCents,
    lineTotalCents: lineTotalCents ?? this.lineTotalCents,
    costAtSaleRaw: costAtSaleRaw ?? this.costAtSaleRaw,
    costTotalCents: costTotalCents ?? this.costTotalCents,
    profitCents: profitCents ?? this.profitCents,
  );
  SaleLineRow copyWithCompanion(SaleLinesCompanion data) {
    return SaleLineRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      presentation: data.presentation.present
          ? data.presentation.value
          : this.presentation,
      unitsBase: data.unitsBase.present ? data.unitsBase.value : this.unitsBase,
      unitPriceCents: data.unitPriceCents.present
          ? data.unitPriceCents.value
          : this.unitPriceCents,
      suggestedUnitPriceCents: data.suggestedUnitPriceCents.present
          ? data.suggestedUnitPriceCents.value
          : this.suggestedUnitPriceCents,
      lineTotalCents: data.lineTotalCents.present
          ? data.lineTotalCents.value
          : this.lineTotalCents,
      costAtSaleRaw: data.costAtSaleRaw.present
          ? data.costAtSaleRaw.value
          : this.costAtSaleRaw,
      costTotalCents: data.costTotalCents.present
          ? data.costTotalCents.value
          : this.costTotalCents,
      profitCents: data.profitCents.present
          ? data.profitCents.value
          : this.profitCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleLineRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('presentation: $presentation, ')
          ..write('unitsBase: $unitsBase, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('suggestedUnitPriceCents: $suggestedUnitPriceCents, ')
          ..write('lineTotalCents: $lineTotalCents, ')
          ..write('costAtSaleRaw: $costAtSaleRaw, ')
          ..write('costTotalCents: $costTotalCents, ')
          ..write('profitCents: $profitCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    saleId,
    productId,
    quantity,
    presentation,
    unitsBase,
    unitPriceCents,
    suggestedUnitPriceCents,
    lineTotalCents,
    costAtSaleRaw,
    costTotalCents,
    profitCents,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleLineRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.saleId == this.saleId &&
          other.productId == this.productId &&
          other.quantity == this.quantity &&
          other.presentation == this.presentation &&
          other.unitsBase == this.unitsBase &&
          other.unitPriceCents == this.unitPriceCents &&
          other.suggestedUnitPriceCents == this.suggestedUnitPriceCents &&
          other.lineTotalCents == this.lineTotalCents &&
          other.costAtSaleRaw == this.costAtSaleRaw &&
          other.costTotalCents == this.costTotalCents &&
          other.profitCents == this.profitCents);
}

class SaleLinesCompanion extends UpdateCompanion<SaleLineRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> saleId;
  final Value<String> productId;
  final Value<int> quantity;
  final Value<Presentation> presentation;
  final Value<int> unitsBase;
  final Value<int> unitPriceCents;
  final Value<int> suggestedUnitPriceCents;
  final Value<int> lineTotalCents;
  final Value<int> costAtSaleRaw;
  final Value<int> costTotalCents;
  final Value<int> profitCents;
  final Value<int> rowid;
  const SaleLinesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.saleId = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.presentation = const Value.absent(),
    this.unitsBase = const Value.absent(),
    this.unitPriceCents = const Value.absent(),
    this.suggestedUnitPriceCents = const Value.absent(),
    this.lineTotalCents = const Value.absent(),
    this.costAtSaleRaw = const Value.absent(),
    this.costTotalCents = const Value.absent(),
    this.profitCents = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaleLinesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String saleId,
    required String productId,
    required int quantity,
    required Presentation presentation,
    required int unitsBase,
    required int unitPriceCents,
    required int suggestedUnitPriceCents,
    required int lineTotalCents,
    required int costAtSaleRaw,
    required int costTotalCents,
    required int profitCents,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       saleId = Value(saleId),
       productId = Value(productId),
       quantity = Value(quantity),
       presentation = Value(presentation),
       unitsBase = Value(unitsBase),
       unitPriceCents = Value(unitPriceCents),
       suggestedUnitPriceCents = Value(suggestedUnitPriceCents),
       lineTotalCents = Value(lineTotalCents),
       costAtSaleRaw = Value(costAtSaleRaw),
       costTotalCents = Value(costTotalCents),
       profitCents = Value(profitCents);
  static Insertable<SaleLineRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? saleId,
    Expression<String>? productId,
    Expression<int>? quantity,
    Expression<String>? presentation,
    Expression<int>? unitsBase,
    Expression<int>? unitPriceCents,
    Expression<int>? suggestedUnitPriceCents,
    Expression<int>? lineTotalCents,
    Expression<int>? costAtSaleRaw,
    Expression<int>? costTotalCents,
    Expression<int>? profitCents,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (saleId != null) 'sale_id': saleId,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (presentation != null) 'presentation': presentation,
      if (unitsBase != null) 'units_base': unitsBase,
      if (unitPriceCents != null) 'unit_price_cents': unitPriceCents,
      if (suggestedUnitPriceCents != null)
        'suggested_unit_price_cents': suggestedUnitPriceCents,
      if (lineTotalCents != null) 'line_total_cents': lineTotalCents,
      if (costAtSaleRaw != null) 'cost_at_sale_raw': costAtSaleRaw,
      if (costTotalCents != null) 'cost_total_cents': costTotalCents,
      if (profitCents != null) 'profit_cents': profitCents,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaleLinesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? saleId,
    Value<String>? productId,
    Value<int>? quantity,
    Value<Presentation>? presentation,
    Value<int>? unitsBase,
    Value<int>? unitPriceCents,
    Value<int>? suggestedUnitPriceCents,
    Value<int>? lineTotalCents,
    Value<int>? costAtSaleRaw,
    Value<int>? costTotalCents,
    Value<int>? profitCents,
    Value<int>? rowid,
  }) {
    return SaleLinesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      presentation: presentation ?? this.presentation,
      unitsBase: unitsBase ?? this.unitsBase,
      unitPriceCents: unitPriceCents ?? this.unitPriceCents,
      suggestedUnitPriceCents:
          suggestedUnitPriceCents ?? this.suggestedUnitPriceCents,
      lineTotalCents: lineTotalCents ?? this.lineTotalCents,
      costAtSaleRaw: costAtSaleRaw ?? this.costAtSaleRaw,
      costTotalCents: costTotalCents ?? this.costTotalCents,
      profitCents: profitCents ?? this.profitCents,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (presentation.present) {
      map['presentation'] = Variable<String>(
        $SaleLinesTable.$converterpresentation.toSql(presentation.value),
      );
    }
    if (unitsBase.present) {
      map['units_base'] = Variable<int>(unitsBase.value);
    }
    if (unitPriceCents.present) {
      map['unit_price_cents'] = Variable<int>(unitPriceCents.value);
    }
    if (suggestedUnitPriceCents.present) {
      map['suggested_unit_price_cents'] = Variable<int>(
        suggestedUnitPriceCents.value,
      );
    }
    if (lineTotalCents.present) {
      map['line_total_cents'] = Variable<int>(lineTotalCents.value);
    }
    if (costAtSaleRaw.present) {
      map['cost_at_sale_raw'] = Variable<int>(costAtSaleRaw.value);
    }
    if (costTotalCents.present) {
      map['cost_total_cents'] = Variable<int>(costTotalCents.value);
    }
    if (profitCents.present) {
      map['profit_cents'] = Variable<int>(profitCents.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleLinesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('presentation: $presentation, ')
          ..write('unitsBase: $unitsBase, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('suggestedUnitPriceCents: $suggestedUnitPriceCents, ')
          ..write('lineTotalCents: $lineTotalCents, ')
          ..write('costAtSaleRaw: $costAtSaleRaw, ')
          ..write('costTotalCents: $costTotalCents, ')
          ..write('profitCents: $profitCents, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SaleExtraChargesTable extends SaleExtraCharges
    with TableInfo<$SaleExtraChargesTable, SaleExtraChargeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleExtraChargesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sales (id)',
    ),
  );
  static const VerificationMeta _conceptMeta = const VerificationMeta(
    'concept',
  );
  @override
  late final GeneratedColumn<String> concept = GeneratedColumn<String>(
    'concept',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidByCustomerMeta = const VerificationMeta(
    'paidByCustomer',
  );
  @override
  late final GeneratedColumn<bool> paidByCustomer = GeneratedColumn<bool>(
    'paid_by_customer',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("paid_by_customer" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    saleId,
    concept,
    amountCents,
    paidByCustomer,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_extra_charges';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleExtraChargeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('concept')) {
      context.handle(
        _conceptMeta,
        concept.isAcceptableOrUnknown(data['concept']!, _conceptMeta),
      );
    } else if (isInserting) {
      context.missing(_conceptMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('paid_by_customer')) {
      context.handle(
        _paidByCustomerMeta,
        paidByCustomer.isAcceptableOrUnknown(
          data['paid_by_customer']!,
          _paidByCustomerMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleExtraChargeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleExtraChargeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      )!,
      concept: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concept'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      paidByCustomer: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}paid_by_customer'],
      )!,
    );
  }

  @override
  $SaleExtraChargesTable createAlias(String alias) {
    return $SaleExtraChargesTable(attachedDatabase, alias);
  }
}

class SaleExtraChargeRow extends DataClass
    implements Insertable<SaleExtraChargeRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String saleId;
  final String concept;
  final int amountCents;

  /// v7. True: the customer pays it on top of the products (adds to total
  /// and profit). False: the shop pays it (total unchanged, profit lowered).
  /// Every row from before v7 was charged to the customer.
  final bool paidByCustomer;
  const SaleExtraChargeRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.saleId,
    required this.concept,
    required this.amountCents,
    required this.paidByCustomer,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sale_id'] = Variable<String>(saleId);
    map['concept'] = Variable<String>(concept);
    map['amount_cents'] = Variable<int>(amountCents);
    map['paid_by_customer'] = Variable<bool>(paidByCustomer);
    return map;
  }

  SaleExtraChargesCompanion toCompanion(bool nullToAbsent) {
    return SaleExtraChargesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      saleId: Value(saleId),
      concept: Value(concept),
      amountCents: Value(amountCents),
      paidByCustomer: Value(paidByCustomer),
    );
  }

  factory SaleExtraChargeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleExtraChargeRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      saleId: serializer.fromJson<String>(json['saleId']),
      concept: serializer.fromJson<String>(json['concept']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      paidByCustomer: serializer.fromJson<bool>(json['paidByCustomer']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'saleId': serializer.toJson<String>(saleId),
      'concept': serializer.toJson<String>(concept),
      'amountCents': serializer.toJson<int>(amountCents),
      'paidByCustomer': serializer.toJson<bool>(paidByCustomer),
    };
  }

  SaleExtraChargeRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? saleId,
    String? concept,
    int? amountCents,
    bool? paidByCustomer,
  }) => SaleExtraChargeRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    saleId: saleId ?? this.saleId,
    concept: concept ?? this.concept,
    amountCents: amountCents ?? this.amountCents,
    paidByCustomer: paidByCustomer ?? this.paidByCustomer,
  );
  SaleExtraChargeRow copyWithCompanion(SaleExtraChargesCompanion data) {
    return SaleExtraChargeRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      concept: data.concept.present ? data.concept.value : this.concept,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      paidByCustomer: data.paidByCustomer.present
          ? data.paidByCustomer.value
          : this.paidByCustomer,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleExtraChargeRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('saleId: $saleId, ')
          ..write('concept: $concept, ')
          ..write('amountCents: $amountCents, ')
          ..write('paidByCustomer: $paidByCustomer')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    saleId,
    concept,
    amountCents,
    paidByCustomer,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleExtraChargeRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.saleId == this.saleId &&
          other.concept == this.concept &&
          other.amountCents == this.amountCents &&
          other.paidByCustomer == this.paidByCustomer);
}

class SaleExtraChargesCompanion extends UpdateCompanion<SaleExtraChargeRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> saleId;
  final Value<String> concept;
  final Value<int> amountCents;
  final Value<bool> paidByCustomer;
  final Value<int> rowid;
  const SaleExtraChargesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.saleId = const Value.absent(),
    this.concept = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.paidByCustomer = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaleExtraChargesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String saleId,
    required String concept,
    required int amountCents,
    this.paidByCustomer = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       saleId = Value(saleId),
       concept = Value(concept),
       amountCents = Value(amountCents);
  static Insertable<SaleExtraChargeRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? saleId,
    Expression<String>? concept,
    Expression<int>? amountCents,
    Expression<bool>? paidByCustomer,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (saleId != null) 'sale_id': saleId,
      if (concept != null) 'concept': concept,
      if (amountCents != null) 'amount_cents': amountCents,
      if (paidByCustomer != null) 'paid_by_customer': paidByCustomer,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaleExtraChargesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? saleId,
    Value<String>? concept,
    Value<int>? amountCents,
    Value<bool>? paidByCustomer,
    Value<int>? rowid,
  }) {
    return SaleExtraChargesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      saleId: saleId ?? this.saleId,
      concept: concept ?? this.concept,
      amountCents: amountCents ?? this.amountCents,
      paidByCustomer: paidByCustomer ?? this.paidByCustomer,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (concept.present) {
      map['concept'] = Variable<String>(concept.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (paidByCustomer.present) {
      map['paid_by_customer'] = Variable<bool>(paidByCustomer.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleExtraChargesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('saleId: $saleId, ')
          ..write('concept: $concept, ')
          ..write('amountCents: $amountCents, ')
          ..write('paidByCustomer: $paidByCustomer, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockAdjustmentsTable extends StockAdjustments
    with TableInfo<$StockAdjustmentsTable, StockAdjustmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockAdjustmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Presentation, String>
  presentation = GeneratedColumn<String>(
    'presentation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<Presentation>($StockAdjustmentsTable.$converterpresentation);
  static const VerificationMeta _unitsBaseMeta = const VerificationMeta(
    'unitsBase',
  );
  @override
  late final GeneratedColumn<int> unitsBase = GeneratedColumn<int>(
    'units_base',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AdjustmentReason, String> reason =
      GeneratedColumn<String>(
        'reason',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AdjustmentReason>(
        $StockAdjustmentsTable.$converterreason,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _registeredByMeta = const VerificationMeta(
    'registeredBy',
  );
  @override
  late final GeneratedColumn<String> registeredBy = GeneratedColumn<String>(
    'registered_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voidedByMeta = const VerificationMeta(
    'voidedBy',
  );
  @override
  late final GeneratedColumn<String> voidedBy = GeneratedColumn<String>(
    'voided_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voidReasonMeta = const VerificationMeta(
    'voidReason',
  );
  @override
  late final GeneratedColumn<String> voidReason = GeneratedColumn<String>(
    'void_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitCostRawMeta = const VerificationMeta(
    'unitCostRaw',
  );
  @override
  late final GeneratedColumn<int> unitCostRaw = GeneratedColumn<int>(
    'unit_cost_raw',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costTotalCentsMeta = const VerificationMeta(
    'costTotalCents',
  );
  @override
  late final GeneratedColumn<int> costTotalCents = GeneratedColumn<int>(
    'cost_total_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    productId,
    date,
    quantity,
    presentation,
    unitsBase,
    reason,
    notes,
    registeredBy,
    voidedBy,
    voidReason,
    unitCostRaw,
    costTotalCents,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_adjustments';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockAdjustmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('units_base')) {
      context.handle(
        _unitsBaseMeta,
        unitsBase.isAcceptableOrUnknown(data['units_base']!, _unitsBaseMeta),
      );
    } else if (isInserting) {
      context.missing(_unitsBaseMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('registered_by')) {
      context.handle(
        _registeredByMeta,
        registeredBy.isAcceptableOrUnknown(
          data['registered_by']!,
          _registeredByMeta,
        ),
      );
    }
    if (data.containsKey('voided_by')) {
      context.handle(
        _voidedByMeta,
        voidedBy.isAcceptableOrUnknown(data['voided_by']!, _voidedByMeta),
      );
    }
    if (data.containsKey('void_reason')) {
      context.handle(
        _voidReasonMeta,
        voidReason.isAcceptableOrUnknown(data['void_reason']!, _voidReasonMeta),
      );
    }
    if (data.containsKey('unit_cost_raw')) {
      context.handle(
        _unitCostRawMeta,
        unitCostRaw.isAcceptableOrUnknown(
          data['unit_cost_raw']!,
          _unitCostRawMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitCostRawMeta);
    }
    if (data.containsKey('cost_total_cents')) {
      context.handle(
        _costTotalCentsMeta,
        costTotalCents.isAcceptableOrUnknown(
          data['cost_total_cents']!,
          _costTotalCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_costTotalCentsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockAdjustmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockAdjustmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      presentation: $StockAdjustmentsTable.$converterpresentation.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}presentation'],
        )!,
      ),
      unitsBase: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}units_base'],
      )!,
      reason: $StockAdjustmentsTable.$converterreason.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}reason'],
        )!,
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      registeredBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registered_by'],
      ),
      voidedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voided_by'],
      ),
      voidReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}void_reason'],
      ),
      unitCostRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_cost_raw'],
      )!,
      costTotalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cost_total_cents'],
      )!,
    );
  }

  @override
  $StockAdjustmentsTable createAlias(String alias) {
    return $StockAdjustmentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Presentation, String, String>
  $converterpresentation = const EnumNameConverter<Presentation>(
    Presentation.values,
  );
  static JsonTypeConverter2<AdjustmentReason, String, String> $converterreason =
      const EnumNameConverter<AdjustmentReason>(AdjustmentReason.values);
}

class StockAdjustmentRow extends DataClass
    implements Insertable<StockAdjustmentRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String productId;
  final DateTime date;
  final int quantity;
  final Presentation presentation;
  final int unitsBase;
  final AdjustmentReason reason;
  final String? notes;

  /// v8. Email of the account that registered it (see the entity).
  final String? registeredBy;

  /// v9. Who voided it and why. A voided document has `deleted_at` set:
  /// it stays visible in the history but counts nowhere.
  final String? voidedBy;
  final String? voidReason;

  /// Average cost per base unit when written off, 1/10.000 Bs.
  final int unitCostRaw;
  final int costTotalCents;
  const StockAdjustmentRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.productId,
    required this.date,
    required this.quantity,
    required this.presentation,
    required this.unitsBase,
    required this.reason,
    this.notes,
    this.registeredBy,
    this.voidedBy,
    this.voidReason,
    required this.unitCostRaw,
    required this.costTotalCents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['product_id'] = Variable<String>(productId);
    map['date'] = Variable<DateTime>(date);
    map['quantity'] = Variable<int>(quantity);
    {
      map['presentation'] = Variable<String>(
        $StockAdjustmentsTable.$converterpresentation.toSql(presentation),
      );
    }
    map['units_base'] = Variable<int>(unitsBase);
    {
      map['reason'] = Variable<String>(
        $StockAdjustmentsTable.$converterreason.toSql(reason),
      );
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || registeredBy != null) {
      map['registered_by'] = Variable<String>(registeredBy);
    }
    if (!nullToAbsent || voidedBy != null) {
      map['voided_by'] = Variable<String>(voidedBy);
    }
    if (!nullToAbsent || voidReason != null) {
      map['void_reason'] = Variable<String>(voidReason);
    }
    map['unit_cost_raw'] = Variable<int>(unitCostRaw);
    map['cost_total_cents'] = Variable<int>(costTotalCents);
    return map;
  }

  StockAdjustmentsCompanion toCompanion(bool nullToAbsent) {
    return StockAdjustmentsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      productId: Value(productId),
      date: Value(date),
      quantity: Value(quantity),
      presentation: Value(presentation),
      unitsBase: Value(unitsBase),
      reason: Value(reason),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      registeredBy: registeredBy == null && nullToAbsent
          ? const Value.absent()
          : Value(registeredBy),
      voidedBy: voidedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(voidedBy),
      voidReason: voidReason == null && nullToAbsent
          ? const Value.absent()
          : Value(voidReason),
      unitCostRaw: Value(unitCostRaw),
      costTotalCents: Value(costTotalCents),
    );
  }

  factory StockAdjustmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockAdjustmentRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      productId: serializer.fromJson<String>(json['productId']),
      date: serializer.fromJson<DateTime>(json['date']),
      quantity: serializer.fromJson<int>(json['quantity']),
      presentation: $StockAdjustmentsTable.$converterpresentation.fromJson(
        serializer.fromJson<String>(json['presentation']),
      ),
      unitsBase: serializer.fromJson<int>(json['unitsBase']),
      reason: $StockAdjustmentsTable.$converterreason.fromJson(
        serializer.fromJson<String>(json['reason']),
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      registeredBy: serializer.fromJson<String?>(json['registeredBy']),
      voidedBy: serializer.fromJson<String?>(json['voidedBy']),
      voidReason: serializer.fromJson<String?>(json['voidReason']),
      unitCostRaw: serializer.fromJson<int>(json['unitCostRaw']),
      costTotalCents: serializer.fromJson<int>(json['costTotalCents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'productId': serializer.toJson<String>(productId),
      'date': serializer.toJson<DateTime>(date),
      'quantity': serializer.toJson<int>(quantity),
      'presentation': serializer.toJson<String>(
        $StockAdjustmentsTable.$converterpresentation.toJson(presentation),
      ),
      'unitsBase': serializer.toJson<int>(unitsBase),
      'reason': serializer.toJson<String>(
        $StockAdjustmentsTable.$converterreason.toJson(reason),
      ),
      'notes': serializer.toJson<String?>(notes),
      'registeredBy': serializer.toJson<String?>(registeredBy),
      'voidedBy': serializer.toJson<String?>(voidedBy),
      'voidReason': serializer.toJson<String?>(voidReason),
      'unitCostRaw': serializer.toJson<int>(unitCostRaw),
      'costTotalCents': serializer.toJson<int>(costTotalCents),
    };
  }

  StockAdjustmentRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? productId,
    DateTime? date,
    int? quantity,
    Presentation? presentation,
    int? unitsBase,
    AdjustmentReason? reason,
    Value<String?> notes = const Value.absent(),
    Value<String?> registeredBy = const Value.absent(),
    Value<String?> voidedBy = const Value.absent(),
    Value<String?> voidReason = const Value.absent(),
    int? unitCostRaw,
    int? costTotalCents,
  }) => StockAdjustmentRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    productId: productId ?? this.productId,
    date: date ?? this.date,
    quantity: quantity ?? this.quantity,
    presentation: presentation ?? this.presentation,
    unitsBase: unitsBase ?? this.unitsBase,
    reason: reason ?? this.reason,
    notes: notes.present ? notes.value : this.notes,
    registeredBy: registeredBy.present ? registeredBy.value : this.registeredBy,
    voidedBy: voidedBy.present ? voidedBy.value : this.voidedBy,
    voidReason: voidReason.present ? voidReason.value : this.voidReason,
    unitCostRaw: unitCostRaw ?? this.unitCostRaw,
    costTotalCents: costTotalCents ?? this.costTotalCents,
  );
  StockAdjustmentRow copyWithCompanion(StockAdjustmentsCompanion data) {
    return StockAdjustmentRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      productId: data.productId.present ? data.productId.value : this.productId,
      date: data.date.present ? data.date.value : this.date,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      presentation: data.presentation.present
          ? data.presentation.value
          : this.presentation,
      unitsBase: data.unitsBase.present ? data.unitsBase.value : this.unitsBase,
      reason: data.reason.present ? data.reason.value : this.reason,
      notes: data.notes.present ? data.notes.value : this.notes,
      registeredBy: data.registeredBy.present
          ? data.registeredBy.value
          : this.registeredBy,
      voidedBy: data.voidedBy.present ? data.voidedBy.value : this.voidedBy,
      voidReason: data.voidReason.present
          ? data.voidReason.value
          : this.voidReason,
      unitCostRaw: data.unitCostRaw.present
          ? data.unitCostRaw.value
          : this.unitCostRaw,
      costTotalCents: data.costTotalCents.present
          ? data.costTotalCents.value
          : this.costTotalCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockAdjustmentRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('productId: $productId, ')
          ..write('date: $date, ')
          ..write('quantity: $quantity, ')
          ..write('presentation: $presentation, ')
          ..write('unitsBase: $unitsBase, ')
          ..write('reason: $reason, ')
          ..write('notes: $notes, ')
          ..write('registeredBy: $registeredBy, ')
          ..write('voidedBy: $voidedBy, ')
          ..write('voidReason: $voidReason, ')
          ..write('unitCostRaw: $unitCostRaw, ')
          ..write('costTotalCents: $costTotalCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    productId,
    date,
    quantity,
    presentation,
    unitsBase,
    reason,
    notes,
    registeredBy,
    voidedBy,
    voidReason,
    unitCostRaw,
    costTotalCents,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockAdjustmentRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.productId == this.productId &&
          other.date == this.date &&
          other.quantity == this.quantity &&
          other.presentation == this.presentation &&
          other.unitsBase == this.unitsBase &&
          other.reason == this.reason &&
          other.notes == this.notes &&
          other.registeredBy == this.registeredBy &&
          other.voidedBy == this.voidedBy &&
          other.voidReason == this.voidReason &&
          other.unitCostRaw == this.unitCostRaw &&
          other.costTotalCents == this.costTotalCents);
}

class StockAdjustmentsCompanion extends UpdateCompanion<StockAdjustmentRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> productId;
  final Value<DateTime> date;
  final Value<int> quantity;
  final Value<Presentation> presentation;
  final Value<int> unitsBase;
  final Value<AdjustmentReason> reason;
  final Value<String?> notes;
  final Value<String?> registeredBy;
  final Value<String?> voidedBy;
  final Value<String?> voidReason;
  final Value<int> unitCostRaw;
  final Value<int> costTotalCents;
  final Value<int> rowid;
  const StockAdjustmentsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.productId = const Value.absent(),
    this.date = const Value.absent(),
    this.quantity = const Value.absent(),
    this.presentation = const Value.absent(),
    this.unitsBase = const Value.absent(),
    this.reason = const Value.absent(),
    this.notes = const Value.absent(),
    this.registeredBy = const Value.absent(),
    this.voidedBy = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.unitCostRaw = const Value.absent(),
    this.costTotalCents = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockAdjustmentsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String productId,
    required DateTime date,
    required int quantity,
    required Presentation presentation,
    required int unitsBase,
    required AdjustmentReason reason,
    this.notes = const Value.absent(),
    this.registeredBy = const Value.absent(),
    this.voidedBy = const Value.absent(),
    this.voidReason = const Value.absent(),
    required int unitCostRaw,
    required int costTotalCents,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       productId = Value(productId),
       date = Value(date),
       quantity = Value(quantity),
       presentation = Value(presentation),
       unitsBase = Value(unitsBase),
       reason = Value(reason),
       unitCostRaw = Value(unitCostRaw),
       costTotalCents = Value(costTotalCents);
  static Insertable<StockAdjustmentRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? productId,
    Expression<DateTime>? date,
    Expression<int>? quantity,
    Expression<String>? presentation,
    Expression<int>? unitsBase,
    Expression<String>? reason,
    Expression<String>? notes,
    Expression<String>? registeredBy,
    Expression<String>? voidedBy,
    Expression<String>? voidReason,
    Expression<int>? unitCostRaw,
    Expression<int>? costTotalCents,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (productId != null) 'product_id': productId,
      if (date != null) 'date': date,
      if (quantity != null) 'quantity': quantity,
      if (presentation != null) 'presentation': presentation,
      if (unitsBase != null) 'units_base': unitsBase,
      if (reason != null) 'reason': reason,
      if (notes != null) 'notes': notes,
      if (registeredBy != null) 'registered_by': registeredBy,
      if (voidedBy != null) 'voided_by': voidedBy,
      if (voidReason != null) 'void_reason': voidReason,
      if (unitCostRaw != null) 'unit_cost_raw': unitCostRaw,
      if (costTotalCents != null) 'cost_total_cents': costTotalCents,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockAdjustmentsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? productId,
    Value<DateTime>? date,
    Value<int>? quantity,
    Value<Presentation>? presentation,
    Value<int>? unitsBase,
    Value<AdjustmentReason>? reason,
    Value<String?>? notes,
    Value<String?>? registeredBy,
    Value<String?>? voidedBy,
    Value<String?>? voidReason,
    Value<int>? unitCostRaw,
    Value<int>? costTotalCents,
    Value<int>? rowid,
  }) {
    return StockAdjustmentsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      productId: productId ?? this.productId,
      date: date ?? this.date,
      quantity: quantity ?? this.quantity,
      presentation: presentation ?? this.presentation,
      unitsBase: unitsBase ?? this.unitsBase,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      registeredBy: registeredBy ?? this.registeredBy,
      voidedBy: voidedBy ?? this.voidedBy,
      voidReason: voidReason ?? this.voidReason,
      unitCostRaw: unitCostRaw ?? this.unitCostRaw,
      costTotalCents: costTotalCents ?? this.costTotalCents,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (presentation.present) {
      map['presentation'] = Variable<String>(
        $StockAdjustmentsTable.$converterpresentation.toSql(presentation.value),
      );
    }
    if (unitsBase.present) {
      map['units_base'] = Variable<int>(unitsBase.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(
        $StockAdjustmentsTable.$converterreason.toSql(reason.value),
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (registeredBy.present) {
      map['registered_by'] = Variable<String>(registeredBy.value);
    }
    if (voidedBy.present) {
      map['voided_by'] = Variable<String>(voidedBy.value);
    }
    if (voidReason.present) {
      map['void_reason'] = Variable<String>(voidReason.value);
    }
    if (unitCostRaw.present) {
      map['unit_cost_raw'] = Variable<int>(unitCostRaw.value);
    }
    if (costTotalCents.present) {
      map['cost_total_cents'] = Variable<int>(costTotalCents.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockAdjustmentsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('productId: $productId, ')
          ..write('date: $date, ')
          ..write('quantity: $quantity, ')
          ..write('presentation: $presentation, ')
          ..write('unitsBase: $unitsBase, ')
          ..write('reason: $reason, ')
          ..write('notes: $notes, ')
          ..write('registeredBy: $registeredBy, ')
          ..write('voidedBy: $voidedBy, ')
          ..write('voidReason: $voidReason, ')
          ..write('unitCostRaw: $unitCostRaw, ')
          ..write('costTotalCents: $costTotalCents, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final SyncOutbox syncOutbox = SyncOutbox(this);
  late final SyncState syncState = SyncState(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final Trigger productsOutboxInsert = Trigger(
    'CREATE TRIGGER products_outbox_insert AFTER INSERT ON products WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE "key" = \'applying_remote\') BEGIN INSERT INTO sync_outbox (table_name, row_id) VALUES (\'products\', new.id);END',
    'products_outbox_insert',
  );
  late final Trigger productsOutboxUpdate = Trigger(
    'CREATE TRIGGER products_outbox_update AFTER UPDATE OF name, sku, units_per_box, suggested_price_unit_cents, suggested_price_box_cents, is_active, min_stock_units, deleted_at ON products WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE "key" = \'applying_remote\') BEGIN INSERT INTO sync_outbox (table_name, row_id) VALUES (\'products\', new.id);END',
    'products_outbox_update',
  );
  late final $PurchasesTable purchases = $PurchasesTable(this);
  late final Trigger purchasesOutboxInsert = Trigger(
    'CREATE TRIGGER purchases_outbox_insert AFTER INSERT ON purchases WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE "key" = \'applying_remote\') BEGIN INSERT INTO sync_outbox (table_name, row_id) VALUES (\'purchases\', new.id);END',
    'purchases_outbox_insert',
  );
  late final Trigger purchasesOutboxUpdate = Trigger(
    'CREATE TRIGGER purchases_outbox_update AFTER UPDATE ON purchases WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE "key" = \'applying_remote\') BEGIN INSERT INTO sync_outbox (table_name, row_id) VALUES (\'purchases\', new.id);END',
    'purchases_outbox_update',
  );
  late final $PurchaseLinesTable purchaseLines = $PurchaseLinesTable(this);
  late final Trigger purchaseLinesOutboxInsert = Trigger(
    'CREATE TRIGGER purchase_lines_outbox_insert AFTER INSERT ON purchase_lines WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE "key" = \'applying_remote\') BEGIN INSERT INTO sync_outbox (table_name, row_id) VALUES (\'purchase_lines\', new.id);END',
    'purchase_lines_outbox_insert',
  );
  late final Trigger purchaseLinesOutboxUpdate = Trigger(
    'CREATE TRIGGER purchase_lines_outbox_update AFTER UPDATE ON purchase_lines WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE "key" = \'applying_remote\') BEGIN INSERT INTO sync_outbox (table_name, row_id) VALUES (\'purchase_lines\', new.id);END',
    'purchase_lines_outbox_update',
  );
  late final $SalesTable sales = $SalesTable(this);
  late final Trigger salesOutboxInsert = Trigger(
    'CREATE TRIGGER sales_outbox_insert AFTER INSERT ON sales WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE "key" = \'applying_remote\') BEGIN INSERT INTO sync_outbox (table_name, row_id) VALUES (\'sales\', new.id);END',
    'sales_outbox_insert',
  );
  late final Trigger salesOutboxUpdate = Trigger(
    'CREATE TRIGGER sales_outbox_update AFTER UPDATE ON sales WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE "key" = \'applying_remote\') BEGIN INSERT INTO sync_outbox (table_name, row_id) VALUES (\'sales\', new.id);END',
    'sales_outbox_update',
  );
  late final $SaleLinesTable saleLines = $SaleLinesTable(this);
  late final Trigger saleLinesOutboxInsert = Trigger(
    'CREATE TRIGGER sale_lines_outbox_insert AFTER INSERT ON sale_lines WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE "key" = \'applying_remote\') BEGIN INSERT INTO sync_outbox (table_name, row_id) VALUES (\'sale_lines\', new.id);END',
    'sale_lines_outbox_insert',
  );
  late final Trigger saleLinesOutboxUpdate = Trigger(
    'CREATE TRIGGER sale_lines_outbox_update AFTER UPDATE ON sale_lines WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE "key" = \'applying_remote\') BEGIN INSERT INTO sync_outbox (table_name, row_id) VALUES (\'sale_lines\', new.id);END',
    'sale_lines_outbox_update',
  );
  late final $SaleExtraChargesTable saleExtraCharges = $SaleExtraChargesTable(
    this,
  );
  late final Trigger saleExtraChargesOutboxInsert = Trigger(
    'CREATE TRIGGER sale_extra_charges_outbox_insert AFTER INSERT ON sale_extra_charges WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE "key" = \'applying_remote\') BEGIN INSERT INTO sync_outbox (table_name, row_id) VALUES (\'sale_extra_charges\', new.id);END',
    'sale_extra_charges_outbox_insert',
  );
  late final Trigger saleExtraChargesOutboxUpdate = Trigger(
    'CREATE TRIGGER sale_extra_charges_outbox_update AFTER UPDATE ON sale_extra_charges WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE "key" = \'applying_remote\') BEGIN INSERT INTO sync_outbox (table_name, row_id) VALUES (\'sale_extra_charges\', new.id);END',
    'sale_extra_charges_outbox_update',
  );
  late final $StockAdjustmentsTable stockAdjustments = $StockAdjustmentsTable(
    this,
  );
  late final Trigger stockAdjustmentsOutboxInsert = Trigger(
    'CREATE TRIGGER stock_adjustments_outbox_insert AFTER INSERT ON stock_adjustments WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE "key" = \'applying_remote\') BEGIN INSERT INTO sync_outbox (table_name, row_id) VALUES (\'stock_adjustments\', new.id);END',
    'stock_adjustments_outbox_insert',
  );
  late final Trigger stockAdjustmentsOutboxUpdate = Trigger(
    'CREATE TRIGGER stock_adjustments_outbox_update AFTER UPDATE ON stock_adjustments WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE "key" = \'applying_remote\') BEGIN INSERT INTO sync_outbox (table_name, row_id) VALUES (\'stock_adjustments\', new.id);END',
    'stock_adjustments_outbox_update',
  );
  late final Index stockAdjustmentsProductIdx = Index(
    'stock_adjustments_product_idx',
    'CREATE INDEX stock_adjustments_product_idx ON stock_adjustments (product_id)',
  );
  late final Index stockAdjustmentsDateIdx = Index(
    'stock_adjustments_date_idx',
    'CREATE INDEX stock_adjustments_date_idx ON stock_adjustments (date)',
  );
  late final Index salesDateIdx = Index(
    'sales_date_idx',
    'CREATE INDEX sales_date_idx ON sales (date)',
  );
  late final Index saleLinesSaleIdx = Index(
    'sale_lines_sale_idx',
    'CREATE INDEX sale_lines_sale_idx ON sale_lines (sale_id)',
  );
  late final Index saleLinesProductIdx = Index(
    'sale_lines_product_idx',
    'CREATE INDEX sale_lines_product_idx ON sale_lines (product_id)',
  );
  late final Index saleExtraChargesSaleIdx = Index(
    'sale_extra_charges_sale_idx',
    'CREATE INDEX sale_extra_charges_sale_idx ON sale_extra_charges (sale_id)',
  );
  late final Index purchasesDateIdx = Index(
    'purchases_date_idx',
    'CREATE INDEX purchases_date_idx ON purchases (date)',
  );
  late final Index purchaseLinesPurchaseIdx = Index(
    'purchase_lines_purchase_idx',
    'CREATE INDEX purchase_lines_purchase_idx ON purchase_lines (purchase_id)',
  );
  late final Index purchaseLinesProductIdx = Index(
    'purchase_lines_product_idx',
    'CREATE INDEX purchase_lines_product_idx ON purchase_lines (product_id)',
  );
  late final Index productsNameIdx = Index(
    'products_name_idx',
    'CREATE INDEX products_name_idx ON products (name)',
  );
  late final Index productsSkuIdx = Index(
    'products_sku_idx',
    'CREATE INDEX products_sku_idx ON products (sku)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    syncOutbox,
    syncState,
    products,
    productsOutboxInsert,
    productsOutboxUpdate,
    purchases,
    purchasesOutboxInsert,
    purchasesOutboxUpdate,
    purchaseLines,
    purchaseLinesOutboxInsert,
    purchaseLinesOutboxUpdate,
    sales,
    salesOutboxInsert,
    salesOutboxUpdate,
    saleLines,
    saleLinesOutboxInsert,
    saleLinesOutboxUpdate,
    saleExtraCharges,
    saleExtraChargesOutboxInsert,
    saleExtraChargesOutboxUpdate,
    stockAdjustments,
    stockAdjustmentsOutboxInsert,
    stockAdjustmentsOutboxUpdate,
    stockAdjustmentsProductIdx,
    stockAdjustmentsDateIdx,
    salesDateIdx,
    saleLinesSaleIdx,
    saleLinesProductIdx,
    saleExtraChargesSaleIdx,
    purchasesDateIdx,
    purchaseLinesPurchaseIdx,
    purchaseLinesProductIdx,
    productsNameIdx,
    productsSkuIdx,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'products',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [TableUpdate('sync_outbox', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'products',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('sync_outbox', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'purchases',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [TableUpdate('sync_outbox', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'purchases',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('sync_outbox', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'purchase_lines',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [TableUpdate('sync_outbox', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'purchase_lines',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('sync_outbox', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sales',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [TableUpdate('sync_outbox', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sales',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('sync_outbox', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sale_lines',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [TableUpdate('sync_outbox', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sale_lines',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('sync_outbox', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sale_extra_charges',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [TableUpdate('sync_outbox', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sale_extra_charges',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('sync_outbox', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'stock_adjustments',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [TableUpdate('sync_outbox', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'stock_adjustments',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('sync_outbox', kind: UpdateKind.insert)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $SyncOutboxCreateCompanionBuilder = SyncOutboxCompanion Function({
  Value<int> seq,
  required String tableName$,
  required String rowId,
});
typedef $SyncOutboxUpdateCompanionBuilder = SyncOutboxCompanion Function({
  Value<int> seq,
  Value<String> tableName$,
  Value<String> rowId,
});

class $SyncOutboxFilterComposer extends Composer<_$AppDatabase, SyncOutbox> {
  $SyncOutboxFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tableName$ => $composableBuilder(
    column: $table.tableName$,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnFilters(column),
  );
}

class $SyncOutboxOrderingComposer extends Composer<_$AppDatabase, SyncOutbox> {
  $SyncOutboxOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tableName$ => $composableBuilder(
    column: $table.tableName$,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $SyncOutboxAnnotationComposer
    extends Composer<_$AppDatabase, SyncOutbox> {
  $SyncOutboxAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get tableName$ => $composableBuilder(
    column: $table.tableName$,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);
}

class $SyncOutboxTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          SyncOutbox,
          SyncOutboxData,
          $SyncOutboxFilterComposer,
          $SyncOutboxOrderingComposer,
          $SyncOutboxAnnotationComposer,
          $SyncOutboxCreateCompanionBuilder,
          $SyncOutboxUpdateCompanionBuilder,
          (
            SyncOutboxData,
            BaseReferences<_$AppDatabase, SyncOutbox, SyncOutboxData>,
          ),
          SyncOutboxData,
          PrefetchHooks Function()
        > {
  $SyncOutboxTableManager(_$AppDatabase db, SyncOutbox table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SyncOutboxFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SyncOutboxOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SyncOutboxAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                Value<String> tableName$ = const Value.absent(),
                Value<String> rowId = const Value.absent(),
              }) => SyncOutboxCompanion(
                seq: seq,
                tableName$: tableName$,
                rowId: rowId,
              ),
          createCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                required String tableName$,
                required String rowId,
              }) => SyncOutboxCompanion.insert(
                seq: seq,
                tableName$: tableName$,
                rowId: rowId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<SyncOutbox, SyncOutboxData>(table),
                  BaseReferences<_$AppDatabase, SyncOutbox, SyncOutboxData>(
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

typedef $SyncOutboxProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      SyncOutbox,
      SyncOutboxData,
      $SyncOutboxFilterComposer,
      $SyncOutboxOrderingComposer,
      $SyncOutboxAnnotationComposer,
      $SyncOutboxCreateCompanionBuilder,
      $SyncOutboxUpdateCompanionBuilder,
      (
        SyncOutboxData,
        BaseReferences<_$AppDatabase, SyncOutbox, SyncOutboxData>,
      ),
      SyncOutboxData,
      PrefetchHooks Function()
    >;
typedef $SyncStateCreateCompanionBuilder = SyncStateCompanion Function({
  required String key,
  Value<String?> value,
  Value<int> rowid,
});
typedef $SyncStateUpdateCompanionBuilder = SyncStateCompanion Function({
  Value<String> key,
  Value<String?> value,
  Value<int> rowid,
});

class $SyncStateFilterComposer extends Composer<_$AppDatabase, SyncState> {
  $SyncStateFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $SyncStateOrderingComposer extends Composer<_$AppDatabase, SyncState> {
  $SyncStateOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $SyncStateAnnotationComposer extends Composer<_$AppDatabase, SyncState> {
  $SyncStateAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $SyncStateTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          SyncState,
          SyncStateData,
          $SyncStateFilterComposer,
          $SyncStateOrderingComposer,
          $SyncStateAnnotationComposer,
          $SyncStateCreateCompanionBuilder,
          $SyncStateUpdateCompanionBuilder,
          (
            SyncStateData,
            BaseReferences<_$AppDatabase, SyncState, SyncStateData>,
          ),
          SyncStateData,
          PrefetchHooks Function()
        > {
  $SyncStateTableManager(_$AppDatabase db, SyncState table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SyncStateFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SyncStateOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SyncStateAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String?> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SyncStateCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            Value<String?> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SyncStateCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<SyncState, SyncStateData>(table),
                  BaseReferences<_$AppDatabase, SyncState, SyncStateData>(
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

typedef $SyncStateProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      SyncState,
      SyncStateData,
      $SyncStateFilterComposer,
      $SyncStateOrderingComposer,
      $SyncStateAnnotationComposer,
      $SyncStateCreateCompanionBuilder,
      $SyncStateUpdateCompanionBuilder,
      (SyncStateData, BaseReferences<_$AppDatabase, SyncState, SyncStateData>),
      SyncStateData,
      PrefetchHooks Function()
    >;
typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String name,
  Value<String?> sku,
  Value<int> unitsPerBox,
  Value<int> stockUnits,
  Value<int> avgCostRaw,
  Value<int> suggestedPriceUnitCents,
  Value<int?> suggestedPriceBoxCents,
  Value<bool> isActive,
  Value<int?> minStockUnits,
  Value<int> rowid,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> name,
  Value<String?> sku,
  Value<int> unitsPerBox,
  Value<int> stockUnits,
  Value<int> avgCostRaw,
  Value<int> suggestedPriceUnitCents,
  Value<int?> suggestedPriceBoxCents,
  Value<bool> isActive,
  Value<int?> minStockUnits,
  Value<int> rowid,
});

final class $$ProductsTableReferences
    extends BaseReferences<_$AppDatabase, $ProductsTable, ProductRow> {
  $$ProductsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PurchaseLinesTable, List<PurchaseLineRow>>
  _purchaseLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.purchaseLines,
    aliasName: 'products__id__purchase_lines__product_id',
  );

  $$PurchaseLinesTableProcessedTableManager get purchaseLinesRefs {
    final manager = $$PurchaseLinesTableTableManager(
      $_db,
      $_db.purchaseLines,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_purchaseLinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SaleLinesTable, List<SaleLineRow>>
  _saleLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saleLines,
    aliasName: 'products__id__sale_lines__product_id',
  );

  $$SaleLinesTableProcessedTableManager get saleLinesRefs {
    final manager = $$SaleLinesTableTableManager(
      $_db,
      $_db.saleLines,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_saleLinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StockAdjustmentsTable, List<StockAdjustmentRow>>
  _stockAdjustmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stockAdjustments,
    aliasName: 'products__id__stock_adjustments__product_id',
  );

  $$StockAdjustmentsTableProcessedTableManager get stockAdjustmentsRefs {
    final manager = $$StockAdjustmentsTableTableManager(
      $_db,
      $_db.stockAdjustments,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _stockAdjustmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitsPerBox => $composableBuilder(
    column: $table.unitsPerBox,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stockUnits => $composableBuilder(
    column: $table.stockUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avgCostRaw => $composableBuilder(
    column: $table.avgCostRaw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get suggestedPriceUnitCents => $composableBuilder(
    column: $table.suggestedPriceUnitCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get suggestedPriceBoxCents => $composableBuilder(
    column: $table.suggestedPriceBoxCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minStockUnits => $composableBuilder(
    column: $table.minStockUnits,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> purchaseLinesRefs(
    Expression<bool> Function($$PurchaseLinesTableFilterComposer f) f,
  ) {
    final $$PurchaseLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseLines,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseLinesTableFilterComposer(
            $db: $db,
            $table: $db.purchaseLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> saleLinesRefs(
    Expression<bool> Function($$SaleLinesTableFilterComposer f) f,
  ) {
    final $$SaleLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleLines,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleLinesTableFilterComposer(
            $db: $db,
            $table: $db.saleLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> stockAdjustmentsRefs(
    Expression<bool> Function($$StockAdjustmentsTableFilterComposer f) f,
  ) {
    final $$StockAdjustmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockAdjustments,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockAdjustmentsTableFilterComposer(
            $db: $db,
            $table: $db.stockAdjustments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitsPerBox => $composableBuilder(
    column: $table.unitsPerBox,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stockUnits => $composableBuilder(
    column: $table.stockUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avgCostRaw => $composableBuilder(
    column: $table.avgCostRaw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get suggestedPriceUnitCents => $composableBuilder(
    column: $table.suggestedPriceUnitCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get suggestedPriceBoxCents => $composableBuilder(
    column: $table.suggestedPriceBoxCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minStockUnits => $composableBuilder(
    column: $table.minStockUnits,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<int> get unitsPerBox => $composableBuilder(
    column: $table.unitsPerBox,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stockUnits => $composableBuilder(
    column: $table.stockUnits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get avgCostRaw => $composableBuilder(
    column: $table.avgCostRaw,
    builder: (column) => column,
  );

  GeneratedColumn<int> get suggestedPriceUnitCents => $composableBuilder(
    column: $table.suggestedPriceUnitCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get suggestedPriceBoxCents => $composableBuilder(
    column: $table.suggestedPriceBoxCents,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get minStockUnits => $composableBuilder(
    column: $table.minStockUnits,
    builder: (column) => column,
  );

  Expression<T> purchaseLinesRefs<T extends Object>(
    Expression<T> Function($$PurchaseLinesTableAnnotationComposer a) f,
  ) {
    final $$PurchaseLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseLines,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.purchaseLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> saleLinesRefs<T extends Object>(
    Expression<T> Function($$SaleLinesTableAnnotationComposer a) f,
  ) {
    final $$SaleLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleLines,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.saleLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> stockAdjustmentsRefs<T extends Object>(
    Expression<T> Function($$StockAdjustmentsTableAnnotationComposer a) f,
  ) {
    final $$StockAdjustmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockAdjustments,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockAdjustmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.stockAdjustments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          ProductRow,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (ProductRow, $$ProductsTableReferences),
          ProductRow,
          PrefetchHooks Function({
            bool purchaseLinesRefs,
            bool saleLinesRefs,
            bool stockAdjustmentsRefs,
          })
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> sku = const Value.absent(),
                Value<int> unitsPerBox = const Value.absent(),
                Value<int> stockUnits = const Value.absent(),
                Value<int> avgCostRaw = const Value.absent(),
                Value<int> suggestedPriceUnitCents = const Value.absent(),
                Value<int?> suggestedPriceBoxCents = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int?> minStockUnits = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                sku: sku,
                unitsPerBox: unitsPerBox,
                stockUnits: stockUnits,
                avgCostRaw: avgCostRaw,
                suggestedPriceUnitCents: suggestedPriceUnitCents,
                suggestedPriceBoxCents: suggestedPriceBoxCents,
                isActive: isActive,
                minStockUnits: minStockUnits,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String name,
                Value<String?> sku = const Value.absent(),
                Value<int> unitsPerBox = const Value.absent(),
                Value<int> stockUnits = const Value.absent(),
                Value<int> avgCostRaw = const Value.absent(),
                Value<int> suggestedPriceUnitCents = const Value.absent(),
                Value<int?> suggestedPriceBoxCents = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int?> minStockUnits = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                sku: sku,
                unitsPerBox: unitsPerBox,
                stockUnits: stockUnits,
                avgCostRaw: avgCostRaw,
                suggestedPriceUnitCents: suggestedPriceUnitCents,
                suggestedPriceBoxCents: suggestedPriceBoxCents,
                isActive: isActive,
                minStockUnits: minStockUnits,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProductsTable, ProductRow>(table),
                  $$ProductsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                purchaseLinesRefs = false,
                saleLinesRefs = false,
                stockAdjustmentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (purchaseLinesRefs) db.purchaseLines,
                    if (saleLinesRefs) db.saleLines,
                    if (stockAdjustmentsRefs) db.stockAdjustments,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (purchaseLinesRefs)
                        await $_getPrefetchedDataByColumns<
                          ProductRow,
                          $ProductsTable,
                          PurchaseLineRow,
                          $PurchaseLinesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._purchaseLinesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).purchaseLinesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'product_id',
                          typedResults: items,
                        ),
                      if (saleLinesRefs)
                        await $_getPrefetchedDataByColumns<
                          ProductRow,
                          $ProductsTable,
                          SaleLineRow,
                          $SaleLinesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._saleLinesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).saleLinesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'product_id',
                          typedResults: items,
                        ),
                      if (stockAdjustmentsRefs)
                        await $_getPrefetchedDataByColumns<
                          ProductRow,
                          $ProductsTable,
                          StockAdjustmentRow,
                          $StockAdjustmentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._stockAdjustmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).stockAdjustmentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'product_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      ProductRow,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (ProductRow, $$ProductsTableReferences),
      ProductRow,
      PrefetchHooks Function({
        bool purchaseLinesRefs,
        bool saleLinesRefs,
        bool stockAdjustmentsRefs,
      })
    >;
typedef $$PurchasesTableCreateCompanionBuilder = PurchasesCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required DateTime date,
  Value<String?> supplier,
  Value<String?> notes,
  Value<String?> registeredBy,
  Value<String?> voidedBy,
  Value<String?> voidReason,
  required int totalCents,
  Value<int> rowid,
});
typedef $$PurchasesTableUpdateCompanionBuilder = PurchasesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<DateTime> date,
  Value<String?> supplier,
  Value<String?> notes,
  Value<String?> registeredBy,
  Value<String?> voidedBy,
  Value<String?> voidReason,
  Value<int> totalCents,
  Value<int> rowid,
});

final class $$PurchasesTableReferences
    extends BaseReferences<_$AppDatabase, $PurchasesTable, PurchaseRow> {
  $$PurchasesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PurchaseLinesTable, List<PurchaseLineRow>>
  _purchaseLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.purchaseLines,
    aliasName: 'purchases__id__purchase_lines__purchase_id',
  );

  $$PurchaseLinesTableProcessedTableManager get purchaseLinesRefs {
    final manager = $$PurchaseLinesTableTableManager(
      $_db,
      $_db.purchaseLines,
    ).filter((f) => f.purchaseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_purchaseLinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PurchasesTableFilterComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplier => $composableBuilder(
    column: $table.supplier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registeredBy => $composableBuilder(
    column: $table.registeredBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voidedBy => $composableBuilder(
    column: $table.voidedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> purchaseLinesRefs(
    Expression<bool> Function($$PurchaseLinesTableFilterComposer f) f,
  ) {
    final $$PurchaseLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseLines,
      getReferencedColumn: (t) => t.purchaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseLinesTableFilterComposer(
            $db: $db,
            $table: $db.purchaseLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PurchasesTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplier => $composableBuilder(
    column: $table.supplier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registeredBy => $composableBuilder(
    column: $table.registeredBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voidedBy => $composableBuilder(
    column: $table.voidedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PurchasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get supplier =>
      $composableBuilder(column: $table.supplier, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get registeredBy => $composableBuilder(
    column: $table.registeredBy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get voidedBy =>
      $composableBuilder(column: $table.voidedBy, builder: (column) => column);

  GeneratedColumn<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => column,
  );

  Expression<T> purchaseLinesRefs<T extends Object>(
    Expression<T> Function($$PurchaseLinesTableAnnotationComposer a) f,
  ) {
    final $$PurchaseLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseLines,
      getReferencedColumn: (t) => t.purchaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.purchaseLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PurchasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchasesTable,
          PurchaseRow,
          $$PurchasesTableFilterComposer,
          $$PurchasesTableOrderingComposer,
          $$PurchasesTableAnnotationComposer,
          $$PurchasesTableCreateCompanionBuilder,
          $$PurchasesTableUpdateCompanionBuilder,
          (PurchaseRow, $$PurchasesTableReferences),
          PurchaseRow,
          PrefetchHooks Function({bool purchaseLinesRefs})
        > {
  $$PurchasesTableTableManager(_$AppDatabase db, $PurchasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> supplier = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> registeredBy = const Value.absent(),
                Value<String?> voidedBy = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<int> totalCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchasesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                date: date,
                supplier: supplier,
                notes: notes,
                registeredBy: registeredBy,
                voidedBy: voidedBy,
                voidReason: voidReason,
                totalCents: totalCents,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required DateTime date,
                Value<String?> supplier = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> registeredBy = const Value.absent(),
                Value<String?> voidedBy = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                required int totalCents,
                Value<int> rowid = const Value.absent(),
              }) => PurchasesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                date: date,
                supplier: supplier,
                notes: notes,
                registeredBy: registeredBy,
                voidedBy: voidedBy,
                voidReason: voidReason,
                totalCents: totalCents,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PurchasesTable, PurchaseRow>(table),
                  $$PurchasesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({purchaseLinesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (purchaseLinesRefs) db.purchaseLines,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (purchaseLinesRefs)
                    await $_getPrefetchedDataByColumns<
                      PurchaseRow,
                      $PurchasesTable,
                      PurchaseLineRow,
                      $PurchaseLinesTable
                    >(
                      currentTable: table,
                      referencedTable: $$PurchasesTableReferences
                          ._purchaseLinesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PurchasesTableReferences(
                            db,
                            table,
                            p0,
                          ).purchaseLinesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'purchase_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PurchasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchasesTable,
      PurchaseRow,
      $$PurchasesTableFilterComposer,
      $$PurchasesTableOrderingComposer,
      $$PurchasesTableAnnotationComposer,
      $$PurchasesTableCreateCompanionBuilder,
      $$PurchasesTableUpdateCompanionBuilder,
      (PurchaseRow, $$PurchasesTableReferences),
      PurchaseRow,
      PrefetchHooks Function({bool purchaseLinesRefs})
    >;
typedef $$PurchaseLinesTableCreateCompanionBuilder =
    PurchaseLinesCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String purchaseId,
      required String productId,
      required int quantity,
      required Presentation presentation,
      required int unitsBase,
      required int lineTotalCents,
      required int unitCostRaw,
      Value<int?> unitsPerBox,
      Value<DateTime?> expiryFrom,
      Value<DateTime?> expiryTo,
      Value<String?> lotCode,
      Value<int> rowid,
    });
typedef $$PurchaseLinesTableUpdateCompanionBuilder =
    PurchaseLinesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> purchaseId,
      Value<String> productId,
      Value<int> quantity,
      Value<Presentation> presentation,
      Value<int> unitsBase,
      Value<int> lineTotalCents,
      Value<int> unitCostRaw,
      Value<int?> unitsPerBox,
      Value<DateTime?> expiryFrom,
      Value<DateTime?> expiryTo,
      Value<String?> lotCode,
      Value<int> rowid,
    });

final class $$PurchaseLinesTableReferences
    extends
        BaseReferences<_$AppDatabase, $PurchaseLinesTable, PurchaseLineRow> {
  $$PurchaseLinesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PurchasesTable _purchaseIdTable(_$AppDatabase db) =>
      db.purchases.createAlias('purchase_lines__purchase_id__purchases__id');

  $$PurchasesTableProcessedTableManager get purchaseId {
    final $_column = $_itemColumn<String>('purchase_id')!;

    final manager = $$PurchasesTableTableManager(
      $_db,
      $_db.purchases,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_purchaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias('purchase_lines__product_id__products__id');

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PurchaseLinesTableFilterComposer
    extends Composer<_$AppDatabase, $PurchaseLinesTable> {
  $$PurchaseLinesTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Presentation, Presentation, String>
  get presentation => $composableBuilder(
    column: $table.presentation,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get unitsBase => $composableBuilder(
    column: $table.unitsBase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineTotalCents => $composableBuilder(
    column: $table.lineTotalCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitCostRaw => $composableBuilder(
    column: $table.unitCostRaw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitsPerBox => $composableBuilder(
    column: $table.unitsPerBox,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiryFrom => $composableBuilder(
    column: $table.expiryFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiryTo => $composableBuilder(
    column: $table.expiryTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lotCode => $composableBuilder(
    column: $table.lotCode,
    builder: (column) => ColumnFilters(column),
  );

  $$PurchasesTableFilterComposer get purchaseId {
    final $$PurchasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableFilterComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchaseLinesTable> {
  $$PurchaseLinesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get presentation => $composableBuilder(
    column: $table.presentation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitsBase => $composableBuilder(
    column: $table.unitsBase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineTotalCents => $composableBuilder(
    column: $table.lineTotalCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitCostRaw => $composableBuilder(
    column: $table.unitCostRaw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitsPerBox => $composableBuilder(
    column: $table.unitsPerBox,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiryFrom => $composableBuilder(
    column: $table.expiryFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiryTo => $composableBuilder(
    column: $table.expiryTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lotCode => $composableBuilder(
    column: $table.lotCode,
    builder: (column) => ColumnOrderings(column),
  );

  $$PurchasesTableOrderingComposer get purchaseId {
    final $$PurchasesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableOrderingComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchaseLinesTable> {
  $$PurchaseLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Presentation, String> get presentation =>
      $composableBuilder(
        column: $table.presentation,
        builder: (column) => column,
      );

  GeneratedColumn<int> get unitsBase =>
      $composableBuilder(column: $table.unitsBase, builder: (column) => column);

  GeneratedColumn<int> get lineTotalCents => $composableBuilder(
    column: $table.lineTotalCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unitCostRaw => $composableBuilder(
    column: $table.unitCostRaw,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unitsPerBox => $composableBuilder(
    column: $table.unitsPerBox,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiryFrom => $composableBuilder(
    column: $table.expiryFrom,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiryTo =>
      $composableBuilder(column: $table.expiryTo, builder: (column) => column);

  GeneratedColumn<String> get lotCode =>
      $composableBuilder(column: $table.lotCode, builder: (column) => column);

  $$PurchasesTableAnnotationComposer get purchaseId {
    final $$PurchasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableAnnotationComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchaseLinesTable,
          PurchaseLineRow,
          $$PurchaseLinesTableFilterComposer,
          $$PurchaseLinesTableOrderingComposer,
          $$PurchaseLinesTableAnnotationComposer,
          $$PurchaseLinesTableCreateCompanionBuilder,
          $$PurchaseLinesTableUpdateCompanionBuilder,
          (PurchaseLineRow, $$PurchaseLinesTableReferences),
          PurchaseLineRow,
          PrefetchHooks Function({bool purchaseId, bool productId})
        > {
  $$PurchaseLinesTableTableManager(_$AppDatabase db, $PurchaseLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchaseLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchaseLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchaseLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> purchaseId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<Presentation> presentation = const Value.absent(),
                Value<int> unitsBase = const Value.absent(),
                Value<int> lineTotalCents = const Value.absent(),
                Value<int> unitCostRaw = const Value.absent(),
                Value<int?> unitsPerBox = const Value.absent(),
                Value<DateTime?> expiryFrom = const Value.absent(),
                Value<DateTime?> expiryTo = const Value.absent(),
                Value<String?> lotCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseLinesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                purchaseId: purchaseId,
                productId: productId,
                quantity: quantity,
                presentation: presentation,
                unitsBase: unitsBase,
                lineTotalCents: lineTotalCents,
                unitCostRaw: unitCostRaw,
                unitsPerBox: unitsPerBox,
                expiryFrom: expiryFrom,
                expiryTo: expiryTo,
                lotCode: lotCode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String purchaseId,
                required String productId,
                required int quantity,
                required Presentation presentation,
                required int unitsBase,
                required int lineTotalCents,
                required int unitCostRaw,
                Value<int?> unitsPerBox = const Value.absent(),
                Value<DateTime?> expiryFrom = const Value.absent(),
                Value<DateTime?> expiryTo = const Value.absent(),
                Value<String?> lotCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseLinesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                purchaseId: purchaseId,
                productId: productId,
                quantity: quantity,
                presentation: presentation,
                unitsBase: unitsBase,
                lineTotalCents: lineTotalCents,
                unitCostRaw: unitCostRaw,
                unitsPerBox: unitsPerBox,
                expiryFrom: expiryFrom,
                expiryTo: expiryTo,
                lotCode: lotCode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PurchaseLinesTable, PurchaseLineRow>(table),
                  $$PurchaseLinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({purchaseId = false, productId = false}) {
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
                    if (purchaseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.purchaseId,
                        referencedTable: $$PurchaseLinesTableReferences
                            ._purchaseIdTable(db),
                        referencedColumn: $$PurchaseLinesTableReferences
                            ._purchaseIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (productId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.productId,
                        referencedTable: $$PurchaseLinesTableReferences
                            ._productIdTable(db),
                        referencedColumn: $$PurchaseLinesTableReferences
                            ._productIdTable(db)
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

typedef $$PurchaseLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchaseLinesTable,
      PurchaseLineRow,
      $$PurchaseLinesTableFilterComposer,
      $$PurchaseLinesTableOrderingComposer,
      $$PurchaseLinesTableAnnotationComposer,
      $$PurchaseLinesTableCreateCompanionBuilder,
      $$PurchaseLinesTableUpdateCompanionBuilder,
      (PurchaseLineRow, $$PurchaseLinesTableReferences),
      PurchaseLineRow,
      PrefetchHooks Function({bool purchaseId, bool productId})
    >;
typedef $$SalesTableCreateCompanionBuilder = SalesCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required DateTime date,
  Value<String?> notes,
  Value<String?> registeredBy,
  Value<String?> voidedBy,
  Value<String?> voidReason,
  required int totalCents,
  required int profitCents,
  Value<int> rowid,
});
typedef $$SalesTableUpdateCompanionBuilder = SalesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<DateTime> date,
  Value<String?> notes,
  Value<String?> registeredBy,
  Value<String?> voidedBy,
  Value<String?> voidReason,
  Value<int> totalCents,
  Value<int> profitCents,
  Value<int> rowid,
});

final class $$SalesTableReferences
    extends BaseReferences<_$AppDatabase, $SalesTable, SaleRow> {
  $$SalesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SaleLinesTable, List<SaleLineRow>>
  _saleLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saleLines,
    aliasName: 'sales__id__sale_lines__sale_id',
  );

  $$SaleLinesTableProcessedTableManager get saleLinesRefs {
    final manager = $$SaleLinesTableTableManager(
      $_db,
      $_db.saleLines,
    ).filter((f) => f.saleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_saleLinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SaleExtraChargesTable, List<SaleExtraChargeRow>>
  _saleExtraChargesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saleExtraCharges,
    aliasName: 'sales__id__sale_extra_charges__sale_id',
  );

  $$SaleExtraChargesTableProcessedTableManager get saleExtraChargesRefs {
    final manager = $$SaleExtraChargesTableTableManager(
      $_db,
      $_db.saleExtraCharges,
    ).filter((f) => f.saleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _saleExtraChargesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SalesTableFilterComposer extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registeredBy => $composableBuilder(
    column: $table.registeredBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voidedBy => $composableBuilder(
    column: $table.voidedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get profitCents => $composableBuilder(
    column: $table.profitCents,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> saleLinesRefs(
    Expression<bool> Function($$SaleLinesTableFilterComposer f) f,
  ) {
    final $$SaleLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleLines,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleLinesTableFilterComposer(
            $db: $db,
            $table: $db.saleLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> saleExtraChargesRefs(
    Expression<bool> Function($$SaleExtraChargesTableFilterComposer f) f,
  ) {
    final $$SaleExtraChargesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleExtraCharges,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleExtraChargesTableFilterComposer(
            $db: $db,
            $table: $db.saleExtraCharges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registeredBy => $composableBuilder(
    column: $table.registeredBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voidedBy => $composableBuilder(
    column: $table.voidedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get profitCents => $composableBuilder(
    column: $table.profitCents,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get registeredBy => $composableBuilder(
    column: $table.registeredBy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get voidedBy =>
      $composableBuilder(column: $table.voidedBy, builder: (column) => column);

  GeneratedColumn<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get profitCents => $composableBuilder(
    column: $table.profitCents,
    builder: (column) => column,
  );

  Expression<T> saleLinesRefs<T extends Object>(
    Expression<T> Function($$SaleLinesTableAnnotationComposer a) f,
  ) {
    final $$SaleLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleLines,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.saleLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> saleExtraChargesRefs<T extends Object>(
    Expression<T> Function($$SaleExtraChargesTableAnnotationComposer a) f,
  ) {
    final $$SaleExtraChargesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleExtraCharges,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleExtraChargesTableAnnotationComposer(
            $db: $db,
            $table: $db.saleExtraCharges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalesTable,
          SaleRow,
          $$SalesTableFilterComposer,
          $$SalesTableOrderingComposer,
          $$SalesTableAnnotationComposer,
          $$SalesTableCreateCompanionBuilder,
          $$SalesTableUpdateCompanionBuilder,
          (SaleRow, $$SalesTableReferences),
          SaleRow,
          PrefetchHooks Function({
            bool saleLinesRefs,
            bool saleExtraChargesRefs,
          })
        > {
  $$SalesTableTableManager(_$AppDatabase db, $SalesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> registeredBy = const Value.absent(),
                Value<String?> voidedBy = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<int> totalCents = const Value.absent(),
                Value<int> profitCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                date: date,
                notes: notes,
                registeredBy: registeredBy,
                voidedBy: voidedBy,
                voidReason: voidReason,
                totalCents: totalCents,
                profitCents: profitCents,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required DateTime date,
                Value<String?> notes = const Value.absent(),
                Value<String?> registeredBy = const Value.absent(),
                Value<String?> voidedBy = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                required int totalCents,
                required int profitCents,
                Value<int> rowid = const Value.absent(),
              }) => SalesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                date: date,
                notes: notes,
                registeredBy: registeredBy,
                voidedBy: voidedBy,
                voidReason: voidReason,
                totalCents: totalCents,
                profitCents: profitCents,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SalesTable, SaleRow>(table),
                  $$SalesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({saleLinesRefs = false, saleExtraChargesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (saleLinesRefs) db.saleLines,
                    if (saleExtraChargesRefs) db.saleExtraCharges,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (saleLinesRefs)
                        await $_getPrefetchedDataByColumns<
                          SaleRow,
                          $SalesTable,
                          SaleLineRow,
                          $SaleLinesTable
                        >(
                          currentTable: table,
                          referencedTable: $$SalesTableReferences
                              ._saleLinesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SalesTableReferences(
                                db,
                                table,
                                p0,
                              ).saleLinesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'sale_id',
                          typedResults: items,
                        ),
                      if (saleExtraChargesRefs)
                        await $_getPrefetchedDataByColumns<
                          SaleRow,
                          $SalesTable,
                          SaleExtraChargeRow,
                          $SaleExtraChargesTable
                        >(
                          currentTable: table,
                          referencedTable: $$SalesTableReferences
                              ._saleExtraChargesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SalesTableReferences(
                                db,
                                table,
                                p0,
                              ).saleExtraChargesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'sale_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalesTable,
      SaleRow,
      $$SalesTableFilterComposer,
      $$SalesTableOrderingComposer,
      $$SalesTableAnnotationComposer,
      $$SalesTableCreateCompanionBuilder,
      $$SalesTableUpdateCompanionBuilder,
      (SaleRow, $$SalesTableReferences),
      SaleRow,
      PrefetchHooks Function({bool saleLinesRefs, bool saleExtraChargesRefs})
    >;
typedef $$SaleLinesTableCreateCompanionBuilder = SaleLinesCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String saleId,
  required String productId,
  required int quantity,
  required Presentation presentation,
  required int unitsBase,
  required int unitPriceCents,
  required int suggestedUnitPriceCents,
  required int lineTotalCents,
  required int costAtSaleRaw,
  required int costTotalCents,
  required int profitCents,
  Value<int> rowid,
});
typedef $$SaleLinesTableUpdateCompanionBuilder = SaleLinesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> saleId,
  Value<String> productId,
  Value<int> quantity,
  Value<Presentation> presentation,
  Value<int> unitsBase,
  Value<int> unitPriceCents,
  Value<int> suggestedUnitPriceCents,
  Value<int> lineTotalCents,
  Value<int> costAtSaleRaw,
  Value<int> costTotalCents,
  Value<int> profitCents,
  Value<int> rowid,
});

final class $$SaleLinesTableReferences
    extends BaseReferences<_$AppDatabase, $SaleLinesTable, SaleLineRow> {
  $$SaleLinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SalesTable _saleIdTable(_$AppDatabase db) =>
      db.sales.createAlias('sale_lines__sale_id__sales__id');

  $$SalesTableProcessedTableManager get saleId {
    final $_column = $_itemColumn<String>('sale_id')!;

    final manager = $$SalesTableTableManager(
      $_db,
      $_db.sales,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_saleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias('sale_lines__product_id__products__id');

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SaleLinesTableFilterComposer
    extends Composer<_$AppDatabase, $SaleLinesTable> {
  $$SaleLinesTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Presentation, Presentation, String>
  get presentation => $composableBuilder(
    column: $table.presentation,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get unitsBase => $composableBuilder(
    column: $table.unitsBase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get suggestedUnitPriceCents => $composableBuilder(
    column: $table.suggestedUnitPriceCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineTotalCents => $composableBuilder(
    column: $table.lineTotalCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get costAtSaleRaw => $composableBuilder(
    column: $table.costAtSaleRaw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get costTotalCents => $composableBuilder(
    column: $table.costTotalCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get profitCents => $composableBuilder(
    column: $table.profitCents,
    builder: (column) => ColumnFilters(column),
  );

  $$SalesTableFilterComposer get saleId {
    final $$SalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableFilterComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleLinesTable> {
  $$SaleLinesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get presentation => $composableBuilder(
    column: $table.presentation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitsBase => $composableBuilder(
    column: $table.unitsBase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get suggestedUnitPriceCents => $composableBuilder(
    column: $table.suggestedUnitPriceCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineTotalCents => $composableBuilder(
    column: $table.lineTotalCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get costAtSaleRaw => $composableBuilder(
    column: $table.costAtSaleRaw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get costTotalCents => $composableBuilder(
    column: $table.costTotalCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get profitCents => $composableBuilder(
    column: $table.profitCents,
    builder: (column) => ColumnOrderings(column),
  );

  $$SalesTableOrderingComposer get saleId {
    final $$SalesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableOrderingComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleLinesTable> {
  $$SaleLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Presentation, String> get presentation =>
      $composableBuilder(
        column: $table.presentation,
        builder: (column) => column,
      );

  GeneratedColumn<int> get unitsBase =>
      $composableBuilder(column: $table.unitsBase, builder: (column) => column);

  GeneratedColumn<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get suggestedUnitPriceCents => $composableBuilder(
    column: $table.suggestedUnitPriceCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lineTotalCents => $composableBuilder(
    column: $table.lineTotalCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get costAtSaleRaw => $composableBuilder(
    column: $table.costAtSaleRaw,
    builder: (column) => column,
  );

  GeneratedColumn<int> get costTotalCents => $composableBuilder(
    column: $table.costTotalCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get profitCents => $composableBuilder(
    column: $table.profitCents,
    builder: (column) => column,
  );

  $$SalesTableAnnotationComposer get saleId {
    final $$SalesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableAnnotationComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaleLinesTable,
          SaleLineRow,
          $$SaleLinesTableFilterComposer,
          $$SaleLinesTableOrderingComposer,
          $$SaleLinesTableAnnotationComposer,
          $$SaleLinesTableCreateCompanionBuilder,
          $$SaleLinesTableUpdateCompanionBuilder,
          (SaleLineRow, $$SaleLinesTableReferences),
          SaleLineRow,
          PrefetchHooks Function({bool saleId, bool productId})
        > {
  $$SaleLinesTableTableManager(_$AppDatabase db, $SaleLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> saleId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<Presentation> presentation = const Value.absent(),
                Value<int> unitsBase = const Value.absent(),
                Value<int> unitPriceCents = const Value.absent(),
                Value<int> suggestedUnitPriceCents = const Value.absent(),
                Value<int> lineTotalCents = const Value.absent(),
                Value<int> costAtSaleRaw = const Value.absent(),
                Value<int> costTotalCents = const Value.absent(),
                Value<int> profitCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaleLinesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                saleId: saleId,
                productId: productId,
                quantity: quantity,
                presentation: presentation,
                unitsBase: unitsBase,
                unitPriceCents: unitPriceCents,
                suggestedUnitPriceCents: suggestedUnitPriceCents,
                lineTotalCents: lineTotalCents,
                costAtSaleRaw: costAtSaleRaw,
                costTotalCents: costTotalCents,
                profitCents: profitCents,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String saleId,
                required String productId,
                required int quantity,
                required Presentation presentation,
                required int unitsBase,
                required int unitPriceCents,
                required int suggestedUnitPriceCents,
                required int lineTotalCents,
                required int costAtSaleRaw,
                required int costTotalCents,
                required int profitCents,
                Value<int> rowid = const Value.absent(),
              }) => SaleLinesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                saleId: saleId,
                productId: productId,
                quantity: quantity,
                presentation: presentation,
                unitsBase: unitsBase,
                unitPriceCents: unitPriceCents,
                suggestedUnitPriceCents: suggestedUnitPriceCents,
                lineTotalCents: lineTotalCents,
                costAtSaleRaw: costAtSaleRaw,
                costTotalCents: costTotalCents,
                profitCents: profitCents,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SaleLinesTable, SaleLineRow>(table),
                  $$SaleLinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({saleId = false, productId = false}) {
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
                    if (saleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.saleId,
                        referencedTable: $$SaleLinesTableReferences
                            ._saleIdTable(db),
                        referencedColumn: $$SaleLinesTableReferences
                            ._saleIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (productId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.productId,
                        referencedTable: $$SaleLinesTableReferences
                            ._productIdTable(db),
                        referencedColumn: $$SaleLinesTableReferences
                            ._productIdTable(db)
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

typedef $$SaleLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaleLinesTable,
      SaleLineRow,
      $$SaleLinesTableFilterComposer,
      $$SaleLinesTableOrderingComposer,
      $$SaleLinesTableAnnotationComposer,
      $$SaleLinesTableCreateCompanionBuilder,
      $$SaleLinesTableUpdateCompanionBuilder,
      (SaleLineRow, $$SaleLinesTableReferences),
      SaleLineRow,
      PrefetchHooks Function({bool saleId, bool productId})
    >;
typedef $$SaleExtraChargesTableCreateCompanionBuilder =
    SaleExtraChargesCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String saleId,
      required String concept,
      required int amountCents,
      Value<bool> paidByCustomer,
      Value<int> rowid,
    });
typedef $$SaleExtraChargesTableUpdateCompanionBuilder =
    SaleExtraChargesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> saleId,
      Value<String> concept,
      Value<int> amountCents,
      Value<bool> paidByCustomer,
      Value<int> rowid,
    });

final class $$SaleExtraChargesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SaleExtraChargesTable,
          SaleExtraChargeRow
        > {
  $$SaleExtraChargesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SalesTable _saleIdTable(_$AppDatabase db) =>
      db.sales.createAlias('sale_extra_charges__sale_id__sales__id');

  $$SalesTableProcessedTableManager get saleId {
    final $_column = $_itemColumn<String>('sale_id')!;

    final manager = $$SalesTableTableManager(
      $_db,
      $_db.sales,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_saleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SaleExtraChargesTableFilterComposer
    extends Composer<_$AppDatabase, $SaleExtraChargesTable> {
  $$SaleExtraChargesTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get concept => $composableBuilder(
    column: $table.concept,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get paidByCustomer => $composableBuilder(
    column: $table.paidByCustomer,
    builder: (column) => ColumnFilters(column),
  );

  $$SalesTableFilterComposer get saleId {
    final $$SalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableFilterComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleExtraChargesTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleExtraChargesTable> {
  $$SaleExtraChargesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get concept => $composableBuilder(
    column: $table.concept,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get paidByCustomer => $composableBuilder(
    column: $table.paidByCustomer,
    builder: (column) => ColumnOrderings(column),
  );

  $$SalesTableOrderingComposer get saleId {
    final $$SalesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableOrderingComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleExtraChargesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleExtraChargesTable> {
  $$SaleExtraChargesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get concept =>
      $composableBuilder(column: $table.concept, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get paidByCustomer => $composableBuilder(
    column: $table.paidByCustomer,
    builder: (column) => column,
  );

  $$SalesTableAnnotationComposer get saleId {
    final $$SalesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableAnnotationComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleExtraChargesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaleExtraChargesTable,
          SaleExtraChargeRow,
          $$SaleExtraChargesTableFilterComposer,
          $$SaleExtraChargesTableOrderingComposer,
          $$SaleExtraChargesTableAnnotationComposer,
          $$SaleExtraChargesTableCreateCompanionBuilder,
          $$SaleExtraChargesTableUpdateCompanionBuilder,
          (SaleExtraChargeRow, $$SaleExtraChargesTableReferences),
          SaleExtraChargeRow,
          PrefetchHooks Function({bool saleId})
        > {
  $$SaleExtraChargesTableTableManager(
    _$AppDatabase db,
    $SaleExtraChargesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleExtraChargesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleExtraChargesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleExtraChargesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> saleId = const Value.absent(),
                Value<String> concept = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<bool> paidByCustomer = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaleExtraChargesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                saleId: saleId,
                concept: concept,
                amountCents: amountCents,
                paidByCustomer: paidByCustomer,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String saleId,
                required String concept,
                required int amountCents,
                Value<bool> paidByCustomer = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaleExtraChargesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                saleId: saleId,
                concept: concept,
                amountCents: amountCents,
                paidByCustomer: paidByCustomer,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SaleExtraChargesTable, SaleExtraChargeRow>(
                    table,
                  ),
                  $$SaleExtraChargesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({saleId = false}) {
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
                    if (saleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.saleId,
                        referencedTable: $$SaleExtraChargesTableReferences
                            ._saleIdTable(db),
                        referencedColumn: $$SaleExtraChargesTableReferences
                            ._saleIdTable(db)
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

typedef $$SaleExtraChargesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaleExtraChargesTable,
      SaleExtraChargeRow,
      $$SaleExtraChargesTableFilterComposer,
      $$SaleExtraChargesTableOrderingComposer,
      $$SaleExtraChargesTableAnnotationComposer,
      $$SaleExtraChargesTableCreateCompanionBuilder,
      $$SaleExtraChargesTableUpdateCompanionBuilder,
      (SaleExtraChargeRow, $$SaleExtraChargesTableReferences),
      SaleExtraChargeRow,
      PrefetchHooks Function({bool saleId})
    >;
typedef $$StockAdjustmentsTableCreateCompanionBuilder =
    StockAdjustmentsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String productId,
      required DateTime date,
      required int quantity,
      required Presentation presentation,
      required int unitsBase,
      required AdjustmentReason reason,
      Value<String?> notes,
      Value<String?> registeredBy,
      Value<String?> voidedBy,
      Value<String?> voidReason,
      required int unitCostRaw,
      required int costTotalCents,
      Value<int> rowid,
    });
typedef $$StockAdjustmentsTableUpdateCompanionBuilder =
    StockAdjustmentsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> productId,
      Value<DateTime> date,
      Value<int> quantity,
      Value<Presentation> presentation,
      Value<int> unitsBase,
      Value<AdjustmentReason> reason,
      Value<String?> notes,
      Value<String?> registeredBy,
      Value<String?> voidedBy,
      Value<String?> voidReason,
      Value<int> unitCostRaw,
      Value<int> costTotalCents,
      Value<int> rowid,
    });

final class $$StockAdjustmentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StockAdjustmentsTable,
          StockAdjustmentRow
        > {
  $$StockAdjustmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias('stock_adjustments__product_id__products__id');

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StockAdjustmentsTableFilterComposer
    extends Composer<_$AppDatabase, $StockAdjustmentsTable> {
  $$StockAdjustmentsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Presentation, Presentation, String>
  get presentation => $composableBuilder(
    column: $table.presentation,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get unitsBase => $composableBuilder(
    column: $table.unitsBase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AdjustmentReason, AdjustmentReason, String>
  get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registeredBy => $composableBuilder(
    column: $table.registeredBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voidedBy => $composableBuilder(
    column: $table.voidedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitCostRaw => $composableBuilder(
    column: $table.unitCostRaw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get costTotalCents => $composableBuilder(
    column: $table.costTotalCents,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockAdjustmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockAdjustmentsTable> {
  $$StockAdjustmentsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get presentation => $composableBuilder(
    column: $table.presentation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitsBase => $composableBuilder(
    column: $table.unitsBase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registeredBy => $composableBuilder(
    column: $table.registeredBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voidedBy => $composableBuilder(
    column: $table.voidedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitCostRaw => $composableBuilder(
    column: $table.unitCostRaw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get costTotalCents => $composableBuilder(
    column: $table.costTotalCents,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockAdjustmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockAdjustmentsTable> {
  $$StockAdjustmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Presentation, String> get presentation =>
      $composableBuilder(
        column: $table.presentation,
        builder: (column) => column,
      );

  GeneratedColumn<int> get unitsBase =>
      $composableBuilder(column: $table.unitsBase, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AdjustmentReason, String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get registeredBy => $composableBuilder(
    column: $table.registeredBy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get voidedBy =>
      $composableBuilder(column: $table.voidedBy, builder: (column) => column);

  GeneratedColumn<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unitCostRaw => $composableBuilder(
    column: $table.unitCostRaw,
    builder: (column) => column,
  );

  GeneratedColumn<int> get costTotalCents => $composableBuilder(
    column: $table.costTotalCents,
    builder: (column) => column,
  );

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockAdjustmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockAdjustmentsTable,
          StockAdjustmentRow,
          $$StockAdjustmentsTableFilterComposer,
          $$StockAdjustmentsTableOrderingComposer,
          $$StockAdjustmentsTableAnnotationComposer,
          $$StockAdjustmentsTableCreateCompanionBuilder,
          $$StockAdjustmentsTableUpdateCompanionBuilder,
          (StockAdjustmentRow, $$StockAdjustmentsTableReferences),
          StockAdjustmentRow,
          PrefetchHooks Function({bool productId})
        > {
  $$StockAdjustmentsTableTableManager(
    _$AppDatabase db,
    $StockAdjustmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockAdjustmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockAdjustmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockAdjustmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<Presentation> presentation = const Value.absent(),
                Value<int> unitsBase = const Value.absent(),
                Value<AdjustmentReason> reason = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> registeredBy = const Value.absent(),
                Value<String?> voidedBy = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<int> unitCostRaw = const Value.absent(),
                Value<int> costTotalCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockAdjustmentsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                productId: productId,
                date: date,
                quantity: quantity,
                presentation: presentation,
                unitsBase: unitsBase,
                reason: reason,
                notes: notes,
                registeredBy: registeredBy,
                voidedBy: voidedBy,
                voidReason: voidReason,
                unitCostRaw: unitCostRaw,
                costTotalCents: costTotalCents,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String productId,
                required DateTime date,
                required int quantity,
                required Presentation presentation,
                required int unitsBase,
                required AdjustmentReason reason,
                Value<String?> notes = const Value.absent(),
                Value<String?> registeredBy = const Value.absent(),
                Value<String?> voidedBy = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                required int unitCostRaw,
                required int costTotalCents,
                Value<int> rowid = const Value.absent(),
              }) => StockAdjustmentsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                productId: productId,
                date: date,
                quantity: quantity,
                presentation: presentation,
                unitsBase: unitsBase,
                reason: reason,
                notes: notes,
                registeredBy: registeredBy,
                voidedBy: voidedBy,
                voidReason: voidReason,
                unitCostRaw: unitCostRaw,
                costTotalCents: costTotalCents,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StockAdjustmentsTable, StockAdjustmentRow>(
                    table,
                  ),
                  $$StockAdjustmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
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
                    if (productId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.productId,
                        referencedTable: $$StockAdjustmentsTableReferences
                            ._productIdTable(db),
                        referencedColumn: $$StockAdjustmentsTableReferences
                            ._productIdTable(db)
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

typedef $$StockAdjustmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockAdjustmentsTable,
      StockAdjustmentRow,
      $$StockAdjustmentsTableFilterComposer,
      $$StockAdjustmentsTableOrderingComposer,
      $$StockAdjustmentsTableAnnotationComposer,
      $$StockAdjustmentsTableCreateCompanionBuilder,
      $$StockAdjustmentsTableUpdateCompanionBuilder,
      (StockAdjustmentRow, $$StockAdjustmentsTableReferences),
      StockAdjustmentRow,
      PrefetchHooks Function({bool productId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $SyncOutboxTableManager get syncOutbox =>
      $SyncOutboxTableManager(_db, _db.syncOutbox);
  $SyncStateTableManager get syncState =>
      $SyncStateTableManager(_db, _db.syncState);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$PurchasesTableTableManager get purchases =>
      $$PurchasesTableTableManager(_db, _db.purchases);
  $$PurchaseLinesTableTableManager get purchaseLines =>
      $$PurchaseLinesTableTableManager(_db, _db.purchaseLines);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db, _db.sales);
  $$SaleLinesTableTableManager get saleLines =>
      $$SaleLinesTableTableManager(_db, _db.saleLines);
  $$SaleExtraChargesTableTableManager get saleExtraCharges =>
      $$SaleExtraChargesTableTableManager(_db, _db.saleExtraCharges);
  $$StockAdjustmentsTableTableManager get stockAdjustments =>
      $$StockAdjustmentsTableTableManager(_db, _db.stockAdjustments);
}
