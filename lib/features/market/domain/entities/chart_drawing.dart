// lib/features/market/domain/entities/chart_drawing.dart
// Why: Represents user-drawn lines for technical analysis

enum DrawingType {
  supportLine,
  resistanceLine,
  trendLine,
}

class ChartDrawing {
  final String id;
  final DrawingType type;
  final double startPrice;
  final double endPrice;
  final int startIndex;
  final int endIndex;

  const ChartDrawing({
    required this.id,
    required this.type,
    required this.startPrice,
    required this.endPrice,
    required this.startIndex,
    required this.endIndex,
  });
}
