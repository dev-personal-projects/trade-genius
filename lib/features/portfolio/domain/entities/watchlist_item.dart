class WatchlistItem {
  final String id;
  final String userId;
  final String symbol;
  final String coinName;
  final double? targetPriceLow;   // NEW: Low target
  final double? targetPriceHigh;  // NEW: High target
  final bool alertEnabled;
  final String? alarmSoundPath;   // NEW: Custom alarm sound
  final String? notes;
  final DateTime createdAt;

  double currentPrice;

  WatchlistItem({
    required this.id,
    required this.userId,
    required this.symbol,
    required this.coinName,
    this.targetPriceLow,
    this.targetPriceHigh,
    this.alertEnabled = false,
    this.alarmSoundPath,
    this.notes,
    required this.createdAt,
    this.currentPrice = 0.0,
  });

  double get priceChange => currentPrice > 0 ? currentPrice : 0.0;

  // Check if price is in target range
  bool get isInTargetRange {
    if (targetPriceLow == null && targetPriceHigh == null) return false;
    if (currentPrice == 0) return false;

    final aboveLow = targetPriceLow == null || currentPrice >= targetPriceLow!;
    final belowHigh = targetPriceHigh == null || currentPrice <= targetPriceHigh!;

    return aboveLow && belowHigh;
  }

  // Check if should trigger alert
  bool get shouldAlert {
    if (!alertEnabled || currentPrice == 0) return false;

    // Alert if price hits low target (support level)
    if (targetPriceLow != null && currentPrice <= targetPriceLow!) return true;

    // Alert if price hits high target (resistance level)
    if (targetPriceHigh != null && currentPrice >= targetPriceHigh!) return true;

    return false;
  }

  String get formattedTargets {
    if (targetPriceLow != null && targetPriceHigh != null) {
      return '\$${targetPriceLow!.toStringAsFixed(2)} - \$${targetPriceHigh!.toStringAsFixed(2)}';
    } else if (targetPriceLow != null) {
      return 'Low: \$${targetPriceLow!.toStringAsFixed(2)}';
    } else if (targetPriceHigh != null) {
      return 'High: \$${targetPriceHigh!.toStringAsFixed(2)}';
    }
    return 'N/A';
  }

  WatchlistItem copyWith({double? currentPrice}) {
    return WatchlistItem(
      id: id,
      userId: userId,
      symbol: symbol,
      coinName: coinName,
      targetPriceLow: targetPriceLow,
      targetPriceHigh: targetPriceHigh,
      alertEnabled: alertEnabled,
      alarmSoundPath: alarmSoundPath,
      notes: notes,
      createdAt: createdAt,
      currentPrice: currentPrice ?? this.currentPrice,
    );
  }
}
