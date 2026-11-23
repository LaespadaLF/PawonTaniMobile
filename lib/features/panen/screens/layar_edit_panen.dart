import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawon_mobile/core/constants/api_constants.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/core/widgets/pawon_form_header.dart';
import 'package:pawon_mobile/features/lahan/models/item_lahan.dart';
import 'package:pawon_mobile/features/lahan/services/lahan_api_service.dart';
import 'package:pawon_mobile/features/panen/models/item_panen.dart';
import 'package:pawon_mobile/features/panen/services/panen_api_service.dart';
import 'package:pawon_mobile/features/panen/services/panen_multipart.dart';
import 'package:pawon_mobile/features/panen/widgets/dialog_hapus_panen.dart';

class EditHarvestScreen extends StatefulWidget {
  final HarvestItem item;
  final Function(HarvestItem) onSave;
  final VoidCallback onDelete;

  const EditHarvestScreen({
    super.key,
    required this.item,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<EditHarvestScreen> createState() => _EditHarvestScreenState();
}

class _EditHarvestScreenState extends State<EditHarvestScreen> {
  final LahanApiService _lahanService = LahanApiService();
  final PanenApiService _panenService = PanenApiService();

  List<ItemLahan> _lahanList = [];
  ItemLahan? _selectedItemLahan;
  bool _isLoadingLahan = true;
  bool _isSaving = false;

  late CropType _cropType;
  late String _commodity;
  late TextEditingController _varietasController;
  late DateTime _harvestDate;
  late String _harvestTime;

  late TextEditingController _weightController;
  int _selectedUnitIndex = 0; // 0: Kg, 1: Ton, 2: Kuintal

  final TextEditingController _moistureController = TextEditingController();
  final TextEditingController _wholeGrainController = TextEditingController();
  final TextEditingController _wasteController = TextEditingController();

  int _selectedHarvestMethod = 0;
  late TextEditingController _costController;
  late TextEditingController _workersController;
  late TextEditingController _priceController;
  late TextEditingController _notesController;

  final List<Uint8List> _selectedPhotoBytesList = [];
  final List<String> _selectedPhotoNamesList = [];

  /// Foto lama (path/URL dari server) yang masih dipertahankan saat disimpan.
  final List<String> _keptOldPhotos = [];

  @override
  void initState() {
    super.initState();
    _keptOldPhotos
      ..clear()
      ..addAll(widget.item.photos.where((p) => p.trim().isNotEmpty));
    _cropType = widget.item.cropType;
    _commodity = widget.item.subtitle;
    _varietasController = TextEditingController(text: widget.item.title);
    _harvestDate = DateTime.tryParse(widget.item.date) ?? DateTime.now();
    _harvestTime = widget.item.harvestTime;

    _weightController = TextEditingController(text: widget.item.weightKg.toInt().toString());
    _costController = TextEditingController(text: widget.item.harvestCost.toInt().toString());
    _workersController = TextEditingController(text: widget.item.costWorkers);
    _priceController = TextEditingController(text: widget.item.pricePerKg.toInt().toString());
    _notesController = TextEditingController(text: widget.item.fieldNotes);

    _moistureController.text = widget.item.moisturePercent.toString();
    _wholeGrainController.text = widget.item.wholeGrainPercent.toString();
    _wasteController.text = widget.item.wastePercent.toString();

    if (widget.item.harvestMethod.toLowerCase().contains('manual') ||
        widget.item.harvestMethod.toLowerCase().contains('sabit')) {
      _selectedHarvestMethod = 1;
    } else {
      _selectedHarvestMethod = 0;
    }

    _fetchLahanList();
  }

  @override
  void dispose() {
    _varietasController.dispose();
    _weightController.dispose();
    _costController.dispose();
    _workersController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    _moistureController.dispose();
    _wholeGrainController.dispose();
    _wasteController.dispose();
    super.dispose();
  }

  Future<void> _fetchLahanList() async {
    setState(() => _isLoadingLahan = true);
    final response = await _lahanService.getLahanList();
    if (!mounted) return;

    if (response.success && response.data != null && response.data!.isNotEmpty) {
      final list = response.data!;
      ItemLahan? matched;
      if (widget.item.idLahan.isNotEmpty) {
        matched = list.cast<ItemLahan?>().firstWhere(
              (l) => l != null && l.id == widget.item.idLahan,
              orElse: () => null,
            );
      }
      matched ??= list.cast<ItemLahan?>().firstWhere(
            (l) => l != null && l.nama.toLowerCase() == widget.item.location.toLowerCase(),
            orElse: () => list.first,
          );

      setState(() {
        _lahanList = list;
        _selectedItemLahan = matched;
        _isLoadingLahan = false;
      });
    } else {
      setState(() => _isLoadingLahan = false);
    }
  }

  double get _currentWeightKg {
    final rawText = _weightController.text.replaceAll('.', '').replaceAll(',', '.').trim();
    final val = double.tryParse(rawText) ?? widget.item.weightKg;
    if (_selectedUnitIndex == 0) return val;
    if (_selectedUnitIndex == 1) return val * 1000.0;
    return val * 100.0;
  }

  double get _currentTon => _currentWeightKg / 1000.0;
  double get _currentKuintal => _currentWeightKg / 100.0;

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: WarnaAplikasi.primary),
              title: const Text('Kamera Langsung'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: WarnaAplikasi.primary),
              title: const Text('Pilih dari Galeri (Bisa Banyak)'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      if (source == ImageSource.gallery) {
        final images = await picker.pickMultiImage(imageQuality: 85, maxWidth: 1280);
        if (images.isNotEmpty) {
          for (final img in images) {
            final bytes = await img.readAsBytes();
            setState(() {
              _selectedPhotoBytesList.add(bytes);
              _selectedPhotoNamesList.add(img.name);
            });
          }
        }
      } else {
        final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 85, maxWidth: 1280);
        if (image != null) {
          final bytes = await image.readAsBytes();
          setState(() {
            _selectedPhotoBytesList.add(bytes);
            _selectedPhotoNamesList.add(image.name);
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih foto: $e'), backgroundColor: WarnaAplikasi.errorRedDark),
      );
    }
  }

  Future<void> _saveChanges() async {
    if (_currentWeightKg <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berat hasil panen harus lebih dari 0.'), backgroundColor: WarnaAplikasi.errorRedDark),
      );
      return;
    }

    setState(() => _isSaving = true);

    final qualityGrade = widget.item.qualityGrade.isNotEmpty ? widget.item.qualityGrade : 'Grade A / Super';

    final harvestMethod = _selectedHarvestMethod == 0
        ? 'Mesin Combine Harvester'
        : 'Manual / Sabit & Thresher';

    final dateIso = '${_harvestDate.year}-${_harvestDate.month.toString().padLeft(2, '0')}-${_harvestDate.day.toString().padLeft(2, '0')}';
    final rawCost = _costController.text.replaceAll('.', '').replaceAll(',', '.').trim();
    final rawPrice = _priceController.text.replaceAll('.', '').replaceAll(',', '.').trim();

    final payload = <String, dynamic>{
      if (_selectedItemLahan != null) 'id_lahan': _selectedItemLahan!.id,
      'komoditas_nama': _cropType.displayName,
      'varietas': _varietasController.text.trim().isNotEmpty ? _varietasController.text.trim() : widget.item.title,
      'jenis_panen': _commodity,
      'tanggal_panen': dateIso,
      'waktu_panen': _harvestTime,
      'musim_tanam': widget.item.season,
      'berat_kg': _currentWeightKg,
      'kualitas_grade': qualityGrade,
      'kadar_air': double.tryParse(_moistureController.text) ?? widget.item.moisturePercent,
      'persen_butir_utuh': double.tryParse(_wholeGrainController.text) ?? widget.item.wholeGrainPercent,
      'persen_hampa_kotoran': double.tryParse(_wasteController.text) ?? widget.item.wastePercent,
      'metode_panen': harvestMethod,
      'biaya_panen': double.tryParse(rawCost) ?? widget.item.harvestCost,
      'keterangan_tenaga_kerja': _workersController.text.trim(),
      'harga_per_kg': double.tryParse(rawPrice) ?? widget.item.pricePerKg,
      'catatan': _notesController.text.trim(),
      // Foto lama yang masih dipertahankan; backend menghapus berkas yang
      // tidak lagi ada di daftar ini lalu menggabungkannya dengan foto baru.
      'existing_photos': List<String>.from(_keptOldPhotos),
    };

    // Bila pengguna tidak memilih foto baru, keduanya dikirim null supaya
    // backend tidak menjalankan validasi unggah berkas sama sekali.
    final List<MultipartFile> photoFiles = _selectedPhotoBytesList.isEmpty
        ? const <MultipartFile>[]
        : List<MultipartFile>.generate(_selectedPhotoBytesList.length, (i) {
            final name = i < _selectedPhotoNamesList.length
                ? _selectedPhotoNamesList[i]
                : 'panen_edit_$i.jpg';
            return buatFotoPanen(_selectedPhotoBytesList[i], name);
          });

    try {
      final res = await _panenService.updatePanen(
        widget.item.id,
        payload,
        fotoPanen: null,
        fotoPanenList: photoFiles.isEmpty ? null : photoFiles,
      );
      if (!mounted) return;
      setState(() => _isSaving = false);

      if (res.success && res.data != null) {
        final updated = res.data!;
        widget.onSave(updated);
        Navigator.pop(context, updated);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message.isNotEmpty ? res.message : 'Gagal memperbarui catatan panen.'),
            backgroundColor: WarnaAplikasi.errorRedDark,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: WarnaAplikasi.errorRedDark),
      );
    }
  }

  void _confirmDelete() {
    DeleteHarvestDialog.show(
      context,
      item: widget.item,
      onConfirmDelete: () async {
        final res = await _panenService.deletePanen(widget.item.id);
        if (!mounted) return;
        if (res.success) {
          widget.onDelete();
          Navigator.pop(context, true); // pop edit screen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res.message.isNotEmpty ? res.message : 'Gagal menghapus panen.'),
              backgroundColor: WarnaAplikasi.errorRedDark,
            ),
          );
        }
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
            const PawonFormHeader(
              title: 'Edit Data Panen',
              subtitle: 'Perbarui rincian data hasil panen',
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildModeEditBanner(),
                    const SizedBox(height: 16),
                    _buildLahanGarapanCard(),
                    const SizedBox(height: 16),
                    _buildTanggalWaktuCard(),
                    const SizedBox(height: 16),
                    _buildJumlahPanenCard(),
                    const SizedBox(height: 16),
                    _buildMetodePemanenanCard(),
                    const SizedBox(height: 16),
                    _buildBiayaPetikCard(),
                    const SizedBox(height: 16),
                    _buildCatatanMandorCard(),
                    const SizedBox(height: 16),
                    _buildDokumentasiCard(),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeEditBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: WarnaAplikasi.bgPaleGreen2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: WarnaAplikasi.greenPill),
      ),
      child: const Row(
        children: [
          Icon(Icons.edit_note_rounded, color: WarnaAplikasi.primary, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MODE EDIT HASIL PANEN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: WarnaAplikasi.greenText,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'Perbarui rincian timbangan, varietas, atau catatan sebelum diverifikasi poktan.',
                  style: TextStyle(
                    fontSize: 10.5,
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

  Widget _buildLahanGarapanCard() {
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
                  Icon(Icons.agriculture_rounded, size: 16, color: WarnaAplikasi.primary),
                  SizedBox(width: 6),
                  Text(
                    'Lahan Garapan Terpilih',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: WarnaAplikasi.textDarkGreen,
                    ),
                  ),
                ],
              ),
              if (_lahanList.isNotEmpty)
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                      builder: (ctx) => Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Ganti Petak Lahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: WarnaAplikasi.textDarkGreen)),
                            const SizedBox(height: 12),
                            ..._lahanList.map((lhn) => ListTile(
                                  leading: const Icon(Icons.eco_rounded, color: WarnaAplikasi.primary),
                                  title: Text(lhn.nama),
                                  subtitle: Text('${lhn.luas.toStringAsFixed(2)} Ha • ${lhn.komoditas}'),
                                  onTap: () {
                                    setState(() {
                                      _selectedItemLahan = lhn;
                                      final kom = lhn.komoditas.toLowerCase();
                                      if (kom.contains('jagung')) {
                                        _cropType = CropType.jagung;
                                        _commodity = 'Jagung Pipil Kering (JPK)';
                                      } else {
                                        _cropType = CropType.padi;
                                        _commodity = 'Gabah Kering Panen (GKP)';
                                      }
                                      _varietasController.text = lhn.komoditas.isNotEmpty ? lhn.komoditas : (_cropType == CropType.padi ? 'Padi Ciherang' : 'Jagung Hibrida');
                                    });
                                    Navigator.pop(ctx);
                                  },
                                )),
                          ],
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Ganti Lahan',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: WarnaAplikasi.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: WarnaAplikasi.bgPaleGreen3,
              borderRadius: BorderRadius.circular(14),
            ),
            child: _isLoadingLahan
                ? const Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: WarnaAplikasi.primary),
                      ),
                      SizedBox(width: 8),
                      Text('Memuat daftar lahan...', style: TextStyle(fontSize: 11, color: WarnaAplikasi.textGray)),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _selectedItemLahan?.nama ?? widget.item.location,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: WarnaAplikasi.textDarkGreen,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: WarnaAplikasi.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _selectedItemLahan != null
                            ? '${_selectedItemLahan!.luas.toStringAsFixed(2)} Ha • ${_selectedItemLahan!.komoditas}'
                            : widget.item.blockArea,
                        style: const TextStyle(fontSize: 11, color: WarnaAplikasi.textGray),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTanggalWaktuCard() {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final dateStr = '${_harvestDate.day} ${months[_harvestDate.month - 1]} ${_harvestDate.year}';

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
          const Text(
            'Tanggal & Waktu Panen',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: WarnaAplikasi.textDarkGreen,
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _harvestDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                setState(() => _harvestDate = picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: WarnaAplikasi.bgPaleGreen3,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: WarnaAplikasi.borderField),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '$dateStr • $_harvestTime',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: WarnaAplikasi.textDarkGreen,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_month_outlined,
                    size: 20,
                    color: WarnaAplikasi.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJumlahPanenCard() {
    final unitLabels = ['Kilogram (Kg)', 'Ton', 'Kuintal'];

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
          const Text(
            'Jumlah Hasil Panen',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: WarnaAplikasi.textDarkGreen,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            onChanged: (val) => setState(() {}),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: WarnaAplikasi.primaryDark,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(unitLabels.length, (index) {
              final isSelected = _selectedUnitIndex == index;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index < 2 ? 6 : 0),
                  child: InkWell(
                    onTap: () => setState(() => _selectedUnitIndex = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? WarnaAplikasi.primary : WarnaAplikasi.borderField,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        unitLabels[index],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : WarnaAplikasi.textDarkGreen,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'Setara dengan ${_currentTon.toStringAsFixed(2)} Ton (${_currentKuintal.toStringAsFixed(1)} Kuintal)',
            style: const TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayGreen),
          ),
        ],
      ),
    );
  }

  Widget _buildMetodePemanenanCard() {
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
          const Text('Metode Pemanenan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: WarnaAplikasi.textDarkGreen)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _selectedHarvestMethod = 0),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _selectedHarvestMethod == 0 ? WarnaAplikasi.primary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _selectedHarvestMethod == 0 ? WarnaAplikasi.primary : WarnaAplikasi.borderField),
                    ),
                    child: Text(
                      'Mesin Combine\nHarvester',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _selectedHarvestMethod == 0 ? Colors.white : WarnaAplikasi.textDarkGreen),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _selectedHarvestMethod = 1),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _selectedHarvestMethod == 1 ? WarnaAplikasi.primary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _selectedHarvestMethod == 1 ? WarnaAplikasi.primary : WarnaAplikasi.borderField),
                    ),
                    child: Text(
                      'Manual / Sabit &\nThresher',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _selectedHarvestMethod == 1 ? Colors.white : WarnaAplikasi.textDarkGreen),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBiayaPetikCard() {
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
          const Text('Harga Jual & Biaya Panen', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: WarnaAplikasi.textDarkGreen)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Harga / Kg (Rp)', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _costController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Biaya Panen (Rp)', border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCatatanMandorCard() {
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
          const Text('Catatan Lapangan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: WarnaAplikasi.textDarkGreen)),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Kondisi timbangan, cuaca, dll.'),
          ),
        ],
      ),
    );
  }

  Widget _buildDokumentasiCard() {
    final totalFoto = _keptOldPhotos.length + _selectedPhotoBytesList.length;

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
              const Text(
                'Dokumentasi Panen & Timbangan',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: WarnaAplikasi.textDarkGreen),
              ),
              Text(
                '$totalFoto Foto',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: WarnaAplikasi.primary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Foto lama tetap tersimpan. Ketuk tanda silang pada foto yang ingin dihapus.',
            style: TextStyle(fontSize: 10.5, color: WarnaAplikasi.textGrayGreen, height: 1.3),
          ),
          const SizedBox(height: 12),

          if (totalFoto == 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: WarnaAplikasi.bgPaleGreen3,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: WarnaAplikasi.borderField),
              ),
              child: const Column(
                children: [
                  Icon(Icons.image_not_supported_outlined, size: 22, color: WarnaAplikasi.textGray),
                  SizedBox(height: 6),
                  Text('Belum ada foto bukti panen', style: TextStyle(fontSize: 11, color: WarnaAplikasi.textGray)),
                ],
              ),
            ),

          // Foto Lama yang Tersimpan di Server
          if (_keptOldPhotos.isNotEmpty) ...[
            const Text(
              'Foto Tersimpan:',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: WarnaAplikasi.textGrayGreen),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _keptOldPhotos.length,
                separatorBuilder: (sepCtx, sepIdx) => const SizedBox(width: 8),
                itemBuilder: (ctx, index) {
                  final path = _keptOldPhotos[index];
                  final fullUrl = ApiConstants.resolveImageUrl(path) ?? path;
                  return _fotoThumbnail(
                    image: Image.network(
                      fullUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (eCtx, eObj, eTrace) => const Icon(
                        Icons.broken_image_rounded,
                        color: Colors.grey,
                      ),
                    ),
                    onHapus: () => setState(() => _keptOldPhotos.removeAt(index)),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Foto Baru yang Baru Dipilih (belum diunggah)
          if (_selectedPhotoBytesList.isNotEmpty) ...[
            const Text(
              'Foto Baru yang Akan Ditambahkan:',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: WarnaAplikasi.textGrayGreen),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _selectedPhotoBytesList.length,
                separatorBuilder: (sepCtx, sepIdx) => const SizedBox(width: 8),
                itemBuilder: (ctx, index) {
                  return _fotoThumbnail(
                    image: Image.memory(_selectedPhotoBytesList[index], fit: BoxFit.cover),
                    onHapus: () => setState(() {
                      _selectedPhotoBytesList.removeAt(index);
                      if (index < _selectedPhotoNamesList.length) {
                        _selectedPhotoNamesList.removeAt(index);
                      }
                    }),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Tombol Pilih Foto: selalu menambah, tidak mereset foto lama
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.add_a_photo_outlined, size: 16),
              label: const Text('Tambah Foto', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: WarnaAplikasi.greenLight,
                foregroundColor: WarnaAplikasi.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fotoThumbnail({
    required Widget image,
    required VoidCallback onHapus,
  }) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 100,
            height: 90,
            color: WarnaAplikasi.bgPaleGreen3,
            child: image,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: onHapus,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Color(0xCC000000),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveChanges,
            icon: _isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.check_circle_outline_rounded, size: 18, color: Colors.white),
            label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Perubahan', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: WarnaAplikasi.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: _confirmDelete,
                  icon: const Icon(Icons.delete_outline_rounded, size: 16, color: WarnaAplikasi.errorRedDark),
                  label: const Text('Hapus Data Ini', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: WarnaAplikasi.errorRedDark)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: WarnaAplikasi.rejectedRedBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WarnaAplikasi.greenLight,
                    foregroundColor: WarnaAplikasi.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('Batal', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
