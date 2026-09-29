import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:flutter/material.dart';
import 'package:pawon_mobile/core/widgets/ikon_tanaman_kustom.dart';

class HarvestSummaryCard extends StatelessWidget {
  final double totalTon;
  final double padiTon;
  final double jagungTon;
  final String seasonName;

  const HarvestSummaryCard({
    super.key,
    required this.totalTon,
    required this.padiTon,
    required this.jagungTon,
    this.seasonName = 'Musim Tanam 2024',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEDF6F0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: WarnaAplikasi.greenPill,
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
              opacity: 0.6,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Hasil Panen',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5A7263),
                        letterSpacing: -0.2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDEEE3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFCCE4D4),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            size: 13,
                            color: WarnaAplikasi.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            seasonName,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: WarnaAplikasi.primary,
                            ),
                          ),
                        ],
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
                        text: totalTon.toStringAsFixed(1).replaceAll('.', ','),
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: WarnaAplikasi.primaryDark,
                          letterSpacing: -1.0,
                          height: 1.1,
                        ),
                      ),
                      const TextSpan(
                        text: ' Ton',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: WarnaAplikasi.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Sub-breakdown: Padi & Jagung
                Row(
                  children: [
                    // Padi
                    const Icon(
                      Icons.grass_rounded,
                      size: 15,
                      color: Color(0xFF488458),
                    ),
                    const SizedBox(width: 5),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Padi: ',
                            style: TextStyle(
                              fontSize: 12,
                              color: WarnaAplikasi.textGray,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: '${padiTon.toStringAsFixed(2).replaceAll('.', ',')} Ton',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1B2B20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      width: 1,
                      height: 12,
                      color: const Color(0xFFC3D8CA),
                    ),
                    const SizedBox(width: 14),

                    // Jagung
                    const Icon(
                      Icons.bolt_rounded,
                      size: 15,
                      color: Color(0xFFE59015),
                    ),
                    const SizedBox(width: 5),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Jagung: ',
                            style: TextStyle(
                              fontSize: 12,
                              color: WarnaAplikasi.textGray,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: '${jagungTon.toStringAsFixed(2).replaceAll('.', ',')} Ton',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1B2B20),
                            ),
                          ),
                        ],
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

