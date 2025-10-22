// Why: Displays single watchlist item with live price and target indicator
// Flutter Concepts: Card, StreamBuilder, color-coded distance to target
// UX: Live prices, visual target indicator, swipe actions

import 'package:flutter/material.dart';
import '../../domain/entities/watchlist_item.dart';
import '../../../../core/theme/app_theme.dart';

class WatchlistCard extends StatelessWidget {
  final WatchlistItem item;
  final Stream<double>? priceStream;
  final VoidCallback onRemove;
  final VoidCallback onEdit;

  const WatchlistCard({
    super.key,
    required this.item,
    this.priceStream,
    required this.onRemove,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Coin avatar
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      item.symbol[0],
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Coin info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item.symbol,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (item.alertEnabled) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.notifications_active,
                                size: 16,
                                color: AppColors.warning,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          item.coinName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Current price with live updates
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (priceStream != null)
                        StreamBuilder<double>(
                          stream: priceStream,
                          initialData: item.currentPrice,
                          builder: (context, snapshot) {
                            final price = snapshot.data ?? item.currentPrice;
                            return Text(
                              '\$${price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        )
                      else
                        Text(
                          '\$${item.currentPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),

                  // Actions menu
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: onEdit,
                        child: const Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 12),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: onRemove,
                        child: const Row(
                          children: [
                            Icon(
                              Icons.delete,
                              size: 20,
                              color: AppColors.bearish,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Remove',
                              style: TextStyle(color: AppColors.bearish),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Target price indicator
              if (item.targetPrice != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getTargetColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getTargetIcon(),
                        size: 16,
                        color: _getTargetColor(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Target: ${item.formattedTarget}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getTargetColor(),
                              ),
                            ),
                            if (item.distanceToTarget != null)
                              Text(
                                '${item.distanceToTarget!.toStringAsFixed(2)}% ${item.distanceToTarget! > 0 ? 'above' : 'below'}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (item.shouldAlert)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.bullish,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'TARGET HIT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              // Notes
              if (item.notes != null && item.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.notes!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getTargetColor() {
    if (item.distanceToTarget == null) return AppColors.primary;
    return item.distanceToTarget! > 0 ? AppColors.bullish : AppColors.bearish;
  }

  IconData _getTargetIcon() {
    if (item.distanceToTarget == null) return Icons.flag;
    return item.distanceToTarget! > 0
        ? Icons.arrow_upward
        : Icons.arrow_downward;
  }
}
