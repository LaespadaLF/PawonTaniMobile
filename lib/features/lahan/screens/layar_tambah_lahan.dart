import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/core/widgets/pawon_form_header.dart';
import 'package:pawon_mobile/features/lahan/services/lahan_api_service.dart';
import 'package:pawon_mobile/features/lahan/widgets/layar_pilih_titik_peta.dart';

class AddLandScreen extends StatefulWidget {
  const AddLandScreen({super.key});

  @override
  State<AddLandScreen> createState() => _AddLandScreenState();
}

class _AddLandScreenState extends State<AddLandScreen> {
  final _nameController = TextEditingController();
  final _areaController = TextEditingController(text: '0,8');
  final _notesController = TextEditingController();
  final _latitudeController = TextEditingController(text: '-6.5621');
  final _longitudeController = TextEditingController(text: '107.7589');
  late final MapController _mapController;

  String _selectedDesa = 'Desa Sukamaju, Dusun Krajan';
  String _selectedCrop = 'Padi Ciherang';
  String _selectedSeason = 'MT-1 (Musim Hujan)';
  bool _isSubmitting = false;
  XFile? _selectedImage;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
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

  Future<void> _submitLand() async {
    setState(() => _isSubmitting = true);

    final payload = <String, dynamic>{
      'nama_lahan': _nameController.text.trim(),
      'luas': double.tryParse(_areaController.text.replaceAll(',', '.')) ?? 0.0,
      'alamat_lahan': _selectedDesa,
      'latitude': double.tryParse(_latitudeController.text.replaceAll(',', '.')) ?? -6.5621,
      'longitude': double.tryParse(_longitudeController.text.replaceAll(',', '.')) ?? 107.7589,
      'musim_tanam': _selectedSeason,
      'keterangan': _notesController.text.trim(),
    };

    final service = LahanApiService();
    final fotoFile = await _toMultipartFile(_selectedImage);
    final response = await service.createLahanWithFoto(payload, fotoFile);

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (response.success && response.data != null) {
      Navigator.pop(context, response.data);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message.isNotEmpty ? response.message : 'Gagal menyimpan data lahan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
        SnackBar(
          content: Text('Gagal mengambil lokasi: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PawonFormHeader(
        title: 'Tambah Lahan',
        subtitle: 'Daftarkan petak garapanmu untuk pemantauan',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
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
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        border: Border.all(color: WarnaAplikasi.border),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Stack(
                          children: [
                            FlutterMap(
                              key: ValueKey('${_latitudeController.text},${_longitudeController.text}'),
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
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Latitude', style: TextStyle(fontSize: 10, color: WarnaAplikasi.textGray)),
                                TextField(
                                  controller: _latitudeController,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: WarnaAplikasi.border)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: WarnaAplikasi.border)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Longitude', style: TextStyle(fontSize: 10, color: WarnaAplikasi.textGray)),
                                TextField(
                                  controller: _longitudeController,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: WarnaAplikasi.border)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: WarnaAplikasi.border)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(bottom: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () async {
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
                          },
                          icon: const Icon(Icons.edit, size: 14, color: WarnaAplikasi.primary),
                          label: const Text('Ubah Titik Lokasi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(bottom: 12),
                      child: SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: OutlinedButton.icon(
                          onPressed: _useCurrentLocation,
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
                  Text(_selectedImage == null ? 'Belum ada foto' : '1 Foto Terpilih', style: const TextStyle(fontSize: 11, color: WarnaAplikasi.primaryLight)),
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
                  if (_selectedImage != null) ...[
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
                              onTap: () => setState(() => _selectedImage = null),
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
                      onPressed: _isSubmitting ? null : _submitLand,
                      icon: _isSubmitting
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.save_outlined, color: Colors.white, size: 18),
                      label: Text(_isSubmitting ? 'Menyimpan...' : 'Simpan Data Lahan', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

    
    // Quick hack for dashed rounded rectangle: draw lines and clip it, wait clipping stroke is complex.
    // Simpler is to just draw rect, but since we want dashed, we use dashed path.
    // For now, drawing simple lines
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

