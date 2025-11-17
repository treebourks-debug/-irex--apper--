# TIREX SAPPER - Technical Architecture

## 🏗️ System Architecture

### Overview
TIREX SAPPER is a modular, event-driven MQL5 Expert Advisor built on a multi-layered architecture that separates concerns between market analysis, signal generation, risk management, and trade execution.

---

## 📐 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    TIREX SAPPER EA                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌───────────────────────────────────────────────────┐     │
│  │              OnTick() - Main Loop                 │     │
│  │  • Time filter check                              │     │
│  │  • Daily risk check                               │     │
│  │  • Trailing stop updates                          │     │
│  │  • New bar detection                              │     │
│  └───────────┬───────────────────────────────────────┘     │
│              │                                             │
│              ▼                                             │
│  ┌───────────────────────────────────────────────────┐     │
│  │        Market Data Collection Layer               │     │
│  │  • Trend MA (50)                                  │     │
│  │  • Fast MA (20)                                   │     │
│  │  • Slow MA (50)                                   │     │
│  │  • RSI (14)                                       │     │
│  │  • ATR (14)                                       │     │
│  │  • Current Price (Bid/Ask)                        │     │
│  └───────────┬───────────────────────────────────────┘     │
│              │                                             │
│              ▼                                             │
│  ┌───────────────────────────────────────────────────┐     │
│  │          Trend Detection Module                   │     │
│  │  • Compare Fast vs Slow MA                        │     │
│  │  • Check price vs Trend MA                        │     │
│  │  • Determine market direction                     │     │
│  │  Returns: +1 (Up), -1 (Down), 0 (Sideways)       │     │
│  └───────────┬───────────────────────────────────────┘     │
│              │                                             │
│              ▼                                             │
│  ┌───────────────────────────────────────────────────┐     │
│  │          Signal Generation Module                 │     │
│  │  • Check pullback conditions                      │     │
│  │  • Verify RSI confirmation                        │     │
│  │  • Validate price levels                          │     │
│  │  Returns: Buy signal / Sell signal / No signal   │     │
│  └───────────┬───────────────────────────────────────┘     │
│              │                                             │
│              ▼                                             │
│  ┌───────────────────────────────────────────────────┐     │
│  │          Risk Management Module                   │     │
│  │  • Calculate position size                        │     │
│  │  • Check daily risk limit                         │     │
│  │  • Validate lot size constraints                  │     │
│  │  • Calculate SL/TP levels                         │     │
│  └───────────┬───────────────────────────────────────┘     │
│              │                                             │
│              ▼                                             │
│  ┌───────────────────────────────────────────────────┐     │
│  │        Position Management Module                 │     │
│  │  • Count existing positions                       │     │
│  │  • Check grid eligibility                         │     │
│  │  • Manage position limits                         │     │
│  └───────────┬───────────────────────────────────────┘     │
│              │                                             │
│              ▼                                             │
│  ┌───────────────────────────────────────────────────┐     │
│  │          Trade Execution Module                   │     │
│  │  • Place market orders                            │     │
│  │  • Set SL/TP levels                               │     │
│  │  • Handle order errors                            │     │
│  │  • Log trade information                          │     │
│  └───────────┬───────────────────────────────────────┘     │
│              │                                             │
│              ▼                                             │
│  ┌───────────────────────────────────────────────────┐     │
│  │          Grid Management Module                   │     │
│  │  • Monitor price distance                         │     │
│  │  • Calculate grid entry points                    │     │
│  │  • Execute grid orders                            │     │
│  │  • Track grid levels                              │     │
│  └───────────┬───────────────────────────────────────┘     │
│              │                                             │
│              ▼                                             │
│  ┌───────────────────────────────────────────────────┐     │
│  │        Stop Management Module                     │     │
│  │  • Update trailing stops                          │     │
│  │  • Modify existing positions                      │     │
│  │  • Protect profits                                │     │
│  └───────────────────────────────────────────────────┘     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🧩 Component Details

### 1. Initialization Module (OnInit)
**Purpose**: Set up the EA environment and validate configuration

**Functions**:
- `OnInit()`: Main initialization routine

**Responsibilities**:
- Load symbol properties (point, tick value, lot step)
- Create indicator handles (MAs, RSI, ATR)
- Validate configuration parameters
- Initialize global variables
- Set up daily P&L tracking

**Error Handling**:
- Check indicator handle validity
- Return INIT_FAILED on critical errors
- Log initialization status

---

### 2. Market Data Layer
**Purpose**: Collect and organize market information

**Functions**:
- `GetIndicatorData()`: Retrieve indicator values

**Data Sources**:
- Trend MA buffer
- Fast MA buffer
- Slow MA buffer
- RSI buffer
- ATR buffer
- Real-time price (Bid/Ask)

**Data Format**:
- Arrays set as series (most recent = index 0)
- Normalized to symbol digits
- Validated before use

---

### 3. Trend Detection Module
**Purpose**: Identify market direction

**Functions**:
- `DetermineTrend()`: Analyze trend direction

**Algorithm**:
```
IF (Fast MA > Slow MA) AND (Price > Trend MA)
    THEN Uptrend (+1)
ELSE IF (Fast MA < Slow MA) AND (Price < Trend MA)
    THEN Downtrend (-1)
ELSE
    No clear trend (0)
```

**Filters**:
- Multiple MA confirmation
- Price position validation
- Trend strength assessment

---

### 4. Signal Generation Module
**Purpose**: Generate trading signals based on pullback logic

**Functions**:
- `CheckBuySignal()`: Identify buy opportunities
- `CheckSellSignal()`: Identify sell opportunities

**Buy Signal Logic**:
```
Conditions:
1. Uptrend detected (from Trend Module)
2. Price ≤ Slow MA (pullback)
3. Price ≥ Slow MA - (ATR × Pullback%)
4. RSI > Oversold level (recovering)
5. RSI < 50 (not overbought)
```

**Sell Signal Logic**:
```
Conditions:
1. Downtrend detected (from Trend Module)
2. Price ≥ Slow MA (pullback)
3. Price ≤ Slow MA + (ATR × Pullback%)
4. RSI < Overbought level (recovering)
5. RSI > 50 (not oversold)
```

---

### 5. Risk Management Module
**Purpose**: Control exposure and protect capital

**Functions**:
- `CalculateLotSize()`: Determine position size
- `CalculateStopLoss()`: Set stop loss level
- `CalculateTakeProfit()`: Set take profit level
- `UpdateDailyPnL()`: Track daily performance
- `IsDailyRiskExceeded()`: Check risk limits

**Position Sizing Algorithm**:
```
IF Fixed Lot Size > 0
    THEN Use fixed lot size
ELSE
    Risk Amount = Balance × (Risk% / 100)
    Points to SL = SL Distance / Point Size
    Lot Size = Risk Amount / (Points to SL × Tick Value)
    Normalize to broker constraints
```

**Stop Loss Calculation**:
```
IF Dynamic SL enabled
    THEN SL Distance = ATR × Dynamic SL Multiplier
ELSE
    SL Distance = Fixed SL Points × Point Size

For BUY: SL = Entry Price - SL Distance
For SELL: SL = Entry Price + SL Distance
```

**Daily Risk Control**:
```
Track all positions and closed trades for current day
IF Daily Loss > (Balance × Max Daily Risk%)
    THEN Block new trades
```

---

### 6. Position Management Module
**Purpose**: Manage open positions and track status

**Functions**:
- `CountPositions()`: Count positions by type
- `GetLastEntryPrice()`: Get last position entry price

**Tracking**:
- Position count by type (Buy/Sell)
- Last entry price for grid logic
- Position status and P&L
- Magic number filtering

---

### 7. Trade Execution Module
**Purpose**: Execute trading orders

**Functions**:
- `OpenBuyPosition()`: Place buy order
- `OpenSellPosition()`: Place sell order
- `NormalizeLots()`: Adjust lot size to broker specs

**Order Placement Process**:
```
1. Calculate lot size (Risk Module)
2. Apply min/max constraints
3. Normalize to lot step
4. Create trade request structure
5. Set price, SL, TP
6. Execute order via OrderSend()
7. Log result
8. Handle errors
```

**Error Handling**:
- Retry logic for temporary errors
- Requote handling
- Insufficient margin detection
- Logging all failures

---

### 8. Grid Management Module
**Purpose**: Implement grid trading without martingale

**Functions**:
- `CheckGridEntry()`: Monitor grid conditions
- `OpenGridPosition()`: Place grid order

**Grid Algorithm**:
```
For each position type:
1. Get last entry price
2. Calculate price distance
3. IF distance ≥ Grid Step
   THEN
       Calculate grid lot size
       Lot = Base Lot × Grid Multiplier
       (Multiplier = 1.0 = No Martingale)
       Open new position
       Update grid count
4. Check max levels constraint
```

**Safety Features**:
- Maximum grid levels limit
- Independent SL/TP per level
- No lot size multiplication (default)
- Price distance validation

---

### 9. Stop Management Module
**Purpose**: Manage stop loss modifications

**Functions**:
- `UpdateTrailingStops()`: Update SL for all positions

**Trailing Stop Algorithm**:
```
For each open position:
    IF Position Type = BUY
        New SL = Current Bid - Trailing Distance
        IF New SL > Current SL + Trailing Step
            THEN Modify position
    ELSE (SELL)
        New SL = Current Ask + Trailing Distance
        IF New SL < Current SL - Trailing Step
            THEN Modify position
```

**Features**:
- Activates only in profit
- Minimum step requirement
- Prevents unnecessary modifications
- Broker-level validation

---

### 10. Time Filter Module
**Purpose**: Control trading hours

**Functions**:
- `IsTimeAllowed()`: Check if current time is valid

**Logic**:
```
IF Time Filter Enabled
    Get current hour
    IF hour ≥ Start Hour AND hour < End Hour
        THEN Allow trading
    ELSE
        Block trading
```

---

## 🔄 Data Flow

### Main Execution Flow
```
OnTick() Called
    ↓
Check Time Filter → If failed, exit
    ↓
Check Daily Risk → If exceeded, exit
    ↓
Update Trailing Stops
    ↓
Check New Bar → If not new bar, exit
    ↓
Get Indicator Data → If failed, exit
    ↓
Determine Trend → Returns: +1, -1, or 0
    ↓
Check Signal (Buy/Sell based on trend)
    ↓
Count Existing Positions
    ↓
IF no positions
    Open new position
ELSE IF grid enabled AND < max levels
    Check grid entry
    ↓
Execute trade if conditions met
    ↓
Log results
```

---

## 💾 State Management

### Global State Variables
```
g_symbol           - Trading symbol
g_trendMAHandle    - Trend MA indicator handle
g_fastMAHandle     - Fast MA indicator handle
g_slowMAHandle     - Slow MA indicator handle
g_rsiHandle        - RSI indicator handle
g_atrHandle        - ATR indicator handle
g_point            - Symbol point size
g_tickValue        - Symbol tick value
g_tickSize         - Symbol tick size
g_lotStep          - Symbol lot step
g_dailyPnL         - Current daily P&L
g_lastCheckDate    - Last daily check date
```

### Persistent State
- Position information (MetaTrader database)
- Order history (MetaTrader database)
- Account information (MetaTrader)

---

## ⚡ Performance Considerations

### Optimization Strategies
1. **Indicator Caching**: Handles created once in OnInit
2. **New Bar Detection**: Only process on new bars
3. **Batch Updates**: Update all trailing stops in one pass
4. **Array Reuse**: Pre-sized arrays for indicator data
5. **Early Exit**: Return early from OnTick when conditions not met

### Resource Management
- Indicator handles released in OnDeinit
- No memory leaks
- Minimal computation per tick
- Efficient position lookup

---

## 🔒 Error Handling Strategy

### Levels of Error Handling

1. **Initialization Errors**
   - Invalid indicator handles → INIT_FAILED
   - Invalid parameters → INIT_FAILED
   - Log detailed error messages

2. **Runtime Errors**
   - Indicator data unavailable → Skip tick
   - Order placement failed → Log and continue
   - Invalid trade parameters → Log and skip

3. **Recovery Strategies**
   - Retry transient errors
   - Continue on non-critical failures
   - Alert user on critical issues

---

## 🧪 Testing Strategy

### Unit Testing
- Individual function validation
- Edge case handling
- Parameter boundary testing

### Integration Testing
- Module interaction testing
- Data flow validation
- State management verification

### System Testing
- Full EA backtesting
- Forward testing on demo
- Multiple symbol/timeframe testing
- Stress testing (volatile markets)

---

## 🔧 Maintenance & Extensibility

### Adding New Features

1. **New Indicator**
   - Add handle in global variables
   - Initialize in OnInit
   - Release in OnDeinit
   - Add to data collection layer

2. **New Signal Logic**
   - Create new function in Signal Module
   - Integrate into main flow
   - Add input parameters
   - Document in README

3. **New Risk Control**
   - Add to Risk Management Module
   - Update calculation functions
   - Add configuration parameters
   - Test thoroughly

### Code Standards
- Follow MQL5 naming conventions
- Document all functions
- Use consistent formatting
- Add comments for complex logic
- Update CHANGELOG

---

## 📊 Performance Metrics

### Key Metrics Tracked
- Daily P&L
- Position count
- Grid levels used
- Win rate (via history)
- Average trade duration
- Drawdown levels
- Risk-adjusted returns

### Monitoring Points
- Initialization success
- Trade execution results
- Order errors
- Risk limit hits
- Performance statistics

---

## 🏁 Conclusion

TIREX SAPPER's architecture is designed for:
- **Modularity**: Easy to maintain and extend
- **Reliability**: Robust error handling
- **Performance**: Efficient execution
- **Transparency**: Clear logic flow
- **Safety**: Multi-level risk controls

The system provides a solid foundation for algorithmic trading while maintaining the flexibility to adapt to different market conditions and trading styles.

---

*Architecture Version 1.0 - November 2024*
