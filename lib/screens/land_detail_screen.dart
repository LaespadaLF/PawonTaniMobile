import 'package:flutter/material.dart';
import '../models/land_item.dart';
import 'edit_land_screen.dart';

class LandDetailScreen extends StatelessWidget {
  final LandItem item;

  const LandDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isAktif = item.status == LandStatus.aktif;
    final tagText = isAktif ? 'Aktif Ditanami' : (item.status == LandStatus.persiapan ? 'Dalam Proses' : 'Masa Olah Tanah');
    final tagColor = isAktif ? const Color(0xFFD6EADB) : const Color(0xFFFFF7ED);
    final tagTextColor = isAktif ? const Color(0xFF1E5334) : const Color(0xFFD97706);
    final dotColor = isAktif ? const Color(0xFF22C55E) : const Color(0xFFF59E0B);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAF9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF142419)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Lahan',
          style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF142419), fontSize: 18),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Color(0xFF142419)),
                onPressed: () {},
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                  child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ),
              )
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16, left: 4),
            child: CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1595246140625-573b715d11dc?w=100&q=80'),
            ),
          ),
        ],
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
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1595246140625-573b715d11dc?w=600&q=80'),
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
                          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
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
                          const Text('PETAK SAWAH', style: TextStyle(color: Color(0xFF6EE7B7), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.arrow_downward, color: Color(0xFF6EE7B7), size: 14),
                              const SizedBox(width: 4),
                              Text('${item.area.toStringAsFixed(1).replaceAll('.', ',')} Ha', style: const TextStyle(color: Colors.white, fontSize: 12)),
                              const SizedBox(width: 16),
                              const Icon(Icons.eco, color: Color(0xFF6EE7B7), size: 14),
                              const SizedBox(width: 4),
                              Text(item.currentCrop, style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Info Grid
              Row(
                children: [
                  Expanded(child: _buildInfoGridCard(Icons.crop_square, 'Luas Lahan', '${item.area.toStringAsFixed(1).replaceAll('.', ',')} Ha')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInfoGridCard(Icons.eco_outlined, 'Komoditas', item.currentCrop)),
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
                  border: Border.all(color: const Color(0xFFE2E9E4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Spesifikasi Petak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF142419))),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, color: Color(0xFF94A3B8), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Lokasi', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                              const SizedBox(height: 4),
                              Text(item.location, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF142419), height: 1.4)),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 40, color: const Color(0xFFF1F5F9), margin: const EdgeInsets.symmetric(horizontal: 16)),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Luas', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                              const SizedBox(height: 4),
                              Text('${item.area.toStringAsFixed(1).replaceAll('.', ',')} Ha', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF142419))),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: Color(0xFFF1F5F9), thickness: 1),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.water_drop_outlined, color: Color(0xFF3B82F6), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Sumber Irigasi', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                              const SizedBox(height: 4),
                              const Text('Sekunder', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF142419))),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 40, color: const Color(0xFFF1F5F9), margin: const EdgeInsets.symmetric(horizontal: 16)),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tanggal Tanam', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                              const SizedBox(height: 4),
                              const Text('15 Okt 2024', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF142419))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Dokumentasi Petak
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dokumentasi Petak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF142419))),
                  const Text('+ Tambah Foto', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF285438))),
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
                        image: const DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1595246140625-573b715d11dc?w=300&q=80'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1586771107445-d3ca888129ff?w=300&q=80'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFBFE0CD), width: 1.5), // Not exactly dashed here to simplify, using solid border
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined, color: Color(0xFF285438)),
                          SizedBox(height: 4),
                          Text('Lihat Semua', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF142419))),
                          Text('(2 Foto)', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Riwayat Terkini
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Riwayat Terkini', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF142419))),
                  const Text('Lihat Semua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF285438))),
                ],
              ),
              const SizedBox(height: 12),
              _buildRiwayatCard(Icons.inventory_2_outlined, const Color(0xFFE8F4EC), 'Pemupukan', '12 Nov 2024 • 120 kg/Ha'),
              const SizedBox(height: 12),
              _buildRiwayatCard(Icons.science_outlined, const Color(0xFFEFF6FF), 'Penyemprotan', '04 Nov 2024 • Pencegahan Hama'),
              const SizedBox(height: 32),

              // Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const Text('Catat Aktivitas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF164E36),
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
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF475569), size: 18),
                  label: const Text('Edit Informasi Lahan', style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    side: const BorderSide(color: Color(0xFFF1F5F9)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                  label: const Text('Hapus Lahan', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEF2F2),
                    side: const BorderSide(color: Color(0xFFFECACA)),
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
        border: Border.all(color: const Color(0xFFE2E9E4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFFF8FAFC), shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFF285438), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF142419))),
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
        border: Border.all(color: const Color(0xFFE2E9E4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: const Color(0xFF285438), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF142419))),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF94A3B8), size: 20),
        ],
      ),
    );
  }
}
