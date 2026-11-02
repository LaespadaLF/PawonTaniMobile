import 'package:flutter/material.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/features/auth/repositories/auth_repository.dart';
import 'package:pawon_mobile/features/auth/screens/layar_login.dart';
import 'package:pawon_mobile/main.dart';

/// Gerbang autentikasi aplikasi PawonTani Mobile.
/// Berfungsi sebagai pengatur alur otomatis antara layar splash/loading,
/// LayarLogin, dan MainNavigationShell berdasarkan status token aktif.
class AuthGate extends StatefulWidget {
  final AuthRepository? authRepository;

  const AuthGate({
    super.key,
    this.authRepository,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthRepository _authRepo;

  @override
  void initState() {
    super.initState();
    _authRepo = widget.authRepository ?? AuthRepository.instance;

    // Menjalankan pengecekan token satu kali saat inisialisasi awal aplikasi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authRepo.checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthStatus>(
      valueListenable: _authRepo.authStatusListenable,
      builder: (context, status, _) {
        switch (status) {
          case AuthStatus.initial:
            return const _SplashLoadingScreen();
          case AuthStatus.authenticated:
            return const MainNavigationShell();
          case AuthStatus.unauthenticated:
            return const LayarLogin();
        }
      },
    );
  }
}

/// Layar transisi ringan saat aplikasi pertama kali memverifikasi token
class _SplashLoadingScreen extends StatelessWidget {
  const _SplashLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo_pawontani.png',
              height: 72,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.eco_rounded,
                size: 64,
                color: WarnaAplikasi.primary,
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(WarnaAplikasi.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
