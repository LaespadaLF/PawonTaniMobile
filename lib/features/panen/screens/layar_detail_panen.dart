import 'package:pawon_mobile/core/constants/api_constants.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:flutter/material.dart';
import 'package:pawon_mobile/features/panen/models/item_panen.dart';
import 'package:pawon_mobile/features/panen/widgets/dialog_hapus_panen.dart';
import 'package:pawon_mobile/features/panen/screens/layar_edit_panen.dart';

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
      backgroundColor: WarnaAplikasi.primaryBackground,
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
          bottom: BorderSide(color: WarnaAplikasi.surfaceLight, width: 1),
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
                color: WarnaAplikasi.greenLight,
                borderRadius: BorderRadius.circular(19),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: WarnaAplikasi.primary,
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
                    color: WarnaAplikasi.textDarkGreen,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'ID: ${_currentItem.harvestCode}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: WarnaAplikasi.textGrayGreen,
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
            icon: const Icon(Icons.share_outlined, size: 20, color: WarnaAplikasi.grayGreenDark),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, size: 22, color: WarnaAplikasi.grayGreenDark),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationAlert() {
    if (_currentItem.status == HarvestStatus.disetujui) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: WarnaAplikasi.bgPaleGreen2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: WarnaAplikasi.greenPill),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: WarnaAplikasi.primary,
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
                          color: WarnaAplikasi.greenPill,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Telah Diverifikasi',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: WarnaAplikasi.greenText,
                          ),
                        ),
                      ),
                      Text(
                        _currentItem.validatedAt,
                        style: const TextStyle(
                          fontSize: 10,
                          color: WarnaAplikasi.textGrayGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Divalidasi oleh: ${_currentItem.validatedBy.isNotEmpty ? _currentItem.validatedBy : "Pengurus Poktan"}.',
                    style: const TextStyle(
                      fontSize: 11,
                      color: WarnaAplikasi.grayGreenDark,
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

    if (_currentItem.status == HarvestStatus.ditolak) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
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
                          color: Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Perlu Perbaikan / Ditolak',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      Text(
                        _currentItem.validatedAt,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentItem.validatedNotes != null && _currentItem.validatedNotes!.isNotEmpty
                        ? 'Catatan Pengurus: "${_currentItem.validatedNotes}". Silakan ketuk tombol edit untuk mengajukan revisi.'
                        : 'Catatan panen ini ditolak pengurus poktan. Silakan periksa kembali dan ajukan perbaikan.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.red.shade900,
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

    // Status Menunggu
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: WarnaAplikasi.warningOrange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WarnaAplikasi.warningOrange.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: WarnaAplikasi.warningOrange,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              size: 13,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: WarnaAplikasi.warningOrange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Menunggu Verifikasi',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: WarnaAplikasi.warningOrange,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Catatan panen ini telah diajukan dan sedang menunggu verifikasi dari pengurus poktan.',
                  style: TextStyle(
                    fontSize: 11,
                    color: WarnaAplikasi.textDarkGreen,
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
          colors: [WarnaAplikasi.primaryDark, WarnaAplikasi.primaryDark],
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
                          color: WarnaAplikasi.successPaleGreen,
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_currentItem.isLegacy) ...[
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amberAccent),
                      ),
                      child: const Text(
                        'Legacy',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.amberAccent,
                        ),
                      ),
                    ),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0x33FFFFFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _currentItem.subtitle.isNotEmpty ? _currentItem.subtitle : 'Panen Segar',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
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
                      color: WarnaAplikasi.successPaleGreen,
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
                      color: WarnaAplikasi.successPaleGreen,
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
        border: Border.all(color: WarnaAplikasi.borderField),
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
                  color: WarnaAplikasi.bgSuccessLight2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.monetization_on_outlined,
                  color: WarnaAplikasi.primary,
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
                      style: TextStyle(fontSize: 11, color: WarnaAplikasi.textGray),
                    ),
                    Text(
                      'Rp ${_formatCurrency(_currentItem.estimatedValue)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: WarnaAplikasi.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Harga Jual / Kg',
                    style: TextStyle(fontSize: 10.5, color: WarnaAplikasi.textGray),
                  ),
                  Text(
                    'Rp ${_formatCurrency(_currentItem.pricePerKg)} / kg',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: WarnaAplikasi.textDarkGreen,
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

  Widget _buildLahanPanenInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WarnaAplikasi.borderField),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.agriculture_rounded, size: 18, color: WarnaAplikasi.primary),
                  SizedBox(width: 8),
                  Text(
                    'Informasi Lahan & Panen',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: WarnaAplikasi.textDarkGreen,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: WarnaAplikasi.bgPaleGreen2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: WarnaAplikasi.greenPill),
                ),
                child: const Text(
                  'Musim MT-1 2023/2024',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: WarnaAplikasi.primary,
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
              color: WarnaAplikasi.bgPaleGreen3,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: WarnaAplikasi.borderField),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_outlined, size: 16, color: WarnaAplikasi.grayGreenDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Biaya Petik / Tebas',
                        style: TextStyle(fontSize: 10, color: WarnaAplikasi.textGray),
                      ),
                      Text(
                        'Rp ${_formatCurrency(_currentItem.harvestCost)}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: WarnaAplikasi.textDarkGreen,
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
                    border: Border.all(color: WarnaAplikasi.borderPale2),
                  ),
                  child: Text(
                    _currentItem.costWorkers,
                    style: const TextStyle(fontSize: 10, color: WarnaAplikasi.grayGreenDark),
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
              color: WarnaAplikasi.bgPaleGreen3,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: WarnaAplikasi.borderField),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.notes_rounded, size: 14, color: WarnaAplikasi.grayGreenDark),
                    SizedBox(width: 6),
                    Text(
                      'Catatan Lapangan (Mandor)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: WarnaAplikasi.textDarkGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '"${_currentItem.fieldNotes}"',
                  style: const TextStyle(
                    fontSize: 11,
                    color: WarnaAplikasi.grayGreenDark,
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
        Icon(icon, size: 15, color: WarnaAplikasi.primary),
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
                  color: WarnaAplikasi.textDarkGreen,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                sublabel,
                style: const TextStyle(fontSize: 10, color: WarnaAplikasi.textGray),
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
    final photoList = _currentItem.photos.where((p) => p.trim().isNotEmpty).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WarnaAplikasi.borderField),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.photo_library_outlined, size: 16, color: WarnaAplikasi.primary),
                  SizedBox(width: 8),
                  Text(
                    'Dokumentasi Bukti Fisik',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: WarnaAplikasi.textDarkGreen,
                    ),
                  ),
                ],
              ),
              Text(
                '${photoList.length} Berkas',
                style: const TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayGreen),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Daftar Foto atau Empty State
          if (photoList.isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: photoList.length,
                separatorBuilder: (sepCtx, sepIdx) => const SizedBox(width: 10),
                itemBuilder: (ctx, index) {
                  final rawPath = photoList[index];
                  final fullUrl = ApiConstants.resolveImageUrl(rawPath) ?? rawPath;

                  return InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (dCtx) => Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: const EdgeInsets.all(16),
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  fullUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (errCtx, errObj, errTrace) => Container(
                                    color: Colors.black87,
                                    padding: const EdgeInsets.all(24),
                                    child: const Text('Gagal memuat gambar', style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                                onPressed: () => Navigator.pop(dCtx),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: WarnaAplikasi.dividerGray,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        fullUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: WarnaAplikasi.primary),
                            ),
                          );
                        },
                        errorBuilder: (errCtx, errObj, errTrace) => Container(
                          color: WarnaAplikasi.bgPaleGreen3,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image_rounded, color: WarnaAplikasi.primary, size: 28),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: WarnaAplikasi.bgPaleGreen3,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: WarnaAplikasi.borderField),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_camera_outlined, color: WarnaAplikasi.grayGreenMuted, size: 28),
                  SizedBox(height: 6),
                  Text(
                    'Belum ada foto bukti fisik yang dilampirkan.',
                    style: TextStyle(fontSize: 11.5, color: WarnaAplikasi.textGray),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),

          // Banner Status Verifikasi
          Builder(
            builder: (ctx) {
              if (_currentItem.status == HarvestStatus.disetujui) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: WarnaAplikasi.bgPaleGreen2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: WarnaAplikasi.greenPill),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 15, color: WarnaAplikasi.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Hasil panen telah terverifikasi oleh kelompok tani.',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: WarnaAplikasi.textDarkGreen),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (_currentItem.status == HarvestStatus.ditolak) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.cancel_outlined, size: 15, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _currentItem.validatedNotes?.isNotEmpty == true
                              ? 'Catatan Penolakan: ${_currentItem.validatedNotes}'
                              : 'Catatan hasil panen ini ditolak saat verifikasi lapangan.',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.red.shade800),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.hourglass_top_rounded, size: 15, color: Colors.amber.shade800),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Menunggu verifikasi lapangan oleh pengurus kelompok tani.',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.amber.shade900),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
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
          top: BorderSide(color: WarnaAplikasi.surfaceLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (_currentItem.status == HarvestStatus.ditolak) ...[
            Expanded(
              child: SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: _openEditScreen,
                  icon: const Icon(Icons.replay_rounded, size: 18, color: Colors.white),
                  label: const Text(
                    'Ajukan Revisi Panen',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WarnaAplikasi.warningOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ] else ...[
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
                    backgroundColor: WarnaAplikasi.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(width: 10),

          // Edit Button
          if (_currentItem.status == HarvestStatus.disetujui)
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Catatan panen yang telah disetujui Poktan telah terkunci dan tidak dapat diedit.'),
                    backgroundColor: WarnaAplikasi.primaryDark,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
            )
          else
            InkWell(
              onTap: _openEditScreen,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: WarnaAplikasi.bgPaleGreen2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: WarnaAplikasi.greenPill),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: WarnaAplikasi.primary,
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
                color: WarnaAplikasi.errorRedBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: WarnaAplikasi.errorRedBg),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: WarnaAplikasi.errorRedDark,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

