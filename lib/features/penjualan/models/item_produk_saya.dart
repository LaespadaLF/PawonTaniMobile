import 'package:pawon_mobile/core/constants/api_constants.dart';

class ItemProdukSaya {
  final String idProduk;
  final String idPengguna;
  final String? idKomoditas;
  final String? namaKomoditas;
  final String namaProduk;
  final String? fotoProduk;
  final String? deskripsi;
  final String jenisHarga; // 'tetap' | 'rentang'
  final double harga;
  final double? hargaMin;
  final double? hargaMax;
  final String hargaFormatted;
  final String satuan;
  final double stokFisik;
  final double stokDitahan;
  final double stokTersedia;
  final double totalTerjual;
  final String status; // 'aktif' | 'tidak_aktif' | 'stok_habis' | 'diarsipkan'
  final DateTime? createdAt;

  const ItemProdukSaya({
    required this.idProduk,
    required this.idPengguna,
    this.idKomoditas,
    this.namaKomoditas,
    required this.namaProduk,
    this.fotoProduk,
    this.deskripsi,
    required this.jenisHarga,
    required this.harga,
    this.hargaMin,
    this.hargaMax,
    required this.hargaFormatted,
    required this.satuan,
    required this.stokFisik,
    required this.stokDitahan,
    required this.stokTersedia,
    required this.totalTerjual,
    required this.status,
    this.createdAt,
  });

  bool get isStokHabis => stokTersedia <= 0 || status == 'stok_habis';
  bool get isAktif => status == 'aktif' && !isStokHabis;

  String? get fotoResolvedUrl => ApiConstants.resolveImageUrl(fotoProduk);

  factory ItemProdukSaya.fromJson(Map<String, dynamic> json) {
    return ItemProdukSaya(
      idProduk: json['id_produk']?.toString() ?? '',
      idPengguna: json['id_pengguna']?.toString() ?? '',
      idKomoditas: json['id_komoditas']?.toString(),
      namaKomoditas: json['nama_komoditas']?.toString(),
      namaProduk: json['nama_produk']?.toString() ?? '',
      fotoProduk: json['foto_produk']?.toString(),
      deskripsi: json['deskripsi']?.toString(),
      jenisHarga: json['jenis_harga']?.toString() ?? 'tetap',
      harga: (json['harga'] as num?)?.toDouble() ?? 0.0,
      hargaMin: (json['harga_min'] as num?)?.toDouble(),
      hargaMax: (json['harga_max'] as num?)?.toDouble(),
      hargaFormatted: json['harga_formatted']?.toString() ?? 'Rp 0',
      satuan: json['satuan']?.toString() ?? 'kg',
      stokFisik: (json['stok_fisik'] as num?)?.toDouble() ?? 0.0,
      stokDitahan: (json['stok_ditahan'] as num?)?.toDouble() ?? 0.0,
      stokTersedia: (json['stok_tersedia'] as num?)?.toDouble() ?? 0.0,
      totalTerjual: (json['total_terjual'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'aktif',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_produk': idProduk,
      'id_pengguna': idPengguna,
      'id_komoditas': idKomoditas,
      'nama_komoditas': namaKomoditas,
      'nama_produk': namaProduk,
      'foto_produk': fotoProduk,
      'deskripsi': deskripsi,
      'jenis_harga': jenisHarga,
      'harga': harga,
      'harga_min': hargaMin,
      'harga_max': hargaMax,
      'harga_formatted': hargaFormatted,
      'satuan': satuan,
      'stok_fisik': stokFisik,
      'stok_ditahan': stokDitahan,
      'stok_tersedia': stokTersedia,
      'total_terjual': totalTerjual,
      'status': status,
    };
  }
}
