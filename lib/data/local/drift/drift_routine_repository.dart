import 'package:cadence_tasks/core/domain/failure.dart';
import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/data/local/drift/app_database.dart';
import 'package:cadence_tasks/data/local/drift/drift_record_mappers.dart';
import 'package:cadence_tasks/data/local/drift/outbox_writer.dart';
import 'package:cadence_tasks/features/routines/domain/repositories/routine_repository.dart';
import 'package:cadence_tasks/features/routines/domain/routine_occurrence_state.dart';
import 'package:cadence_tasks/features/routines/domain/routine_template.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

final class DriftRoutineRepository implements RoutineRepository {
  DriftRoutineRepository(
    this._database, {
    this.userId = 'local',
    DateTime Function()? clock,
    Uuid? uuid,
  }) : _clock = clock ?? DateTime.now,
       _uuid = uuid ?? const Uuid() {
    if (userId.trim().isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'Must not be empty.');
    }
  }

  final AppDatabase _database;
  final String userId;
  final DateTime Function() _clock;
  final Uuid _uuid;

  @override
  Future<Result<Unit>> save(RoutineTemplate routine) async {
    final updatedAtUtc = _clock().toUtc();
    final mutationId = _uuid.v4();
    final companion = DriftRecordMappers.routineToCompanion(
      routine: routine,
      userId: userId,
      updatedAtUtc: updatedAtUtc,
      mutationId: mutationId,
    );

    await _database.transaction(() async {
      await _database
          .into(_database.routineTemplates)
          .insertOnConflictUpdate(companion);
      await enqueueSyncMutation(
        _database,
        userId: userId,
        collectionName: 'routineTemplates',
        recordId: routine.id,
        updatedAtUtc: updatedAtUtc,
        mutationId: mutationId,
        payload: DriftRecordMappers.routinePayload(
          routine: routine,
          userId: userId,
          updatedAtUtc: updatedAtUtc,
          mutationId: mutationId,
        ),
      );
    });

    return const Success<Unit>(Unit.value);
  }

  @override
  Future<Result<Unit>> saveOccurrenceState(RoutineOccurrenceState state) async {
    final updatedAtUtc = _clock().toUtc();
    final mutationId = _uuid.v4();

    await _database.transaction(() async {
      await _database
          .into(_database.routineOccurrenceLogs)
          .insertOnConflictUpdate(
            DriftRecordMappers.occurrenceToCompanion(
              state: state,
              userId: userId,
              updatedAtUtc: updatedAtUtc,
              mutationId: mutationId,
            ),
          );
      await enqueueSyncMutation(
        _database,
        userId: userId,
        collectionName: 'routineOccurrenceLogs',
        recordId: _occurrenceRecordId(state),
        updatedAtUtc: updatedAtUtc,
        mutationId: mutationId,
        payload: DriftRecordMappers.occurrencePayload(
          state: state,
          userId: userId,
          updatedAtUtc: updatedAtUtc,
          mutationId: mutationId,
        ),
      );
    });

    return const Success<Unit>(Unit.value);
  }

  @override
  Future<Result<Unit>> delete(String routineId) async {
    final updatedAtUtc = _clock().toUtc();
    final mutationId = _uuid.v4();

    return _database.transaction(() async {
      final routine =
          await (_database.select(_database.routineTemplates)..where(
                (row) => row.userId.equals(userId) & row.id.equals(routineId),
              ))
              .getSingleOrNull();
      if (routine == null || routine.deletedAtUtcMillis != null) {
        return FailureResult<Unit>(
          NotFoundFailure('Routine $routineId was not found.'),
        );
      }

      final domainRoutine = DriftRecordMappers.routineFromRow(routine);
      final deletedAtUtc = updatedAtUtc;
      await (_database.update(_database.routineTemplates)..where(
            (row) => row.userId.equals(userId) & row.id.equals(routineId),
          ))
          .write(
            RoutineTemplatesCompanion(
              updatedAtUtcMillis: Value<int>(
                updatedAtUtc.millisecondsSinceEpoch,
              ),
              deletedAtUtcMillis: Value<int?>(
                deletedAtUtc.millisecondsSinceEpoch,
              ),
              mutationId: Value<String>(mutationId),
            ),
          );
      await enqueueSyncMutation(
        _database,
        userId: userId,
        collectionName: 'routineTemplates',
        recordId: routineId,
        updatedAtUtc: updatedAtUtc,
        mutationId: mutationId,
        payload: DriftRecordMappers.routinePayload(
          routine: domainRoutine,
          userId: userId,
          updatedAtUtc: updatedAtUtc,
          mutationId: mutationId,
          deletedAtUtc: deletedAtUtc,
        ),
      );

      return const Success<Unit>(Unit.value);
    });
  }

  @override
  Future<Result<List<RoutineTemplate>>> getAllRoutines() async {
    final rows =
        await (_database.select(_database.routineTemplates)
              ..where(
                (row) =>
                    row.userId.equals(userId) & row.deletedAtUtcMillis.isNull(),
              )
              ..orderBy([
                (row) => OrderingTerm.asc(row.startDate),
                (row) => OrderingTerm.asc(row.targetTimeMinutes),
              ]))
            .get();

    return Success<List<RoutineTemplate>>(
      rows.map(DriftRecordMappers.routineFromRow).toList(growable: false),
    );
  }

  @override
  Future<Result<List<RoutineTemplate>>> getEnabledRoutines() async {
    final rows =
        await (_database.select(_database.routineTemplates)..where(
              (row) =>
                  row.userId.equals(userId) &
                  row.isEnabled.equals(true) &
                  row.deletedAtUtcMillis.isNull(),
            ))
            .get();

    return Success<List<RoutineTemplate>>(
      rows.map(DriftRecordMappers.routineFromRow).toList(growable: false),
    );
  }

  @override
  Future<Result<List<RoutineOccurrenceState>>> getOccurrenceStatesAffecting(
    LocalDate date,
  ) async {
    final isoDate = date.iso8601;
    final rows =
        await (_database.select(_database.routineOccurrenceLogs)..where(
              (row) =>
                  row.userId.equals(userId) &
                  row.deletedAtUtcMillis.isNull() &
                  (row.occurrenceDate.equals(isoDate) |
                      row.rescheduledDate.equals(isoDate)),
            ))
            .get();

    return Success<List<RoutineOccurrenceState>>(
      rows.map(DriftRecordMappers.occurrenceFromRow).toList(growable: false),
    );
  }

  static String _occurrenceRecordId(RoutineOccurrenceState state) {
    return '${state.routineId}:${state.occurrenceDate.iso8601}';
  }
}
