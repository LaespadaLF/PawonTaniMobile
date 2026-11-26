import 'package:flutter/material.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/core/widgets/ikon_tanaman_kustom.dart';
import 'package:pawon_mobile/features/panen/models/item_panen.dart';
import 'package:pawon_mobile/features/panen/screens/layar_catat_panen.dart';
import 'package:pawon_mobile/features/panen/screens/layar_detail_panen.dart';
import 'package:pawon_mobile/features/panen/services/panen_api_service.dart';
import 'package:pawon_mobile/features/panen/widgets/kartu_panen.dart';
import 'package:pawon_mobile/features/panen/widgets/kartu_ringkasan_panen.dart';

class HarvestScreen extends StatefulWidget {
  const HarvestScreen({super.key});

  @override
  State<HarvestScreen> createState() => _HarvestScreenState();
}

class _HarvestScreenState extends State<HarvestScreen> {
  final PanenApiService _apiService = PanenApiService();

  int _selectedFilterIndex = 0; // 0: Semua, 1: Menunggu, 2: Disetujui, 3: Ditolak
  String _selectedSort = 'Terbaru';

  List<HarvestItem> _harvestItems = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchHarvestData();
  }

  Future<void> _fetchHarvestData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await _apiService.getPanenList();
    if (!mounted) return;

    if (res.success && res.data != null) {
      setState(() {
        _harvestItems = res.data!;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = res.message.isNotEmpty
            ? res.message
            : 'Gagal memuat data panen. Silakan periksa koneksi.';
      });
    }
  }

  double get _totalTon {
    return _harvestItems.fold(0.0, (prev, elem) => prev + elem.weightTon);
  }

  Map<String, double> get _commodityBreakdownTon {
    final Map<String, double> breakdown = {};
    for (final item in _harvestItems) {
      final name = item.title.trim().isNotEmpty
          ? item.title.trim()
          : (item.cropType == CropType.jagung ? 'Jagung' : 'Padi');
      breakdown[name] = (breakdown[name] ?? 0.0) + item.weightTon;
    }
    return breakdown;
  }

  /// Nama musim tanam aktif: mengikuti musim pada catatan panen terbaru.
  /// Jika belum ada data, dihitung dari kalender tanam berjalan.
  String get _seasonName {
    for (final item in _harvestItems) {
      final musim = item.season.trim();
      if (musim.isNotEmpty && musim != '-') return musim;
    }
    return _musimBerjalan();
  }

  String get _selectedFilterLabel {
    switch (_selectedFilterIndex) {
      case 1:
        return 'Menunggu';
      case 2:
        return 'Disetujui';
      case 3:
        return 'Ditolak';
      default:
        return 'Semua';
    }
  }

  String _musimBerjalan() {
    final now = DateTime.now();
    final isRendeng = now.month >= 10 || now.month <= 3;
    return 'Musim ${isRendeng ? 'Rendeng' : 'Gadu'} ${now.year}';
  }

  int get _countMenunggu =>
      _harvestItems.where((i) => i.status == HarvestStatus.menunggu).length;
  int get _countDisetujui =>
      _harvestItems.where((i) => i.status == HarvestStatus.disetujui).length;
  int get _countDitolak =>
      _harvestItems.where((i) => i.status == HarvestStatus.ditolak).length;

  List<HarvestItem> get _filteredItems {
    List<HarvestItem> list = List.from(_harvestItems);
    if (_selectedFilterIndex == 1) {
      list = list.where((i) => i.status == HarvestStatus.menunggu).toList();
    } else if (_selectedFilterIndex == 2) {
      list = list.where((i) => i.status == HarvestStatus.disetujui).toList();
    } else if (_selectedFilterIndex == 3) {
      list = list.where((i) => i.status == HarvestStatus.ditolak).toList();
    }

    if (_selectedSort == 'Terbesar') {
      list.sort((a, b) => b.weightKg.compareTo(a.weightKg));
    } else if (_selectedSort == 'Terkecil') {
      list.sort((a, b) => a.weightKg.compareTo(b.weightKg));
    }
    return list;
  }

  Future<void> _openAddHarvestModal() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => const RecordHarvestScreen(),
      ),
    );

    if (result == true || result is HarvestItem) {
      _fetchHarvestData();
    }
  }

  Future<void> _openItemDetail(HarvestItem item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => HarvestDetailScreen(
          item: item,
          onUpdate: (updated) => _fetchHarvestData(),
          onDelete: () => _fetchHarvestData(),
        ),
      ),
    );

    if (result == true || result is HarvestItem) {
      _fetchHarvestData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.primaryDark;
    final subtitleColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray;
    final chipUnselectedBg = isDark ? const Color(0xFF1D2420) : Colors.white;
    final chipUnselectedBorder = isDark ? const Color(0xFF28332C) : WarnaAplikasi.border;
    final chipUnselectedText = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.grayGreenDark;
    final emptyCardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
    final emptyCardBorder = isDark ? const Color(0xFF28332C) : WarnaAplikasi.border;

    final filterChips = [
      'Semua (${_harvestItems.length})',
      'Menunggu ($_countMenunggu)',
      'Disetujui ($_countDisetujui)',
      'Ditolak ($_countDitolak)',
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF141916) : WarnaAplikasi.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            const PawonFixedHeader(title: 'Panen'),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchHarvestData,
                color: WarnaAplikasi.primary,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Text(
                            'Data Panen',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: titleColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kelola dan pantau hasil panen Anda',
                            style: TextStyle(
                              fontSize: 13,
                              color: subtitleColor,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 18),

                          HarvestSummaryCard(
                            totalTon: _totalTon,
                            seasonName: _seasonName,
                            commodityBreakdown: _commodityBreakdownTon,
                          ),
                          const SizedBox(height: 14),

                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton.icon(
                              onPressed: _openAddHarvestModal,
                              icon: const Icon(
                                Icons.add_circle_outline_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Tambah Panen',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: WarnaAplikasi.primary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: List.generate(filterChips.length, (index) {
                                final isSelected = _selectedFilterIndex == index;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedFilterIndex = index;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? WarnaAplikasi.primary
                                            : chipUnselectedBg,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected
                                              ? WarnaAplikasi.primary
                                              : chipUnselectedBorder,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        filterChips[index],
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : chipUnselectedText,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Daftar Panen',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: titleColor,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              PopupMenuButton<String>(
                                initialValue: _selectedSort,
                                onSelected: (val) {
                                  setState(() {
                                    _selectedSort = val;
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                itemBuilder: (ctx) => [
                                  const PopupMenuItem(
                                    value: 'Terbaru',
                                    child: Text('Terbaru', style: TextStyle(fontSize: 12)),
                                  ),
                                  const PopupMenuItem(
                                    value: 'Terbesar',
                                    child: Text('Bobot Terbesar', style: TextStyle(fontSize: 12)),
                                  ),
                                  const PopupMenuItem(
                                    value: 'Terkecil',
                                    child: Text('Bobot Terkecil', style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                                child: Row(
                                  children: [
                                    Text(
                                      _selectedSort,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: subtitleColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 16,
                                      color: subtitleColor,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ]),
                      ),
                    ),

                    if (_isLoading)
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.all(48),
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(
                            color: WarnaAplikasi.primary,
                            strokeWidth: 2.5,
                          ),
                        ),
                      )
                    else if (_errorMessage != null)
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: WarnaAplikasi.errorRedDark, size: 36),
                              const SizedBox(height: 8),
                              Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: subtitleColor)),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _fetchHarvestData,
                                style: ElevatedButton.styleFrom(backgroundColor: WarnaAplikasi.primary),
                                child: const Text('Coba Lagi', style: TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_harvestItems.isEmpty)
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 18),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 30,
                          ),
                          decoration: BoxDecoration(
                            color: emptyCardBg,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: emptyCardBorder,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF243328) : WarnaAplikasi.bgSuccessPale,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.agriculture_outlined,
                                  size: 34,
                                  color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Belum ada data panen yang dicatat. Tekan tombol Tambah Panen untuk mencatat hasil panen Anda.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.45,
                                  color: subtitleColor,
                                ),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                height: 40,
                                child: ElevatedButton.icon(
                                  onPressed: _openAddHarvestModal,
                                  icon: const Icon(
                                    Icons.add_circle_outline_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Tambah Panen',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: WarnaAplikasi.primary,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_filteredItems.isEmpty)
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              const Icon(
                                Icons.inbox_outlined,
                                size: 48,
                                color: WarnaAplikasi.iconGrayGreenDark,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Belum ada panen dengan status ${_selectedFilterLabel.toLowerCase()}.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: WarnaAplikasi.textGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = _filteredItems[index];
                              return HarvestCard(
                                item: item,
                                onTap: () => _openItemDetail(item),
                              );
                            },
                            childCount: _filteredItems.length,
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 20),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
