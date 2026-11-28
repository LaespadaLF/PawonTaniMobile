import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawon_mobile/features/auth/models/auth_user_model.dart';
import 'package:pawon_mobile/features/profil/screens/layar_profil.dart';

void main() {
  testWidgets('LayarProfil pumps and displays profile screen elements', (tester) async {
    const user = AuthUserModel(
      id: 'USR-001',
      nama: 'Budi Santoso',
      nik: '3509123456780001',
      username: 'budisantoso',
      email: 'budi@pawontani.id',
      noTelepon: '081234567890',
      alamat: 'Dusun Krajan RT 01 RW 02',
      role: 'Anggota',
      status: 'Aktif',
    );

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: LayarProfil(initialUser: user),
      ),
    );

    await tester.pump();
    expect(find.text('Profil Petani'), findsOneWidget);
    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('@budisantoso'), findsOneWidget);
    expect(find.text('Ubah Data Profil'), findsOneWidget);
    expect(find.text('Pengaturan Tampilan'), findsOneWidget);
    expect(find.text('Kelompok Tani & Keanggotaan'), findsOneWidget);
    expect(find.text('ID Anggota'), findsNothing);
  });
}
