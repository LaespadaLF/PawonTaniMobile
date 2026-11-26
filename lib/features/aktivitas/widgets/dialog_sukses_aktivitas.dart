import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:flutter/material.dart';
import 'package:pawon_mobile/features/aktivitas/models/item_aktivitas_tanam.dart';

class ActivitySuccessDialog extends StatelessWidget {
  final PlantActivityItem item;
  final VoidCallback onGoToHistory;
  final VoidCallback onBackToList;

  const ActivitySuccessDialog({
    super.key,
    required this.item,
    required this.onGoToHistory,
    required this.onBackToList,
  });

  static Future<void> show(
    BuildContext context, {
    required PlantActivityItem item,
    required VoidCallback onGoToHistory,
    required VoidCallback onBackToList,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ActivitySuccessDialog(
        item: item,
        onGoToHistory: onGoToHistory,
        onBackToList: onBackToList,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF1D2420) : Colors.white;
    final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.primaryDark;
    final subtitleColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray;
    final boxBg = isDark ? const Color(0xFF141916) : WarnaAplikasi.bgInput;
    final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.borderPale;
    final closeBtnBg = isDark ? const Color(0xFF283A2E) : WarnaAplikasi.bgPaleGreen;
    final closeIconColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGrayMedium;

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close Button Top Right
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: onBackToList,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: closeBtnBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: closeIconColor,
                  ),
                ),
              ),
            ),

            // Big Green Checkmark
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF243328) : WarnaAplikasi.bgSuccessLight2,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Aktivitas Berhasil Disimpan!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Pencatatan aktivitas ${item.title} ${item.cropName} telah berhasil diperbarui dan tersimpan ke riwayat petak lahan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: subtitleColor,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),

            // Summary Info Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: boxBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(context, 'Lahan', item.location),
                  Divider(height: 16, color: borderColor),
                  _buildSummaryRow(context, 'Jenis Aktivitas', '${item.title} (${item.cropName})'),
                  Divider(height: 16, color: borderColor),
                  _buildSummaryRow(context, 'Tanggal & Waktu', '${item.date}, ${item.time}'),
                  Divider(height: 16, color: borderColor),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kondisi Tanaman',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGrayGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: item.condition == PlantCondition.sehat
                              ? (isDark ? const Color(0xFF283A2E) : WarnaAplikasi.bgSuccessLight2)
                              : item.condition == PlantCondition.perluPerhatian
                                  ? (isDark ? const Color(0xFF3E2E18) : WarnaAplikasi.warningOrangeBg)
                                  : (isDark ? const Color(0xFF3E1E1E) : WarnaAplikasi.errorRedBg),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          item.condition.badgeText,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: item.condition == PlantCondition.sehat
                                ? (isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary)
                                : item.condition == PlantCondition.perluPerhatian
                                    ? (isDark ? Colors.amber.shade300 : WarnaAplikasi.warningOrange)
                                    : (isDark ? Colors.redAccent.shade100 : WarnaAplikasi.errorRedDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Primary Action Button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: onGoToHistory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: WarnaAplikasi.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Lihat Riwayat Aktivitas',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Secondary Action Button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: onBackToList,
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary,
                  side: BorderSide(
                    color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary,
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Kembali ke Daftar Aktivitas',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGrayGreen,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.primaryDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

