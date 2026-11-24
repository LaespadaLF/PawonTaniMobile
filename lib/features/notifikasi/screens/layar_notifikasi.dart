import 'package:flutter/material.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';

enum JenisNotifikasi {
  panenTerkirim,
  panenDiperiksa,
  panenDisetujui,
  panenDitolak,
  transaksi,
}

class ItemNotifikasi {
  final String id;
  final String judul;
  final String pesan;
  final String waktu;
  final JenisNotifikasi jenis;
  final bool dibaca;
  final String? kodeReferensi;
  final String? alasanPenolakan;

  const ItemNotifikasi({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.waktu,
    required this.jenis,
    this.dibaca = false,
    this.kodeReferensi,
    this.alasanPenolakan,
  });

  ItemNotifikasi copyWith({bool? dibaca}) {
    return ItemNotifikasi(
      id: id,
      judul: judul,
      pesan: pesan,
      waktu: waktu,
      jenis: jenis,
      dibaca: dibaca ?? this.dibaca,
      kodeReferensi: kodeReferensi,
      alasanPenolakan: alasanPenolakan,
    );
  }
}

class LayarNotifikasi extends StatefulWidget {
  const LayarNotifikasi({super.key});

  @override
  State<LayarNotifikasi> createState() => _LayarNotifikasiState();
}

class _LayarNotifikasiState extends State<LayarNotifikasi> {
  int _selectedFilter = 0; // 0: Semua, 1: Panen, 2: Transaksi

  late List<ItemNotifikasi> _notifikasiList;

  @override
  void initState() {
    super.initState();
    _notifikasiList = [
      const ItemNotifikasi(
        id: '1',
        judul: 'Laporan Panen Disetujui',
        pesan: 'Laporan hasil panen Padi Ciherang seberat 3.200 Kg pada petak Sawah Blok Timur telah diverifikasi dan disetujui oleh Pengurus.',
        waktu: '10 menit yang lalu',
        jenis: JenisNotifikasi.panenDisetujui,
        kodeReferensi: 'PNN-202611-002',
        dibaca: false,
      ),
      const ItemNotifikasi(
        id: '2',
        judul: 'Laporan Panen Ditolak',
        pesan: 'Laporan hasil panen Jagung Manis (PNN-202611-003) ditolak oleh Admin.',
        waktu: '1 jam yang lalu',
        jenis: JenisNotifikasi.panenDitolak,
        kodeReferensi: 'PNN-202611-003',
        alasanPenolakan: 'Foto bukti timbangan buram/tidak terbaca dan kadar air tercatat melebihi batas toleransi mutu kelompok tani (maks 15%). Silakan perbaiki dan laporkan kembali.',
        dibaca: false,
      ),
      const ItemNotifikasi(
        id: '3',
        judul: 'Laporan Sedang Diperiksa',
        pesan: 'Laporan hasil panen Padi Pandanwangi Anda saat ini sedang dalam proses pemeriksaan dan validasi lapangan oleh tim verifikator kelompok tani.',
        waktu: '3 jam yang lalu',
        jenis: JenisNotifikasi.panenDiperiksa,
        kodeReferensi: 'PNN-202611-004',
        dibaca: true,
      ),
      const ItemNotifikasi(
        id: '4',
        judul: 'Laporan Panen Berhasil Dikirim',
        pesan: 'Laporan panen baru berhasil disimpan ke sistem pusat dan siap ditinjau oleh pengurus kelompok tani.',
        waktu: 'Kemarin, 14.30 WIB',
        jenis: JenisNotifikasi.panenTerkirim,
        kodeReferensi: 'PNN-202611-001',
        dibaca: true,
      ),
      const ItemNotifikasi(
        id: '5',
        judul: 'Pembayaran Penjualan Diterima',
        pesan: 'Dana hasil transaksi penjualan gabah kering sebesar Rp 24.150.000 telah berhasil diverifikasi lunas melalui Koperasi Tani Sumber Makmur.',
        waktu: 'Kemarin, 10.15 WIB',
        jenis: JenisNotifikasi.transaksi,
        kodeReferensi: 'TRX-PN-20261115-889',
        dibaca: true,
      ),
      const ItemNotifikasi(
        id: '6',
        judul: 'Pesanan Baru Masuk',
        pesan: 'Terdapat pemesanan 500 Kg Beras Organik Ciherang dari pembeli lokal. Segera siapkan pengemasan produk.',
        waktu: '2 hari yang lalu',
        jenis: JenisNotifikasi.transaksi,
        kodeReferensi: 'TRX-MKT-20261112-004',
        dibaca: true,
      ),
    ];
  }

  void _tandaiSemuaDibaca() {
    setState(() {
      _notifikasiList = _notifikasiList.map((item) => item.copyWith(dibaca: true)).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua notifikasi telah ditandai sebagai dibaca.'),
        backgroundColor: WarnaAplikasi.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  List<ItemNotifikasi> get _filteredList {
    if (_selectedFilter == 1) {
      return _notifikasiList
          .where((item) =>
              item.jenis == JenisNotifikasi.panenTerkirim ||
              item.jenis == JenisNotifikasi.panenDiperiksa ||
              item.jenis == JenisNotifikasi.panenDisetujui ||
              item.jenis == JenisNotifikasi.panenDitolak)
          .toList();
    }
    if (_selectedFilter == 2) {
      return _notifikasiList.where((item) => item.jenis == JenisNotifikasi.transaksi).toList();
    }
    return _notifikasiList;
  }

  int get _unreadCount => _notifikasiList.where((item) => !item.dibaca).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarnaAplikasi.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: WarnaAplikasi.primaryDark, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifikasi',
              style: TextStyle(
                color: WarnaAplikasi.primaryDark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            if (_unreadCount > 0)
              Text(
                '$_unreadCount belum dibaca',
                style: const TextStyle(
                  color: WarnaAplikasi.textGray,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton.icon(
              onPressed: _tandaiSemuaDibaca,
              icon: const Icon(Icons.done_all_rounded, size: 16, color: WarnaAplikasi.primary),
              label: const Text(
                'Baca Semua',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: WarnaAplikasi.primary,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs (Semua, Panen, Transaksi)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip(0, 'Semua'),
                const SizedBox(width: 8),
                _buildFilterChip(1, 'Laporan Panen'),
                const SizedBox(width: 8),
                _buildFilterChip(2, 'Transaksi'),
              ],
            ),
          ),
          const Divider(height: 1, color: WarnaAplikasi.border),

          // Notification List
          Expanded(
            child: _filteredList.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    itemCount: _filteredList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _filteredList[index];
                      return _buildNotificationCard(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _selectedFilter == index;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = index),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? WarnaAplikasi.primary : WarnaAplikasi.greenLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? WarnaAplikasi.primary : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : WarnaAplikasi.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(ItemNotifikasi item) {
    Color iconBg;
    Color iconColor;
    IconData iconData;
    String badgeLabel;
    Color badgeColor;
    Color badgeTextColor;

    switch (item.jenis) {
      case JenisNotifikasi.panenDisetujui:
        iconBg = const Color(0xFFEAF5E8);
        iconColor = WarnaAplikasi.primary;
        iconData = Icons.check_circle_rounded;
        badgeLabel = 'DISETUJUI';
        badgeColor = const Color(0xFFEAF5E8);
        badgeTextColor = const Color(0xFF24573A);
        break;
      case JenisNotifikasi.panenDitolak:
        iconBg = const Color(0xFFFEF2F2);
        iconColor = const Color(0xFFDC2626);
        iconData = Icons.cancel_rounded;
        badgeLabel = 'DITOLAK';
        badgeColor = const Color(0xFFFEF2F2);
        badgeTextColor = const Color(0xFFB91C1C);
        break;
      case JenisNotifikasi.panenDiperiksa:
        iconBg = const Color(0xFFFFFBEB);
        iconColor = const Color(0xFFD97706);
        iconData = Icons.hourglass_top_rounded;
        badgeLabel = 'MENUNGGU';
        badgeColor = const Color(0xFFFFFBEB);
        badgeTextColor = const Color(0xFFB45309);
        break;
      case JenisNotifikasi.panenTerkirim:
        iconBg = const Color(0xFFEFF6FF);
        iconColor = const Color(0xFF2563EB);
        iconData = Icons.send_rounded;
        badgeLabel = 'TERKIRIM';
        badgeColor = const Color(0xFFEFF6FF);
        badgeTextColor = const Color(0xFF1D4ED8);
        break;
      case JenisNotifikasi.transaksi:
        iconBg = const Color(0xFFF3E8FF);
        iconColor = const Color(0xFF7E22CE);
        iconData = Icons.receipt_long_rounded;
        badgeLabel = 'TRANSAKSI';
        badgeColor = const Color(0xFFF3E8FF);
        badgeTextColor = const Color(0xFF6B21A8);
        break;
    }

    return InkWell(
      onTap: () {
        setState(() {
          final idx = _notifikasiList.indexWhere((n) => n.id == item.id);
          if (idx != -1) {
            _notifikasiList[idx] = _notifikasiList[idx].copyWith(dibaca: true);
          }
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.dibaca ? Colors.white : const Color(0xFFF7FAF7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.dibaca ? WarnaAplikasi.border : WarnaAplikasi.primary.withOpacity(0.35),
            width: item.dibaca ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),

                // Title, Badge, Time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.judul,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: item.dibaca ? FontWeight.w600 : FontWeight.w800,
                                color: WarnaAplikasi.primaryDark,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badgeLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: badgeTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            item.waktu,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: WarnaAplikasi.textGray,
                            ),
                          ),
                          if (item.kodeReferensi != null) ...[
                            const Text(' • ', style: TextStyle(color: WarnaAplikasi.textGray)),
                            Text(
                              item.kodeReferensi!,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: WarnaAplikasi.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Message Body
            Padding(
              padding: const EdgeInsets.only(left: 52),
              child: Text(
                item.pesan,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: Color(0xFF374151),
                ),
              ),
            ),

            // Rejection reason banner if rejected
            if (item.alasanPenolakan != null) ...[
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.only(left: 52),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFFDC2626), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Alasan Penolakan: ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF991B1B),
                              ),
                            ),
                            TextSpan(
                              text: item.alasanPenolakan!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF7F1D1D),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: WarnaAplikasi.greenLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: WarnaAplikasi.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada Notifikasi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: WarnaAplikasi.primaryDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Semua pemberitahuan panen dan transaksi\nakan muncul di halaman ini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: WarnaAplikasi.textGray,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
