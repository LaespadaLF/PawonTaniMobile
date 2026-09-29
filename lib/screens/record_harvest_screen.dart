import 'package:flutter/material.dart';
import '../models/harvest_item.dart';
import '../widgets/save_success_dialog.dart';
import 'harvest_detail_screen.dart';

class RecordHarvestScreen extends StatefulWidget {
  final Function(HarvestItem) onSave;

  const RecordHarvestScreen({super.key, required this.onSave});

  @override
  State<RecordHarvestScreen> createState() => _RecordHarvestScreenState();
}

class _RecordHarvestScreenState extends State<RecordHarvestScreen> {
  // Lahan Garapan selection
  String _selectedLahan = 'Petak Sawah Barat';
  String _selectedLahanDetail = 'Blok A • 0,75 Ha • Padi Ciherang';
  final String _musimTanam = '2023/2024';
  final String _poktan = 'Sumber Makmur';

  // Komoditas
  CropType _cropType = CropType.padi;
  String _commodityName = 'Gabah Kering Panen (GKP)';

  // Tanggal Panen
  DateTime _harvestDate = DateTime(2024, 11, 18);

  // Jumlah Hasil Panen
  final TextEditingController _weightController =
      TextEditingController(text: '4850');
  int _selectedUnitIndex = 0; // 0: Kg, 1: Ton, 2: Kuintal

  // Kualitas / Mutu Panen (0: Grade A, 1: Grade B, 2: Grade C)
  int _selectedGradeIndex = 0;

  // Metode Pemanenan (0: Mesin Combine Harvester, 1: Manual)
  int _selectedHarvestMethod = 0;

  // Biaya Petik / Tebas
  final TextEditingController _costController =
      TextEditingController(text: '1.200.000');

  // Catatan Lapangan
  final TextEditingController _notesController = TextEditingController(
    text:
        'Kondisi bulir padi padat berisi, penimbangan disaksikan oleh mandor Poktan Sumber Makmur.',
  );

  // Photos mock
  bool _hasSamplePhoto = true;

  @override
  void dispose() {
    _weightController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _currentWeightKg {
    final rawText = _weightController.text.replaceAll('.', '').replaceAll(',', '.');
    final val = double.tryParse(rawText) ?? 4850.0;
    if (_selectedUnitIndex == 0) return val;
    if (_selectedUnitIndex == 1) return val * 1000.0;
    return val * 100.0; // Kuintal
  }

  double get _currentTon => _currentWeightKg / 1000.0;
  double get _currentKuintal => _currentWeightKg / 100.0;

  void _saveData() {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    final dateStr =
        '${_harvestDate.day} ${months[_harvestDate.month - 1].substring(0, 3)} ${_harvestDate.year}';

    String qualityTitle;
    String qualityNotes;
    if (_selectedGradeIndex == 0) {
      qualityTitle = 'Grade A / Super';
      qualityNotes = 'Kadar Air <14%';
    } else if (_selectedGradeIndex == 1) {
      qualityTitle = 'Grade B / Standar Pasar';
      qualityNotes = 'Kadar Air 14%-17%';
    } else {
      qualityTitle = 'Grade C / Perlu Jemur';
      qualityNotes = 'Kadar Air >18%';
    }

    final newItem = HarvestItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      harvestCode: 'PN-202410-09',
      title: _cropType == CropType.padi ? 'Padi Ciherang' : 'Jagung Manis H',
      subtitle: _commodityName,
      cropType: _cropType,
      status: HarvestStatus.menunggu,
      location: _selectedLahan,
      blockArea:
          '${_selectedLahanDetail.split('•')[0].trim()} • ${_selectedLahanDetail.split('•')[1].trim()}',
      date: dateStr,
      season: 'Musim Rendeng',
      weightKg: _currentWeightKg,
      qualityGrade: qualityTitle,
      moistureOrNotes: qualityNotes,
    );

    widget.onSave(newItem);

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
              onUpdate: (updated) => widget.onSave(updated),
              onDelete: () => Navigator.pop(context),
            ),
          ),
        );
      },
      onDownloadPdf: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mengunduh berkas bukti panen PDF...'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onBackToList: () {
        Navigator.pop(context); // pop dialog
        Navigator.pop(context); // pop screen back to list
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

            // Form Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Title
                    _buildSectionHeader(),
                    const SizedBox(height: 16),

                    // 1. Lahan Garapan
                    _buildLahanGarapanSection(),
                    const SizedBox(height: 18),

                    // 2. Komoditas & Bentuk Hasil Panen
                    _buildKomoditasSection(),
                    const SizedBox(height: 18),

                    // 3. Tanggal Panen
                    _buildTanggalPanenSection(),
                    const SizedBox(height: 18),

                    // 4. Jumlah Hasil Panen
                    _buildJumlahPanenSection(),
                    const SizedBox(height: 18),

                    // 5. Kualitas / Mutu Panen
                    _buildKualitasMutuSection(),
                    const SizedBox(height: 18),

                    // 6. Metode Pemanenan
                    _buildMetodePemanenanSection(),
                    const SizedBox(height: 18),

                    // 7. Biaya Petik / Tebas
                    _buildBiayaPetikSection(),
                    const SizedBox(height: 18),

                    // 8. Catatan Lapangan Tambahan
                    _buildCatatanSection(),
                    const SizedBox(height: 18),

                    // 9. Foto Bukti Panen & Timbangan
                    _buildFotoBuktiSection(),
                    const SizedBox(height: 18),

                    // 10. Status setelah disimpan preview card
                    _buildStatusPreviewCard(),
                    const SizedBox(height: 20),

                    // Action Buttons
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

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFEFF3F0),
            width: 1,
          ),
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Catat Panen',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF15261B),
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 1),
              Text(
                'Formulir hasil panen',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF708577),
                ),
              ),
            ],
          ),
        ],
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
            color: Color(0xFF285438),
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Masukkan hasil panen dari lahan yang dipilih.',
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
            color: Color(0xFF1B2C20),
          ),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFFDC2626),
            ),
          ),
      ],
    );
  }

  // 1. Lahan Garapan
  Widget _buildLahanGarapanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Lahan Garapan', isRequired: true),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
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
                        color: Color(0xFF15261B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const Icon(Icons.eco_rounded, color: Color(0xFF285438)),
                      title: const Text('Petak Sawah Barat'),
                      subtitle: const Text('Blok A • 0,75 Ha • Padi Ciherang'),
                      onTap: () {
                        setState(() {
                          _selectedLahan = 'Petak Sawah Barat';
                          _selectedLahanDetail = 'Blok A • 0,75 Ha • Padi Ciherang';
                          _cropType = CropType.padi;
                          _commodityName = 'Gabah Kering Panen (GKP)';
                        });
                        Navigator.pop(ctx);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.eco_rounded, color: Color(0xFF285438)),
                      title: const Text('Kebun Jagung Lereng'),
                      subtitle: const Text('Blok C • 0,5 Ha • Jagung Manis H'),
                      onTap: () {
                        setState(() {
                          _selectedLahan = 'Kebun Jagung Lereng';
                          _selectedLahanDetail = 'Blok C • 0,5 Ha • Jagung Manis H';
                          _cropType = CropType.jagung;
                          _commodityName = 'Jagung Pipil Kering (JPK)';
                        });
                        Navigator.pop(ctx);
                      },
                    ),
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
              border: Border.all(color: const Color(0xFFE2EBE5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5F4EA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: Color(0xFF2E6A44),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedLahan,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15261B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '($_selectedLahanDetail)',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B8072),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF708577),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF7F1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD6EADB)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: Color(0xFF285438),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Musim Tan.',
                            style: TextStyle(
                              fontSize: 9.5,
                              color: Color(0xFF6B8072),
                            ),
                          ),
                          Text(
                            _musimTanam,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1B2C20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF7F1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD6EADB)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.groups_outlined,
                      size: 15,
                      color: Color(0xFF285438),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Poktan',
                            style: TextStyle(
                              fontSize: 9.5,
                              color: Color(0xFF6B8072),
                            ),
                          ),
                          Text(
                            _poktan,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1B2C20),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 2. Komoditas & Bentuk Hasil Panen
  Widget _buildKomoditasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Komoditas & Bentuk Hasil Panen', isRequired: true),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            setState(() {
              if (_cropType == CropType.padi) {
                _cropType = CropType.jagung;
                _commodityName = 'Jagung Pipil Kering (JPK)';
              } else {
                _cropType = CropType.padi;
                _commodityName = 'Gabah Kering Panen (GKP)';
              }
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2EBE5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5F4EA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _cropType == CropType.padi
                        ? Icons.grass_rounded
                        : Icons.bolt_rounded,
                    color: const Color(0xFF2E6A44),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _commodityName,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF15261B),
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF869E90),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 3. Tanggal Panen
  Widget _buildTanggalPanenSection() {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    final dateStr =
        '${_harvestDate.day} ${months[_harvestDate.month - 1]} ${_harvestDate.year}';

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
              border: Border.all(color: const Color(0xFFE2EBE5)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xFF285438),
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF15261B),
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF708577),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 4. Jumlah Hasil Panen
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
            border: Border.all(color: const Color(0xFFE2EBE5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Big Number Input + Unit dropdown pill
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      onChanged: (val) => setState(() {}),
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A3826),
                        letterSpacing: -0.5,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F6F4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E7E2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          unitLabels[_selectedUnitIndex],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF43584B),
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: Color(0xFF43584B),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Segmented unit buttons: [Kg] [Ton] [Kuintal]
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F6F3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: List.generate(unitLabels.length, (index) {
                    final isSelected = _selectedUnitIndex == index;
                    return Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedUnitIndex = index;
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF285438)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: isSelected
                                ? const [
                                    BoxShadow(
                                      color: Color(0x1A000000),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            unitLabels[index],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF556C5E),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 10),

              // Setara dengan ...
              Row(
                children: [
                  const Icon(
                    Icons.balance_outlined,
                    size: 13,
                    color: Color(0xFF708577),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Setara dengan ${_currentTon.toStringAsFixed(2).replaceAll('.', ',')} Ton (${_currentKuintal.toStringAsFixed(1).replaceAll('.', ',')} Kuintal)',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF708577),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 5. Kualitas / Mutu Panen
  Widget _buildKualitasMutuSection() {
    final grades = [
      {
        'title': 'Grade A / Super',
        'desc': 'Kadar air <14%, butir utuh >95%, bebas kotoran & gabah hampa.',
      },
      {
        'title': 'Grade B / Standar Pasar',
        'desc':
            'Kadar air 14% - 17%, butir pecah toleran normal standar Bulog.',
      },
      {
        'title': 'Grade C / Perlu Pengeringan Ulang',
        'desc':
            'Kadar air tinggi >18%, akibat hujan, butuh penjemuran tambahan.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Kualitas / Mutu Panen', isRequired: true),
        const SizedBox(height: 8),
        ...List.generate(grades.length, (index) {
          final isSelected = _selectedGradeIndex == index;
          final item = grades[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedGradeIndex = index),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF6FAF7) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF285438)
                        : const Color(0xFFE2EBE5),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isSelected
                          ? const Color(0xFF285438)
                          : const Color(0xFF9FB2A6),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF15261B),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item['desc']!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B8072),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // 6. Metode Pemanenan
  Widget _buildMetodePemanenanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Metode Pemanenan'),
        const SizedBox(height: 8),
        Row(
          children: [
            // Option 0: Mesin Combine Harvester
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _selectedHarvestMethod = 0),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedHarvestMethod == 0
                        ? const Color(0xFF285438)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedHarvestMethod == 0
                          ? const Color(0xFF285438)
                          : const Color(0xFFE2EBE5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.agriculture_rounded,
                        color: _selectedHarvestMethod == 0
                            ? Colors.white
                            : const Color(0xFF285438),
                        size: 22,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mesin Combine\nHarvester',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _selectedHarvestMethod == 0
                              ? Colors.white
                              : const Color(0xFF15261B),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cepat, minim susut rontok',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: _selectedHarvestMethod == 0
                              ? const Color(0xFFC7EBD2)
                              : const Color(0xFF708577),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Option 1: Manual
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _selectedHarvestMethod = 1),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedHarvestMethod == 1
                        ? const Color(0xFF285438)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedHarvestMethod == 1
                          ? const Color(0xFF285438)
                          : const Color(0xFFE2EBE5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.content_cut_rounded,
                        color: _selectedHarvestMethod == 1
                            ? Colors.white
                            : const Color(0xFF285438),
                        size: 22,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manual / Sabit &\nThresher',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _selectedHarvestMethod == 1
                              ? Colors.white
                              : const Color(0xFF15261B),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tradisi gotong royong',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: _selectedHarvestMethod == 1
                              ? const Color(0xFFC7EBD2)
                              : const Color(0xFF708577),
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

  // 7. Biaya Petik / Tebas
  Widget _buildBiayaPetikSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFieldLabel('Biaya Petik / Tebas'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF3F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Opsional',
                style: TextStyle(fontSize: 10, color: Color(0xFF708577)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2EBE5)),
          ),
          child: Row(
            children: [
              const Text(
                'Rp ',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF15261B),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _costController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15261B),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Masukkan biaya jika ada',
                    hintStyle: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF9FB2A6),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 8. Catatan Lapangan Tambahan
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
            border: Border.all(color: const Color(0xFFE2EBE5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _notesController,
                maxLines: 3,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF15261B),
                  height: 1.4,
                ),
                decoration: const InputDecoration(
                  hintText: 'Tulis catatan kondisi cuaca, kendala, dll.',
                  hintStyle: TextStyle(fontSize: 11, color: Color(0xFF9FB2A6)),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '78/250',
                style: TextStyle(fontSize: 10, color: Color(0xFF9FB2A6)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 9. Foto Bukti Panen & Timbangan
  Widget _buildFotoBuktiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFieldLabel('Foto Bukti Panen & Timbangan'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF3F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Opsional',
                style: TextStyle(fontSize: 10, color: Color(0xFF708577)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        const Text(
          'Unggah foto tumpukan hasil panen atau slip timbangan.',
          style: TextStyle(fontSize: 11, color: Color(0xFF708577)),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Sample uploaded photo thumbnail
            if (_hasSamplePhoto)
              Stack(
                children: [
                  Container(
                    width: 110,
                    height: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFF8B7355),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?w=300&q=80',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 16,
                    child: InkWell(
                      onTap: () => setState(() => _hasSamplePhoto = false),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Color(0xCC000000),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            // Upload button
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() => _hasSamplePhoto = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Foto berhasil ditambahkan.'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFC7EBD2),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        color: Color(0xFF285438),
                        size: 22,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tambah Foto',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF285438),
                        ),
                      ),
                      Text(
                        'JPG/PNG maks. 5 MB',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: Color(0xFF9FB2A6),
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

  // 10. Status setelah disimpan preview card
  Widget _buildStatusPreviewCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF7F1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6EADB)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shield_outlined,
            color: Color(0xFF285438),
            size: 20,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status setelah disimpan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15261B),
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'Estimasi verifikasi 1x24 jam oleh pengurus poktan.',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6B8072),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5E6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFDEB5)),
            ),
            child: const Text(
              'Menunggu Verifikasi',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFFD97706),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Action Buttons
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary: Simpan Data Panen
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _saveData,
            icon: const Icon(
              Icons.assignment_turned_in_outlined,
              size: 18,
              color: Colors.white,
            ),
            label: const Text(
              'Simpan Data Panen',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF285438),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Secondary: Batal
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF15261B),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFE2EBE5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
