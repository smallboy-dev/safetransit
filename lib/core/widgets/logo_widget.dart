import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'dart:math' as math;

class LogoWidget extends StatelessWidget {
  final double size;

  const LogoWidget({
    super.key,
    this.size = 112,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 64,
      height: size + 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer dashed ring - rotates slowly
          _DashedCircle(
            radius: (size / 2) + 16,
            color: AppTheme.primaryColor.withOpacity(0.3),
            isDashed: true,
          )
              .animate(onPlay: (controller) => controller.repeat())
              .rotate(duration: 20.seconds, begin: 0, end: 1),

          // Inner solid ring
          _DashedCircle(
            radius: (size / 2) + 32,
            color: AppTheme.primaryColor.withOpacity(0.1),
            isDashed: false,
          ),

          // Deep glow
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),

          // Core container
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.darkBackground,
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.25),
                  blurRadius: 32,
                  offset: const Offset(0, 0),
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryColor.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  LucideIcons.shield,
                  size: size * 0.5,
                  color: AppTheme.primaryColor,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Icon(
                    LucideIcons.trainFront,
                    size: size * 0.22,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ).animate().scale(
                duration: 600.ms,
                curve: Curves.easeOutBack,
              ),
        ],
      ),
    );
  }
}

class _DashedCircle extends StatelessWidget {
  final double radius;
  final Color color;
  final bool isDashed;

  const _DashedCircle({
    required this.radius,
    required this.color,
    required this.isDashed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(radius * 2, radius * 2),
      painter: _CirclePainter(
        color: color,
        isDashed: isDashed,
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final Color color;
  final bool isDashed;

  _CirclePainter({
    required this.color,
    required this.isDashed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    if (isDashed) {
      const dashWidth = 4.0;
      const dashSpace = 4.0;
      double startAngle = 0;
      const totalAngle = 2 * math.pi;

      while (startAngle < totalAngle) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          dashWidth / radius,
          false,
          paint,
        );
        startAngle += (dashWidth + dashSpace) / radius;
      }
    } else {
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
