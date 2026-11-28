import 'package:flutter/material.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/core/utils/currency_input_formatter.dart';
import 'package:pawon_mobile/core/widgets/pawon_form_header.dart';
import 'package:pawon_mobile/features/penjualan/models/item_penjualan.dart';
import 'package:pawon_mobile/features/penjualan/services/marketplace_penjualan_api_service.dart';

class SaleDetailScreen extends StatefulWidget {
  final SaleItem item;

  const SaleDetailScreen({super.key, required this.item});

  @override
  State<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends State<SaleDetailScreen> {
  late SaleItem _item;
  bool _isLoading = false;
  final _apiService = MarketplacePenjualanApiService();

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _refreshDetail();
  }

  Future<void> _refreshDetail() async {
    if (_item.id.isEmpty) return;
    try {
      final res = await _apiService.getPenjualanDetail(_item.id);
      if (res.success && res.data != null && mounted) {
        setState(() => _item = res.data!);
      }
    } catch (_) {}
  }

  String _formatNum(num number) {
    final s = number.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp $buf';
  }

  String _formatDate(DateTime date) {
    const months = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  Future<void> _showTambahPembayaranDialog() async {
    final nominalController = TextEditingController();
    final keteranganController = TextEditingController(text: 'Pelunasan bertahap');
    final sisa = _item.remainingAmount > 0 ? _item.remainingAmount : (_item.totalValue - _item.totalReceived);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF1D2420) : Colors.white;
    final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark;
    final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.border;
    final inputBg = isDark ? const Color(0xFF141916) : WarnaAplikasi.bgInput;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Tambah Catatan Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: titleColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sisa tagihan transaksi: ${_formatNum(sisa)}',
                style: const TextStyle(fontSize: 12, color: WarnaAplikasi.warningOrange, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              Text('Nominal Pembayaran (Rp) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: titleColor)),
              const SizedBox(height: 6),
              TextField(
                controller: nominalController,
                style: TextStyle(color: titleColor),
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                decoration: InputDecoration(
                  hintText: 'Misal: 500.000',
                  hintStyle: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF6B7F73) : WarnaAplikasi.textGrayLight),
                  prefixText: 'Rp ',
                  prefixStyle: TextStyle(color: titleColor, fontWeight: FontWeight.w600),
                  filled: true,
                  fillColor: inputBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary, width: 1.5)),
                ),
              ),
              const SizedBox(height: 12),
              Text('Keterangan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: titleColor)),
              const SizedBox(height: 6),
              TextField(
                controller: keteranganController,
                style: TextStyle(color: titleColor),
                decoration: InputDecoration(
                  hintText: 'Misal: DP ke-2, transfer BCA',
                  hintStyle: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF6B7F73) : WarnaAplikasi.textGrayLight),
                  filled: true,
                  fillColor: inputBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary, width: 1.5)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final nominal = CurrencyInputFormatter.parse(nominalController.text);
                if (nominal <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nominal harus lebih dari 0!'), backgroundColor: WarnaAplikasi.errorRedDark),
                  );
                  return;
                }
                Navigator.pop(ctx, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: WarnaAplikasi.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Simpan Pembayaran'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final nominal = CurrencyInputFormatter.parse(nominalController.text);
      setState(() => _isLoading = true);
      try {
        final res = await _apiService.tambahPembayaran(
          _item.id,
          nominal: nominal,
          keterangan: keteranganController.text.trim(),
        );
        if (res.success && res.data != null) {
          setState(() => _item = res.data!);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pembayaran berhasil dicatat!'), backgroundColor: WarnaAplikasi.primary),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menambah pembayaran: $e'), backgroundColor: WarnaAplikasi.errorRedDark),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleTandaiLunas() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1D2420) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Konfirmasi Pelunasan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark)),
        content: Text(
          'Pastikan seluruh uang pembayaran telah Anda terima dan diverifikasi secara manual. Setelah dikonfirmasi, transaksi akan berstatus Lunas dan stok fisik akan disesuaikan.',
          style: TextStyle(fontSize: 13, height: 1.4, color: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textMedium),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: WarnaAplikasi.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Ya, Tandai Lunas'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final res = await _apiService.tandaiLunas(_item.id);
        if (res.success && res.data != null) {
          setState(() => _item = res.data!);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaksi berhasil ditandai Lunas!'), backgroundColor: WarnaAplikasi.primary),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengubah status: $e'), backgroundColor: WarnaAplikasi.errorRedDark),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleTandaiDiserahkan() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1D2420) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Konfirmasi Penyerahan Barang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark)),
        content: Text(
          'Setelah barang ditandai "Sudah Diserahkan", transaksi ini tidak dapat dibatalkan lagi melalui sistem. Lanjutkan?',
          style: TextStyle(fontSize: 13, height: 1.4, color: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textMedium),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: WarnaAplikasi.gradientStart,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Ya, Barang Diserahkan'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final res = await _apiService.tandaiDiserahkan(_item.id);
        if (res.success && res.data != null) {
          setState(() => _item = res.data!);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Status barang berhasil diperbarui menjadi Sudah Diserahkan!'), backgroundColor: WarnaAplikasi.primary),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memperbarui status penyerahan: $e'), backgroundColor: WarnaAplikasi.errorRedDark),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleBatalkanTransaksi() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.border;
    final inputBg = isDark ? const Color(0xFF141916) : WarnaAplikasi.bgInput;
    final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark;
    final alasanController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1D2420) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Batalkan Transaksi Penjualan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: WarnaAplikasi.errorRedDark)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pembatalan akan melepaskan/mengembalikan alokasi stok ke katalog. Jika customer sudah membayar sebagian, pengembalian dana dilakukan manual di luar aplikasi.',
              style: TextStyle(fontSize: 12.5, color: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray, height: 1.4),
            ),
            const SizedBox(height: 12),
            Text('Alasan Pembatalan *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: titleColor)),
            const SizedBox(height: 6),
            TextField(
              controller: alasanController,
              style: TextStyle(color: titleColor),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Misal: Pembeli membatalkan pesanan lewat WhatsApp',
                hintStyle: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF6B7F73) : WarnaAplikasi.textGrayLight),
                filled: true,
                fillColor: inputBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary, width: 1.5)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Tutup', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              if (alasanController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alasan pembatalan wajib diisi!'), backgroundColor: WarnaAplikasi.errorRedDark),
                );
                return;
              }
              Navigator.pop(ctx, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WarnaAplikasi.errorRedDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Konfirmasi Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final res = await _apiService.batalkanTransaksi(
          _item.id,
          alasanBatal: alasanController.text.trim(),
        );
        if (res.success && res.data != null) {
          setState(() => _item = res.data!);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaksi telah dibatalkan dan alokasi stok dipulihkan.'), backgroundColor: WarnaAplikasi.primary),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal membatalkan transaksi: $e'), backgroundColor: WarnaAplikasi.errorRedDark),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarnaAplikasi.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            const PawonFormHeader(
              title: 'Detail Transaksi',
              subtitle: 'Rincian penjualan hasil panen & pembayaran',
            ),
            if (_isLoading)
              const LinearProgressIndicator(color: WarnaAplikasi.primary, minHeight: 2),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeroSection(),
                    const SizedBox(height: 12),
                    _buildStatusBanners(),
                    const SizedBox(height: 12),
                    _buildCommoditySection(),
                    const SizedBox(height: 12),
                    _buildBuyerSection(),
                    const SizedBox(height: 12),
                    _buildMultiPaymentSection(),
                    const SizedBox(height: 12),
                    if (_item.notes.isNotEmpty) _buildFieldNotesSection(),
                    const SizedBox(height: 14),
                    _buildActionButtons(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [WarnaAplikasi.gradientStart, WarnaAplikasi.primary, WarnaAplikasi.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: WarnaAplikasi.primary.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 6),
          )
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _item.trxCode,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _item.statusLabel,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text('Total Nilai Penjualan', style: TextStyle(fontSize: 12, color: Colors.white70)),
          const SizedBox(height: 4),
          Text(
            _formatNum(_item.totalValue),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sudah Diterima: ${_formatNum(_item.totalReceived)}',
                style: const TextStyle(fontSize: 11.5, color: WarnaAplikasi.accentGreen, fontWeight: FontWeight.w600),
              ),
              Text(
                'Sisa: ${_formatNum(_item.remainingAmount)}',
                style: TextStyle(
                  fontSize: 11.5,
                  color: _item.remainingAmount > 0 ? Colors.amberAccent : Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanners() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.border;
    final pendingBg = isDark ? const Color(0xFF1D2420) : WarnaAplikasi.bgPaleGreen;
    final lunasBg = isDark ? const Color(0xFF283A2E) : WarnaAplikasi.statusLunasBg;
    final lunasText = isDark ? const Color(0xFF81C784) : WarnaAplikasi.statusLunasText;
    final pendingText = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Handover Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _item.isSudahDiserahkan ? lunasBg : pendingBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _item.isSudahDiserahkan ? lunasText.withValues(alpha: 0.3) : borderColor),
            ),
            child: Row(
              children: [
                Icon(
                  _item.isSudahDiserahkan ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                  size: 18,
                  color: _item.isSudahDiserahkan ? lunasText : (isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _item.isSudahDiserahkan
                        ? 'Status Barang: Sudah Diserahkan kepada Pembeli'
                        : 'Status Barang: Belum Diserahkan',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _item.isSudahDiserahkan ? lunasText : pendingText,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_item.isDibatalkan) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF381E1E) : WarnaAplikasi.errorRedBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? const Color(0xFF5A2A2A) : WarnaAplikasi.errorRedBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cancel_rounded, size: 18, color: WarnaAplikasi.errorRedDark),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Transaksi Dibatalkan: "${_item.alasanBatal ?? 'Dibatalkan oleh petani'}"',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WarnaAplikasi.errorRedDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommoditySection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
    final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.border;
    final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark;
    final subtitleColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_item.commodityName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: titleColor)),
              if (_item.idProduk != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF283A2E) : WarnaAplikasi.greenPill,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('Marketplace', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.greenText)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(_item.commoditySubtitle, style: TextStyle(fontSize: 11.5, color: subtitleColor)),
          Divider(height: 24, color: borderColor),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricColumn('Volume Penjualan', '${_item.volumeKg} ${_item.satuan}'),
              _buildMetricColumn('Harga Aktual', '${_formatNum(_item.pricePerKg)} / ${_item.satuan}'),
              _buildMetricColumn('Tanggal', _formatDate(_item.transactionDate)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark;
    final subtitleColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: subtitleColor)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: titleColor)),
      ],
    );
  }

  Widget _buildBuyerSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
    final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.border;
    final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark;
    final subtitleColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray;
    final badgeBg = isDark ? const Color(0xFF141916) : WarnaAplikasi.bgPage;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF283A2E) : WarnaAplikasi.greenLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.person_rounded, color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_item.buyerName, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: titleColor)),
                const SizedBox(height: 2),
                Text(
                  _item.buyerPhone != null && _item.buyerPhone!.isNotEmpty ? _item.buyerPhone! : 'Kontak via WhatsApp / Langsung',
                  style: TextStyle(fontSize: 11, color: subtitleColor),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(8)),
            child: Text(_item.paymentMethodLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: titleColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiPaymentSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
    final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.border;
    final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark;
    final subtitleColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray;
    final emptyBoxBg = isDark ? const Color(0xFF141916) : WarnaAplikasi.bgPage;
    final itemBg = isDark ? const Color(0xFF141916) : WarnaAplikasi.bgPaleGreen;
    final primaryAccent = isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Riwayat Pembayaran (DP & Pelunasan)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: titleColor)),
              if (!_item.isLunas && !_item.isDibatalkan)
                InkWell(
                  onTap: _showTambahPembayaranDialog,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text('+ Catat Bayar', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: primaryAccent)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (_item.riwayatPembayaran.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: emptyBoxBg, borderRadius: BorderRadius.circular(12)),
              child: Text('Belum ada catatan pembayaran yang diverifikasi.', style: TextStyle(fontSize: 11.5, color: subtitleColor)),
            )
          else
            ...List.generate(_item.riwayatPembayaran.length, (idx) {
              final p = _item.riwayatPembayaran[idx];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: itemBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pembayaran #${idx + 1} &bull; ${p.keterangan.isNotEmpty ? p.keterangan : 'DP / Pelunasan'}',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: titleColor),
                        ),
                        if (p.tanggalPembayaran != null)
                          Text(_formatDate(p.tanggalPembayaran!), style: TextStyle(fontSize: 10, color: subtitleColor)),
                      ],
                    ),
                    Text(_formatNum(p.nominal), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: primaryAccent)),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildFieldNotesSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
    final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.border;
    final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark;
    final subtitleColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Catatan Transaksi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: titleColor)),
          const SizedBox(height: 6),
          Text(
            '"${_item.notes}"',
            style: TextStyle(fontSize: 11.5, color: subtitleColor, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final bool canMarkLunas = !_item.isLunas && !_item.isDibatalkan && (_item.totalReceived >= _item.totalValue);
    final bool canHandover = !_item.isSudahDiserahkan && !_item.isDibatalkan;
    final bool canCancel = !_item.isSudahDiserahkan && !_item.isDibatalkan;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Tandai Lunas Button (Hanya jika belum lunas)
          if (!_item.isLunas && !_item.isDibatalkan) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canMarkLunas ? _handleTandaiLunas : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: WarnaAplikasi.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: WarnaAplikasi.primary.withValues(alpha: 0.3),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: Text(
                  canMarkLunas
                      ? 'Tandai Lunas (Verifikasi Pembayaran Penuh)'
                      : 'Pelunasan (Sisa: ${_formatNum(_item.remainingAmount)})',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Tandai Barang Diserahkan
          if (canHandover) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _handleTandaiDiserahkan,
                style: OutlinedButton.styleFrom(
                  foregroundColor: WarnaAplikasi.primary,
                  side: const BorderSide(color: WarnaAplikasi.primary, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.local_shipping_outlined, size: 18),
                label: const Text('Tandai Barang Sudah Diserahkan', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Batalkan Transaksi Button
          if (canCancel) ...[
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _handleBatalkanTransaksi,
                style: TextButton.styleFrom(
                  foregroundColor: WarnaAplikasi.errorRedDark,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.cancel_outlined, size: 16),
                label: const Text('Batalkan Transaksi Ini', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
