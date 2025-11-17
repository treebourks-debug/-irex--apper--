# TIREX SAPPER - Техническа спецификация

## Обща информация

**Име на проекта**: TIREX SAPPER  
**Версия**: 1.00  
**Език**: MQL5  
**Платформа**: MetaTrader 5  
**Тип**: Expert Advisor (Автоматизирана търговска система)  
**Лиценз**: Open Source  

## Архитектура

### Файлова структура

```
-irex--apper--/
├── TIREX_SAPPER.mq5          # Основен EA файл (679 реда)
├── TIREX_SAPPER_Utils.mqh    # Библиотека с утилити (245 реда)
├── README.md                  # Главна документация
├── INSTALLATION.md            # Инсталационна инструкция
├── QUICKSTART.md              # Бърз старт
├── CONFIGURATIONS.md          # Примерни конфигурации
├── CHANGELOG.md               # История на версиите
├── TECHNICAL_SPEC.md          # Тази спецификация
└── .gitignore                 # Git ignore правила
```

## Основни компоненти

### 1. Трендово разпознаване (Trend Recognition)

**Принцип на работа:**
- Използва три експоненциални движещи средни (EMA):
  - Fast MA (по подразбиране: 10 периода)
  - Slow MA (по подразбиране: 50 периода)
  - Trend MA (по подразбиране: 200 периода)

**Логика за разпознаване:**
```
Uptrend (Бичи тренд):
  - Fast MA > Slow MA
  - Price > Trend MA
  - Минимум N последователни барове над Trend MA

Downtrend (Мечи тренд):
  - Fast MA < Slow MA
  - Price < Trend MA
  - Минимум N последователни барове под Trend MA
```

**Функции:**
- `DetectTrend()` - Връща 1 (up), -1 (down), или 0 (no trend)

### 2. Входове при корекции (Pullback Entry)

**Принцип на работа:**
- Търси временни корекции в основния тренд
- Използва Fibonacci нива (по подразбиране 38.2%)
- Опционален RSI филтър за потвърждение

**Логика:**
```
За Uptrend:
  - Намери най-високата цена в lookback периода
  - Изчисли корекция от върха
  - Провери дали корекцията е >= MinPullbackSize
  - Ако UseRSIFilter: RSI между Oversold и 50

За Downtrend:
  - Намери най-ниската цена в lookback периода
  - Изчисли корекция от дъното
  - Провери дали корекцията е >= MinPullbackSize
  - Ако UseRSIFilter: RSI между 50 и Overbought
```

**Функции:**
- `IsPullbackEntry(int trendDirection)` - Връща true/false

### 3. Мрежова логика (Grid System)

**Принцип на работа:**
- Не-мартингейл система (фиксиран лот размер)
- Отваря допълнителни позиции при движение на цената
- Ограничен максимален брой нива

**Логика:**
```
Условия за отваряне на grid level:
  - Съществуваща отворена позиция
  - Цената се е отдалечила >= GridStepPoints
  - Брой отворени позиции < MaxGridLevels
  - Ако GridSameDirection: нова позиция в същата посока
```

**Параметри:**
- GridStepPoints: Разстояние между нивата в points
- MaxGridLevels: Максимален брой едновременни позиции
- GridLotSize: Фиксиран размер (не мартингейл!)

**Функции:**
- `ManageGrid()` - Управлява grid позициите

### 4. Динамични стопове (Dynamic Stops)

#### 4.1 Trailing Stop

**Логика:**
```
Активира се когато:
  - Печалба >= TrailingStop_Points

Действие:
  - Премества SL на TrailingStop_Points от текущата цена
  - Използва TrailingStep_Points за минимално движение
  - Работи само в посока на печалбата (не връща назад)
```

#### 4.2 Break Even

**Логика:**
```
Активира се когато:
  - Печалба >= BreakEven_Points

Действие:
  - Премества SL на входната цена + BreakEven_Profit
  - Заключва минимална печалба
  - Изпълнява се само веднъж
```

**Функции:**
- `ManagePositions()` - Управлява trailing stop и break even
- `ModifyPosition(ulong ticket, double sl, double tp)` - Модифицира SL/TP

### 5. Адаптивен риск мениджмънт (Adaptive Risk Management)

#### 5.1 Адаптивен лот размер

**Формула:**
```
lotSize = (Balance * RiskPercent / 100) / (StopLossPoints * TickValue)

Нормализация:
  - Минимум: MinLotSize
  - Максимум: MaxLotSize
  - Стъпка: Symbol LotStep
```

#### 5.2 Дневни лимити

**Логика:**
```
Проверки при всеки тик:
  - Ако dailyLoss >= Balance * MaxDailyLoss / 100: СТОП
  - Ако dailyProfit >= Balance * MaxDailyProfit / 100: СТОП

Нулиране:
  - При смяна на датата (полунощ)
```

#### 5.3 Equity Stop

**Логика:**
```
Проверка:
  - equityDrawdown = (InitialBalance - CurrentEquity) / InitialBalance * 100
  
Ако equityDrawdown >= EquityStopPercent:
  - Затваря всички отворени позиции
  - Спира търговията
```

**Функции:**
- `CalculateLotSize()` - Изчислява адаптивен лот
- `CheckRiskLimits()` - Проверява всички рискови лимити
- `CloseAllPositions()` - Затваря всички позиции

### 6. Управление на позиции (Position Management)

**Функции:**
- `OpenPosition()` - Отваря нова позиция с валидация
- `CountPositions()` - Брои отворените позиции
- `ModifyPosition()` - Модифицира SL/TP
- `CloseAllPositions()` - Затваря всички позиции

**Error Handling:**
```
При OrderSend():
  1. Опит с ORDER_FILLING_FOK
  2. Ако неуспешно: Опит с ORDER_FILLING_IOC
  3. Логване на грешки
  4. Връща bool за успех/неуспех
```

## Входни параметри

### Категории (общо 45+ параметри)

1. **General Settings** (3 параметра)
   - ExpertComment, MagicNumber, EnableTrading

2. **Trend Recognition** (6 параметра)
   - FastMA_Period, SlowMA_Period, TrendMA_Period
   - MA_Method, MA_Price, MinTrendBars

3. **Pullback Entry** (7 параметра)
   - PullbackPercent, PullbackLookback, MinPullbackSize
   - UseRSIFilter, RSI_Period, RSI_Oversold, RSI_Overbought

4. **Grid Settings** (5 параметра)
   - EnableGrid, GridStepPoints, MaxGridLevels
   - GridLotSize, GridSameDirection

5. **Stop Loss & Take Profit** (9 параметра)
   - InitialSL_Points, InitialTP_Points
   - UseTrailingStop, TrailingStop_Points, TrailingStep_Points
   - UseBreakEven, BreakEven_Points, BreakEven_Profit

6. **Risk Management** (9 параметра)
   - RiskPercent, MaxDailyLoss, MaxDailyProfit
   - AdaptiveLotSize, MinLotSize, MaxLotSize
   - UseEquityStop, EquityStopPercent

7. **Multi-Symbol Settings** (3 параметра)
   - TradeCurrentSymbolOnly, AdditionalSymbols, Timeframe

8. **Time Filter** (3 параметра)
   - UseTimeFilter, StartHour, EndHour

## Поток на изпълнение

### OnInit()
```
1. Инициализира индикаторите (MA, RSI)
2. Настройва arrays (SetAsSeries)
3. Запазва началния баланс
4. Логва информация за инициализация
5. Връща INIT_SUCCEEDED или INIT_FAILED
```

### OnTick()
```
1. Проверка EnableTrading
2. Проверка времеви филтър
3. UpdateDailyStatistics()
4. CheckRiskLimits() - ако fail: return
5. UpdateIndicators() - ако fail: return
6. ManagePositions() - управление на съществуващи
7. CheckEntrySignals() - проверка за нови входове
8. ManageGrid() - ако EnableGrid
```

### OnDeinit()
```
1. Освобождава indicator handles
2. Логва информация за деинициализация
```

## Използвани индикатори

### iMA (Moving Average)
- Създава 3 handles (Fast, Slow, Trend)
- Buffer arrays: fastMA[], slowMA[], trendMA[]
- Използва CopyBuffer() за данни

### iRSI (Relative Strength Index)
- 1 handle
- Buffer array: rsiBuffer[]
- Използва се за филтриране на входове

## Технически детайли

### Нормализация на цени и лотове

```mql5
// Цени
price = NormalizeDouble(price, _Digits);

// Лотове
lotSize = NormalizeDouble(lotSize / lotStep, 0) * lotStep;
lotSize = MathMax(minLot, MathMin(maxLot, lotSize));
```

### Обработка на грешки

```mql5
// При OrderSend
if(!OrderSend(request, result))
{
   request.type_filling = ORDER_FILLING_IOC;
   if(!OrderSend(request, result))
   {
      Print("Order send error: ", result.retcode);
      return false;
   }
}
```

### Логване

```mql5
// Важни операции
Print("Position opened: ", orderType, " | Lot: ", lot);
Print("Daily loss limit reached: ", dailyLoss);
Print("Equity stop triggered: ", equityDrawdown, "%");
```

## Производителност

### Оптимизации
- Използва indicator handles (не пресмята индикатори на всеки тик)
- Arrays с SetAsSeries за бърз достъп
- Минимален брой OrderSend() повиквания
- Ефективни цикли

### Ресурси
- CPU: Минимално натоварване
- Памет: ~50KB за EA + индикаторни буфери
- Мрежа: Само при OrderSend/OrderModify

## Тестване

### Strategy Tester настройки
```
Mode: Every tick (най-точен)
Period: Минимум 3 месеца
Optimization: Genetic algorithm
Initial deposit: >= $1000
```

### Критерии за оценка
- Profit Factor > 1.5
- Sharpe Ratio > 1.0
- Max Drawdown < 20%
- Win Rate > 45%
- Recovery Factor > 3.0

## Сигурност и валидация

### Входна валидация
- Проверка на permissions (TerminalTradeAllowed, MQLTradeAllowed)
- Валидация на symbol trading mode
- Проверка на минимални/максимални стойности

### Защита от грешки
- Error handling при всички OrderSend()
- Проверка на indicator handles
- Проверка на CopyBuffer() резултати
- Валидация на лот размери

### Защита на капитала
- Daily loss limit
- Daily profit limit
- Equity stop
- Maximum grid levels
- Trailing stop & Break even

## Разширяемост

### Възможни разширения
1. Добавяне на нови индикатори (Bollinger Bands, ATR)
2. Machine Learning интеграция
3. Multi-timeframe analysis
4. Телеграм/Email нотификации
5. Web dashboard със статистика

### Hook points
```mql5
// Може да се добави преди entry
bool CustomFilter() { /* custom logic */ }

// Може да се добави при position management
void CustomManagement() { /* custom logic */ }
```

## Известни ограничения

1. **Еднопосочен анализ**: Анализира само текущия timeframe
2. **Фиксирани Fibonacci нива**: Не адаптира автоматично
3. **Липса на correlation analysis**: Не проверява корелация между символи
4. **Липса на sentiment analysis**: Не използва новини/sentiment
5. **MQL5 only**: Не работи на MT4

## Препоръки за production

1. **Минимален капитал**: $500 за реална сметка
2. **Leverage**: Препоръчително 1:100 до 1:500
3. **VPS**: Препоръчително за 24/7 работа
4. **Backup**: Редовно копие на настройките
5. **Monitoring**: Ежедневна проверка на логовете

## Поддръжка

- **GitHub**: https://github.com/treebourks-debug/-irex--apper--
- **Issues**: За bug reports и feature requests
- **Documentation**: Всички MD файлове в репозиторито

## Заключение

TIREX SAPPER е пълнофункционален, прозрачен MQL5 EA, който имплементира проверени принципи на търговия с фокус върху безопасност, адаптивност и прозрачност. Кодът е добре документиран, модулен и готов за използване и разширяване.

---

**Версия на документа**: 1.00  
**Дата**: 2024-11-17  
**Автор**: TIREX SAPPER Project
