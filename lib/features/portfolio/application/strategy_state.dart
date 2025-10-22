// Why: Type-safe state representation for strategy feature
// Pattern: Sealed class (exhaustive pattern matching, no missing cases)
// States: Initial, Loading, Loaded (with data), Error (with message)

import '../../portfolio/domain/entities/trading_strategy.dart';

// Sealed class - All subclasses must be in same file (exhaustive matching)
sealed class StrategyState {
  const StrategyState();
}

// Initial state - Before any data is loaded
class StrategyInitial extends StrategyState {
  const StrategyInitial();
}

// Loading state - Data fetch in progress
class StrategyLoading extends StrategyState {
  const StrategyLoading();
}

// Success state - Data loaded successfully
class StrategyLoaded extends StrategyState {
  final List<TradingStrategy> strategies;

  const StrategyLoaded(this.strategies);

  // Computed properties for UI convenience
  bool get isEmpty => strategies.isEmpty;
  int get count => strategies.length;

  // Filter helpers
  List<TradingStrategy> get activeStrategies =>
      strategies.where((s) => s.status == StrategyStatus.active).toList();

  List<TradingStrategy> get completedStrategies =>
      strategies.where((s) => s.status == StrategyStatus.completed).toList();

  List<TradingStrategy> get cancelledStrategies =>
      strategies.where((s) => s.status == StrategyStatus.cancelled).toList();
}

// Error state - Operation failed
class StrategyError extends StrategyState {
  final String message;

  const StrategyError(this.message);
}
