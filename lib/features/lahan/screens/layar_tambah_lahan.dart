import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:flutter/material.dart';
import 'package:pawon_mobile/features/lahan/models/item_lahan.dart';

class AddLandScreen extends StatefulWidget {
  const AddLandScreen({super.key});

  @override
  State<AddLandScreen> createState() => _AddLandScreenState();
}

class _AddLandScreenState extends State<AddLandScreen> {
  final _nameController = TextEditingController();
  final _areaController = TextEditingController(text: '0,8');
  final _notesController = TextEditingController();

  String _selectedDesa = 'Desa Sukamaju, Dusun Krajan';
  String _selectedCrop = 'Padi Ciherang';
  String _selectedSeason = 'MT-1 (Musim Hujan)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: WarnaAplikasi.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Lahan',
          style: TextStyle(fontWeight: FontWeight.w800, color: WarnaAplikasi.primaryDark, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daftarkan petak garapanmu untuk memudahkan pemantauan tanaman.',
                style: TextStyle(fontSize: 13, color: WarnaAplikasi.textGray),
              ),
              const SizedBox(height: 24),
              const Text('Informasi Lahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark)),
              const SizedBox(height: 16),
              
              // Name
              RichText(text: const TextSpan(children: [
                TextSpan(text: 'Nama / Penamaan Petak ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: WarnaAplikasi.primaryDark)),
                TextSpan(text: '*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
              ])),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Petak Sawah Barat',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WarnaAplikasi.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WarnaAplikasi.border)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 4),
              const Text('Gunakan nama yang mudah dibedakan.', style: TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayLight)),
              const SizedBox(height: 16),

              // Area
              RichText(text: const TextSpan(children: [
                TextSpan(text: 'Luas Lahan ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: WarnaAplikasi.primaryDark)),
                TextSpan(text: '*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
              ])),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _areaController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WarnaAplikasi.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WarnaAplikasi.border)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: WarnaAplikasi.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: 'Hektar (Ha)',
                          isExpanded: true,
                          items: ['Hektar (Ha)', 'Meter Persegi (m²)'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) {},
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text('≈ 8.000 m²', style: TextStyle(fontSize: 11, color: WarnaAplikasi.primaryLight, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),

              // Location Dropdown
              RichText(text: const TextSpan(children: [
                TextSpan(text: 'Alamat & Lokasi Desa ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: WarnaAplikasi.primaryDark)),
                TextSpan(text: '*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
              ])),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: WarnaAplikasi.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDesa,
                    isExpanded: true,
                    items: [_selectedDesa].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) {},
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Map
              RichText(text: const TextSpan(children: [
                TextSpan(text: 'Titik Koordinat & Peta Lahan ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: WarnaAplikasi.primaryDark)),
                TextSpan(text: '*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
              ])),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: WarnaAplikasi.border),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 140,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        image: DecorationImage(
                          image: NetworkImage('https://maps.googleapis.com/maps/api/staticmap?center=-6.5621,107.7589&zoom=15&size=400x150&maptype=roadmap'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          const Center(child: Icon(Icons.location_on, color: WarnaAplikasi.primary, size: 36)),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                              child: const Row(
                                children: [
                                  Icon(Icons.crop_free, size: 14, color: WarnaAplikasi.primary),
                                  SizedBox(width: 4),
                                  Text('Pilih Lokasi', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark)),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Lat: -6.5621', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          Container(width: 1, height: 12, color: WarnaAplikasi.border),
                          const Text('Long: 107.7589', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(bottom: 12),
                      child: SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.gps_fixed, size: 14, color: WarnaAplikasi.primary),
                          label: const Text('Gunakan Lokasi GPS Saat Ini', style: TextStyle(color: WarnaAplikasi.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: WarnaAplikasi.greenLight,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Crop Dropdown
              RichText(text: const TextSpan(children: [
                TextSpan(text: 'Komoditas / Tanaman ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: WarnaAplikasi.primaryDark)),
                TextSpan(text: '*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
              ])),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: WarnaAplikasi.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCrop,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: [_selectedCrop].map((e) => DropdownMenuItem(value: e, child: Row(
                      children: [
                        const Icon(Icons.eco_outlined, color: WarnaAplikasi.primaryLight, size: 18),
                        const SizedBox(width: 8),
                        Text(e),
                      ],
                    ))).toList(),
                    onChanged: (v) {},
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Season Dropdown
              RichText(text: const TextSpan(children: [
                TextSpan(text: 'Musim Tanam ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: WarnaAplikasi.primaryDark)),
                TextSpan(text: '*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
              ])),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: WarnaAplikasi.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSeason,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: [_selectedSeason].map((e) => DropdownMenuItem(value: e, child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, color: WarnaAplikasi.textGray, size: 18),
                        const SizedBox(width: 8),
                        Text(e),
                      ],
                    ))).toList(),
                    onChanged: (v) {},
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Photos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dokumentasi Petak (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: WarnaAplikasi.primaryDark)),
                  const Text('1 Foto Terpilih', style: TextStyle(fontSize: 11, color: WarnaAplikasi.primaryLight)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFBFE0CD), style: BorderStyle.none),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CustomPaint(
                        painter: _DashedRectPainter(color: const Color(0xFFBFE0CD)),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined, color: WarnaAplikasi.primaryLight),
                            SizedBox(height: 4),
                            Text('Ambil Foto / Galeri', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark)),
                            Text('JPG, PNG maks 5MB', style: TextStyle(fontSize: 9, color: WarnaAplikasi.textGrayLight)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: const DecorationImage(
                              image: NetworkImage('https://images.unsplash.com/photo-1595246140625-573b715d11dc?w=300&q=80'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Foto Kondisi Awal', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 2)])),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 14),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),

              // Notes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Keterangan Tambahan (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: WarnaAplikasi.primaryDark)),
                  const Text('0/200', style: TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayLight)),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tambahkan informasi lahan bila diperlukan...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WarnaAplikasi.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WarnaAplikasi.border)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Info Alert
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: WarnaAplikasi.greenLight, borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: WarnaAplikasi.primary, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Data akan diverifikasi oleh PPL dan dicatat pada sistem ROCKK untuk validasi petak.', style: TextStyle(fontSize: 11, color: WarnaAplikasi.primary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Buttons
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        side: const BorderSide(color: WarnaAplikasi.border),
                      ),
                      child: const Text('Batal', style: TextStyle(color: WarnaAplikasi.primaryDark, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final newLand = ItemLahan(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          nama: _nameController.text.isEmpty ? 'Petak Baru' : _nameController.text,
                          lokasi: _selectedDesa,
                          luas: double.tryParse(_areaController.text.replaceAll(',', '.')) ?? 0.0,
                          komoditas: _selectedCrop,
                          status: StatusLahan.aktif,
                        );
                        Navigator.pop(context, newLand);
                      },
                      icon: const Icon(Icons.save_outlined, color: Colors.white, size: 18),
                      label: const Text('Simpan Data Lahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WarnaAplikasi.primaryLight,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;

  _DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final path = Path();

    // Top
    for (double i = 0; i < size.width; i += dashWidth + dashSpace) {
      path.moveTo(i, 0);
      path.lineTo(i + dashWidth > size.width ? size.width : i + dashWidth, 0);
    }
    // Right
    for (double i = 0; i < size.height; i += dashWidth + dashSpace) {
      path.moveTo(size.width, i);
      path.lineTo(size.width, i + dashWidth > size.height ? size.height : i + dashWidth);
    }
    // Bottom
    for (double i = size.width; i > 0; i -= dashWidth + dashSpace) {
      path.moveTo(i, size.height);
      path.lineTo(i - dashWidth < 0 ? 0 : i - dashWidth, size.height);
    }
    // Left
    for (double i = size.height; i > 0; i -= dashWidth + dashSpace) {
      path.moveTo(0, i);
      path.lineTo(0, i - dashWidth < 0 ? 0 : i - dashWidth);
    }

    final rrect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12));
    final clipPath = Path()..addRRect(rrect);
    
    // Quick hack for dashed rounded rectangle: draw lines and clip it, wait clipping stroke is complex.
    // Simpler is to just draw rect, but since we want dashed, we use dashed path.
    // For now, drawing simple lines
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

