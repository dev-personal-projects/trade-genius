// Why: Main portfolio screen that displays holdings, summary, and manages state
// Flutter Concepts: StatefulWidget, ValueListenableBuilder, RefreshIndicator, FloatingActionButton
// UX: Pull-to-refresh, real-time updates, smooth loading states, easy navigation

import 'package:flutter/material.dart';
import 'package:tradegenius/features/portfolio/domain/entities/holding.dart'
    show Holding;
import 'package:tradegenius/features/portfolio/presentation/pages/holding_detail_screen.dart'
    show HoldingDetailScreen;
import 'package:tradegenius/features/portfolio/presentation/widgets/add_holding_dialog.dart'
    show AddHoldingDialog;
import 'package:tradegenius/features/portfolio/presentation/widgets/edit_holding_dialog.dart'
    show EditHoldingDialog;
import '../../../../core/theme/app_theme.dart';
import '../../application/portfolio_controller.dart';
import '../../application/portfolio_state.dart';
import '../../data/datasources/portfolio_supabase_datasource.dart';
import '../../data/repositories/portfolio_repository_impl.dart';
import '../../../market/data/datasources/binance_datasource.dart';
import '../widgets/portfolio_summary_card.dart';
import '../widgets/holding_card.dart';
import '../widgets/empty_portfolio_widget.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  // Controller instance - manages portfolio state and business logic
  late final PortfolioController _controller;

  @override
  void initState() {
    super.initState();
    // initState - Called once when widget is inserted into widget tree
    // Perfect place to initialize controllers and load initial data

    // Initialize controller with dependencies (Dependency Injection pattern)
    _controller = PortfolioController(
      PortfolioRepositoryImpl(
        supabaseDatasource: PortfolioSupabaseDatasource(),
        binanceDatasource: BinanceDatasource(),
      ),
      BinanceDatasource(),
    );

    // Load portfolio data when screen opens
    _controller.loadPortfolio();
  }

  @override
  void dispose() {
    // dispose - Called when widget is removed from widget tree
    // CRITICAL: Always dispose controllers to prevent memory leaks
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold - Basic Material Design layout structure
      appBar: AppBar(
        // AppBar - Top bar with title and actions
        title: const Text(
          'Portfolio',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Action buttons in top-right corner
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Transaction History',
            onPressed: () {
              // TODO: Navigate to transactions screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transaction history coming soon'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            tooltip: 'Watchlist',
            onPressed: () {
              // TODO: Navigate to watchlist screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Watchlist coming soon')),
              );
            },
          ),
        ],
      ),

      // Main content area
      body: ValueListenableBuilder<PortfolioState>(
        // ValueListenableBuilder - Rebuilds when controller's value changes
        // More efficient than setState() - only rebuilds this widget, not entire screen
        valueListenable: _controller,
        builder: (context, state, child) {
          // Pattern matching on sealed class - type-safe state handling
          return switch (state) {
            // Initial state - show nothing or placeholder
            PortfolioInitial() => const SizedBox.shrink(),

            // Loading state - show centered progress indicator
            PortfolioLoading() => const Center(
              child: CircularProgressIndicator(),
            ),

            // Error state - show error message with retry button
            PortfolioError(:final message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.bearish),
                  const SizedBox(height: 16),
                  Text(
                    'Oops! Something went wrong',
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
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _controller.loadPortfolio(),
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

            // Success state - show portfolio content
            PortfolioLoaded(:final holdings, :final summary) =>
              holdings.isEmpty
                  ? EmptyPortfolioWidget(onAddHolding: _showAddHoldingDialog)
                  : RefreshIndicator(
                      // RefreshIndicator - Pull-to-refresh gesture
                      // UX: Standard mobile pattern for refreshing content
                      onRefresh: () async {
                        await _controller.loadPortfolio();
                      },
                      child: ListView(
                        // ListView - Scrollable list of widgets
                        // Automatically handles scrolling, performance optimization
                        padding: const EdgeInsets.only(
                          bottom: 80,
                        ), // Space for FAB
                        children: [
                          // Portfolio summary at top
                          PortfolioSummaryCard(summary: summary),

                          // Section header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Your Holdings',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  '${holdings.length} ${holdings.length == 1 ? 'coin' : 'coins'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Holdings list
                          ...holdings.map((holding) {
                            // Get real-time price stream for this holding
                            final priceStream = _controller.getPriceStream(
                              holding.symbol,
                            );

                            return HoldingCard(
                              holding: holding,
                              priceStream: priceStream,
                              onTap: () => _navigateToHoldingDetail(holding),
                            );
                          }),

                          // Bottom spacing
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
          };
        },
      ),

      // Floating Action Button - Primary action button
      floatingActionButton: ValueListenableBuilder<PortfolioState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          // Only show FAB when portfolio is loaded
          if (state is! PortfolioLoaded) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            // FloatingActionButton.extended - FAB with icon and label
            onPressed: _showAddHoldingDialog,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Add Holding'),
          );
        },
      ),
    );
  }

  // Navigate to holding detail screen
  void _navigateToHoldingDetail(Holding holding) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HoldingDetailScreen(
          holding: holding,
          onEdit: () {
            Navigator.pop(context); // Close detail screen
            _showEditHoldingDialog(holding); // Show edit dialog
          },
          onDelete: () async {
            final messenger = ScaffoldMessenger.of(context);
            Navigator.pop(context);
            await _controller.deleteHolding(holding.id);
            if (mounted) {
              messenger.showSnackBar(
                SnackBar(content: Text('${holding.symbol} deleted')),
              );
            }
          },
          onAddTransaction: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add transaction coming soon')),
            );
          },
        ),
      ),
    );
  }

  void _showEditHoldingDialog(Holding holding) {
    showDialog(
      context: context,
      builder: (context) => EditHoldingDialog(
        holding: holding,
        onUpdate: (updatedHolding) async {
          final messenger = ScaffoldMessenger.of(context);
          await _controller.updateHolding(updatedHolding);
          if (mounted) {
            messenger.showSnackBar(
              SnackBar(
                content: Text('${updatedHolding.symbol} updated successfully'),
                backgroundColor: AppColors.bullish,
              ),
            );
          }
        },
      ),
    );
  }

  // Show dialog to add new holding
  void _showAddHoldingDialog() {
    showDialog(
      context: context,
      builder: (context) => AddHoldingDialog(
        onAdd: (holding) async {
          final messenger = ScaffoldMessenger.of(context);
          await _controller.addHolding(holding);
          if (mounted) {
            messenger.showSnackBar(
              SnackBar(
                content: Text('${holding.symbol} added successfully'),
                backgroundColor: AppColors.bullish,
              ),
            );
          }
        },
      ),
    );
  }
}
