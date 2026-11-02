import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service penyimpanan kredensial aman berbasis hardware encryption
/// (Android KeyStore dan iOS Keychain).
/// Tidak menggunakan SharedPreferences biasa demi keamanan data token.
class SecureStorageService {
  SecureStorageService._internal();
  static final SecureStorageService instance = SecureStorageService._internal();

  factory SecureStorageService() => instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const String _keyToken = 'pawontani_auth_token';
  static const String _keyUser = 'pawontani_user_data';

  /// Menyimpan Bearer Token secara terenkripsi.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  /// Mengambil Bearer Token aktif (mengembalikan null jika belum login).
  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  /// Memeriksa apakah token tersedia.
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Menghapus Bearer Token saat logout.
  Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
  }

  /// Menyimpan cache data profil pengguna dalam format string JSON.
  Future<void> saveUserData(String userDataJson) async {
    await _storage.write(key: _keyUser, value: userDataJson);
  }

  /// Mengambil cache data profil pengguna.
  Future<String?> getUserData() async {
    return await _storage.read(key: _keyUser);
  }

  /// Menghapus seluruh data sesi login dari penyimpanan aman.
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
