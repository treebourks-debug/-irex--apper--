//+------------------------------------------------------------------+
//|                                               TIREX_SAPPER.mq5   |
//|                        Copyright 2024, TIREX SAPPER Project      |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, TIREX SAPPER Project"
#property link      "https://github.com/treebourks-debug/-irex--apper--"
#property version   "1.00"
#property description "TIREX SAPPER - Transparent MQL5 EA reproducing Exorcist principles"
#property description "Trend recognition, pullback entries, grid logic, dynamic stops, adaptive risk"

//+------------------------------------------------------------------+
//| Input Parameters                                                  |
//+------------------------------------------------------------------+

// General Settings
input group "=== General Settings ==="
input string   ExpertComment = "TIREX_SAPPER";      // Expert comment
input int      MagicNumber = 20241117;              // Magic number
input bool     EnableTrading = true;                // Enable trading

// Trend Recognition Settings
input group "=== Trend Recognition ==="
input int      FastMA_Period = 10;                  // Fast MA period
input int      SlowMA_Period = 50;                  // Slow MA period
input int      TrendMA_Period = 200;                // Trend MA period
input ENUM_MA_METHOD MA_Method = MODE_EMA;          // MA calculation method
input ENUM_APPLIED_PRICE MA_Price = PRICE_CLOSE;    // MA applied price
input int      MinTrendBars = 3;                    // Min bars to confirm trend

// Pullback Entry Settings
input group "=== Pullback Entry ==="
input double   PullbackPercent = 0.382;             // Pullback level (Fibonacci 38.2%)
input int      PullbackLookback = 20;               // Bars to look for pullback
input double   MinPullbackSize = 10;                // Min pullback size in points
input bool     UseRSIFilter = true;                 // Use RSI filter
input int      RSI_Period = 14;                     // RSI period
input int      RSI_Oversold = 30;                   // RSI oversold level
input int      RSI_Overbought = 70;                 // RSI overbought level

// Grid Logic (Non-Martingale)
input group "=== Grid Settings ==="
input bool     EnableGrid = true;                   // Enable grid trading
input int      GridStepPoints = 200;                // Grid step in points
input int      MaxGridLevels = 5;                   // Maximum grid levels
input double   GridLotSize = 0.01;                  // Fixed lot size for grid
input bool     GridSameDirection = true;            // Grid in same direction only

// Dynamic Stop Loss Settings
input group "=== Stop Loss & Take Profit ==="
input int      InitialSL_Points = 500;              // Initial Stop Loss in points
input int      InitialTP_Points = 1000;             // Initial Take Profit in points
input bool     UseTrailingStop = true;              // Use trailing stop
input int      TrailingStop_Points = 300;           // Trailing stop distance
input int      TrailingStep_Points = 50;            // Trailing step
input bool     UseBreakEven = true;                 // Use break even
input int      BreakEven_Points = 300;              // Break even activation
input int      BreakEven_Profit = 50;               // Break even profit lock

// Adaptive Risk Management
input group "=== Risk Management ==="
input double   RiskPercent = 1.0;                   // Risk per trade (%)
input double   MaxDailyLoss = 5.0;                  // Max daily loss (%)
input double   MaxDailyProfit = 10.0;               // Max daily profit (%)
input bool     AdaptiveLotSize = true;              // Adaptive lot sizing
input double   MinLotSize = 0.01;                   // Minimum lot size
input double   MaxLotSize = 10.0;                   // Maximum lot size
input bool     UseEquityStop = true;                // Use equity stop
input double   EquityStopPercent = 10.0;            // Equity stop loss (%)

// Multi-Symbol & Timeframe
input group "=== Multi-Symbol Settings ==="
input bool     TradeCurrentSymbolOnly = true;       // Trade current symbol only
input string   AdditionalSymbols = "";              // Additional symbols (comma separated)
input ENUM_TIMEFRAMES Timeframe = PERIOD_CURRENT;   // Working timeframe

// Trading Time Filter
input group "=== Time Filter ==="
input bool     UseTimeFilter = false;               // Use time filter
input int      StartHour = 0;                       // Trading start hour
input int      EndHour = 23;                        // Trading end hour

//+------------------------------------------------------------------+
//| Global Variables                                                  |
//+------------------------------------------------------------------+
double         fastMA[], slowMA[], trendMA[], rsiBuffer[];
int            fastMA_handle, slowMA_handle, trendMA_handle, rsi_handle;
double         dailyProfit = 0.0;
double         dailyLoss = 0.0;
datetime       lastDayChecked;
double         initialBalance;
int            totalGridOrders = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                    |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("TIREX SAPPER EA initialization started...");
   
   // Initialize indicators
   fastMA_handle = iMA(_Symbol, Timeframe, FastMA_Period, 0, MA_Method, MA_Price);
   slowMA_handle = iMA(_Symbol, Timeframe, SlowMA_Period, 0, MA_Method, MA_Price);
   trendMA_handle = iMA(_Symbol, Timeframe, TrendMA_Period, 0, MA_Method, MA_Price);
   rsi_handle = iRSI(_Symbol, Timeframe, RSI_Period, MA_Price);
   
   if(fastMA_handle == INVALID_HANDLE || slowMA_handle == INVALID_HANDLE || 
      trendMA_handle == INVALID_HANDLE || rsi_handle == INVALID_HANDLE)
   {
      Print("Error creating indicators");
      return(INIT_FAILED);
   }
   
   // Initialize arrays
   ArraySetAsSeries(fastMA, true);
   ArraySetAsSeries(slowMA, true);
   ArraySetAsSeries(trendMA, true);
   ArraySetAsSeries(rsiBuffer, true);
   
   // Initialize balance tracking
   initialBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   lastDayChecked = TimeCurrent();
   
   Print("TIREX SAPPER EA initialized successfully");
   Print("Magic Number: ", MagicNumber);
   Print("Symbol: ", _Symbol);
   Print("Timeframe: ", EnumToString(Timeframe));
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Release indicator handles
   if(fastMA_handle != INVALID_HANDLE) IndicatorRelease(fastMA_handle);
   if(slowMA_handle != INVALID_HANDLE) IndicatorRelease(slowMA_handle);
   if(trendMA_handle != INVALID_HANDLE) IndicatorRelease(trendMA_handle);
   if(rsi_handle != INVALID_HANDLE) IndicatorRelease(rsi_handle);
   
   Print("TIREX SAPPER EA deinitialized. Reason: ", reason);
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick()
{
   // Check if trading is enabled
   if(!EnableTrading) return;
   
   // Check time filter
   if(UseTimeFilter && !IsTimeToTrade()) return;
   
   // Update daily statistics
   UpdateDailyStatistics();
   
   // Check risk limits
   if(!CheckRiskLimits()) return;
   
   // Update indicator data
   if(!UpdateIndicators()) return;
   
   // Manage existing positions
   ManagePositions();
   
   // Check for new entry signals
   CheckEntrySignals();
   
   // Manage grid orders
   if(EnableGrid) ManageGrid();
}

//+------------------------------------------------------------------+
//| Update indicator data                                             |
//+------------------------------------------------------------------+
bool UpdateIndicators()
{
   if(CopyBuffer(fastMA_handle, 0, 0, 3, fastMA) <= 0) return false;
   if(CopyBuffer(slowMA_handle, 0, 0, 3, slowMA) <= 0) return false;
   if(CopyBuffer(trendMA_handle, 0, 0, 3, trendMA) <= 0) return false;
   if(CopyBuffer(rsi_handle, 0, 0, 3, rsiBuffer) <= 0) return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Detect trend direction                                            |
//+------------------------------------------------------------------+
int DetectTrend()
{
   // 1 = Uptrend, -1 = Downtrend, 0 = No clear trend
   
   // Check if fast MA is above/below slow MA
   bool fastAboveSlow = fastMA[0] > slowMA[0];
   bool fastBelowSlow = fastMA[0] < slowMA[0];
   
   // Check if price is above/below trend MA
   double currentPrice = iClose(_Symbol, Timeframe, 0);
   bool priceAboveTrend = currentPrice > trendMA[0];
   bool priceBelowTrend = currentPrice < trendMA[0];
   
   // Confirm trend with multiple bars
   int bullishBars = 0;
   int bearishBars = 0;
   
   for(int i = 0; i < MinTrendBars; i++)
   {
      double closePrice = iClose(_Symbol, Timeframe, i);
      if(closePrice > trendMA[i]) bullishBars++;
      if(closePrice < trendMA[i]) bearishBars++;
   }
   
   // Uptrend confirmation
   if(fastAboveSlow && priceAboveTrend && bullishBars >= MinTrendBars)
      return 1;
   
   // Downtrend confirmation
   if(fastBelowSlow && priceBelowTrend && bearishBars >= MinTrendBars)
      return -1;
   
   return 0;
}

//+------------------------------------------------------------------+
//| Detect pullback entry                                             |
//+------------------------------------------------------------------+
bool IsPullbackEntry(int trendDirection)
{
   if(trendDirection == 0) return false;
   
   double high = iHigh(_Symbol, Timeframe, 0);
   double low = iLow(_Symbol, Timeframe, 0);
   double close = iClose(_Symbol, Timeframe, 0);
   
   // Find recent high/low in lookback period
   double extremePrice = 0;
   if(trendDirection == 1) // Uptrend - look for pullback from high
   {
      extremePrice = iHigh(_Symbol, Timeframe, iHighest(_Symbol, Timeframe, MODE_HIGH, PullbackLookback, 0));
      double pullbackLevel = extremePrice - (extremePrice - low) * PullbackPercent;
      double currentPullback = extremePrice - close;
      
      // Check if we're in a pullback zone
      if(close < extremePrice && currentPullback >= MinPullbackSize * _Point)
      {
         // Check RSI filter
         if(UseRSIFilter && rsiBuffer[0] > RSI_Oversold && rsiBuffer[0] < 50)
            return true;
         else if(!UseRSIFilter)
            return true;
      }
   }
   else if(trendDirection == -1) // Downtrend - look for pullback from low
   {
      extremePrice = iLow(_Symbol, Timeframe, iLowest(_Symbol, Timeframe, MODE_LOW, PullbackLookback, 0));
      double pullbackLevel = extremePrice + (high - extremePrice) * PullbackPercent;
      double currentPullback = close - extremePrice;
      
      // Check if we're in a pullback zone
      if(close > extremePrice && currentPullback >= MinPullbackSize * _Point)
      {
         // Check RSI filter
         if(UseRSIFilter && rsiBuffer[0] < RSI_Overbought && rsiBuffer[0] > 50)
            return true;
         else if(!UseRSIFilter)
            return true;
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Check for entry signals                                           |
//+------------------------------------------------------------------+
void CheckEntrySignals()
{
   // Don't open new positions if we already have one
   if(CountPositions() >= MaxGridLevels) return;
   
   // Detect trend
   int trend = DetectTrend();
   if(trend == 0) return;
   
   // Check for pullback entry
   if(!IsPullbackEntry(trend)) return;
   
   // Calculate lot size
   double lotSize = CalculateLotSize();
   if(lotSize < MinLotSize || lotSize > MaxLotSize) return;
   
   // Open position
   if(trend == 1)
      OpenPosition(ORDER_TYPE_BUY, lotSize, "Pullback Entry");
   else if(trend == -1)
      OpenPosition(ORDER_TYPE_SELL, lotSize, "Pullback Entry");
}

//+------------------------------------------------------------------+
//| Calculate adaptive lot size                                       |
//+------------------------------------------------------------------+
double CalculateLotSize()
{
   double lotSize = GridLotSize;
   
   if(AdaptiveLotSize)
   {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double riskAmount = balance * RiskPercent / 100.0;
      
      // Calculate lot size based on stop loss
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double stopLossPoints = InitialSL_Points;
      
      if(tickValue > 0 && stopLossPoints > 0)
      {
         lotSize = riskAmount / (stopLossPoints * tickValue);
      }
   }
   
   // Normalize lot size
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   lotSize = MathMax(minLot, MathMin(maxLot, lotSize));
   lotSize = NormalizeDouble(lotSize / lotStep, 0) * lotStep;
   
   return MathMax(MinLotSize, MathMin(MaxLotSize, lotSize));
}

//+------------------------------------------------------------------+
//| Open position                                                     |
//+------------------------------------------------------------------+
bool OpenPosition(ENUM_ORDER_TYPE orderType, double lotSize, string comment)
{
   MqlTradeRequest request = {};
   MqlTradeResult result = {};
   
   double price = (orderType == ORDER_TYPE_BUY) ? 
                  SymbolInfoDouble(_Symbol, SYMBOL_ASK) : 
                  SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   double sl = 0, tp = 0;
   
   // Calculate stop loss and take profit
   if(InitialSL_Points > 0)
   {
      if(orderType == ORDER_TYPE_BUY)
         sl = price - InitialSL_Points * _Point;
      else
         sl = price + InitialSL_Points * _Point;
   }
   
   if(InitialTP_Points > 0)
   {
      if(orderType == ORDER_TYPE_BUY)
         tp = price + InitialTP_Points * _Point;
      else
         tp = price - InitialTP_Points * _Point;
   }
   
   // Fill request
   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = lotSize;
   request.type = orderType;
   request.price = price;
   request.sl = sl;
   request.tp = tp;
   request.deviation = 10;
   request.magic = MagicNumber;
   request.comment = ExpertComment + " | " + comment;
   request.type_filling = ORDER_FILLING_FOK;
   
   // Try to send order
   if(!OrderSend(request, result))
   {
      // Try with IOC filling
      request.type_filling = ORDER_FILLING_IOC;
      if(!OrderSend(request, result))
      {
         Print("Order send error: ", result.retcode, " - ", result.comment);
         return false;
      }
   }
   
   if(result.retcode == TRADE_RETCODE_DONE || result.retcode == TRADE_RETCODE_PLACED)
   {
      Print("Position opened: ", EnumToString(orderType), " | Lot: ", lotSize, 
            " | Price: ", price, " | SL: ", sl, " | TP: ", tp);
      return true;
   }
   
   Print("Order failed: ", result.retcode, " - ", result.comment);
   return false;
}

//+------------------------------------------------------------------+
//| Count positions with our magic number                            |
//+------------------------------------------------------------------+
int CountPositions()
{
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol && 
            PositionGetInteger(POSITION_MAGIC) == MagicNumber)
         {
            count++;
         }
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//| Manage existing positions                                         |
//+------------------------------------------------------------------+
void ManagePositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      
      if(PositionGetString(POSITION_SYMBOL) != _Symbol || 
         PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
      
      // Get position info
      double positionPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentSL = PositionGetDouble(POSITION_SL);
      ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      
      double currentPrice = (posType == POSITION_TYPE_BUY) ? 
                            SymbolInfoDouble(_Symbol, SYMBOL_BID) : 
                            SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      
      double profit = currentPrice - positionPrice;
      if(posType == POSITION_TYPE_SELL) profit = -profit;
      
      double profitPoints = profit / _Point;
      
      // Break even logic
      if(UseBreakEven && profitPoints >= BreakEven_Points)
      {
         double newSL = positionPrice + BreakEven_Profit * _Point;
         if(posType == POSITION_TYPE_SELL)
            newSL = positionPrice - BreakEven_Profit * _Point;
         
         if((posType == POSITION_TYPE_BUY && (currentSL == 0 || newSL > currentSL)) ||
            (posType == POSITION_TYPE_SELL && (currentSL == 0 || newSL < currentSL)))
         {
            ModifyPosition(ticket, newSL, PositionGetDouble(POSITION_TP));
         }
      }
      
      // Trailing stop logic
      if(UseTrailingStop && profitPoints >= TrailingStop_Points)
      {
         double newSL = currentPrice - TrailingStop_Points * _Point;
         if(posType == POSITION_TYPE_SELL)
            newSL = currentPrice + TrailingStop_Points * _Point;
         
         if((posType == POSITION_TYPE_BUY && (currentSL == 0 || newSL > currentSL + TrailingStep_Points * _Point)) ||
            (posType == POSITION_TYPE_SELL && (currentSL == 0 || newSL < currentSL - TrailingStep_Points * _Point)))
         {
            ModifyPosition(ticket, newSL, PositionGetDouble(POSITION_TP));
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Modify position                                                   |
//+------------------------------------------------------------------+
bool ModifyPosition(ulong ticket, double sl, double tp)
{
   MqlTradeRequest request = {};
   MqlTradeResult result = {};
   
   request.action = TRADE_ACTION_SLTP;
   request.position = ticket;
   request.sl = NormalizeDouble(sl, _Digits);
   request.tp = NormalizeDouble(tp, _Digits);
   
   if(!OrderSend(request, result))
   {
      Print("Modify position error: ", result.retcode);
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Manage grid orders                                                |
//+------------------------------------------------------------------+
void ManageGrid()
{
   if(CountPositions() == 0) return;
   
   // Get average position price and direction
   double avgPrice = 0;
   double totalVolume = 0;
   ENUM_POSITION_TYPE gridDirection = POSITION_TYPE_BUY;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      
      if(PositionGetString(POSITION_SYMBOL) != _Symbol || 
         PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
      
      double volume = PositionGetDouble(POSITION_VOLUME);
      double price = PositionGetDouble(POSITION_PRICE_OPEN);
      avgPrice += price * volume;
      totalVolume += volume;
      gridDirection = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   }
   
   if(totalVolume > 0)
      avgPrice /= totalVolume;
   
   // Check if we should add grid level
   double currentPrice = (gridDirection == POSITION_TYPE_BUY) ? 
                         SymbolInfoDouble(_Symbol, SYMBOL_BID) : 
                         SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   
   double distancePoints = MathAbs(currentPrice - avgPrice) / _Point;
   
   if(distancePoints >= GridStepPoints && CountPositions() < MaxGridLevels)
   {
      // Add grid level in the same direction (non-martingale)
      if(GridSameDirection)
      {
         if(gridDirection == POSITION_TYPE_BUY)
            OpenPosition(ORDER_TYPE_BUY, GridLotSize, "Grid Level");
         else
            OpenPosition(ORDER_TYPE_SELL, GridLotSize, "Grid Level");
      }
   }
}

//+------------------------------------------------------------------+
//| Update daily statistics                                           |
//+------------------------------------------------------------------+
void UpdateDailyStatistics()
{
   datetime currentTime = TimeCurrent();
   MqlDateTime dtCurrent, dtLast;
   
   TimeToStruct(currentTime, dtCurrent);
   TimeToStruct(lastDayChecked, dtLast);
   
   // Reset daily stats at day change
   if(dtCurrent.day != dtLast.day)
   {
      dailyProfit = 0;
      dailyLoss = 0;
      lastDayChecked = currentTime;
      Print("Daily statistics reset");
   }
   
   // Calculate current daily P&L
   double currentProfit = AccountInfoDouble(ACCOUNT_PROFIT);
   if(currentProfit > 0)
      dailyProfit = currentProfit;
   else
      dailyLoss = MathAbs(currentProfit);
}

//+------------------------------------------------------------------+
//| Check risk limits                                                 |
//+------------------------------------------------------------------+
bool CheckRiskLimits()
{
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   
   // Check max daily loss
   if(dailyLoss > balance * MaxDailyLoss / 100.0)
   {
      Print("Daily loss limit reached: ", dailyLoss);
      return false;
   }
   
   // Check max daily profit
   if(dailyProfit > balance * MaxDailyProfit / 100.0)
   {
      Print("Daily profit target reached: ", dailyProfit);
      return false;
   }
   
   // Check equity stop
   if(UseEquityStop)
   {
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      double equityDrawdown = (initialBalance - equity) / initialBalance * 100.0;
      
      if(equityDrawdown >= EquityStopPercent)
      {
         Print("Equity stop triggered: ", equityDrawdown, "%");
         CloseAllPositions();
         return false;
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Close all positions                                               |
//+------------------------------------------------------------------+
void CloseAllPositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      
      if(PositionGetString(POSITION_SYMBOL) != _Symbol || 
         PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
      
      MqlTradeRequest request = {};
      MqlTradeResult result = {};
      
      request.action = TRADE_ACTION_DEAL;
      request.position = ticket;
      request.symbol = _Symbol;
      request.volume = PositionGetDouble(POSITION_VOLUME);
      request.deviation = 10;
      request.magic = MagicNumber;
      
      ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      if(posType == POSITION_TYPE_BUY)
      {
         request.type = ORDER_TYPE_SELL;
         request.price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      }
      else
      {
         request.type = ORDER_TYPE_BUY;
         request.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      }
      
      request.type_filling = ORDER_FILLING_FOK;
      if(!OrderSend(request, result))
      {
         request.type_filling = ORDER_FILLING_IOC;
         OrderSend(request, result);
      }
   }
}

//+------------------------------------------------------------------+
//| Check if it's time to trade                                      |
//+------------------------------------------------------------------+
bool IsTimeToTrade()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   if(StartHour <= EndHour)
   {
      return (dt.hour >= StartHour && dt.hour <= EndHour);
   }
   else
   {
      return (dt.hour >= StartHour || dt.hour <= EndHour);
   }
}
//+------------------------------------------------------------------+
