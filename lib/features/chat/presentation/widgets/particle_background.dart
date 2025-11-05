import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';

class Particle {
  double x, y, vx, vy, size, opacity;
  Color color;
  
  Particle() :
    x = math.Random().nextDouble(),
    y = math.Random().nextDouble(),
    vx = (math.Random().nextDouble() - 0.5) * 0.002,
    vy = (math.Random().nextDouble() - 0.5) * 0.002,
    size = math.Random().nextDouble() * 3 + 1,
    opacity = math.Random().nextDouble() * 0.5 + 0.1,
    color = [AppColors.primary, AppColors.bullish, AppColors.warning]
        [math.Random().nextInt(3)];
  
  void update() {
    x += vx;
    y += vy;
    
    if (x < 0 || x > 1) vx *= -1;
    if (y < 0 || y > 1) vy *= -1;
    
    x = x.clamp(0.0, 1.0);
    y = y.clamp(0.0, 1.0);
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;
  
  ParticlePainter(this.particles, this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * 0.3)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
