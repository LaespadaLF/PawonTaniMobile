import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Komponen Header reusable untuk aplikasi PawonTani
/// 
/// Menampilkan:
/// - Sapaan waktu (Selamat pagi/siang/sore/malam)
/// - Nama pengguna dengan emoji
/// - Ikon notifikasi dengan badge
/// - Foto profil pengguna
class PawonTaniHeader extends StatelessWidget {
  final String userName;
  final String? greeting; // Opsional, jika null akan auto-detect berdasarkan waktu
  final int notificationCount;
  final String? profileImageUrl;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const PawonTaniHeader({
    super.key,
    required this.userName,
    this.greeting,
    this.notificationCount = 0,
    this.profileImageUrl,
    this.onNotificationTap,
    this.onProfileTap,
  });

  /// Mendapatkan sapaan berdasarkan waktu saat ini
  String _getGreeting() {
    if (greeting != null) return greeting!;

    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      return 'Selamat pagi';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat siang';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat sore';
    } else {
      return 'Selamat malam';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Bagian Kiri: Sapaan dan Nama
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_getGreeting()},',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$userName 👋',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          
          // Bagian Kanan: Notifikasi dan Profil
          Row(
            children: [
              // Ikon Notifikasi dengan Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    iconSize: 26,
                    color: AppColors.textPrimary,
                    onPressed: onNotificationTap ?? () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          notificationCount > 9 ? '9+' : '$notificationCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              
              // Foto Profil
              GestureDetector(
                onTap: onProfileTap ?? () {},
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    border: Border.all(
                      color: AppColors.primaryLight.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: profileImageUrl != null
                      ? ClipOval(
                          child: Image.network(
                            profileImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAvatar();
                            },
                          ),
                        )
                      : _buildDefaultAvatar(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget avatar default jika tidak ada foto profil
  Widget _buildDefaultAvatar() {
    return const Icon(
      Icons.person,
      color: Colors.white,
      size: 26,
    );
  }
}
