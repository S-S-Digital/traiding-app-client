// DTOs for the account-level strategy mode (backend Task #4 /
// IMPL_STRATEGY_PLUMBING.md):
//   GET  /users/strategy-mode -> { strategyMode, availableModes }
//   PUT  /users/strategy-mode  { strategyMode } -> { strategyMode }

class StrategyModeDto {
  const StrategyModeDto({required this.strategyMode, required this.availableModes});

  /// "quality" | "turnover".
  final String strategyMode;
  final List<String> availableModes;

  factory StrategyModeDto.fromJson(Map<String, dynamic> json) {
    final raw = json['availableModes'];
    return StrategyModeDto(
      strategyMode: json['strategyMode'] as String? ?? 'quality',
      availableModes: raw is List
          ? raw.map((e) => e.toString()).toList()
          : const ['quality', 'turnover'],
    );
  }
}

class UpdateStrategyMode {
  const UpdateStrategyMode({required this.strategyMode});
  final String strategyMode;

  Map<String, dynamic> toJson() => {'strategyMode': strategyMode};
}
