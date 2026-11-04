import 'package:flutter/material.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';

/// Header Standar & Konsisten untuk Seluruh Layar Form / Sub-Layar PawonTani
/// (Tambah Lahan, Edit Lahan, Catat Panen, Tambah Penjualan, Catat Aktivitas, dsb.)
class PawonFormHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;

  const PawonFormHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
  });

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null && subtitle!.isNotEmpty ? 68 : 58);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            InkWell(
              onTap: onBack ?? () => Navigator.maybePop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: WarnaAplikasi.greenLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: WarnaAplikasi.primary,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: WarnaAplikasi.primaryDark,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: WarnaAplikasi.textGray,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
