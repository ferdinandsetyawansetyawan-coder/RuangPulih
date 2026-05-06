import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/login.dart';

void main() {
  testWidgets('smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RuangPulihApp());
  });
}