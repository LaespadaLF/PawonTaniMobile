/// Representasi model master data komoditas dari backend PawonTani.
class ItemKomoditas {
  final String idKomoditas;
  final String namaKomoditas;
  final String kategori;

  const ItemKomoditas({
    required this.idKomoditas,
    required this.namaKomoditas,
    required this.kategori,
  });

  factory ItemKomoditas.fromJson(Map<String, dynamic> json) {
    return ItemKomoditas(
      idKomoditas: (json['id_komoditas'] ?? '').toString(),
      namaKomoditas: (json['nama_komoditas'] ?? '').toString(),
      kategori: (json['kategori'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_komoditas': idKomoditas,
      'nama_komoditas': namaKomoditas,
      'kategori': kategori,
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

