import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:flutter/material.dart';
import 'package:pawon_mobile/features/aktivitas/models/item_aktivitas_tanam.dart';
import 'package:pawon_mobile/core/widgets/ikon_tanaman_kustom.dart';
import 'package:pawon_mobile/features/aktivitas/widgets/dialog_hapus_aktivitas.dart';
import 'package:pawon_mobile/features/aktivitas/screens/layar_catat_aktivitas.dart';
import 'package:pawon_mobile/features/aktivitas/screens/layar_edit_aktivitas.dart';

class ActivityScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const ActivityScreen({super.key, this.onBackToHome});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  String _selectedFilter = 'Semua';
  String _selectedSort = 'Terbaru';

  late List<PlantActivityItem> _activities;

  @override
  void initState() {
    super.initState();
    _activities = [
      const PlantActivityItem(
        id: '1',
        title: 'Pemupukan',
        cropName: 'Padi Ciherang - MTI',
        category: ActivityCategory.pemupukan,
        condition: PlantCondition.sehat,
        date: '15 Nov 2024',
        time: '07:30 WIB',
        location: 'Petak Sawah Barat (Blok A)',
        blockArea: '0,75 Ha • Padi Ciherang',
        notes: 'Pemupukan NPK Phonska sebanyak 50 kg dan pembersihan gulma.',
        imageUrl: 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=600&auto=format&fit=crop&q=80',
        dayNumber: 45,
      ),
      const PlantActivityItem(
        id: '2',
        title: 'Pengairan',
        cropName: 'Jagung Manis - HTI',
        category: ActivityCategory.pengairan,
        condition: PlantCondition.perluPerhatian,
        date: '12 Nov 2024',
        time: '06:30 WIB',
        location: 'Petak Sawah Timur (Blok C)',
        blockArea: '0,50 Ha • Jagung Manis',
        notes: 'Pengairan dilakukan selama 2 jam menggunakan pompa air.',
        imageUrl: 'https://images.unsplash.com/photo-1592417817098-8f3d6910a711?w=600&auto=format&fit=crop&q=80',
        dayNumber: 32,
      ),
      const PlantActivityItem(
        id: '3',
        title: 'Penyemprotan',
        cropName: 'Padi Ciherang - MTI',
        category: ActivityCategory.penyemprotan,
        condition: PlantCondition.sehat,
        date: '08 Nov 2024',
        time: '16:00 WIB',
        location: 'Petak Sawah Barat (Blok A)',
        blockArea: '0,75 Ha • Padi Ciherang',
        notes: 'Penyemprotan pestisida untuk pencegahan hama wereng.',
        imageUrl: 'https://images.unsplash.com/photo-1530507629858-e4977d30e9e0?w=600&auto=format&fit=crop&q=80',
        dayNumber: 38,
      ),
    ];
  }

  List<PlantActivityItem> get _filteredActivities {
    var list = _activities;
    if (_selectedFilter != 'Semua') {
      list = list.where((item) => item.category.label.toLowerCase() == _selectedFilter.toLowerCase()).toList();
    }
    if (_selectedSort == 'Terlama') {
      return list.reversed.toList();
    }
    return list;
  }

  int get _countPerluPerhatian {
    return _activities.where((a) => a.condition != PlantCondition.sehat).length;
  }

  void _navigateToAddActivity() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecordActivityScreen(
          onSave: (newItem) {
            setState(() {
              _activities.insert(0, newItem);
            });
          },
        ),
      ),
    );
  }

  void _navigateToEditActivity(PlantActivityItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditActivityScreen(
          item: item,
          onUpdate: (updated) {
            setState(() {
              final idx = _activities.indexWhere((a) => a.id == updated.id);
              if (idx != -1) {
                _activities[idx] = updated;
              }
            });
          },
          onDelete: (id) {
            setState(() {
              _activities.removeWhere((a) => a.id == id);
            });
          },
        ),
      ),
    );
  }

  void _confirmDelete(PlantActivityItem item) {
    DeleteActivityDialog.show(
      context,
      item: item,
      onConfirmDelete: () {
        setState(() {
          _activities.removeWhere((a) => a.id == item.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catatan aktivitas berhasil dihapus.'),
            backgroundColor: Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filterOptions = ['Semua', 'Penyiraman', 'Pemupukan', 'Pengairan', 'Penyemprotan', 'Penyiangan'];

    return Scaffold(
      backgroundColor: WarnaAplikasi.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Top Header (Style PawonFixedHeader)
            const PawonFixedHeader(title: 'Aktivitas'),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Banner Card
                    _buildSummaryBanner(),
              const SizedBox(height: 16),

              // 3. Filter Chips
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: filterOptions.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = filterOptions[index];
                    final isSelected = _selectedFilter == filter;
                    return InkWell(
                      onTap: () => setState(() => _selectedFilter = filter),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? WarnaAplikasi.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? WarnaAplikasi.primary : const Color(0xFFE2EBE5),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : const Color(0xFF4B5563),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // 4. Section Header: "Aktivitas Terbaru" & Sort Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Aktivitas Terbaru',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: WarnaAplikasi.primaryDark,
                    ),
                  ),
                  InkWell(
                    onTap: _showSortPicker,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Row(
                        children: [
                          Text(
                            _selectedSort,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF718679),
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: Color(0xFF718679),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 5. Activity Cards List
              if (_filteredActivities.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE8EFEA)),
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.spa_outlined, size: 40, color: Color(0xFFB0C2B5)),
                      SizedBox(height: 12),
                      Text(
                        'Belum Ada Aktivitas',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: WarnaAplikasi.primaryDark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tidak ada aktivitas yang sesuai dengan filter ini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Color(0xFF718679)),
                      ),
                    ],
                  ),
                )
              else
                ..._filteredActivities.map((activity) {
                  return _buildActivityCard(activity);
                }),

              const SizedBox(height: 16),

              // 6. Bottom CTA Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF5EE),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD3E7D9)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.library_books_outlined,
                        color: WarnaAplikasi.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Belum ada aktivitas lainnya',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: WarnaAplikasi.primaryDark,
                            ),
                          ),
                          SizedBox(height: 1),
                          Text(
                            'Catat aktivitas baru untuk memantau perkembangan tanaman.',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF5E7567),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _navigateToAddActivity,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WarnaAplikasi.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        minimumSize: Size.zero,
                      ),
                      child: const Text(
                        '+ Catat',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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

  Widget _buildSummaryBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: WarnaAplikasi.greenLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFD4EBD9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.spa_rounded,
              color: WarnaAplikasi.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aktivitas Tanaman',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: WarnaAplikasi.primaryDark,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _buildSummaryPill(
                      icon: Icons.assignment_turned_in_outlined,
                      label: '${_activities.length} Aktivitas',
                    ),
                    _buildSummaryPill(
                      icon: Icons.holiday_village_outlined,
                      label: '3 Lahan Aktif',
                    ),
                    _buildSummaryPill(
                      icon: Icons.warning_amber_rounded,
                      label: '$_countPerluPerhatian Perlu Perhatian',
                      isWarning: true,
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

  Widget _buildSummaryPill({
    required IconData icon,
    required String label,
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: isWarning ? const Color(0xFFFFF3E0) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isWarning ? const Color(0xFFFED7AA) : const Color(0xFFE2EBE5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: isWarning ? WarnaAplikasi.warningOrange : WarnaAplikasi.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isWarning ? WarnaAplikasi.warningOrange : WarnaAplikasi.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(PlantActivityItem item) {
    Color iconBg;
    Color iconColor;
    IconData icon;

    switch (item.category) {
      case ActivityCategory.pemupukan:
        iconBg = WarnaAplikasi.greenLight;
        iconColor = WarnaAplikasi.primary;
        icon = Icons.spa_rounded;
        break;
      case ActivityCategory.pengairan:
      case ActivityCategory.penyiraman:
        iconBg = const Color(0xFFE0F2FE);
        iconColor = const Color(0xFF0284C7);
        icon = Icons.water_drop_outlined;
        break;
      case ActivityCategory.penyemprotan:
        iconBg = WarnaAplikasi.greenLight;
        iconColor = WarnaAplikasi.primary;
        icon = Icons.shield_outlined;
        break;
      default:
        iconBg = WarnaAplikasi.greenLight;
        iconColor = WarnaAplikasi.primary;
        icon = Icons.eco_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EFEA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon, Title & Crop, Condition Badge
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: WarnaAplikasi.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        item.cropName,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF718679),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: item.condition == PlantCondition.sehat
                        ? const Color(0xFFE5F6EA)
                        : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item.condition.badgeText,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: item.condition == PlantCondition.sehat
                          ? WarnaAplikasi.primary
                          : WarnaAplikasi.warningOrange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Date & Time Row
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFF718679)),
                const SizedBox(width: 4),
                Text(
                  item.date,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF718679), fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 10),
                const Text('•', style: TextStyle(color: Color(0xFFB0C2B5))),
                const SizedBox(width: 10),
                const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF718679)),
                const SizedBox(width: 4),
                Text(
                  item.time,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF718679), fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Location Row
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF718679)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.location,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF718679), fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Notes
            Text(
              item.notes,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF374151),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),

            // Divider
            const Divider(height: 1, color: Color(0xFFF0F4F1)),
            const SizedBox(height: 8),

            // Footer: Lihat Detail, Edit, Delete
            Row(
              children: [
                InkWell(
                  onTap: () => _showDetailModal(item),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          'Lihat Detail',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: WarnaAplikasi.primary,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 14, color: WarnaAplikasi.primary),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Edit Button
                IconButton(
                  onPressed: () => _navigateToEditActivity(item),
                  icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF718679)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 14),
                // Delete Button
                IconButton(
                  onPressed: () => _confirmDelete(item),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSortPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4E0D7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Urutkan Aktivitas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: WarnaAplikasi.primaryDark),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Terbaru', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                trailing: _selectedSort == 'Terbaru'
                    ? const Icon(Icons.check_circle_rounded, color: WarnaAplikasi.primary)
                    : null,
                onTap: () {
                  setState(() => _selectedSort = 'Terbaru');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Terlama', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                trailing: _selectedSort == 'Terlama'
                    ? const Icon(Icons.check_circle_rounded, color: WarnaAplikasi.primary)
                    : null,
                onTap: () {
                  setState(() => _selectedSort = 'Terlama');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDetailModal(PlantActivityItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4E0D7),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: WarnaAplikasi.primaryDark,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.condition == PlantCondition.sehat
                              ? const Color(0xFFE5F6EA)
                              : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          item.condition.badgeText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: item.condition == PlantCondition.sehat
                                ? WarnaAplikasi.primary
                                : WarnaAplikasi.warningOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.cropName,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF718679), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  // Information Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAF9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8EFEA)),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Petak Lahan', item.location),
                        const Divider(height: 14, color: Color(0xFFEBF0EC)),
                        _buildDetailRow('Luas & Varietas', item.blockArea),
                        const Divider(height: 14, color: Color(0xFFEBF0EC)),
                        _buildDetailRow('Waktu Catat', '${item.date}, ${item.time}'),
                        const Divider(height: 14, color: Color(0xFFEBF0EC)),
                        _buildDetailRow('Fase Pertumbuhan', 'Hari Ke-${item.dayNumber ?? 45}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Catatan Lapangan',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: WarnaAplikasi.primaryDark),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.notes,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.5),
                  ),
                  if (item.imageUrl != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Dokumentasi Foto',
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: WarnaAplikasi.primaryDark),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        item.imageUrl!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _navigateToEditActivity(item);
                          },
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit Aktivitas'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: WarnaAplikasi.primary,
                            side: const BorderSide(color: WarnaAplikasi.primary),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WarnaAplikasi.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF718679))),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: WarnaAplikasi.primaryDark),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

