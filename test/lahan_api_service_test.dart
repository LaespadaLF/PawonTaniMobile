import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawon_mobile/core/constants/api_constants.dart';
import 'package:pawon_mobile/core/network/dio_client.dart';
import 'package:pawon_mobile/features/lahan/services/lahan_api_service.dart';

class MockDioAdapter implements HttpClientAdapter {
  ResponseBody Function(RequestOptions options)? handler;

  MockDioAdapter({this.handler});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (handler != null) {
      return handler!(options);
    }
    return ResponseBody.fromString(
      jsonEncode({'success': true, 'message': 'OK'}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late DioClient client;
  late MockDioAdapter mockAdapter;
  late LahanApiService service;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({
      'pawontani_auth_token': 'mock-test-bearer-token-123',
    });

    client = DioClient(baseUrl: 'http://127.0.0.1:8000/api/v1');
    mockAdapter = MockDioAdapter();
    client.rawDio.httpClientAdapter = mockAdapter;

    service = LahanApiService(client: client);
  });

  group('LahanApiService Unit & Mock Integration Tests', () {
    // 1. GET daftar lahan
    test('1. getLahanList memanggil endpoint GET /lahan dan memparsing data', () async {
      mockAdapter.handler = (options) {
        expect(options.method, 'GET');
        expect(options.path, ApiConstants.lahanEndpoint);
        expect(options.headers['Authorization'], 'Bearer mock-test-bearer-token-123');

        final responseBody = {
          'success': true,
          'message': 'Daftar lahan berhasil diambil.',
          'data': [
            {
              'id': 'LHN-001',
              'nama': 'Petak Barat',
              'lokasi': 'Desa Maju',
              'luas': 1.2,
              'komoditas': 'Padi',
              'status': 'aktif',
              'status_verifikasi': 'terverifikasi',
            },
            {
              'id': 'LHN-002',
              'nama': 'Petak Timur',
              'lokasi': 'Desa Makmur',
              'luas': 0.8,
              'komoditas': 'Jagung',
              'status': 'persiapan',
              'status_verifikasi': 'menunggu_verifikasi',
            }
          ]
        };

        return ResponseBody.fromString(
          jsonEncode(responseBody),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };

      final response = await service.getLahanList();

      expect(response.success, isTrue);
      expect(response.data, isNotNull);
      expect(response.data!.length, 2);
      expect(response.data![0].nama, 'Petak Barat');
      expect(response.data![0].isTerverifikasi, isTrue);
      expect(response.data![1].isMenungguVerifikasi, isTrue);
    });

    // 2. GET detail lahan
    test('2. getLahanDetail memanggil endpoint GET /lahan/{id} dengan benar', () async {
      mockAdapter.handler = (options) {
        expect(options.method, 'GET');
        expect(options.path, '${ApiConstants.lahanEndpoint}/LHN-001');

        final responseBody = {
          'success': true,
          'message': 'Detail lahan berhasil diambil.',
          'data': {
            'id': 'LHN-001',
            'nama': 'Petak Barat',
            'lokasi': 'Desa Maju',
            'luas': 1.2,
            'komoditas': 'Padi',
            'status': 'aktif',
            'latitude': -6.5621,
            'longitude': 107.7589,
            'status_verifikasi': 'terverifikasi',
            'catatan_verifikasi': 'Dokumen lengkap',
          }
        };

        return ResponseBody.fromString(
          jsonEncode(responseBody),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };

      final response = await service.getLahanDetail('LHN-001');

      expect(response.success, isTrue);
      expect(response.data, isNotNull);
      expect(response.data!.id, 'LHN-001');
      expect(response.data!.statusVerifikasi, 'terverifikasi');
      expect(response.data!.catatanVerifikasi, 'Dokumen lengkap');
    });

    // 3. POST create lahan
    test('3. createLahan mengirim POST /lahan dengan payload JSON', () async {
      mockAdapter.handler = (options) {
        expect(options.method, 'POST');
        expect(options.path, ApiConstants.lahanEndpoint);
        expect(options.data['nama_lahan'], 'Sawah Baru');

        final responseBody = {
          'success': true,
          'message': 'Lahan berhasil didaftarkan.',
          'data': {
            'id': 'LHN-003',
            'nama': 'Sawah Baru',
            'lokasi': 'Desa Baru',
            'luas': 2.0,
            'status': 'persiapan',
            'status_verifikasi': 'menunggu_verifikasi',
          }
        };

        return ResponseBody.fromString(
          jsonEncode(responseBody),
          201,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };

      final response = await service.createLahan({
        'nama_lahan': 'Sawah Baru',
        'luas': 2.0,
        'alamat_lahan': 'Desa Baru',
      });

      expect(response.success, isTrue);
      expect(response.data!.id, 'LHN-003');
      expect(response.data!.isMenungguVerifikasi, isTrue);
    });

    // 4 & 5. POST update dengan _method=PUT dan Multipart foto
    test('4. updateLahanWithFoto mengirim POST dengan _method=PUT dan FormData multipart', () async {
      mockAdapter.handler = (options) {
        expect(options.method, 'POST');
        expect(options.path, '${ApiConstants.lahanEndpoint}/LHN-001');
        expect(options.data, isA<FormData>());

        final formData = options.data as FormData;
        final methodField = formData.fields.firstWhere((f) => f.key == '_method');
        expect(methodField.value, 'PUT');

        final namaField = formData.fields.firstWhere((f) => f.key == 'nama_lahan');
        expect(namaField.value, 'Sawah Diperbarui');

        final fileEntry = formData.files.firstWhere((f) => f.key == 'foto_lahan');
        expect(fileEntry.value.filename, 'foto_baru.jpg');

        final responseBody = {
          'success': true,
          'message': 'Data lahan berhasil diperbarui.',
          'data': {
            'id': 'LHN-001',
            'nama': 'Sawah Diperbarui',
            'foto_lahan': 'https://res.cloudinary.com/demo/image/upload/foto_baru.jpg',
            'status_verifikasi': 'menunggu_verifikasi',
          }
        };

        return ResponseBody.fromString(
          jsonEncode(responseBody),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };

      final photo = MultipartFile.fromBytes(
        Uint8List.fromList([1, 2, 3]),
        filename: 'foto_baru.jpg',
      );

      final response = await service.updateLahanWithFoto(
        'LHN-001',
        {'nama_lahan': 'Sawah Diperbarui'},
        photo,
      );

      expect(response.success, isTrue);
      expect(response.data!.nama, 'Sawah Diperbarui');
      expect(response.data!.fotoLahan, isNotNull);
    });

    // 6. DELETE lahan
    test('5. deleteLahan memanggil DELETE /lahan/{id}', () async {
      mockAdapter.handler = (options) {
        expect(options.method, 'DELETE');
        expect(options.path, '${ApiConstants.lahanEndpoint}/LHN-001');

        final responseBody = {
          'success': true,
          'message': 'Data lahan berhasil dihapus.',
        };

        return ResponseBody.fromString(
          jsonEncode(responseBody),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };

      final response = await service.deleteLahan('LHN-001');
      expect(response.success, isTrue);
    });

    // 7. Bearer token disematkan via Interceptor
    test('6. Bearer token otomatis disematkan pada header Authorization', () async {
      bool tokenVerified = false;
      mockAdapter.handler = (options) {
        expect(options.headers['Authorization'], 'Bearer mock-test-bearer-token-123');
        tokenVerified = true;

        return ResponseBody.fromString(
          jsonEncode({'success': true, 'message': 'OK'}),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };

      await service.deleteLahan('LHN-999');
      expect(tokenVerified, isTrue);
    });

    // 8. Error handling: 401, 403, 422, 500
    test('7. Menangani respons error 401 Unauthorized', () async {
      mockAdapter.handler = (options) {
        final errorJson = {
          'success': false,
          'message': 'Unauthenticated.',
        };
        return ResponseBody.fromString(
          jsonEncode(errorJson),
          401,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };

      final response = await service.getLahanList();
      expect(response.success, isFalse);
      expect(response.statusCode, 401);
      expect(response.message, 'Unauthenticated.');
    });

    test('8. Menangani respons error 403 Forbidden', () async {
      mockAdapter.handler = (options) {
        final errorJson = {
          'success': false,
          'message': 'Akses ditolak. Layanan ini hanya diperuntukkan bagi Anggota aktif.',
        };
        return ResponseBody.fromString(
          jsonEncode(errorJson),
          403,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };

      final response = await service.getLahanList();
      expect(response.success, isFalse);
      expect(response.statusCode, 403);
      expect(response.message, contains('Akses ditolak'));
    });

    test('9. Menangani respons error 422 Validation Error', () async {
      mockAdapter.handler = (options) {
        final errorJson = {
          'success': false,
          'message': 'Validasi data lahan gagal.',
          'errors': {
            'nama_lahan': ['Nama lahan wajib diisi.'],
            'luas': ['Luas lahan harus lebih besar dari 0 hektare.']
          }
        };
        return ResponseBody.fromString(
          jsonEncode(errorJson),
          422,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };

      final response = await service.createLahan({});
      expect(response.success, isFalse);
      expect(response.statusCode, 422);
      expect(response.firstErrorMessage, contains('Nama lahan wajib diisi.'));
    });

    test('10. Menangani respons error 500 Internal Server Error', () async {
      mockAdapter.handler = (options) {
        final errorJson = {
          'success': false,
          'message': 'Terjadi kesalahan sistem saat mendaftarkan lahan.',
        };
        return ResponseBody.fromString(
          jsonEncode(errorJson),
          500,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };

      final response = await service.createLahan({'nama_lahan': 'Lahan Crash'});
      expect(response.success, isFalse);
      expect(response.statusCode, 500);
      expect(response.message, contains('kesalahan sistem'));
    });
  });
}
