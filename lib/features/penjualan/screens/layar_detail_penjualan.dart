import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:flutter/material.dart';
import 'package:pawon_mobile/features/penjualan/models/item_penjualan.dart';

class SaleDetailScreen extends StatelessWidget {
  final SaleItem item;

  const SaleDetailScreen({super.key, required this.item});

  static const Color _primaryGreen = WarnaAplikasi.primary;
  static const Color _textDark = Color(0xFF0F2018);
  static const Color _textMedium = Color(0xFF3D5C49);
  static const Color _textLight = Color(0xFF6B8572);
  static const Color _bgPage = Color(0xFFF4F7F5);
  static const Color _cardBg = Colors.white;
  static const Color _borderColor = Color(0xFFE2EDE5);
  static const Color _lightGreenBg = Color(0xFFEDF7F0);

  String _formatNum(int num) {
    final s = num.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  String _formatDate(DateTime date) {
    const months = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeroSection(),
                    const SizedBox(height: 12),
                    _buildVerificationBanner(),
                    const SizedBox(height: 12),
                    _buildCommoditySection(),
                    const SizedBox(height: 12),
                    _buildBuyerSection(),
                    const SizedBox(height: 12),
                    _buildPaymentSection(),
                    const SizedBox(height: 12),
                    _buildReceiptImageSection(),
                    const SizedBox(height: 12),
                    _buildFieldNotesSection(),
                    const SizedBox(height: 12),
                    _buildMarketPriceBanner(),
                    const SizedBox(height: 12),
                    _buildActionButtons(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: const Color(0xFFF2F7F4),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: _textMedium),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('POKTAN TANI',
                  style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: _primaryGreen,
                      letterSpacing: 1.2)),
              Text('Detail Transaksi',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                      letterSpacing: -0.2)),
            ],
          ),
          const Spacer(),
          Stack(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: const Color(0xFFF2F7F4),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.notifications_outlined,
                    size: 18, color: _textMedium),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                        color: Color(0xFFE53935), shape: BoxShape.circle)),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: const Color(0xFFF2F7F4),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.person_outline_rounded,
                size: 18, color: _textMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A3828), WarnaAplikasi.primary, Color(0xFF2D6040)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: WarnaAplikasi.primary.withValues(alpha: 0.4),
              blurRadius: 18,
              offset: const Offset(0, 6))
        ],
      ),
      child: Stack(
        children: [
          Positioned(right: -25, top: -35, child: Container(width: 160, height: 160,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.04)))),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                      child: Text('#${item.trxCode}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 0.3)),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: const Color(0xFF4CAF50).withValues(alpha: 0.25), borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF81C784), size: 12),
                          const SizedBox(width: 4),
                          Text(item.status == SaleStatus.lunas
                              ? 'LUNAS (${item.paymentMethodLabel})'
                              : item.statusLabel.toUpperCase(),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF81C784))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('TOTAL DITERIMA (VERIFIKASI\nOTOMATIS)',
                    style: TextStyle(fontSize: 9.5, color: Colors.white60, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
                const SizedBox(height: 4),
                Text('Rp ${_formatNum(item.totalReceived.toInt())}',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('${_formatNum(item.volumeKg.toInt())} Kg x Rp ${_formatNum(item.pricePerKg.toInt())} / Kg',
                        style: const TextStyle(fontSize: 11, color: Colors.white60)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                      child: Text('${_formatDate(item.transactionDate)}\n${item.timeStr}',
                          style: const TextStyle(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.right),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_upward_rounded, color: Color(0xFF81C784), size: 10),
                          SizedBox(width: 3),
                          Text('+18% Musim Lalu',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF81C784))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('HPP Poktan: Rp 6.700 – 7.100',
                        style: TextStyle(fontSize: 10, color: Colors.white54)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.verified_user_rounded, color: Color(0xFF2E7D32), size: 16),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pembayaran Tuntas Terverifikasi.',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: _textDark)),
                SizedBox(height: 3),
                Text(
                    'Dana telah sukses masuk ke Rekening Penampung Kas Petani BRI & dikonfirmasi oleh pengurus Poktan Sumber Makmur.',
                    style: TextStyle(fontSize: 11, color: _textLight, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommoditySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _borderColor)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 16, color: _primaryGreen),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Komoditas & Stok Panen',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _textDark)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: _lightGreenBg, borderRadius: BorderRadius.circular(8)),
                  child: const Text('Tersedia di Lumbung',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _primaryGreen)),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFEDF2EF), height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.commodityName,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _textDark)),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 13, color: _textLight),
                    SizedBox(width: 4),
                    Text('Panen 28 Okt 2024 (Petak Sawah Barat, Kadar Air - 14%)',
                        style: TextStyle(fontSize: 11, color: _textLight)),
                  ],
                ),
                const SizedBox(height: 14),
                // Volume Progress Bar
                Row(
                  children: [
                    const Text('Volume Penjualan Kali Ini',
                        style: TextStyle(fontSize: 11.5, color: _textLight)),
                    const Spacer(),
                    Text('${_formatNum(item.volumeKg.toInt())} Kg',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _textDark)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: item.volumeKg / (item.volumeKg + 2350),
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE8F0EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(_primaryGreen),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text('Sisa Stok Lumbung: 2.350 Kg',
                        style: TextStyle(fontSize: 10.5, color: _textLight)),
                    const Spacer(),
                    Text('Awal: ${_formatNum((item.volumeKg + 2350).toInt())} Kg',
                        style: const TextStyle(fontSize: 10.5, color: _textLight)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: _bgPage, borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Harga Satuan Realisasi',
                                style: TextStyle(fontSize: 10.5, color: _textLight)),
                            const SizedBox(height: 4),
                            Text('Rp ${_formatNum(item.pricePerKg.toInt())} /Kg',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _textDark)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Status Margin',
                                style: TextStyle(fontSize: 10.5, color: _textLight)),
                            const SizedBox(height: 4),
                            const Row(
                              children: [
                                Icon(Icons.trending_up_rounded, size: 14, color: Color(0xFF2E7D32)),
                                SizedBox(width: 4),
                                Text('Di Atas HPP',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyerSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _borderColor)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                const Icon(Icons.handshake_outlined, size: 16, color: _primaryGreen),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Mitra Pembeli / Pengepul',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _textDark)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(8)),
                  child: const Text('Mitra Terdaftar Desa',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF1565C0))),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFEDF2EF), height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: _lightGreenBg, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.account_balance_rounded, color: _primaryGreen, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.buyerName,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _textDark)),
                          const SizedBox(height: 2),
                          const Text('Penanggung Jawab: Bpk. H. Sukirman',
                              style: TextStyle(fontSize: 11, color: _textLight)),
                          const Text('\u260e 0812 - 8899 - 7711',
                              style: TextStyle(fontSize: 11, color: _textLight)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.chat_rounded, size: 16),
                        label: const Text('Chat WhatsApp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _primaryGreen,
                          side: const BorderSide(color: _borderColor, width: 1),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.phone_rounded, size: 16),
                        label: const Text('Telepon', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _borderColor)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded, size: 16, color: _primaryGreen),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Rincian Pembayaran & Bukti Nota',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _textDark)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
                  child: const Text('Auto-Check BRI',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _primaryGreen)),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFEDF2EF), height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _buildPayRow('Kanal Pembayaran', 'Transfer Bank BRI (Virtual Account / Kas)', isGreen: true),
                const SizedBox(height: 10),
                _buildPayRow('No. Rekening Tujuan', item.bankAccountNumber ?? '0129-01-098234-56-1'),
                const SizedBox(height: 10),
                _buildPayRow('Nama Rekening', item.bankAccountName ?? 'Kas Poktan / H. Sukirman'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayRow(String label, String value, {bool isGreen = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: const TextStyle(fontSize: 11, color: _textLight)),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isGreen)
                Container(width: 7, height: 7, margin: const EdgeInsets.only(top: 3, right: 6),
                    decoration: const BoxDecoration(color: Color(0xFF2E7D32), shape: BoxShape.circle)),
              Expanded(
                child: Text(value,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isGreen ? const Color(0xFF2E7D32) : _textDark)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptImageSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _borderColor)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                const Icon(Icons.image_search_rounded, size: 16, color: _primaryGreen),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Lampiran Nota Timbangan Fisik',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _textDark)),
                ),
                const Text('Lihat Fullsize',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _primaryGreen)),
              ],
            ),
          ),
          const Divider(color: Color(0xFFEDF2EF), height: 1),
          Container(
            height: 120,
            margin: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF7F0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.description_outlined, color: _primaryGreen, size: 32),
                      const SizedBox(height: 6),
                      const Text('Nota Timbangan Fisik', style: TextStyle(fontSize: 11, color: _textLight)),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: _primaryGreen, borderRadius: BorderRadius.circular(8)),
                    child: const Row(
                      children: [
                        Icon(Icons.check_rounded, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text('Stempel Basah Tertera',
                            style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF2E7D32), borderRadius: BorderRadius.circular(8)),
                    child: const Text('Terverifikasi',
                        style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldNotesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.edit_note_rounded, size: 16, color: _primaryGreen),
              SizedBox(width: 8),
              Text('Catatan Petugas Lapangan',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _textDark)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor),
            ),
            child: Text(
              item.notes.isNotEmpty
                  ? '"${item.notes}"'
                  : '"Berasal dari petak A, kadar air aman (~14%), gabah telah dipisahkan langsung dengan armada truk Koperasi Sumber Makmur plat R-1824-KA dalam kondisi baik dan timbangan sesuai batas toleransi."',
              style: const TextStyle(
                  fontSize: 12,
                  color: _textMedium,
                  fontStyle: FontStyle.italic,
                  height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketPriceBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.show_chart_rounded, color: _primaryGreen, size: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('Harga Pasar Terkini Banyumas',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _textDark)),
          ),
          const Text('...', style: TextStyle(fontSize: 18, color: _textLight, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Print & Download Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primaryGreen,
                    side: const BorderSide(color: _borderColor, width: 1),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.print_rounded, size: 16),
                  label: const Text('Cetak Kuitansi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primaryGreen,
                    side: const BorderSide(color: _borderColor, width: 1),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: const Text('Unduh Nota PDF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // WhatsApp Share
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A3828),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.share_rounded, size: 18),
              label: const Text('Bagikan Nota ke WhatsApp Mitra',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ],
    );
  }
}

