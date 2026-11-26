import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:flutter/material.dart';
import 'package:pawon_mobile/core/widgets/ikon_tanaman_kustom.dart';

class HarvestSummaryCard extends StatelessWidget {
  final double totalTon;
  final String seasonName;
  final Map<String, double> commodityBreakdown;

  const HarvestSummaryCard({
    super.key,
    required this.totalTon,
    required this.seasonName,
    this.commodityBreakdown = const {},
  });

  /// Format angka ton gaya Indonesia (koma desimal) tanpa nol di belakang koma.
  /// Nilai 0 / kosong ditampilkan sebagai "0" agar tidak muncul "0,00".
  static String formatTon(double value, {int decimals = 2}) {
    if (!value.isFinite || value <= 0) return '0';
    final teks = value.toStringAsFixed(decimals).replaceAll('.', ',');
    final tanpaNol = teks.replaceFirst(RegExp(r',?0+$'), '');
    return tanpaNol.isEmpty ? '0' : tanpaNol;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalText = formatTon(totalTon, decimals: 1);
    final badgeText =
        seasonName.trim().isEmpty ? 'Musim Tanam Berjalan' : seasonName.trim();

    final nonZeroBreakdown = commodityBreakdown.entries
        .where((e) => e.value > 0)
        .toList();

    final cardBg = isDark ? const Color(0xFF1D2420) : WarnaAplikasi.bgSuccessPale;
    final cardBorder = isDark ? const Color(0xFF28332C) : WarnaAplikasi.greenPill;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cardBorder,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Background decorative leaves watermark on right
          Positioned(
            right: 12,
            top: 24,
            bottom: 24,
            width: 90,
            child: Opacity(
              opacity: isDark ? 0.25 : 0.6,
              child: CustomPaint(
                painter: DecorativeLeavesPainter(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Title and Season Badge
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Total Hasil Panen',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGrayGreenMedium,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF243328) : WarnaAplikasi.seasonBadgeBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? const Color(0xFF2E4033) : WarnaAplikasi.seasonBadgeBorder,
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 13,
                              color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                badgeText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Main Stat: 12,8 Ton
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: totalText,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.primaryDark,
                          letterSpacing: -1.0,
                          height: 1.1,
                        ),
                      ),
                      TextSpan(
                        text: ' Ton',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Sub-breakdown: Dinamis berdasarkan komoditas aktual di hasil panen
                if (nonZeroBreakdown.isNotEmpty)
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 14,
                    runSpacing: 6,
                    children: nonZeroBreakdown.map((entry) {
                      final cName = entry.key;
                      final cTon = formatTon(entry.value);
                      final isJagung = cName.toLowerCase().contains('jagung');
                      final isPadi = cName.toLowerCase().contains('padi');

                      IconData icon = Icons.eco_rounded;
                      Color iconColor = isDark ? const Color(0xFF81C784) : WarnaAplikasi.primaryDark;

                      if (isJagung) {
                        icon = Icons.bolt_rounded;
                        iconColor = WarnaAplikasi.jagungAmber;
                      } else if (isPadi) {
                        icon = Icons.grass_rounded;
                        iconColor = isDark ? const Color(0xFF81C784) : WarnaAplikasi.padiGreenIcon;
                      }

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 15, color: iconColor),
                          const SizedBox(width: 5),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '$cName: ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(
                                  text: '$cTon Ton',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.textDarkGreenMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  )
                else
                  const Row(
                    children: [
                      Icon(Icons.eco_rounded, size: 14, color: WarnaAplikasi.grayGreenMuted),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Belum ada rincian komoditas',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11.5, color: WarnaAplikasi.textGray),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

