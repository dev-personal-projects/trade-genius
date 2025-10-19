// lib/features/market/domain/entities/crypto_coin.dart
// Why: Represents a cryptocurrency with all market data needed for display

class CryptoCoin {
  final String symbol;        // e.g., "BTC", "ETH"
  final String name;          // e.g., "Bitcoin", "Ethereum"
  final double currentPrice;  // Current price in USD
  final double priceChange24h; // 24h price change percentage
  final double volume24h;     // 24h trading volume
  final double marketCap;     // Market capitalization
  final double high24h;       // 24h high price
  final double low24h;        // 24h low price
  final int rank;             // Market cap ranking

  const CryptoCoin({
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.priceChange24h,
    required this.volume24h,
    required this.marketCap,
    required this.high24h,
    required this.low24h,
    required this.rank,
  });

  // Helper to check if price is going up
  bool get isPositiveChange => priceChange24h >= 0;

  // Format price with appropriate decimals
  String get formattedPrice {
    if (currentPrice >= 1) {
      return '\$${currentPrice.toStringAsFixed(2)}';
    }
    return '\$${currentPrice.toStringAsFixed(6)}';
  }

  // Format percentage change
  String get formattedChange {
    final sign = isPositiveChange ? '+' : '';
    return '$sign${priceChange24h.toStringAsFixed(2)}%';
  }
}
