import 'package:dio/dio.dart';
import 'package:pawon_mobile/core/storage/secure_storage_service.dart';

/// Interceptor Dio untuk otomatis menyematkan header standar API
/// dan Bearer Token pada setiap permintaan HTTP yang membutuhkan autentikasi.
class AuthInterceptor extends Interceptor {
  final SecureStorageService _storageService;
  final void Function()? onUnauthorized;
  static bool _isHandlingUnauthorized = false;

  AuthInterceptor({
    SecureStorageService? storageService,
    this.onUnauthorized,
  }) : _storageService = storageService ?? SecureStorageService.instance;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 1. Pastikan header Accept selalu application/json
    options.headers['Accept'] = 'application/json';

    // 2. Sematkan Bearer Token jika belum ada di header eksplisit
    if (!options.headers.containsKey('Authorization')) {
      final token = await _storageService.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Jika token kedaluwarsa atau tidak valid (HTTP 401 Unauthorized).
    // Jangan panggil callback global jika error berasal dari endpoint autentikasi (/auth/login atau /auth/me)
    // untuk mencegah siklus atau pengulangan request tak berujung.
    final path = err.requestOptions.path;
    final isAuthEndpoint = path.contains('/auth/login') || path.contains('/auth/me');

    if (err.response?.statusCode == 401 && !isAuthEndpoint) {
      if (!_isHandlingUnauthorized) {
        _isHandlingUnauthorized = true;
        try {
          await _storageService.clearAll();
          onUnauthorized?.call();
        } finally {
          // Reset status setelah cooldown singkat agar tidak memicu transisi ganda
          Future.delayed(const Duration(seconds: 3), () {
            _isHandlingUnauthorized = false;
          });
        }
      }
    }

    return handler.next(err);
  }
}
