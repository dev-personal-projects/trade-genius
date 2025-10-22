// ignore_for_file: unused_local_variable

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../domain/entities/holding.dart';
import '../domain/entities/transaction.dart';
import '../domain/entities/watchlist_item.dart';
import '../domain/entities/trading_strategy.dart';
import '../domain/entities/portfolio_result.dart';
import '../domain/repositories/portfolio_repository.dart';
import '../../market/data/datasources/binance_datasource.dart';
import 'portfolio_state.dart';

class PortfolioController extends ValueNotifier<PortfolioState> {
  final PortfolioRepository _repository;
  final BinanceDatasource _binanceDatasource;
  final ValueNotifier<TransactionsState> transactionsState = ValueNotifier(
    const TransactionsState(),
  );

  final Map<String, StreamController<double>> _priceStreams = {};
  final Map<String, StreamSubscription> _streamSubscriptions = {};
  Timer? _refreshTimer;

  PortfolioController(this._repository, this._binanceDatasource)
    : super(const PortfolioInitial());

  Future<void> loadPortfolio() async {
    value = const PortfolioLoading();

    final holdingsResult = await _repository.getHoldings();
    final summaryResult = await _repository.getPortfolioSummary();
    final watchlistResult = await _repository.getWatchlist();
    final strategiesResult = await _repository.getStrategies();

    switch (holdingsResult) {
      case PortfolioSuccess(:final data):
        switch (summaryResult) {
          case PortfolioSuccess(:final data):
            value = PortfolioLoaded(
              holdings: holdingsResult.data,
              summary: data,
              watchlist: switch (watchlistResult) {
                PortfolioSuccess(:final data) => data,
                _ => [],
              },
              strategies: switch (strategiesResult) {
                PortfolioSuccess(:final data) => data,
                _ => [],
              },
            );
            _startPriceStreams(holdingsResult.data);
            _startAutoRefresh();
          case PortfolioFailure(:final message):
            value = PortfolioError(message);
        }
      case PortfolioFailure(:final message):
        value = PortfolioError(message);
    }
  }

  Future<void> addHolding(Holding holding) async {
    final result = await _repository.addHolding(holding);
    switch (result) {
      case PortfolioSuccess():
        await loadPortfolio();
      case PortfolioFailure(:final message):
        value = PortfolioError(message);
    }
  }

  Future<void> updateHolding(Holding holding) async {
    final result = await _repository.updateHolding(holding);
    switch (result) {
      case PortfolioSuccess():
        await loadPortfolio();
      case PortfolioFailure(:final message):
        value = PortfolioError(message);
    }
  }

  Future<void> deleteHolding(String holdingId) async {
    final result = await _repository.deleteHolding(holdingId);
    switch (result) {
      case PortfolioSuccess():
        await loadPortfolio();
      case PortfolioFailure(:final message):
        value = PortfolioError(message);
    }
  }

  Future<void> loadTransactions() async {
    transactionsState.value = const TransactionsState(isLoading: true);

    final result = await _repository.getTransactions();
    switch (result) {
      case PortfolioSuccess(:final data):
        transactionsState.value = TransactionsState(transactions: data);
      case PortfolioFailure(:final message):
        transactionsState.value = TransactionsState(error: message);
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    final result = await _repository.addTransaction(transaction);
    switch (result) {
      case PortfolioSuccess():
        await loadTransactions();
        await loadPortfolio();
      case PortfolioFailure(:final message):
        transactionsState.value = TransactionsState(error: message);
    }
  }

  Future<void> addToWatchlist(WatchlistItem item) async {
    final result = await _repository.addToWatchlist(item);
    switch (result) {
      case PortfolioSuccess():
        await loadPortfolio();
      case PortfolioFailure(:final message):
        value = PortfolioError(message);
    }
  }

  Future<void> removeFromWatchlist(String itemId) async {
    final result = await _repository.removeFromWatchlist(itemId);
    switch (result) {
      case PortfolioSuccess():
        await loadPortfolio();
      case PortfolioFailure(:final message):
        value = PortfolioError(message);
    }
  }

  Future<void> addStrategy(TradingStrategy strategy) async {
    final result = await _repository.addStrategy(strategy);
    switch (result) {
      case PortfolioSuccess():
        await loadPortfolio();
      case PortfolioFailure(:final message):
        value = PortfolioError(message);
    }
  }

  Future<void> updateStrategy(TradingStrategy strategy) async {
    final result = await _repository.updateStrategy(strategy);
    switch (result) {
      case PortfolioSuccess():
        await loadPortfolio();
      case PortfolioFailure(:final message):
        value = PortfolioError(message);
    }
  }

  Future<void> deleteStrategy(String strategyId) async {
    final result = await _repository.deleteStrategy(strategyId);
    switch (result) {
      case PortfolioSuccess():
        await loadPortfolio();
      case PortfolioFailure(:final message):
        value = PortfolioError(message);
    }
  }

void _startPriceStreams(List items) {
  _stopAllStreams();
  // Limit to first 10 items to reduce load
  final limitedItems = items.take(10);
  for (final item in limitedItems) {
    final controller = StreamController<double>.broadcast();
    _priceStreams[item.symbol] = controller;

    // Add debounce to reduce updates
    final subscription = _binanceDatasource
        .streamPrice(item.symbol)
        .distinct() // Only emit when value changes
        .listen(
      (price) {
        if (!controller.isClosed) {
          controller.add(price);
        }
      },
      onError: (error) {
        debugPrint('Stream error for ${item.symbol}: $error');
      },
    );

    _streamSubscriptions[item.symbol] = subscription;
  }
}


  Stream<double>? getPriceStream(String symbol) {
    return _priceStreams[symbol]?.stream;
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 1), // Changed from 30 seconds to 1 minute
          (_) {
        if (value is PortfolioLoaded) {
          loadPortfolio();
        }
      },
    );
  }


  void _stopAllStreams() {
    for (final subscription in _streamSubscriptions.values) {
      subscription.cancel();
    }
    for (final controller in _priceStreams.values) {
      controller.close();
    }
    _priceStreams.clear();
    _streamSubscriptions.clear();
  }

  @override
  void dispose() {
    _stopAllStreams();
    _refreshTimer?.cancel();
    transactionsState.dispose();
    super.dispose();
  }
}
