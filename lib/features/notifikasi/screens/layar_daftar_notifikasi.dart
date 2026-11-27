import 'package:flutter/material.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/features/lahan/screens/layar_detail_lahan.dart';
import 'package:pawon_mobile/features/lahan/services/lahan_api_service.dart';
import 'package:pawon_mobile/features/notifikasi/models/item_notifikasi.dart';
import 'package:pawon_mobile/features/notifikasi/repositories/notifikasi_repository.dart';
import 'package:pawon_mobile/features/notifikasi/widgets/kartu_item_notifikasi.dart';
import 'package:pawon_mobile/features/panen/screens/layar_detail_panen.dart';
import 'package:pawon_mobile/features/panen/services/panen_api_service.dart';

/// Halaman Daftar Notifikasi PawonTani Mobile.
/// Mendukung filter Semua/Belum Dibaca, infinite scroll pagination,
/// pull-to-refresh, tandai semua dibaca, serta deep linking ke modul Lahan, Siklus, dan Panen.
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotifikasiRepository _repository = NotifikasiRepository.instance;
  final ScrollController _scrollController = ScrollController();
  final LahanApiService _lahanApiService = LahanApiService();
  final PanenApiService _panenApiService = PanenApiService();

  bool _isNavigatingEntity = false;
  bool _isMarkingAll = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _repository.loadInitial();
      _repository.markAllAsRead();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _repository.loadNextPage();
    }
  }

  Future<void> _handleMarkAllRead() async {
    if (_isMarkingAll || _repository.unreadCount == 0) return;

    setState(() {
      _isMarkingAll = true;
    });

    final success = await _repository.markAllAsRead();

    if (!mounted) return;
    setState(() {
      _isMarkingAll = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua notifikasi ditandai sebagai dibaca.'),
          backgroundColor: WarnaAplikasi.primary,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menandai semua notifikasi. Periksa koneksi Anda.'),
          backgroundColor: WarnaAplikasi.errorRed,
        ),
      );
    }
  }

  Future<void> _handleNotificationTap(ItemNotifikasi item) async {
    // 1. Tandai sebagai dibaca
    if (!item.sudahDibaca) {
      _repository.markAsRead(item);
    }

    // 2. Jalankan Navigasi / Deep Link jika memiliki entitas target
    final entityType = item.entityType;
    final entityId = item.entityId;

    if (entityId == null || entityId.isEmpty) {
      _showSimpleDetailDialog(item);
      return;
    }

    if (_isNavigatingEntity) return;
    setState(() {
      _isNavigatingEntity = true;
    });

    try {
      if (entityType == 'lahan') {
        final lahanId = item.targetLahanId ?? entityId;
        final res = await _lahanApiService.getLahanDetail(lahanId);
        if (!mounted) return;

        if (res.success && res.data != null) {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LandDetailScreen(item: res.data!),
            ),
          );
          _repository.fetchUnreadCount();
        } else {
          _showErrorSnackBar(res.statusCode == 404
              ? 'Data lahan tidak ditemukan atau telah dihapus.'
              : res.statusCode == 403
                  ? 'Akses ditolak. Anda tidak berhak melihat lahan ini.'
                  : (res.message.isNotEmpty ? res.message : 'Gagal membuka detail lahan.'));
        }
      } else if (entityType == 'siklus_tanam') {
        // Siklus tanam selalu berada dalam konteks petak Lahan
        String? lahanId = item.targetLahanId;
        if (lahanId == null || lahanId.isEmpty) {
          // Ambil detail siklus terlebih dahulu untuk mendapatkan id_lahan
          final siklusRes = await _lahanApiService.getSiklusDetail(entityId);
          if (siklusRes.success && siklusRes.data != null) {
            lahanId = siklusRes.data!.idLahan;
          }
        }

        if (lahanId != null && lahanId.isNotEmpty) {
          final res = await _lahanApiService.getLahanDetail(lahanId);
          if (!mounted) return;

          if (res.success && res.data != null) {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LandDetailScreen(item: res.data!),
              ),
            );
            _repository.fetchUnreadCount();
          } else {
            _showErrorSnackBar(res.statusCode == 404
                ? 'Lahan terkait siklus tidak ditemukan atau telah dihapus.'
                : 'Gagal membuka detail lahan siklus.');
          }
        } else {
          _showErrorSnackBar('Informasi petak lahan untuk siklus ini tidak tersedia.');
        }
      } else if (entityType == 'panen') {
        final panenId = item.targetPanenId ?? entityId;
        final res = await _panenApiService.getPanenDetail(panenId);
        if (!mounted) return;

        if (res.success && res.data != null) {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => HarvestDetailScreen(
                item: res.data!,
                onUpdate: (_) {
                  _repository.fetchUnreadCount();
                },
                onDelete: () {
                  _repository.fetchUnreadCount();
                },
              ),
            ),
          );
          _repository.fetchUnreadCount();
        } else {
          _showErrorSnackBar(res.statusCode == 404
              ? 'Catatan panen tidak ditemukan atau telah dihapus.'
              : res.statusCode == 403
                  ? 'Akses ditolak. Anda tidak berhak melihat panen ini.'
                  : (res.message.isNotEmpty ? res.message : 'Gagal membuka detail panen.'));
        }
      } else {
        _showSimpleDetailDialog(item);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Terjadi gangguan saat membuka data: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isNavigatingEntity = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: WarnaAplikasi.errorRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSimpleDetailDialog(ItemNotifikasi item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            item.judul,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: WarnaAplikasi.primaryDark,
            ),
          ),
          content: Text(
            item.pesan,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF333333),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup', style: TextStyle(color: WarnaAplikasi.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarnaAplikasi.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: WarnaAplikasi.primaryDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: WarnaAplikasi.primaryDark,
          ),
        ),
        centerTitle: false,
        actions: [
          AnimatedBuilder(
            animation: _repository,
            builder: (context, _) {
              final unread = _repository.unreadCount;
              if (unread == 0) return const SizedBox.shrink();

              return TextButton.icon(
                onPressed: _isMarkingAll ? null : _handleMarkAllRead,
                icon: _isMarkingAll
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2, color: WarnaAplikasi.primary),
                      )
                    : const Icon(Icons.done_all_rounded, size: 16, color: WarnaAplikasi.primary),
                label: const Text(
                  'Tandai Dibaca',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: WarnaAplikasi.primary,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _buildFilterChip('semua', 'Semua'),
                const SizedBox(width: 8),
                _buildFilterChip('belum_dibaca', 'Belum Dibaca'),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _repository,
            builder: (context, _) {
              final status = _repository.status;
              final items = _repository.items;

              // 1. Initial Loading State
              if (status == NotifikasiLoadStatus.loading && items.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: WarnaAplikasi.primary),
                );
              }

              // 2. Error State
              if (status == NotifikasiLoadStatus.error && items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off_rounded, size: 48, color: WarnaAplikasi.textGray),
                        const SizedBox(height: 12),
                        Text(
                          _repository.errorMessage ?? 'Gagal memuat notifikasi.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13.5, color: WarnaAplikasi.textGray),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _repository.loadInitial(),
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Coba Lagi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WarnaAplikasi.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // 3. Empty State
              if (items.isEmpty) {
                final isUnreadFilter = _repository.activeFilter == 'belum_dibaca';
                return RefreshIndicator(
                  onRefresh: _repository.refresh,
                  color: WarnaAplikasi.primary,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                color: WarnaAplikasi.bgPaleGreen2,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications_none_rounded,
                                size: 32,
                                color: WarnaAplikasi.primary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              isUnreadFilter
                                  ? 'Tidak ada notifikasi belum dibaca'
                                  : 'Belum ada notifikasi',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: WarnaAplikasi.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isUnreadFilter
                                  ? 'Semua notifikasi Anda sudah dibaca.'
                                  : 'Aktivitas seputar lahan, siklus, dan panen akan muncul di sini.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: WarnaAplikasi.textGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              // 4. List Notifikasi dengan Pagination
              return RefreshIndicator(
                onRefresh: _repository.refresh,
                color: WarnaAplikasi.primary,
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: items.length + (_repository.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= items.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: WarnaAplikasi.primary),
                          ),
                        ),
                      );
                    }

                    final item = items[index];
                    return NotificationItemCard(
                      item: item,
                      onTap: () => _handleNotificationTap(item),
                    );
                  },
                ),
              );
            },
          ),

          // Loading Overlay saat membuka entitas target
          if (_isNavigatingEntity)
            Container(
              color: Colors.black.withAlpha(50),
              child: const Center(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: WarnaAplikasi.primary),
                        ),
                        SizedBox(width: 14),
                        Text(
                          'Membuka data...',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: WarnaAplikasi.primaryDark),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _repository.activeFilter == filterKey;

    return InkWell(
      onTap: () => _repository.switchFilter(filterKey),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? WarnaAplikasi.primary : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : WarnaAplikasi.textGray,
          ),
        ),
      ),
    );
  }
}
