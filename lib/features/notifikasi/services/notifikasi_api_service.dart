import 'package:pawon_mobile/core/constants/api_constants.dart';
import 'package:pawon_mobile/core/network/api_response.dart';
import 'package:pawon_mobile/core/network/dio_client.dart';
import 'package:pawon_mobile/features/notifikasi/models/item_notifikasi.dart';

/// Layanan API untuk modul Notifikasi PawonTani Mobile.
/// Berkomunikasi dengan endpoint REST API Notification di backend Laravel:
/// - GET /api/v1/notifikasi (list & pagination)
/// - GET /api/v1/notifikasi/unread-count (badge)
/// - PATCH /api/v1/notifikasi/{id}/baca (mark single read)
/// - POST /api/v1/notifikasi/baca-semua (mark all read)
class NotifikasiApiService {
  final DioClient _client;

  NotifikasiApiService({DioClient? client}) : _client = client ?? DioClient();

  /// Mengambil daftar notifikasi pengguna login.
  /// Parameter:
  /// - [filter]: 'semua' (default) atau 'belum_dibaca'
  /// - [page]: nomor halaman (default: 1, 15 item per halaman)
  Future<ApiResponse<List<ItemNotifikasi>>> getNotifikasiList({
    String filter = 'semua',
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      'filter': filter,
      'page': page,
    };

    return await _client.get<List<ItemNotifikasi>>(
      ApiConstants.notifikasiEndpoint,
      queryParameters: queryParams,
      fromJson: (data) {
        if (data is! List) {
          return <ItemNotifikasi>[];
        }
        return data
            .map((item) => ItemNotifikasi.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      },
    );
  }

  /// Mengambil jumlah notifikasi yang belum dibaca (untuk badge icon bell).
  Future<ApiResponse<int>> getUnreadCount() async {
    return await _client.get<int>(
      ApiConstants.notifikasiUnreadCountEndpoint,
      fromJson: (data) {
        if (data is Map && data['unread_count'] != null) {
          return int.tryParse(data['unread_count'].toString()) ?? 0;
        }
        return 0;
      },
    );
  }

  /// Menandai satu notifikasi tertentu sebagai sudah dibaca (Idempotent).
  Future<ApiResponse<ItemNotifikasi>> markAsRead(String id) async {
    return await _client.patch<ItemNotifikasi>(
      ApiConstants.notifikasiBacaEndpoint(id),
      fromJson: (data) {
        if (data is Map) {
          return ItemNotifikasi.fromJson(Map<String, dynamic>.from(data));
        }
        throw Exception('Format data notifikasi tidak valid');
      },
    );
  }

  /// Menandai semua notifikasi belum dibaca milik pengguna sebagai sudah dibaca (Idempotent).
  /// Mengembalikan jumlah record yang diperbarui.
  Future<ApiResponse<int>> markAllAsRead() async {
    return await _client.post<int>(
      ApiConstants.notifikasiBacaSemuaEndpoint,
      fromJson: (data) {
        if (data is Map && data['updated_count'] != null) {
          return int.tryParse(data['updated_count'].toString()) ?? 0;
        }
        return 0;
      },
    );
  }
}
