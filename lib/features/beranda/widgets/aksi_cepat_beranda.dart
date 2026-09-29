import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:flutter/material.dart';

class HomeQuickActionsSection extends StatelessWidget {
  final VoidCallback? onAllTap;
  final VoidCallback? onTambahLahan;
  final VoidCallback? onCatatAktivitas;
  final VoidCallback? onCatatPanen;
  final VoidCallback? onPenjualan;

  const HomeQuickActionsSection({
    super.key,
    this.onAllTap,
    this.onTambahLahan,
    this.onCatatAktivitas,
    this.onCatatPanen,
    this.onPenjualan,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Aksi Cepat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: WarnaAplikasi.primaryDark,
              ),
            ),
            InkWell(
              onTap: onAllTap,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'Semua aksi >',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: WarnaAplikasi.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Action Buttons Row
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.spa_outlined,
                label: 'Tambah\nLahan',
                onTap: onTambahLahan,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.assignment_outlined,
                label: 'Catat\nAktivitas',
                onTap: onCatatAktivitas,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.agriculture_rounded,
                label: 'Catat\nPanen',
                onTap: onCatatPanen,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.storefront_outlined,
                label: 'Penjualan',
                onTap: onPenjualan,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 98,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8EFEA),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon pill
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 20,
                      color: WarnaAplikasi.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Label
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: WarnaAplikasi.primaryDark,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
