import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawon_mobile/features/panen/models/item_panen.dart';
import 'package:pawon_mobile/features/panen/screens/layar_detail_panen.dart';

void main() {
  testWidgets('HarvestDetailScreen pumps and displays correctly on narrow screen and taps cetak PDF', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;

    const item = HarvestItem(
      id: 'PN-001',
      harvestCode: 'PN-202611-001',
      title: 'Padi Inpari 32 Sangat Panjang Sekali Varietasnya',
      subtitle: 'Gabah Kering Panen (GKP) Kualitas Unggul',
      cropType: CropType.padi,
      status: HarvestStatus.disetujui,
      location: 'Petak Sawah Timur Blok B Wilayah Selatan',
      blockArea: 'Blok 02 (1,5 Ha)',
      date: '25 Nov 2026',
      harvestTime: '08:30 WIB',
      season: 'Musim Rendeng 2026',
      poktan: 'Poktan Sumber Makmur Jaya Abadi',
      weightKg: 6500,
      qualityGrade: 'Grade A',
      moistureOrNotes: 'Kadar Air 13.5%',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HarvestDetailScreen(
          item: item,
          onUpdate: (_) {},
          onDelete: () {},
        ),
      ),
    );

    expect(find.text('Cetak Bukti PDF'), findsOneWidget);

    await tester.tap(find.text('Cetak Bukti PDF'));
    await tester.pumpAndSettle();

    expect(find.text('Cetak Bukti Hasil Panen'), findsOneWidget);
    expect(find.text('Cetak / Pratinjau Dokumen PDF'), findsOneWidget);

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
