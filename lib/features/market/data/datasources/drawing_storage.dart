// lib/features/market/data/datasources/drawing_storage.dart
// Why: Persist user drawings locally using SharedPreferences

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/chart_drawing.dart';

class DrawingStorage {
  static const _prefix = 'chart_drawings_';

  // Save drawings for a specific coin
  static Future<void> saveDrawings(String symbol, List<ChartDrawing> drawings) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix$symbol';
    final jsonList = drawings.map((d) => {
      'id': d.id,
      'type': d.type.name,
      'startPrice': d.startPrice,
      'endPrice': d.endPrice,
      'startIndex': d.startIndex,
      'endIndex': d.endIndex,
    }).toList();
    await prefs.setString(key, json.encode(jsonList));
  }

  // Load drawings for a specific coin
  static Future<List<ChartDrawing>> loadDrawings(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix$symbol';
    final jsonString = prefs.getString(key);
    
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) {
      return ChartDrawing(
        id: json['id'],
        type: DrawingType.values.firstWhere((e) => e.name == json['type']),
        startPrice: json['startPrice'],
        endPrice: json['endPrice'],
        startIndex: json['startIndex'],
        endIndex: json['endIndex'],
      );
    }).toList();
  }

  // Clear drawings for a specific coin
  static Future<void> clearDrawings(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$symbol');
  }
}
