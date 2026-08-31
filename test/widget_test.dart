import 'package:flutter_test/flutter_test.dart';
import 'package:billi_billi/main.dart';

void main() {
  testWidgets('Billi Billi app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const BilliBilliApp());

    expect(find.text('Billi Billi'), findsOneWidget);
  });
}
