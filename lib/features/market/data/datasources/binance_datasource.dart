// lib/features/market/data/datasources/binance_datasource.dart
// Why: Handles Binance API integration for real-time crypto data

// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../domain/entities/crypto_coin.dart';
import '../../domain/entities/price_point.dart';
import '../../domain/entities/time_interval.dart';

class BinanceDatasource {
  static const String _baseUrl = 'https://api.binance.com/api/v3';
  static const String _wsUrl = 'wss://stream.binance.com:9443/ws';
  final http.Client _client;

  BinanceDatasource({http.Client? client}) : _client = client ?? http.Client();

  // Fetch top coins with 24h ticker data
  Future<List<CryptoCoin>> getTopCoins({int limit = 50}) async {
    try {
      // Get 24h ticker for all USDT pairs
      final response = await _client.get(
        Uri.parse('$_baseUrl/ticker/24hr'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch coins: ${response.statusCode}');
      }

      final List<dynamic> data = json.decode(response.body);

      // Filter USDT pairs and convert to CryptoCoin
      final coins = data
          .where((item) => item['symbol'].toString().endsWith('USDT'))
          .map((item) => _mapToCryptoCoin(item))
          .toList();

      // Sort by volume (proxy for market cap) and take top N
      coins.sort((a, b) => b.volume24h.compareTo(a.volume24h));
      return coins.take(limit).toList();
    } catch (e) {
      throw Exception('Error fetching top coins: $e');
    }
  }

  // Get price history (klines/candlestick data)
  Future<List<PricePoint>> getPriceHistory({
    required String symbol,
    required TimeInterval interval,
  }) async {
    try {
      // Calculate limit based on interval
      final limit = interval == TimeInterval.hour24 ? 24 :
      interval == TimeInterval.days7 ? 42 : 30;

      final response = await _client.get(
        Uri.parse('$_baseUrl/klines').replace(queryParameters: {
          'symbol': '${symbol.toUpperCase()}USDT',
          'interval': interval.binanceInterval,
          'limit': limit.toString(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch price history');
      }

      final List<dynamic> data = json.decode(response.body);

      return data.map((candle) {
        return PricePoint(
          timestamp: DateTime.fromMillisecondsSinceEpoch(candle[0]),
          price: double.parse(candle[4]), // Close price
        );
      }).toList();
    } catch (e) {
      throw Exception('Error fetching price history: $e');
    }
  }

  // Stream real-time price updates via WebSocket
  Stream<double> streamPrice(String symbol) {
    final channel = WebSocketChannel.connect(
      Uri.parse('$_wsUrl/${symbol.toLowerCase()}usdt@trade'),
    );

    // Transform WebSocket stream to price stream
    return channel.stream.map((data) {
      final json = jsonDecode(data);
      return double.parse(json['p']); // 'p' is the price field
    }).handleError((error) {
      channel.sink.close();
      throw Exception('WebSocket error: $error');
    });
  }

  // Helper: Convert Binance API response to CryptoCoin
  CryptoCoin _mapToCryptoCoin(Map<String, dynamic> json) {
    final symbol = json['symbol'].toString().replaceAll('USDT', '');

    return CryptoCoin(
      symbol: symbol,
      name: _getCoinName(symbol), // Map symbol to full name
      currentPrice: double.parse(json['lastPrice']),
      priceChange24h: double.parse(json['priceChangePercent']),
      volume24h: double.parse(json['volume']) * double.parse(json['lastPrice']),
      marketCap: 0, // Binance doesn't provide market cap
      high24h: double.parse(json['highPrice']),
      low24h: double.parse(json['lowPrice']),
      rank: 0, // Will be set based on volume sorting
    );
  }

  // Helper: Map common symbols to full names
  String _getCoinName(String symbol) {
    const names = {
      'BTC': 'Bitcoin',
      'ETH': 'Ethereum',
      'BNB': 'Binance Coin',
      'XRP': 'Ripple',
      'ADA': 'Cardano',
      'DOGE': 'Dogecoin',
      'SOL': 'Solana',
      'DOT': 'Polkadot',
      'MATIC': 'Polygon',
      'AVAX': 'Avalanche',
    };
    return names[symbol] ?? symbol;
  }
}
