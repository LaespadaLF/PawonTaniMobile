import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:pawon_mobile/core/constants/api_constants.dart';
import 'package:pawon_mobile/core/storage/secure_storage_service.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/core/widgets/pawon_form_header.dart';
import 'package:pawon_mobile/features/aktivitas/models/item_aktivitas_tanam.dart';
import 'package:pawon_mobile/features/aktivitas/screens/layar_catat_aktivitas.dart';
import 'package:pawon_mobile/features/aktivitas/services/aktivitas_api_service.dart';
import 'package:pawon_mobile/features/auth/repositories/auth_repository.dart';
import 'package:pawon_mobile/features/lahan/models/item_dokumen_sppt.dart';
import 'package:pawon_mobile/features/lahan/models/item_komoditas.dart';
import 'package:pawon_mobile/features/lahan/models/item_lahan.dart';
import 'package:pawon_mobile/features/lahan/models/item_siklus_tanam.dart';
import 'package:pawon_mobile/features/lahan/screens/layar_edit_lahan.dart';
import 'package:pawon_mobile/features/lahan/services/lahan_api_service.dart';
import 'package:pawon_mobile/features/panen/models/item_panen.dart';
import 'package:pawon_mobile/features/panen/screens/layar_catat_panen.dart';
import 'package:pawon_mobile/features/panen/services/panen_api_service.dart';

class LandDetailScreen extends StatefulWidget {
  final ItemLahan item;

  const LandDetailScreen({super.key, required this.item});

  @override
  State<LandDetailScreen> createState() => _LandDetailScreenState();
}

class _LandDetailScreenState extends State<LandDetailScreen> {
  late ItemLahan _item;
  bool _isFetching = false;
  bool _isMapInteractive = false;

  final AktivitasApiService _aktivitasService = AktivitasApiService();
  List<PlantActivityItem> _activities = [];
  bool _isLoadingActivities = true;

  List<ItemDokumenSppt> _spptDocuments = [];
  bool _isLoadingSpptDocuments = true;
  bool _isUploadingSppt = false;

  // State Siklus Tanam & Operasional (Phase 2)
  ItemSiklusTanam? _siklusBerjalan;
  List<ItemSiklusTanam> _riwayatSiklus = [];
  bool _isLoadingSiklus = true;
  bool _isActionInProgress = false;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _siklusBerjalan = _item.siklusBerjalan;
    _fetchFreshDetail();
    _fetchLahanActivities();
    _fetchSpptDocuments();
    _fetchSiklusData();
  }

  Future<void> _fetchLahanActivities() async {
    setState(() => _isLoadingActivities = true);
    try {
      final res = await _aktivitasService.getAktivitasList(lahanId: _item.id);
      if (mounted) {
        setState(() {
          _activities = res.data ?? [];
          _isLoadingActivities = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingActivities = false);
    }
  }

  Future<void> _fetchSpptDocuments({bool showLoading = true}) async {
    if (showLoading && mounted) setState(() => _isLoadingSpptDocuments = true);
    try {
      final response = await LahanApiService().getSpptDocuments(_item.id);
      if (!mounted) return;
      setState(() {
        _spptDocuments = response.success ? (response.data ?? []) : [];
        _isLoadingSpptDocuments = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingSpptDocuments = false);
    }
  }

  Future<void> _pickAndUploadSppt() async {
    if (_isUploadingSppt) return;

    try {
      final pickedFiles = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg'],
      );

      if (!mounted || pickedFiles.isEmpty) return;

      if (pickedFiles.length > 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maksimal 10 dokumen SPPT dapat diunggah sekaligus.'),
          ),
        );
        return;
      }

      for (final file in pickedFiles) {
        final extension = (file.extension ?? file.name.split('.').last)
            .toLowerCase();

        if (!['pdf', 'jpg', 'jpeg'].contains(extension)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Format ${file.name} tidak didukung.')),
          );
          return;
        }

        final fileSize = file.lengthSync() ?? await file.length();

        if (!mounted) return;

        if (fileSize != null && fileSize > 5 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${file.name} melebihi batas 5 MB.')),
          );
          return;
        }
      }

      if (!mounted) return;

      setState(() => _isUploadingSppt = true);

      final response = await LahanApiService().uploadSpptDocuments(
        _item.id,
        pickedFiles,
      );

      if (!mounted) return;

      setState(() => _isUploadingSppt = false);

      if (response.success) {
        await _fetchSpptDocuments(showLoading: false);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message.isNotEmpty
                  ? response.message
                  : 'Dokumen SPPT berhasil ditambahkan.',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.firstErrorMessage ??
                  (response.message.isNotEmpty
                      ? response.message
                      : 'Gagal mengunggah SPPT.'),
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      setState(() => _isUploadingSppt = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih atau mengunggah SPPT: $error')),
      );
    }
  }

  Future<void> _deleteSpptDocument(ItemDokumenSppt document) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text('Hapus dokumen SPPT?'),
            content: Text(
              'Dokumen "${document.namaFile}" akan dihapus. Data lahan dan dokumen SPPT lainnya tetap tersimpan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Hapus',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed || !mounted) return;
    final response = await LahanApiService().deleteSpptDocument(document.id);
    if (!mounted) return;
    if (response.success) {
      setState(
        () => _spptDocuments.removeWhere((item) => item.id == document.id),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.message.isNotEmpty
                ? response.message
                : 'Dokumen SPPT berhasil dihapus.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.message.isNotEmpty
                ? response.message
                : 'Dokumen SPPT gagal dihapus.',
          ),
        ),
      );
    }
  }

  String _formatSpptSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)} KB';
    }
    return '$bytes B';
  }

  String _formatSpptDate(DateTime? date) {
    if (date == null) return 'Tanggal tidak tersedia';
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
  }

  Widget _buildSpptDocumentsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WarnaAplikasi.greenLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Dokumen SPPT',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: WarnaAplikasi.primaryDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: WarnaAplikasi.greenLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_spptDocuments.length} file',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: WarnaAplikasi.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Perbarui dokumen saat masa berlaku atau masa sewa lahan berubah. Format PDF/JPG, maksimal 5 MB per file.',
            style: TextStyle(
              fontSize: 11,
              color: WarnaAplikasi.textGray,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoadingSpptDocuments)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_spptDocuments.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: WarnaAplikasi.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Belum ada dokumen SPPT untuk lahan ini.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: WarnaAplikasi.textGray),
              ),
            )
          else
            ..._spptDocuments.map(
              (document) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: WarnaAplikasi.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.insert_drive_file_outlined,
                      color: WarnaAplikasi.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            document.namaFile,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: WarnaAplikasi.textDarkGreen,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${_formatSpptSize(document.ukuranBytes)} · ${_formatSpptDate(document.diperbaruiPada)}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: WarnaAplikasi.textGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Hapus dokumen SPPT',
                      onPressed: () => _deleteSpptDocument(document),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                        size: 21,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isUploadingSppt ? null : _pickAndUploadSppt,
              icon: _isUploadingSppt
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file_rounded, size: 18),
              label: Text(
                _isUploadingSppt ? 'Mengunggah...' : 'Tambah SPPT Baru',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: WarnaAplikasi.primaryDark,
                side: const BorderSide(color: WarnaAplikasi.greenLight),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToCatatAktivitas() async {
    if (_siklusBerjalan == null || !_siklusBerjalan!.isAktif) {
      final msg = _siklusBerjalan == null
          ? 'Lahan ini belum memiliki siklus tanam aktif. Silakan mulai siklus tanam terlebih dahulu sebelum mencatat aktivitas.'
          : 'Siklus tanam sedang ${_siklusBerjalan!.statusLabel} dan tidak dapat menerima aktivitas baru.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: WarnaAplikasi.warningOrange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecordActivityScreen(
          initialLahanId: _item.id,
          initialLahanName: _item.nama,
          initialSiklus: _siklusBerjalan,
        ),
      ),
    );

    if (res == true || res is PlantActivityItem) {
      _fetchLahanActivities();
    }
  }

  Future<void> _navigateToCatatPanen() async {
    if (_siklusBerjalan == null || !_siklusBerjalan!.isAktif) {
      final msg = _siklusBerjalan == null
          ? 'Lahan ini belum memiliki siklus tanam aktif. Panen hanya dapat dicatat jika lahan memiliki siklus tanam berjalan.'
          : 'Siklus tanam sedang ${_siklusBerjalan!.statusLabel} dan tidak dapat menerima catatan panen baru.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: WarnaAplikasi.warningOrange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecordHarvestScreen(
          initialLahanId: _item.id,
          initialLahanName: _item.nama,
          initialSiklus: _siklusBerjalan,
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant LandDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item != widget.item) {
      _item = widget.item;
    }
  }

  Future<void> _fetchFreshDetail() async {
    if (_isFetching) return;
    _isFetching = true;
    try {
      final response = await LahanApiService().getLahanDetail(_item.id);
      if (mounted && response.success && response.data != null) {
        setState(() {
          _item = response.data!;
          _siklusBerjalan = _item.siklusBerjalan;
        });
      }
    } catch (_) {
      // Abaikan bila offline/error dalam background fetch
    } finally {
      if (mounted) {
        _isFetching = false;
      }
    }
  }

  Future<void> _fetchSiklusData({bool showLoading = true}) async {
    if (showLoading && mounted) setState(() => _isLoadingSiklus = true);
    try {
      final resBerjalan = await LahanApiService().getSiklusBerjalan(_item.id);
      final resRiwayat = await LahanApiService().getRiwayatSiklus(_item.id);
      if (!mounted) return;
      setState(() {
        if (resBerjalan.success) {
          _siklusBerjalan = resBerjalan.data;
        }
        if (resRiwayat.success && resRiwayat.data != null) {
          _riwayatSiklus = resRiwayat.data!
              .where((s) => s.isTerminal || (s.idSiklus != _siklusBerjalan?.idSiklus && !s.isBerjalan))
              .toList();
        }
        _isLoadingSiklus = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingSiklus = false);
    }
  }

  Future<void> _handleMulaiPersiapan() async {
    if (_isActionInProgress) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Mulai Persiapan Lahan?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text(
          'Status lahan akan diubah menjadi "Persiapan" untuk pengolahan tanah dan persiapan penanaman.',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: WarnaAplikasi.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Mulai Persiapan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed || !mounted) return;

    setState(() => _isActionInProgress = true);
    try {
      final res = await LahanApiService().mulaiPersiapan(_item.id);
      if (!mounted) return;
      if (res.success && res.data != null) {
        setState(() {
          _item = res.data!;
          _siklusBerjalan = _item.siklusBerjalan;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status lahan berhasil diubah menjadi persiapan.')),
        );
        _fetchFreshDetail();
        _fetchSiklusData(showLoading: false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message.isNotEmpty ? res.message : 'Gagal memulai persiapan lahan.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionInProgress = false);
    }
  }

  Future<void> _handleBatalkanPersiapan() async {
    if (_isActionInProgress) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Batalkan Persiapan?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text(
          'Status operasional lahan akan dikembalikan ke "Istirahat".',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Kembali', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: WarnaAplikasi.warningOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed || !mounted) return;

    setState(() => _isActionInProgress = true);
    try {
      final res = await LahanApiService().batalkanPersiapan(_item.id);
      if (!mounted) return;
      if (res.success && res.data != null) {
        setState(() {
          _item = res.data!;
          _siklusBerjalan = _item.siklusBerjalan;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Persiapan lahan dibatalkan. Status lahan kembali istirahat.')),
        );
        _fetchFreshDetail();
        _fetchSiklusData(showLoading: false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message.isNotEmpty ? res.message : 'Gagal membatalkan persiapan.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionInProgress = false);
    }
  }

  Future<void> _showMulaiSiklusModal() async {
    if (!_item.isTerverifikasi) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.info_outline, color: WarnaAplikasi.warningOrange),
              SizedBox(width: 8),
              Expanded(
                child: Text('Lahan Belum Terverifikasi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          content: const Text(
            'Lahan belum dapat digunakan untuk memulai Siklus Tanam karena belum disetujui / terverifikasi oleh Pengurus Kelompok Tani.',
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: WarnaAplikasi.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Mengerti', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      return;
    }

    // Ambil master komoditas
    List<ItemKomoditas> komoditasList = [];
    try {
      final resKom = await LahanApiService().getKomoditasList();
      if (resKom.success && resKom.data != null) {
        komoditasList = resKom.data!;
      }
    } catch (_) {}

    if (!mounted) return;

    // Buka BottomSheet Form
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FormMulaiSiklusSheet(
        lahan: _item,
        komoditasList: komoditasList,
        onSuccess: (newSiklus) {
          _fetchFreshDetail();
          _fetchSiklusData();
        },
      ),
    );
  }

  Future<void> _confirmDelete() async {
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
            content: Text('Yakin ingin menghapus lahan "${_item.nama}"? Data yang dihapus tidak bisa dikembalikan.', style: const TextStyle(fontSize: 13)),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ) ??
        false;

    if (mounted && confirmed) {
      try {
        final res = await LahanApiService().deleteLahan(_item.id);
        if (mounted) {
          if (res.success) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data lahan berhasil dihapus.')));
            Navigator.pop(context, 'delete');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message.isNotEmpty ? res.message : 'Gagal menghapus lahan.')));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
        }
      }
    }
  }

  Future<void> _navigateToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditLandScreen(item: _item)),
    );
    if (!mounted) return;
    if (result == 'delete') {
      Navigator.pop(context, 'delete');
    } else if (result is ItemLahan) {
      setState(() {
        _item = result;
      });
      _fetchFreshDetail();
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _fetchFreshDetail(),
      _fetchLahanActivities(),
      _fetchSpptDocuments(showLoading: false),
      _fetchSiklusData(showLoading: false),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final isAktif = _item.status == StatusLahan.aktif;
    final tagText = isAktif ? 'Aktif Ditanami' : (_item.status == StatusLahan.persiapan ? 'Dalam Proses' : 'Masa Olah Tanah');
    final tagColor = isAktif ? WarnaAplikasi.greenPill : WarnaAplikasi.warningOrangeBg;
    final tagTextColor = isAktif ? WarnaAplikasi.greenText : WarnaAplikasi.warningOrange;
    final dotColor = isAktif ? WarnaAplikasi.successGreen : WarnaAplikasi.hppAmberBg;

    return Scaffold(
      backgroundColor: WarnaAplikasi.getBackgroundColor(context),
      appBar: const PawonFormHeader(
        title: 'Detail Lahan',
        subtitle: 'Informasi lengkap petak garapan',
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
            final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.border;
            final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.primaryDark;
            final subtitleColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGrayLight;
            final dividerColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.backgroundLight;

            return RefreshIndicator(
              onRefresh: _refreshAll,
              color: WarnaAplikasi.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // Image Header Card
                Container(
                  height: 220,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: WarnaAplikasi.greenLight,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        (_item.fotoLahan != null && _item.fotoLahan!.isNotEmpty)
                            ? _item.fotoLahan!
                            : 'https://images.unsplash.com/photo-1595246140625-573b715d11dc?w=600&q=80',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.network(
                          'https://images.unsplash.com/photo-1595246140625-573b715d11dc?w=600&q=80',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: tagColor, borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text(tagText, style: TextStyle(color: tagTextColor, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('PETAK SAWAH', style: TextStyle(color: WarnaAplikasi.accentGreen, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            const SizedBox(height: 4),
                            Text(_item.nama, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.arrow_downward, color: WarnaAplikasi.accentGreen, size: 14),
                                const SizedBox(width: 4),
                                Text('${_item.luas.toStringAsFixed(1).replaceAll('.', ',')} Ha', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                const SizedBox(width: 16),
                                const Icon(Icons.eco, color: WarnaAplikasi.accentGreen, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  _siklusBerjalan != null
                                      ? _siklusBerjalan!.komoditasNama
                                      : (_item.status == StatusLahan.istirahat
                                          ? 'Masa Istirahat'
                                          : (_item.status == StatusLahan.persiapan ? 'Dalam Persiapan' : 'Belum Ada Siklus')),
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Kartu Status Verifikasi Pengurus/Ketua
                _buildVerificationStatusCard(),

                // Kartu Operasional & Siklus Tanam Berjalan (Phase 2)
                _buildOperasionalDanSiklusCard(),
                const SizedBox(height: 20),

                // Info Grid Fisik Lahan (Single Source of Truth: Data Operasional di Siklus Tanam)
                Row(
                  children: [
                    Expanded(child: _buildInfoGridCard(Icons.crop_square, 'Luas Lahan', '${_item.luas.toStringAsFixed(1).replaceAll('.', ',')} Ha')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoGridCard(
                        Icons.verified_user_outlined,
                        'Penguasaan',
                        _item.statusPenguasaan.isNotEmpty ? _item.statusPenguasaan : 'Milik Sendiri',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoGridCard(
                        Icons.layers_outlined,
                        'Status Petak',
                        _item.status == StatusLahan.aktif
                            ? 'Aktif Ditanami'
                            : (_item.status == StatusLahan.persiapan ? 'Persiapan' : 'Istirahat'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoGridCard(
                        Icons.description_outlined,
                        'Dokumen SPPT',
                        _isLoadingSpptDocuments ? '...' : '${_spptDocuments.length} Berkas',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Spesifikasi Petak
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Spesifikasi Petak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: titleColor)),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined, color: WarnaAplikasi.textGrayLight, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Lokasi', style: TextStyle(fontSize: 11, color: subtitleColor)),
                                const SizedBox(height: 4),
                                Text(_item.lokasi, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: titleColor, height: 1.4)),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 40, color: dividerColor, margin: const EdgeInsets.symmetric(horizontal: 16)),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Luas', style: TextStyle(fontSize: 11, color: subtitleColor)),
                                const SizedBox(height: 4),
                                Text('${_item.luas.toStringAsFixed(1).replaceAll('.', ',')} Ha', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: titleColor)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: dividerColor, thickness: 1),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.water_drop_outlined, color: WarnaAplikasi.errorRedBright, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sumber Irigasi', style: TextStyle(fontSize: 11, color: subtitleColor)),
                                const SizedBox(height: 4),
                                Text('-', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: titleColor)),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 40, color: dividerColor, margin: const EdgeInsets.symmetric(horizontal: 16)),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Tanggal Tanam', style: TextStyle(fontSize: 11, color: subtitleColor)),
                                const SizedBox(height: 4),
                                Text('-', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: titleColor)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_item.keterangan != null && _item.keterangan!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.notes_rounded, color: WarnaAplikasi.primary, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Keterangan / Catatan Lahan',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: titleColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _item.keterangan!,
                          style: TextStyle(fontSize: 12, color: subtitleColor, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Peta Lokasi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Peta Lokasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: WarnaAplikasi.primaryDark)),
                    Text(
                      'Lat: ${(_item.latitude ?? -6.5621).toStringAsFixed(6)}, Long: ${(_item.longitude ?? 107.7589).toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayLight),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: WarnaAplikasi.border),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(_item.latitude ?? -6.5621, _item.longitude ?? 107.7589),
                            initialZoom: 15,
                            interactionOptions: InteractionOptions(
                              flags: _isMapInteractive ? (InteractiveFlag.all & ~InteractiveFlag.rotate) : InteractiveFlag.none,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'id.pawontani.mobile',
                              tileProvider: NetworkTileProvider(),
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  width: 40,
                                  height: 40,
                                  point: LatLng(_item.latitude ?? -6.5621, _item.longitude ?? 107.7589),
                                  child: const Icon(Icons.location_on, color: WarnaAplikasi.primary, size: 40),
                                ),
                              ],
                            ),
                          ],
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
                const SizedBox(height: 24),

                // Riwayat Siklus Tanam (Phase 2)
                _buildRiwayatSiklusSection(),
                const SizedBox(height: 24),

                // Dokumen SPPT yang melekat pada lahan ini.
                _buildSpptDocumentsSection(),
                const SizedBox(height: 24),

                // Dokumentasi Petak (Galeri Perkembangan & Aktivitas)
                _buildGaleriDokumentasiSection(),
                const SizedBox(height: 24),

                // Riwayat Terkini / Aktivitas
                _buildRiwayatAktivitasSection(),

                // Riwayat Verifikasi (Audit Trail Backend)
                _buildRiwayatVerifikasiList(),

                const SizedBox(height: 32),

                // Buttons
                if (_siklusBerjalan != null && _siklusBerjalan!.isAktif) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _navigateToCatatAktivitas,
                          icon: const Icon(Icons.add, color: Colors.white, size: 18),
                          label: const Text('Catat Aktivitas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WarnaAplikasi.buttonDark,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _navigateToCatatPanen,
                          icon: const Icon(Icons.agriculture_rounded, color: Colors.white, size: 18),
                          label: const Text('Catat Panen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
                ] else if (_siklusBerjalan != null && _siklusBerjalan!.isMenungguVerifikasi) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF59E0B)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_clock_rounded, color: Color(0xFFD97706), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Input Aktivitas & Panen Terkunci',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF92400E)),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Siklus sedang menunggu verifikasi pengakhiran oleh Pengurus. Penambahan data dikunci sementara.',
                                style: TextStyle(fontSize: 11, color: Color(0xFFB45309)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _navigateToCatatAktivitas,
                      icon: const Icon(Icons.add, color: Colors.white, size: 18),
                      label: const Text('Catat Aktivitas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WarnaAplikasi.buttonDark,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _navigateToEdit,
                    icon: Icon(Icons.edit_outlined, color: titleColor, size: 18),
                    label: Text('Edit Informasi Lahan', style: TextStyle(color: titleColor, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF1D2420) : WarnaAplikasi.backgroundLight,
                      side: BorderSide(color: borderColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                ),
                if (_item.isCanDelete) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _confirmDelete,
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                      label: const Text('Hapus Lahan', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: WarnaAplikasi.errorRedBg,
                        side: const BorderSide(color: WarnaAplikasi.errorRedBorder),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    ),
  ),
);
  }

  /// Dialog popup untuk melihat foto ukuran besar
  void _showImagePreviewDialog(String imageUrl, String title, String subtitle) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    color: Colors.black,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.black,
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.white70, size: 40),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      if (subtitle.isNotEmpty)
                        Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bagian Dokumentasi Petak: Galeri Foto Aktivitas & Foto Profil Lahan
  Widget _buildGaleriDokumentasiSection() {
    // Kumpulkan seluruh foto aktivitas yang memiliki foto
    final List<Map<String, dynamic>> fotoList = [];

    // 1. Kumpulan foto lahan (multi-photo) atau foto profil utama lahan
    if (_item.photos.isNotEmpty) {
      for (int i = 0; i < _item.photos.length; i++) {
        fotoList.add({
          'url': _item.photos[i],
          'title': i == 0 ? 'Profil Petak' : 'Dokumentasi Petak #${i + 1}',
          'subtitle': i == 0 ? 'Foto Utama Lahan' : 'Foto Petak Lahan',
          'isMain': i == 0,
        });
      }
    } else if (_item.fotoLahan != null && _item.fotoLahan!.isNotEmpty) {
      fotoList.add({
        'url': _item.fotoLahan!,
        'title': 'Profil Petak',
        'subtitle': 'Foto Utama Lahan',
        'isMain': true,
      });
    }

    // 2. Kumpulan foto dari setiap aktivitas tanam (multi-photo & single)
    for (final akt in _activities) {
      if (akt.photos.isNotEmpty) {
        for (final p in akt.photos) {
          fotoList.add({
            'url': p,
            'title': akt.title,
            'subtitle': akt.date,
            'isMain': false,
            'item': akt,
          });
        }
      } else if (akt.imageUrl != null && akt.imageUrl!.isNotEmpty) {
        fotoList.add({
          'url': akt.imageUrl!,
          'title': akt.title,
          'subtitle': akt.date,
          'isMain': false,
          'item': akt,
        });
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Dokumentasi Petak',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: WarnaAplikasi.primaryDark),
                ),
                if (fotoList.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: WarnaAplikasi.greenLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${fotoList.length} Foto',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: WarnaAplikasi.primary),
                    ),
                  ),
                ],
              ],
            ),
            InkWell(
              onTap: _navigateToCatatAktivitas,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  '+ Tambah Foto',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WarnaAplikasi.primary),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (fotoList.isEmpty)
          InkWell(
            onTap: _navigateToCatatAktivitas,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: WarnaAplikasi.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: WarnaAplikasi.greenLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_a_photo_outlined, color: WarnaAplikasi.primary, size: 22),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Belum Ada Foto Dokumentasi',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ambil foto saat mencatat pemupukan, pengairan, atau kegiatan rawat petak.',
                    style: TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayLight),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _navigateToCatatAktivitas,
                    icon: const Icon(Icons.camera_alt_outlined, size: 14),
                    label: const Text('Ambil Foto Kegiatan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WarnaAplikasi.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 155,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: fotoList.length + 1, // +1 untuk kartu tambah cepat
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                // Kartu terakhir: tombol tambah cepat
                if (index == fotoList.length) {
                  return InkWell(
                    onTap: _navigateToCatatAktivitas,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 110,
                      decoration: BoxDecoration(
                        color: WarnaAplikasi.greenLight.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: WarnaAplikasi.borderField, style: BorderStyle.solid),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_circle_outline, color: WarnaAplikasi.primary, size: 26),
                          SizedBox(height: 6),
                          Text(
                            'Tambah\nFoto',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final foto = fotoList[index];
                final url = foto['url'] as String;
                final title = foto['title'] as String;
                final subtitle = foto['subtitle'] as String;
                final isMain = foto['isMain'] == true;

                return InkWell(
                  onTap: () => _showImagePreviewDialog(url, title, subtitle),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 140,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: WarnaAplikasi.border),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          url,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: WarnaAplikasi.primary),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: WarnaAplikasi.greenLight,
                            child: const Center(
                              child: Icon(Icons.broken_image, color: Colors.grey, size: 24),
                            ),
                          ),
                        ),
                        // Gradient Overlay & Info Bar
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.85),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  subtitle,
                                  style: const TextStyle(color: Colors.white70, fontSize: 9.5),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Badge jika foto profil lahan
                        if (isMain)
                          Positioned(
                            top: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: WarnaAplikasi.buttonDark,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('Foto Utama', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildRiwayatAktivitasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Riwayat Aktivitas',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: WarnaAplikasi.primaryDark),
            ),
            if (_activities.isNotEmpty)
              Text(
                '${_activities.length} Kegiatan',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WarnaAplikasi.primary),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoadingActivities)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: WarnaAplikasi.border),
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: WarnaAplikasi.primary),
              ),
            ),
          )
        else if (_activities.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: WarnaAplikasi.border),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_toggle_off_rounded, color: WarnaAplikasi.textGrayLight, size: 36),
                SizedBox(height: 8),
                Text(
                  'Belum Ada Riwayat Aktivitas',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark),
                ),
                SizedBox(height: 4),
                Text(
                  'Riwayat pemupukan, penyemprotan, dan perawatan petak ini akan tercatat di sini setelah Anda mencatat aktivitas.',
                  style: TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayLight),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Column(
            children: _activities.take(5).map((akt) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
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
                        color: WarnaAplikasi.greenLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.spa_rounded, color: WarnaAplikasi.primary, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                akt.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: WarnaAplikasi.primaryDark),
                              ),
                              Row(
                                children: [
                                  if (akt.isLegacy) ...[
                                    Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: WarnaAplikasi.bgGray,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Legacy',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                          color: WarnaAplikasi.textGrayDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: akt.condition == PlantCondition.sehat ? WarnaAplikasi.bgSuccessLight : WarnaAplikasi.statusTempoBg,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      akt.condition.badgeText,
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: akt.condition == PlantCondition.sehat ? WarnaAplikasi.primary : WarnaAplikasi.warningOrange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${akt.date} ${akt.time.isNotEmpty ? "• ${akt.time}" : ""}',
                            style: const TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayLight),
                          ),
                          if (akt.notes.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              akt.notes,
                              style: const TextStyle(fontSize: 11.5, color: WarnaAplikasi.textGrayDark),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildRiwayatVerifikasiList() {
    if (_item.riwayatVerifikasi.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Row(
          children: [
            Icon(Icons.history_edu_rounded, size: 18, color: WarnaAplikasi.primaryDark),
            SizedBox(width: 8),
            Text(
              'Riwayat Verifikasi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: WarnaAplikasi.primaryDark),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: WarnaAplikasi.border),
          ),
          child: Column(
            children: List.generate(_item.riwayatVerifikasi.length, (index) {
              final riwayat = _item.riwayatVerifikasi[index];
              final isLast = index == _item.riwayatVerifikasi.length - 1;

              String tanggalStr = '-';
              if (riwayat.createdAt != null) {
                final dt = riwayat.createdAt!.toLocal();
                tanggalStr = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
              }

              IconData aksiIcon = Icons.info_outline;
              Color iconColor = WarnaAplikasi.textGray;
              String statusLabel = riwayat.aksi.replaceAll('_', ' ').toUpperCase();

              if (riwayat.statusSesudahnya == 'terverifikasi') {
                aksiIcon = Icons.check_circle_outline;
                iconColor = WarnaAplikasi.primary;
              } else if (riwayat.statusSesudahnya == 'perlu_perbaikan') {
                aksiIcon = Icons.warning_amber_rounded;
                iconColor = WarnaAplikasi.warningOrange;
              } else if (riwayat.statusSesudahnya == 'menunggu_verifikasi') {
                aksiIcon = Icons.hourglass_top_rounded;
                iconColor = const Color(0xFF1D4ED8);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(aksiIcon, size: 16, color: iconColor),
                          const SizedBox(width: 6),
                          Text(
                            statusLabel,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: iconColor),
                          ),
                          if (riwayat.nomorRevisi > 0)
                            Text(
                              ' (Rev #${riwayat.nomorRevisi})',
                              style: const TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayLight),
                            ),
                        ],
                      ),
                      Text(
                        tanggalStr,
                        style: const TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayLight),
                      ),
                    ],
                  ),
                  if (riwayat.namaAktor != null && riwayat.namaAktor!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Oleh: ${riwayat.namaAktor}${riwayat.jabatanAktor != null && riwayat.jabatanAktor!.isNotEmpty ? ' (${riwayat.jabatanAktor})' : ''}',
                      style: const TextStyle(fontSize: 11, color: WarnaAplikasi.textGray),
                    ),
                  ],
                  if (riwayat.catatan != null && riwayat.catatan!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: WarnaAplikasi.backgroundLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Catatan: "${riwayat.catatan}"',
                        style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: WarnaAplikasi.primaryDark),
                      ),
                    ),
                  ],
                  if (!isLast)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: WarnaAplikasi.backgroundLight, thickness: 1),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGridCard(IconData icon, String title, String value) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
        final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.border;
        final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.primaryDark;
        final subtitleColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGrayLight;
        final iconBoxBg = isDark ? const Color(0xFF283A2E) : WarnaAplikasi.bgInput;
        final iconColor = isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconBoxBg, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 10, color: subtitleColor)),
                    const SizedBox(height: 2),
                    Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: titleColor)),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildVerificationStatusCard() {
    return Builder(
      builder: (context) {
        final status = _item.statusVerifikasi;
        if (status == null || status.isEmpty) {
          return const SizedBox.shrink();
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;

        Color bgColor;
        Color borderColor;
        Color textColor;
        IconData icon;
        String title;
        String subtitle;

        switch (status) {
          case 'terverifikasi':
            bgColor = isDark ? const Color(0xFF1B2E22) : WarnaAplikasi.greenLight;
            borderColor = isDark ? const Color(0xFF285438) : WarnaAplikasi.greenPill;
            textColor = isDark ? const Color(0xFF86EFAC) : WarnaAplikasi.greenText;
            icon = Icons.verified_rounded;
            title = 'Lahan Terverifikasi';
            subtitle = 'Data petak lahan telah disetujui oleh Pengurus/Ketua Kelompok Tani.';
            break;
          case 'perlu_perbaikan':
            bgColor = isDark ? const Color(0xFF382314) : WarnaAplikasi.warningOrangeBg;
            borderColor = isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A);
            textColor = isDark ? const Color(0xFFFDBA74) : WarnaAplikasi.warningOrange;
            icon = Icons.error_outline_rounded;
            title = 'Perlu Perbaikan';
            subtitle = _item.catatanVerifikasi != null && _item.catatanVerifikasi!.isNotEmpty
                ? 'Catatan Pengurus: "${_item.catatanVerifikasi}"'
                : 'Ketua meminta perbaikan data lahan sebelum dapat diverifikasi.';
            break;
          case 'menunggu_verifikasi':
          default:
            bgColor = isDark ? const Color(0xFF17253D) : const Color(0xFFEFF6FF);
            borderColor = isDark ? const Color(0xFF1E3A8A) : const Color(0xFFBFDBFE);
            textColor = isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8);
            icon = Icons.hourglass_top_rounded;
            title = 'Menunggu Verifikasi';
            subtitle = 'Data petak dalam antrean verifikasi oleh Pengurus/Ketua Kelompok Tani.';
            break;
        }

        final displayTitle = _item.nomorRevisi > 0 ? '$title (Revisi #${_item.nomorRevisi})' : title;

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: textColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor.withValues(alpha: 0.9),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // WIDGET OPERASIONAL & SIKLUS TANAM (PHASE 2)
  // ==========================================

  Widget _buildOperasionalDanSiklusCard() {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
        final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.border;
        final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.primaryDark;
        final subtitleColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGrayLight;
        final iconBoxBg = isDark ? const Color(0xFF283A2E) : WarnaAplikasi.bgInput;

        final statusOp = _item.status;

        if (statusOp == StatusLahan.istirahat) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: iconBoxBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.bedtime_outlined, color: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status Petak: Istirahat (Bera)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: titleColor),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Petak sedang dalam masa jeda tanam. Silakan mulai persiapan lahan untuk mengolah tanah.',
                            style: TextStyle(fontSize: 11, color: subtitleColor, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isActionInProgress ? null : _handleMulaiPersiapan,
                    icon: _isActionInProgress
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.handyman_outlined, size: 16),
                    label: const Text('Mulai Persiapan Lahan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WarnaAplikasi.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (statusOp == StatusLahan.persiapan) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF382314) : const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.construction_rounded, color: WarnaAplikasi.warningOrange, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status Petak: Dalam Persiapan',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: titleColor),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Petak sedang dalam proses pengolahan tanah dan persiapan penanaman.',
                            style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFFFDBA74) : const Color(0xFF92400E), height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (!_item.isTerverifikasi) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1D2420) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isDark ? const Color(0xFF78350F) : const Color(0xFFFCD34D)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: WarnaAplikasi.warningOrange, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Perhatian: Lahan belum disetujui / terverifikasi oleh Pengurus. Siklus tanam dapat dimulai setelah lahan terverifikasi.',
                            style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFFFDBA74) : const Color(0xFF78350F), height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isActionInProgress ? null : _handleBatalkanPersiapan,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: WarnaAplikasi.warningOrange,
                          side: const BorderSide(color: WarnaAplikasi.warningOrange),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Batalkan'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _isActionInProgress ? null : _showMulaiSiklusModal,
                        icon: const Icon(Icons.play_arrow_rounded, size: 18),
                        label: const Text('Mulai Siklus Tanam'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WarnaAplikasi.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        // Status Lahan Aktif: Kartu Siklus Tanam Berjalan
        final siklus = _siklusBerjalan;

        // Jika lahan berstatus aktif tetapi belum ada siklus berjalan, tampilkan kartu state jujur
        if (siklus == null) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF141916) : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.info_outline_rounded, color: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Belum Ada Siklus Aktif',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: titleColor),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Petak lahan ini belum memiliki siklus tanam aktif yang berjalan. Silakan mulai siklus tanam baru.',
                            style: TextStyle(fontSize: 11, color: subtitleColor, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (_isActionInProgress || !_item.isTerverifikasi) ? null : _showMulaiSiklusModal,
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: const Text('Mulai Siklus Tanam'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WarnaAplikasi.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Jika siklus aktif tersedia, seluruh informasi operasional murni bersumber dari siklus (Single Source of Truth)
        final komoditasNama = siklus.komoditasNama;
        final varietas = (siklus.varietas != null && siklus.varietas!.isNotEmpty) ? '(${siklus.varietas})' : '';
        final musim = siklus.musimTanam;

        String formatDate(DateTime? date) {
          if (date == null) return '-';
          return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
        }

        final isMenunggu = siklus.isMenungguVerifikasi;
        final currentUser = AuthRepository.instance.currentUser;
        final isKetuaOrPengurus = currentUser != null && !currentUser.isAnggota;
        final isOwnerAnggota = _item.isCanEdit && (currentUser == null || currentUser.isAnggota);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isMenunggu
                ? (isDark ? const Color(0xFF382314) : const Color(0xFFFFFBEB))
                : (isDark ? const Color(0xFF1B2E22) : WarnaAplikasi.greenLight.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isMenunggu
                  ? (isDark ? const Color(0xFF78350F) : const Color(0xFFFBBF24))
                  : (isDark ? const Color(0xFF285438) : WarnaAplikasi.greenPill),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isMenunggu ? const Color(0xFFD97706) : WarnaAplikasi.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isMenunggu ? Icons.hourglass_top_rounded : Icons.eco_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isMenunggu ? 'Siklus Tanam (Menunggu Persetujuan)' : 'Siklus Tanam Berjalan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isMenunggu ? const Color(0xFF92400E) : WarnaAplikasi.primaryDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isMenunggu ? const Color(0xFFFEF3C7) : WarnaAplikasi.greenPill,
                  borderRadius: BorderRadius.circular(12),
                  border: isMenunggu ? Border.all(color: const Color(0xFFF59E0B)) : null,
                ),
                child: Text(
                  isMenunggu
                      ? (siklus.jenisPengakhiran == 'gagal' ? 'MENUNGGU GAGAL' : 'MENUNGGU SELESAI')
                      : siklus.status.toUpperCase(),
                  style: TextStyle(
                    color: isMenunggu ? const Color(0xFFB45309) : WarnaAplikasi.greenText,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$komoditasNama $varietas',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark),
          ),
          const SizedBox(height: 4),
          Text(
            'Musim Tanam: $musim',
            style: const TextStyle(fontSize: 12, color: WarnaAplikasi.textGray),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: WarnaAplikasi.borderField, thickness: 1),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Mulai Tanam', style: TextStyle(fontSize: 10, color: WarnaAplikasi.textGrayLight)),
                    const SizedBox(height: 2),
                    Text(
                      formatDate(siklus.tanggalMulai),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estimasi Panen', style: TextStyle(fontSize: 10, color: WarnaAplikasi.textGrayLight)),
                    const SizedBox(height: 2),
                    Text(
                      formatDate(siklus.estimasiPanen),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Target Hasil', style: TextStyle(fontSize: 10, color: WarnaAplikasi.textGrayLight)),
                    const SizedBox(height: 2),
                    Text(
                      siklus.targetPanenTon != null ? '${siklus.targetPanenTon} Ton' : '-',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Realisasi Hasil Panen & Progress Bar
          if (siklus.targetPanenTon != null || (siklus.totalPanenKg != null && siklus.totalPanenKg! > 0)) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: WarnaAplikasi.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Realisasi Hasil Panen',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark),
                      ),
                      Text(
                        '${siklus.totalPanenTon ?? 0.0} Ton (${(siklus.totalPanenKg ?? 0).toInt()} Kg)',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: WarnaAplikasi.primary),
                      ),
                    ],
                  ),
                  if (siklus.targetPanenTon != null && siklus.targetPanenTon! > 0) ...[
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ((siklus.totalPanenTon ?? 0.0) / siklus.targetPanenTon!).clamp(0.0, 1.0),
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(WarnaAplikasi.primary),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Target: ${siklus.targetPanenTon} Ton',
                          style: const TextStyle(fontSize: 10, color: WarnaAplikasi.textGray),
                        ),
                        Text(
                          '${siklus.persentaseTarget?.toStringAsFixed(1) ?? '0'}% tercapai',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Banner Pengajuan Pengakhiran yang Sedang Pending
          if (isMenunggu) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pengajuan ${siklus.jenisPengakhiran == 'gagal' ? 'Gagal Panen' : 'Panen Selesai'}:',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    siklus.alasanPengakhiran ?? '-',
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF78350F)),
                  ),
                  if (siklus.fotoBuktiGagal != null && siklus.fotoBuktiGagal!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    FutureBuilder<String?>(
                      future: SecureStorageService.instance.getToken(),
                      builder: (context, tokenSnap) {
                        final token = tokenSnap.data;
                        final targetUrl = siklus.fotoBuktiGagalUrl ?? '${ApiConstants.baseUrl}/siklus-tanam/${siklus.idSiklus}/bukti-gagal';
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            targetUrl,
                            headers: token != null ? {'Authorization': 'Bearer $token'} : null,
                            height: 70,
                            width: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Text('Bukti terlampir', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
            if (isKetuaOrPengurus) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showDialogVerifikasi(siklus),
                  icon: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 16),
                  label: const Text('Verifikasi Pengakhiran Siklus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WarnaAplikasi.primary,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
            ],
          ],

          // Tombol Aksi Pengakhiran jika Siklus Aktif dan milik Anggota pemilik
          if (siklus.isAktif && isOwnerAnggota) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showOpsiPengakhiranSheet(siklus),
                icon: const Icon(Icons.pending_actions_rounded, size: 16, color: WarnaAplikasi.primaryDark),
                label: const Text(
                  'Opsi Pengakhiran Siklus',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: WarnaAplikasi.primary),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
      },
    );
  }

  // ==========================================
  // WIDGET RIWAYAT SIKLUS TANAM (PHASE 2 & 5)
  // ==========================================

  Widget _buildRiwayatSiklusSection() {
    String formatDate(DateTime? date) {
      if (date == null) return '-';
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Riwayat Siklus Tanam',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: WarnaAplikasi.primaryDark),
                ),
                if (_riwayatSiklus.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: WarnaAplikasi.greenLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_riwayatSiklus.length} Siklus',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: WarnaAplikasi.primary),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoadingSiklus)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: WarnaAplikasi.primary),
            ),
          )
        else if (_riwayatSiklus.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: WarnaAplikasi.border),
            ),
            child: Column(
              children: const [
                Icon(Icons.history_edu_rounded, color: WarnaAplikasi.textGrayLight, size: 36),
                SizedBox(height: 8),
                Text(
                  'Belum Ada Riwayat Siklus Tanam',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark),
                ),
                SizedBox(height: 4),
                Text(
                  'Riwayat siklus tanam sebelumnya akan tercatat secara otomatis di sini.',
                  style: TextStyle(fontSize: 11, color: WarnaAplikasi.textGrayLight),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Column(
            children: _riwayatSiklus.map((siklus) {
              Color statusBg = WarnaAplikasi.greenPill;
              Color statusText = WarnaAplikasi.greenText;

              if (siklus.status == 'gagal' || siklus.status == 'dibatalkan') {
                statusBg = const Color(0xFFFEE2E2);
                statusText = const Color(0xFFB91C1C);
              } else if (siklus.status == 'selesai') {
                statusBg = const Color(0xFFEFF6FF);
                statusText = const Color(0xFF1D4ED8);
              }

              return InkWell(
                onTap: () => _showDetailRiwayatSiklusSheet(siklus),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: WarnaAplikasi.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: WarnaAplikasi.bgInput,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.grass_rounded, color: WarnaAplikasi.primary, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  siklus.komoditasNama,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: statusBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    siklus.statusLabel.toUpperCase(),
                                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: statusText),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Musim: ${siklus.musimTanam} ${siklus.varietas != null && siklus.varietas!.isNotEmpty ? '· ${siklus.varietas}' : ''}',
                              style: const TextStyle(fontSize: 11, color: WarnaAplikasi.textGray),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Mulai: ${formatDate(siklus.tanggalMulai)} ${siklus.tanggalSelesai != null ? '· Selesai: ${formatDate(siklus.tanggalSelesai)}' : ''}',
                                  style: const TextStyle(fontSize: 10.5, color: WarnaAplikasi.textGrayLight),
                                ),
                                if (siklus.totalPanenTon != null && siklus.totalPanenTon! > 0)
                                  Text(
                                    '${siklus.totalPanenTon} Ton',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: WarnaAplikasi.primary),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // ==========================================
  // PENGAKHIRAN SIKLUS TANAM (PHASE 5)
  // ==========================================

  void _showOpsiPengakhiranSheet(ItemSiklusTanam siklus) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Text(
                    'Opsi Pengakhiran Siklus',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Pilih jenis pengakhiran siklus tanam sesuai kondisi di lapangan:',
                    style: TextStyle(fontSize: 12, color: WarnaAplikasi.textGray),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
                    ),
                    title: const Text('Akhiri Siklus Panen (Selesai)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    subtitle: const Text('Diajukan jika seluruh panen telah disetujui Pengurus', style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      Navigator.pop(ctx);
                      _checkAndShowPengakhiranSelesai(siklus);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 24),
                    ),
                    title: const Text('Laporkan Kegagalan Panen (Gagal)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    subtitle: const Text('Tanaman puso/rusak (wajib unggah foto bukti)', style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      Navigator.pop(ctx);
                      _showDialogPengakhiranGagal(siklus);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.cancel_outlined, color: Colors.red, size: 24),
                    ),
                    title: const Text('Batalkan Siklus Tanam', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.red)),
                    subtitle: const Text('Hanya jika belum ada aktivitas & panen yang dicatat', style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      Navigator.pop(ctx);
                      _showDialogPembatalan(siklus);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _checkAndShowPengakhiranSelesai(ItemSiklusTanam siklus) async {
    try {
      final resPanen = await PanenApiService().getPanenList(idSiklus: siklus.idSiklus);
      if (!mounted) return;

      if (resPanen.success) {
        final panenList = resPanen.data ?? [];

        // Validasi 1: Belum memiliki data panen sama sekali
        if (panenList.isEmpty) {
          _showFeedbackDialog(
            title: 'Siklus Belum Dapat Diakhiri',
            message: 'Siklus tanam belum memiliki data panen. Tambahkan data panen terlebih dahulu sebelum mengajukan pengakhiran siklus selesai.',
            icon: Icons.info_outline_rounded,
            iconColor: WarnaAplikasi.warningOrange,
          );
          return;
        }

        // Validasi 2: Masih terdapat catatan panen yang belum disetujui
        final unapproved = panenList.where((p) => p.status != HarvestStatus.disetujui).toList();
        if (unapproved.isNotEmpty) {
          _showFeedbackDialog(
            title: 'Siklus Belum Dapat Diakhiri',
            message: 'Pengakhiran siklus belum dapat diajukan karena masih terdapat hasil panen yang menunggu verifikasi atau belum disetujui Pengurus.',
            icon: Icons.pending_actions_rounded,
            iconColor: WarnaAplikasi.warningOrange,
          );
          return;
        }
      } else {
        if (siklus.totalPanenKg == null || siklus.totalPanenKg! <= 0) {
          _showFeedbackDialog(
            title: 'Siklus Belum Dapat Diakhiri',
            message: 'Siklus tanam belum memiliki data panen. Tambahkan data panen terlebih dahulu sebelum mengajukan pengakhiran siklus selesai.',
            icon: Icons.info_outline_rounded,
            iconColor: WarnaAplikasi.warningOrange,
          );
          return;
        }
      }
    } catch (_) {
      if (siklus.totalPanenKg == null || siklus.totalPanenKg! <= 0) {
        _showFeedbackDialog(
          title: 'Siklus Belum Dapat Diakhiri',
          message: 'Siklus tanam belum memiliki data panen. Tambahkan data panen terlebih dahulu sebelum mengajukan pengakhiran siklus selesai.',
          icon: Icons.info_outline_rounded,
          iconColor: WarnaAplikasi.warningOrange,
        );
        return;
      }
    }

    if (!mounted) return;
    _showDialogPengakhiranSelesai(siklus);
  }

  void _showFeedbackDialog({
    required String title,
    required String message,
    IconData icon = Icons.info_outline_rounded,
    Color iconColor = WarnaAplikasi.warningOrange,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Mengerti', style: TextStyle(color: WarnaAplikasi.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _showDialogPengakhiranSelesai(ItemSiklusTanam siklus) async {
    final formKey = GlobalKey<FormState>();
    final alasanController = TextEditingController(text: 'Seluruh petak telah dipanen dan timbangan telah disetujui.');
    PlatformFile? selectedFoto;
    bool isSubmitting = false;
    String? errorMessage;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        children: const [
                          Icon(Icons.task_alt_rounded, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Pengajuan Pengakhiran Selesai',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: WarnaAplikasi.greenLight.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: WarnaAplikasi.greenPill),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Komoditas: ${siklus.komoditasNama} (${siklus.musimTanam})',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: WarnaAplikasi.primaryDark),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Target: ${siklus.targetPanenTon != null ? "${siklus.targetPanenTon} Ton" : "-"} · Realisasi: ${siklus.totalPanenTon ?? 0.0} Ton (${(siklus.totalPanenKg ?? 0).toInt()} Kg)',
                              style: const TextStyle(fontSize: 11, color: WarnaAplikasi.textDarkGreen),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Catatan: Minimal 1 panen harus berstatus disetujui, dan tidak boleh ada panen yang masih menunggu verifikasi atau ditolak.',
                              style: TextStyle(fontSize: 10.5, color: WarnaAplikasi.textGray),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Alasan Pengakhiran Siklus *',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: WarnaAplikasi.primaryDark),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: alasanController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Contoh: Masa panen telah rampung dan lahan siap diistirahatkan...',
                          filled: true,
                          fillColor: WarnaAplikasi.bgInput,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Alasan pengakhiran wajib diisi';
                          if (val.trim().length < 5) return 'Alasan minimal 5 karakter';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Foto Bukti Panen (Opsional)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: WarnaAplikasi.primaryDark),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final res = await FilePicker.pickFiles(type: FileType.image);
                          if (res.isNotEmpty) {
                            setModalState(() => selectedFoto = res.first);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: WarnaAplikasi.bgInput,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.photo_camera_outlined, color: Colors.grey, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  selectedFoto != null ? selectedFoto!.name : 'Pilih Foto Bukti Panen...',
                                  style: TextStyle(fontSize: 12, color: selectedFoto != null ? Colors.black87 : Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (selectedFoto != null)
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18, color: Colors.red),
                                  onPressed: () => setModalState(() => selectedFoto = null),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade300),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Siklus Belum Dapat Diakhiri',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 12),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      errorMessage!,
                                      style: const TextStyle(color: Colors.red, fontSize: 11.5, height: 1.3),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  setModalState(() {
                                    isSubmitting = true;
                                    errorMessage = null;
                                  });
                                  try {
                                    MultipartFile? multipartFoto;
                                    if (selectedFoto != null) {
                                      final bytes = await selectedFoto!.readAsBytes();
                                      multipartFoto = MultipartFile.fromBytes(bytes, filename: selectedFoto!.name);
                                    }

                                    final res = await LahanApiService().ajukanPengakhiranSelesai(
                                      siklus.idSiklus,
                                      alasan: alasanController.text.trim(),
                                      fotoBukti: multipartFoto,
                                    );

                                    if (!context.mounted) return;
                                    if (res.success) {
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(res.message.isNotEmpty ? res.message : 'Pengajuan pengakhiran siklus berhasil dikirim.'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      _fetchFreshDetail();
                                      _fetchSiklusData();
                                    } else {
                                      String userFriendlyMsg = res.message;
                                      if (userFriendlyMsg.contains('minimal 1 catatan panen')) {
                                        userFriendlyMsg = 'Siklus tanam belum memiliki data panen. Tambahkan data panen terlebih dahulu sebelum mengajukan pengakhiran siklus selesai.';
                                      } else if (userFriendlyMsg.contains('belum disetujui') || userFriendlyMsg.contains('menunggu verifikasi')) {
                                        userFriendlyMsg = 'Pengakhiran siklus belum dapat diajukan karena masih terdapat hasil panen yang menunggu verifikasi atau belum disetujui Pengurus.';
                                      }

                                      setModalState(() {
                                        isSubmitting = false;
                                        errorMessage = userFriendlyMsg.isNotEmpty ? userFriendlyMsg : 'Gagal mengajukan pengakhiran.';
                                      });
                                    }
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    setModalState(() {
                                      isSubmitting = false;
                                      errorMessage = 'Terjadi kesalahan sistem: $e';
                                    });
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WarnaAplikasi.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: isSubmitting
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Kirim Pengajuan Selesai', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showDialogPengakhiranGagal(ItemSiklusTanam siklus) async {
    final formKey = GlobalKey<FormState>();
    final alasanController = TextEditingController();
    PlatformFile? selectedFoto;
    String? fotoError;
    bool isSubmitting = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            'Laporan Kegagalan Panen',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF59E0B)),
                        ),
                        child: const Text(
                          'Perhatian: Pengajuan gagal panen memerlukan verifikasi lapangan oleh Ketua/Pengurus. Anda WAJIB melampirkan foto bukti kondisi tanaman puso/rusak.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Alasan Kegagalan Panen *',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: WarnaAplikasi.primaryDark),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: alasanController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Jelaskan penyebab puso/kegagalan (banjir, wereng, kekeringan, dsb)...',
                          filled: true,
                          fillColor: WarnaAplikasi.bgInput,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Alasan kegagalan wajib diisi';
                          if (val.trim().length < 5) return 'Alasan minimal 5 karakter';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Foto Bukti Kegagalan (WAJIB) *',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: WarnaAplikasi.primaryDark),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final res = await FilePicker.pickFiles(type: FileType.image);
                          if (res.isNotEmpty) {
                            setModalState(() {
                              selectedFoto = res.first;
                              fotoError = null;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: WarnaAplikasi.bgInput,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: fotoError != null ? Colors.red : Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.camera_alt_outlined, color: Colors.orange, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  selectedFoto != null ? selectedFoto!.name : 'Pilih Foto Bukti Kegagalan...',
                                  style: TextStyle(fontSize: 12, color: selectedFoto != null ? Colors.black87 : Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (selectedFoto != null)
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18, color: Colors.red),
                                  onPressed: () => setModalState(() => selectedFoto = null),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (fotoError != null) ...[
                        const SizedBox(height: 4),
                        Text(fotoError!, style: const TextStyle(fontSize: 11, color: Colors.red)),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  if (selectedFoto == null) {
                                    setModalState(() => fotoError = 'Foto bukti kegagalan wajib dilampirkan');
                                    return;
                                  }
                                  setModalState(() => isSubmitting = true);
                                  try {
                                    final bytes = await selectedFoto!.readAsBytes();
                                    final multipartFoto = MultipartFile.fromBytes(bytes, filename: selectedFoto!.name);

                                    final res = await LahanApiService().ajukanPengakhiranGagal(
                                      siklus.idSiklus,
                                      alasan: alasanController.text.trim(),
                                      fotoBukti: multipartFoto,
                                    );

                                    if (!context.mounted) return;
                                    if (res.success) {
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(res.message.isNotEmpty ? res.message : 'Laporan kegagalan panen berhasil dikirim.'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      _fetchFreshDetail();
                                      _fetchSiklusData();
                                    } else {
                                      setModalState(() => isSubmitting = false);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(res.message.isNotEmpty ? res.message : 'Gagal mengirim laporan kegagalan.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    setModalState(() => isSubmitting = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: isSubmitting
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Kirim Laporan Gagal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showDialogPembatalan(ItemSiklusTanam siklus) async {
    final alasanController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: const [
                  Icon(Icons.cancel_outlined, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Batalkan Siklus Tanam', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: const Text(
                          'Peringatan: Pembatalan hanya dapat dilakukan jika belum ada aktivitas dan panen. Tindakan ini bersifat final dan lahan akan kembali ke status istirahat.',
                          style: TextStyle(fontSize: 11, color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('Alasan Pembatalan *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: alasanController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Misal: Salah input lahan / komoditas...',
                          filled: true,
                          fillColor: WarnaAplikasi.bgInput,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Alasan pembatalan wajib diisi';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(dialogCtx),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => isSubmitting = true);
                          try {
                            final res = await LahanApiService().batalkanSiklus(
                              siklus.idSiklus,
                              alasan: alasanController.text.trim(),
                            );
                            if (!context.mounted) return;
                            if (res.success) {
                              Navigator.pop(dialogCtx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(res.message.isNotEmpty ? res.message : 'Siklus tanam berhasil dibatalkan.'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              _fetchFreshDetail();
                              _fetchSiklusData();
                            } else {
                              setDialogState(() => isSubmitting = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(res.message.isNotEmpty ? res.message : 'Gagal membatalkan siklus.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            if (!context.mounted) return;
                            setDialogState(() => isSubmitting = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isSubmitting
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Ya, Batalkan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showDialogVerifikasi(ItemSiklusTanam siklus) async {
    final catatanController = TextEditingController();
    bool isSubmitting = false;
    String? catatanError;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isGagal = siklus.isMenungguGagal;
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          isGagal ? Icons.warning_amber_rounded : Icons.verified_user_rounded,
                          color: isGagal ? Colors.orange : WarnaAplikasi.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isGagal ? 'Verifikasi Pengakhiran Gagal' : 'Verifikasi Pengakhiran Selesai',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Lahan: ${_item.nama}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text('Komoditas: ${siklus.komoditasNama} (${siklus.musimTanam})', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            'Alasan Pengajuan:',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                          ),
                          Text(
                            siklus.alasanPengakhiran ?? '-',
                            style: const TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                          if (siklus.fotoBuktiGagal != null) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Foto Bukti Kegagalan:',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            FutureBuilder<String?>(
                              future: SecureStorageService.instance.getToken(),
                              builder: (context, tokenSnap) {
                                final token = tokenSnap.data;
                                final targetUrl = siklus.fotoBuktiGagalUrl ?? '${ApiConstants.baseUrl}/siklus-tanam/${siklus.idSiklus}/bukti-gagal';
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    targetUrl,
                                    headers: token != null ? {'Authorization': 'Bearer $token'} : null,
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      height: 60,
                                      color: Colors.grey.shade200,
                                      alignment: Alignment.center,
                                      child: const Text('Foto bukti tidak dapat dimuat', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Catatan Keputusan (Wajib jika tolak, opsional jika setuju):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: catatanController,
                      maxLines: 2,
                      onChanged: (val) {
                        if (catatanError != null && val.trim().isNotEmpty) {
                          setModalState(() => catatanError = null);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Tuliskan catatan verifikasi lapangan...',
                        filled: true,
                        fillColor: WarnaAplikasi.bgInput,
                        errorText: catatanError,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    final textCatatan = catatanController.text.trim();
                                    if (textCatatan.isEmpty) {
                                      setModalState(() {
                                        catatanError = 'Catatan alasan penolakan pengakhiran wajib diisi.';
                                      });
                                      return;
                                    }
                                    setModalState(() {
                                      catatanError = null;
                                      isSubmitting = true;
                                    });
                                    try {
                                      final res = await LahanApiService().verifikasiPengakhiranSiklus(
                                        siklus.idSiklus,
                                        keputusan: 'ditolak',
                                        catatan: textCatatan,
                                      );
                                      if (!context.mounted) return;
                                      if (res.success) {
                                        Navigator.pop(ctx);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Pengakhiran siklus telah ditolak. Siklus kembali aktif.')),
                                        );
                                        _fetchFreshDetail();
                                        _fetchSiklusData();
                                      } else {
                                        setModalState(() => isSubmitting = false);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(res.message.isNotEmpty ? res.message : 'Gagal menolak pengakhiran.')),
                                        );
                                      }
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      setModalState(() => isSubmitting = false);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Terjadi kesalahan: $e')),
                                      );
                                    }
                                  },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            child: const Text('Tolak', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    setModalState(() {
                                      catatanError = null;
                                      isSubmitting = true;
                                    });
                                    try {
                                      final res = await LahanApiService().verifikasiPengakhiranSiklus(
                                        siklus.idSiklus,
                                        keputusan: 'disetujui',
                                        catatan: catatanController.text.trim(),
                                      );
                                      if (!context.mounted) return;
                                      if (res.success) {
                                        Navigator.pop(ctx);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Pengakhiran siklus disetujui. Lahan beralih ke masa istirahat.'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        _fetchFreshDetail();
                                        _fetchSiklusData();
                                      } else {
                                        setModalState(() => isSubmitting = false);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(res.message.isNotEmpty ? res.message : 'Gagal menyetujui pengakhiran.')),
                                        );
                                      }
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      setModalState(() => isSubmitting = false);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Terjadi kesalahan: $e')),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: WarnaAplikasi.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            child: isSubmitting
                                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Setujui', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDetailRiwayatSiklusSheet(ItemSiklusTanam siklus) {
    String formatDate(DateTime? date) {
      if (date == null) return '-';
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        siklus.komoditasNama,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: siklus.isSelesai
                              ? const Color(0xFFEFF6FF)
                              : (siklus.isGagal ? const Color(0xFFFEE2E2) : Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          siklus.statusLabel.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: siklus.isSelesai
                                ? const Color(0xFF1D4ED8)
                                : (siklus.isGagal ? const Color(0xFFB91C1C) : Colors.grey.shade700),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Musim: ${siklus.musimTanam} ${siklus.varietas != null && siklus.varietas!.isNotEmpty ? '· Varietas: ${siklus.varietas}' : ''}',
                    style: const TextStyle(fontSize: 12, color: WarnaAplikasi.textGray),
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Mulai Tanam', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            const SizedBox(height: 2),
                            Text(formatDate(siklus.tanggalMulai), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Selesai Tanam', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            const SizedBox(height: 2),
                            Text(formatDate(siklus.tanggalSelesai), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Panen', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            const SizedBox(height: 2),
                            Text(
                              siklus.totalPanenTon != null ? '${siklus.totalPanenTon} Ton' : '-',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (siklus.alasanPengakhiran != null && siklus.alasanPengakhiran!.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text('Alasan Pengakhiran:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(siklus.alasanPengakhiran!, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                  ],
                  if (siklus.diverifikasiOleh != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Diverifikasi oleh: ${siklus.diverifikasiOleh} ${siklus.catatanVerifikasi != null ? "(${siklus.catatanVerifikasi})" : ""}',
                      style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                  ],
                  const Divider(height: 24),
                  const Text('Jejak Audit & Riwayat Pengakhiran', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark)),
                  const SizedBox(height: 8),
                  if (siklus.riwayatPengakhiran.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Tidak ada riwayat catatan audit.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    )
                  else
                    Column(
                      children: siklus.riwayatPengakhiran.map((r) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    r.aksi?.toUpperCase() ?? 'CATATAN',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: WarnaAplikasi.primary),
                                  ),
                                  Text(
                                    formatDate(r.createdAt),
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${r.statusSebelumnya ?? '-'} ➔ ${r.statusSesudahnya ?? '-'}',
                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.black54),
                              ),
                              if (r.alasan != null && r.alasan!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text('Alasan: ${r.alasan}', style: const TextStyle(fontSize: 11, color: Colors.black87)),
                              ],
                              if (r.catatanVerifikasi != null && r.catatanVerifikasi!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text('Catatan: ${r.catatanVerifikasi} (${r.verifikatorNama ?? "Pengurus"})', style: const TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: Colors.grey)),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}

// ==========================================
// BOTTOM SHEET FORM MULAI SIKLUS TANAM
// ==========================================

class _FormMulaiSiklusSheet extends StatefulWidget {
  final ItemLahan lahan;
  final List<ItemKomoditas> komoditasList;
  final Function(ItemSiklusTanam) onSuccess;

  const _FormMulaiSiklusSheet({
    required this.lahan,
    required this.komoditasList,
    required this.onSuccess,
  });

  @override
  State<_FormMulaiSiklusSheet> createState() => _FormMulaiSiklusSheetState();
}

class _FormMulaiSiklusSheetState extends State<_FormMulaiSiklusSheet> {
  final _formKey = GlobalKey<FormState>();

  static const Map<String, String> _kategoriIcons = {
    'Tanaman Pangan': '🌾',
    'Hortikultura & Sayuran': '🌶️',
    'Buah-buahan': '🍉',
    'Perkebunan & Rempah': '☕',
  };

  static const List<String> _kategoriOrder = [
    'Tanaman Pangan',
    'Hortikultura & Sayuran',
    'Buah-buahan',
    'Perkebunan & Rempah',
  ];

  static String _getKategoriIcon(String kategori) {
    return _kategoriIcons[kategori] ?? '🌱';
  }

  static List<ItemKomoditas> _sortKomoditasList(List<ItemKomoditas> input) {
    final list = List<ItemKomoditas>.from(input);
    list.sort((a, b) {
      int orderA = _kategoriOrder.indexOf(a.kategori);
      int orderB = _kategoriOrder.indexOf(b.kategori);
      if (orderA == -1) orderA = 99;
      if (orderB == -1) orderB = 99;
      if (orderA != orderB) return orderA.compareTo(orderB);
      return a.namaKomoditas.toLowerCase().compareTo(b.namaKomoditas.toLowerCase());
    });
    return list;
  }

  late List<ItemKomoditas> _komoditasList;
  bool _isLoadingKomoditas = false;

  String? _selectedKomoditasId;
  final TextEditingController _varietasController = TextEditingController();
  final TextEditingController _musimTanamController = TextEditingController(text: 'MT 1 - 2026');
  final TextEditingController _targetPanenController = TextEditingController();

  DateTime _tanggalMulai = DateTime.now();
  DateTime? _estimasiPanen;

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _komoditasList = _sortKomoditasList(widget.komoditasList);
    _initKomoditasSelection();
    if (_komoditasList.isEmpty) {
      _loadKomoditas();
    }
  }

  void _initKomoditasSelection() {
    if (widget.lahan.idKomoditas != null && _komoditasList.any((k) => k.id == widget.lahan.idKomoditas)) {
      _selectedKomoditasId = widget.lahan.idKomoditas;
    } else if (_komoditasList.isNotEmpty) {
      _selectedKomoditasId = _komoditasList.first.id;
    }
  }

  Future<void> _loadKomoditas() async {
    setState(() => _isLoadingKomoditas = true);
    try {
      final res = await LahanApiService().getKomoditasList();
      if (res.success && res.data != null && res.data!.isNotEmpty) {
        setState(() {
          _komoditasList = _sortKomoditasList(res.data!);
          _initKomoditasSelection();
          _isLoadingKomoditas = false;
        });
      } else {
        setState(() => _isLoadingKomoditas = false);
      }
    } catch (_) {
      setState(() => _isLoadingKomoditas = false);
    }
  }

  @override
  void dispose() {
    _varietasController.dispose();
    _musimTanamController.dispose();
    _targetPanenController.dispose();
    super.dispose();
  }

  Future<void> _pickTanggalMulai() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalMulai,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(), // Boleh backdate, tidak boleh future date
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: WarnaAplikasi.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _tanggalMulai = picked;
        if (_estimasiPanen != null && _estimasiPanen!.isBefore(_tanggalMulai)) {
          _estimasiPanen = null;
        }
      });
    }
  }

  Future<void> _pickEstimasiPanen() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _estimasiPanen ?? _tanggalMulai.add(const Duration(days: 90)),
      firstDate: _tanggalMulai,
      lastDate: DateTime(2035),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: WarnaAplikasi.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _estimasiPanen = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedKomoditasId == null) {
      setState(() => _errorMessage = 'Pilih komoditas terlebih dahulu.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final payload = <String, dynamic>{
      'id_lahan': widget.lahan.id,
      'id_komoditas': _selectedKomoditasId,
      'varietas': _varietasController.text.trim().isNotEmpty ? _varietasController.text.trim() : null,
      'musim_tanam': _musimTanamController.text.trim(),
      'tanggal_mulai': '${_tanggalMulai.year}-${_tanggalMulai.month.toString().padLeft(2, '0')}-${_tanggalMulai.day.toString().padLeft(2, '0')}',
      if (_estimasiPanen != null)
        'estimasi_panen': '${_estimasiPanen!.year}-${_estimasiPanen!.month.toString().padLeft(2, '0')}-${_estimasiPanen!.day.toString().padLeft(2, '0')}',
      if (_targetPanenController.text.trim().isNotEmpty)
        'target_panen_ton': double.tryParse(_targetPanenController.text.trim()),
    };

    try {
      final res = await LahanApiService().createSiklusTanam(payload);
      if (!mounted) return;

      if (res.success && res.data != null) {
        widget.onSuccess(res.data!);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Siklus Tanam berhasil dimulai!')),
        );
      } else {
        setState(() {
          _errorMessage = res.message.isNotEmpty ? res.message : 'Gagal membuat siklus tanam.';
          _isSubmitting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Terjadi kesalahan sistem: $e';
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String formatDate(DateTime? date) {
      if (date == null) return 'Pilih Tanggal';
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }

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
                    color: WarnaAplikasi.borderField,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mulai Siklus Tanam',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: WarnaAplikasi.textGray),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Text(
                'Catat data awal komoditas dan musim tanam untuk memulai masa tanam aktif pada petak ini.',
                style: TextStyle(fontSize: 11.5, color: WarnaAplikasi.textGrayLight, height: 1.3),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFB91C1C), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(fontSize: 11, color: Color(0xFFB91C1C)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Dropdown Komoditas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Komoditas *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark)),
                  if (_isLoadingKomoditas)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: WarnaAplikasi.primary),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              if (_komoditasList.isEmpty && !_isLoadingKomoditas)
                InkWell(
                  onTap: _loadKomoditas,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.refresh_rounded, size: 18, color: Colors.amber),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Gagal memuat master komoditas. Ketuk untuk memuat ulang.',
                            style: TextStyle(fontSize: 12, color: Colors.brown),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  key: ValueKey(_selectedKomoditasId ?? 'komoditas_dropdown'),
                  initialValue: _selectedKomoditasId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WarnaAplikasi.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WarnaAplikasi.border)),
                    filled: true,
                    fillColor: WarnaAplikasi.bgInput,
                  ),
                  selectedItemBuilder: (context) {
                    return _komoditasList.map((k) {
                      final icon = _getKategoriIcon(k.kategori);
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '$icon ${k.nama} (${k.kategori})',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: WarnaAplikasi.primaryDark),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList();
                  },
                  items: _komoditasList.map((k) {
                    final icon = _getKategoriIcon(k.kategori);
                    return DropdownMenuItem<String>(
                      value: k.id,
                      child: Row(
                        children: [
                          Text(icon, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              k.nama,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: WarnaAplikasi.bgLightGreen,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              k.kategori,
                              style: const TextStyle(fontSize: 10, color: WarnaAplikasi.primaryDark, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedKomoditasId = val),
                  validator: (val) => val == null ? 'Komoditas wajib dipilih' : null,
                ),
              const SizedBox(height: 14),

              // TextField Varietas
              const Text('Varietas (Opsional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _varietasController,
                decoration: InputDecoration(
                  hintText: 'Contoh: Inpari 32, Ciherang',
                  hintStyle: const TextStyle(fontSize: 12, color: WarnaAplikasi.textGrayLight),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WarnaAplikasi.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WarnaAplikasi.border)),
                  filled: true,
                  fillColor: WarnaAplikasi.bgInput,
                ),
              ),
              const SizedBox(height: 14),

              // TextField Musim Tanam
              const Text('Musim Tanam *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _musimTanamController,
                decoration: InputDecoration(
                  hintText: 'Contoh: MT 1 - 2026',
                  hintStyle: const TextStyle(fontSize: 12, color: WarnaAplikasi.textGrayLight),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WarnaAplikasi.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WarnaAplikasi.border)),
                  filled: true,
                  fillColor: WarnaAplikasi.bgInput,
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Musim tanam wajib diisi' : null,
              ),
              const SizedBox(height: 14),

              // Row Tanggal Mulai & Estimasi Panen
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tanggal Mulai *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark)),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickTanggalMulai,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: WarnaAplikasi.bgInput,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: WarnaAplikasi.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 14, color: WarnaAplikasi.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    formatDate(_tanggalMulai),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Estimasi Panen', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark)),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickEstimasiPanen,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: WarnaAplikasi.bgInput,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: WarnaAplikasi.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.event_available, size: 14, color: WarnaAplikasi.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    formatDate(_estimasiPanen),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _estimasiPanen != null ? WarnaAplikasi.primaryDark : WarnaAplikasi.textGrayLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // TextField Target Panen Ton
              const Text('Target Hasil Panen (Ton - Opsional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _targetPanenController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Contoh: 5.5',
                  hintStyle: const TextStyle(fontSize: 12, color: WarnaAplikasi.textGrayLight),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WarnaAplikasi.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WarnaAplikasi.border)),
                  filled: true,
                  fillColor: WarnaAplikasi.bgInput,
                ),
              ),
              const SizedBox(height: 20),

              // Tombol Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WarnaAplikasi.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Mulai Siklus Tanam Sekarang'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

