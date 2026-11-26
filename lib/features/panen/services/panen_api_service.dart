import 'package:dio/dio.dart';
import 'package:pawon_mobile/core/constants/api_constants.dart';
import 'package:pawon_mobile/core/network/api_response.dart';
import 'package:pawon_mobile/core/network/dio_client.dart';
import 'package:pawon_mobile/core/storage/pawon_database_service.dart';
import 'package:pawon_mobile/features/panen/models/item_panen.dart';
import 'package:pawon_mobile/features/panen/services/panen_multipart.dart';

/// Service networking untuk modul Panen memanggil API backend Laravel.
/// Dilengkapi fallback SQLite Local Storage saat perangkat offline.
class PanenApiService {
  final DioClient _client;

  PanenApiService({DioClient? client}) : _client = client ?? DioClient();

  /// Mengambil daftar panen dengan parameter filter opsional.
  /// Otomatis menyimpan cache ke SQLite saat online, dan membaca SQLite saat offline.
  Future<ApiResponse<List<HarvestItem>>> getPanenList({
    String? status,
    String? cropType,
    String? lahanId,
    String? idSiklus,
    String? query,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null && status.isNotEmpty && status != 'Semua') {
      queryParams['status'] = status.toLowerCase();
    }
    if (cropType != null && cropType.isNotEmpty && cropType != 'Semua') {
      queryParams['crop_type'] = cropType.toLowerCase();
    }
    if (lahanId != null && lahanId.isNotEmpty) {
      queryParams['id_lahan'] = lahanId;
    }
    if (idSiklus != null && idSiklus.isNotEmpty) {
      queryParams['id_siklus'] = idSiklus;
    }
    if (query != null && query.isNotEmpty) {
      queryParams['q'] = query;
    }

    try {
      final response = await _client.get<List<HarvestItem>>(
        ApiConstants.panenEndpoint,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        fromJson: (data) {
          if (data is! List) return <HarvestItem>[];
          return data
              .map((item) => HarvestItem.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList();
        },
      );

      // Jika berhasil online, simpan cache ke SQLite
      if (response.success && response.data != null && response.data!.isNotEmpty) {
        final cacheList = response.data!.map((h) => {
          'id': h.id,
          'kode_panen': h.harvestCode,
          'komoditas_nama': h.cropType.displayName,
          'varietas': h.title,
          'jumlah_berat': h.weightKg,
          'satuan_berat': 'kg',
          'tanggal_panen': h.date,
          'status': h.status.displayName,
          'catatan': h.fieldNotes,
        }).toList();
        PawonDatabaseService.instance.cachePanenList(cacheList);
      }

      return response;
    } catch (e) {
      // Fallback: Baca dari SQLite Local Storage jika jaringan terputus (Offline)
      final localRows = await PawonDatabaseService.instance.getLocalPanenList();
      if (localRows.isNotEmpty) {
        final offlineItems = localRows.map((row) => HarvestItem(
          id: row['id']?.toString() ?? '',
          harvestCode: row['kode_panen']?.toString() ?? 'PN-OFFLINE',
          title: row['varietas']?.toString() ?? 'Panen',
          subtitle: 'Tersimpan di SQLite Lokal',
          cropType: CropType.fromString(row['komoditas_nama']?.toString()),
          status: HarvestStatus.fromString(row['status']?.toString()),
          location: 'Penyimpanan Offline',
          blockArea: '',
          date: row['tanggal_panen']?.toString() ?? '',
          season: 'Musim Berjalan',
          weightKg: (row['jumlah_berat'] as num?)?.toDouble() ?? 0.0,
          qualityGrade: 'A',
          moistureOrNotes: 'Offline Cache',
          fieldNotes: row['catatan']?.toString() ?? '',
        )).toList();

        return ApiResponse<List<HarvestItem>>(
          success: true,
          message: 'Menampilkan data offline dari SQLite lokal',
          data: offlineItems,
        );
      }
      rethrow;
    }
  }

  /// Mengambil detail satu hasil panen berdasarkan ID.
  Future<ApiResponse<HarvestItem>> getPanenDetail(String id) async {
    return await _client.get<HarvestItem>(
      '${ApiConstants.panenEndpoint}/$id',
      fromJson: (data) => HarvestItem.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Mencatat panen baru (bisa dengan upload foto / multiple foto multipart).
  Future<ApiResponse<HarvestItem>> createPanen(
    Map<String, dynamic> payload, {
    MultipartFile? fotoPanen,
    List<MultipartFile>? fotoPanenList,
  }) async {
    final hasFiles = fotoPanen != null || (fotoPanenList != null && fotoPanenList.isNotEmpty);

    if (hasFiles) {
      final formData = bangunFormDataPanen(
        payload,
        fotoPanen: fotoPanen,
        fotoPanenList: fotoPanenList,
      );
      return await _client.post<HarvestItem>(
        ApiConstants.panenEndpoint,
        data: formData,
        fromJson: (data) => HarvestItem.fromJson(Map<String, dynamic>.from(data as Map)),
      );
    }

    return await _client.post<HarvestItem>(
      ApiConstants.panenEndpoint,
      data: payload,
      fromJson: (data) => HarvestItem.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Memperbarui catatan panen (bisa dengan foto baru / multiple foto multipart).
  Future<ApiResponse<HarvestItem>> updatePanen(
    String id,
    Map<String, dynamic> payload, {
    MultipartFile? fotoPanen,
    List<MultipartFile>? fotoPanenList,
  }) async {
    final hasFiles = fotoPanen != null || (fotoPanenList != null && fotoPanenList.isNotEmpty);

    if (hasFiles) {
      final formData = bangunFormDataPanen(
        payload,
        fotoPanen: fotoPanen,
        fotoPanenList: fotoPanenList,
      );
      // Laravel route POST /panen/{id} untuk multipart update
      return await _client.post<HarvestItem>(
        '${ApiConstants.panenEndpoint}/$id',
        data: formData,
        fromJson: (data) => HarvestItem.fromJson(Map<String, dynamic>.from(data as Map)),
      );
    }

    return await _client.put<HarvestItem>(
      '${ApiConstants.panenEndpoint}/$id',
      data: payload,
      fromJson: (data) => HarvestItem.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Menghapus catatan hasil panen.
  Future<ApiResponse<dynamic>> deletePanen(String id) async {
    return await _client.delete<dynamic>(
      '${ApiConstants.panenEndpoint}/$id',
      fromJson: (data) => data,
    );
  }
}
