import 'package:cadence_tasks/features/synchronization/domain/sync_version.dart';

enum ConflictWinner { local, remote, sameVersion }

abstract final class ConflictResolver {
  static ConflictWinner resolve({
    required SyncVersion local,
    required SyncVersion remote,
  }) {
    final comparison = local.compareTo(remote);
    if (comparison > 0) {
      return ConflictWinner.local;
    }
    if (comparison < 0) {
      return ConflictWinner.remote;
    }
    return ConflictWinner.sameVersion;
  }
}
