import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Controller pengelola mode tampilan aplikasi (Terang / Gelap).
class TemaController {
  static final TemaController instance = TemaController._internal();
  factory TemaController() => instance;

  TemaController._internal();

  static const String _keyThemeMode = 'pawontani_theme_mode';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
  ValueNotifier<ThemeMode> get themeMode => _themeMode;

  bool get isDarkMode => _themeMode.value == ThemeMode.dark;

  /// Inisialisasi tema saat aplikasi startup
  Future<void> inisialisasi() async {
    try {
      final savedMode = await _storage.read(key: _keyThemeMode);
      if (savedMode == 'dark') {
        _themeMode.value = ThemeMode.dark;
      } else {
        _themeMode.value = ThemeMode.light;
      }
    } catch (_) {
      _themeMode.value = ThemeMode.light;
    }
  }

  /// Ubah mode tema aplikasi
  Future<void> ubahMode(ThemeMode mode) async {
    _themeMode.value = mode;
    try {
      await _storage.write(
        key: _keyThemeMode,
        value: mode == ThemeMode.dark ? 'dark' : 'light',
      );
    } catch (_) {}
  }

  /// Toggle antara mode gelap dan terang
  Future<void> toggleMode(bool isDark) async {
    await ubahMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
