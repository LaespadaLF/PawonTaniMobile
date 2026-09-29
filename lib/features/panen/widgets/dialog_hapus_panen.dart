import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:flutter/material.dart';
import 'package:pawon_mobile/features/panen/models/item_panen.dart';

class DeleteHarvestDialog extends StatelessWidget {
  final HarvestItem item;
  final VoidCallback onConfirmDelete;

  const DeleteHarvestDialog({
    super.key,
    required this.item,
    required this.onConfirmDelete,
  });

  static Future<bool?> show(
    BuildContext context, {
    required HarvestItem item,
    required VoidCallback onConfirmDelete,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => DeleteHarvestDialog(
        item: item,
        onConfirmDelete: onConfirmDelete,
      ),
    );
  }

  String _formatNumber(double number) {
    final intVal = number.toInt();
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

  @override
  Widget build(BuildContext context) {
    final harvestCode = item.harvestCode.isNotEmpty ? item.harvestCode : 'PN-202410-09';
    final weightStr = _formatNumber(item.weightKg);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top circular icon with red trash
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFFDE8E8),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Title
            const Text(
              'Hapus Data Panen Ini?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: WarnaAplikasi.primaryDark,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Description with bold highlights
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF556C5E),
                  height: 1.45,
                ),
                children: [
                  const TextSpan(text: 'Apakah Anda yakin ingin menghapus data panen '),
                  TextSpan(
                    text: '${item.title} (ID: $harvestCode)',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: WarnaAplikasi.primaryDark,
                    ),
                  ),
                  const TextSpan(text: ' dengan bobot '),
                  TextSpan(
                    text: '$weightStr Kg',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: WarnaAplikasi.primaryDark,
                    ),
                  ),
                  const TextSpan(text: '? Tindakan ini tidak dapat dibatalkan.'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Warning Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFFFD5D5),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_rounded,
                    color: Color(0xFFDC2626),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFB91C1C),
                          height: 1.35,
                        ),
                        children: [
                          const TextSpan(
                            text:
                                'Data riwayat bobot timbangan, foto bukti karung, dan surat jalan terkait di ',
                          ),
                          TextSpan(
                            text: item.poktan.isNotEmpty
                                ? item.poktan
                                : 'Poktan Sumber Makmur',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const TextSpan(text: ' akan terhapus permanen.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Red Primary Button: Ya, Hapus Data Panen
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context, true);
                  onConfirmDelete();
                },
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  'Ya, Hapus Data Panen',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Secondary Button: Batal / Kembali
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F2),
                  foregroundColor: const Color(0xFF3B5243),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Batal / Kembali',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

