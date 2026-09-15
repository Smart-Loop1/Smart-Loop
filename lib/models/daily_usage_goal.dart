enum UsageGoalPeriod {
  daily,
  monthly;

  String get storageName => name;

  static UsageGoalPeriod fromStorage(Object? value) {
    return value == monthly.name ? monthly : daily;
  }
}

enum DailyGoalUnit {
  liters,
  cost;

  String get storageName => name;

  static DailyGoalUnit fromStorage(Object? value) {
    return value == cost.name ? cost : liters;
  }
}

class DailyUsageGoal {
  const DailyUsageGoal({
    this.enabled = false,
    this.period = UsageGoalPeriod.daily,
    this.unit = DailyGoalUnit.liters,
    this.limit = 10,
  });

  final bool enabled;
  final UsageGoalPeriod period;
  final DailyGoalUnit unit;
  final double limit;

  Map<String, Object?> toJson() {
    return {
      'enabled': enabled,
      'period': period.storageName,
      'unit': unit.storageName,
      'limit': limit,
    };
  }

  factory DailyUsageGoal.fromJson(Object? value) {
    if (value is! Map<Object?, Object?>) return const DailyUsageGoal();

    final parsedLimit = (value['limit'] as num?)?.toDouble() ?? 10;
    return DailyUsageGoal(
      enabled: value['enabled'] as bool? ?? false,
      period: UsageGoalPeriod.fromStorage(value['period']),
      unit: DailyGoalUnit.fromStorage(value['unit']),
      limit: parsedLimit > 0 ? parsedLimit : 10,
    );
  }
}
