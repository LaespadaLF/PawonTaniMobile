/// Representasi entitas data Notifikasi PawonTani Mobile selaras dengan
/// NotificationResource dari backend Laravel.
class ItemNotifikasi {
  final String id;
  final String idNotifikasi;
  final String jenisNotifikasi;
  final String judul;
  final String pesan;
  final String? idPengirim;
  final String? pengirimNama;
  final String idPenerima;
  final String? idLahan;
  final String? namaLahan;
  final Map<String, dynamic>? dataPayload;
  final bool sudahDibaca;
  final DateTime? dibacaPada;
  final DateTime? createdAt;

  const ItemNotifikasi({
    required this.id,
    required this.idNotifikasi,
    required this.jenisNotifikasi,
    required this.judul,
    required this.pesan,
    this.idPengirim,
    this.pengirimNama,
    required this.idPenerima,
    this.idLahan,
    this.namaLahan,
    this.dataPayload,
    this.sudahDibaca = false,
    this.dibacaPada,
    this.createdAt,
  });

  factory ItemNotifikasi.fromJson(Map<String, dynamic> json) {
    final rawId = (json['id'] ?? json['id_notifikasi'] ?? '').toString();
    final rawIdNotif = (json['id_notifikasi'] ?? json['id'] ?? '').toString();

    DateTime? dibacaPada;
    if (json['dibaca_pada'] != null) {
      dibacaPada = DateTime.tryParse(json['dibaca_pada'].toString());
    }

    DateTime? createdAt;
    if (json['created_at'] != null) {
      createdAt = DateTime.tryParse(json['created_at'].toString());
    }

    Map<String, dynamic>? payload;
    if (json['data_payload'] != null && json['data_payload'] is Map) {
      payload = Map<String, dynamic>.from(json['data_payload'] as Map);
    }

    final sudahDibacaVal = json['sudah_dibaca'];
    final bool sudahDibaca = (sudahDibacaVal is bool)
        ? sudahDibacaVal
        : (sudahDibacaVal == 1 || sudahDibacaVal == '1' || sudahDibacaVal == 'true');

    return ItemNotifikasi(
      id: rawId.isNotEmpty ? rawId : rawIdNotif,
      idNotifikasi: rawIdNotif.isNotEmpty ? rawIdNotif : rawId,
      jenisNotifikasi: (json['jenis_notifikasi'] ?? '').toString(),
      judul: (json['judul'] ?? '').toString(),
      pesan: (json['pesan'] ?? '').toString(),
      idPengirim: json['id_pengirim']?.toString(),
      pengirimNama: json['pengirim_nama']?.toString(),
      idPenerima: (json['id_penerima'] ?? '').toString(),
      idLahan: json['id_lahan']?.toString(),
      namaLahan: json['nama_lahan']?.toString(),
      dataPayload: payload,
      sudahDibaca: sudahDibaca,
      dibacaPada: dibacaPada,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_notifikasi': idNotifikasi,
      'jenis_notifikasi': jenisNotifikasi,
      'judul': judul,
      'pesan': pesan,
      'id_pengirim': idPengirim,
      'pengirim_nama': pengirimNama,
      'id_penerima': idPenerima,
      'id_lahan': idLahan,
      'nama_lahan': namaLahan,
      'data_payload': dataPayload,
      'sudah_dibaca': sudahDibaca,
      'dibaca_pada': dibacaPada?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Membuat duplikat objek dengan status sudah dibaca diperbarui.
  ItemNotifikasi copyWith({
    bool? sudahDibaca,
    DateTime? dibacaPada,
  }) {
    return ItemNotifikasi(
      id: id,
      idNotifikasi: idNotifikasi,
      jenisNotifikasi: jenisNotifikasi,
      judul: judul,
      pesan: pesan,
      idPengirim: idPengirim,
      pengirimNama: pengirimNama,
      idPenerima: idPenerima,
      idLahan: idLahan,
      namaLahan: namaLahan,
      dataPayload: dataPayload,
      sudahDibaca: sudahDibaca ?? this.sudahDibaca,
      dibacaPada: dibacaPada ?? this.dibacaPada,
      createdAt: createdAt,
    );
  }

  // ==================== CONVENIENCE ACCESSORS ====================

  /// Alias status terbaca
  bool get isRead => sudahDibaca;

  /// Kategori entitas bisnis: 'lahan', 'siklus_tanam', 'panen', atau 'lainnya'
  String get entityType {
    if (dataPayload != null && dataPayload!['entity_type'] != null) {
      final et = dataPayload!['entity_type'].toString().trim().toLowerCase();
      if (et.isNotEmpty) return et;
    }

    final j = jenisNotifikasi.toLowerCase();
    if (j.startsWith('panen')) return 'panen';
    if (j.startsWith('siklus')) return 'siklus_tanam';
    if (j.contains('lahan') || j == 'perlu_perbaikan') return 'lahan';
    return 'lainnya';
  }

  /// ID entitas target (lahan, siklus, atau panen)
  String? get entityId {
    if (dataPayload != null && dataPayload!['entity_id'] != null) {
      final eid = dataPayload!['entity_id'].toString().trim();
      if (eid.isNotEmpty) return eid;
    }
    if (entityType == 'lahan') {
      return targetLahanId;
    }
    if (entityType == 'panen') {
      return targetPanenId;
    }
    if (entityType == 'siklus_tanam') {
      return targetSiklusId;
    }
    return null;
  }

  /// ID Lahan terasosiasi
  String? get targetLahanId {
    if (idLahan != null && idLahan!.isNotEmpty) return idLahan;
    if (dataPayload != null && dataPayload!['id_lahan'] != null) {
      final l = dataPayload!['id_lahan'].toString().trim();
      if (l.isNotEmpty) return l;
    }
    return null;
  }

  /// ID Siklus Tanam terasosiasi
  String? get targetSiklusId {
    if (entityType == 'siklus_tanam') {
      final eid = dataPayload?['entity_id']?.toString().trim();
      if (eid != null && eid.isNotEmpty) return eid;
    }
    if (dataPayload != null && dataPayload!['id_siklus'] != null) {
      final s = dataPayload!['id_siklus'].toString().trim();
      if (s.isNotEmpty) return s;
    }
    return null;
  }

  /// ID Panen terasosiasi
  String? get targetPanenId {
    if (entityType == 'panen') {
      final eid = dataPayload?['entity_id']?.toString().trim();
      if (eid != null && eid.isNotEmpty) return eid;
    }
    if (dataPayload != null && dataPayload!['id_panen'] != null) {
      final p = dataPayload!['id_panen'].toString().trim();
      if (p.isNotEmpty) return p;
    }
    return null;
  }
}

/// Metadata Pagination respons notifikasi.
class NotifikasiPaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const NotifikasiPaginationMeta({
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 15,
    this.total = 0,
  });

  factory NotifikasiPaginationMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const NotifikasiPaginationMeta();
    return NotifikasiPaginationMeta(
      currentPage: int.tryParse(json['current_page']?.toString() ?? '1') ?? 1,
      lastPage: int.tryParse(json['last_page']?.toString() ?? '1') ?? 1,
      perPage: int.tryParse(json['per_page']?.toString() ?? '15') ?? 15,
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
    );
  }

  bool get hasMore => currentPage < lastPage;
}
