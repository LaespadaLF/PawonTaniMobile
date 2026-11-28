import 'package:flutter/material.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/core/utils/waktu_relatif_util.dart';
import 'package:pawon_mobile/features/notifikasi/models/item_notifikasi.dart';

/// Kartu tampilan per item notifikasi dalam daftar.
/// Menampilkan icon kategori, judul, pesan, waktu relatif, serta indikator visual read/unread.
class NotificationItemCard extends StatelessWidget {
  final ItemNotifikasi item;
  final VoidCallback onTap;

  const NotificationItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !item.sudahDibaca;
    final entityType = item.entityType;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Tentukan konfigurasi ikon dan warna berdasarkan tipe entitas
    final IconData iconData;
    final Color iconColor;
    final Color iconBgColor;

    switch (entityType) {
      case 'lahan':
        iconData = Icons.landscape_rounded;
        iconColor = isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32);
        iconBgColor = isDark ? const Color(0xFF1E3324) : const Color(0xFFE8F5E9);
        break;
      case 'siklus_tanam':
        iconData = Icons.eco_rounded;
        iconColor = isDark ? const Color(0xFFA5D6A7) : const Color(0xFF1B5E20);
        iconBgColor = isDark ? const Color(0xFF233D2A) : const Color(0xFFDCEDC8);
        break;
      case 'panen':
        iconData = Icons.agriculture_rounded;
        iconColor = isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100);
        iconBgColor = isDark ? const Color(0xFF3E2C1C) : const Color(0xFFFFF3E0);
        break;
      default:
        iconData = Icons.notifications_active_rounded;
        iconColor = isDark ? const Color(0xFF66BB6A) : WarnaAplikasi.primary;
        iconBgColor = isDark ? const Color(0xFF203627) : WarnaAplikasi.bgPaleGreen2;
    }

    final normalCardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
    final unreadCardBg = isDark ? const Color(0xFF223027) : const Color(0xFFF1F8F4);
    final borderColor = isDark ? const Color(0xFF2E3B33) : WarnaAplikasi.borderPale;
    final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDark;
    final bodyColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray;

    final metaColor = isDark ? const Color(0xFF7E9385) : WarnaAplikasi.textGray;
    final timeColor = isUnread
        ? (isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary)
        : metaColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isUnread ? unreadCardBg : normalCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnread ? WarnaAplikasi.primary.withAlpha(isDark ? 100 : 50) : borderColor,
          width: isUnread ? 1.2 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 20 : (isUnread ? 8 : 4)),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Icon Kategori
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      iconData,
                      size: 20,
                      color: iconColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // 2. Isi Notifikasi: Judul, Pesan, Waktu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              item.judul,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                                color: titleColor,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: WarnaAplikasi.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.pesan,
                        style: TextStyle(
                          fontSize: 12.2,
                          color: bodyColor,
                          height: 1.35,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 11,
                            color: timeColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            WaktuRelatifUtil.format(item.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                              color: timeColor,
                            ),
                          ),
                          if (item.namaLahan != null && item.namaLahan!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              '•  ${item.namaLahan}',
                              style: TextStyle(
                                fontSize: 11,
                                color: metaColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ],
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
