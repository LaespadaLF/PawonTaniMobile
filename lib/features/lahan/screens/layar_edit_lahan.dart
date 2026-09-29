import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:flutter/material.dart';
import 'package:pawon_mobile/features/lahan/models/item_lahan.dart';

class EditLandScreen extends StatefulWidget {
  final ItemLahan item;

  const EditLandScreen({super.key, required this.item});

  @override
  State<EditLandScreen> createState() => _EditLandScreenState();
}

class _EditLandScreenState extends State<EditLandScreen> {
  late TextEditingController _nameController;
  late TextEditingController _areaController;
  late TextEditingController _notesController;

  String _selectedDesa = 'Desa Sukamaju, Dusun Krajan, RT 02/RW 01';
  String _selectedCrop = 'Padi Ciherang (Unggul Nasional)';
  String _selectedSeason = 'MT-1 (Musim Hujan: Okt - Mar)';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.nama);
    _areaController = TextEditingController(text: widget.item.luas.toStringAsFixed(1).replaceAll('.', ','));
    _notesController = TextEditingController(text: 'Kondisi tanah petak A sangat responsif terhadap pupuk organik kandang. Saluran irigasi sekunder lancar.');
  }

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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Informasi Lahan', style: TextStyle(fontWeight: FontWeight.w800, color: WarnaAplikasi.primaryDark, fontSize: 18)),
            Text('Perbarui data spesifikasi dan kondisi petak garapanmu.', style: TextStyle(fontSize: 10, color: WarnaAplikasi.textGray)),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Editing Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: WarnaAplikasi.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.edit_note, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('MODE PENYUNTINGAN LAHAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFBFE0CD))),
                          Text('${widget.item.nama} | ID: LHN-SKM-04', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF5D876C), borderRadius: BorderRadius.circular(16)),
                      child: const Text('Aktif', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section 1
              Row(
                children: [
                  Container(width: 4, height: 16, color: WarnaAplikasi.primaryLight),
                  const SizedBox(width: 8),
                  const Text('SPESIFIKASI & IDENTITAS LAHAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark)),
                ],
              ),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WarnaAplikasi.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WarnaAplikasi.border)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 4),
              const Text('Gunakan nama yang mudah dibedakan saat pencatatan pupuk & hasil panen.', style: TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayLight)),
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
                      decoration: BoxDecoration(border: Border.all(color: WarnaAplikasi.border), borderRadius: BorderRadius.circular(12)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: 'Hektar (Ha)',
                          isExpanded: true,
                          items: ['Hektar (Ha)'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) {},
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text('≈ 8.000 m² (Konversi baku otomatis)', style: TextStyle(fontSize: 11, color: WarnaAplikasi.primaryLight, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),

              // Location Dropdown
              RichText(text: const TextSpan(children: [
                TextSpan(text: 'Alamat & Lokasi Desa ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: WarnaAplikasi.primaryDark)),
                TextSpan(text: '*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
              ])),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(border: Border.all(color: WarnaAplikasi.border), borderRadius: BorderRadius.circular(12)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDesa,
                    isExpanded: true,
                    items: [_selectedDesa].map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (v) {},
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Map
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(text: const TextSpan(children: [
                    TextSpan(text: 'Titik Koordinat & Peta Lahan ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: WarnaAplikasi.primaryDark)),
                    TextSpan(text: '*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                  ])),
                  const Row(
                    children: [
                      Icon(Icons.check_circle, size: 14, color: WarnaAplikasi.primaryLight),
                      SizedBox(width: 4),
                      Text('GPS Terverifikasi', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryLight)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: WarnaAplikasi.greenLight,
                  border: Border.all(color: const Color(0xFFBFE0CD)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 120,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        image: DecorationImage(
                          image: NetworkImage('https://maps.googleapis.com/maps/api/staticmap?center=-6.5621,107.7589&zoom=16&size=400x150&maptype=roadmap'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: WarnaAplikasi.primaryLight, borderRadius: BorderRadius.circular(4)),
                                  child: const Text('Petak A', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                ),
                                const Icon(Icons.location_on, color: WarnaAplikasi.primaryLight, size: 36),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                              child: const Row(
                                children: [
                                  Icon(Icons.edit, size: 14, color: WarnaAplikasi.primary),
                                  SizedBox(width: 4),
                                  Text('Ubah Titik Lokasi', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark)),
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
                          const Text('Long: 107.7589', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          const Text('Akurasi ± 3m', style: TextStyle(fontSize: 11, color: WarnaAplikasi.primaryLight)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 36,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.location_searching, size: 14, color: WarnaAplikasi.primary),
                  label: const Text('Perbarui Titik dengan GPS Perangkat', style: TextStyle(color: WarnaAplikasi.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: WarnaAplikasi.backgroundLight,
                    side: const BorderSide(color: WarnaAplikasi.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
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
                decoration: BoxDecoration(border: Border.all(color: WarnaAplikasi.border), borderRadius: BorderRadius.circular(12)),
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
                decoration: BoxDecoration(border: Border.all(color: WarnaAplikasi.border), borderRadius: BorderRadius.circular(12)),
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

              // Notes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Keterangan Tambahan (Opsional)', style: TextStyle(fontSize: 12, color: WarnaAplikasi.textGray)),
                  const Text('98/200', style: TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayLight)),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WarnaAplikasi.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WarnaAplikasi.border)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),

              // Section 2
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 4, height: 16, color: WarnaAplikasi.primaryLight),
                      const SizedBox(width: 8),
                      const Text('DOKUMENTASI PETAK', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: WarnaAplikasi.greenLight, borderRadius: BorderRadius.circular(16)),
                    child: const Text('2 Foto Terpasang', style: TextStyle(color: WarnaAplikasi.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              const SizedBox(height: 8),
              const Text('Foto kondisi visual terbaru memudahkan verifikasi PPL dan pemantauan fase tumbuh.', style: TextStyle(fontSize: 11, color: WarnaAplikasi.textGray)),
              const SizedBox(height: 16),

              // Photos
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(border: Border.all(color: WarnaAplikasi.border), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          Container(
                            height: 90,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                              image: DecorationImage(image: NetworkImage('https://images.unsplash.com/photo-1595246140625-573b715d11dc?w=300&q=80'), fit: BoxFit.cover),
                            ),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(4)),
                                child: const Text('Vegetatif 30 HST', style: TextStyle(color: Colors.white, fontSize: 9)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(children: [Icon(Icons.upload, size: 12, color: WarnaAplikasi.primaryDark), SizedBox(width: 4), Text('Ganti', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))]),
                                const Icon(Icons.delete_outline, size: 14, color: Colors.red),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(border: Border.all(color: WarnaAplikasi.border), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          Container(
                            height: 90,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                              image: DecorationImage(image: NetworkImage('https://images.unsplash.com/photo-1586771107445-d3ca888129ff?w=300&q=80'), fit: BoxFit.cover),
                            ),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(4)),
                                child: const Text('Cek Anakan 40 HST', style: TextStyle(color: Colors.white, fontSize: 9)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(children: [Icon(Icons.upload, size: 12, color: WarnaAplikasi.primaryDark), SizedBox(width: 4), Text('Ganti', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))]),
                                const Icon(Icons.delete_outline, size: 14, color: Colors.red),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomPaint(
                  painter: _DashedRectPainter(color: const Color(0xFFBFE0CD)),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: WarnaAplikasi.primaryLight),
                      SizedBox(height: 4),
                      Text('+ Unggah Dokumentasi Baru', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark)),
                      Text('Format JPG/PNG, ukuran berkas maksimal 5MB', style: TextStyle(fontSize: 9, color: WarnaAplikasi.textGrayLight)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Info Alert
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: WarnaAplikasi.backgroundLight, borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: WarnaAplikasi.primaryLight, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Perubahan luas dan titik GPS akan diselaraskan dengan data kelompok tani serta buku saku digital PPL wilayah Sukamaju.', style: TextStyle(fontSize: 11, color: Color(0xFF475569))),
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
                        backgroundColor: const Color(0xFFF8FAFC),
                      ),
                      child: const Text('Batal', style: TextStyle(color: WarnaAplikasi.primaryDark, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final updatedLand = widget.item.copyWith(
                          nama: _nameController.text,
                          luas: double.tryParse(_areaController.text.replaceAll(',', '.')) ?? widget.item.luas,
                        );
                        Navigator.pop(context, updatedLand);
                      },
                      icon: const Icon(Icons.check, color: Colors.white, size: 18),
                      label: const Text('Simpan Perubahan Lahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context, 'delete');
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                  label: const Text('Hapus Petak Sawah Ini', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    side: const BorderSide(color: WarnaAplikasi.errorRedBorder),
                    backgroundColor: WarnaAplikasi.errorRedBg,
                  ),
                ),
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

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

