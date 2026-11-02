import 'package:flutter/foundation.dart';

/// Konfigurasi konstanta API PawonTani.
/// Mendukung berbagai environment (Android Emulator, Device Fisik, Web/Desktop).
class ApiConstants {
  ApiConstants._();

  /// IP manual untuk pengujian menggunakan HP/perangkat fisik dalam satu jaringan Wi-Fi/LAN.
  /// Ubah nilai ini sesuai IP komputer lokal (misal: '192.168.1.10') jika menguji via HP fisik.
  static String? customDeviceIp;

  /// Port development server Laravel.
  static const int port = 8000;

  /// Prefix rute API v1.
  static const String apiPrefix = '/api/v1';

  /// Mendapatkan Base URL secara dinamis tanpa menggunakan `dart:io`
  /// agar kompatibel secara multiplatform (Android, iOS, Web, Desktop).
  static String get baseUrl {
    // 1. Jika pengguna menentukan IP perangkat fisik khusus
    if (customDeviceIp != null && customDeviceIp!.isNotEmpty) {
      return 'http://$customDeviceIp:$port$apiPrefix';
    }

    // 2. Jika platform adalah Web atau Desktop (Windows/macOS/Linux)
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return 'http://127.0.0.1:$port$apiPrefix';
    }

    // 3. Jika platform adalah Android (Standar Emulator memetakan host ke 10.0.2.2)
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:$port$apiPrefix';
    }

    // 4. Default fallback untuk iOS Simulator / platform lainnya
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
}
