import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pawon_mobile/core/constants/api_constants.dart';
import 'package:pawon_mobile/core/network/api_response.dart';
import 'package:pawon_mobile/core/network/dio_client.dart';
import 'package:pawon_mobile/core/storage/pawon_database_service.dart';
import 'package:pawon_mobile/features/lahan/models/item_dokumen_sppt.dart';
import 'package:pawon_mobile/features/lahan/models/item_komoditas.dart';
import 'package:pawon_mobile/features/lahan/models/item_lahan.dart';
import 'package:pawon_mobile/features/lahan/models/item_siklus_tanam.dart';

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

    try {
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

      if (response.success && response.data != null && response.data!.isNotEmpty) {
        final cacheList = response.data!.map((l) => {
          'id': l.id,
          'nama': l.nama,
          'luas': l.luas,
          'lokasi': l.lokasi,
          'komoditas': l.komoditas,
          'status_penguasaan': l.statusPenguasaan,
          'status_verifikasi': l.statusVerifikasi,
          'latitude': l.latitude,
          'longitude': l.longitude,
          'foto_lahan': l.fotoLahan,
        }).toList();
        PawonDatabaseService.instance.cacheLahanList(cacheList);
      }

      return response;
    } catch (e) {
      // Fallback: ambil data dari SQLite lokal saat offline
      try {
        final localRows = await PawonDatabaseService.instance.getLocalLahanList();
        if (localRows.isNotEmpty) {
          final items = localRows.map((row) {
            return ItemLahan(
              id: row['id']?.toString() ?? '',
              nama: row['nama_lahan']?.toString() ?? 'Lahan',
              lokasi: row['alamat']?.toString() ?? '',
              luas: (row['luas_m2'] as num?)?.toDouble() ?? 0.0,
              komoditas: row['komoditas']?.toString() ?? '',
              statusPenguasaan: row['status_penguasaan']?.toString() ?? 'Milik Sendiri',
              status: StatusLahan.aktif,
              latitude: (row['latitude'] as num?)?.toDouble(),
              longitude: (row['longitude'] as num?)?.toDouble(),
              fotoLahan: row['foto_lahan']?.toString(),
              statusVerifikasi: row['status_verifikasi']?.toString() ?? 'menunggu_verifikasi',
            );
          }).toList();
          return ApiResponse.success(
            data: items,
            message: 'Menampilkan data lahan dari penyimpanan offline.',
          );
        }
      } catch (_) {}
      rethrow;
    }
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

  /// Mendaftarkan lahan baru beserta foto dan SPPT melalui `POST /api/v1/lahan`.
  Future<ApiResponse<ItemLahan>> createLahanWithFoto(
    Map<String, dynamic> payload,
    MultipartFile? fotoLahan, {
    List<MultipartFile>? fotoLahanList,
    MultipartFile? dokumenSppt,
  }) async {
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

    final list = fotoLahanList ?? const <MultipartFile>[];
    if (list.isNotEmpty) {
      for (final f in list) {
        formData.files.add(MapEntry('foto_lahan_list[]', f));
      }
    } else if (fotoLahan != null) {
      formData.files.add(MapEntry('foto_lahan', fotoLahan));
    }

    if (dokumenSppt != null) {
      formData.files.add(MapEntry('dokumen_sppt', dokumenSppt));
    }

    try {
      return await _client.post<ItemLahan>(
        ApiConstants.lahanEndpoint,
        data: formData,
        fromJson: (data) => ItemLahan.fromJson(Map<String, dynamic>.from(data as Map)),
      );
    } catch (e) {
      // Simpan ke antrean sinkronisasi offline saat koneksi gagal
      try {
        await PawonDatabaseService.instance.enqueueOffline(
          tipe: 'lahan',
          aksi: 'create',
          payload: payload,
        );
        return ApiResponse.success(
          data: ItemLahan(
            id: 'OFFLINE-${DateTime.now().millisecondsSinceEpoch}',
            nama: payload['nama_lahan']?.toString() ?? 'Lahan Baru',
            lokasi: payload['alamat_lahan']?.toString() ?? '',
            luas: double.tryParse(payload['luas_lahan']?.toString() ?? '0') ?? 0.0,
            komoditas: 'Belum Ditentukan',
            statusPenguasaan: payload['status_penguasaan']?.toString() ?? 'Milik Sendiri',
            status: StatusLahan.persiapan,
          ),
          message: 'Lahan tersimpan secara offline (draft). Akan disinkronkan saat terhubung internet.',
        );
      } catch (_) {}
      rethrow;
    }
  }

  /// Memperbarui data lahan melalui `PUT /api/v1/lahan/{id}` (JSON biasa tanpa file).
  Future<ApiResponse<ItemLahan>> updateLahan(String id, Map<String, dynamic> payload) async {
    return await _client.put<ItemLahan>(
      '${ApiConstants.lahanEndpoint}/$id',
      data: payload,
      fromJson: (data) => ItemLahan.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Memperbarui data lahan beserta foto dan SPPT melalui `POST /api/v1/lahan/{id}` dengan method spoofing `_method=PUT`.
  /// Laravel memerlukan POST multipart/form-data dengan field _method=PUT karena PHP native tidak mem-parse body PUT multipart.
  Future<ApiResponse<ItemLahan>> updateLahanWithFoto(
    String id,
    Map<String, dynamic> payload,
    MultipartFile? fotoLahan, {
    List<MultipartFile>? fotoLahanList,
    MultipartFile? dokumenSppt,
  }) async {
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

    final list = fotoLahanList ?? const <MultipartFile>[];
    if (list.isNotEmpty) {
      for (final f in list) {
        formData.files.add(MapEntry('foto_lahan_list[]', f));
      }
    } else if (fotoLahan != null) {
      formData.files.add(MapEntry('foto_lahan', fotoLahan));
    }

    if (dokumenSppt != null) {
      formData.files.add(MapEntry('dokumen_sppt', dokumenSppt));
    }

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

  Future<ApiResponse<List<ItemDokumenSppt>>> getSpptDocuments(
    String idLahan,
  ) async {
    return await _client.get<List<ItemDokumenSppt>>(
      '/documents',
      fromJson: (data) {
        if (data is! Map) return <ItemDokumenSppt>[];

        final lands = data['lahan'];

        if (lands is! List) return <ItemDokumenSppt>[];

        Map<String, dynamic>? selectedLand;

        for (final land in lands) {
          if (land is Map && (land['id_lahan'] ?? '').toString() == idLahan) {
            selectedLand = Map<String, dynamic>.from(land);
            break;
          }
        }

        final documents = selectedLand?['sppt_documents'];

        if (documents is! List) return <ItemDokumenSppt>[];

        return documents
            .whereType<Map>()
            .map(
              (item) =>
                  ItemDokumenSppt.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      },
    );
  }

  /// Upload satu atau beberapa dokumen SPPT.
  Future<ApiResponse<bool>> uploadSpptDocuments(
    String idLahan,
    List<PlatformFile> pickedFiles,
  ) async {
    final files = <MultipartFile>[];

    for (final file in pickedFiles) {
      final bytes = await file.readAsBytes();

      files.add(MultipartFile.fromBytes(bytes, filename: file.name));
    }

    // Dio otomatis mengubah List file menjadi field files[].
    final formData = FormData.fromMap({'files': files});

    return await _client.post<bool>(
      '/lahan/$idLahan/sppt',
      data: formData,
      options: Options(contentType: Headers.multipartFormDataContentType),
      fromJson: (_) => true,
    );
  }

  Future<ApiResponse<bool>> deleteSpptDocument(String idDokumen) async {
    return await _client.delete<bool>(
      '/documents/sppt/$idDokumen',
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

  /// Mengambil siklus tanam yang sedang berjalan pada suatu lahan:
  /// `GET /api/v1/lahan/{id}/siklus/berjalan`.
  Future<ApiResponse<ItemSiklusTanam?>> getSiklusBerjalan(String idLahan) async {
    return await _client.get<ItemSiklusTanam?>(
      '${ApiConstants.lahanEndpoint}/$idLahan/siklus/berjalan',
      fromJson: (data) {
        if (data == null || data is! Map) return null;
        return ItemSiklusTanam.fromJson(Map<String, dynamic>.from(data));
      },
    );
  }

  /// Mengambil riwayat siklus tanam pada suatu lahan:
  /// `GET /api/v1/lahan/{id}/siklus`.
  Future<ApiResponse<List<ItemSiklusTanam>>> getRiwayatSiklus(
    String idLahan, {
    int? page,
    int? perPage,
  }) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (perPage != null) queryParams['per_page'] = perPage;

    return await _client.get<List<ItemSiklusTanam>>(
      '${ApiConstants.lahanEndpoint}/$idLahan/siklus',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (data) {
        if (data is! List) return <ItemSiklusTanam>[];
        return data
            .map((item) => ItemSiklusTanam.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      },
    );
  }

  /// Membuat Siklus Tanam baru:
  /// `POST /api/v1/siklus-tanam`.
  Future<ApiResponse<ItemSiklusTanam>> createSiklusTanam(Map<String, dynamic> payload) async {
    return await _client.post<ItemSiklusTanam>(
      ApiConstants.siklusTanamEndpoint,
      data: payload,
      fromJson: (data) => ItemSiklusTanam.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Mengubah status operasional lahan menjadi persiapan:
  /// `POST /api/v1/lahan/{id}/mulai-persiapan`.
  Future<ApiResponse<ItemLahan>> mulaiPersiapan(String idLahan) async {
    return await _client.post<ItemLahan>(
      '${ApiConstants.lahanEndpoint}/$idLahan/mulai-persiapan',
      fromJson: (data) => ItemLahan.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Membatalkan persiapan lahan (kembali ke istirahat):
  /// `POST /api/v1/lahan/{id}/batalkan-persiapan`.
  Future<ApiResponse<ItemLahan>> batalkanPersiapan(String idLahan) async {
    return await _client.post<ItemLahan>(
      '${ApiConstants.lahanEndpoint}/$idLahan/batalkan-persiapan',
      fromJson: (data) => ItemLahan.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Mengambil detail siklus tanam:
  /// `GET /api/v1/siklus-tanam/{id}`.
  Future<ApiResponse<ItemSiklusTanam>> getSiklusDetail(String idSiklus) async {
    return await _client.get<ItemSiklusTanam>(
      '${ApiConstants.siklusTanamEndpoint}/$idSiklus',
      fromJson: (data) => ItemSiklusTanam.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Mengajukan pengakhiran berhasil (selesai):
  /// `POST /api/v1/siklus-tanam/{id}/ajukan-selesai`.
  Future<ApiResponse<ItemSiklusTanam>> ajukanPengakhiranSelesai(
    String idSiklus, {
    required String alasan,
    MultipartFile? fotoBukti,
  }) async {
    dynamic payload;
    if (fotoBukti != null) {
      final formData = FormData();
      formData.fields.add(MapEntry('alasan', alasan));
      formData.files.add(MapEntry('foto_bukti', fotoBukti));
      payload = formData;
    } else {
      payload = {'alasan': alasan};
    }

    return await _client.post<ItemSiklusTanam>(
      '${ApiConstants.siklusTanamEndpoint}/$idSiklus/ajukan-selesai',
      data: payload,
      fromJson: (data) => ItemSiklusTanam.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Mengajukan pengakhiran gagal (gagal panen):
  /// `POST /api/v1/siklus-tanam/{id}/ajukan-gagal`.
  Future<ApiResponse<ItemSiklusTanam>> ajukanPengakhiranGagal(
    String idSiklus, {
    required String alasan,
    required MultipartFile fotoBukti,
  }) async {
    final formData = FormData();
    formData.fields.add(MapEntry('alasan', alasan));
    formData.files.add(MapEntry('foto_bukti', fotoBukti));

    return await _client.post<ItemSiklusTanam>(
      '${ApiConstants.siklusTanamEndpoint}/$idSiklus/ajukan-gagal',
      data: formData,
      fromJson: (data) => ItemSiklusTanam.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Membatalkan siklus tanam langsung (tanpa aktivitas & tanpa panen):
  /// `POST /api/v1/siklus-tanam/{id}/batalkan`.
  Future<ApiResponse<ItemSiklusTanam>> batalkanSiklus(
    String idSiklus, {
    required String alasan,
  }) async {
    return await _client.post<ItemSiklusTanam>(
      '${ApiConstants.siklusTanamEndpoint}/$idSiklus/batalkan',
      data: {'alasan': alasan},
      fromJson: (data) => ItemSiklusTanam.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Verifikasi persetujuan/penolakan pengakhiran oleh Ketua/Pengurus:
  /// `POST /api/v1/siklus-tanam/{id}/verifikasi-pengakhiran`.
  Future<ApiResponse<ItemSiklusTanam>> verifikasiPengakhiranSiklus(
    String idSiklus, {
    required String keputusan,
    String? catatan,
  }) async {
    final payload = <String, dynamic>{
      'keputusan': keputusan,
    };
    if (catatan != null && catatan.trim().isNotEmpty) {
      payload['catatan'] = catatan.trim();
    }

    return await _client.post<ItemSiklusTanam>(
      '${ApiConstants.siklusTanamEndpoint}/$idSiklus/verifikasi-pengakhiran',
      data: payload,
      fromJson: (data) => ItemSiklusTanam.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }
}
