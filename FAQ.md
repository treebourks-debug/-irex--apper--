# TIREX SAPPER - Frequently Asked Questions (FAQ)

## 📌 General Questions

### Q1: What is TIREX SAPPER?
**A:** TIREX SAPPER is a transparent MQL5 Expert Advisor that implements a trend-following strategy with pullback entries and grid logic. It's designed to be optimizable, safe (no dangerous martingale), and works across multiple symbols and timeframes.

### Q2: Is this EA suitable for beginners?
**A:** Yes, with proper education. The EA has conservative default settings and comprehensive documentation. However, beginners should:
- Thoroughly test on demo account first
- Start with minimal risk (0.5-1%)
- Understand basic trading concepts
- Learn risk management principles

### Q3: What makes TIREX SAPPER different from other EAs?
**A:**
- ✅ Completely transparent code (no black box)
- ✅ No dangerous martingale (fixed lot multiplier)
- ✅ Adaptive risk management
- ✅ Multi-layer trend confirmation
- ✅ Dynamic stops based on volatility
- ✅ Comprehensive documentation
- ✅ Open source and customizable

### Q4: How much capital do I need?
**A:** 
- **Minimum**: $100 (demo testing)
- **Recommended**: $500-1000 for live trading
- **Optimal**: $2000+ for comfortable risk management
- Higher capital allows better risk distribution and lower percentage risk

---

## 🔧 Technical Questions

### Q5: What symbols work best with this EA?
**A:** The EA is designed for multiple symbols:
- **Best**: Major forex pairs (EURUSD, GBPUSD, USDJPY)
- **Good**: Gold (XAUUSD), major indices
- **Test**: Minor pairs, exotic pairs
- **Avoid**: Highly illiquid symbols, symbols with huge spreads

### Q6: What timeframe should I use?
**A:**
- **Conservative**: H1, H4 (fewer trades, lower spread impact)
- **Balanced**: M30, H1 (moderate frequency)
- **Active**: M15, M30 (more trades, higher monitoring needed)
- **Avoid**: M1, M5 (too much noise for this strategy)

### Q7: Can I run multiple instances on different symbols?
**A:** Yes! Use different Magic Numbers for each instance:
```
EURUSD - Magic: 20241117
GBPUSD - Magic: 20241118
XAUUSD - Magic: 20241119
```
Adjust total risk accordingly (e.g., 0.5% per symbol if running 4 instances).

### Q8: How do I optimize the EA?
**A:** Use MetaTrader 5 Strategy Tester:
1. Tools → Strategy Tester
2. Select TIREX_SAPPER
3. Choose symbol and period
4. Set optimization parameters (see CONFIGURATION_EXAMPLES.md)
5. Run optimization
6. Analyze results (focus on Sharpe ratio, drawdown)
7. Forward test winning parameters on demo

---

## ⚙️ Configuration Questions

### Q9: What does "Grid Lot Multiplier" do?
**A:** Controls lot size for grid levels:
- **1.0**: Same lot size (NO martingale) ✅ Recommended
- **1.5**: Increase by 50% each level (mild averaging)
- **2.0**: Double each level (risky martingale) ⚠️ Not recommended

### Q10: Should I use Dynamic SL or Fixed SL?
**A:** 
- **Dynamic SL (recommended)**: Adapts to market volatility using ATR
  - Better in different market conditions
  - Wider stops in volatile markets
  - Tighter stops in calm markets
  
- **Fixed SL**: Same SL regardless of volatility
  - More predictable
  - Easier to backtest
  - May be too tight or too wide

### Q11: How many grid levels should I use?
**A:**
- **Beginner**: 2-3 levels (less exposure)
- **Intermediate**: 3-5 levels (balanced)
- **Advanced**: 5-7 levels (higher exposure, needs monitoring)
- **Warning**: More levels = more risk

### Q12: What risk percentage should I use?
**A:**
- **Ultra-conservative**: 0.5% per trade
- **Conservative**: 1.0% per trade ✅ Recommended
- **Moderate**: 1.5-2.0% per trade
- **Aggressive**: 2.5-3.0% per trade ⚠️ High risk
- **Never**: >5% per trade ❌

---

## 💰 Trading & Risk Questions

### Q13: How often does the EA trade?
**A:** Depends on:
- **Timeframe**: Lower = more trades
- **Market conditions**: Trending = more trades
- **Parameters**: Stricter RSI levels = fewer trades
- **Typical**: 1-5 signals per day on H1

### Q14: What is the expected win rate?
**A:** Varies by market conditions:
- **Trending markets**: 60-70% win rate
- **Ranging markets**: 40-50% win rate
- **Overall**: Target 55-65% win rate
- **Remember**: Win rate isn't everything; risk/reward matters more

### Q15: How does daily risk limit work?
**A:** 
- EA tracks all P&L for current day
- If total loss exceeds Max Daily Risk %, EA stops trading
- Resets at start of new trading day
- Protects against excessive drawdown in bad days

### Q16: What happens during news events?
**A:** 
- EA continues trading unless time filter is set
- High volatility may trigger more grid levels
- Wide spreads may prevent order execution
- **Recommendation**: Use time filter to avoid major news

---

## 🐛 Troubleshooting Questions

### Q17: Why isn't my EA opening any trades?
**Possible reasons:**
1. **No trend detected** - Market is ranging
2. **Time filter active** - Outside trading hours
3. **Daily risk exceeded** - Max loss reached for day
4. **No pullback** - Waiting for correction
5. **AutoTrading disabled** - Check MT5 toolbar
6. **Insufficient margin** - Check account balance
7. **RSI conditions not met** - Waiting for setup

**Solution**: Check Experts tab for messages

### Q18: Why did the EA open grid positions?
**A:** Grid positions open when:
1. Already have position in trend direction
2. Price moves against position by Grid Step points
3. Grid enabled and under max levels
4. This is normal averaging behavior

### Q19: Positions not closing at Take Profit?
**Check:**
- TP level is set correctly (check Trade tab)
- Broker honors TP levels (some brokers have minimum distance)
- Spread hasn't widened beyond TP
- Orders weren't manually modified

### Q20: How do I stop all trading immediately?
**A:**
1. **Remove EA from chart** (right-click chart → Expert Advisors → Remove)
2. **Or disable AutoTrading** (toolbar button)
3. **Close positions manually** (Trade tab → right-click → Close)
4. **EA will not open new trades** once removed/disabled

---

## 📊 Performance Questions

### Q21: What returns should I expect?
**A:** 
- **Realistic monthly**: 3-8% (with 1-2% risk)
- **Good months**: 10-15%
- **Bad months**: -5% to breakeven
- **Annual target**: 30-50% (with reasonable drawdown)
- **Warning**: Never guaranteed, market-dependent

### Q22: What is acceptable drawdown?
**A:**
- **Low risk (1% per trade)**: 10-15% max drawdown
- **Medium risk (2%)**: 15-25% max drawdown
- **High risk (3%)**: 25-35% max drawdown
- **Unacceptable**: >40% drawdown (too risky)

### Q23: How long should I test before going live?
**A:**
- **Minimum**: 2 weeks demo testing
- **Recommended**: 1 month demo + 1 month micro lots
- **Ideal**: 2-3 months thorough testing
- **Backtest**: Minimum 1 year historical data
- **Never skip testing!**

---

## 🔄 Strategy Questions

### Q24: What is pullback trading?
**A:** 
- Wait for established trend
- Enter when price temporarily moves against trend
- Catch the "correction" or "pullback"
- Ride the price back into trend direction
- Like buying a dip in an uptrend

### Q25: Why use RSI for confirmation?
**A:** RSI helps identify:
- Overbought/oversold conditions
- Momentum shifts
- Divergences
- Entry timing
- Reduces false signals

### Q26: How does the EA identify trends?
**A:** Multi-layer confirmation:
1. **Fast MA vs Slow MA** - Direction
2. **Price vs Trend MA** - Confirmation
3. **Both must align** - Reduces false signals

### Q27: What if the trend changes while holding positions?
**A:** 
- Trailing stop protects profits
- Stop loss limits losses
- EA won't add grid levels against new trend
- Positions close at SL/TP or trailing stop
- New trend → New position direction

---

## 🛠️ Customization Questions

### Q28: Can I modify the code?
**A:** Yes! The EA is open source:
- View and edit MQ5 file in MetaEditor
- Add custom indicators
- Modify entry/exit logic
- Add notifications
- **Remember**: Test thoroughly after changes

### Q29: Can I add email/push notifications?
**A:** Yes, you can add to the code:
```mql5
// After successful trade
SendNotification("TIREX SAPPER: Buy order opened at " + DoubleToString(price));
SendMail("Trade Alert", "Position opened: " + InpComment);
```

### Q30: Can I use this with other EAs?
**A:** Yes, but:
- Use different Magic Numbers
- Watch total account risk
- Don't trade same symbol with conflicting strategies
- Monitor margin carefully

---

## 📈 Advanced Questions

### Q31: Can I implement trailing take profit?
**A:** Not natively, but can be added:
- Modify UpdateTrailingStops() function
- Add trailing TP logic
- Move TP as price advances
- Keep code changes documented

### Q32: Can I add fundamental analysis filters?
**A:** Possible additions:
- Economic calendar integration
- News impact filters
- Correlation filters
- Sentiment indicators
- Requires custom coding

### Q33: Can I run this on VPS?
**A:** Yes, highly recommended:
- **Benefits**: 24/7 operation, low latency, stability
- **Setup**: Install MT5 on VPS, load EA
- **Requirements**: Minimal (1GB RAM, Windows VPS)
- **Providers**: Forex VPS, commercial VPS services

---

## 💡 Best Practices

### Q34: What are the key success factors?
**A:**
1. **Risk Management** - Never risk more than you can lose
2. **Testing** - Thorough demo testing required
3. **Monitoring** - Check EA daily initially
4. **Patience** - Don't expect overnight riches
5. **Education** - Understand the strategy
6. **Discipline** - Follow the rules
7. **Adaptation** - Adjust parameters as needed

### Q35: Common mistakes to avoid?
**A:**
1. ❌ Skipping demo testing
2. ❌ Using too much risk
3. ❌ Too many grid levels
4. ❌ Running on exotic pairs without testing
5. ❌ Changing parameters constantly
6. ❌ Not monitoring performance
7. ❌ Ignoring market conditions

---

## 🆘 Support Questions

### Q36: Where can I get help?
**A:**
- **Documentation**: README.md, QUICKSTART.md, ARCHITECTURE.md
- **GitHub Issues**: Report bugs, ask questions
- **Configuration**: See CONFIGURATION_EXAMPLES.md
- **Community**: GitHub Discussions (if available)

### Q37: How do I report a bug?
**A:** Create GitHub Issue with:
- MT5 version and build number
- EA parameters used
- Symbol and timeframe
- Error messages from Experts tab
- Steps to reproduce
- Screenshots if applicable

### Q38: How can I contribute?
**A:** See CONTRIBUTING.md:
- Bug fixes
- Feature additions
- Documentation improvements
- Test results sharing
- Community support

---

## ⚠️ Important Disclaimers

### Q39: Is profit guaranteed?
**A:** **NO**. Trading involves risk:
- Past performance ≠ future results
- You can lose money
- No EA guarantees profits
- Markets are unpredictable
- Use only risk capital

### Q40: Should I use this EA?
**A:** Only if:
- ✅ You understand the risks
- ✅ You can afford potential losses
- ✅ You've tested thoroughly
- ✅ You understand the strategy
- ✅ You'll monitor regularly
- ✅ You follow risk management

**If unsure, seek professional financial advice.**

---

## 📞 Quick Contact

- **Bugs**: GitHub Issues
- **Features**: GitHub Issues
- **Questions**: GitHub Discussions (or Issues)
- **Code**: GitHub Repository

---

*Last Updated: November 2024*
*FAQ Version: 1.0*

**Happy Trading! Remember: The best trader is an informed and cautious trader.** 📊✨
