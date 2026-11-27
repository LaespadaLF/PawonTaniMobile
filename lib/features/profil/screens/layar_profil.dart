import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pawon_mobile/core/constants/api_constants.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/features/auth/models/auth_user_model.dart';
import 'package:pawon_mobile/features/auth/repositories/auth_repository.dart';
import 'package:pawon_mobile/features/dokumen/screens/layar_dokumen_saya.dart';

class ProfileScreen extends StatefulWidget {
  final AuthUserModel? initialUser;

  const ProfileScreen({super.key, this.initialUser});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

/// Alias LayarProfil untuk kompatibilitas nama komponen berbahasa Indonesia
typedef LayarProfil = ProfileScreen;

class _ProfileScreenState extends State<ProfileScreen> {
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

  void _showEditProfileModal(BuildContext context, AuthUserModel user) {
    final nameController = TextEditingController(text: user.nama);
    final phoneController = TextEditingController(text: user.noTelepon ?? '');
    final emailController = TextEditingController(text: user.email ?? '');
    final addressController = TextEditingController(text: user.alamat ?? '');
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
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
                          color: WarnaAplikasi.borderPale,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ubah Data Profil',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: WarnaAplikasi.primaryDark,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Field Nama
                    const Text('Nama Lengkap *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WarnaAplikasi.primaryDark)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Nama lengkap Anda',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Nama tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 12),

                    // Field No Telepon
                    const Text('Nomor WhatsApp / Telepon', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WarnaAplikasi.primaryDark)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Contoh: 081234567890',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Field Email
                    const Text('Email', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WarnaAplikasi.primaryDark)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'nama@email.com',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Field Alamat
                    const Text('Alamat Tempat Tinggal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WarnaAplikasi.primaryDark)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: addressController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Dusun, RT/RW, Desa',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Field Password Baru (opsional)
                    const Text('Password Baru (Kosongkan jika tidak diubah)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WarnaAplikasi.primaryDark)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Minimal 6 karakter',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),

                    if (errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        errorMessage!,
                        style: const TextStyle(fontSize: 12, color: WarnaAplikasi.errorRedDark, fontWeight: FontWeight.bold),
                      ),
                    ],

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setSheetState(() {
                                  isSaving = true;
                                  errorMessage = null;
                                });

                                final res = await _authRepo.updateProfile(
                                  nama: nameController.text.trim(),
                                  noTelepon: phoneController.text.trim(),
                                  email: emailController.text.trim(),
                                  alamat: addressController.text.trim(),
                                  password: passwordController.text.trim().isNotEmpty ? passwordController.text.trim() : null,
                                );

                                if (!mounted) return;

                                if (res.success && res.data != null) {
                                  setState(() {
                                    _user = res.data;
                                  });
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Profil berhasil diperbarui!'),
                                        backgroundColor: WarnaAplikasi.primary,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                } else {
                                  setSheetState(() {
                                    isSaving = false;
                                    errorMessage = res.message.isNotEmpty ? res.message : 'Gagal memperbarui profil.';
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WarnaAplikasi.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: isSaving
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
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

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.logout_rounded, color: WarnaAplikasi.errorRedDark, size: 24),
            SizedBox(width: 10),
            Text('Keluar Akun', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun PawonTani Anda di perangkat ini?',
          style: TextStyle(fontSize: 13.5, color: WarnaAplikasi.textGray),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: WarnaAplikasi.textGray)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // Pop dialog
              Navigator.pop(context); // Pop profile screen if pushed
              await _authRepo.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WarnaAplikasi.errorRedDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Ya, Keluar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    final passwordController = TextEditingController();
    final confirmKeywordController = TextEditingController();
    bool isSubmitting = false;
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: const [
                Icon(Icons.warning_amber_rounded, color: WarnaAplikasi.errorRedDark, size: 24),
                SizedBox(width: 8),
                Text('Hapus Akun', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: WarnaAplikasi.errorRedDark)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Perhatian: Tindakan ini permanen. Akun dan data pribadi Anda akan dihapus dan dinonaktifkan.',
                    style: TextStyle(fontSize: 12.5, color: WarnaAplikasi.textGray),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Masukkan Password:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WarnaAplikasi.primaryDark),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password akun Anda',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ketik konfirmasi "HAPUS AKUN":',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WarnaAplikasi.primaryDark),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: confirmKeywordController,
                    decoration: InputDecoration(
                      hintText: 'HAPUS AKUN',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorText!,
                      style: const TextStyle(fontSize: 12, color: WarnaAplikasi.errorRedDark, fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal', style: TextStyle(color: WarnaAplikasi.textGray)),
              ),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final pw = passwordController.text.trim();
                        final confirm = confirmKeywordController.text.trim();

                        if (pw.isEmpty) {
                          setModalState(() => errorText = 'Password tidak boleh kosong.');
                          return;
                        }
                        if (confirm != 'HAPUS AKUN') {
                          setModalState(() => errorText = 'Ketik "HAPUS AKUN" dengan huruf kapital.');
                          return;
                        }

                        setModalState(() {
                          isSubmitting = true;
                          errorText = null;
                        });

                        final res = await _authRepo.deleteAccount(password: pw);

                        if (!mounted) return;
                        if (res.success) {
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (context.mounted) Navigator.pop(context);
                        } else {
                          setModalState(() {
                            isSubmitting = false;
                            errorText = res.message.isNotEmpty ? res.message : 'Gagal menghapus akun.';
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: WarnaAplikasi.errorRedDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isSubmitting
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Hapus Akun', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return Scaffold(
      backgroundColor: WarnaAplikasi.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profil Petani',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: WarnaAplikasi.primaryDark,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: WarnaAplikasi.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: WarnaAplikasi.primary,
                    ),
                  )
                : const Icon(Icons.refresh_rounded, color: WarnaAplikasi.primary),
            onPressed: _isRefreshing ? null : _refreshProfileData,
            tooltip: 'Segarkan Profil',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: WarnaAplikasi.borderPale, height: 1),
        ),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator(color: WarnaAplikasi.primary))
          : RefreshIndicator(
              onRefresh: _refreshProfileData,
              color: WarnaAplikasi.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header Card (Avatar, Nama, Username, Role & Status)
                    _buildHeaderCard(user),
                    const SizedBox(height: 16),

                    // 2. Data Pribadi & Kontak
                    _buildSectionTitle('Informasi Pribadi & Kontak'),
                    const SizedBox(height: 8),
                    _buildCardWrapper([
                      _buildInfoRow(
                        icon: Icons.badge_outlined,
                        label: 'NIK (Nomor Induk Kependudukan)',
                        value: _formatMaskedNik(user.nik),
                        action: user.nik != null && user.nik!.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  _hideNik ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  size: 18,
                                  color: WarnaAplikasi.textGray,
                                ),
                                onPressed: () {
                                  setState(() => _hideNik = !_hideNik);
                                },
                              )
                            : null,
                      ),
                      const Divider(height: 1, color: WarnaAplikasi.borderPale),
                      _buildInfoRow(
                        icon: Icons.phone_android_rounded,
                        label: 'Nomor WhatsApp / Telepon',
                        value: user.noTelepon ?? '-',
                        action: user.noTelepon != null && user.noTelepon!.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.copy_rounded, size: 16, color: WarnaAplikasi.primary),
                                onPressed: () => _copyToClipboard(user.noTelepon!, 'Nomor Telepon'),
                              )
                            : null,
                      ),
                      const Divider(height: 1, color: WarnaAplikasi.borderPale),
                      _buildInfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email Terdaftar',
                        value: user.email ?? '-',
                        action: user.email != null && user.email!.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.copy_rounded, size: 16, color: WarnaAplikasi.primary),
                                onPressed: () => _copyToClipboard(user.email!, 'Email'),
                              )
                            : null,
                      ),
                      const Divider(height: 1, color: WarnaAplikasi.borderPale),
                      _buildInfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Alamat Tempat Tinggal',
                        value: user.alamat ?? '-',
                      ),
                      if (user.lokasi?.nama != null && user.lokasi!.nama!.isNotEmpty) ...[
                        const Divider(height: 1, color: WarnaAplikasi.borderPale),
                        _buildInfoRow(
                          icon: Icons.map_outlined,
                          label: 'Wilayah / Desa',
                          value: user.lokasi!.nama!,
                        ),
                      ],
                    ]),
                    const SizedBox(height: 16),

                    // 3. Informasi Kelompok Tani (Poktan)
                    _buildSectionTitle('Kelompok Tani & Keanggotaan'),
                    const SizedBox(height: 8),
                    _buildCardWrapper([
                      _buildInfoRow(
                        icon: Icons.groups_outlined,
                        label: 'Nama Kelompok Tani',
                        value: user.kelompokTani?.namaKelompok ?? 'Kelompok Tani Pawon',
                      ),
                      const Divider(height: 1, color: WarnaAplikasi.borderPale),
                      _buildInfoRow(
                        icon: Icons.card_membership_rounded,
                        label: 'ID Anggota',
                        value: user.anggota?.idAnggota ?? (user.id.isNotEmpty ? 'ID: ${user.id}' : '-'),
                        action: IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 16, color: WarnaAplikasi.primary),
                          onPressed: () => _copyToClipboard(
                            user.anggota?.idAnggota ?? user.id,
                            'ID Anggota',
                          ),
                        ),
                      ),
                      const Divider(height: 1, color: WarnaAplikasi.borderPale),
                      _buildInfoRow(
                        icon: Icons.verified_user_outlined,
                        label: 'Status Keanggotaan',
                        value: user.anggota?.statusKeanggotaan ?? 'Aktif',
                      ),
                      if (user.kelompokTani?.alamat != null && user.kelompokTani!.alamat!.isNotEmpty) ...[
                        const Divider(height: 1, color: WarnaAplikasi.borderPale),
                        _buildInfoRow(
                          icon: Icons.domain_rounded,
                          label: 'Sekretariat Poktan',
                          value: user.kelompokTani!.alamat!,
                        ),
                      ],
                    ]),
                    const SizedBox(height: 16),

                    // Dokumen & Privasi Saya
                    _buildSectionTitle('Dokumen & Berkas'),
                    const SizedBox(height: 8),
                    _buildCardWrapper([
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: WarnaAplikasi.bgLightGreen,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.shield_outlined, color: WarnaAplikasi.primary, size: 20),
                        ),
                        title: const Text('Dokumen & Privasi Saya', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark)),
                        subtitle: const Text('Kelola KTP, KK, SPPT & Izin Akses Pengurus', style: TextStyle(fontSize: 11, color: WarnaAplikasi.textGray)),
                        trailing: const Icon(Icons.chevron_right_rounded, color: WarnaAplikasi.textGray),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const LayarDokumenSaya()),
                          );
                        },
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // 4. Informasi Aplikasi
                    _buildSectionTitle('Informasi Aplikasi'),
                    const SizedBox(height: 8),
                    _buildCardWrapper([
                      _buildInfoRow(
                        icon: Icons.smartphone_rounded,
                        label: 'Versi Aplikasi',
                        value: '1.0.0 (PawonTani Mobile)',
                      ),
                      const Divider(height: 1, color: WarnaAplikasi.borderPale),
                      _buildInfoRow(
                        icon: Icons.cloud_done_outlined,
                        label: 'Status Layanan Cloud',
                        value: 'Terhubung ke Server PawonTani',
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // 5. Aksi Akun (Logout & Hapus Akun)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _confirmLogout,
                        icon: const Icon(Icons.logout_rounded, size: 20, color: WarnaAplikasi.errorRedDark),
                        label: const Text(
                          'Keluar dari Akun',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: WarnaAplikasi.errorRedDark,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: WarnaAplikasi.errorRedDark, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Center(
                      child: TextButton.icon(
                        onPressed: _confirmDeleteAccount,
                        icon: const Icon(Icons.delete_forever_outlined, size: 16, color: WarnaAplikasi.textGray),
                        label: const Text(
                          'Hapus Akun Mandiri',
                          style: TextStyle(
                            fontSize: 12,
                            color: WarnaAplikasi.textGray,
                            decoration: TextDecoration.underline,
                          ),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: WarnaAplikasi.primaryDark,
        ),
      ),
    );
  }

  Widget _buildHeaderCard(AuthUserModel user) {
    final photoUrl = ApiConstants.resolveImageUrl(user.fotoProfil);
    final initial = user.nama.isNotEmpty ? user.nama[0].toUpperCase() : 'P';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: WarnaAplikasi.borderPale),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: WarnaAplikasi.primary,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: WarnaAplikasi.primary.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: photoUrl != null
                  ? Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),

          // Nama
          Text(
            user.nama,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: WarnaAplikasi.primaryDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),

          // Username
          Text(
            '@${user.username}',
            style: const TextStyle(
              fontSize: 13,
              color: WarnaAplikasi.textGray,
            ),
          ),
          const SizedBox(height: 12),

          // Role & Status Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: WarnaAplikasi.greenLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.role.isNotEmpty ? user.role : 'Anggota',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: WarnaAplikasi.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: user.isAktif ? const Color(0xFFE8F5E9) : WarnaAplikasi.errorRedBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: user.isAktif ? const Color(0xFF2E7D32) : WarnaAplikasi.errorRedDark,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      user.status.isNotEmpty ? user.status : 'Aktif',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: user.isAktif ? const Color(0xFF2E7D32) : WarnaAplikasi.errorRedDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showEditProfileModal(context, user),
              icon: const Icon(Icons.edit_outlined, size: 16, color: WarnaAplikasi.primary),
              label: const Text(
                'Ubah Data Profil',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: WarnaAplikasi.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: WarnaAplikasi.primary, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardWrapper(List<Widget> children) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: WarnaAplikasi.borderPale),
        ),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? action,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: WarnaAplikasi.greenLight,
              borderRadius: BorderRadius.circular(10),
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
                  style: const TextStyle(
                    fontSize: 11,
                    color: WarnaAplikasi.textGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: WarnaAplikasi.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          if (action != null) ...[action],
        ],
      ),
    );
  }
}
