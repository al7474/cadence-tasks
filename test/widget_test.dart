import 'package:cadence_tasks/app/cadence_app.dart';
import 'package:cadence_tasks/app/providers.dart';
import 'package:cadence_tasks/data/local/drift/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CadenceApp displays the empty agenda', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const CadenceApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your day is clear'), findsOneWidget);
  });
}
