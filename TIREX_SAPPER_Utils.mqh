//+------------------------------------------------------------------+
//|                                        TIREX_SAPPER_Utils.mqh    |
//|                        Copyright 2024, TIREX SAPPER Project      |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, TIREX SAPPER Project"
#property link      "https://github.com/treebourks-debug/-irex--apper--"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Utility functions for TIREX SAPPER EA                            |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Get current spread in points                                     |
//+------------------------------------------------------------------+
double GetSpreadPoints(string symbol)
{
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   
   if(point > 0)
      return (ask - bid) / point;
   
   return 0;
}

//+------------------------------------------------------------------+
//| Check if spread is acceptable                                    |
//+------------------------------------------------------------------+
bool IsSpreadAcceptable(string symbol, double maxSpreadPoints)
{
   double currentSpread = GetSpreadPoints(symbol);
   return (currentSpread <= maxSpreadPoints);
}

//+------------------------------------------------------------------+
//| Calculate position profit in account currency                    |
//+------------------------------------------------------------------+
double CalculatePositionProfit(ulong ticket)
{
   if(!PositionSelectByTicket(ticket)) return 0;
   return PositionGetDouble(POSITION_PROFIT);
}

//+------------------------------------------------------------------+
//| Calculate total profit for all positions                         |
//+------------------------------------------------------------------+
double CalculateTotalProfit(int magicNumber, string symbol = "")
{
   double totalProfit = 0;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      
      if(PositionGetInteger(POSITION_MAGIC) != magicNumber) continue;
      
      if(symbol != "" && PositionGetString(POSITION_SYMBOL) != symbol) continue;
      
      totalProfit += PositionGetDouble(POSITION_PROFIT);
   }
   
   return totalProfit;
}

//+------------------------------------------------------------------+
//| Format price with proper digits                                  |
//+------------------------------------------------------------------+
string FormatPrice(double price, string symbol = NULL)
{
   if(symbol == NULL) symbol = _Symbol;
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   return DoubleToString(price, digits);
}

//+------------------------------------------------------------------+
//| Check if symbol is trading allowed                               |
//+------------------------------------------------------------------+
bool IsSymbolTradingAllowed(string symbol)
{
   return SymbolInfoInteger(symbol, SYMBOL_TRADE_MODE) != SYMBOL_TRADE_MODE_DISABLED;
}

//+------------------------------------------------------------------+
//| Get symbol point value                                           |
//+------------------------------------------------------------------+
double GetSymbolPoint(string symbol)
{
   return SymbolInfoDouble(symbol, SYMBOL_POINT);
}

//+------------------------------------------------------------------+
//| Get optimal lot size based on free margin                        |
//+------------------------------------------------------------------+
double GetOptimalLotSize(string symbol, double riskPercent, double stopLossPoints)
{
   double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   
   if(tickValue == 0 || stopLossPoints == 0) return minLot;
   
   double riskAmount = freeMargin * riskPercent / 100.0;
   double lotSize = riskAmount / (stopLossPoints * tickValue);
   
   // Normalize
   lotSize = MathFloor(lotSize / lotStep) * lotStep;
   lotSize = MathMax(minLot, MathMin(maxLot, lotSize));
   
   return lotSize;
}

//+------------------------------------------------------------------+
//| Send notification                                                 |
//+------------------------------------------------------------------+
void SendNotification(string message, bool pushNotification = false)
{
   Print(message);
   
   if(pushNotification)
   {
      SendNotification(message);
   }
}

//+------------------------------------------------------------------+
//| Log trade information                                             |
//+------------------------------------------------------------------+
void LogTradeInfo(string action, ENUM_ORDER_TYPE orderType, double lot, 
                  double price, double sl, double tp)
{
   string msg = StringFormat("%s: %s %.2f lots at %.5f (SL: %.5f, TP: %.5f)",
                            action,
                            EnumToString(orderType),
                            lot,
                            price,
                            sl,
                            tp);
   Print(msg);
}

//+------------------------------------------------------------------+
//| Calculate RSI manually (fallback)                                |
//+------------------------------------------------------------------+
double CalculateRSI(string symbol, ENUM_TIMEFRAMES timeframe, int period, int shift = 0)
{
   double avgGain = 0, avgLoss = 0;
   
   for(int i = shift + 1; i <= shift + period; i++)
   {
      double change = iClose(symbol, timeframe, i-1) - iClose(symbol, timeframe, i);
      if(change > 0) avgGain += change;
      else avgLoss += MathAbs(change);
   }
   
   avgGain /= period;
   avgLoss /= period;
   
   if(avgLoss == 0) return 100;
   
   double rs = avgGain / avgLoss;
   double rsi = 100 - (100 / (1 + rs));
   
   return rsi;
}

//+------------------------------------------------------------------+
//| Check if new bar opened                                          |
//+------------------------------------------------------------------+
bool IsNewBar(string symbol, ENUM_TIMEFRAMES timeframe, datetime &lastBarTime)
{
   datetime currentBarTime = iTime(symbol, timeframe, 0);
   
   if(currentBarTime != lastBarTime)
   {
      lastBarTime = currentBarTime;
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Calculate ATR (Average True Range)                               |
//+------------------------------------------------------------------+
double CalculateATR(string symbol, ENUM_TIMEFRAMES timeframe, int period)
{
   double atr = 0;
   
   for(int i = 1; i <= period; i++)
   {
      double high = iHigh(symbol, timeframe, i);
      double low = iLow(symbol, timeframe, i);
      double prevClose = iClose(symbol, timeframe, i + 1);
      
      double tr = MathMax(high - low, 
                  MathMax(MathAbs(high - prevClose), 
                         MathAbs(low - prevClose)));
      
      atr += tr;
   }
   
   return atr / period;
}

//+------------------------------------------------------------------+
//| Get account leverage                                              |
//+------------------------------------------------------------------+
long GetAccountLeverage()
{
   return AccountInfoInteger(ACCOUNT_LEVERAGE);
}

//+------------------------------------------------------------------+
//| Check if EA can trade (permissions)                              |
//+------------------------------------------------------------------+
bool CanTrade()
{
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
   {
      Print("Trading not allowed in terminal");
      return false;
   }
   
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
   {
      Print("Trading not allowed for EA");
      return false;
   }
   
   if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
   {
      Print("Automated trading disabled for account");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
