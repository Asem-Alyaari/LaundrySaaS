import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_mobile_app/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LaundryApp());
    expect(find.byType(LaundryApp), findsOneWidget);
  });
}
