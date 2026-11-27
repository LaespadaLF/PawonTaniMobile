class ItemDokumenSaya {
  final String jenis; // KTP, KK, SPPT
  final String nama;
  final bool isUploaded;
  final String? url;
  final String? originalName;
  final DateTime? updatedAt;

  const ItemDokumenSaya({
    required this.jenis,
    required this.nama,
    required this.isUploaded,
    this.url,
    this.originalName,
    this.updatedAt,
  });

  factory ItemDokumenSaya.fromJson(Map<String, dynamic> json) {
    return ItemDokumenSaya(
      jenis: json['jenis']?.toString() ?? '',
      nama: json['nama']?.toString() ?? json['jenis']?.toString() ?? '',
      isUploaded: json['is_uploaded'] == true,
      url: json['url']?.toString(),
      originalName: json['original_name']?.toString(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }
}

class ItemIzinDokumen {
  final int id;
  final String jenisDokumen;
  final String tujuanAkses;
  final DateTime berlakuSampai;
  final String status;
  final String? namaPengurus;
  final String? namaKelompok;
  final DateTime? createdAt;

  const ItemIzinDokumen({
    required this.id,
    required this.jenisDokumen,
    required this.tujuanAkses,
    required this.berlakuSampai,
    required this.status,
    this.namaPengurus,
    this.namaKelompok,
    this.createdAt,
  });

  factory ItemIzinDokumen.fromJson(Map<String, dynamic> json) {
    return ItemIzinDokumen(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      jenisDokumen: (json['tipe_dokumen'] ?? json['jenis_dokumen'] ?? '').toString().toUpperCase(),
      tujuanAkses: (json['tujuan_penggunaan'] ?? json['tujuan_akses'] ?? '').toString(),
      berlakuSampai: DateTime.tryParse((json['waktu_berakhir'] ?? json['berlaku_sampai'] ?? '').toString()) ?? DateTime.now(),
      status: (json['status_akses'] ?? json['status'] ?? 'aktif').toString(),
      namaPengurus: json['pengurus'] is Map ? json['pengurus']['nama']?.toString() : null,
      namaKelompok: json['kelompok_tani'] is Map ? json['kelompok_tani']['nama_kelompok']?.toString() : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}
