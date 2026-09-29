import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:flutter/material.dart';

class PawonBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const PawonBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
      _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Beranda'),
      _NavItem(icon: Icons.grid_view_rounded, activeIcon: Icons.grid_view_rounded, label: 'Lahan'),
      _NavItem(icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today_rounded, label: 'Aktivitas'),
      _NavItem(icon: Icons.eco_outlined, activeIcon: Icons.eco_rounded, label: 'Panen'),
      _NavItem(icon: Icons.shopping_bag_outlined, activeIcon: Icons.shopping_bag_rounded, label: 'Penjualan'),
      _NavItem(icon: Icons.school_outlined, activeIcon: Icons.school_rounded, label: 'Edukasi'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFEBF0EC),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        top: 6,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom
            : 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          final item = navItems[index];
          final isSelected = currentIndex == index;

          return InkWell(
            onTap: () => onTap(index),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon container (active has light green pill)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? WarnaAplikasi.greenPill
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      size: 20,
                      color: isSelected
                          ? WarnaAplikasi.greenText
                          : const Color(0xFF869E90),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? WarnaAplikasi.greenText
                          : const Color(0xFF869E90),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
