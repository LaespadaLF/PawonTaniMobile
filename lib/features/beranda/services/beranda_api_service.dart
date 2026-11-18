import 'package:geolocator/geolocator.dart';
import 'package:pawon_mobile/core/constants/api_constants.dart';
import 'package:pawon_mobile/core/network/api_response.dart';
import 'package:pawon_mobile/core/network/dio_client.dart';
import 'package:pawon_mobile/features/beranda/models/beranda_ringkasan_model.dart';

/// Service networking untuk mengambil data agregat Beranda dari backend Laravel
class BerandaApiService {
  final DioClient _client;

  BerandaApiService({DioClient? client}) : _client = client ?? DioClient();

  /// Mengambil data ringkasan beranda lengkap (Statistik, Cuaca GPS, Artikel)
  Future<ApiResponse<BerandaRingkasanModel>> getRingkasan({
    double? lat,
    double? lon,
  }) async {
    final queryParams = <String, dynamic>{};

    // Jika lat & lon tidak diberikan, coba deteksi GPS perangkat secara halus
    double? targetLat = lat;
    double? targetLon = lon;

    if (targetLat == null || targetLon == null) {
      try {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          var permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }

          if (permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always) {
            // Ambil posisi GPS akurat dengan batas waktu 5 detik
            Position? pos;
            try {
              pos = await Geolocator.getCurrentPosition(
                locationSettings: const LocationSettings(
                  accuracy: LocationAccuracy.medium,
                  timeLimit: Duration(seconds: 5),
                ),
              );
            } catch (_) {
              // Jika timeout atau gagal, coba ambil posisi terakhir yang tersimpan
              pos = await Geolocator.getLastKnownPosition();
            }

            if (pos != null) {
              targetLat = pos.latitude;
              targetLon = pos.longitude;
            }
          }
        }
      } catch (_) {
        // Fallback hening jika sensor GPS tidak aktif atau permission ditolak
      }
    }

    if (targetLat != null && targetLon != null) {
      queryParams['lat'] = targetLat;
      queryParams['lon'] = targetLon;
    }

    return await _client.get<BerandaRingkasanModel>(
      ApiConstants.berandaRingkasanEndpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (data) => BerandaRingkasanModel.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }
}
