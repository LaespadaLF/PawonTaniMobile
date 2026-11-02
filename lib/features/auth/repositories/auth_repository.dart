import 'package:flutter/foundation.dart';
import 'package:pawon_mobile/core/network/api_response.dart';
import 'package:pawon_mobile/core/storage/secure_storage_service.dart';
import 'package:pawon_mobile/features/auth/models/auth_user_model.dart';
import 'package:pawon_mobile/features/auth/services/auth_api_service.dart';

/// Status autentikasi aplikasi mobile
enum AuthStatus {
  /// Sedang memeriksa token awal saat aplikasi pertama kali dimuat
  initial,

  /// Pengguna terautentikasi dan token valid
  authenticated,

  /// Pengguna belum login atau sesi telah berakhir
  unauthenticated,
}

/// Repository pengelola status autentikasi aplikasi.
/// Bertindak sebagai Single Source of Truth status login.
class AuthRepository {
  static final AuthRepository instance = AuthRepository._internal();
  factory AuthRepository() => instance;

  final AuthApiService _apiService;
  final SecureStorageService _storageService;

  final ValueNotifier<AuthStatus> _authStatus = ValueNotifier<AuthStatus>(AuthStatus.initial);
  ValueListenable<AuthStatus> get authStatusListenable => _authStatus;
  AuthStatus get currentStatus => _authStatus.value;

  AuthUserModel? _currentUser;
  AuthUserModel? get currentUser => _currentUser;

  bool _isInitialized = false;

  AuthRepository._internal({
    AuthApiService? apiService,
    SecureStorageService? storageService,
  })  : _apiService = apiService ?? AuthApiService(),
        _storageService = storageService ?? SecureStorageService.instance;

  /// Metode bantu khusus pengujian untuk mereset status AuthRepository secara terisolasi.
  @visibleForTesting
  void resetForTesting({AuthStatus status = AuthStatus.initial}) {
    _isInitialized = false;
    _currentUser = null;
    _authStatus.value = status;
  }

  /// Memeriksa status autentikasi saat aplikasi dibuka.
  /// Hanya dieksekusi satu kali untuk mencegah request berulang saat widget me-rebuild.
  Future<void> checkAuthStatus() async {
    if (_isInitialized) return;
    _isInitialized = true;

    final hasToken = await _storageService.hasToken();
    if (!hasToken) {
      _authStatus.value = AuthStatus.unauthenticated;
      return;
    }

    // Validasi token aktif langsung ke backend Laravel (/api/v1/auth/me)
    final response = await _apiService.getProfile();

    if (response.success && response.data != null) {
      final user = response.data!;

      // Lapisan validasi keamanan di sisi Flutter
      if (user.isAnggota && user.isAktif) {
        _currentUser = user;
        _authStatus.value = AuthStatus.authenticated;
        return;
      }
    }

    // Jika token tidak valid / bukan anggota aktif, hapus token lokal
    await _storageService.deleteToken();
    _currentUser = null;
    _authStatus.value = AuthStatus.unauthenticated;
  }

  /// Proses login anggota dengan identifier (username atau email) dan password.
  Future<ApiResponse<AuthUserModel>> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _apiService.login(
      identifier: identifier,
      password: password,
    );

    if (!response.success || response.data == null) {
      return ApiResponse.error(
        message: response.message.isNotEmpty
            ? response.message
            : (response.firstErrorMessage ?? 'Login gagal. Periksa kembali username dan password Anda.'),
        errors: response.errors,
        statusCode: response.statusCode,
      );
    }

    final data = response.data!;
    final token = data['token']?.toString();
    final rawUser = data['user'];

    // 1. Validasi keberadaan token
    if (token == null || token.isEmpty) {
      return ApiResponse.error(
        message: 'Respons server tidak menyertakan token autentikasi.',
        statusCode: 500,
      );
    }

    // 2. Pemetaan data pengguna ke AuthUserModel
    if (rawUser == null || rawUser is! Map) {
      return ApiResponse.error(
        message: 'Data profil pengguna dari server tidak valid.',
        statusCode: 500,
      );
    }

    final user = AuthUserModel.fromJson(Map<String, dynamic>.from(rawUser));

    // 3. Validasi role Anggota dan status Aktif di sisi Flutter
    if (!user.isAnggota) {
      return ApiResponse.error(
        message: 'Akses ditolak. Aplikasi mobile ini hanya diperuntukkan bagi Anggota kelompok tani.',
        statusCode: 403,
      );
    }

    if (!user.isAktif) {
      return ApiResponse.error(
        message: 'Akun Anda berstatus tidak aktif. Silakan hubungi pengurus kelompok tani.',
        statusCode: 403,
      );
    }

    // 4. Simpan token ke SecureStorageService
    await _storageService.saveToken(token);

    _currentUser = user;
    _authStatus.value = AuthStatus.authenticated;

    return ApiResponse.success(
      data: user,
      message: response.message.isNotEmpty ? response.message : 'Login berhasil.',
      statusCode: response.statusCode,
    );
  }

  /// Proses logout pengguna dengan blok try / finally.
  /// Menjamin token lokal SELALU dihapus walaupun request jaringan gagal/offline.
  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (_) {
      // Abaikan error jaringan saat logout agar alur keluar tidak macet
    } finally {
      await _storageService.deleteToken();
      _currentUser = null;
      _authStatus.value = AuthStatus.unauthenticated;
    }
  }
}
