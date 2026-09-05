import 'package:flutter_test/flutter_test.dart';
import 'package:customer_mobile_app/app.dart';

void main() {
  testWidgets('CustomerApp loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CustomerApp());
    expect(find.byType(CustomerApp), findsOneWidget);
  });
}
