import 'dart:convert';

import 'package:cadence_tasks/data/local/drift/app_database.dart';
import 'package:drift/drift.dart';

Future<void> enqueueSyncMutation(
  AppDatabase database, {
  required String userId,
  required String collectionName,
  required String recordId,
  required DateTime updatedAtUtc,
  required String mutationId,
  required Map<String, Object?> payload,
}) async {
  await (database.delete(database.syncOutboxEntries)..where(
        (entry) =>
            entry.userId.equals(userId) &
            entry.collectionName.equals(collectionName) &
            entry.recordId.equals(recordId),
      ))
      .go();

  await database
      .into(database.syncOutboxEntries)
      .insert(
        SyncOutboxEntriesCompanion.insert(
          id: mutationId,
          userId: userId,
          collectionName: collectionName,
          recordId: recordId,
          updatedAtUtcMillis: updatedAtUtc.millisecondsSinceEpoch,
          mutationId: mutationId,
          payload: jsonEncode(payload),
        ),
      );
}
