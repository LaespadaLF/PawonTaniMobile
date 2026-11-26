import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawon_mobile/features/auth/models/auth_user_model.dart';
import 'package:pawon_mobile/features/profile/screens/layar_profil.dart';

void main() {
  testWidgets('ProfileScreen menampilkan data lengkap pengguna, kontak, dan informasi poktan', (tester) async {
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
      kelompokTani: KelompokTaniModel(
        idKelompok: 'PKT-001',
        namaKelompok: 'Poktan Sumber Makmur',
        alamat: 'Desa Sukamaju',
        status: 'Aktif',
      ),
      anggota: AnggotaModel(
        idAnggota: 'AGT-2024-001',
        statusKeanggotaan: 'Aktif',
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileScreen(initialUser: user),
      ),
    );

    expect(find.text('Profil Petani'), findsOneWidget);
    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('@budisantoso'), findsOneWidget);
    expect(find.text('Anggota'), findsWidgets);
    expect(find.text('Aktif'), findsWidgets);
    expect(find.text('Poktan Sumber Makmur'), findsOneWidget);
    expect(find.text('081234567890'), findsOneWidget);
    expect(find.text('budi@pawontani.id'), findsOneWidget);
    expect(find.text('Dusun Krajan RT 01 RW 02'), findsOneWidget);
    expect(find.text('Ubah Data Profil'), findsOneWidget);
    expect(find.text('Keluar dari Akun'), findsOneWidget);
    expect(find.text('Hapus Akun Mandiri'), findsOneWidget);

    // Buka dialog ubah profil
    await tester.tap(find.text('Ubah Data Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Nama Lengkap *'), findsOneWidget);
    expect(find.text('Simpan Perubahan'), findsOneWidget);
  });
}
