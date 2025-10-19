// lib/features/market/presentation/pages/fullscreen_chart_screen.dart
// Why: Fullscreen chart view for better analysis

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/candlestick.dart';
import '../../domain/entities/chart_drawing.dart';
import '../../domain/entities/crypto_coin.dart';
import '../../domain/entities/time_interval.dart';
import '../widgets/candlestick_chart.dart';

class FullscreenChartScreen extends StatefulWidget {
  final CryptoCoin coin;
  final List<Candlestick> candles;
  final List<ChartDrawing> drawings;
  final TimeInterval selectedInterval;
  final DrawingType? activeDrawingTool;
  final Function(ChartDrawing) onDrawingAdded;
  final Function(ChartDrawing) onDrawingMoved;
  final Function(DrawingType?) onToolChanged;

  const FullscreenChartScreen({
    super.key,
    required this.coin,
    required this.candles,
    required this.drawings,
    required this.selectedInterval,
    required this.activeDrawingTool,
    required this.onDrawingAdded,
    required this.onDrawingMoved,
    required this.onToolChanged,
  });

  @override
  State<FullscreenChartScreen> createState() => _FullscreenChartScreenState();
}

class _FullscreenChartScreenState extends State<FullscreenChartScreen> {
  @override
  void initState() {
    super.initState();
    // Hide system UI for true fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Lock to landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // Unlock orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Chart
            Positioned.fill(
              child: CandlestickChart(
                candles: widget.candles,
                drawings: widget.drawings,
                activeDrawingTool: widget.activeDrawingTool,
                onDrawingAdded: widget.onDrawingAdded,
                onDrawingMoved: widget.onDrawingMoved,
              ),
            ),

            // Top bar with coin info and exit button
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Coin info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.coin.symbol,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.coin.formattedPrice,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: widget.coin.isPositiveChange
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Exit fullscreen button
                    IconButton(
                      icon: const Icon(Icons.fullscreen_exit),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Exit Fullscreen',
                    ),
                  ],
                ),
              ),
            ),

            // Drawing tools (bottom)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ToolButton(
                      icon: Icons.horizontal_rule,
                      label: 'Support',
                      color: Colors.green,
                      isActive: widget.activeDrawingTool == DrawingType.supportLine,
                      onTap: () {
                        widget.onToolChanged(
                          widget.activeDrawingTool == DrawingType.supportLine
                              ? null
                              : DrawingType.supportLine,
                        );
                      },
                    ),
                    _ToolButton(
                      icon: Icons.horizontal_rule,
                      label: 'Resistance',
                      color: Colors.red,
                      isActive: widget.activeDrawingTool == DrawingType.resistanceLine,
                      onTap: () {
                        widget.onToolChanged(
                          widget.activeDrawingTool == DrawingType.resistanceLine
                              ? null
                              : DrawingType.resistanceLine,
                        );
                      },
                    ),
                    _ToolButton(
                      icon: Icons.trending_up,
                      label: 'Trend',
                      color: Colors.blue,
                      isActive: widget.activeDrawingTool == DrawingType.trendLine,
                      onTap: () {
                        widget.onToolChanged(
                          widget.activeDrawingTool == DrawingType.trendLine
                              ? null
                              : DrawingType.trendLine,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? color : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? color : theme.colorScheme.onSurface,
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? color : theme.colorScheme.onSurface,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
