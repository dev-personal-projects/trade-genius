// lib/features/market/presentation/pages/coin_detail_screen.dart
// Why: Detailed view with interactive charts and analysis tools

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../market/domain/entities/candlestick.dart';
import '../../../market/domain/entities/chart_drawing.dart';
import '../../../market/domain/entities/crypto_coin.dart';
import '../../../market/domain/entities/time_interval.dart';
import '../../data/datasources/binance_datasource.dart';
import '../widgets/candlestick_chart.dart';

class CoinDetailScreen extends StatefulWidget {
  final CryptoCoin coin;

  const CoinDetailScreen({
    super.key,
    required this.coin,
  });

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

  @override
  void initState() {
    super.initState();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading chart: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = widget.coin.isPositiveChange;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.coin.symbol),
            Text(
              widget.coin.name,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCandlesticks,
          ),
        ],
      ),
      body: Column(
          children: [
    // Price header
      Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surface,
      child: Row(
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
    Text('24h High', style: theme.textTheme.bodySmall),
    Text(
    '\$${widget.coin.high24h.toStringAsFixed(2)}',
    style: theme.textTheme.bodyMedium?.copyWith(
    fontWeight: FontWeight.w600,
    ),
    ),
    const SizedBox(height: 4),
    Text('24h Low', style: theme.textTheme.bodySmall),
    Text(
    '\$${widget.coin.low24h.toStringAsFixed(2)}',
    style: theme.textTheme.bodyMedium?.copyWith(
    fontWeight: FontWeight.w600,
    ),
    ),
    ],
    ),
    ],
    ),
    ),

    // Time interval selector
    Container(
    height: 50,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
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

    // Chart
    Expanded(
    child: _isLoading
    ? const Center(child: CircularProgressIndicator())
        : Padding(
    padding: const EdgeInsets.all(16),
    child: CandlestickChart(
    candles: _candles,
    drawings: _drawings,
    activeDrawingTool: _activeDrawingTool,
    onDrawingAdded: (drawing) {
    setState(() {
    _drawings.add(drawing);
    _activeDrawingTool = null;
    });
    },
    ),
    ),
    ),

    // Drawing tools
    Container(
    padding: const EdgeInsets.all(16),
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
    _activeDrawingTool = _activeDrawingTool == DrawingType.supportLine
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
    _activeDrawingTool = _activeDrawingTool == DrawingType.resistanceLine
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
    _activeDrawingTool = _activeDrawingTool == DrawingType.trendLine
    ? null
        : DrawingType.trendLine;
    });
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? color : theme.colorScheme.outline,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? color : theme.colorScheme.onSurface, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
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
