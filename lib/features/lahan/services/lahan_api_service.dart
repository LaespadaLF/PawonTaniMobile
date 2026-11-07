import 'package:dio/dio.dart';
import 'package:pawon_mobile/core/constants/api_constants.dart';
import 'package:pawon_mobile/core/network/api_response.dart';
import 'package:pawon_mobile/core/network/dio_client.dart';
import 'package:pawon_mobile/features/lahan/models/item_komoditas.dart';
import 'package:pawon_mobile/features/lahan/models/item_lahan.dart';

/// Service networking untuk memanggil endpoint lahan backend Laravel.
class LahanApiService {
  final DioClient _client;

  LahanApiService({DioClient? client}) : _client = client ?? DioClient();

  /// Mengambil daftar lahan milik anggota yang login dari
  /// `GET /api/v1/lahan`. Mendukung parameter page dan per_page untuk pagination.
  Future<ApiResponse<List<ItemLahan>>> getLahanList({
    int? page,
    int? perPage,
  }) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (perPage != null) queryParams['per_page'] = perPage;

    final response = await _client.get<List<ItemLahan>>(
      ApiConstants.lahanEndpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (data) {
        if (data is! List) {
          return <ItemLahan>[];
        }
        return data
            .map((item) => ItemLahan.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      },
    );

    return response;
  }

  /// Mengambil detail lahan dari `GET /api/v1/lahan/{id}`.
  Future<ApiResponse<ItemLahan>> getLahanDetail(String id) async {
    return await _client.get<ItemLahan>(
      '${ApiConstants.lahanEndpoint}/$id',
      fromJson: (data) => ItemLahan.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Mendaftarkan lahan baru melalui `POST /api/v1/lahan`.
  Future<ApiResponse<ItemLahan>> createLahan(Map<String, dynamic> payload) async {
    return await _client.post<ItemLahan>(
      ApiConstants.lahanEndpoint,
      data: payload,
      fromJson: (data) => ItemLahan.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Mendaftarkan lahan baru beserta foto melalui `POST /api/v1/lahan`.
  Future<ApiResponse<ItemLahan>> createLahanWithFoto(
    Map<String, dynamic> payload,
    MultipartFile? fotoLahan,
  ) async {
    final mapData = <String, dynamic>{
      ...payload,
    };
    if (fotoLahan != null) {
      mapData['foto_lahan'] = fotoLahan;
    }
    final formData = FormData.fromMap(mapData);

    return await _client.post<ItemLahan>(
      ApiConstants.lahanEndpoint,
      data: formData,
      fromJson: (data) => ItemLahan.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Memperbarui data lahan melalui `PUT /api/v1/lahan/{id}` (JSON biasa tanpa file).
  Future<ApiResponse<ItemLahan>> updateLahan(String id, Map<String, dynamic> payload) async {
    return await _client.put<ItemLahan>(
      '${ApiConstants.lahanEndpoint}/$id',
      data: payload,
      fromJson: (data) => ItemLahan.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Memperbarui data lahan beserta foto melalui `POST /api/v1/lahan/{id}` dengan method spoofing `_method=PUT`.
  /// Laravel memerlukan POST multipart/form-data dengan field _method=PUT karena PHP native tidak mem-parse body PUT multipart.
  Future<ApiResponse<ItemLahan>> updateLahanWithFoto(
    String id,
    Map<String, dynamic> payload,
    MultipartFile? fotoLahan,
  ) async {
    final mapData = <String, dynamic>{
      '_method': 'PUT',
      ...payload,
    };
    if (fotoLahan != null) {
      mapData['foto_lahan'] = fotoLahan;
    }
    final formData = FormData.fromMap(mapData);

    return await _client.post<ItemLahan>(
      '${ApiConstants.lahanEndpoint}/$id',
      data: formData,
      fromJson: (data) => ItemLahan.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Menghapus data lahan melalui `DELETE /api/v1/lahan/{id}`.
  Future<ApiResponse<bool>> deleteLahan(String id) async {
    return await _client.delete<bool>(
      '${ApiConstants.lahanEndpoint}/$id',
      fromJson: (_) => true,
    );
  }

  /// Mengambil daftar master komoditas dari `GET /api/v1/komoditas`.
  Future<ApiResponse<List<ItemKomoditas>>> getKomoditasList() async {
    return await _client.get<List<ItemKomoditas>>(
      ApiConstants.komoditasEndpoint,
      fromJson: (data) {
        if (data is! List) {
          return <ItemKomoditas>[];
        }
        return data
            .map((item) => ItemKomoditas.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      },
    );
  }
}
