import 'package:flutter_test/flutter_test.dart';
import 'package:bwhere_wear/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const BWhereWearApp());
    await tester.pump();
  });
}
