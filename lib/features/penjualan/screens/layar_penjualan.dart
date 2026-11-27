import 'package:flutter/material.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/core/widgets/ikon_tanaman_kustom.dart';
import 'package:pawon_mobile/features/penjualan/models/item_penjualan.dart';
import 'package:pawon_mobile/features/penjualan/models/item_produk_saya.dart';
import 'package:pawon_mobile/features/penjualan/screens/layar_catat_penjualan.dart';
import 'package:pawon_mobile/features/penjualan/screens/layar_detail_penjualan.dart';
import 'package:pawon_mobile/features/penjualan/screens/layar_form_produk.dart';
import 'package:pawon_mobile/features/penjualan/services/marketplace_penjualan_api_service.dart';
import 'package:pawon_mobile/features/profil/screens/layar_profil.dart';
import 'package:pawon_mobile/features/notifikasi/screens/layar_notifikasi.dart';

class PenjualanScreen extends StatefulWidget {
  const PenjualanScreen({super.key});

  @override
  State<PenjualanScreen> createState() => _PenjualanScreenState();
}

class _PenjualanScreenState extends State<PenjualanScreen>
    with SingleTickerProviderStateMixin {
  // 0: Riwayat Penjualan, 1: Produk Saya
  int _mainSectionIndex = 0;

  // Filter sub-tab untuk Riwayat Penjualan (0: Semua, 1: Lunas, 2: Uang Muka/Tempo, 3: Verifikasi)
  int _selectedTabIndex = 0;

  static const Color _primaryGreen = WarnaAplikasi.primary;
  static const Color _textDark = WarnaAplikasi.textDark;
  static const Color _textLight = WarnaAplikasi.textLight;
  static const Color _bgPage = WarnaAplikasi.primaryBackground;
  static const Color _cardBg = Colors.white;
  static const Color _borderColor = WarnaAplikasi.border;
  static const Color _lightGreenBg = WarnaAplikasi.bgLightGreen;

  final _apiService = MarketplacePenjualanApiService();

  List<SaleItem> _allItems = [];
  List<ItemProdukSaya> _myProducts = [];
  List<Map<String, dynamic>> _marketPrices = [];
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    _fetchApiData();
  }

  Future<void> _fetchApiData() async {
    _fetchProducts();
    _fetchSales();
    _fetchMarketPrices();
  }

  Future<void> _fetchMarketPrices() async {
    try {
      final res = await _apiService.getHargaPasarList();
      if (res.success && res.data != null && mounted) {
        setState(() => _marketPrices = res.data!);
      }
    } catch (_) {}
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoadingProducts = true);
    try {
      final res = await _apiService.getProdukSayaList();
      if (res.success && res.data != null && mounted) {
        setState(() => _myProducts = res.data!);
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoadingProducts = false);
  }

  Future<void> _fetchSales() async {
    try {
      final res = await _apiService.getPenjualanList();
      if (res.success && res.data != null && mounted) {
        setState(() => _allItems = res.data!);
      }
    } catch (_) {}
  }

  List<SaleItem> get _filteredItems {
    switch (_selectedTabIndex) {
      case 1:
        return _allItems.where((e) => e.status == SaleStatus.lunas).toList();
      case 2:
        return _allItems
            .where((e) =>
                e.status == SaleStatus.tempoAktif ||
                e.status == SaleStatus.uangMuka)
            .toList();
      case 3:
        return _allItems
            .where((e) => e.status == SaleStatus.prosesVerifikasi)
            .toList();
      default:
        return _allItems;
    }
  }

  double get _totalPenjualanValue {
    return _allItems
        .where((e) => e.status != SaleStatus.dibatalkan)
        .fold(0.0, (prev, elem) => prev + elem.totalValue);
  }

  int get _lunasCount => _allItems.where((e) => e.status == SaleStatus.lunas).length;
  int get _tempoCount => _allItems
      .where((e) => e.status == SaleStatus.tempoAktif || e.status == SaleStatus.uangMuka)
      .length;

  Future<void> _confirmDeleteProduct(ItemProdukSaya product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Arsipkan Produk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(
          'Produk "${product.namaProduk}" akan diarsipkan dan disembunyikan dari katalog publik. Riwayat penjualan produk tetap tersimpan aman.',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: WarnaAplikasi.errorRedDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Ya, Arsipkan'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final res = await _apiService.deleteProduk(product.idProduk);
        if (res.success) {
          _fetchProducts();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Produk berhasil diarsipkan.'), backgroundColor: WarnaAplikasi.primary),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengarsipkan: $e'), backgroundColor: WarnaAplikasi.errorRedDark),
          );
        }
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
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                color: _primaryGreen,
                onRefresh: _fetchApiData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Page Title & Subtitle
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Penjualan & Marketplace',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : WarnaAplikasi.primaryDark,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _mainSectionIndex == 0
                                  ? 'Kelola transaksi dan pembukuan hasil panen Anda'
                                  : 'Kelola etalase produk Anda di Website Customer PawonTani',
                              style: const TextStyle(
                                fontSize: 13,
                                color: WarnaAplikasi.textGray,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Segmented Section Selector (Riwayat Penjualan vs Produk Saya)
                      _buildMainSegmentedControl(),
                      const SizedBox(height: 14),

                      // Switch Section Content
                      if (_mainSectionIndex == 0) ...[
                        _buildRiwayatPenjualanSection(context),
                      ] else ...[
                        _buildProdukSayaSection(context),
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return PawonFixedHeader(
      title: 'Penjualan',
      onProfileTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      ),
      onNotificationTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LayarNotifikasi()),
      ),
    );
  }

  /// Segmented control navigasi utama menu Penjualan (Sesuai Bagian 8)
  Widget _buildMainSegmentedControl() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerBg = isDark ? const Color(0xFF1D2420) : WarnaAplikasi.bgPaleGreen;
    final borderColor = isDark ? const Color(0xFF28332C) : _borderColor;
    final activeTabBg = isDark ? const Color(0xFF283A2E) : Colors.white;
    final activeTextColor = isDark ? const Color(0xFF81C784) : _primaryGreen;
    final inactiveTextColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: containerBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _mainSectionIndex = 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _mainSectionIndex == 0 ? activeTabBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _mainSectionIndex == 0
                        ? [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05), blurRadius: 4, offset: const Offset(0, 2))]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        size: 16,
                        color: _mainSectionIndex == 0 ? activeTextColor : inactiveTextColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Riwayat Penjualan',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: _mainSectionIndex == 0 ? FontWeight.w800 : FontWeight.w600,
                          color: _mainSectionIndex == 0 ? activeTextColor : inactiveTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _mainSectionIndex = 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _mainSectionIndex == 1 ? activeTabBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _mainSectionIndex == 1
                        ? [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05), blurRadius: 4, offset: const Offset(0, 2))]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.storefront_rounded,
                        size: 16,
                        color: _mainSectionIndex == 1 ? activeTextColor : inactiveTextColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Produk Saya',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: _mainSectionIndex == 1 ? FontWeight.w800 : FontWeight.w600,
                          color: _mainSectionIndex == 1 ? activeTextColor : inactiveTextColor,
                        ),
                      ),
                      if (_myProducts.isNotEmpty) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: _mainSectionIndex == 1
                                ? (isDark ? const Color(0xFF3B6B4F) : _primaryGreen)
                                : (isDark ? const Color(0xFF28332C) : WarnaAplikasi.textGray),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_myProducts.length}',
                            style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= TAB 1: RIWAYAT PENJUALAN =================

  Widget _buildRiwayatPenjualanSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryBanner(),
        const SizedBox(height: 14),
        _buildAddButton(context),
        const SizedBox(height: 16),
        _buildTabFilter(),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Transaksi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : WarnaAplikasi.primaryDark,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Terbaru',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : WarnaAplikasi.textGray,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, size: 16, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : WarnaAplikasi.textGray),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_filteredItems.isEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1D2420) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF28332C) : _borderColor),
            ),
            child: Center(
              child: Text(
                'Tidak ada transaksi penjualan pada kategori ini.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray,
                ),
              ),
            ),
          )
        else
          ..._filteredItems.map((item) => _buildTransactionCard(context, item)),
        const SizedBox(height: 12),
        _buildMarketPriceSection(),
      ],
    );
  }

  // ================= TAB 2: PRODUK SAYA (MARKETPLACE) =================

  Widget _buildProdukSayaSection(BuildContext context) {
    final int aktifCount = _myProducts.where((p) => p.isAktif).length;
    final double totalTerjualCount = _myProducts.fold(0.0, (acc, p) => acc + p.totalTerjual);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Metric Banner Produk Saya
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1D2420) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF28332C) : _borderColor),
            boxShadow: [
              BoxShadow(color: _primaryGreen.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMarketMetric('Produk Aktif', '$aktifCount Listing', Icons.check_circle_outline, WarnaAplikasi.primary),
                  Container(width: 1, height: 36, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF28332C) : _borderColor),
                  _buildMarketMetric('Total Terjual', '${totalTerjualCount.toInt()} Item', Icons.shopping_bag_outlined, Colors.amber.shade800),
                  Container(width: 1, height: 36, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF28332C) : _borderColor),
                  _buildMarketMetric('Website Sync', 'Terhubung', Icons.cloud_done_outlined, Colors.blue.shade700),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // + Tambah Produk Baru Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () async {
                final created = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const LayarFormProduk()),
                );
                if (created == true) _fetchProducts();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
              label: const Text('+ Tambah Produk Marketplace', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Section Title: Etalase Produk Saya
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Etalase Produk Saya',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark),
              ),
              Text(
                '${_myProducts.length} Produk',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WarnaAplikasi.textGray),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Product List
        if (_isLoadingProducts)
          const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
        else if (_myProducts.isEmpty)
          _buildEmptyProdukState(context)
        else
          ..._myProducts.map((p) => _buildProdukCard(context, p)),
      ],
    );
  }

  Widget _buildMarketMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 1),
        Text(label, style: const TextStyle(fontSize: 10.5, color: WarnaAplikasi.textGray, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildEmptyProdukState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
    final borderColor = isDark ? const Color(0xFF28332C) : _borderColor;
    final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark;
    final subtitleColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray;
    final iconBoxBg = isDark ? const Color(0xFF283A2E) : WarnaAplikasi.greenLight;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconBoxBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.storefront_rounded, size: 28, color: _primaryGreen),
          ),
          const SizedBox(height: 14),
          Text(
            'Belum Ada Produk di Marketplace',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: titleColor),
          ),
          const SizedBox(height: 6),
          Text(
            'Tambahkan hasil panen Anda ke Marketplace agar pembeli dan konsumen dapat memesan langsung via WhatsApp.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: subtitleColor, height: 1.4),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final created = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const LayarFormProduk()),
              );
              if (created == true) _fetchProducts();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('+ Tambah Produk Pertama', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  /// Kartu Produk Saya di Menu Penjualan (Sesuai Bagian 8 & 9)
  Widget _buildProdukCard(BuildContext context, ItemProdukSaya product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1D2420) : _cardBg;
    final borderColor = isDark ? const Color(0xFF28332C) : _borderColor;
    final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark;
    final subtitleColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray;
    final innerBoxBg = isDark ? const Color(0xFF141916) : WarnaAplikasi.bgPaleGreen;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: _primaryGreen.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Foto, Nama, Status Badge, Menu Titik Tiga
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto Produk
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF283A2E) : WarnaAplikasi.bgLightGreen,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: product.fotoResolvedUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            product.fotoResolvedUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(child: Text('🌾', style: TextStyle(fontSize: 26))),
                          ),
                        )
                      : const Center(child: Text('🌾', style: TextStyle(fontSize: 26))),
                ),
                const SizedBox(width: 12),

                // Info Utama
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product.namaProduk,
                              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: titleColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildProdukStatusBadge(product),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        product.namaKomoditas ?? 'Komoditas Hasil Panen',
                        style: TextStyle(fontSize: 11.5, color: subtitleColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${product.hargaFormatted} / ${product.satuan}',
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: _primaryGreen),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 20, color: borderColor),

            // Stock Details Grid: Stok Fisik, Stok Ditahan, Stok Tersedia, Terjual
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: innerBoxBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStockCol('Fisik', '${product.stokFisik.toInt()}'),
                  Container(width: 1, height: 24, color: borderColor),
                  _buildStockCol('Ditahan (DP)', '${product.stokDitahan.toInt()}', isWarning: product.stokDitahan > 0),
                  Container(width: 1, height: 24, color: borderColor),
                  _buildStockCol('Tersedia', '${product.stokTersedia.toInt()}', isHighlight: true),
                  Container(width: 1, height: 24, color: borderColor),
                  _buildStockCol('Terjual', '${product.totalTerjual.toInt()}'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Actions Row: Catat Penjualan (Primary CTA) & Edit & Arsip
            Row(
              children: [
                // Tombol Catat Penjualan
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final recorded = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecordSaleScreen(sourceProduct: product),
                        ),
                      );
                      if (recorded == true) {
                        _fetchProducts();
                        _fetchSales();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WarnaAplikasi.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 15),
                    label: const Text('Catat Penjualan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 8),

                // Tombol Edit
                OutlinedButton(
                  onPressed: () async {
                    final updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LayarFormProduk(produkToEdit: product),
                      ),
                    );
                    if (updated == true) _fetchProducts();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primaryGreen,
                    side: const BorderSide(color: _borderColor),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Icon(Icons.edit_outlined, size: 16),
                ),
                const SizedBox(width: 6),

                // Tombol Hapus/Arsip
                OutlinedButton(
                  onPressed: () => _confirmDeleteProduct(product),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: WarnaAplikasi.errorRedDark,
                    side: const BorderSide(color: _borderColor),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Icon(Icons.archive_outlined, size: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockCol(String label, String value, {bool isHighlight = false, bool isWarning = false}) {
    Color col = WarnaAplikasi.textDark;
    if (isHighlight) col = _primaryGreen;
    if (isWarning) col = WarnaAplikasi.warningOrange;

    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: col)),
        const SizedBox(height: 1),
        Text(label, style: const TextStyle(fontSize: 10, color: WarnaAplikasi.textGray)),
      ],
    );
  }

  Widget _buildProdukStatusBadge(ItemProdukSaya p) {
    Color bg = WarnaAplikasi.statusLunasBg;
    Color fg = WarnaAplikasi.statusLunasText;
    String label = 'Aktif';

    if (p.isStokHabis) {
      bg = WarnaAplikasi.errorRedBg;
      fg = WarnaAplikasi.errorRedDark;
      label = 'Stok Habis';
    } else if (p.status == 'tidak_aktif') {
      bg = Colors.grey.shade100;
      fg = Colors.grey.shade700;
      label = 'Nonaktif';
    } else if (p.status == 'diarsipkan') {
      bg = Colors.amber.shade50;
      fg = Colors.amber.shade800;
      label = 'Arsip';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: fg)),
    );
  }

  // ================= HELPER WIDGETS LAMA (DIPERTAHANKAN) =================

  Widget _buildSummaryBanner() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D2420) : WarnaAplikasi.bgSuccessPale,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF28332C) : WarnaAplikasi.greenPill,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 12,
            top: 20,
            bottom: 20,
            width: 90,
            child: Opacity(
              opacity: isDark ? 0.2 : 0.6,
              child: CustomPaint(
                painter: DecorativeLeavesPainter(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL PENJUALAN TERCATAT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGrayGreenMedium,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF283A2E) : WarnaAplikasi.seasonBadgeBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? const Color(0xFF3B6B4F) : WarnaAplikasi.seasonBadgeBorder,
                          width: 0.8,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            size: 13,
                            color: WarnaAplikasi.primary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Musim Ini',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: WarnaAplikasi.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _formatNum(_totalPenjualanValue.toInt()),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.primaryDark,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tercatat dari ${_allItems.length} transaksi ($_lunasCount lunas, $_tempoCount bertahap/DP)',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: () async {
            final res = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (_) => const RecordSaleScreen()),
            );
            if (res == true) _fetchSales();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: WarnaAplikasi.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 16, color: Colors.white70),
              SizedBox(width: 8),
              Text(
                '+ Catat Penjualan Hasil Panen',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabFilter() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tabs = [
      'Semua (${_allItems.length})',
      'Lunas ($_lunasCount)',
      'Uang Muka / Tempo ($_tempoCount)',
      'Verifikasi'
    ];
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        itemBuilder: (ctx, i) {
          final selected = i == _selectedTabIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? _primaryGreen
                    : (isDark ? const Color(0xFF1D2420) : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? _primaryGreen
                      : (isDark ? const Color(0xFF28332C) : _borderColor),
                  width: 1.2,
                ),
              ),
              child: Text(
                tabs[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? Colors.white
                      : (isDark ? const Color(0xFFA0B3A6) : _textLight),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, SaleItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1D2420) : _cardBg;
    final borderColor = isDark ? const Color(0xFF28332C) : _borderColor;
    final titleColor = isDark ? const Color(0xFFF1F5F2) : _textDark;
    final subtitleColor = isDark ? const Color(0xFFA0B3A6) : _textLight;
    final innerBoxBg = isDark ? const Color(0xFF141916) : _bgPage;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SaleDetailScreen(item: item)),
        );
        _fetchSales();
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 12, color: subtitleColor.withValues(alpha: 0.7)),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatDate(item.transactionDate)} \u2022 ${item.timeStr}',
                    style: TextStyle(fontSize: 11, color: subtitleColor, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  _buildStatusBadge(item.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildCommodityIcon(item.commodityType),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.commodityName,
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: titleColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 46),
                child: Text(
                  item.commoditySubtitle,
                  style: TextStyle(fontSize: 11.5, color: subtitleColor),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: innerBoxBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Volume Penjualan', style: TextStyle(fontSize: 10.5, color: subtitleColor)),
                        const SizedBox(height: 2),
                        Text(
                          '${_formatVol(item.volumeKg)} ${item.satuan}',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: titleColor),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Total Penerimaan', style: TextStyle(fontSize: 10.5, color: subtitleColor)),
                        const SizedBox(height: 2),
                        Text(
                          _formatNum(item.totalValue.toInt()),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _primaryGreen),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(SaleStatus status) {
    Color bg, textColor;
    IconData icon;
    String label;
    switch (status) {
      case SaleStatus.lunas:
        bg = WarnaAplikasi.statusLunasBg;
        textColor = WarnaAplikasi.statusLunasText;
        icon = Icons.check_circle_outline_rounded;
        label = 'Lunas';
        break;
      case SaleStatus.tempoAktif:
        bg = WarnaAplikasi.statusTempoBg;
        textColor = WarnaAplikasi.statusTempoText;
        icon = Icons.access_time_rounded;
        label = 'Tempo Aktif';
        break;
      case SaleStatus.uangMuka:
        bg = WarnaAplikasi.statusUangMukaBg;
        textColor = WarnaAplikasi.statusUangMukaText;
        icon = Icons.payment_rounded;
        label = 'Uang Muka';
        break;
      case SaleStatus.prosesVerifikasi:
        bg = WarnaAplikasi.statusVerifikasiBg;
        textColor = WarnaAplikasi.statusVerifikasiText;
        icon = Icons.pending_rounded;
        label = 'Proses Verifikasi';
        break;
      case SaleStatus.dibatalkan:
        bg = WarnaAplikasi.errorRedBg;
        textColor = WarnaAplikasi.errorRedDark;
        icon = Icons.cancel_outlined;
        label = 'Dibatalkan';
        break;
      case SaleStatus.belumDibayar:
        bg = Colors.amber.shade50;
        textColor = Colors.amber.shade900;
        icon = Icons.hourglass_empty_rounded;
        label = 'Belum Dibayar';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildCommodityIcon(CommodityType type) {
    IconData icon;
    Color color, bgColor;
    switch (type) {
      case CommodityType.gabahKeringPanen:
      case CommodityType.gabahKeringGiling:
        icon = Icons.grain_rounded;
        color = WarnaAplikasi.commodityGabah;
        bgColor = WarnaAplikasi.commodityGabahBg;
        break;
      case CommodityType.jagungManisPipil:
      case CommodityType.jagungManisTongkol:
        icon = Icons.spa_rounded;
        color = WarnaAplikasi.commodityJagung;
        bgColor = WarnaAplikasi.hppAmberBg;
        break;
      case CommodityType.padiIr64:
      case CommodityType.lainnya:
        icon = Icons.grain_rounded;
        color = _primaryGreen;
        bgColor = _lightGreenBg;
        break;
    }
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Widget _buildMarketPriceSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
    final borderColor = isDark ? const Color(0xFF28332C) : _borderColor;
    final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.primaryDark;

    // Ambil maksimal 3 item teratas dari data pasar dinamis backend (atau fallback terstruktur)
    final items = _marketPrices.isNotEmpty
        ? _marketPrices.take(3).toList()
        : [
            {'nama': 'Padi GKG', 'harga': 'Rp 6.800', 'change': '+3.8%'},
            {'nama': 'Jagung Pipil', 'harga': 'Rp 5.200', 'change': '+2.9%'},
            {'nama': 'Cabai Rawit', 'harga': 'Rp 38.000', 'change': '-8.4%'},
          ];

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
              Text(
                'Referensi Harga Pasar Banyumas',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: titleColor),
              ),
              const Icon(Icons.trending_up, size: 16, color: _primaryGreen),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: items.map((item) {
              final nama = (item['nama'] ?? item['nama_komoditas'] ?? '-').toString();
              final harga = (item['harga'] ?? '-').toString();
              final change = (item['change'] ?? 'Stabil').toString();
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _buildPriceItem(nama, harga, change),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceItem(String name, String price, String change) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameColor = isDark ? const Color(0xFFA0B3A6) : _textLight;
    final priceColor = isDark ? const Color(0xFFF1F5F2) : _textDark;
    final isUp = change.startsWith('+');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: TextStyle(fontSize: 11, color: nameColor)),
        const SizedBox(height: 2),
        Text(price, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: priceColor)),
        const SizedBox(height: 2),
        Text(
          change,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isUp ? (isDark ? const Color(0xFF81C784) : WarnaAplikasi.statusLunasText) : nameColor,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  String _formatNum(int num) {
    final s = num.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp $buf';
  }

  String _formatVol(double vol) => vol.toInt().toString();
}
