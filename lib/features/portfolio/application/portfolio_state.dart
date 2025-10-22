import '../domain/entities/holding.dart';
import '../domain/entities/transaction.dart';
import '../domain/entities/watchlist_item.dart';
import '../domain/entities/trading_strategy.dart';
import '../domain/entities/portfolio_summary.dart';

sealed class PortfolioState {
  const PortfolioState();
}

class PortfolioInitial extends PortfolioState {
  const PortfolioInitial();
}

class PortfolioLoading extends PortfolioState {
  const PortfolioLoading();
}

class PortfolioLoaded extends PortfolioState {
  final List<Holding> holdings;
  final PortfolioSummary summary;
  final List<WatchlistItem> watchlist;
  final List<TradingStrategy> strategies;

  const PortfolioLoaded({
    required this.holdings,
    required this.summary,
    this.watchlist = const [],
    this.strategies = const [],
  });
}

class PortfolioError extends PortfolioState {
  final String message;
  const PortfolioError(this.message);
}

class TransactionsState {
  final List<Transaction> transactions;
  final bool isLoading;
  final String? error;

  const TransactionsState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
  });
}
