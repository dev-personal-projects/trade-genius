import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/entities/holding.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/watchlist_item.dart';
import '../../domain/entities/trading_strategy.dart';

class PortfolioSupabaseDatasource {
  final SupabaseClient _client = SupabaseService.client;

  String get _userId => _client.auth.currentUser!.id;

  // Holdings
  Future<List<Holding>> getHoldings() async {
    final data = await _client
        .from('holdings')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (data as List).map((json) => _mapToHolding(json)).toList();
  }

  Future<Holding> addHolding(Holding holding) async {
    final data = await _client
        .from('holdings')
        .insert({
          'user_id': _userId,
          'symbol': holding.symbol,
          'coin_name': holding.coinName,
          'quantity': holding.quantity,
          'average_buy_price': holding.averageBuyPrice,
        })
        .select()
        .single();

    return _mapToHolding(data);
  }

  Future<Holding> updateHolding(Holding holding) async {
    final data = await _client
        .from('holdings')
        .update({
          'quantity': holding.quantity,
          'average_buy_price': holding.averageBuyPrice,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', holding.id)
        .eq('user_id', _userId)
        .select()
        .single();

    return _mapToHolding(data);
  }

  Future<void> deleteHolding(String holdingId) async {
    await _client
        .from('holdings')
        .delete()
        .eq('id', holdingId)
        .eq('user_id', _userId);
  }

  // Transactions
  Future<List<Transaction>> getTransactions() async {
    final data = await _client
        .from('transactions')
        .select()
        .eq('user_id', _userId)
        .order('transaction_date', ascending: false);

    return (data as List).map((json) => _mapToTransaction(json)).toList();
  }

  Future<Transaction> addTransaction(Transaction transaction) async {
    final data = await _client
        .from('transactions')
        .insert({
          'user_id': _userId,
          'holding_id': transaction.holdingId,
          'symbol': transaction.symbol,
          'type': transaction.type.name,
          'quantity': transaction.quantity,
          'price': transaction.price,
          'fee': transaction.fee,
          'total_value': transaction.totalValue,
          'notes': transaction.notes,
          'transaction_date': transaction.transactionDate.toIso8601String(),
        })
        .select()
        .single();

    return _mapToTransaction(data);
  }

  Future<List<Transaction>> getTransactionsByHolding(String holdingId) async {
    final data = await _client
        .from('transactions')
        .select()
        .eq('user_id', _userId)
        .eq('holding_id', holdingId)
        .order('transaction_date', ascending: false);

    return (data as List).map((json) => _mapToTransaction(json)).toList();
  }

  // Watchlist
  Future<List<WatchlistItem>> getWatchlist() async {
    final data = await _client
        .from('watchlist')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (data as List).map((json) => _mapToWatchlistItem(json)).toList();
  }

  Future<WatchlistItem> addToWatchlist(WatchlistItem item) async {
    final data = await _client
        .from('watchlist')
        .insert({
          'user_id': _userId,
          'symbol': item.symbol,
          'coin_name': item.coinName,
          'target_price': item.targetPrice,
          'alert_enabled': item.alertEnabled,
          'notes': item.notes,
        })
        .select()
        .single();

    return _mapToWatchlistItem(data);
  }

  Future<void> removeFromWatchlist(String itemId) async {
    await _client
        .from('watchlist')
        .delete()
        .eq('id', itemId)
        .eq('user_id', _userId);
  }

  Future<WatchlistItem> updateWatchlistItem(WatchlistItem item) async {
    final data = await _client
        .from('watchlist')
        .update({
          'target_price': item.targetPrice,
          'alert_enabled': item.alertEnabled,
          'notes': item.notes,
        })
        .eq('id', item.id)
        .eq('user_id', _userId)
        .select()
        .single();

    return _mapToWatchlistItem(data);
  }

  // Strategies
  Future<List<TradingStrategy>> getStrategies() async {
    final data = await _client
        .from('trading_strategies')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (data as List).map((json) => _mapToStrategy(json)).toList();
  }

  Future<TradingStrategy> addStrategy(TradingStrategy strategy) async {
    final data = await _client
        .from('trading_strategies')
        .insert({
          'user_id': _userId,
          'title': strategy.title,
          'description': strategy.description,
          'symbol': strategy.symbol,
          'tags': strategy.tags,
          'entry_price': strategy.entryPrice,
          'target_price': strategy.targetPrice,
          'stop_loss': strategy.stopLoss,
          'status': strategy.status.name,
        })
        .select()
        .single();

    return _mapToStrategy(data);
  }

  Future<TradingStrategy> updateStrategy(TradingStrategy strategy) async {
    final data = await _client
        .from('trading_strategies')
        .update({
          'title': strategy.title,
          'description': strategy.description,
          'symbol': strategy.symbol,
          'tags': strategy.tags,
          'entry_price': strategy.entryPrice,
          'target_price': strategy.targetPrice,
          'stop_loss': strategy.stopLoss,
          'status': strategy.status.name,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', strategy.id)
        .eq('user_id', _userId)
        .select()
        .single();

    return _mapToStrategy(data);
  }

  Future<void> deleteStrategy(String strategyId) async {
    await _client
        .from('trading_strategies')
        .delete()
        .eq('id', strategyId)
        .eq('user_id', _userId);
  }

  // Mappers
  Holding _mapToHolding(Map<String, dynamic> json) {
    return Holding(
      id: json['id'],
      userId: json['user_id'],
      symbol: json['symbol'],
      coinName: json['coin_name'],
      quantity: (json['quantity'] as num).toDouble(),
      averageBuyPrice: (json['average_buy_price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Transaction _mapToTransaction(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      userId: json['user_id'],
      holdingId: json['holding_id'],
      symbol: json['symbol'],
      type: TransactionType.values.firstWhere((e) => e.name == json['type']),
      quantity: (json['quantity'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
      totalValue: (json['total_value'] as num).toDouble(),
      notes: json['notes'],
      transactionDate: DateTime.parse(json['transaction_date']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  WatchlistItem _mapToWatchlistItem(Map<String, dynamic> json) {
    return WatchlistItem(
      id: json['id'],
      userId: json['user_id'],
      symbol: json['symbol'],
      coinName: json['coin_name'],
      targetPrice: json['target_price'] != null
          ? (json['target_price'] as num).toDouble()
          : null,
      alertEnabled: json['alert_enabled'] ?? false,
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  TradingStrategy _mapToStrategy(Map<String, dynamic> json) {
    return TradingStrategy(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      symbol: json['symbol'],
      tags: List<String>.from(json['tags'] ?? []),
      entryPrice: json['entry_price'] != null
          ? (json['entry_price'] as num).toDouble()
          : null,
      targetPrice: json['target_price'] != null
          ? (json['target_price'] as num).toDouble()
          : null,
      stopLoss: json['stop_loss'] != null
          ? (json['stop_loss'] as num).toDouble()
          : null,
      status: StrategyStatus.values.firstWhere((e) => e.name == json['status']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
