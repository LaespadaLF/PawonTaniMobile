enum StatusLahan {
  aktif,
  istirahat,
  persiapan,
}

/// Representasi entitas riwayat audit verifikasi lahan dari backend.
class ItemRiwayatVerifikasiLahan {
  final String id;
  final String idLahan;
  final String aksi;
  final String? statusSebelumnya;
  final String statusSesudahnya;
  final String? catatan;
  final int nomorRevisi;
  final String? namaAktor;
  final String? jabatanAktor;
  final DateTime? createdAt;

  const ItemRiwayatVerifikasiLahan({
    required this.id,
    required this.idLahan,
    required this.aksi,
    this.statusSebelumnya,
    required this.statusSesudahnya,
    this.catatan,
    this.nomorRevisi = 0,
    this.namaAktor,
    this.jabatanAktor,
    this.createdAt,
  });

  factory ItemRiwayatVerifikasiLahan.fromJson(Map<String, dynamic> json) {
    String? namaAktor;
    String? jabatanAktor;
    if (json['aktor'] is Map) {
      final aktorMap = json['aktor'] as Map;
      namaAktor = aktorMap['nama']?.toString();
      jabatanAktor = aktorMap['jabatan']?.toString();
    }

    DateTime? createdAt;
    if (json['created_at'] != null) {
      createdAt = DateTime.tryParse(json['created_at'].toString());
    }

    return ItemRiwayatVerifikasiLahan(
      id: (json['id'] ?? json['id_riwayat'] ?? '').toString(),
      idLahan: (json['id_lahan'] ?? '').toString(),
      aksi: (json['aksi'] ?? '').toString(),
      statusSebelumnya: json['status_sebelumnya']?.toString(),
      statusSesudahnya: (json['status_sesudahnya'] ?? '').toString(),
      catatan: json['catatan']?.toString(),
      nomorRevisi: int.tryParse(json['nomor_revisi']?.toString() ?? '0') ?? 0,
      namaAktor: namaAktor,
      jabatanAktor: jabatanAktor,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_riwayat': id,
      'id_lahan': idLahan,
      'aksi': aksi,
      'status_sebelumnya': statusSebelumnya,
      'status_sesudahnya': statusSesudahnya,
      'catatan': catatan,
      'nomor_revisi': nomorRevisi,
      if (namaAktor != null || jabatanAktor != null)
        'aktor': {
          'nama': namaAktor,
          'jabatan': jabatanAktor,
        },
      'created_at': createdAt?.toIso8601String(),
    };
  }
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

  // Atribut Operasional & Dokumen (F-04)
  final String? keterangan;
  final String? musimTanam;
  final int nomorRevisi;

  // Hak Akses Client dari Backend Policy (F-04)
  final bool isCanDelete;
  final bool isCanEdit;

  // Riwayat Verifikasi (F-04)
  final List<ItemRiwayatVerifikasiLahan> riwayatVerifikasi;

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
    this.keterangan,
    this.musimTanam,
    this.nomorRevisi = 0,
    this.isCanDelete = false,
    this.isCanEdit = false,
    this.riwayatVerifikasi = const [],
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

    final List<ItemRiwayatVerifikasiLahan> riwayatList = [];
    if (json['riwayat_verifikasi'] is List) {
      for (final item in json['riwayat_verifikasi'] as List) {
        if (item is Map) {
          riwayatList.add(ItemRiwayatVerifikasiLahan.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return ItemLahan(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      lokasi: (json['lokasi'] ?? json['alamat_lahan'] ?? '').toString(),
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
      keterangan: json['keterangan']?.toString(),
      musimTanam: json['musim_tanam']?.toString(),
      nomorRevisi: int.tryParse(json['nomor_revisi']?.toString() ?? '0') ?? 0,
      isCanDelete: json['is_can_delete'] == true,
      isCanEdit: json['is_can_edit'] == true,
      riwayatVerifikasi: riwayatList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'lokasi': lokasi,
      'alamat_lahan': lokasi,
      'luas': luas,
      'komoditas': komoditas,
      'status': status.name,
      'latitude': latitude,
      'longitude': longitude,
      'foto_lahan': fotoLahan,
      'status_verifikasi': statusVerifikasi,
      'catatan_verifikasi': catatanVerifikasi,
      'tanggal_verifikasi': tanggalVerifikasi?.toIso8601String(),
      'id_komoditas': idKomoditas,
      'keterangan': keterangan,
      'musim_tanam': musimTanam,
      'nomor_revisi': nomorRevisi,
      'is_can_delete': isCanDelete,
      'is_can_edit': isCanEdit,
      'riwayat_verifikasi': riwayatVerifikasi.map((r) => r.toJson()).toList(),
    };
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
    String? keterangan,
    String? musimTanam,
    int? nomorRevisi,
    bool? isCanDelete,
    bool? isCanEdit,
    List<ItemRiwayatVerifikasiLahan>? riwayatVerifikasi,
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
      keterangan: keterangan ?? this.keterangan,
      musimTanam: musimTanam ?? this.musimTanam,
      nomorRevisi: nomorRevisi ?? this.nomorRevisi,
      isCanDelete: isCanDelete ?? this.isCanDelete,
      isCanEdit: isCanEdit ?? this.isCanEdit,
      riwayatVerifikasi: riwayatVerifikasi ?? this.riwayatVerifikasi,
    );
  }
}
