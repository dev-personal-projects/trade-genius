// Why: Displays individual holding with live price, quantity, and P/L
// Flutter Concepts: ListTile, StreamBuilder for real-time updates, InkWell for tap feedback
// UX: Live price updates, color-coded P/L, tap to view details, smooth animations

import 'package:flutter/material.dart';
import '../../domain/entities/holding.dart';
import '../../../../core/theme/app_theme.dart';

class HoldingCard extends StatelessWidget {
  final Holding holding;
  final Stream<double>? priceStream; // Optional real-time price stream
  final VoidCallback? onTap; // Callback when card is tapped

  const HoldingCard({
    super.key,
    required this.holding,
    this.priceStream,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        // InkWell - Provides Material Design ripple effect on tap
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Coin icon/avatar
                  CircleAvatar(
                    // CircleAvatar - Circular widget for icons/images
                    radius: 20,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      holding.symbol[0], // First letter of symbol
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Coin info
                  Expanded(
                    // Expanded - Takes remaining space in Row/Column
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          holding.symbol,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          holding.coinName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Current value and P/L
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Real-time price with StreamBuilder
                      if (priceStream != null)
                        StreamBuilder<double>(
                          // StreamBuilder - Rebuilds widget when stream emits new data
                          stream: priceStream,
                          initialData: holding.currentPrice,
                          builder: (context, snapshot) {
                            final price = snapshot.data ?? holding.currentPrice;
                            return AnimatedDefaultTextStyle(
                              // AnimatedDefaultTextStyle - Animates text style changes
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              child: Text('\$${price.toStringAsFixed(2)}'),
                            );
                          },
                        )
                      else
                        Text(
                          '\$${holding.currentPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      const SizedBox(height: 4),

                      // P/L percentage with color
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (holding.isProfit
                                      ? AppColors.bullish
                                      : AppColors.bearish)
                                  .withValues(),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${holding.isProfit ? '+' : ''}${holding.profitLossPercentage.toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: holding.isProfit
                                ? AppColors.bullish
                                : AppColors.bearish,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Bottom info row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem(
                    context,
                    'Quantity',
                    holding.quantity.toStringAsFixed(4),
                  ),
                  _buildInfoItem(
                    context,
                    'Avg Buy',
                    '\$${holding.averageBuyPrice.toStringAsFixed(2)}',
                  ),
                  _buildInfoItem(
                    context,
                    'Value',
                    '\$${holding.currentValue.toStringAsFixed(2)}',
                  ),
                  _buildInfoItem(
                    context,
                    'P/L',
                    holding.formattedProfitLoss,
                    color: holding.isProfit
                        ? AppColors.bullish
                        : AppColors.bearish,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value, {
    Color? color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
