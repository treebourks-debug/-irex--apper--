# CHANGELOG

All notable changes to the TIREX SAPPER project will be documented in this file.

## [1.0.0] - 2024-11-17

### Added
- Initial release of TIREX SAPPER MQL5 Expert Advisor
- Complete transparent implementation of Exorcist-style trading strategy
- Trend recognition using multiple Moving Averages (Fast, Slow, Trend)
- Pullback entry logic with RSI confirmation
- Grid trading system without dangerous martingale
- Dynamic stop loss based on ATR (Average True Range)
- Trailing stop functionality for profit protection
- Adaptive risk management system
- Risk per trade calculation based on account balance percentage
- Maximum daily risk limit protection
- Multi-symbol support (works on any symbol)
- Multi-timeframe analysis capability
- Time filter for trading hours restriction
- Comprehensive input parameters for full customization
- Position management and tracking
- Grid level management with configurable maximum levels
- Lot size normalization according to broker requirements
- Daily P&L tracking and monitoring

### Features

#### Trend Detection
- Trend MA (default period: 50)
- Fast MA (default period: 20)
- Slow MA (default period: 50)
- Configurable MA method (EMA, SMA, SMMA, LWMA)
- Price position relative to trend MA confirmation

#### Entry Logic
- RSI indicator for overbought/oversold conditions (default period: 14)
- Pullback detection based on ATR percentage
- Entry timing on trend corrections
- Multiple confirmation levels

#### Grid System
- Configurable grid step (default: 50 points)
- Maximum grid levels (default: 5)
- Grid lot multiplier (default: 1.0 - no martingale)
- Independent grid positions with individual SL/TP

#### Risk Management
- Auto lot size calculation based on risk percentage
- Default risk: 1% per trade
- Maximum daily risk: 3%
- Position size limits (min/max lot size)
- Balance-based risk calculation

#### Stop Management
- Fixed stop loss option (default: 100 points)
- Dynamic stop loss based on ATR (default: 2.0 x ATR)
- Fixed take profit (default: 200 points)
- Trailing stop (default: 50 points)
- Trailing step (default: 10 points)

#### Additional Features
- Time filter for trading hours
- Magic number for order identification
- Custom order comments
- Symbol auto-detection
- Broker-specific parameter normalization

### Technical Details
- Language: MQL5
- Compatible with: MetaTrader 5
- Minimum deposit: Varies by risk settings (recommended: $100+)
- Recommended timeframes: M5, M15, M30, H1, H4
- Recommended symbols: Major forex pairs, gold, indices

### Documentation
- Comprehensive README with feature descriptions
- Configuration examples for different markets
- Optimization guidelines
- Strategy explanation
- Installation instructions

### Code Quality
- Clean, readable code structure
- Extensive comments and documentation
- Modular function design
- Error handling and validation
- Proper resource management

### Testing Recommendations
- Backtest minimum 12 months historical data
- Forward test on demo account minimum 1 month
- Test on multiple symbols and timeframes
- Validate under different market conditions
- Monitor drawdown and risk metrics

## [Planned Features]

### Version 1.1.0 (Future)
- [ ] Multiple timeframe analysis (MTF)
- [ ] Additional indicators (MACD, Stochastic)
- [ ] News filter integration
- [ ] Email/Push notifications
- [ ] Advanced position averaging strategies
- [ ] Break-even functionality
- [ ] Partial close options
- [ ] Custom session filters
- [ ] Equity-based risk management
- [ ] Advanced trailing stop algorithms

### Version 1.2.0 (Future)
- [ ] Machine learning trend prediction
- [ ] Market correlation analysis
- [ ] Portfolio management features
- [ ] Advanced statistics and reporting
- [ ] Strategy tester optimization modes
- [ ] Multi-currency support
- [ ] Risk/Reward ratio calculator
- [ ] Spread filter
- [ ] Volatility filter
- [ ] Economic calendar integration

### Version 2.0.0 (Future)
- [ ] Complete strategy framework
- [ ] Multiple strategy modes
- [ ] Advanced AI integration
- [ ] Cloud-based optimization
- [ ] Social trading features
- [ ] API integration
- [ ] Mobile app support
- [ ] Advanced analytics dashboard

## Known Issues
- None reported in initial release

## Notes
- This is the initial stable release
- Tested on major forex pairs and gold
- Optimized for H1 timeframe
- Default parameters are conservative
- Always test on demo account first
- Adjust parameters for specific symbols and market conditions

## Support
For issues, questions, or feature requests, please use the GitHub Issues section.

---

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
