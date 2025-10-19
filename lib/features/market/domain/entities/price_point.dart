
// lib/features/market/domain/entities/price_point.dart
// Why: Represents a single point in price history for charting

class PricePoint {
  final DateTime timestamp;
  final double price;

  const PricePoint({
    required this.timestamp,
    required this.price,
  });
}
