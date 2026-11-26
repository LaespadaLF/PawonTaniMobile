import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/core/widgets/dialog_sukses_simpan.dart';
import 'package:pawon_mobile/core/widgets/pawon_form_header.dart';
import 'package:pawon_mobile/features/lahan/models/item_lahan.dart';
import 'package:pawon_mobile/features/lahan/models/item_siklus_tanam.dart';
import 'package:pawon_mobile/features/lahan/services/lahan_api_service.dart';
import 'package:pawon_mobile/features/panen/models/item_panen.dart';
import 'package:pawon_mobile/features/panen/screens/layar_detail_panen.dart';
import 'package:pawon_mobile/features/panen/services/panen_api_service.dart';
import 'package:pawon_mobile/features/panen/services/panen_multipart.dart';

class RecordHarvestScreen extends StatefulWidget {
  final Function(HarvestItem)? onSave;
  final String? initialLahanId;
  final String? initialLahanName;
  final ItemSiklusTanam? initialSiklus;

  const RecordHarvestScreen({
    super.key,
    this.onSave,
    this.initialLahanId,
    this.initialLahanName,
    this.initialSiklus,
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
  ItemSiklusTanam? _activeSiklus;
  bool _isLoadingLahan = true;
  bool _isLoadingSiklus = false;
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
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchLahanList() async {
    setState(() => _isLoadingLahan = true);
    final response = await _lahanService.getLahanList();
    if (!mounted) return;

    if (response.success && response.data != null && response.data!.isNotEmpty) {
      final allList = response.data!;
      final list = allList.where((l) => l.status == StatusLahan.aktif || l.status == StatusLahan.persiapan || l.siklusBerjalan != null).toList();
      ItemLahan? preselected;
      if (list.isNotEmpty) {
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
      }

      setState(() {
        _lahanList = list;
        _selectedItemLahan = preselected;
        _isLoadingLahan = false;
        _syncCommodityFromLahan(preselected);
      });

      if (widget.initialSiklus != null && preselected?.id == widget.initialLahanId) {
        setState(() {
          _activeSiklus = widget.initialSiklus;
          _syncFromSiklus(_activeSiklus!);
        });
      } else if (preselected != null) {
        _fetchSiklusForSelectedLahan(preselected.id);
      }
    } else {
      setState(() {
        _isLoadingLahan = false;
      });
    }
  }

  void _syncFromSiklus(ItemSiklusTanam siklus) {
    final kom = siklus.komoditasNama.toLowerCase().trim();
    if (kom.contains('jagung')) {
      _cropType = CropType.jagung;
      _commodityName = 'Jagung Pipil Kering (JPK)';
    } else {
      _cropType = CropType.padi;
      _commodityName = 'Gabah Kering Panen (GKP)';
    }
    if (siklus.varietas != null && siklus.varietas!.isNotEmpty) {
      _varietasName = siklus.varietas!;
    }
  }

  Future<void> _fetchSiklusForSelectedLahan(String lahanId) async {
    setState(() => _isLoadingSiklus = true);
    try {
      final res = await _lahanService.getSiklusBerjalan(lahanId);
      if (!mounted) return;
      setState(() {
        _activeSiklus = res.data;
        _isLoadingSiklus = false;
        if (_activeSiklus != null) {
          _syncFromSiklus(_activeSiklus!);
        }
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingSiklus = false);
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

    if (_activeSiklus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lahan ini tidak memiliki siklus tanam aktif. Panen wajib terhubung dengan siklus berjalan.'),
          backgroundColor: WarnaAplikasi.warningOrange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_activeSiklus!.isAktif) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Siklus tanam sedang ${_activeSiklus!.statusLabel} dan tidak dapat menerima catatan panen baru.'),
          backgroundColor: WarnaAplikasi.warningOrange,
          behavior: SnackBarBehavior.floating,
        ),
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

    final payload = <String, dynamic>{
      'id_lahan': _selectedItemLahan!.id,
      'id_siklus': _activeSiklus!.idSiklus,
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
      'biaya_panen': 0.0,
      'keterangan_tenaga_kerja': '',
      'harga_per_kg': 0.0,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF141916) : WarnaAplikasi.primaryBackground,
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
                    _buildLuasLahanSection(),
                    const SizedBox(height: 18),
                    _buildTanggalPanenSection(),
                    const SizedBox(height: 18),
                    _buildJumlahPanenSection(),
                    const SizedBox(height: 18),
                    _buildMetodePemanenanSection(),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DETAIL HASIL PANEN',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Masukkan hasil panen nyata dari petak lahan binaan Anda.',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? const Color(0xFFA0B3A6) : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.nearBlack,
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
      ],
    );
  }

  Widget _buildLuasLahanSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
    final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.borderField;
    final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDarkGreen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Luas Lahan yang Dipanen (Hektar)', isRequired: true),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(Icons.square_foot_rounded, color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _harvestedAreaController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: titleColor),
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
                  color: isDark ? const Color(0xFF243328) : WarnaAplikasi.greenLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Ha', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLahanGarapanSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
    final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.borderField;
    final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDarkGreen;
    final subtitleColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray;

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
              backgroundColor: cardBg,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (ctx) => ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        'Pilih Lahan Garapan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _lahanList.length,
                          itemBuilder: (context, idx) {
                            final lhn = _lahanList[idx];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              leading: Icon(Icons.eco_rounded, color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary),
                              title: Text(lhn.nama, style: TextStyle(color: titleColor, fontWeight: FontWeight.w600)),
                              subtitle: Text('${lhn.luas.toStringAsFixed(2)} Ha • ${lhn.komoditas.isNotEmpty ? lhn.komoditas : 'Pertanian'}', style: TextStyle(color: subtitleColor)),
                              onTap: () {
                                setState(() {
                                  _selectedItemLahan = lhn;
                                  _syncCommodityFromLahan(lhn);
                                });
                                Navigator.pop(ctx);
                                _fetchSiklusForSelectedLahan(lhn.id);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF243328) : WarnaAplikasi.bgSuccessLight2,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.eco_rounded,
                    color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.primaryDark,
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
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _selectedItemLahan != null && _selectedItemLahan!.luas > 0
                            ? '${_selectedItemLahan!.luas.toStringAsFixed(2)} Ha • ${_selectedItemLahan!.komoditas.isNotEmpty ? _selectedItemLahan!.komoditas : _cropType.displayName}'
                            : (_isLoadingLahan ? 'Memuat daftar lahan...' : 'Ketuk untuk memilih petak lahan'),
                        style: TextStyle(
                          fontSize: 11,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isLoadingLahan)
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary))
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
        if (_isLoadingSiklus) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary)),
              const SizedBox(width: 8),
              Text('Memeriksa siklus tanam berjalan...', style: TextStyle(fontSize: 11, color: subtitleColor)),
            ],
          ),
        ] else if (_activeSiklus != null) ...[
          const SizedBox(height: 8),
          _buildSiklusBanner(),
        ] else if (_selectedItemLahan != null && !_isLoadingLahan) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: isDark ? 0.4 : 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Lahan ini tidak memiliki siklus tanam aktif. Panen hanya dapat dicatat jika lahan memiliki siklus tanam berjalan.',
                    style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFFFF8A80) : Colors.red, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSiklusBanner() {
    if (_activeSiklus == null) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1D2420) : WarnaAplikasi.primaryBackground;
    final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.primary.withValues(alpha: 0.3);
    final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.primaryDark;
    final subtitleColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF243328) : WarnaAplikasi.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.autorenew_rounded, size: 16, color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.primaryDark),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _activeSiklus!.musimTanam,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: titleColor),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF243328) : WarnaAplikasi.greenLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _activeSiklus!.statusLabel,
                        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.primaryDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${_activeSiklus!.komoditasNama}${_activeSiklus!.varietas != null && _activeSiklus!.varietas!.isNotEmpty ? ' • ${_activeSiklus!.varietas}' : ''}',
                  style: TextStyle(fontSize: 11, color: subtitleColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTanggalPanenSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
    final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.borderField;
    final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDarkGreen;

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
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    dateStr,
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: titleColor),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded, color: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGrayGreen, size: 22),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJumlahPanenSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
    final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.borderField;
    final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.primaryDark;
    final subtitleColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGrayGreen;

    final unitLabels = ['Kg', 'Ton', 'Kuintal'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Jumlah Hasil Panen', isRequired: true),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
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
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                        letterSpacing: -0.5,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '0',
                        hintStyle: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: isDark ? const Color(0xFF4A5E51) : WarnaAplikasi.grayGreenMuted,
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
                      color: isDark ? const Color(0xFF243328) : WarnaAplikasi.bgPaleGreen3,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? const Color(0xFF2E4033) : WarnaAplikasi.borderPale2),
                    ),
                    child: Text(
                      unitLabels[_selectedUnitIndex],
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.grayGreenDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141916) : WarnaAplikasi.borderField,
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
                            color: isSelected ? (isDark ? const Color(0xFF285438) : WarnaAplikasi.primary) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            unitLabels[index],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : (isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.grayGreenDark),
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
                  Icon(Icons.balance_outlined, size: 13, color: subtitleColor),
                  const SizedBox(width: 5),
                  Text(
                    'Setara dengan ${_currentTon.toStringAsFixed(2)} Ton (${_currentKuintal.toStringAsFixed(1)} Kuintal)',
                    style: TextStyle(fontSize: 11, color: subtitleColor),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
    final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.borderField;
    final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDarkGreen;

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
                    color: _selectedHarvestMethod == 0
                        ? (isDark ? const Color(0xFF285438) : WarnaAplikasi.primary)
                        : cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedHarvestMethod == 0
                          ? (isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary)
                          : borderColor,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.agriculture_rounded, color: _selectedHarvestMethod == 0 ? Colors.white : (isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary), size: 22),
                      const SizedBox(height: 8),
                      Text(
                        'Mesin Combine\nHarvester',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _selectedHarvestMethod == 0 ? Colors.white : titleColor,
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
                    color: _selectedHarvestMethod == 1
                        ? (isDark ? const Color(0xFF285438) : WarnaAplikasi.primary)
                        : cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedHarvestMethod == 1
                          ? (isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary)
                          : borderColor,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.content_cut_rounded, color: _selectedHarvestMethod == 1 ? Colors.white : (isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary), size: 22),
                      const SizedBox(height: 8),
                      Text(
                        'Manual / Sabit &\nThresher',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _selectedHarvestMethod == 1 ? Colors.white : titleColor,
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

  Widget _buildCatatanSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
    final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.borderField;
    final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDarkGreen;
    final hintColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.grayGreenMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Catatan Lapangan Tambahan'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 3,
            style: TextStyle(fontSize: 12, color: titleColor, height: 1.4),
            decoration: InputDecoration(
              hintText: 'Tulis catatan kondisi cuaca, kendala timbangan, dll.',
              hintStyle: TextStyle(fontSize: 11, color: hintColor),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
    final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.borderField;

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
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary),
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
                        border: Border.all(color: borderColor),
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
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? const Color(0xFF384D3E) : WarnaAplikasi.successPaleGreen, style: BorderStyle.solid),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined, color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary, size: 22),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tambah Foto Dokumentasi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary)),
                    Text('Bisa ambil dari kamera atau pilih banyak foto dari galeri', style: TextStyle(fontSize: 10, color: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.grayGreenMuted)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1D2420) : WarnaAplikasi.bgPaleGreen2;
    final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.greenPill;
    final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDarkGreen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status setelah disimpan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: titleColor)),
                const SizedBox(height: 1),
                Text('Menunggu verifikasi pengurus kelompok tani.', style: TextStyle(fontSize: 10, color: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF332714) : WarnaAplikasi.commodityJagungBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? const Color(0xFF5E4520) : WarnaAplikasi.hppAmberBorder),
            ),
            child: const Text('Menunggu Verifikasi', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: WarnaAplikasi.warningOrange)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final btnCancelBg = isDark ? const Color(0xFF1D2420) : Colors.white;
    final btnCancelBorder = isDark ? const Color(0xFF28332C) : WarnaAplikasi.borderField;
    final btnCancelText = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDarkGreen;

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
              foregroundColor: btnCancelText,
              backgroundColor: btnCancelBg,
              side: BorderSide(color: btnCancelBorder),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text('Batal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}
