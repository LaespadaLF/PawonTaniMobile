import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/features/dokumen/models/item_dokumen_saya.dart';
import 'package:pawon_mobile/features/dokumen/services/dokumen_api_service.dart';

class LayarDokumenSaya extends StatefulWidget {
  const LayarDokumenSaya({super.key});

  @override
  State<LayarDokumenSaya> createState() => _LayarDokumenSayaState();
}

class _LayarDokumenSayaState extends State<LayarDokumenSaya> {
  final DokumenApiService _apiService = DokumenApiService();

  bool _isLoading = true;

  bool _ktpUploaded = false;
  bool _kkUploaded = false;
  int _totalSppt = 0;
  List<ItemIzinDokumen> _activePermissions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final docRes = await _apiService.getDocumentsSummary();
    final permRes = await _apiService.getPermissions();

    if (!mounted) return;

    if (docRes.success && docRes.data != null) {
      final data = docRes.data!;
      final identitas = data['identitas'] is Map ? data['identitas'] as Map : {};
      final lands = data['lahan'] is List ? data['lahan'] as List : [];

      int spptCount = 0;
      for (final l in lands) {
        if (l is Map && l['sppt_documents'] is List) {
          spptCount += (l['sppt_documents'] as List).length;
        }
      }

      setState(() {
        _ktpUploaded = identitas['ktp'] != null;
        _kkUploaded = identitas['kk'] != null;
        _totalSppt = spptCount;
      });
    }

    if (permRes.success && permRes.data != null) {
      setState(() {
        _activePermissions = permRes.data!;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pilihDanUnggah(String jenis) async {
    try {
      final pickedFiles = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (pickedFiles.isNotEmpty && pickedFiles.first.path != null) {
        final path = pickedFiles.first.path!;
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mengunggah dokumen $jenis...')),
        );

        final uploadRes = await _apiService.uploadIdentity(jenis, path);
        if (!mounted) return;

        if (uploadRes.success) {
          setState(() {
            if (jenis.toUpperCase() == 'KTP') _ktpUploaded = true;
            if (jenis.toUpperCase() == 'KK') _kkUploaded = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Dokumen $jenis berhasil diunggah!'),
              backgroundColor: WarnaAplikasi.primary,
            ),
          );
          _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(uploadRes.message.isNotEmpty ? uploadRes.message : 'Gagal mengunggah dokumen.'),
              backgroundColor: WarnaAplikasi.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: WarnaAplikasi.errorRed),
        );
      }
    }
  }

  void _tampilkanModalBagiIzin() {
    String selectedJenis = 'SEMUA';
    int masaBerlaku = 30;
    final tujuanController = TextEditingController(text: 'Administrasi Kelompok Tani');
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bagikan Izin Akses Dokumen',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(modalCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Pilih dokumen yang ingin diizinkan untuk dibuka/diunduh oleh Pengurus kelompok tani Anda:',
                    style: TextStyle(fontSize: 12, color: WarnaAplikasi.textGray),
                  ),
                  const SizedBox(height: 14),

                  // Pilihan jenis dokumen
                  const Text('Jenis Dokumen', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedJenis,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'SEMUA', child: Text('Semua Dokumen (KTP, KK, SPPT)')),
                      DropdownMenuItem(value: 'KTP', child: Text('Hanya KTP')),
                      DropdownMenuItem(value: 'KK', child: Text('Hanya Kartu Keluarga')),
                      DropdownMenuItem(value: 'SPPT', child: Text('Hanya Bukti SPPT Lahan')),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedJenis = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Masa berlaku
                  const Text('Masa Berlaku Akses', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<int>(
                    initialValue: masaBerlaku,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 7, child: Text('7 Hari (1 Minggu)')),
                      DropdownMenuItem(value: 30, child: Text('30 Hari (1 Bulan)')),
                      DropdownMenuItem(value: 90, child: Text('90 Hari (3 Bulan)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => masaBerlaku = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Tujuan Akses
                  const Text('Keperluan / Tujuan Akses', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: tujuanController,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Pembaruan administrasi kelompok',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tombol Bagikan
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final tujuan = tujuanController.text.trim();
                              if (tujuan.isEmpty) {
                                ScaffoldMessenger.of(modalCtx).showSnackBar(
                                  const SnackBar(content: Text('Tujuan akses wajib diisi.')),
                                );
                                return;
                              }

                              setModalState(() => isSubmitting = true);
                              final grantRes = await _apiService.grantPermission(
                                jenisDokumen: selectedJenis,
                                tujuanAkses: tujuan,
                                masaBerlakuHari: masaBerlaku,
                              );

                              if (!modalCtx.mounted) return;
                              if (grantRes.success) {
                                Navigator.pop(modalCtx);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Izin akses dokumen berhasil dibagikan.'),
                                      backgroundColor: WarnaAplikasi.primary,
                                    ),
                                  );
                                  _loadData();
                                }
                              } else {
                                setModalState(() => isSubmitting = false);
                                ScaffoldMessenger.of(modalCtx).showSnackBar(
                                  SnackBar(
                                    content: Text(grantRes.message.isNotEmpty ? grantRes.message : 'Gagal membagikan izin.'),
                                    backgroundColor: WarnaAplikasi.errorRed,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WarnaAplikasi.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isSubmitting
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Bagikan Izin Sekarang', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _cabutIzin(ItemIzinDokumen perm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cabut Izin Akses?'),
        content: Text('Pengurus tidak akan dapat lagi melihat atau mengunduh dokumen ${perm.jenisDokumen} Anda.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: WarnaAplikasi.errorRed),
            child: const Text('Ya, Cabut Izin', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final res = await _apiService.revokePermission(perm.id);
      if (!mounted) return;
      if (res.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin akses berhasil dicabut.'), backgroundColor: WarnaAplikasi.primary),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message.isNotEmpty ? res.message : 'Gagal mencabut izin.'), backgroundColor: WarnaAplikasi.errorRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarnaAplikasi.primaryBackground,
      appBar: AppBar(
        title: const Text('Dokumen & Privasi Saya', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: WarnaAplikasi.primaryDark)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: WarnaAplikasi.primary))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Banner Privasi Dokumen
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: WarnaAplikasi.bgLightGreen,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: WarnaAplikasi.border),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.shield_outlined, color: WarnaAplikasi.primary, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Privasi Anda Dilindungi',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: WarnaAplikasi.primaryDark),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Dokumen KTP, KK, dan SPPT tersimpan aman di platform PawonTani. Pengurus kelompok tani hanya dapat membuka atau mengunduh jika Anda telah memberikan izin aktif.',
                                style: TextStyle(fontSize: 11, color: WarnaAplikasi.textDark, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Seksi 1: Status Berkas Saya
                  const Text('Daftar Dokumen Saya', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark)),
                  const SizedBox(height: 10),

                  _buildDocCard(
                    title: 'Kartu Tanda Penduduk (KTP)',
                    subtitle: _ktpUploaded ? '✓ Dokumen KTP Sudah Diunggah' : 'Belum diunggah (Wajib untuk administrasi)',
                    isUploaded: _ktpUploaded,
                    onUpload: () => _pilihDanUnggah('KTP'),
                  ),
                  const SizedBox(height: 10),

                  _buildDocCard(
                    title: 'Kartu Keluarga (KK)',
                    subtitle: _kkUploaded ? '✓ Dokumen KK Sudah Diunggah' : 'Belum diunggah (Wajib untuk administrasi)',
                    isUploaded: _kkUploaded,
                    onUpload: () => _pilihDanUnggah('KK'),
                  ),
                  const SizedBox(height: 10),

                  _buildDocCard(
                    title: 'Bukti SPPT Lahan',
                    subtitle: _totalSppt > 0 ? '$_totalSppt berkas SPPT terhubung di daftar lahan' : 'Belum ada bukti SPPT di lahan',
                    isUploaded: _totalSppt > 0,
                    isLandDoc: true,
                  ),
                  const SizedBox(height: 24),

                  // Seksi 2: Izin Akses Aktif
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Izin Akses Pengurus', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark)),
                      TextButton.icon(
                        onPressed: _tampilkanModalBagiIzin,
                        icon: const Icon(Icons.share_outlined, size: 16, color: WarnaAplikasi.primary),
                        label: const Text('Bagi Izin', style: TextStyle(fontWeight: FontWeight.bold, color: WarnaAplikasi.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (_activePermissions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: WarnaAplikasi.border),
                      ),
                      child: const Center(
                        child: Text(
                          'Belum ada izin akses yang dibagikan. Pengurus tidak dapat melihat atau mengunduh dokumen Anda.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: WarnaAplikasi.textGray),
                        ),
                      ),
                    )
                  else
                    ..._activePermissions.map(
                      (perm) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: WarnaAplikasi.border),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: WarnaAplikasi.bgLightGreen,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.lock_open_rounded, color: WarnaAplikasi.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dokumen: ${perm.jenisDokumen}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: WarnaAplikasi.primaryDark),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Keperluan: ${perm.tujuanAkses}',
                                    style: const TextStyle(fontSize: 11, color: WarnaAplikasi.textGray),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Berlaku hingga: ${perm.berlakuSampai.day}/${perm.berlakuSampai.month}/${perm.berlakuSampai.year}',
                                    style: const TextStyle(fontSize: 10, color: WarnaAplikasi.primary, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: WarnaAplikasi.errorRed, size: 20),
                              tooltip: 'Cabut Izin',
                              onPressed: () => _cabutIzin(perm),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildDocCard({
    required String title,
    required String subtitle,
    required bool isUploaded,
    VoidCallback? onUpload,
    bool isLandDoc = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: WarnaAplikasi.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isUploaded ? const Color(0xFFEBF6E0) : const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isUploaded ? Icons.check_circle_outline_rounded : Icons.pending_actions_rounded,
              color: isUploaded ? WarnaAplikasi.primary : const Color(0xFFF97316),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: WarnaAplikasi.primaryDark)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: WarnaAplikasi.textGray)),
              ],
            ),
          ),
          if (!isLandDoc && onUpload != null)
            ElevatedButton(
              onPressed: onUpload,
              style: ElevatedButton.styleFrom(
                backgroundColor: isUploaded ? Colors.white : WarnaAplikasi.primary,
                foregroundColor: isUploaded ? WarnaAplikasi.primary : Colors.white,
                elevation: 0,
                side: isUploaded ? const BorderSide(color: WarnaAplikasi.primary) : null,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text(
                isUploaded ? 'Ganti' : 'Unggah',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
