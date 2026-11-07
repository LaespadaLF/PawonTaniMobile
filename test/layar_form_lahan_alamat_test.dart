import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
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

  group('Pemeriksaan dan Pengujian Form Input Alamat Lahan (F-02)', () {
    testWidgets('1. AddLandScreen: Alamat menggunakan TextField dinamis dan dropdown hardcoded telah dihilangkan', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: AddLandScreen(),
        ),
      );
      await tester.pump();

      // Label RichText harus ada
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('Alamat & Lokasi Lahan'),
        ),
        findsOneWidget,
      );

      // Hint text harus ada
      expect(find.text('Contoh: Dusun Krajan RT 02 / RW 01, Desa Sukamaju'), findsOneWidget);

      // Nilai hardcoded 'Desa Sukamaju, Dusun Krajan' TIDAK boleh ada sebagai dropdown / teks
      expect(find.text('Desa Sukamaju, Dusun Krajan'), findsNothing);

      // Cari TextField dengan hint alamat
      final specificAddressField = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == 'Contoh: Dusun Krajan RT 02 / RW 01, Desa Sukamaju',
      );
      expect(specificAddressField, findsOneWidget);

      await tester.enterText(specificAddressField, 'Dusun Wates RT 04 / RW 02, Desa Kalisari');
      await tester.pump();

      expect(find.text('Dusun Wates RT 04 / RW 02, Desa Kalisari'), findsOneWidget);
    });

    testWidgets('2. EditLandScreen: Alamat lama terisi otomatis dari model widget.item.lokasi dan dapat disunting', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      const mockItem = ItemLahan(
        id: 'LHN-TEST-999',
        nama: 'Petak Sawah Barat',
        lokasi: 'Jl. Raya Pertanian No. 88, Blok C',
        luas: 1.2,
        komoditas: 'Padi IR64',
        status: StatusLahan.aktif,
        latitude: -6.5621,
        longitude: 107.7589,
        musimTanam: 'MT-1 (Musim Hujan)',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: EditLandScreen(item: mockItem),
        ),
      );
      await tester.pump();

      // Nilai hardcoded lama 'Desa Sukamaju, Dusun Krajan, RT 02/RW 01' TIDAK boleh ada
      expect(find.text('Desa Sukamaju, Dusun Krajan, RT 02/RW 01'), findsNothing);

      // Alamat asli dari mockItem.lokasi harus ditampilkan di form
      expect(find.text('Jl. Raya Pertanian No. 88, Blok C'), findsOneWidget);

      // Cari TextField yang memuat alamat tersebut
      final specificAddressField = find.byWidgetPredicate(
        (w) => w is TextField && w.controller?.text == 'Jl. Raya Pertanian No. 88, Blok C',
      );
      expect(specificAddressField, findsOneWidget);

      // Pengguna mengedit alamat
      await tester.enterText(specificAddressField, 'Jl. Raya Pertanian No. 90 (Revisi Alamat)');
      await tester.pump();

      expect(find.text('Jl. Raya Pertanian No. 90 (Revisi Alamat)'), findsOneWidget);
    });

    testWidgets('3. EditLandScreen: Validasi kosong mencegah submit jika alamat dihapus', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      const mockItem = ItemLahan(
        id: 'LHN-TEST-888',
        nama: 'Petak Sawah Timur',
        lokasi: 'Dusun Timur RT 01',
        luas: 0.8,
        komoditas: 'Jagung',
        status: StatusLahan.aktif,
        idKomoditas: 'KMD-001',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: EditLandScreen(item: mockItem),
        ),
      );
      await tester.pump();

      final specificAddressField = find.byWidgetPredicate(
        (w) => w is TextField && w.controller?.text == 'Dusun Timur RT 01',
      );
      expect(specificAddressField, findsOneWidget);

      // Hapus alamat menjadi kosong
      await tester.enterText(specificAddressField, '');
      await tester.pump();

      // Tekan tombol Simpan Perubahan
      final submitButton = find.widgetWithText(ElevatedButton, 'Simpan Perubahan Lahan');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pump();

      // SnackBar validasi harus muncul
      expect(find.text('Silakan masukkan alamat / lokasi petak lahan.'), findsOneWidget);
    });
  });
}
