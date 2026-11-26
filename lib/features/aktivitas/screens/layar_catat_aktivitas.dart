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
import 'package:pawon_mobile/features/lahan/models/item_siklus_tanam.dart';
import 'package:pawon_mobile/features/lahan/services/lahan_api_service.dart';

class RecordActivityScreen extends StatefulWidget {
  final Function(PlantActivityItem)? onSave;
  final String? initialLahanId;
  final String? initialLahanName;
  final ItemSiklusTanam? initialSiklus;

  const RecordActivityScreen({
    super.key,
    this.onSave,
    this.initialLahanId,
    this.initialLahanName,
    this.initialSiklus,
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

  // Siklus Tanam selection & validation (Phase 3)
  ItemSiklusTanam? _activeSiklus;
  bool _isLoadingSiklus = false;

  // Date & Time (Default to Now)
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // Category
  ActivityCategory _selectedCategory = ActivityCategory.pemupukan;

  // Condition
  PlantCondition _selectedCondition = PlantCondition.sehat;

  // Notes
  final TextEditingController _notesController = TextEditingController();

  // Photo (Multiple Support)
  final List<Uint8List> _selectedPhotoBytesList = [];
  final List<String> _selectedPhotoNamesList = [];

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
    if (widget.initialSiklus != null) {
      _activeSiklus = widget.initialSiklus;
    }
    _fetchLahanList();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchSiklusForSelectedLahan(String lahanId) async {
    setState(() => _isLoadingSiklus = true);
    try {
      final response = await _lahanService.getSiklusBerjalan(lahanId);
      if (!mounted) return;
      setState(() {
        _activeSiklus = response.data;
        _isLoadingSiklus = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingSiklus = false);
    }
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

      if (widget.initialSiklus != null && preselected?.id == widget.initialLahanId) {
        setState(() => _activeSiklus = widget.initialSiklus);
      } else if (preselected != null) {
        _fetchSiklusForSelectedLahan(preselected.id);
      }
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
      if (source == ImageSource.gallery) {
        final pickedList = await picker.pickMultiImage(
          imageQuality: 80,
          maxWidth: 1200,
        );
        if (pickedList.isEmpty) return;
        for (final p in pickedList) {
          final bytes = await p.readAsBytes();
          if (!mounted) return;
          setState(() {
            _selectedPhotoBytesList.add(bytes);
            _selectedPhotoNamesList.add(p.name);
          });
        }
        return;
      }

      final picked = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (picked == null || !mounted) return;

      final bytes = await picked.readAsBytes();
      setState(() {
        _selectedPhotoBytesList.add(bytes);
        _selectedPhotoNamesList.add(picked.name);
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
                  subtitle: const Text('Bisa pilih beberapa foto sekaligus', style: TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayLight)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickPhoto(ImageSource.gallery);
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

    if (_activeSiklus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Petak lahan belum memiliki siklus tanam aktif. Silakan mulai siklus tanam terlebih dahulu.'),
          backgroundColor: WarnaAplikasi.errorRedDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_activeSiklus!.isAktif) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Siklus tanam sedang ${_activeSiklus!.statusLabel} dan tidak dapat menerima aktivitas baru.'),
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
        'id_siklus': _activeSiklus!.idSiklus,
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

      final List<MultipartFile> photoFiles = [];
      for (int i = 0; i < _selectedPhotoBytesList.length; i++) {
        final name = i < _selectedPhotoNamesList.length
            ? _selectedPhotoNamesList[i]
            : 'aktivitas_$i.jpg';
        photoFiles.add(MultipartFile.fromBytes(_selectedPhotoBytesList[i], filename: name));
      }

      final response = await _aktivitasService.createAktivitas(
        payload,
        fotoAktivitas: null,
        fotoAktivitasList: photoFiles.isEmpty ? null : photoFiles,
      );

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
    final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.borderField;
    final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.primaryDark;
    final subtitleColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGrayGreen;
    final bannerBg = isDark ? const Color(0xFF1B261F) : WarnaAplikasi.greenLight;

    return Scaffold(
      backgroundColor: WarnaAplikasi.getBackgroundColor(context),
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
                color: bannerBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF283A2E) : WarnaAplikasi.bannerIconBg,
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
                      children: [
                        Text(
                          'Catatan Harian Lahan',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Dokumentasikan aktivitas harian untuk mempermudah pemantauan tanaman.',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? const Color(0xFFD4E0D7) : WarnaAplikasi.textDarkGrayGreen,
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
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
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
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF283A2E) : WarnaAplikasi.greenLight,
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
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              _selectedItemLahan != null && _selectedItemLahan!.luas > 0
                                  ? '${_selectedItemLahan!.luas.toStringAsFixed(2)} Ha • ${_selectedItemLahan!.komoditas.isNotEmpty ? _selectedItemLahan!.komoditas : 'Pertanian'}'
                                  : (_isLoadingLahan ? 'Menyelaraskan data lahan...' : 'Petak Lahan Terpilih'),
                              style: TextStyle(
                                fontSize: 11,
                                color: subtitleColor,
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
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: subtitleColor,
                          size: 22,
                        ),
                    ],
                  ),
                ),
              ),
            _buildSiklusBanner(),
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
                            color: cardBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 16, color: WarnaAplikasi.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _formatDate(_selectedDate),
                                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: titleColor),
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
                            color: cardBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time_rounded, size: 16, color: WarnaAplikasi.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _formatTime(_selectedTime),
                                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: titleColor),
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
                  backgroundColor: cardBg,
                  labelStyle: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : (isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.primaryDark),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? WarnaAplikasi.primary : borderColor,
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
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: TextField(
                controller: _notesController,
                maxLines: 3,
                maxLength: 250,
                style: TextStyle(fontSize: 13, color: titleColor),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Contoh: Pemupukan NPK 50 kg dan pembersihan gulma...',
                  hintStyle: TextStyle(fontSize: 12.5, color: subtitleColor),
                  contentPadding: const EdgeInsets.all(14),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 6. Foto Dokumentasi
            _buildFieldLabel('Dokumentasi Foto (Opsional)'),
            const SizedBox(height: 8),
            if (_selectedPhotoBytesList.isNotEmpty) ...[
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _selectedPhotoBytesList.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _selectedPhotoBytesList[index],
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _selectedPhotoBytesList.removeAt(index);
                              if (index < _selectedPhotoNamesList.length) {
                                _selectedPhotoNamesList.removeAt(index);
                              }
                            }),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), shape: BoxShape.circle),
                              child: const Icon(Icons.close, color: Colors.white, size: 12),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
            InkWell(
              onTap: _showPhotoOptions,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: WarnaAplikasi.bgPaleGreen3,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: WarnaAplikasi.borderPale2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_a_photo_outlined, size: 18, color: WarnaAplikasi.primary),
                    const SizedBox(width: 8),
                    Text(
                      _selectedPhotoBytesList.isEmpty ? 'Tambah Foto Dokumentasi' : 'Tambah Foto Lainnya (${_selectedPhotoBytesList.length} terpilih)',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WarnaAplikasi.primary),
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

  Widget _buildSiklusBanner() {
    if (_isLoadingSiklus) {
      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: WarnaAplikasi.primaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: WarnaAplikasi.borderField),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: WarnaAplikasi.primary),
            ),
            SizedBox(width: 10),
            Text(
              'Memeriksa status siklus tanam aktif...',
              style: TextStyle(fontSize: 11.5, color: WarnaAplikasi.textGrayGreen),
            ),
          ],
        ),
      );
    }

    if (_activeSiklus == null) {
      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: WarnaAplikasi.bgErrorLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: WarnaAplikasi.errorBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber_rounded, color: WarnaAplikasi.errorRedDark, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Belum Ada Siklus Tanam Aktif',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WarnaAplikasi.errorRedDark),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Aktivitas pertanian harus terikat pada siklus tanam yang aktif. Silakan mulai siklus tanam terlebih dahulu di menu Detail Lahan.',
                    style: TextStyle(fontSize: 11, color: WarnaAplikasi.errorRedDark, height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (!_activeSiklus!.isAktif) {
      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: WarnaAplikasi.statusTempoBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: WarnaAplikasi.warningOrange.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded, color: WarnaAplikasi.warningOrange, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Siklus Berstatus ${_activeSiklus!.statusLabel}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WarnaAplikasi.warningOrange),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Siklus ini sedang dalam proses pengakhiran dan tidak dapat menerima aktivitas baru.',
                    style: TextStyle(fontSize: 11, color: WarnaAplikasi.textDarkGrayGreen, height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Active cycle
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: WarnaAplikasi.greenLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WarnaAplikasi.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.eco_rounded, color: WarnaAplikasi.primary, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Siklus Aktif: ${_activeSiklus!.komoditasNama.isNotEmpty ? _activeSiklus!.komoditasNama : (_selectedItemLahan?.komoditas ?? "Pertanian")}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark),
                ),
                const SizedBox(height: 1),
                Text(
                  'Mulai: ${_activeSiklus!.tanggalMulaiFormatted} • Target: ${_activeSiklus!.targetPanenTon != null ? "${_activeSiklus!.targetPanenTon} ton" : "-"}',
                  style: const TextStyle(fontSize: 10.5, color: WarnaAplikasi.textGrayGreen),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: WarnaAplikasi.bgSuccessLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Aktif',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: WarnaAplikasi.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Builder(builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.primaryDark,
        ),
      );
    });
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

    return Builder(builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
      final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.iconGray;
      final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.primaryDark;
      final subtitleColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGrayGreen;

      return InkWell(
        onTap: () => setState(() => _selectedCondition = condition),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? WarnaAplikasi.primary : borderColor,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? iconColor.withValues(alpha: 0.2) : iconBg,
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
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: subtitleColor,
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
                    color: isSelected ? WarnaAplikasi.primary : (isDark ? const Color(0xFF4B6653) : WarnaAplikasi.iconGray),
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
    });
  }

  void _showLahanPicker() {
    if (_lahanList.isEmpty) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
    final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.primaryDark;
    final subtitleColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGrayGreen;

    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
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
                    color: isDark ? const Color(0xFF3B4A40) : WarnaAplikasi.outlineGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pilih Petak Lahan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: titleColor),
              ),
              const SizedBox(height: 12),
              ..._lahanList.map((lahan) {
                final isCurrent = _selectedItemLahan?.id == lahan.id;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF283A2E) : WarnaAplikasi.greenLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.holiday_village_outlined, color: WarnaAplikasi.primary),
                  ),
                  title: Text(lahan.nama, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: titleColor)),
                  subtitle: Text('${lahan.luas.toStringAsFixed(2)} Ha • ${lahan.komoditas.isNotEmpty ? lahan.komoditas : 'Pertanian'}', style: TextStyle(fontSize: 11.5, color: subtitleColor)),
                  trailing: isCurrent ? const Icon(Icons.check_circle, color: WarnaAplikasi.primary) : null,
                  onTap: () {
                    setState(() {
                      _selectedItemLahan = lahan;
                    });
                    Navigator.pop(context);
                    _fetchSiklusForSelectedLahan(lahan.id);
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
