import 'package:flutter/services.dart';

/// Formatter otomatis untuk input nominal Rupiah (ribuan dengan titik).
/// Menambahkan titik setiap 3 digit saat pengguna mengetik:
/// Contoh: mengetik 15000 -> otomatis menjadi 15.000.
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Ambil hanya angka digit
    final cleanDigits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanDigits.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final number = int.tryParse(cleanDigits);
    if (number == null) return oldValue;

    // Format dengan pemisah ribuan titik (.)
    final s = number.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    final formatted = buf.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Helper untuk memformat angka menjadi string bertitik
  static String format(num? value) {
    if (value == null) return '';
    final s = value.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  /// Helper untuk membersihkan titik dan mengambil angka double
  static double parse(String? text) {
    if (text == null) return 0;
    final clean = text.replaceAll('.', '').trim();
    return double.tryParse(clean) ?? 0;
  }
}
