import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/core/widgets/pawon_form_header.dart';
import 'package:pawon_mobile/features/aktivitas/models/item_aktivitas_tanam.dart';
import 'package:pawon_mobile/features/aktivitas/screens/layar_catat_aktivitas.dart';
import 'package:pawon_mobile/features/aktivitas/services/aktivitas_api_service.dart';
import 'package:pawon_mobile/features/lahan/models/item_lahan.dart';
import 'package:pawon_mobile/features/lahan/screens/layar_edit_lahan.dart';
import 'package:pawon_mobile/features/lahan/services/lahan_api_service.dart';

class LandDetailScreen extends StatefulWidget {
  final ItemLahan item;

  const LandDetailScreen({super.key, required this.item});

  @override
  State<LandDetailScreen> createState() => _LandDetailScreenState();
}

class _LandDetailScreenState extends State<LandDetailScreen> {
  late ItemLahan _item;
  bool _isFetching = false;
  bool _isMapInteractive = false;

  final AktivitasApiService _aktivitasService = AktivitasApiService();
  List<PlantActivityItem> _activities = [];
  bool _isLoadingActivities = true;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _fetchFreshDetail();
    _fetchLahanActivities();
  }

  Future<void> _fetchLahanActivities() async {
    setState(() => _isLoadingActivities = true);
    try {
      final res = await _aktivitasService.getAktivitasList(lahanId: _item.id);
      if (mounted) {
        setState(() {
          _activities = res.data ?? [];
          _isLoadingActivities = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingActivities = false);
    }
  }

  Future<void> _navigateToCatatAktivitas() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecordActivityScreen(
          initialLahanId: _item.id,
          initialLahanName: _item.nama,
        ),
      ),
    );

    if (res == true || res is PlantActivityItem) {
      _fetchLahanActivities();
    }
  }

  @override
  void didUpdateWidget(covariant LandDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item != widget.item) {
      _item = widget.item;
    }
  }

  Future<void> _fetchFreshDetail() async {
    if (_isFetching) return;
    _isFetching = true;
    try {
      final response = await LahanApiService().getLahanDetail(_item.id);
      if (mounted && response.success && response.data != null) {
        setState(() {
          _item = response.data!;
        });
      }
    } catch (_) {
      // Abaikan bila offline/error dalam background fetch
    } finally {
      if (mounted) {
        _isFetching = false;
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text('Hapus Lahan?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              ],
            ),
            content: Text('Yakin ingin menghapus lahan "${_item.nama}"? Data yang dihapus tidak bisa dikembalikan.', style: const TextStyle(fontSize: 13)),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ) ??
        false;

    if (mounted && confirmed) {
      try {
        final res = await LahanApiService().deleteLahan(_item.id);
        if (mounted) {
          if (res.success) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data lahan berhasil dihapus.')));
            Navigator.pop(context, 'delete');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message.isNotEmpty ? res.message : 'Gagal menghapus lahan.')));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
        }
      }
    }
  }

  Future<void> _navigateToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditLandScreen(item: _item)),
    );
    if (!mounted) return;
    if (result == 'delete') {
      Navigator.pop(context, 'delete');
    } else if (result is ItemLahan) {
      setState(() {
        _item = result;
      });
      _fetchFreshDetail();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAktif = _item.status == StatusLahan.aktif;
    final tagText = isAktif ? 'Aktif Ditanami' : (_item.status == StatusLahan.persiapan ? 'Dalam Proses' : 'Masa Olah Tanah');
    final tagColor = isAktif ? WarnaAplikasi.greenPill : WarnaAplikasi.warningOrangeBg;
    final tagTextColor = isAktif ? WarnaAplikasi.greenText : WarnaAplikasi.warningOrange;
    final dotColor = isAktif ? WarnaAplikasi.successGreen : WarnaAplikasi.hppAmberBg;

    return Scaffold(
      backgroundColor: WarnaAplikasi.primaryBackground,
      appBar: const PawonFormHeader(
        title: 'Detail Lahan',
        subtitle: 'Informasi lengkap petak garapan',
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchFreshDetail,
          color: WarnaAplikasi.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Header Card
                Container(
                  height: 220,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: WarnaAplikasi.greenLight,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        (_item.fotoLahan != null && _item.fotoLahan!.isNotEmpty)
                            ? _item.fotoLahan!
                            : 'https://images.unsplash.com/photo-1595246140625-573b715d11dc?w=600&q=80',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.network(
                          'https://images.unsplash.com/photo-1595246140625-573b715d11dc?w=600&q=80',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: tagColor, borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text(tagText, style: TextStyle(color: tagTextColor, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('PETAK SAWAH', style: TextStyle(color: WarnaAplikasi.accentGreen, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            const SizedBox(height: 4),
                            Text(_item.nama, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.arrow_downward, color: WarnaAplikasi.accentGreen, size: 14),
                                const SizedBox(width: 4),
                                Text('${_item.luas.toStringAsFixed(1).replaceAll('.', ',')} Ha', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                const SizedBox(width: 16),
                                const Icon(Icons.eco, color: WarnaAplikasi.accentGreen, size: 14),
                                const SizedBox(width: 4),
                                Text(_item.komoditas, style: const TextStyle(color: Colors.white, fontSize: 12)),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Kartu Status Verifikasi Pengurus/Ketua
                _buildVerificationStatusCard(),

                // Info Grid
                Row(
                  children: [
                    Expanded(child: _buildInfoGridCard(Icons.crop_square, 'Luas Lahan', '${_item.luas.toStringAsFixed(1).replaceAll('.', ',')} Ha')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildInfoGridCard(Icons.eco_outlined, 'Komoditas', _item.komoditas)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildInfoGridCard(Icons.calendar_today_outlined, 'Musim Tanam', (_item.musimTanam != null && _item.musimTanam!.isNotEmpty) ? _item.musimTanam! : '-')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildInfoGridCard(Icons.access_time, 'Estimasi Panen', '-')),
                  ],
                ),
                const SizedBox(height: 24),

                // Spesifikasi Petak
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: WarnaAplikasi.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Spesifikasi Petak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: WarnaAplikasi.primaryDark)),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined, color: WarnaAplikasi.textGrayLight, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Lokasi', style: TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayLight)),
                                const SizedBox(height: 4),
                                Text(_item.lokasi, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WarnaAplikasi.primaryDark, height: 1.4)),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 40, color: WarnaAplikasi.backgroundLight, margin: const EdgeInsets.symmetric(horizontal: 16)),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Luas', style: TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayLight)),
                                const SizedBox(height: 4),
                                Text('${_item.luas.toStringAsFixed(1).replaceAll('.', ',')} Ha', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WarnaAplikasi.primaryDark)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: WarnaAplikasi.backgroundLight, thickness: 1),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.water_drop_outlined, color: WarnaAplikasi.errorRedBright, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Sumber Irigasi', style: TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayLight)),
                                const SizedBox(height: 4),
                                const Text('-', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WarnaAplikasi.primaryDark)),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 40, color: WarnaAplikasi.backgroundLight, margin: const EdgeInsets.symmetric(horizontal: 16)),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Tanggal Tanam', style: TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayLight)),
                                const SizedBox(height: 4),
                                const Text('-', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WarnaAplikasi.primaryDark)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_item.keterangan != null && _item.keterangan!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: WarnaAplikasi.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.notes_rounded, color: WarnaAplikasi.primary, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Keterangan / Catatan Lahan',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: WarnaAplikasi.primaryDark),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _item.keterangan!,
                          style: const TextStyle(fontSize: 12, color: WarnaAplikasi.textGray, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Peta Lokasi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Peta Lokasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: WarnaAplikasi.primaryDark)),
                    Text(
                      'Lat: ${(_item.latitude ?? -6.5621).toStringAsFixed(6)}, Long: ${(_item.longitude ?? 107.7589).toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayLight),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: WarnaAplikasi.border),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(_item.latitude ?? -6.5621, _item.longitude ?? 107.7589),
                            initialZoom: 15,
                            interactionOptions: InteractionOptions(
                              flags: _isMapInteractive ? (InteractiveFlag.all & ~InteractiveFlag.rotate) : InteractiveFlag.none,
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
                                  width: 40,
                                  height: 40,
                                  point: LatLng(_item.latitude ?? -6.5621, _item.longitude ?? 107.7589),
                                  child: const Icon(Icons.location_on, color: WarnaAplikasi.primary, size: 40),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Map Interaction Toggle Badge
                        Positioned(
                          top: 8,
                          right: 8,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _isMapInteractive = !_isMapInteractive;
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _isMapInteractive ? WarnaAplikasi.primary : Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isMapInteractive ? Icons.lock_open_rounded : Icons.pan_tool_outlined,
                                    size: 14,
                                    color: _isMapInteractive ? Colors.white : WarnaAplikasi.primaryDark,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _isMapInteractive ? 'Mode geser aktif' : 'Ketuk untuk geser',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: _isMapInteractive ? Colors.white : WarnaAplikasi.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Dokumentasi Petak (Galeri Perkembangan & Aktivitas)
                _buildGaleriDokumentasiSection(),
                const SizedBox(height: 24),

                // Riwayat Terkini / Aktivitas
                _buildRiwayatAktivitasSection(),

                // Riwayat Verifikasi (Audit Trail Backend)
                _buildRiwayatVerifikasiList(),

                const SizedBox(height: 32),

                // Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _navigateToCatatAktivitas,
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    label: const Text('Catat Aktivitas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WarnaAplikasi.buttonDark,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _navigateToEdit,
                    icon: const Icon(Icons.edit_outlined, color: WarnaAplikasi.textDarkGreen, size: 18),
                    label: const Text('Edit Informasi Lahan', style: TextStyle(color: WarnaAplikasi.textDarkGreen, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: WarnaAplikasi.backgroundLight,
                      side: const BorderSide(color: WarnaAplikasi.backgroundLight),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                ),
                if (_item.isCanDelete) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _confirmDelete,
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                      label: const Text('Hapus Lahan', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: WarnaAplikasi.errorRedBg,
                        side: const BorderSide(color: WarnaAplikasi.errorRedBorder),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Dialog popup untuk melihat foto ukuran besar
  void _showImagePreviewDialog(String imageUrl, String title, String subtitle) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    color: Colors.black,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.black,
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.white70, size: 40),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      if (subtitle.isNotEmpty)
                        Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bagian Dokumentasi Petak: Galeri Foto Aktivitas & Foto Profil Lahan
  Widget _buildGaleriDokumentasiSection() {
    // Kumpulkan seluruh foto aktivitas yang memiliki foto
    final List<Map<String, dynamic>> fotoList = [];

    // 1. Foto Profil Utama Lahan (jika ada)
    if (_item.fotoLahan != null && _item.fotoLahan!.isNotEmpty) {
      fotoList.add({
        'url': _item.fotoLahan!,
        'title': 'Profil Petak',
        'subtitle': 'Foto Utama Lahan',
        'isMain': true,
      });
    }

    // 2. Kumpulan foto dari setiap aktivitas tanam
    for (final akt in _activities) {
      if (akt.imageUrl != null && akt.imageUrl!.isNotEmpty) {
        fotoList.add({
          'url': akt.imageUrl!,
          'title': akt.title,
          'subtitle': akt.date,
          'isMain': false,
          'item': akt,
        });
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Dokumentasi Petak',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: WarnaAplikasi.primaryDark),
                ),
                if (fotoList.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: WarnaAplikasi.greenLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${fotoList.length} Foto',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: WarnaAplikasi.primary),
                    ),
                  ),
                ],
              ],
            ),
            InkWell(
              onTap: _navigateToCatatAktivitas,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  '+ Tambah Foto',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WarnaAplikasi.primary),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (fotoList.isEmpty)
          InkWell(
            onTap: _navigateToCatatAktivitas,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: WarnaAplikasi.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: WarnaAplikasi.greenLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_a_photo_outlined, color: WarnaAplikasi.primary, size: 22),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Belum Ada Foto Dokumentasi',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ambil foto saat mencatat pemupukan, pengairan, atau kegiatan rawat petak.',
                    style: TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayLight),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _navigateToCatatAktivitas,
                    icon: const Icon(Icons.camera_alt_outlined, size: 14),
                    label: const Text('Ambil Foto Kegiatan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WarnaAplikasi.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 155,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: fotoList.length + 1, // +1 untuk kartu tambah cepat
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                // Kartu terakhir: tombol tambah cepat
                if (index == fotoList.length) {
                  return InkWell(
                    onTap: _navigateToCatatAktivitas,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 110,
                      decoration: BoxDecoration(
                        color: WarnaAplikasi.greenLight.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: WarnaAplikasi.borderField, style: BorderStyle.solid),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_circle_outline, color: WarnaAplikasi.primary, size: 26),
                          SizedBox(height: 6),
                          Text(
                            'Tambah\nFoto',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final foto = fotoList[index];
                final url = foto['url'] as String;
                final title = foto['title'] as String;
                final subtitle = foto['subtitle'] as String;
                final isMain = foto['isMain'] == true;

                return InkWell(
                  onTap: () => _showImagePreviewDialog(url, title, subtitle),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 140,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: WarnaAplikasi.border),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          url,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: WarnaAplikasi.primary),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: WarnaAplikasi.greenLight,
                            child: const Center(
                              child: Icon(Icons.broken_image, color: Colors.grey, size: 24),
                            ),
                          ),
                        ),
                        // Gradient Overlay & Info Bar
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.85),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  subtitle,
                                  style: const TextStyle(color: Colors.white70, fontSize: 9.5),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Badge jika foto profil lahan
                        if (isMain)
                          Positioned(
                            top: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: WarnaAplikasi.buttonDark,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('Foto Utama', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildRiwayatAktivitasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Riwayat Aktivitas',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: WarnaAplikasi.primaryDark),
            ),
            if (_activities.isNotEmpty)
              Text(
                '${_activities.length} Kegiatan',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WarnaAplikasi.primary),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoadingActivities)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: WarnaAplikasi.border),
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: WarnaAplikasi.primary),
              ),
            ),
          )
        else if (_activities.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: WarnaAplikasi.border),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_toggle_off_rounded, color: WarnaAplikasi.textGrayLight, size: 36),
                SizedBox(height: 8),
                Text(
                  'Belum Ada Riwayat Aktivitas',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark),
                ),
                SizedBox(height: 4),
                Text(
                  'Riwayat pemupukan, penyemprotan, dan perawatan petak ini akan tercatat di sini setelah Anda mencatat aktivitas.',
                  style: TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayLight),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Column(
            children: _activities.take(5).map((akt) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: WarnaAplikasi.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: WarnaAplikasi.greenLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.spa_rounded, color: WarnaAplikasi.primary, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                akt.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: WarnaAplikasi.primaryDark),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: akt.condition == PlantCondition.sehat ? WarnaAplikasi.bgSuccessLight : WarnaAplikasi.statusTempoBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  akt.condition.badgeText,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: akt.condition == PlantCondition.sehat ? WarnaAplikasi.primary : WarnaAplikasi.warningOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${akt.date} ${akt.time.isNotEmpty ? "• ${akt.time}" : ""}',
                            style: const TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayLight),
                          ),
                          if (akt.notes.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              akt.notes,
                              style: const TextStyle(fontSize: 11.5, color: WarnaAplikasi.textGrayDark),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildRiwayatVerifikasiList() {
    if (_item.riwayatVerifikasi.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Row(
          children: [
            Icon(Icons.history_edu_rounded, size: 18, color: WarnaAplikasi.primaryDark),
            SizedBox(width: 8),
            Text(
              'Riwayat Verifikasi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: WarnaAplikasi.primaryDark),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: WarnaAplikasi.border),
          ),
          child: Column(
            children: List.generate(_item.riwayatVerifikasi.length, (index) {
              final riwayat = _item.riwayatVerifikasi[index];
              final isLast = index == _item.riwayatVerifikasi.length - 1;

              String tanggalStr = '-';
              if (riwayat.createdAt != null) {
                final dt = riwayat.createdAt!.toLocal();
                tanggalStr = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
              }

              IconData aksiIcon = Icons.info_outline;
              Color iconColor = WarnaAplikasi.textGray;
              String statusLabel = riwayat.aksi.replaceAll('_', ' ').toUpperCase();

              if (riwayat.statusSesudahnya == 'terverifikasi') {
                aksiIcon = Icons.check_circle_outline;
                iconColor = WarnaAplikasi.primary;
              } else if (riwayat.statusSesudahnya == 'perlu_perbaikan') {
                aksiIcon = Icons.warning_amber_rounded;
                iconColor = WarnaAplikasi.warningOrange;
              } else if (riwayat.statusSesudahnya == 'menunggu_verifikasi') {
                aksiIcon = Icons.hourglass_top_rounded;
                iconColor = const Color(0xFF1D4ED8);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(aksiIcon, size: 16, color: iconColor),
                          const SizedBox(width: 6),
                          Text(
                            statusLabel,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: iconColor),
                          ),
                          if (riwayat.nomorRevisi > 0)
                            Text(
                              ' (Rev #${riwayat.nomorRevisi})',
                              style: const TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayLight),
                            ),
                        ],
                      ),
                      Text(
                        tanggalStr,
                        style: const TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayLight),
                      ),
                    ],
                  ),
                  if (riwayat.namaAktor != null && riwayat.namaAktor!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Oleh: ${riwayat.namaAktor}${riwayat.jabatanAktor != null && riwayat.jabatanAktor!.isNotEmpty ? ' (${riwayat.jabatanAktor})' : ''}',
                      style: const TextStyle(fontSize: 11, color: WarnaAplikasi.textGray),
                    ),
                  ],
                  if (riwayat.catatan != null && riwayat.catatan!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: WarnaAplikasi.backgroundLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Catatan: "${riwayat.catatan}"',
                        style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: WarnaAplikasi.primaryDark),
                      ),
                    ),
                  ],
                  if (!isLast)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: WarnaAplikasi.backgroundLight, thickness: 1),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGridCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WarnaAplikasi.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: WarnaAplikasi.bgInput, shape: BoxShape.circle),
            child: Icon(icon, color: WarnaAplikasi.primary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 10, color: WarnaAplikasi.textGrayLight)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVerificationStatusCard() {
    final status = _item.statusVerifikasi;
    if (status == null || status.isEmpty) {
      return const SizedBox.shrink();
    }

    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData icon;
    String title;
    String subtitle;

    switch (status) {
      case 'terverifikasi':
        bgColor = WarnaAplikasi.greenLight;
        borderColor = WarnaAplikasi.greenPill;
        textColor = WarnaAplikasi.greenText;
        icon = Icons.verified_rounded;
        title = 'Lahan Terverifikasi';
        subtitle = 'Data petak lahan telah disetujui oleh Pengurus/Ketua Kelompok Tani.';
        break;
      case 'perlu_perbaikan':
        bgColor = WarnaAplikasi.warningOrangeBg;
        borderColor = const Color(0xFFFDE68A);
        textColor = WarnaAplikasi.warningOrange;
        icon = Icons.error_outline_rounded;
        title = 'Perlu Perbaikan';
        subtitle = _item.catatanVerifikasi != null && _item.catatanVerifikasi!.isNotEmpty
            ? 'Catatan Pengurus: "${_item.catatanVerifikasi}"'
            : 'Ketua meminta perbaikan data lahan sebelum dapat diverifikasi.';
        break;
      case 'menunggu_verifikasi':
      default:
        bgColor = const Color(0xFFEFF6FF);
        borderColor = const Color(0xFFBFDBFE);
        textColor = const Color(0xFF1D4ED8);
        icon = Icons.hourglass_top_rounded;
        title = 'Menunggu Verifikasi';
        subtitle = 'Data petak dalam antrean verifikasi oleh Pengurus/Ketua Kelompok Tani.';
        break;
    }

    final displayTitle = _item.nomorRevisi > 0 ? '$title (Revisi #${_item.nomorRevisi})' : title;

    return Container(

      margin: const EdgeInsets.only(bottom: 20),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: bgColor,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: borderColor),

      ),

      child: Row(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Icon(icon, color: textColor, size: 24),

          const SizedBox(width: 12),

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(

                  displayTitle,

                  style: TextStyle(

                    fontSize: 13,

                    fontWeight: FontWeight.bold,

                    color: textColor,

                  ),

                ),

                const SizedBox(height: 4),

                Text(

                  subtitle,

                  style: TextStyle(

                    fontSize: 12,

                    color: textColor.withValues(alpha: 0.9),

                    height: 1.4,

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

}

