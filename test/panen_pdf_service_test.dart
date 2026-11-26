import 'package:flutter_test/flutter_test.dart';
import 'package:pawon_mobile/features/panen/models/item_panen.dart';
import 'package:pawon_mobile/features/panen/services/panen_pdf_service.dart';

void main() {
  group('PanenPdfService.generatePanenPdf', () {
    test('menghasilkan berkas PDF dengan byte valid untuk status disetujui', () async {
      const item = HarvestItem(
        id: 'PN-001',
        harvestCode: 'PN-202611-001',
        title: 'Padi Inpari 32',
        subtitle: 'Gabah Kering Panen (GKP)',
        cropType: CropType.padi,
        status: HarvestStatus.disetujui,
        location: 'Petak Sawah Timur Blok B',
        blockArea: 'Blok 02 (1,5 Ha)',
        date: '25 Nov 2026',
        harvestTime: '08:30 WIB',
        season: 'Musim Rendeng 2026',
        poktan: 'Poktan Sumber Makmur',
        weightKg: 6500,
        qualityGrade: 'Grade A',
        moistureOrNotes: 'Kadar Air 13.5%',
        moisturePercent: 13.5,
        wholeGrainPercent: 96.0,
        wastePercent: 1.5,
        harvestMethod: 'Combine Harvester',
        harvestCost: 1500000,
        costWorkers: 'Operator Mesin',
        pricePerKg: 7200,
        fieldNotes: 'Hasil gabah bersih dan kering optimal.',
        validatedBy: 'Pengurus Poktan',
        validatedAt: '25 Nov 2026 14:00',
      );

      final bytes = await PanenPdfService.generatePanenPdf(item);

      expect(bytes, isNotEmpty);
      // Validasi PDF magic number: %PDF-
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });

    test('menghasilkan berkas PDF dengan byte valid untuk status menunggu dan komoditas jagung', () async {
      const item = HarvestItem(
        id: 'PN-002',
        harvestCode: 'PN-202611-002',
        title: 'Jagung Hibrida Pioneer P27',
        subtitle: 'Tongkol Kering',
        cropType: CropType.jagung,
        status: HarvestStatus.menunggu,
        location: 'Ladang Jagung Utara',
        blockArea: 'Blok C (0,8 Ha)',
        date: '26 Nov 2026',
        season: 'Musim Gadu 2026',
        weightKg: 850,
        qualityGrade: 'Grade B',
        moistureOrNotes: 'Kadar Air 15.0%',
      );

      final bytes = await PanenPdfService.generatePanenPdf(item);

      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });

    test('menghasilkan berkas PDF dengan byte valid untuk status ditolak', () async {
      const item = HarvestItem(
        id: 'PN-003',
        harvestCode: 'PN-202611-003',
        title: 'Padi Ciherang',
        subtitle: 'Gabah Kering',
        cropType: CropType.padi,
        status: HarvestStatus.ditolak,
        location: 'Lahan Selatan',
        blockArea: 'Blok 1',
        date: '20 Nov 2026',
        season: 'Musim Rendeng',
        weightKg: 3200,
        qualityGrade: 'Grade C',
        moistureOrNotes: 'Kadar air tinggi',
        validatedNotes: 'Kadar air melebihi batas standar kelompok tani (18%).',
      );

      final bytes = await PanenPdfService.generatePanenPdf(item);

      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });
  });
}
