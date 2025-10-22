// Why: Type-safe state management for watchlist
// Pattern: Sealed class with pattern matching

import '../domain/entities/watchlist_item.dart';

sealed class WatchlistState {
  const WatchlistState();
}

class WatchlistInitial extends WatchlistState {
  const WatchlistInitial();
}

class WatchlistLoading extends WatchlistState {
  const WatchlistLoading();
}

class WatchlistLoaded extends WatchlistState {
  final List<WatchlistItem> items;

  const WatchlistLoaded({required this.items});
}

class WatchlistError extends WatchlistState {
  final String message;
  const WatchlistError(this.message);
}
