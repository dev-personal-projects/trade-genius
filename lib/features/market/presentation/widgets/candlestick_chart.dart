// lib/features/market/presentation/widgets/candlestick_chart.dart
// Why: Interactive candlestick chart with drawing tools

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../market/domain/entities/candlestick.dart';
import '../../../market/domain/entities/chart_drawing.dart';

class CandlestickChart extends StatefulWidget {
  final List<Candlestick> candles;
  final List<ChartDrawing> drawings;
  final Function(ChartDrawing) onDrawingAdded;
  final DrawingType? activeDrawingTool;

  const CandlestickChart({
    super.key,
    required this.candles,
    required this.drawings,
    required this.onDrawingAdded,
    this.activeDrawingTool,
  });

  @override
  State<CandlestickChart> createState() => _CandlestickChartState();
}

class _CandlestickChartState extends State<CandlestickChart> {
  Offset? _drawStart;
  Offset? _drawEnd;

  @override
  Widget build(BuildContext context) {
    if (widget.candles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final theme = Theme.of(context);
    final maxPrice = widget.candles.map((c) => c.high).reduce((a, b) => a > b ? a : b);
    final minPrice = widget.candles.map((c) => c.low).reduce((a, b) => a < b ? a : b);

    return GestureDetector(
      onPanStart: widget.activeDrawingTool != null ? _onPanStart : null,
      onPanUpdate: widget.activeDrawingTool != null ? _onPanUpdate : null,
      onPanEnd: widget.activeDrawingTool != null ? _onPanEnd : null,
      child: Stack(
        children: [
          LineChart(
            LineChartData(
              minY: minPrice * 0.99,
              maxY: maxPrice * 1.01,
              minX: 0,
              maxX: widget.candles.length.toDouble() - 1,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: (maxPrice - minPrice) / 5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '\$${value.toStringAsFixed(2)}',
                        style: theme.textTheme.bodySmall,
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [],
              extraLinesData: ExtraLinesData(
                horizontalLines: widget.drawings.map((drawing) {
                  return HorizontalLine(
                    y: drawing.startPrice,
                    color: _getDrawingColor(drawing.type),
                    strokeWidth: 2,
                    dashArray: [5, 5],
                  );
                }).toList(),
              ),
            ),
          ),
          // Candlesticks overlay
          CustomPaint(
            size: Size.infinite,
            painter: CandlestickPainter(
              candles: widget.candles,
              maxPrice: maxPrice,
              minPrice: minPrice,
            ),
          ),
          // Drawing preview
          if (_drawStart != null && _drawEnd != null)
            CustomPaint(
              size: Size.infinite,
              painter: DrawingPreviewPainter(
                start: _drawStart!,
                end: _drawEnd!,
                color: widget.activeDrawingTool != null
                    ? _getDrawingColor(widget.activeDrawingTool!)
                    : Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _drawStart = details.localPosition;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _drawEnd = details.localPosition;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_drawStart != null && _drawEnd != null && widget.activeDrawingTool != null) {
      // Convert screen coordinates to chart data
      final drawing = ChartDrawing(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: widget.activeDrawingTool!,
        startPrice: _drawStart!.dy,
        endPrice: _drawEnd!.dy,
        startIndex: _drawStart!.dx.toInt(),
        endIndex: _drawEnd!.dx.toInt(),
      );
      widget.onDrawingAdded(drawing);
    }
    setState(() {
      _drawStart = null;
      _drawEnd = null;
    });
  }

  Color _getDrawingColor(DrawingType type) {
    switch (type) {
      case DrawingType.supportLine:
        return Colors.green;
      case DrawingType.resistanceLine:
        return Colors.red;
      case DrawingType.trendLine:
        return Colors.blue;
    }
  }
}

// Custom painter for candlesticks
class CandlestickPainter extends CustomPainter {
  final List<Candlestick> candles;
  final double maxPrice;
  final double minPrice;

  CandlestickPainter({
    required this.candles,
    required this.maxPrice,
    required this.minPrice,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final priceRange = maxPrice - minPrice;
    final candleWidth = size.width / candles.length;

    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final x = i * candleWidth + candleWidth / 2;

      final openY = size.height - ((candle.open - minPrice) / priceRange * size.height);
      final closeY = size.height - ((candle.close - minPrice) / priceRange * size.height);
      final highY = size.height - ((candle.high - minPrice) / priceRange * size.height);
      final lowY = size.height - ((candle.low - minPrice) / priceRange * size.height);

      final color = candle.isBullish ? Colors.green : Colors.red;
      final paint = Paint()..color = color;

      // Draw wick
      canvas.drawLine(
        Offset(x, highY),
        Offset(x, lowY),
        paint..strokeWidth = 1,
      );

      // Draw body
      final bodyTop = candle.isBullish ? closeY : openY;
      final bodyBottom = candle.isBullish ? openY : closeY;
      canvas.drawRect(
        Rect.fromLTRB(
          x - candleWidth * 0.3,
          bodyTop,
          x + candleWidth * 0.3,
          bodyBottom,
        ),
        paint..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom painter for drawing preview
class DrawingPreviewPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;

  DrawingPreviewPainter({
    required this.start,
    required this.end,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
