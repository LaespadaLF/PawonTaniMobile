import 'package:flutter_test/flutter_test.dart';
import 'package:pawon_mobile/features/aktivitas/models/item_aktivitas_tanam.dart';
import 'package:pawon_mobile/features/lahan/models/item_siklus_tanam.dart';

void main() {
  group('Phase 3 - PlantActivityItem & Siklus Integration Test', () {
    test('Aktivitas baru dengan id_siklus memiliki isLegacy = false', () {
      final json = {
        'id_aktivitas': 'AKT-001',
        'id_lahan': 'LHN-001',
        'id_siklus': 'SKL-202611-0001',
        'kategori': 'pemupukan',
        'judul': 'Pemupukan NPK',
        'kondisi_tanaman': 'sehat',
        'tanggal': '2026-11-24',
        'waktu': '08:00 WIB',
        'catatan': 'Pupuk dasar',
      };

      final item = PlantActivityItem.fromJson(json);

      expect(item.id, equals('AKT-001'));
      expect(item.idSiklus, equals('SKL-202611-0001'));
      expect(item.isLegacy, isFalse);
      expect(item.toJson()['id_siklus'], equals('SKL-202611-0001'));
    });

    test('Aktivitas legacy tanpa id_siklus memiliki isLegacy = true dan idSiklus null', () {
      final jsonLegacy = {
        'id_aktivitas': 'AKT-LEGACY-01',
        'id_lahan': 'LHN-LEGACY',
        'kategori': 'penyiraman',
        'judul': 'Penyiraman Pagi',
        'kondisi_tanaman': 'sehat',
        'tanggal': '2026-11-01',
        'waktu': '07:00 WIB',
      };

      final item = PlantActivityItem.fromJson(jsonLegacy);

      expect(item.id, equals('AKT-LEGACY-01'));
      expect(item.idSiklus, isNull);
      expect(item.isLegacy, isTrue);
      expect(item.toJson()['id_siklus'], isNull);
    });

    test('copyWith memperbarui idSiklus dengan benar', () {
      final initial = PlantActivityItem(
        id: 'AKT-002',
        title: 'Penyiangan',
        cropName: 'Padi',
        category: ActivityCategory.penyiangan,
        condition: PlantCondition.sehat,
        date: '2026-11-24',
        time: '09:00 WIB',
        location: 'Petak A',
        blockArea: 'Blok 1',
        notes: 'Catatan',
        idSiklus: null,
      );

      expect(initial.isLegacy, isTrue);

      final updated = initial.copyWith(idSiklus: 'SKL-202611-0002');
      expect(updated.idSiklus, equals('SKL-202611-0002'));
      expect(updated.isLegacy, isFalse);
    });

    test('ItemSiklusTanam helper getters status dan tanggal', () {
      final siklusAktif = ItemSiklusTanam(
        idSiklus: 'SKL-01',
        idLahan: 'LHN-01',
        idKomoditas: 'KMD-01',
        komoditasNama: 'Padi Ciherang',
        musimTanam: 'Musim Hujan 2026',
        tanggalMulai: DateTime(2026, 11, 24),
        status: 'aktif',
      );

      expect(siklusAktif.isAktif, isTrue);
      expect(siklusAktif.isMenungguSelesai, isFalse);
      expect(siklusAktif.statusLabel, equals('Aktif'));
      expect(siklusAktif.tanggalMulaiFormatted, equals('24/11/2026'));

      final siklusMenunggu = ItemSiklusTanam(
        idSiklus: 'SKL-02',
        idLahan: 'LHN-01',
        idKomoditas: 'KMD-01',
        komoditasNama: 'Padi Ciherang',
        musimTanam: 'Musim Hujan 2026',
        status: 'menunggu_selesai',
      );

      expect(siklusMenunggu.isAktif, isFalse);
      expect(siklusMenunggu.isMenungguSelesai, isTrue);
      expect(siklusMenunggu.statusLabel, equals('Menunggu Selesai'));
    });
  });
}
