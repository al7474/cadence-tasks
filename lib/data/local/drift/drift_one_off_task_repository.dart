import 'package:cadence_tasks/core/domain/failure.dart';
import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/data/local/drift/app_database.dart';
import 'package:cadence_tasks/data/local/drift/drift_record_mappers.dart';
import 'package:cadence_tasks/data/local/drift/outbox_writer.dart';
import 'package:cadence_tasks/features/tasks/domain/one_off_task.dart';
import 'package:cadence_tasks/features/tasks/domain/repositories/one_off_task_repository.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

final class DriftOneOffTaskRepository implements OneOffTaskRepository {
  DriftOneOffTaskRepository(
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
  Future<Result<Unit>> save(OneOffTask task) async {
    final updatedAtUtc = _clock().toUtc();
    final mutationId = _uuid.v4();

    await _database.transaction(() async {
      await _database
          .into(_database.oneOffTasks)
          .insertOnConflictUpdate(
            DriftRecordMappers.oneOffTaskToCompanion(
              task: task,
              userId: userId,
              updatedAtUtc: updatedAtUtc,
              mutationId: mutationId,
            ),
          );
      await enqueueSyncMutation(
        _database,
        userId: userId,
        collectionName: 'oneOffTasks',
        recordId: task.id,
        updatedAtUtc: updatedAtUtc,
        mutationId: mutationId,
        payload: DriftRecordMappers.oneOffTaskPayload(
          task: task,
          userId: userId,
          updatedAtUtc: updatedAtUtc,
          mutationId: mutationId,
        ),
      );
    });

    return const Success<Unit>(Unit.value);
  }

  @override
  Future<Result<Unit>> delete(String taskId) async {
    final updatedAtUtc = _clock().toUtc();
    final mutationId = _uuid.v4();

    return _database.transaction(() async {
      final row =
          await (_database.select(_database.oneOffTasks)..where(
                (task) => task.userId.equals(userId) & task.id.equals(taskId),
              ))
              .getSingleOrNull();
      if (row == null || row.deletedAtUtcMillis != null) {
        return FailureResult<Unit>(
          NotFoundFailure('Task $taskId was not found.'),
        );
      }

      final task = DriftRecordMappers.oneOffTaskFromRow(row);
      await (_database.update(_database.oneOffTasks)..where(
            (savedTask) =>
                savedTask.userId.equals(userId) & savedTask.id.equals(taskId),
          ))
          .write(
            OneOffTasksCompanion(
              updatedAtUtcMillis: Value<int>(
                updatedAtUtc.millisecondsSinceEpoch,
              ),
              deletedAtUtcMillis: Value<int?>(
                updatedAtUtc.millisecondsSinceEpoch,
              ),
              mutationId: Value<String>(mutationId),
            ),
          );
      await enqueueSyncMutation(
        _database,
        userId: userId,
        collectionName: 'oneOffTasks',
        recordId: taskId,
        updatedAtUtc: updatedAtUtc,
        mutationId: mutationId,
        payload: DriftRecordMappers.oneOffTaskPayload(
          task: task,
          userId: userId,
          updatedAtUtc: updatedAtUtc,
          mutationId: mutationId,
          deletedAtUtc: updatedAtUtc,
        ),
      );

      return const Success<Unit>(Unit.value);
    });
  }

  @override
  Future<Result<List<OneOffTask>>> getScheduledFor(LocalDate date) async {
    final rows =
        await (_database.select(_database.oneOffTasks)
              ..where(
                (task) =>
                    task.userId.equals(userId) &
                    task.scheduledDate.equals(date.iso8601) &
                    task.deletedAtUtcMillis.isNull(),
              )
              ..orderBy([
                (task) => OrderingTerm.asc(task.scheduledTimeMinutes),
                (task) => OrderingTerm.asc(task.title),
              ]))
            .get();

    return Success<List<OneOffTask>>(
      rows.map(DriftRecordMappers.oneOffTaskFromRow).toList(growable: false),
    );
  }
}
