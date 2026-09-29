import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';
import '../../widgets/status_badge.dart';
import 'edit_lahan_screen.dart';

class DetailLahanScreen extends StatelessWidget {
  const DetailLahanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'Detail Lahan',
              isBackButton: true,
              showProfile: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroCard(),
                    const SizedBox(height: 16),
                    _buildQuickStats(),
                    const SizedBox(height: 24),
                    _buildSpesifikasi(),
                    const SizedBox(height: 24),
                    _buildDokumentasi(),
                    const SizedBox(height: 24),
                    _buildRiwayat(),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: 'Catat Aktivitas',
                        icon: LucideIcons.plus,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: 'Edit Informasi Lahan',
                        icon: LucideIcons.pencil,
                        isPrimary: false,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditLahanScreen(
                                namaLahan: 'Petak Sawah Barat (Blok A)',
                                idLahan: 'LHN-SKM-04',
                                luas: '0,8',
                                alamat: 'Desa Sukamaju, Dusun Krajan, RT 02/RW 01',
                                komoditas: 'Padi Ciherang (Unggul Nasional)',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: 'Hapus Lahan',
                        icon: LucideIcons.trash2,
                        isPrimary: false,
                        textColor: AppColors.danger,
                        onPressed: () => _showDeleteDialog(context),
                      ),
                    ),
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

  void _showDeleteDialog(BuildContext context) {
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
                'Hapus Petak Sawah Ini?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Apakah Anda yakin ingin menghapus data lahan Petak Sawah Barat (Blok A)? Tindakan ini tidak dapat dibatalkan.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context); // back to list
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

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: NetworkImage('https://picsum.photos/seed/sawah1/600/400'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.8),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: StatusBadge(
                label: 'Aktif Ditanami',
                color: AppColors.primary,
                backgroundColor: AppColors.white.withOpacity(0.9),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PETAK SAWAH',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.lightGreen,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Petak Sawah Barat (Blok A)',
                  style: AppTextStyles.sectionTitle.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(LucideIcons.arrowDownToLine, size: 14, color: AppColors.white),
                    const SizedBox(width: 4),
                    Text('0.8 Ha', style: AppTextStyles.caption.copyWith(color: AppColors.white)),
                    const SizedBox(width: 16),
                    const Icon(LucideIcons.leaf, size: 14, color: AppColors.white),
                    const SizedBox(width: 4),
                    Text('Padi Ciherang', style: AppTextStyles.caption.copyWith(color: AppColors.white)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _buildStatCard(LucideIcons.maximize, 'Luas Lahan', '0,8 Ha'),
        _buildStatCard(LucideIcons.leaf, 'Komoditas', 'Padi Ciherang'),
        _buildStatCard(LucideIcons.calendar, 'Musim Tanam', 'MT-1 (Musim Huj...'),
        _buildStatCard(LucideIcons.clock, 'Estimasi Panen', '10 Feb 2025'),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.greenSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpesifikasi() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Spesifikasi Petak', style: AppTextStyles.cardTitle),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(LucideIcons.mapPin, color: AppColors.textMuted, size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lokasi', style: AppTextStyles.caption),
                  const SizedBox(height: 2),
                  Text('Dusun Krajan, RT 02/RW 01,\nDesa Sukamaju', style: AppTextStyles.secondary.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Luas', style: AppTextStyles.caption),
                  const SizedBox(height: 2),
                  Text('0,8 Ha', style: AppTextStyles.secondary.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.lightBorder),
          ),
          Row(
            children: [
              const Icon(LucideIcons.droplets, color: AppColors.info, size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sumber Irigasi', style: AppTextStyles.caption),
                  const SizedBox(height: 2),
                  Text('Sekunder', style: AppTextStyles.secondary.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tanggal Tanam', style: AppTextStyles.caption),
                  const SizedBox(height: 2),
                  Text('15 Okt 2024', style: AppTextStyles.secondary.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDokumentasi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Dokumentasi Petak', style: AppTextStyles.cardTitle),
            Text('+ Tambah Foto', style: AppTextStyles.secondary.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network('https://picsum.photos/seed/sawah4/200', height: 100, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network('https://picsum.photos/seed/sawah5/200', height: 100, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  color: AppColors.greenSurface,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.image, color: AppColors.primary),
                    const SizedBox(height: 4),
                    Text('Lihat Semua', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    Text('(2 Foto)', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontSize: 10)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRiwayat() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Riwayat Terkini', style: AppTextStyles.cardTitle),
              Text('Lihat Semua', style: AppTextStyles.secondary.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          _buildRiwayatItem(LucideIcons.box, 'Pemupukan', '12 Nov 2024 • 120 kg/Ha'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.lightBorder),
          ),
          _buildRiwayatItem(LucideIcons.droplet, 'Penyemprotan', '04 Nov 2024 • Pencegahan Hama'),
        ],
      ),
    );
  }

  Widget _buildRiwayatItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.greenSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.caption),
            ],
          ),
        ),
        const Icon(LucideIcons.chevronRight, color: AppColors.textMuted, size: 20),
      ],
    );
  }
}
