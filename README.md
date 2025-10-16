# tradegenius

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# TradeGenius - Bottom Navigation Features

## Overview
TradeGenius implements a 4-tab bottom navigation system for comprehensive crypto trading and learning experience.

## Architecture

### Clean Architecture Layers

Each feature follows:
- **Domain**: Business logic, entities, repository interfaces
- **Data**: API integration, data sources, repository implementations
- **Application**: State management, controllers
- **Presentation**: UI screens and widgets

## Features

### 1. 📊 Portfolio
**Purpose**: Track investments and trading strategies

**Entities**:
- `Coin`: Cryptocurrency with user-specific data
- `Watchlist`: Collection of tracked coins
- `Strategy`: Trading strategy notes and performance

**Key Functionality**:
- Add/remove coins to watchlist
- Record trading strategies
- Track portfolio performance
- View profit/loss analytics

**Data Source**: Supabase (user data) + Market API (prices)

---

### 2. 📈 Market
**Purpose**: Real-time crypto market data and trends

**Entities**:
- `CryptoCoin`: Coin with market data (price, volume, change)
- `MarketTrend`: Overall market sentiment
- `PriceChart`: Historical price data points

**Key Functionality**:
- Live crypto prices
- Market cap rankings
- Price charts (24h, 7d, 30d)
- Search and filter coins
- Trending coins

**Data Source**: CoinGecko API / CoinMarketCap API

**API Integration**:
```dart
// Free tier: 50 calls/minute
// Endpoint: https://api.coingecko.com/api/v3/
3. 💬 Chat (AI Assistant)
Purpose: AI-powered crypto learning and trading assistant

Entities:

Message: User/AI message with timestamp

Conversation: Chat session history

AIResponse: Structured AI response with sources

Key Functionality:

Ask crypto-related questions

Learn trading concepts

Get market analysis

Understand blockchain technology

Trading strategy suggestions

Data Source: OpenAI API / Google Gemini API

AI Integration:

// Model: GPT-3.5-turbo or Gemini Pro
// Context: Crypto trading, blockchain, market analysis


lib/
├── core/
│   ├── navigation/
│   │   ├── bottom_nav_bar.dart              # Main bottom navigation widget
│   │   ├── nav_item.dart                    # Navigation item model
│   │   └── navigation_controller.dart       # Navigation state management
│   └── widgets/
│       └── app_scaffold.dart                # Scaffold with bottom nav
│
├── features/
│   ├── portfolio/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── coin.dart                # Coin entity
│   │   │   │   ├── watchlist.dart           # Watchlist entity
│   │   │   │   └── strategy.dart            # Trading strategy entity
│   │   │   └── repositories/
│   │   │       └── portfolio_repository.dart
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── portfolio_datasource.dart
│   │   │   └── repositories/
│   │   │       └── portfolio_repository_impl.dart
│   │   ├── application/
│   │   │   ├── portfolio_controller.dart
│   │   │   └── portfolio_state.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── portfolio_screen.dart
│   │       └── widgets/
│   │           ├── watchlist_card.dart
│   │           ├── strategy_card.dart
│   │           └── coin_item.dart
│   │
│   ├── market/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── crypto_coin.dart         # Crypto coin with market data
│   │   │   │   ├── market_trend.dart        # Market trend data
│   │   │   │   └── price_chart.dart         # Chart data points
│   │   │   └── repositories/
│   │   │       └── market_repository.dart
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── market_api_datasource.dart  # CoinGecko/CoinMarketCap API
│   │   │   └── repositories/
│   │   │       └── market_repository_impl.dart
│   │   ├── application/
│   │   │   ├── market_controller.dart
│   │   │   └── market_state.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── market_screen.dart
│   │       └── widgets/
│   │           ├── coin_list_item.dart
│   │           ├── market_chart.dart
│   │           ├── trend_indicator.dart
│   │           └── search_bar.dart
│   │
│   ├── chat/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── message.dart             # Chat message entity
│   │   │   │   ├── conversation.dart        # Conversation entity
│   │   │   │   └── ai_response.dart         # AI response entity
│   │   │   └── repositories/
│   │   │       └── chat_repository.dart
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── ai_chat_datasource.dart  # OpenAI/Gemini API integration
│   │   │   └── repositories/
│   │   │       └── chat_repository_impl.dart
│   │   ├── application/
│   │   │   ├── chat_controller.dart
│   │   │   └── chat_state.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── chat_screen.dart
│   │       └── widgets/
│   │           ├── message_bubble.dart
│   │           ├── chat_input.dart
│   │           ├── typing_indicator.dart
│   │           └── suggested_questions.dart
│   │
│   └── profile/
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── user_profile.dart        # Extended user profile
│       │   │   └── user_settings.dart       # User preferences
│       │   └── repositories/
│       │       └── profile_repository.dart
│       ├── data/
│       │   ├── datasources/
│       │   │   └── profile_datasource.dart
│       │   └── repositories/
│       │       └── profile_repository_impl.dart
│       ├── application/
│       │   ├── profile_controller.dart
│       │   └── profile_state.dart
│       └── presentation/
│           ├── pages/
│           │   └── profile_screen.dart
│           └── widgets/
│               ├── profile_header.dart
│               ├── settings_section.dart
│               ├── stats_card.dart
│               └── theme_toggle.dart
