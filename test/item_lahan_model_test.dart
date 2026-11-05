import 'package:flutter_test/flutter_test.dart';
import 'package:pawon_mobile/features/lahan/models/item_lahan.dart';

void main() {
  group('ItemLahan.fromJson Unit Tests', () {
    // 1. JSON lengkap
    test('1. JSON lengkap diparsing dengan benar dan akurat', () {
      final json = {
        'id': 'LHN-TEST-001',
        'nama': 'Petak Sawah Lembah',
        'lokasi': 'Dusun Krajan RT 01',
        'luas': 1.5,
        'komoditas': 'Padi Ciherang',
        'status': 'aktif',
        'latitude': -6.5621,
        'longitude': 107.7589,
        'foto_lahan': 'https://res.cloudinary.com/demo/image/upload/sample.jpg',
        'status_verifikasi': 'terverifikasi',
        'catatan_verifikasi': 'Lahan memenuhi syarat.',
        'tanggal_verifikasi': '2026-11-04T12:00:00Z',
        'detail_komoditas': {
          'id_komoditas': 'KMD-001',
          'nama_komoditas': 'Padi Ciherang',
        },
      };

      final item = ItemLahan.fromJson(json);

      expect(item.id, 'LHN-TEST-001');
      expect(item.nama, 'Petak Sawah Lembah');
      expect(item.lokasi, 'Dusun Krajan RT 01');
      expect(item.luas, 1.5);
      expect(item.komoditas, 'Padi Ciherang');
      expect(item.status, StatusLahan.aktif);
      expect(item.latitude, -6.5621);
      expect(item.longitude, 107.7589);
      expect(item.fotoLahan, 'https://res.cloudinary.com/demo/image/upload/sample.jpg');
      expect(item.statusVerifikasi, 'terverifikasi');
      expect(item.isTerverifikasi, isTrue);
      expect(item.catatanVerifikasi, 'Lahan memenuhi syarat.');
      expect(item.tanggalVerifikasi, isNotNull);
      expect(item.idKomoditas, 'KMD-001');
    });

    // 2. Komoditas null
    test('2. Komoditas bernilai null tidak menyebabkan crash dan menghasilkan string kosong', () {
      final json = {
        'id': 'LHN-002',
        'nama': 'Lahan Tanpa Komoditas',
        'lokasi': 'Desa Maju',
        'luas': 0.5,
        'komoditas': null,
        'status': 'persiapan',
      };

      final item = ItemLahan.fromJson(json);

      expect(item.komoditas, '');
      expect(item.idKomoditas, isNull);
    });

    // 3. Latitude null
    test('3. Latitude bernilai null menghasilkan null pada properti latitude', () {
      final json = {
        'id': 'LHN-003',
        'nama': 'Lahan Tanpa Titik Koordinat',
        'latitude': null,
        'longitude': 107.0,
        'status': 'aktif',
      };

      final item = ItemLahan.fromJson(json);
      expect(item.latitude, isNull);
      expect(item.longitude, 107.0);
    });

    // 4. Longitude null
    test('4. Longitude bernilai null menghasilkan null pada properti longitude', () {
      final json = {
        'id': 'LHN-004',
        'nama': 'Lahan Tanpa Bujur',
        'latitude': -6.5,
        'longitude': null,
        'status': 'aktif',
      };

      final item = ItemLahan.fromJson(json);
      expect(item.latitude, -6.5);
      expect(item.longitude, isNull);
    });

    // 5. Luas berupa int
    test('5. Luas berupa tipe int berhasil dikonversi ke double', () {
      final json = {
        'id': 'LHN-005',
        'nama': 'Lahan Luas Integer',
        'luas': 2,
        'status': 'aktif',
      };

      final item = ItemLahan.fromJson(json);
      expect(item.luas, 2.0);
    });

    // 6. Luas berupa double
    test('6. Luas berupa tipe double diparsing tanpa modifikasi', () {
      final json = {
        'id': 'LHN-006',
        'nama': 'Lahan Luas Double',
        'luas': 2.75,
        'status': 'aktif',
      };

      final item = ItemLahan.fromJson(json);
      expect(item.luas, 2.75);
    });

    // 7. Luas berupa string numerik
    test('7. Luas berupa string numerik berhasil dikonversi ke double', () {
      final json = {
        'id': 'LHN-007',
        'nama': 'Lahan Luas String',
        'luas': '0.85',
        'status': 'aktif',
      };

      final item = ItemLahan.fromJson(json);
      expect(item.luas, 0.85);
    });

    // 8. Status operasional valid (aktif, istirahat, persiapan)
    test('8. Status operasional valid dipetakan ke enum StatusLahan yang tepat', () {
      final itemAktif = ItemLahan.fromJson({'id': '1', 'status': 'aktif'});
      final itemIstirahat = ItemLahan.fromJson({'id': '2', 'status': 'istirahat'});
      final itemPersiapan = ItemLahan.fromJson({'id': '3', 'status': 'persiapan'});
      final itemUnknown = ItemLahan.fromJson({'id': '4', 'status': 'random_value'});

      expect(itemAktif.status, StatusLahan.aktif);
      expect(itemIstirahat.status, StatusLahan.istirahat);
      expect(itemPersiapan.status, StatusLahan.persiapan);
      expect(itemUnknown.status, StatusLahan.aktif); // Default fallback
    });

    // 9. Status verifikasi null
    test('9. Status verifikasi bernilai null ditangani tanpa error', () {
      final json = {
        'id': 'LHN-009',
        'nama': 'Lahan Belum Terdaftar Verifikasi',
        'status_verifikasi': null,
      };

      final item = ItemLahan.fromJson(json);
      expect(item.statusVerifikasi, isNull);
      expect(item.isTerverifikasi, isFalse);
      expect(item.isMenungguVerifikasi, isFalse);
      expect(item.isPerluPerbaikan, isFalse);
    });

    // 10. Catatan verifikasi null
    test('10. Catatan verifikasi bernilai null ditangani dengan aman', () {
      final json = {
        'id': 'LHN-010',
        'nama': 'Lahan Tanpa Catatan',
        'status_verifikasi': 'menunggu_verifikasi',
        'catatan_verifikasi': null,
      };

      final item = ItemLahan.fromJson(json);
      expect(item.statusVerifikasi, 'menunggu_verifikasi');
      expect(item.isMenungguVerifikasi, isTrue);
      expect(item.catatanVerifikasi, isNull);
    });
  });
}

