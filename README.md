# TradeGenius - Advanced Crypto Trading & Analysis Platform

## 📊 Project Overview

TradeGenius is a professional-grade cryptocurrency trading analysis application built with Flutter, featuring real-time market data, interactive candlestick charts, technical analysis tools, and AI-powered trading insights.

---

## 🏗️ Architecture

### Clean Architecture Layers

```
lib/
├── core/                    # Shared utilities, themes, routes
├── features/
    ├── auth/               # Authentication (Supabase)
    ├── market/             # Market data & charts ⭐
    ├── portfolio/          # User portfolio tracking
    ├── chat/               # AI trading assistant
    └── profile/            # User profile management
```

Each feature follows **Clean Architecture**:
- **Domain**: Business logic, entities, repository interfaces
- **Data**: API integration, data sources, repository implementations
- **Application**: State management, controllers
- **Presentation**: UI screens and widgets

---

## 📈 Market Feature - Deep Dive

### Architecture Overview

```
market/
├── domain/
│   ├── entities/
│   │   ├── crypto_coin.dart          # Coin data model
│   │   ├── candlestick.dart          # OHLC data
│   │   ├── chart_drawing.dart        # User drawings
│   │   ├── time_interval.dart        # Chart timeframes
│   │   └── market_result.dart        # Result wrapper
│   └── repositories/
│       └── market_repository.dart    # Data contract
├── data/
│   ├── datasources/
│   │   ├── binance_datasource.dart   # Binance API
│   │   └── drawing_storage.dart      # Local storage
│   └── repositories/
│       └── market_repository_impl.dart
├── application/
│   ├── market_controller.dart        # State management
│   └── market_state.dart             # State definitions
└── presentation/
    ├── pages/
    │   ├── market_screen.dart        # Main market view
    │   └── coin_detail_screen.dart   # Chart analysis
    └── widgets/
        ├── candlestick_chart.dart    # Interactive chart ⭐
        ├── animated_price_widget.dart # Live price animation
        ├── coin_list_item.dart
        ├── trending_section.dart
        └── market_search_bar.dart
```

---

## 🎨 Candlestick Chart Implementation (Learning Guide)

### Overview

The `CandlestickChart` widget is a fully custom, interactive chart built using Flutter's **CustomPainter** API. It demonstrates advanced Flutter concepts including gesture handling, custom rendering, animations, and state management.

### Key Flutter Concepts Used

#### 1. **CustomPainter - Drawing on Canvas**

Flutter's `CustomPainter` allows us to draw directly on a canvas using low-level drawing APIs.

```dart
class CandlestickPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Drawing logic here
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

**Why CustomPainter?**
- Full control over rendering
- High performance for complex graphics
- Ability to create custom chart types
- Direct access to Canvas API

#### 2. **Canvas Drawing Methods**

We use various Canvas methods to draw chart elements:

```dart
// Draw lines (wicks of candlesticks)
canvas.drawLine(
  Offset(x, highY),
  Offset(x, lowY),
  Paint()..color = Colors.green..strokeWidth = 1.5,
);

// Draw rectangles (bodies of candlesticks)
canvas.drawRect(
  Rect.fromLTWH(x, y, width, height),
  Paint()..color = Colors.red..style = PaintingStyle.fill,
);

// Draw circles (drawing handles)
canvas.drawCircle(
  Offset(x, y),
  radius,
  Paint()..color = Colors.blue,
);

// Draw text (price labels)
final textPainter = TextPainter(
  text: TextSpan(text: '\$1234.56', style: TextStyle(...)),
  textDirection: TextDirection.ltr,
);
textPainter.layout();
textPainter.paint(canvas, Offset(x, y));
```

#### 3. **Coordinate System Transformation**

Converting between screen coordinates and data values:

```dart
// Price to Y coordinate
final priceRange = maxPrice - minPrice;
final y = size.height - ((price - minPrice) / priceRange * size.height);

// X coordinate from candle index
final candleWidth = size.width / candles.length;
final x = index * candleWidth + candleWidth / 2;

// Screen coordinate to price
final price = maxPrice - (screenY / size.height * priceRange);
```

**Why this matters:**
- Charts display data in a coordinate system (price vs time)
- Screen uses pixel coordinates (x, y)
- We must convert between these systems for accurate rendering

#### 4. **Gesture Detection - Multi-touch Interactions**

Flutter's `GestureDetector` handles complex touch interactions:

```dart
GestureDetector(
  onScaleStart: _onScaleStart,      // Touch begins
  onScaleUpdate: _onScaleUpdate,    // Touch moves (zoom/pan)
  onScaleEnd: _onScaleEnd,          // Touch ends
  onTapDown: _onTapDown,            // Single tap
  child: chartWidget,
)
```

**Gesture Handling Logic:**

```dart
void _onScaleUpdate(ScaleUpdateDetails details, double width, double height) {
  if (widget.activeDrawingTool != null) {
    // DRAWING MODE: User is drawing a line
    final localPos = Offset(
      (details.localFocalPoint.dx - _offset.dx) / _scale,
      details.localFocalPoint.dy,
    );
    setState(() => _drawEnd = localPos);
    
  } else if (_selectedDrawing != null) {
    // MOVE MODE: User is moving an existing line
    final delta = details.localFocalPoint - _dragStart!;
    final priceDelta = -(delta.dy / height) * priceRange;
    // Update drawing position
    
  } else {
    // ZOOM/PAN MODE: User is navigating the chart
    setState(() {
      _scale = (_previousScale * details.scale).clamp(0.5, 3.0);
      _offset = _previousOffset + (details.focalPoint - details.localFocalPoint);
    });
  }
}
```

**Why multiple modes?**
- Different user intentions require different behaviors
- Drawing tool active = drawing mode
- Line selected = move mode
- Otherwise = navigation mode

#### 5. **Transform Matrix - Zoom & Pan**

Flutter's `Transform` widget applies matrix transformations:

```dart
Transform(
  transform: Matrix4.identity()
    ..translate(_offset.dx, 0.0)    // Pan horizontally
    ..scale(_scale, 1.0),           // Zoom horizontally only
  child: chartContent,
)
```

**Matrix Transformations:**
- `translate()`: Moves content (panning)
- `scale()`: Resizes content (zooming)
- Applied to both chart and volume bars for consistency

**Why only horizontal zoom?**
- Price axis (vertical) should remain fixed
- Time axis (horizontal) benefits from zoom
- Maintains readability of price labels

#### 6. **LayoutBuilder - Responsive Sizing**

`LayoutBuilder` provides parent constraints for responsive layouts:

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final volumeHeight = 60.0;
    final chartHeight = constraints.maxHeight - volumeHeight - 40;
    final chartWidth = constraints.maxWidth - 80;
    
    return Stack(
      children: [
        // Chart positioned based on calculated dimensions
        Positioned(
          left: 0,
          top: 0,
          right: 80,  // Reserve space for price axis
          bottom: volumeHeight + 40,
          child: chartArea,
        ),
      ],
    );
  },
)
```

**Why LayoutBuilder?**
- Charts must adapt to different screen sizes
- Calculate available space dynamically
- Reserve space for axes and volume bars

#### 7. **ClipRect - Boundary Enforcement**

`ClipRect` prevents content from overflowing:

```dart
ClipRect(
  child: Transform(
    transform: zoomPanMatrix,
    child: chartContent,
  ),
)
```

**Why ClipRect?**
- Zoomed/panned content can exceed boundaries
- Prevents candlesticks from overlapping price axis
- Maintains clean visual boundaries

#### 8. **State Management - setState()**

Managing chart state for interactivity:

```dart
class _CandlestickChartState extends State<CandlestickChart> {
  double _scale = 1.0;              // Current zoom level
  Offset _offset = Offset.zero;     // Current pan position
  ChartDrawing? _selectedDrawing;   // Currently selected line
  
  void _onScaleUpdate(...) {
    setState(() {
      _scale = newScale;
      _offset = newOffset;
    });
  }
}
```

**State Variables:**
- `_scale`: Zoom level (0.5x to 3.0x)
- `_offset`: Pan position (horizontal scroll)
- `_selectedDrawing`: Which line is selected
- `_drawStart/_drawEnd`: Drawing preview coordinates

#### 9. **Custom Painters - Layered Rendering**

Multiple painters create layered chart elements:

```dart
Stack(
  children: [
    CustomPaint(painter: GridPainter(...)),        // Layer 1: Grid
    CustomPaint(painter: CandlestickPainter(...)), // Layer 2: Candles
    CustomPaint(painter: DrawingsPainter(...)),    // Layer 3: User lines
    CustomPaint(painter: DrawingPreviewPainter(...)), // Layer 4: Preview
  ],
)
```

**Painter Responsibilities:**

**GridPainter:**
```dart
void paint(Canvas canvas, Size size) {
  // Draw horizontal lines (price levels)
  for (int i = 0; i <= 5; i++) {
    final y = size.height * i / 5;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
  
  // Draw vertical lines (time divisions)
  for (int i = 0; i <= 4; i++) {
    final x = size.width * i / 4;
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
  }
}
```

**CandlestickPainter:**
```dart
void paint(Canvas canvas, Size size) {
  for (int i = 0; i < candles.length; i++) {
    final candle = candles[i];
    
    // Calculate positions
    final x = i * candleWidth + candleWidth / 2;
    final openY = priceToY(candle.open);
    final closeY = priceToY(candle.close);
    final highY = priceToY(candle.high);
    final lowY = priceToY(candle.low);
    
    // Draw wick (high-low line)
    canvas.drawLine(Offset(x, highY), Offset(x, lowY), wickPaint);
    
    // Draw body (open-close rectangle)
    final bodyTop = candle.isBullish ? closeY : openY;
    final bodyBottom = candle.isBullish ? openY : closeY;
    canvas.drawRect(
      Rect.fromLTWH(x - bodyWidth/2, bodyTop, bodyWidth, bodyBottom - bodyTop),
      bodyPaint,
    );
  }
}
```

**DrawingsPainter:**
```dart
void paint(Canvas canvas, Size size) {
  for (final drawing in drawings) {
    // Calculate line endpoints
    final startY = priceToY(drawing.startPrice);
    final endY = priceToY(drawing.endPrice);
    final startX = indexToX(drawing.startIndex);
    final endX = indexToX(drawing.endIndex);
    
    // Draw line
    canvas.drawLine(Offset(startX, startY), Offset(endX, endY), linePaint);
    
    // Draw handles if selected
    if (isSelected) {
      canvas.drawCircle(Offset(startX, startY), 6, handlePaint);
      canvas.drawCircle(Offset(endX, endY), 6, handlePaint);
    }
    
    // Draw price label
    textPainter.paint(canvas, Offset(startX + 5, startY - 15));
  }
}
```

**VolumePainter:**
```dart
void paint(Canvas canvas, Size size) {
  final maxVolume = candles.map((c) => c.volume).reduce(max);
  
  for (int i = 0; i < candles.length; i++) {
    final candle = candles[i];
    final x = i * candleWidth;
    final barHeight = (candle.volume / maxVolume) * size.height;
    final color = candle.isBullish ? Colors.green : Colors.red;
    
    canvas.drawRect(
      Rect.fromLTWH(x, size.height - barHeight, candleWidth * 0.8, barHeight),
      Paint()..color = color.withOpacity(0.5),
    );
  }
}
```

#### 10. **Animation - Real-time Price Updates**

`AnimatedPriceWidget` uses `AnimationController` for smooth transitions:

```dart
class _AnimatedPriceWidgetState extends State<AnimatedPriceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _colorAnimation = ColorTween(
      begin: Colors.green.withOpacity(0.3),
      end: Colors.transparent,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }
  
  @override
  void didUpdateWidget(AnimatedPriceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.price != widget.price) {
      _controller.forward(from: 0);  // Trigger animation
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: _colorAnimation.value,  // Animated background
          ),
          child: Text('\$${widget.price}'),
        );
      },
    );
  }
}
```

**Animation Flow:**
1. Price changes (WebSocket update)
2. `didUpdateWidget` detects change
3. Animation controller starts from 0
4. Color transitions from green/red to transparent
5. Creates "flash" effect over 500ms

---

## 🔄 Real-time Data Flow

### WebSocket Integration

```dart
// Binance WebSocket connection
Stream<double> streamPrice(String symbol) {
  final channel = WebSocketChannel.connect(
    Uri.parse('wss://stream.binance.com:9443/ws/${symbol.toLowerCase()}usdt@trade'),
  );
  
  return channel.stream.map((data) {
    final json = jsonDecode(data);
    return double.parse(json['p']);  // Extract price
  });
}
```

**Data Flow:**
1. WebSocket connects to Binance
2. Receives trade events in real-time
3. Extracts price from JSON
4. Emits to Stream
5. UI listens via StreamBuilder
6. AnimatedPriceWidget updates with flash effect

### StreamBuilder Usage

```dart
StreamBuilder<double>(
  stream: _datasource.streamPrice('BTC'),
  initialData: coin.currentPrice,
  builder: (context, snapshot) {
    return AnimatedPriceWidget(
      price: snapshot.data ?? coin.currentPrice,
    );
  },
)
```

---

## 💾 Data Persistence

### Drawing Storage (SharedPreferences)

```dart
class DrawingStorage {
  static Future<void> saveDrawings(String symbol, List<ChartDrawing> drawings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = drawings.map((d) => {
      'id': d.id,
      'type': d.type.name,
      'startPrice': d.startPrice,
      'endPrice': d.endPrice,
      'startIndex': d.startIndex,
      'endIndex': d.endIndex,
    }).toList();
    await prefs.setString('chart_drawings_$symbol', json.encode(jsonList));
  }
  
  static Future<List<ChartDrawing>> loadDrawings(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('chart_drawings_$symbol');
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => ChartDrawing.fromJson(json)).toList();
  }
}
```

**Persistence Flow:**
1. User draws support/resistance line
2. `onDrawingAdded` callback triggered
3. Drawing added to state list
4. `saveDrawings()` serializes to JSON
5. Stored in SharedPreferences with coin symbol as key
6. On screen reload, `loadDrawings()` restores lines

---

## 🎯 Technical Indicators

### Simple Moving Average (SMA)

```dart
final closes = candles.map((c) => c.close).toList();
final sma20 = closes.take(20).reduce((a, b) => a + b) / 20;
```

### Relative Strength Index (RSI)

```dart
double rsi = 50;
if (closes.length >= 14) {
  double gains = 0, losses = 0;
  for (int i = 1; i < 14; i++) {
    final change = closes[i] - closes[i - 1];
    if (change > 0) gains += change;
    else losses += change.abs();
  }
  final avgGain = gains / 14;
  final avgLoss = losses / 14;
  if (avgLoss != 0) {
    final rs = avgGain / avgLoss;
    rsi = 100 - (100 / (1 + rs));
  }
}
```

### Volume Ratio

```dart
final avgVolume = candles.take(20).map((c) => c.volume).reduce((a, b) => a + b) / 20;
final currentVolume = candles.first.volume;
final volumeRatio = currentVolume / avgVolume;
```

---

## 🎮 User Interactions

### Chart Navigation
- **Pinch to Zoom**: Two-finger pinch gesture (0.5x - 3.0x)
- **Drag to Pan**: Single-finger horizontal scroll
- **Tap to Select**: Tap drawing line to select (shows handles)

### Drawing Tools
- **Support Line**: Green horizontal line marking support level
- **Resistance Line**: Red horizontal line marking resistance level
- **Trend Line**: Blue diagonal line showing trend direction

### Drawing Workflow
1. Tap tool button (Support/Resistance/Trend)
2. Tool activates (button highlighted)
3. Drag on chart to draw line
4. Release to finalize
5. Line saved automatically
6. Tool deactivates

### Moving Drawings
1. Tap existing line (handles appear)
2. Drag up/down to adjust price level
3. Release to finalize
4. New position saved automatically

---

## 📊 Performance Optimizations

### 1. **Efficient Rendering**
- Only redraw when data changes (`shouldRepaint`)
- Use `const` constructors where possible
- Minimize widget rebuilds with `ValueListenableBuilder`

### 2. **Stream Management**
- Limit WebSocket connections (top 20 coins only)
- Cancel streams on dispose
- Use broadcast streams for multiple listeners

### 3. **Data Caching**
- Cache candlestick data per timeframe
- Store drawings locally (SharedPreferences)
- Avoid redundant API calls

### 4. **Gesture Optimization**
- Debounce rapid gesture updates
- Clamp zoom/pan values
- Use `ClipRect` to prevent overdraw

---

## 🚀 Getting Started

### Prerequisites
```bash
flutter --version  # Flutter 3.9.2+
dart --version     # Dart 3.9.2+
```

### Installation
```bash
git clone https://github.com/yourusername/tradegenius.git
cd tradegenius
flutter pub get
flutter run
```

### Configuration
Create `.env` file:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
```

---

## 📚 Key Learnings

### Flutter Concepts Demonstrated
1. **CustomPainter**: Low-level canvas drawing
2. **GestureDetector**: Multi-touch gesture handling
3. **Transform**: Matrix transformations for zoom/pan
4. **LayoutBuilder**: Responsive sizing
5. **AnimationController**: Smooth transitions
6. **StreamBuilder**: Real-time data updates
7. **SharedPreferences**: Local data persistence
8. **Clean Architecture**: Separation of concerns
9. **State Management**: ValueNotifier pattern
10. **WebSocket**: Real-time communication

### Best Practices Applied
- ✅ Clean Architecture (Domain/Data/Application/Presentation)
- ✅ SOLID principles
- ✅ Type-safe error handling (Result pattern)
- ✅ Responsive design (LayoutBuilder)
- ✅ Performance optimization (shouldRepaint, const)
- ✅ Code documentation (inline comments)
- ✅ Modular widgets (single responsibility)

---

## 🔮 Future Enhancements

- [ ] More technical indicators (MACD, Bollinger Bands, Fibonacci)
- [ ] Chart pattern recognition (Head & Shoulders, Triangles)
- [ ] Multiple chart types (Line, Area, Heikin-Ashi)
- [ ] Drawing templates (save/load drawing sets)
- [ ] Price alerts (notify on price levels)
- [ ] Export charts as images
- [ ] Multi-timeframe analysis
- [ ] Backtesting capabilities

---

## 📄 License

MIT License - See LICENSE file for details

---

## 👥 Contributing

Contributions welcome! Please read CONTRIBUTING.md first.

---

## 📞 Support

- Documentation: [docs.tradegenius.com](https://docs.tradegenius.com)
- Issues: [GitHub Issues](https://github.com/yourusername/tradegenius/issues)
- Discord: [Join Community](https://discord.gg/tradegenius)

---

**Built with ❤️ using Flutter**
