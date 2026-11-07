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

    // 11. Kelengkapan field F-04 (keterangan, musim_tanam, nomor_revisi, is_can_delete, is_can_edit)
    test('11. Field F-04 diparsing dengan tipe data dan nilai yang tepat', () {
      final json = {
        'id': 'LHN-011',
        'nama': 'Lahan Petak C',
        'luas': 1.0,
        'status': 'aktif',
        'keterangan': 'Saluran irigasi lancar dan subur.',
        'musim_tanam': 'MT-1 (Musim Hujan)',
        'nomor_revisi': 2,
        'is_can_delete': true,
        'is_can_edit': true,
      };

      final item = ItemLahan.fromJson(json);
      expect(item.keterangan, 'Saluran irigasi lancar dan subur.');
      expect(item.musimTanam, 'MT-1 (Musim Hujan)');
      expect(item.nomorRevisi, 2);
      expect(item.isCanDelete, isTrue);
      expect(item.isCanEdit, isTrue);
    });

    // 12. Riwayat verifikasi array of objects
    test('12. Riwayat verifikasi dipetakan ke List<ItemRiwayatVerifikasiLahan> dengan aman', () {
      final json = {
        'id': 'LHN-012',
        'nama': 'Lahan dengan Riwayat',
        'status': 'aktif',
        'riwayat_verifikasi': [
          {
            'id': 'RWY-001',
            'id_riwayat': 'RWY-001',
            'id_lahan': 'LHN-012',
            'aksi': 'revisi',
            'status_sebelumnya': 'menunggu_verifikasi',
            'status_sesudahnya': 'perlu_perbaikan',
            'catatan': 'Batas petak barat perlu dicek ulang.',
            'nomor_revisi': 1,
            'aktor': {
              'id_pengguna': 'USR-KETUA-01',
              'nama': 'Pak Subroto',
              'jabatan': 'Ketua',
            },
            'created_at': '2026-11-05T08:30:00Z',
          },
          {
            'id': 'RWY-002',
            'id_lahan': 'LHN-012',
            'aksi': 'verifikasi',
            'status_sebelumnya': 'perlu_perbaikan',
            'status_sesudahnya': 'terverifikasi',
            'catatan': 'Data sudah diperbaiki dan sesuai.',
            'nomor_revisi': 2,
            'aktor': {
              'nama': 'Pak Subroto',
              'jabatan': 'Ketua',
            },
            'created_at': '2026-11-06T09:15:00Z',
          }
        ],
      };

      final item = ItemLahan.fromJson(json);
      expect(item.riwayatVerifikasi.length, 2);

      final r1 = item.riwayatVerifikasi[0];
      expect(r1.id, 'RWY-001');
      expect(r1.aksi, 'revisi');
      expect(r1.statusSebelumnya, 'menunggu_verifikasi');
      expect(r1.statusSesudahnya, 'perlu_perbaikan');
      expect(r1.catatan, 'Batas petak barat perlu dicek ulang.');
      expect(r1.nomorRevisi, 1);
      expect(r1.namaAktor, 'Pak Subroto');
      expect(r1.jabatanAktor, 'Ketua');
      expect(r1.createdAt, isNotNull);

      final r2 = item.riwayatVerifikasi[1];
      expect(r2.id, 'RWY-002');
      expect(r2.aksi, 'verifikasi');
      expect(r2.statusSesudahnya, 'terverifikasi');
      expect(r2.nomorRevisi, 2);
    });

    // 13. Default values ketika field F-04 tidak ada atau null
    test('13. Field F-04 opsional bernilai null menghasilkan default yang aman', () {
      final json = {
        'id': 'LHN-013',
        'nama': 'Lahan Minimal',
      };

      final item = ItemLahan.fromJson(json);
      expect(item.keterangan, isNull);
      expect(item.musimTanam, isNull);
      expect(item.nomorRevisi, 0);
      expect(item.isCanDelete, isFalse);
      expect(item.isCanEdit, isFalse);
      expect(item.riwayatVerifikasi, isEmpty);
    });

    // 14. Serialisasi toJson() mempertahankan seluruh field
    test('14. toJson menghasilkan Map yang konsisten dengan data model', () {
      const item = ItemLahan(
        id: 'LHN-014',
        nama: 'Petak Selatan',
        lokasi: 'Dusun Selatan',
        luas: 2.5,
        komoditas: 'Jagung Hibrida',
        status: StatusLahan.aktif,
        idKomoditas: 'kmdt-0001',
        keterangan: 'Tanah gembur',
        musimTanam: 'MT-2 (Kemarau I)',
        nomorRevisi: 1,
        isCanDelete: true,
        isCanEdit: true,
      );

      final json = item.toJson();
      expect(json['id'], 'LHN-014');
      expect(json['nama'], 'Petak Selatan');
      expect(json['lokasi'], 'Dusun Selatan');
      expect(json['alamat_lahan'], 'Dusun Selatan');
      expect(json['luas'], 2.5);
      expect(json['komoditas'], 'Jagung Hibrida');
      expect(json['id_komoditas'], 'kmdt-0001');
      expect(json['keterangan'], 'Tanah gembur');
      expect(json['musim_tanam'], 'MT-2 (Kemarau I)');
      expect(json['nomor_revisi'], 1);
      expect(json['is_can_delete'], isTrue);
      expect(json['is_can_edit'], isTrue);
      expect(json['status'], 'aktif');
    });

    // 15. Fallback alamat_lahan saat lokasi null (F-02)
    test('15. Field alamat_lahan dibaca sebagai lokasi jika key lokasi tidak tersedia (F-02)', () {
      final json = {
        'id': 'LHN-015',
        'nama': 'Petak Alamat Lahan',
        'alamat_lahan': 'Dusun Krajan, RT 03/RW 02, Desa Cibogo',
      };

      final item = ItemLahan.fromJson(json);
      expect(item.lokasi, 'Dusun Krajan, RT 03/RW 02, Desa Cibogo');
    });

    // 16. Key lokasi diprioritaskan jika tersedia (F-02)
    test('16. Key lokasi diprioritaskan jika kedua key tersedia (F-02)', () {
      final json = {
        'id': 'LHN-016',
        'nama': 'Petak Dua Alamat',
        'lokasi': 'Jalan Sawah No. 5',
        'alamat_lahan': 'Alamat Sekunder',
      };

      final item = ItemLahan.fromJson(json);
      expect(item.lokasi, 'Jalan Sawah No. 5');
    });
  });
}
