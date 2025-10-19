// lib/features/market/presentation/widgets/coin_detail_screen.dart
// Why: Advanced trading analysis screen with technical indicators

// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import '../../../market/domain/entities/candlestick.dart';
import '../../../market/domain/entities/chart_drawing.dart';
import '../../../market/domain/entities/crypto_coin.dart';
import '../../../market/domain/entities/time_interval.dart';
import '../../data/datasources/binance_datasource.dart';
import '../../data/datasources/drawing_storage.dart';
import 'candlestick_chart.dart' as chart;
import 'animated_price_widget.dart';
import '../pages/fullscreen_chart_screen.dart';

class CoinDetailScreen extends StatefulWidget {
  final CryptoCoin coin;

  const CoinDetailScreen({super.key, required this.coin});

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  final _datasource = BinanceDatasource();
  List<Candlestick> _candles = [];
  final List<ChartDrawing> _drawings = [];
  TimeInterval _selectedInterval = TimeInterval.hour24;
  DrawingType? _activeDrawingTool;
  bool _isLoading = true;
  bool _showIndicators = false;

  @override
  void initState() {
    super.initState();
    _loadDrawings();
    _loadCandlesticks();
  }

  Future<void> _loadCandlesticks() async {
    setState(() => _isLoading = true);
    try {
      final candles = await _datasource.getCandlesticks(
        symbol: widget.coin.symbol,
        interval: _selectedInterval,
        limit: 100,
      );
      setState(() {
        _candles = candles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _loadDrawings() async {
    final drawings = await DrawingStorage.loadDrawings(widget.coin.symbol);
    setState(() => _drawings.addAll(drawings));
  }

  Future<void> _saveDrawings() async {
    await DrawingStorage.saveDrawings(widget.coin.symbol, _drawings);
  }

  void _openFullscreen() {
    if (_candles.isEmpty) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenChartScreen(
          coin: widget.coin,
          candles: _candles,
          drawings: _drawings,
          selectedInterval: _selectedInterval,
          activeDrawingTool: _activeDrawingTool,
          onDrawingAdded: (drawing) {
            setState(() {
              _drawings.add(drawing);
              _activeDrawingTool = null;
            });
            _saveDrawings();
          },
          onDrawingMoved: (drawing) {
            setState(() {
              final index = _drawings.indexWhere((d) => d.id == drawing.id);
              if (index != -1) _drawings[index] = drawing;
            });
            _saveDrawings();
          },
          onToolChanged: (tool) {
            setState(() => _activeDrawingTool = tool);
          },
        ),
      ),
    );
  }

  Map<String, double> _calculateIndicators() {
    if (_candles.length < 14) return {};

    final closes = _candles.map((c) => c.close).toList();
    final sma20 = closes.take(20).reduce((a, b) => a + b) / 20;

    double rsi = 50;
    if (closes.length >= 14) {
      double gains = 0, losses = 0;
      for (int i = 1; i < 14; i++) {
        final change = closes[i] - closes[i - 1];
        if (change > 0) {
          gains += change;
        } else {
          losses += change.abs();
        }
      }
      final avgGain = gains / 14;
      final avgLoss = losses / 14;
      if (avgLoss != 0) {
        final rs = avgGain / avgLoss;
        rsi = 100 - (100 / (1 + rs));
      }
    }

    final avgVolume =
        _candles.take(20).map((c) => c.volume).reduce((a, b) => a + b) / 20;
    final currentVolume = _candles.first.volume;
    final volumeRatio = currentVolume / avgVolume;

    return {'SMA20': sma20, 'RSI': rsi, 'VolumeRatio': volumeRatio};
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = widget.coin.isPositiveChange;
    final indicators = _calculateIndicators();
    StreamBuilder<double>(
      stream: _datasource.streamPrice(widget.coin.symbol),
      initialData: widget.coin.currentPrice,
      builder: (context, snapshot) {
        return AnimatedPriceWidget(
          price: snapshot.data ?? widget.coin.currentPrice,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.coin.symbol),
            Text(widget.coin.name, style: theme.textTheme.bodySmall),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showIndicators ? Icons.analytics : Icons.analytics_outlined,
            ),
            onPressed: () => setState(() => _showIndicators = !_showIndicators),
            tooltip: 'Technical Indicators',
          ),
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: _openFullscreen,
            tooltip: 'Fullscreen',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCandlesticks,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surface,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.coin.formattedPrice,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.coin.formattedChange,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isPositive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _StatRow(
                          '24h High',
                          '\$${widget.coin.high24h.toStringAsFixed(2)}',
                          theme,
                        ),
                        const SizedBox(height: 4),
                        _StatRow(
                          '24h Low',
                          '\$${widget.coin.low24h.toStringAsFixed(2)}',
                          theme,
                        ),
                        const SizedBox(height: 4),
                        _StatRow(
                          'Volume',
                          '\$${(widget.coin.volume24h / 1000000).toStringAsFixed(2)}M',
                          theme,
                        ),
                      ],
                    ),
                  ],
                ),
                if (_showIndicators && indicators.isNotEmpty) ...[
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _IndicatorChip(
                        label: 'SMA20',
                        value: '\$${indicators['SMA20']!.toStringAsFixed(2)}',
                        color: Colors.blue,
                      ),
                      _IndicatorChip(
                        label: 'RSI',
                        value: indicators['RSI']!.toStringAsFixed(1),
                        color: indicators['RSI']! > 70
                            ? Colors.red
                            : indicators['RSI']! < 30
                            ? Colors.green
                            : Colors.orange,
                      ),
                      _IndicatorChip(
                        label: 'Volume',
                        value:
                            '${indicators['VolumeRatio']!.toStringAsFixed(2)}x',
                        color: indicators['VolumeRatio']! > 1.5
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: TimeInterval.values.map((interval) {
                final isSelected = interval == _selectedInterval;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(interval.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedInterval = interval);
                      _loadCandlesticks();
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : chart.CandlestickChart(
                    candles: _candles,
                    drawings: _drawings,
                    activeDrawingTool: _activeDrawingTool,
                    onDrawingAdded: (drawing) {
                      setState(() {
                        _drawings.add(drawing);
                        _activeDrawingTool = null;
                      });
                      _saveDrawings();
                    },
                    onDrawingMoved: (drawing) {
                      setState(() {
                        final index = _drawings.indexWhere(
                          (d) => d.id == drawing.id,
                        );
                        if (index != -1) _drawings[index] = drawing;
                      });
                      _saveDrawings();
                    },
                  ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DrawingToolButton(
                  icon: Icons.horizontal_rule,
                  label: 'Support',
                  color: Colors.green,
                  isActive: _activeDrawingTool == DrawingType.supportLine,
                  onTap: () {
                    setState(() {
                      _activeDrawingTool =
                          _activeDrawingTool == DrawingType.supportLine
                          ? null
                          : DrawingType.supportLine;
                    });
                  },
                ),
                _DrawingToolButton(
                  icon: Icons.horizontal_rule,
                  label: 'Resistance',
                  color: Colors.red,
                  isActive: _activeDrawingTool == DrawingType.resistanceLine,
                  onTap: () {
                    setState(() {
                      _activeDrawingTool =
                          _activeDrawingTool == DrawingType.resistanceLine
                          ? null
                          : DrawingType.resistanceLine;
                    });
                  },
                ),
                _DrawingToolButton(
                  icon: Icons.trending_up,
                  label: 'Trend',
                  color: Colors.blue,
                  isActive: _activeDrawingTool == DrawingType.trendLine,
                  onTap: () {
                    setState(() {
                      _activeDrawingTool =
                          _activeDrawingTool == DrawingType.trendLine
                          ? null
                          : DrawingType.trendLine;
                    });
                  },
                ),
                _DrawingToolButton(
                  icon: Icons.undo,
                  label: 'Undo',
                  color: Colors.orange,
                  isActive: false,
                  onTap: () {
                    if (_drawings.isNotEmpty) {
                      setState(() => _drawings.removeLast());
                      _saveDrawings();
                    }
                  },
                ),
                _DrawingToolButton(
                  icon: Icons.delete_outline,
                  label: 'Clear',
                  color: theme.colorScheme.error,
                  isActive: false,
                  onTap: () {
                    setState(() {
                      _drawings.clear();
                      _activeDrawingTool = null;
                    });
                    _saveDrawings();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widgets remain the same...
class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _StatRow(this.label, this.value, this.theme);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label: ', style: theme.textTheme.bodySmall),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _IndicatorChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _IndicatorChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawingToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawingToolButton({
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? color
                : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? color : theme.colorScheme.onSurface,
              size: 18,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
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
