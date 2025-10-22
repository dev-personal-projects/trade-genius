// Why: Displays single transaction in history list
// Flutter Concepts: ListTile, Icon with background, DateFormat
// UX: Clear transaction type with icons, color coding, formatted dates

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../../domain/entities/transaction.dart';
import '../../../../core/theme/app_theme.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final color = _getTransactionColor();
    final icon = _getTransactionIcon();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        // ListTile - Standard Material Design list item with leading, title, subtitle, trailing
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        // Leading icon with colored background
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),

        // Transaction details
        title: Row(
          children: [
            Text(
              transaction.formattedType,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 8),
            Text(
              transaction.symbol,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),

        // Date and quantity
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${_formatDate(transaction.transactionDate)} • ${transaction.quantity.toStringAsFixed(4)} @ \$${transaction.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),

        // Total value
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              transaction.formattedTotal,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (transaction.fee > 0)
              Text(
                'Fee: \$${transaction.fee.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getTransactionColor() {
    switch (transaction.type) {
      case TransactionType.buy:
      case TransactionType.transferIn:
        return AppColors.bullish;
      case TransactionType.sell:
      case TransactionType.transferOut:
        return AppColors.bearish;
    }
  }

  IconData _getTransactionIcon() {
    switch (transaction.type) {
      case TransactionType.buy:
        return Icons.add_shopping_cart;
      case TransactionType.sell:
        return Icons.sell;
      case TransactionType.transferIn:
        return Icons.arrow_downward;
      case TransactionType.transferOut:
        return Icons.arrow_upward;
    }
  }

  String _formatDate(DateTime date) {
    // DateFormat from intl package - formats dates in readable format
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }
}
