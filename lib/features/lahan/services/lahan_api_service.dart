import 'package:dio/dio.dart';
import 'package:pawon_mobile/core/constants/api_constants.dart';
import 'package:pawon_mobile/core/network/api_response.dart';
import 'package:pawon_mobile/core/network/dio_client.dart';
import 'package:pawon_mobile/features/lahan/models/item_lahan.dart';

/// Service networking untuk memanggil endpoint lahan backend Laravel.
class LahanApiService {
  final DioClient _client;

  LahanApiService({DioClient? client}) : _client = client ?? DioClient();

  /// Mengambil daftar lahan milik anggota yang login dari
  /// `GET /api/v1/lahan`.
  Future<ApiResponse<List<ItemLahan>>> getLahanList() async {
    final response = await _client.get<List<ItemLahan>>(
      ApiConstants.lahanEndpoint,
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
    final formData = FormData.fromMap({
      ...payload,
      if (fotoLahan != null) 'foto_lahan': fotoLahan,
    });

    return await _client.post<ItemLahan>(
      ApiConstants.lahanEndpoint,
      data: formData,
      fromJson: (data) => ItemLahan.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Memperbarui data lahan melalui `PUT /api/v1/lahan/{id}`.
  Future<ApiResponse<ItemLahan>> updateLahan(String id, Map<String, dynamic> payload) async {
    return await _client.put<ItemLahan>(
      '${ApiConstants.lahanEndpoint}/$id',
      data: payload,
      fromJson: (data) => ItemLahan.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Memperbarui data lahan beserta foto melalui `PUT /api/v1/lahan/{id}`.
  Future<ApiResponse<ItemLahan>> updateLahanWithFoto(
    String id,
    Map<String, dynamic> payload,
    MultipartFile? fotoLahan,
  ) async {
    final formData = FormData.fromMap({
      ...payload,
      if (fotoLahan != null) 'foto_lahan': fotoLahan,
    });

    return await _client.put<ItemLahan>(
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
}
