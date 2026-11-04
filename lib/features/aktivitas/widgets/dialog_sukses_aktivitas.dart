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
    return Dialog(
      backgroundColor: Colors.white,
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
                  decoration: const BoxDecoration(
                    color: WarnaAplikasi.bgPaleGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: WarnaAplikasi.textGrayMedium,
                  ),
                ),
              ),
            ),

            // Big Green Checkmark
            Container(
              width: 62,
              height: 62,
              decoration: const BoxDecoration(
                color: WarnaAplikasi.bgSuccessLight2,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.check_rounded,
                  color: WarnaAplikasi.primary,
                  size: 34,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'Aktivitas Berhasil Disimpan!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: WarnaAplikasi.primaryDark,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Pencatatan aktivitas ${item.title} ${item.cropName} telah berhasil diperbarui dan tersimpan ke riwayat petak lahan.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                color: WarnaAplikasi.textGray,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),

            // Summary Info Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: WarnaAplikasi.bgInput,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: WarnaAplikasi.borderPale,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Lahan', item.location),
                  const Divider(height: 16, color: WarnaAplikasi.divider),
                  _buildSummaryRow('Jenis Aktivitas', '${item.title} (${item.cropName})'),
                  const Divider(height: 16, color: WarnaAplikasi.divider),
                  _buildSummaryRow('Tanggal & Waktu', '${item.date}, ${item.time}'),
                  const Divider(height: 16, color: WarnaAplikasi.divider),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kondisi Tanaman',
                        style: TextStyle(
                          fontSize: 12,
                          color: WarnaAplikasi.textGrayGreen,
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
                              ? WarnaAplikasi.bgSuccessLight2
                              : item.condition == PlantCondition.perluPerhatian
                                  ? WarnaAplikasi.warningOrangeBg
                                  : WarnaAplikasi.errorRedBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          item.condition.badgeText,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: item.condition == PlantCondition.sehat
                                ? WarnaAplikasi.primary
                                : item.condition == PlantCondition.perluPerhatian
                                    ? WarnaAplikasi.warningOrange
                                    : WarnaAplikasi.errorRedDark,
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
                  foregroundColor: WarnaAplikasi.primary,
                  side: const BorderSide(
                    color: WarnaAplikasi.borderPale,
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

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: WarnaAplikasi.textGrayGreen,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: WarnaAplikasi.primaryDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

