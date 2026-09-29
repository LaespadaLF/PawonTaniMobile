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

    // Main curved stem 1
    final path1 = Path();
    path1.moveTo(size.width * 0.22, size.height * 0.88);
    path1.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.45,
      size.width * 0.75,
      size.height * 0.35,
    );
    canvas.drawPath(path1, strokePaint);

    // Grains on stalk 1
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

    // Stem 2
    final path2 = Path();
    path2.moveTo(size.width * 0.32, size.height * 0.88);
    path2.quadraticBezierTo(
      size.width * 0.45,
      size.height * 0.55,
      size.width * 0.82,
      size.height * 0.50,
    );
    canvas.drawPath(path2, strokePaint);

    // Grains on stalk 2
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

    // Green husk leaf
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

    // Corn body (tilted oval)
    canvas.save();
    canvas.translate(size.width * 0.55, size.height * 0.50);
    canvas.rotate(-0.4);

    final cornRect = Rect.fromCenter(center: Offset.zero, width: size.width * 0.32, height: size.height * 0.55);
    final rrect = RRect.fromRectAndRadius(cornRect, Radius.circular(size.width * 0.15));
    canvas.drawRRect(rrect, cornPaint);

    // Corn kernels grid lines
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

    // Left leaf
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

    // Right leaf
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

  const PawonTaniLogo({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF2C6B46),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          Icons.energy_savings_leaf_rounded,
          color: Colors.white,
          size: size * 0.62,
        ),
      ),
    );
  }
}

