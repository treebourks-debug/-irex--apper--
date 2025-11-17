//+------------------------------------------------------------------+
//|                                                 TIREX_SAPPER.mq5 |
//|                                     Copyright 2024, TIREX SAPPER |
//|                                                                   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, TIREX SAPPER"
#property link      ""
#property version   "1.00"
#property description "TIREX SAPPER - Transparent MQL5 Expert Advisor"
#property description "Trend recognition + Pullback entries + Grid logic without martingale"
#property description "Dynamic stops + Adaptive risk management"

//--- Input Parameters
//--- General Settings
input group "=== General Settings ==="
input string   InpSymbol = "";                    // Symbol (empty = current chart)
input ENUM_TIMEFRAMES InpTimeframe = PERIOD_H1;   // Timeframe for analysis
input int      InpMagicNumber = 20241117;         // Magic Number
input string   InpComment = "TIREX_SAPPER";       // Order Comment

//--- Risk Management
input group "=== Risk Management ==="
input double   InpRiskPercent = 1.0;              // Risk per trade (% of balance)
input double   InpMaxDailyRisk = 3.0;             // Max daily risk (% of balance)
input double   InpFixedLotSize = 0.0;             // Fixed lot size (0 = auto)
input double   InpMinLotSize = 0.01;              // Minimum lot size
input double   InpMaxLotSize = 10.0;              // Maximum lot size

//--- Trend Detection
input group "=== Trend Detection ==="
input int      InpTrendMAPeriod = 50;             // Trend MA Period
input int      InpFastMAPeriod = 20;              // Fast MA Period
input int      InpSlowMAPeriod = 50;              // Slow MA Period
input ENUM_MA_METHOD InpMAMethod = MODE_EMA;      // MA Method
input ENUM_APPLIED_PRICE InpMAPrice = PRICE_CLOSE; // MA Applied Price

//--- Entry Logic (Pullback)
input group "=== Entry Logic ==="
input int      InpRSIPeriod = 14;                 // RSI Period
input int      InpRSIOverbought = 70;             // RSI Overbought Level
input int      InpRSIOversold = 30;               // RSI Oversold Level
input double   InpPullbackPercent = 0.5;          // Pullback threshold (% of ATR)
input int      InpATRPeriod = 14;                 // ATR Period for volatility

//--- Grid Logic (No Martingale)
input group "=== Grid Logic ==="
input bool     InpEnableGrid = true;              // Enable Grid Trading
input int      InpMaxGridLevels = 5;              // Maximum Grid Levels
input double   InpGridStep = 50;                  // Grid Step (points)
input double   InpGridLotMultiplier = 1.0;        // Grid Lot Multiplier (1.0 = no martingale)

//--- Stop Loss and Take Profit
input group "=== Stop Loss / Take Profit ==="
input int      InpStopLoss = 100;                 // Initial Stop Loss (points)
input int      InpTakeProfit = 200;               // Initial Take Profit (points)
input bool     InpUseDynamicSL = true;            // Use Dynamic Stop Loss (ATR-based)
input double   InpDynamicSLMultiplier = 2.0;      // Dynamic SL Multiplier (x ATR)
input bool     InpUseTrailingStop = true;         // Use Trailing Stop
input int      InpTrailingStop = 50;              // Trailing Stop (points)
input int      InpTrailingStep = 10;              // Trailing Step (points)

//--- Time Filters
input group "=== Time Filters ==="
input bool     InpUseTimeFilter = false;          // Use Time Filter
input int      InpStartHour = 0;                  // Start Hour
input int      InpEndHour = 23;                   // End Hour

//--- Global Variables
string         g_symbol;
int            g_trendMAHandle;
int            g_fastMAHandle;
int            g_slowMAHandle;
int            g_rsiHandle;
int            g_atrHandle;
double         g_point;
double         g_tickValue;
double         g_tickSize;
double         g_lotStep;
double         g_dailyPnL;
datetime       g_lastCheckDate;

//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Set symbol
   g_symbol = (InpSymbol == "") ? _Symbol : InpSymbol;
   
   //--- Get symbol properties
   g_point = SymbolInfoDouble(g_symbol, SYMBOL_POINT);
   g_tickValue = SymbolInfoDouble(g_symbol, SYMBOL_TRADE_TICK_VALUE);
   g_tickSize = SymbolInfoDouble(g_symbol, SYMBOL_TRADE_TICK_SIZE);
   g_lotStep = SymbolInfoDouble(g_symbol, SYMBOL_VOLUME_STEP);
   
   //--- Initialize indicators
   g_trendMAHandle = iMA(g_symbol, InpTimeframe, InpTrendMAPeriod, 0, InpMAMethod, InpMAPrice);
   g_fastMAHandle = iMA(g_symbol, InpTimeframe, InpFastMAPeriod, 0, InpMAMethod, InpMAPrice);
   g_slowMAHandle = iMA(g_symbol, InpTimeframe, InpSlowMAPeriod, 0, InpMAMethod, InpMAPrice);
   g_rsiHandle = iRSI(g_symbol, InpTimeframe, InpRSIPeriod, InpMAPrice);
   g_atrHandle = iATR(g_symbol, InpTimeframe, InpATRPeriod);
   
   //--- Check indicator handles
   if(g_trendMAHandle == INVALID_HANDLE || g_fastMAHandle == INVALID_HANDLE || 
      g_slowMAHandle == INVALID_HANDLE || g_rsiHandle == INVALID_HANDLE || 
      g_atrHandle == INVALID_HANDLE)
   {
      Print("Error creating indicator handles");
      return(INIT_FAILED);
   }
   
   //--- Initialize daily PnL tracking
   g_lastCheckDate = TimeCurrent();
   g_dailyPnL = 0.0;
   
   Print("TIREX SAPPER initialized successfully on ", g_symbol);
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //--- Release indicator handles
   if(g_trendMAHandle != INVALID_HANDLE) IndicatorRelease(g_trendMAHandle);
   if(g_fastMAHandle != INVALID_HANDLE) IndicatorRelease(g_fastMAHandle);
   if(g_slowMAHandle != INVALID_HANDLE) IndicatorRelease(g_slowMAHandle);
   if(g_rsiHandle != INVALID_HANDLE) IndicatorRelease(g_rsiHandle);
   if(g_atrHandle != INVALID_HANDLE) IndicatorRelease(g_atrHandle);
   
   Print("TIREX SAPPER deinitialized. Reason: ", reason);
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick()
{
   //--- Check time filter
   if(InpUseTimeFilter && !IsTimeAllowed())
      return;
   
   //--- Check daily risk limit
   UpdateDailyPnL();
   if(IsDailyRiskExceeded())
   {
      Print("Daily risk limit exceeded. No new trades.");
      return;
   }
   
   //--- Update trailing stops for existing positions
   if(InpUseTrailingStop)
      UpdateTrailingStops();
   
   //--- Check for new bar
   static datetime lastBarTime = 0;
   datetime currentBarTime = iTime(g_symbol, InpTimeframe, 0);
   
   if(currentBarTime == lastBarTime)
      return;
   
   lastBarTime = currentBarTime;
   
   //--- Get market data
   double trendMA[], fastMA[], slowMA[], rsi[], atr[];
   
   if(!GetIndicatorData(g_trendMAHandle, trendMA, 3) ||
      !GetIndicatorData(g_fastMAHandle, fastMA, 3) ||
      !GetIndicatorData(g_slowMAHandle, slowMA, 3) ||
      !GetIndicatorData(g_rsiHandle, rsi, 3) ||
      !GetIndicatorData(g_atrHandle, atr, 3))
   {
      Print("Error getting indicator data");
      return;
   }
   
   //--- Get current price
   double bid = SymbolInfoDouble(g_symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(g_symbol, SYMBOL_ASK);
   
   //--- Determine trend
   int trend = DetermineTrend(fastMA, slowMA, trendMA, bid);
   
   //--- Check for entry signal
   if(trend == 1) // Uptrend
   {
      if(CheckBuySignal(rsi[0], bid, slowMA[0], atr[0]))
      {
         if(CountPositions(POSITION_TYPE_BUY) == 0)
         {
            OpenBuyPosition(ask, atr[0]);
         }
         else if(InpEnableGrid && CountPositions(POSITION_TYPE_BUY) < InpMaxGridLevels)
         {
            CheckGridEntry(POSITION_TYPE_BUY, bid, atr[0]);
         }
      }
   }
   else if(trend == -1) // Downtrend
   {
      if(CheckSellSignal(rsi[0], bid, slowMA[0], atr[0]))
      {
         if(CountPositions(POSITION_TYPE_SELL) == 0)
         {
            OpenSellPosition(bid, atr[0]);
         }
         else if(InpEnableGrid && CountPositions(POSITION_TYPE_SELL) < InpMaxGridLevels)
         {
            CheckGridEntry(POSITION_TYPE_SELL, ask, atr[0]);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Get indicator data helper function                                |
//+------------------------------------------------------------------+
bool GetIndicatorData(int handle, double &buffer[], int count)
{
   ArraySetAsSeries(buffer, true);
   if(CopyBuffer(handle, 0, 0, count, buffer) != count)
   {
      return false;
   }
   return true;
}

//+------------------------------------------------------------------+
//| Determine market trend                                            |
//+------------------------------------------------------------------+
int DetermineTrend(const double &fastMA[], const double &slowMA[], const double &trendMA[], double price)
{
   //--- Uptrend: Fast MA > Slow MA and price > Trend MA
   if(fastMA[0] > slowMA[0] && price > trendMA[0])
      return 1;
   
   //--- Downtrend: Fast MA < Slow MA and price < Trend MA
   if(fastMA[0] < slowMA[0] && price < trendMA[0])
      return -1;
   
   //--- No clear trend
   return 0;
}

//+------------------------------------------------------------------+
//| Check buy signal (pullback in uptrend)                           |
//+------------------------------------------------------------------+
bool CheckBuySignal(double rsi, double price, double slowMA, double atr)
{
   //--- Price should be near or below slow MA (pullback)
   double pullbackLevel = slowMA - (atr * InpPullbackPercent);
   
   //--- RSI should be recovering from oversold
   if(rsi > InpRSIOversold && rsi < 50 && price <= slowMA && price >= pullbackLevel)
      return true;
   
   return false;
}

//+------------------------------------------------------------------+
//| Check sell signal (pullback in downtrend)                        |
//+------------------------------------------------------------------+
bool CheckSellSignal(double rsi, double price, double slowMA, double atr)
{
   //--- Price should be near or above slow MA (pullback)
   double pullbackLevel = slowMA + (atr * InpPullbackPercent);
   
   //--- RSI should be recovering from overbought
   if(rsi < InpRSIOverbought && rsi > 50 && price >= slowMA && price <= pullbackLevel)
      return true;
   
   return false;
}

//+------------------------------------------------------------------+
//| Open buy position                                                 |
//+------------------------------------------------------------------+
void OpenBuyPosition(double price, double atr)
{
   double sl = CalculateStopLoss(POSITION_TYPE_BUY, price, atr);
   double tp = CalculateTakeProfit(POSITION_TYPE_BUY, price, atr);
   double lots = CalculateLotSize(MathAbs(price - sl));
   
   if(lots < InpMinLotSize)
      lots = InpMinLotSize;
   if(lots > InpMaxLotSize)
      lots = InpMaxLotSize;
   
   lots = NormalizeLots(lots);
   
   MqlTradeRequest request = {};
   MqlTradeResult result = {};
   
   request.action = TRADE_ACTION_DEAL;
   request.symbol = g_symbol;
   request.volume = lots;
   request.type = ORDER_TYPE_BUY;
   request.price = price;
   request.sl = sl;
   request.tp = tp;
   request.deviation = 10;
   request.magic = InpMagicNumber;
   request.comment = InpComment;
   
   if(OrderSend(request, result))
   {
      Print("Buy order opened: ", result.order, " at ", price, " SL: ", sl, " TP: ", tp, " Lots: ", lots);
   }
   else
   {
      Print("Buy order failed: ", GetLastError(), " - ", result.comment);
   }
}

//+------------------------------------------------------------------+
//| Open sell position                                                |
//+------------------------------------------------------------------+
void OpenSellPosition(double price, double atr)
{
   double sl = CalculateStopLoss(POSITION_TYPE_SELL, price, atr);
   double tp = CalculateTakeProfit(POSITION_TYPE_SELL, price, atr);
   double lots = CalculateLotSize(MathAbs(price - sl));
   
   if(lots < InpMinLotSize)
      lots = InpMinLotSize;
   if(lots > InpMaxLotSize)
      lots = InpMaxLotSize;
   
   lots = NormalizeLots(lots);
   
   MqlTradeRequest request = {};
   MqlTradeResult result = {};
   
   request.action = TRADE_ACTION_DEAL;
   request.symbol = g_symbol;
   request.volume = lots;
   request.type = ORDER_TYPE_SELL;
   request.price = price;
   request.sl = sl;
   request.tp = tp;
   request.deviation = 10;
   request.magic = InpMagicNumber;
   request.comment = InpComment;
   
   if(OrderSend(request, result))
   {
      Print("Sell order opened: ", result.order, " at ", price, " SL: ", sl, " TP: ", tp, " Lots: ", lots);
   }
   else
   {
      Print("Sell order failed: ", GetLastError(), " - ", result.comment);
   }
}

//+------------------------------------------------------------------+
//| Calculate stop loss                                              |
//+------------------------------------------------------------------+
double CalculateStopLoss(ENUM_POSITION_TYPE type, double price, double atr)
{
   double sl = 0;
   
   if(InpUseDynamicSL)
   {
      //--- Dynamic SL based on ATR
      double slDistance = atr * InpDynamicSLMultiplier;
      
      if(type == POSITION_TYPE_BUY)
         sl = price - slDistance;
      else
         sl = price + slDistance;
   }
   else
   {
      //--- Fixed SL in points
      double slDistance = InpStopLoss * g_point;
      
      if(type == POSITION_TYPE_BUY)
         sl = price - slDistance;
      else
         sl = price + slDistance;
   }
   
   return NormalizeDouble(sl, (int)SymbolInfoInteger(g_symbol, SYMBOL_DIGITS));
}

//+------------------------------------------------------------------+
//| Calculate take profit                                            |
//+------------------------------------------------------------------+
double CalculateTakeProfit(ENUM_POSITION_TYPE type, double price, double atr)
{
   double tp = 0;
   double tpDistance = InpTakeProfit * g_point;
   
   if(type == POSITION_TYPE_BUY)
      tp = price + tpDistance;
   else
      tp = price - tpDistance;
   
   return NormalizeDouble(tp, (int)SymbolInfoInteger(g_symbol, SYMBOL_DIGITS));
}

//+------------------------------------------------------------------+
//| Calculate lot size based on risk                                 |
//+------------------------------------------------------------------+
double CalculateLotSize(double slDistance)
{
   if(InpFixedLotSize > 0)
      return InpFixedLotSize;
   
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = balance * (InpRiskPercent / 100.0);
   
   //--- Calculate lot size based on risk and SL distance
   double tickValuePerLot = SymbolInfoDouble(g_symbol, SYMBOL_TRADE_TICK_VALUE);
   double pointsToSL = slDistance / g_point;
   
   double lots = 0;
   if(tickValuePerLot > 0 && pointsToSL > 0)
   {
      lots = riskAmount / (pointsToSL * tickValuePerLot / SymbolInfoDouble(g_symbol, SYMBOL_TRADE_TICK_SIZE));
   }
   
   return lots;
}

//+------------------------------------------------------------------+
//| Normalize lot size                                               |
//+------------------------------------------------------------------+
double NormalizeLots(double lots)
{
   double minLot = SymbolInfoDouble(g_symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(g_symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(g_symbol, SYMBOL_VOLUME_STEP);
   
   if(lots < minLot)
      lots = minLot;
   if(lots > maxLot)
      lots = maxLot;
   
   lots = MathFloor(lots / lotStep) * lotStep;
   
   return NormalizeDouble(lots, 2);
}

//+------------------------------------------------------------------+
//| Count positions by type                                          |
//+------------------------------------------------------------------+
int CountPositions(ENUM_POSITION_TYPE type)
{
   int count = 0;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetString(POSITION_SYMBOL) == g_symbol &&
            PositionGetInteger(POSITION_MAGIC) == InpMagicNumber &&
            PositionGetInteger(POSITION_TYPE) == type)
         {
            count++;
         }
      }
   }
   
   return count;
}

//+------------------------------------------------------------------+
//| Check grid entry condition                                       |
//+------------------------------------------------------------------+
void CheckGridEntry(ENUM_POSITION_TYPE type, double currentPrice, double atr)
{
   double lastEntryPrice = GetLastEntryPrice(type);
   
   if(lastEntryPrice <= 0)
      return;
   
   double gridDistance = InpGridStep * g_point;
   
   if(type == POSITION_TYPE_BUY)
   {
      //--- Price should be below last entry by grid step
      if(currentPrice <= lastEntryPrice - gridDistance)
      {
         double ask = SymbolInfoDouble(g_symbol, SYMBOL_ASK);
         OpenGridPosition(type, ask, atr);
      }
   }
   else // SELL
   {
      //--- Price should be above last entry by grid step
      if(currentPrice >= lastEntryPrice + gridDistance)
      {
         double bid = SymbolInfoDouble(g_symbol, SYMBOL_BID);
         OpenGridPosition(type, bid, atr);
      }
   }
}

//+------------------------------------------------------------------+
//| Get last entry price                                             |
//+------------------------------------------------------------------+
double GetLastEntryPrice(ENUM_POSITION_TYPE type)
{
   double lastPrice = 0;
   datetime lastTime = 0;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetString(POSITION_SYMBOL) == g_symbol &&
            PositionGetInteger(POSITION_MAGIC) == InpMagicNumber &&
            PositionGetInteger(POSITION_TYPE) == type)
         {
            datetime posTime = (datetime)PositionGetInteger(POSITION_TIME);
            if(posTime > lastTime)
            {
               lastTime = posTime;
               lastPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            }
         }
      }
   }
   
   return lastPrice;
}

//+------------------------------------------------------------------+
//| Open grid position (no martingale)                               |
//+------------------------------------------------------------------+
void OpenGridPosition(ENUM_POSITION_TYPE type, double price, double atr)
{
   double sl = CalculateStopLoss(type, price, atr);
   double tp = CalculateTakeProfit(type, price, atr);
   
   //--- Calculate lot size with grid multiplier (1.0 = no martingale)
   double baseLots = CalculateLotSize(MathAbs(price - sl));
   double lots = baseLots * InpGridLotMultiplier;
   
   if(lots < InpMinLotSize)
      lots = InpMinLotSize;
   if(lots > InpMaxLotSize)
      lots = InpMaxLotSize;
   
   lots = NormalizeLots(lots);
   
   MqlTradeRequest request = {};
   MqlTradeResult result = {};
   
   request.action = TRADE_ACTION_DEAL;
   request.symbol = g_symbol;
   request.volume = lots;
   request.type = (type == POSITION_TYPE_BUY) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   request.price = price;
   request.sl = sl;
   request.tp = tp;
   request.deviation = 10;
   request.magic = InpMagicNumber;
   request.comment = InpComment + "_GRID";
   
   if(OrderSend(request, result))
   {
      Print("Grid order opened: ", result.order, " Type: ", EnumToString(type), " at ", price, " Lots: ", lots);
   }
   else
   {
      Print("Grid order failed: ", GetLastError(), " - ", result.comment);
   }
}

//+------------------------------------------------------------------+
//| Update trailing stops                                            |
//+------------------------------------------------------------------+
void UpdateTrailingStops()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetString(POSITION_SYMBOL) == g_symbol &&
            PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
         {
            ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            double currentSL = PositionGetDouble(POSITION_SL);
            double currentTP = PositionGetDouble(POSITION_TP);
            
            double bid = SymbolInfoDouble(g_symbol, SYMBOL_BID);
            double ask = SymbolInfoDouble(g_symbol, SYMBOL_ASK);
            
            double newSL = 0;
            bool modifyNeeded = false;
            
            if(type == POSITION_TYPE_BUY)
            {
               double trailDistance = InpTrailingStop * g_point;
               double trailStep = InpTrailingStep * g_point;
               
               newSL = bid - trailDistance;
               
               if(newSL > currentSL + trailStep && newSL < bid)
               {
                  modifyNeeded = true;
               }
            }
            else // SELL
            {
               double trailDistance = InpTrailingStop * g_point;
               double trailStep = InpTrailingStep * g_point;
               
               newSL = ask + trailDistance;
               
               if((currentSL == 0 || newSL < currentSL - trailStep) && newSL > ask)
               {
                  modifyNeeded = true;
               }
            }
            
            if(modifyNeeded)
            {
               MqlTradeRequest request = {};
               MqlTradeResult result = {};
               
               request.action = TRADE_ACTION_SLTP;
               request.position = ticket;
               request.symbol = g_symbol;
               request.sl = NormalizeDouble(newSL, (int)SymbolInfoInteger(g_symbol, SYMBOL_DIGITS));
               request.tp = currentTP;
               
               if(OrderSend(request, result))
               {
                  Print("Trailing stop updated for ticket: ", ticket, " New SL: ", request.sl);
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Check if time is allowed for trading                             |
//+------------------------------------------------------------------+
bool IsTimeAllowed()
{
   MqlDateTime dt;
   TimeCurrent(dt);
   
   if(dt.hour >= InpStartHour && dt.hour < InpEndHour)
      return true;
   
   return false;
}

//+------------------------------------------------------------------+
//| Update daily P&L tracking                                        |
//+------------------------------------------------------------------+
void UpdateDailyPnL()
{
   MqlDateTime currentDate, lastDate;
   TimeCurrent(currentDate);
   TimeToStruct(g_lastCheckDate, lastDate);
   
   //--- Reset daily PnL on new day
   if(currentDate.day != lastDate.day)
   {
      g_dailyPnL = 0.0;
      g_lastCheckDate = TimeCurrent();
   }
   
   //--- Calculate current daily PnL
   double dailyProfit = 0.0;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetString(POSITION_SYMBOL) == g_symbol &&
            PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
         {
            dailyProfit += PositionGetDouble(POSITION_PROFIT);
         }
      }
   }
   
   //--- Add closed positions today
   HistorySelect(iTime(g_symbol, PERIOD_D1, 0), TimeCurrent());
   
   for(int i = HistoryDealsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket > 0)
      {
         if(HistoryDealGetString(ticket, DEAL_SYMBOL) == g_symbol &&
            HistoryDealGetInteger(ticket, DEAL_MAGIC) == InpMagicNumber &&
            HistoryDealGetInteger(ticket, DEAL_ENTRY) == DEAL_ENTRY_OUT)
         {
            dailyProfit += HistoryDealGetDouble(ticket, DEAL_PROFIT);
         }
      }
   }
   
   g_dailyPnL = dailyProfit;
}

//+------------------------------------------------------------------+
//| Check if daily risk limit is exceeded                            |
//+------------------------------------------------------------------+
bool IsDailyRiskExceeded()
{
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double maxDailyLoss = balance * (InpMaxDailyRisk / 100.0);
   
   if(g_dailyPnL < -maxDailyLoss)
      return true;
   
   return false;
}
//+------------------------------------------------------------------+
