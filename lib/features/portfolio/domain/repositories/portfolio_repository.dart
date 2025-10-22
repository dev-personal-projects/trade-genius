import '../entities/holding.dart';
import '../entities/transaction.dart';
import '../entities/watchlist_item.dart';
import '../entities/trading_strategy.dart';
import '../entities/portfolio_summary.dart';
import '../entities/portfolio_result.dart';

abstract class PortfolioRepository {
  // Holdings
  Future<PortfolioResult<List<Holding>>> getHoldings();
  Future<PortfolioResult<Holding>> addHolding(Holding holding);
  Future<PortfolioResult<Holding>> updateHolding(Holding holding);
  Future<PortfolioResult<void>> deleteHolding(String holdingId);

  // Transactions
  Future<PortfolioResult<List<Transaction>>> getTransactions();
  Future<PortfolioResult<Transaction>> addTransaction(Transaction transaction);
  Future<PortfolioResult<List<Transaction>>> getTransactionsByHolding(String holdingId);

  // Watchlist
  Future<PortfolioResult<List<WatchlistItem>>> getWatchlist();
  Future<PortfolioResult<WatchlistItem>> addToWatchlist(WatchlistItem item);
  Future<PortfolioResult<void>> removeFromWatchlist(String itemId);
  Future<PortfolioResult<WatchlistItem>> updateWatchlistItem(WatchlistItem item);

  // Strategies
  Future<PortfolioResult<List<TradingStrategy>>> getStrategies();
  Future<PortfolioResult<TradingStrategy>> addStrategy(TradingStrategy strategy);
  Future<PortfolioResult<TradingStrategy>> updateStrategy(TradingStrategy strategy);
  Future<PortfolioResult<void>> deleteStrategy(String strategyId);

  // Analytics
  Future<PortfolioResult<PortfolioSummary>> getPortfolioSummary();
}
