import 'package:cadence_tasks/app/cadence_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CadenceApp displays its title', (WidgetTester tester) async {
    await tester.pumpWidget(const CadenceApp());

    expect(find.text('Cadence Tasks'), findsOneWidget);
  });
}
