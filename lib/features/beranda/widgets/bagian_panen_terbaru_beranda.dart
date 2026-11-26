import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:flutter/material.dart';

class HomeLatestHarvestSection extends StatelessWidget {
  final VoidCallback? onAllTap;
  final VoidCallback? onItemTap;

  const HomeLatestHarvestSection({
    super.key,
    this.onAllTap,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerColor = isDark ? Colors.white : WarnaAplikasi.primaryDark;
    final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
    final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.borderPale;
    final titleTextColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.primaryDark;
    final subtitleTextColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray;
    final pillBg = isDark ? const Color(0xFF2D3B31) : WarnaAplikasi.hppAmberBg;
    final pillTextColor = isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hasil Panen Terbaru',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: headerColor,
              ),
            ),
            InkWell(
              onTap: onAllTap,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'Lihat semua >',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: WarnaAplikasi.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Harvest Item Card
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onItemTap,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    // Chili Pepper Image Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 58,
                        height: 58,
                        color: isDark ? const Color(0xFF283A2E) : WarnaAplikasi.nearBlack,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=200&auto=format&fit=crop&q=80',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const CustomPaint(
                                  painter: _ChiliPainter(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Information
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cabai Merah',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: subtitleTextColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '500 kg',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: titleTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: pillBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Siap dijual',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: pillTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Chevron
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: subtitleTextColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChiliPainter extends CustomPainter {
  const _ChiliPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Dark background
    final bgPaint = Paint()..color = const Color(0xFF23120C);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final center = Offset(size.width * 0.5, size.height * 0.5);

    // Red chili outer ring
    final outerRingPaint = Paint()
      ..color = WarnaAplikasi.errorRedBright
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.22;
    canvas.drawCircle(center, size.width * 0.3, outerRingPaint);

    // Red inner flesh
    final innerPaint = Paint()
      ..color = WarnaAplikasi.errorRedBright
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width * 0.22, innerPaint);

    // Center seed cluster (pale yellow)
    final corePaint = Paint()
      ..color = WarnaAplikasi.hppAmberBorder
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width * 0.1, corePaint);

    // Seeds dots
    final seedPaint = Paint()
      ..color = const Color(0xFFFDE047)
      ..style = PaintingStyle.fill;
    final seedOffsets = [
      Offset(center.dx - 4, center.dy - 4),
      Offset(center.dx + 4, center.dy - 3),
      Offset(center.dx - 3, center.dy + 4),
      Offset(center.dx + 4, center.dy + 4),
    ];
    for (final pt in seedOffsets) {
      canvas.drawCircle(pt, 1.8, seedPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
