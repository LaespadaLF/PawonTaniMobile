import 'package:flutter/material.dart';
import 'package:pawon_mobile/core/storage/pawon_preferences_service.dart';

/// Controller pengelola mode tampilan aplikasi (Terang / Gelap).
/// Menggunakan SharedPreferences untuk Local Storage preferensi pengguna.
class TemaController {
  static final TemaController instance = TemaController._internal();
  factory TemaController() => instance;

  TemaController._internal();

  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
  ValueNotifier<ThemeMode> get themeMode => _themeMode;

  bool get isDarkMode => _themeMode.value == ThemeMode.dark;

  /// Inisialisasi tema saat aplikasi startup via SharedPreferences
  Future<void> inisialisasi() async {
    try {
      final prefs = await PawonPreferencesService.getInstance();
      final savedMode = prefs.getThemeMode();
      if (savedMode == 'dark') {
        _themeMode.value = ThemeMode.dark;
      } else {
        _themeMode.value = ThemeMode.light;
      }
    } catch (_) {
      _themeMode.value = ThemeMode.light;
    }
  }

  /// Ubah mode tema aplikasi dan simpan ke SharedPreferences
  Future<void> ubahMode(ThemeMode mode) async {
    _themeMode.value = mode;
    try {
      final prefs = await PawonPreferencesService.getInstance();
      await prefs.setThemeMode(mode == ThemeMode.dark ? 'dark' : 'light');
    } catch (_) {}
  }

  /// Toggle antara mode gelap dan terang
  Future<void> toggleMode(bool isDark) async {
    await ubahMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
