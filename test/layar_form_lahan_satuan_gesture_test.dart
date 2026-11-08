import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawon_mobile/features/lahan/models/item_lahan.dart';
import 'package:pawon_mobile/features/lahan/screens/layar_edit_lahan.dart';
import 'package:pawon_mobile/features/lahan/screens/layar_tambah_lahan.dart';

final transparentPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
];

class FakeHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => transparentPng.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(transparentPng).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeHttpClientRequest implements HttpClientRequest {
  @override
  final HttpHeaders headers = FakeHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => FakeHttpClientResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => FakeHttpClientRequest();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async => FakeHttpClientRequest();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => FakeHttpClient();
}

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  group('Pengujian Satuan Luas Lahan & Gesture Peta PawonTani Mobile', () {
    testWidgets('1. AddLandScreen: Dropdown satuan menyediakan Hektar dan Meter Persegi, konversi berjalan responsif', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: AddLandScreen(),
        ),
      );
      await tester.pump();

      // Cek dropdown satuan lahan
      final dropdownFinder = find.byType(DropdownButton<String>);
      expect(dropdownFinder, findsWidgets);

      // Pastikan ada teks default "Hektar (Ha)" dan teks ekuivalen awal
      expect(find.text('Hektar (Ha)'), findsOneWidget);
      expect(find.textContaining('8000 m²'), findsOneWidget);

      // Buka dropdown satuan
      await tester.tap(find.text('Hektar (Ha)'));
      await tester.pump(const Duration(milliseconds: 300));

      // Pastikan opsi 'Meter Persegi (m²)' muncul di popup menu
      final m2OptionFinder = find.text('Meter Persegi (m²)').last;
      expect(m2OptionFinder, findsOneWidget);

      // Pilih Meter Persegi (m²)
      await tester.tap(m2OptionFinder);
      await tester.pump(const Duration(milliseconds: 300));

      // Teks controller harus dikonversi dari 0,8 Ha ke 8000 m²
      expect(find.text('8000'), findsOneWidget);
      expect(find.textContaining('0,8 Ha'), findsOneWidget);
    });

    testWidgets('2. EditLandScreen: Dropdown satuan menyediakan 2 opsi dan menjaga presisi desimal', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final testItem = ItemLahan(
        id: 'lh-999',
        nama: 'Petak Sukamaju 01',
        lokasi: 'Dusun Sukamaju RT 01',
        luas: 0.25, // 0.25 Ha = 2500 m2
        status: StatusLahan.aktif,
        statusVerifikasi: 'Terverifikasi',
        latitude: -6.5621,
        longitude: 107.7589,
        musimTanam: 'MT-1 (Musim Hujan)',
        idKomoditas: 'kmdt-01',
        komoditas: 'Padi Ciherang',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditLandScreen(item: testItem),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Verifikasi presisi nilai awal: 0,25 tidak boleh terpotong menjadi 0.2 atau 0.3
      expect(find.text('0,25'), findsOneWidget);
      expect(find.textContaining('2500 m²'), findsOneWidget);

      // Buka dropdown satuan
      await tester.tap(find.text('Hektar (Ha)').first);
      await tester.pump(const Duration(milliseconds: 300));

      // Pastikan opsi Meter Persegi tersedia
      final m2OptionFinder = find.text('Meter Persegi (m²)').last;
      expect(m2OptionFinder, findsOneWidget);

      // Pilih Meter Persegi (m²)
      await tester.tap(m2OptionFinder);
      await tester.pump(const Duration(milliseconds: 300));

      // Konversi: 0.25 Ha * 10000 = 2500
      expect(find.text('2500'), findsOneWidget);
      expect(find.textContaining('0,25 Ha'), findsOneWidget);
    });

    testWidgets('3. AddLandScreen & EditLandScreen: Mode gesture peta default terkunci dan toggle dapat diaktifkan', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: AddLandScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Cek FlutterMap ada
      final flutterMapFinder = find.byType(FlutterMap);
      expect(flutterMapFinder, findsOneWidget);

      FlutterMap mapWidget = tester.widget(flutterMapFinder);
      // Default: InteractiveFlag.none sehingga scroll parent tidak terganggu
      expect(mapWidget.options.interactionOptions.flags, equals(InteractiveFlag.none));

      // Cek tombol toggle mode geser
      final toggleFinder = find.text('Ketuk untuk geser');
      expect(toggleFinder, findsOneWidget);

      // Ketuk toggle untuk mengaktifkan mode geser
      await tester.tap(toggleFinder);
      await tester.pump(const Duration(milliseconds: 300));

      // Setelah diketuk, badge berubah menjadi 'Mode geser aktif'
      expect(find.text('Mode geser aktif'), findsOneWidget);

      mapWidget = tester.widget(flutterMapFinder);
      expect(mapWidget.options.interactionOptions.flags, equals(InteractiveFlag.all & ~InteractiveFlag.rotate));

      // Ketuk kembali untuk mengunci
      await tester.tap(find.text('Mode geser aktif'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Ketuk untuk geser'), findsOneWidget);
      mapWidget = tester.widget(flutterMapFinder);
      expect(mapWidget.options.interactionOptions.flags, equals(InteractiveFlag.none));
    });
  });
}
