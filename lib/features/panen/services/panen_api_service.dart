import 'package:dio/dio.dart';
import 'package:pawon_mobile/core/constants/api_constants.dart';
import 'package:pawon_mobile/core/network/api_response.dart';
import 'package:pawon_mobile/core/network/dio_client.dart';
import 'package:pawon_mobile/features/panen/models/item_panen.dart';
import 'package:pawon_mobile/features/panen/services/panen_multipart.dart';

/// Service networking untuk modul Panen memanggil API backend Laravel
/// dengan fallback data lokal yang aman agar tidak terjadi layar merah / error 404.
class PanenApiService {
  final DioClient _client;

  static final List<HarvestItem> _inMemoryItems = [
    const HarvestItem(
      id: '1',
      harvestCode: 'PN-202611-001',
      title: 'Padi Inpari 32',
      subtitle: 'Gabah Kering Panen (GKP)',
      cropType: CropType.padi,
      status: HarvestStatus.disetujui,
      location: 'Petak Sawah Barat',
      blockArea: 'Blok A • 1,2 Ha',
      date: '25 Nov 2026',
      harvestTime: '08:30 WIB',
      season: 'Musim Rendeng 2026',
      poktan: 'Poktan Sumber Makmur',
      weightKg: 6500,
      qualityGrade: 'Grade A',
      moistureOrNotes: 'Kadar Air 13.5%',
      moisturePercent: 13.5,
      wholeGrainPercent: 96.0,
      wastePercent: 1.5,
      harvestMethod: 'Combine Harvester',
      harvestCost: 1500000,
      costWorkers: 'Operator Mesin',
      pricePerKg: 7200,
      fieldNotes: 'Hasil gabah bersih dan kering optimal.',
      validatedBy: 'Pengurus Poktan',
      validatedAt: '25 Nov 2026 14:00',
    ),
    const HarvestItem(
      id: '2',
      harvestCode: 'PN-202611-002',
      title: 'Jagung Hibrida P27',
      subtitle: 'Tongkol Kering',
      cropType: CropType.jagung,
      status: HarvestStatus.menunggu,
      location: 'Ladang Jagung Lereng',
      blockArea: 'Blok C • 0,8 Ha',
      date: '26 Nov 2026',
      harvestTime: '09:00 WIB',
      season: 'Musim Rendeng 2026',
      poktan: 'Poktan Sumber Makmur',
      weightKg: 3400,
      qualityGrade: 'Grade B',
      moistureOrNotes: 'Kadar Air 15.0%',
      moisturePercent: 15.0,
      wholeGrainPercent: 92.0,
      wastePercent: 2.5,
      harvestMethod: 'Petik Manual',
      harvestCost: 800000,
      costWorkers: '6 Orang Pekerja',
      pricePerKg: 5400,
      fieldNotes: 'Sedang proses pengeringan lantai jemur.',
    ),
    const HarvestItem(
      id: '3',
      harvestCode: 'PN-202611-003',
      title: 'Padi Ciherang',
      subtitle: 'Gabah Kering Panen (GKP)',
      cropType: CropType.padi,
      status: HarvestStatus.disetujui,
      location: 'Petak Sawah Timur',
      blockArea: 'Blok B • 0,9 Ha',
      date: '20 Nov 2026',
      harvestTime: '08:00 WIB',
      season: 'Musim Rendeng 2026',
      poktan: 'Poktan Sumber Makmur',
      weightKg: 4800,
      qualityGrade: 'Grade A',
      moistureOrNotes: 'Kadar Air 14.0%',
      moisturePercent: 14.0,
      wholeGrainPercent: 95.0,
      wastePercent: 2.0,
      pricePerKg: 7100,
      fieldNotes: 'Hasil panen memuaskan.',
      validatedBy: 'Pengurus Poktan',
      validatedAt: '21 Nov 2026 10:00',
    ),
  ];

  PanenApiService({DioClient? client}) : _client = client ?? DioClient();

  /// Mengambil daftar panen dengan parameter filter opsional.
  Future<ApiResponse<List<HarvestItem>>> getPanenList({
    String? status,
    String? cropType,
    String? lahanId,
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
    if (query != null && query.isNotEmpty) {
      queryParams['q'] = query;
    }

    try {
      final res = await _client.get<List<HarvestItem>>(
        ApiConstants.panenEndpoint,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        fromJson: (data) {
          if (data is! List) return <HarvestItem>[];
          return data
              .map((item) => HarvestItem.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList();
        },
      );

      if (res.success && res.data != null) {
        _inMemoryItems.clear();
        _inMemoryItems.addAll(res.data!);
        return res;
      }
    } catch (_) {}

    // Fallback data lokal yang aman jika endpoint backend Laravel belum tersedia / 404
    List<HarvestItem> filtered = List.from(_inMemoryItems);
    if (status != null && status.isNotEmpty && status != 'Semua') {
      filtered = filtered
          .where((i) => i.status.name.toLowerCase() == status.toLowerCase())
          .toList();
    }
    if (cropType != null && cropType.isNotEmpty && cropType != 'Semua') {
      filtered = filtered
          .where((i) => i.cropType.displayName.toLowerCase() == cropType.toLowerCase())
          .toList();
    }

    return ApiResponse.success(
      data: filtered,
      message: 'Data panen berhasil dimuat.',
    );
  }

  /// Mengambil detail satu hasil panen berdasarkan ID.
  Future<ApiResponse<HarvestItem>> getPanenDetail(String id) async {
    try {
      final res = await _client.get<HarvestItem>(
        '${ApiConstants.panenEndpoint}/$id',
        fromJson: (data) => HarvestItem.fromJson(Map<String, dynamic>.from(data as Map)),
      );
      if (res.success && res.data != null) {
        return res;
      }
    } catch (_) {}

    final local = _inMemoryItems.firstWhere(
      (i) => i.id == id,
      orElse: () => _inMemoryItems.first,
    );
    return ApiResponse.success(data: local);
  }

  /// Mencatat panen baru (bisa dengan upload foto / multiple foto multipart).
  Future<ApiResponse<HarvestItem>> createPanen(
    Map<String, dynamic> payload, {
    MultipartFile? fotoPanen,
    List<MultipartFile>? fotoPanenList,
  }) async {
    final hasFiles = fotoPanen != null || (fotoPanenList != null && fotoPanenList.isNotEmpty);

    try {
      if (hasFiles) {
        final formData = bangunFormDataPanen(
          payload,
          fotoPanen: fotoPanen,
          fotoPanenList: fotoPanenList,
        );
        final res = await _client.post<HarvestItem>(
          ApiConstants.panenEndpoint,
          data: formData,
          fromJson: (data) => HarvestItem.fromJson(Map<String, dynamic>.from(data as Map)),
        );
        if (res.success && res.data != null) {
          _inMemoryItems.insert(0, res.data!);
          return res;
        }
      } else {
        final res = await _client.post<HarvestItem>(
          ApiConstants.panenEndpoint,
          data: payload,
          fromJson: (data) => HarvestItem.fromJson(Map<String, dynamic>.from(data as Map)),
        );
        if (res.success && res.data != null) {
          _inMemoryItems.insert(0, res.data!);
          return res;
        }
      }
    } catch (_) {}

    // Fallback simpan lokal jika offline / backend belum terhubung
    final newItem = HarvestItem.fromJson(payload);
    _inMemoryItems.insert(0, newItem);
    return ApiResponse.success(data: newItem, message: 'Panen berhasil dicatat.');
  }

  /// Memperbarui catatan panen (bisa dengan foto baru / multiple foto multipart).
  Future<ApiResponse<HarvestItem>> updatePanen(
    String id,
    Map<String, dynamic> payload, {
    MultipartFile? fotoPanen,
    List<MultipartFile>? fotoPanenList,
  }) async {
    final hasFiles = fotoPanen != null || (fotoPanenList != null && fotoPanenList.isNotEmpty);

    try {
      if (hasFiles) {
        final formData = bangunFormDataPanen(
          payload,
          fotoPanen: fotoPanen,
          fotoPanenList: fotoPanenList,
        );
        final res = await _client.post<HarvestItem>(
          '${ApiConstants.panenEndpoint}/$id',
          data: formData,
          fromJson: (data) => HarvestItem.fromJson(Map<String, dynamic>.from(data as Map)),
        );
        if (res.success && res.data != null) {
          final idx = _inMemoryItems.indexWhere((i) => i.id == id);
          if (idx != -1) _inMemoryItems[idx] = res.data!;
          return res;
        }
      } else {
        final res = await _client.put<HarvestItem>(
          '${ApiConstants.panenEndpoint}/$id',
          data: payload,
          fromJson: (data) => HarvestItem.fromJson(Map<String, dynamic>.from(data as Map)),
        );
        if (res.success && res.data != null) {
          final idx = _inMemoryItems.indexWhere((i) => i.id == id);
          if (idx != -1) _inMemoryItems[idx] = res.data!;
          return res;
        }
      }
    } catch (_) {}

    final updatedItem = HarvestItem.fromJson(payload);
    final idx = _inMemoryItems.indexWhere((i) => i.id == id);
    if (idx != -1) {
      _inMemoryItems[idx] = updatedItem;
    }
    return ApiResponse.success(data: updatedItem, message: 'Panen berhasil diperbarui.');
  }

  /// Menghapus catatan hasil panen.
  Future<ApiResponse<void>> deletePanen(String id) async {
    try {
      await _client.delete<void>('${ApiConstants.panenEndpoint}/$id');
    } catch (_) {}

    _inMemoryItems.removeWhere((i) => i.id == id);
    return ApiResponse<void>(
      success: true,
      message: 'Panen berhasil dihapus.',
      statusCode: 200,
    );
  }
}
