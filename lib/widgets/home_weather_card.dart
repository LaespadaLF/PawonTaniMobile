import 'package:flutter/material.dart';

class HomeWeatherCard extends StatelessWidget {
  final VoidCallback? onTap;

  const HomeWeatherCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE8EFEA),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Cuaca Hari Ini',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF162A1D),
            ),
          ),
          const SizedBox(height: 10),

          // Weather Content Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Weather graphic (Sun behind cloud)
              const SizedBox(
                width: 40,
                height: 36,
                child: CustomPaint(
                  painter: _SunCloudWeatherPainter(),
                ),
              ),
              const SizedBox(width: 10),

              // Temperature
              const Text(
                '28°C',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF162A1D),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 10),

              // Condition & Location
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Cerah Berawan',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF162A1D),
                        height: 1.15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: const [
                        Icon(
                          Icons.location_on_outlined,
                          size: 11,
                          color: Color(0xFF718679),
                        ),
                        SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            'Lahan Sukamaju',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF718679),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),

              // Action button
              InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF5EE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Lihat detail',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF285438),
                        ),
                      ),
                      SizedBox(width: 3),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 14,
                        color: Color(0xFF285438),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SunCloudWeatherPainter extends CustomPainter {
  const _SunCloudWeatherPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Sun (golden yellow with glowing aura)
    final sunCenter = Offset(size.width * 0.38, size.height * 0.42);
    final sunRadius = size.height * 0.32;

    final sunPaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(sunCenter, sunRadius, sunPaint);

    // Sun rays subtle highlight
    final sunHaloPaint = Paint()
      ..color = const Color(0x80FDE68A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(sunCenter, sunRadius + 2.5, sunHaloPaint);

    // Re-draw sun core over halo
    canvas.drawCircle(sunCenter, sunRadius, sunPaint);

    // Cute Soft Cloud in front of the sun
    final cloudPaint = Paint()
      ..color = const Color(0xFF93C5FD)
      ..style = PaintingStyle.fill;

    final cloudPath = Path();
    // Base oval
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.28,
        size.height * 0.48,
        size.width * 0.65,
        size.height * 0.42,
      ),
      Radius.circular(size.height * 0.21),
    );
    cloudPath.addRRect(baseRect);

    // Left puff
    cloudPath.addOval(
      Rect.fromCircle(
        center: Offset(size.width * 0.48, size.height * 0.52),
        radius: size.height * 0.22,
      ),
    );

    // Right puff
    cloudPath.addOval(
      Rect.fromCircle(
        center: Offset(size.width * 0.68, size.height * 0.48),
        radius: size.height * 0.26,
      ),
    );

    canvas.drawPath(cloudPath, cloudPaint);

    // Cloud highlight
    final cloudHighlightPaint = Paint()
      ..color = const Color(0xFFBAE6FD)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.66, size.height * 0.46),
      size.height * 0.18,
      cloudHighlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
