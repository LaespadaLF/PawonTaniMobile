import 'package:flutter/material.dart';
import 'package:pawon_mobile/core/network/api_response.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/features/aktivitas/screens/layar_catat_aktivitas.dart';
import 'package:pawon_mobile/features/artikel/models/item_artikel.dart';
import 'package:pawon_mobile/features/auth/repositories/auth_repository.dart';
import 'package:pawon_mobile/features/beranda/models/beranda_ringkasan_model.dart';
import 'package:pawon_mobile/features/beranda/services/beranda_api_service.dart';
import 'package:pawon_mobile/features/beranda/widgets/aksi_cepat_beranda.dart';
import 'package:pawon_mobile/features/beranda/widgets/bagian_artikel_beranda.dart';
import 'package:pawon_mobile/features/beranda/widgets/bagian_panen_terbaru_beranda.dart';
import 'package:pawon_mobile/features/beranda/widgets/kartu_banner_petani.dart';
import 'package:pawon_mobile/features/beranda/widgets/kartu_statistik_beranda.dart';
import 'package:pawon_mobile/features/lahan/screens/layar_tambah_lahan.dart';
import 'package:pawon_mobile/features/panen/models/item_panen.dart';
import 'package:pawon_mobile/features/panen/screens/layar_catat_panen.dart';
import 'package:pawon_mobile/features/panen/screens/layar_detail_panen.dart';
import 'package:pawon_mobile/features/panen/services/panen_api_service.dart';
import 'package:pawon_mobile/features/profile/screens/layar_profil.dart';
import 'package:pawon_mobile/features/notifikasi/screens/layar_notifikasi.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const HomeScreen({
    super.key,
    this.onNavigateTab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BerandaApiService _apiService = BerandaApiService();
  final PanenApiService _panenApiService = PanenApiService();
  BerandaRingkasanModel? _data;
  HarvestItem? _latestHarvest;
  bool _isLoading = true;
  bool _isLoadingHarvest = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBerandaData();
  }

  Future<void> _loadBerandaData() async {
    setState(() {
      _isLoading = true;
      _isLoadingHarvest = true;
      _errorMessage = null;
    });

    final berandaFuture = _apiService.getRingkasan();
    final panenFuture = _panenApiService.getPanenList();

    final results = await Future.wait([berandaFuture, panenFuture]);
    final res = results[0] as ApiResponse<BerandaRingkasanModel>;
    final panenRes = results[1] as ApiResponse<List<HarvestItem>>;

    if (!mounted) return;

    setState(() {
      if (res.success && res.data != null) {
        _data = res.data;
      } else {
        _errorMessage = res.message;
      }
      _isLoading = false;

      if (panenRes.success && panenRes.data != null && panenRes.data!.isNotEmpty) {
        _latestHarvest = panenRes.data!.first;
      } else {
        _latestHarvest = null;
      }
      _isLoadingHarvest = false;
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'Selamat pagi,';
    if (hour >= 11 && hour < 15) return 'Selamat siang,';
    if (hour >= 15 && hour < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthRepository().currentUser;
    final userName = _data?.user.nama ?? currentUser?.nama ?? 'Petani';

    return Scaffold(
      backgroundColor: WarnaAplikasi.primaryBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadBerandaData,
          color: WarnaAplikasi.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Header: Greeting, Notification, Avatar
                _buildTopHeader(context, userName),
                const SizedBox(height: 16),

                // 2. Banner: Semangat Bertani + Cuaca Realtime
                FarmerBannerCard(
                  cuaca: _data?.cuaca,
                  onTap: () {
                    _showWeatherDetailModal(context, _data?.cuaca);
                  },
                ),
                const SizedBox(height: 20),

                // 3. Ringkasan Pertanian (2x2 Grid Lahan, Komoditas, Aktivitas)
                HomeFarmSummarySection(
                  statistik: _data?.statistik,
                  onDetailTap: () => widget.onNavigateTab?.call(1),
                  onLahanTap: () => widget.onNavigateTab?.call(1),
                  onKomoditasTap: () => widget.onNavigateTab?.call(1),
                  onPanenTap: () => widget.onNavigateTab?.call(3),
                  onPenjualanTap: () => widget.onNavigateTab?.call(2), // Buka Aktivitas
                  onKondisiTap: () => _showConditionDetailModal(context),
                ),
                const SizedBox(height: 20),

                // 4. Aksi Cepat
                HomeQuickActionsSection(
                  onAllTap: () => _showQuickActionsModal(context),
                  onTambahLahan: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AddLandScreen(),
                      ),
                    ).then((value) {
                      if (value != null) _loadBerandaData();
                    });
                  },
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
                            _loadBerandaData();
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
                            _loadBerandaData();
                          },
                        ),
                      ),
                    );
                  },
                  onPenjualan: () => widget.onNavigateTab?.call(4),
                ),
                const SizedBox(height: 20),

                // 5. Informasi & Panduan Pertanian
                HomeArticlesSection(
                  onAllTap: () => widget.onNavigateTab?.call(5),
                  onArticleTap: (article) => _showArticleDetail(context, article),
                ),
                const SizedBox(height: 20),

                // 6. Hasil Panen Terbaru
                HomeLatestHarvestSection(
                  item: _latestHarvest,
                  isLoading: _isLoadingHarvest,
                  onAllTap: () => widget.onNavigateTab?.call(3),
                  onItemTap: (harvest) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HarvestDetailScreen(
                          item: harvest,
                          onUpdate: (_) => _loadBerandaData(),
                          onDelete: () => _loadBerandaData(),
                        ),
                      ),
                    );
                  },
                  onAddTap: () async {
                    final newItem = await Navigator.push<HarvestItem>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RecordHarvestScreen(),
                      ),
                    );
                    if (newItem != null) {
                      _loadBerandaData();
                    }
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, String name) {
    final firstName = name.trim().split(' ').first;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Greeting & Name
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: WarnaAplikasi.textGray,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Pak $firstName 👋',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: WarnaAplikasi.primaryDark,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Action Icons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Notification Button with Badge
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LayarNotifikasi(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: WarnaAplikasi.bgPaleGreen2,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      size: 20,
                      color: WarnaAplikasi.primaryDark,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: WarnaAplikasi.errorRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Profile Avatar Button
            InkWell(
              onTap: () => _showProfileModal(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: WarnaAplikasi.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    firstName.isNotEmpty ? firstName[0].toUpperCase() : 'P',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showWeatherDetailModal(BuildContext context, BerandaCuacaModel? cuaca) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final suhu = cuaca != null ? '${cuaca.suhu}°C' : '28°C';
        final kondisi = cuaca?.kondisi ?? 'Cerah Berawan';
        final lokasi = cuaca?.lokasi ?? 'Jember, Jawa Timur';
        final kelembapan = cuaca?.kelembapan ?? 80;
        final angin = cuaca?.kecepatanAngin ?? 4.0;
        final hujan = cuaca?.peluangHujan ?? 20;

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
                    color: WarnaAplikasi.borderPale,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cuaca di $lokasi',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: WarnaAplikasi.primaryDark,
                    ),
                  ),
                  Text(
                    suhu,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: WarnaAplikasi.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '$kondisi · Sangat baik untuk monitoring lahan dan pemupukan.',
                style: const TextStyle(
                  fontSize: 13,
                  color: WarnaAplikasi.textGray,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: WarnaAplikasi.greenLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildWeatherMiniParam('💧 Lembap', '$kelembapan%'),
                    _buildWeatherMiniParam('💨 Angin', '$angin km/h'),
                    _buildWeatherMiniParam('🌧 Hujan', '$hujan%'),
                  ],
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
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeatherMiniParam(String label, String val) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: WarnaAplikasi.textGray)),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark)),
      ],
    );
  }

  void _showConditionDetailModal(BuildContext context) {
    final stat = _data?.statistik;

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
                    color: WarnaAplikasi.borderPale,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Status Lahan Pertanian',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: WarnaAplikasi.primaryDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Saat ini Anda memiliki ${stat?.lahanAktif ?? 0} petak lahan yang aktif ditanami dari total ${stat?.totalLahan ?? 0} lahan terdaftar.',
                style: const TextStyle(fontSize: 13.5, color: WarnaAplikasi.textGray, height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WarnaAplikasi.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    color: WarnaAplikasi.borderPale,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text('Notifikasi Terkini', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark)),
              const SizedBox(height: 14),
              _buildNotifItem('Lahan Sawah Barat disetujui oleh Pengurus', '10 menit yang lalu'),
              const SizedBox(height: 10),
              _buildNotifItem('Peringatan cuaca hujan lebat esok hari', '1 jam yang lalu'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotifItem(String title, String time) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: WarnaAplikasi.greenLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: WarnaAplikasi.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: WarnaAplikasi.primaryDark)),
                const SizedBox(height: 2),
                Text(time, style: const TextStyle(fontSize: 11, color: WarnaAplikasi.textGray)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileModal(BuildContext context) {
    final user = AuthRepository().currentUser;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: WarnaAplikasi.borderPale,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: WarnaAplikasi.primary,
                    child: Text(
                      (user?.nama.isNotEmpty == true) ? user!.nama[0].toUpperCase() : 'P',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(user?.nama ?? 'Petani', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark)),
                  Text(user?.role ?? 'Anggota Kelompok Tani', style: const TextStyle(fontSize: 12, color: WarnaAplikasi.textGray)),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        ).then((_) => _loadBerandaData());
                      },
                      icon: const Icon(Icons.person_rounded, size: 18, color: Colors.white),
                      label: const Text('Lihat Profil Lengkap', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WarnaAplikasi.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await AuthRepository().logout();
                      },
                      icon: const Icon(Icons.logout_rounded, size: 18, color: WarnaAplikasi.errorRed),
                      label: const Text('Keluar dari Akun', style: TextStyle(color: WarnaAplikasi.errorRed, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: WarnaAplikasi.errorRed),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Menu Aksi Cepat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.add_location_alt_outlined, color: WarnaAplikasi.primary),
              title: const Text('Tambah Lahan Baru'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddLandScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_calendar_outlined, color: WarnaAplikasi.primary),
              title: const Text('Catat Aktivitas Tanam'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => RecordActivityScreen(onSave: (_) {})));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showArticleDetail(BuildContext context, ArticleItem article) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(article.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark)),
            const SizedBox(height: 8),
            Text(article.category, style: const TextStyle(fontSize: 12, color: WarnaAplikasi.primary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text(article.summary ?? 'Panduan pertanian praktis untuk petani.', style: const TextStyle(fontSize: 13, color: WarnaAplikasi.textGray)),
          ],
        ),
      ),
    );
  }

  void _showLatestHarvestDetail(BuildContext context) {
    widget.onNavigateTab?.call(3);
  }
}
