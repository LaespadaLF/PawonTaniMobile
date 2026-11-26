import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/features/auth/models/auth_user_model.dart';
import 'package:pawon_mobile/features/auth/repositories/auth_repository.dart';

/// Layar Form Edit Biodata Anggota (Foto Profil, Nama, Username, No Telepon, Email, Alamat, Password Baru).
class LayarEditProfil extends StatefulWidget {
  final AuthUserModel? user;

  const LayarEditProfil({super.key, this.user});

  @override
  State<LayarEditProfil> createState() => _LayarEditProfilState();
}

class _LayarEditProfilState extends State<LayarEditProfil> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _teleponController;
  late TextEditingController _alamatController;
  late TextEditingController _passwordBaruController;
  late TextEditingController _konfirmasiPasswordController;

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;

  bool _isSaving = false;
  bool _obscurePassword = true;
  bool _obscureKonfirmasi = true;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.user?.nama ?? '');
    _usernameController = TextEditingController(text: widget.user?.username ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _teleponController = TextEditingController(text: widget.user?.noTelepon ?? '');
    _alamatController = TextEditingController(text: widget.user?.alamat ?? '');
    _passwordBaruController = TextEditingController();
    _konfirmasiPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    _passwordBaruController.dispose();
    _konfirmasiPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pilihFotoProfil() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _selectedImage = picked;
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih foto: $e')),
      );
    }
  }

  Future<void> _simpanPerubahan() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordBaruController.text.isNotEmpty &&
        _passwordBaruController.text != _konfirmasiPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi kata sandi tidak cocok dengan kata sandi baru.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      MultipartFile? multipartFoto;
      if (_selectedImage != null && _selectedImageBytes != null) {
        multipartFoto = MultipartFile.fromBytes(
          _selectedImageBytes!,
          filename: _selectedImage!.name,
        );
      }

      final response = await AuthRepository().updateProfile(
        nama: _namaController.text,
        username: _usernameController.text.isNotEmpty ? _usernameController.text : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        noTelepon: _teleponController.text.isNotEmpty ? _teleponController.text : null,
        alamat: _alamatController.text.isNotEmpty ? _alamatController.text : null,
        passwordBaru: _passwordBaruController.text.isNotEmpty ? _passwordBaruController.text : null,
        fotoProfil: multipartFoto,
      );

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message.isNotEmpty ? response.message : 'Profil berhasil diperbarui.'),
            backgroundColor: WarnaAplikasi.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message.isNotEmpty ? response.message : 'Gagal memperbarui profil.'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E2820) : Colors.white;
    final textHeader = isDark ? Colors.white : WarnaAplikasi.primaryDark;
    final inputBg = isDark ? const Color(0xFF283A2E) : WarnaAplikasi.bgInput;
    final existingPhoto = widget.user?.fotoProfil;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profil',
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Edit Card
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 54,
                      backgroundColor: WarnaAplikasi.primary,
                      backgroundImage: _selectedImageBytes != null
                          ? MemoryImage(_selectedImageBytes!)
                          : (existingPhoto != null && existingPhoto.isNotEmpty
                              ? NetworkImage(existingPhoto)
                              : null) as ImageProvider?,
                      child: (_selectedImageBytes == null && (existingPhoto == null || existingPhoto.isEmpty))
                          ? Text(
                              (widget.user?.nama.isNotEmpty == true)
                                  ? widget.user!.nama[0].toUpperCase()
                                  : 'P',
                              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pilihFotoProfil,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: WarnaAplikasi.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: cardBg, width: 2.5),
                          ),
                          child: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: _pilihFotoProfil,
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: const Text('Ganti Foto Profil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  style: TextButton.styleFrom(foregroundColor: WarnaAplikasi.primary),
                ),
              ),

              const SizedBox(height: 16),

              // Card Informasi Biodata
              Container(
                padding: const EdgeInsets.all(20),
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
                    Text('Data Pribadi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textHeader)),
                    const SizedBox(height: 14),

                    // Field Nama
                    _buildLabel('Nama Lengkap *', textHeader),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _namaController,
                      style: TextStyle(color: textHeader, fontSize: 14),
                      decoration: _inputDecoration(
                        hint: 'Masukkan nama lengkap',
                        icon: Icons.person_outline_rounded,
                        inputBg: inputBg,
                        isDark: isDark,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Nama lengkap tidak boleh kosong';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Field Username
                    _buildLabel('Username Akun *', textHeader),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _usernameController,
                      style: TextStyle(color: textHeader, fontSize: 14),
                      decoration: _inputDecoration(
                        hint: 'Masukkan username unik akun Anda',
                        icon: Icons.alternate_email_rounded,
                        inputBg: inputBg,
                        isDark: isDark,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Username tidak boleh kosong';
                        }
                        if (val.contains(' ')) {
                          return 'Username tidak boleh menggunakan spasi';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Field Nomor Telepon
                    _buildLabel('Nomor Telepon / WhatsApp', textHeader),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _teleponController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: textHeader, fontSize: 14),
                      decoration: _inputDecoration(
                        hint: 'Contoh: 081234567890',
                        icon: Icons.phone_outlined,
                        inputBg: inputBg,
                        isDark: isDark,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Field Email
                    _buildLabel('Alamat Email', textHeader),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: textHeader, fontSize: 14),
                      decoration: _inputDecoration(
                        hint: 'Contoh: petani@pawontani.com',
                        icon: Icons.mail_outline_rounded,
                        inputBg: inputBg,
                        isDark: isDark,
                      ),
                      validator: (val) {
                        if (val != null && val.trim().isNotEmpty) {
                          final emailRegEx = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegEx.hasMatch(val.trim())) {
                            return 'Format email tidak valid';
                          }
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Field Alamat
                    _buildLabel('Alamat Domisili', textHeader),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _alamatController,
                      maxLines: 2,
                      style: TextStyle(color: textHeader, fontSize: 14),
                      decoration: _inputDecoration(
                        hint: 'Masukkan alamat tempat tinggal / dusun',
                        icon: Icons.location_on_outlined,
                        inputBg: inputBg,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Card Ganti Kata Sandi (Opsional)
              Container(
                padding: const EdgeInsets.all(20),
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
                    Row(
                      children: [
                        const Icon(Icons.lock_reset_rounded, size: 20, color: WarnaAplikasi.primary),
                        const SizedBox(width: 8),
                        Text('Ganti Kata Sandi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textHeader)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kosongkan jika tidak ingin mengubah kata sandi.',
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : WarnaAplikasi.textGray),
                    ),
                    const SizedBox(height: 16),

                    // Field Password Baru
                    _buildLabel('Kata Sandi Baru', textHeader),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordBaruController,
                      obscureText: _obscurePassword,
                      style: TextStyle(color: textHeader, fontSize: 14),
                      decoration: _inputDecoration(
                        hint: 'Minimal 6 karakter',
                        icon: Icons.lock_outline_rounded,
                        inputBg: inputBg,
                        isDark: isDark,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 18,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (val) {
                        if (val != null && val.isNotEmpty && val.length < 6) {
                          return 'Kata sandi minimal 6 karakter';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Field Konfirmasi Password
                    _buildLabel('Konfirmasi Kata Sandi Baru', textHeader),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _konfirmasiPasswordController,
                      obscureText: _obscureKonfirmasi,
                      style: TextStyle(color: textHeader, fontSize: 14),
                      decoration: _inputDecoration(
                        hint: 'Ketik ulang kata sandi baru',
                        icon: Icons.lock_clock_outlined,
                        inputBg: inputBg,
                        isDark: isDark,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureKonfirmasi ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 18,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(() => _obscureKonfirmasi = !_obscureKonfirmasi),
                        ),
                      ),
                      validator: (val) {
                        if (_passwordBaruController.text.isNotEmpty) {
                          if (val == null || val.isEmpty) {
                            return 'Harap konfirmasi kata sandi baru Anda';
                          }
                          if (val != _passwordBaruController.text) {
                            return 'Konfirmasi kata sandi tidak cocok';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _simpanPerubahan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WarnaAplikasi.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: WarnaAplikasi.primary.withOpacity(0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Simpan Perubahan',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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

  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required Color inputBg,
    required bool isDark,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 13,
        color: isDark ? Colors.grey.shade500 : WarnaAplikasi.textFieldHint,
      ),
      prefixIcon: Icon(icon, size: 20, color: WarnaAplikasi.primary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: inputBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF384E3F) : WarnaAplikasi.borderField,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF384E3F) : WarnaAplikasi.borderField,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: WarnaAplikasi.primary, width: 1.5),
      ),
    );
  }
}
