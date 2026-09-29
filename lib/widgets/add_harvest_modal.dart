import 'package:flutter/material.dart';
import '../models/harvest_item.dart';

class AddHarvestModal extends StatefulWidget {
  final Function(HarvestItem) onAdd;

  const AddHarvestModal({super.key, required this.onAdd});

  @override
  State<AddHarvestModal> createState() => _AddHarvestModalState();
}

class _AddHarvestModalState extends State<AddHarvestModal> {
  final _formKey = GlobalKey<FormState>();
  CropType _selectedCrop = CropType.padi;
  final _varietyController = TextEditingController(text: 'Padi Ciherang');
  final _typeSubtitleController = TextEditingController(text: 'GKP • Gabah Kering Panen');
  final _locationController = TextEditingController(text: 'Petak Sawah Utara');
  final _blockAreaController = TextEditingController(text: 'Blok E • 0,6 Ha');
  final _weightController = TextEditingController(text: '3500');
  final _qualityController = TextEditingController(text: 'Kualitas Super');
  final _notesController = TextEditingController(text: 'Kadar Air 14%');
  String _season = 'Musim Rendeng';

  @override
  void dispose() {
    _varietyController.dispose();
    _typeSubtitleController.dispose();
    _locationController.dispose();
    _blockAreaController.dispose();
    _weightController.dispose();
    _qualityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onCropChanged(CropType type) {
    setState(() {
      _selectedCrop = type;
      if (type == CropType.padi) {
        _varietyController.text = 'Padi Ciherang';
        _typeSubtitleController.text = 'GKP • Gabah Kering Panen';
        _notesController.text = 'Kadar Air 14%';
      } else {
        _varietyController.text = 'Jagung Hibrida Bisi-18';
        _typeSubtitleController.text = 'Tongkol Kering Panen';
        _notesController.text = 'Pipilan Penuh';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tambah Hasil Panen Baru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF162A1D),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Catat data hasil panen untuk proses verifikasi dan kemitraan lelang.',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B8072)),
              ),
              const SizedBox(height: 16),

              // Crop Type Selector
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _onCropChanged(CropType.padi),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedCrop == CropType.padi
                              ? const Color(0xFF285438)
                              : const Color(0xFFF3F6F4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedCrop == CropType.padi
                                ? const Color(0xFF285438)
                                : const Color(0xFFE2EAE4),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.grass_rounded,
                              size: 16,
                              color: _selectedCrop == CropType.padi
                                  ? Colors.white
                                  : const Color(0xFF3B5243),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Padi',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _selectedCrop == CropType.padi
                                    ? Colors.white
                                    : const Color(0xFF3B5243),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _onCropChanged(CropType.jagung),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedCrop == CropType.jagung
                              ? const Color(0xFF285438)
                              : const Color(0xFFF3F6F4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedCrop == CropType.jagung
                                ? const Color(0xFF285438)
                                : const Color(0xFFE2EAE4),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bolt_rounded,
                              size: 16,
                              color: _selectedCrop == CropType.jagung
                                  ? Colors.white
                                  : const Color(0xFF3B5243),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Jagung',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _selectedCrop == CropType.jagung
                                    ? Colors.white
                                    : const Color(0xFF3B5243),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Variety & Subtitle
              TextFormField(
                controller: _varietyController,
                decoration: _inputDecoration('Varietas / Nama Komoditas', Icons.label_outline),
                validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: _inputDecoration('Lokasi Lahan', Icons.location_on_outlined),
                      validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _blockAreaController,
                      decoration: _inputDecoration('Blok & Luas', Icons.square_foot_outlined),
                      validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Berat (Kg)', Icons.scale_outlined),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Wajib diisi';
                        if (double.tryParse(val) == null) return 'Angka tidak valid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _season,
                      decoration: _inputDecoration('Musim', Icons.cloud_outlined),
                      items: const [
                        DropdownMenuItem(value: 'Musim Rendeng', child: Text('Musim Rendeng', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'Musim Gadu', child: Text('Musim Gadu', style: TextStyle(fontSize: 12))),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _season = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _qualityController,
                      decoration: _inputDecoration('Kualitas Grade', Icons.verified_outlined),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _notesController,
                      decoration: _inputDecoration('Kadar Air / Catatan', Icons.water_drop_outlined),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      final weight = double.parse(_weightController.text);
                      final now = DateTime.now();
                      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
                      final dateStr = '${now.day.toString().padLeft(2, '0')} ${months[now.month - 1]} ${now.year}';

                      final newItem = HarvestItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: _varietyController.text,
                        subtitle: _typeSubtitleController.text,
                        cropType: _selectedCrop,
                        status: HarvestStatus.menunggu,
                        location: _locationController.text,
                        blockArea: _blockAreaController.text,
                        date: dateStr,
                        season: _season,
                        weightKg: weight,
                        qualityGrade: _qualityController.text,
                        moistureOrNotes: _notesController.text,
                      );

                      widget.onAdd(newItem);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF285438),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Simpan Data Panen',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF6B8072)),
      prefixIcon: Icon(icon, size: 16, color: const Color(0xFF6B8072)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const ColorBorderSide(),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD6E2D9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF285438), width: 1.5),
      ),
    );
  }
}

class ColorBorderSide extends BorderSide {
  const ColorBorderSide() : super(color: const Color(0xFFD6E2D9));
}
