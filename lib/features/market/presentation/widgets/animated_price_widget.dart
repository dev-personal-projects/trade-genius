// lib/features/market/presentation/widgets/animated_price_widget.dart
// Why: Animated price display with flash effect for real-time updates

import 'package:flutter/material.dart';

class AnimatedPriceWidget extends StatefulWidget {
  final double price;
  final TextStyle? style;

  const AnimatedPriceWidget({
    super.key,
    required this.price,
    this.style,
  });

  @override
  State<AnimatedPriceWidget> createState() => _AnimatedPriceWidgetState();
}

class _AnimatedPriceWidgetState extends State<AnimatedPriceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  double? _previousPrice;
  bool _isIncreasing = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _updateAnimation();
  }

  @override
  void didUpdateWidget(AnimatedPriceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.price != widget.price) {
      _previousPrice = oldWidget.price;
      _isIncreasing = widget.price > oldWidget.price;
      _updateAnimation();
      _controller.forward(from: 0);
    }
  }

  void _updateAnimation() {
    final flashColor = _isIncreasing ? Colors.green : Colors.red;
    _colorAnimation = ColorTween(
      begin: flashColor.withValues(alpha: 0.3),
      end: Colors.transparent,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_previousPrice != null)
                Icon(
                  _isIncreasing ? Icons.arrow_upward : Icons.arrow_downward,
                  color: _isIncreasing ? Colors.green : Colors.red,
                  size: 16,
                ),
              const SizedBox(width: 4),
              Text(
                _formatPrice(widget.price),
                style: widget.style,
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatPrice(double price) {
    if (price >= 1) {
      return '\$${price.toStringAsFixed(2)}';
    }
    return '\$${price.toStringAsFixed(6)}';
  }
}
