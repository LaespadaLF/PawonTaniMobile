import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:flutter/material.dart';
import 'package:pawon_mobile/features/aktivitas/models/item_aktivitas_tanam.dart';
import 'package:pawon_mobile/features/aktivitas/widgets/dialog_sukses_aktivitas.dart';

class RecordActivityScreen extends StatefulWidget {
  final Function(PlantActivityItem) onSave;

  const RecordActivityScreen({super.key, required this.onSave});

  @override
  State<RecordActivityScreen> createState() => _RecordActivityScreenState();
}

class _RecordActivityScreenState extends State<RecordActivityScreen> {
  // Lahan selection
  String _selectedLahan = 'Petak Sawah Barat (Blok A)';
  String _selectedLahanDetail = '0,75 Ha • Padi Ciherang';

  // Date & Time
  DateTime _selectedDate = DateTime(2024, 11, 15);
  TimeOfDay _selectedTime = const TimeOfDay(hour: 7, minute: 30);

  // Category
  ActivityCategory _selectedCategory = ActivityCategory.pemupukan;

  // Condition
  PlantCondition _selectedCondition = PlantCondition.sehat;

  // Notes
  final TextEditingController _notesController = TextEditingController(
    text: 'Pemupukan NPK Phonska sebanyak 50 kg dan pembersihan gulma di pematang sawah.',
  );

  // Photo
  String? _selectedPhotoUrl = 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=600&auto=format&fit=crop&q=80';

  final List<Map<String, String>> _availableLahan = [
    {
      'name': 'Petak Sawah Barat (Blok A)',
      'detail': '0,75 Ha • Padi Ciherang',
    },
    {
      'name': 'Petak Sawah Timur (Blok C)',
      'detail': '0,50 Ha • Jagung Manis',
    },
    {
      'name': 'Petak Lereng Selatan (Blok B)',
      'detail': '0,40 Ha • Cabai Merah',
    },
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m WIB';
  }

  void _handleSave() {
    final newActivity = PlantActivityItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _selectedCategory.label,
      cropName: _selectedLahanDetail.split('•').last.trim(),
      category: _selectedCategory,
      condition: _selectedCondition,
      date: _formatDate(_selectedDate),
      time: _formatTime(_selectedTime),
      location: _selectedLahan,
      blockArea: _selectedLahanDetail,
      notes: _notesController.text.trim().isEmpty
          ? 'Aktivitas rutin ${ _selectedCategory.label.toLowerCase() } pada petak sawah.'
          : _notesController.text.trim(),
      imageUrl: _selectedPhotoUrl,
      dayNumber: 45,
    );

    widget.onSave(newActivity);

    ActivitySuccessDialog.show(
      context,
      item: newActivity,
      onGoToHistory: () {
        Navigator.pop(context); // close dialog
        Navigator.pop(context); // close record screen back to list
      },
      onBackToList: () {
        Navigator.pop(context); // close dialog
        Navigator.pop(context); // close record screen
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarnaAplikasi.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: WarnaAplikasi.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Catat Aktivitas',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: WarnaAplikasi.primaryDark,
              ),
            ),
            Text(
              'Dokumentasikan aktivitas dan kondisi lahan Anda',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF718679),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          // Notification & Profile
          Container(
            margin: const EdgeInsets.only(right: 8),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE8EFEA)),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(Icons.notifications_none_rounded, size: 19, color: WarnaAplikasi.primaryDark),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE8EFEA)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              'https://images.unsplash.com/photo-1544717305-2782549b5136?w=150&auto=format&fit=crop&q=80',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: WarnaAplikasi.primary,
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFEBF0EC)),
        ),
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
                      color: const Color(0xFFD3E8D8),
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
                          'Catatan Harian Sawah',
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
                            color: Color(0xFF4B6653),
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
            _buildFieldLabel('Lahan*'),
            const SizedBox(height: 8),
            InkWell(
              onTap: _showLahanPicker,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2EBE5)),
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
                            _selectedLahan,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: WarnaAplikasi.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            _selectedLahanDetail,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF718679),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF718679),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // 2. Tanggal & Waktu*
            _buildFieldLabel('Tanggal & Waktu*'),
            const SizedBox(height: 8),
            Row(
              children: [
                // Date Field
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2EBE5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 16, color: WarnaAplikasi.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _formatDate(_selectedDate),
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: WarnaAplikasi.primaryDark,
                              ),
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF718679)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Time Field
                Expanded(
                  child: InkWell(
                    onTap: _pickTime,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2EBE5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 16, color: WarnaAplikasi.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _formatTime(_selectedTime),
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: WarnaAplikasi.primaryDark,
                              ),
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF718679)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 3. Aktivitas Pertanian*
            _buildFieldLabel('Aktivitas Pertanian*'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ActivityCategory.values.map((cat) {
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat.label),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedCategory = cat);
                  },
                  selectedColor: WarnaAplikasi.primary,
                  backgroundColor: Colors.white,
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF4B5563),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? WarnaAplikasi.primary : const Color(0xFFE2EBE5),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 4. Kondisi Tanaman*
            _buildFieldLabel('Kondisi Tanaman*'),
            const SizedBox(height: 10),
            _buildConditionOption(
              condition: PlantCondition.sehat,
              icon: Icons.spa_rounded,
              iconColor: WarnaAplikasi.primary,
              iconBg: const Color(0xFFE5F6EA),
              title: 'Sehat',
              subtitle: 'Pertumbuhan normal dan daun hijau segar.',
            ),
            const SizedBox(height: 10),
            _buildConditionOption(
              condition: PlantCondition.perluPerhatian,
              icon: Icons.warning_amber_rounded,
              iconColor: WarnaAplikasi.warningOrange,
              iconBg: const Color(0xFFFFF3E0),
              title: 'Perlu Perhatian',
              subtitle: 'Ada gejala kekeringan atau daun mulai menguning.',
            ),
            const SizedBox(height: 10),
            _buildConditionOption(
              condition: PlantCondition.terserangHama,
              icon: Icons.bug_report_outlined,
              iconColor: const Color(0xFFDC2626),
              iconBg: const Color(0xFFFEE2E2),
              title: 'Terserang Hama/Penyakit',
              subtitle: 'Ditemukan gejala serangan hama wereng/ulat/jamur.',
            ),
            const SizedBox(height: 20),

            // 5. Catatan Aktivitas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFieldLabel('Catatan Aktivitas'),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _notesController,
                  builder: (context, value, child) {
                    return Text(
                      '${value.text.length}/250',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF718679)),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2EBE5)),
              ),
              child: TextField(
                controller: _notesController,
                maxLines: 4,
                maxLength: 250,
                style: const TextStyle(fontSize: 13, color: WarnaAplikasi.primaryDark),
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: 'Contoh: Pemupukan susulan dengan dosis NPK Phonska...',
                  hintStyle: TextStyle(fontSize: 12.5, color: Color(0xFFA0B3A6)),
                  contentPadding: EdgeInsets.all(14),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 6. Foto Kondisi Tanaman (Opsional)
            _buildFieldLabel('Foto Kondisi Tanaman (Opsional)'),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                setState(() {
                  _selectedPhotoUrl = 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=600&auto=format&fit=crop&q=80';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Foto kondisi tanaman berhasil dipilih!'),
                    backgroundColor: WarnaAplikasi.primary,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFC7DDD0),
                    width: 1.2,
                  ),
                ),
                child: Column(
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
                      'JPG, PNG maks 10MB',
                      style: TextStyle(fontSize: 10.5, color: Color(0xFF718679)),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.check_circle_outline_rounded, size: 12, color: WarnaAplikasi.primary),
                        SizedBox(width: 4),
                        Text(
                          'Bantu sistem memantau kondisi petak lahan',
                          style: TextStyle(fontSize: 10.5, color: Color(0xFF718679)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Bottom Buttons: Batal & Simpan Aktivitas
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4B5563),
                        side: const BorderSide(color: Color(0xFFD4E0D7)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _handleSave,
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                      label: const Text(
                        'Simpan Aktivitas',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WarnaAplikasi.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
            color: isSelected ? WarnaAplikasi.primary : const Color(0xFFE2EBE5),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x04000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
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
                      color: Color(0xFF718679),
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
                  color: isSelected ? WarnaAplikasi.primary : const Color(0xFFB0C2B5),
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
                    color: const Color(0xFFD4E0D7),
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
              ..._availableLahan.map((lahan) {
                final isCurrent = _selectedLahan == lahan['name'];
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
                  title: Text(lahan['name']!, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                  subtitle: Text(lahan['detail']!, style: const TextStyle(fontSize: 11.5, color: Color(0xFF718679))),
                  trailing: isCurrent ? const Icon(Icons.check_circle_rounded, color: WarnaAplikasi.primary) : null,
                  onTap: () {
                    setState(() {
                      _selectedLahan = lahan['name']!;
                      _selectedLahanDetail = lahan['detail']!;
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: WarnaAplikasi.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: WarnaAplikasi.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }
}

