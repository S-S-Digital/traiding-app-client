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
