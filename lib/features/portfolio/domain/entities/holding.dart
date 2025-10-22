class Holding {
  final String id;
  final String userId;
  final String symbol;
  final String coinName;
  final double quantity;
  final double averageBuyPrice;
  final DateTime createdAt;
  final DateTime updatedAt;

  double currentPrice;

  Holding({
    required this.id,
    required this.userId,
    required this.symbol,
    required this.coinName,
    required this.quantity,
    required this.averageBuyPrice,
    required this.createdAt,
    required this.updatedAt,
    this.currentPrice = 0.0,
  });

  double get totalCost => quantity * averageBuyPrice;
  double get currentValue => quantity * currentPrice;
  double get profitLoss => currentValue - totalCost;
  double get profitLossPercentage => totalCost > 0 ? (profitLoss / totalCost) * 100 : 0;
  double get roi => profitLossPercentage;
  bool get isProfit => profitLoss >= 0;

  String get formattedProfitLoss {
    final sign = isProfit ? '+' : '';
    return '$sign\$${profitLoss.toStringAsFixed(2)}';
  }

  double allocationPercentage(double totalPortfolioValue) {
    return totalPortfolioValue > 0 ? (currentValue / totalPortfolioValue) * 100 : 0;
  }

  Holding copyWith({double? currentPrice}) {
    return Holding(
      id: id,
      userId: userId,
      symbol: symbol,
      coinName: coinName,
      quantity: quantity,
      averageBuyPrice: averageBuyPrice,
      createdAt: createdAt,
      updatedAt: updatedAt,
      currentPrice: currentPrice ?? this.currentPrice,
    );
  }
}
