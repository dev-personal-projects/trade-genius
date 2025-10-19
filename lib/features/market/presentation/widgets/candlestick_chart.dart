// lib/features/market/presentation/widgets/candlestick_chart.dart
// Why: Responsive interactive candlestick chart with drawing tools

import 'package:flutter/material.dart';
import '../../domain/entities/candlestick.dart';
import '../../domain/entities/chart_drawing.dart';

class CandlestickChart extends StatefulWidget {
  final List<Candlestick> candles;
  final List<ChartDrawing> drawings;
  final Function(ChartDrawing) onDrawingAdded;
  final Function(ChartDrawing)? onDrawingMoved;
  final DrawingType? activeDrawingTool;

  const CandlestickChart({
    super.key,
    required this.candles,
    required this.drawings,
    required this.onDrawingAdded,
    this.onDrawingMoved,
    this.activeDrawingTool,
  });

  @override
  State<CandlestickChart> createState() => _CandlestickChartState();
}

class _CandlestickChartState extends State<CandlestickChart> {
  Offset? _drawStart;
  Offset? _drawEnd;
  double _minPrice = 0;
  double _maxPrice = 0;

  @override
  void initState() {
    super.initState();
    _calculatePriceRange();
  }

  @override
  void didUpdateWidget(CandlestickChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.candles != widget.candles) {
      _calculatePriceRange();
    }
  }

  void _calculatePriceRange() {
    if (widget.candles.isEmpty) return;
    _minPrice = widget.candles
        .map((c) => c.low)
        .reduce((a, b) => a < b ? a : b);
    _maxPrice = widget.candles
        .map((c) => c.high)
        .reduce((a, b) => a > b ? a : b);
    // Add 2% padding
    final padding = (_maxPrice - _minPrice) * 0.02;
    _minPrice -= padding;
    _maxPrice += padding;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.candles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartHeight =
            constraints.maxHeight - 40; // Reserve space for price labels
        final chartWidth =
            constraints.maxWidth - 80; // Reserve space for price axis

        return GestureDetector(
          onPanStart: widget.activeDrawingTool != null
              ? (details) => _onPanStart(details, chartWidth, chartHeight)
              : null,
          onPanUpdate: widget.activeDrawingTool != null
              ? (details) => _onPanUpdate(details, chartWidth, chartHeight)
              : null,
          onPanEnd: widget.activeDrawingTool != null ? _onPanEnd : null,
          child: Container(
            color: theme.scaffoldBackgroundColor,
            child: Stack(
              children: [
                // Price axis (right side)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 40,
                  width: 80,
                  child: _buildPriceAxis(theme, chartHeight),
                ),

                // Chart area
                Positioned(
                  left: 0,
                  top: 0,
                  right: 80,
                  bottom: 40,
                  child: Stack(
                    children: [
                      // Grid lines
                      CustomPaint(
                        size: Size(chartWidth, chartHeight),
                        painter: GridPainter(
                          minPrice: _minPrice,
                          maxPrice: _maxPrice,
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.1,
                          ),
                        ),
                      ),
                      // Candlesticks
                      CustomPaint(
                        size: Size(chartWidth, chartHeight),
                        painter: CandlestickPainter(
                          candles: widget.candles,
                          maxPrice: _maxPrice,
                          minPrice: _minPrice,
                        ),
                      ),
                      // User drawings
                      CustomPaint(
                        size: Size(chartWidth, chartHeight),
                        painter: DrawingsPainter(
                          drawings: widget.drawings,
                          maxPrice: _maxPrice,
                          minPrice: _minPrice,
                          candleCount: widget.candles.length,
                        ),
                      ),
                      // Drawing preview
                      if (_drawStart != null && _drawEnd != null)
                        CustomPaint(
                          size: Size(chartWidth, chartHeight),
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
                ),

                // Time axis (bottom)
                Positioned(
                  left: 0,
                  right: 80,
                  bottom: 0,
                  height: 40,
                  child: _buildTimeAxis(theme, chartWidth),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceAxis(ThemeData theme, double height) {
    final priceRange = _maxPrice - _minPrice;
    final steps = 5;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps + 1, (index) {
        final price = _maxPrice - (priceRange * index / steps);
        return Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            '\$${price.toStringAsFixed(2)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTimeAxis(ThemeData theme, double width) {
    if (widget.candles.isEmpty) return const SizedBox();

    final displayCount = 4;
    final step = widget.candles.length ~/ displayCount;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(displayCount, (index) {
        final candleIndex = index * step;
        if (candleIndex >= widget.candles.length) return const SizedBox();

        final candle = widget.candles[candleIndex];
        final time =
            '${candle.timestamp.hour}:${candle.timestamp.minute.toString().padLeft(2, '0')}';

        return Text(
          time,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        );
      }),
    );
  }

  void _onPanStart(DragStartDetails details, double width, double height) {
    final localPos = details.localPosition;
    if (localPos.dx >= 0 &&
        localPos.dx <= width &&
        localPos.dy >= 0 &&
        localPos.dy <= height) {
      setState(() => _drawStart = localPos);
    }
  }

  void _onPanUpdate(DragUpdateDetails details, double width, double height) {
    final localPos = details.localPosition;
    if (localPos.dx >= 0 &&
        localPos.dx <= width &&
        localPos.dy >= 0 &&
        localPos.dy <= height) {
      setState(() => _drawEnd = localPos);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_drawStart != null &&
        _drawEnd != null &&
        widget.activeDrawingTool != null) {
      // Convert screen Y to price
      final priceRange = _maxPrice - _minPrice;
      final startPrice =
          _maxPrice - (_drawStart!.dy / context.size!.height * priceRange);
      final endPrice =
          _maxPrice - (_drawEnd!.dy / context.size!.height * priceRange);

      final drawing = ChartDrawing(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: widget.activeDrawingTool!,
        startPrice: startPrice,
        endPrice: endPrice,
        startIndex:
            (_drawStart!.dx / context.size!.width * widget.candles.length)
                .toInt(),
        endIndex: (_drawEnd!.dx / context.size!.width * widget.candles.length)
            .toInt(),
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

// Grid painter
class GridPainter extends CustomPainter {
  final double minPrice;
  final double maxPrice;
  final Color color;

  GridPainter({
    required this.minPrice,
    required this.maxPrice,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    // Horizontal lines
    for (int i = 0; i <= 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertical lines
    for (int i = 0; i <= 4; i++) {
      final x = size.width * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Candlestick painter
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
    if (candles.isEmpty) return;

    final priceRange = maxPrice - minPrice;
    final candleWidth = size.width / candles.length;
    final bodyWidth = candleWidth * 0.6;

    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final x = i * candleWidth + candleWidth / 2;

      final openY =
          size.height - ((candle.open - minPrice) / priceRange * size.height);
      final closeY =
          size.height - ((candle.close - minPrice) / priceRange * size.height);
      final highY =
          size.height - ((candle.high - minPrice) / priceRange * size.height);
      final lowY =
          size.height - ((candle.low - minPrice) / priceRange * size.height);

      final color = candle.isBullish ? Colors.green : Colors.red;
      final paint = Paint()..color = color;

      // Draw wick
      canvas.drawLine(
        Offset(x, highY),
        Offset(x, lowY),
        paint..strokeWidth = 1.5,
      );

      // Draw body
      final bodyTop = candle.isBullish ? closeY : openY;
      final bodyBottom = candle.isBullish ? openY : closeY;
      final bodyHeight = (bodyBottom - bodyTop).abs();

      canvas.drawRect(
        Rect.fromLTWH(
          x - bodyWidth / 2,
          bodyTop,
          bodyWidth,
          bodyHeight.clamp(1.0, double.infinity), // Minimum 1px height
        ),
        paint..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Drawings painter
class DrawingsPainter extends CustomPainter {
  final List<ChartDrawing> drawings;
  final double maxPrice;
  final double minPrice;
  final int candleCount;

  DrawingsPainter({
    required this.drawings,
    required this.maxPrice,
    required this.minPrice,
    required this.candleCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final priceRange = maxPrice - minPrice;

    for (final drawing in drawings) {
      final startY =
          size.height -
          ((drawing.startPrice - minPrice) / priceRange * size.height);
      final endY =
          size.height -
          ((drawing.endPrice - minPrice) / priceRange * size.height);
      final startX = (drawing.startIndex / candleCount) * size.width;
      final endX = (drawing.endIndex / candleCount) * size.width;

      final color = _getDrawingColor(drawing.type);
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);

      // Draw label
      final textPainter = TextPainter(
        text: TextSpan(
          text: '\$${drawing.startPrice.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(startX + 5, startY - 15));
    }
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Drawing preview painter
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
      ..color = color.withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, end, paint);

    // Draw circles at endpoints
    canvas.drawCircle(start, 4, Paint()..color = color);
    canvas.drawCircle(end, 4, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
