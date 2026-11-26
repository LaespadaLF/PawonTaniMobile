import 'package:dio/dio.dart';
import 'package:pawon_mobile/core/network/api_response.dart';
import 'package:pawon_mobile/core/constants/api_constants.dart';
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

  /// Memperbarui biodata profil anggota (mendukung Multipart file foto dan PUT profile).
  Future<ApiResponse<AuthUserModel>> updateProfile({
    String? nama,
    String? username,
    String? email,
    String? noTelepon,
    String? alamat,
    String? password,
    String? passwordBaru,
    MultipartFile? fotoProfil,
  }) async {
    final Map<String, dynamic> map = {
      if (nama != null && nama.trim().isNotEmpty) 'nama': nama.trim(),
      if (username != null && username.trim().isNotEmpty) 'username': username.trim(),
      if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
      if (noTelepon != null && noTelepon.trim().isNotEmpty) 'no_telepon': noTelepon.trim(),
      if (alamat != null && alamat.trim().isNotEmpty) 'alamat': alamat.trim(),
      if (password != null && password.trim().isNotEmpty) 'password': password.trim(),
      if (passwordBaru != null && passwordBaru.trim().isNotEmpty) 'password_baru': passwordBaru.trim(),
      if (fotoProfil != null) 'foto_profil': fotoProfil,
    };

    if (fotoProfil != null) {
      final formData = FormData.fromMap(map);
      return await _client.post<AuthUserModel>(
        ApiConstants.meEndpoint,
        data: formData,
        fromJson: (data) => AuthUserModel.fromJson(Map<String, dynamic>.from(data)),
      );
    }

    return await _client.put<AuthUserModel>(
      ApiConstants.profileUpdateEndpoint,
      data: map,
      fromJson: (data) => AuthUserModel.fromJson(Map<String, dynamic>.from(data)),
    );
  }
  }

  /// Mengirim permintaan pencabutan token ke `POST /api/v1/auth/logout`.
  Future<ApiResponse<void>> logout() async {
    return await _client.post<void>(
      ApiConstants.logoutEndpoint,
    );
  }

  /// Mengirim permintaan penghapusan akun mandiri ke `DELETE /api/v1/auth/account`.
  Future<ApiResponse<void>> deleteAccount({
    required String password,
    String confirmation = 'HAPUS AKUN',
  }) async {
    return await _client.delete<void>(
      ApiConstants.accountEndpoint,
      data: {
        'password': password,
        'confirmation': confirmation,
      },
    );
  }
}
