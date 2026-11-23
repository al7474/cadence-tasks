// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CalendarDisplaySettingsTableTable extends CalendarDisplaySettingsTable
    with
        TableInfo<
          $CalendarDisplaySettingsTableTable,
          CalendarDisplaySettingsRow
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarDisplaySettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startHourMeta = const VerificationMeta(
    'startHour',
  );
  @override
  late final GeneratedColumn<int> startHour = GeneratedColumn<int>(
    'start_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endHourMeta = const VerificationMeta(
    'endHour',
  );
  @override
  late final GeneratedColumn<int> endHour = GeneratedColumn<int>(
    'end_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMillisMeta =
      const VerificationMeta('updatedAtUtcMillis');
  @override
  late final GeneratedColumn<int> updatedAtUtcMillis = GeneratedColumn<int>(
    'updated_at_utc_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mutationIdMeta = const VerificationMeta(
    'mutationId',
  );
  @override
  late final GeneratedColumn<String> mutationId = GeneratedColumn<String>(
    'mutation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    startHour,
    endHour,
    updatedAtUtcMillis,
    mutationId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_display_settings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CalendarDisplaySettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('start_hour')) {
      context.handle(
        _startHourMeta,
        startHour.isAcceptableOrUnknown(data['start_hour']!, _startHourMeta),
      );
    } else if (isInserting) {
      context.missing(_startHourMeta);
    }
    if (data.containsKey('end_hour')) {
      context.handle(
        _endHourMeta,
        endHour.isAcceptableOrUnknown(data['end_hour']!, _endHourMeta),
      );
    } else if (isInserting) {
      context.missing(_endHourMeta);
    }
    if (data.containsKey('updated_at_utc_millis')) {
      context.handle(
        _updatedAtUtcMillisMeta,
        updatedAtUtcMillis.isAcceptableOrUnknown(
          data['updated_at_utc_millis']!,
          _updatedAtUtcMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMillisMeta);
    }
    if (data.containsKey('mutation_id')) {
      context.handle(
        _mutationIdMeta,
        mutationId.isAcceptableOrUnknown(data['mutation_id']!, _mutationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mutationIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  CalendarDisplaySettingsRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarDisplaySettingsRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      startHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_hour'],
      )!,
      endHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_hour'],
      )!,
      updatedAtUtcMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc_millis'],
      )!,
      mutationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mutation_id'],
      )!,
    );
  }

  @override
  $CalendarDisplaySettingsTableTable createAlias(String alias) {
    return $CalendarDisplaySettingsTableTable(attachedDatabase, alias);
  }
}

class CalendarDisplaySettingsRow extends DataClass
    implements Insertable<CalendarDisplaySettingsRow> {
  final String userId;
  final int startHour;
  final int endHour;
  final int updatedAtUtcMillis;
  final String mutationId;
  const CalendarDisplaySettingsRow({
    required this.userId,
    required this.startHour,
    required this.endHour,
    required this.updatedAtUtcMillis,
    required this.mutationId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['start_hour'] = Variable<int>(startHour);
    map['end_hour'] = Variable<int>(endHour);
    map['updated_at_utc_millis'] = Variable<int>(updatedAtUtcMillis);
    map['mutation_id'] = Variable<String>(mutationId);
    return map;
  }

  CalendarDisplaySettingsTableCompanion toCompanion(bool nullToAbsent) {
    return CalendarDisplaySettingsTableCompanion(
      userId: Value(userId),
      startHour: Value(startHour),
      endHour: Value(endHour),
      updatedAtUtcMillis: Value(updatedAtUtcMillis),
      mutationId: Value(mutationId),
    );
  }

  factory CalendarDisplaySettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarDisplaySettingsRow(
      userId: serializer.fromJson<String>(json['userId']),
      startHour: serializer.fromJson<int>(json['startHour']),
      endHour: serializer.fromJson<int>(json['endHour']),
      updatedAtUtcMillis: serializer.fromJson<int>(json['updatedAtUtcMillis']),
      mutationId: serializer.fromJson<String>(json['mutationId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'startHour': serializer.toJson<int>(startHour),
      'endHour': serializer.toJson<int>(endHour),
      'updatedAtUtcMillis': serializer.toJson<int>(updatedAtUtcMillis),
      'mutationId': serializer.toJson<String>(mutationId),
    };
  }

  CalendarDisplaySettingsRow copyWith({
    String? userId,
    int? startHour,
    int? endHour,
    int? updatedAtUtcMillis,
    String? mutationId,
  }) => CalendarDisplaySettingsRow(
    userId: userId ?? this.userId,
    startHour: startHour ?? this.startHour,
    endHour: endHour ?? this.endHour,
    updatedAtUtcMillis: updatedAtUtcMillis ?? this.updatedAtUtcMillis,
    mutationId: mutationId ?? this.mutationId,
  );
  CalendarDisplaySettingsRow copyWithCompanion(
    CalendarDisplaySettingsTableCompanion data,
  ) {
    return CalendarDisplaySettingsRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      startHour: data.startHour.present ? data.startHour.value : this.startHour,
      endHour: data.endHour.present ? data.endHour.value : this.endHour,
      updatedAtUtcMillis: data.updatedAtUtcMillis.present
          ? data.updatedAtUtcMillis.value
          : this.updatedAtUtcMillis,
      mutationId: data.mutationId.present
          ? data.mutationId.value
          : this.mutationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarDisplaySettingsRow(')
          ..write('userId: $userId, ')
          ..write('startHour: $startHour, ')
          ..write('endHour: $endHour, ')
          ..write('updatedAtUtcMillis: $updatedAtUtcMillis, ')
          ..write('mutationId: $mutationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(userId, startHour, endHour, updatedAtUtcMillis, mutationId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarDisplaySettingsRow &&
          other.userId == this.userId &&
          other.startHour == this.startHour &&
          other.endHour == this.endHour &&
          other.updatedAtUtcMillis == this.updatedAtUtcMillis &&
          other.mutationId == this.mutationId);
}

class CalendarDisplaySettingsTableCompanion
    extends UpdateCompanion<CalendarDisplaySettingsRow> {
  final Value<String> userId;
  final Value<int> startHour;
  final Value<int> endHour;
  final Value<int> updatedAtUtcMillis;
  final Value<String> mutationId;
  final Value<int> rowid;
  const CalendarDisplaySettingsTableCompanion({
    this.userId = const Value.absent(),
    this.startHour = const Value.absent(),
    this.endHour = const Value.absent(),
    this.updatedAtUtcMillis = const Value.absent(),
    this.mutationId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CalendarDisplaySettingsTableCompanion.insert({
    required String userId,
    required int startHour,
    required int endHour,
    required int updatedAtUtcMillis,
    required String mutationId,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       startHour = Value(startHour),
       endHour = Value(endHour),
       updatedAtUtcMillis = Value(updatedAtUtcMillis),
       mutationId = Value(mutationId);
  static Insertable<CalendarDisplaySettingsRow> custom({
    Expression<String>? userId,
    Expression<int>? startHour,
    Expression<int>? endHour,
    Expression<int>? updatedAtUtcMillis,
    Expression<String>? mutationId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (startHour != null) 'start_hour': startHour,
      if (endHour != null) 'end_hour': endHour,
      if (updatedAtUtcMillis != null)
        'updated_at_utc_millis': updatedAtUtcMillis,
      if (mutationId != null) 'mutation_id': mutationId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CalendarDisplaySettingsTableCompanion copyWith({
    Value<String>? userId,
    Value<int>? startHour,
    Value<int>? endHour,
    Value<int>? updatedAtUtcMillis,
    Value<String>? mutationId,
    Value<int>? rowid,
  }) {
    return CalendarDisplaySettingsTableCompanion(
      userId: userId ?? this.userId,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
      updatedAtUtcMillis: updatedAtUtcMillis ?? this.updatedAtUtcMillis,
      mutationId: mutationId ?? this.mutationId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (startHour.present) {
      map['start_hour'] = Variable<int>(startHour.value);
    }
    if (endHour.present) {
      map['end_hour'] = Variable<int>(endHour.value);
    }
    if (updatedAtUtcMillis.present) {
      map['updated_at_utc_millis'] = Variable<int>(updatedAtUtcMillis.value);
    }
    if (mutationId.present) {
      map['mutation_id'] = Variable<String>(mutationId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarDisplaySettingsTableCompanion(')
          ..write('userId: $userId, ')
          ..write('startHour: $startHour, ')
          ..write('endHour: $endHour, ')
          ..write('updatedAtUtcMillis: $updatedAtUtcMillis, ')
          ..write('mutationId: $mutationId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutineTemplatesTable extends RoutineTemplates
    with TableInfo<$RoutineTemplatesTable, RoutineTemplateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetTimeMinutesMeta = const VerificationMeta(
    'targetTimeMinutes',
  );
  @override
  late final GeneratedColumn<int> targetTimeMinutes = GeneratedColumn<int>(
    'target_time_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recurrenceKindMeta = const VerificationMeta(
    'recurrenceKind',
  );
  @override
  late final GeneratedColumn<String> recurrenceKind = GeneratedColumn<String>(
    'recurrence_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekdaysMaskMeta = const VerificationMeta(
    'weekdaysMask',
  );
  @override
  late final GeneratedColumn<int> weekdaysMask = GeneratedColumn<int>(
    'weekdays_mask',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
    'interval_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderEnabledMeta = const VerificationMeta(
    'reminderEnabled',
  );
  @override
  late final GeneratedColumn<bool> reminderEnabled = GeneratedColumn<bool>(
    'reminder_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminder_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtUtcMillisMeta =
      const VerificationMeta('updatedAtUtcMillis');
  @override
  late final GeneratedColumn<int> updatedAtUtcMillis = GeneratedColumn<int>(
    'updated_at_utc_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtUtcMillisMeta =
      const VerificationMeta('deletedAtUtcMillis');
  @override
  late final GeneratedColumn<int> deletedAtUtcMillis = GeneratedColumn<int>(
    'deleted_at_utc_millis',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mutationIdMeta = const VerificationMeta(
    'mutationId',
  );
  @override
  late final GeneratedColumn<String> mutationId = GeneratedColumn<String>(
    'mutation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    id,
    title,
    notes,
    startDate,
    endDate,
    targetTimeMinutes,
    recurrenceKind,
    weekdaysMask,
    intervalDays,
    reminderEnabled,
    isEnabled,
    updatedAtUtcMillis,
    deletedAtUtcMillis,
    mutationId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineTemplateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('target_time_minutes')) {
      context.handle(
        _targetTimeMinutesMeta,
        targetTimeMinutes.isAcceptableOrUnknown(
          data['target_time_minutes']!,
          _targetTimeMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetTimeMinutesMeta);
    }
    if (data.containsKey('recurrence_kind')) {
      context.handle(
        _recurrenceKindMeta,
        recurrenceKind.isAcceptableOrUnknown(
          data['recurrence_kind']!,
          _recurrenceKindMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recurrenceKindMeta);
    }
    if (data.containsKey('weekdays_mask')) {
      context.handle(
        _weekdaysMaskMeta,
        weekdaysMask.isAcceptableOrUnknown(
          data['weekdays_mask']!,
          _weekdaysMaskMeta,
        ),
      );
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('reminder_enabled')) {
      context.handle(
        _reminderEnabledMeta,
        reminderEnabled.isAcceptableOrUnknown(
          data['reminder_enabled']!,
          _reminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('updated_at_utc_millis')) {
      context.handle(
        _updatedAtUtcMillisMeta,
        updatedAtUtcMillis.isAcceptableOrUnknown(
          data['updated_at_utc_millis']!,
          _updatedAtUtcMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMillisMeta);
    }
    if (data.containsKey('deleted_at_utc_millis')) {
      context.handle(
        _deletedAtUtcMillisMeta,
        deletedAtUtcMillis.isAcceptableOrUnknown(
          data['deleted_at_utc_millis']!,
          _deletedAtUtcMillisMeta,
        ),
      );
    }
    if (data.containsKey('mutation_id')) {
      context.handle(
        _mutationIdMeta,
        mutationId.isAcceptableOrUnknown(data['mutation_id']!, _mutationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mutationIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  RoutineTemplateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineTemplateRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_date'],
      ),
      targetTimeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_time_minutes'],
      )!,
      recurrenceKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_kind'],
      )!,
      weekdaysMask: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekdays_mask'],
      )!,
      intervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_days'],
      ),
      reminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminder_enabled'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      updatedAtUtcMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc_millis'],
      )!,
      deletedAtUtcMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_utc_millis'],
      ),
      mutationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mutation_id'],
      )!,
    );
  }

  @override
  $RoutineTemplatesTable createAlias(String alias) {
    return $RoutineTemplatesTable(attachedDatabase, alias);
  }
}

class RoutineTemplateRow extends DataClass
    implements Insertable<RoutineTemplateRow> {
  final String userId;
  final String id;
  final String title;
  final String? notes;
  final String startDate;
  final String? endDate;
  final int targetTimeMinutes;
  final String recurrenceKind;
  final int weekdaysMask;
  final int? intervalDays;
  final bool reminderEnabled;
  final bool isEnabled;
  final int updatedAtUtcMillis;
  final int? deletedAtUtcMillis;
  final String mutationId;
  const RoutineTemplateRow({
    required this.userId,
    required this.id,
    required this.title,
    this.notes,
    required this.startDate,
    this.endDate,
    required this.targetTimeMinutes,
    required this.recurrenceKind,
    required this.weekdaysMask,
    this.intervalDays,
    required this.reminderEnabled,
    required this.isEnabled,
    required this.updatedAtUtcMillis,
    this.deletedAtUtcMillis,
    required this.mutationId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['start_date'] = Variable<String>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(endDate);
    }
    map['target_time_minutes'] = Variable<int>(targetTimeMinutes);
    map['recurrence_kind'] = Variable<String>(recurrenceKind);
    map['weekdays_mask'] = Variable<int>(weekdaysMask);
    if (!nullToAbsent || intervalDays != null) {
      map['interval_days'] = Variable<int>(intervalDays);
    }
    map['reminder_enabled'] = Variable<bool>(reminderEnabled);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['updated_at_utc_millis'] = Variable<int>(updatedAtUtcMillis);
    if (!nullToAbsent || deletedAtUtcMillis != null) {
      map['deleted_at_utc_millis'] = Variable<int>(deletedAtUtcMillis);
    }
    map['mutation_id'] = Variable<String>(mutationId);
    return map;
  }

  RoutineTemplatesCompanion toCompanion(bool nullToAbsent) {
    return RoutineTemplatesCompanion(
      userId: Value(userId),
      id: Value(id),
      title: Value(title),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      targetTimeMinutes: Value(targetTimeMinutes),
      recurrenceKind: Value(recurrenceKind),
      weekdaysMask: Value(weekdaysMask),
      intervalDays: intervalDays == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalDays),
      reminderEnabled: Value(reminderEnabled),
      isEnabled: Value(isEnabled),
      updatedAtUtcMillis: Value(updatedAtUtcMillis),
      deletedAtUtcMillis: deletedAtUtcMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtUtcMillis),
      mutationId: Value(mutationId),
    );
  }

  factory RoutineTemplateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineTemplateRow(
      userId: serializer.fromJson<String>(json['userId']),
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String?>(json['notes']),
      startDate: serializer.fromJson<String>(json['startDate']),
      endDate: serializer.fromJson<String?>(json['endDate']),
      targetTimeMinutes: serializer.fromJson<int>(json['targetTimeMinutes']),
      recurrenceKind: serializer.fromJson<String>(json['recurrenceKind']),
      weekdaysMask: serializer.fromJson<int>(json['weekdaysMask']),
      intervalDays: serializer.fromJson<int?>(json['intervalDays']),
      reminderEnabled: serializer.fromJson<bool>(json['reminderEnabled']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      updatedAtUtcMillis: serializer.fromJson<int>(json['updatedAtUtcMillis']),
      deletedAtUtcMillis: serializer.fromJson<int?>(json['deletedAtUtcMillis']),
      mutationId: serializer.fromJson<String>(json['mutationId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String?>(notes),
      'startDate': serializer.toJson<String>(startDate),
      'endDate': serializer.toJson<String?>(endDate),
      'targetTimeMinutes': serializer.toJson<int>(targetTimeMinutes),
      'recurrenceKind': serializer.toJson<String>(recurrenceKind),
      'weekdaysMask': serializer.toJson<int>(weekdaysMask),
      'intervalDays': serializer.toJson<int?>(intervalDays),
      'reminderEnabled': serializer.toJson<bool>(reminderEnabled),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'updatedAtUtcMillis': serializer.toJson<int>(updatedAtUtcMillis),
      'deletedAtUtcMillis': serializer.toJson<int?>(deletedAtUtcMillis),
      'mutationId': serializer.toJson<String>(mutationId),
    };
  }

  RoutineTemplateRow copyWith({
    String? userId,
    String? id,
    String? title,
    Value<String?> notes = const Value.absent(),
    String? startDate,
    Value<String?> endDate = const Value.absent(),
    int? targetTimeMinutes,
    String? recurrenceKind,
    int? weekdaysMask,
    Value<int?> intervalDays = const Value.absent(),
    bool? reminderEnabled,
    bool? isEnabled,
    int? updatedAtUtcMillis,
    Value<int?> deletedAtUtcMillis = const Value.absent(),
    String? mutationId,
  }) => RoutineTemplateRow(
    userId: userId ?? this.userId,
    id: id ?? this.id,
    title: title ?? this.title,
    notes: notes.present ? notes.value : this.notes,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    targetTimeMinutes: targetTimeMinutes ?? this.targetTimeMinutes,
    recurrenceKind: recurrenceKind ?? this.recurrenceKind,
    weekdaysMask: weekdaysMask ?? this.weekdaysMask,
    intervalDays: intervalDays.present ? intervalDays.value : this.intervalDays,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    isEnabled: isEnabled ?? this.isEnabled,
    updatedAtUtcMillis: updatedAtUtcMillis ?? this.updatedAtUtcMillis,
    deletedAtUtcMillis: deletedAtUtcMillis.present
        ? deletedAtUtcMillis.value
        : this.deletedAtUtcMillis,
    mutationId: mutationId ?? this.mutationId,
  );
  RoutineTemplateRow copyWithCompanion(RoutineTemplatesCompanion data) {
    return RoutineTemplateRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      targetTimeMinutes: data.targetTimeMinutes.present
          ? data.targetTimeMinutes.value
          : this.targetTimeMinutes,
      recurrenceKind: data.recurrenceKind.present
          ? data.recurrenceKind.value
          : this.recurrenceKind,
      weekdaysMask: data.weekdaysMask.present
          ? data.weekdaysMask.value
          : this.weekdaysMask,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      reminderEnabled: data.reminderEnabled.present
          ? data.reminderEnabled.value
          : this.reminderEnabled,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      updatedAtUtcMillis: data.updatedAtUtcMillis.present
          ? data.updatedAtUtcMillis.value
          : this.updatedAtUtcMillis,
      deletedAtUtcMillis: data.deletedAtUtcMillis.present
          ? data.deletedAtUtcMillis.value
          : this.deletedAtUtcMillis,
      mutationId: data.mutationId.present
          ? data.mutationId.value
          : this.mutationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineTemplateRow(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('targetTimeMinutes: $targetTimeMinutes, ')
          ..write('recurrenceKind: $recurrenceKind, ')
          ..write('weekdaysMask: $weekdaysMask, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('updatedAtUtcMillis: $updatedAtUtcMillis, ')
          ..write('deletedAtUtcMillis: $deletedAtUtcMillis, ')
          ..write('mutationId: $mutationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    id,
    title,
    notes,
    startDate,
    endDate,
    targetTimeMinutes,
    recurrenceKind,
    weekdaysMask,
    intervalDays,
    reminderEnabled,
    isEnabled,
    updatedAtUtcMillis,
    deletedAtUtcMillis,
    mutationId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineTemplateRow &&
          other.userId == this.userId &&
          other.id == this.id &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.targetTimeMinutes == this.targetTimeMinutes &&
          other.recurrenceKind == this.recurrenceKind &&
          other.weekdaysMask == this.weekdaysMask &&
          other.intervalDays == this.intervalDays &&
          other.reminderEnabled == this.reminderEnabled &&
          other.isEnabled == this.isEnabled &&
          other.updatedAtUtcMillis == this.updatedAtUtcMillis &&
          other.deletedAtUtcMillis == this.deletedAtUtcMillis &&
          other.mutationId == this.mutationId);
}

class RoutineTemplatesCompanion extends UpdateCompanion<RoutineTemplateRow> {
  final Value<String> userId;
  final Value<String> id;
  final Value<String> title;
  final Value<String?> notes;
  final Value<String> startDate;
  final Value<String?> endDate;
  final Value<int> targetTimeMinutes;
  final Value<String> recurrenceKind;
  final Value<int> weekdaysMask;
  final Value<int?> intervalDays;
  final Value<bool> reminderEnabled;
  final Value<bool> isEnabled;
  final Value<int> updatedAtUtcMillis;
  final Value<int?> deletedAtUtcMillis;
  final Value<String> mutationId;
  final Value<int> rowid;
  const RoutineTemplatesCompanion({
    this.userId = const Value.absent(),
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.targetTimeMinutes = const Value.absent(),
    this.recurrenceKind = const Value.absent(),
    this.weekdaysMask = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.updatedAtUtcMillis = const Value.absent(),
    this.deletedAtUtcMillis = const Value.absent(),
    this.mutationId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutineTemplatesCompanion.insert({
    required String userId,
    required String id,
    required String title,
    this.notes = const Value.absent(),
    required String startDate,
    this.endDate = const Value.absent(),
    required int targetTimeMinutes,
    required String recurrenceKind,
    this.weekdaysMask = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.isEnabled = const Value.absent(),
    required int updatedAtUtcMillis,
    this.deletedAtUtcMillis = const Value.absent(),
    required String mutationId,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       id = Value(id),
       title = Value(title),
       startDate = Value(startDate),
       targetTimeMinutes = Value(targetTimeMinutes),
       recurrenceKind = Value(recurrenceKind),
       updatedAtUtcMillis = Value(updatedAtUtcMillis),
       mutationId = Value(mutationId);
  static Insertable<RoutineTemplateRow> custom({
    Expression<String>? userId,
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<int>? targetTimeMinutes,
    Expression<String>? recurrenceKind,
    Expression<int>? weekdaysMask,
    Expression<int>? intervalDays,
    Expression<bool>? reminderEnabled,
    Expression<bool>? isEnabled,
    Expression<int>? updatedAtUtcMillis,
    Expression<int>? deletedAtUtcMillis,
    Expression<String>? mutationId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (targetTimeMinutes != null) 'target_time_minutes': targetTimeMinutes,
      if (recurrenceKind != null) 'recurrence_kind': recurrenceKind,
      if (weekdaysMask != null) 'weekdays_mask': weekdaysMask,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (reminderEnabled != null) 'reminder_enabled': reminderEnabled,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (updatedAtUtcMillis != null)
        'updated_at_utc_millis': updatedAtUtcMillis,
      if (deletedAtUtcMillis != null)
        'deleted_at_utc_millis': deletedAtUtcMillis,
      if (mutationId != null) 'mutation_id': mutationId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutineTemplatesCompanion copyWith({
    Value<String>? userId,
    Value<String>? id,
    Value<String>? title,
    Value<String?>? notes,
    Value<String>? startDate,
    Value<String?>? endDate,
    Value<int>? targetTimeMinutes,
    Value<String>? recurrenceKind,
    Value<int>? weekdaysMask,
    Value<int?>? intervalDays,
    Value<bool>? reminderEnabled,
    Value<bool>? isEnabled,
    Value<int>? updatedAtUtcMillis,
    Value<int?>? deletedAtUtcMillis,
    Value<String>? mutationId,
    Value<int>? rowid,
  }) {
    return RoutineTemplatesCompanion(
      userId: userId ?? this.userId,
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      targetTimeMinutes: targetTimeMinutes ?? this.targetTimeMinutes,
      recurrenceKind: recurrenceKind ?? this.recurrenceKind,
      weekdaysMask: weekdaysMask ?? this.weekdaysMask,
      intervalDays: intervalDays ?? this.intervalDays,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      isEnabled: isEnabled ?? this.isEnabled,
      updatedAtUtcMillis: updatedAtUtcMillis ?? this.updatedAtUtcMillis,
      deletedAtUtcMillis: deletedAtUtcMillis ?? this.deletedAtUtcMillis,
      mutationId: mutationId ?? this.mutationId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(endDate.value);
    }
    if (targetTimeMinutes.present) {
      map['target_time_minutes'] = Variable<int>(targetTimeMinutes.value);
    }
    if (recurrenceKind.present) {
      map['recurrence_kind'] = Variable<String>(recurrenceKind.value);
    }
    if (weekdaysMask.present) {
      map['weekdays_mask'] = Variable<int>(weekdaysMask.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (reminderEnabled.present) {
      map['reminder_enabled'] = Variable<bool>(reminderEnabled.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (updatedAtUtcMillis.present) {
      map['updated_at_utc_millis'] = Variable<int>(updatedAtUtcMillis.value);
    }
    if (deletedAtUtcMillis.present) {
      map['deleted_at_utc_millis'] = Variable<int>(deletedAtUtcMillis.value);
    }
    if (mutationId.present) {
      map['mutation_id'] = Variable<String>(mutationId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineTemplatesCompanion(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('targetTimeMinutes: $targetTimeMinutes, ')
          ..write('recurrenceKind: $recurrenceKind, ')
          ..write('weekdaysMask: $weekdaysMask, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('updatedAtUtcMillis: $updatedAtUtcMillis, ')
          ..write('deletedAtUtcMillis: $deletedAtUtcMillis, ')
          ..write('mutationId: $mutationId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutineOccurrenceLogsTable extends RoutineOccurrenceLogs
    with TableInfo<$RoutineOccurrenceLogsTable, RoutineOccurrenceLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineOccurrenceLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routineIdMeta = const VerificationMeta(
    'routineId',
  );
  @override
  late final GeneratedColumn<String> routineId = GeneratedColumn<String>(
    'routine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurrenceDateMeta = const VerificationMeta(
    'occurrenceDate',
  );
  @override
  late final GeneratedColumn<String> occurrenceDate = GeneratedColumn<String>(
    'occurrence_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtUtcMillisMeta =
      const VerificationMeta('completedAtUtcMillis');
  @override
  late final GeneratedColumn<int> completedAtUtcMillis = GeneratedColumn<int>(
    'completed_at_utc_millis',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snoozedUntilUtcMillisMeta =
      const VerificationMeta('snoozedUntilUtcMillis');
  @override
  late final GeneratedColumn<int> snoozedUntilUtcMillis = GeneratedColumn<int>(
    'snoozed_until_utc_millis',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rescheduledDateMeta = const VerificationMeta(
    'rescheduledDate',
  );
  @override
  late final GeneratedColumn<String> rescheduledDate = GeneratedColumn<String>(
    'rescheduled_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rescheduledTimeMinutesMeta =
      const VerificationMeta('rescheduledTimeMinutes');
  @override
  late final GeneratedColumn<int> rescheduledTimeMinutes = GeneratedColumn<int>(
    'rescheduled_time_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtUtcMillisMeta =
      const VerificationMeta('updatedAtUtcMillis');
  @override
  late final GeneratedColumn<int> updatedAtUtcMillis = GeneratedColumn<int>(
    'updated_at_utc_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtUtcMillisMeta =
      const VerificationMeta('deletedAtUtcMillis');
  @override
  late final GeneratedColumn<int> deletedAtUtcMillis = GeneratedColumn<int>(
    'deleted_at_utc_millis',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mutationIdMeta = const VerificationMeta(
    'mutationId',
  );
  @override
  late final GeneratedColumn<String> mutationId = GeneratedColumn<String>(
    'mutation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    routineId,
    occurrenceDate,
    status,
    completedAtUtcMillis,
    snoozedUntilUtcMillis,
    rescheduledDate,
    rescheduledTimeMinutes,
    updatedAtUtcMillis,
    deletedAtUtcMillis,
    mutationId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_occurrence_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineOccurrenceLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('occurrence_date')) {
      context.handle(
        _occurrenceDateMeta,
        occurrenceDate.isAcceptableOrUnknown(
          data['occurrence_date']!,
          _occurrenceDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurrenceDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('completed_at_utc_millis')) {
      context.handle(
        _completedAtUtcMillisMeta,
        completedAtUtcMillis.isAcceptableOrUnknown(
          data['completed_at_utc_millis']!,
          _completedAtUtcMillisMeta,
        ),
      );
    }
    if (data.containsKey('snoozed_until_utc_millis')) {
      context.handle(
        _snoozedUntilUtcMillisMeta,
        snoozedUntilUtcMillis.isAcceptableOrUnknown(
          data['snoozed_until_utc_millis']!,
          _snoozedUntilUtcMillisMeta,
        ),
      );
    }
    if (data.containsKey('rescheduled_date')) {
      context.handle(
        _rescheduledDateMeta,
        rescheduledDate.isAcceptableOrUnknown(
          data['rescheduled_date']!,
          _rescheduledDateMeta,
        ),
      );
    }
    if (data.containsKey('rescheduled_time_minutes')) {
      context.handle(
        _rescheduledTimeMinutesMeta,
        rescheduledTimeMinutes.isAcceptableOrUnknown(
          data['rescheduled_time_minutes']!,
          _rescheduledTimeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('updated_at_utc_millis')) {
      context.handle(
        _updatedAtUtcMillisMeta,
        updatedAtUtcMillis.isAcceptableOrUnknown(
          data['updated_at_utc_millis']!,
          _updatedAtUtcMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMillisMeta);
    }
    if (data.containsKey('deleted_at_utc_millis')) {
      context.handle(
        _deletedAtUtcMillisMeta,
        deletedAtUtcMillis.isAcceptableOrUnknown(
          data['deleted_at_utc_millis']!,
          _deletedAtUtcMillisMeta,
        ),
      );
    }
    if (data.containsKey('mutation_id')) {
      context.handle(
        _mutationIdMeta,
        mutationId.isAcceptableOrUnknown(data['mutation_id']!, _mutationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mutationIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, routineId, occurrenceDate};
  @override
  RoutineOccurrenceLogRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineOccurrenceLogRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine_id'],
      )!,
      occurrenceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occurrence_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      completedAtUtcMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at_utc_millis'],
      ),
      snoozedUntilUtcMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snoozed_until_utc_millis'],
      ),
      rescheduledDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rescheduled_date'],
      ),
      rescheduledTimeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rescheduled_time_minutes'],
      ),
      updatedAtUtcMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc_millis'],
      )!,
      deletedAtUtcMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_utc_millis'],
      ),
      mutationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mutation_id'],
      )!,
    );
  }

  @override
  $RoutineOccurrenceLogsTable createAlias(String alias) {
    return $RoutineOccurrenceLogsTable(attachedDatabase, alias);
  }
}

class RoutineOccurrenceLogRow extends DataClass
    implements Insertable<RoutineOccurrenceLogRow> {
  final String userId;
  final String routineId;
  final String occurrenceDate;
  final String status;
  final int? completedAtUtcMillis;
  final int? snoozedUntilUtcMillis;
  final String? rescheduledDate;
  final int? rescheduledTimeMinutes;
  final int updatedAtUtcMillis;
  final int? deletedAtUtcMillis;
  final String mutationId;
  const RoutineOccurrenceLogRow({
    required this.userId,
    required this.routineId,
    required this.occurrenceDate,
    required this.status,
    this.completedAtUtcMillis,
    this.snoozedUntilUtcMillis,
    this.rescheduledDate,
    this.rescheduledTimeMinutes,
    required this.updatedAtUtcMillis,
    this.deletedAtUtcMillis,
    required this.mutationId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['routine_id'] = Variable<String>(routineId);
    map['occurrence_date'] = Variable<String>(occurrenceDate);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || completedAtUtcMillis != null) {
      map['completed_at_utc_millis'] = Variable<int>(completedAtUtcMillis);
    }
    if (!nullToAbsent || snoozedUntilUtcMillis != null) {
      map['snoozed_until_utc_millis'] = Variable<int>(snoozedUntilUtcMillis);
    }
    if (!nullToAbsent || rescheduledDate != null) {
      map['rescheduled_date'] = Variable<String>(rescheduledDate);
    }
    if (!nullToAbsent || rescheduledTimeMinutes != null) {
      map['rescheduled_time_minutes'] = Variable<int>(rescheduledTimeMinutes);
    }
    map['updated_at_utc_millis'] = Variable<int>(updatedAtUtcMillis);
    if (!nullToAbsent || deletedAtUtcMillis != null) {
      map['deleted_at_utc_millis'] = Variable<int>(deletedAtUtcMillis);
    }
    map['mutation_id'] = Variable<String>(mutationId);
    return map;
  }

  RoutineOccurrenceLogsCompanion toCompanion(bool nullToAbsent) {
    return RoutineOccurrenceLogsCompanion(
      userId: Value(userId),
      routineId: Value(routineId),
      occurrenceDate: Value(occurrenceDate),
      status: Value(status),
      completedAtUtcMillis: completedAtUtcMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAtUtcMillis),
      snoozedUntilUtcMillis: snoozedUntilUtcMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozedUntilUtcMillis),
      rescheduledDate: rescheduledDate == null && nullToAbsent
          ? const Value.absent()
          : Value(rescheduledDate),
      rescheduledTimeMinutes: rescheduledTimeMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(rescheduledTimeMinutes),
      updatedAtUtcMillis: Value(updatedAtUtcMillis),
      deletedAtUtcMillis: deletedAtUtcMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtUtcMillis),
      mutationId: Value(mutationId),
    );
  }

  factory RoutineOccurrenceLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineOccurrenceLogRow(
      userId: serializer.fromJson<String>(json['userId']),
      routineId: serializer.fromJson<String>(json['routineId']),
      occurrenceDate: serializer.fromJson<String>(json['occurrenceDate']),
      status: serializer.fromJson<String>(json['status']),
      completedAtUtcMillis: serializer.fromJson<int?>(
        json['completedAtUtcMillis'],
      ),
      snoozedUntilUtcMillis: serializer.fromJson<int?>(
        json['snoozedUntilUtcMillis'],
      ),
      rescheduledDate: serializer.fromJson<String?>(json['rescheduledDate']),
      rescheduledTimeMinutes: serializer.fromJson<int?>(
        json['rescheduledTimeMinutes'],
      ),
      updatedAtUtcMillis: serializer.fromJson<int>(json['updatedAtUtcMillis']),
      deletedAtUtcMillis: serializer.fromJson<int?>(json['deletedAtUtcMillis']),
      mutationId: serializer.fromJson<String>(json['mutationId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'routineId': serializer.toJson<String>(routineId),
      'occurrenceDate': serializer.toJson<String>(occurrenceDate),
      'status': serializer.toJson<String>(status),
      'completedAtUtcMillis': serializer.toJson<int?>(completedAtUtcMillis),
      'snoozedUntilUtcMillis': serializer.toJson<int?>(snoozedUntilUtcMillis),
      'rescheduledDate': serializer.toJson<String?>(rescheduledDate),
      'rescheduledTimeMinutes': serializer.toJson<int?>(rescheduledTimeMinutes),
      'updatedAtUtcMillis': serializer.toJson<int>(updatedAtUtcMillis),
      'deletedAtUtcMillis': serializer.toJson<int?>(deletedAtUtcMillis),
      'mutationId': serializer.toJson<String>(mutationId),
    };
  }

  RoutineOccurrenceLogRow copyWith({
    String? userId,
    String? routineId,
    String? occurrenceDate,
    String? status,
    Value<int?> completedAtUtcMillis = const Value.absent(),
    Value<int?> snoozedUntilUtcMillis = const Value.absent(),
    Value<String?> rescheduledDate = const Value.absent(),
    Value<int?> rescheduledTimeMinutes = const Value.absent(),
    int? updatedAtUtcMillis,
    Value<int?> deletedAtUtcMillis = const Value.absent(),
    String? mutationId,
  }) => RoutineOccurrenceLogRow(
    userId: userId ?? this.userId,
    routineId: routineId ?? this.routineId,
    occurrenceDate: occurrenceDate ?? this.occurrenceDate,
    status: status ?? this.status,
    completedAtUtcMillis: completedAtUtcMillis.present
        ? completedAtUtcMillis.value
        : this.completedAtUtcMillis,
    snoozedUntilUtcMillis: snoozedUntilUtcMillis.present
        ? snoozedUntilUtcMillis.value
        : this.snoozedUntilUtcMillis,
    rescheduledDate: rescheduledDate.present
        ? rescheduledDate.value
        : this.rescheduledDate,
    rescheduledTimeMinutes: rescheduledTimeMinutes.present
        ? rescheduledTimeMinutes.value
        : this.rescheduledTimeMinutes,
    updatedAtUtcMillis: updatedAtUtcMillis ?? this.updatedAtUtcMillis,
    deletedAtUtcMillis: deletedAtUtcMillis.present
        ? deletedAtUtcMillis.value
        : this.deletedAtUtcMillis,
    mutationId: mutationId ?? this.mutationId,
  );
  RoutineOccurrenceLogRow copyWithCompanion(
    RoutineOccurrenceLogsCompanion data,
  ) {
    return RoutineOccurrenceLogRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      occurrenceDate: data.occurrenceDate.present
          ? data.occurrenceDate.value
          : this.occurrenceDate,
      status: data.status.present ? data.status.value : this.status,
      completedAtUtcMillis: data.completedAtUtcMillis.present
          ? data.completedAtUtcMillis.value
          : this.completedAtUtcMillis,
      snoozedUntilUtcMillis: data.snoozedUntilUtcMillis.present
          ? data.snoozedUntilUtcMillis.value
          : this.snoozedUntilUtcMillis,
      rescheduledDate: data.rescheduledDate.present
          ? data.rescheduledDate.value
          : this.rescheduledDate,
      rescheduledTimeMinutes: data.rescheduledTimeMinutes.present
          ? data.rescheduledTimeMinutes.value
          : this.rescheduledTimeMinutes,
      updatedAtUtcMillis: data.updatedAtUtcMillis.present
          ? data.updatedAtUtcMillis.value
          : this.updatedAtUtcMillis,
      deletedAtUtcMillis: data.deletedAtUtcMillis.present
          ? data.deletedAtUtcMillis.value
          : this.deletedAtUtcMillis,
      mutationId: data.mutationId.present
          ? data.mutationId.value
          : this.mutationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineOccurrenceLogRow(')
          ..write('userId: $userId, ')
          ..write('routineId: $routineId, ')
          ..write('occurrenceDate: $occurrenceDate, ')
          ..write('status: $status, ')
          ..write('completedAtUtcMillis: $completedAtUtcMillis, ')
          ..write('snoozedUntilUtcMillis: $snoozedUntilUtcMillis, ')
          ..write('rescheduledDate: $rescheduledDate, ')
          ..write('rescheduledTimeMinutes: $rescheduledTimeMinutes, ')
          ..write('updatedAtUtcMillis: $updatedAtUtcMillis, ')
          ..write('deletedAtUtcMillis: $deletedAtUtcMillis, ')
          ..write('mutationId: $mutationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    routineId,
    occurrenceDate,
    status,
    completedAtUtcMillis,
    snoozedUntilUtcMillis,
    rescheduledDate,
    rescheduledTimeMinutes,
    updatedAtUtcMillis,
    deletedAtUtcMillis,
    mutationId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineOccurrenceLogRow &&
          other.userId == this.userId &&
          other.routineId == this.routineId &&
          other.occurrenceDate == this.occurrenceDate &&
          other.status == this.status &&
          other.completedAtUtcMillis == this.completedAtUtcMillis &&
          other.snoozedUntilUtcMillis == this.snoozedUntilUtcMillis &&
          other.rescheduledDate == this.rescheduledDate &&
          other.rescheduledTimeMinutes == this.rescheduledTimeMinutes &&
          other.updatedAtUtcMillis == this.updatedAtUtcMillis &&
          other.deletedAtUtcMillis == this.deletedAtUtcMillis &&
          other.mutationId == this.mutationId);
}

class RoutineOccurrenceLogsCompanion
    extends UpdateCompanion<RoutineOccurrenceLogRow> {
  final Value<String> userId;
  final Value<String> routineId;
  final Value<String> occurrenceDate;
  final Value<String> status;
  final Value<int?> completedAtUtcMillis;
  final Value<int?> snoozedUntilUtcMillis;
  final Value<String?> rescheduledDate;
  final Value<int?> rescheduledTimeMinutes;
  final Value<int> updatedAtUtcMillis;
  final Value<int?> deletedAtUtcMillis;
  final Value<String> mutationId;
  final Value<int> rowid;
  const RoutineOccurrenceLogsCompanion({
    this.userId = const Value.absent(),
    this.routineId = const Value.absent(),
    this.occurrenceDate = const Value.absent(),
    this.status = const Value.absent(),
    this.completedAtUtcMillis = const Value.absent(),
    this.snoozedUntilUtcMillis = const Value.absent(),
    this.rescheduledDate = const Value.absent(),
    this.rescheduledTimeMinutes = const Value.absent(),
    this.updatedAtUtcMillis = const Value.absent(),
    this.deletedAtUtcMillis = const Value.absent(),
    this.mutationId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutineOccurrenceLogsCompanion.insert({
    required String userId,
    required String routineId,
    required String occurrenceDate,
    required String status,
    this.completedAtUtcMillis = const Value.absent(),
    this.snoozedUntilUtcMillis = const Value.absent(),
    this.rescheduledDate = const Value.absent(),
    this.rescheduledTimeMinutes = const Value.absent(),
    required int updatedAtUtcMillis,
    this.deletedAtUtcMillis = const Value.absent(),
    required String mutationId,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       routineId = Value(routineId),
       occurrenceDate = Value(occurrenceDate),
       status = Value(status),
       updatedAtUtcMillis = Value(updatedAtUtcMillis),
       mutationId = Value(mutationId);
  static Insertable<RoutineOccurrenceLogRow> custom({
    Expression<String>? userId,
    Expression<String>? routineId,
    Expression<String>? occurrenceDate,
    Expression<String>? status,
    Expression<int>? completedAtUtcMillis,
    Expression<int>? snoozedUntilUtcMillis,
    Expression<String>? rescheduledDate,
    Expression<int>? rescheduledTimeMinutes,
    Expression<int>? updatedAtUtcMillis,
    Expression<int>? deletedAtUtcMillis,
    Expression<String>? mutationId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (routineId != null) 'routine_id': routineId,
      if (occurrenceDate != null) 'occurrence_date': occurrenceDate,
      if (status != null) 'status': status,
      if (completedAtUtcMillis != null)
        'completed_at_utc_millis': completedAtUtcMillis,
      if (snoozedUntilUtcMillis != null)
        'snoozed_until_utc_millis': snoozedUntilUtcMillis,
      if (rescheduledDate != null) 'rescheduled_date': rescheduledDate,
      if (rescheduledTimeMinutes != null)
        'rescheduled_time_minutes': rescheduledTimeMinutes,
      if (updatedAtUtcMillis != null)
        'updated_at_utc_millis': updatedAtUtcMillis,
      if (deletedAtUtcMillis != null)
        'deleted_at_utc_millis': deletedAtUtcMillis,
      if (mutationId != null) 'mutation_id': mutationId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutineOccurrenceLogsCompanion copyWith({
    Value<String>? userId,
    Value<String>? routineId,
    Value<String>? occurrenceDate,
    Value<String>? status,
    Value<int?>? completedAtUtcMillis,
    Value<int?>? snoozedUntilUtcMillis,
    Value<String?>? rescheduledDate,
    Value<int?>? rescheduledTimeMinutes,
    Value<int>? updatedAtUtcMillis,
    Value<int?>? deletedAtUtcMillis,
    Value<String>? mutationId,
    Value<int>? rowid,
  }) {
    return RoutineOccurrenceLogsCompanion(
      userId: userId ?? this.userId,
      routineId: routineId ?? this.routineId,
      occurrenceDate: occurrenceDate ?? this.occurrenceDate,
      status: status ?? this.status,
      completedAtUtcMillis: completedAtUtcMillis ?? this.completedAtUtcMillis,
      snoozedUntilUtcMillis:
          snoozedUntilUtcMillis ?? this.snoozedUntilUtcMillis,
      rescheduledDate: rescheduledDate ?? this.rescheduledDate,
      rescheduledTimeMinutes:
          rescheduledTimeMinutes ?? this.rescheduledTimeMinutes,
      updatedAtUtcMillis: updatedAtUtcMillis ?? this.updatedAtUtcMillis,
      deletedAtUtcMillis: deletedAtUtcMillis ?? this.deletedAtUtcMillis,
      mutationId: mutationId ?? this.mutationId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<String>(routineId.value);
    }
    if (occurrenceDate.present) {
      map['occurrence_date'] = Variable<String>(occurrenceDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (completedAtUtcMillis.present) {
      map['completed_at_utc_millis'] = Variable<int>(
        completedAtUtcMillis.value,
      );
    }
    if (snoozedUntilUtcMillis.present) {
      map['snoozed_until_utc_millis'] = Variable<int>(
        snoozedUntilUtcMillis.value,
      );
    }
    if (rescheduledDate.present) {
      map['rescheduled_date'] = Variable<String>(rescheduledDate.value);
    }
    if (rescheduledTimeMinutes.present) {
      map['rescheduled_time_minutes'] = Variable<int>(
        rescheduledTimeMinutes.value,
      );
    }
    if (updatedAtUtcMillis.present) {
      map['updated_at_utc_millis'] = Variable<int>(updatedAtUtcMillis.value);
    }
    if (deletedAtUtcMillis.present) {
      map['deleted_at_utc_millis'] = Variable<int>(deletedAtUtcMillis.value);
    }
    if (mutationId.present) {
      map['mutation_id'] = Variable<String>(mutationId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineOccurrenceLogsCompanion(')
          ..write('userId: $userId, ')
          ..write('routineId: $routineId, ')
          ..write('occurrenceDate: $occurrenceDate, ')
          ..write('status: $status, ')
          ..write('completedAtUtcMillis: $completedAtUtcMillis, ')
          ..write('snoozedUntilUtcMillis: $snoozedUntilUtcMillis, ')
          ..write('rescheduledDate: $rescheduledDate, ')
          ..write('rescheduledTimeMinutes: $rescheduledTimeMinutes, ')
          ..write('updatedAtUtcMillis: $updatedAtUtcMillis, ')
          ..write('deletedAtUtcMillis: $deletedAtUtcMillis, ')
          ..write('mutationId: $mutationId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OneOffTasksTable extends OneOffTasks
    with TableInfo<$OneOffTasksTable, OneOffTaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OneOffTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _scheduledDateMeta = const VerificationMeta(
    'scheduledDate',
  );
  @override
  late final GeneratedColumn<String> scheduledDate = GeneratedColumn<String>(
    'scheduled_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledTimeMinutesMeta =
      const VerificationMeta('scheduledTimeMinutes');
  @override
  late final GeneratedColumn<int> scheduledTimeMinutes = GeneratedColumn<int>(
    'scheduled_time_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderEnabledMeta = const VerificationMeta(
    'reminderEnabled',
  );
  @override
  late final GeneratedColumn<bool> reminderEnabled = GeneratedColumn<bool>(
    'reminder_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminder_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtUtcMillisMeta =
      const VerificationMeta('completedAtUtcMillis');
  @override
  late final GeneratedColumn<int> completedAtUtcMillis = GeneratedColumn<int>(
    'completed_at_utc_millis',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snoozedUntilUtcMillisMeta =
      const VerificationMeta('snoozedUntilUtcMillis');
  @override
  late final GeneratedColumn<int> snoozedUntilUtcMillis = GeneratedColumn<int>(
    'snoozed_until_utc_millis',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtUtcMillisMeta =
      const VerificationMeta('updatedAtUtcMillis');
  @override
  late final GeneratedColumn<int> updatedAtUtcMillis = GeneratedColumn<int>(
    'updated_at_utc_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtUtcMillisMeta =
      const VerificationMeta('deletedAtUtcMillis');
  @override
  late final GeneratedColumn<int> deletedAtUtcMillis = GeneratedColumn<int>(
    'deleted_at_utc_millis',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mutationIdMeta = const VerificationMeta(
    'mutationId',
  );
  @override
  late final GeneratedColumn<String> mutationId = GeneratedColumn<String>(
    'mutation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    id,
    title,
    notes,
    scheduledDate,
    scheduledTimeMinutes,
    reminderEnabled,
    status,
    completedAtUtcMillis,
    snoozedUntilUtcMillis,
    updatedAtUtcMillis,
    deletedAtUtcMillis,
    mutationId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'one_off_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<OneOffTaskRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('scheduled_date')) {
      context.handle(
        _scheduledDateMeta,
        scheduledDate.isAcceptableOrUnknown(
          data['scheduled_date']!,
          _scheduledDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledDateMeta);
    }
    if (data.containsKey('scheduled_time_minutes')) {
      context.handle(
        _scheduledTimeMinutesMeta,
        scheduledTimeMinutes.isAcceptableOrUnknown(
          data['scheduled_time_minutes']!,
          _scheduledTimeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('reminder_enabled')) {
      context.handle(
        _reminderEnabledMeta,
        reminderEnabled.isAcceptableOrUnknown(
          data['reminder_enabled']!,
          _reminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('completed_at_utc_millis')) {
      context.handle(
        _completedAtUtcMillisMeta,
        completedAtUtcMillis.isAcceptableOrUnknown(
          data['completed_at_utc_millis']!,
          _completedAtUtcMillisMeta,
        ),
      );
    }
    if (data.containsKey('snoozed_until_utc_millis')) {
      context.handle(
        _snoozedUntilUtcMillisMeta,
        snoozedUntilUtcMillis.isAcceptableOrUnknown(
          data['snoozed_until_utc_millis']!,
          _snoozedUntilUtcMillisMeta,
        ),
      );
    }
    if (data.containsKey('updated_at_utc_millis')) {
      context.handle(
        _updatedAtUtcMillisMeta,
        updatedAtUtcMillis.isAcceptableOrUnknown(
          data['updated_at_utc_millis']!,
          _updatedAtUtcMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMillisMeta);
    }
    if (data.containsKey('deleted_at_utc_millis')) {
      context.handle(
        _deletedAtUtcMillisMeta,
        deletedAtUtcMillis.isAcceptableOrUnknown(
          data['deleted_at_utc_millis']!,
          _deletedAtUtcMillisMeta,
        ),
      );
    }
    if (data.containsKey('mutation_id')) {
      context.handle(
        _mutationIdMeta,
        mutationId.isAcceptableOrUnknown(data['mutation_id']!, _mutationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mutationIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  OneOffTaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OneOffTaskRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      scheduledDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scheduled_date'],
      )!,
      scheduledTimeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scheduled_time_minutes'],
      ),
      reminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminder_enabled'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      completedAtUtcMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at_utc_millis'],
      ),
      snoozedUntilUtcMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snoozed_until_utc_millis'],
      ),
      updatedAtUtcMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc_millis'],
      )!,
      deletedAtUtcMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_utc_millis'],
      ),
      mutationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mutation_id'],
      )!,
    );
  }

  @override
  $OneOffTasksTable createAlias(String alias) {
    return $OneOffTasksTable(attachedDatabase, alias);
  }
}

class OneOffTaskRow extends DataClass implements Insertable<OneOffTaskRow> {
  final String userId;
  final String id;
  final String title;
  final String? notes;
  final String scheduledDate;
  final int? scheduledTimeMinutes;
  final bool reminderEnabled;
  final String status;
  final int? completedAtUtcMillis;
  final int? snoozedUntilUtcMillis;
  final int updatedAtUtcMillis;
  final int? deletedAtUtcMillis;
  final String mutationId;
  const OneOffTaskRow({
    required this.userId,
    required this.id,
    required this.title,
    this.notes,
    required this.scheduledDate,
    this.scheduledTimeMinutes,
    required this.reminderEnabled,
    required this.status,
    this.completedAtUtcMillis,
    this.snoozedUntilUtcMillis,
    required this.updatedAtUtcMillis,
    this.deletedAtUtcMillis,
    required this.mutationId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['scheduled_date'] = Variable<String>(scheduledDate);
    if (!nullToAbsent || scheduledTimeMinutes != null) {
      map['scheduled_time_minutes'] = Variable<int>(scheduledTimeMinutes);
    }
    map['reminder_enabled'] = Variable<bool>(reminderEnabled);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || completedAtUtcMillis != null) {
      map['completed_at_utc_millis'] = Variable<int>(completedAtUtcMillis);
    }
    if (!nullToAbsent || snoozedUntilUtcMillis != null) {
      map['snoozed_until_utc_millis'] = Variable<int>(snoozedUntilUtcMillis);
    }
    map['updated_at_utc_millis'] = Variable<int>(updatedAtUtcMillis);
    if (!nullToAbsent || deletedAtUtcMillis != null) {
      map['deleted_at_utc_millis'] = Variable<int>(deletedAtUtcMillis);
    }
    map['mutation_id'] = Variable<String>(mutationId);
    return map;
  }

  OneOffTasksCompanion toCompanion(bool nullToAbsent) {
    return OneOffTasksCompanion(
      userId: Value(userId),
      id: Value(id),
      title: Value(title),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      scheduledDate: Value(scheduledDate),
      scheduledTimeMinutes: scheduledTimeMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledTimeMinutes),
      reminderEnabled: Value(reminderEnabled),
      status: Value(status),
      completedAtUtcMillis: completedAtUtcMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAtUtcMillis),
      snoozedUntilUtcMillis: snoozedUntilUtcMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozedUntilUtcMillis),
      updatedAtUtcMillis: Value(updatedAtUtcMillis),
      deletedAtUtcMillis: deletedAtUtcMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtUtcMillis),
      mutationId: Value(mutationId),
    );
  }

  factory OneOffTaskRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OneOffTaskRow(
      userId: serializer.fromJson<String>(json['userId']),
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String?>(json['notes']),
      scheduledDate: serializer.fromJson<String>(json['scheduledDate']),
      scheduledTimeMinutes: serializer.fromJson<int?>(
        json['scheduledTimeMinutes'],
      ),
      reminderEnabled: serializer.fromJson<bool>(json['reminderEnabled']),
      status: serializer.fromJson<String>(json['status']),
      completedAtUtcMillis: serializer.fromJson<int?>(
        json['completedAtUtcMillis'],
      ),
      snoozedUntilUtcMillis: serializer.fromJson<int?>(
        json['snoozedUntilUtcMillis'],
      ),
      updatedAtUtcMillis: serializer.fromJson<int>(json['updatedAtUtcMillis']),
      deletedAtUtcMillis: serializer.fromJson<int?>(json['deletedAtUtcMillis']),
      mutationId: serializer.fromJson<String>(json['mutationId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String?>(notes),
      'scheduledDate': serializer.toJson<String>(scheduledDate),
      'scheduledTimeMinutes': serializer.toJson<int?>(scheduledTimeMinutes),
      'reminderEnabled': serializer.toJson<bool>(reminderEnabled),
      'status': serializer.toJson<String>(status),
      'completedAtUtcMillis': serializer.toJson<int?>(completedAtUtcMillis),
      'snoozedUntilUtcMillis': serializer.toJson<int?>(snoozedUntilUtcMillis),
      'updatedAtUtcMillis': serializer.toJson<int>(updatedAtUtcMillis),
      'deletedAtUtcMillis': serializer.toJson<int?>(deletedAtUtcMillis),
      'mutationId': serializer.toJson<String>(mutationId),
    };
  }

  OneOffTaskRow copyWith({
    String? userId,
    String? id,
    String? title,
    Value<String?> notes = const Value.absent(),
    String? scheduledDate,
    Value<int?> scheduledTimeMinutes = const Value.absent(),
    bool? reminderEnabled,
    String? status,
    Value<int?> completedAtUtcMillis = const Value.absent(),
    Value<int?> snoozedUntilUtcMillis = const Value.absent(),
    int? updatedAtUtcMillis,
    Value<int?> deletedAtUtcMillis = const Value.absent(),
    String? mutationId,
  }) => OneOffTaskRow(
    userId: userId ?? this.userId,
    id: id ?? this.id,
    title: title ?? this.title,
    notes: notes.present ? notes.value : this.notes,
    scheduledDate: scheduledDate ?? this.scheduledDate,
    scheduledTimeMinutes: scheduledTimeMinutes.present
        ? scheduledTimeMinutes.value
        : this.scheduledTimeMinutes,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    status: status ?? this.status,
    completedAtUtcMillis: completedAtUtcMillis.present
        ? completedAtUtcMillis.value
        : this.completedAtUtcMillis,
    snoozedUntilUtcMillis: snoozedUntilUtcMillis.present
        ? snoozedUntilUtcMillis.value
        : this.snoozedUntilUtcMillis,
    updatedAtUtcMillis: updatedAtUtcMillis ?? this.updatedAtUtcMillis,
    deletedAtUtcMillis: deletedAtUtcMillis.present
        ? deletedAtUtcMillis.value
        : this.deletedAtUtcMillis,
    mutationId: mutationId ?? this.mutationId,
  );
  OneOffTaskRow copyWithCompanion(OneOffTasksCompanion data) {
    return OneOffTaskRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      scheduledDate: data.scheduledDate.present
          ? data.scheduledDate.value
          : this.scheduledDate,
      scheduledTimeMinutes: data.scheduledTimeMinutes.present
          ? data.scheduledTimeMinutes.value
          : this.scheduledTimeMinutes,
      reminderEnabled: data.reminderEnabled.present
          ? data.reminderEnabled.value
          : this.reminderEnabled,
      status: data.status.present ? data.status.value : this.status,
      completedAtUtcMillis: data.completedAtUtcMillis.present
          ? data.completedAtUtcMillis.value
          : this.completedAtUtcMillis,
      snoozedUntilUtcMillis: data.snoozedUntilUtcMillis.present
          ? data.snoozedUntilUtcMillis.value
          : this.snoozedUntilUtcMillis,
      updatedAtUtcMillis: data.updatedAtUtcMillis.present
          ? data.updatedAtUtcMillis.value
          : this.updatedAtUtcMillis,
      deletedAtUtcMillis: data.deletedAtUtcMillis.present
          ? data.deletedAtUtcMillis.value
          : this.deletedAtUtcMillis,
      mutationId: data.mutationId.present
          ? data.mutationId.value
          : this.mutationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OneOffTaskRow(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('scheduledTimeMinutes: $scheduledTimeMinutes, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('status: $status, ')
          ..write('completedAtUtcMillis: $completedAtUtcMillis, ')
          ..write('snoozedUntilUtcMillis: $snoozedUntilUtcMillis, ')
          ..write('updatedAtUtcMillis: $updatedAtUtcMillis, ')
          ..write('deletedAtUtcMillis: $deletedAtUtcMillis, ')
          ..write('mutationId: $mutationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    id,
    title,
    notes,
    scheduledDate,
    scheduledTimeMinutes,
    reminderEnabled,
    status,
    completedAtUtcMillis,
    snoozedUntilUtcMillis,
    updatedAtUtcMillis,
    deletedAtUtcMillis,
    mutationId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OneOffTaskRow &&
          other.userId == this.userId &&
          other.id == this.id &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.scheduledDate == this.scheduledDate &&
          other.scheduledTimeMinutes == this.scheduledTimeMinutes &&
          other.reminderEnabled == this.reminderEnabled &&
          other.status == this.status &&
          other.completedAtUtcMillis == this.completedAtUtcMillis &&
          other.snoozedUntilUtcMillis == this.snoozedUntilUtcMillis &&
          other.updatedAtUtcMillis == this.updatedAtUtcMillis &&
          other.deletedAtUtcMillis == this.deletedAtUtcMillis &&
          other.mutationId == this.mutationId);
}

class OneOffTasksCompanion extends UpdateCompanion<OneOffTaskRow> {
  final Value<String> userId;
  final Value<String> id;
  final Value<String> title;
  final Value<String?> notes;
  final Value<String> scheduledDate;
  final Value<int?> scheduledTimeMinutes;
  final Value<bool> reminderEnabled;
  final Value<String> status;
  final Value<int?> completedAtUtcMillis;
  final Value<int?> snoozedUntilUtcMillis;
  final Value<int> updatedAtUtcMillis;
  final Value<int?> deletedAtUtcMillis;
  final Value<String> mutationId;
  final Value<int> rowid;
  const OneOffTasksCompanion({
    this.userId = const Value.absent(),
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.scheduledDate = const Value.absent(),
    this.scheduledTimeMinutes = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.status = const Value.absent(),
    this.completedAtUtcMillis = const Value.absent(),
    this.snoozedUntilUtcMillis = const Value.absent(),
    this.updatedAtUtcMillis = const Value.absent(),
    this.deletedAtUtcMillis = const Value.absent(),
    this.mutationId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OneOffTasksCompanion.insert({
    required String userId,
    required String id,
    required String title,
    this.notes = const Value.absent(),
    required String scheduledDate,
    this.scheduledTimeMinutes = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    required String status,
    this.completedAtUtcMillis = const Value.absent(),
    this.snoozedUntilUtcMillis = const Value.absent(),
    required int updatedAtUtcMillis,
    this.deletedAtUtcMillis = const Value.absent(),
    required String mutationId,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       id = Value(id),
       title = Value(title),
       scheduledDate = Value(scheduledDate),
       status = Value(status),
       updatedAtUtcMillis = Value(updatedAtUtcMillis),
       mutationId = Value(mutationId);
  static Insertable<OneOffTaskRow> custom({
    Expression<String>? userId,
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<String>? scheduledDate,
    Expression<int>? scheduledTimeMinutes,
    Expression<bool>? reminderEnabled,
    Expression<String>? status,
    Expression<int>? completedAtUtcMillis,
    Expression<int>? snoozedUntilUtcMillis,
    Expression<int>? updatedAtUtcMillis,
    Expression<int>? deletedAtUtcMillis,
    Expression<String>? mutationId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (scheduledDate != null) 'scheduled_date': scheduledDate,
      if (scheduledTimeMinutes != null)
        'scheduled_time_minutes': scheduledTimeMinutes,
      if (reminderEnabled != null) 'reminder_enabled': reminderEnabled,
      if (status != null) 'status': status,
      if (completedAtUtcMillis != null)
        'completed_at_utc_millis': completedAtUtcMillis,
      if (snoozedUntilUtcMillis != null)
        'snoozed_until_utc_millis': snoozedUntilUtcMillis,
      if (updatedAtUtcMillis != null)
        'updated_at_utc_millis': updatedAtUtcMillis,
      if (deletedAtUtcMillis != null)
        'deleted_at_utc_millis': deletedAtUtcMillis,
      if (mutationId != null) 'mutation_id': mutationId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OneOffTasksCompanion copyWith({
    Value<String>? userId,
    Value<String>? id,
    Value<String>? title,
    Value<String?>? notes,
    Value<String>? scheduledDate,
    Value<int?>? scheduledTimeMinutes,
    Value<bool>? reminderEnabled,
    Value<String>? status,
    Value<int?>? completedAtUtcMillis,
    Value<int?>? snoozedUntilUtcMillis,
    Value<int>? updatedAtUtcMillis,
    Value<int?>? deletedAtUtcMillis,
    Value<String>? mutationId,
    Value<int>? rowid,
  }) {
    return OneOffTasksCompanion(
      userId: userId ?? this.userId,
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTimeMinutes: scheduledTimeMinutes ?? this.scheduledTimeMinutes,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      status: status ?? this.status,
      completedAtUtcMillis: completedAtUtcMillis ?? this.completedAtUtcMillis,
      snoozedUntilUtcMillis:
          snoozedUntilUtcMillis ?? this.snoozedUntilUtcMillis,
      updatedAtUtcMillis: updatedAtUtcMillis ?? this.updatedAtUtcMillis,
      deletedAtUtcMillis: deletedAtUtcMillis ?? this.deletedAtUtcMillis,
      mutationId: mutationId ?? this.mutationId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (scheduledDate.present) {
      map['scheduled_date'] = Variable<String>(scheduledDate.value);
    }
    if (scheduledTimeMinutes.present) {
      map['scheduled_time_minutes'] = Variable<int>(scheduledTimeMinutes.value);
    }
    if (reminderEnabled.present) {
      map['reminder_enabled'] = Variable<bool>(reminderEnabled.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (completedAtUtcMillis.present) {
      map['completed_at_utc_millis'] = Variable<int>(
        completedAtUtcMillis.value,
      );
    }
    if (snoozedUntilUtcMillis.present) {
      map['snoozed_until_utc_millis'] = Variable<int>(
        snoozedUntilUtcMillis.value,
      );
    }
    if (updatedAtUtcMillis.present) {
      map['updated_at_utc_millis'] = Variable<int>(updatedAtUtcMillis.value);
    }
    if (deletedAtUtcMillis.present) {
      map['deleted_at_utc_millis'] = Variable<int>(deletedAtUtcMillis.value);
    }
    if (mutationId.present) {
      map['mutation_id'] = Variable<String>(mutationId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OneOffTasksCompanion(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('scheduledTimeMinutes: $scheduledTimeMinutes, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('status: $status, ')
          ..write('completedAtUtcMillis: $completedAtUtcMillis, ')
          ..write('snoozedUntilUtcMillis: $snoozedUntilUtcMillis, ')
          ..write('updatedAtUtcMillis: $updatedAtUtcMillis, ')
          ..write('deletedAtUtcMillis: $deletedAtUtcMillis, ')
          ..write('mutationId: $mutationId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTable extends SyncCursors
    with TableInfo<$SyncCursorsTable, SyncCursorRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectionNameMeta = const VerificationMeta(
    'collectionName',
  );
  @override
  late final GeneratedColumn<String> collectionName = GeneratedColumn<String>(
    'collection_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUpdatedAtUtcMillisMeta =
      const VerificationMeta('lastUpdatedAtUtcMillis');
  @override
  late final GeneratedColumn<int> lastUpdatedAtUtcMillis = GeneratedColumn<int>(
    'last_updated_at_utc_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastMutationIdMeta = const VerificationMeta(
    'lastMutationId',
  );
  @override
  late final GeneratedColumn<String> lastMutationId = GeneratedColumn<String>(
    'last_mutation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    collectionName,
    lastUpdatedAtUtcMillis,
    lastMutationId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncCursorRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('collection_name')) {
      context.handle(
        _collectionNameMeta,
        collectionName.isAcceptableOrUnknown(
          data['collection_name']!,
          _collectionNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionNameMeta);
    }
    if (data.containsKey('last_updated_at_utc_millis')) {
      context.handle(
        _lastUpdatedAtUtcMillisMeta,
        lastUpdatedAtUtcMillis.isAcceptableOrUnknown(
          data['last_updated_at_utc_millis']!,
          _lastUpdatedAtUtcMillisMeta,
        ),
      );
    }
    if (data.containsKey('last_mutation_id')) {
      context.handle(
        _lastMutationIdMeta,
        lastMutationId.isAcceptableOrUnknown(
          data['last_mutation_id']!,
          _lastMutationIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, collectionName};
  @override
  SyncCursorRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursorRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      collectionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_name'],
      )!,
      lastUpdatedAtUtcMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_updated_at_utc_millis'],
      )!,
      lastMutationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_mutation_id'],
      )!,
    );
  }

  @override
  $SyncCursorsTable createAlias(String alias) {
    return $SyncCursorsTable(attachedDatabase, alias);
  }
}

class SyncCursorRow extends DataClass implements Insertable<SyncCursorRow> {
  final String userId;
  final String collectionName;
  final int lastUpdatedAtUtcMillis;
  final String lastMutationId;
  const SyncCursorRow({
    required this.userId,
    required this.collectionName,
    required this.lastUpdatedAtUtcMillis,
    required this.lastMutationId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['collection_name'] = Variable<String>(collectionName);
    map['last_updated_at_utc_millis'] = Variable<int>(lastUpdatedAtUtcMillis);
    map['last_mutation_id'] = Variable<String>(lastMutationId);
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(
      userId: Value(userId),
      collectionName: Value(collectionName),
      lastUpdatedAtUtcMillis: Value(lastUpdatedAtUtcMillis),
      lastMutationId: Value(lastMutationId),
    );
  }

  factory SyncCursorRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursorRow(
      userId: serializer.fromJson<String>(json['userId']),
      collectionName: serializer.fromJson<String>(json['collectionName']),
      lastUpdatedAtUtcMillis: serializer.fromJson<int>(
        json['lastUpdatedAtUtcMillis'],
      ),
      lastMutationId: serializer.fromJson<String>(json['lastMutationId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'collectionName': serializer.toJson<String>(collectionName),
      'lastUpdatedAtUtcMillis': serializer.toJson<int>(lastUpdatedAtUtcMillis),
      'lastMutationId': serializer.toJson<String>(lastMutationId),
    };
  }

  SyncCursorRow copyWith({
    String? userId,
    String? collectionName,
    int? lastUpdatedAtUtcMillis,
    String? lastMutationId,
  }) => SyncCursorRow(
    userId: userId ?? this.userId,
    collectionName: collectionName ?? this.collectionName,
    lastUpdatedAtUtcMillis:
        lastUpdatedAtUtcMillis ?? this.lastUpdatedAtUtcMillis,
    lastMutationId: lastMutationId ?? this.lastMutationId,
  );
  SyncCursorRow copyWithCompanion(SyncCursorsCompanion data) {
    return SyncCursorRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      collectionName: data.collectionName.present
          ? data.collectionName.value
          : this.collectionName,
      lastUpdatedAtUtcMillis: data.lastUpdatedAtUtcMillis.present
          ? data.lastUpdatedAtUtcMillis.value
          : this.lastUpdatedAtUtcMillis,
      lastMutationId: data.lastMutationId.present
          ? data.lastMutationId.value
          : this.lastMutationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorRow(')
          ..write('userId: $userId, ')
          ..write('collectionName: $collectionName, ')
          ..write('lastUpdatedAtUtcMillis: $lastUpdatedAtUtcMillis, ')
          ..write('lastMutationId: $lastMutationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    collectionName,
    lastUpdatedAtUtcMillis,
    lastMutationId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursorRow &&
          other.userId == this.userId &&
          other.collectionName == this.collectionName &&
          other.lastUpdatedAtUtcMillis == this.lastUpdatedAtUtcMillis &&
          other.lastMutationId == this.lastMutationId);
}

class SyncCursorsCompanion extends UpdateCompanion<SyncCursorRow> {
  final Value<String> userId;
  final Value<String> collectionName;
  final Value<int> lastUpdatedAtUtcMillis;
  final Value<String> lastMutationId;
  final Value<int> rowid;
  const SyncCursorsCompanion({
    this.userId = const Value.absent(),
    this.collectionName = const Value.absent(),
    this.lastUpdatedAtUtcMillis = const Value.absent(),
    this.lastMutationId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsCompanion.insert({
    required String userId,
    required String collectionName,
    this.lastUpdatedAtUtcMillis = const Value.absent(),
    this.lastMutationId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       collectionName = Value(collectionName);
  static Insertable<SyncCursorRow> custom({
    Expression<String>? userId,
    Expression<String>? collectionName,
    Expression<int>? lastUpdatedAtUtcMillis,
    Expression<String>? lastMutationId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (collectionName != null) 'collection_name': collectionName,
      if (lastUpdatedAtUtcMillis != null)
        'last_updated_at_utc_millis': lastUpdatedAtUtcMillis,
      if (lastMutationId != null) 'last_mutation_id': lastMutationId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsCompanion copyWith({
    Value<String>? userId,
    Value<String>? collectionName,
    Value<int>? lastUpdatedAtUtcMillis,
    Value<String>? lastMutationId,
    Value<int>? rowid,
  }) {
    return SyncCursorsCompanion(
      userId: userId ?? this.userId,
      collectionName: collectionName ?? this.collectionName,
      lastUpdatedAtUtcMillis:
          lastUpdatedAtUtcMillis ?? this.lastUpdatedAtUtcMillis,
      lastMutationId: lastMutationId ?? this.lastMutationId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (collectionName.present) {
      map['collection_name'] = Variable<String>(collectionName.value);
    }
    if (lastUpdatedAtUtcMillis.present) {
      map['last_updated_at_utc_millis'] = Variable<int>(
        lastUpdatedAtUtcMillis.value,
      );
    }
    if (lastMutationId.present) {
      map['last_mutation_id'] = Variable<String>(lastMutationId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('userId: $userId, ')
          ..write('collectionName: $collectionName, ')
          ..write('lastUpdatedAtUtcMillis: $lastUpdatedAtUtcMillis, ')
          ..write('lastMutationId: $lastMutationId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxEntriesTable extends SyncOutboxEntries
    with TableInfo<$SyncOutboxEntriesTable, SyncOutboxEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectionNameMeta = const VerificationMeta(
    'collectionName',
  );
  @override
  late final GeneratedColumn<String> collectionName = GeneratedColumn<String>(
    'collection_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMillisMeta =
      const VerificationMeta('updatedAtUtcMillis');
  @override
  late final GeneratedColumn<int> updatedAtUtcMillis = GeneratedColumn<int>(
    'updated_at_utc_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mutationIdMeta = const VerificationMeta(
    'mutationId',
  );
  @override
  late final GeneratedColumn<String> mutationId = GeneratedColumn<String>(
    'mutation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    collectionName,
    recordId,
    updatedAtUtcMillis,
    mutationId,
    payload,
    retryCount,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOutboxEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('collection_name')) {
      context.handle(
        _collectionNameMeta,
        collectionName.isAcceptableOrUnknown(
          data['collection_name']!,
          _collectionNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionNameMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('updated_at_utc_millis')) {
      context.handle(
        _updatedAtUtcMillisMeta,
        updatedAtUtcMillis.isAcceptableOrUnknown(
          data['updated_at_utc_millis']!,
          _updatedAtUtcMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMillisMeta);
    }
    if (data.containsKey('mutation_id')) {
      context.handle(
        _mutationIdMeta,
        mutationId.isAcceptableOrUnknown(data['mutation_id']!, _mutationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mutationIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncOutboxEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      collectionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_name'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      updatedAtUtcMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc_millis'],
      )!,
      mutationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mutation_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $SyncOutboxEntriesTable createAlias(String alias) {
    return $SyncOutboxEntriesTable(attachedDatabase, alias);
  }
}

class SyncOutboxEntryRow extends DataClass
    implements Insertable<SyncOutboxEntryRow> {
  final String id;
  final String userId;
  final String collectionName;
  final String recordId;
  final int updatedAtUtcMillis;
  final String mutationId;
  final String payload;
  final int retryCount;
  final String? lastError;
  const SyncOutboxEntryRow({
    required this.id,
    required this.userId,
    required this.collectionName,
    required this.recordId,
    required this.updatedAtUtcMillis,
    required this.mutationId,
    required this.payload,
    required this.retryCount,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['collection_name'] = Variable<String>(collectionName);
    map['record_id'] = Variable<String>(recordId);
    map['updated_at_utc_millis'] = Variable<int>(updatedAtUtcMillis);
    map['mutation_id'] = Variable<String>(mutationId);
    map['payload'] = Variable<String>(payload);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncOutboxEntriesCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxEntriesCompanion(
      id: Value(id),
      userId: Value(userId),
      collectionName: Value(collectionName),
      recordId: Value(recordId),
      updatedAtUtcMillis: Value(updatedAtUtcMillis),
      mutationId: Value(mutationId),
      payload: Value(payload),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncOutboxEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxEntryRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      collectionName: serializer.fromJson<String>(json['collectionName']),
      recordId: serializer.fromJson<String>(json['recordId']),
      updatedAtUtcMillis: serializer.fromJson<int>(json['updatedAtUtcMillis']),
      mutationId: serializer.fromJson<String>(json['mutationId']),
      payload: serializer.fromJson<String>(json['payload']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'collectionName': serializer.toJson<String>(collectionName),
      'recordId': serializer.toJson<String>(recordId),
      'updatedAtUtcMillis': serializer.toJson<int>(updatedAtUtcMillis),
      'mutationId': serializer.toJson<String>(mutationId),
      'payload': serializer.toJson<String>(payload),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncOutboxEntryRow copyWith({
    String? id,
    String? userId,
    String? collectionName,
    String? recordId,
    int? updatedAtUtcMillis,
    String? mutationId,
    String? payload,
    int? retryCount,
    Value<String?> lastError = const Value.absent(),
  }) => SyncOutboxEntryRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    collectionName: collectionName ?? this.collectionName,
    recordId: recordId ?? this.recordId,
    updatedAtUtcMillis: updatedAtUtcMillis ?? this.updatedAtUtcMillis,
    mutationId: mutationId ?? this.mutationId,
    payload: payload ?? this.payload,
    retryCount: retryCount ?? this.retryCount,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  SyncOutboxEntryRow copyWithCompanion(SyncOutboxEntriesCompanion data) {
    return SyncOutboxEntryRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      collectionName: data.collectionName.present
          ? data.collectionName.value
          : this.collectionName,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      updatedAtUtcMillis: data.updatedAtUtcMillis.present
          ? data.updatedAtUtcMillis.value
          : this.updatedAtUtcMillis,
      mutationId: data.mutationId.present
          ? data.mutationId.value
          : this.mutationId,
      payload: data.payload.present ? data.payload.value : this.payload,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxEntryRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('collectionName: $collectionName, ')
          ..write('recordId: $recordId, ')
          ..write('updatedAtUtcMillis: $updatedAtUtcMillis, ')
          ..write('mutationId: $mutationId, ')
          ..write('payload: $payload, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    collectionName,
    recordId,
    updatedAtUtcMillis,
    mutationId,
    payload,
    retryCount,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxEntryRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.collectionName == this.collectionName &&
          other.recordId == this.recordId &&
          other.updatedAtUtcMillis == this.updatedAtUtcMillis &&
          other.mutationId == this.mutationId &&
          other.payload == this.payload &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError);
}

class SyncOutboxEntriesCompanion extends UpdateCompanion<SyncOutboxEntryRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> collectionName;
  final Value<String> recordId;
  final Value<int> updatedAtUtcMillis;
  final Value<String> mutationId;
  final Value<String> payload;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<int> rowid;
  const SyncOutboxEntriesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.collectionName = const Value.absent(),
    this.recordId = const Value.absent(),
    this.updatedAtUtcMillis = const Value.absent(),
    this.mutationId = const Value.absent(),
    this.payload = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOutboxEntriesCompanion.insert({
    required String id,
    required String userId,
    required String collectionName,
    required String recordId,
    required int updatedAtUtcMillis,
    required String mutationId,
    required String payload,
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       collectionName = Value(collectionName),
       recordId = Value(recordId),
       updatedAtUtcMillis = Value(updatedAtUtcMillis),
       mutationId = Value(mutationId),
       payload = Value(payload);
  static Insertable<SyncOutboxEntryRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? collectionName,
    Expression<String>? recordId,
    Expression<int>? updatedAtUtcMillis,
    Expression<String>? mutationId,
    Expression<String>? payload,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (collectionName != null) 'collection_name': collectionName,
      if (recordId != null) 'record_id': recordId,
      if (updatedAtUtcMillis != null)
        'updated_at_utc_millis': updatedAtUtcMillis,
      if (mutationId != null) 'mutation_id': mutationId,
      if (payload != null) 'payload': payload,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOutboxEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? collectionName,
    Value<String>? recordId,
    Value<int>? updatedAtUtcMillis,
    Value<String>? mutationId,
    Value<String>? payload,
    Value<int>? retryCount,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return SyncOutboxEntriesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      collectionName: collectionName ?? this.collectionName,
      recordId: recordId ?? this.recordId,
      updatedAtUtcMillis: updatedAtUtcMillis ?? this.updatedAtUtcMillis,
      mutationId: mutationId ?? this.mutationId,
      payload: payload ?? this.payload,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (collectionName.present) {
      map['collection_name'] = Variable<String>(collectionName.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (updatedAtUtcMillis.present) {
      map['updated_at_utc_millis'] = Variable<int>(updatedAtUtcMillis.value);
    }
    if (mutationId.present) {
      map['mutation_id'] = Variable<String>(mutationId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxEntriesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('collectionName: $collectionName, ')
          ..write('recordId: $recordId, ')
          ..write('updatedAtUtcMillis: $updatedAtUtcMillis, ')
          ..write('mutationId: $mutationId, ')
          ..write('payload: $payload, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CalendarDisplaySettingsTableTable calendarDisplaySettingsTable =
      $CalendarDisplaySettingsTableTable(this);
  late final $RoutineTemplatesTable routineTemplates = $RoutineTemplatesTable(
    this,
  );
  late final $RoutineOccurrenceLogsTable routineOccurrenceLogs =
      $RoutineOccurrenceLogsTable(this);
  late final $OneOffTasksTable oneOffTasks = $OneOffTasksTable(this);
  late final $SyncCursorsTable syncCursors = $SyncCursorsTable(this);
  late final $SyncOutboxEntriesTable syncOutboxEntries =
      $SyncOutboxEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    calendarDisplaySettingsTable,
    routineTemplates,
    routineOccurrenceLogs,
    oneOffTasks,
    syncCursors,
    syncOutboxEntries,
  ];
}

typedef $$CalendarDisplaySettingsTableTableCreateCompanionBuilder =
    CalendarDisplaySettingsTableCompanion Function({
      required String userId,
      required int startHour,
      required int endHour,
      required int updatedAtUtcMillis,
      required String mutationId,
      Value<int> rowid,
    });
typedef $$CalendarDisplaySettingsTableTableUpdateCompanionBuilder =
    CalendarDisplaySettingsTableCompanion Function({
      Value<String> userId,
      Value<int> startHour,
      Value<int> endHour,
      Value<int> updatedAtUtcMillis,
      Value<String> mutationId,
      Value<int> rowid,
    });

class $$CalendarDisplaySettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $CalendarDisplaySettingsTableTable> {
  $$CalendarDisplaySettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startHour => $composableBuilder(
    column: $table.startHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endHour => $composableBuilder(
    column: $table.endHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtcMillis => $composableBuilder(
    column: $table.updatedAtUtcMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CalendarDisplaySettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CalendarDisplaySettingsTableTable> {
  $$CalendarDisplaySettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startHour => $composableBuilder(
    column: $table.startHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endHour => $composableBuilder(
    column: $table.endHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtcMillis => $composableBuilder(
    column: $table.updatedAtUtcMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CalendarDisplaySettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CalendarDisplaySettingsTableTable> {
  $$CalendarDisplaySettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get startHour =>
      $composableBuilder(column: $table.startHour, builder: (column) => column);

  GeneratedColumn<int> get endHour =>
      $composableBuilder(column: $table.endHour, builder: (column) => column);

  GeneratedColumn<int> get updatedAtUtcMillis => $composableBuilder(
    column: $table.updatedAtUtcMillis,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => column,
  );
}

class $$CalendarDisplaySettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CalendarDisplaySettingsTableTable,
          CalendarDisplaySettingsRow,
          $$CalendarDisplaySettingsTableTableFilterComposer,
          $$CalendarDisplaySettingsTableTableOrderingComposer,
          $$CalendarDisplaySettingsTableTableAnnotationComposer,
          $$CalendarDisplaySettingsTableTableCreateCompanionBuilder,
          $$CalendarDisplaySettingsTableTableUpdateCompanionBuilder,
          (
            CalendarDisplaySettingsRow,
            BaseReferences<
              _$AppDatabase,
              $CalendarDisplaySettingsTableTable,
              CalendarDisplaySettingsRow
            >,
          ),
          CalendarDisplaySettingsRow,
          PrefetchHooks Function()
        > {
  $$CalendarDisplaySettingsTableTableTableManager(
    _$AppDatabase db,
    $CalendarDisplaySettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalendarDisplaySettingsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CalendarDisplaySettingsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CalendarDisplaySettingsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<int> startHour = const Value.absent(),
                Value<int> endHour = const Value.absent(),
                Value<int> updatedAtUtcMillis = const Value.absent(),
                Value<String> mutationId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarDisplaySettingsTableCompanion(
                userId: userId,
                startHour: startHour,
                endHour: endHour,
                updatedAtUtcMillis: updatedAtUtcMillis,
                mutationId: mutationId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required int startHour,
                required int endHour,
                required int updatedAtUtcMillis,
                required String mutationId,
                Value<int> rowid = const Value.absent(),
              }) => CalendarDisplaySettingsTableCompanion.insert(
                userId: userId,
                startHour: startHour,
                endHour: endHour,
                updatedAtUtcMillis: updatedAtUtcMillis,
                mutationId: mutationId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $CalendarDisplaySettingsTableTable,
                    CalendarDisplaySettingsRow
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CalendarDisplaySettingsTableTable,
                    CalendarDisplaySettingsRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CalendarDisplaySettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CalendarDisplaySettingsTableTable,
      CalendarDisplaySettingsRow,
      $$CalendarDisplaySettingsTableTableFilterComposer,
      $$CalendarDisplaySettingsTableTableOrderingComposer,
      $$CalendarDisplaySettingsTableTableAnnotationComposer,
      $$CalendarDisplaySettingsTableTableCreateCompanionBuilder,
      $$CalendarDisplaySettingsTableTableUpdateCompanionBuilder,
      (
        CalendarDisplaySettingsRow,
        BaseReferences<
          _$AppDatabase,
          $CalendarDisplaySettingsTableTable,
          CalendarDisplaySettingsRow
        >,
      ),
      CalendarDisplaySettingsRow,
      PrefetchHooks Function()
    >;
typedef $$RoutineTemplatesTableCreateCompanionBuilder =
    RoutineTemplatesCompanion Function({
      required String userId,
      required String id,
      required String title,
      Value<String?> notes,
      required String startDate,
      Value<String?> endDate,
      required int targetTimeMinutes,
      required String recurrenceKind,
      Value<int> weekdaysMask,
      Value<int?> intervalDays,
      Value<bool> reminderEnabled,
      Value<bool> isEnabled,
      required int updatedAtUtcMillis,
      Value<int?> deletedAtUtcMillis,
      required String mutationId,
      Value<int> rowid,
    });
typedef $$RoutineTemplatesTableUpdateCompanionBuilder =
    RoutineTemplatesCompanion Function({
      Value<String> userId,
      Value<String> id,
      Value<String> title,
      Value<String?> notes,
      Value<String> startDate,
      Value<String?> endDate,
      Value<int> targetTimeMinutes,
      Value<String> recurrenceKind,
      Value<int> weekdaysMask,
      Value<int?> intervalDays,
      Value<bool> reminderEnabled,
      Value<bool> isEnabled,
      Value<int> updatedAtUtcMillis,
      Value<int?> deletedAtUtcMillis,
      Value<String> mutationId,
      Value<int> rowid,
    });

class $$RoutineTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $RoutineTemplatesTable> {
  $$RoutineTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetTimeMinutes => $composableBuilder(
    column: $table.targetTimeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceKind => $composableBuilder(
    column: $table.recurrenceKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekdaysMask => $composableBuilder(
    column: $table.weekdaysMask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtcMillis => $composableBuilder(
    column: $table.updatedAtUtcMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtUtcMillis => $composableBuilder(
    column: $table.deletedAtUtcMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RoutineTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutineTemplatesTable> {
  $$RoutineTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetTimeMinutes => $composableBuilder(
    column: $table.targetTimeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceKind => $composableBuilder(
    column: $table.recurrenceKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekdaysMask => $composableBuilder(
    column: $table.weekdaysMask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtcMillis => $composableBuilder(
    column: $table.updatedAtUtcMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtUtcMillis => $composableBuilder(
    column: $table.deletedAtUtcMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoutineTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutineTemplatesTable> {
  $$RoutineTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<int> get targetTimeMinutes => $composableBuilder(
    column: $table.targetTimeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurrenceKind => $composableBuilder(
    column: $table.recurrenceKind,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weekdaysMask => $composableBuilder(
    column: $table.weekdaysMask,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<int> get updatedAtUtcMillis => $composableBuilder(
    column: $table.updatedAtUtcMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtUtcMillis => $composableBuilder(
    column: $table.deletedAtUtcMillis,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => column,
  );
}

class $$RoutineTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutineTemplatesTable,
          RoutineTemplateRow,
          $$RoutineTemplatesTableFilterComposer,
          $$RoutineTemplatesTableOrderingComposer,
          $$RoutineTemplatesTableAnnotationComposer,
          $$RoutineTemplatesTableCreateCompanionBuilder,
          $$RoutineTemplatesTableUpdateCompanionBuilder,
          (
            RoutineTemplateRow,
            BaseReferences<
              _$AppDatabase,
              $RoutineTemplatesTable,
              RoutineTemplateRow
            >,
          ),
          RoutineTemplateRow,
          PrefetchHooks Function()
        > {
  $$RoutineTemplatesTableTableManager(
    _$AppDatabase db,
    $RoutineTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> startDate = const Value.absent(),
                Value<String?> endDate = const Value.absent(),
                Value<int> targetTimeMinutes = const Value.absent(),
                Value<String> recurrenceKind = const Value.absent(),
                Value<int> weekdaysMask = const Value.absent(),
                Value<int?> intervalDays = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<int> updatedAtUtcMillis = const Value.absent(),
                Value<int?> deletedAtUtcMillis = const Value.absent(),
                Value<String> mutationId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineTemplatesCompanion(
                userId: userId,
                id: id,
                title: title,
                notes: notes,
                startDate: startDate,
                endDate: endDate,
                targetTimeMinutes: targetTimeMinutes,
                recurrenceKind: recurrenceKind,
                weekdaysMask: weekdaysMask,
                intervalDays: intervalDays,
                reminderEnabled: reminderEnabled,
                isEnabled: isEnabled,
                updatedAtUtcMillis: updatedAtUtcMillis,
                deletedAtUtcMillis: deletedAtUtcMillis,
                mutationId: mutationId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String id,
                required String title,
                Value<String?> notes = const Value.absent(),
                required String startDate,
                Value<String?> endDate = const Value.absent(),
                required int targetTimeMinutes,
                required String recurrenceKind,
                Value<int> weekdaysMask = const Value.absent(),
                Value<int?> intervalDays = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                required int updatedAtUtcMillis,
                Value<int?> deletedAtUtcMillis = const Value.absent(),
                required String mutationId,
                Value<int> rowid = const Value.absent(),
              }) => RoutineTemplatesCompanion.insert(
                userId: userId,
                id: id,
                title: title,
                notes: notes,
                startDate: startDate,
                endDate: endDate,
                targetTimeMinutes: targetTimeMinutes,
                recurrenceKind: recurrenceKind,
                weekdaysMask: weekdaysMask,
                intervalDays: intervalDays,
                reminderEnabled: reminderEnabled,
                isEnabled: isEnabled,
                updatedAtUtcMillis: updatedAtUtcMillis,
                deletedAtUtcMillis: deletedAtUtcMillis,
                mutationId: mutationId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoutineTemplatesTable, RoutineTemplateRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $RoutineTemplatesTable,
                    RoutineTemplateRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RoutineTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutineTemplatesTable,
      RoutineTemplateRow,
      $$RoutineTemplatesTableFilterComposer,
      $$RoutineTemplatesTableOrderingComposer,
      $$RoutineTemplatesTableAnnotationComposer,
      $$RoutineTemplatesTableCreateCompanionBuilder,
      $$RoutineTemplatesTableUpdateCompanionBuilder,
      (
        RoutineTemplateRow,
        BaseReferences<
          _$AppDatabase,
          $RoutineTemplatesTable,
          RoutineTemplateRow
        >,
      ),
      RoutineTemplateRow,
      PrefetchHooks Function()
    >;
typedef $$RoutineOccurrenceLogsTableCreateCompanionBuilder =
    RoutineOccurrenceLogsCompanion Function({
      required String userId,
      required String routineId,
      required String occurrenceDate,
      required String status,
      Value<int?> completedAtUtcMillis,
      Value<int?> snoozedUntilUtcMillis,
      Value<String?> rescheduledDate,
      Value<int?> rescheduledTimeMinutes,
      required int updatedAtUtcMillis,
      Value<int?> deletedAtUtcMillis,
      required String mutationId,
      Value<int> rowid,
    });
typedef $$RoutineOccurrenceLogsTableUpdateCompanionBuilder =
    RoutineOccurrenceLogsCompanion Function({
      Value<String> userId,
      Value<String> routineId,
      Value<String> occurrenceDate,
      Value<String> status,
      Value<int?> completedAtUtcMillis,
      Value<int?> snoozedUntilUtcMillis,
      Value<String?> rescheduledDate,
      Value<int?> rescheduledTimeMinutes,
      Value<int> updatedAtUtcMillis,
      Value<int?> deletedAtUtcMillis,
      Value<String> mutationId,
      Value<int> rowid,
    });

class $$RoutineOccurrenceLogsTableFilterComposer
    extends Composer<_$AppDatabase, $RoutineOccurrenceLogsTable> {
  $$RoutineOccurrenceLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routineId => $composableBuilder(
    column: $table.routineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occurrenceDate => $composableBuilder(
    column: $table.occurrenceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAtUtcMillis => $composableBuilder(
    column: $table.completedAtUtcMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snoozedUntilUtcMillis => $composableBuilder(
    column: $table.snoozedUntilUtcMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rescheduledDate => $composableBuilder(
    column: $table.rescheduledDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rescheduledTimeMinutes => $composableBuilder(
    column: $table.rescheduledTimeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtcMillis => $composableBuilder(
    column: $table.updatedAtUtcMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtUtcMillis => $composableBuilder(
    column: $table.deletedAtUtcMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RoutineOccurrenceLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutineOccurrenceLogsTable> {
  $$RoutineOccurrenceLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routineId => $composableBuilder(
    column: $table.routineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occurrenceDate => $composableBuilder(
    column: $table.occurrenceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAtUtcMillis => $composableBuilder(
    column: $table.completedAtUtcMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snoozedUntilUtcMillis => $composableBuilder(
    column: $table.snoozedUntilUtcMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rescheduledDate => $composableBuilder(
    column: $table.rescheduledDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rescheduledTimeMinutes => $composableBuilder(
    column: $table.rescheduledTimeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtcMillis => $composableBuilder(
    column: $table.updatedAtUtcMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtUtcMillis => $composableBuilder(
    column: $table.deletedAtUtcMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoutineOccurrenceLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutineOccurrenceLogsTable> {
  $$RoutineOccurrenceLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get routineId =>
      $composableBuilder(column: $table.routineId, builder: (column) => column);

  GeneratedColumn<String> get occurrenceDate => $composableBuilder(
    column: $table.occurrenceDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get completedAtUtcMillis => $composableBuilder(
    column: $table.completedAtUtcMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get snoozedUntilUtcMillis => $composableBuilder(
    column: $table.snoozedUntilUtcMillis,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rescheduledDate => $composableBuilder(
    column: $table.rescheduledDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rescheduledTimeMinutes => $composableBuilder(
    column: $table.rescheduledTimeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtcMillis => $composableBuilder(
    column: $table.updatedAtUtcMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtUtcMillis => $composableBuilder(
    column: $table.deletedAtUtcMillis,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => column,
  );
}

class $$RoutineOccurrenceLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutineOccurrenceLogsTable,
          RoutineOccurrenceLogRow,
          $$RoutineOccurrenceLogsTableFilterComposer,
          $$RoutineOccurrenceLogsTableOrderingComposer,
          $$RoutineOccurrenceLogsTableAnnotationComposer,
          $$RoutineOccurrenceLogsTableCreateCompanionBuilder,
          $$RoutineOccurrenceLogsTableUpdateCompanionBuilder,
          (
            RoutineOccurrenceLogRow,
            BaseReferences<
              _$AppDatabase,
              $RoutineOccurrenceLogsTable,
              RoutineOccurrenceLogRow
            >,
          ),
          RoutineOccurrenceLogRow,
          PrefetchHooks Function()
        > {
  $$RoutineOccurrenceLogsTableTableManager(
    _$AppDatabase db,
    $RoutineOccurrenceLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineOccurrenceLogsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RoutineOccurrenceLogsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RoutineOccurrenceLogsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> routineId = const Value.absent(),
                Value<String> occurrenceDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> completedAtUtcMillis = const Value.absent(),
                Value<int?> snoozedUntilUtcMillis = const Value.absent(),
                Value<String?> rescheduledDate = const Value.absent(),
                Value<int?> rescheduledTimeMinutes = const Value.absent(),
                Value<int> updatedAtUtcMillis = const Value.absent(),
                Value<int?> deletedAtUtcMillis = const Value.absent(),
                Value<String> mutationId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineOccurrenceLogsCompanion(
                userId: userId,
                routineId: routineId,
                occurrenceDate: occurrenceDate,
                status: status,
                completedAtUtcMillis: completedAtUtcMillis,
                snoozedUntilUtcMillis: snoozedUntilUtcMillis,
                rescheduledDate: rescheduledDate,
                rescheduledTimeMinutes: rescheduledTimeMinutes,
                updatedAtUtcMillis: updatedAtUtcMillis,
                deletedAtUtcMillis: deletedAtUtcMillis,
                mutationId: mutationId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String routineId,
                required String occurrenceDate,
                required String status,
                Value<int?> completedAtUtcMillis = const Value.absent(),
                Value<int?> snoozedUntilUtcMillis = const Value.absent(),
                Value<String?> rescheduledDate = const Value.absent(),
                Value<int?> rescheduledTimeMinutes = const Value.absent(),
                required int updatedAtUtcMillis,
                Value<int?> deletedAtUtcMillis = const Value.absent(),
                required String mutationId,
                Value<int> rowid = const Value.absent(),
              }) => RoutineOccurrenceLogsCompanion.insert(
                userId: userId,
                routineId: routineId,
                occurrenceDate: occurrenceDate,
                status: status,
                completedAtUtcMillis: completedAtUtcMillis,
                snoozedUntilUtcMillis: snoozedUntilUtcMillis,
                rescheduledDate: rescheduledDate,
                rescheduledTimeMinutes: rescheduledTimeMinutes,
                updatedAtUtcMillis: updatedAtUtcMillis,
                deletedAtUtcMillis: deletedAtUtcMillis,
                mutationId: mutationId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $RoutineOccurrenceLogsTable,
                    RoutineOccurrenceLogRow
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RoutineOccurrenceLogsTable,
                    RoutineOccurrenceLogRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RoutineOccurrenceLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutineOccurrenceLogsTable,
      RoutineOccurrenceLogRow,
      $$RoutineOccurrenceLogsTableFilterComposer,
      $$RoutineOccurrenceLogsTableOrderingComposer,
      $$RoutineOccurrenceLogsTableAnnotationComposer,
      $$RoutineOccurrenceLogsTableCreateCompanionBuilder,
      $$RoutineOccurrenceLogsTableUpdateCompanionBuilder,
      (
        RoutineOccurrenceLogRow,
        BaseReferences<
          _$AppDatabase,
          $RoutineOccurrenceLogsTable,
          RoutineOccurrenceLogRow
        >,
      ),
      RoutineOccurrenceLogRow,
      PrefetchHooks Function()
    >;
typedef $$OneOffTasksTableCreateCompanionBuilder =
    OneOffTasksCompanion Function({
      required String userId,
      required String id,
      required String title,
      Value<String?> notes,
      required String scheduledDate,
      Value<int?> scheduledTimeMinutes,
      Value<bool> reminderEnabled,
      required String status,
      Value<int?> completedAtUtcMillis,
      Value<int?> snoozedUntilUtcMillis,
      required int updatedAtUtcMillis,
      Value<int?> deletedAtUtcMillis,
      required String mutationId,
      Value<int> rowid,
    });
typedef $$OneOffTasksTableUpdateCompanionBuilder =
    OneOffTasksCompanion Function({
      Value<String> userId,
      Value<String> id,
      Value<String> title,
      Value<String?> notes,
      Value<String> scheduledDate,
      Value<int?> scheduledTimeMinutes,
      Value<bool> reminderEnabled,
      Value<String> status,
      Value<int?> completedAtUtcMillis,
      Value<int?> snoozedUntilUtcMillis,
      Value<int> updatedAtUtcMillis,
      Value<int?> deletedAtUtcMillis,
      Value<String> mutationId,
      Value<int> rowid,
    });

class $$OneOffTasksTableFilterComposer
    extends Composer<_$AppDatabase, $OneOffTasksTable> {
  $$OneOffTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scheduledTimeMinutes => $composableBuilder(
    column: $table.scheduledTimeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAtUtcMillis => $composableBuilder(
    column: $table.completedAtUtcMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snoozedUntilUtcMillis => $composableBuilder(
    column: $table.snoozedUntilUtcMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtcMillis => $composableBuilder(
    column: $table.updatedAtUtcMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtUtcMillis => $composableBuilder(
    column: $table.deletedAtUtcMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OneOffTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $OneOffTasksTable> {
  $$OneOffTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduledTimeMinutes => $composableBuilder(
    column: $table.scheduledTimeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAtUtcMillis => $composableBuilder(
    column: $table.completedAtUtcMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snoozedUntilUtcMillis => $composableBuilder(
    column: $table.snoozedUntilUtcMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtcMillis => $composableBuilder(
    column: $table.updatedAtUtcMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtUtcMillis => $composableBuilder(
    column: $table.deletedAtUtcMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OneOffTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $OneOffTasksTable> {
  $$OneOffTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scheduledTimeMinutes => $composableBuilder(
    column: $table.scheduledTimeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get completedAtUtcMillis => $composableBuilder(
    column: $table.completedAtUtcMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get snoozedUntilUtcMillis => $composableBuilder(
    column: $table.snoozedUntilUtcMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtcMillis => $composableBuilder(
    column: $table.updatedAtUtcMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtUtcMillis => $composableBuilder(
    column: $table.deletedAtUtcMillis,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => column,
  );
}

class $$OneOffTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OneOffTasksTable,
          OneOffTaskRow,
          $$OneOffTasksTableFilterComposer,
          $$OneOffTasksTableOrderingComposer,
          $$OneOffTasksTableAnnotationComposer,
          $$OneOffTasksTableCreateCompanionBuilder,
          $$OneOffTasksTableUpdateCompanionBuilder,
          (
            OneOffTaskRow,
            BaseReferences<_$AppDatabase, $OneOffTasksTable, OneOffTaskRow>,
          ),
          OneOffTaskRow,
          PrefetchHooks Function()
        > {
  $$OneOffTasksTableTableManager(_$AppDatabase db, $OneOffTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OneOffTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OneOffTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OneOffTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> scheduledDate = const Value.absent(),
                Value<int?> scheduledTimeMinutes = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> completedAtUtcMillis = const Value.absent(),
                Value<int?> snoozedUntilUtcMillis = const Value.absent(),
                Value<int> updatedAtUtcMillis = const Value.absent(),
                Value<int?> deletedAtUtcMillis = const Value.absent(),
                Value<String> mutationId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OneOffTasksCompanion(
                userId: userId,
                id: id,
                title: title,
                notes: notes,
                scheduledDate: scheduledDate,
                scheduledTimeMinutes: scheduledTimeMinutes,
                reminderEnabled: reminderEnabled,
                status: status,
                completedAtUtcMillis: completedAtUtcMillis,
                snoozedUntilUtcMillis: snoozedUntilUtcMillis,
                updatedAtUtcMillis: updatedAtUtcMillis,
                deletedAtUtcMillis: deletedAtUtcMillis,
                mutationId: mutationId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String id,
                required String title,
                Value<String?> notes = const Value.absent(),
                required String scheduledDate,
                Value<int?> scheduledTimeMinutes = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                required String status,
                Value<int?> completedAtUtcMillis = const Value.absent(),
                Value<int?> snoozedUntilUtcMillis = const Value.absent(),
                required int updatedAtUtcMillis,
                Value<int?> deletedAtUtcMillis = const Value.absent(),
                required String mutationId,
                Value<int> rowid = const Value.absent(),
              }) => OneOffTasksCompanion.insert(
                userId: userId,
                id: id,
                title: title,
                notes: notes,
                scheduledDate: scheduledDate,
                scheduledTimeMinutes: scheduledTimeMinutes,
                reminderEnabled: reminderEnabled,
                status: status,
                completedAtUtcMillis: completedAtUtcMillis,
                snoozedUntilUtcMillis: snoozedUntilUtcMillis,
                updatedAtUtcMillis: updatedAtUtcMillis,
                deletedAtUtcMillis: deletedAtUtcMillis,
                mutationId: mutationId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OneOffTasksTable, OneOffTaskRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $OneOffTasksTable,
                    OneOffTaskRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OneOffTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OneOffTasksTable,
      OneOffTaskRow,
      $$OneOffTasksTableFilterComposer,
      $$OneOffTasksTableOrderingComposer,
      $$OneOffTasksTableAnnotationComposer,
      $$OneOffTasksTableCreateCompanionBuilder,
      $$OneOffTasksTableUpdateCompanionBuilder,
      (
        OneOffTaskRow,
        BaseReferences<_$AppDatabase, $OneOffTasksTable, OneOffTaskRow>,
      ),
      OneOffTaskRow,
      PrefetchHooks Function()
    >;
typedef $$SyncCursorsTableCreateCompanionBuilder =
    SyncCursorsCompanion Function({
      required String userId,
      required String collectionName,
      Value<int> lastUpdatedAtUtcMillis,
      Value<String> lastMutationId,
      Value<int> rowid,
    });
typedef $$SyncCursorsTableUpdateCompanionBuilder =
    SyncCursorsCompanion Function({
      Value<String> userId,
      Value<String> collectionName,
      Value<int> lastUpdatedAtUtcMillis,
      Value<String> lastMutationId,
      Value<int> rowid,
    });

class $$SyncCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectionName => $composableBuilder(
    column: $table.collectionName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastUpdatedAtUtcMillis => $composableBuilder(
    column: $table.lastUpdatedAtUtcMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMutationId => $composableBuilder(
    column: $table.lastMutationId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectionName => $composableBuilder(
    column: $table.collectionName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastUpdatedAtUtcMillis => $composableBuilder(
    column: $table.lastUpdatedAtUtcMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMutationId => $composableBuilder(
    column: $table.lastMutationId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get collectionName => $composableBuilder(
    column: $table.collectionName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastUpdatedAtUtcMillis => $composableBuilder(
    column: $table.lastUpdatedAtUtcMillis,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastMutationId => $composableBuilder(
    column: $table.lastMutationId,
    builder: (column) => column,
  );
}

class $$SyncCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncCursorsTable,
          SyncCursorRow,
          $$SyncCursorsTableFilterComposer,
          $$SyncCursorsTableOrderingComposer,
          $$SyncCursorsTableAnnotationComposer,
          $$SyncCursorsTableCreateCompanionBuilder,
          $$SyncCursorsTableUpdateCompanionBuilder,
          (
            SyncCursorRow,
            BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursorRow>,
          ),
          SyncCursorRow,
          PrefetchHooks Function()
        > {
  $$SyncCursorsTableTableManager(_$AppDatabase db, $SyncCursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> collectionName = const Value.absent(),
                Value<int> lastUpdatedAtUtcMillis = const Value.absent(),
                Value<String> lastMutationId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion(
                userId: userId,
                collectionName: collectionName,
                lastUpdatedAtUtcMillis: lastUpdatedAtUtcMillis,
                lastMutationId: lastMutationId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String collectionName,
                Value<int> lastUpdatedAtUtcMillis = const Value.absent(),
                Value<String> lastMutationId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion.insert(
                userId: userId,
                collectionName: collectionName,
                lastUpdatedAtUtcMillis: lastUpdatedAtUtcMillis,
                lastMutationId: lastMutationId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncCursorsTable, SyncCursorRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncCursorsTable,
                    SyncCursorRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncCursorsTable,
      SyncCursorRow,
      $$SyncCursorsTableFilterComposer,
      $$SyncCursorsTableOrderingComposer,
      $$SyncCursorsTableAnnotationComposer,
      $$SyncCursorsTableCreateCompanionBuilder,
      $$SyncCursorsTableUpdateCompanionBuilder,
      (
        SyncCursorRow,
        BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursorRow>,
      ),
      SyncCursorRow,
      PrefetchHooks Function()
    >;
typedef $$SyncOutboxEntriesTableCreateCompanionBuilder =
    SyncOutboxEntriesCompanion Function({
      required String id,
      required String userId,
      required String collectionName,
      required String recordId,
      required int updatedAtUtcMillis,
      required String mutationId,
      required String payload,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$SyncOutboxEntriesTableUpdateCompanionBuilder =
    SyncOutboxEntriesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> collectionName,
      Value<String> recordId,
      Value<int> updatedAtUtcMillis,
      Value<String> mutationId,
      Value<String> payload,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$SyncOutboxEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxEntriesTable> {
  $$SyncOutboxEntriesTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectionName => $composableBuilder(
    column: $table.collectionName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtcMillis => $composableBuilder(
    column: $table.updatedAtUtcMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOutboxEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxEntriesTable> {
  $$SyncOutboxEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectionName => $composableBuilder(
    column: $table.collectionName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtcMillis => $composableBuilder(
    column: $table.updatedAtUtcMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOutboxEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxEntriesTable> {
  $$SyncOutboxEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get collectionName => $composableBuilder(
    column: $table.collectionName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<int> get updatedAtUtcMillis => $composableBuilder(
    column: $table.updatedAtUtcMillis,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncOutboxEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncOutboxEntriesTable,
          SyncOutboxEntryRow,
          $$SyncOutboxEntriesTableFilterComposer,
          $$SyncOutboxEntriesTableOrderingComposer,
          $$SyncOutboxEntriesTableAnnotationComposer,
          $$SyncOutboxEntriesTableCreateCompanionBuilder,
          $$SyncOutboxEntriesTableUpdateCompanionBuilder,
          (
            SyncOutboxEntryRow,
            BaseReferences<
              _$AppDatabase,
              $SyncOutboxEntriesTable,
              SyncOutboxEntryRow
            >,
          ),
          SyncOutboxEntryRow,
          PrefetchHooks Function()
        > {
  $$SyncOutboxEntriesTableTableManager(
    _$AppDatabase db,
    $SyncOutboxEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> collectionName = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<int> updatedAtUtcMillis = const Value.absent(),
                Value<String> mutationId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxEntriesCompanion(
                id: id,
                userId: userId,
                collectionName: collectionName,
                recordId: recordId,
                updatedAtUtcMillis: updatedAtUtcMillis,
                mutationId: mutationId,
                payload: payload,
                retryCount: retryCount,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String collectionName,
                required String recordId,
                required int updatedAtUtcMillis,
                required String mutationId,
                required String payload,
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxEntriesCompanion.insert(
                id: id,
                userId: userId,
                collectionName: collectionName,
                recordId: recordId,
                updatedAtUtcMillis: updatedAtUtcMillis,
                mutationId: mutationId,
                payload: payload,
                retryCount: retryCount,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncOutboxEntriesTable, SyncOutboxEntryRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncOutboxEntriesTable,
                    SyncOutboxEntryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOutboxEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncOutboxEntriesTable,
      SyncOutboxEntryRow,
      $$SyncOutboxEntriesTableFilterComposer,
      $$SyncOutboxEntriesTableOrderingComposer,
      $$SyncOutboxEntriesTableAnnotationComposer,
      $$SyncOutboxEntriesTableCreateCompanionBuilder,
      $$SyncOutboxEntriesTableUpdateCompanionBuilder,
      (
        SyncOutboxEntryRow,
        BaseReferences<
          _$AppDatabase,
          $SyncOutboxEntriesTable,
          SyncOutboxEntryRow
        >,
      ),
      SyncOutboxEntryRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CalendarDisplaySettingsTableTableTableManager
  get calendarDisplaySettingsTable =>
      $$CalendarDisplaySettingsTableTableTableManager(
        _db,
        _db.calendarDisplaySettingsTable,
      );
  $$RoutineTemplatesTableTableManager get routineTemplates =>
      $$RoutineTemplatesTableTableManager(_db, _db.routineTemplates);
  $$RoutineOccurrenceLogsTableTableManager get routineOccurrenceLogs =>
      $$RoutineOccurrenceLogsTableTableManager(_db, _db.routineOccurrenceLogs);
  $$OneOffTasksTableTableManager get oneOffTasks =>
      $$OneOffTasksTableTableManager(_db, _db.oneOffTasks);
  $$SyncCursorsTableTableManager get syncCursors =>
      $$SyncCursorsTableTableManager(_db, _db.syncCursors);
  $$SyncOutboxEntriesTableTableManager get syncOutboxEntries =>
      $$SyncOutboxEntriesTableTableManager(_db, _db.syncOutboxEntries);
}
