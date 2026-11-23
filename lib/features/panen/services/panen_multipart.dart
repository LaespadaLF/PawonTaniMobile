import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Membuat [MultipartFile] dengan Content-Type sesuai ekstensi berkas.
///
/// Content-Type eksplisit diperlukan agar Laravel tidak menerima berkas
/// sebagai `application/octet-stream` (yang bisa ditolak aturan validasi
/// gambar), terutama untuk foto hasil kamera di Flutter Web yang namanya
/// kadang tidak membawa ekstensi.
MultipartFile buatFotoPanen(Uint8List bytes, String namaBerkas) {
  var nama = namaBerkas.trim().isEmpty ? 'foto_panen.jpg' : namaBerkas.trim();
  final ext = nama.contains('.') ? nama.split('.').last.toLowerCase() : '';

  final subtipe = switch (ext) {
    'png' => 'png',
    'webp' => 'webp',
    'gif' => 'gif',
    'bmp' => 'bmp',
    'heic' => 'heic',
    'heif' => 'heif',
    _ => 'jpeg',
  };

  // Nama berkas tanpa ekstensi (umum pada hasil kamera Flutter Web) membuat
  // backend menyimpan berkas tanpa ekstensi, jadi ekstensi ditambahkan di sini.
  if (ext.isEmpty) {
    nama = '$nama.${subtipe == 'jpeg' ? 'jpg' : subtipe}';
  }

  return MultipartFile.fromBytes(
    bytes,
    filename: nama,
    contentType: DioMediaType('image', subtipe),
  );
}

/// Menyusun body multipart untuk endpoint panen.
///
/// Aturan penting: satu instance [MultipartFile] hanya boleh dipakai sekali.
/// Dio menandai berkas sebagai "finalized" setelah dikirim, sehingga memakai
/// instance yang sama pada dua field (misalnya `foto_panen` sekaligus
/// `foto_panen_list[]`) membuat request gagal dengan
/// "The MultipartFile has already been finalized" dan server membalas
/// "Gagal mengunggah foto...". Karena itu, bila daftar foto tersedia, semua
/// foto dikirim lewat `foto_panen_list[]` saja; backend memakai foto pertama
/// sebagai `foto_panen`.
FormData bangunFormDataPanen(
  Map<String, dynamic> payload, {
  MultipartFile? fotoPanen,
  List<MultipartFile>? fotoPanenList,
}) {
  final formData = FormData();

  payload.forEach((key, value) {
    if (value == null) return;

    // Nilai berbentuk daftar (mis. `existing_photos`) harus dikirim sebagai
    // field berulang `key[]` agar PHP membacanya sebagai array. Daftar kosong
    // tetap dikirim sebagai satu entri kosong supaya key-nya tidak hilang.
    if (value is Iterable) {
      final items = value.map((e) => e.toString()).toList();
      if (items.isEmpty) {
        formData.fields.add(MapEntry('$key[]', ''));
      } else {
        for (final item in items) {
          formData.fields.add(MapEntry('$key[]', item));
        }
      }
      return;
    }

    formData.fields.add(
      MapEntry(key, value is bool ? (value ? '1' : '0') : value.toString()),
    );
  });

  final daftarFoto = fotoPanenList ?? const <MultipartFile>[];
  if (daftarFoto.isNotEmpty) {
    for (final foto in daftarFoto) {
      // Nama field berakhiran "[]" agar PHP/Laravel membacanya sebagai array.
      formData.files.add(MapEntry('foto_panen_list[]', foto));
    }
  } else if (fotoPanen != null) {
    formData.files.add(MapEntry('foto_panen', fotoPanen));
  }

  return formData;
}
