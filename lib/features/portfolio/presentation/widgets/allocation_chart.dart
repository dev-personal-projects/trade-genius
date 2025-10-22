// Why: Visual pie chart showing portfolio allocation by coin
// Flutter Concepts: CustomPaint, Canvas, GestureDetector
// UX: Interactive pie chart with tap to highlight

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/holding.dart';

class AllocationChart extends StatefulWidget {
  final List<Holding> holdings;

  const AllocationChart({
    super.key,
    required this.holdings,
  });

  @override
  State<AllocationChart> createState() => _AllocationChartState();
}

class _AllocationChartState extends State<AllocationChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.holdings.isEmpty) return const SizedBox.shrink();

    final totalValue = widget.holdings.fold(
      0.0,
          (sum, h) => sum + h.currentValue,
    );

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portfolio Allocation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),

            // Pie Chart
            Center(
              child: SizedBox(
                height: 200,
                width: 200,
                child: CustomPaint(
                  painter: _PieChartPainter(
                    holdings: widget.holdings,
                    totalValue: totalValue,
                    selectedIndex: _selectedIndex,
                  ),
                  child: GestureDetector(
                    onTapDown: (details) {
                      final index = _getSegmentIndex(
                        details.localPosition,
                        const Size(200, 200),
                      );
                      setState(() {
                        _selectedIndex = index == _selectedIndex ? null : index;
                      });
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Legend
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: List.generate(
                widget.holdings.length,
                    (index) {
                  final holding = widget.holdings[index];
                  final percentage = holding.allocationPercentage(totalValue);
                  final color = _getColor(index);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index == _selectedIndex ? null : index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedIndex == index
                            ? color.withOpacity(0.2)
                            : color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _selectedIndex == index
                              ? color
                              : color.withOpacity(0.3),
                          width: _selectedIndex == index ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${holding.symbol} ${percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _selectedIndex == index
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  int? _getSegmentIndex(Offset position, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);

    if (distance > size.width / 2) return null;

    var angle = math.atan2(dy, dx);
    if (angle < 0) angle += 2 * math.pi;

    final totalValue = widget.holdings.fold(0.0, (sum, h) => sum + h.currentValue);
    var currentAngle = -math.pi / 2;

    for (int i = 0; i < widget.holdings.length; i++) {
      final percentage = widget.holdings[i].allocationPercentage(totalValue);
      final sweepAngle = (percentage / 100) * 2 * math.pi;

      if (angle >= currentAngle && angle < currentAngle + sweepAngle) {
        return i;
      }

      currentAngle += sweepAngle;
    }

    return null;
  }

  Color _getColor(int index) {
    final colors = [
      AppColors.primary,
      AppColors.bullish,
      AppColors.bearish,
      AppColors.warning,
      const Color(0xFF9C27B0),
      const Color(0xFF00BCD4),
      const Color(0xFFFF5722),
      const Color(0xFF4CAF50),
    ];
    return colors[index % colors.length];
  }
}

class _PieChartPainter extends CustomPainter {
  final List<Holding> holdings;
  final double totalValue;
  final int? selectedIndex;

  _PieChartPainter({
    required this.holdings,
    required this.totalValue,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    var startAngle = -math.pi / 2;

    for (int i = 0; i < holdings.length; i++) {
      final holding = holdings[i];
      final percentage = holding.allocationPercentage(totalValue);
      final sweepAngle = (percentage / 100) * 2 * math.pi;

      final paint = Paint()
        ..color = _getColor(i).withOpacity(selectedIndex == i ? 1.0 : 0.8)
        ..style = PaintingStyle.fill;

      final rect = Rect.fromCircle(center: center, radius: radius);

      // Draw segment
      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      // Highlight selected
      if (selectedIndex == i) {
        final highlightPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius + 5),
          startAngle,
          sweepAngle,
          true,
          highlightPaint,
        );
      }

      startAngle += sweepAngle;
    }

    // Draw center circle (donut effect)
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.5, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  Color _getColor(int index) {
    final colors = [
      AppColors.primary,
      AppColors.bullish,
      AppColors.bearish,
      AppColors.warning,
      const Color(0xFF9C27B0),
      const Color(0xFF00BCD4),
      const Color(0xFFFF5722),
      const Color(0xFF4CAF50),
    ];
    return colors[index % colors.length];
  }
}
