import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawon_mobile/features/lahan/models/item_lahan.dart';
import 'package:pawon_mobile/features/lahan/screens/layar_detail_lahan.dart';

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

  const baseItem = ItemLahan(
    id: 'LHN-TEST-001',
    nama: 'Petak Sawah Lembah',
    lokasi: 'Dusun Krajan RT 01',
    luas: 1.5,
    komoditas: 'Padi Ciherang',
    status: StatusLahan.aktif,
    latitude: -6.5621,
    longitude: 107.7589,
    musimTanam: 'MT-1 (Musim Hujan)',
    keterangan: 'Kondisi tanah subur dekat saluran primer.',
    statusVerifikasi: 'terverifikasi',
    isCanDelete: false,
    isCanEdit: true,
  );

  Widget createDetailWidget(ItemLahan item) {
    return MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(size: Size(800, 1600)),
        child: LandDetailScreen(item: item),
      ),
    );
  }

  group('LandDetailScreen Dummy Data Elimination & Placeholder Tests (F-05)', () {
    testWidgets('1. Nilai dummy operasional telah digantikan dengan placeholder dan empty state', (tester) async {
      await tester.pumpWidget(createDetailWidget(baseItem));
      await tester.pump();

      // Verifikasi Data Riil dari Model Lahan
      expect(find.text('Petak Sawah Lembah'), findsAtLeastNWidgets(1));
      expect(find.text('1,5 Ha'), findsAtLeastNWidgets(1));
      expect(find.text('Padi Ciherang'), findsAtLeastNWidgets(1));
      expect(find.text('MT-1 (Musim Hujan)'), findsOneWidget);
      expect(find.text('Dusun Krajan RT 01'), findsOneWidget);
      expect(find.text('Kondisi tanah subur dekat saluran primer.'), findsOneWidget);

      // Verifikasi Placeholder '-' pada data yang belum tersedia di backend
      expect(find.text('-'), findsAtLeastNWidgets(3)); // Estimasi Panen, Sumber Irigasi, Tanggal Tanam

      // Verifikasi Empty State Riwayat Aktivitas
      expect(find.text('Belum Ada Riwayat Aktivitas'), findsOneWidget);

      // Verifikasi seluruh teks dummy masa lalu TIDAK LAGI DITEMUKAN
      expect(find.text('Sekunder'), findsNothing);
      expect(find.text('15 Okt 2024'), findsNothing);
      expect(find.text('10 Feb 2025'), findsNothing);
      expect(find.text('12 Nov 2024 • 120 kg/Ha'), findsNothing);
      expect(find.text('04 Nov 2024 • Pencegahan Hama'), findsNothing);
    });

    testWidgets('2. Hak akses hapus dikendalikan sepenuhnya oleh isCanDelete dari backend policy', (tester) async {
      // Skenario A: Lahan terverifikasi (isCanDelete = false) -> Tombol hapus tidak tampil
      await tester.pumpWidget(createDetailWidget(baseItem));
      await tester.pump();
      expect(find.text('Hapus Lahan'), findsNothing);

      // Skenario B: Lahan draft/bisa dihapus (isCanDelete = true) -> Tombol hapus tampil
      final deletableItem = baseItem.copyWith(isCanDelete: true);
      await tester.pumpWidget(createDetailWidget(deletableItem));
      await tester.pump();
      expect(find.text('Hapus Lahan'), findsOneWidget);
    });

    testWidgets('3. Halaman Detail Lahan tetap dapat dibuka dan stabil saat seluruh field operasional null', (tester) async {
      const emptyOperationalItem = ItemLahan(
        id: 'LHN-TEST-002',
        nama: 'Petak Baru Kosong',
        lokasi: 'Dusun Baru',
        luas: 0.8,
        komoditas: '',
        status: StatusLahan.persiapan,
        latitude: null,
        longitude: null,
        musimTanam: null,
        keterangan: null,
        fotoLahan: null,
        statusVerifikasi: 'menunggu_verifikasi',
        isCanDelete: false,
      );

      await tester.pumpWidget(createDetailWidget(emptyOperationalItem));
      await tester.pump();

      expect(find.text('Petak Baru Kosong'), findsAtLeastNWidgets(1));
      expect(find.text('0,8 Ha'), findsAtLeastNWidgets(1));
      expect(find.text('Belum Ada Riwayat Aktivitas'), findsOneWidget);
      // Keterangan card tidak boleh muncul bila null
      expect(find.text('Keterangan / Catatan Lahan'), findsNothing);
    });
  });
}
