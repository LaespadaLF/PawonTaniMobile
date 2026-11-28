import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/features/lahan/models/item_lahan.dart';
import 'package:pawon_mobile/features/lahan/screens/layar_tambah_lahan.dart';
import 'package:pawon_mobile/features/lahan/screens/layar_edit_lahan.dart';
import 'package:pawon_mobile/features/lahan/screens/layar_detail_lahan.dart';
import 'package:pawon_mobile/features/lahan/services/lahan_api_service.dart';
import 'package:pawon_mobile/core/widgets/ikon_tanaman_kustom.dart';
import 'package:pawon_mobile/features/profil/screens/layar_profil.dart';
import 'package:pawon_mobile/features/notifikasi/screens/layar_notifikasi.dart';

class LandScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  
  const LandScreen({super.key, this.onBackToHome});

  @override
  State<LandScreen> createState() => _LandScreenState();
}

class _LandScreenState extends State<LandScreen> {
  int _selectedFilterIndex = 0;
  bool _isSortNewest = true;
  List<ItemLahan> _ItemLahans = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMore = true;
  int? _totalPlots;
  final ScrollController _scrollController = ScrollController();
  String? _errorMessage;

  List<ItemLahan> get _displayedLahans {
    List<ItemLahan> list = List.from(_ItemLahans);

    // Filter berdasarkan status operasional (Semua, Aktif, Persiapan, Istirahat)
    if (_selectedFilterIndex == 1) {
      // Aktif
      list = list.where((item) => item.status == StatusLahan.aktif).toList();
    } else if (_selectedFilterIndex == 2) {
      // Persiapan
      list = list.where((item) => item.status == StatusLahan.persiapan).toList();
    } else if (_selectedFilterIndex == 3) {
      // Istirahat
      list = list.where((item) => item.status == StatusLahan.istirahat).toList();
    }

    // Sorting (Terbaru vs Terlama)
    list.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final cmp = _isSortNewest ? bDate.compareTo(aDate) : aDate.compareTo(bDate);
      if (cmp != 0) return cmp;
      return _isSortNewest ? b.id.compareTo(a.id) : a.id.compareTo(b.id);
    });

    return list;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadLahanList();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        !_isLoading &&
        _hasMore) {
      _loadMoreLahan();
    }
  }

  Future<void> _loadLahanList() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
      _hasMore = true;
    });

    final service = LahanApiService();
    final response = await service.getLahanList(page: 1);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (response.success) {
        _ItemLahans = response.data ?? [];
        _errorMessage = null;
        if (response.meta != null) {
          final lastPage = response.meta!['last_page'] as int? ?? 1;
          _hasMore = _currentPage < lastPage;
          _totalPlots = response.meta!['total'] as int?;
        } else {
          _hasMore = (_ItemLahans.length >= 10);
        }
      } else {
        _ItemLahans = [];
        _errorMessage = response.message.isNotEmpty ? response.message : 'Gagal memuat data lahan.';
      }
    });
  }

  Future<void> _loadMoreLahan() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    final nextPage = _currentPage + 1;
    final service = LahanApiService();
    final response = await service.getLahanList(page: nextPage);

    if (!mounted) return;

    setState(() {
      _isLoadingMore = false;
      if (response.success && response.data != null && response.data!.isNotEmpty) {
        _ItemLahans.addAll(response.data!);
        _currentPage = nextPage;
        if (response.meta != null) {
          final lastPage = response.meta!['last_page'] as int? ?? nextPage;
          _hasMore = _currentPage < lastPage;
          _totalPlots = response.meta!['total'] as int?;
        } else {
          _hasMore = response.data!.length >= 10;
        }
      } else {
        _hasMore = false;
      }
    });
  }

  void _navigateToAddLand() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddLandScreen()),
    ).then((value) {
      if (value != null) {
        _loadLahanList();
      }
    });
  }

  void _navigateToEditLand(ItemLahan item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditLandScreen(item: item)),
    ).then((value) {
      if (value != null) {
        if (value == 'delete') {
          _loadLahanList();
        } else if (value is ItemLahan) {
          setState(() {
            final index = _ItemLahans.indexWhere((element) => element.id == item.id);
            if (index != -1) {
              _ItemLahans[index] = value;
            }
          });
        } else {
          _loadLahanList();
        }
      }
    });
  }

  Future<void> _deleteLand(ItemLahan item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: WarnaAplikasi.errorRedBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Hapus Lahan?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text('Yakin ingin menghapus lahan "${item.nama}"? Data yang dihapus tidak bisa dikembalikan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ya, Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final service = LahanApiService();
    final response = await service.deleteLahan(item.id);

    if (!mounted) return;

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.nama} berhasil dihapus'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadLahanList();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message.isNotEmpty ? response.message : 'Gagal menghapus lahan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showMapBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final sheetBg = isDark ? const Color(0xFF1D2420) : Colors.white;
        final itemCardBg = isDark ? const Color(0xFF141916) : Colors.white;
        final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.border;
        final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.primaryDark;
        final subtitleColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3B4A40) : WarnaAplikasi.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Sebaran Lokasi Lahan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: titleColor),
                ),
              ),
              if (_ItemLahans.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Text('Belum ada data lahan.', style: TextStyle(color: subtitleColor)),
                )
              else
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _ItemLahans.length,
                    itemBuilder: (context, index) {
                      final item = _ItemLahans[index];
                      final lat = item.latitude ?? -6.5621;
                      final lng = item.longitude ?? 107.7589;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: itemCardBg,
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.nama,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: titleColor),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.lokasi,
                              style: TextStyle(fontSize: 12, color: subtitleColor),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Lat: ${lat.toStringAsFixed(6)}, Long: ${lng.toStringAsFixed(6)}',
                              style: TextStyle(fontSize: 11, color: subtitleColor),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 100,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: borderColor),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: FlutterMap(
                                  options: MapOptions(
                                    initialCenter: LatLng(lat, lng),
                                    initialZoom: 15,
                                    interactionOptions: const InteractionOptions(
                                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                                    ),
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      userAgentPackageName: 'id.pawontani.mobile',
                                      tileProvider: NetworkTileProvider(),
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          width: 32,
                                          height: 32,
                                          point: LatLng(lat, lng),
                                          child: Icon(Icons.location_on, color: Colors.red, size: 32),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filterChips = ['Semua', 'Aktif', 'Persiapan', 'Istirahat'];
    final displayed = _displayedLahans;

    double totalArea = _ItemLahans.fold(0.0, (sum, item) => sum + item.luas);
    int totalPlots = _totalPlots ?? _ItemLahans.length;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : WarnaAplikasi.primaryDark;
    final subtitleColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray;
    final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
    final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.border;

    return Scaffold(
      backgroundColor: WarnaAplikasi.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Top Header (Style Penjualan)
            PawonFixedHeader(
              title: 'Lahan',
              onProfileTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LayarProfil()),
              ),
              onNotificationTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LayarNotifikasi()),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadLahanList,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                        // Header Texts
                        Text(
                          'Data Lahan',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Kelola petak sawah dan kebun garapanmu.',
                          style: TextStyle(
                            fontSize: 13,
                            color: WarnaAplikasi.textGray,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Stats Cards
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1D2420) : WarnaAplikasi.greenLight,
                                  borderRadius: BorderRadius.circular(16),
                                  border: isDark ? Border.all(color: const Color(0xFF28332C)) : null,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF283A2E) : WarnaAplikasi.greenPill,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.architecture, color: WarnaAplikasi.primary, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Total Luas', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray)),
                                        Text('${totalArea.toStringAsFixed(1).replaceAll('.', ',')} Ha', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.primaryDark)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1D2420) : WarnaAplikasi.greenLight,
                                  borderRadius: BorderRadius.circular(16),
                                  border: isDark ? Border.all(color: const Color(0xFF28332C)) : null,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF283A2E) : WarnaAplikasi.greenPill,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.eco_outlined, color: WarnaAplikasi.primary, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Total Petak', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray)),
                                        Text('$totalPlots', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.primaryDark)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Add Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _navigateToAddLand,
                            icon: const Icon(Icons.add, color: Colors.white, size: 20),
                            label: const Text('Tambah Lahan Baru', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: WarnaAplikasi.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Filter Chips
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
                                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                    decoration: BoxDecoration(
                                                      color: isSelected
                                                          ? WarnaAplikasi.primary
                                                          : (isDark ? const Color(0xFF1D2420) : Colors.transparent),
                                                      borderRadius: BorderRadius.circular(20),
                                                      border: Border.all(
                                                        color: isSelected
                                                            ? WarnaAplikasi.primary
                                                            : (isDark ? const Color(0xFF28332C) : WarnaAplikasi.border),
                                                        width: 1,
                                                      ),
                                                    ),
                                    child: Text(
                                      filterChips[index],
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                        color: isSelected
                                            ? Colors.white
                                            : (isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // List Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Lahan Saya',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: titleColor),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _isSortNewest = !_isSortNewest;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Row(
                                  children: [
                                    Text(
                                      _isSortNewest ? 'Terbaru' : 'Terlama',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? WarnaAplikasi.accentGreen : WarnaAplikasi.primary),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      _isSortNewest ? Icons.arrow_downward : Icons.arrow_upward,
                                      size: 14,
                                      color: isDark ? WarnaAplikasi.accentGreen : WarnaAplikasi.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ]),
                    ),
                  ),
                  if (_isLoading)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: CircularProgressIndicator(color: WarnaAplikasi.primary),
                          ),
                        ),
                      ),
                    )
                  else if (_errorMessage != null)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                const Icon(Icons.wifi_off_rounded, size: 40, color: WarnaAplikasi.textGray),
                                const SizedBox(height: 12),
                                Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: WarnaAplikasi.textGray)),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: _loadLahanList,
                                  icon: const Icon(Icons.refresh, size: 18),
                                  label: const Text('Coba lagi'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: WarnaAplikasi.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (_ItemLahans.isEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                Icon(Icons.agriculture_outlined, size: 40, color: WarnaAplikasi.textGray),
                                const SizedBox(height: 12),
                                const Text('Belum ada data lahan.', style: TextStyle(color: WarnaAplikasi.textGray)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (displayed.isEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                const Icon(Icons.filter_list_off_rounded, size: 40, color: WarnaAplikasi.textGray),
                                const SizedBox(height: 12),
                                Text(
                                  'Tidak ada lahan dengan filter "${filterChips[_selectedFilterIndex]}".',
                                  style: const TextStyle(color: WarnaAplikasi.textGray),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = displayed[index];
                            final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
                            final isAktif = item.status == StatusLahan.aktif;
                            final isPersiapan = item.status == StatusLahan.persiapan;
                            final tagColor = isAktif
                                ? WarnaAplikasi.greenLight
                                : (isPersiapan ? WarnaAplikasi.warningOrangeBg : WarnaAplikasi.bgInput);
                            final tagTextColor = isAktif
                                ? WarnaAplikasi.primary
                                : (isPersiapan ? WarnaAplikasi.warningOrange : WarnaAplikasi.textGray);
                            final tagText = isAktif
                                ? 'Aktif Ditanami'
                                : (isPersiapan ? 'Dalam Persiapan' : 'Masa Istirahat');
                            final dotColor = isAktif
                                ? WarnaAplikasi.successGreen
                                : (isPersiapan ? WarnaAplikasi.hppAmberBg : WarnaAplikasi.textGrayLight);

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => LandDetailScreen(item: item)),
                                ).then((_) => _loadLahanList());
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF28332C) : WarnaAplikasi.borderPale,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: item.fotoLahan != null && item.fotoLahan!.isNotEmpty
                                          ? Image.network(
                                              item.fotoLahan!,
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                width: 80,
                                                height: 80,
                                                color: isDark ? const Color(0xFF283A2E) : WarnaAplikasi.greenLight,
                                                child: const Icon(Icons.agriculture_rounded, color: WarnaAplikasi.primary, size: 30),
                                              ),
                                            )
                                          : Container(
                                              width: 80,
                                              height: 80,
                                              color: isDark ? const Color(0xFF283A2E) : WarnaAplikasi.greenLight,
                                              child: const Icon(Icons.agriculture_rounded, color: WarnaAplikasi.primary, size: 30),
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: tagColor,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                                                const SizedBox(width: 4),
                                                Text(tagText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: tagTextColor)),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(item.nama, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.primaryDark)),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.location_on_outlined, size: 12, color: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGrayLight),
                                              const SizedBox(width: 4),
                                              Expanded(child: Text(item.lokasi, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.primaryLight), overflow: TextOverflow.ellipsis)),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(Icons.wb_sunny_outlined, size: 12, color: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.primaryLight),
                                              const SizedBox(width: 4),
                                              Text('${item.luas.toStringAsFixed(1).replaceAll('.', ',')} Ha', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFFE2E9E4) : WarnaAplikasi.textDarkGreen)),
                                              const SizedBox(width: 12),
                                              Icon(Icons.eco_outlined, size: 12, color: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.primaryLight),
                                              const SizedBox(width: 4),
                                              Text(item.komoditas, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFFE2E9E4) : WarnaAplikasi.textDarkGreen)),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  InkWell(
                                                    onTap: () => _navigateToEditLand(item),
                                                    child: Icon(Icons.edit_outlined, size: 18, color: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGrayLight),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  InkWell(
                                                    onTap: () => _deleteLand(item),
                                                    child: const Icon(Icons.delete_outline, size: 18, color: WarnaAplikasi.errorRedBright),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: displayed.length,
                        ),
                      ),
                    ),
                  if (_isLoadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: WarnaAplikasi.primary),
                          ),
                        ),
                      ),
                    ),
                  // Bottom Map Card
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.map_outlined, color: WarnaAplikasi.primary, size: 20),
                                    const SizedBox(width: 8),
                                    Text('Sebaran Lokasi Lahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: titleColor)),
                                  ],
                                ),
                                Text('${_ItemLahans.length} Petak', style: TextStyle(fontSize: 12, color: subtitleColor)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: _showMapBottomSheet,
                              child: Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF141916) : WarnaAplikasi.greenPill,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isDark ? Border.all(color: borderColor) : null,
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: FlutterMap(
                                        options: MapOptions(
                                          initialCenter: const LatLng(-6.5621, 107.7589),
                                          initialZoom: 14,
                                          interactionOptions: const InteractionOptions(
                                            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                                          ),
                                        ),
                                        children: [
                                          TileLayer(
                                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                            userAgentPackageName: 'id.pawontani.mobile',
                                            tileProvider: NetworkTileProvider(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF1D2420) : Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          border: isDark ? Border.all(color: borderColor) : null,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          'Lihat Peta',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
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
