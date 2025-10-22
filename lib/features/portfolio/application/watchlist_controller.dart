// Why: Manages watchlist state and real-time price updates
// Pattern: Same as portfolio controller - clean and simple
// Reuses: BinanceDatasource for prices

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:tradegenius/features/market/data/datasources/binance_datasource.dart'
    show BinanceDatasource;
import '../../portfolio/domain/entities/watchlist_item.dart';
import '../../portfolio/domain/entities/portfolio_result.dart';
import '../../portfolio/domain/repositories/portfolio_repository.dart';
import 'watchlist_state.dart';

class WatchlistController extends ValueNotifier<WatchlistState> {
  final PortfolioRepository _repository;
  final BinanceDatasource _binanceDatasource;

  final Map<String, StreamController<double>> _priceStreams = {};
  final Map<String, StreamSubscription> _streamSubscriptions = {};

  WatchlistController(this._repository, this._binanceDatasource)
    : super(const WatchlistInitial());

  Future<void> loadWatchlist() async {
    value = const WatchlistLoading();

    final result = await _repository.getWatchlist();

    switch (result) {
      case PortfolioSuccess(:final data):
        value = WatchlistLoaded(items: data);
        _startPriceStreams(data);
      case PortfolioFailure(:final message):
        value = WatchlistError(message);
    }
  }

  Future<void> addToWatchlist(WatchlistItem item) async {
    final result = await _repository.addToWatchlist(item);
    switch (result) {
      case PortfolioSuccess():
        await loadWatchlist();
      case PortfolioFailure(:final message):
        value = WatchlistError(message);
    }
  }

  Future<void> removeFromWatchlist(String itemId) async {
    final result = await _repository.removeFromWatchlist(itemId);
    switch (result) {
      case PortfolioSuccess():
        await loadWatchlist();
      case PortfolioFailure(:final message):
        value = WatchlistError(message);
    }
  }

  Future<void> updateWatchlistItem(WatchlistItem item) async {
    final result = await _repository.updateWatchlistItem(item);
    switch (result) {
      case PortfolioSuccess():
        await loadWatchlist();
      case PortfolioFailure(:final message):
        value = WatchlistError(message);
    }
  }

  void _startPriceStreams(List items) {
    _stopAllStreams();
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
    super.dispose();
  }
}
