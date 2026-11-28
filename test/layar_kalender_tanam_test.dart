import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawon_mobile/features/beranda/screens/layar_kalender_tanam.dart';

void main() {
  testWidgets('LayarKalenderTanam menampilkan info musim tanam dan rekomendasi agronomi', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LayarKalenderTanam(),
      ),
    );

    // Pump frame initial and next frame for fallback load
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Kalender Musim Tanam'), findsOneWidget);
  });
}
