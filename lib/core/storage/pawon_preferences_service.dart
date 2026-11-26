import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service Local Storage berbasis SharedPreferences
/// Digunakan untuk menyimpan preferensi aplikasi, session ringkas, dan cache cepat.
class PawonPreferencesService {
  static PawonPreferencesService? _instance;
  static SharedPreferences? _prefs;

  PawonPreferencesService._();

  static Future<PawonPreferencesService> getInstance() async {
    _instance ??= PawonPreferencesService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Key Constants
  static const String _keyThemeMode = 'pref_theme_mode';
  static const String _keyUserCache = 'pref_user_cache';
  static const String _keyLastSync = 'pref_last_sync';
  static const String _keyOfflineNotificationCount = 'pref_unread_notif';

  /// Simpan Mode Tema (light / dark / system)
  Future<bool> setThemeMode(String mode) async {
    return await _prefs?.setString(_keyThemeMode, mode) ?? false;
  }

  /// Ambil Mode Tema
  String getThemeMode() {
    return _prefs?.getString(_keyThemeMode) ?? 'light';
  }

  /// Simpan Cache Data Profil Pengguna (JSON String)
  Future<bool> saveUserCache(Map<String, dynamic> userData) async {
    return await _prefs?.setString(_keyUserCache, jsonEncode(userData)) ?? false;
  }

  /// Ambil Cache Data Profil Pengguna
  Map<String, dynamic>? getUserCache() {
    final raw = _prefs?.getString(_keyUserCache);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Simpan Waktu Terakhir Sinkronisasi
  Future<bool> setLastSyncTime(DateTime time) async {
    return await _prefs?.setString(_keyLastSync, time.toIso8601String()) ?? false;
  }

  /// Ambil Waktu Terakhir Sinkronisasi
  DateTime? getLastSyncTime() {
    final raw = _prefs?.getString(_keyLastSync);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  /// Hapus Semua Data Preferences (misal saat logout)
  Future<bool> clearAll() async {
    return await _prefs?.clear() ?? false;
  }
}
