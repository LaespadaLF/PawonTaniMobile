import 'package:flutter_test/flutter_test.dart';
import 'package:pawon_mobile/main.dart';

void main() {
  testWidgets('PawonTaniApp renders home screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PawonTaniApp());
    expect(find.text('Pak Joko 👋'), findsOneWidget);
    expect(find.text('Ringkasan Pertanian'), findsOneWidget);
    expect(find.text('Aksi Cepat'), findsOneWidget);
  });
}

