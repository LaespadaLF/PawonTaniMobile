import 'package:flutter/foundation.dart';

/// Konfigurasi konstanta API PawonTani.
/// Mendukung berbagai environment (Android Emulator, Device Fisik, Web/Desktop).
class ApiConstants {
  ApiConstants._();

  /// IP manual untuk pengujian menggunakan HP/perangkat fisik dalam satu jaringan Wi-Fi/LAN.
  /// Default null agar Android Emulator otomatis menggunakan host loopback 10.0.2.2.
  /// Isi nilai ini secara lokal (misal: '192.168.1.X') hanya saat pengujian di perangkat fisik Android.
  static String? customDeviceIp;

  /// Port development server Laravel.
  static const int port = 8000;

  /// Prefix rute API v1.
  static const String apiPrefix = '/api/v1';

  /// Mendapatkan Base URL secara dinamis tanpa menggunakan `dart:io`
  /// agar kompatibel secara multiplatform (Android, iOS, Web, Desktop).
  static String get baseUrl {
    // 1. Web atau Desktop — selalu pakai localhost (tidak berlaku customDeviceIp)
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return 'http://127.0.0.1:$port$apiPrefix';
    }

    // 2. Android perangkat fisik — pakai IP custom jika diset atau lewat parameter --dart-define
    if (defaultTargetPlatform == TargetPlatform.android) {
      const envIp = String.fromEnvironment('API_IP');
      if (envIp.isNotEmpty) {
        return 'http://$envIp:$port$apiPrefix';
      }
      if (customDeviceIp != null && customDeviceIp!.isNotEmpty) {
        return 'http://$customDeviceIp:$port$apiPrefix';
      }
      // Android Emulator: host PC dipetakan ke 10.0.2.2
      return 'http://10.0.2.2:$port$apiPrefix';
    }

    // 3. Default fallback untuk iOS Simulator / platform lainnya
    return 'http://127.0.0.1:$port$apiPrefix';
  }

  // --- Timeout Jaringan ---
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  // --- Endpoint Rute Autentikasi ---
  static const String loginEndpoint = '/auth/login';
  static const String meEndpoint = '/auth/me';
  static const String logoutEndpoint = '/auth/logout';

  // --- Endpoint Rute Lahan ---
  static const String lahanEndpoint = '/lahan';

  // --- Endpoint Rute Aktivitas ---
  static const String aktivitasEndpoint = '/aktivitas';

  // --- Endpoint Rute Komoditas ---
  static const String komoditasEndpoint = '/komoditas';

  /// Normalisasi URL gambar dari storage backend agar selalu dapat dimuat
  /// baik di Android Emulator, HP fisik, maupun Web/Desktop.
  static String? resolveImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    final clean = path.trim();

    // Biarkan URL CDN pihak ketiga (Cloudinary / Unsplash) apa adanya
    if (clean.contains('res.cloudinary.com') || clean.contains('unsplash.com')) {
      return clean;
    }

    final host = baseUrl.replaceAll(apiPrefix, '');

    // Ekstrak path media internal
    final match = RegExp(r'(?:storage|media)/(.*)$', caseSensitive: false).firstMatch(clean);
    String relative;
    if (match != null && match.groupCount >= 1) {
      relative = match.group(1)!;
    } else if (clean.startsWith('http://') || clean.startsWith('https://')) {
      final uri = Uri.tryParse(clean);
      final p = uri?.path ?? '';
      relative = p.replaceFirst(RegExp(r'^/(?:storage|media)/'), '');
    } else {
      relative = clean.startsWith('/') ? clean.substring(1) : clean;
      relative = relative.replaceFirst(RegExp(r'^(?:storage|media)/'), '');
    }

    return '$host/media/$relative';
  }
}