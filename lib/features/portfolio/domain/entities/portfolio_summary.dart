class PortfolioSummary {
  final double totalValue;
  final double totalCost;
  final double totalProfitLoss;
  final double profitLossPercentage;
  final double change24h;
  final double change24hPercentage;
  final int holdingsCount;

  const PortfolioSummary({
    required this.totalValue,
    required this.totalCost,
    required this.totalProfitLoss,
    required this.profitLossPercentage,
    required this.change24h,
    required this.change24hPercentage,
    required this.holdingsCount,
  });

  bool get isProfit => totalProfitLoss >= 0;

  String get formattedTotalValue => '\$${totalValue.toStringAsFixed(2)}';

  String get formattedProfitLoss {
    final sign = isProfit ? '+' : '';
    return '$sign\$${totalProfitLoss.toStringAsFixed(2)} ($sign${profitLossPercentage.toStringAsFixed(2)}%)';
  }
}
