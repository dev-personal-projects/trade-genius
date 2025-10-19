// lib/features/market/domain/entities/candlestick.dart
// Why: Represents OHLC (Open, High, Low, Close) data for candlestick charts

class Candlestick {
  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const Candlestick({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  // Check if candle is bullish (green)
  bool get isBullish => close >= open;

  // Candle body size
  double get bodySize => (close - open).abs();

  // Upper wick size
  double get upperWick => high - (isBullish ? close : open);

  // Lower wick size
  double get lowerWick => (isBullish ? open : close) - low;
}
