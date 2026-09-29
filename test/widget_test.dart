import 'package:flutter_test/flutter_test.dart';
import 'package:pawon_mobile/main.dart';

void main() {
  testWidgets('PawonTaniApp renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PawonTaniApp());
    expect(find.text('Data Panen'), findsOneWidget);
    expect(find.text('Total Hasil Panen'), findsOneWidget);
  });
}
