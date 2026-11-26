import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/core/widgets/pawon_form_header.dart';
import 'package:pawon_mobile/features/aktivitas/models/item_aktivitas_tanam.dart';
import 'package:pawon_mobile/features/aktivitas/services/aktivitas_api_service.dart';
import 'package:pawon_mobile/features/aktivitas/widgets/dialog_hapus_aktivitas.dart';
import 'package:pawon_mobile/features/lahan/models/item_lahan.dart';
import 'package:pawon_mobile/features/lahan/services/lahan_api_service.dart';

class EditActivityScreen extends StatefulWidget {
  final PlantActivityItem item;
  final Function(PlantActivityItem)? onUpdate;
  final Function(String)? onDelete;

  const EditActivityScreen({
    super.key,
    required this.item,
    this.onUpdate,
    this.onDelete,
  });

  @override
  State<EditActivityScreen> createState() => _EditActivityScreenState();
}

class _EditActivityScreenState extends State<EditActivityScreen> {
  final LahanApiService _lahanService = LahanApiService();
  final AktivitasApiService _aktivitasService = AktivitasApiService();

  List<ItemLahan> _lahanList = [];
  ItemLahan? _selectedItemLahan;
  bool _isLoadingLahan = true;
  bool _isSaving = false;
  bool _isDeleting = false;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late ActivityCategory _selectedCategory;
  late PlantCondition _selectedCondition;
  late TextEditingController _notesController;

  final List<String> _keptOldPhotos = [];
  final List<Uint8List> _selectedPhotoBytesList = [];
  final List<String> _selectedPhotoNamesList = [];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.item.category;
    _selectedCondition = widget.item.condition;
    _notesController = TextEditingController(text: widget.item.notes);
    _keptOldPhotos
      ..clear()
      ..addAll(widget.item.photos.where((p) => p.trim().isNotEmpty));
    if (_keptOldPhotos.isEmpty && widget.item.imageUrl != null && widget.item.imageUrl!.trim().isNotEmpty) {
      _keptOldPhotos.add(widget.item.imageUrl!);
    }

    // Parse existing date/time or default to now
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();

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
      ItemLahan? matched;
      if (widget.item.lahanId != null) {
        matched = list.firstWhere((l) => l.id == widget.item.lahanId, orElse: () => list.first);
      } else {
        matched = list.firstWhere(
          (l) => l.nama.toLowerCase() == widget.item.location.toLowerCase(),
          orElse: () => list.first,
        );
      }

      setState(() {
        _lahanList = list;
        _selectedItemLahan = matched;
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
                  'Tambah Foto Aktivitas',
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
    setState(() => _isSaving = true);

    try {
      final payload = <String, dynamic>{
        'kategori': _selectedCategory.name,
        'judul': _selectedCategory.label,
        'kondisi_tanaman': _selectedCondition.name,
        'tanggal': _formatDateIso(_selectedDate),
        'waktu': _formatTime(_selectedTime),
        'catatan': _notesController.text.trim(),
        'existing_photos': List<String>.from(_keptOldPhotos),
      };

      if (_selectedItemLahan != null) {
        payload['id_lahan'] = _selectedItemLahan!.id;
      }

      final List<MultipartFile> photoFiles = [];
      for (int i = 0; i < _selectedPhotoBytesList.length; i++) {
        final name = i < _selectedPhotoNamesList.length
            ? _selectedPhotoNamesList[i]
            : 'aktivitas_$i.jpg';
        photoFiles.add(MultipartFile.fromBytes(_selectedPhotoBytesList[i], filename: name));
      }

      final response = await _aktivitasService.updateAktivitas(
        widget.item.id,
        payload,
        fotoAktivitas: null,
        fotoAktivitasList: photoFiles.isEmpty ? null : photoFiles,
      );

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (response.success && response.data != null) {
        final updated = response.data!;
        widget.onUpdate?.call(updated);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perubahan aktivitas berhasil disimpan!'),
            backgroundColor: WarnaAplikasi.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, updated);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message.isNotEmpty
                ? response.message
                : 'Gagal memperbarui aktivitas.'),
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

  void _handleDelete() {
    DeleteActivityDialog.show(
      context,
      item: widget.item,
      onConfirmDelete: () async {
        setState(() => _isDeleting = true);
        final response = await _aktivitasService.deleteAktivitas(widget.item.id);
        if (!mounted) return;
        setState(() => _isDeleting = false);

        if (response.success) {
          widget.onDelete?.call(widget.item.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Catatan aktivitas berhasil dihapus.'),
              backgroundColor: WarnaAplikasi.errorRedDark,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, 'deleted');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message.isNotEmpty ? response.message : 'Gagal menghapus aktivitas.'),
              backgroundColor: WarnaAplikasi.errorRedDark,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
    final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.borderField;
    final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.primaryDark;
    final subtitleColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGrayGreen;

    return Scaffold(
      backgroundColor: WarnaAplikasi.getBackgroundColor(context),
      appBar: const PawonFormHeader(
        title: 'Edit Aktivitas',
        subtitle: 'Perbarui rincian aktivitas dan catatan lahan',
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Lahan
            _buildFieldLabel('Petak Lahan*'),
            const SizedBox(height: 8),
            if (_isLoadingLahan)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                    const SizedBox(width: 12),
                    Text('Memuat data lahan...', style: TextStyle(fontSize: 12, color: subtitleColor)),
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
                              _selectedItemLahan?.nama ?? widget.item.location,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              _selectedItemLahan != null
                                  ? '${_selectedItemLahan!.luas.toStringAsFixed(2)} Ha • ${_selectedItemLahan!.komoditas.isNotEmpty ? _selectedItemLahan!.komoditas : 'Pertanian'}'
                                  : widget.item.blockArea,
                              style: TextStyle(
                                fontSize: 11,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: subtitleColor,
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

            // 3. Jenis Aktivitas
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

            // 4. Kondisi Tanaman
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

            // 5. Catatan
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
                  hintText: 'Tuliskan catatan detail aktivitas...',
                  hintStyle: TextStyle(fontSize: 12.5, color: subtitleColor),
                  contentPadding: const EdgeInsets.all(14),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 6. Foto Dokumentasi
            _buildFieldLabel('Dokumentasi Foto'),
            const SizedBox(height: 8),
            if (_keptOldPhotos.isNotEmpty) ...[
              const Text('Foto Tersimpan:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: WarnaAplikasi.textGrayGreen)),
              const SizedBox(height: 6),
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _keptOldPhotos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, index) {
                    final url = _keptOldPhotos[index];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            url,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 90,
                              height: 90,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => setState(() => _keptOldPhotos.removeAt(index)),
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
            if (_selectedPhotoBytesList.isNotEmpty) ...[
              const Text('Foto Baru yang Akan Ditambahkan:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: WarnaAplikasi.textGrayGreen)),
              const SizedBox(height: 6),
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
                      'Tambah Foto Aktivitas (${_keptOldPhotos.length + _selectedPhotoBytesList.length} Foto)',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WarnaAplikasi.primary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Tombol Simpan Perubahan & Hapus
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _handleSave,
                icon: _isSaving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: Text(
                  _isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
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
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: (_isSaving || _isDeleting) ? null : _handleDelete,
                icon: _isDeleting
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: WarnaAplikasi.errorRedDark, strokeWidth: 2))
                    : const Icon(Icons.delete_outline, color: WarnaAplikasi.errorRedDark, size: 18),
                label: Text(
                  _isDeleting ? 'Menghapus...' : 'Hapus Aktivitas',
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: WarnaAplikasi.errorRedDark),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                  backgroundColor: const Color(0xFFFEF2F2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
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
