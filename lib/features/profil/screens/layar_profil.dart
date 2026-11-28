import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawon_mobile/core/constants/api_constants.dart';
import 'package:pawon_mobile/core/theme/tema_controller.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/features/auth/models/auth_user_model.dart';
import 'package:pawon_mobile/features/auth/repositories/auth_repository.dart';

/// Layar Profil Petani PawonTani.
/// Tampilan kartu bersih elegan sesuai desain Profil Petani dengan:
/// 1. Toggle Mode Gelap / Terang terintegrasi TemaController
/// 2. Fitur ganti Foto Profil (PP) & ganti Kata Sandi (PW) pada form edit
/// 3. Baris "ID Anggota" disembunyikan
class LayarProfil extends StatefulWidget {
  final AuthUserModel? initialUser;

  const LayarProfil({super.key, this.initialUser});

  @override
  State<LayarProfil> createState() => _LayarProfilState();
}

class _LayarProfilState extends State<LayarProfil> {
  final AuthRepository _authRepo = AuthRepository();
  AuthUserModel? _user;
  bool _isRefreshing = false;
  bool _hideNik = true;

  @override
  void initState() {
    super.initState();
    _user = widget.initialUser ?? _authRepo.currentUser;
    if (widget.initialUser == null) {
      _refreshProfileData();
    }
  }

  Future<void> _refreshProfileData() async {
    setState(() => _isRefreshing = true);
    final res = await _authRepo.refreshProfile();
    if (!mounted) return;

    setState(() {
      _isRefreshing = false;
      if (res.success && res.data != null) {
        _user = res.data;
      }
    });
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label berhasil disalin ke papan klip'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatMaskedNik(String? nik) {
    if (nik == null || nik.isEmpty) return '-';
    if (_hideNik && nik.length >= 8) {
      final prefix = nik.substring(0, 4);
      final suffix = nik.substring(nik.length - 4);
      return '$prefix •••• •••• $suffix';
    }
    return nik;
  }

  void _bukaDialogEditProfil(BuildContext context) {
    final user = _user;
    if (user == null) return;

    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user.nama);
    final phoneController = TextEditingController(text: user.noTelepon ?? '');
    final emailController = TextEditingController(text: user.email ?? '');
    final addressController = TextEditingController(text: user.alamat ?? '');
    final passwordBaruController = TextEditingController();
    final konfirmasiPasswordController = TextEditingController();

    final ImagePicker picker = ImagePicker();
    XFile? selectedImage;
    Uint8List? selectedImageBytes;
    bool obscurePassword = true;
    bool obscureKonfirmasi = true;
    bool isSaving = false;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final sheetBg = isDark ? const Color(0xFF1D2420) : Colors.white;
          final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.primaryDark;
          final labelColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.grayGreenDark;
          final fieldBorder = isDark ? const Color(0xFF2E4034) : const Color(0xFFD4E5D9);

          return Container(
            decoration: BoxDecoration(
              color: sheetBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2E4034) : WarnaAplikasi.borderPale,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ubah Data Profil',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, size: 20, color: titleColor),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Avatar Edit Section (Ganti Foto Profil / PP)
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: WarnaAplikasi.primary,
                              border: Border.all(color: Colors.white, width: 2.5),
                            ),
                            child: ClipOval(
                              child: selectedImageBytes != null
                                  ? Image.memory(
                                      selectedImageBytes!,
                                      fit: BoxFit.cover,
                                      width: 88,
                                      height: 88,
                                    )
                                  : ((user.fotoProfil != null && user.fotoProfil!.trim().isNotEmpty)
                                      ? Image.network(
                                          ApiConstants.resolveImageUrl(user.fotoProfil) ?? user.fotoProfil!,
                                          fit: BoxFit.cover,
                                          width: 88,
                                          height: 88,
                                          errorBuilder: (context, error, stackTrace) => Center(
                                            child: Text(
                                              user.nama.isNotEmpty ? user.nama.substring(0, 1).toUpperCase() : 'A',
                                              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                                            ),
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            user.nama.isNotEmpty ? user.nama.substring(0, 1).toUpperCase() : 'A',
                                            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                        )),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () async {
                                try {
                                  final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                                  if (picked != null) {
                                    final bytes = await picked.readAsBytes();
                                    setSheetState(() {
                                      selectedImage = picked;
                                      selectedImageBytes = bytes;
                                    });
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Gagal memilih foto: $e')),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: const BoxDecoration(
                                  color: WarnaAplikasi.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),

                    // Field Nama
                    Text('Nama Lengkap *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: labelColor)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: nameController,
                      style: TextStyle(color: titleColor, fontSize: 13.5),
                      decoration: InputDecoration(
                        hintText: 'Nama lengkap Anda',
                        hintStyle: TextStyle(color: labelColor.withOpacity(0.7)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: fieldBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: WarnaAplikasi.primary, width: 1.5),
                        ),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Nama tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 12),

                    // Field No Telepon
                    Text('Nomor WhatsApp / Telepon', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: labelColor)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: titleColor, fontSize: 13.5),
                      decoration: InputDecoration(
                        hintText: 'Contoh: 081234567890',
                        hintStyle: TextStyle(color: labelColor.withOpacity(0.7)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: fieldBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: WarnaAplikasi.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Field Email
                    Text('Email', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: labelColor)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: titleColor, fontSize: 13.5),
                      decoration: InputDecoration(
                        hintText: 'email@domain.com',
                        hintStyle: TextStyle(color: labelColor.withOpacity(0.7)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: fieldBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: WarnaAplikasi.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Field Alamat
                    Text('Alamat Domisili', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: labelColor)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: addressController,
                      maxLines: 2,
                      style: TextStyle(color: titleColor, fontSize: 13.5),
                      decoration: InputDecoration(
                        hintText: 'Dusun, RT/RW, Desa, Kecamatan',
                        hintStyle: TextStyle(color: labelColor.withOpacity(0.7)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: fieldBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: WarnaAplikasi.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Ganti Kata Sandi (PW) Section
                    Text('Ganti Kata Sandi (Kosongkan jika tidak diubah)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: titleColor)),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: passwordBaruController,
                      obscureText: obscurePassword,
                      style: TextStyle(color: titleColor, fontSize: 13.5),
                      decoration: InputDecoration(
                        hintText: 'Kata Sandi Baru (min. 6 karakter)',
                        hintStyle: TextStyle(color: labelColor.withOpacity(0.7)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        suffixIcon: IconButton(
                          icon: Icon(obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: labelColor),
                          onPressed: () => setSheetState(() => obscurePassword = !obscurePassword),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: fieldBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: WarnaAplikasi.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: konfirmasiPasswordController,
                      obscureText: obscureKonfirmasi,
                      style: TextStyle(color: titleColor, fontSize: 13.5),
                      decoration: InputDecoration(
                        hintText: 'Konfirmasi Kata Sandi Baru',
                        hintStyle: TextStyle(color: labelColor.withOpacity(0.7)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        suffixIcon: IconButton(
                          icon: Icon(obscureKonfirmasi ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: labelColor),
                          onPressed: () => setSheetState(() => obscureKonfirmasi = !obscureKonfirmasi),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: fieldBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: WarnaAplikasi.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tombol Aksi Simpan
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSaving ? null : () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: fieldBorder),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            child: Text('Batal', style: TextStyle(color: labelColor, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: isSaving
                                ? null
                                : () async {
                                    if (!formKey.currentState!.validate()) return;
                                    if (passwordBaruController.text.isNotEmpty) {
                                      if (passwordBaruController.text.length < 6) {
                                        setSheetState(() => errorMessage = 'Kata sandi baru minimal 6 karakter');
                                        return;
                                      }
                                      if (passwordBaruController.text != konfirmasiPasswordController.text) {
                                        setSheetState(() => errorMessage = 'Konfirmasi kata sandi tidak cocok');
                                        return;
                                      }
                                    }

                                    setSheetState(() {
                                      isSaving = true;
                                      errorMessage = null;
                                    });

                                    MultipartFile? fotoFile;
                                    if (selectedImage != null && selectedImageBytes != null) {
                                      fotoFile = MultipartFile.fromBytes(
                                        selectedImageBytes!,
                                        filename: selectedImage!.name,
                                      );
                                    }

                                    final res = await _authRepo.updateProfile(
                                      nama: nameController.text.trim(),
                                      noTelepon: phoneController.text.trim(),
                                      email: emailController.text.trim(),
                                      alamat: addressController.text.trim(),
                                      passwordBaru: passwordBaruController.text.isNotEmpty ? passwordBaruController.text : null,
                                      fotoProfil: fotoFile,
                                    );

                                    if (!mounted) return;

                                    if (res.success && res.data != null) {
                                      setState(() {
                                        _user = res.data;
                                      });
                                      if (ctx.mounted) Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Profil berhasil diperbarui'),
                                          backgroundColor: WarnaAplikasi.primary,
                                        ),
                                      );
                                    } else {
                                      setSheetState(() {
                                        isSaving = false;
                                        errorMessage = res.message;
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: WarnaAplikasi.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            child: isSaving
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _konfirmasiLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar dari Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: const Text('Apakah Anda yakin ingin keluar dari sesi aplikasi PawonTani?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              Navigator.pop(context);
              await _authRepo.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = _user ?? _authRepo.currentUser;
    final bgCol = WarnaAplikasi.getBackgroundColor(context);
    final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF28332C) : WarnaAplikasi.borderField;
    final textDark = isDark ? Colors.white : WarnaAplikasi.primaryDark;
    final textSub = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray;
    final dividerCol = isDark ? const Color(0xFF28332C) : WarnaAplikasi.borderPale;

    return Scaffold(
      backgroundColor: bgCol,
      appBar: AppBar(
        title: Text(
          'Profil Petani',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: bgCol,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, size: 22, color: textDark),
            onPressed: _isRefreshing ? null : _refreshProfileData,
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator(color: WarnaAplikasi.primary))
          : RefreshIndicator(
              onRefresh: _refreshProfileData,
              color: WarnaAplikasi.primary,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // 1. Hero Card Foto Profil, Nama, Role, Status & Tombol Ubah Data Profil
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: cardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black26 : Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: WarnaAplikasi.primary,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: (user.fotoProfil != null && user.fotoProfil!.trim().isNotEmpty)
                                ? Image.network(
                                    ApiConstants.resolveImageUrl(user.fotoProfil) ?? user.fotoProfil!,
                                    fit: BoxFit.cover,
                                    width: 92,
                                    height: 92,
                                    errorBuilder: (context, error, stackTrace) => Center(
                                      child: Text(
                                        user.nama.isNotEmpty ? user.nama.substring(0, 1).toUpperCase() : 'A',
                                        style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      user.nama.isNotEmpty ? user.nama.substring(0, 1).toUpperCase() : 'A',
                                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          user.nama,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${user.username}',
                          style: TextStyle(fontSize: 13, color: textSub),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF283A2E) : const Color(0xFFEDF6EE),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                user.role,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: WarnaAplikasi.primary),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF283A2E) : const Color(0xFFEDF6EE),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF4D9830),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    user.status,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4D9830)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _bukaDialogEditProfil(context),
                            icon: const Icon(Icons.edit_outlined, size: 16, color: WarnaAplikasi.primary),
                            label: const Text(
                              'Ubah Data Profil',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: WarnaAplikasi.primary),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: WarnaAplikasi.primary, width: 1.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. Pengaturan Tampilan (Toggle Mode Gelap / Terang)
                  _buildSectionHeader('Pengaturan Tampilan', textDark),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: cardBorder),
                    ),
                    child: ValueListenableBuilder<ThemeMode>(
                      valueListenable: TemaController.instance.themeMode,
                      builder: (context, mode, _) {
                        final isCurrentlyDark = mode == ThemeMode.dark;
                        return Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF2A3830) : const Color(0xFFF0F5F1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isCurrentlyDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                                size: 20,
                                color: isCurrentlyDark ? Colors.amber : WarnaAplikasi.primary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isCurrentlyDark ? 'Mode Gelap Aktif' : 'Mode Terang Aktif',
                                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: textDark),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Sesuaikan tampilan layar ramah mata',
                                    style: TextStyle(fontSize: 11, color: textSub),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: isCurrentlyDark,
                              activeThumbColor: const Color(0xFF4D9830),
                              onChanged: (val) {
                                TemaController.instance.toggleMode(val);
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 3. Informasi Pribadi & Kontak
                  _buildSectionHeader('Informasi Pribadi & Kontak', textDark),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: cardBorder),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.badge_outlined,
                          label: 'NIK (Nomor Induk Kependudukan)',
                          value: _formatMaskedNik(user.nik),
                          isDark: isDark,
                          action: IconButton(
                            icon: Icon(
                              _hideNik ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              size: 18,
                              color: textSub,
                            ),
                            onPressed: () => setState(() => _hideNik = !_hideNik),
                          ),
                        ),
                        Divider(height: 1, color: dividerCol),
                        _buildInfoRow(
                          icon: Icons.phone_android_rounded,
                          label: 'Nomor WhatsApp / Telepon',
                          value: user.noTelepon ?? '-',
                          isDark: isDark,
                          action: user.noTelepon != null
                              ? IconButton(
                                  icon: const Icon(Icons.copy_rounded, size: 16, color: WarnaAplikasi.primary),
                                  onPressed: () => _copyToClipboard(user.noTelepon!, 'Nomor WhatsApp'),
                                )
                              : null,
                        ),
                        Divider(height: 1, color: dividerCol),
                        _buildInfoRow(
                          icon: Icons.mail_outline_rounded,
                          label: 'Email Terdaftar',
                          value: user.email ?? '-',
                          isDark: isDark,
                          action: user.email != null
                              ? IconButton(
                                  icon: const Icon(Icons.copy_rounded, size: 16, color: WarnaAplikasi.primary),
                                  onPressed: () => _copyToClipboard(user.email!, 'Email'),
                                )
                              : null,
                        ),
                        Divider(height: 1, color: dividerCol),
                        _buildInfoRow(
                          icon: Icons.location_on_outlined,
                          label: 'Alamat Tempat Tinggal',
                          value: user.alamat ?? '-',
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 4. Kelompok Tani & Keanggotaan (ID Anggota Dihapus sesuai permintaan)
                  _buildSectionHeader('Kelompok Tani & Keanggotaan', textDark),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: cardBorder),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.groups_outlined,
                          label: 'Nama Kelompok Tani',
                          value: user.kelompokTani?.namaKelompok ?? 'Kelompok Tani Bersama',
                          isDark: isDark,
                        ),
                        Divider(height: 1, color: dividerCol),
                        _buildInfoRow(
                          icon: Icons.verified_user_outlined,
                          label: 'Status Keanggotaan',
                          value: user.anggota?.statusKeanggotaan ?? 'Aktif',
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 5. Tombol Keluar dari Akun
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _konfirmasiLogout(context),
                      icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.red),
                      label: const Text('Keluar dari Akun', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    Widget? action,
  }) {
    final titleCol = isDark ? Colors.white : WarnaAplikasi.primaryDark;
    final subCol = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF283A2E) : const Color(0xFFEDF6EE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: WarnaAplikasi.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: subCol),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: titleCol),
                ),
              ],
            ),
          ),
          if (action != null) action,
        ],
      ),
    );
  }
}
