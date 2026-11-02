import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawon_mobile/features/auth/repositories/auth_repository.dart';
import 'package:pawon_mobile/features/auth/screens/layar_login.dart';
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

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    AuthRepository.instance.resetForTesting();
  });

  testWidgets('PawonTaniApp renders login screen when unauthenticated', (WidgetTester tester) async {
    // Jalankan aplikasi utama tanpa sesi login
    await tester.pumpWidget(const PawonTaniApp());
    await tester.pumpAndSettle();

    // Verifikasi bahwa AuthGate mengarahkan ke LayarLogin saat tidak ada token
    expect(find.byType(LayarLogin), findsOneWidget);
    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.text('Masuk sebagai Anggota Kelompok Tani'), findsOneWidget);

    // Pastikan konten beranda TIDAK tampil sebelum pengguna terautentikasi
    expect(find.text('Pak Joko 👋'), findsNothing);
  });

  testWidgets('MainNavigationShell renders home screen components when loaded', (WidgetTester tester) async {
    // Pengujian komponen beranda secara terpisah (mempertahankan asersi smoke test asli)
    await tester.pumpWidget(
      const MaterialApp(
        home: MainNavigationShell(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pak Joko 👋'), findsOneWidget);
    expect(find.text('Ringkasan Pertanian'), findsOneWidget);
    expect(find.text('Aksi Cepat'), findsOneWidget);
  });
}
