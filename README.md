# TradeGenius Market Feature - Technical Documentation

## Architecture Overview

The Market feature follows Clean Architecture principles with four distinct layers:

### 1. Domain Layer (`lib/features/market/domain/`)
**Purpose**: Contains business logic and entities (framework-independent)

#### Entities:
- **CryptoCoin**: Core cryptocurrency data model
  - Properties: symbol, name, currentPrice, priceChange24h, volume24h, marketCap, high24h, low24h, rank
  - Methods: `isPositiveChange`, `formattedPrice`, `formattedChange`

- **Candlestick**: OHLC (Open, High, Low, Close) data for charts
  - Properties: timestamp, open, high, low, close, volume
  - Methods: `isBullish`, `bodySize`, `upperWick`, `lowerWick`

- **ChartDrawing**: User-drawn technical analysis lines
  - Properties: id, type (support/resistance/trend), startPrice, endPrice, startIndex, endIndex

- **TimeInterval**: Chart timeframe enum (24H, 7D, 30D)

- **MarketResult**: Type-safe result wrapper (Success/Failure)

#### Repository Interface:
- `MarketRepository`: Defines data operations contract
  - `getTopCoins()`: Fetch top cryptocurrencies
  - `searchCoins()`: Search by name/symbol
  - `getTrendingCoins()`: Get highest movers
  - `getPriceHistory()`: Historical price data
  - `streamPrice()`: Real-time WebSocket updates

### 2. Data Layer (`lib/features/market/data/`)
**Purpose**: Implements data sources and repository

#### Data Sources:
- **BinanceDatasource**: Binance API integration
  - REST API: `https://api.binance.com/api/v3`
  - WebSocket: `wss://stream.binance.com:9443/ws`
  - Methods: `getTopCoins()`, `getCandlesticks()`, `streamPrice()`

- **DrawingStorage**: Local persistence using SharedPreferences
  - Saves/loads user drawings per coin
  - JSON serialization for ChartDrawing objects

#### Repository Implementation:
- **MarketRepositoryImpl**: Implements MarketRepository
  - Error handling with try-catch
  - Returns MarketResult (Success/Failure)

### 3. Application Layer (`lib/features/market/application/`)
**Purpose**: State management and business logic coordination

#### Controllers:
- **MarketController**: Manages market data state
  - State: MarketInitial → MarketLoading → MarketLoaded/MarketError
  - Methods: `loadMarketData()`, `searchCoins()`, `loadPriceHistory()`
  - Real-time streams: Manages WebSocket connections for top 20 coins

#### States:
- **MarketState**: Sealed class with 4 states
  - `MarketInitial`: Initial state
  - `MarketLoading`: Data fetching
  - `MarketLoaded`: Success with coins + trending
  - `MarketError`: Failure with error message

- **ChartState**: Separate state for price history charts

### 4. Presentation Layer (`lib/features/market/presentation/`)
**Purpose**: UI components and user interaction

#### Pages:
- **MarketScreen**: Main market overview
  - Search bar with real-time filtering
  - Trending coins horizontal scroll
  - Coin list with live price updates (top 20)
  - Pull-to-refresh functionality

- **CoinDetailScreen**: Advanced trading analysis
  - Interactive candlestick chart
  - Technical indicators (SMA20, RSI, Volume Ratio)
  - Drawing tools (Support, Resistance, Trend lines)
  - Multiple timeframes (24H, 7D, 30D)
  - Persistent drawings (saved locally)

#### Widgets:
- **CoinListItem**: Displays coin with live price flash animation
- **LivePriceText**: Real-time price with color flash on change
- **TrendingSection**: Horizontal scrollable trending coins
- **MarketSearchBar**: Custom search input
- **MarketStatsHeader**: Market overview stats
- **CandlestickChart**: Advanced interactive chart
  - Zoom: Pinch to zoom in/out (0.5x - 3x)
  - Pan: Drag to scroll horizontally
  - Volume bars: Display at bottom
  - Drawing tools: Tap to select, drag to draw
  - Move drawings: Tap line, then drag to reposition
  - Grid lines for better readability

## Data Flow



## Dependencies
- `http`: REST API calls
- `web_socket_channel`: WebSocket connections
- `fl_chart`: Chart rendering (optional, using custom painters)
- `shared_preferences`: Local storage
- `intl`: Date/time formatting

## Future Enhancements
- [ ] More technical indicators (MACD, Bollinger Bands)
- [ ] Fibonacci retracement tool
- [ ] Chart pattern recognition
- [
