import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:flutter/material.dart';
import 'package:pawon_mobile/features/panen/models/item_panen.dart';

class CropIconWidget extends StatelessWidget {
  final CropType cropType;
  final double size;

  const CropIconWidget({
    super.key,
    required this.cropType,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    if (cropType == CropType.padi) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF6E833C),
          borderRadius: BorderRadius.circular(14),
        ),
        child: CustomPaint(
          size: Size(size, size),
          painter: _PadiPainter(),
        ),
      );
    } else {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF285430),
          borderRadius: BorderRadius.circular(14),
        ),
        child: CustomPaint(
          size: Size(size, size),
          painter: _CornPainter(),
        ),
      );
    }
  }
}

class _PadiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = const Color(0xFFFACC15)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = const Color(0xFFEAB308)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(size.width * 0.22, size.height * 0.88);
    path1.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.45,
      size.width * 0.75,
      size.height * 0.35,
    );
    canvas.drawPath(path1, strokePaint);

    final grainCenters1 = [
      Offset(size.width * 0.45, size.height * 0.48),
      Offset(size.width * 0.58, size.height * 0.40),
      Offset(size.width * 0.70, size.height * 0.36),
    ];
    for (final pt in grainCenters1) {
      canvas.drawOval(
        Rect.fromCenter(center: pt, width: 4.5, height: 7.5),
        fillPaint,
      );
    }

    final path2 = Path();
    path2.moveTo(size.width * 0.32, size.height * 0.88);
    path2.quadraticBezierTo(
      size.width * 0.45,
      size.height * 0.55,
      size.width * 0.82,
      size.height * 0.50,
    );
    canvas.drawPath(path2, strokePaint);

    final grainCenters2 = [
      Offset(size.width * 0.55, size.height * 0.60),
      Offset(size.width * 0.68, size.height * 0.54),
      Offset(size.width * 0.79, size.height * 0.51),
    ];
    for (final pt in grainCenters2) {
      canvas.drawOval(
        Rect.fromCenter(center: pt, width: 4.5, height: 7.5),
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CornPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cornPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;

    final leafPaint = Paint()
      ..color = const Color(0xFF84CC16)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = WarnaAplikasi.warningOrange
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final leafPath = Path();
    leafPath.moveTo(size.width * 0.28, size.height * 0.78);
    leafPath.quadraticBezierTo(
      size.width * 0.18,
      size.height * 0.50,
      size.width * 0.40,
      size.height * 0.30,
    );
    leafPath.quadraticBezierTo(
      size.width * 0.32,
      size.height * 0.60,
      size.width * 0.35,
      size.height * 0.78,
    );
    leafPath.close();
    canvas.drawPath(leafPath, leafPaint);

    canvas.save();
    canvas.translate(size.width * 0.55, size.height * 0.50);
    canvas.rotate(-0.4);

    final cornRect = Rect.fromCenter(center: Offset.zero, width: size.width * 0.32, height: size.height * 0.55);
    final rrect = RRect.fromRectAndRadius(cornRect, Radius.circular(size.width * 0.15));
    canvas.drawRRect(rrect, cornPaint);

    canvas.drawLine(
      Offset(-cornRect.width * 0.25, -cornRect.height * 0.2),
      Offset(-cornRect.width * 0.25, cornRect.height * 0.2),
      linePaint,
    );
    canvas.drawLine(
      Offset(cornRect.width * 0.25, -cornRect.height * 0.2),
      Offset(cornRect.width * 0.25, cornRect.height * 0.2),
      linePaint,
    );
    canvas.drawLine(
      Offset(-cornRect.width * 0.4, 0),
      Offset(cornRect.width * 0.4, 0),
      linePaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DecorativeLeavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final leafPaint = Paint()
      ..color = const Color(0xD9BFE0CD)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(size.width * 0.35, size.height * 0.95);
    path1.cubicTo(
      size.width * 0.05,
      size.height * 0.65,
      size.width * 0.10,
      size.height * 0.20,
      size.width * 0.30,
      size.height * 0.05,
    );
    path1.cubicTo(
      size.width * 0.55,
      size.height * 0.30,
      size.width * 0.50,
      size.height * 0.75,
      size.width * 0.35,
      size.height * 0.95,
    );
    path1.close();
    canvas.drawPath(path1, leafPaint);

    final path2 = Path();
    path2.moveTo(size.width * 0.45, size.height * 0.95);
    path2.cubicTo(
      size.width * 0.65,
      size.height * 0.60,
      size.width * 0.85,
      size.height * 0.35,
      size.width * 0.95,
      size.height * 0.15,
    );
    path2.cubicTo(
      size.width * 0.98,
      size.height * 0.55,
      size.width * 0.80,
      size.height * 0.85,
      size.width * 0.45,
      size.height * 0.95,
    );
    path2.close();
    canvas.drawPath(path2, leafPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PawonTaniLogo extends StatelessWidget {
  final double size;

  const PawonTaniLogo({super.key, this.size = 30});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        'assets/images/logo_pawontani.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: WarnaAplikasi.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                Icons.eco_rounded,
                color: Colors.white,
                size: size * 0.65,
              ),
            ),
          );
        },
      ),
    );
  }
}

class PawonTaniBrand extends StatelessWidget {
  final double logoSize;
  final double fontSize;
  final Color textColor;

  const PawonTaniBrand({
    super.key,
    this.logoSize = 30,
    this.fontSize = 18,
    this.textColor = WarnaAplikasi.primaryDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PawonTaniLogo(size: logoSize),
        const SizedBox(width: 10),
        Text(
          'PawonTani',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}

/// Header Atas Konsisten & Fixed untuk Layar Fitur (Lahan, Aktivitas, Panen, Penjualan)
class PawonFixedHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final bool showNotificationBadge;

  const PawonFixedHeader({
    super.key,
    required this.title,
    this.onNotificationTap,
    this.onProfileTap,
    this.showNotificationBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
      child: Row(
        children: [
          // Logo Image Asset
          const PawonTaniLogo(size: 32),
          const SizedBox(width: 10),
          // Sub-header Brand & Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'PAWON TANI',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: WarnaAplikasi.primary,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: WarnaAplikasi.primaryDark,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Action Icons: Notifikasi (Style Penjualan)
          InkWell(
            onTap: onNotificationTap ?? () {},
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F7F4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    size: 20,
                    color: Color(0xFF52685B),
                  ),
                ),
                if (showNotificationBadge)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE53935),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Profile Icon (Style Penjualan)
          InkWell(
            onTap: onProfileTap ?? () {},
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F7F4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 20,
                color: Color(0xFF52685B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

