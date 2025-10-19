// lib/features/market/domain/entities/market_result.dart
// Why: Type-safe result handling for market operations

sealed class MarketResult<T> {
  const MarketResult();
}

class MarketSuccess<T> extends MarketResult<T> {
  final T data;
  const MarketSuccess(this.data);
}

class MarketFailure<T> extends MarketResult<T> {
  final String message;
  const MarketFailure(this.message);
}
