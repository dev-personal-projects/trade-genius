// Why: Detailed view of single holding with transactions and actions
// Flutter Concepts: Scaffold, TabBar, ListView, showModalBottomSheet
// UX: Edit/delete actions, transaction history, visual P/L indicators

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/holding.dart';

class HoldingDetailScreen extends StatelessWidget {
  final Holding holding;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddTransaction;

  const HoldingDetailScreen({
    super.key,
    required this.holding,
    required this.onEdit,
    required this.onDelete,
    required this.onAddTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(holding.symbol),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Holding summary card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            holding.coinName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${holding.currentPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (holding.isProfit
                                      ? AppColors.bullish
                                      : AppColors.bearish)
                                  .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          holding.formattedProfitLoss,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: holding.isProfit
                                ? AppColors.bullish
                                : AppColors.bearish,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Divider(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    context,
                    'Quantity',
                    holding.quantity.toStringAsFixed(4),
                  ),
                  _buildInfoRow(
                    context,
                    'Avg Buy Price',
                    '\$${holding.averageBuyPrice.toStringAsFixed(2)}',
                  ),
                  _buildInfoRow(
                    context,
                    'Total Cost',
                    '\$${holding.totalCost.toStringAsFixed(2)}',
                  ),
                  _buildInfoRow(
                    context,
                    'Current Value',
                    '\$${holding.currentValue.toStringAsFixed(2)}',
                  ),
                  _buildInfoRow(
                    context,
                    'ROI',
                    '${holding.roi.toStringAsFixed(2)}%',
                    valueColor: holding.isProfit
                        ? AppColors.bullish
                        : AppColors.bearish,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Add transaction button
          ElevatedButton.icon(
            onPressed: onAddTransaction,
            icon: const Icon(Icons.add),
            label: const Text('Add Transaction'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Holding'),
        content: Text('Are you sure you want to delete ${holding.symbol}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bearish,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
