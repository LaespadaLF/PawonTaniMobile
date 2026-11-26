import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:flutter/material.dart';
import 'package:pawon_mobile/features/panen/models/item_panen.dart';
import 'package:pawon_mobile/core/widgets/ikon_tanaman_kustom.dart';

class HarvestCard extends StatelessWidget {
  final HarvestItem item;
  final VoidCallback? onTap;

  const HarvestCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF28332C) : WarnaAplikasi.borderPale;
    final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.nearBlack;
    final subtitleColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGrayGreenSoft;
    final dividerColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.dividerLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cardBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.transparent : WarnaAplikasi.shadowSubtle,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Icon, Title & Subtitle, Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CropIconWidget(
                      cropType: item.cropType,
                      size: 46,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: subtitleColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(item.status, isDark),
                  ],
                ),
                const SizedBox(height: 12),

                // Divider line with subtle right chevron indicator
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Divider(
                      height: 1,
                      thickness: 0.8,
                      color: dividerColor,
                    ),
                    Container(
                      color: cardBg,
                      padding: const EdgeInsets.only(left: 6),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.grayGreenMuted,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 2x2 Grid of details
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Col 1 Row 1: Location
                    Expanded(
                      child: _buildDetailCell(
                        icon: Icons.location_on_outlined,
                        iconColor: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.iconGrayGreenMid,
                        title: item.location,
                        subtitle: item.blockArea.replaceAll(RegExp(r'\.0000|\.00'), ''),
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Col 2 Row 1: Date & Season
                    Expanded(
                      child: _buildDetailCell(
                        icon: Icons.calendar_today_outlined,
                        iconColor: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.iconGrayGreenMid,
                        title: item.date,
                        subtitle: item.season,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Col 1 Row 2: Total Berat Panen
                    Expanded(
                      child: _buildDetailCell(
                        icon: Icons.scale_outlined,
                        iconColor: item.cropType == CropType.padi
                            ? (isDark ? const Color(0xFF81C784) : WarnaAplikasi.padiGreen)
                            : WarnaAplikasi.jagungAmber,
                        title: '${_formatNumber(item.weightKg)} Kg',
                        subtitle: '${item.weightTon.toStringAsFixed(item.weightTon.truncateToDouble() == item.weightTon ? 0 : 2).replaceAll('.', ',')} Ton',
                        isBoldTitle: true,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Col 2 Row 2: Metode Pemanenan & Waktu Panen
                    Expanded(
                      child: _buildDetailCell(
                        icon: Icons.agriculture_outlined,
                        iconColor: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.iconGrayGreenMid,
                        title: item.harvestMethod,
                        subtitle: item.harvestTime,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(HarvestStatus status, bool isDark) {
    switch (status) {
      case HarvestStatus.menunggu:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF332714) : WarnaAplikasi.warningOrangeBgLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF5E4520) : WarnaAplikasi.warningOrangeBorderLight,
              width: 0.8,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sync_rounded,
                size: 13,
                color: WarnaAplikasi.warningOrange,
              ),
              SizedBox(width: 4),
              Text(
                'Menunggu\nVerifikasi',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: WarnaAplikasi.warningOrange,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      case HarvestStatus.disetujui:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E3324) : WarnaAplikasi.approvedGreenBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF285438) : WarnaAplikasi.approvedGreenBorder,
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_rounded,
                size: 13,
                color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.approvedGreen,
              ),
              const SizedBox(width: 4),
              Text(
                'Disetujui',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.approvedGreen,
                ),
              ),
            ],
          ),
        );
      case HarvestStatus.ditolak:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF3B1F23) : WarnaAplikasi.rejectedRedBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF6B2D35) : WarnaAplikasi.rejectedRedBorder,
              width: 0.8,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.close_rounded,
                size: 13,
                color: Colors.redAccent,
              ),
              SizedBox(width: 4),
              Text(
                'Ditolak',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildDetailCell({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool isBoldTitle = false,
    bool isDark = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            icon,
            size: 14,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isBoldTitle ? FontWeight.w700 : FontWeight.w600,
                  color: isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDarkGreenDeep,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10.5,
                  color: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatNumber(double number) {
    final intVal = number.toInt();
    // format Indonesian dot separator: 4850 -> 4.850
    final str = intVal.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

