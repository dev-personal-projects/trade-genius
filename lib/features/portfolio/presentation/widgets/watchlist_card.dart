// Why: Displays watchlist item with low/high targets and alarm indicator
// Flutter Concepts: Card, StreamBuilder, visual price range indicators
// UX: Live prices, dual targets, alarm sound indicator, color-coded zones

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
                            if (item.alarmSoundPath != null) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.music_note,
                                size: 14,
                                color: AppColors.primary,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          item.coinName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
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
                            // Only rebuild if data actually changed
                            if (!snapshot.hasData) {
                              return Text(
                                '\$${item.currentPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            }

                            final price = snapshot.data!;
                            return Text(
                              '\$${price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _getPriceColor(price),
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

              // Target price range indicator
              if (item.targetPriceLow != null || item.targetPriceHigh != null) ...[
                const SizedBox(height: 12),

                // Price range visual
                Column(
                  children: [
                    // High target
                    if (item.targetPriceHigh != null)
                      _buildTargetRow(
                        context,
                        'High Target',
                        item.targetPriceHigh!,
                        Icons.arrow_upward,
                        AppColors.bullish,
                        item.currentPrice >= item.targetPriceHigh!,
                      ),

                    if (item.targetPriceLow != null && item.targetPriceHigh != null)
                      const SizedBox(height: 8),

                    // Low target
                    if (item.targetPriceLow != null)
                      _buildTargetRow(
                        context,
                        'Low Target',
                        item.targetPriceLow!,
                        Icons.arrow_downward,
                        AppColors.bearish,
                        item.currentPrice <= item.targetPriceLow!,
                      ),
                  ],
                ),

                // Alert status
                if (item.shouldAlert) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.warning,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notification_important,
                          size: 16,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'TARGET REACHED!',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
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

  Widget _buildTargetRow(
      BuildContext context,
      String label,
      double price,
      IconData icon,
      Color color,
      bool isHit,
      ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: isHit
            ? Border.all(color: color, width: 2)
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          if (isHit)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'HIT',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getPriceColor(double price) {
    // Color code based on position relative to targets
    if (item.targetPriceHigh != null && price >= item.targetPriceHigh!) {
      return AppColors.bullish;
    }
    if (item.targetPriceLow != null && price <= item.targetPriceLow!) {
      return AppColors.bearish;
    }
    if (item.isInTargetRange) {
      return AppColors.warning;
    }
    return AppColors.primary;
  }
}
