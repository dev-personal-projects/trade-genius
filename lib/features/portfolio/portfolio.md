---

## 💼 Portfolio Feature - Technical Documentation

### Overview

The Portfolio feature enables users to track cryptocurrency investments, record transactions, monitor performance, and manage trading strategies. All data is securely stored in Supabase with real-time price updates from Binance.

---

### 🎯 Core Features

#### 1. **Holdings Management**
Track owned cryptocurrencies with real-time valuations

- Add/Edit/Delete holdings
- Track quantity and average purchase price
- Real-time current value calculation
- Profit/Loss tracking per holding
- Visual allocation breakdown

#### 2. **Transaction History**
Complete record of all trading activities

**Transaction Types:**
- **Buy**: Purchase cryptocurrency
- **Sell**: Sell cryptocurrency
- **Transfer In**: Receive from external wallet
- **Transfer Out**: Send to external wallet

**Tracked Data:** Date/time, quantity, price, fees, total value, notes

#### 3. **Watchlist**
Monitor coins without owning them

- Add coins to watchlist
- Set target price alerts
- Quick conversion to holdings
- Personal notes per coin

#### 4. **Performance Analytics**
Comprehensive portfolio insights

- Total portfolio value
- Overall profit/loss ($ and %)
- 24-hour change
- Best/worst performers
- ROI per holding
- Allocation percentages

#### 5. **Trading Strategies**
Document and track trading plans

- Title and description
- Entry/target/stop-loss prices
- Tags (swing, day-trade, HODL)
- Status tracking
- Coin-specific or general strategies

---

### 🗄️ Database Schema (Supabase)

#### Holdings Table
```sql
CREATE TABLE holdings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  symbol TEXT NOT NULL,
  coin_name TEXT NOT NULL,
  quantity DECIMAL(20, 8) NOT NULL,
  average_buy_price DECIMAL(20, 8) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  holding_id UUID REFERENCES holdings(id) ON DELETE SET NULL,
  symbol TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('buy', 'sell', 'transfer_in', 'transfer_out')),
  quantity DECIMAL(20, 8) NOT NULL,
  price DECIMAL(20, 8) NOT NULL,
  fee DECIMAL(20, 8) DEFAULT 0,
  total_value DECIMAL(20, 8) NOT NULL,
  notes TEXT,
  transaction_date TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);


CREATE TABLE watchlist (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  symbol TEXT NOT NULL,
  coin_name TEXT NOT NULL,
  target_price DECIMAL(20, 8),
  alert_enabled BOOLEAN DEFAULT false,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, symbol)
);

CREATE TABLE trading_strategies (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  symbol TEXT,
  tags TEXT[] DEFAULT '{}',
  entry_price DECIMAL(20, 8),
  target_price DECIMAL(20, 8),
  stop_loss DECIMAL(20, 8),
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

### entities
class Holding {
  final String id;
  final String symbol;
  final double quantity;
  final double averageBuyPrice;
  
  // Calculated fields
  double currentPrice = 0.0;
  double get currentValue => quantity * currentPrice;
  double get totalCost => quantity * averageBuyPrice;
  double get profitLoss => currentValue - totalCost;
  double get profitLossPercentage => (profitLoss / totalCost) * 100;
}


enum TransactionType { buy, sell, transferIn, transferOut }

class Transaction {
  final String id;
  final String symbol;
  final TransactionType type;
  final double quantity;
  final double price;
  final double fee;
  final double totalValue;
  final DateTime transactionDate;
}


User Action → Controller → Repository → Supabase
                ↓
         Update State
                ↓
         UI Rebuilds
                ↓
    Fetch Live Prices (Binance)
                ↓
    Calculate P/L & Display

