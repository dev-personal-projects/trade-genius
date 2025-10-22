// Why: Displays total portfolio value, P/L, and key metrics at the top of portfolio screen
// Flutter Concepts: Card, Container, Column, Row, AnimatedSwitcher for smooth value changes
// UX: Eye-catching gradient background, large readable numbers, color-coded profit/loss

import 'package:flutter/material.dart';
import '../../domain/entities/portfolio_summary.dart';
import '../../../../core/theme/app_theme.dart';

class PortfolioSummaryCard extends StatelessWidget {
  final PortfolioSummary summary;

  const PortfolioSummaryCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    // Theme.of(context) - Gets current theme (light/dark) from widget tree
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      // Card - Material Design elevated surface with rounded corners
      margin: const EdgeInsets.all(16),
      elevation: 4, // Shadow depth
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        // Container - Box model widget for padding, decoration, sizing
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // Gradient background for visual appeal
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.darkSurface, AppColors.darkCard]
                : [AppColors.lightSurface, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          // Column - Vertical layout of children
          crossAxisAlignment: CrossAxisAlignment.start, // Align left
          children: [
            // Label text
            Text(
              'Total Portfolio Value',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8), // Spacing between widgets

            // Main value with animation
            AnimatedSwitcher(
              // AnimatedSwitcher - Animates between different child widgets
              duration: const Duration(milliseconds: 300),
              child: Text(
                summary.formattedTotalValue,
                key: ValueKey(summary.totalValue), // Key for animation trigger
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Profit/Loss row
            Row(
              // Row - Horizontal layout of children
              children: [
                // P/L indicator icon
                Icon(
                  summary.isProfit ? Icons.trending_up : Icons.trending_down,
                  color: summary.isProfit ? AppColors.bullish : AppColors.bearish,
                  size: 20,
                ),
                const SizedBox(width: 8),

                // P/L text with color coding
                Text(
                  summary.formattedProfitLoss,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: summary.isProfit ? AppColors.bullish : AppColors.bearish,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Divider line
            Divider(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),

            // Bottom stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between items
              children: [
                _buildStatItem(
                  context,
                  'Holdings',
                  '${summary.holdingsCount}',
                ),
                _buildStatItem(
                  context,
                  'Total Cost',
                  '\$${summary.totalCost.toStringAsFixed(2)}',
                ),
                _buildStatItem(
                  context,
                  'ROI',
                  '${summary.profitLossPercentage.toStringAsFixed(2)}%',
                  color: summary.isProfit ? AppColors.bullish : AppColors.bearish,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build stat items (DRY principle)
  Widget _buildStatItem(
      BuildContext context,
      String label,
      String value, {
        Color? color,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
