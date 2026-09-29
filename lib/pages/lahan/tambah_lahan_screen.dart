import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class TambahLahanScreen extends StatefulWidget {
  const TambahLahanScreen({super.key});

  @override
  State<TambahLahanScreen> createState() => _TambahLahanScreenState();
}

class _TambahLahanScreenState extends State<TambahLahanScreen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _luasController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();

  String _selectedSatuan = 'Hektar (Ha)';
  String _selectedAlamat = 'Desa Sukamaju, Dusun Krajan';
  String _selectedKomoditas = 'Padi Ciherang';
  String _selectedMusim = 'MT-1 (Musim Hujan)';

  final List<String> _satuanOptions = ['Hektar (Ha)', 'm²', 'Bata / Tumbak'];
  final List<String> _alamatOptions = [
    'Desa Sukamaju, Dusun Krajan',
    'Dusun Sukasari, Area Irigasi',
    'Bukit Sukamaju, Lereng Selatan',
  ];
  final List<String> _komoditasOptions = [
    'Padi Ciherang',
    'Padi IR 64',
    'Jagung Hibrida',
    'Cabai Merah',
    'Bawang Merah',
  ];
  final List<String> _musimOptions = [
    'MT-1 (Musim Hujan)',
    'MT-2 (Gadu: Apr - Jul)',
    'MT-3 (Kemarau: Agu - Sep)',
  ];

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
                    const Text(
                      'Informasi Lahan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFormCard(),
                    const SizedBox(height: 24),
                    _buildDokumentasiSection(),
                    const SizedBox(height: 24),
                    _buildPPLNotice(),
                    const SizedBox(height: 28),
                    _buildBottomButtons(),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tambah Lahan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Daftarkan petak garapanmu untuk memudahkan pemantauan tanaman.',
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

  Widget _buildFormCard() {
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
          _buildFieldLabel('Nama / Penamaan Petak', isRequired: true),
          const SizedBox(height: 8),
          TextField(
            controller: _namaController,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: _inputDecoration(hint: 'Petak Sawah Barat'),
          ),
          const SizedBox(height: 6),
          const Text(
            'Gunakan nama yang mudah dibedakan.',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 18),

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
                  decoration: _inputDecoration(hint: '0,8'),
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
                      items: _satuanOptions.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
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
            '≈ 8.000 m²',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
          const SizedBox(height: 18),

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
                items: _alamatOptions.map((a) => DropdownMenuItem(value: a, child: Text(a, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedAlamat = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 18),

          _buildFieldLabel('Titik Koordinat & Peta Lahan', isRequired: true),
          const SizedBox(height: 10),
          _buildMapCard(),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lokasi GPS saat ini terdeteksi: -6.5621, 107.7589'),
                  backgroundColor: AppColors.primary,
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
                  Icon(LucideIcons.crosshair, size: 16, color: AppColors.darkGreen),
                  SizedBox(width: 8),
                  Text(
                    'Gunakan Lokasi GPS Saat Ini',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

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
                items: _komoditasOptions
                    .map((k) => DropdownMenuItem(value: k, child: Text('🌾  $k', style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedKomoditas = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 18),

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
                items: _musimOptions
                    .map((m) => DropdownMenuItem(value: m, child: Text('📅  $m', style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedMusim = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 18),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Keterangan Tambahan (Opsional)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              Text('0/200', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _keteranganController,
            maxLines: 3,
            maxLength: 200,
            buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            decoration: _inputDecoration(hint: 'Tambahkan informasi lahan bila diperlukan...'),
          ),
        ],
      ),
    );
  }

  Widget _buildMapCard() {
    return Container(
      width: double.infinity,
      height: 130,
      decoration: BoxDecoration(
        color: const Color(0xFFD9EFE2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC2E4CD)),
      ),
      child: Stack(
        children: [
          // Marker at center
          Center(
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.darkGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.mapPin, color: Colors.white, size: 16),
            ),
          ),
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
                  Icon(LucideIcons.map, size: 12, color: AppColors.textPrimary),
                  SizedBox(width: 4),
                  Text('Pilih Lokasi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(13),
                  bottomRight: Radius.circular(13),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Lat: -6.5621', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text('Long: 107.7589', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDokumentasiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Dokumentasi Petak (Opsional)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            Text(
              '1 Foto Terpilih',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Ambil Foto Box
            Expanded(
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFC7E2D1), width: 1.5),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.camera, color: AppColors.primary, size: 24),
                    SizedBox(height: 6),
                    Text('Ambil Foto / Galeri', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    Text('JPG, PNG maks 5MB', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Existing photo preview
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=400',
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Foto Kondisi Awal',
                        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.x, color: Colors.white, size: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPPLNotice() {
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
              'Data akan diverifikasi oleh PPL dan dicatat pada sistem ROCKK untuk validasi petak.',
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

  Widget _buildBottomButtons() {
    return Row(
      children: [
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
              child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data lahan baru berhasil disimpan!'),
                    backgroundColor: AppColors.darkGreen,
                  ),
                );
              },
              icon: const Icon(LucideIcons.save, size: 18),
              label: const Text('Simpan Data Lahan', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F6F3E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),
      ],
    );
  }

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
}
