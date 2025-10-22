// Why: Displays individual strategy with status, prices, and risk/reward
// Flutter Concepts: Card, InkWell (tap ripple), Chip (status badge), Row/Column layout
// UX: Color-coded status, swipe-to-delete gesture, tap to edit

import 'package:flutter/material.dart';
import '../../domain/entities/trading_strategy.dart';
import '../../../../core/theme/app_theme.dart';

class StrategyCard extends StatelessWidget {
  final TradingStrategy strategy;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const StrategyCard({
    super.key,
    required this.strategy,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      // Dismissible - Swipe-to-delete gesture (Material Design pattern)
      key: Key(strategy.id),
      direction: DismissDirection.endToStart, // Swipe left only
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.bearish,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        // Show confirmation dialog before deleting
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Strategy'),
            content: const Text('Are you sure you want to delete this strategy?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete', style: TextStyle(color: AppColors.bearish)),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) => onDelete?.call(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          // InkWell - Adds Material ripple effect on tap
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Title + Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        strategy.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildStatusChip(strategy.status),
                  ],
                ),

                if (strategy.symbol != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    strategy.symbol!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],

                if (strategy.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    strategy.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Price levels (if available)
                if (strategy.entryPrice != null ||
                    strategy.targetPrice != null ||
                    strategy.stopLoss != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (strategy.entryPrice != null)
                        _buildPriceChip('Entry', strategy.entryPrice!, Colors.blue),
                      if (strategy.targetPrice != null)
                        _buildPriceChip('Target', strategy.targetPrice!, AppColors.bullish),
                      if (strategy.stopLoss != null)
                        _buildPriceChip('Stop', strategy.stopLoss!, AppColors.bearish),
                    ],
                  ),
                ],

                // Risk/Reward ratio
                if (strategy.riskRewardRatio != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.analytics, size: 16,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                      const SizedBox(width: 4),
                      Text(
                        'R:R ${strategy.riskRewardRatio!.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],

                // Tags
                if (strategy.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: strategy.tags.map((tag) => Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 11)),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(StrategyStatus status) {
    Color color;
    switch (status) {
      case StrategyStatus.active:
        color = AppColors.bullish;
      case StrategyStatus.completed:
        color = Colors.blue;
      case StrategyStatus.cancelled:
        color = AppColors.bearish;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPriceChip(String label, double price, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$label: \$${price.toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
