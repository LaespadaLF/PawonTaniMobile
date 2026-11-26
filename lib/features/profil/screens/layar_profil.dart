import 'package:flutter/material.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/core/theme/tema_controller.dart';
import 'package:pawon_mobile/features/auth/repositories/auth_repository.dart';
import 'package:pawon_mobile/features/auth/models/auth_user_model.dart';
import 'package:pawon_mobile/features/profil/screens/layar_edit_profil.dart';

/// Layar Profil Anggota PawonTani.
/// Menampilkan biodata lengkap, informasi kelompok tani, pengaturan tema gelap/terang, dan tombol logout.
class LayarProfil extends StatefulWidget {
  const LayarProfil({super.key});

  @override
  State<LayarProfil> createState() => _LayarProfilState();
}

class _LayarProfilState extends State<LayarProfil> {
  final AuthRepository _authRepository = AuthRepository();
  AuthUserModel? _user;

  @override
  void initState() {
    super.initState();
    _user = _authRepository.currentUser;
    _refreshProfile();
  }

  Future<void> _refreshProfile() async {
    await _authRepository.checkAuthStatus();
    if (mounted) {
      setState(() {
        _user = _authRepository.currentUser;
      });
    }
  }

  void _bukaLayarEdit() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => LayarEditProfil(user: _user),
      ),
    );
    if (result == true) {
      _refreshProfile();
    }
  }

  void _konfirmasiLogout() {
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
              Navigator.pop(context); // Kembali dari LayarProfil
              await _authRepository.logout();
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
    final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
    final textHeader = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.primaryDark;
    final textSub = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray;
    final dividerColor = isDark ? const Color(0xFF28332C) : const Color(0xFFEBF0EC);

    return Scaffold(
      backgroundColor: WarnaAplikasi.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: cardBg,
        foregroundColor: textHeader,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, size: 26),
            tooltip: 'Edit Biodata',
            onPressed: _bukaLayarEdit,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        color: WarnaAplikasi.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Header Card Avatar & Nama
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: WarnaAplikasi.primary,
                          backgroundImage: (_user?.fotoProfil != null && _user!.fotoProfil!.isNotEmpty)
                              ? NetworkImage(_user!.fotoProfil!)
                              : null,
                          child: (_user?.fotoProfil == null || _user!.fotoProfil!.isEmpty)
                              ? Text(
                                  (_user?.nama.isNotEmpty == true)
                                      ? _user!.nama[0].toUpperCase()
                                      : 'P',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: WarnaAplikasi.accentGreen,
                            shape: BoxShape.circle,
                            border: Border.all(color: cardBg, width: 2),
                          ),
                          child: const Icon(Icons.check, size: 14, color: WarnaAplikasi.primaryDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _user?.nama ?? 'Nama Petani',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: textHeader,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF283A2E) : WarnaAplikasi.greenPill,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _user?.role ?? 'Anggota Kelompok Tani',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: WarnaAplikasi.primaryMedium,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Quick Action Edit
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _bukaLayarEdit,
                        icon: Icon(Icons.edit_rounded, size: 16, color: isDark ? WarnaAplikasi.accentGreen : WarnaAplikasi.primary),
                        label: Text('Edit Biodata', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? WarnaAplikasi.accentGreen : WarnaAplikasi.primary)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: isDark ? WarnaAplikasi.accentGreen : WarnaAplikasi.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Pengaturan Tampilan (Gelap / Terang)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengaturan Tampilan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textHeader,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<ThemeMode>(
                      valueListenable: TemaController.instance.themeMode,
                      builder: (context, themeMode, _) {
                        final isCurrentlyDark = themeMode == ThemeMode.dark;
                        return Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isCurrentlyDark
                                    ? const Color(0xFF2D3C32)
                                    : const Color(0xFFF2F7F4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isCurrentlyDark
                                    ? Icons.dark_mode_rounded
                                    : Icons.light_mode_rounded,
                                color: isCurrentlyDark ? Colors.amber : WarnaAplikasi.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isCurrentlyDark ? 'Mode Gelap Aktif' : 'Mode Terang Aktif',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: textHeader,
                                    ),
                                  ),
                                  Text(
                                    isCurrentlyDark
                                        ? 'Tampilan gelap ramah mata malam hari'
                                        : 'Tampilan terang alami PawonTani',
                                    style: TextStyle(fontSize: 12, color: textSub),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: isCurrentlyDark,
                              activeColor: WarnaAplikasi.primary,
                              activeTrackColor: WarnaAplikasi.accentGreen,
                              onChanged: (val) {
                                TemaController.instance.toggleMode(val);
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Informasi Biodata Detail
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Biodata Anggota',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textHeader,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildBiodataItem(
                      context: context,
                      icon: Icons.badge_outlined,
                      label: 'Nomor Induk Kependudukan (NIK)',
                      value: _user?.nik?.isNotEmpty == true ? _user!.nik! : 'Belum terdaftar',
                      textHeader: textHeader,
                      textSub: textSub,
                      dividerColor: dividerColor,
                    ),
                    _buildBiodataItem(
                      context: context,
                      icon: Icons.person_outline_rounded,
                      label: 'Username Akun',
                      value: _user?.username ?? '-',
                      textHeader: textHeader,
                      textSub: textSub,
                      dividerColor: dividerColor,
                    ),
                    _buildBiodataItem(
                      context: context,
                      icon: Icons.phone_outlined,
                      label: 'Nomor Telepon / WhatsApp',
                      value: _user?.noTelepon?.isNotEmpty == true
                          ? _user!.noTelepon!
                          : 'Belum diisi',
                      textHeader: textHeader,
                      textSub: textSub,
                      dividerColor: dividerColor,
                    ),
                    _buildBiodataItem(
                      context: context,
                      icon: Icons.mail_outline_rounded,
                      label: 'Alamat Email',
                      value: _user?.email?.isNotEmpty == true
                          ? _user!.email!
                          : 'Belum diisi',
                      textHeader: textHeader,
                      textSub: textSub,
                      dividerColor: dividerColor,
                    ),
                    _buildBiodataItem(
                      context: context,
                      icon: Icons.location_on_outlined,
                      label: 'Alamat Tempat Tinggal',
                      value: _user?.alamat?.isNotEmpty == true
                          ? _user!.alamat!
                          : 'Belum diisi',
                      textHeader: textHeader,
                      textSub: textSub,
                      dividerColor: dividerColor,
                    ),
                    _buildBiodataItem(
                      context: context,
                      icon: Icons.groups_outlined,
                      label: 'Kelompok Tani',
                      value: _user?.kelompokTani?.namaKelompok ?? 'Belum bergabung',
                      textHeader: textHeader,
                      textSub: textSub,
                      dividerColor: dividerColor,
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tombol Logout
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _konfirmasiLogout,
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text('Keluar dari Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE2E2),
                    foregroundColor: const Color(0xFFDC2626),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBiodataItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color textHeader,
    required Color textSub,
    required Color dividerColor,
    bool isLast = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF283A2E) : WarnaAplikasi.bgPaleGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: isDark ? WarnaAplikasi.accentGreen : WarnaAplikasi.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 11, color: textSub, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textHeader)),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 12),
          Divider(color: dividerColor, height: 1),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
