import 'package:cadence_tasks/core/domain/failure.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/core/domain/task_status.dart';
import 'package:cadence_tasks/data/local/drift/app_database.dart';
import 'package:cadence_tasks/data/local/drift/drift_record_mappers.dart';
import 'package:cadence_tasks/data/local/drift/outbox_writer.dart';
import 'package:cadence_tasks/features/routines/domain/routine_occurrence_state.dart';
import 'package:cadence_tasks/features/routines/domain/routine_template.dart';
import 'package:cadence_tasks/features/tasks/domain/one_off_task.dart';
import 'package:cadence_tasks/features/tasks/domain/task_type_conversion_repository.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

final class DriftTaskTypeConversionRepository
    implements TaskTypeConversionRepository {
  DriftTaskTypeConversionRepository(
    this._database, {
    required this.userId,
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
  Future<Result<Unit>> convertOneOffTaskToRoutine({
    required OneOffTask source,
    required RoutineTemplate target,
  }) {
    if (source.id != target.id) {
      return Future<Result<Unit>>.value(
        const FailureResult<Unit>(
          ValidationFailure('A conversion must preserve the task ID.'),
        ),
      );
    }

    return _database.transaction(() async {
      final sourceRow =
          await (_database.select(_database.oneOffTasks)..where(
                (row) =>
                    row.userId.equals(userId) &
                    row.id.equals(source.id) &
                    row.deletedAtUtcMillis.isNull(),
              ))
              .getSingleOrNull();
      if (sourceRow == null) {
        return FailureResult<Unit>(
          NotFoundFailure('Task ${source.id} was not found.'),
        );
      }
      final activeRoutine =
          await (_database.select(_database.routineTemplates)..where(
                (row) =>
                    row.userId.equals(userId) &
                    row.id.equals(target.id) &
                    row.deletedAtUtcMillis.isNull(),
              ))
              .getSingleOrNull();
      if (activeRoutine != null) {
        return FailureResult<Unit>(
          ConflictFailure('A routine with ID ${target.id} already exists.'),
        );
      }

      final updatedAtUtc = _clock().toUtc();
      final sourceMutationId = _uuid.v4();
      final targetMutationId = _uuid.v4();
      final completedTask = DriftRecordMappers.oneOffTaskFromRow(sourceRow);
      final deletedTaskPayload = DriftRecordMappers.oneOffTaskPayload(
        task: completedTask,
        userId: userId,
        updatedAtUtc: updatedAtUtc,
        mutationId: sourceMutationId,
        deletedAtUtc: updatedAtUtc,
      );
      final targetPayload = DriftRecordMappers.routinePayload(
        routine: target,
        userId: userId,
        updatedAtUtc: updatedAtUtc,
        mutationId: targetMutationId,
      );

      await (_database.update(_database.oneOffTasks)..where(
            (row) => row.userId.equals(userId) & row.id.equals(source.id),
          ))
          .write(
            OneOffTasksCompanion(
              updatedAtUtcMillis: Value<int>(
                updatedAtUtc.millisecondsSinceEpoch,
              ),
              deletedAtUtcMillis: Value<int?>(
                updatedAtUtc.millisecondsSinceEpoch,
              ),
              mutationId: Value<String>(sourceMutationId),
            ),
          );
      await _database
          .into(_database.routineTemplates)
          .insertOnConflictUpdate(
            DriftRecordMappers.routineToCompanion(
              routine: target,
              userId: userId,
              updatedAtUtc: updatedAtUtc,
              mutationId: targetMutationId,
            ),
          );
      await enqueueSyncMutation(
        _database,
        userId: userId,
        collectionName: 'oneOffTasks',
        recordId: source.id,
        updatedAtUtc: updatedAtUtc,
        mutationId: sourceMutationId,
        payload: deletedTaskPayload,
      );
      await enqueueSyncMutation(
        _database,
        userId: userId,
        collectionName: 'routineTemplates',
        recordId: target.id,
        updatedAtUtc: updatedAtUtc,
        mutationId: targetMutationId,
        payload: targetPayload,
      );

      final initialState = RoutineOccurrenceState.create(
        routineId: target.id,
        occurrenceDate: target.startDate,
        status: completedTask.status,
        completedAtUtc: completedTask.completedAtUtc,
        snoozedUntilUtc: completedTask.snoozedUntilUtc,
      );
      final state = switch (initialState) {
        Success<RoutineOccurrenceState>(:final value) => value,
        FailureResult<RoutineOccurrenceState>(:final failure) =>
          throw FormatException(failure.message),
      };
      if (state.status != TaskStatus.pending || state.snoozedUntilUtc != null) {
        final stateMutationId = _uuid.v4();
        await _database
            .into(_database.routineOccurrenceLogs)
            .insertOnConflictUpdate(
              DriftRecordMappers.occurrenceToCompanion(
                state: state,
                userId: userId,
                updatedAtUtc: updatedAtUtc,
                mutationId: stateMutationId,
              ),
            );
        await enqueueSyncMutation(
          _database,
          userId: userId,
          collectionName: 'routineOccurrenceLogs',
          recordId: '${state.routineId}:${state.occurrenceDate.iso8601}',
          updatedAtUtc: updatedAtUtc,
          mutationId: stateMutationId,
          payload: DriftRecordMappers.occurrencePayload(
            state: state,
            userId: userId,
            updatedAtUtc: updatedAtUtc,
            mutationId: stateMutationId,
          ),
        );
      }

      return const Success<Unit>(Unit.value);
    });
  }

  @override
  Future<Result<Unit>> convertRoutineToOneOffTask({
    required RoutineTemplate source,
    required OneOffTask target,
  }) {
    if (source.id != target.id) {
      return Future<Result<Unit>>.value(
        const FailureResult<Unit>(
          ValidationFailure('A conversion must preserve the routine ID.'),
        ),
      );
    }

    return _database.transaction(() async {
      final sourceRow =
          await (_database.select(_database.routineTemplates)..where(
                (row) =>
                    row.userId.equals(userId) &
                    row.id.equals(source.id) &
                    row.deletedAtUtcMillis.isNull(),
              ))
              .getSingleOrNull();
      if (sourceRow == null) {
        return FailureResult<Unit>(
          NotFoundFailure('Routine ${source.id} was not found.'),
        );
      }
      final activeTask =
          await (_database.select(_database.oneOffTasks)..where(
                (row) =>
                    row.userId.equals(userId) &
                    row.id.equals(target.id) &
                    row.deletedAtUtcMillis.isNull(),
              ))
              .getSingleOrNull();
      if (activeTask != null) {
        return FailureResult<Unit>(
          ConflictFailure('A task with ID ${target.id} already exists.'),
        );
      }

      final updatedAtUtc = _clock().toUtc();
      final sourceMutationId = _uuid.v4();
      final targetMutationId = _uuid.v4();
      final savedRoutine = DriftRecordMappers.routineFromRow(sourceRow);
      final deletedRoutinePayload = DriftRecordMappers.routinePayload(
        routine: savedRoutine,
        userId: userId,
        updatedAtUtc: updatedAtUtc,
        mutationId: sourceMutationId,
        deletedAtUtc: updatedAtUtc,
      );
      final targetPayload = DriftRecordMappers.oneOffTaskPayload(
        task: target,
        userId: userId,
        updatedAtUtc: updatedAtUtc,
        mutationId: targetMutationId,
      );

      await (_database.update(_database.routineTemplates)..where(
            (row) => row.userId.equals(userId) & row.id.equals(source.id),
          ))
          .write(
            RoutineTemplatesCompanion(
              updatedAtUtcMillis: Value<int>(
                updatedAtUtc.millisecondsSinceEpoch,
              ),
              deletedAtUtcMillis: Value<int?>(
                updatedAtUtc.millisecondsSinceEpoch,
              ),
              mutationId: Value<String>(sourceMutationId),
            ),
          );
      await _database
          .into(_database.oneOffTasks)
          .insertOnConflictUpdate(
            DriftRecordMappers.oneOffTaskToCompanion(
              task: target,
              userId: userId,
              updatedAtUtc: updatedAtUtc,
              mutationId: targetMutationId,
            ),
          );
      await enqueueSyncMutation(
        _database,
        userId: userId,
        collectionName: 'routineTemplates',
        recordId: source.id,
        updatedAtUtc: updatedAtUtc,
        mutationId: sourceMutationId,
        payload: deletedRoutinePayload,
      );
      await enqueueSyncMutation(
        _database,
        userId: userId,
        collectionName: 'oneOffTasks',
        recordId: target.id,
        updatedAtUtc: updatedAtUtc,
        mutationId: targetMutationId,
        payload: targetPayload,
      );

      return const Success<Unit>(Unit.value);
    });
  }
}
