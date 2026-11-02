import 'package:flutter_test/flutter_test.dart';
import 'package:pawon_mobile/core/network/api_response.dart';
import 'package:pawon_mobile/features/auth/models/auth_user_model.dart';

void main() {
  group('AuthUserModel & ApiResponse Unit Tests', () {
    final Map<String, dynamic> sampleLaravelJson = {
      'id': 'PGR-7219',
      'nama': 'Ali Yuski',
      'nik': '3509923151530001',
      'username': 'yuzki',
      'email': 'yuzki12@gmail.com',
      'no_telepon': '0899773523134',
      'alamat': 'Dusun Plosok Hebat Jungkrak',
      'foto_profil': null,
      'role': 'Anggota',
      'status': 'Aktif',
      'lokasi': {
        'provinsi_id': '35',
        'kabupaten_id': '3509',
        'kecamatan_id': '350901',
        'desa_id': null,
        'nama': 'Jember',
        'latitude': -8.1724,
        'longitude': 113.6995,
      },
      'kelompok_tani': {
        'id_kelompok': 'PokTan-2906',
        'nama_kelompok': 'Kelompok Tani Karya Bersama',
        'alamat': 'Desa Sukorambi, Kec. Sukorambi, Jember',
        'status': 'Aktif',
      },
      'anggota': {
        'id_anggota': 'AGT-3733',
        'status_keanggotaan': 'Aktif',
      },
    };

    test('AuthUserModel parses Laravel PenggunaResource response accurately', () {
      final user = AuthUserModel.fromJson(sampleLaravelJson);

      expect(user.id, 'PGR-7219');
      expect(user.nama, 'Ali Yuski');
      expect(user.nik, '3509923151530001');
      expect(user.username, 'yuzki');
      expect(user.email, 'yuzki12@gmail.com');
      expect(user.noTelepon, '0899773523134');
      expect(user.alamat, 'Dusun Plosok Hebat Jungkrak');
      expect(user.fotoProfil, isNull);
      expect(user.role, 'Anggota');
      expect(user.status, 'Aktif');
      expect(user.isAnggota, isTrue);
      expect(user.isAktif, isTrue);

      // Kelompok Tani
      expect(user.kelompokTani, isNotNull);
      expect(user.kelompokTani!.idKelompok, 'PokTan-2906');
      expect(user.kelompokTani!.namaKelompok, 'Kelompok Tani Karya Bersama');

      // Anggota
      expect(user.anggota, isNotNull);
      expect(user.anggota!.idAnggota, 'AGT-3733');
      expect(user.anggota!.statusKeanggotaan, 'Aktif');

      // Lokasi
      expect(user.lokasi, isNotNull);
      expect(user.lokasi!.latitude, -8.1724);
      expect(user.lokasi!.longitude, 113.6995);
    });

    test('AuthUserModel flags non-Anggota role correctly', () {
      final nonAnggotaJson = Map<String, dynamic>.from(sampleLaravelJson);
      nonAnggotaJson['role'] = 'PPL';
      final user = AuthUserModel.fromJson(nonAnggotaJson);

      expect(user.isAnggota, isFalse);
    });

    test('AuthUserModel flags inactive status correctly', () {
      final inactiveJson = Map<String, dynamic>.from(sampleLaravelJson);
      inactiveJson['status'] = 'Tidak Aktif';
      final user = AuthUserModel.fromJson(inactiveJson);

      expect(user.isAktif, isFalse);
    });

    test('ApiResponse parses generic success body correctly', () {
      final responseJson = {
        'success': true,
        'message': 'Login berhasil.',
        'data': sampleLaravelJson,
      };

      final apiResponse = ApiResponse<AuthUserModel>.fromJson(
        responseJson,
        fromJsonT: (data) => AuthUserModel.fromJson(data),
      );

      expect(apiResponse.success, isTrue);
      expect(apiResponse.message, 'Login berhasil.');
      expect(apiResponse.data, isNotNull);
      expect(apiResponse.data!.username, 'yuzki');
    });

    test('ApiResponse parses error and extracts firstErrorMessage', () {
      final errorJson = {
        'success': false,
        'message': 'Validasi gagal.',
        'errors': {
          'identifier': ['Username atau email wajib diisi.'],
          'password': ['Password wajib diisi.'],
        },
      };

      final apiResponse = ApiResponse.fromJson(errorJson);

      expect(apiResponse.success, isFalse);
      expect(apiResponse.firstErrorMessage, 'Username atau email wajib diisi.');
    });
  });
}
