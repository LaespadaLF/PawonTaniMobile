import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawon_mobile/features/beranda/widgets/bagian_panen_terbaru_beranda.dart';
import 'package:pawon_mobile/features/panen/models/item_panen.dart';

void main() {
  group('HomeLatestHarvestSection Widget Tests', () {
    testWidgets('menampilkan data panen dinamis secara lengkap saat item tidak null', (tester) async {
      HarvestItem? tappedItem;
      bool allTapped = false;

      const testItem = HarvestItem(
        id: 'PN-101',
        harvestCode: 'PN-202611-101',
        title: 'Padi Inpari 32',
        subtitle: 'Gabah Kering Panen (GKP)',
        cropType: CropType.padi,
        status: HarvestStatus.disetujui,
        location: 'Petak Sawah Barat',
        blockArea: 'Blok A',
        date: '26 Nov 2026',
        season: 'Musim Rendeng',
        weightKg: 4500,
        qualityGrade: 'Grade A',
        moistureOrNotes: 'Kadar Air 14%',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeLatestHarvestSection(
              item: testItem,
              onItemTap: (item) => tappedItem = item,
              onAllTap: () => allTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Hasil Panen Terbaru'), findsOneWidget);
      expect(find.text('Lihat semua >'), findsOneWidget);
      expect(find.text('Padi Inpari 32'), findsOneWidget);
      expect(find.text('Padi • Petak Sawah Barat'), findsOneWidget);
      expect(find.text('4,50 Ton'), findsOneWidget);
      expect(find.text('Disetujui'), findsOneWidget);

      await tester.tap(find.text('Padi Inpari 32'));
      await tester.pump();
      expect(tappedItem, equals(testItem));

      await tester.tap(find.text('Lihat semua >'));
      await tester.pump();
      expect(allTapped, isTrue);
    });

    testWidgets('menampilkan empty state dan tombol catat saat item null', (tester) async {
      bool addTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeLatestHarvestSection(
              item: null,
              isLoading: false,
              onAddTap: () => addTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Belum Ada Panen Baru'), findsOneWidget);
      expect(find.text('Catat'), findsOneWidget);

      await tester.tap(find.text('Catat'));
      await tester.pump();
      expect(addTapped, isTrue);
    });
  });
}
