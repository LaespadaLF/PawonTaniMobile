// Model untuk data transaksi penjualan hasil panen

enum SaleStatus {
  lunas,
  tempoAktif,
  uangMuka,
  prosesVerifikasi,
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
  final double pricePerKg;
  final double totalValue;
  final double totalReceived;
  final String buyerName;
  final PaymentMethod paymentMethod;
  final String paymentMethodLabel;
  final String notes;

  // For tempo transactions
  final bool isTempo;
  final int tempoDays;
  final double dpAmount;
  final double remainingAmount;
  final DateTime? dueDateTempo;

  // For completed transactions
  final String? bankAccountName;
  final String? bankAccountNumber;
  final bool isVerified;

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
    required this.pricePerKg,
    required this.totalValue,
    required this.totalReceived,
    required this.buyerName,
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
  });

  String get statusLabel {
    switch (status) {
      case SaleStatus.lunas:
        return 'Lunas';
      case SaleStatus.tempoAktif:
        return 'Tempo Aktif';
      case SaleStatus.uangMuka:
        return 'Uang Muka';
      case SaleStatus.prosesVerifikasi:
        return 'Proses Verifikasi';
    }
  }
}
