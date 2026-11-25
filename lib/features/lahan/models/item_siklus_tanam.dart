class ItemRiwayatPengakhiran {
  final String idRiwayat;
  final String? jenisPengakhiran;
  final String? aksi;
  final String? statusSebelumnya;
  final String? statusSesudahnya;
  final String? alasan;
  final String? fotoBukti;
  final String? verifikatorId;
  final String? verifikatorNama;
  final String? catatanVerifikasi;
  final DateTime? tanggalKeputusan;
  final Map<String, dynamic>? snapshotData;
  final DateTime? createdAt;

  const ItemRiwayatPengakhiran({
    required this.idRiwayat,
    this.jenisPengakhiran,
    this.aksi,
    this.statusSebelumnya,
    this.statusSesudahnya,
    this.alasan,
    this.fotoBukti,
    this.verifikatorId,
    this.verifikatorNama,
    this.catatanVerifikasi,
    this.tanggalKeputusan,
    this.snapshotData,
    this.createdAt,
  });

  factory ItemRiwayatPengakhiran.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null || val.toString().isEmpty) return null;
      return DateTime.tryParse(val.toString());
    }

    return ItemRiwayatPengakhiran(
      idRiwayat: (json['id_riwayat'] ?? '').toString(),
      jenisPengakhiran: json['jenis_pengakhiran']?.toString(),
      aksi: json['aksi']?.toString(),
      statusSebelumnya: json['status_sebelumnya']?.toString(),
      statusSesudahnya: json['status_sesudahnya']?.toString(),
      alasan: json['alasan']?.toString(),
      fotoBukti: json['foto_bukti']?.toString(),
      verifikatorId: json['verifikator_id']?.toString(),
      verifikatorNama: json['verifikator_nama']?.toString(),
      catatanVerifikasi: json['catatan_verifikasi']?.toString(),
      tanggalKeputusan: parseDate(json['tanggal_keputusan']),
      snapshotData: json['snapshot_data'] is Map ? Map<String, dynamic>.from(json['snapshot_data'] as Map) : null,
      createdAt: parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_riwayat': idRiwayat,
      'jenis_pengakhiran': jenisPengakhiran,
      'aksi': aksi,
      'status_sebelumnya': statusSebelumnya,
      'status_sesudahnya': statusSesudahnya,
      'alasan': alasan,
      'foto_bukti': fotoBukti,
      'verifikator_id': verifikatorId,
      'verifikator_nama': verifikatorNama,
      'catatan_verifikasi': catatanVerifikasi,
      'tanggal_keputusan': tanggalKeputusan?.toIso8601String(),
      'snapshot_data': snapshotData,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class ItemSiklusTanam {
  final String idSiklus;
  final String idLahan;
  final String idKomoditas;
  final String komoditasNama;
  final String? varietas;
  final String musimTanam;
  final DateTime? tanggalMulai;
  final DateTime? estimasiPanen;
  final DateTime? tanggalSelesai;
  final String status;
  final bool isBerjalan;
  final bool isBolehInput;
  final String? jenisPengakhiran;
  final DateTime? tanggalPengajuan;
  final DateTime? tanggalVerifikasi;
  final String? alasanPengakhiran;
  final String? fotoBuktiGagal;
  final String? fotoBuktiGagalUrl;
  final String? diverifikasiOleh;
  final String? catatanVerifikasi;
  final double? targetPanenTon;
  final double? totalPanenKg;
  final double? totalPanenTon;
  final double? persentaseTarget;
  final List<ItemRiwayatPengakhiran> riwayatPengakhiran;
  final String? idKelompok;
  final String? namaKelompok;
  final String? namaPencatat;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isAktif => status == 'aktif';
  bool get isMenungguSelesai => status == 'menunggu_selesai';
  bool get isMenungguGagal => status == 'menunggu_gagal';
  bool get isMenungguVerifikasi => isMenungguSelesai || isMenungguGagal;
  bool get isSelesai => status == 'selesai';
  bool get isGagal => status == 'gagal';
  bool get isDibatalkan => status == 'dibatalkan';
  bool get isTerminal => isSelesai || isGagal || isDibatalkan;

  String get statusLabel {
    switch (status) {
      case 'aktif':
        return 'Aktif';
      case 'menunggu_selesai':
        return 'Menunggu Selesai';
      case 'menunggu_gagal':
        return 'Menunggu Gagal';
      case 'selesai':
        return 'Selesai';
      case 'gagal':
        return 'Gagal';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  String get tanggalMulaiFormatted {
    if (tanggalMulai == null) return '-';
    return '${tanggalMulai!.day.toString().padLeft(2, '0')}/${tanggalMulai!.month.toString().padLeft(2, '0')}/${tanggalMulai!.year}';
  }

  String get tanggalSelesaiFormatted {
    if (tanggalSelesai == null) return '-';
    return '${tanggalSelesai!.day.toString().padLeft(2, '0')}/${tanggalSelesai!.month.toString().padLeft(2, '0')}/${tanggalSelesai!.year}';
  }

  const ItemSiklusTanam({
    required this.idSiklus,
    required this.idLahan,
    required this.idKomoditas,
    required this.komoditasNama,
    this.varietas,
    required this.musimTanam,
    this.tanggalMulai,
    this.estimasiPanen,
    this.tanggalSelesai,
    required this.status,
    this.isBerjalan = false,
    this.isBolehInput = false,
    this.jenisPengakhiran,
    this.tanggalPengajuan,
    this.tanggalVerifikasi,
    this.alasanPengakhiran,
    this.fotoBuktiGagal,
    this.fotoBuktiGagalUrl,
    this.diverifikasiOleh,
    this.catatanVerifikasi,
    this.targetPanenTon,
    this.totalPanenKg,
    this.totalPanenTon,
    this.persentaseTarget,
    this.riwayatPengakhiran = const [],
    this.idKelompok,
    this.namaKelompok,
    this.namaPencatat,
    this.createdAt,
    this.updatedAt,
  });

  factory ItemSiklusTanam.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null || val.toString().isEmpty) return null;
      return DateTime.tryParse(val.toString());
    }

    String? namaKelompok;
    if (json['kelompok'] is Map) {
      namaKelompok = json['kelompok']['nama_kelompok']?.toString();
    }

    String? namaPencatat;
    if (json['pencatat'] is Map) {
      namaPencatat = json['pencatat']['nama']?.toString();
    }

    double? parseDouble(dynamic val) {
      if (val == null) return null;
      return double.tryParse(val.toString());
    }

    List<ItemRiwayatPengakhiran> parseRiwayat(dynamic val) {
      if (val is! List) return [];
      return val
          .whereType<Map>()
          .map((item) => ItemRiwayatPengakhiran.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return ItemSiklusTanam(
      idSiklus: (json['id_siklus'] ?? json['id'] ?? '').toString(),
      idLahan: (json['id_lahan'] ?? '').toString(),
      idKomoditas: (json['id_komoditas'] ?? '').toString(),
      komoditasNama: (json['komoditas_nama'] ?? '').toString(),
      varietas: json['varietas']?.toString(),
      musimTanam: (json['musim_tanam'] ?? '').toString(),
      tanggalMulai: parseDate(json['tanggal_mulai']),
      estimasiPanen: parseDate(json['estimasi_panen']),
      tanggalSelesai: parseDate(json['tanggal_selesai']),
      status: (json['status'] ?? 'aktif').toString(),
      isBerjalan: json['is_berjalan'] == true,
      isBolehInput: json['is_boleh_input'] == true,
      jenisPengakhiran: json['jenis_pengakhiran']?.toString(),
      tanggalPengajuan: parseDate(json['tanggal_pengajuan']),
      tanggalVerifikasi: parseDate(json['tanggal_verifikasi']),
      alasanPengakhiran: json['alasan_pengakhiran']?.toString(),
      fotoBuktiGagal: json['foto_bukti_gagal']?.toString(),
      fotoBuktiGagalUrl: json['foto_bukti_gagal_url']?.toString(),
      diverifikasiOleh: json['diverifikasi_oleh']?.toString(),
      catatanVerifikasi: json['catatan_verifikasi']?.toString(),
      targetPanenTon: parseDouble(json['target_panen_ton']),
      totalPanenKg: parseDouble(json['total_panen_kg']),
      totalPanenTon: parseDouble(json['total_panen_ton']),
      persentaseTarget: parseDouble(json['persentase_target']),
      riwayatPengakhiran: parseRiwayat(json['riwayat_pengakhiran']),
      idKelompok: json['id_kelompok']?.toString(),
      namaKelompok: namaKelompok,
      namaPencatat: namaPencatat,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_siklus': idSiklus,
      'id_lahan': idLahan,
      'id_komoditas': idKomoditas,
      'komoditas_nama': komoditasNama,
      'varietas': varietas,
      'musim_tanam': musimTanam,
      'tanggal_mulai': tanggalMulai?.toIso8601String(),
      'estimasi_panen': estimasiPanen?.toIso8601String(),
      'tanggal_selesai': tanggalSelesai?.toIso8601String(),
      'status': status,
      'is_berjalan': isBerjalan,
      'is_boleh_input': isBolehInput,
      'jenis_pengakhiran': jenisPengakhiran,
      'tanggal_pengajuan': tanggalPengajuan?.toIso8601String(),
      'tanggal_verifikasi': tanggalVerifikasi?.toIso8601String(),
      'alasan_pengakhiran': alasanPengakhiran,
      'foto_bukti_gagal': fotoBuktiGagal,
      'foto_bukti_gagal_url': fotoBuktiGagalUrl,
      'diverifikasi_oleh': diverifikasiOleh,
      'catatan_verifikasi': catatanVerifikasi,
      'target_panen_ton': targetPanenTon,
      'total_panen_kg': totalPanenKg,
      'total_panen_ton': totalPanenTon,
      'persentase_target': persentaseTarget,
      'riwayat_pengakhiran': riwayatPengakhiran.map((r) => r.toJson()).toList(),
      'id_kelompok': idKelompok,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
