import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/core/utils/currency_input_formatter.dart';
import 'package:pawon_mobile/core/widgets/pawon_form_header.dart';
import 'package:pawon_mobile/features/lahan/models/item_komoditas.dart';
import 'package:pawon_mobile/features/lahan/services/lahan_api_service.dart';
import 'package:pawon_mobile/features/penjualan/models/item_produk_saya.dart';
import 'package:pawon_mobile/features/penjualan/services/marketplace_penjualan_api_service.dart';

class LayarFormProduk extends StatefulWidget {
  final ItemProdukSaya? produkToEdit;

  const LayarFormProduk({super.key, this.produkToEdit});

  @override
  State<LayarFormProduk> createState() => _LayarFormProdukState();
}

class _LayarFormProdukState extends State<LayarFormProduk> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaController;
  late TextEditingController _deskripsiController;
  late TextEditingController _hargaController;
  late TextEditingController _hargaMinController;
  late TextEditingController _hargaMaxController;
  late TextEditingController _stokController;

  String _jenisHarga = 'tetap'; // 'tetap' | 'rentang'
  String _satuan = 'kg';
  String _status = 'aktif';
  String? _selectedKomoditasId;

  XFile? _selectedImage;
  Uint8List? _fotoBytes;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool _isLoadingKomoditas = true;
  List<ItemKomoditas> _komoditasList = [];

  final _apiService = MarketplacePenjualanApiService();
  final _lahanApiService = LahanApiService();

  final List<String> _satuanOptions = ['kg', 'ikat', 'karung', 'ton', 'kuintal', 'butir', 'buah'];

  @override
  void initState() {
    super.initState();
    final p = widget.produkToEdit;
    _namaController = TextEditingController(text: p?.namaProduk ?? '');
    _deskripsiController = TextEditingController(text: p?.deskripsi ?? '');
    _hargaController = TextEditingController(
      text: p != null && p.harga > 0 ? CurrencyInputFormatter.format(p.harga) : '',
    );
    _hargaMinController = TextEditingController(
      text: p != null && p.hargaMin != null ? CurrencyInputFormatter.format(p.hargaMin!) : '',
    );
    _hargaMaxController = TextEditingController(
      text: p != null && p.hargaMax != null ? CurrencyInputFormatter.format(p.hargaMax!) : '',
    );
    _stokController = TextEditingController(
      text: p != null ? p.stokFisik.toInt().toString() : '',
    );

    if (p != null) {
      _jenisHarga = p.jenisHarga;
      _satuan = p.satuan.toLowerCase();
      _status = p.status;
      _selectedKomoditasId = p.idKomoditas;
    }

    _loadKomoditas();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _hargaController.dispose();
    _hargaMinController.dispose();
    _hargaMaxController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  Future<void> _loadKomoditas() async {
    try {
      final res = await _lahanApiService.getKomoditasList();
      if (mounted) {
        final list = res.data ?? [];
        list.sort((a, b) => a.namaKomoditas.toLowerCase().compareTo(b.namaKomoditas.toLowerCase()));
        setState(() {
          _komoditasList = list;
          _isLoadingKomoditas = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingKomoditas = false);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _selectedImage = picked;
          _fotoBytes = bytes;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  Future<void> _saveProduk() async {
    if (!_formKey.currentState!.validate()) return;

    if (_jenisHarga == 'rentang') {
      final min = CurrencyInputFormatter.parse(_hargaMinController.text);
      final max = CurrencyInputFormatter.parse(_hargaMaxController.text);
      if (min > max) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harga minimum tidak boleh melebihi harga maksimum!'),
            backgroundColor: WarnaAplikasi.errorRedDark,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final payload = <String, dynamic>{
        'nama_produk': _namaController.text.trim(),
        'id_komoditas': _selectedKomoditasId,
        'deskripsi': _deskripsiController.text.trim(),
        'jenis_harga': _jenisHarga,
        'satuan': _satuan,
        'stok_fisik': double.tryParse(_stokController.text.trim()) ?? 0,
        'status': _status,
      };

      if (_jenisHarga == 'rentang') {
        payload['harga_min'] = CurrencyInputFormatter.parse(_hargaMinController.text);
        payload['harga_max'] = CurrencyInputFormatter.parse(_hargaMaxController.text);
      } else {
        payload['harga'] = CurrencyInputFormatter.parse(_hargaController.text);
      }

      if (widget.produkToEdit == null) {
        // Tambah baru
        final res = await _apiService.createProduk(payload, fotoFile: _selectedImage);
        if (res.success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Produk berhasil dipublikasikan ke Marketplace!'),
                backgroundColor: WarnaAplikasi.primary,
              ),
            );
            Navigator.of(context).pop(true);
          }
        } else {
          throw Exception(res.message);
        }
      } else {
        // Update produk
        final res = await _apiService.updateProduk(
          widget.produkToEdit!.idProduk,
          payload,
          fotoFile: _selectedImage,
        );
        if (res.success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Produk berhasil diperbarui!'),
                backgroundColor: WarnaAplikasi.primary,
              ),
            );
            Navigator.of(context).pop(true);
          }
        } else {
          throw Exception(res.message);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan produk: $e'),
            backgroundColor: WarnaAplikasi.errorRedDark,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.produkToEdit != null;

    return Scaffold(
      backgroundColor: WarnaAplikasi.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            PawonFormHeader(
              title: isEdit ? 'Edit Produk Saya' : 'Tambah Produk Marketplace',
              subtitle: 'Pasarkan hasil panen ke Website Customer PawonTani',
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImagePickerCard(),
                      const SizedBox(height: 16),
                      _buildMainDetailsCard(),
                      const SizedBox(height: 16),
                      _buildPricingCard(),
                      const SizedBox(height: 16),
                      _buildStockAndStatusCard(),
                      const SizedBox(height: 24),
                      _buildSaveButton(isEdit),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerCard() {
    return Builder(builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
      final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.border;
      final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark;
      final subtitleColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray;
      final previewBoxBg = isDark ? const Color(0xFF141916) : WarnaAplikasi.bgLightGreen;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Foto Produk Hasil Panen',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Unggah foto produk yang jelas dan menarik untuk calon pembeli.',
              style: TextStyle(fontSize: 11.5, color: subtitleColor),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => _showImageSourcePicker(),
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: previewBoxBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, style: BorderStyle.solid),
                ),
                child: _fotoBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          _fotoBytes!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : widget.produkToEdit?.fotoResolvedUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              widget.produkToEdit!.fotoResolvedUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, _, _) => _buildPlaceholder(),
                            ),
                          )
                        : _buildPlaceholder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? WarnaAplikasi.accentGreen : WarnaAplikasi.primary,
                    side: BorderSide(color: isDark ? const Color(0xFF3B4A40) : WarnaAplikasi.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.camera_alt_outlined, size: 16),
                  label: const Text('Kamera', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? WarnaAplikasi.accentGreen : WarnaAplikasi.primary,
                    side: BorderSide(color: isDark ? const Color(0xFF3B4A40) : WarnaAplikasi.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.photo_library_outlined, size: 16),
                  label: const Text('Galeri', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined, size: 42, color: WarnaAplikasi.primary.withValues(alpha: 0.7)),
        const SizedBox(height: 8),
        const Text(
          'Ketuk untuk memilih foto',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WarnaAplikasi.primary),
        ),
        const Text(
          'PNG, JPG hingga 5MB',
          style: TextStyle(fontSize: 10, color: WarnaAplikasi.textGray),
        ),
      ],
    );
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: WarnaAplikasi.primary),
              title: const Text('Ambil Foto Kamera'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: WarnaAplikasi.primary),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showKomoditasSearchDialog() {
    final searchController = TextEditingController();
    List<ItemKomoditas> filtered = List.from(_komoditasList);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.75,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              builder: (_, scrollController) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: WarnaAplikasi.border,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const Text(
                        'Pilih Komoditas',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: WarnaAplikasi.textDark),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Cari nama komoditas...',
                          hintStyle: const TextStyle(fontSize: 13, color: WarnaAplikasi.textGrayLight),
                          prefixIcon: const Icon(Icons.search_rounded, color: WarnaAplikasi.primary, size: 20),
                          filled: true,
                          fillColor: WarnaAplikasi.bgInput,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: WarnaAplikasi.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: WarnaAplikasi.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: WarnaAplikasi.primary, width: 1.5),
                          ),
                        ),
                        onChanged: (q) {
                          setModalState(() {
                            filtered = _komoditasList
                                .where((k) => k.namaKomoditas.toLowerCase().contains(q.toLowerCase()))
                                .toList();
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: filtered.isEmpty
                            ? const Center(
                                child: Text(
                                  'Komoditas tidak ditemukan',
                                  style: TextStyle(color: WarnaAplikasi.textGray, fontSize: 13),
                                ),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                itemCount: filtered.length,
                                separatorBuilder: (_, _) => const Divider(height: 1, color: WarnaAplikasi.border),
                                itemBuilder: (_, i) {
                                  final k = filtered[i];
                                  final isSelected = k.idKomoditas == _selectedKomoditasId;
                                  return ListTile(
                                    dense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    leading: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: isSelected ? WarnaAplikasi.primary : WarnaAplikasi.bgLightGreen,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          k.namaKomoditas.isNotEmpty ? k.namaKomoditas[0].toUpperCase() : '?',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected ? Colors.white : WarnaAplikasi.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      k.namaKomoditas,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        color: isSelected ? WarnaAplikasi.primary : WarnaAplikasi.textDark,
                                      ),
                                    ),
                                    trailing: isSelected
                                        ? const Icon(Icons.check_circle_rounded, color: WarnaAplikasi.primary, size: 20)
                                        : null,
                                    onTap: () {
                                      setState(() => _selectedKomoditasId = k.idKomoditas);
                                      Navigator.pop(ctx);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMainDetailsCard() {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
        final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.border;
        final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informasi Dasar',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: titleColor),
              ),
              const SizedBox(height: 14),

              // Nama Produk
              Text('Nama Produk *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: titleColor)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _namaController,
                style: TextStyle(color: isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark),
                decoration: _inputDecoration(hint: 'Contoh: Beras Organik Pandanwangi Super', context: context),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nama produk wajib diisi' : null,
              ),
              const SizedBox(height: 14),

              // Komoditas
              Text('Kategori Komoditas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: titleColor)),
              const SizedBox(height: 6),
              _isLoadingKomoditas
                  ? const LinearProgressIndicator()
                  : GestureDetector(
                      onTap: () => _showKomoditasSearchDialog(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF141916) : WarnaAplikasi.bgInput,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedKomoditasId != null
                                    ? (_komoditasList.firstWhere(
                                        (k) => k.idKomoditas == _selectedKomoditasId,
                                        orElse: () => _komoditasList.first,
                                      ).namaKomoditas)
                                    : 'Pilih jenis komoditas',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _selectedKomoditasId != null
                                      ? (isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark)
                                      : WarnaAplikasi.textGrayLight,
                                ),
                              ),
                            ),
                            const Icon(Icons.search_rounded, color: WarnaAplikasi.primary, size: 20),
                          ],
                        ),
                      ),
                    ),
              const SizedBox(height: 14),

              // Deskripsi
              Text('Deskripsi Produk', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: titleColor)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _deskripsiController,
                maxLines: 3,
                style: TextStyle(color: isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark),
                decoration: _inputDecoration(hint: 'Jelaskan kualitas, varietas, kadar air, atau cara penyimpanan...', context: context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPricingCard() {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
        final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.border;
        final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Penetapan Harga',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: titleColor),
              ),
              const SizedBox(height: 12),

              // Toggle Jenis Harga
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _jenisHarga = 'tetap'),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _jenisHarga == 'tetap'
                              ? (isDark ? const Color(0xFF283A2E) : WarnaAplikasi.greenLight)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _jenisHarga == 'tetap' ? WarnaAplikasi.primary : borderColor,
                          ),
                        ),
                        child: Text(
                          'Harga Tetap',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: _jenisHarga == 'tetap' ? FontWeight.w700 : FontWeight.w500,
                            color: _jenisHarga == 'tetap'
                                ? (isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary)
                                : (isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _jenisHarga = 'rentang'),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _jenisHarga == 'rentang'
                              ? (isDark ? const Color(0xFF283A2E) : WarnaAplikasi.greenLight)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _jenisHarga == 'rentang' ? WarnaAplikasi.primary : borderColor,
                          ),
                        ),
                        child: Text(
                          'Rentang Harga',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: _jenisHarga == 'rentang' ? FontWeight.w700 : FontWeight.w500,
                            color: _jenisHarga == 'rentang'
                                ? (isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary)
                                : (isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_jenisHarga == 'tetap') ...[
                Text('Harga Tetap (Rp) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: titleColor)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _hargaController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyInputFormatter()],
                  style: TextStyle(color: isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark),
                  decoration: _inputDecoration(hint: 'Misal: 15.000', prefixText: 'Rp ', context: context),
                  validator: (v) {
                    if (_jenisHarga == 'tetap' && (v == null || v.trim().isEmpty)) {
                      return 'Harga tetap wajib diisi';
                    }
                    return null;
                  },
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Harga Min (Rp) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: titleColor)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _hargaMinController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [CurrencyInputFormatter()],
                            style: TextStyle(color: isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark),
                            decoration: _inputDecoration(hint: '12.000', prefixText: 'Rp ', context: context),
                            validator: (v) {
                              if (_jenisHarga == 'rentang' && (v == null || v.trim().isEmpty)) {
                                return 'Min wajib diisi';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Harga Max (Rp) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: titleColor)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _hargaMaxController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [CurrencyInputFormatter()],
                            style: TextStyle(color: isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark),
                            decoration: _inputDecoration(hint: '15.000', prefixText: 'Rp ', context: context),
                            validator: (v) {
                              if (_jenisHarga == 'rentang' && (v == null || v.trim().isEmpty)) {
                                return 'Max wajib diisi';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStockAndStatusCard() {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
        final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.border;
        final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stok & Ketersediaan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: titleColor),
              ),
              const SizedBox(height: 14),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stok Fisik
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Stok Manual *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: titleColor)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _stokController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark),
                          decoration: _inputDecoration(hint: 'Misal: 100', context: context),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Stok wajib diisi' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Satuan
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Satuan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: titleColor)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _satuan,
                          dropdownColor: isDark ? const Color(0xFF1D2420) : Colors.white,
                          style: TextStyle(color: isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark),
                          decoration: _inputDecoration(hint: 'Satuan', context: context),
                          items: _satuanOptions.map((s) {
                            return DropdownMenuItem<String>(
                              value: s,
                              child: Text(s, style: TextStyle(color: isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _satuan = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Status Publikasi
              Text('Status Publikasi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: titleColor)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _status,
                dropdownColor: isDark ? const Color(0xFF1D2420) : Colors.white,
                style: TextStyle(color: isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark),
                decoration: _inputDecoration(hint: 'Status', context: context),
                items: [
                  DropdownMenuItem(value: 'aktif', child: Text('Aktif (Tampil di Website Customer)', style: TextStyle(color: isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark))),
                  DropdownMenuItem(value: 'tidak_aktif', child: Text('Tidak Aktif (Sembunyikan)', style: TextStyle(color: isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark))),
                  DropdownMenuItem(value: 'stok_habis', child: Text('Stok Habis', style: TextStyle(color: isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark))),
                  DropdownMenuItem(value: 'diarsipkan', child: Text('Diarsipkan', style: TextStyle(color: isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark))),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSaveButton(bool isEdit) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProduk,
        style: ElevatedButton.styleFrom(
          backgroundColor: WarnaAplikasi.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: WarnaAplikasi.primary.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Text(
                isEdit ? 'Simpan Perubahan Produk' : 'Terbitkan ke Marketplace',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, String? prefixText, BuildContext? context}) {
    final isDark = context != null ? (Theme.of(context).brightness == Brightness.dark) : false;
    return InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      hintStyle: const TextStyle(fontSize: 13, color: WarnaAplikasi.textGrayLight),
      filled: true,
      fillColor: isDark ? const Color(0xFF141916) : WarnaAplikasi.bgInput,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? const Color(0xFF28332C) : WarnaAplikasi.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? const Color(0xFF28332C) : WarnaAplikasi.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: WarnaAplikasi.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: WarnaAplikasi.errorRedDark),
      ),
    );
  }
}
