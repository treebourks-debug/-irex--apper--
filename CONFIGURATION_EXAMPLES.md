# TIREX SAPPER - Configuration Examples

## Примерни конфигурации за различни пазари и стилове на търговия

### 1. Conservative EUR/USD H1 (Консервативна настройка)

```
Symbol: EURUSD
Timeframe: H1
Magic Number: 20241117

=== Risk Management ===
Risk per trade: 1.0%
Max daily risk: 2.5%
Fixed lot size: 0.0 (auto)
Min lot size: 0.01
Max lot size: 1.0

=== Trend Detection ===
Trend MA Period: 50
Fast MA Period: 20
Slow MA Period: 50
MA Method: MODE_EMA
MA Applied Price: PRICE_CLOSE

=== Entry Logic ===
RSI Period: 14
RSI Overbought: 70
RSI Oversold: 30
Pullback Percent: 0.5
ATR Period: 14

=== Grid Logic ===
Enable Grid: true
Max Grid Levels: 3
Grid Step: 50
Grid Lot Multiplier: 1.0

=== Stop Loss / Take Profit ===
Initial Stop Loss: 100
Initial Take Profit: 200
Use Dynamic SL: true
Dynamic SL Multiplier: 2.0
Use Trailing Stop: true
Trailing Stop: 50
Trailing Step: 10

=== Time Filters ===
Use Time Filter: false
```

### 2. Aggressive Gold (XAU/USD) M15 (Агресивна настройка за злато)

```
Symbol: XAUUSD
Timeframe: M15
Magic Number: 20241118

=== Risk Management ===
Risk per trade: 2.0%
Max daily risk: 5.0%
Fixed lot size: 0.0 (auto)
Min lot size: 0.01
Max lot size: 2.0

=== Trend Detection ===
Trend MA Period: 30
Fast MA Period: 10
Slow MA Period: 30
MA Method: MODE_EMA
MA Applied Price: PRICE_CLOSE

=== Entry Logic ===
RSI Period: 10
RSI Overbought: 75
RSI Oversold: 25
Pullback Percent: 0.3
ATR Period: 10

=== Grid Logic ===
Enable Grid: true
Max Grid Levels: 5
Grid Step: 100
Grid Lot Multiplier: 1.0

=== Stop Loss / Take Profit ===
Initial Stop Loss: 200
Initial Take Profit: 400
Use Dynamic SL: true
Dynamic SL Multiplier: 2.5
Use Trailing Stop: true
Trailing Stop: 100
Trailing Step: 20

=== Time Filters ===
Use Time Filter: true
Start Hour: 8
End Hour: 17
```

### 3. Scalping GBP/USD M5 (Скалпинг настройка)

```
Symbol: GBPUSD
Timeframe: M5
Magic Number: 20241119

=== Risk Management ===
Risk per trade: 0.5%
Max daily risk: 2.0%
Fixed lot size: 0.0 (auto)
Min lot size: 0.01
Max lot size: 0.5

=== Trend Detection ===
Trend MA Period: 20
Fast MA Period: 5
Slow MA Period: 20
MA Method: MODE_EMA
MA Applied Price: PRICE_CLOSE

=== Entry Logic ===
RSI Period: 7
RSI Overbought: 80
RSI Oversold: 20
Pullback Percent: 0.2
ATR Period: 7

=== Grid Logic ===
Enable Grid: false
Max Grid Levels: 2
Grid Step: 30
Grid Lot Multiplier: 1.0

=== Stop Loss / Take Profit ===
Initial Stop Loss: 50
Initial Take Profit: 100
Use Dynamic SL: false
Dynamic SL Multiplier: 1.5
Use Trailing Stop: true
Trailing Stop: 30
Trailing Step: 5

=== Time Filters ===
Use Time Filter: true
Start Hour: 8
End Hour: 17
```

### 4. Swing Trading USD/JPY H4 (Swing търговия)

```
Symbol: USDJPY
Timeframe: H4
Magic Number: 20241120

=== Risk Management ===
Risk per trade: 1.5%
Max daily risk: 3.0%
Fixed lot size: 0.0 (auto)
Min lot size: 0.01
Max lot size: 2.0

=== Trend Detection ===
Trend MA Period: 100
Fast MA Period: 30
Slow MA Period: 80
MA Method: MODE_EMA
MA Applied Price: PRICE_CLOSE

=== Entry Logic ===
RSI Period: 14
RSI Overbought: 65
RSI Oversold: 35
Pullback Percent: 0.7
ATR Period: 14

=== Grid Logic ===
Enable Grid: true
Max Grid Levels: 4
Grid Step: 80
Grid Lot Multiplier: 1.0

=== Stop Loss / Take Profit ===
Initial Stop Loss: 150
Initial Take Profit: 300
Use Dynamic SL: true
Dynamic SL Multiplier: 3.0
Use Trailing Stop: true
Trailing Stop: 80
Trailing Step: 15

=== Time Filters ===
Use Time Filter: false
```

### 5. Multi-Symbol Portfolio (Портфолио подход)

За управление на множество символи едновременно, използвайте отделни инстанции на експерта с различни Magic Numbers:

```
EURUSD (H1) - Magic: 2024111701
GBPUSD (H1) - Magic: 2024111702
USDJPY (H1) - Magic: 2024111703
XAUUSD (H1) - Magic: 2024111704

Обща настройка:
- Risk per trade: 0.5% per symbol
- Max daily risk: 1.5% per symbol
- Grid: disabled or max 3 levels
- Conservative SL/TP ratios
```

## Препоръки за оптимизация

### Стъпка 1: Базова оптимизация (Fast Parameters)
Оптимизирайте основните параметри:
- Trend MA Period: 40-60 (step 10)
- Fast MA Period: 15-25 (step 5)
- RSI Period: 12-16 (step 2)

### Стъпка 2: Risk и Grid оптимизация
След намиране на добри MA параметри:
- Risk per trade: 0.5-2.0% (step 0.5)
- Grid Step: 40-80 (step 10)
- Max Grid Levels: 2-5 (step 1)

### Стъпка 3: Fine-tuning на SL/TP
Финална оптимизация:
- Stop Loss: 80-150 (step 10)
- Take Profit: 150-300 (step 25)
- Trailing Stop: 40-80 (step 10)

## Общи насоки

1. **Започнете консервативно**: Използвайте по-малък риск и по-малко grid нива
2. **Тествайте дълго**: Минимум 6-12 месеца исторически данни
3. **Различни пазарни условия**: Тествайте на тренд и странични пазари
4. **Forward testing**: Задължително тествайте на демо акаунт поне 1 месец
5. **Мониторинг**: Редовно проверявайте производителността и адаптирайте параметрите

## Предупреждения

- Не използвайте агресивни настройки без задълбочено тестване
- Grid trading увеличава експозицията - внимавайте с брой нива
- Различни брокери имат различни спредове - адаптирайте параметрите
- Новини и събития могат да повлияят на резултатите - внимавайте с времевите филтри
