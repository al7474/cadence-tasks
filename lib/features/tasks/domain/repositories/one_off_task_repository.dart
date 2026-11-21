import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/features/tasks/domain/one_off_task.dart';

abstract interface class OneOffTaskRepository {
  Future<Result<Unit>> save(OneOffTask task);

  Future<Result<List<OneOffTask>>> getScheduledFor(LocalDate date);
}
