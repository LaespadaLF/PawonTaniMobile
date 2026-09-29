import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:flutter/material.dart';
import 'package:pawon_mobile/features/artikel/models/item_artikel.dart';
import 'package:pawon_mobile/features/beranda/widgets/kartu_banner_petani.dart';
import 'package:pawon_mobile/features/beranda/widgets/kartu_statistik_beranda.dart';
import 'package:pawon_mobile/features/beranda/widgets/kartu_cuaca_beranda.dart';
import 'package:pawon_mobile/features/beranda/widgets/aksi_cepat_beranda.dart';
import 'package:pawon_mobile/features/beranda/widgets/bagian_artikel_beranda.dart';
import 'package:pawon_mobile/features/beranda/widgets/bagian_panen_terbaru_beranda.dart';
import 'package:pawon_mobile/features/panen/screens/layar_catat_panen.dart';
import 'package:pawon_mobile/features/aktivitas/screens/layar_catat_aktivitas.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<int>? onNavigateTab;

  const HomeScreen({
    super.key,
    this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarnaAplikasi.primaryBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header: Greeting, Notification, Avatar
              _buildTopHeader(context),
              const SizedBox(height: 16),

              // 2. Banner: Semangat Bertani
              FarmerBannerCard(
                onTap: () {
                  _showBannerInfoModal(context);
                },
              ),
              const SizedBox(height: 20),

              // 3. Ringkasan Pertanian (2x2 Grid + Kondisi Pertanian)
              HomeFarmSummarySection(
                onDetailTap: () => onNavigateTab?.call(1),
                onLahanTap: () => onNavigateTab?.call(1),
                onKomoditasTap: () => onNavigateTab?.call(1),
                onPanenTap: () => onNavigateTab?.call(3),
                onPenjualanTap: () => onNavigateTab?.call(4),
                onKondisiTap: () => _showConditionDetailModal(context),
              ),
              const SizedBox(height: 20),

              // 4. Cuaca Hari Ini Card
              HomeWeatherCard(
                onTap: () => _showWeatherDetailModal(context),
              ),
              const SizedBox(height: 20),

              // 5. Aksi Cepat
              HomeQuickActionsSection(
                onAllTap: () => _showQuickActionsModal(context),
                onTambahLahan: () => _showQuickActionMessage(context, 'Tambah Lahan'),
                onCatatAktivitas: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RecordActivityScreen(
                        onSave: (newItem) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Aktivitas ${newItem.title} berhasil dicatat!'),
                              backgroundColor: WarnaAplikasi.primary,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
                onCatatPanen: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RecordHarvestScreen(
                        onSave: (newItem) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Hasil panen ${newItem.title} berhasil dicatat!'),
                              backgroundColor: WarnaAplikasi.primary,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
                onPenjualan: () => onNavigateTab?.call(4),
              ),
              const SizedBox(height: 20),

              // 6. Informasi & Panduan Pertanian
              HomeArticlesSection(
                onAllTap: () => onNavigateTab?.call(5), // Edukasi
                onArticleTap: (article) => _showArticleDetail(context, article),
              ),
              const SizedBox(height: 20),

              // 7. Hasil Panen Terbaru
              HomeLatestHarvestSection(
                onAllTap: () => onNavigateTab?.call(1), // Data Panen
                onItemTap: () => _showLatestHarvestDetail(context),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Greeting & Name
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Selamat pagi,',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: WarnaAplikasi.textGray,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Pak Joko 👋',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: WarnaAplikasi.primaryDark,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),

        // Action Icons: Notification & Profile
        Row(
          children: [
            // Notification Button with Badge '2'
            InkWell(
              onTap: () => _showNotificationsModal(context),
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE8EFEA),
                    width: 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(
                        Icons.notifications_none_rounded,
                        color: Color(0xFF283A2E),
                        size: 22,
                      ),
                    ),
                    // Red Notification Badge '2'
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(3.5),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: const Center(
                          child: Text(
                            '2',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Profile Avatar
            InkWell(
              onTap: () => _showProfileModal(context),
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE8EFEA),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  'https://images.unsplash.com/photo-1544717305-2782549b5136?w=150&auto=format&fit=crop&q=80',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: WarnaAplikasi.primary,
                      child: const Center(
                        child: Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Interactive Modals & Details ---

  void _showBannerInfoModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 18),
              const Text(
                'Semangat Bertani Bersama PawonTani',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: WarnaAplikasi.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'PawonTani mempermudah pengelolaan data pertanian, pencatatan jadwal pemupukan, pemantauan panen, dan koneksi langsung ke pasar penjualan secara terintegrasi.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: WarnaAplikasi.textGray,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WarnaAplikasi.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Mengerti', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConditionDetailModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F6EA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.spa_rounded, color: WarnaAplikasi.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Kondisi Lahan: Aman',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: WarnaAplikasi.primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                '• Pemupukan terakhir: 2 jam yang lalu (NPK Phonska)\n'
                '• Kelembaban tanah: 68% (Ideal)\n'
                '• Status pengairan: Cukup terairi\n'
                '• Pengecekan hama berikutnya: Besok pukul 08:00 WIB',
                style: TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF435A4B),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WarnaAplikasi.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWeatherDetailModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 18),
              const Text(
                'Prakiraan Cuaca Lahan Sukamaju',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: WarnaAplikasi.primaryDark,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Suhu rata-rata 28°C dengan kondisi cerah berawan. Sangat baik untuk proses penjemuran gabah atau penyemprotan pupuk daun di pagi hari.',
                style: TextStyle(fontSize: 13.5, color: WarnaAplikasi.textGray, height: 1.45),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WarnaAplikasi.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNotificationsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Notifikasi Pertanian',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: WarnaAplikasi.primaryDark,
                    ),
                  ),
                  Text(
                    '2 Baru',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: WarnaAplikasi.greenLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.water_drop_outlined, color: WarnaAplikasi.primary),
                ),
                title: const Text(
                  'Jadwal Pemupukan Lahan Barat',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
                subtitle: const Text(
                  'Pemupukan tahap 2 telah tercatat 2 jam yang lalu.',
                  style: TextStyle(fontSize: 12, color: WarnaAplikasi.textGray),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.monetization_on_outlined, color: WarnaAplikasi.warningOrange),
                ),
                title: const Text(
                  'Update Harga Cabai Merah',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
                subtitle: const Text(
                  'Harga cabai merah naik 5% di Pasar Induk regional.',
                  style: TextStyle(fontSize: 12, color: WarnaAplikasi.textGray),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WarnaAplikasi.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProfileModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 18),
              const CircleAvatar(
                radius: 36,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1544717305-2782549b5136?w=150&auto=format&fit=crop&q=80'),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pak Joko Widodo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: WarnaAplikasi.primaryDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Petani Utama • Poktan Sukamaju',
                style: TextStyle(fontSize: 13, color: WarnaAplikasi.textGray),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WarnaAplikasi.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Selesai', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQuickActionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 18),
              const Text(
                'Semua Aksi Cepat',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: WarnaAplikasi.primaryDark,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.add_location_alt_outlined, color: WarnaAplikasi.primary),
                title: const Text('Tambah Petak Lahan Baru'),
                onTap: () {
                  Navigator.pop(context);
                  _showQuickActionMessage(context, 'Tambah Lahan');
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_calendar_outlined, color: WarnaAplikasi.primary),
                title: const Text('Catat Jadwal Pemupukan & Penyiraman'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RecordActivityScreen(
                        onSave: (newItem) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Aktivitas ${newItem.title} berhasil dicatat!'),
                              backgroundColor: WarnaAplikasi.primary,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.agriculture_rounded, color: WarnaAplikasi.primary),
                title: const Text('Catat Hasil Panen Baru'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RecordHarvestScreen(
                        onSave: (newItem) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Hasil panen ${newItem.title} berhasil dicatat!'),
                              backgroundColor: WarnaAplikasi.primary,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.storefront_outlined, color: WarnaAplikasi.primary),
                title: const Text('Buka Menu Penjualan & Kemitraan'),
                onTap: () {
                  Navigator.pop(context);
                  onNavigateTab?.call(4);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQuickActionMessage(BuildContext context, String actionName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Membuka formulir: $actionName'),
        backgroundColor: WarnaAplikasi.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showArticleDetail(BuildContext context, ArticleItem article) {
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
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
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
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: WarnaAplikasi.greenLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      article.category,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: WarnaAplikasi.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: WarnaAplikasi.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF718679)),
                      const SizedBox(width: 4),
                      Text(
                        article.readTime,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF718679)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    article.summary ??
                        'Informasi dan panduan teknis mendalam mengenai budidaya pertanian terbaik untuk memaksimalkan hasil panen secara optimal.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF435A4B),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WarnaAplikasi.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Tutup Artikel', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLatestHarvestDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Cabai Merah',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: WarnaAplikasi.primaryDark,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F6EA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Siap dijual',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: WarnaAplikasi.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                '• Total Hasil: 500 kg\n'
                '• Lokasi Panen: Petak Cabai Blok B\n'
                '• Kualitas: Grade A Super Segar\n'
                '• Estimasi Nilai Jual: Rp17.500.000',
                style: TextStyle(fontSize: 13.5, color: Color(0xFF435A4B), height: 1.6),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WarnaAplikasi.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

