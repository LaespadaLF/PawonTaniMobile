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
  });

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
    );
  }
}
