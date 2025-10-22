// lib/features/market/data/datasources/binance_datasource.dart
// Why: Handles Binance API integration for real-time crypto data

// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../domain/entities/candlestick.dart';
import '../../domain/entities/crypto_coin.dart';
import '../../domain/entities/price_point.dart';
import '../../domain/entities/time_interval.dart';

class BinanceDatasource {
  static const String _baseUrl = 'https://api.binance.com/api/v3';
  static const String _wsUrl = 'wss://stream.binance.com:9443/ws';
  final http.Client _client;

  BinanceDatasource({http.Client? client}) : _client = client ?? http.Client();

  // Fetch top coins with 24h ticker data
  Future<List<CryptoCoin>> getTopCoins({int limit = 200}) async {
    try {
      final response = await _client.get(Uri.parse('$_baseUrl/ticker/24hr'));

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch coins: ${response.statusCode}');
      }

      final List<dynamic> data = json.decode(response.body);

      final coins = data
          .where((item) => item['symbol'].toString().endsWith('USDT'))
          .map((item) => _mapToCryptoCoin(item))
          .toList();

      coins.sort((a, b) => b.volume24h.compareTo(a.volume24h));
      return coins.take(limit).toList();
    } catch (e) {
      throw Exception('Error fetching top coins: $e');
    }
  }

  // Get candlestick data for charts
  Future<List<Candlestick>> getCandlesticks({
    required String symbol,
    required TimeInterval interval,
    int limit = 100,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/klines').replace(
          queryParameters: {
            'symbol': '${symbol.toUpperCase()}USDT',
            'interval': interval.binanceInterval,
            'limit': limit.toString(),
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch candlesticks');
      }

      final List<dynamic> data = json.decode(response.body);

      return data.map((candle) {
        return Candlestick(
          timestamp: DateTime.fromMillisecondsSinceEpoch(candle[0]),
          open: double.parse(candle[1].toString()),
          high: double.parse(candle[2].toString()),
          low: double.parse(candle[3].toString()),
          close: double.parse(candle[4].toString()),
          volume: double.parse(candle[5].toString()),
        );
      }).toList();
    } catch (e) {
      throw Exception('Error fetching candlesticks: $e');
    }
  }

  // Get price history (klines/candlestick data)
  Future<List<PricePoint>> getPriceHistory({
    required String symbol,
    required TimeInterval interval,
  }) async {
    try {
      final limit = interval == TimeInterval.hour24
          ? 24
          : interval == TimeInterval.days7
          ? 42
          : 30;

      final response = await _client.get(
        Uri.parse('$_baseUrl/klines').replace(
          queryParameters: {
            'symbol': '${symbol.toUpperCase()}USDT',
            'interval': interval.binanceInterval,
            'limit': limit.toString(),
          },
        ),
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

    return channel.stream
        .map((data) {
          final json = jsonDecode(data);
          return double.parse(json['p']);
        })
        .distinct() // Remove duplicates
        .cast<double>() // Cast to ensure type safety
        .handleError((error) {
          channel.sink.close();
          throw Exception('WebSocket error: $error');
        });
  }

  CryptoCoin _mapToCryptoCoin(Map<String, dynamic> json) {
    final symbol = json['symbol'].toString().replaceAll('USDT', '');

    return CryptoCoin(
      symbol: symbol,
      name: _getCoinName(symbol),
      currentPrice: double.parse(json['lastPrice']),
      priceChange24h: double.parse(json['priceChangePercent']),
      volume24h: double.parse(json['volume']) * double.parse(json['lastPrice']),
      marketCap: 0,
      high24h: double.parse(json['highPrice']),
      low24h: double.parse(json['lowPrice']),
      rank: 0,
    );
  }

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
