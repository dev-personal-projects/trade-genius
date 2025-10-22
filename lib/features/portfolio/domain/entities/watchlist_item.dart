class WatchlistItem {
  final String id;
  final String userId;
  final String symbol;
  final String coinName;
  final double? targetPrice;
  final bool alertEnabled;
  final String? notes;
  final DateTime createdAt;

  double currentPrice;

  WatchlistItem({
    required this.id,
    required this.userId,
    required this.symbol,
    required this.coinName,
    this.targetPrice,
    this.alertEnabled = false,
    this.notes,
    required this.createdAt,
    this.currentPrice = 0.0,
  });

  double get priceChange => currentPrice > 0 ? currentPrice : 0.0;

  double? get distanceToTarget {
    if (targetPrice == null || currentPrice == 0) return null;
    return ((targetPrice! - currentPrice) / currentPrice) * 100;
  }

  bool get shouldAlert {
    if (!alertEnabled || targetPrice == null || currentPrice == 0) return false;
    return currentPrice >= targetPrice!;
  }

  String get formattedTarget => targetPrice != null ? '\$${targetPrice!.toStringAsFixed(2)}' : 'N/A';

  WatchlistItem copyWith({double? currentPrice}) {
    return WatchlistItem(
      id: id,
      userId: userId,
      symbol: symbol,
      coinName: coinName,
      targetPrice: targetPrice,
      alertEnabled: alertEnabled,
      notes: notes,
      createdAt: createdAt,
      currentPrice: currentPrice ?? this.currentPrice,
    );
  }
}
