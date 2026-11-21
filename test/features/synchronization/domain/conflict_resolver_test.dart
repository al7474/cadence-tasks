import 'package:cadence_tasks/features/synchronization/domain/conflict_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/domain_test_factories.dart';

void main() {
  group('ConflictResolver', () {
    test('selects the version with the later update timestamp', () {
      final local = syncVersion(
        updatedAtUtc: DateTime.utc(2026, 1, 2),
        mutationId: 'local',
      );
      final remote = syncVersion(
        updatedAtUtc: DateTime.utc(2026, 1, 1),
        mutationId: 'remote',
      );

      expect(
        ConflictResolver.resolve(local: local, remote: remote),
        ConflictWinner.local,
      );
    });

    test('uses mutation ID as a deterministic timestamp tie-breaker', () {
      final local = syncVersion(
        updatedAtUtc: DateTime.utc(2026, 1, 1),
        mutationId: 'b',
      );
      final remote = syncVersion(
        updatedAtUtc: DateTime.utc(2026, 1, 1),
        mutationId: 'a',
      );

      expect(
        ConflictResolver.resolve(local: local, remote: remote),
        ConflictWinner.local,
      );
    });

    test('recognizes identical versions', () {
      final local = syncVersion(
        updatedAtUtc: DateTime.utc(2026, 1, 1),
        mutationId: 'same',
      );
      final remote = syncVersion(
        updatedAtUtc: DateTime.utc(2026, 1, 1),
        mutationId: 'same',
      );

      expect(
        ConflictResolver.resolve(local: local, remote: remote),
        ConflictWinner.sameVersion,
      );
    });
  });
}
