import 'dart:convert';

import 'package:finalproject/models/device_location.dart';
import 'package:finalproject/models/waterloop.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoredAppData {
  const StoredAppData({
    this.locations = const [],
    this.ungroupedDevices = const [],
  });

  final List<DeviceLocation> locations;
  final List<WaterLoop> ungroupedDevices;
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
      );
    } catch (error) {
      debugPrint('Could not read saved Smart Loop data: $error');
      return const StoredAppData();
    }
  }

  Future<void> save({
    required List<DeviceLocation> locations,
    required List<WaterLoop> ungroupedDevices,
  }) {
    final storedJson = jsonEncode({
      'locations': locations.map((location) => location.toJson()).toList(),
      'ungroupedDevices': ungroupedDevices
          .map((device) => device.toJson())
          .toList(),
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
}
