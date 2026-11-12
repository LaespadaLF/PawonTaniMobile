import 'package:flutter/material.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/features/aktivitas/models/item_aktivitas_tanam.dart';
import 'package:pawon_mobile/features/aktivitas/screens/layar_catat_aktivitas.dart';
import 'package:pawon_mobile/features/aktivitas/screens/layar_edit_aktivitas.dart';
import 'package:pawon_mobile/features/aktivitas/services/aktivitas_api_service.dart';
import 'package:pawon_mobile/features/aktivitas/widgets/dialog_hapus_aktivitas.dart';

class ActivityScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const ActivityScreen({super.key, this.onBackToHome});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final AktivitasApiService _aktivitasService = AktivitasApiService();

  String _selectedFilter = 'Semua';
  String _selectedSort = 'Terbaru';

  List<PlantActivityItem> _activities = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _aktivitasService.getAktivitasList();

    if (!mounted) return;

    if (response.success && response.data != null) {
      setState(() {
        _activities = response.data!;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Gagal memuat catatan aktivitas pertanian.';
        _isLoading = false;
      });
    }
  }

  List<PlantActivityItem> get _filteredActivities {
    var list = _activities;
    if (_selectedFilter != 'Semua') {
      list = list
          .where(
            (item) =>
                item.category.label.toLowerCase() ==
                _selectedFilter.toLowerCase(),
          )
          .toList();
    }
    if (_selectedSort == 'Terlama') {
      return list.reversed.toList();
    }
    return list;
  }

  int get _countPerluPerhatian {
    return _activities.where((a) => a.condition != PlantCondition.sehat).length;
  }

  Future<void> _navigateToAddActivity() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RecordActivityScreen(),
      ),
    );

    if (result == true || result is PlantActivityItem) {
      _loadActivities();
    }
  }

  Future<void> _navigateToEditActivity(PlantActivityItem item) async {
    final result = await Navigator.of(context).push(
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

    if (result != null) {
      _loadActivities();
    }
  }

  void _confirmDelete(PlantActivityItem item) {
    DeleteActivityDialog.show(
      context,
      item: item,
      onConfirmDelete: () async {
        final response = await _aktivitasService.deleteAktivitas(item.id);
        if (!mounted) return;

        if (response.success) {
          setState(() {
            _activities.removeWhere((a) => a.id == item.id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Catatan aktivitas berhasil dihapus.'),
              backgroundColor: WarnaAplikasi.errorRedDark,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message.isNotEmpty
                  ? response.message
                  : 'Gagal menghapus aktivitas.'),
              backgroundColor: WarnaAplikasi.errorRedDark,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filterOptions = [
      'Semua',
      'Pemupukan',
      'Penyiraman',
      'Pengairan',
      'Penyemprotan',
      'Penyiangan',
      'Pemangkasan',
    ];

    return Scaffold(
      backgroundColor: WarnaAplikasi.primaryBackground,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddActivity,
        backgroundColor: WarnaAplikasi.buttonDark,
        elevation: 3,
        icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
        label: const Text(
          'Catat Aktivitas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadActivities,
          color: WarnaAplikasi.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (widget.onBackToHome != null) ...[
                            InkWell(
                              onTap: widget.onBackToHome,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: WarnaAplikasi.borderField),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: WarnaAplikasi.primaryDark,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          const Text(
                            'Aktivitas Pertanian',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: WarnaAplikasi.primaryDark,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: _loadActivities,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: WarnaAplikasi.borderField),
                          ),
                          child: const Icon(
                            Icons.refresh_rounded,
                            color: WarnaAplikasi.primaryDark,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Pantau dan catat seluruh kegiatan perawatan tanaman Anda',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: WarnaAplikasi.textGray,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Summary Banner Card
                  _buildSummaryBanner(),
                  const SizedBox(height: 16),

                  // Filter Chips
                  SizedBox(
                    height: 36,
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
                                color: isSelected ? WarnaAplikasi.primary : WarnaAplikasi.borderField,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                filter,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? Colors.white : WarnaAplikasi.dialogText,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Section Header: Aktivitas & Sort Selector
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
                                  color: WarnaAplikasi.textGrayGreen,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: WarnaAplikasi.textGrayGreen,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // State Display: Loading, Error, Empty, or List
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(color: WarnaAplikasi.primary),
                            SizedBox(height: 12),
                            Text(
                              'Memuat catatan aktivitas...',
                              style: TextStyle(fontSize: 12.5, color: WarnaAplikasi.textGrayGreen),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 36),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12.5, color: Colors.red),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _loadActivities,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Coba Lagi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: WarnaAplikasi.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_filteredActivities.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: WarnaAplikasi.borderPale),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: WarnaAplikasi.greenLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.spa_outlined,
                              size: 32,
                              color: WarnaAplikasi.primary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Belum Ada Aktivitas',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: WarnaAplikasi.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Mulai catat jadwal pemupukan, penyiraman, atau perawatan petak lahan Anda sekarang.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: WarnaAplikasi.textGrayGreen,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _navigateToAddActivity,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Catat Aktivitas Baru'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: WarnaAplikasi.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._filteredActivities.map((activity) {
                      return _buildActivityCard(activity);
                    }),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WarnaAplikasi.primary,
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=600&auto=format&fit=crop&q=80',
          ),
          fit: BoxFit.cover,
          opacity: 0.12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ringkasan Aktivitas',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      '${_activities.length} Kegiatan',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildBannerStat(
                  icon: Icons.check_circle_outline,
                  title: 'Sehat & Baik',
                  value: '${_activities.where((a) => a.condition == PlantCondition.sehat).length}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildBannerStat(
                  icon: Icons.warning_amber_rounded,
                  title: 'Perlu Perhatian',
                  value: '$_countPerluPerhatian',
                  highlight: _countPerluPerhatian > 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBannerStat({
    required IconData icon,
    required String title,
    required String value,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight
            ? const Color(0xFFF59E0B).withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight
              ? const Color(0xFFF59E0B)
              : Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
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
        iconBg = WarnaAplikasi.statusBadgeBlueBg;
        iconColor = WarnaAplikasi.statusBadgeBlueText;
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
        border: Border.all(color: WarnaAplikasi.borderPale),
        boxShadow: const [
          BoxShadow(
            color: WarnaAplikasi.shadowCard,
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
                        item.cropName.isNotEmpty ? item.cropName : item.location,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: WarnaAplikasi.textGrayGreen,
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
                        ? WarnaAplikasi.bgSuccessLight
                        : WarnaAplikasi.statusTempoBg,
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
                const Icon(Icons.calendar_today_outlined, size: 12, color: WarnaAplikasi.textGrayGreen),
                const SizedBox(width: 4),
                Text(
                  item.date,
                  style: const TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayGreen, fontWeight: FontWeight.w500),
                ),
                if (item.time.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  const Text('•', style: TextStyle(color: WarnaAplikasi.iconGray)),
                  const SizedBox(width: 8),
                  const Icon(Icons.access_time_rounded, size: 12, color: WarnaAplikasi.textGrayGreen),
                  const SizedBox(width: 4),
                  Text(
                    item.time,
                    style: const TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayGreen, fontWeight: FontWeight.w500),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),

            // Location Row
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 12, color: WarnaAplikasi.textGrayGreen),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.location,
                    style: const TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayGreen, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Notes
            if (item.notes.isNotEmpty)
              Text(
                item.notes,
                style: const TextStyle(
                  fontSize: 12,
                  color: WarnaAplikasi.textGrayDark,
                  height: 1.35,
                ),
              ),

            // Foto thumbnail if available
            if (item.imageUrl != null && item.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.imageUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1, color: WarnaAplikasi.dividerLight),
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
                IconButton(
                  onPressed: () => _navigateToEditActivity(item),
                  icon: const Icon(Icons.edit_outlined, size: 18, color: WarnaAplikasi.textGrayGreen),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Edit Aktivitas',
                ),
                const SizedBox(width: 14),
                IconButton(
                  onPressed: () => _confirmDelete(item),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: WarnaAplikasi.errorRedBright),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Hapus Aktivitas',
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
                    color: WarnaAplikasi.outlineGray,
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
                trailing: _selectedSort == 'Terbaru' ? const Icon(Icons.check_circle_rounded, color: WarnaAplikasi.primary) : null,
                onTap: () {
                  setState(() => _selectedSort = 'Terbaru');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Terlama', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                trailing: _selectedSort == 'Terlama' ? const Icon(Icons.check_circle_rounded, color: WarnaAplikasi.primary) : null,
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
                        color: WarnaAplikasi.outlineGray,
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
                              ? WarnaAplikasi.bgSuccessLight
                              : WarnaAplikasi.statusTempoBg,
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
                    item.cropName.isNotEmpty ? item.cropName : item.location,
                    style: const TextStyle(
                      fontSize: 13,
                      color: WarnaAplikasi.textGrayGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Information Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: WarnaAplikasi.bgInput,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: WarnaAplikasi.borderPale),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(Icons.calendar_today_outlined, 'Tanggal', item.date),
                        const SizedBox(height: 10),
                        _buildDetailRow(Icons.access_time_rounded, 'Waktu Pelaksanaan', item.time),
                        const SizedBox(height: 10),
                        _buildDetailRow(Icons.holiday_village_outlined, 'Petak Lahan', item.location),
                        if (item.blockArea.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _buildDetailRow(Icons.crop_free_rounded, 'Luas & Komoditas', item.blockArea),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Catatan Kegiatan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: WarnaAplikasi.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.notes.isNotEmpty ? item.notes : 'Tidak ada catatan tambahan.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: WarnaAplikasi.textGrayDark,
                      height: 1.4,
                    ),
                  ),
                  if (item.imageUrl != null && item.imageUrl!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Dokumentasi Foto',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: WarnaAplikasi.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        item.imageUrl!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image)),
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
                            _confirmDelete(item);
                          },
                          icon: const Icon(Icons.delete_outline, size: 16, color: WarnaAplikasi.errorRedBright),
                          label: const Text('Hapus', style: TextStyle(color: WarnaAplikasi.errorRedBright)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _navigateToEditActivity(item);
                          },
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WarnaAplikasi.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: WarnaAplikasi.primary),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: WarnaAplikasi.textGrayGreen),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: WarnaAplikasi.primaryDark),
        ),
      ],
    );
  }
}
