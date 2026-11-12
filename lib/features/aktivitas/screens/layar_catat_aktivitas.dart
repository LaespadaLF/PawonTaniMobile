import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/core/widgets/pawon_form_header.dart';
import 'package:pawon_mobile/features/aktivitas/models/item_aktivitas_tanam.dart';
import 'package:pawon_mobile/features/aktivitas/services/aktivitas_api_service.dart';
import 'package:pawon_mobile/features/aktivitas/widgets/dialog_sukses_aktivitas.dart';
import 'package:pawon_mobile/features/lahan/models/item_lahan.dart';
import 'package:pawon_mobile/features/lahan/services/lahan_api_service.dart';

class RecordActivityScreen extends StatefulWidget {
  final Function(PlantActivityItem)? onSave;
  final String? initialLahanId;
  final String? initialLahanName;

  const RecordActivityScreen({
    super.key,
    this.onSave,
    this.initialLahanId,
    this.initialLahanName,
  });

  @override
  State<RecordActivityScreen> createState() => _RecordActivityScreenState();
}

class _RecordActivityScreenState extends State<RecordActivityScreen> {
  final LahanApiService _lahanService = LahanApiService();
  final AktivitasApiService _aktivitasService = AktivitasApiService();

  // Lahan selection
  List<ItemLahan> _lahanList = [];
  ItemLahan? _selectedItemLahan;
  bool _isLoadingLahan = true;
  bool _isSaving = false;

  // Date & Time (Default to Now)
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // Category
  ActivityCategory _selectedCategory = ActivityCategory.pemupukan;

  // Condition
  PlantCondition _selectedCondition = PlantCondition.sehat;

  // Notes
  final TextEditingController _notesController = TextEditingController();

  // Photo
  Uint8List? _selectedPhotoBytes;
  String? _selectedPhotoName;

  @override
  void initState() {
    super.initState();
    // Jika dibuka dengan parameter initial lahan, langsung set instan agar form tidak kosong/berkedip
    if (widget.initialLahanId != null) {
      _selectedItemLahan = ItemLahan(
        id: widget.initialLahanId!,
        nama: widget.initialLahanName ?? 'Lahan Terpilih',
        lokasi: '',
        luas: 0.0,
        komoditas: '',
        status: StatusLahan.aktif,
      );
    }
    _fetchLahanList();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchLahanList() async {
    setState(() => _isLoadingLahan = true);
    final response = await _lahanService.getLahanList();
    if (!mounted) return;

    if (response.success && response.data != null && response.data!.isNotEmpty) {
      final list = response.data!;
      ItemLahan? preselected;
      if (widget.initialLahanId != null) {
        final targetId = widget.initialLahanId!.trim().toLowerCase();
        final targetName = widget.initialLahanName?.trim().toLowerCase();
        preselected = list.cast<ItemLahan?>().firstWhere(
          (l) => l != null && (
            l.id.trim().toLowerCase() == targetId ||
            (targetName != null && targetName.isNotEmpty && l.nama.trim().toLowerCase() == targetName)
          ),
          orElse: () => _selectedItemLahan ?? list.first,
        );
      } else {
        preselected = _selectedItemLahan ?? list.first;
      }

      setState(() {
        _lahanList = list;
        _selectedItemLahan = preselected;
        _isLoadingLahan = false;
      });
    } else {
      setState(() {
        _isLoadingLahan = false;
      });
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatDateIso(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m WIB';
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (picked == null || !mounted) return;

      final bytes = await picked.readAsBytes();
      setState(() {
        _selectedPhotoBytes = bytes;
        _selectedPhotoName = picked.name;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih foto: $e'),
          backgroundColor: WarnaAplikasi.errorRedDark,
        ),
      );
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: WarnaAplikasi.outlineGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Dokumentasi Foto Aktivitas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: WarnaAplikasi.primaryDark,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: WarnaAplikasi.primary),
                  title: const Text('Ambil dari Kamera', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickPhoto(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: WarnaAplikasi.primary),
                  title: const Text('Pilih dari Galeri', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickPhoto(ImageSource.gallery);
                  },
                ),
                if (_selectedPhotoBytes != null)
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: WarnaAplikasi.errorRedDark),
                    title: const Text('Hapus Foto', style: TextStyle(color: WarnaAplikasi.errorRedDark, fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _selectedPhotoBytes = null;
                        _selectedPhotoName = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSave() async {
    if (_selectedItemLahan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih petak lahan terlebih dahulu.'),
          backgroundColor: WarnaAplikasi.errorRedDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final payload = <String, dynamic>{
        'id_lahan': _selectedItemLahan!.id,
        'kategori': _selectedCategory.name,
        'judul': _selectedCategory.label,
        'kondisi_tanaman': _selectedCondition.name,
        'tanggal': _formatDateIso(_selectedDate),
        'waktu': _formatTime(_selectedTime),
        'catatan': _notesController.text.trim().isEmpty
            ? 'Aktivitas rutin ${_selectedCategory.label.toLowerCase()} pada petak lahan.'
            : _notesController.text.trim(),
        'hari_setelah_tanam': 30,
      };

      MultipartFile? file;
      if (_selectedPhotoBytes != null) {
        file = MultipartFile.fromBytes(
          _selectedPhotoBytes!,
          filename: _selectedPhotoName ?? 'aktivitas.jpg',
        );
      }

      final response = await _aktivitasService.createAktivitas(payload, fotoAktivitas: file);

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (response.success && response.data != null) {
        final savedItem = response.data!;
        widget.onSave?.call(savedItem);

        ActivitySuccessDialog.show(
          context,
          item: savedItem,
          onGoToHistory: () {
            Navigator.pop(context); // close dialog
            Navigator.pop(context, true); // return success to list
          },
          onBackToList: () {
            Navigator.pop(context); // close dialog
            Navigator.pop(context, true); // return success
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message.isNotEmpty
                ? response.message
                : 'Gagal mencatat aktivitas. Periksa kembali koneksi.'),
            backgroundColor: WarnaAplikasi.errorRedDark,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: WarnaAplikasi.errorRedDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarnaAplikasi.primaryBackground,
      appBar: const PawonFormHeader(
        title: 'Catat Aktivitas',
        subtitle: 'Dokumentasikan aktivitas dan kondisi lahan Anda',
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Info Banner: Catatan Harian Sawah
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: WarnaAplikasi.greenLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: WarnaAplikasi.bannerIconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.spa_rounded,
                      color: WarnaAplikasi.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Catatan Harian Lahan',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: WarnaAplikasi.primaryDark,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Dokumentasikan aktivitas harian untuk mempermudah pemantauan tanaman.',
                          style: TextStyle(
                            fontSize: 11,
                            color: WarnaAplikasi.textDarkGrayGreen,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 1. Lahan*
            _buildFieldLabel('Petak Lahan*'),
            const SizedBox(height: 8),
            if (_isLoadingLahan && _selectedItemLahan == null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: WarnaAplikasi.borderField),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 12),
                    Text('Memuat daftar lahan Anda...', style: TextStyle(fontSize: 12, color: WarnaAplikasi.textGrayGreen)),
                  ],
                ),
              )
            else
              InkWell(
                onTap: _showLahanPicker,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: WarnaAplikasi.borderField),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: WarnaAplikasi.greenLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.holiday_village_outlined,
                          color: WarnaAplikasi.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedItemLahan?.nama ?? (widget.initialLahanName ?? 'Belum ada lahan'),
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: WarnaAplikasi.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              _selectedItemLahan != null && _selectedItemLahan!.luas > 0
                                  ? '${_selectedItemLahan!.luas.toStringAsFixed(2)} Ha • ${_selectedItemLahan!.komoditas.isNotEmpty ? _selectedItemLahan!.komoditas : 'Pertanian'}'
                                  : (_isLoadingLahan ? 'Menyelaraskan data lahan...' : 'Petak Lahan Terpilih'),
                              style: const TextStyle(
                                fontSize: 11,
                                color: WarnaAplikasi.textGrayGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isLoadingLahan)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: WarnaAplikasi.primary),
                        )
                      else
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: WarnaAplikasi.textGrayGreen,
                          size: 22,
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // 2. Tanggal & Waktu
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Tanggal*'),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) setState(() => _selectedDate = picked);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: WarnaAplikasi.borderField),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 16, color: WarnaAplikasi.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _formatDate(_selectedDate),
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: WarnaAplikasi.primaryDark),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Waktu*'),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime,
                          );
                          if (picked != null) setState(() => _selectedTime = picked);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: WarnaAplikasi.borderField),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time_rounded, size: 16, color: WarnaAplikasi.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _formatTime(_selectedTime),
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: WarnaAplikasi.primaryDark),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 3. Jenis Aktivitas*
            _buildFieldLabel('Jenis Aktivitas*'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ActivityCategory.values.map((cat) {
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat.label),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                  selectedColor: WarnaAplikasi.primary,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : WarnaAplikasi.primaryDark,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? WarnaAplikasi.primary : WarnaAplikasi.outlineGray,
                    ),
                  ),
                  showCheckmark: false,
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 4. Kondisi Tanaman*
            _buildFieldLabel('Kondisi Tanaman*'),
            const SizedBox(height: 8),
            _buildConditionOption(
              condition: PlantCondition.sehat,
              icon: Icons.check_circle_outline_rounded,
              iconColor: const Color(0xFF16A34A),
              iconBg: const Color(0xFFDCFCE7),
              title: 'Sehat & Normal',
              subtitle: 'Pertumbuhan optimal, daun hijau segar, bebas hama',
            ),
            const SizedBox(height: 8),
            _buildConditionOption(
              condition: PlantCondition.perluPerhatian,
              icon: Icons.change_history_rounded,
              iconColor: const Color(0xFFD97706),
              iconBg: const Color(0xFFFEF3C7),
              title: 'Perlu Perhatian',
              subtitle: 'Kekurangan air/pupuk, daun agak menguning atau kerdil',
            ),
            const SizedBox(height: 8),
            _buildConditionOption(
              condition: PlantCondition.terserangHama,
              icon: Icons.warning_amber_rounded,
              iconColor: const Color(0xFFDC2626),
              iconBg: const Color(0xFFFEE2E2),
              title: 'Terserang Hama/Penyakit',
              subtitle: 'Gejala wereng, ulat, blast atau bercak coklat tampak jelas',
            ),
            const SizedBox(height: 20),

            // 5. Catatan / Keterangan
            _buildFieldLabel('Catatan Aktivitas'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: WarnaAplikasi.borderField),
              ),
              child: TextField(
                controller: _notesController,
                maxLines: 3,
                maxLength: 250,
                style: const TextStyle(fontSize: 13, color: WarnaAplikasi.primaryDark),
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: 'Contoh: Pemupukan NPK 50 kg dan pembersihan gulma...',
                  hintStyle: TextStyle(fontSize: 12.5, color: WarnaAplikasi.iconGray),
                  contentPadding: EdgeInsets.all(14),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 6. Foto Dokumentasi
            _buildFieldLabel('Dokumentasi Foto (Opsional)'),
            const SizedBox(height: 8),
            InkWell(
              onTap: _showPhotoOptions,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: WarnaAplikasi.photoUploadBorder,
                    width: 1.2,
                  ),
                ),
                child: _selectedPhotoBytes != null
                    ? Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              _selectedPhotoBytes!,
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.edit_outlined, size: 16, color: WarnaAplikasi.primary),
                              SizedBox(width: 4),
                              Text('Ganti Foto', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WarnaAplikasi.primary)),
                            ],
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: WarnaAplikasi.greenLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: WarnaAplikasi.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '+ Tambah Foto',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: WarnaAplikasi.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Kamera atau Galeri (Maks 10MB)',
                            style: TextStyle(fontSize: 10.5, color: WarnaAplikasi.textGrayGreen),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 32),

            // Bottom Buttons
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: WarnaAplikasi.dialogText,
                        side: const BorderSide(color: WarnaAplikasi.outlineGray),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Batal', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _handleSave,
                      icon: _isSaving
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.check_circle_outline_rounded, size: 18),
                      label: Text(
                        _isSaving ? 'Menyimpan...' : 'Simpan Aktivitas',
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WarnaAplikasi.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: WarnaAplikasi.primaryDark,
      ),
    );
  }

  Widget _buildConditionOption({
    required PlantCondition condition,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedCondition == condition;

    return InkWell(
      onTap: () => setState(() => _selectedCondition = condition),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? WarnaAplikasi.primary : WarnaAplikasi.iconGray,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: WarnaAplikasi.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: WarnaAplikasi.textGrayGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? WarnaAplikasi.primary : WarnaAplikasi.iconGray,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: WarnaAplikasi.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _showLahanPicker() {
    if (_lahanList.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: WarnaAplikasi.outlineGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pilih Petak Lahan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: WarnaAplikasi.primaryDark),
              ),
              const SizedBox(height: 12),
              ..._lahanList.map((lahan) {
                final isCurrent = _selectedItemLahan?.id == lahan.id;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: WarnaAplikasi.greenLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.holiday_village_outlined, color: WarnaAplikasi.primary),
                  ),
                  title: Text(lahan.nama, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                  subtitle: Text('${lahan.luas.toStringAsFixed(2)} Ha • ${lahan.komoditas.isNotEmpty ? lahan.komoditas : 'Pertanian'}', style: const TextStyle(fontSize: 11.5, color: WarnaAplikasi.textGrayGreen)),
                  trailing: isCurrent ? const Icon(Icons.check_circle, color: WarnaAplikasi.primary) : null,
                  onTap: () {
                    setState(() {
                      _selectedItemLahan = lahan;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
