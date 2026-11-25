import 'package:flutter_test/flutter_test.dart';
import 'package:pawon_mobile/features/lahan/models/item_lahan.dart';
import 'package:pawon_mobile/features/lahan/models/item_siklus_tanam.dart';

void main() {
  group('ItemSiklusTanam DTO Tests', () {
    test('fromJson and toJson parse attributes accurately', () {
      final json = {
        'id_siklus': 'SKL-20261124-ABCD',
        'id_lahan': 'LHN-001',
        'id_komoditas': 'KMD-001',
        'komoditas_nama': 'Padi Sawah',
        'varietas': 'Inpari 32',
        'musim_tanam': 'MT 1 - 2026',
        'tanggal_mulai': '2026-11-24',
        'estimasi_panen': '2027-02-24',
        'tanggal_selesai': null,
        'status': 'aktif',
        'is_berjalan': true,
        'is_boleh_input': true,
        'target_panen_ton': 5.5,
        'id_kelompok': 'PKT-001',
        'kelompok': {'id_kelompok': 'PKT-001', 'nama_kelompok': 'Kelompok Tani Makmur'},
        'pencatat': {'id_pengguna': 'PGR-001', 'nama': 'Budi Santoso', 'role': 'Anggota'},
        'created_at': '2026-11-24T18:00:00Z',
      };

      final siklus = ItemSiklusTanam.fromJson(json);

      expect(siklus.idSiklus, 'SKL-20261124-ABCD');
      expect(siklus.idLahan, 'LHN-001');
      expect(siklus.komoditasNama, 'Padi Sawah');
      expect(siklus.varietas, 'Inpari 32');
      expect(siklus.musimTanam, 'MT 1 - 2026');
      expect(siklus.status, 'aktif');
      expect(siklus.isBerjalan, isTrue);
      expect(siklus.isBolehInput, isTrue);
      expect(siklus.targetPanenTon, 5.5);
      expect(siklus.namaKelompok, 'Kelompok Tani Makmur');
      expect(siklus.namaPencatat, 'Budi Santoso');

      final serialized = siklus.toJson();
      expect(serialized['id_siklus'], 'SKL-20261124-ABCD');
      expect(serialized['status'], 'aktif');
      expect(serialized['target_panen_ton'], 5.5);
    });

    test('ItemLahan parses siklusBerjalan from JSON envelope', () {
      final lahanJson = {
        'id': 'LHN-001',
        'nama': 'Sawah Kulon',
        'lokasi': 'Desa Sukamaju',
        'luas': 2.0,
        'komoditas': 'Padi Sawah',
        'status': 'aktif',
        'status_operasional': 'aktif',
        'status_verifikasi': 'terverifikasi',
        'siklus_berjalan': {
          'id_siklus': 'SKL-20261124-WXYZ',
          'id_lahan': 'LHN-001',
          'id_komoditas': 'KMD-001',
          'komoditas_nama': 'Padi Sawah',
          'musim_tanam': 'MT 1',
          'tanggal_mulai': '2026-11-24',
          'status': 'aktif',
          'is_berjalan': true,
        },
      };

      final lahan = ItemLahan.fromJson(lahanJson);

      expect(lahan.id, 'LHN-001');
      expect(lahan.isTerverifikasi, isTrue);
      expect(lahan.status, StatusLahan.aktif);
      expect(lahan.siklusBerjalan, isNotNull);
      expect(lahan.siklusBerjalan!.idSiklus, 'SKL-20261124-WXYZ');
      expect(lahan.siklusBerjalan!.komoditasNama, 'Padi Sawah');
      expect(lahan.siklusBerjalan!.isBerjalan, isTrue);
    });
  });
}
