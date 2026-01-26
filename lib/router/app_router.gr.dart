// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AddTickersScreen]
class AddTickersRoute extends PageRouteInfo<AddTickersRouteArgs> {
  AddTickersRoute({
    Key? key,
    required Assets assets,
    List<PageRouteInfo>? children,
  }) : super(
         AddTickersRoute.name,
         args: AddTickersRouteArgs(key: key, assets: assets),
         initialChildren: children,
       );

  static const String name = 'AddTickersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddTickersRouteArgs>();
      return AddTickersScreen(key: args.key, assets: args.assets);
    },
  );
}

class AddTickersRouteArgs {
  const AddTickersRouteArgs({this.key, required this.assets});

  final Key? key;

  final Assets assets;

  @override
  String toString() {
    return 'AddTickersRouteArgs{key: $key, assets: $assets}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AddTickersRouteArgs) return false;
    return key == other.key && assets == other.assets;
  }

  @override
  int get hashCode => key.hashCode ^ assets.hashCode;
}

/// generated route for
/// [AssetDetailsScreen]
class AssetDetailsRoute extends PageRouteInfo<AssetDetailsRouteArgs> {
  AssetDetailsRoute({
    Key? key,
    required Assets assets,
    List<PageRouteInfo>? children,
  }) : super(
         AssetDetailsRoute.name,
         args: AssetDetailsRouteArgs(key: key, assets: assets),
         initialChildren: children,
       );

  static const String name = 'AssetDetailsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AssetDetailsRouteArgs>();
      return AssetDetailsScreen(key: args.key, assets: args.assets);
    },
  );
}

class AssetDetailsRouteArgs {
  const AssetDetailsRouteArgs({this.key, required this.assets});

  final Key? key;

  final Assets assets;

  @override
  String toString() {
    return 'AssetDetailsRouteArgs{key: $key, assets: $assets}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AssetDetailsRouteArgs) return false;
    return key == other.key && assets == other.assets;
  }

  @override
  int get hashCode => key.hashCode ^ assets.hashCode;
}

/// generated route for
/// [AssetsScreen]
class AssetsRoute extends PageRouteInfo<void> {
  const AssetsRoute({List<PageRouteInfo>? children})
    : super(AssetsRoute.name, initialChildren: children);

  static const String name = 'AssetsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AssetsScreen();
    },
  );
}

/// generated route for
/// [HistoryScreen]
class HistoryRoute extends PageRouteInfo<void> {
  const HistoryRoute({List<PageRouteInfo>? children})
    : super(HistoryRoute.name, initialChildren: children);

  static const String name = 'HistoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HistoryScreen();
    },
  );
}

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeScreen();
    },
  );
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginScreen();
    },
  );
}

/// generated route for
/// [PrivacyPolicyScreen]
class PrivacyPolicyRoute extends PageRouteInfo<void> {
  const PrivacyPolicyRoute({List<PageRouteInfo>? children})
    : super(PrivacyPolicyRoute.name, initialChildren: children);

  static const String name = 'PrivacyPolicyRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PrivacyPolicyScreen();
    },
  );
}

/// generated route for
/// [ProfileScreen]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileScreen();
    },
  );
}

/// generated route for
/// [RegisterScreen]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RegisterScreen();
    },
  );
}

/// generated route for
/// [SettingsScreen]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsScreen();
    },
  );
}

/// generated route for
/// [SignalsScreen]
class SignalsRoute extends PageRouteInfo<void> {
  const SignalsRoute({List<PageRouteInfo>? children})
    : super(SignalsRoute.name, initialChildren: children);

  static const String name = 'SignalsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SignalsScreen();
    },
  );
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashScreen();
    },
  );
}

/// generated route for
/// [SubscriptionScreen]
class SubscriptionRoute extends PageRouteInfo<void> {
  const SubscriptionRoute({List<PageRouteInfo>? children})
    : super(SubscriptionRoute.name, initialChildren: children);

  static const String name = 'SubscriptionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SubscriptionScreen();
    },
  );
}

/// generated route for
/// [TermsOfUseScreen]
class TermsOfUseRoute extends PageRouteInfo<void> {
  const TermsOfUseRoute({List<PageRouteInfo>? children})
    : super(TermsOfUseRoute.name, initialChildren: children);

  static const String name = 'TermsOfUseRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TermsOfUseScreen();
    },
  );
}

/// generated route for
/// [TickersScreen]
class TickersRoute extends PageRouteInfo<void> {
  const TickersRoute({List<PageRouteInfo>? children})
    : super(TickersRoute.name, initialChildren: children);

  static const String name = 'TickersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TickersScreen();
    },
  );
}

/// generated route for
/// [UpdateTickersScreen]
class UpdateTickersRoute extends PageRouteInfo<UpdateTickersRouteArgs> {
  UpdateTickersRoute({
    Key? key,
    required CombinedTicker tickers,
    List<PageRouteInfo>? children,
  }) : super(
         UpdateTickersRoute.name,
         args: UpdateTickersRouteArgs(key: key, tickers: tickers),
         initialChildren: children,
       );

  static const String name = 'UpdateTickersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UpdateTickersRouteArgs>();
      return UpdateTickersScreen(key: args.key, tickers: args.tickers);
    },
  );
}

class UpdateTickersRouteArgs {
  const UpdateTickersRouteArgs({this.key, required this.tickers});

  final Key? key;

  final CombinedTicker tickers;

  @override
  String toString() {
    return 'UpdateTickersRouteArgs{key: $key, tickers: $tickers}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UpdateTickersRouteArgs) return false;
    return key == other.key && tickers == other.tickers;
  }

  @override
  int get hashCode => key.hashCode ^ tickers.hashCode;
}
