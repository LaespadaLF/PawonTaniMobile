import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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
  final _areaController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _latitudeController = TextEditingController(text: '-6.5621');
  final _longitudeController = TextEditingController(text: '107.7589');
  late final MapController _mapController;

  String _selectedAreaUnit = 'Hektar (Ha)';
  String _selectedStatusPenguasaan = 'Milik Sendiri';
  bool _isMapInteractive = false;
  String? _selectedCropId;
  bool _isSubmitting = false;
  final List<XFile> _selectedImages = [];
  final List<Uint8List> _selectedImageBytesList = [];
  PlatformFile? _selectedSpptFile;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _areaController.addListener(_onAreaInputChanged);
  }

  @override
  void dispose() {
    _areaController.removeListener(_onAreaInputChanged);
    _nameController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _onAreaInputChanged() {
    setState(() {});
  }

  String get _areaEquivalentText {
    final raw = double.tryParse(_areaController.text.replaceAll(',', '.'));
    if (raw == null || raw <= 0) return '';
    if (_selectedAreaUnit == 'Hektar (Ha)') {
      final m2 = raw * 10000;
      final formatted = (m2 % 1 == 0) ? m2.toInt().toString() : m2.toStringAsFixed(2);
      return '≈ $formatted m² (Konversi baku otomatis)';
    } else {
      final ha = raw / 10000;
      final formatted = (ha % 1 == 0)
          ? ha.toInt().toString()
          : ha.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
      return '≈ ${formatted.replaceAll('.', ',')} Ha (Konversi baku otomatis)';
    }
  }

  void _onAreaUnitChanged(String? newUnit) {
    if (newUnit == null || newUnit == _selectedAreaUnit) return;
    final currentVal = double.tryParse(_areaController.text.replaceAll(',', '.'));
    if (currentVal != null && currentVal > 0) {
      if (newUnit == 'Meter Persegi (m²)') {
        final newVal = currentVal * 10000;
        _areaController.text = (newVal % 1 == 0) ? newVal.toInt().toString() : newVal.toStringAsFixed(2);
      } else {
        final newVal = currentVal / 10000;
        final formatted = (newVal % 1 == 0)
            ? newVal.toInt().toString()
            : newVal.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
        _areaController.text = formatted.replaceAll('.', ',');
      }
    }
    setState(() {
      _selectedAreaUnit = newUnit;
    });
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
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
                    _selectedImages.add(picked);
                    _selectedImageBytesList.add(bytes);
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: WarnaAplikasi.primary),
                title: const Text('Pilih dari Galeri', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Pilih beberapa foto dari galeri', style: TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayLight)),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final pickedList = await picker.pickMultiImage(imageQuality: 85, maxWidth: 1200);
                  if (!mounted || pickedList.isEmpty) return;
                  for (final p in pickedList) {
                    final bytes = await p.readAsBytes();
                    if (!mounted) return;
                    setState(() {
                      _selectedImages.add(p);
                      _selectedImageBytesList.add(bytes);
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitLand() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan alamat / lokasi petak lahan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final rawArea = double.tryParse(_areaController.text.replaceAll(',', '.')) ?? 0.0;
    final areaInHa = _selectedAreaUnit == 'Meter Persegi (m²)' ? (rawArea / 10000.0) : rawArea;

    final payload = <String, dynamic>{
      'nama_lahan': _nameController.text.trim(),
      'luas': areaInHa,
      'status_penguasaan': _selectedStatusPenguasaan,
      'alamat_lahan': address,
      'latitude': double.tryParse(_latitudeController.text.replaceAll(',', '.')) ?? -6.5621,
      'longitude': double.tryParse(_longitudeController.text.replaceAll(',', '.')) ?? 107.7589,
      if (_selectedCropId != null && _selectedCropId!.isNotEmpty) 'id_komoditas': _selectedCropId,
      'keterangan': _notesController.text.trim(),
    };

    final List<MultipartFile> photoFiles = [];
    for (int i = 0; i < _selectedImageBytesList.length; i++) {
      final name = i < _selectedImages.length ? _selectedImages[i].name : 'lahan_$i.jpg';
      photoFiles.add(MultipartFile.fromBytes(_selectedImageBytesList[i], filename: name));
    }

    MultipartFile? spptMultipart;
    if (_selectedSpptFile != null) {
      final bytes = await _selectedSpptFile!.readAsBytes();
      spptMultipart = MultipartFile.fromBytes(
        bytes,
        filename: _selectedSpptFile!.name,
      );
    }

    final service = LahanApiService();
    final response = await service.createLahanWithFoto(
      payload,
      null,
      fotoLahanList: photoFiles.isEmpty ? null : photoFiles,
      dokumenSppt: spptMultipart,
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (response.success && response.data != null) {
      Navigator.pop(context, response.data);
    } else {
      final errorMsg = response.firstErrorMessage ??
          (response.message.isNotEmpty ? response.message : 'Gagal menyimpan data lahan.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
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
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      if (position.isMocked) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Peringatan: Terdeteksi Fake GPS / Mock Location. Harap gunakan lokasi asli.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
    final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.border;
    final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.primaryDark;
    final subtitleColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray;
    final hintColor = isDark ? const Color(0xFF627B6C) : WarnaAplikasi.textGrayLight;
    final bannerBg = isDark ? const Color(0xFF1B261F) : WarnaAplikasi.greenLight;

    return Scaffold(
      backgroundColor: WarnaAplikasi.getBackgroundColor(context),
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
              
              Text('Informasi Lahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: titleColor)),
              const SizedBox(height: 16),
              
              // Name
              RichText(text: TextSpan(children: [
                TextSpan(text: 'Nama / Penamaan Petak ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: titleColor)),
                const TextSpan(text: '*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
              ])),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: TextStyle(fontSize: 13, color: titleColor),
                decoration: InputDecoration(
                  hintText: 'Contoh: Petak Sawah Barat',
                  hintStyle: TextStyle(fontSize: 12, color: hintColor),
                  filled: true,
                  fillColor: cardBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WarnaAplikasi.primary, width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 4),
              Text('Gunakan nama yang mudah dibedakan.', style: TextStyle(fontSize: 11, color: hintColor)),
              const SizedBox(height: 16),

              // Area
              RichText(text: TextSpan(children: [
                TextSpan(text: 'Luas Lahan ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: titleColor)),
                const TextSpan(text: '*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
              ])),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _areaController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(fontSize: 13, color: titleColor),
                      decoration: InputDecoration(
                        hintText: 'Contoh: 0.8',
                        hintStyle: TextStyle(fontSize: 12, color: hintColor),
                        filled: true,
                        fillColor: cardBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WarnaAplikasi.primary, width: 1.5)),
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
                        color: cardBg,
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedAreaUnit,
                          isExpanded: true,
                          dropdownColor: cardBg,
                          style: TextStyle(color: titleColor, fontSize: 13, fontWeight: FontWeight.w600),
                          items: ['Hektar (Ha)', 'Meter Persegi (m²)'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: titleColor)))).toList(),
                          onChanged: _onAreaUnitChanged,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_areaEquivalentText.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(_areaEquivalentText, style: TextStyle(fontSize: 11, color: isDark ? WarnaAplikasi.accentGreen : WarnaAplikasi.primaryLight, fontWeight: FontWeight.w600)),
              ],
              const SizedBox(height: 16),

              // Status Penguasaan Lahan (Tenure Type)
              Text('Status Penguasaan Lahan *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: titleColor)),
              const SizedBox(height: 8),
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: cardBg,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStatusPenguasaan,
                    isExpanded: true,
                    dropdownColor: cardBg,
                    style: TextStyle(color: titleColor, fontSize: 13, fontWeight: FontWeight.w600),
                    items: ['Milik Sendiri', 'Sewa', 'Garap', 'Bagi Hasil', 'Lainnya']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: titleColor))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedStatusPenguasaan = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Location / Address Field
              RichText(text: TextSpan(children: [
                TextSpan(text: 'Alamat & Lokasi Lahan ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: titleColor)),
                const TextSpan(text: '*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
              ])),
              const SizedBox(height: 8),
              TextField(
                controller: _addressController,
                maxLines: 2,
                style: TextStyle(fontSize: 13, color: titleColor),
                decoration: InputDecoration(
                  hintText: 'Contoh: Dusun Krajan RT 02 / RW 01, Desa Sukamaju',
                  hintStyle: TextStyle(fontSize: 12, color: hintColor),
                  prefixIcon: Icon(Icons.location_on_outlined, color: subtitleColor, size: 20),
                  filled: true,
                  fillColor: cardBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WarnaAplikasi.primary, width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: LatLng(
                                  double.tryParse(_latitudeController.text.replaceAll(',', '.')) ?? -6.5621,
                                  double.tryParse(_longitudeController.text.replaceAll(',', '.')) ?? 107.7589,
                                ),
                                initialZoom: 16,
                                interactionOptions: InteractionOptions(
                                  flags: _isMapInteractive ? (InteractiveFlag.all & ~InteractiveFlag.rotate) : InteractiveFlag.none,
                                ),
                                onTap: (tapPosition, latLng) {
                                  _mapController.move(latLng, _mapController.camera.zoom);
                                  setState(() {
                                    _latitudeController.text = latLng.latitude.toStringAsFixed(6);
                                    _longitudeController.text = latLng.longitude.toStringAsFixed(6);
                                  });
                                },
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
                            // Map Interaction Toggle Badge
                            Positioned(
                              top: 8,
                              right: 8,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _isMapInteractive = !_isMapInteractive;
                                  });
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: _isMapInteractive ? WarnaAplikasi.primary : Colors.white.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _isMapInteractive ? Icons.lock_open_rounded : Icons.pan_tool_outlined,
                                        size: 14,
                                        color: _isMapInteractive ? Colors.white : WarnaAplikasi.primaryDark,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _isMapInteractive ? 'Mode geser aktif' : 'Ketuk untuk geser',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: _isMapInteractive ? Colors.white : WarnaAplikasi.primaryDark,
                                        ),
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
                                Text('Latitude', style: TextStyle(fontSize: 10, color: subtitleColor)),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: _latitudeController,
                                  style: TextStyle(fontSize: 12, color: titleColor),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF141916) : Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: WarnaAplikasi.primary, width: 1.5)),
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
                                Text('Longitude', style: TextStyle(fontSize: 10, color: subtitleColor)),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: _longitudeController,
                                  style: TextStyle(fontSize: 12, color: titleColor),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF141916) : Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: WarnaAplikasi.primary, width: 1.5)),
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
                          icon: Icon(Icons.edit, size: 14, color: isDark ? WarnaAplikasi.accentGreen : WarnaAplikasi.primary),
                          label: Text('Ubah Titik Lokasi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? WarnaAplikasi.accentGreen : WarnaAplikasi.primaryDark)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(bottom: 12),
                      child: SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: OutlinedButton.icon(
                          onPressed: _useCurrentLocation,
                          icon: Icon(Icons.gps_fixed, size: 14, color: isDark ? Colors.white : WarnaAplikasi.primary),
                          label: Text('Gunakan Lokasi GPS Saat Ini', style: TextStyle(color: isDark ? Colors.white : WarnaAplikasi.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isDark ? const Color(0xFF283A2E) : WarnaAplikasi.greenLight,
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

              // Info Banner: Informasi Penanaman
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bannerBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? const Color(0xFF28332C) : WarnaAplikasi.greenPill),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: isDark ? WarnaAplikasi.accentGreen : WarnaAplikasi.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Komoditas, varietas, dan musim tanam akan dicatat saat Anda memulai Siklus Tanam setelah lahan terdaftar.',
                        style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFFD4E0D7) : WarnaAplikasi.primaryDark, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Photos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dokumentasi Petak (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: titleColor)),
                  Text('${_selectedImageBytesList.length} Foto Terpilih', style: TextStyle(fontSize: 11, color: isDark ? WarnaAplikasi.accentGreen : WarnaAplikasi.primaryLight)),
                ],
              ),
              const SizedBox(height: 8),
              if (_selectedImageBytesList.isNotEmpty) ...[
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _selectedImageBytesList.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (ctx, index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              _selectedImageBytesList[index],
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _selectedImageBytesList.removeAt(index);
                                if (index < _selectedImages.length) {
                                  _selectedImages.removeAt(index);
                                }
                              }),
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), shape: BoxShape.circle),
                                child: const Icon(Icons.close, color: Colors.white, size: 12),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 65,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardBg,
                    border: Border.all(color: borderColor, style: BorderStyle.none),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomPaint(
                    painter: _DashedRectPainter(color: borderColor),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, color: isDark ? WarnaAplikasi.accentGreen : WarnaAplikasi.primaryLight, size: 20),
                        const SizedBox(width: 8),
                        Text('Ambil Foto / Pilih dari Galeri', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: titleColor)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Keterangan Tambahan (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: titleColor)),
                  Text('${_notesController.text.length}/200', style: TextStyle(fontSize: 11, color: hintColor)),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 4,
                style: TextStyle(fontSize: 13, color: titleColor),
                decoration: InputDecoration(
                  hintText: 'Tambahkan informasi lahan bila diperlukan...',
                  hintStyle: TextStyle(fontSize: 12, color: hintColor),
                  filled: true,
                  fillColor: cardBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WarnaAplikasi.primary, width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Upload Dokumen SPPT (1 Lahan = 1 SPPT)
              Text('Dokumen SPPT Lahan (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: titleColor)),
              const SizedBox(height: 4),
              Text('Lampirkan berkas SPPT kepemilikan/penguasaan lahan ini (Format: PDF/JPG, maks. 5 MB).', style: TextStyle(fontSize: 11, color: hintColor)),
              const SizedBox(height: 8),
              if (_selectedSpptFile != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: WarnaAplikasi.bgLightGreen,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: WarnaAplikasi.accentGreen.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.description, color: WarnaAplikasi.primary, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedSpptFile!.name,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: titleColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Berkas siap diunggah',
                              style: TextStyle(fontSize: 10, color: hintColor),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red, size: 18),
                        onPressed: () => setState(() => _selectedSpptFile = null),
                        tooltip: 'Hapus file',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              GestureDetector(
                onTap: () async {
                  final result = await FilePicker.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: const ['pdf', 'jpg', 'jpeg'],
                  );
                  if (result.isNotEmpty) {
                    setState(() => _selectedSpptFile = result.first);
                  }
                },
                child: Container(
                  height: 52,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardBg,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.file_present_outlined, color: isDark ? WarnaAplikasi.accentGreen : WarnaAplikasi.primaryLight, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _selectedSpptFile == null ? 'Pilih Berkas SPPT (PDF/JPG)' : 'Ganti Berkas SPPT',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: titleColor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Info Alert
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: bannerBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
                child: Row(
                  children: [
                    Icon(Icons.info, color: isDark ? WarnaAplikasi.accentGreen : WarnaAplikasi.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Data akan diverifikasi oleh PPL dan dicatat pada sistem ROCKK untuk validasi petak.', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFFD4E0D7) : WarnaAplikasi.primary)),
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
                        side: BorderSide(color: borderColor),
                      ),
                      child: Text('Batal', style: TextStyle(color: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.primaryDark, fontWeight: FontWeight.bold)),
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

