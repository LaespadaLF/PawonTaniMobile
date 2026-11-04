import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/core/widgets/pawon_form_header.dart';
import 'package:pawon_mobile/features/lahan/models/item_lahan.dart';
import 'package:pawon_mobile/features/lahan/services/lahan_api_service.dart';
import 'package:pawon_mobile/features/lahan/widgets/layar_pilih_titik_peta.dart';

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
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late final MapController _mapController;

  String _selectedDesa = 'Desa Sukamaju, Dusun Krajan, RT 02/RW 01';
  String _selectedCrop = 'Padi Ciherang (Unggul Nasional)';
  String _selectedSeason = 'MT-1 (Musim Hujan: Okt - Mar)';
  bool _isSubmitting = false;
  XFile? _selectedImage;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _nameController = TextEditingController(text: widget.item.nama);
    _areaController = TextEditingController(text: widget.item.luas.toStringAsFixed(1).replaceAll('.', ','));
    _notesController = TextEditingController(text: 'Kondisi tanah petak A sangat responsif terhadap pupuk organik kandang. Saluran irigasi sekunder lancar.');
    _latitudeController = TextEditingController(text: (widget.item.latitude ?? -6.5621).toStringAsFixed(6));
    _longitudeController = TextEditingController(text: (widget.item.longitude ?? 107.7589).toStringAsFixed(6));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PawonFormHeader(
        title: 'Edit Informasi Lahan',
        subtitle: 'Perbarui data spesifikasi dan kondisi petak garapanmu',
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
                          const Text('MODE PENYUNTINGAN LAHAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: WarnaAplikasi.borderField)),
                          Text('${widget.item.nama} | ID: LHN-SKM-04', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: WarnaAplikasi.primaryDark, borderRadius: BorderRadius.circular(16)),
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
                  border: Border.all(color: WarnaAplikasi.borderField),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        border: Border.all(color: WarnaAplikasi.borderField),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Stack(
                          children: [
                            FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: LatLng(
                                  double.tryParse(_latitudeController.text.replaceAll(',', '.')) ?? -6.5621,
                                  double.tryParse(_longitudeController.text.replaceAll(',', '.')) ?? 107.7589,
                                ),
                                initialZoom: 16,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                                ),
                                onPositionChanged: (camera, hasGesture) {
                                  if (hasGesture) {
                                    final center = camera.center;
                                    setState(() {
                                      _latitudeController.text = center.latitude.toStringAsFixed(6);
                                      _longitudeController.text = center.longitude.toStringAsFixed(6);
                                    });
                                  }
                                },
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'id.pawontani.mobile',
                                  tileProvider: NetworkTileProvider(),
                                ),
                              ],
                            ),
                            // Center floating pin
                            IgnorePointer(
                              child: Align(
                                alignment: Alignment.center,
                                child: Transform.translate(
                                  offset: const Offset(0, -24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: WarnaAplikasi.primaryLight,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          _nameController.text.isEmpty ? 'Petak' : _nameController.text,
                                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Icon(
                                        Icons.location_on,
                                        color: WarnaAplikasi.primary,
                                        size: 40,
                                        shadows: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Lat: ${_latitudeController.text}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          Text('Long: ${_longitudeController.text}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          TextButton.icon(
                            onPressed: _bukaPetaPicker,
                            icon: const Icon(Icons.edit, size: 14, color: WarnaAplikasi.primary),
                            label: const Text('Ubah Titik Lokasi', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark)),
                          ),
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
                  onPressed: _useCurrentLocation,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dokumentasi Petak (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: WarnaAplikasi.primaryDark)),
                  Text((_imageBytes != null || widget.item.fotoLahan != null) ? '1 Foto Terpilih' : 'Belum ada foto', style: const TextStyle(fontSize: 11, color: WarnaAplikasi.primaryLight)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: WarnaAplikasi.borderField, style: BorderStyle.none),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomPaint(
                          painter: _DashedRectPainter(color: WarnaAplikasi.borderField),
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
                  ),
                  if (_imageBytes != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: MemoryImage(_imageBytes!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _selectedImage = null;
                                _imageBytes = null;
                              }),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
                                child: const Icon(Icons.close, color: Colors.white, size: 14),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ] else if (widget.item.fotoLahan != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: NetworkImage(widget.item.fotoLahan!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _selectedImage = null;
                                _imageBytes = null;
                              }),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
                                child: const Icon(Icons.close, color: Colors.white, size: 14),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ]
                ],
              ),
              const SizedBox(height: 12),

              // Info Alert
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: WarnaAplikasi.backgroundLight, borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: WarnaAplikasi.primaryLight, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Perubahan luas dan titik GPS akan diselaraskan dengan data kelompok tani serta buku saku digital PPL wilayah Sukamaju.', style: TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayGreen)),
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
                        backgroundColor: WarnaAplikasi.bgInput,
                      ),
                      child: const Text('Batal', style: TextStyle(color: WarnaAplikasi.primaryDark, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitUpdate,
                      icon: const Icon(Icons.check, color: Colors.white, size: 18),
                      label: Text(_isSubmitting ? 'Menyimpan...' : 'Simpan Perubahan Lahan', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WarnaAplikasi.primary,
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

  Future<void> _bukaPetaPicker() async {
    final initial = LatLng(
      double.tryParse(_latitudeController.text.replaceAll(',', '.')) ?? -6.5621,
      double.tryParse(_longitudeController.text.replaceAll(',', '.')) ?? 107.7589,
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LayarPilihTitikPeta(initialPosition: initial),
      ),
    );

    if (!mounted) return;

    if (result is LatLng) {
      setState(() {
        _latitudeController.text = result.latitude.toStringAsFixed(6);
        _longitudeController.text = result.longitude.toStringAsFixed(6);
      });
    }
  }

  Future<void> _useCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Layanan lokasi tidak aktif. Silakan aktifkan GPS.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin akses lokasi ditolak.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izin lokasi ditolak permanen. Silakan ubah di pengaturan perangkat.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);

      if (!mounted) return;

      setState(() {
        _latitudeController.text = position.latitude.toStringAsFixed(6);
        _longitudeController.text = position.longitude.toStringAsFixed(6);
      });

      _mapController.move(latLng, 15);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengambil lokasi GPS saat ini.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet<XFile>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              Text('Ambil Foto dari...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: WarnaAplikasi.primaryDark)),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: WarnaAplikasi.primary),
                title: const Text('Buka Kamera', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Ambil foto langsung dari kamera', style: TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayLight)),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 85, maxWidth: 1200);
                  if (!mounted || picked == null) return;
                  final bytes = await picked.readAsBytes();
                  if (!mounted) return;
                  setState(() {
                    _selectedImage = picked;
                    _imageBytes = bytes;
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: WarnaAplikasi.primary),
                title: const Text('Pilih dari Galeri', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Pilih foto dari galeri perangkat', style: TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayLight)),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1200);
                  if (!mounted || picked == null) return;
                  final bytes = await picked.readAsBytes();
                  if (!mounted) return;
                  setState(() {
                    _selectedImage = picked;
                    _imageBytes = bytes;
                  });
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<MultipartFile?> _toMultipartFile(XFile? file) async {
    if (file == null) return null;
    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      return MultipartFile.fromBytes(bytes, filename: file.name);
    }
    return MultipartFile.fromFile(file.path, filename: file.name);
  }

  Future<void> _submitUpdate() async {
    setState(() => _isSubmitting = true);

    final payload = <String, dynamic>{
      'nama_lahan': _nameController.text.trim(),
      'luas': double.tryParse(_areaController.text.replaceAll(',', '.')) ?? widget.item.luas,
      'alamat_lahan': _selectedDesa,
      'latitude': double.tryParse(_latitudeController.text.replaceAll(',', '.')) ?? widget.item.latitude ?? -6.5621,
      'longitude': double.tryParse(_longitudeController.text.replaceAll(',', '.')) ?? widget.item.longitude ?? 107.7589,
      'musim_tanam': _selectedSeason,
      'keterangan': _notesController.text.trim(),
    };

    final service = LahanApiService();
    final fotoFile = await _toMultipartFile(_selectedImage);
    final response = await service.updateLahanWithFoto(widget.item.id, payload, fotoFile);

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (response.success && response.data != null) {
      Navigator.pop(context, response.data);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Gagal memperbarui data lahan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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

