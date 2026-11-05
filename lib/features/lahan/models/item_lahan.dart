enum StatusLahan {
  aktif,
  istirahat,
  persiapan,
}

class ItemLahan {
  final String id;
  final String nama;
  final String lokasi;
  final double luas;
  final String komoditas;
  final StatusLahan status;
  final double? latitude;
  final double? longitude;
  final String? fotoLahan;

  // Atribut Verifikasi Tata Kelola
  final String? statusVerifikasi;
  final String? catatanVerifikasi;
  final DateTime? tanggalVerifikasi;

  // Atribut Komoditas ID
  final String? idKomoditas;

  const ItemLahan({
    required this.id,
    required this.nama,
    required this.lokasi,
    required this.luas,
    required this.komoditas,
    required this.status,
    this.latitude,
    this.longitude,
    this.fotoLahan,
    this.statusVerifikasi,
    this.catatanVerifikasi,
    this.tanggalVerifikasi,
    this.idKomoditas,
  });

  bool get isTerverifikasi => statusVerifikasi == 'terverifikasi';
  bool get isMenungguVerifikasi => statusVerifikasi == 'menunggu_verifikasi';
  bool get isPerluPerbaikan => statusVerifikasi == 'perlu_perbaikan';

  factory ItemLahan.fromJson(Map<String, dynamic> json) {
    final statusString = (json['status'] ?? 'aktif').toString().toLowerCase();
    StatusLahan status;
    switch (statusString) {
      case 'istirahat':
        status = StatusLahan.istirahat;
      case 'persiapan':
        status = StatusLahan.persiapan;
      case 'aktif':
      default:
        status = StatusLahan.aktif;
    }

    DateTime? tanggalVerif;
    if (json['tanggal_verifikasi'] != null) {
      tanggalVerif = DateTime.tryParse(json['tanggal_verifikasi'].toString());
    }

    String? parsedIdKomoditas;
    if (json['detail_komoditas'] is Map) {
      parsedIdKomoditas = (json['detail_komoditas'] as Map)['id_komoditas']?.toString();
    } else if (json['id_komoditas'] != null) {
      parsedIdKomoditas = json['id_komoditas'].toString();
    }

    return ItemLahan(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      lokasi: json['lokasi']?.toString() ?? '',
      luas: json['luas'] != null ? (double.tryParse(json['luas'].toString()) ?? 0.0) : 0.0,
      komoditas: json['komoditas']?.toString() ?? '',
      status: status,
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      fotoLahan: json['foto_lahan']?.toString(),
      statusVerifikasi: json['status_verifikasi']?.toString(),
      catatanVerifikasi: json['catatan_verifikasi']?.toString(),
      tanggalVerifikasi: tanggalVerif,
      idKomoditas: parsedIdKomoditas,
    );
  }

  ItemLahan copyWith({
    String? id,
    String? nama,
    String? lokasi,
    double? luas,
    String? komoditas,
    StatusLahan? status,
    double? latitude,
    double? longitude,
    String? fotoLahan,
    String? statusVerifikasi,
    String? catatanVerifikasi,
    DateTime? tanggalVerifikasi,
    String? idKomoditas,
  }) {
    return ItemLahan(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      lokasi: lokasi ?? this.lokasi,
      luas: luas ?? this.luas,
      komoditas: komoditas ?? this.komoditas,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fotoLahan: fotoLahan ?? this.fotoLahan,
      statusVerifikasi: statusVerifikasi ?? this.statusVerifikasi,
      catatanVerifikasi: catatanVerifikasi ?? this.catatanVerifikasi,
      tanggalVerifikasi: tanggalVerifikasi ?? this.tanggalVerifikasi,
      idKomoditas: idKomoditas ?? this.idKomoditas,
    );
  }
}
