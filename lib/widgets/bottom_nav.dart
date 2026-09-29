import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Model untuk item menu Bottom Navigation
class BottomNavItem {
  final String label;
  final IconData inactiveIcon;
  final IconData activeIcon;
  final int index;

  const BottomNavItem({
    required this.label,
    required this.inactiveIcon,
    required this.activeIcon,
    required this.index,
  });
}

/// Komponen Bottom Navigation Bar reusable untuk aplikasi PawonTani
/// 
/// Menampilkan 6 menu navigasi:
/// 1. Beranda
/// 2. Lahan
/// 3. Aktivitas
/// 4. Panen
/// 5. Penjualan
/// 6. Edukasi
class PawonTaniBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const PawonTaniBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  /// Daftar menu navigasi
  static const List<BottomNavItem> navItems = [
    BottomNavItem(
      label: 'Beranda',
      inactiveIcon: Icons.home_outlined,
      activeIcon: Icons.home,
      index: 0,
    ),
    BottomNavItem(
      label: 'Lahan',
      inactiveIcon: Icons.landscape_outlined,
      activeIcon: Icons.landscape,
      index: 1,
    ),
    BottomNavItem(
      label: 'Aktivitas',
      inactiveIcon: Icons.checklist_outlined,
      activeIcon: Icons.checklist,
      index: 2,
    ),
    BottomNavItem(
      label: 'Panen',
      inactiveIcon: Icons.shopping_basket_outlined,
      activeIcon: Icons.shopping_basket,
      index: 3,
    ),
    BottomNavItem(
      label: 'Penjualan',
      inactiveIcon: Icons.point_of_sale_outlined,
      activeIcon: Icons.point_of_sale,
      index: 4,
    ),
    BottomNavItem(
      label: 'Edukasi',
      inactiveIcon: Icons.school_outlined,
      activeIcon: Icons.school,
      index: 5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: AppColors.border.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navItems.map((item) {
              return _buildNavItem(item);
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// Membangun satu item menu navigasi
  Widget _buildNavItem(BottomNavItem item) {
    final isActive = currentIndex == item.index;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(item.index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? item.activeIcon : item.inactiveIcon,
                color: isActive ? AppColors.primary : AppColors.textMuted,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 10,
                  color: isActive ? AppColors.primary : AppColors.textMuted,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Alternative: Bottom Navigation dengan design yang lebih compact
/// untuk menghindari overflow pada layar kecil
class PawonTaniBottomNavCompact extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const PawonTaniBottomNavCompact({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: AppColors.border.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: PawonTaniBottomNav.navItems.asMap().entries.map((entry) {
              final item = entry.value;
              final isActive = currentIndex == item.index;

              return Flexible(
                child: InkWell(
                  onTap: () => onTap(item.index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive ? item.activeIcon : item.inactiveIcon,
                        color: isActive ? AppColors.primary : AppColors.textMuted,
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 9,
                            color: isActive ? AppColors.primary : AppColors.textMuted,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
