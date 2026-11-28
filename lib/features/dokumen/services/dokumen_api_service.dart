import 'package:dio/dio.dart';
import 'package:pawon_mobile/core/network/api_response.dart';
import 'package:pawon_mobile/core/network/dio_client.dart';
import 'package:pawon_mobile/features/dokumen/models/item_dokumen_saya.dart';

class DokumenApiService {
  final DioClient _client;

  DokumenApiService({DioClient? client}) : _client = client ?? DioClient();

  /// Mengambil status kelengkapan dokumen KTP, KK, dan SPPT milik anggota
  Future<ApiResponse<Map<String, dynamic>>> getDocumentsSummary() async {
    return _client.get<Map<String, dynamic>>(
      '/documents',
      fromJson: (data) => data is Map<String, dynamic> ? data : {},
    );
  }

  /// Mengunggah dokumen identitas KTP atau KK
  Future<ApiResponse<dynamic>> uploadIdentity(String jenis, String filePath) async {
    final fileName = filePath.split(RegExp(r'[/\\]')).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    return _client.post<dynamic>(
      '/documents/identity/$jenis',
      data: formData,
      fromJson: (data) => data,
    );
  }

  /// Mengambil daftar izin akses aktif yang diberikan oleh anggota
  Future<ApiResponse<List<ItemIzinDokumen>>> getPermissions() async {
    return _client.get<List<ItemIzinDokumen>>(
      '/documents/permissions',
      fromJson: (data) {
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map((e) => ItemIzinDokumen.fromJson(e))
              .toList();
        }
        return [];
      },
    );
  }

  /// Membagikan izin akses kepada pengurus kelompok tani
  Future<ApiResponse<ItemIzinDokumen>> grantPermission({
    required String jenisDokumen,
    required String tujuanAkses,
    required int masaBerlakuHari,
  }) async {
    return _client.post<ItemIzinDokumen>(
      '/documents/permissions/grant',
      data: {
        'jenis_dokumen': jenisDokumen,
        'tujuan_akses': tujuanAkses,
        'masa_berlaku_hari': masaBerlakuHari,
      },
      fromJson: (data) => ItemIzinDokumen.fromJson(data is Map<String, dynamic> ? data : {}),
    );
  }

  /// Mencabut izin akses yang pernah diberikan
  Future<ApiResponse<dynamic>> revokePermission(int idIzin) async {
    return _client.post<dynamic>(
      '/documents/permissions/$idIzin/revoke',
      fromJson: (data) => data,
    );
  }
}
