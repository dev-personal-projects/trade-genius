enum StrategyStatus {
  active,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case StrategyStatus.active:
        return 'Active';
      case StrategyStatus.completed:
        return 'Completed';
      case StrategyStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class TradingStrategy {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? symbol;
  final List<String> tags;
  final double? entryPrice;
  final double? targetPrice;
  final double? stopLoss;
  final StrategyStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TradingStrategy({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.symbol,
    this.tags = const [],
    this.entryPrice,
    this.targetPrice,
    this.stopLoss,
    this.status = StrategyStatus.active,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => status == StrategyStatus.active;

  double? get riskRewardRatio {
    if (entryPrice == null || targetPrice == null || stopLoss == null) return null;
    final risk = (entryPrice! - stopLoss!).abs();
    final reward = (targetPrice! - entryPrice!).abs();
    return risk > 0 ? reward / risk : null;
  }

  String get formattedStatus => status.displayName;
}
