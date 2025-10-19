// lib/features/market/presentation/widgets/live_price_text.dart
// Why: Displays real-time price with flash animation on change

import 'package:flutter/material.dart';

class LivePriceText extends StatefulWidget {
  final Stream<double> priceStream;
  final TextStyle? style;

  const LivePriceText({
    super.key,
    required this.priceStream,
    this.style,
  });

  @override
  State<LivePriceText> createState() => _LivePriceTextState();
}

class _LivePriceTextState extends State<LivePriceText> {
  double? _currentPrice;
  double? _previousPrice;
  Color? _flashColor;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: widget.priceStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final newPrice = snapshot.data!;

          // Determine price direction
          if (_currentPrice != null && newPrice != _currentPrice) {
            _previousPrice = _currentPrice;
            _flashColor = newPrice > _currentPrice! ? Colors.green : Colors.red;

            // Reset flash after animation
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                setState(() => _flashColor = null);
              }
            });
          }

          _currentPrice = newPrice;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: _flashColor?.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _formatPrice(newPrice),
              style: widget.style?.copyWith(
                color: _flashColor ?? widget.style?.color,
              ),
            ),
          );
        }

        return Text(
          _currentPrice != null ? _formatPrice(_currentPrice!) : '--',
          style: widget.style,
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
