// Why: Main screen displaying all trading strategies with filtering
// Flutter Concepts: ValueListenableBuilder, TabBar, RefreshIndicator, ListView
// State: Listens to StrategyController for reactive updates
// Theme: Supports both light and dark mode using Theme.of(context)

import 'package:flutter/material.dart';
import '../../application/strategy_controller.dart';
import '../../application/strategy_state.dart';
import '../../domain/entities/trading_strategy.dart';
import '../widgets/strategy_card.dart';
import '../widgets/add_strategy_dialog.dart';
import '../../../../core/theme/app_theme.dart';

class StrategiesScreen extends StatefulWidget {
  final StrategyController controller;

  const StrategiesScreen({
    super.key,
    required this.controller,
  });

  @override
  State<StrategiesScreen> createState() => _StrategiesScreenState();
}

class _StrategiesScreenState extends State<StrategiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    widget.controller.loadStrategies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Theme.of(context) - Gets current theme (light/dark)
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trading Strategies'),
        bottom: TabBar(
          controller: _tabController,
          // Theme-aware tab indicator color
          indicatorColor: AppColors.primary,
          labelColor: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: ValueListenableBuilder<StrategyState>(
        valueListenable: widget.controller,
        builder: (context, state, _) {
          return switch (state) {
            StrategyInitial() => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No strategies yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create your first strategy',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            StrategyLoading() => const Center(child: CircularProgressIndicator()),
            StrategyError(:final message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.bearish),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: widget.controller.loadStrategies,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            StrategyLoaded() => _buildContent(state),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(StrategyLoaded state) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildList(state.activeStrategies),
        _buildList(state.completedStrategies),
        _buildList(state.strategies),
      ],
    );
  }

  Widget _buildList(List<TradingStrategy> strategies) {
    if (strategies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No strategies in this category',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: widget.controller.loadStrategies,
      child: ListView.builder(
        itemCount: strategies.length,
        padding: const EdgeInsets.only(bottom: 80),
        itemBuilder: (context, index) {
          final strategy = strategies[index];
          return StrategyCard(
            strategy: strategy,
            onTap: () => _showEditDialog(strategy),
            onDelete: () => widget.controller.deleteStrategy(strategy.id),
          );
        },
      ),
    );
  }

  Future<void> _showAddDialog() async {
    final strategy = await showDialog<TradingStrategy>(
      context: context,
      builder: (context) => const AddStrategyDialog(),
    );

    if (strategy != null) {
      await widget.controller.addStrategy(strategy);
    }
  }

  Future<void> _showEditDialog(TradingStrategy strategy) async {
    final updated = await showDialog<TradingStrategy>(
      context: context,
      builder: (context) => AddStrategyDialog(strategy: strategy),
    );

    if (updated != null) {
      await widget.controller.updateStrategy(updated);
    }
  }
}
