import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/core/widgets/dialog_sukses_simpan.dart';
import 'package:pawon_mobile/core/widgets/pawon_form_header.dart';
import 'package:pawon_mobile/features/lahan/models/item_lahan.dart';
import 'package:pawon_mobile/features/lahan/services/lahan_api_service.dart';
import 'package:pawon_mobile/features/panen/models/item_panen.dart';
import 'package:pawon_mobile/features/panen/screens/layar_detail_panen.dart';
import 'package:pawon_mobile/features/panen/services/panen_api_service.dart';
import 'package:pawon_mobile/features/panen/services/panen_multipart.dart';

class RecordHarvestScreen extends StatefulWidget {
  final Function(HarvestItem)? onSave;
  final String? initialLahanId;
  final String? initialLahanName;

  const RecordHarvestScreen({
    super.key,
    this.onSave,
    this.initialLahanId,
    this.initialLahanName,
  });

  @override
  State<RecordHarvestScreen> createState() => _RecordHarvestScreenState();
}

class _RecordHarvestScreenState extends State<RecordHarvestScreen> {
  final LahanApiService _lahanService = LahanApiService();
  final PanenApiService _panenService = PanenApiService();

  // Lahan Garapan selection
  List<ItemLahan> _lahanList = [];
  ItemLahan? _selectedItemLahan;
  bool _isLoadingLahan = true;
  bool _isSaving = false;

  final String _musimTanam = 'Musim Rendeng';

  // Komoditas
  CropType _cropType = CropType.padi;
  String _commodityName = 'Gabah Kering Panen (GKP)';
  String _varietasName = 'Ciherang';

  // Tanggal Panen
  DateTime _harvestDate = DateTime.now();

  // Luas Lahan yang Dipanen
  final TextEditingController _harvestedAreaController = TextEditingController();

  // Jumlah Hasil Panen
  final TextEditingController _weightController = TextEditingController();
  int _selectedUnitIndex = 0; // 0: Kg, 1: Ton, 2: Kuintal

  // Parameter Kualitas
  final TextEditingController _moistureController = TextEditingController(text: '13.8');
  final TextEditingController _wholeGrainController = TextEditingController(text: '95.0');
  final TextEditingController _wasteController = TextEditingController(text: '2.0');

  // Metode Pemanenan (0: Mesin Combine Harvester, 1: Manual)
  int _selectedHarvestMethod = 0;

  // Biaya Petik / Tebas & Harga
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _workersController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Catatan Lapangan
  final TextEditingController _notesController = TextEditingController();

  // Photos (Multiple Support)
  final List<Uint8List> _selectedPhotoBytesList = [];
  final List<String> _selectedPhotoNamesList = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialLahanId != null) {
      _selectedItemLahan = ItemLahan(
        id: widget.initialLahanId!,
        nama: widget.initialLahanName ?? 'Petak Lahan',
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
    _harvestedAreaController.dispose();
    _weightController.dispose();
    _moistureController.dispose();
    _wholeGrainController.dispose();
    _wasteController.dispose();
    _costController.dispose();
    _workersController.dispose();
    _priceController.dispose();
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
        _syncCommodityFromLahan(preselected);
      });
    } else {
      setState(() {
        _isLoadingLahan = false;
      });
    }
  }

  void _syncCommodityFromLahan(ItemLahan? lhn) {
    if (lhn == null) return;
    if (lhn.luas > 0) {
      _harvestedAreaController.text = lhn.luas.toStringAsFixed(2);
    }
    final kom = lhn.komoditas.toLowerCase().trim();
    if (kom.contains('jagung')) {
      _cropType = CropType.jagung;
      _commodityName = 'Jagung Pipil Kering (JPK)';
      _varietasName = lhn.komoditas.isNotEmpty ? lhn.komoditas : 'Jagung Hibrida';
    } else {
      _cropType = CropType.padi;
      _commodityName = 'Gabah Kering Panen (GKP)';
      _varietasName = lhn.komoditas.isNotEmpty ? lhn.komoditas : 'Padi Ciherang';
    }
  }

  double get _currentWeightKg {
    final rawText = _weightController.text.replaceAll('.', '').replaceAll(',', '.').trim();
    final val = double.tryParse(rawText) ?? 0.0;
    if (_selectedUnitIndex == 0) return val;
    if (_selectedUnitIndex == 1) return val * 1000.0;
    return val * 100.0; // Kuintal
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

  Future<void> _saveData() async {
    if (_selectedItemLahan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih petak lahan terlebih dahulu.'), backgroundColor: WarnaAplikasi.errorRedDark),
      );
      return;
    }

    if (_currentWeightKg <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berat hasil panen harus lebih dari 0.'), backgroundColor: WarnaAplikasi.errorRedDark),
      );
      return;
    }

    setState(() => _isSaving = true);

    const qualityTitle = 'Grade A / Super';

    final harvestMethod = _selectedHarvestMethod == 0 ? 'Mesin Combine Harvester' : 'Manual / Sabit & Thresher';

    final dateIso = '${_harvestDate.year}-${_harvestDate.month.toString().padLeft(2, '0')}-${_harvestDate.day.toString().padLeft(2, '0')}';
    final rawCost = _costController.text.replaceAll('.', '').replaceAll(',', '.').trim();
    final rawPrice = _priceController.text.replaceAll('.', '').replaceAll(',', '.').trim();

    final payload = <String, dynamic>{
      'id_lahan': _selectedItemLahan!.id,
      'komoditas_nama': _cropType.displayName,
      'varietas': _varietasName,
      'jenis_panen': _commodityName,
      'tanggal_panen': dateIso,
      'waktu_panen': '09:00 WIB',
      'musim_tanam': _musimTanam,
      'berat_kg': _currentWeightKg,
      'kualitas_grade': qualityTitle,
      'kadar_air': double.tryParse(_moistureController.text) ?? 14.0,
      'persen_butir_utuh': double.tryParse(_wholeGrainController.text) ?? 95.0,
      'persen_hampa_kotoran': double.tryParse(_wasteController.text) ?? 2.0,
      'metode_panen': harvestMethod,
      'biaya_panen': double.tryParse(rawCost) ?? 0.0,
      'keterangan_tenaga_kerja': _workersController.text.trim(),
      'harga_per_kg': double.tryParse(rawPrice) ?? 7000.0,
      'catatan': _notesController.text.trim(),
    };

    // Seluruh foto dikirim lewat foto_panen_list[]; backend memakai foto
    // pertama sebagai foto_panen. Jangan memakai instance MultipartFile yang
    // sama dua kali karena Dio menandainya sudah "finalized".
    final List<MultipartFile> fileList = _selectedPhotoBytesList.isEmpty
        ? const <MultipartFile>[]
        : List<MultipartFile>.generate(_selectedPhotoBytesList.length, (i) {
            final name = i < _selectedPhotoNamesList.length
                ? _selectedPhotoNamesList[i]
                : 'panen_$i.jpg';
            return buatFotoPanen(_selectedPhotoBytesList[i], name);
          });

    try {
      final res = await _panenService.createPanen(
        payload,
        fotoPanen: null,
        fotoPanenList: fileList.isEmpty ? null : fileList,
      );
      if (!mounted) return;
      setState(() => _isSaving = false);

      if (res.success && res.data != null) {
        final newItem = res.data!;
        widget.onSave?.call(newItem);

        SaveSuccessDialog.show(
          context,
          item: newItem,
          onViewDetail: () {
            Navigator.pop(context); // pop dialog
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (ctx) => HarvestDetailScreen(
                  item: newItem,
                  onUpdate: (updated) => widget.onSave?.call(updated),
                  onDelete: () => Navigator.pop(context),
                ),
              ),
            );
          },
          onDownloadPdf: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bukti panen tercatat resmi di sistem PawonTani.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onBackToList: () {
            Navigator.pop(context); // pop dialog
            Navigator.pop(context, true); // pop screen back to list
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message.isNotEmpty ? res.message : 'Gagal menyimpan panen.'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarnaAplikasi.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            const PawonFormHeader(
              title: 'Catat Panen',
              subtitle: 'Formulir hasil panen kelompok tani',
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(),
                    const SizedBox(height: 16),
                    _buildLahanGarapanSection(),
                    const SizedBox(height: 18),
                    _buildTanggalPanenSection(),
                    const SizedBox(height: 18),
                    _buildJumlahPanenSection(),
                    const SizedBox(height: 18),
                    _buildMetodePemanenanSection(),
                    const SizedBox(height: 18),
                    _buildBiayaPetikSection(),
                    const SizedBox(height: 18),
                    _buildCatatanSection(),
                    const SizedBox(height: 18),
                    _buildFotoBuktiSection(),
                    const SizedBox(height: 18),
                    _buildStatusPreviewCard(),
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

  Widget _buildSectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DETAIL HASIL PANEN',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: WarnaAplikasi.primary,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Masukkan hasil panen nyata dari petak lahan binaan Anda.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
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
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: WarnaAplikasi.nearBlack,
          ),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: WarnaAplikasi.errorRedDark,
          ),
        ),
        const SizedBox(height: 14),
        _buildFieldLabel('Luas Lahan yang Dipanen (Hektar)', isRequired: true),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: WarnaAplikasi.borderField),
          ),
          child: Row(
            children: [
              const Icon(Icons.square_foot_rounded, color: WarnaAplikasi.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _harvestedAreaController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: WarnaAplikasi.textDarkGreen),
                  decoration: const InputDecoration(
                    hintText: 'Contoh: 0.85',
                    hintStyle: TextStyle(fontSize: 13, color: WarnaAplikasi.textGray),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: WarnaAplikasi.greenLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Ha', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: WarnaAplikasi.primary)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLahanGarapanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Lahan Garapan', isRequired: true),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            if (_lahanList.isEmpty) return;
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (ctx) => Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih Lahan Garapan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: WarnaAplikasi.textDarkGreen,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._lahanList.map((lhn) {
                      return ListTile(
                        leading: const Icon(Icons.eco_rounded, color: WarnaAplikasi.primary),
                        title: Text(lhn.nama),
                        subtitle: Text('${lhn.luas.toStringAsFixed(2)} Ha • ${lhn.komoditas.isNotEmpty ? lhn.komoditas : 'Pertanian'}'),
                        onTap: () {
                          setState(() {
                            _selectedItemLahan = lhn;
                            _syncCommodityFromLahan(lhn);
                          });
                          Navigator.pop(ctx);
                        },
                      );
                    }),
                  ],
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: WarnaAplikasi.borderField),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: WarnaAplikasi.bgSuccessLight2,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: WarnaAplikasi.primaryDark,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedItemLahan?.nama ?? (widget.initialLahanName ?? 'Pilih Petak Lahan'),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: WarnaAplikasi.textDarkGreen,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _selectedItemLahan != null && _selectedItemLahan!.luas > 0
                            ? '${_selectedItemLahan!.luas.toStringAsFixed(2)} Ha • ${_selectedItemLahan!.komoditas.isNotEmpty ? _selectedItemLahan!.komoditas : _cropType.displayName}'
                            : (_isLoadingLahan ? 'Memuat daftar lahan...' : 'Ketuk untuk memilih petak lahan'),
                        style: const TextStyle(
                          fontSize: 11,
                          color: WarnaAplikasi.textGray,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isLoadingLahan)
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: WarnaAplikasi.primary))
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
      ],
    );
  }

  Widget _buildTanggalPanenSection() {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final dateStr = '${_harvestDate.day} ${months[_harvestDate.month - 1]} ${_harvestDate.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Tanggal Panen', isRequired: true),
        const SizedBox(height: 8),
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
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: WarnaAplikasi.borderField),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: WarnaAplikasi.primary, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    dateStr,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: WarnaAplikasi.textDarkGreen),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, color: WarnaAplikasi.textGrayGreen, size: 22),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJumlahPanenSection() {
    final unitLabels = ['Kg', 'Ton', 'Kuintal'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Jumlah Hasil Panen', isRequired: true),
        const SizedBox(height: 8),
        Container(
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      onChanged: (val) => setState(() {}),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: WarnaAplikasi.primaryDark,
                        letterSpacing: -0.5,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '0',
                        hintStyle: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: WarnaAplikasi.grayGreenMuted,
                          letterSpacing: -0.5,
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: WarnaAplikasi.bgPaleGreen3,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: WarnaAplikasi.borderPale2),
                    ),
                    child: Text(
                      unitLabels[_selectedUnitIndex],
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WarnaAplikasi.grayGreenDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: WarnaAplikasi.borderField,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: List.generate(unitLabels.length, (index) {
                    final isSelected = _selectedUnitIndex == index;
                    return Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedUnitIndex = index),
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? WarnaAplikasi.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            unitLabels[index],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : WarnaAplikasi.grayGreenDark,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.balance_outlined, size: 13, color: WarnaAplikasi.textGrayGreen),
                  const SizedBox(width: 5),
                  Text(
                    'Setara dengan ${_currentTon.toStringAsFixed(2)} Ton (${_currentKuintal.toStringAsFixed(1)} Kuintal)',
                    style: const TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayGreen),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetodePemanenanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Metode Pemanenan'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _selectedHarvestMethod = 0),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedHarvestMethod == 0 ? WarnaAplikasi.primary : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _selectedHarvestMethod == 0 ? WarnaAplikasi.primary : WarnaAplikasi.borderField),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.agriculture_rounded, color: _selectedHarvestMethod == 0 ? Colors.white : WarnaAplikasi.primary, size: 22),
                      const SizedBox(height: 8),
                      Text(
                        'Mesin Combine\nHarvester',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _selectedHarvestMethod == 0 ? Colors.white : WarnaAplikasi.textDarkGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _selectedHarvestMethod = 1),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedHarvestMethod == 1 ? WarnaAplikasi.primary : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _selectedHarvestMethod == 1 ? WarnaAplikasi.primary : WarnaAplikasi.borderField),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.content_cut_rounded, color: _selectedHarvestMethod == 1 ? Colors.white : WarnaAplikasi.primary, size: 22),
                      const SizedBox(height: 8),
                      Text(
                        'Manual / Sabit &\nThresher',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _selectedHarvestMethod == 1 ? Colors.white : WarnaAplikasi.textDarkGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBiayaPetikSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Estimasi Harga Jual & Biaya Petik'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: WarnaAplikasi.borderField),
                ),
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: WarnaAplikasi.textDarkGreen),
                  decoration: const InputDecoration(
                    labelText: 'Harga / Kg (Rp)',
                    hintText: 'Contoh: 7000',
                    hintStyle: TextStyle(fontSize: 12, color: WarnaAplikasi.grayGreenMuted),
                    labelStyle: TextStyle(fontSize: 11, color: WarnaAplikasi.textGray),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: WarnaAplikasi.borderField),
                ),
                child: TextField(
                  controller: _costController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: WarnaAplikasi.textDarkGreen),
                  decoration: const InputDecoration(
                    labelText: 'Biaya Panen (Rp)',
                    hintText: 'Contoh: 1200000',
                    hintStyle: TextStyle(fontSize: 12, color: WarnaAplikasi.grayGreenMuted),
                    labelStyle: TextStyle(fontSize: 11, color: WarnaAplikasi.textGray),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCatatanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Catatan Lapangan Tambahan'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: WarnaAplikasi.borderField),
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 3,
            style: const TextStyle(fontSize: 12, color: WarnaAplikasi.textDarkGreen, height: 1.4),
            decoration: const InputDecoration(
              hintText: 'Tulis catatan kondisi cuaca, kendala timbangan, dll.',
              hintStyle: TextStyle(fontSize: 11, color: WarnaAplikasi.grayGreenMuted),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFotoBuktiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFieldLabel('Foto Bukti Panen & Timbangan'),
            if (_selectedPhotoBytesList.isNotEmpty)
              Text(
                '${_selectedPhotoBytesList.length} Foto Terpilih',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: WarnaAplikasi.primary),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Carousel / Horizontal list foto terpilih
        if (_selectedPhotoBytesList.isNotEmpty)
          Container(
            height: 90,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _selectedPhotoBytesList.length,
              separatorBuilder: (sepCtx, sepIdx) => const SizedBox(width: 8),
              itemBuilder: (ctx, index) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: WarnaAplikasi.borderField),
                        image: DecorationImage(
                          image: MemoryImage(_selectedPhotoBytesList[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () => setState(() {
                          _selectedPhotoBytesList.removeAt(index);
                          if (index < _selectedPhotoNamesList.length) {
                            _selectedPhotoNamesList.removeAt(index);
                          }
                        }),
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
              },
            ),
          ),

        // Tombol Tambah Foto
        InkWell(
          onTap: _pickPhoto,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: WarnaAplikasi.successPaleGreen, style: BorderStyle.solid),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined, color: WarnaAplikasi.primary, size: 22),
                SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tambah Foto Dokumentasi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: WarnaAplikasi.primary)),
                    Text('Bisa ambil dari kamera atau pilih banyak foto dari galeri', style: TextStyle(fontSize: 10, color: WarnaAplikasi.grayGreenMuted)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPreviewCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: WarnaAplikasi.bgPaleGreen2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: WarnaAplikasi.greenPill),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: WarnaAplikasi.primary, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status setelah disimpan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: WarnaAplikasi.textDarkGreen)),
                SizedBox(height: 1),
                Text('Menunggu verifikasi pengurus kelompok tani.', style: TextStyle(fontSize: 10, color: WarnaAplikasi.textGray)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: WarnaAplikasi.commodityJagungBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: WarnaAplikasi.hppAmberBorder),
            ),
            child: const Text('Menunggu Verifikasi', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: WarnaAplikasi.warningOrange)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveData,
            icon: _isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.assignment_turned_in_outlined, size: 18, color: Colors.white),
            label: Text(
              _isSaving ? 'Menyimpan...' : 'Simpan Data Panen',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: WarnaAplikasi.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: WarnaAplikasi.textDarkGreen,
              backgroundColor: Colors.white,
              side: BorderSide(color: WarnaAplikasi.borderField),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text('Batal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}
