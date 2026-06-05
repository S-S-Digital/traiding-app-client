/// Supported app languages

/// Supported app languages
enum AppLanguage { en, ru }

/// All translatable strings in the app
class AppLocalizations {
  AppLocalizations._();

  static AppLanguage _current = AppLanguage.en;

  static AppLanguage get current => _current;

  static void setLanguage(AppLanguage lang) {
    _current = lang;
  }

  static bool get isRu => _current == AppLanguage.ru;
  static bool get isEn => _current == AppLanguage.en;

  // ─── Navigation ───
  static String get market => isRu ? 'Рынок' : 'Market';
  static String get signals => isRu ? 'Сигналы' : 'Signals';
  static String get history => isRu ? 'История' : 'History';
  static String get profile => isRu ? 'Профиль' : 'Profile';

  // ─── Settings ───
  static String get account => isRu ? 'Аккаунт' : 'Account';
  static String get editProfile => isRu ? 'Редактировать профиль' : 'Edit Profile';
  static String get subscription => isRu ? 'Подписка' : 'Subscription';
  static String get support => isRu ? 'Поддержка' : 'Support';
  static String get termsOfUse => isRu ? 'Условия использования' : 'Terms of Use';
  static String get privacyPolicy => isRu ? 'Политика конфиденциальности' : 'Privacy Policy';
  static String get signOut => isRu ? 'Выйти' : 'Sign Out';
  static String get language => isRu ? 'Язык' : 'Language';
  static String get languageValue => isRu ? 'Русский' : 'English';
  static String get freePlan => isRu ? 'Бесплатный план' : 'Free Plan';
  static String get proPlan => isRu ? 'Pro план' : 'Pro Plan';
  static String get active => isRu ? 'Активна' : 'Active';
  static String get upgrade => isRu ? 'Улучшить' : 'Upgrade';
  static String get getFree => isRu ? 'Получить бесплатно' : 'Get for Free';
  static String get renews => isRu ? 'Обновляется' : 'Renews';
  
  // ─── Profile ───
  static String get email => isRu ? 'Почта' : 'Email';
  static String get plan => isRu ? 'План' : 'Plan';
  static String get tickers => isRu ? 'Тикеры' : 'Tickers';
  static String get unlimited => isRu ? 'Безлимит' : 'Unlimited';
  static String get premiumUntil => isRu ? 'Премиум до' : 'Premium until';
  static String get deleteAccount => isRu ? 'Удалить аккаунт' : 'Delete Account';
  static String get free => isRu ? 'Бесплатный' : 'Free';

  // ─── Subscription ───
  static String get upgradeToPro => isRu ? 'Перейти на ' : 'Upgrade to ';
  static String get pro => 'Pro';
  static String get youArePro => isRu ? 'Вы Pro!' : "You're Pro!";
  static String subscriptionActiveUntil(String date) =>
      isRu ? 'Ваша подписка активна до $date' : 'Your subscription is active until $date';
  static String get proDescription =>
      isRu ? 'Торговые сигналы по 20+ активам\nна 2 таймфреймах (15m, 1H)' 
            : 'Trading signals for 20+ assets\nacross 2 timeframes (15m, 1H)';
  static String get proActiveBadge => isRu ? 'Pro план активен' : 'Pro Plan Active';
  static String autoRenews(String date) => isRu ? 'Автообновление $date' : 'Auto-renews $date';
  static String subscribeTo(String price, String duration) =>
      isRu ? 'Подписка — $price$duration' : 'Subscribe — $price$duration';
  static String get selectAPlan => isRu ? 'Выберите план' : 'Select a plan';
  static String get restoring => isRu ? 'Восстановление...' : 'Restoring...';
  static String get cancelRestore =>
      isRu ? 'Отмена в любое время · Восстановить покупку' : 'Cancel anytime · Restore purchase';
  static String get termsOfService => isRu ? 'Условия использования' : 'Terms of Service';
  static String get accessGranted => isRu ? 'Доступ предоставлен!' : 'Access Granted!';
  static String get accessGrantedMessage =>
      isRu ? 'Спасибо за выбор! Теперь вы пользователь PRO.' : 'Thank you for choosing us! You are now a PRO user.';

  // ─── Purchase Result Screens ───
  static String get welcomeToPro => isRu ? 'Добро пожаловать в Pro!' : 'Welcome to Pro!';
  static String get purchaseSuccessSubtitle => isRu
      ? 'Подписка активна. Откройте все возможности Aspiro Pro.'
      : 'Your subscription is active. Enjoy everything Aspiro Pro has to offer.';
  static String get whatsUnlocked => isRu ? 'Что разблокировано' : "What's unlocked";
  static String get continueToApp => isRu ? 'Продолжить' : 'Continue';
  static String get featureUnlimitedSignals =>
      isRu ? 'Безлимитные торговые сигналы' : 'Unlimited trading signals';
  static String get featureAdvancedAnalytics =>
      isRu ? 'Расширенная AI-аналитика' : 'Advanced AI analytics';
  static String get featureUnlimitedTickers =>
      isRu ? 'Безлимитное отслеживание тикеров' : 'Unlimited ticker tracking';
  static String get featurePriorityAlerts =>
      isRu ? 'Мгновенные push-уведомления' : 'Real-time push alerts';

  static String get purchaseFailedTitle =>
      isRu ? 'Платёж не завершён' : "Payment didn't go through";
  static String get purchaseFailedGeneric => isRu
      ? 'Не удалось завершить покупку. Повторите попытку — средства не списаны.'
      : "We couldn't complete your purchase. Please try again — you haven't been charged.";
  static String get purchaseCancelled =>
      isRu ? 'Покупка отменена.' : 'Purchase was cancelled.';
  static String get nothingToRestore =>
      isRu ? 'Активные покупки не найдены.' : 'No active purchases to restore.';
  static String get retryPayment => isRu ? 'Попробовать снова' : 'Try Again';
  static String get restorePurchase => isRu ? 'Восстановить покупку' : 'Restore Purchase';
  static String get contactSupport => isRu ? 'Связаться с поддержкой' : 'Contact Support';
  static String get notNow => isRu ? 'Не сейчас' : 'Not Now';
  static String get supportEmail => 'support@aspiro.trade';
  static String get supportSubject =>
      isRu ? 'Проблема с оплатой Aspiro Pro' : 'Aspiro Pro payment issue';

  // ─── Trial & Annual ───
  static String get trialFree3Days => isRu ? '3 дня бесплатно' : '3 days free';
  static String get startFreeTrial => isRu ? 'Начать бесплатный период' : 'Start Free Trial';
  static String get save20 => isRu ? 'ВЫГОДА 20%' : 'SAVE 20%';
  static String get bestValue => isRu ? 'ЛУЧШАЯ ЦЕНА' : 'BEST VALUE';
  static String get mostPopular => isRu ? 'ПОПУЛЯРНЫЙ' : 'POPULAR';
  static String savingsPerYear(String amount) =>
      isRu ? 'Экономия $amount в год' : 'Save $amount per year';
  static String equivalentPerMonth(String amount) =>
      isRu ? '≈ $amount/мес' : '≈ $amount/mo';
  static String get trialDisclaimer =>
      isRu ? 'После бесплатного периода автоматическое списание. Отмена в любое время.'
            : 'Auto-charged after free trial. Cancel anytime.';
  static String get agreeToTerms =>
      isRu ? 'Я принимаю условия подписки' : 'I agree to subscription terms';
  static String get subscriptionNeeded =>
      isRu ? 'Подписка Pro для полного доступа' : 'Pro subscription for full access';
  static String get unlockAccess =>
      isRu ? 'Разблокировать' : 'Unlock Access';
  static String get premiumRequired =>
      isRu ? 'Требуется подписка' : 'Premium Required';
  static String get premiumSubtitle =>
      isRu ? 'Оформите Pro подписку\nчтобы разблокировать все функции' : 'Upgrade to Pro to unlock\nall features and tools';
  static String get premiumSignals =>
      isRu ? 'Сигналы' : 'Signals';
  static String get premiumAnalytics =>
      isRu ? 'Аналитика' : 'Analytics';
  static String get premiumTickers =>
      isRu ? 'Тикеры' : 'Tickers';
  static String get premiumAlerts =>
      isRu ? 'Оповещения' : 'Alerts';
  static String get upgradeToPlan =>
      isRu ? 'Оформить Pro' : 'Upgrade to Pro';
  static String get maybeLater =>
      isRu ? 'Позже' : 'Maybe Later';
  static String get trialEndsIn => isRu ? 'Trial заканчивается через' : 'Trial ends in';
  static String hoursRemaining(int hours) => isRu ? '$hours ч' : '${hours}h';

  // ─── Auth ───
  static String get login => isRu ? 'Войти' : 'Sign In';
  static String get register => isRu ? 'Регистрация' : 'Sign Up';
  static String get forgotPassword =>
      isRu ? 'Сброс пароля скоро будет доступен' : 'Password reset is coming soon';
  static String get fillAllFields => isRu ? 'Заполните все поля' : 'Please fill all fields';
  static String get agreePrefix =>
      isRu ? 'Продолжая, вы соглашаетесь с ' : 'By continuing, you agree to our ';
  static String get and => isRu ? ' и ' : ' and ';

  // ─── Assets / Search ───
  static String get nothingFound => isRu ? 'Ничего не найдено' : 'Nothing found';
  static String get searchCoins => isRu ? 'Поиск монет...' : 'Search coins...';
  
  // ─── Add Tickers ───
  static String get addTicker => isRu ? 'Добавить тикер' : 'Add Ticker';
  static String get tickerAdded => isRu ? 'Тикер добавлен' : 'Ticker Added';
  static String tickerAddedMessage(String symbol) => 
      isRu ? 'Тикер $symbol успешно добавлен в наблюдение.' : 'Ticker $symbol has been added to your watchlist.';
  static String get tickerAlreadyAdded => isRu ? 'Этот тикер с таким таймфреймом уже добавлен' : 'This ticker with this timeframe is already added';
  static String get subscriptionRequired => isRu ? 'Необходимо оформить подписку для добавления тикеров' : 'Subscription required to add tickers';
  static String get loading => isRu ? 'Загрузка...' : 'Loading...';
  static String get found => isRu ? 'Найден' : 'Found';
  static String get notFound => isRu ? 'Не найден' : 'Not found';
  static String get timeframe => isRu ? 'ТАЙМФРЕЙМ' : 'TIMEFRAME';
  static String get notifications => isRu ? 'УВЕДОМЛЕНИЯ' : 'NOTIFICATIONS';
  static String get buyAndSell => isRu ? 'Покупка и продажа' : 'Buy & Sell';
  static String get buyAndSellSubtitle => isRu ? 'уведомления о всех типах сигналов' : 'notifications for all signal types';
  static String get buyOnly => isRu ? 'Только покупка' : 'Buy only';
  static String get buyOnlySubtitle => isRu ? 'Уведомления только о сигналах покупки' : 'Notifications for buy signals only';
  static String get sellOnly => isRu ? 'Только продажа' : 'Sell only';
  static String get sellOnlySubtitle => isRu ? 'Уведомления только о сигналах продажи' : 'Notifications for sell signals only';
  static String addSymbol(String symbol, String? tf) => 
      isRu ? 'Добавить $symbol${tf != null ? " · $tf" : ""}' : 'Add $symbol${tf != null ? " · $tf" : ""}';
  static String get failedToLoad => isRu ? 'Не удалось загрузить' : 'Failed to load';
  static String get tryAgain => isRu ? 'Попробовать снова' : 'Try again';
  static String get buySignals => isRu ? 'Сигналы покупки' : 'Buy Signals';
  static String get sellSignals => isRu ? 'Сигналы продажи' : 'Sell Signals';
  static String get enabled => isRu ? 'Включено' : 'Enabled';
  static String get disabled => isRu ? 'Выключено' : 'Disabled';

  // ─── Update Tickers ───
  static String get tf15m => isRu ? '15 минут · Трейдинг' : '15 min · Trading';
  static String get tf1h => isRu ? '1 час · Инвестиции' : '1 hour · Investments';

  // ─── Signals ───
  static String get signalBuy => isRu ? 'ПОКУПКА' : 'BUY';
  static String get signalSell => isRu ? 'ПРОДАЖА' : 'SELL';
  static String get signalWait => isRu ? 'ОЖИДАНИЕ' : 'WAITING';
  static String get signalLabel => isRu ? 'Сигнал: ' : 'Signal: ';
  static String get directionLong => isRu ? 'ЛОНГ' : 'LONG';
  static String get directionShort => isRu ? 'ШОРТ' : 'SHORT';
  static String get statusClosed => isRu ? 'ЗАКРЫТ' : 'CLOSED';
  static String get entryLabel => isRu ? 'Вход' : 'Entry';
  static String get currentLabel => isRu ? 'Текущая' : 'Current';
  static String get closeLabel => isRu ? 'Закрытие' : 'Close';

  // ─── History ───
  static String get totalTrades => isRu ? 'Всего сделок' : 'Total trades';
  static String get successful => isRu ? 'Успешных' : 'Successful';
  static String get result => isRu ? 'Результат' : 'Result';
  static String get today => isRu ? 'Сегодня' : 'Today';
  static String get yesterday => isRu ? 'Вчера' : 'Yesterday';
  static String get noHistoryPeriod => isRu ? 'Нет истории за этот период' : 'No history for this period';
  static String get completedSignalsHere => isRu ? 'Завершенные сигналы появятся здесь' : 'Completed signals will appear here';
  static String get noHistoryYet => isRu ? 'История пуста' : 'No history yet';
  static String get sevenDays => isRu ? '7 дней' : '7 Days';
  static String get allTime => isRu ? 'Все' : 'All-Time';
  static String get todaysPerformance => isRu ? 'РЕЗУЛЬТАТ ЗА СЕГОДНЯ' : 'TODAY\'S PERFORMANCE';
  static String get sevenDaysPerformance => isRu ? 'РЕЗУЛЬТАТ ЗА 7 ДНЕЙ' : '7 DAYS PERFORMANCE';
  static String get allTimePerformance => isRu ? 'РЕЗУЛЬТАТ ЗА ВСЁ ВРЕМЯ' : 'ALL-TIME PERFORMANCE';
  static String get profitWord => isRu ? 'ПРИБЫЛЬ' : 'PROFIT';
  static String get lossWord => isRu ? 'УБЫТОК' : 'LOSS';
  static String get totalReturn => isRu ? 'ОБЩАЯ ДОХОДНОСТЬ' : 'TOTAL RETURN';
  static String get winRate => isRu ? 'ВИНРЕЙТ' : 'WIN RATE';
  static String get winWord => isRu ? 'Вин' : 'Win';
  static String get wWord => isRu ? 'В' : 'W';
  static String get lWord => isRu ? 'П' : 'L';
  static String get inWord => isRu ? 'Вход' : 'In';
  static String get outWord => isRu ? 'Выход' : 'Out';
  static String get takeProfit => 'Take Profit';
  static String get stopLoss => 'Stop Loss';
  static String get closed => isRu ? 'Закрыт' : 'Closed';

  // ─── Dialogs ───
  static String get confirmSignOut => isRu ? 'Вы уверены, что хотите выйти?' : 'Are you sure you want to sign out?';
  static String get cancel => isRu ? 'Отмена' : 'Cancel';
  static String get confirm => isRu ? 'Подтвердить' : 'Confirm';
  static String get ok => 'OK';
  static String get sessionExpired => isRu ? 'Сессия истекла' : 'Session Expired';
  static String get logInAgain => isRu ? 'Войдите в аккаунт заново' : 'Please log in again';
  static String get noInternet => isRu ? 'Нет подключения к интернету' : 'No internet connection';
  static String get close => isRu ? 'Закрыть' : 'Close';
  static String get deleteAccountConfirm => isRu ? 'Ваш профиль и все связанные данные будут стерты. Вы действительно хотите продолжить?' : 'Your profile and all associated data will be erased. Are you sure you want to continue?';
  static String get delete => isRu ? 'Удалить' : 'Delete';

  // ─── Digest / Analytics ───
  static String get aiAnalytics => isRu ? 'AI Аналитика' : 'AI Analytics';
  static String get analyticsTab => isRu ? 'Аналитика' : 'Analytics';
  static String get cryptocurrencies => isRu ? 'Криптовалюты' : 'Cryptocurrencies';
  static String get marketsAndCurrencies => isRu ? 'Рынки & Валюты' : 'Markets & Currencies';
  static String get errorLoadingAnalytics => isRu ? 'Ошибка загрузки аналитики' : 'Error loading analytics';
  static String get retry => isRu ? 'Повторить' : 'Retry';
  static String get noDigestReviewsYet => isRu ? 'Аналитических обзоров пока нет.' : 'No analytics reviews yet.';
  static String get premiumAiAnalytics => isRu ? 'Премиум Аналитика от AI' : 'Premium AI Analytics';
  static String get premiumDigestDisclaimer => 
      isRu ? 'Обзоры текущих суток доступны по Premium подписке. Разблокируйте доступ, чтобы видеть ежедневные инсайды!'
            : 'Today\'s digest is available to Premium subscribers. Unlock access to view daily market insights!';
  static String get marketSummary => isRu ? 'Резюме рынка' : 'Market Summary';
  static String get mainEvents => isRu ? 'Главные события' : 'Main Events';
  static String get technicalAnalysis => isRu ? 'Технический разбор' : 'Technical Analysis';
  static String get supportWord => isRu ? 'Поддержка' : 'Support';
  static String get resistanceWord => isRu ? 'Сопротивление' : 'Resistance';
  static String get strategyAndActionZones => isRu ? 'Зоны внимания и стратегия:' : 'Focus Zones & Strategy:';
  static String get neutralSentiment => isRu ? 'Нейтральный сентимент' : 'Neutral Sentiment';
  static String get bullishSentiment => isRu ? 'Бычий сентимент' : 'Bullish Sentiment';
  static String get bearishSentiment => isRu ? 'Медвежий сентимент' : 'Bearish Sentiment';
  static String get neutralImpact => isRu ? 'Нейтрально' : 'Neutral';
  static String get bullishImpact => isRu ? 'В рост' : 'Bullish';
  static String get bearishImpact => isRu ? 'Вниз' : 'Bearish';
  static String get riskControl => isRu ? 'Контроль рисков на сегодня' : 'Risk Control for Today';

  // ─── Per-asset Analytics (premium) ───
  static String get assetAnalyticsTitle => isRu ? 'AI Аналитика по активу' : 'AI Asset Analytics';
  static String get analyticsPerCoinTitle => isRu ? 'AI Аналитика по монетам' : 'AI Per-coin Analytics';
  static String get analyticsTrend => isRu ? 'Тренд' : 'Trend';
  static String get analyticsRegime => isRu ? 'Режим' : 'Regime';
  static String get analyticsVolatility => isRu ? 'Волатильность' : 'Volatility';
  static String get analyticsScenariosTitle => isRu ? 'Сценарии' : 'Scenarios';
  static String get analyticsSignalsLikely => isRu ? 'Сигналы вероятны сегодня' : 'Signals likely today';
  static String get analyticsSignalsUnlikely => isRu ? 'Сигналы маловероятны' : 'Signals unlikely';
  static String get analyticsLevels => isRu ? 'Ключевые уровни' : 'Key Levels';
  static String get analyticsNoData => isRu ? 'Аналитика по этому активу пока не готова' : 'No analytics for this asset yet';
  static String get analyticsLockedTeaser => isRu
      ? 'Подробный AI-разбор по активу — тренд, режим рынка, уровни и сценарии — доступен в Premium.'
      : 'Detailed AI breakdown — trend, market regime, levels and scenarios — is available in Premium.';
  static String trendValue(String? t) {
    switch (t) {
      case 'UP': return isRu ? 'Восходящий' : 'Up';
      case 'DOWN': return isRu ? 'Нисходящий' : 'Down';
      case 'FLAT': return isRu ? 'Боковой' : 'Flat';
      default: return '—';
    }
  }
  static String regimeValue(String? r) {
    switch (r) {
      case 'TREND': return isRu ? 'Тренд' : 'Trend';
      case 'RANGE': return isRu ? 'Флэт' : 'Range';
      default: return '—';
    }
  }
  static String scenarioType(String type) {
    switch (type) {
      case 'bounce': return isRu ? 'Отскок' : 'Bounce';
      case 'breakout': return isRu ? 'Пробой вверх' : 'Breakout';
      case 'breakdown': return isRu ? 'Пробой вниз' : 'Breakdown';
      case 'range': return isRu ? 'Флэт' : 'Range';
      default: return type;
    }
  }

  // ─── Strategy mode selector ───
  static String get strategyModeTitle => isRu ? 'Режим стратегии' : 'Strategy Mode';
  static String get strategyModeSubtitle => isRu
      ? 'Как фильтровать сигналы для вашего аккаунта'
      : 'How signals are filtered for your account';
  static String get strategyModeQuality => isRu ? 'Качество' : 'Quality';
  static String get strategyModeQualityDesc => isRu
      ? 'Только проверенные сигналы высокой уверенности. Меньше сделок, выше точность.'
      : 'Only validated high-conviction signals. Fewer trades, higher precision.';
  static String get strategyModeTurnover => isRu ? 'Оборот' : 'Turnover';
  static String get strategyModeTurnoverDesc => isRu
      ? 'Больше сигналов всех уровней. Больше сделок, выше активность.'
      : 'More signals across all tiers. More trades, higher activity.';
  static String get strategyModeSaved => isRu ? 'Режим обновлён' : 'Mode updated';
  // Static backtest stats panel (hardcoded numbers, not recomputed)
  static String get strategyModeBacktestLabel =>
      isRu ? 'Бэктест 90 дней, без комиссии' : 'Backtest 90 days, no commission';
  static String get strategyModeQualityExplain => isRu
      ? 'Строже, чище, спокойнее. Меньше сделок — выше точность.'
      : 'Stricter, cleaner, calmer. Fewer trades — higher precision.';
  static String get strategyModeTurnoverExplain => isRu
      ? 'Больше сделок для оборота на нулевой комиссии и малом депозите. Активнее, волатильнее.'
      : 'More trades for turnover on zero commission and a small deposit. More active, more volatile.';
  static String get strategyModeStatTrades => isRu ? 'Сделок/мес' : 'Trades/mo';
  static String get strategyModeStatWinrate => isRu ? 'Винрейт' : 'Win rate';
  static String get strategyModeStatPf => isRu ? 'Profit factor' : 'Profit factor';
  static String get strategyModeStatMaxDd => isRu ? 'Макс. просадка' : 'Max drawdown';
  static String get strategyModeChartAxis => isRu ? '\$, рост за 90д' : '\$, growth over 90d';
  static String get strategyModeDisclaimer => isRu
      ? 'Исторический бэктест без комиссии. Не гарантия будущей доходности.'
      : 'Historical backtest without commission. Not a guarantee of future returns.';

  // ─── Login / Register ───
  static String get welcomeBack => isRu ? 'С возвращением' : 'Welcome back';
  static String get signInSubtitle => isRu ? 'Войдите в Aspiro Trade' : 'Sign in to Aspiro Trade';
  static String get noAccount => isRu ? 'Нет аккаунта?' : "Don't have an account?";
  static String get createAccount => isRu ? 'Создать аккаунт' : 'Create Account';
  static String get joinSubtitle => isRu ? 'Присоединяйтесь к Aspiro Trade' : 'Join Aspiro Trade today';
  static String get alreadyHaveAccount => isRu ? 'Уже есть аккаунт?' : 'Already have an account?';
  static String get password => isRu ? 'Пароль' : 'Password';
  static String get enterPassword => isRu ? 'Введите пароль' : 'Enter password';
  static String get orDivider => isRu ? 'или' : 'or';
  static String get searchCountry => isRu ? 'Поиск страны...' : 'Search country...';

  // ─── Signals ───
  static String get filterAll => isRu ? 'Все' : 'All';
  static String get filterBuy => isRu ? 'Покупка' : 'Buy';
  static String get filterSell => isRu ? 'Продажа' : 'Sell';
  static String get noSignalsFilter => isRu ? 'Нет сигналов для этого фильтра' : 'No signals for this filter';
  static String get noActiveSignals => isRu ? 'Нет активных сигналов' : 'No active signals';
  static String get addTickerHint => isRu ? 'Добавьте тикер, чтобы начать\nполучать торговые сигналы' : 'Add a ticker to start receiving\ntrading signals';
  static String get activeCount => isRu ? 'активных' : 'active';

  // ─── Tickers / Market ───
  static String get addAsset => isRu ? 'Добавить' : 'Add Asset';
  static String get assetColumn => isRu ? 'АКТИВ' : 'ASSET';
  static String get trendColumn => isRu ? 'ТРЕНД' : 'TREND';
  static String get priceColumn => isRu ? 'ЦЕНА / 24Ч' : 'PRICE / 24H';
  static String get noTickersYet => isRu ? 'Тикеров пока нет' : 'No tickers yet';
  static String get addFirstTicker => isRu ? 'Добавьте первый тикер, чтобы\nначать отслеживать рынок' : 'Add your first ticker to start\ntracking the market';
  static String get noData => isRu ? 'Нет данных' : 'No data';

  // ─── Settings ───
  static String get defaultUserName => isRu ? 'Пользователь' : 'User';
  static String get legalSecurity => isRu ? 'ЮРИДИЧЕСКАЯ ИНФОРМАЦИЯ' : 'LEGAL & SECURITY';
  static String get disconnectSession => isRu ? 'Отключить сессию' : 'Disconnect Session';
  static String get earnFree => isRu ? 'Получить бесплатно' : 'Earn Free';
  static String get activePipeline => isRu ? 'АКТИВНЫЕ АЛГО-СКАНЕРЫ' : 'ACTIVE ALGO SCANNERS';
  static String get estimatedNodeValue => isRu ? 'ЭФФЕКТИВНОСТЬ СИГНАЛОВ' : 'SIGNALS PERFORMANCE';
  static String get viewMore => isRu ? 'Подробнее' : 'View More';
  static String appVersion(String version) => isRu ? 'Aspiro Trading Engine v$version' : 'Aspiro Trading Engine v$version';

  // ─── Profile ───
  static String get proNodeActive => isRu ? 'PRO СТАТУС АКТИВЕН' : 'PRO STATUS ACTIVE';
  static String get accountMetrics => isRu ? 'МЕТРИКИ И ДЕТАЛИ АККАУНТА' : 'ACCOUNT METRICS & DETAILS';
  static String get emailCopied => isRu ? 'Email скопирован' : 'Email copied to clipboard';
  static String get proYear => isRu ? 'PRO · ГОД' : 'PRO · YEAR';
  static String get premiumWord => isRu ? 'Премиум' : 'Premium';
  static String get basicWord => isRu ? 'Базовый' : 'Basic';
  static String get canAdd => isRu ? 'Можно добавлять' : 'Can add';
  static String get limitReached => isRu ? 'Достигнут лимит' : 'Limit reached';
  static String get statusLabel => isRu ? 'Статус' : 'Status';
  static String get availableFeatures => isRu ? 'Доступные функции:' : 'Available features:';

  // ─── Subscription ───
  static String get unlockPotential => isRu ? 'Разблокируй полный потенциал' : 'Unlock Your Full Potential';
  static String get unlockPotentialSub => isRu ? 'Получи доступ к расширенной аналитике, неограниченным сигналам и приоритетной поддержке' : 'Get access to advanced analytics, unlimited signals and priority support';
  static String get includedLabel => isRu ? 'Включено:' : 'Included:';
  static String get untilPrefix => isRu ? 'до ' : 'until ';
  static String get currentPlan => isRu ? 'Ваш текущий тариф' : 'Your current plan';
  static String subscribeFor(String price) => isRu ? 'Подписаться за $price\$' : 'Subscribe for $price\$';
  static String get basicPlanLabel => isRu ? 'У вас обычный тариф' : 'You have a basic plan';
  static String get appleEulaNote => isRu ? 'См. также: Apple Standard EULA' : 'See also: Apple Standard EULA';

  // ─── Asset Details ───
  static String get marketStats => isRu ? 'СТАТИСТИКА РЫНКА' : 'MARKET STATS';
  static String get volume24h => isRu ? 'Объём 24ч' : 'Volume 24h';

  // ─── Shared Widgets ───
  static String get deleteTicker => isRu ? 'Удалить тикер?' : 'Delete ticker?';
  static String get cannotUndo => isRu ? 'Это действие нельзя отменить.' : 'This action cannot be undone.';
  static String get errorTitle => isRu ? 'Ошибка' : 'Error';
  static String get tickersWord => isRu ? 'тикеров' : 'tickers';
  static String get daysWord => isRu ? 'дней' : 'days';
  static String get manageSubscription => isRu ? 'Управление подпиской' : 'Manage Subscription';
  static String get seeAlsoAppleEula => isRu ? 'См. также: Apple Standard EULA' : 'See also: Apple Standard EULA';
  static String get done => isRu ? 'Готово' : 'Done';
  static String get analyzingMarkets => isRu ? 'Анализируем рынки...' : 'Analyzing markets...';
  static String get tickerSettings => isRu ? 'Настройки тикера' : 'Ticker Settings';
  static String get save => isRu ? 'Сохранить' : 'Save';
  static String get open => isRu ? 'Открыт' : 'Open';

  // ─── Error Messages ───
  static String get errorNoNetwork => isRu ? 'Нет подключения к сети или сервер недоступен' : 'No network connection or server unavailable';
  static String get errorTimeout => isRu ? 'Сервер не отвечает. Попробуйте позже.' : 'Server not responding. Try again later.';
  static String errorConnection(String? msg) => isRu ? 'Произошла ошибка соединения: $msg' : 'Connection error: $msg';
  static String get errorBadRequest => isRu ? 'Некорректный запрос' : 'Invalid request';
  static String get errorUnauthorized => isRu ? 'Необходима авторизация' : 'Authorization required';
  static String get errorForbidden => isRu ? 'Недостаточно прав!' : 'Insufficient permissions!';
  static String get errorConflict => isRu ? 'Конфликт данных' : 'Data conflict';
  static String get errorTooManyRequests => isRu ? 'Слишком много запросов. Попробуйте позже' : 'Too many requests. Try again later';
  static String get errorServer => isRu ? 'Ошибка сервера' : 'Server error';
  static String get errorServerUnavailable => isRu ? 'Сервер временно недоступен' : 'Server temporarily unavailable';
  static String get errorUnknown => isRu ? 'Неизвестная ошибка' : 'Unknown error';
  static String get errorInvalidCredentials => isRu ? 'Неверный логин или пароль' : 'Invalid login or password';
  static String get errorUserNotFound => isRu ? 'Пользователь не найден' : 'User not found';
  static String get errorEmailExists => isRu ? 'Этот Email уже зарегистрирован' : 'This email is already registered';
  static String get errorNoConnection => isRu ? 'Нет подключения к сети' : 'No network connection';
  static String get errorSessionExpired => isRu ? 'Сессия истекла, войдите заново' : 'Session expired, please log in again';
  static String get errorPremiumRequired => isRu ? 'Необходимо приобрести Premium подписку' : 'Premium subscription required';

  // ─── Domain model ───
  static String readableDuration(int duration) {
    if (isRu) {
      switch (duration) {
        case 7: return '/неделя';
        case 30: return '/месяц';
        case 365: return '/год';
        default: return '$duration дней';
      }
    } else {
      switch (duration) {
        case 7: return '/week';
        case 30: return '/month';
        case 365: return '/year';
        default: return '$duration days';
      }
    }
  }
  
  static String readableFeature(String feature) {
    final map = isRu
        ? {
            'view_signals': 'Просмотр сигналов',
            'add_tickers': 'Добавление тикеров',
            'receive_signals': 'Получение сигналов',
            'push_notifications': 'Push-уведомления',
            'signal_history': 'История сигналов',
            'advanced_analytics': 'Расширенная аналитика',
            'priority_support': 'Приоритетная поддержка',
            'unlimited_signals': 'Безлимитные сигналы',
            'custom_alerts': 'Пользовательские уведомления',
            'lifetime_updates': 'Пожизненное обновление',
          }
        : {
            'view_signals': 'View Signals',
            'add_tickers': 'Add Tickers',
            'receive_signals': 'Receive Signals',
            'push_notifications': 'Push Notifications',
            'signal_history': 'Signal History',
            'advanced_analytics': 'Advanced Analytics',
            'priority_support': 'Priority Support',
            'unlimited_signals': 'Unlimited Signals',
            'custom_alerts': 'Custom Alerts',
            'lifetime_updates': 'Lifetime Updates',
          };
    return map[feature] ?? feature;
  }
}
