import 'package:flutter/material.dart';
import '../models/harvest_item.dart';

class SaveSuccessDialog extends StatelessWidget {
  final HarvestItem item;
  final VoidCallback onViewDetail;
  final VoidCallback? onDownloadPdf;
  final VoidCallback onBackToList;

  const SaveSuccessDialog({
    super.key,
    required this.item,
    required this.onViewDetail,
    this.onDownloadPdf,
    required this.onBackToList,
  });

  static Future<void> show(
    BuildContext context, {
    required HarvestItem item,
    required VoidCallback onViewDetail,
    VoidCallback? onDownloadPdf,
    required VoidCallback onBackToList,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => SaveSuccessDialog(
        item: item,
        onViewDetail: onViewDetail,
        onDownloadPdf: onDownloadPdf,
        onBackToList: onBackToList,
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
    final harvestCode =
        item.harvestCode.isNotEmpty ? item.harvestCode : 'PN-202410-09';
    final weightStr = _formatNumber(item.weightKg);
    final tonStr = item.weightTon.toStringAsFixed(2).replaceAll('.', ',');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Stack(
        children: [
          // Close button ✕ at top right
          Positioned(
            top: 14,
            right: 14,
            child: InkWell(
              onTap: onBackToList,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: Color(0xFF708577),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top checkmark icon
                Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE2F4E7),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF388E52),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                const Text(
                  'Data Panen Berhasil Disimpan!',
                  style: TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF142419),
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Subtitle
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5A7264),
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(text: 'Pencatatan hasil panen '),
                      TextSpan(
                        text: '${item.title} ($weightStr Kg)',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF142419),
                        ),
                      ),
                      const TextSpan(
                        text:
                            ' telah tersimpan di sistem Lumbung Hasil Tani dan diteruskan ke Poktan untuk verifikasi.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Info Box Container
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF7F1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFD6EADB),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Row 1: No. Tiket / ID
                      _buildInfoRow(
                        icon: Icons.confirmation_number_outlined,
                        label: 'No. Tiket / ID',
                        valueWidget: Text(
                          harvestCode,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF15261B),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const Divider(color: Color(0xFFDCECE1), height: 16),

                      // Row 2: Total Bobot
                      _buildInfoRow(
                        icon: Icons.hourglass_bottom_rounded,
                        label: 'Total Bobot',
                        valueWidget: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '$weightStr Kg ',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF285438),
                                ),
                              ),
                              TextSpan(
                                text: '($tonStr Ton)',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF556C5E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(color: Color(0xFFDCECE1), height: 16),

                      // Row 3: Petak Lahan
                      _buildInfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Petak Lahan',
                        valueWidget: Text(
                          item.location.contains('Petak')
                              ? '${item.location.replaceAll('Petak ', '')} Blok A'
                              : item.location,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF15261B),
                          ),
                        ),
                      ),
                      const Divider(color: Color(0xFFDCECE1), height: 16),

                      // Row 4: Status
                      _buildInfoRow(
                        icon: Icons.hourglass_top_rounded,
                        label: 'Status',
                        valueWidget: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDEEFE4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '● ',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF285438),
                                ),
                              ),
                              Text(
                                'Menunggu Validasi Poktan',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF285438),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Primary Button: Lihat Detail Panen →
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: onViewDetail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF285438),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Lihat Detail Panen',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Button: Cetak / Unduh Bukti PDF
                InkWell(
                  onTap: onDownloadPdf,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xFF285438), width: 1.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf_outlined,
                            size: 14,
                            color: Color(0xFF285438),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Cetak / Unduh Bukti PDF',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF285438),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Text Button: Kembali ke Daftar Panen
                TextButton(
                  onPressed: onBackToList,
                  child: const Text(
                    'Kembali ke Daftar Panen',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5A7264),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required Widget valueWidget,
  }) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF556C5E)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            color: Color(0xFF556C5E),
          ),
        ),
        const Spacer(),
        valueWidget,
      ],
    );
  }
}
