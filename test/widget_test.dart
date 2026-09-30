import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawon_mobile/main.dart';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  testWidgets('PawonTaniApp renders home screen smoke test', (WidgetTester tester) async {
    // Avoid network image load failure by overriding HttpClient or testing home screen
    await tester.pumpWidget(const PawonTaniApp());
    expect(find.text('Pak Joko 👋'), findsOneWidget);
    expect(find.text('Ringkasan Pertanian'), findsOneWidget);
    expect(find.text('Aksi Cepat'), findsOneWidget);
  });
}
