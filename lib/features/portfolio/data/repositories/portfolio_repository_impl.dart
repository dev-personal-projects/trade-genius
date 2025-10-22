import '../../../market/data/datasources/binance_datasource.dart';
import '../../domain/entities/holding.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/watchlist_item.dart';
import '../../domain/entities/trading_strategy.dart';
import '../../domain/entities/portfolio_summary.dart';
import '../../domain/entities/portfolio_result.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../datasources/portfolio_supabase_datasource.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  final PortfolioSupabaseDatasource _supabaseDatasource;
  final BinanceDatasource _binanceDatasource;

  PortfolioRepositoryImpl({
    required PortfolioSupabaseDatasource supabaseDatasource,
    required BinanceDatasource binanceDatasource,
  }) : _supabaseDatasource = supabaseDatasource,
       _binanceDatasource = binanceDatasource;

  @override
  Future<PortfolioResult<List<Holding>>> getHoldings() async {
    try {
      final holdings = await _supabaseDatasource.getHoldings();
      await _updateHoldingsPrices(holdings);
      return PortfolioSuccess(holdings);
    } catch (e) {
      return PortfolioFailure(e.toString());
    }
  }

  @override
  Future<PortfolioResult<Holding>> addHolding(Holding holding) async {
    try {
      final result = await _supabaseDatasource.addHolding(holding);
      return PortfolioSuccess(result);
    } catch (e) {
      return PortfolioFailure(e.toString());
    }
  }

  @override
  Future<PortfolioResult<Holding>> updateHolding(Holding holding) async {
    try {
      final result = await _supabaseDatasource.updateHolding(holding);
      return PortfolioSuccess(result);
    } catch (e) {
      return PortfolioFailure(e.toString());
    }
  }

  @override
  Future<PortfolioResult<void>> deleteHolding(String holdingId) async {
    try {
      await _supabaseDatasource.deleteHolding(holdingId);
      return const PortfolioSuccess(null);
    } catch (e) {
      return PortfolioFailure(e.toString());
    }
  }

  @override
  Future<PortfolioResult<List<Transaction>>> getTransactions() async {
    try {
      final transactions = await _supabaseDatasource.getTransactions();
      return PortfolioSuccess(transactions);
    } catch (e) {
      return PortfolioFailure(e.toString());
    }
  }

  @override
  Future<PortfolioResult<Transaction>> addTransaction(
    Transaction transaction,
  ) async {
    try {
      final result = await _supabaseDatasource.addTransaction(transaction);
      return PortfolioSuccess(result);
    } catch (e) {
      return PortfolioFailure(e.toString());
    }
  }

  @override
  Future<PortfolioResult<List<Transaction>>> getTransactionsByHolding(
    String holdingId,
  ) async {
    try {
      final transactions = await _supabaseDatasource.getTransactionsByHolding(
        holdingId,
      );
      return PortfolioSuccess(transactions);
    } catch (e) {
      return PortfolioFailure(e.toString());
    }
  }

  @override
  Future<PortfolioResult<List<WatchlistItem>>> getWatchlist() async {
    try {
      final watchlist = await _supabaseDatasource.getWatchlist();
      await _updateWatchlistPrices(watchlist);
      return PortfolioSuccess(watchlist);
    } catch (e) {
      return PortfolioFailure(e.toString());
    }
  }

  @override
  Future<PortfolioResult<WatchlistItem>> addToWatchlist(
    WatchlistItem item,
  ) async {
    try {
      final result = await _supabaseDatasource.addToWatchlist(item);
      return PortfolioSuccess(result);
    } catch (e) {
      return PortfolioFailure(e.toString());
    }
  }

  @override
  Future<PortfolioResult<void>> removeFromWatchlist(String itemId) async {
    try {
      await _supabaseDatasource.removeFromWatchlist(itemId);
      return const PortfolioSuccess(null);
    } catch (e) {
      return PortfolioFailure(e.toString());
    }
  }

  @override
  Future<PortfolioResult<WatchlistItem>> updateWatchlistItem(
    WatchlistItem item,
  ) async {
    try {
      final result = await _supabaseDatasource.updateWatchlistItem(item);
      return PortfolioSuccess(result);
    } catch (e) {
      return PortfolioFailure(e.toString());
    }
  }

  @override
  Future<PortfolioResult<List<TradingStrategy>>> getStrategies() async {
    try {
      final strategies = await _supabaseDatasource.getStrategies();
      return PortfolioSuccess(strategies);
    } catch (e) {
      return PortfolioFailure(e.toString());
    }
  }

  @override
  Future<PortfolioResult<TradingStrategy>> addStrategy(
    TradingStrategy strategy,
  ) async {
    try {
      final result = await _supabaseDatasource.addStrategy(strategy);
      return PortfolioSuccess(result);
    } catch (e) {
      return PortfolioFailure(e.toString());
    }
  }

  @override
  Future<PortfolioResult<TradingStrategy>> updateStrategy(
    TradingStrategy strategy,
  ) async {
    try {
      final result = await _supabaseDatasource.updateStrategy(strategy);
      return PortfolioSuccess(result);
    } catch (e) {
      return PortfolioFailure(e.toString());
    }
  }

  @override
  Future<PortfolioResult<void>> deleteStrategy(String strategyId) async {
    try {
      await _supabaseDatasource.deleteStrategy(strategyId);
      return const PortfolioSuccess(null);
    } catch (e) {
      return PortfolioFailure(e.toString());
    }
  }

  @override
  Future<PortfolioResult<PortfolioSummary>> getPortfolioSummary() async {
    try {
      final holdings = await _supabaseDatasource.getHoldings();
      await _updateHoldingsPrices(holdings);

      final totalValue = holdings.fold(0.0, (sum, h) => sum + h.currentValue);
      final totalCost = holdings.fold(0.0, (sum, h) => sum + h.totalCost);
      final totalProfitLoss = totalValue - totalCost;
      final profitLossPercentage = totalCost > 0
          ? (totalProfitLoss / totalCost) * 100
          : 0.0;

      final summary = PortfolioSummary(
        totalValue: totalValue,
        totalCost: totalCost,
        totalProfitLoss: totalProfitLoss,
        profitLossPercentage: profitLossPercentage,
        change24h: 0.0,
        change24hPercentage: 0.0,
        holdingsCount: holdings.length,
      );

      return PortfolioSuccess(summary);
    } catch (e) {
      return PortfolioFailure(e.toString());
    }
  }

  Future<void> _updateHoldingsPrices(List<Holding> holdings) async {
    if (holdings.isEmpty) return;

    try {
      final coins = await _binanceDatasource.getTopCoins(limit: 200);
      for (final holding in holdings) {
        final coin = coins.firstWhere(
          (c) => c.symbol == holding.symbol,
          orElse: () => coins.first,
        );
        holding.currentPrice = coin.currentPrice;
      }
    } catch (_) {}
  }

  Future<void> _updateWatchlistPrices(List<WatchlistItem> watchlist) async {
    if (watchlist.isEmpty) return;

    try {
      final coins = await _binanceDatasource.getTopCoins(limit: 200);
      for (final item in watchlist) {
        final coin = coins.firstWhere(
          (c) => c.symbol == item.symbol,
          orElse: () => coins.first,
        );
        item.currentPrice = coin.currentPrice;
      }
    } catch (_) {}
  }
}
