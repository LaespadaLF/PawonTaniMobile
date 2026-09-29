import 'package:flutter/material.dart';
import '../models/harvest_item.dart';
import '../widgets/delete_harvest_dialog.dart';

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
  late String _lahan;
  late String _lahanDetail;
  late String _commodity;
  late DateTime _harvestDate;
  late String _harvestTime;
  late TextEditingController _weightController;
  int _selectedUnitIndex = 0; // 0: Kg, 1: Ton, 2: Kuintal
  int _selectedGradeIndex = 0; // 0: Grade A, 1: Grade B, 2: Grade C
  String _harvestMethod = 'Mesin Combine Harvester';
  late TextEditingController _costController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _lahan = widget.item.location;
    _lahanDetail = 'Varietas: ${widget.item.title} • Luas: ${widget.item.blockArea}';
    _commodity = widget.item.subtitle;
    _harvestDate = DateTime(2024, 10, 28);
    _harvestTime = widget.item.harvestTime;
    _weightController =
        TextEditingController(text: widget.item.weightKg.toInt().toString());
    _costController = TextEditingController(
        text: 'Rp 1.200.000 (${widget.item.costWorkers})');
    _notesController = TextEditingController(text: widget.item.fieldNotes);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _currentWeightKg {
    final rawText = _weightController.text.replaceAll('.', '').replaceAll(',', '.');
    final val = double.tryParse(rawText) ?? widget.item.weightKg;
    if (_selectedUnitIndex == 0) return val;
    if (_selectedUnitIndex == 1) return val * 1000.0;
    return val * 100.0;
  }

  double get _currentTon => _currentWeightKg / 1000.0;
  double get _currentKuintal => _currentWeightKg / 100.0;

  void _saveChanges() {
    String qualityGrade;
    String qualityNotes;
    if (_selectedGradeIndex == 0) {
      qualityGrade = 'Grade A / Super';
      qualityNotes = 'Kadar Air <14%';
    } else if (_selectedGradeIndex == 1) {
      qualityGrade = 'Grade B / Standar Pasar';
      qualityNotes = 'Kadar Air 14%-17%';
    } else {
      qualityGrade = 'Grade C / Lokal';
      qualityNotes = 'Kadar Air >18%';
    }

    final updated = widget.item.copyWith(
      location: _lahan,
      weightKg: _currentWeightKg,
      qualityGrade: qualityGrade,
      moistureOrNotes: qualityNotes,
      fieldNotes: _notesController.text,
      harvestMethod: _harvestMethod,
    );

    widget.onSave(updated);
    Navigator.pop(context, updated);
  }

  void _confirmDelete() {
    DeleteHarvestDialog.show(
      context,
      item: widget.item,
      onConfirmDelete: () {
        widget.onDelete();
        Navigator.pop(context); // pop edit screen
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

            // Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Mode Edit Banner
                    _buildModeEditBanner(),
                    const SizedBox(height: 16),

                    // 2. Lahan Garapan Terpilih
                    _buildLahanGarapanCard(),
                    const SizedBox(height: 16),

                    // 3. Komoditas / Bentuk Panen
                    _buildKomoditasCard(),
                    const SizedBox(height: 16),

                    // 4. Tanggal & Waktu Panen
                    _buildTanggalWaktuCard(),
                    const SizedBox(height: 16),

                    // 5. Jumlah Hasil Panen
                    _buildJumlahPanenCard(),
                    const SizedBox(height: 16),

                    // 6. Kualitas / Mutu Gabah
                    _buildKualitasMutuCard(),
                    const SizedBox(height: 16),

                    // 7. Metode Pemanenan
                    _buildMetodePemanenanCard(),
                    const SizedBox(height: 16),

                    // 8. Biaya Petik / Tebas
                    _buildBiayaPetikCard(),
                    const SizedBox(height: 16),

                    // 9. Catatan Lapangan (Mandor)
                    _buildCatatanMandorCard(),
                    const SizedBox(height: 16),

                    // 10. Dokumentasi Panen & Timbangan
                    _buildDokumentasiCard(),
                    const SizedBox(height: 20),

                    // 11. Action Buttons
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
          bottom: BorderSide(color: Color(0xFFEFF3F0), width: 1),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Data Panen',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF15261B),
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'Terakhir diperbarui: 08:30 WIB, 19 Nov 2024',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF708577),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined, size: 20, color: Color(0xFF43584B)),
          ),
        ],
      ),
    );
  }

  Widget _buildModeEditBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF7F1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6EADB)),
      ),
      child: const Row(
        children: [
          Icon(Icons.edit_note_rounded, color: Color(0xFF285438), size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MODE EDIT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E5334),
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'Data panen ini membawa data fisik nyata. Atur catatan sebelum verifikasi resmi.',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF556C5E),
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
        border: Border.all(color: const Color(0xFFE2EBE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.agriculture_rounded, size: 16, color: Color(0xFF285438)),
                  SizedBox(width: 6),
                  Text(
                    'Lahan Garapan Terpilih',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF15261B),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pilihan ganti petak lahan terbuka.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text(
                  'Ganti Lahan',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF285438),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F7F4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$_lahan (Blok A)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF15261B),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: Color(0xFF285438),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _lahanDetail,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B8072)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6EADB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Musim Tanam MT-1 2023/2024',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E5334),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5F4EA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.item.poktan,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E5334),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKomoditasCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2EBE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Komoditas / Bentuk Panen',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF15261B),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2EBE5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _commodity,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF15261B),
                    ),
                  ),
                ),
                const Icon(Icons.unfold_more_rounded, size: 20, color: Color(0xFF708577)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Standar kadar air: 13,5% - 14,0%',
            style: TextStyle(fontSize: 10.5, color: Color(0xFF708577)),
          ),
        ],
      ),
    );
  }

  Widget _buildTanggalWaktuCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2EBE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tanggal & Waktu Panen',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF15261B),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2EBE5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_harvestDate.day} Oktober ${_harvestDate.year} • $_harvestTime',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF15261B),
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 20,
                  color: Color(0xFF285438),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Waktu penimbangan awal panen',
            style: TextStyle(fontSize: 10.5, color: Color(0xFF708577)),
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
        border: Border.all(color: const Color(0xFFE2EBE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.hourglass_bottom_rounded, size: 16, color: Color(0xFF285438)),
                  SizedBox(width: 6),
                  Text(
                    'Jumlah Hasil Panen',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF15261B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF3F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Berat', style: TextStyle(fontSize: 10, color: Color(0xFF708577))),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Big input box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2EBE5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF15261B),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (v) => setState(() {}),
                  ),
                ),
                const Text(
                  'Kg',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF43584B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Segmented unit buttons
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
                    onTap: () => setState(() => _selectedUnitIndex = index),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF285438) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        unitLabels[index],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF556C5E),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF7F1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.sync_alt_rounded, size: 14, color: Color(0xFF285438)),
                const SizedBox(width: 6),
                Text(
                  'Setara dengan ${_currentTon.toStringAsFixed(2).replaceAll('.', ',')} Ton (${_currentKuintal.toStringAsFixed(1).replaceAll('.', ',')} Kuintal)',
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF285438)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKualitasMutuCard() {
    final gradeItems = [
      {
        'badge': 'REKOMENDASI',
        'badgeColor': const Color(0xFF285438),
        'title': 'Grade A',
        'desc': 'Kualitas Super, butir hampa <3%, bebas kotoran/batu.',
      },
      {
        'badge': 'STANDAR',
        'badgeColor': const Color(0xFF556C5E),
        'title': 'Grade B',
        'desc': 'Kadar air pecah normal, butir hijau <10%.',
      },
      {
        'badge': 'LOKAL',
        'badgeColor': const Color(0xFF869E90),
        'title': 'Grade C',
        'desc': 'Perlu penjemuran ulang ke pengepul atau sertifikasi.',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2EBE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kualitas / Mutu Gabah',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF15261B),
                ),
              ),
              Text(
                'Kadar Air: 13,8%',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF708577),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(gradeItems.length, (index) {
            final isSelected = _selectedGradeIndex == index;
            final item = gradeItems[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => setState(() => _selectedGradeIndex = index),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF6FAF7) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF285438) : const Color(0xFFE2EBE5),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: item['badgeColor'] as Color,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item['badge'] as String,
                              style: const TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 18,
                            color: isSelected ? const Color(0xFF285438) : const Color(0xFF9FB2A6),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['title'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15261B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['desc'] as String,
                        style: const TextStyle(fontSize: 10.5, color: Color(0xFF6B8072)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
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
        border: Border.all(color: const Color(0xFFE2EBE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Metode Pemanenan',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF15261B),
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              setState(() {
                _harvestMethod = _harvestMethod == 'Mesin Combine Harvester'
                    ? 'Manual / Sabit & Thresher'
                    : 'Mesin Combine Harvester';
              });
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAF8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2EBE5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _harvestMethod,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF15261B),
                      ),
                    ),
                  ),
                  const Icon(Icons.unfold_more_rounded, size: 20, color: Color(0xFF708577)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _harvestMethod == 'Mesin Combine Harvester'
                ? 'Efisiensi susut panen tercepat <1,5%'
                : 'Tradisi gotong royong warga desa',
            style: const TextStyle(fontSize: 10.5, color: Color(0xFF708577)),
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
        border: Border.all(color: const Color(0xFFE2EBE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Biaya Petik / Tebas',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF15261B),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2EBE5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _costController,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF15261B),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const Icon(Icons.receipt_long_outlined, size: 18, color: Color(0xFF708577)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Termasuk upah angkut karung ke tepi jalan',
            style: TextStyle(fontSize: 10.5, color: Color(0xFF708577)),
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
        border: Border.all(color: const Color(0xFFE2EBE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.notes_rounded, size: 16, color: Color(0xFF285438)),
                  SizedBox(width: 6),
                  Text(
                    'Catatan Lapangan (Mandor)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF15261B),
                    ),
                  ),
                ],
              ),
              Text(
                'Terverifikasi otomatis',
                style: TextStyle(fontSize: 10, color: Color(0xFF708577)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2EBE5)),
            ),
            child: TextField(
              controller: _notesController,
              maxLines: 4,
              style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFF15261B),
                height: 1.4,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDokumentasiCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2EBE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.photo_library_outlined, size: 16, color: Color(0xFF285438)),
                  SizedBox(width: 6),
                  Text(
                    'Dokumentasi Panen & Timbangan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF15261B),
                    ),
                  ),
                ],
              ),
              Text(
                '2 Foto Terunggah',
                style: TextStyle(fontSize: 10.5, color: Color(0xFF708577)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?w=600&q=80',
                ),
                fit: BoxFit.cover,
              ),
            ),
            alignment: Alignment.bottomLeft,
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xCC000000),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '1/2 Karung Panen',
                style: TextStyle(fontSize: 9.5, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.photo_camera_outlined, size: 16),
              label: const Text('Ganti Foto Bukti', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8F4EC),
                foregroundColor: const Color(0xFF285438),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_a_photo_outlined, size: 16),
              label: const Text('Ambil Foto Tambahan', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF15261B),
                side: const BorderSide(color: Color(0xFFE2EBE5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Format JPG/PNG/HEIC, 10MB per berkas foto.',
              style: TextStyle(fontSize: 9.5, color: Color(0xFF9FB2A6)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary: Simpan Perubahan
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _saveChanges,
            icon: const Icon(Icons.check_circle_outline_rounded, size: 18, color: Colors.white),
            label: const Text(
              'Simpan Perubahan',
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

        // Row: Hapus Data Ini & Batal
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: _confirmDelete,
                  icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFDC2626)),
                  label: const Text(
                    'Hapus Data Ini',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFFDCBCB)),
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
                    backgroundColor: const Color(0xFFE8F4EC),
                    foregroundColor: const Color(0xFF285438),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
