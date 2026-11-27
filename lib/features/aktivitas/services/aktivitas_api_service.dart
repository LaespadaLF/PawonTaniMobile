import 'package:dio/dio.dart';
import 'package:pawon_mobile/core/constants/api_constants.dart';
import 'package:pawon_mobile/core/network/api_response.dart';
import 'package:pawon_mobile/core/network/dio_client.dart';
import 'package:pawon_mobile/core/storage/pawon_database_service.dart';
import 'package:pawon_mobile/features/aktivitas/models/item_aktivitas_tanam.dart';

/// Service networking untuk modul Aktivitas Tanam memanggil API backend Laravel.
class AktivitasApiService {
  final DioClient _client;

  AktivitasApiService({DioClient? client}) : _client = client ?? DioClient();

  /// Mengambil daftar aktivitas tanam dengan parameter filter opsional.
  Future<ApiResponse<List<PlantActivityItem>>> getAktivitasList({
    String? lahanId,
    String? idSiklus,
    String? kategori,
    String? kondisi,
    String? query,
  }) async {
    final queryParams = <String, dynamic>{};
    if (lahanId != null && lahanId.isNotEmpty) queryParams['id_lahan'] = lahanId;
    if (idSiklus != null && idSiklus.isNotEmpty) queryParams['id_siklus'] = idSiklus;
    if (kategori != null && kategori.isNotEmpty && kategori != 'Semua') {
      queryParams['kategori'] = kategori;
    }
    if (kondisi != null && kondisi.isNotEmpty && kondisi != 'Semua') {
      queryParams['kondisi'] = kondisi;
    }
    if (query != null && query.isNotEmpty) queryParams['q'] = query;

    try {
      final response = await _client.get<List<PlantActivityItem>>(
        ApiConstants.aktivitasEndpoint,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        fromJson: (data) {
          if (data is! List) return <PlantActivityItem>[];
          return data
              .map((item) => PlantActivityItem.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList();
        },
      );

      if (response.success && response.data != null && response.data!.isNotEmpty) {
        final cacheList = response.data!.map((a) => {
          'id': a.id,
          'title': a.title,
          'crop_name': a.cropName,
          'category': a.category.label,
          'condition': a.condition.label,
          'date': a.date,
          'time': a.time,
          'location': a.location,
          'block_area': a.blockArea,
          'notes': a.notes,
          'lahan_id': a.lahanId,
          'biaya': a.biaya,
          'image_url': a.imageUrl,
        }).toList();
        PawonDatabaseService.instance.cacheAktivitasList(cacheList);
      }

      return response;
    } catch (e) {
      // Fallback: baca dari SQLite lokal saat offline
      try {
        final localRows = await PawonDatabaseService.instance.getLocalAktivitasList();
        if (localRows.isNotEmpty) {
          final items = localRows.map((row) {
            return PlantActivityItem(
              id: row['id']?.toString() ?? '',
              title: row['judul']?.toString() ?? 'Aktivitas',
              cropName: row['komoditas']?.toString() ?? '',
              category: ActivityCategory.fromString(row['kategori']?.toString()),
              condition: PlantCondition.fromString(row['kondisi']?.toString()),
              date: row['tanggal']?.toString() ?? '',
              time: row['waktu']?.toString() ?? '',
              location: row['lokasi']?.toString() ?? '',
              blockArea: row['blok']?.toString() ?? '',
              notes: row['catatan']?.toString() ?? '',
              lahanId: row['lahan_id']?.toString(),
              biaya: (row['biaya'] as num?)?.toDouble(),
              imageUrl: row['foto_url']?.toString(),
            );
          }).toList();
          return ApiResponse.success(
            data: items,
            message: 'Menampilkan data aktivitas dari penyimpanan offline.',
          );
        }
      } catch (_) {}
      rethrow;
    }
  }

  /// Mengambil detail satu aktivitas berdasarkan ID.
  Future<ApiResponse<PlantActivityItem>> getAktivitasDetail(String id) async {
    return await _client.get<PlantActivityItem>(
      '${ApiConstants.aktivitasEndpoint}/$id',
      fromJson: (data) => PlantActivityItem.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Menyimpan aktivitas baru (bisa dengan upload foto multipart).
  Future<ApiResponse<PlantActivityItem>> createAktivitas(
    Map<String, dynamic> payload, {
    MultipartFile? fotoAktivitas,
    List<MultipartFile>? fotoAktivitasList,
  }) async {
    try {
      final list = fotoAktivitasList ?? const <MultipartFile>[];
      if (list.isNotEmpty || fotoAktivitas != null) {
        final formData = FormData();
        payload.forEach((key, value) {
          if (value == null) return;
          if (value is Iterable) {
            final items = value.map((e) => e.toString()).toList();
            if (items.isEmpty) {
              formData.fields.add(MapEntry('$key[]', ''));
            } else {
              for (final item in items) {
                formData.fields.add(MapEntry('$key[]', item));
              }
            }
            return;
          }
          formData.fields.add(
            MapEntry(key, value is bool ? (value ? '1' : '0') : value.toString()),
          );
        });

        if (list.isNotEmpty) {
          for (final f in list) {
            formData.files.add(MapEntry('foto_aktivitas_list[]', f));
          }
        } else if (fotoAktivitas != null) {
          formData.files.add(MapEntry('foto_aktivitas', fotoAktivitas));
        }

        return await _client.post<PlantActivityItem>(
          ApiConstants.aktivitasEndpoint,
          data: formData,
          fromJson: (data) => PlantActivityItem.fromJson(Map<String, dynamic>.from(data as Map)),
        );
      }

      return await _client.post<PlantActivityItem>(
        ApiConstants.aktivitasEndpoint,
        data: payload,
        fromJson: (data) => PlantActivityItem.fromJson(Map<String, dynamic>.from(data as Map)),
      );
    } catch (e) {
      // Simpan ke antrean sinkronisasi offline saat koneksi gagal
      try {
        await PawonDatabaseService.instance.enqueueOffline(
          tipe: 'aktivitas',
          aksi: 'create',
          payload: payload,
        );
        return ApiResponse.success(
          data: PlantActivityItem(
            id: 'OFFLINE-${DateTime.now().millisecondsSinceEpoch}',
            title: payload['nama_aktivitas']?.toString() ?? payload['title']?.toString() ?? 'Aktivitas Baru',
            cropName: payload['crop_name']?.toString() ?? 'Komoditas',
            category: ActivityCategory.fromString(payload['kategori']?.toString()),
            condition: PlantCondition.fromString(payload['kondisi']?.toString()),
            date: payload['tanggal']?.toString() ?? DateTime.now().toIso8601String().substring(0, 10),
            time: payload['waktu']?.toString() ?? '08:00',
            location: payload['lokasi']?.toString() ?? '',
            blockArea: payload['blok']?.toString() ?? '',
            notes: payload['catatan']?.toString() ?? '',
            lahanId: payload['id_lahan']?.toString(),
            biaya: double.tryParse(payload['biaya']?.toString() ?? '0'),
          ),
          message: 'Aktivitas tersimpan secara offline (draft). Akan disinkronkan saat terhubung internet.',
        );
      } catch (_) {}
      rethrow;
    }
  }

  /// Memperbarui aktivitas (bisa dengan upload foto baru melalui spoofing _method=PUT).
  Future<ApiResponse<PlantActivityItem>> updateAktivitas(
    String id,
    Map<String, dynamic> payload, {
    MultipartFile? fotoAktivitas,
    List<MultipartFile>? fotoAktivitasList,
  }) async {
    final list = fotoAktivitasList ?? const <MultipartFile>[];
    final hasExistingPhotos = payload.containsKey('existing_photos');
    if (list.isNotEmpty || fotoAktivitas != null || hasExistingPhotos) {
      final formData = FormData();
      formData.fields.add(const MapEntry('_method', 'PUT'));

      payload.forEach((key, value) {
        if (value == null) return;
        if (value is Iterable) {
          final items = value.map((e) => e.toString()).toList();
          if (items.isEmpty) {
            formData.fields.add(MapEntry('$key[]', ''));
          } else {
            for (final item in items) {
              formData.fields.add(MapEntry('$key[]', item));
            }
          }
          return;
        }
        formData.fields.add(
          MapEntry(key, value is bool ? (value ? '1' : '0') : value.toString()),
        );
      });

      if (list.isNotEmpty) {
        for (final f in list) {
          formData.files.add(MapEntry('foto_aktivitas_list[]', f));
        }
      } else if (fotoAktivitas != null) {
        formData.files.add(MapEntry('foto_aktivitas', fotoAktivitas));
      }

      return await _client.post<PlantActivityItem>(
        '${ApiConstants.aktivitasEndpoint}/$id',
        data: formData,
        fromJson: (data) => PlantActivityItem.fromJson(Map<String, dynamic>.from(data as Map)),
      );
    }

    return await _client.put<PlantActivityItem>(
      '${ApiConstants.aktivitasEndpoint}/$id',
      data: payload,
      fromJson: (data) => PlantActivityItem.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Menghapus aktivitas (soft delete).
  Future<ApiResponse<void>> deleteAktivitas(String id) async {
    return await _client.delete<void>(
      '${ApiConstants.aktivitasEndpoint}/$id',
      fromJson: (_) {},
    );
  }
}

