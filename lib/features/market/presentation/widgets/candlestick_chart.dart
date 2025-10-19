// lib/features/market/presentation/widgets/candlestick_chart.dart
// Why: Interactive chart with zoom, pan, movable drawings, and volume bars

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
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _previousOffset = Offset.zero;
  
  Offset? _drawStart;
  Offset? _drawEnd;
  ChartDrawing? _selectedDrawing;
  Offset? _dragStart;
  
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
    _minPrice = widget.candles.map((c) => c.low).reduce((a, b) => a < b ? a : b);
    _maxPrice = widget.candles.map((c) => c.high).reduce((a, b) => a > b ? a : b);
    final padding = (_maxPrice - _minPrice) * 0.05;
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
        final volumeHeight = 60.0;
        final chartHeight = constraints.maxHeight - volumeHeight - 40;
        final chartWidth = constraints.maxWidth - 80;

        return GestureDetector(
          onScaleStart: _onScaleStart,
          onScaleUpdate: (details) => _onScaleUpdate(details, chartWidth, chartHeight),
          onScaleEnd: _onScaleEnd,
          onTapDown: (details) => _onTapDown(details, chartWidth, chartHeight),
          child: Container(
            color: theme.scaffoldBackgroundColor,
            child: Stack(
              children: [
                // Price axis
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: volumeHeight + 40,
                  width: 80,
                  child: _buildPriceAxis(theme, chartHeight),
                ),
                
                // Chart area with zoom/pan
                Positioned(
                  left: 0,
                  top: 0,
                  right: 80,
                  bottom: volumeHeight + 40,
                  child: ClipRect(
                    child: Transform(
                      transform: Matrix4.identity()
                        ..translate(_offset.dx, 0.0)
                        ..scale(_scale, 1.0),
                      child: Stack(
                        children: [
                          CustomPaint(
                            size: Size(chartWidth, chartHeight),
                            painter: GridPainter(
                              minPrice: _minPrice,
                              maxPrice: _maxPrice,
                              color: theme.colorScheme.outline.withValues(alpha: 0.1),
                            ),
                          ),
                          CustomPaint(
                            size: Size(chartWidth, chartHeight),
                            painter: CandlestickPainter(
                              candles: widget.candles,
                              maxPrice: _maxPrice,
                              minPrice: _minPrice,
                            ),
                          ),
                          CustomPaint(
                            size: Size(chartWidth, chartHeight),
                            painter: DrawingsPainter(
                              drawings: widget.drawings,
                              maxPrice: _maxPrice,
                              minPrice: _minPrice,
                              candleCount: widget.candles.length,
                              selectedDrawing: _selectedDrawing,
                            ),
                          ),
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
                  ),
                ),
                
                // Volume bars
                Positioned(
                  left: 0,
                  right: 80,
                  bottom: 40,
                  height: volumeHeight,
                  child: ClipRect(
                    child: Transform(
                      transform: Matrix4.identity()
                        ..translate(_offset.dx, 0.0)
                        ..scale(_scale, 1.0),
                      child: CustomPaint(
                        size: Size(chartWidth, volumeHeight),
                        painter: VolumePainter(candles: widget.candles),
                      ),
                    ),
                  ),
                ),
                
                // Time axis
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
        final time = '${candle.timestamp.hour}:${candle.timestamp.minute.toString().padLeft(2, '0')}';
        
        return Text(
          time,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        );
      }),
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    _previousScale = _scale;
    _previousOffset = _offset;
    _dragStart = details.localFocalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails details, double width, double height) {
    if (widget.activeDrawingTool != null) {
      // Drawing mode
      final localPos = Offset(
        (details.localFocalPoint.dx - _offset.dx) / _scale,
        details.localFocalPoint.dy,
      );
      
      if (_drawStart == null) {
        setState(() => _drawStart = localPos);
      } else {
        setState(() => _drawEnd = localPos);
      }
    } else if (_selectedDrawing != null && _dragStart != null) {
      // Move drawing mode
      final delta = details.localFocalPoint - _dragStart!;
      _dragStart = details.localFocalPoint;
      
      final priceRange = _maxPrice - _minPrice;
      final priceDelta = -(delta.dy / height) * priceRange;
      
      final movedDrawing = ChartDrawing(
        id: _selectedDrawing!.id,
        type: _selectedDrawing!.type,
        startPrice: _selectedDrawing!.startPrice + priceDelta,
        endPrice: _selectedDrawing!.endPrice + priceDelta,
        startIndex: _selectedDrawing!.startIndex,
        endIndex: _selectedDrawing!.endIndex,
      );
      
      widget.onDrawingMoved?.call(movedDrawing);
      setState(() => _selectedDrawing = movedDrawing);
    } else {
      // Zoom and pan mode
      setState(() {
        _scale = (_previousScale * details.scale).clamp(0.5, 3.0);
        
        if (details.scale == 1.0) {
          // Pure pan
          _offset = _previousOffset + (details.focalPoint - details.localFocalPoint);
        }
      });
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (widget.activeDrawingTool != null && _drawStart != null && _drawEnd != null) {
      final priceRange = _maxPrice - _minPrice;
      final startPrice = _maxPrice - (_drawStart!.dy / context.size!.height * priceRange);
      final endPrice = _maxPrice - (_drawEnd!.dy / context.size!.height * priceRange);
      
      final drawing = ChartDrawing(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: widget.activeDrawingTool!,
        startPrice: startPrice,
        endPrice: endPrice,
        startIndex: (_drawStart!.dx / (context.size!.width - 80) * widget.candles.length).toInt(),
        endIndex: (_drawEnd!.dx / (context.size!.width - 80) * widget.candles.length).toInt(),
      );
      
      widget.onDrawingAdded(drawing);
    }
    
    setState(() {
      _drawStart = null;
      _drawEnd = null;
      _selectedDrawing = null;
      _dragStart = null;
    });
  }

  void _onTapDown(TapDownDetails details, double width, double height) {
    if (widget.activeDrawingTool != null) return;
    
    final tapPos = Offset(
      (details.localPosition.dx - _offset.dx) / _scale,
      details.localPosition.dy,
    );
    final priceRange = _maxPrice - _minPrice;
    
    for (final drawing in widget.drawings) {
      final startY = height - ((drawing.startPrice - _minPrice) / priceRange * height);
      final endY = height - ((drawing.endPrice - _minPrice) / priceRange * height);
      
      if ((tapPos.dy - startY).abs() < 20 || (tapPos.dy - endY).abs() < 20) {
        setState(() => _selectedDrawing = drawing);
        return;
      }
    }
    
    setState(() => _selectedDrawing = null);
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

class VolumePainter extends CustomPainter {
  final List<Candlestick> candles;

  VolumePainter({required this.candles});

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;
    
    final maxVolume = candles.map((c) => c.volume).reduce((a, b) => a > b ? a : b);
    final candleWidth = size.width / candles.length;

    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final x = i * candleWidth;
      final barHeight = (candle.volume / maxVolume) * size.height;
      final color = candle.isBullish 
          ? Colors.green.withValues(alpha: 0.5)
          : Colors.red.withValues(alpha: 0.5);

      canvas.drawRect(
        Rect.fromLTWH(x, size.height - barHeight, candleWidth * 0.8, barHeight),
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GridPainter extends CustomPainter {
  final double minPrice;
  final double maxPrice;
  final Color color;

  GridPainter({required this.minPrice, required this.maxPrice, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1;
    for (int i = 0; i <= 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (int i = 0; i <= 4; i++) {
      final x = size.width * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CandlestickPainter extends CustomPainter {
  final List<Candlestick> candles;
  final double maxPrice;
  final double minPrice;

  CandlestickPainter({required this.candles, required this.maxPrice, required this.minPrice});

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;
    
    final priceRange = maxPrice - minPrice;
    final candleWidth = size.width / candles.length;
    final bodyWidth = candleWidth * 0.6;

    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final x = i * candleWidth + candleWidth / 2;
      
      final openY = size.height - ((candle.open - minPrice) / priceRange * size.height);
      final closeY = size.height - ((candle.close - minPrice) / priceRange * size.height);
      final highY = size.height - ((candle.high - minPrice) / priceRange * size.height);
      final lowY = size.height - ((candle.low - minPrice) / priceRange * size.height);

      final color = candle.isBullish ? Colors.green : Colors.red;
      final paint = Paint()..color = color;

      canvas.drawLine(Offset(x, highY), Offset(x, lowY), paint..strokeWidth = 1.5);

      final bodyTop = candle.isBullish ? closeY : openY;
      final bodyBottom = candle.isBullish ? openY : closeY;
      final bodyHeight = (bodyBottom - bodyTop).abs();
      
      canvas.drawRect(
        Rect.fromLTWH(x - bodyWidth / 2, bodyTop, bodyWidth, bodyHeight.clamp(1.0, double.infinity)),
        paint..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DrawingsPainter extends CustomPainter {
  final List<ChartDrawing> drawings;
  final double maxPrice;
  final double minPrice;
  final int candleCount;
  final ChartDrawing? selectedDrawing;

  DrawingsPainter({
    required this.drawings,
    required this.maxPrice,
    required this.minPrice,
    required this.candleCount,
    this.selectedDrawing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final priceRange = maxPrice - minPrice;

    for (final drawing in drawings) {
      final isSelected = drawing.id == selectedDrawing?.id;
      final startY = size.height - ((drawing.startPrice - minPrice) / priceRange * size.height);
      final endY = size.height - ((drawing.endPrice - minPrice) / priceRange * size.height);
      final startX = (drawing.startIndex / candleCount) * size.width;
      final endX = (drawing.endIndex / candleCount) * size.width;

      final color = _getDrawingColor(drawing.type);
      final paint = Paint()
        ..color = isSelected ? color : color.withValues(alpha: 0.7)
        ..strokeWidth = isSelected ? 3 : 2
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);

      if (isSelected) {
        canvas.drawCircle(Offset(startX, startY), 6, Paint()..color = color);
        canvas.drawCircle(Offset(endX, endY), 6, Paint()..color = color);
      }

      final textPainter = TextPainter(
        text: TextSpan(
          text: '\$${drawing.startPrice.toStringAsFixed(2)}',
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
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

class DrawingPreviewPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;

  DrawingPreviewPainter({required this.start, required this.end, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.7)..strokeWidth = 2..style = PaintingStyle.stroke;
    canvas.drawLine(start, end, paint);
    canvas.drawCircle(start, 4, Paint()..color = color);
    canvas.drawCircle(end, 4, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
