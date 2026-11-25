import 'package:flutter_test/flutter_test.dart';
import 'package:pawon_mobile/features/panen/models/item_panen.dart';

void main() {
  group('Phase 4 - HarvestItem & Siklus Integration Test', () {
    test('HarvestItem baru dengan id_siklus memiliki isLegacy = false', () {
      final json = {
        'id_panen': 'PN-001',
        'kode_panen': 'PN-202611-001',
        'id_lahan': 'LHN-001',
        'id_siklus': 'SKL-202611-0001',
        'varietas': 'Ciherang Unggul',
        'jenis_panen': 'Gabah Kering Panen (GKP)',
        'tanggal_panen': '2026-11-24',
        'waktu_panen': '09:00 WIB',
        'berat_kg': 2500.0,
        'status': 'menunggu',
      };

      final item = HarvestItem.fromJson(json);

      expect(item.id, equals('PN-001'));
      expect(item.idSiklus, equals('SKL-202611-0001'));
      expect(item.isLegacy, isFalse);
      expect(item.status, equals(HarvestStatus.menunggu));
      expect(item.toJson()['id_siklus'], equals('SKL-202611-0001'));
    });

    test('HarvestItem legacy tanpa id_siklus memiliki isLegacy = true dan idSiklus null', () {
      final jsonLegacy = {
        'id_panen': 'PN-LEGACY-01',
        'kode_panen': 'PN-LEGACY',
        'id_lahan': 'LHN-LEGACY',
        'varietas': 'Padi Ciherang',
        'jenis_panen': 'Gabah Kering Panen (GKP)',
        'tanggal_panen': '2026-11-01',
        'waktu_panen': '08:00 WIB',
        'berat_kg': 1200.0,
        'status': 'disetujui',
      };

      final item = HarvestItem.fromJson(jsonLegacy);

      expect(item.id, equals('PN-LEGACY-01'));
      expect(item.idSiklus, isNull);
      expect(item.isLegacy, isTrue);
      expect(item.status, equals(HarvestStatus.disetujui));
      expect(item.toJson()['id_siklus'], isNull);
    });

    test('copyWith memperbarui idSiklus dan status dengan benar', () {
      final initial = HarvestItem(
        id: 'PN-002',
        title: 'Ciherang',
        subtitle: 'Gabah Kering Panen',
        weightKg: 2000.0,
        date: '2026-11-24',
        status: HarvestStatus.ditolak,
        cropType: CropType.padi,
        qualityGrade: 'Grade A',
        moisturePercent: 14.0,
        wholeGrainPercent: 95.0,
        wastePercent: 2.0,
        harvestCost: 500000.0,
        costWorkers: '2 Orang',
        pricePerKg: 6500.0,
        location: 'Petak Sawah 1',
        blockArea: '1 Ha',
        season: 'MT 1 - 2026',
        moistureOrNotes: '14.0%',
        idLahan: 'LHN-001',
        idSiklus: null,
      );

      expect(initial.isLegacy, isTrue);
      expect(initial.status, equals(HarvestStatus.ditolak));

      final updated = initial.copyWith(
        idSiklus: 'SKL-202611-0002',
        status: HarvestStatus.menunggu,
      );

      expect(updated.idSiklus, equals('SKL-202611-0002'));
      expect(updated.isLegacy, isFalse);
      expect(updated.status, equals(HarvestStatus.menunggu));
    });

    test('HarvestItem membedakan status disetujui, ditolak, dan menunggu', () {
      final itemApproved = HarvestItem.fromJson({
        'id_panen': 'PN-A',
        'id_lahan': 'LHN-A',
        'id_siklus': 'SKL-A',
        'status': 'disetujui',
        'diverifikasi_oleh': 'Bpk. Ketua',
      });
      expect(itemApproved.status, equals(HarvestStatus.disetujui));
      expect(itemApproved.validatedBy, equals('Bpk. Ketua'));

      final itemRejected = HarvestItem.fromJson({
        'id_panen': 'PN-B',
        'id_lahan': 'LHN-B',
        'id_siklus': 'SKL-B',
        'status': 'ditolak',
        'catatan_verifikasi': 'Kadar air tinggi',
      });
      expect(itemRejected.status, equals(HarvestStatus.ditolak));
      expect(itemRejected.validatedNotes, equals('Kadar air tinggi'));

      final itemPending = HarvestItem.fromJson({
        'id_panen': 'PN-C',
        'id_lahan': 'LHN-C',
        'id_siklus': 'SKL-C',
        'status': 'menunggu',
      });
      expect(itemPending.status, equals(HarvestStatus.menunggu));
    });
  });
}
