# TIREX SAPPER - Quick Start Guide

## 🚀 Quick Start in 5 Minutes

### Step 1: Installation (1 minute)
1. Open MetaTrader 5
2. Click `File` → `Open Data Folder`
3. Navigate to `MQL5/Experts/`
4. Copy `TIREX_SAPPER.mq5` into this folder
5. Restart MetaTrader 5 (or press F4 and compile in MetaEditor)

### Step 2: Attach to Chart (1 minute)
1. Open a chart (e.g., EURUSD H1)
2. In Navigator panel, find `Expert Advisors` → `TIREX_SAPPER`
3. Drag and drop onto the chart
4. Click `OK` to use default settings (or customize - see below)
5. Ensure "AutoTrading" button is enabled (top toolbar)

### Step 3: Verify Setup (1 minute)
Check the "Experts" tab in Terminal window:
- You should see: "TIREX SAPPER initialized successfully on EURUSD"
- If error appears, check Experts tab for details

### Step 4: Demo Testing (2 minutes)
1. **ALWAYS start on DEMO account**
2. Monitor the "Experts" tab for signals and trades
3. Watch for position opens in "Trade" tab
4. Let it run for at least 1 hour to see first signals

---

## ⚙️ Basic Configuration

### For Beginners (Conservative Settings)
Use these settings when attaching the EA:

```
=== Risk Management ===
Risk per trade: 1.0%
Max daily risk: 2.5%

=== Grid Logic ===
Enable Grid: true
Max Grid Levels: 3

=== Stop Loss / Take Profit ===
Use Dynamic SL: true
Use Trailing Stop: true
```

### For Intermediate Traders (Balanced Settings)
```
=== Risk Management ===
Risk per trade: 1.5%
Max daily risk: 3.5%

=== Grid Logic ===
Enable Grid: true
Max Grid Levels: 5

=== Trend Detection ===
Trend MA Period: 50
Fast MA Period: 20
```

---

## 📊 Recommended Starting Configurations

### EUR/USD (H1) - Most Popular
- **Symbol**: EURUSD
- **Timeframe**: H1 (1 hour)
- **Risk per trade**: 1.0%
- **Grid enabled**: Yes (max 3 levels)
- **Best for**: Beginners

### Gold/XAU (M15) - More Active
- **Symbol**: XAUUSD
- **Timeframe**: M15 (15 minutes)
- **Risk per trade**: 1.5%
- **Grid enabled**: Yes (max 5 levels)
- **Grid Step**: 100 points
- **Best for**: Experienced traders

### GBP/USD (H1) - Moderate Volatility
- **Symbol**: GBPUSD
- **Timeframe**: H1
- **Risk per trade**: 1.0%
- **Grid enabled**: Yes (max 4 levels)
- **Best for**: All levels

---

## 🎯 What to Expect

### First Hour
- EA will analyze the market
- May not open trades immediately
- Wait for proper setup (trend + pullback)
- Monitor Experts tab for signals

### First Day
- Expect 1-5 trade signals depending on timeframe
- Some signals may not trigger trades (risk limits)
- Grid levels may activate in trending markets
- Monitor daily P&L in Experts tab

### First Week
- Get familiar with EA behavior
- Observe different market conditions
- Note which setups work best
- Consider parameter adjustment

---

## ✅ Pre-Flight Checklist

Before going live:

- [ ] Tested on DEMO account minimum 1 week
- [ ] Understand all input parameters
- [ ] Set appropriate risk per trade (1-2% recommended)
- [ ] Verified on your broker's spreads
- [ ] Checked margin requirements
- [ ] Set realistic expectations
- [ ] Have emergency stop plan
- [ ] Monitor first few days closely

---

## 🛑 Common Mistakes to Avoid

### ❌ Don't Do This:
1. **Too much risk** - Don't use >2% per trade initially
2. **Too many grid levels** - Start with 3, not 10
3. **No testing** - Never skip demo testing
4. **Ignoring news** - Be careful during major news events
5. **Multiple EAs** - Don't run multiple EAs with same magic number
6. **Wrong lot size** - Check minimum lot size for your broker
7. **No monitoring** - Check EA at least daily

### ✅ Do This Instead:
1. **Start conservative** - Use 1% risk
2. **Test thoroughly** - 1+ weeks on demo
3. **Monitor closely** - Check daily initially
4. **Adjust gradually** - Small parameter changes
5. **Keep records** - Note what works
6. **Stay informed** - Check economic calendar
7. **Be patient** - Results take time

---

## 📈 Performance Monitoring

### Daily Checks
- Open positions count
- Daily P&L
- Grid levels used
- Any errors in Experts tab

### Weekly Review
- Win rate
- Average trade duration
- Drawdown levels
- Parameter effectiveness

### Monthly Analysis
- Overall profitability
- Risk-adjusted returns
- Strategy tester comparison
- Parameter optimization needs

---

## 🔧 Quick Troubleshooting

### EA Not Opening Trades
- ✓ Check AutoTrading is enabled
- ✓ Verify account has sufficient margin
- ✓ Check time filter settings
- ✓ Ensure trend conditions are met
- ✓ Check daily risk limit not exceeded

### Too Many Trades
- ↓ Increase grid step size
- ↓ Reduce max grid levels
- ↓ Stricter RSI levels (65/35 instead of 70/30)
- ↓ Increase pullback threshold

### Too Few Trades
- ↑ Enable time filter off
- ↑ Reduce pullback threshold
- ↑ Wider RSI levels (75/25)
- ↑ Consider different timeframe

### Losses Exceeding Expectations
- Stop EA immediately
- Review settings vs market conditions
- Check if news events occurred
- Consider demo testing with new parameters
- Reduce risk per trade

---

## 📚 Next Steps

After successful demo testing:

1. **Review Documentation**
   - Read full README.md
   - Study CONFIGURATION_EXAMPLES.md
   - Check CHANGELOG.md for updates

2. **Optimize Parameters**
   - Use Strategy Tester
   - Test different combinations
   - Focus on risk-adjusted returns

3. **Live Trading**
   - Start with minimum lot sizes
   - Monitor closely first week
   - Gradually increase if successful
   - Keep trading journal

4. **Community**
   - Share experiences (GitHub Issues)
   - Report bugs if found
   - Suggest improvements
   - Help other users

---

## 📞 Support

Need help? Check these resources:

1. **Documentation**
   - README.md (full features)
   - CONFIGURATION_EXAMPLES.md (settings)
   - CONTRIBUTING.md (for developers)

2. **GitHub Issues**
   - Search existing issues
   - Create new issue with details
   - Tag appropriately

3. **Testing**
   - Always demo test first
   - Use Strategy Tester for backtesting
   - Forward test before live

---

## ⚠️ Important Reminders

> **Trading involves risk. Past performance does not guarantee future results.**

- Start on DEMO account
- Never risk more than you can afford to lose
- Monitor your trades regularly
- Adjust settings for your risk tolerance
- Stop trading if you don't understand something
- Seek professional advice if needed

---

## 🎓 Learning Resources

### Understanding the Strategy
1. **Trend Following**: Learn about Moving Averages
2. **Pullback Trading**: Study mean reversion concepts
3. **RSI**: Understand momentum indicators
4. **Grid Trading**: Research averaging strategies
5. **Risk Management**: Critical for long-term success

### Recommended Reading
- Technical Analysis basics
- Risk management principles
- Position sizing strategies
- Trading psychology
- Market structure

---

## ✨ Tips for Success

1. **Patience** - Don't expect overnight success
2. **Discipline** - Follow your risk management rules
3. **Consistency** - Don't change settings constantly
4. **Learning** - Understand why trades win/lose
5. **Adaptation** - Markets change, be flexible
6. **Documentation** - Keep trading journal
7. **Realistic Goals** - Aim for consistent modest gains

---

**Ready to Start?** 

Go back to Step 1 and begin your TIREX SAPPER journey! 

Good luck and happy trading! 📊✨

---

*Remember: The best trader is a well-informed and patient trader.*
