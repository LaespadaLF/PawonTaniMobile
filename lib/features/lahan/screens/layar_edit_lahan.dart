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
  late TextEditingController _addressController;
  late TextEditingController _notesController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late final MapController _mapController;

  String _selectedAreaUnit = 'Hektar (Ha)';
  bool _isMapInteractive = false;
  String? _selectedCropId;
  String _selectedSeason = 'MT-1 (Musim Hujan: Okt - Mar)';
  bool _isSubmitting = false;
  bool _isDeleting = false;
  final List<XFile> _selectedImages = [];
  final List<Uint8List> _selectedImageBytesList = [];
  final List<String> _keptOldPhotos = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _nameController = TextEditingController(text: widget.item.nama);
    final rawLuas = widget.item.luas;
    final initialLuasText = (rawLuas % 1 == 0)
        ? rawLuas.toInt().toString()
        : rawLuas.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    _areaController = TextEditingController(text: initialLuasText.replaceAll('.', ','));
    _areaController.addListener(_onAreaInputChanged);
    _addressController = TextEditingController(text: widget.item.lokasi);
    _notesController = TextEditingController(text: widget.item.keterangan ?? '');
    _latitudeController = TextEditingController(text: (widget.item.latitude ?? -6.5621).toStringAsFixed(6));
    _longitudeController = TextEditingController(text: (widget.item.longitude ?? 107.7589).toStringAsFixed(6));
    _selectedSeason = (widget.item.musimTanam != null && widget.item.musimTanam!.isNotEmpty)
        ? widget.item.musimTanam!
        : 'MT-1 (Musim Hujan)';
    _selectedCropId = widget.item.idKomoditas;
    _keptOldPhotos
      ..clear()
      ..addAll(widget.item.photos.where((p) => p.trim().isNotEmpty));
    if (_keptOldPhotos.isEmpty && widget.item.fotoLahan != null && widget.item.fotoLahan!.trim().isNotEmpty) {
      _keptOldPhotos.add(widget.item.fotoLahan!);
    }
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.primaryDark;
    final subtitleColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray;
    final cardBg = isDark ? const Color(0xFF1D2420) : WarnaAplikasi.greenLight;
    final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.border;
    final inputFill = isDark ? const Color(0xFF141916) : Colors.transparent;

    return Scaffold(
      backgroundColor: WarnaAplikasi.getBackgroundColor(context),
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
                  color: isDark ? const Color(0xFF1D2420) : WarnaAplikasi.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: isDark ? Border.all(color: const Color(0xFF28332C)) : null,
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit_note, color: isDark ? const Color(0xFF81C784) : Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('MODE PENYUNTINGAN LAHAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.borderField)),
                          Text('${widget.item.nama}${widget.item.nomorRevisi > 0 ? " (Revisi #${widget.item.nomorRevisi})" : ""}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFF1F5F2) : Colors.white)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF283A2E) : WarnaAplikasi.primaryDark,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text('Aktif', style: TextStyle(color: isDark ? const Color(0xFF81C784) : Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
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
                  Text('SPESIFIKASI & IDENTITAS LAHAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: titleColor)),
                ],
              ),
              const SizedBox(height: 16),
              
              // Name
              RichText(text: TextSpan(children: [
                TextSpan(text: 'Nama / Penamaan Petak ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: titleColor)),
                const TextSpan(text: '*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
              ])),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: TextStyle(color: titleColor),
                decoration: InputDecoration(
                  filled: isDark,
                  fillColor: inputFill,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 4),
              Text('Gunakan nama yang mudah dibedakan saat pencatatan pupuk & hasil panen.', style: TextStyle(fontSize: 11, color: subtitleColor)),
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
                      style: TextStyle(color: titleColor),
                      decoration: InputDecoration(
                        filled: isDark,
                        fillColor: inputFill,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
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
                        color: inputFill,
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedAreaUnit,
                          isExpanded: true,
                          dropdownColor: isDark ? const Color(0xFF1D2420) : Colors.white,
                          style: TextStyle(color: titleColor, fontSize: 13),
                          items: ['Hektar (Ha)', 'Meter Persegi (m²)'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: _onAreaUnitChanged,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_areaEquivalentText.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(_areaEquivalentText, style: const TextStyle(fontSize: 11, color: WarnaAplikasi.primaryLight, fontWeight: FontWeight.w600)),
              ],
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
                style: TextStyle(color: titleColor),
                decoration: InputDecoration(
                  filled: isDark,
                  fillColor: inputFill,
                  hintText: 'Contoh: Dusun Krajan RT 02 / RW 01, Desa Sukamaju',
                  hintStyle: const TextStyle(fontSize: 12, color: WarnaAplikasi.textGrayLight),
                  prefixIcon: const Icon(Icons.location_on_outlined, color: WarnaAplikasi.textGray, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WarnaAplikasi.primary, width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Map
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(text: TextSpan(children: [
                    TextSpan(text: 'Titik Koordinat & Peta Lahan ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: titleColor)),
                    const TextSpan(text: '*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
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
                  color: cardBg,
                  border: Border.all(color: borderColor),
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

              // Info Banner: Informasi Penanaman
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1D2420) : WarnaAplikasi.greenLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Komoditas, varietas, dan musim tanam operasional dikelola secara terpusat melalui fitur Siklus Tanam pada halaman Detail Lahan.',
                        style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.primaryDark, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Keterangan Tambahan (Opsional)', style: TextStyle(fontSize: 12, color: subtitleColor)),
                  const Text('98/200', style: TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayLight)),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 3,
                style: TextStyle(color: titleColor),
                decoration: InputDecoration(
                  filled: isDark,
                  fillColor: inputFill,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WarnaAplikasi.primary, width: 1.5)),
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
                      Text('DOKUMENTASI PETAK', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: titleColor)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF283A2E) : WarnaAplikasi.greenLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text('2 Foto Terpasang', style: TextStyle(color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Text('Foto kondisi visual terbaru memudahkan verifikasi PPL dan pemantauan fase tumbuh.', style: TextStyle(fontSize: 11, color: subtitleColor)),
              const SizedBox(height: 16),

              // Photos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dokumentasi Petak (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: titleColor)),
                  Text('${_keptOldPhotos.length + _selectedImageBytesList.length} Foto Terpilih', style: const TextStyle(fontSize: 11, color: WarnaAplikasi.primaryLight)),
                ],
              ),
              const SizedBox(height: 8),
              if (_keptOldPhotos.isNotEmpty) ...[
                Text('Foto Tersimpan:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGrayGreen)),
                const SizedBox(height: 6),
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _keptOldPhotos.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (ctx, index) {
                      final url = _keptOldPhotos[index];
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              url,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 90,
                                height: 90,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => setState(() => _keptOldPhotos.removeAt(index)),
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
              if (_selectedImageBytesList.isNotEmpty) ...[
                const Text('Foto Baru yang Akan Ditambahkan:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: WarnaAplikasi.textGrayGreen)),
                const SizedBox(height: 6),
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
                    color: isDark ? const Color(0xFF1D2420) : Colors.transparent,
                    border: Border.all(color: borderColor, style: BorderStyle.none),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomPaint(
                    painter: _DashedRectPainter(color: borderColor),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_a_photo_outlined, color: WarnaAplikasi.primaryLight, size: 20),
                        const SizedBox(width: 8),
                        Text('Tambah Foto Lahan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: titleColor)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Info Alert
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1D2420) : WarnaAplikasi.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: isDark ? Border.all(color: borderColor) : null,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: WarnaAplikasi.primaryLight, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Perubahan luas dan titik GPS akan diselaraskan dengan data kelompok tani serta buku saku digital PPL wilayah Sukamaju.',
                        style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGrayGreen),
                      ),
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
                      onPressed: (_isDeleting || _isSubmitting) ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        side: BorderSide(color: borderColor),
                        backgroundColor: isDark ? const Color(0xFF1D2420) : WarnaAplikasi.bgInput,
                      ),
                      child: Text('Batal', style: TextStyle(color: titleColor, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: (_isSubmitting || _isDeleting) ? null : _submitUpdate,
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
              if (widget.item.isCanDelete) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: (_isDeleting || _isSubmitting) ? null : _confirmAndDeleteLand,
                    icon: _isDeleting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                          )
                        : const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                    label: Text(
                      _isDeleting ? 'Menghapus...' : 'Hapus Petak Sawah Ini',
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      side: const BorderSide(color: WarnaAplikasi.errorRedBorder),
                      backgroundColor: WarnaAplikasi.errorRedBg,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAndDeleteLand() async {
    if (_isDeleting || _isSubmitting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Hapus Lahan?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Text(
          'Yakin ingin menghapus lahan "${widget.item.nama}"? Data yang dihapus tidak bisa dikembalikan.',
          style: const TextStyle(fontSize: 13),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed || !mounted) return;

    setState(() => _isDeleting = true);

    try {
      final response = await LahanApiService().deleteLahan(widget.item.id);
      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lahan berhasil dihapus.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, 'delete');
      } else {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message.isNotEmpty ? response.message : 'Gagal menghapus lahan.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus lahan: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
        const SnackBar(
          content: Text('Gagal mengambil lokasi GPS saat ini.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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

  Future<void> _submitUpdate() async {
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

    final rawArea = double.tryParse(_areaController.text.replaceAll(',', '.')) ?? widget.item.luas;
    final areaInHa = _selectedAreaUnit == 'Meter Persegi (m²)' ? (rawArea / 10000.0) : rawArea;

    final payload = <String, dynamic>{
      'nama_lahan': _nameController.text.trim(),
      'luas': areaInHa,
      'alamat_lahan': address,
      'latitude': double.tryParse(_latitudeController.text.replaceAll(',', '.')) ?? widget.item.latitude ?? -6.5621,
      'longitude': double.tryParse(_longitudeController.text.replaceAll(',', '.')) ?? widget.item.longitude ?? 107.7589,
      'id_komoditas': _selectedCropId,
      'musim_tanam': _selectedSeason,
      'keterangan': _notesController.text.trim(),
      'existing_photos': List<String>.from(_keptOldPhotos),
    };

    final List<MultipartFile> photoFiles = [];
    for (int i = 0; i < _selectedImageBytesList.length; i++) {
      final name = i < _selectedImages.length ? _selectedImages[i].name : 'lahan_$i.jpg';
      photoFiles.add(MultipartFile.fromBytes(_selectedImageBytesList[i], filename: name));
    }

    final service = LahanApiService();
    final response = await service.updateLahanWithFoto(
      widget.item.id,
      payload,
      null,
      fotoLahanList: photoFiles.isEmpty ? null : photoFiles,
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (response.success && response.data != null) {
      Navigator.pop(context, response.data);
    } else {
      final errorMsg = response.firstErrorMessage ??
          (response.message.isNotEmpty ? response.message : 'Gagal memperbarui data lahan.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
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

