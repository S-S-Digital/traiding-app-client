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
  static String get youArePro => isRu ? 'Вы Pro! 🎉' : "You're Pro! 🎉";
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

  // ─── History ───
  static String get totalTrades => isRu ? 'Всего сделок' : 'Total trades';
  static String get successful => isRu ? 'Успешных' : 'Successful';
  static String get result => isRu ? 'Результат' : 'Result';

  // ─── Dialogs ───
  static String get confirmSignOut => isRu ? 'Вы уверены, что хотите выйти?' : 'Are you sure you want to sign out?';
  static String get cancel => isRu ? 'Отмена' : 'Cancel';
  static String get confirm => isRu ? 'Подтвердить' : 'Confirm';
  static String get ok => 'OK';

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
