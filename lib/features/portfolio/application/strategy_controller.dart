// Why: Manages trading strategy state and business logic
// Pattern: ValueNotifier for reactive state management
// Responsibilities: CRUD operations, status filtering, state updates

import 'package:flutter/foundation.dart';
import '../../portfolio/domain/entities/trading_strategy.dart';
import '../../portfolio/domain/entities/portfolio_result.dart';
import '../../portfolio/domain/repositories/portfolio_repository.dart';
import './strategy_state.dart';

class StrategyController extends ValueNotifier<StrategyState> {
  final PortfolioRepository _repository;

  // ValueNotifier - Notifies listeners when value changes (reactive pattern)
  // Initial state is StrategyInitial
  StrategyController(this._repository) : super(const StrategyInitial());

  // Load all strategies from repository
  Future<void> loadStrategies() async {
    // Set loading state (triggers UI rebuild via listeners)
    value = const StrategyLoading();

    // Fetch from repository
    final result = await _repository.getStrategies();

    // Pattern matching on sealed class (type-safe error handling)
    value = switch (result) {
      PortfolioSuccess(:final data) => StrategyLoaded(data),
      PortfolioFailure(:final message) => StrategyError(message),
    };
  }

  // Add new strategy
  Future<void> addStrategy(TradingStrategy strategy) async {
    final result = await _repository.addStrategy(strategy);

    // Pattern matching for type-safe property access
    switch (result) {
      case PortfolioSuccess():
        await loadStrategies();
      case PortfolioFailure(:final message):
        value = StrategyError(message);
    }
  }

  // Update existing strategy
  Future<void> updateStrategy(TradingStrategy strategy) async {
    final result = await _repository.updateStrategy(strategy);

    switch (result) {
      case PortfolioSuccess():
        await loadStrategies();
      case PortfolioFailure(:final message):
        value = StrategyError(message);
    }
  }

  // Delete strategy
  Future<void> deleteStrategy(String strategyId) async {
    final result = await _repository.deleteStrategy(strategyId);

    switch (result) {
      case PortfolioSuccess():
        await loadStrategies();
      case PortfolioFailure(:final message):
        value = StrategyError(message);
    }
  }

  // Filter strategies by status (computed property)
  List<TradingStrategy> getStrategiesByStatus(StrategyStatus status) {
    final currentState = value;
    if (currentState is StrategyLoaded) {
      return currentState.strategies
          .where((s) => s.status == status)
          .toList();
    }
    return [];
  }

  // Get active strategies count
  int get activeCount {
    final currentState = value;
    if (currentState is StrategyLoaded) {
      return currentState.strategies
          .where((s) => s.isActive)
          .length;
    }
    return 0;
  }

  // Get completed strategies count
  int get completedCount {
    final currentState = value;
    if (currentState is StrategyLoaded) {
      return currentState.strategies
          .where((s) => s.status == StrategyStatus.completed)
          .length;
    }
    return 0;
  }
}
