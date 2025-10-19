// lib/features/market/domain/entities/time_interval.dart
// Why: Defines available time intervals for price charts

enum TimeInterval {
  hour24('24H', '1h'),    // 24 hours, 1 hour candles
  days7('7D', '4h'),      // 7 days, 4 hour candles
  days30('30D', '1d');    // 30 days, 1 day candles

  final String label;      // Display label
  final String binanceInterval; // Binance API interval code

  const TimeInterval(this.label, this.binanceInterval);
}