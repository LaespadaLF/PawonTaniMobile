import 'package:pawon_mobile/core/network/api_response.dart';
import 'package:pawon_mobile/core/network/dio_client.dart';
import 'package:pawon_mobile/features/artikel/models/item_artikel.dart';

/// Service networking untuk modul Edukasi Pertanian (Artikel, Tips, Panduan).
class ArtikelApiService {
  final DioClient _client;

  ArtikelApiService({DioClient? client}) : _client = client ?? DioClient();

  /// Mengambil daftar artikel/tips/panduan dari `GET /api/v1/edukasi`.
  Future<ApiResponse<List<ArticleItem>>> getEdukasiList({
    String? kategori,
    String? query,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};
    if (kategori != null && kategori.isNotEmpty && kategori.toLowerCase() != 'semua') {
      queryParams['kategori'] = kategori.toLowerCase();
    }
    if (query != null && query.trim().isNotEmpty) {
      queryParams['q'] = query.trim();
    }
    if (limit != null && limit > 0) {
      queryParams['limit'] = limit;
    }

    return await _client.get<List<ArticleItem>>(
      '/edukasi',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (data) {
        if (data is! List) return <ArticleItem>[];
        return data
            .map((item) => ArticleItem.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      },
    );
  }

  /// Mengambil detail satu item edukasi dari `GET /api/v1/edukasi/{type}/{id}`.
  Future<ApiResponse<ArticleItem>> getEdukasiDetail(String type, String id) async {
    return await _client.get<ArticleItem>(
      '/edukasi/${type.toLowerCase()}/$id',
      fromJson: (data) => ArticleItem.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }
}
