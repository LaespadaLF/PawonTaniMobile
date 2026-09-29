import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class EditLahanScreen extends StatefulWidget {
  final String namaLahan;
  final String idLahan;
  final String luas;
  final String alamat;
  final String komoditas;
  final String musimTanam;
  final String status;

  const EditLahanScreen({
    super.key,
    this.namaLahan = 'Petak Sawah Barat (Blok A)',
    this.idLahan = 'LHN-SKM-04',
    this.luas = '0,8',
    this.alamat = 'Desa Sukamaju, Dusun Krajan, RT 02/RW 01',
    this.komoditas = 'Padi Ciherang (Unggul Nasional)',
    this.musimTanam = 'MT-1 (Musim Hujan: Okt - Mar)',
    this.status = 'Aktif',
  });

  @override
  State<EditLahanScreen> createState() => _EditLahanScreenState();
}

class _EditLahanScreenState extends State<EditLahanScreen> {
  late TextEditingController _namaController;
  late TextEditingController _luasController;
  late TextEditingController _keteranganController;

  String _selectedSatuan = 'Hektar (Ha)';
  late String _selectedAlamat;
  late String _selectedKomoditas;
  late String _selectedMusim;
  bool _gpsVerified = true;

  final List<String> _satuanOptions = ['Hektar (Ha)', 'm²', 'Bata / Tumbak'];
  final List<String> _alamatOptions = [
    'Desa Sukamaju, Dusun Krajan, RT 02/RW 01',
    'Desa Sukamaju, Dusun Krajan, RT 01/RW 01',
    'Dusun Sukasari, Area Irigasi',
    'Bukit Sukamaju, Lereng Selatan',
  ];
  final List<String> _komoditasOptions = [
    'Padi Ciherang (Unggul Nasional)',
    'Padi IR 64',
    'Jagung Hibrida',
    'Cabai Merah Keriting',
    'Bawang Merah',
  ];
  final List<String> _musimOptions = [
    'MT-1 (Musim Hujan: Okt - Mar)',
    'MT-2 (Gadu: Apr - Jul)',
    'MT-3 (Kemarau: Agu - Sep)',
  ];

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: 'Petak Sawah Barat - Blok A');
    _luasController = TextEditingController(text: widget.luas);
    _keteranganController = TextEditingController(
      text:
          'Kondisi tanah petak A sangat responsif terhadap pupuk organik kandang. Saluran irigasi sekunder lancar.',
    );
    _selectedAlamat = _alamatOptions.first;
    _selectedKomoditas = _komoditasOptions.first;
    _selectedMusim = _musimOptions.first;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _luasController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildModeBanner(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('SPESIFIKASI & IDENTITAS LAHAN'),
                    const SizedBox(height: 16),
                    _buildFormSpesifikasi(),
                    const SizedBox(height: 28),
                    _buildDokumentasiSection(),
                    const SizedBox(height: 24),
                    _buildInfoNotice(),
                    const SizedBox(height: 28),
                    _buildActionButtons(),
                    const SizedBox(height: 16),
                    _buildDeleteButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 1. Top App Bar ──────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(LucideIcons.chevronLeft, color: AppColors.textPrimary, size: 24),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Informasi Lahan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Perbarui data spesifikasi dan kondisi petak garapanmu.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. Mode Banner ──────────────────────────────────────────
  Widget _buildModeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF265333),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF265333).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(LucideIcons.pencil, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MODE PENYUNTINGAN LAHAN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: Color(0xFFB8E6C1),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.namaLahan} | ID: ${widget.idLahan}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Aktif',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. Section Header Indicator ─────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ── 4. Form Spesifikasi & Identitas Lahan ───────────────────
  Widget _buildFormSpesifikasi() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama / Penamaan Petak
          _buildFieldLabel('Nama / Penamaan Petak', isRequired: true),
          const SizedBox(height: 8),
          TextField(
            controller: _namaController,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
            decoration: _inputDecoration(hint: 'Masukkan nama petak'),
          ),
          const SizedBox(height: 6),
          const Text(
            'Gunakan nama yang mudah dibedakan saat pencatatan pupuk & hasil panen.',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 18),

          // Luas Lahan
          _buildFieldLabel('Luas Lahan', isRequired: true),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _luasController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  decoration: _inputDecoration(hint: '0,0'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSatuan,
                      isExpanded: true,
                      icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textSecondary),
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                      items: _satuanOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedSatuan = val);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '= 8.000 m² (Konversi baku otomatis)',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
          const SizedBox(height: 18),

          // Alamat & Lokasi Desa
          _buildFieldLabel('Alamat & Lokasi Desa', isRequired: true),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedAlamat,
                isExpanded: true,
                icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textSecondary),
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                items: _alamatOptions.map((a) => DropdownMenuItem(value: a, child: Text(a, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedAlamat = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Titik Koordinat & Peta Lahan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFieldLabel('Titik Koordinat & Peta Lahan', isRequired: true),
              Row(
                children: [
                  Icon(
                    _gpsVerified ? LucideIcons.checkCircle2 : LucideIcons.alertCircle,
                    size: 14,
                    color: _gpsVerified ? AppColors.success : AppColors.warning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _gpsVerified ? 'GPS Terverifikasi' : 'Belum Diverifikasi',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _gpsVerified ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildMapPreview(),
          const SizedBox(height: 10),
          // Button perbarui GPS
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lokasi GPS berhasil diperbarui: -6.5621, 107.7589'),
                  backgroundColor: AppColors.primary,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3FCF7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lightGreen, width: 1),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.mapPin, size: 16, color: AppColors.darkGreen),
                  SizedBox(width: 8),
                  Text(
                    'Perbarui Titik dengan GPS Perangkat',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Komoditas / Tanaman
          _buildFieldLabel('Komoditas / Tanaman', isRequired: true),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedKomoditas,
                isExpanded: true,
                icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textSecondary),
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                items: _komoditasOptions
                    .map(
                      (k) => DropdownMenuItem(
                        value: k,
                        child: Row(
                          children: [
                            const Text('🌾 '),
                            Expanded(child: Text(k, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedKomoditas = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Musim Tanam
          _buildFieldLabel('Musim Tanam', isRequired: true),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedMusim,
                isExpanded: true,
                icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textSecondary),
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                items: _musimOptions
                    .map(
                      (m) => DropdownMenuItem(
                        value: m,
                        child: Row(
                          children: [
                            const Text('📅 '),
                            Expanded(child: Text(m, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedMusim = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Keterangan Tambahan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Keterangan Tambahan (Opsional)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const Text(
                '98/200',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _keteranganController,
            maxLines: 3,
            maxLength: 200,
            buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
            decoration: _inputDecoration(hint: 'Tambahkan informasi lahan bila diperlukan...'),
          ),
        ],
      ),
    );
  }

  // ── 5. Map Preview Widget ──────────────────────────────────
  Widget _buildMapPreview() {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFFD6EFE0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBCE0CB), width: 1),
      ),
      child: Stack(
        children: [
          // Stylized map contours
          CustomPaint(
            size: const Size(double.infinity, 150),
            painter: _MapPainter(),
          ),
          // Petak polygon highlight
          Positioned(
            left: 120,
            top: 25,
            child: Container(
              width: 100,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF447E4F).withValues(alpha: 0.15),
                border: Border.all(
                  color: const Color(0xFF447E4F).withValues(alpha: 0.6),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          // Center Marker
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF265333),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Petak A',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.darkGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                  child: const Icon(LucideIcons.mapPin, color: Colors.white, size: 14),
                ),
              ],
            ),
          ),
          // Top right button: Ubah Titik Lokasi
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.pencil, size: 12, color: AppColors.textPrimary),
                  SizedBox(width: 4),
                  Text(
                    'Ubah Titik Lokasi',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Bar with coordinates
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(13),
                  bottomRight: Radius.circular(13),
                ),
                border: const Border(top: BorderSide(color: Color(0xFFE5EAF0), width: 1)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Lat: -6.5621', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  Text('Long: 107.7589', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  Text('Akurasi ± 3m', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 6. Dokumentasi Petak Section ────────────────────────────
  Widget _buildDokumentasiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('DOKUMENTASI PETAK'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE5F2E8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '2 Foto Terpasang',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreen,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Foto kondisi visual terbaru memudahkan verifikasi PPL dan pemantauan fase tumbuh.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 14),

        // Photo Grid Row
        Row(
          children: [
            Expanded(
              child: _buildPhotoCard(
                tag: 'Vegetatif 30 HST',
                imageUrl: 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=400',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPhotoCard(
                tag: 'Cek Anakan 40 HST',
                imageUrl: 'https://images.unsplash.com/photo-1523348837708-15d4a09cfac2?w=400',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Dashed border: Unggah Baru
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFBCE0CB),
              width: 1.5,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFF3FCF7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.plus, color: AppColors.primary, size: 20),
              ),
              const SizedBox(height: 6),
              const Text(
                '+ Unggah Dokumentasi Baru',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Format JPG/PNG, ukuran berkas maksimal 5MB',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoCard({required String tag, required String imageUrl}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with tag overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(13),
                  topRight: Radius.circular(13),
                ),
                child: Image.network(
                  imageUrl,
                  height: 90,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 90,
                    color: const Color(0xFFE5F2E8),
                    child: const Center(
                      child: Icon(LucideIcons.image, color: AppColors.primary, size: 28),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          // Actions: Ganti / Hapus
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.arrowUpFromLine, size: 14, color: AppColors.textPrimary),
                    SizedBox(width: 4),
                    Text('Ganti', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  ],
                ),
                InkWell(
                  onTap: () {},
                  child: const Icon(LucideIcons.trash2, size: 15, color: Color(0xFFFF5C6C)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 7. PPL Info Notice ──────────────────────────────────────
  Widget _buildInfoNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3FCF7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD3EEDC), width: 1),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.info, size: 18, color: AppColors.darkGreen),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Perubahan luas dan titik GPS akan diselaraskan dengan data kelompok tani serta buku saku digital PPL wilayah Sukamaju.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 8. Bottom Action Buttons ────────────────────────────────
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Batal Button
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEFF3F6),
                foregroundColor: AppColors.textSecondary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Batal',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Simpan Perubahan Button
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _showSuccessSaveDialog,
              icon: const Icon(LucideIcons.check, size: 18),
              label: const Text(
                'Simpan Perubahan Lahan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F6F3E),
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── 9. Hapus Petak Button ───────────────────────────────────
  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton.icon(
        onPressed: _showDeleteDialog,
        icon: const Icon(LucideIcons.trash2, size: 16, color: Color(0xFFFF5C6C)),
        label: const Text(
          'Hapus Petak Sawah Ini',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF5C6C),
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFFECDD3), width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  // Helper Methods & Dialogs
  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        if (isRequired)
          const Text(' *', style: TextStyle(color: Color(0xFFFF5C6C), fontWeight: FontWeight.bold)),
      ],
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  void _showSuccessSaveDialog() {
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
                  color: Color(0xFFE5F2E8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.check, color: AppColors.darkGreen, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Perubahan Lahan Disimpan!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Data ${_namaController.text} berhasil diperbarui di sistem PawonTani.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context); // back to detail or list
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Kembali ke Lahan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog() {
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
                'Hapus Petak Lahan Ini?',
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
                      text: _namaController.text,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const TextSpan(text: '? Tindakan ini tidak dapat dibatalkan.'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFECDD3)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.alertTriangle, color: Color(0xFFFF5C6C), size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Semua riwayat pemupukan, pencatatan bibit, dan data panen pada petak ini akan terhapus permanen.',
                        style: TextStyle(fontSize: 11, color: Color(0xFFB91C1C), height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5C6C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Ya, Hapus Data Lahan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
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

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFFB3DEC4)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final roadPaint = Paint()
      ..color = const Color(0xFFE2F4EA)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    // Draw stylized contour lines and roads
    final path = Path()
      ..moveTo(0, size.height * 0.4)
      ..cubicTo(size.width * 0.3, size.height * 0.2, size.width * 0.7, size.height * 0.8, size.width, size.height * 0.5);
    canvas.drawPath(path, linePaint);

    final path2 = Path()
      ..moveTo(size.width * 0.2, 0)
      ..cubicTo(size.width * 0.4, size.height * 0.5, size.width * 0.6, size.height * 0.6, size.width * 0.8, size.height);
    canvas.drawPath(path2, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
