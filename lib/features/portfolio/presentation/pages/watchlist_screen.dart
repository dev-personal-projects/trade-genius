// Why: Main watchlist screen showing all watched coins
// Flutter Concepts: ValueListenableBuilder, RefreshIndicator, real-time prices
// UX: Pull-to-refresh, live prices, add/remove actions

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/watchlist_controller.dart';
import '../../application/watchlist_state.dart';
import '../../data/datasources/portfolio_supabase_datasource.dart';
import '../../data/repositories/portfolio_repository_impl.dart';
import '../../../market/data/datasources/binance_datasource.dart';
import '../widgets/watchlist_card.dart';
import '../widgets/add_watchlist_dialog.dart';
import '../widgets/empty_watchlist_widget.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  late final WatchlistController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WatchlistController(
      PortfolioRepositoryImpl(
        supabaseDatasource: PortfolioSupabaseDatasource(),
        binanceDatasource: BinanceDatasource(),
      ),
      BinanceDatasource(),
    );
    _controller.loadWatchlist();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Watchlist',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ValueListenableBuilder<WatchlistState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          return switch (state) {
            WatchlistInitial() => const SizedBox.shrink(),
            WatchlistLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            WatchlistError(:final message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.bearish,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading watchlist',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _controller.loadWatchlist(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            WatchlistLoaded(:final items) => items.isEmpty
                ? EmptyWatchlistWidget(
              onAddCoin: _showAddWatchlistDialog,
            )
                : RefreshIndicator(
              onRefresh: () async {
                await _controller.loadWatchlist();
              },
              child: ListView(
                padding: const EdgeInsets.only(bottom: 80),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '${items.length} ${items.length == 1 ? 'coin' : 'coins'} watched',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  ...items.map((item) {
                    final priceStream = _controller.getPriceStream(item.symbol);

                    return RepaintBoundary(
                      key: ValueKey(item.id),
                      child: WatchlistCard(
                        item: item,
                        priceStream: priceStream,
                        onRemove: () => _handleRemove(item),
                        onEdit: () => _showEditWatchlistDialog(item),
                      ),
                    );
                  }),
                ],
              ),
            ),
          };
        },
      ),
      floatingActionButton: ValueListenableBuilder<WatchlistState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          if (state is! WatchlistLoaded) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: _showAddWatchlistDialog,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Add Coin'),
          );
        },
      ),
    );
  }

  void _showAddWatchlistDialog() {
    showDialog(
      context: context,
      builder: (context) => AddWatchlistDialog(
        onAdd: (item) async {
          final messenger = ScaffoldMessenger.of(context);
          await _controller.addToWatchlist(item);
          if (mounted) {
            messenger.showSnackBar(
              SnackBar(
                content: Text('${item.symbol} added to watchlist'),
                backgroundColor: AppColors.bullish,
              ),
            );
          }
        },
      ),
    );
  }

  void _showEditWatchlistDialog(item) {
    showDialog(
      context: context,
      builder: (context) => AddWatchlistDialog(
        item: item,
        onAdd: (updatedItem) async {
          final messenger = ScaffoldMessenger.of(context);
          await _controller.updateWatchlistItem(updatedItem);
          if (mounted) {
            messenger.showSnackBar(
              SnackBar(
                content: Text('${updatedItem.symbol} updated'),
                backgroundColor: AppColors.bullish,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _handleRemove(item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Watchlist'),
        content: Text('Remove ${item.symbol} from your watchlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bearish,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      await _controller.removeFromWatchlist(item.id);
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('${item.symbol} removed')),
        );
      }
    }
  }
}
