import 'package:cadence_tasks/core/domain/failure.dart';
import 'package:cadence_tasks/core/domain/result.dart';

final class SyncVersion implements Comparable<SyncVersion> {
  const SyncVersion._({required this.updatedAtUtc, required this.mutationId});

  final DateTime updatedAtUtc;
  final String mutationId;

  static Result<SyncVersion> create({
    required DateTime updatedAtUtc,
    required String mutationId,
  }) {
    if (!updatedAtUtc.isUtc) {
      return const FailureResult<SyncVersion>(
        ValidationFailure('A sync version timestamp must be UTC.'),
      );
    }
    if (mutationId.trim().isEmpty) {
      return const FailureResult<SyncVersion>(
        ValidationFailure('A mutation ID is required for sync ordering.'),
      );
    }

    return Success<SyncVersion>(
      SyncVersion._(updatedAtUtc: updatedAtUtc, mutationId: mutationId.trim()),
    );
  }

  @override
  int compareTo(SyncVersion other) {
    final timestampComparison = updatedAtUtc.compareTo(other.updatedAtUtc);
    return timestampComparison != 0
        ? timestampComparison
        : mutationId.compareTo(other.mutationId);
  }
}
