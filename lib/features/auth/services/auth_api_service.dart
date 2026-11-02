import 'package:pawon_mobile/core/constants/api_constants.dart';
import 'package:pawon_mobile/core/network/api_response.dart';
import 'package:pawon_mobile/core/network/dio_client.dart';
import 'package:pawon_mobile/features/auth/models/auth_user_model.dart';

/// Service networking untuk memanggil endpoint autentikasi backend Laravel.
class AuthApiService {
  final DioClient _client;

  AuthApiService({DioClient? client}) : _client = client ?? DioClient();

  /// Mengirim kredensial login ke `POST /api/v1/auth/login`.
  /// Mengembalikan data berisi `token` dan data `user`.
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String identifier,
    required String password,
  }) async {
    return await _client.post<Map<String, dynamic>>(
      ApiConstants.loginEndpoint,
      data: {
        'identifier': identifier.trim(),
        'password': password,
      },
      fromJson: (data) => Map<String, dynamic>.from(data),
    );
  }

  /// Mengambil data profil anggota saat ini dari `GET /api/v1/auth/me`.
  Future<ApiResponse<AuthUserModel>> getProfile() async {
    return await _client.get<AuthUserModel>(
      ApiConstants.meEndpoint,
      fromJson: (data) => AuthUserModel.fromJson(Map<String, dynamic>.from(data)),
    );
  }

  /// Mengirim permintaan pencabutan token ke `POST /api/v1/auth/logout`.
  Future<ApiResponse<void>> logout() async {
    return await _client.post<void>(
      ApiConstants.logoutEndpoint,
    );
  }
}
