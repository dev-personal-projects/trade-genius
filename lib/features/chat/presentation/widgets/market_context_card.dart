import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class MarketContextCard extends StatelessWidget {
  final String btcPrice;
  final String ethPrice;
  final String marketSentiment;
  final bool isLoading;

  const MarketContextCard({
    super.key,
    this.btcPrice = '...',
    this.ethPrice = '...',
    this.marketSentiment = 'Neutral',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.bullish.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Live Market Context',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPriceItem(
                  'BTC',
                  btcPrice,
                  Icons.currency_bitcoin,
                  AppColors.bullish,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPriceItem(
                  'ETH',
                  ethPrice,
                  Icons.diamond,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSentimentItem(marketSentiment),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceItem(String symbol, String price, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            symbol,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            price,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentItem(String sentiment) {
    final color = sentiment == 'Bullish'
        ? AppColors.bullish
        : sentiment == 'Bearish'
            ? AppColors.bearish
            : Colors.grey;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            sentiment == 'Bullish'
                ? Icons.trending_up
                : sentiment == 'Bearish'
                    ? Icons.trending_down
                    : Icons.trending_flat,
            color: color,
            size: 16,
          ),
          const SizedBox(height: 4),
          Text(
            'Sentiment',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            sentiment,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
