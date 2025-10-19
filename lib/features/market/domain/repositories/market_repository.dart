// lib/features/market/domain/repositories/market_repository.dart
// Why: Defines contract for market data operations (abstraction for clean architecture)

import '../entities/crypto_coin.dart';
import '../entities/market_result.dart';
import '../entities/price_point.dart';
import '../entities/time_interval.dart';

abstract class MarketRepository {
  // Fetch top cryptocurrencies by market cap
  Future<MarketResult<List<CryptoCoin>>> getTopCoins({int limit = 50});

  // Search coins by name or symbol
  Future<MarketResult<List<CryptoCoin>>> searchCoins(String query);

  // Get trending coins (highest 24h volume or price change)
  Future<MarketResult<List<CryptoCoin>>> getTrendingCoins({int limit = 10});

  // Get price history for a specific coin
  Future<MarketResult<List<PricePoint>>> getPriceHistory({
    required String symbol,
    required TimeInterval interval,
  });

  // Stream real-time price updates for a coin
  Stream<double> streamPrice(String symbol);
}
