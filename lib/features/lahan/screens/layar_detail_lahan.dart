import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/core/widgets/pawon_form_header.dart';
import 'package:pawon_mobile/features/lahan/models/item_lahan.dart';
import 'package:pawon_mobile/features/lahan/screens/layar_edit_lahan.dart';
import 'package:pawon_mobile/features/lahan/services/lahan_api_service.dart';

class LandDetailScreen extends StatelessWidget {
  final ItemLahan item;

  const LandDetailScreen({super.key, required this.item});

  static Future<void> _confirmDelete(BuildContext context, ItemLahan item) async {
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
            content: Text('Yakin ingin menghapus lahan "${item.nama}"? Data yang dihapus tidak bisa dikembalikan.', style: const TextStyle(fontSize: 13)),
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

    if (context.mounted && confirmed) {
      try {
        await LahanApiService().deleteLahan(item.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data lahan berhasil dihapus.')));
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAktif = item.status == StatusLahan.aktif;
    final tagText = isAktif ? 'Aktif Ditanami' : (item.status == StatusLahan.persiapan ? 'Dalam Proses' : 'Masa Olah Tanah');
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Header Card
              Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: (item.fotoLahan != null && item.fotoLahan!.isNotEmpty)
                        ? NetworkImage(item.fotoLahan!)
                        : const NetworkImage('https://images.unsplash.com/photo-1595246140625-573b715d11dc?w=600&q=80') as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
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
                          Text(item.nama, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.arrow_downward, color: WarnaAplikasi.accentGreen, size: 14),
                              const SizedBox(width: 4),
                              Text('${item.luas.toStringAsFixed(1).replaceAll('.', ',')} Ha', style: const TextStyle(color: Colors.white, fontSize: 12)),
                              const SizedBox(width: 16),
                              const Icon(Icons.eco, color: WarnaAplikasi.accentGreen, size: 14),
                              const SizedBox(width: 4),
                              Text(item.komoditas, style: const TextStyle(color: Colors.white, fontSize: 12)),
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
                  Expanded(child: _buildInfoGridCard(Icons.crop_square, 'Luas Lahan', '${item.luas.toStringAsFixed(1).replaceAll('.', ',')} Ha')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInfoGridCard(Icons.eco_outlined, 'Komoditas', item.komoditas)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildInfoGridCard(Icons.calendar_today_outlined, 'Musim Tanam', 'MT-1 (Musim Huj...')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInfoGridCard(Icons.access_time, 'Estimasi Panen', '10 Feb 2025')),
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
                              Text(item.lokasi, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WarnaAplikasi.primaryDark, height: 1.4)),
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
                              Text('${item.luas.toStringAsFixed(1).replaceAll('.', ',')} Ha', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WarnaAplikasi.primaryDark)),
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
                              const Text('Sekunder', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WarnaAplikasi.primaryDark)),
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
                              const Text('15 Okt 2024', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WarnaAplikasi.primaryDark)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Peta Lokasi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Peta Lokasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: WarnaAplikasi.primaryDark)),
                  Text(
                    'Lat: ${(item.latitude ?? -6.5621).toStringAsFixed(6)}, Long: ${(item.longitude ?? 107.7589).toStringAsFixed(6)}',
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
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(item.latitude ?? -6.5621, item.longitude ?? 107.7589),
                      initialZoom: 15,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
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
                            point: LatLng(item.latitude ?? -6.5621, item.longitude ?? 107.7589),
                            child: Icon(Icons.location_on, color: WarnaAplikasi.primary, size: 40),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Dokumentasi Petak
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dokumentasi Petak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: WarnaAplikasi.primaryDark)),
                  const Text('+ Tambah Foto', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WarnaAplikasi.primary)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: WarnaAplikasi.greenLight,
                        image: item.fotoLahan != null
                            ? DecorationImage(
                                image: NetworkImage(item.fotoLahan!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: item.fotoLahan == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.agriculture_outlined, color: WarnaAplikasi.primary, size: 28),
                                SizedBox(height: 6),
                                Text('Belum ada foto dokumentasi petak', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark), textAlign: TextAlign.center),
                              ],
                            )
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Riwayat Terkini
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Riwayat Terkini', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: WarnaAplikasi.primaryDark)),
                  const Text('Lihat Semua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WarnaAplikasi.primary)),
                ],
              ),
              const SizedBox(height: 12),
              _buildRiwayatCard(Icons.inventory_2_outlined, WarnaAplikasi.greenLight, 'Pemupukan', '12 Nov 2024 • 120 kg/Ha'),
              const SizedBox(height: 12),
              _buildRiwayatCard(Icons.science_outlined, WarnaAplikasi.successPaleGreen, 'Penyemprotan', '04 Nov 2024 • Pencegahan Hama'),
              const SizedBox(height: 32),

              // Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditLandScreen(item: item)),
                    );
                  },
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
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => LandDetailScreen._confirmDelete(context, item),
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
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

  Widget _buildRiwayatCard(IconData icon, Color bgColor, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WarnaAplikasi.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: WarnaAplikasi.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayLight)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: WarnaAplikasi.textGrayLight, size: 20),
        ],
      ),
    );
  }


  Widget _buildVerificationStatusCard() {

    final status = item.statusVerifikasi;

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

        subtitle = item.catatanVerifikasi != null && item.catatanVerifikasi!.isNotEmpty

            ? 'Catatan Pengurus: "${item.catatanVerifikasi}"'

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

                  title,

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

