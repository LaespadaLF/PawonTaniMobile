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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: WarnaAplikasi.borderPale,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: WarnaAplikasi.shadowSubtle,
            blurRadius: 10,
            offset: Offset(0, 3),
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
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: WarnaAplikasi.nearBlack,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: WarnaAplikasi.textGrayGreenSoft,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(item.status),
                  ],
                ),
                const SizedBox(height: 12),

                // Divider line with subtle right chevron indicator
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    const Divider(
                      height: 1,
                      thickness: 0.8,
                      color: WarnaAplikasi.dividerLight,
                    ),
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.only(left: 6),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: WarnaAplikasi.grayGreenMuted,
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
                        iconColor: WarnaAplikasi.iconGrayGreenMid,
                        title: item.location,
                        subtitle: item.blockArea,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Col 2 Row 1: Date & Season
                    Expanded(
                      child: _buildDetailCell(
                        icon: Icons.calendar_today_outlined,
                        iconColor: WarnaAplikasi.iconGrayGreenMid,
                        title: item.date,
                        subtitle: item.season,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Col 1 Row 2: Weight
                    Expanded(
                      child: _buildDetailCell(
                        icon: Icons.scale_outlined,
                        iconColor: item.cropType == CropType.padi
                            ? WarnaAplikasi.padiGreen
                            : WarnaAplikasi.jagungAmber,
                        title: '${_formatNumber(item.weightKg)} Kg',
                        subtitle: '(${item.weightTon.toStringAsFixed(2)} Ton)',
                        isBoldTitle: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Col 2 Row 2: Quality & Notes
                    Expanded(
                      child: _buildDetailCell(
                        icon: Icons.verified_outlined,
                        iconColor: WarnaAplikasi.iconGrayGreenMid,
                        title: item.qualityGrade,
                        subtitle: item.moistureOrNotes,
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

  Widget _buildStatusBadge(HarvestStatus status) {
    switch (status) {
      case HarvestStatus.menunggu:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: WarnaAplikasi.warningOrangeBgLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: WarnaAplikasi.warningOrangeBorderLight,
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
            color: WarnaAplikasi.approvedGreenBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: WarnaAplikasi.approvedGreenBorder,
              width: 0.8,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_rounded,
                size: 13,
                color: WarnaAplikasi.approvedGreen,
              ),
              SizedBox(width: 4),
              Text(
                'Disetujui',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: WarnaAplikasi.approvedGreen,
                ),
              ),
            ],
          ),
        );
      case HarvestStatus.ditolak:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: WarnaAplikasi.rejectedRedBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: WarnaAplikasi.rejectedRedBorder,
              width: 0.8,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.close_rounded,
                size: 13,
                color: WarnaAplikasi.errorRedDark,
              ),
              SizedBox(width: 4),
              Text(
                'Ditolak',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: WarnaAplikasi.errorRedDark,
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
                  color: WarnaAplikasi.textDarkGreenDeep,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: WarnaAplikasi.textGray,
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

