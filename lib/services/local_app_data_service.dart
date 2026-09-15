import 'dart:convert';

import 'package:finalproject/models/daily_usage_goal.dart';
import 'package:finalproject/models/device_location.dart';
import 'package:finalproject/models/waterloop.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoredAppData {
  const StoredAppData({
    this.locations = const [],
    this.ungroupedDevices = const [],
    this.dailyGoal = const DailyUsageGoal(),
    this.dailyUsageDateKey,
    this.dailyUsageLiters = 0,
    this.lastDeviceTotals = const {},
    this.dailyUsageHistory = const {},
  });

  final List<DeviceLocation> locations;
  final List<WaterLoop> ungroupedDevices;
  final DailyUsageGoal dailyGoal;
  final String? dailyUsageDateKey;
  final double dailyUsageLiters;
  final Map<String, double> lastDeviceTotals;
  final Map<String, double> dailyUsageHistory;
}

class LocalAppDataService {
  LocalAppDataService({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _storageKey = 'smart_loop_app_data_v1';

  final SharedPreferencesAsync _preferences;

  Future<StoredAppData> load() async {
    try {
      final storedJson = await _preferences.getString(_storageKey);
      if (storedJson == null || storedJson.isEmpty) {
        return const StoredAppData();
      }

      final decoded = jsonDecode(storedJson);
      if (decoded is! Map<String, dynamic>) return const StoredAppData();

      return StoredAppData(
        locations: _readLocations(decoded['locations']),
        ungroupedDevices: _readDevices(decoded['ungroupedDevices']),
        dailyGoal: DailyUsageGoal.fromJson(decoded['dailyGoal']),
        dailyUsageDateKey: decoded['dailyUsageDateKey'] as String?,
        dailyUsageLiters:
            (decoded['dailyUsageLiters'] as num?)?.toDouble() ?? 0,
        lastDeviceTotals: _readDoubleMap(decoded['lastDeviceTotals']),
        dailyUsageHistory: _readDoubleMap(decoded['dailyUsageHistory']),
      );
    } catch (error) {
      debugPrint('Could not read saved Smart Loop data: $error');
      return const StoredAppData();
    }
  }

  Future<void> save({
    required List<DeviceLocation> locations,
    required List<WaterLoop> ungroupedDevices,
    required DailyUsageGoal dailyGoal,
    required String dailyUsageDateKey,
    required double dailyUsageLiters,
    required Map<String, double> lastDeviceTotals,
    required Map<String, double> dailyUsageHistory,
  }) {
    final storedJson = jsonEncode({
      'locations': locations.map((location) => location.toJson()).toList(),
      'ungroupedDevices': ungroupedDevices
          .map((device) => device.toJson())
          .toList(),
      'dailyGoal': dailyGoal.toJson(),
      'dailyUsageDateKey': dailyUsageDateKey,
      'dailyUsageLiters': dailyUsageLiters,
      'lastDeviceTotals': lastDeviceTotals,
      'dailyUsageHistory': dailyUsageHistory,
    });

    return _preferences.setString(_storageKey, storedJson);
  }

  static List<DeviceLocation> _readLocations(Object? value) {
    if (value is! List<dynamic>) return const [];

    return [
      for (final location in value)
        if (location is Map<Object?, Object?>)
          DeviceLocation.fromJson(Map<String, dynamic>.from(location)),
    ];
  }

  static List<WaterLoop> _readDevices(Object? value) {
    if (value is! List<dynamic>) return const [];

    return [
      for (final device in value)
        if (device is Map<Object?, Object?>)
          WaterLoop.fromJson(Map<String, dynamic>.from(device)),
    ];
  }

  static Map<String, double> _readDoubleMap(Object? value) {
    if (value is! Map<Object?, Object?>) return const {};

    return {
      for (final entry in value.entries)
        if (entry.value is num)
          entry.key.toString(): (entry.value as num).toDouble(),
    };
  }
}
