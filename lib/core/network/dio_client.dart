import 'package:dio/dio.dart';
import 'package:pawon_mobile/core/constants/api_constants.dart';
import 'package:pawon_mobile/core/network/api_response.dart';
import 'package:pawon_mobile/core/network/auth_interceptor.dart';
import 'package:pawon_mobile/core/storage/secure_storage_service.dart';

/// Klien HTTP terpusat berbasis Dio untuk aplikasi PawonTani Mobile.
/// Mengelola konfigurasi timeout, base URL, interceptor autentikasi,
/// dan penanganan error secara terstandarisasi.
class DioClient {
  late final Dio _dio;
  final SecureStorageService _storageService;

  static DioClient? _instance;

  DioClient._internal({
    String? baseUrl,
    SecureStorageService? storageService,
    void Function()? onUnauthorized,
  }) : _storageService = storageService ?? SecureStorageService.instance {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        responseType: ResponseType.json,
      ),
    );

    // Pasang interceptor token autentikasi
    _dio.interceptors.add(
      AuthInterceptor(
        storageService: _storageService,
        onUnauthorized: onUnauthorized,
      ),
    );
  }

  /// Factory singleton untuk akses instans DioClient global.
  factory DioClient({
    String? baseUrl,
    SecureStorageService? storageService,
    void Function()? onUnauthorized,
  }) {
    _instance ??= DioClient._internal(
      baseUrl: baseUrl,
      storageService: storageService,
      onUnauthorized: onUnauthorized,
    );
    return _instance!;
  }

  /// Akses langsung ke instans Dio jika dibutuhkan operasi tingkat lanjut (misal: multipart).
  Dio get rawDio => _dio;

  /// Memperbarui Base URL jika pengguna mengubah konfigurasi host/IP dinamis.
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  /// Request HTTP GET terstruktur
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleSuccess(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse.error(message: 'Terjadi kesalahan tidak terduga: $e');
    }
  }

  /// Request HTTP POST terstruktur
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleSuccess(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse.error(message: 'Terjadi kesalahan tidak terduga: $e');
    }
  }

  /// Request HTTP PUT terstruktur
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleSuccess(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse.error(message: 'Terjadi kesalahan tidak terduga: $e');
    }
  }

  /// Request HTTP DELETE terstruktur
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleSuccess(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse.error(message: 'Terjadi kesalahan tidak terduga: $e');
    }
  }

  // --- Penanganan Respons & Error ---

  ApiResponse<T> _handleSuccess<T>(Response response, T Function(dynamic json)? fromJson) {
    final body = response.data;
    if (body is Map<String, dynamic>) {
      return ApiResponse.fromJson(
        body,
        fromJsonT: fromJson,
        statusCode: response.statusCode,
      );
    }
    return ApiResponse.success(
      data: body as T,
      statusCode: response.statusCode,
    );
  }

  ApiResponse<T> _handleError<T>(DioException e) {
    final response = e.response;
    final statusCode = response?.statusCode;

    // 1. Error respons dari server (Laravel)
    if (response?.data != null && response!.data is Map<String, dynamic>) {
      final body = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        body,
        statusCode: statusCode,
      );
    }

    // 2. Error koneksi jaringan (timeout / offline)
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiResponse.error(
          message: 'Koneksi ke server batas waktu habis (timeout). Silakan periksa jaringan Anda.',
          statusCode: statusCode,
        );
      case DioExceptionType.connectionError:
        return ApiResponse.error(
          message: 'Gagal terhubung ke server PawonTani. Pastikan backend aktif dan URL server benar.',
          statusCode: statusCode,
        );
      case DioExceptionType.badResponse:
        return ApiResponse.error(
          message: 'Server merespons dengan kesalahan (Kode: $statusCode).',
          statusCode: statusCode,
        );
      case DioExceptionType.cancel:
        return ApiResponse.error(
          message: 'Permintaan jaringan dibatalkan.',
          statusCode: statusCode,
        );
      default:
        return ApiResponse.error(
          message: e.message ?? 'Terjadi gangguan jaringan.',
          statusCode: statusCode,
        );
    }
  }
}
