// Why: Shows key portfolio metrics in a compact row
// Flutter Concepts: Row, Card, Icon, color-coded stats
// UX: Quick overview of best/worst performers and 24h change

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/holding.dart';

class PortfolioStatsRow extends StatelessWidget {
  final List<Holding> holdings;

  const PortfolioStatsRow({
    super.key,
    required this.holdings,
  });

  @override
  Widget build(BuildContext context) {
    if (holdings.isEmpty) return const SizedBox.shrink();

    final bestPerformer = _getBestPerformer();
    final worstPerformer = _getWorstPerformer();
    final totalChange24h = _getTotalChange24h();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Best Performer
          Expanded(
            child: _buildStatCard(
              context,
              'Best',
              bestPerformer?.symbol ?? 'N/A',
              bestPerformer?.profitLossPercentage ?? 0,
              Icons.trending_up,
              AppColors.bullish,
            ),
          ),
          const SizedBox(width: 8),

          // Worst Performer
          Expanded(
            child: _buildStatCard(
              context,
              'Worst',
              worstPerformer?.symbol ?? 'N/A',
              worstPerformer?.profitLossPercentage ?? 0,
              Icons.trending_down,
              AppColors.bearish,
            ),
          ),
          const SizedBox(width: 8),

          // 24h Change
          Expanded(
            child: _buildStatCard(
              context,
              '24h Change',
              '${totalChange24h >= 0 ? '+' : ''}${totalChange24h.toStringAsFixed(2)}%',
              totalChange24h,
              Icons.show_chart,
              totalChange24h >= 0 ? AppColors.bullish : AppColors.bearish,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context,
      String label,
      String value,
      double percentage,
      IconData icon,
      Color color,
      ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Holding? _getBestPerformer() {
    if (holdings.isEmpty) return null;
    return holdings.reduce(
          (a, b) => a.profitLossPercentage > b.profitLossPercentage ? a : b,
    );
  }

  Holding? _getWorstPerformer() {
    if (holdings.isEmpty) return null;
    return holdings.reduce(
          (a, b) => a.profitLossPercentage < b.profitLossPercentage ? a : b,
    );
  }

  double _getTotalChange24h() {
    if (holdings.isEmpty) return 0.0;
    // Simplified: average of all holdings' P/L percentages
    final total = holdings.fold(
      0.0,
          (sum, h) => sum + h.profitLossPercentage,
    );
    return total / holdings.length;
  }
}
