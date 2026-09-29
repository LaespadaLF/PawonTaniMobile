import 'package:flutter/material.dart';
import '../models/harvest_item.dart';
import '../widgets/delete_harvest_dialog.dart';
import 'edit_harvest_screen.dart';

class HarvestDetailScreen extends StatefulWidget {
  final HarvestItem item;
  final Function(HarvestItem) onUpdate;
  final VoidCallback onDelete;

  const HarvestDetailScreen({
    super.key,
    required this.item,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<HarvestDetailScreen> createState() => _HarvestDetailScreenState();
}

class _HarvestDetailScreenState extends State<HarvestDetailScreen> {
  late HarvestItem _currentItem;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
  }

  String _formatCurrency(double amount) {
    final intVal = amount.toInt();
    final str = intVal.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  void _openEditScreen() async {
    final updated = await Navigator.push<HarvestItem>(
      context,
      MaterialPageRoute(
        builder: (ctx) => EditHarvestScreen(
          item: _currentItem,
          onSave: (newItem) {
            setState(() {
              _currentItem = newItem;
            });
            widget.onUpdate(newItem);
          },
          onDelete: () {
            widget.onDelete();
            Navigator.pop(context);
          },
        ),
      ),
    );

    if (updated != null) {
      setState(() {
        _currentItem = updated;
      });
      widget.onUpdate(updated);
    }
  }

  void _confirmDelete() {
    DeleteHarvestDialog.show(
      context,
      item: _currentItem,
      onConfirmDelete: () {
        widget.onDelete();
        Navigator.pop(context); // pop detail screen
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF9),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildAppBar(),

            // Content List
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Verification Alert
                    _buildVerificationAlert(),
                    const SizedBox(height: 14),

                    // 2. Main Hero Harvest Card (Deep Green)
                    _buildHeroHarvestCard(),
                    const SizedBox(height: 14),

                    // 3. Financial & Quality Stats Card
                    _buildStatsCard(),
                    const SizedBox(height: 14),

                    // 4. Informasi Lahan & Panen
                    _buildLahanPanenInfoCard(),
                    const SizedBox(height: 14),

                    // 5. Dokumentasi Bukti Fisik
                    _buildDokumentasiCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar (Cetak PDF, Edit, Delete)
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEFF3F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4EC),
                borderRadius: BorderRadius.circular(19),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF285438),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detail Panen',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF15261B),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'ID: ${_currentItem.harvestCode}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF708577),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tautan rincian panen disalin ke clipboard.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.share_outlined, size: 20, color: Color(0xFF43584B)),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, size: 22, color: Color(0xFF43584B)),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationAlert() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF7F1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6EADB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFF285438),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 13,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6EADB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Telah Diverifikasi',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E5334),
                        ),
                      ),
                    ),
                    Text(
                      _currentItem.validatedAt,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF708577),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Divalidasi oleh: ${_currentItem.validatedBy} langsung di timbangan panen.',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF4A6252),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHarvestCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF235535), Color(0xFF1B432A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24285438),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0x33FFFFFF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.grass_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'KOMODITAS UTAMA',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB7DFCA),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        _currentItem.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x33FFFFFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'GKP (Gabah Kering)',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0x26FFFFFF), height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Berat Bersih',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFC7EBD2),
                    ),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: _formatCurrency(_currentItem.weightKg),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const TextSpan(
                          text: ' Kg',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Konversi Bobot',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFFC7EBD2),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_currentItem.weightTon.toStringAsFixed(2).replaceAll('.', ',')} Ton • ${_currentItem.weightKuintal.toStringAsFixed(1).replaceAll('.', ',')} Kw',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2EBE5)),
      ),
      child: Column(
        children: [
          // Row 1: Estimasi Nilai Panen & Harga per kg
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F4EA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.monetization_on_outlined,
                  color: Color(0xFF285438),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estimasi Nilai Panen',
                      style: TextStyle(fontSize: 11, color: Color(0xFF6B8072)),
                    ),
                    Text(
                      'Rp ${_formatCurrency(_currentItem.estimatedValue)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF235535),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Harga per Kg (GKP)*',
                    style: TextStyle(fontSize: 10.5, color: Color(0xFF6B8072)),
                  ),
                  Text(
                    'Rp ${_formatCurrency(_currentItem.pricePerKg)} / kg',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF15261B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFF0F4F1), height: 1),
          const SizedBox(height: 12),

          // Row 2: Kualitas / Mutu Hasil
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.verified_outlined, size: 14, color: Color(0xFF285438)),
                  SizedBox(width: 4),
                  Text(
                    'Kualitas / Mutu Hasil',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF15261B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6EADB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _currentItem.qualityGrade,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E5334),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 3 Metric Boxes: Kadar Air, Butir Utuh, Kotoran/Hampa
          Row(
            children: [
              _buildMetricBox('Kadar Air', '< 14%', 'Standar Bulog'),
              const SizedBox(width: 8),
              _buildMetricBox('Butir Utuh', '≥ 95%', 'Baik Sekali'),
              const SizedBox(width: 8),
              _buildMetricBox('Kotoran/Hampa', '≤ 2%', 'Sangat Bersih'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBox(String label, String value, String status) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F7F4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF6B8072)),
              maxLines: 1,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF15261B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              status,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF285438),
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLahanPanenInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2EBE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.agriculture_rounded, size: 18, color: Color(0xFF285438)),
                  SizedBox(width: 8),
                  Text(
                    'Informasi Lahan & Panen',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF15261B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF7F1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD6EADB)),
                ),
                child: const Text(
                  'Musim MT-1 2023/2024',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF285438),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Grid 2x2
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.location_on_outlined,
                  label: _currentItem.location,
                  sublabel: 'Luas efektif: ${_currentItem.blockArea}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.groups_outlined,
                  label: _currentItem.poktan,
                  sublabel: 'Desa Sukamaju, Subang',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.calendar_today_outlined,
                  label: _currentItem.date,
                  sublabel: '${_currentItem.harvestTime} (Pagi Cerah)',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.precision_manufacturing_outlined,
                  label: _currentItem.harvestMethod,
                  sublabel: 'Minim susut rontok (<1,5%)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Biaya Petik / Tebas Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2EBE5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_outlined, size: 16, color: Color(0xFF43584B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Biaya Petik / Tebas',
                        style: TextStyle(fontSize: 10, color: Color(0xFF6B8072)),
                      ),
                      Text(
                        'Rp ${_formatCurrency(_currentItem.harvestCost)}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15261B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE0E7E2)),
                  ),
                  child: Text(
                    _currentItem.costWorkers,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF43584B)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Catatan Lapangan Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2EBE5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.notes_rounded, size: 14, color: Color(0xFF43584B)),
                    SizedBox(width: 6),
                    Text(
                      'Catatan Lapangan (Mandor)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF15261B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '"${_currentItem.fieldNotes}"',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF556C5E),
                    height: 1.35,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String sublabel,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF285438)),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF15261B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                sublabel,
                style: const TextStyle(fontSize: 10, color: Color(0xFF6B8072)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDokumentasiCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2EBE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.photo_library_outlined, size: 16, color: Color(0xFF285438)),
                  SizedBox(width: 8),
                  Text(
                    'Dokumentasi Bukti Fisik',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF15261B),
                    ),
                  ),
                ],
              ),
              Text(
                '2 Berkas',
                style: TextStyle(fontSize: 11, color: Color(0xFF708577)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2 Photos Side by Side
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFE0E0E0),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?w=400&q=80',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Color(0xCC000000)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Karung Hasil Panen',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Padi 97 Karung (siap angkut)',
                          style: TextStyle(fontSize: 8.5, color: Color(0xFFD6EADB)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFE0E0E0),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1595246140625-573b715d11dc?w=400&q=80',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Color(0xCC000000)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanda Bukti Fisik',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Resi timbangan digital',
                          style: TextStyle(fontSize: 8.5, color: Color(0xFFD6EADB)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Legal lock notice
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF7F1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.lock_outline_rounded, size: 14, color: Color(0xFF285438)),
                    SizedBox(width: 6),
                    Text(
                      'Data telah terkunci & sah secara hukum kemitraan.',
                      style: TextStyle(fontSize: 10, color: Color(0xFF285438)),
                    ),
                  ],
                ),
                Text(
                  'Lihat SK >',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF285438),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom
            : 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEFF3F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Cetak Bukti PDF
          Expanded(
            child: SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Menyiapkan berkas Cetak Bukti PDF...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 18, color: Colors.white),
                label: const Text(
                  'Cetak Bukti PDF',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF285438),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Edit Button (pencil)
          InkWell(
            onTap: _openEditScreen,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFEDF7F1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD6EADB)),
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: Color(0xFF285438),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Delete Button (trash)
          InkWell(
            onTap: _confirmDelete,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFFEEEEE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFDCBCB)),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFDC2626),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
