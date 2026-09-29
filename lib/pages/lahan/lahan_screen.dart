import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_header.dart';
import 'tambah_lahan_screen.dart';
import 'detail_lahan_screen.dart';
import 'edit_lahan_screen.dart';

class LahanScreen extends StatefulWidget {
  const LahanScreen({super.key});

  @override
  State<LahanScreen> createState() => _LahanScreenState();
}

class _LahanScreenState extends State<LahanScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['Semua', 'Aktif Ditanami', 'Masa Olah Tanah'];

  final List<Map<String, dynamic>> _lahanList = [
    {
      'id': 'LHN-SKM-01',
      'title': 'Petak Sawah Barat (Blok A)',
      'location': 'Sukamaju, RT 02/RW 01',
      'size': '0,8 Ha',
      'commodity': 'Padi Ciherang',
      'status': 'Aktif Ditanami',
      'statusColor': Color(0xFF2F6F3E),
      'statusBg': Color(0xFFE5F2E8),
      'imageUrl': 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=300',
    },
    {
      'id': 'LHN-SKM-02',
      'title': 'Kebun Jagung Lereng (Blok C)',
      'location': 'Bukit Sukamaju, Lereng Selatan',
      'size': '0,6 Ha',
      'commodity': 'Jagung Hibrida',
      'status': 'Dalam Proses',
      'statusColor': Color(0xFFD97706),
      'statusBg': Color(0xFFFEF3C7),
      'imageUrl': 'https://images.unsplash.com/photo-1523348837708-15d4a09cfac2?w=300',
    },
    {
      'id': 'LHN-SKM-03',
      'title': 'Petak Sawah Timur (Blok B)',
      'location': 'Dusun Sukasari, Area Irigasi',
      'size': '0,4 Ha',
      'commodity': 'Padi Ciherang',
      'status': 'Aktif Ditanami',
      'statusColor': Color(0xFF2F6F3E),
      'statusBg': Color(0xFFE5F2E8),
      'imageUrl': 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=300',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'PawonTani',
              showProfile: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Data Lahan',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Kelola petak sawah dan kebun garapanmu.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildStatCards(),
                    const SizedBox(height: 18),
                    _buildTambahButton(),
                    const SizedBox(height: 18),
                    _buildFilters(),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Lahan Saya',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Row(
                              children: [
                                Text(
                                  'Terbaru',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textSecondary),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ..._buildFilteredCards(),
                    const SizedBox(height: 16),
                    _buildSebaranLokasi(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Stat Cards ──────────────────────────────────────────────
  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2EFE5), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCEFE1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.sprout, color: Color(0xFF2F6F3E), size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Luas',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '1,8 Ha',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2EFE5), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCEFE1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.leaf, color: Color(0xFF2F6F3E), size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Petak',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '3',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Tambah Lahan Baru Button ────────────────────────────────
  Widget _buildTambahButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahLahanScreen()),
          );
        },
        icon: const Icon(LucideIcons.plus, size: 20),
        label: const Text(
          'Tambah Lahan Baru',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B7A4C),
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: const Color(0xFF3B7A4C).withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
      ),
    );
  }

  // ── Filter Chips ────────────────────────────────────────────
  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.asMap().entries.map((entry) {
          final isSelected = entry.key == _selectedFilter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = entry.key),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2F6F3E) : const Color(0xFFEFF5F1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                entry.value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF4A5568),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── List of Lahan Cards ─────────────────────────────────────
  List<Widget> _buildFilteredCards() {
    final list = _lahanList.where((lahan) {
      if (_selectedFilter == 1) return lahan['status'] == 'Aktif Ditanami';
      if (_selectedFilter == 2) return lahan['status'] == 'Masa Olah Tanah';
      return true;
    }).toList();

    return list.map((lahan) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _buildLahanCard(lahan),
      );
    }).toList();
  }

  Widget _buildLahanCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EAF0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  data['imageUrl'],
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 90,
                    height: 90,
                    color: const Color(0xFFE5F2E8),
                    child: const Icon(LucideIcons.image, color: AppColors.primary, size: 30),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: data['statusBg'],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: data['statusColor'],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            data['status'],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: data['statusColor'],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Title
                    Text(
                      data['title'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Location
                    Row(
                      children: [
                        const Icon(LucideIcons.mapPin, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            data['location'],
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Meta row
                    Row(
                      children: [
                        const Icon(LucideIcons.sunMedium, size: 13, color: Color(0xFF2F6F3E)),
                        const SizedBox(width: 4),
                        Text(
                          data['size'],
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        const SizedBox(width: 12),
                        const Icon(LucideIcons.sprout, size: 13, color: Color(0xFF2F6F3E)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            data['commodity'],
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Lihat Detail Button
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DetailLahanScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF7F2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'Lihat Detail',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2F6F3E),
                        ),
                      ),
                      SizedBox(width: 3),
                      Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF2F6F3E)),
                    ],
                  ),
                ),
              ),
              // Edit & Delete icons
              Row(
                children: [
                  // EDIT BUTTON -> Opens EditLahanScreen
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditLahanScreen(
                            namaLahan: data['title'],
                            idLahan: data['id'],
                            luas: data['size'].replaceAll(' Ha', ''),
                            alamat: data['location'],
                            komoditas: data['commodity'],
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: const Icon(LucideIcons.pencil, size: 17, color: Color(0xFF7A8B9E)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // DELETE BUTTON -> Shows Confirmation Dialog
                  InkWell(
                    onTap: () => _showDeleteDialog(data['title']),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: const Icon(LucideIcons.trash2, size: 17, color: Color(0xFFFF5C6C)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Sebaran Lokasi Lahan ─────────────────────────────────────
  Widget _buildSebaranLokasi() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EAF0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.map, size: 18, color: Color(0xFF2F6F3E)),
                  SizedBox(width: 8),
                  Text(
                    'Sebaran Lokasi Lahan',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Text(
                '3 Petak',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Map illustration
          Container(
            height: 90,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFDCEEE3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFC7E4D1)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(double.infinity, 90),
                  painter: _MiniMapPainter(),
                ),
                // Node 1
                const Positioned(
                  left: 40,
                  top: 35,
                  child: _MapNodeDot(),
                ),
                // Node 2
                const Positioned(
                  left: 120,
                  top: 45,
                  child: _MapNodeDot(),
                ),
                // Node 3
                const Positioned(
                  left: 200,
                  top: 25,
                  child: _MapNodeDot(),
                ),
                // Lihat Peta Button
                Positioned(
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Lihat Peta',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F6F3E),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String title) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.trash2, color: Color(0xFFFF5C6C), size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hapus Data Lahan Ini?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                  children: [
                    const TextSpan(text: 'Apakah Anda yakin ingin menghapus data lahan '),
                    TextSpan(
                      text: title,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const TextSpan(text: '? Tindakan ini tidak dapat dibatalkan.'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lahan $title berhasil dihapus'),
                        backgroundColor: const Color(0xFF2F6F3E),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5C6C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Ya, Hapus Data Lahan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal / Kembali', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapNodeDot extends StatelessWidget {
  const _MapNodeDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: const Color(0xFF2F6F3E).withValues(alpha: 0.25),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF2F6F3E),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final riverPaint = Paint()
      ..color = const Color(0xFFC3E3CF)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.6)
      ..cubicTo(size.width * 0.3, size.height * 0.3, size.width * 0.5, size.height * 0.7, size.width * 0.8, size.height * 0.4);

    canvas.drawPath(path, riverPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
