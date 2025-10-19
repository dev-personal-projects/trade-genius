// lib/features/market/presentation/pages/market_screen.dart
// Why: Main market screen with real-time price updates

import 'package:flutter/material.dart';
import 'package:tradegenius/features/market/presentation/widgets/coin_detail_screen.dart';
import '../../application/market_controller.dart';
import '../../application/market_state.dart';
import '../../data/datasources/binance_datasource.dart';
import '../../data/repositories/market_repository_impl.dart';
import '../widgets/coin_list_item.dart';
import '../widgets/market_search_bar.dart';
import '../widgets/market_stats_header.dart';
import '../widgets/trending_section.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  late final MarketController _controller;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final datasource = BinanceDatasource();
    final repository = MarketRepositoryImpl(datasource);
    _controller = MarketController(repository);
    _controller.loadMarketData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      _controller.loadMarketData();
    } else {
      _controller.searchCoins(query);
    }
  }

  void _onClearSearch() {
    _searchController.clear();
    _controller.loadMarketData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ValueListenableBuilder<MarketState>(
          valueListenable: _controller,
          builder: (context, state, _) {
            return RefreshIndicator(
              onRefresh: () => _controller.loadMarketData(),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: MarketSearchBar(
                      controller: _searchController,
                      onChanged: _onSearch,
                      onClear: _onClearSearch,
                    ),
                  ),

                  if (state is MarketLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  if (state is MarketError)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load market data',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.message,
                              style: theme.textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => _controller.loadMarketData(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (state is MarketLoaded) ...[
                    SliverToBoxAdapter(
                      child: MarketStatsHeader(totalCoins: state.coins.length),
                    ),

                    if (state.trending.isNotEmpty)
                      SliverToBoxAdapter(
                        child: TrendingSection(
                          coins: state.trending,
                          onCoinTap: (coin) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CoinDetailScreen(coin: coin),
                              ),
                            );
                          },
                        ),
                      ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Text(
                          'All Coins',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    if (state.coins.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'No coins found',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final coin = state.coins[index];
                          return CoinListItem(
                            coin: coin,
                            // Add live price stream for top 20 coins
                            priceStream: index < 20
                                ? _controller.getPriceStream(coin.symbol)
                                : null,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CoinDetailScreen(coin: coin),
                                ),
                              );
                            },
                          );
                        }, childCount: state.coins.length),
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
