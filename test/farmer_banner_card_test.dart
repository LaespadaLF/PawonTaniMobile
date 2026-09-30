import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawon_mobile/features/beranda/widgets/kartu_banner_petani.dart';

void main() {
  testWidgets('FarmerBannerCard renders headline, weather, and detail button', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FarmerBannerCard(
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    // Verify Texts
    expect(find.text('Semangat bertani,\nhasil terbaik menanti!'), findsOneWidget);
    expect(find.text('Pantau pertanianmu dengan lebih mudah.'), findsOneWidget);
    expect(find.text('28°C'), findsOneWidget);
    expect(find.text('Cerah Berawan'), findsOneWidget);
    expect(find.text('Sukamaju'), findsOneWidget);
    expect(find.text('Lihat detail'), findsOneWidget);

    // Verify Icons
    expect(find.byIcon(Icons.eco_rounded), findsOneWidget);
    expect(find.byIcon(Icons.wb_sunny_rounded), findsOneWidget);
    expect(find.byIcon(Icons.cloud_rounded), findsOneWidget);
    expect(find.byIcon(Icons.place_outlined), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);

    // Tap the button
    await tester.tap(find.text('Lihat detail'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
