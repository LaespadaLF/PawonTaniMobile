/// Representasi model master data komoditas dari backend PawonTani.
class ItemKomoditas {
  final String idKomoditas;
  final String namaKomoditas;
  final String kategori;

  /// Perkiraan umur panen/siap produksi dalam hari (null jika belum ada di master).
  /// Dipakai untuk menghitung estimasi panen otomatis dari tanggal mulai tanam.
  final int? umurPanenHari;

  const ItemKomoditas({
    required this.idKomoditas,
    required this.namaKomoditas,
    required this.kategori,
    this.umurPanenHari,
  });

  String get id => idKomoditas;
  String get nama => namaKomoditas;

  factory ItemKomoditas.fromJson(Map<String, dynamic> json) {
    final umur = json['umur_panen_hari'];
    return ItemKomoditas(
      idKomoditas: (json['id_komoditas'] ?? '').toString(),
      namaKomoditas: (json['nama_komoditas'] ?? '').toString(),
      kategori: (json['kategori'] ?? '').toString(),
      umurPanenHari: umur == null ? null : int.tryParse(umur.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_komoditas': idKomoditas,
      'nama_komoditas': namaKomoditas,
      'kategori': kategori,
      'umur_panen_hari': umurPanenHari,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemKomoditas &&
          runtimeType == other.runtimeType &&
          idKomoditas == other.idKomoditas;

  @override
  int get hashCode => idKomoditas.hashCode;

  @override
  String toString() => '$namaKomoditas ($kategori)';
}

