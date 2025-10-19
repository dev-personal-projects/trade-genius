// lib/features/market/application/market_state.dart
// Why: Defines all possible states for market feature

import '../domain/entities/crypto_coin.dart';
import '../domain/entities/price_point.dart';

sealed class MarketState {
  const MarketState();
}

class MarketInitial extends MarketState {
  const MarketInitial();
}

class MarketLoading extends MarketState {
  const MarketLoading();
}

class MarketLoaded extends MarketState {
  final List<CryptoCoin> coins;
  final List<CryptoCoin> trending;

  const MarketLoaded({
    required this.coins,
    required this.trending,
  });
}

class MarketError extends MarketState {
  final String message;
  const MarketError(this.message);
}

// Separate state for chart data
class ChartState {
  final List<PricePoint> points;
  final bool isLoading;
  final String? error;

  const ChartState({
    this.points = const [],
    this.isLoading = false,
    this.error,
  });
}
