import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:flutter/material.dart';
import 'package:pawon_mobile/features/lahan/models/item_lahan.dart';
import 'package:pawon_mobile/core/widgets/ikon_tanaman_kustom.dart';
import 'package:pawon_mobile/features/lahan/screens/layar_tambah_lahan.dart';
import 'package:pawon_mobile/features/lahan/screens/layar_edit_lahan.dart';
import 'package:pawon_mobile/features/lahan/screens/layar_detail_lahan.dart';

class LandScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  
  const LandScreen({super.key, this.onBackToHome});

  @override
  State<LandScreen> createState() => _LandScreenState();
}

class _LandScreenState extends State<LandScreen> {
  int _selectedFilterIndex = 0;
  String _selectedSort = 'Terbaru';

  List<ItemLahan> _ItemLahans = [
    const ItemLahan(
      id: '1',
      nama: 'Petak Sawah Barat (Blok A)',
      lokasi: 'Sukamaju, RT 02/RW 01',
      luas: 0.8,
      komoditas: 'Padi Ciherang',
      status: StatusLahan.aktif,
    ),
    const ItemLahan(
      id: '2',
      nama: 'Kebun Jagung Lereng (Blok C)',
      lokasi: 'Bukit Sukamaju, Lereng Selatan',
      luas: 0.6,
      komoditas: 'Jagung Hibrida',
      status: StatusLahan.persiapan,
    ),
    const ItemLahan(
      id: '3',
      nama: 'Petak Sawah Timur (Blok B)',
      lokasi: 'Dusun Sukasari, Area Irigasi',
      luas: 0.4,
      komoditas: 'Padi Ciherang',
      status: StatusLahan.aktif,
    ),
  ];

  void _navigateToAddLand() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddLandScreen()),
    ).then((value) {
      if (value != null && value is ItemLahan) {
        setState(() {
          _ItemLahans.insert(0, value);
        });
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
          setState(() {
            _ItemLahans.removeWhere((element) => element.id == item.id);
          });
        } else if (value is ItemLahan) {
          setState(() {
            final index = _ItemLahans.indexWhere((element) => element.id == item.id);
            if (index != -1) {
              _ItemLahans[index] = value;
            }
          });
        }
      }
    });
  }

  void _deleteLand(ItemLahan item) {
    setState(() {
      _ItemLahans.removeWhere((element) => element.id == item.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.nama} berhasil dihapus'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filterChips = ['Semua', 'Aktif Ditanami', 'Masa Olah Tanah'];

    double totalArea = _ItemLahans.fold(0.0, (sum, item) => sum + item.luas);
    int totalPlots = _ItemLahans.length;

    return Scaffold(
      backgroundColor: WarnaAplikasi.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // App Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const PawonTaniLogo(size: 28),
                          const SizedBox(width: 8),
                          const Text(
                            'PawonTani',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E3325),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined, color: Color(0xFF1E3325)),
                                onPressed: () {},
                              ),
                              Positioned(
                                right: 10,
                                top: 10,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                  child: const Text(
                                    '2',
                                    style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage('https://images.unsplash.com/photo-1595246140625-573b715d11dc?w=100&q=80'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Header Texts
                  const Text(
                    'Data Lahan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: WarnaAplikasi.primaryDark,
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
                            color: WarnaAplikasi.greenLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: WarnaAplikasi.greenPill,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.architecture, color: WarnaAplikasi.primary, size: 20), // Placeholder icon
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total Luas', style: TextStyle(fontSize: 11, color: WarnaAplikasi.textGray)),
                                  Text('${totalArea.toStringAsFixed(1).replaceAll('.', ',')} Ha', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark)),
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
                            color: WarnaAplikasi.greenLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: WarnaAplikasi.greenPill,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.eco_outlined, color: WarnaAplikasi.primary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total Petak', style: TextStyle(fontSize: 11, color: WarnaAplikasi.textGray)),
                                  Text('$totalPlots', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark)),
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
                        backgroundColor: WarnaAplikasi.primaryLight,
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
                                color: isSelected ? WarnaAplikasi.primaryLight : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? WarnaAplikasi.primaryLight : WarnaAplikasi.border,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                filterChips[index],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected ? Colors.white : WarnaAplikasi.textGray,
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
                      const Text(
                        'Lahan Saya',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark),
                      ),
                      Row(
                        children: [
                          Text('Terbaru', style: TextStyle(fontSize: 12, color: WarnaAplikasi.textGray)),
                          const Icon(Icons.keyboard_arrow_down, size: 16, color: WarnaAplikasi.textGray),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = _ItemLahans[index];
                    final isAktif = item.status == StatusLahan.aktif;
                    final tagColor = isAktif ? WarnaAplikasi.greenLight : WarnaAplikasi.warningOrangeBg;
                    final tagTextColor = isAktif ? WarnaAplikasi.primary : WarnaAplikasi.warningOrange;
                    final tagText = isAktif ? 'Aktif Ditanami' : (item.status == StatusLahan.persiapan ? 'Dalam Proses' : 'Masa Olah Tanah');
                    final dotColor = isAktif ? const Color(0xFF22C55E) : const Color(0xFFF59E0B);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
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
                            child: Image.network(
                              'https://images.unsplash.com/photo-1595246140625-573b715d11dc?w=300&q=80',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
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
                                Text(item.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: WarnaAplikasi.primaryDark)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 12, color: WarnaAplikasi.textGrayLight),
                                    const SizedBox(width: 4),
                                    Expanded(child: Text(item.lokasi, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)), overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.wb_sunny_outlined, size: 12, color: WarnaAplikasi.primaryLight),
                                    const SizedBox(width: 4),
                                    Text('${item.luas.toStringAsFixed(1).replaceAll('.', ',')} Ha', style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.eco_outlined, size: 12, color: WarnaAplikasi.primaryLight),
                                    const SizedBox(width: 4),
                                    Text(item.komoditas, style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => LandDetailScreen(item: item)),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(color: WarnaAplikasi.greenLight, borderRadius: BorderRadius.circular(16)),
                                        child: const Row(
                                          children: [
                                            Text('Lihat Detail', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: WarnaAplikasi.primary)),
                                            SizedBox(width: 4),
                                            Icon(Icons.chevron_right, size: 14, color: WarnaAplikasi.primary),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () => _navigateToEditLand(item),
                                          child: const Icon(Icons.edit_outlined, size: 18, color: WarnaAplikasi.textGrayLight),
                                        ),
                                        const SizedBox(width: 16),
                                        InkWell(
                                          onTap: () => _deleteLand(item),
                                          child: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
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
                    );
                  },
                  childCount: _ItemLahans.length,
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
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
                          const Row(
                            children: [
                              Icon(Icons.map_outlined, color: WarnaAplikasi.primary, size: 20),
                              SizedBox(width: 8),
                              Text('Sebaran Lokasi Lahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          Text('${_ItemLahans.length} Petak', style: const TextStyle(fontSize: 12, color: WarnaAplikasi.textGray)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: WarnaAplikasi.greenPill,
                          borderRadius: BorderRadius.circular(12),
                          image: const DecorationImage(
                            image: NetworkImage('https://maps.googleapis.com/maps/api/staticmap?center=-6.5621,107.7589&zoom=14&size=400x150&maptype=roadmap'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text('Lihat Peta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: WarnaAplikasi.primary)),
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
    );
  }
}

