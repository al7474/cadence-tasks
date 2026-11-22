import 'package:cadence_tasks/core/domain/result.dart';

final class SyncSummary {
  const SyncSummary({
    required this.uploaded,
    required this.downloaded,
    required this.conflictsResolved,
  });

  final int uploaded;
  final int downloaded;
  final int conflictsResolved;
}

abstract interface class SyncCoordinator {
  Future<Result<SyncSummary>> synchronize();

  Stream<Result<SyncSummary>> watchRemoteChanges();
}
