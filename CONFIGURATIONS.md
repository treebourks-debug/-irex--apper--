# TIREX SAPPER - Примерни настройки

## Конфигурация за консервативна търговия на EURUSD H1

```
// Общи настройки
ExpertComment = "TIREX_SAPPER"
MagicNumber = 20241117
EnableTrading = true

// Разпознаване на тренд
FastMA_Period = 10
SlowMA_Period = 50
TrendMA_Period = 200
MA_Method = MODE_EMA
MinTrendBars = 3

// Входове при корекции
PullbackPercent = 0.382
PullbackLookback = 20
MinPullbackSize = 10
UseRSIFilter = true
RSI_Period = 14
RSI_Oversold = 30
RSI_Overbought = 70

// Мрежа
EnableGrid = true
GridStepPoints = 200
MaxGridLevels = 3
GridLotSize = 0.01
GridSameDirection = true

// Stop Loss & Take Profit
InitialSL_Points = 500
InitialTP_Points = 1000
UseTrailingStop = true
TrailingStop_Points = 300
TrailingStep_Points = 50
UseBreakEven = true
BreakEven_Points = 300
BreakEven_Profit = 50

// Управление на риска
RiskPercent = 0.5
MaxDailyLoss = 3.0
MaxDailyProfit = 10.0
AdaptiveLotSize = true
MinLotSize = 0.01
MaxLotSize = 1.0
UseEquityStop = true
EquityStopPercent = 10.0

// Времеви филтър
UseTimeFilter = false
```

## Конфигурация за агресивна търговия на GBPUSD M15

```
// Общи настройки
ExpertComment = "TIREX_SAPPER_AGGRESSIVE"
MagicNumber = 20241118
EnableTrading = true

// Разпознаване на тренд
FastMA_Period = 8
SlowMA_Period = 34
TrendMA_Period = 100
MA_Method = MODE_EMA
MinTrendBars = 2

// Входове при корекции
PullbackPercent = 0.5
PullbackLookback = 15
MinPullbackSize = 8
UseRSIFilter = true
RSI_Period = 10
RSI_Oversold = 35
RSI_Overbought = 65

// Мрежа
EnableGrid = true
GridStepPoints = 150
MaxGridLevels = 5
GridLotSize = 0.02
GridSameDirection = true

// Stop Loss & Take Profit
InitialSL_Points = 300
InitialTP_Points = 600
UseTrailingStop = true
TrailingStop_Points = 200
TrailingStep_Points = 30
UseBreakEven = true
BreakEven_Points = 200
BreakEven_Profit = 30

// Управление на риска
RiskPercent = 1.5
MaxDailyLoss = 5.0
MaxDailyProfit = 15.0
AdaptiveLotSize = true
MinLotSize = 0.01
MaxLotSize = 2.0
UseEquityStop = true
EquityStopPercent = 8.0

// Времеви филтър
UseTimeFilter = true
StartHour = 8
EndHour = 17
```

## Конфигурация за скалпинг на XAUUSD M5

```
// Общи настройки
ExpertComment = "TIREX_SAPPER_SCALPING"
MagicNumber = 20241119
EnableTrading = true

// Разпознаване на тренд
FastMA_Period = 5
SlowMA_Period = 20
TrendMA_Period = 50
MA_Method = MODE_EMA
MinTrendBars = 2

// Входове при корекции
PullbackPercent = 0.618
PullbackLookback = 10
MinPullbackSize = 20
UseRSIFilter = true
RSI_Period = 7
RSI_Oversold = 25
RSI_Overbought = 75

// Мрежа
EnableGrid = false
GridStepPoints = 100
MaxGridLevels = 2
GridLotSize = 0.01
GridSameDirection = true

// Stop Loss & Take Profit
InitialSL_Points = 200
InitialTP_Points = 300
UseTrailingStop = true
TrailingStop_Points = 100
TrailingStep_Points = 20
UseBreakEven = true
BreakEven_Points = 100
BreakEven_Profit = 20

// Управление на риска
RiskPercent = 1.0
MaxDailyLoss = 4.0
MaxDailyProfit = 12.0
AdaptiveLotSize = true
MinLotSize = 0.01
MaxLotSize = 1.0
UseEquityStop = true
EquityStopPercent = 5.0

// Времеви филтър
UseTimeFilter = true
StartHour = 9
EndHour = 16
```

## Забележки по оптимизация

### Период на движещите средни (MA Periods)
- **Краткосрочна търговия (M5-M15)**: Използвайте по-малки периоди (5-10 / 20-34 / 50-100)
- **Средносрочна търговия (H1-H4)**: Стандартни периоди (10 / 50 / 200)
- **Дългосрочна търговия (D1)**: По-големи периоди (20 / 100 / 400)

### Размер на мрежата (Grid Step)
- **Ниска волатилност**: 100-150 точки
- **Средна волатилност**: 150-250 точки
- **Висока волатилност**: 250-500 точки
- **Златото (XAUUSD)**: 100-300 точки
- **Индекси**: 50-150 точки

### Риск мениджмънт
- **Консервативен**: RiskPercent = 0.5%, MaxGridLevels = 3
- **Умерен**: RiskPercent = 1.0%, MaxGridLevels = 5
- **Агресивен**: RiskPercent = 1.5-2.0%, MaxGridLevels = 7

### Времеви филтър
- **Forex**: Търгувайте през Лондонската и Ню Йорската сесии (8:00-17:00 GMT)
- **Златото**: Избягвайте нощните часове (23:00-06:00)
- **Индекси**: Търгувайте през сесията на съответния индекс

## Тестване и валидация

1. **Strategy Tester настройки**
   - Период: Минимум 3 месеца
   - Модел: Every tick (най-точен)
   - Оптимизация: Genetic algorithm
   - Критерий: Sharpe Ratio или Recovery Factor

2. **Параметри за оптимизация**
   - Приоритетни: FastMA_Period, SlowMA_Period, GridStepPoints
   - Вторични: PullbackPercent, InitialSL_Points, InitialTP_Points
   - Фиксирани: MagicNumber, EnableTrading

3. **Оценка на резултатите**
   - Profit Factor > 1.5
   - Sharpe Ratio > 1.0
   - Max Drawdown < 20%
   - Win Rate > 45%
   - Recovery Factor > 3.0

## Предупреждения

⚠️ **Винаги тествайте нови настройки на демо сметка преди да ги използвате на реална!**

⚠️ **Не използвайте агресивни настройки с реални пари без достатъчно тестване!**

⚠️ **Адаптирайте настройките според текущата пазарна волатилност!**
