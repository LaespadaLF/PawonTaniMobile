import 'package:flutter/material.dart';

class FarmerBannerCard extends StatelessWidget {
  final VoidCallback? onTap;

  const FarmerBannerCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 148,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3E7E4E),
            Color(0xFF5A9467),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18285438),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background soft circles decoration
          Positioned(
            right: -20,
            bottom: -30,
            child: Container(
              width: 170,
              height: 170,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x667BAE83),
              ),
            ),
          ),
          Positioned(
            right: 15,
            top: 10,
            child: Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x0FFFFFFF),
              ),
            ),
          ),

          // Right illustration of farmer
          Positioned(
            right: 12,
            bottom: 0,
            top: 0,
            width: 120,
            child: CustomPaint(
              painter: _FarmerIllustrationPainter(),
            ),
          ),

          // Left text content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Leaf icon
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0x33FFFFFF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.spa_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Headline
                  const Text(
                    'Semangat bertani,\nhasil terbaik menanti!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Subtitle
                  const Text(
                    'Pantau pertanianmu dengan lebih\nmudah.',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xE5FFFFFF),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FarmerIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width * 0.65;
    final bottomY = size.height;

    // Soft green background hill / circle
    final hillPaint = Paint()
      ..color = const Color(0xFF8FB98E)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, bottomY * 0.72), size.width * 0.46, hillPaint);

    // Farmer body / dark shirt
    final shirtPaint = Paint()
      ..color = const Color(0xFF273E2F)
      ..style = PaintingStyle.fill;
    final bodyPath = Path();
    bodyPath.moveTo(centerX - 24, bottomY);
    bodyPath.lineTo(centerX - 20, bottomY - 36);
    bodyPath.quadraticBezierTo(centerX, bottomY - 44, centerX + 20, bottomY - 36);
    bodyPath.lineTo(centerX + 24, bottomY);
    bodyPath.close();
    canvas.drawPath(bodyPath, shirtPaint);

    // Farmer head (round peach circle)
    final facePaint = Paint()
      ..color = const Color(0xFFF9C6B2)
      ..style = PaintingStyle.fill;
    final headCenter = Offset(centerX, bottomY - 50);
    canvas.drawCircle(headCenter, 14, facePaint);

    // Caping (conical straw hat - yellow triangle with slight flare)
    final hatPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;
    final hatPath = Path();
    hatPath.moveTo(centerX, bottomY - 76); // Peak
    hatPath.lineTo(centerX + 34, bottomY - 51); // Right rim
    hatPath.quadraticBezierTo(centerX, bottomY - 55, centerX - 34, bottomY - 51); // Rim curve
    hatPath.close();
    canvas.drawPath(hatPath, hatPaint);

    // Hat peak highlight/dot
    final hatTipPaint = Paint()
      ..color = const Color(0xFFD97706)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, bottomY - 74), 3, hatTipPaint);

    // Smartphone held in hand
    final phoneRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX + 2, bottomY - 14),
        width: 17,
        height: 28,
      ),
      const Radius.circular(3),
    );

    // Phone casing (dark gray)
    final phoneCasePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(phoneRect, phoneCasePaint);

    // Phone screen (bright cyan blue)
    final phoneScreenRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX + 2, bottomY - 14),
        width: 13,
        height: 22,
      ),
      const Radius.circular(2),
    );
    final screenPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(phoneScreenRect, screenPaint);

    // Farmer hands holding phone
    final handPaint = Paint()
      ..color = const Color(0xFFF9C6B2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX - 8, bottomY - 14), 4.5, handPaint);
    canvas.drawCircle(Offset(centerX + 12, bottomY - 14), 4.5, handPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
