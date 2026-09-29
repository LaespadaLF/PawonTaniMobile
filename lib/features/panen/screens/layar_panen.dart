import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:flutter/material.dart';
import 'package:pawon_mobile/features/panen/models/item_panen.dart';
import 'package:pawon_mobile/core/widgets/ikon_tanaman_kustom.dart';
import 'package:pawon_mobile/features/panen/widgets/kartu_ringkasan_panen.dart';
import 'package:pawon_mobile/features/beranda/widgets/kartu_kemitraan.dart';
import 'package:pawon_mobile/features/panen/widgets/kartu_panen.dart';
import 'package:pawon_mobile/features/panen/screens/layar_catat_panen.dart';
import 'package:pawon_mobile/features/panen/screens/layar_detail_panen.dart';

class HarvestScreen extends StatefulWidget {
  const HarvestScreen({super.key});

  @override
  State<HarvestScreen> createState() => _HarvestScreenState();
}

class _HarvestScreenState extends State<HarvestScreen> {
  int _selectedFilterIndex = 0; // 0: Semua, 1: Menunggu, 2: Disetujui, 3: Ditolak
  String _selectedSort = 'Terbaru';

  late List<HarvestItem> _harvestItems;

  @override
  void initState() {
    super.initState();
    _harvestItems = [
      const HarvestItem(
        id: '1',
        title: 'Padi Ciherang',
        subtitle: 'GKP • Gabah Kering Panen',
        cropType: CropType.padi,
        status: HarvestStatus.menunggu,
        location: 'Petak Sawah Barat',
        blockArea: 'Blok A • 0,75 Ha',
        date: '28 Okt 2024',
        season: 'Musim Rendeng',
        weightKg: 4850,
        qualityGrade: 'Kualitas Super',
        moistureOrNotes: 'Kadar Air 14%',
      ),
      const HarvestItem(
        id: '2',
        title: 'Jagung Manis H',
        subtitle: 'Tongkol Segar Siap Jual',
        cropType: CropType.jagung,
        status: HarvestStatus.disetujui,
        location: 'Kebun Jagung Lereng',
        blockArea: 'Blok C • 0,5 Ha',
        date: '15 Nov 2024',
        season: 'Musim Rendeng',
        weightKg: 3200,
        qualityGrade: 'Grade A Super',
        moistureOrNotes: 'Pipilan Penuh',
      ),
      const HarvestItem(
        id: '3',
        title: 'Padi IR-64',
        subtitle: 'GKP • Gabah Kering Panen',
        cropType: CropType.padi,
        status: HarvestStatus.ditolak,
        location: 'Petak Sawah Timur',
        blockArea: 'Blok B • 0,75 Ha',
        date: '05 Jul 2024',
        season: 'Musim Gadu',
        weightKg: 4750,
        qualityGrade: 'Kualitas Medium',
        moistureOrNotes: 'Kadar Air 18%',
      ),
      const HarvestItem(
        id: '4',
        title: 'Jagung Manis H',
        subtitle: 'Tongkol Segar Siap Jual',
        cropType: CropType.jagung,
        status: HarvestStatus.disetujui,
        location: 'Kebun Jagung Selatan',
        blockArea: 'Blok D • 0,4 Ha',
        date: '11 Jun 2024',
        season: 'Musim Gadu',
        weightKg: 2850,
        qualityGrade: 'Grade B',
        moistureOrNotes: 'Pipilan Sedang',
      ),
    ];
  }

  double get _totalPadiTon {
    return _harvestItems
        .where((i) => i.cropType == CropType.padi)
        .fold(0.0, (prev, elem) => prev + elem.weightTon);
  }

  double get _totalJagungTon {
    return _harvestItems
        .where((i) => i.cropType == CropType.jagung)
        .fold(0.0, (prev, elem) => prev + elem.weightTon);
  }

  double get _totalTon => _totalPadiTon + _totalJagungTon;

  int get _countMenunggu =>
      _harvestItems.where((i) => i.status == HarvestStatus.menunggu).length;
  int get _countDisetujui =>
      _harvestItems.where((i) => i.status == HarvestStatus.disetujui).length;
  int get _countDitolak =>
      _harvestItems.where((i) => i.status == HarvestStatus.ditolak).length;

  List<HarvestItem> get _filteredItems {
    List<HarvestItem> list = _harvestItems;
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

  void _openAddHarvestModal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => RecordHarvestScreen(
          onSave: (newItem) {
            setState(() {
              _harvestItems.insert(0, newItem);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${newItem.title} berhasil ditambahkan!'),
                backgroundColor: WarnaAplikasi.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
  }

  void _openItemDetail(HarvestItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => HarvestDetailScreen(
          item: item,
          onUpdate: (updatedItem) {
            setState(() {
              final idx = _harvestItems.indexWhere((i) => i.id == updatedItem.id);
              if (idx != -1) {
                _harvestItems[idx] = updatedItem;
              }
            });
          },
          onDelete: () {
            setState(() {
              _harvestItems.removeWhere((elem) => elem.id == item.id);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${item.title} berhasil dihapus.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filterChips = [
      'Semua (${_harvestItems.length})',
      'Menunggu ($_countMenunggu)',
      'Disetujui ($_countDisetujui)',
      'Ditolak ($_countDitolak)',
    ];

    return Scaffold(
      backgroundColor: WarnaAplikasi.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Top Header (Style Penjualan)
            const PawonFixedHeader(title: 'Panen'),
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Title and Subtitle
                        const Text(
                          'Data Panen',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: WarnaAplikasi.primaryDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Kelola dan pantau hasil panen Anda',
                          style: TextStyle(
                            fontSize: 13,
                            color: WarnaAplikasi.textGray,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Total Harvest Summary Card
                        HarvestSummaryCard(
                          totalTon: _totalTon > 0 ? _totalTon : 12.8,
                          padiTon: _totalPadiTon > 0 ? _totalPadiTon : 9.60,
                          jagungTon: _totalJagungTon > 0 ? _totalJagungTon : 3.20,
                          seasonName: 'Musim Tanam 2024',
                        ),
                        const SizedBox(height: 14),

                        // "+ Tambah Panen" Button
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

                        // Filter Chips Row
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
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? WarnaAplikasi.primary
                                            : WarnaAplikasi.border,
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
                                            : const Color(0xFF4A6252),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Partnership Card Banner
                        PartnershipCard(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Informasi Kemitraan Bulog & Pupuk Indonesia',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Section Title: "Daftar Panen" & Sort Dropdown
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Daftar Panen',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: WarnaAplikasi.primaryDark,
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
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF5D7364),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 16,
                                    color: Color(0xFF5D7364),
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

                  // Sliver List of Harvest Items
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    sliver: _filteredItems.isEmpty
                        ? SliverToBoxAdapter(
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              alignment: Alignment.center,
                              child: const Column(
                                children: [
                                  Icon(
                                    Icons.inbox_outlined,
                                    size: 48,
                                    color: Color(0xFFADC4B5),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Tidak ada data panen pada kategori ini',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: WarnaAplikasi.textGray,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SliverList(
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
          ],
        ),
      ),
    );
  }
}
