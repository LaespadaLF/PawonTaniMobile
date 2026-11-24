// Model untuk data transaksi penjualan hasil panen & integrasi marketplace

enum SaleStatus {
  lunas,
  tempoAktif,
  uangMuka,
  prosesVerifikasi,
  dibatalkan,
  belumDibayar,
}

enum PaymentMethod {
  transferBRI,
  tunaiKasPoktan,
  tunaiLangsung,
  tempoMingguan,
}

enum CommodityType {
  gabahKeringPanen,
  gabahKeringGiling,
  jagungManisPipil,
  jagungManisTongkol,
  padiIr64,
  lainnya,
}

class RiwayatPembayaranItem {
  final String idPembayaran;
  final double nominal;
  final DateTime? tanggalPembayaran;
  final String keterangan;
  final String statusVerifikasi;

  const RiwayatPembayaranItem({
    required this.idPembayaran,
    required this.nominal,
    this.tanggalPembayaran,
    this.keterangan = '',
    this.statusVerifikasi = 'terverifikasi',
  });

  factory RiwayatPembayaranItem.fromJson(Map<String, dynamic> json) {
    return RiwayatPembayaranItem(
      idPembayaran: json['id_pembayaran']?.toString() ?? '',
      nominal: (json['nominal'] as num?)?.toDouble() ?? 0.0,
      tanggalPembayaran: json['tanggal_pembayaran'] != null
          ? DateTime.tryParse(json['tanggal_pembayaran'].toString())
          : null,
      keterangan: json['keterangan']?.toString() ?? '',
      statusVerifikasi: json['status_verifikasi']?.toString() ?? 'terverifikasi',
    );
  }
}

class SaleItem {
  final String id;
  final String trxCode;
  final CommodityType commodityType;
  final String commodityName;
  final String commoditySubtitle;
  final SaleStatus status;
  final DateTime transactionDate;
  final String timeStr;
  final double volumeKg;
  final String satuan;
  final double pricePerKg;
  final double totalValue;
  final double totalReceived;
  final String buyerName;
  final String? buyerPhone;
  final PaymentMethod paymentMethod;
  final String paymentMethodLabel;
  final String notes;

  // For tempo/DP transactions
  final bool isTempo;
  final int tempoDays;
  final double dpAmount;
  final double remainingAmount;
  final DateTime? dueDateTempo;

  // For completed / verification
  final String? bankAccountName;
  final String? bankAccountNumber;
  final bool isVerified;

  // New Marketplace integration fields
  final String? idProduk;
  final String statusPenyerahan; // 'belum_diserahkan' | 'diserahkan'
  final String? alasanBatal;
  final List<RiwayatPembayaranItem> riwayatPembayaran;

  const SaleItem({
    required this.id,
    required this.trxCode,
    required this.commodityType,
    required this.commodityName,
    required this.commoditySubtitle,
    required this.status,
    required this.transactionDate,
    required this.timeStr,
    required this.volumeKg,
    this.satuan = 'Kg',
    required this.pricePerKg,
    required this.totalValue,
    required this.totalReceived,
    required this.buyerName,
    this.buyerPhone,
    required this.paymentMethod,
    required this.paymentMethodLabel,
    this.notes = '',
    this.isTempo = false,
    this.tempoDays = 0,
    this.dpAmount = 0,
    this.remainingAmount = 0,
    this.dueDateTempo,
    this.bankAccountName,
    this.bankAccountNumber,
    this.isVerified = false,
    this.idProduk,
    this.statusPenyerahan = 'belum_diserahkan',
    this.alasanBatal,
    this.riwayatPembayaran = const [],
  });

  bool get isSudahDiserahkan => statusPenyerahan == 'diserahkan';
  bool get isDibatalkan => status == SaleStatus.dibatalkan;
  bool get isLunas => status == SaleStatus.lunas;

  String get statusLabel {
    switch (status) {
      case SaleStatus.lunas:
        return 'Lunas';
      case SaleStatus.tempoAktif:
        return 'Tempo Aktif';
      case SaleStatus.uangMuka:
        return 'Uang Muka (DP)';
      case SaleStatus.prosesVerifikasi:
        return 'Proses Verifikasi';
      case SaleStatus.dibatalkan:
        return 'Dibatalkan';
      case SaleStatus.belumDibayar:
        return 'Belum Dibayar';
    }
  }

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status_pembayaran']?.toString().toLowerCase() ?? '';
    SaleStatus sStatus;
    if (statusStr == 'lunas') {
      sStatus = SaleStatus.lunas;
    } else if (statusStr == 'dp') {
      sStatus = SaleStatus.uangMuka;
    } else if (statusStr == 'tempo') {
      sStatus = SaleStatus.tempoAktif;
    } else if (statusStr == 'dibatalkan') {
      sStatus = SaleStatus.dibatalkan;
    } else {
      sStatus = SaleStatus.belumDibayar;
    }

    final double total = (json['total_harga'] as num?)?.toDouble() ?? 0.0;
    final double received = (json['total_dibayar'] as num?)?.toDouble() ?? 0.0;
    final double remaining = (json['sisa_pembayaran'] as num?)?.toDouble() ?? (total - received);

    final rawPayments = json['riwayat_pembayaran'];
    List<RiwayatPembayaranItem> paymentList = [];
    if (rawPayments is List) {
      paymentList = rawPayments
          .map((p) => RiwayatPembayaranItem.fromJson(Map<String, dynamic>.from(p as Map)))
          .toList();
    }

    final trxDate = json['tanggal_transaksi'] != null
        ? (DateTime.tryParse(json['tanggal_transaksi'].toString()) ?? DateTime.now())
        : DateTime.now();

    final id = json['id_penjualan']?.toString() ?? json['id']?.toString() ?? '';
    final code = json['kode_transaksi']?.toString() ?? 'TRX-$id';
    final pName = json['nama_produk']?.toString() ?? 'Hasil Panen';
    final kName = json['nama_komoditas']?.toString() ?? 'Komoditas Pertanian';

    return SaleItem(
      id: id,
      trxCode: code,
      commodityType: CommodityType.lainnya,
      commodityName: pName,
      commoditySubtitle: 'Komoditas: $kName',
      status: sStatus,
      transactionDate: trxDate,
      timeStr: json['waktu_transaksi']?.toString() ?? '10.00 WIB',
      volumeKg: (json['jumlah'] as num?)?.toDouble() ?? 0.0,
      satuan: json['satuan']?.toString() ?? 'Kg',
      pricePerKg: (json['harga_satuan'] as num?)?.toDouble() ?? 0.0,
      totalValue: total,
      totalReceived: received,
      buyerName: json['nama_pembeli']?.toString() ?? 'Pelanggan',
      buyerPhone: json['no_telepon_pembeli']?.toString(),
      paymentMethod: PaymentMethod.transferBRI,
      paymentMethodLabel: json['metode_pembayaran']?.toString().replaceAll('_', ' ').toUpperCase() ?? 'TRANSFER',
      notes: json['catatan']?.toString() ?? '',
      isTempo: sStatus == SaleStatus.tempoAktif,
      dpAmount: received,
      remainingAmount: remaining,
      isVerified: sStatus == SaleStatus.lunas || received > 0,
      idProduk: json['id_produk']?.toString(),
      statusPenyerahan: json['status_penyerahan']?.toString() ?? 'belum_diserahkan',
      alasanBatal: json['alasan_batal']?.toString(),
      riwayatPembayaran: paymentList,
    );
  }
}
