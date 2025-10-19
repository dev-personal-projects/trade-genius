// lib/features/market/data/repositories/market_repository_impl.dart
// Why: Implements repository interface with error handling

import '../../domain/entities/crypto_coin.dart';
import '../../domain/entities/market_result.dart';
import '../../domain/entities/price_point.dart';
import '../../domain/entities/time_interval.dart';
import '../../domain/repositories/market_repository.dart';
import '../datasources/binance_datasource.dart';

class MarketRepositoryImpl implements MarketRepository {
  final BinanceDatasource _datasource;

  MarketRepositoryImpl(this._datasource);

  @override
  Future<MarketResult<List<CryptoCoin>>> getTopCoins({int limit = 50}) async {
    try {
      final coins = await _datasource.getTopCoins(limit: limit);
      // Add rank based on position
      final rankedCoins = coins.asMap().entries.map((entry) {
        return CryptoCoin(
          symbol: entry.value.symbol,
          name: entry.value.name,
          currentPrice: entry.value.currentPrice,
          priceChange24h: entry.value.priceChange24h,
          volume24h: entry.value.volume24h,
          marketCap: entry.value.marketCap,
          high24h: entry.value.high24h,
          low24h: entry.value.low24h,
          rank: entry.key + 1,
        );
      }).toList();
      return MarketSuccess(rankedCoins);
    } catch (e) {
      return MarketFailure(e.toString());
    }
  }

  @override
  Future<MarketResult<List<CryptoCoin>>> searchCoins(String query) async {
    try {
      final coins = await _datasource.getTopCoins(limit: 100);
      final filtered = coins.where((coin) {
        final q = query.toLowerCase();
        return coin.symbol.toLowerCase().contains(q) ||
            coin.name.toLowerCase().contains(q);
      }).toList();
      return MarketSuccess(filtered);
    } catch (e) {
      return MarketFailure(e.toString());
    }
  }

  @override
  Future<MarketResult<List<CryptoCoin>>> getTrendingCoins({int limit = 10}) async {
    try {
      final coins = await _datasource.getTopCoins(limit: 50);
      // Sort by absolute price change percentage
      coins.sort((a, b) =>
          b.priceChange24h.abs().compareTo(a.priceChange24h.abs()));
      return MarketSuccess(coins.take(limit).toList());
    } catch (e) {
      return MarketFailure(e.toString());
    }
  }

  @override
  Future<MarketResult<List<PricePoint>>> getPriceHistory({
    required String symbol,
    required TimeInterval interval,
  }) async {
    try {
      final history = await _datasource.getPriceHistory(
        symbol: symbol,
        interval: interval,
      );
      return MarketSuccess(history);
    } catch (e) {
      return MarketFailure(e.toString());
    }
  }

  @override
  Stream<double> streamPrice(String symbol) {
    // Real-time price streaming via Binance WebSocket
    return _datasource.streamPrice(symbol);
  }
}
