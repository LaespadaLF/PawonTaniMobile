import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:flutter/material.dart';
import 'package:pawon_mobile/features/penjualan/models/item_penjualan.dart';
import 'package:pawon_mobile/core/widgets/ikon_tanaman_kustom.dart';
import 'package:pawon_mobile/features/penjualan/screens/layar_detail_penjualan.dart';
import 'package:pawon_mobile/features/penjualan/screens/layar_tambah_penjualan.dart';

class PenjualanScreen extends StatefulWidget {
  const PenjualanScreen({super.key});

  @override
  State<PenjualanScreen> createState() => _PenjualanScreenState();
}

class _PenjualanScreenState extends State<PenjualanScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 0;

  static const Color _primaryGreen = WarnaAplikasi.primary;
  static const Color _textDark = WarnaAplikasi.textDark;
  static const Color _textMedium = WarnaAplikasi.textMedium;
  static const Color _textLight = WarnaAplikasi.textLight;
  static const Color _bgPage = WarnaAplikasi.primaryBackground;
  static const Color _cardBg = Colors.white;
  static const Color _borderColor = WarnaAplikasi.border;
  static const Color _lightGreenBg = WarnaAplikasi.bgLightGreen;

  late List<SaleItem> _allItems;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    _allItems = [
      SaleItem(
        id: '1',
        trxCode: 'TRX-PN-20241115-889',
        commodityType: CommodityType.gabahKeringPanen,
        commodityName: 'Gabah Kering Panen (GKP Ciherang)',
        commoditySubtitle: 'Varietas: Ciherang Super',
        status: SaleStatus.lunas,
        transactionDate: DateTime(2024, 11, 12),
        timeStr: '09.30 WIB',
        volumeKg: 3500,
        pricePerKg: 6900,
        totalValue: 24150000,
        totalReceived: 24150000,
        buyerName: 'Koperasi Tani Sumber Makmur',
        paymentMethod: PaymentMethod.transferBRI,
        paymentMethodLabel: 'Transfer BRI',
        bankAccountName: 'Kas Poktan / H. Sukirman',
        bankAccountNumber: '0129-01-098234-56-1',
        isVerified: true,
        notes: 'Berasal dari petak A, kadar air aman (~14%).',
      ),
      SaleItem(
        id: '2',
        trxCode: 'TRX-JG-20241102-441',
        commodityType: CommodityType.jagungManisPipil,
        commodityName: 'Jagung Manis Hibrida Super',
        commoditySubtitle: 'Kondisi: Pipil Kering Tongkol',
        status: SaleStatus.lunas,
        transactionDate: DateTime(2024, 11, 2),
        timeStr: '14.15 WIB',
        volumeKg: 1500,
        pricePerKg: 5400,
        totalValue: 8100000,
        totalReceived: 8100000,
        buyerName: 'Juragan Sayur Pasar Wage',
        paymentMethod: PaymentMethod.tunaiKasPoktan,
        paymentMethodLabel: 'Tunai / Kas Poktan',
        isVerified: true,
      ),
      SaleItem(
        id: '3',
        trxCode: 'TRX-GG-20241025-221',
        commodityType: CommodityType.gabahKeringGiling,
        commodityName: 'Gabah Kering Giling',
        commoditySubtitle: 'Volume: 2.000 Kg @ Rp 7.200',
        status: SaleStatus.tempoAktif,
        transactionDate: DateTime(2024, 10, 25),
        timeStr: '10.00 WIB',
        volumeKg: 2000,
        pricePerKg: 7200,
        totalValue: 14400000,
        totalReceived: 10000000,
        buyerName: 'UD Beras Berkah Tani (Gudang Sidabowa)',
        paymentMethod: PaymentMethod.tempoMingguan,
        paymentMethodLabel: 'Tempo 14 Hari',
        isTempo: true,
        tempoDays: 14,
        dpAmount: 10000000,
        remainingAmount: 4400000,
        dueDateTempo: DateTime(2024, 12, 8),
      ),
    ];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Page Title & Subtitle (Harmonized with Panen & Lahan)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(18, 12, 18, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Data Penjualan',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: WarnaAplikasi.primaryDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Kelola dan pantau hasil penjualan komoditas Anda',
                            style: TextStyle(
                              fontSize: 13,
                              color: WarnaAplikasi.textGray,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildSummaryBanner(),
                    const SizedBox(height: 14),
                    _buildAddButton(context),
                    const SizedBox(height: 16),
                    _buildTabFilter(),
                    const SizedBox(height: 16),
                    // Section Header: "Daftar Transaksi" & Sort (Harmonized with Panen & Lahan)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Daftar Transaksi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: WarnaAplikasi.primaryDark,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Terbaru',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: WarnaAplikasi.textGray,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 16,
                                color: WarnaAplikasi.textGray,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._filteredItems
                        .map((item) => _buildTransactionCard(context, item)),
                    const SizedBox(height: 12),
                    _buildMarketPriceSection(),
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

  Widget _buildHeader() {
    return const PawonFixedHeader(title: 'Penjualan');
  }

  Widget _buildSummaryBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: WarnaAplikasi.bgSuccessPale,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: WarnaAplikasi.greenPill,
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
              opacity: 0.6,
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
                    const Text(
                      'TOTAL PENJUALAN MUSIM INI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: WarnaAplikasi.textGrayGreenMedium,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: WarnaAplikasi.seasonBadgeBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: WarnaAplikasi.seasonBadgeBorder,
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
                            '+18% Musim Lalu',
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
                const Text(
                  'Rp 34.250.000',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: WarnaAplikasi.primaryDark,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tercatat dari 3 transaksi tuntas & 1 tempo aktif',
                  style: TextStyle(
                    fontSize: 11,
                    color: WarnaAplikasi.textGray,
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
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddSaleScreen()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: WarnaAplikasi.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined,
                  size: 16, color: Colors.white70),
              SizedBox(width: 8),
              Text('+ Catat Penjualan Hasil Panen',
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabFilter() {
    const tabs = [
      'Semua Transaksi (4)',
      'Lunas (3)',
      'Uang Muka / Te...',
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? _primaryGreen : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: selected ? _primaryGreen : _borderColor,
                    width: 1.2),
              ),
              child: Text(tabs[i],
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? Colors.white : _textLight)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, SaleItem item) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => SaleDetailScreen(item: item))),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _borderColor, width: 1),
          boxShadow: [
            BoxShadow(
                color: WarnaAplikasi.primary.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 12,
                      color: _textLight.withValues(alpha: 0.7)),
                  const SizedBox(width: 4),
                  Text('${_formatDate(item.transactionDate)} \u2022 ${item.timeStr}',
                      style: const TextStyle(
                          fontSize: 11,
                          color: _textLight,
                          fontWeight: FontWeight.w500)),
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
                    child: Text(item.commodityName,
                        style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                            letterSpacing: -0.2)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(color: WarnaAplikasi.divider, height: 1, thickness: 1),
              const SizedBox(height: 10),
              if (item.status == SaleStatus.tempoAktif)
                _buildTempoContent(item)
              else
                _buildLunasContent(item),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLunasContent(SaleItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(item.commoditySubtitle,
                style: const TextStyle(
                    fontSize: 11.5,
                    color: _textLight,
                    fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(
                '${_formatVol(item.volumeKg)} Kg @ Rp ${_formatNum(item.pricePerKg.toInt())}',
                style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: _textMedium)),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            const Text('Total Diterima',
                style: TextStyle(fontSize: 12, color: _textLight)),
            const Spacer(),
            Text('Rp ${_formatNum(item.totalReceived.toInt())}',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _primaryGreen,
                    letterSpacing: -0.3)),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(color: WarnaAplikasi.divider, height: 1),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.groups_2_outlined, size: 13, color: _textLight),
            const SizedBox(width: 6),
            Expanded(
                child: Text(item.buyerName,
                    style: const TextStyle(
                        fontSize: 11,
                        color: _textMedium,
                        fontWeight: FontWeight.w500))),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                  color: _lightGreenBg,
                  borderRadius: BorderRadius.circular(8)),
              child: Text(item.paymentMethodLabel,
                  style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: _primaryGreen)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryGreen,
                  side: const BorderSide(color: _borderColor, width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.receipt_long_outlined, size: 14),
                label: const Text('Lihat Nota',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryGreen,
                  side: const BorderSide(color: _borderColor, width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.print_outlined, size: 14),
                label: const Text('Cetak Kuitansi',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTempoContent(SaleItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.commoditySubtitle,
            style:
                const TextStyle(fontSize: 11.5, color: _textLight)),
        const SizedBox(height: 4),
        Row(
          children: [
            const Text('Nilai Transaksi',
                style: TextStyle(fontSize: 11.5, color: _textLight)),
            const Spacer(),
            RichText(
              text: TextSpan(children: [
                const TextSpan(
                    text: 'Sisa: ',
                    style: TextStyle(fontSize: 11.5, color: _textLight)),
                TextSpan(
                    text: 'Rp ${_formatNum(item.remainingAmount.toInt())}',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: WarnaAplikasi.statusSisaTempoText)),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Rp ${_formatNum(item.totalValue.toInt())}',
                style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                    letterSpacing: -0.5)),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('DP Masuk: Rp ${_formatNum(item.dpAmount.toInt())}',
                    style:
                        const TextStyle(fontSize: 10, color: _textLight)),
                Text('Jatuh Tempo: ${_formatDate(item.dueDateTempo!)}',
                    style: const TextStyle(
                        fontSize: 10,
                        color: WarnaAplikasi.statusSisaTempoText,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(color: WarnaAplikasi.divider, height: 1),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.store_outlined, size: 13, color: _textLight),
            const SizedBox(width: 6),
            Expanded(
                child: Text(item.buyerName,
                    style: const TextStyle(
                        fontSize: 11,
                        color: _textMedium,
                        fontWeight: FontWeight.w500))),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: WarnaAplikasi.hppAmberBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: WarnaAplikasi.hppAmberBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 14, color: WarnaAplikasi.hppAmberText),
              const SizedBox(width: 6),
              const Text('Kelola Sisa Tagihan',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: WarnaAplikasi.hppAmberText)),
              const SizedBox(width: 6),
              Text(
                  '\u25cf Rp ${_formatNum(item.remainingAmount.toInt())}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: WarnaAplikasi.statusSisaTempoText)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMarketPriceSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                      color: _lightGreenBg,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.bar_chart_rounded,
                      color: _primaryGreen, size: 16),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('Pantauan Harga Pasar Hari Ini',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _textDark)),
                ),
                const Text('Banyumas &\nSekitar',
                    style: TextStyle(fontSize: 9.5, color: _textLight),
                    textAlign: TextAlign.right),
              ],
            ),
          ),
          const Divider(color: WarnaAplikasi.divider, height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _buildPriceItem('GKP Basah', 'Rp 6.850', '+Rp 150', true),
                Container(
                    width: 1,
                    height: 48,
                    color: _borderColor,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8)),
                _buildPriceItem(
                    'Jagung Pipil', 'Rp 5.200', 'Stabil', false),
                Container(
                    width: 1,
                    height: 48,
                    color: _borderColor,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8)),
                _buildPriceItem(
                    'Beras Medium', 'Rp 12.500', '+Rp 200', true),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
                color: _bgPage,
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded,
                    size: 13, color: _primaryGreen),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                      'Sumber: Sistem Informasi Pasar Poktan Guyub Santoso',
                      style: TextStyle(
                          fontSize: 10,
                          color: _textLight,
                          fontWeight: FontWeight.w500)),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: WarnaAplikasi.statusLunasBg,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Text('Perbarui',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _primaryGreen)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceItem(
      String name, String price, String change, bool isUp) {
    final isStable = change == 'Stabil';
    return Expanded(
      child: Column(
        children: [
          Text(name,
              style: const TextStyle(
                  fontSize: 10.5,
                  color: _textLight,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(price,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _textDark)),
          const SizedBox(height: 3),
          Text(change,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isStable
                      ? _textLight
                      : isUp
                          ? WarnaAplikasi.statusLunasText
                          : WarnaAplikasi.statusSisaTempoText)),
        ],
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
    }
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: textColor)),
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
        icon = Icons.grain_rounded;
        color = _primaryGreen;
        bgColor = _lightGreenBg;
        break;
    }
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: color, size: 18),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
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
    return buf.toString();
  }

  String _formatVol(double vol) => _formatNum(vol.toInt());
}

