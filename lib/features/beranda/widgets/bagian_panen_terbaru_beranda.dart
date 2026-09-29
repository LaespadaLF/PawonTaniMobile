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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Hasil Panen Terbaru',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: WarnaAplikasi.primaryDark,
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE8EFEA),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 8,
                offset: Offset(0, 2),
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
                        color: const Color(0xFF1A1A1A),
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
                          const Text(
                            'Cabai Merah',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: WarnaAplikasi.textGray,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '500 kg',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: WarnaAplikasi.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5F6EA),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Siap dijual',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: WarnaAplikasi.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Chevron
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: Color(0xFFB0C2B5),
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
      ..color = const Color(0xFFDC2626)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.22;
    canvas.drawCircle(center, size.width * 0.3, outerRingPaint);

    // Red inner flesh
    final innerPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width * 0.22, innerPaint);

    // Center seed cluster (pale yellow)
    final corePaint = Paint()
      ..color = const Color(0xFFFEF08A)
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
