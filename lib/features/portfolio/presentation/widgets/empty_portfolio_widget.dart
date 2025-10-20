// Why: Shows when user has no holdings yet, encourages first action
// Flutter Concepts: Center, Column, Icon, ElevatedButton
// UX: Friendly empty state with clear call-to-action

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class EmptyPortfolioWidget extends StatelessWidget {
  final VoidCallback onAddHolding;

  const EmptyPortfolioWidget({super.key, required this.onAddHolding});

  @override
  Widget build(BuildContext context) {
    return Center(
      // Center - Centers child widget in available space
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          children: [
            // Large icon
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'No Holdings Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'Start building your crypto portfolio by adding your first holding',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),

            // Call-to-action button
            ElevatedButton.icon(
              // ElevatedButton - Material Design raised button
              onPressed: onAddHolding,
              icon: const Icon(Icons.add),
              label: const Text('Add First Holding'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tips section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Getting Started',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTip('Track your crypto investments in one place'),
                  _buildTip('Monitor real-time profit and loss'),
                  _buildTip('Record all your transactions'),
                  _buildTip('Set price alerts on watchlist'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: AppColors.bullish),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
