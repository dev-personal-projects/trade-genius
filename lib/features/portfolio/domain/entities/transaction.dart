enum TransactionType {
  buy,
  sell,
  transferIn,
  transferOut;

  String get displayName {
    switch (this) {
      case TransactionType.buy:
        return 'Buy';
      case TransactionType.sell:
        return 'Sell';
      case TransactionType.transferIn:
        return 'Transfer In';
      case TransactionType.transferOut:
        return 'Transfer Out';
    }
  }
}

class Transaction {
  final String id;
  final String userId;
  final String? holdingId;
  final String symbol;
  final TransactionType type;
  final double quantity;
  final double price;
  final double fee;
  final double totalValue;
  final String? notes;
  final DateTime transactionDate;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.userId,
    this.holdingId,
    required this.symbol,
    required this.type,
    required this.quantity,
    required this.price,
    this.fee = 0.0,
    required this.totalValue,
    this.notes,
    required this.transactionDate,
    required this.createdAt,
  });

  bool get isBuy => type == TransactionType.buy;
  bool get isSell => type == TransactionType.sell;

  String get formattedType => type.displayName;
  String get formattedTotal => '\$${totalValue.toStringAsFixed(2)}';
}
