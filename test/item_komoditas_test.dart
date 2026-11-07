import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawon_mobile/core/constants/api_constants.dart';
import 'package:pawon_mobile/core/network/dio_client.dart';
import 'package:pawon_mobile/features/lahan/models/item_komoditas.dart';
import 'package:pawon_mobile/features/lahan/services/lahan_api_service.dart';

import 'lahan_api_service_test.dart';

void main() {
  group('ItemKomoditas Model Tests', () {
    test('1. fromJson mem-parse data komoditas lengkap dengan akurat', () {
      final json = {
        'id_komoditas': 'kmdt-0001',
        'nama_komoditas': 'Padi Ciherang',
        'kategori': 'Tanaman Pangan',
      };

      final item = ItemKomoditas.fromJson(json);

      expect(item.idKomoditas, 'kmdt-0001');
      expect(item.namaKomoditas, 'Padi Ciherang');
      expect(item.kategori, 'Tanaman Pangan');
    });

    test('2. fromJson menangani nilai null dengan fallback string kosong', () {
      final json = <String, dynamic>{};

      final item = ItemKomoditas.fromJson(json);

      expect(item.idKomoditas, '');
      expect(item.namaKomoditas, '');
      expect(item.kategori, '');
    });

    test('3. toJson mengembalikan map sesuai struktur backend', () {
      const item = ItemKomoditas(
        idKomoditas: 'kmdt-0002',
        namaKomoditas: 'Cabai Rawit',
        kategori: 'Hortikultura & Sayuran',
      );

      final map = item.toJson();

      expect(map['id_komoditas'], 'kmdt-0002');
      expect(map['nama_komoditas'], 'Cabai Rawit');
      expect(map['kategori'], 'Hortikultura & Sayuran');
    });

    test('4. Equality operator bekerja berdasarkan idKomoditas', () {
      const item1 = ItemKomoditas(
        idKomoditas: 'kmdt-0001',
        namaKomoditas: 'Padi Ciherang',
        kategori: 'Tanaman Pangan',
      );
      const item2 = ItemKomoditas(
        idKomoditas: 'kmdt-0001',
        namaKomoditas: 'Padi Ciherang Revisi',
        kategori: 'Pangan',
      );
      const item3 = ItemKomoditas(
        idKomoditas: 'kmdt-0003',
        namaKomoditas: 'Jagung',
        kategori: 'Tanaman Pangan',
      );

      expect(item1 == item2, isTrue);
      expect(item1 == item3, isFalse);
    });
  });

  group('LahanApiService getKomoditasList Tests', () {
    late DioClient client;
    late MockDioAdapter mockAdapter;
    late LahanApiService service;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({
        'pawontani_auth_token': 'mock-bearer-token-123',
      });

      client = DioClient(baseUrl: 'http://127.0.0.1:8000/api/v1');
      mockAdapter = MockDioAdapter();
      client.rawDio.httpClientAdapter = mockAdapter;
      service = LahanApiService(client: client);
    });

    test('1. getKomoditasList memanggil GET /api/v1/komoditas dan mem-parse response', () async {
      mockAdapter.handler = (options) {
        expect(options.path, equals(ApiConstants.komoditasEndpoint));
        expect(options.method, equals('GET'));

        return ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'message': 'Daftar komoditas berhasil diambil.',
            'data': [
              {
                'id_komoditas': 'kmdt-0001',
                'nama_komoditas': 'Cabai Rawit',
                'kategori': 'Hortikultura & Sayuran',
              },
              {
                'id_komoditas': 'kmdt-0002',
                'nama_komoditas': 'Padi Ciherang',
                'kategori': 'Tanaman Pangan',
              },
            ],
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final response = await service.getKomoditasList();

      expect(response.success, isTrue);
      expect(response.data, isNotNull);
      expect(response.data!.length, 2);
      expect(response.data![0].namaKomoditas, 'Cabai Rawit');
      expect(response.data![1].namaKomoditas, 'Padi Ciherang');
    });

    test('2. getKomoditasList menangani error 500 dari backend', () async {
      mockAdapter.handler = (options) {
        return ResponseBody.fromString(
          jsonEncode({
            'success': false,
            'message': 'Terjadi kesalahan pada server.',
          }),
          500,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final response = await service.getKomoditasList();

      expect(response.success, isFalse);
      expect(response.data, isNull);
      expect(response.message, contains('Terjadi kesalahan pada server.'));
    });
  });
}

