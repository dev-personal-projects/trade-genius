import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class QuickActionChips extends StatelessWidget {
  final Function(String) onActionTap;
  final bool isEnabled;

  const QuickActionChips({
    super.key,
    required this.onActionTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.trending_up,
        label: 'Market Analysis',
        prompt: 'Give me a quick analysis of the current crypto market trends',
        gradient: [AppColors.bullish, AppColors.bullish.withOpacity(0.7)],
      ),
      _QuickAction(
        icon: Icons.lightbulb_outline,
        label: 'Trading Tips',
        prompt: 'Share 3 essential trading tips for beginners',
        gradient: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
      ),
      _QuickAction(
        icon: Icons.show_chart,
        label: 'Explain RSI',
        prompt: 'Explain the RSI indicator and how to use it in trading',
        gradient: [Colors.purple, Colors.purple.withOpacity(0.7)],
      ),
      _QuickAction(
        icon: Icons.security,
        label: 'Risk Management',
        prompt: 'What are the best risk management strategies for crypto trading?',
        gradient: [AppColors.bearish, AppColors.bearish.withOpacity(0.7)],
      ),
    ];

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildActionChip(context, action),
          );
        },
      ),
    );
  }

  Widget _buildActionChip(BuildContext context, _QuickAction action) {
    return GestureDetector(
      onTap: isEnabled ? () => onActionTap(action.prompt) : null,
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isEnabled
                ? action.gradient
                : [Colors.grey, Colors.grey.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: action.gradient.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              action.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final String prompt;
  final List<Color> gradient;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.prompt,
    required this.gradient,
  });
}
