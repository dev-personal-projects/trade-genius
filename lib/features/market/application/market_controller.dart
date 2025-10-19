// lib/features/market/application/market_controller.dart
// Why: Manages market state and real-time price streams

// ignore_for_file: unused_local_variable

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../domain/entities/time_interval.dart';
import '../domain/repositories/market_repository.dart';
import '../domain/entities/market_result.dart';
import 'market_state.dart';

class MarketController extends ValueNotifier<MarketState> {
  final MarketRepository _repository;
  final ValueNotifier<ChartState> chartState = ValueNotifier(const ChartState());
  
  // Store active price streams
  final Map<String, StreamController<double>> _priceStreams = {};
  final Map<String, StreamSubscription> _streamSubscriptions = {};

  MarketController(this._repository) : super(const MarketInitial());

  // Load top coins and trending coins
  Future<void> loadMarketData() async {
    value = const MarketLoading();

    final coinsResult = await _repository.getTopCoins(limit: 50);
    final trendingResult = await _repository.getTrendingCoins(limit: 10);

    switch (coinsResult) {
      case MarketSuccess(:final data):
        switch (trendingResult) {
          case MarketSuccess(:final data):
            value = MarketLoaded(
              coins: coinsResult.data,
              trending: data,
            );
            // Start streaming prices for visible coins
            _startPriceStreams(coinsResult.data.take(20).toList());
          case MarketFailure(:final message):
            value = MarketError(message);
        }
      case MarketFailure(:final message):
        value = MarketError(message);
    }
  }

  // Search coins
  Future<void> searchCoins(String query) async {
    if (query.isEmpty) {
      loadMarketData();
      return;
    }

    value = const MarketLoading();
    final result = await _repository.searchCoins(query);

    switch (result) {
      case MarketSuccess(:final data):
        value = MarketLoaded(
          coins: data,
          trending: const [],
        );
      case MarketFailure(:final message):
        value = MarketError(message);
    }
  }

  // Load price history for chart
  Future<void> loadPriceHistory(String symbol, TimeInterval interval) async {
    chartState.value = const ChartState(isLoading: true);

    final result = await _repository.getPriceHistory(
      symbol: symbol,
      interval: interval,
    );

    switch (result) {
      case MarketSuccess(:final data):
        chartState.value = ChartState(points: data);
      case MarketFailure(:final message):
        chartState.value = ChartState(error: message);
    }
  }

  // Start streaming prices for multiple coins
  void _startPriceStreams(List coins) {
    // Cancel existing streams
    _stopAllStreams();

    // Start new streams for top coins
    for (final coin in coins) {
      final symbol = coin.symbol;
      
      final controller = StreamController<double>.broadcast();
      _priceStreams[symbol] = controller;

      final subscription = _repository.streamPrice(symbol).listen(
        (price) {
          if (!controller.isClosed) {
            controller.add(price);
          }
        },
        onError: (error) {
          debugPrint('Stream error for $symbol: $error');
        },
      );

      _streamSubscriptions[symbol] = subscription;
    }
  }

  // Get price stream for a specific coin
  Stream<double>? getPriceStream(String symbol) {
    return _priceStreams[symbol]?.stream;
  }

  // Stop all active streams
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
    chartState.dispose();
    super.dispose();
  }
}
