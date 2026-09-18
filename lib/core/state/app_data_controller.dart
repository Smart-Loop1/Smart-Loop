import 'dart:async';

import 'package:finalproject/core/utils/saudi_residential_water_tariff.dart';
import 'package:finalproject/models/daily_usage_goal.dart';
import 'package:finalproject/models/device_location.dart';
import 'package:finalproject/models/water_loop_reading.dart';
import 'package:finalproject/models/waterloop.dart';
import 'package:finalproject/services/firebase_water_service.dart';
import 'package:finalproject/services/local_app_data_service.dart';
import 'package:flutter/foundation.dart';

class AppDataController extends ChangeNotifier {
  AppDataController({LocalAppDataService? storage, this.firebaseWaterService})
    : _storage = storage ?? LocalAppDataService();

  final LocalAppDataService _storage;
  final FirebaseWaterService? firebaseWaterService;
  final List<DeviceLocation> _locations = [];
  final List<WaterLoop> _ungroupedDevices = [];
  Future<void> _saveQueue = Future.value();
  StreamSubscription<Map<String, WaterLoopReading>>? _deviceSubscription;
  Map<String, WaterLoopReading> _cloudReadings = const {};
  DailyUsageGoal _dailyGoal = const DailyUsageGoal();
  String _dailyUsageDateKey = '';
  double _dailyUsageLiters = 0;
  final Map<String, double> _lastDeviceTotals = {};
  final Map<String, double> _dailyUsageHistory = {};
  Timer? _dailyResetTimer;

  List<DeviceLocation> get locations => List.unmodifiable(_locations);
  List<WaterLoop> get ungroupedDevices => List.unmodifiable(_ungroupedDevices);
  List<WaterLoop> get allDevices => [
    ..._ungroupedDevices,
    for (final location in _locations) ...location.devices,
  ];
  DailyUsageGoal get dailyGoal => _dailyGoal;
  String get dailyUsageDateKey => _dailyUsageDateKey;
  double get dailyUsageLiters => _dailyUsageLiters;
  double get usageGoalLiters {
    if (_dailyGoal.period == UsageGoalPeriod.daily) {
      return _dailyUsageLiters;
    }
    final now = DateTime.now();
    return usageForMonth(now.year, now.month);
  }

  double get usageGoalEstimatedCost =>
      SaudiResidentialWaterTariff.estimateWaterCost(usageGoalLiters);
  double get dailyGoalCurrentValue => _dailyGoal.unit == DailyGoalUnit.liters
      ? usageGoalLiters
      : usageGoalEstimatedCost;
  String get usageGoalPeriodKey {
    if (_dailyGoal.period == UsageGoalPeriod.daily) {
      return _dailyUsageDateKey;
    }
    final now = DateTime.now();
    return [
      now.year.toString().padLeft(4, '0'),
      now.month.toString().padLeft(2, '0'),
    ].join('-');
  }

  double get dailyGoalProgress {
    if (!_dailyGoal.enabled || _dailyGoal.limit <= 0) return 0;
    return dailyGoalCurrentValue / _dailyGoal.limit;
  }

  double usageForMonth(int year, int month) {
    final prefix = [
      year.toString().padLeft(4, '0'),
      month.toString().padLeft(2, '0'),
    ].join('-');
    return _dailyUsageHistory.entries
        .where((entry) => entry.key.startsWith(prefix))
        .fold(0, (sum, entry) => sum + entry.value);
  }

  double usageForYear(int year) {
    final prefix = '${year.toString().padLeft(4, '0')}-';
    return _dailyUsageHistory.entries
        .where((entry) => entry.key.startsWith(prefix))
        .fold(0, (sum, entry) => sum + entry.value);
  }

  double estimatedCostForMonth(int year, int month) {
    return SaudiResidentialWaterTariff.estimateWaterCost(
      usageForMonth(year, month),
    );
  }

  double estimatedCostForYear(int year) {
    var cost = 0.0;
    for (var month = 1; month <= 12; month++) {
      cost += estimatedCostForMonth(year, month);
    }
    return cost;
  }

  Future<void> load() async {
    final storedData = await _storage.load();
    final todayKey = _dateKey(DateTime.now());
    _locations
      ..clear()
      ..addAll(storedData.locations);
    _ungroupedDevices
      ..clear()
      ..addAll(storedData.ungroupedDevices);
    _dailyGoal = storedData.dailyGoal;
    _dailyUsageDateKey = storedData.dailyUsageDateKey ?? '';
    _dailyUsageLiters = storedData.dailyUsageLiters;
    _lastDeviceTotals
      ..clear()
      ..addAll(storedData.lastDeviceTotals);
    _dailyUsageHistory
      ..clear()
      ..addAll(storedData.dailyUsageHistory);

    // Older saved data may contain a meter baseline without having counted it
    // in today's usage. Clear only that stale baseline so the next reading
    // seeds today's usage from the flow meter's total.
    if (_dailyUsageDateKey == todayKey &&
        _dailyUsageLiters == 0 &&
        !_dailyUsageHistory.containsKey(todayKey)) {
      _lastDeviceTotals.clear();
    }
    _resetDailyUsageIfNeeded();
    _scheduleDailyReset();
    _notifyAndPersist();
  }

  void connectToCloud() {
    final service = firebaseWaterService;
    if (service == null || _deviceSubscription != null) return;

    _deviceSubscription = service.watchDevices().listen(
      _applyCloudReadings,
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Could not read Smart Loop cloud data: $error');
      },
    );
  }

  String nextDeviceId() {
    final usedIds = {
      ..._ungroupedDevices.map((device) => device.id),
      for (final location in _locations)
        ...location.devices.map((device) => device.id),
    };

    for (var number = 1; ; number++) {
      final id = 'SL-${number.toString().padLeft(3, '0')}';
      if (!usedIds.contains(id)) return id;
    }
  }

  WaterLoop? deviceById(String id) {
    for (final device in _ungroupedDevices) {
      if (device.id == id) return device;
    }
    for (final location in _locations) {
      for (final device in location.devices) {
        if (device.id == id) return device;
      }
    }
    return null;
  }

  void addLocation(DeviceLocation location) {
    _locations.add(location);
    _notifyAndPersist();
  }

  void updateDailyGoal(DailyUsageGoal goal) {
    _dailyGoal = goal;
    _notifyAndPersist();
  }

  void addDevice(WaterLoop device, {String? locationId}) {
    final syncedDevice = _syncDevice(device);
    if (locationId == null) {
      _ungroupedDevices.add(syncedDevice);
      _notifyAndPersist();
      return;
    }

    final locationIndex = _locations.indexWhere(
      (location) => location.id == locationId,
    );
    if (locationIndex == -1) {
      _ungroupedDevices.add(syncedDevice);
      _notifyAndPersist();
      return;
    }

    final location = _locations[locationIndex];
    _locations[locationIndex] = location.copyWith(
      devices: [...location.devices, syncedDevice],
    );
    _notifyAndPersist();
  }

  void updateLocation({
    required String id,
    required String name,
    required LocationIconType iconType,
  }) {
    final index = _locations.indexWhere((location) => location.id == id);
    if (index == -1) return;

    _locations[index] = _locations[index].copyWith(
      name: name,
      iconType: iconType,
    );
    _notifyAndPersist();
  }

  void deleteLocation(String id) {
    final index = _locations.indexWhere((location) => location.id == id);
    if (index == -1) return;

    _ungroupedDevices.addAll(_locations[index].devices);
    _locations.removeAt(index);
    _notifyAndPersist();
  }

  void renameDevice(String id, String name) {
    final ungroupedIndex = _ungroupedDevices.indexWhere(
      (device) => device.id == id,
    );
    if (ungroupedIndex != -1) {
      _ungroupedDevices[ungroupedIndex] = _ungroupedDevices[ungroupedIndex]
          .copyWith(name: name);
      _notifyAndPersist();
      return;
    }

    for (
      var locationIndex = 0;
      locationIndex < _locations.length;
      locationIndex++
    ) {
      final location = _locations[locationIndex];
      final deviceIndex = location.devices.indexWhere(
        (device) => device.id == id,
      );
      if (deviceIndex == -1) continue;

      final devices = [...location.devices];
      devices[deviceIndex] = devices[deviceIndex].copyWith(name: name);
      _locations[locationIndex] = location.copyWith(devices: devices);
      _notifyAndPersist();
      return;
    }
  }

  void deleteDevice(String id) {
    final previousUngroupedCount = _ungroupedDevices.length;
    _ungroupedDevices.removeWhere((device) => device.id == id);
    var changed = _ungroupedDevices.length != previousUngroupedCount;

    for (var index = 0; index < _locations.length; index++) {
      final location = _locations[index];
      final devices = location.devices
          .where((device) => device.id != id)
          .toList();
      if (devices.length == location.devices.length) continue;

      _locations[index] = location.copyWith(devices: devices);
      changed = true;
    }

    if (changed) _notifyAndPersist();
  }

  void _applyCloudReadings(Map<String, WaterLoopReading> readings) {
    final dailyUsageChanged = _recordDailyUsage(readings);
    _cloudReadings = readings;
    var changed = false;
    var createdDemoDevice = false;

    final hasDemoDevice =
        [
          ..._ungroupedDevices,
          for (final location in _locations) ...location.devices,
        ].any(
          (device) =>
              device.id == 'SL-001' ||
              device.name.trim().toLowerCase() == 'test',
        );
    if (readings.containsKey('SL-001') && !hasDemoDevice) {
      _ungroupedDevices.add(
        _syncDevice(const WaterLoop(id: 'SL-001', name: 'Test')),
      );
      changed = true;
      createdDemoDevice = true;
    }

    for (var index = 0; index < _ungroupedDevices.length; index++) {
      final current = _ungroupedDevices[index];
      final synced = _syncDevice(current);
      if (identical(current, synced)) continue;
      _ungroupedDevices[index] = synced;
      changed = true;
    }

    for (
      var locationIndex = 0;
      locationIndex < _locations.length;
      locationIndex++
    ) {
      final location = _locations[locationIndex];
      final devices = [...location.devices];
      var locationChanged = false;

      for (var deviceIndex = 0; deviceIndex < devices.length; deviceIndex++) {
        final current = devices[deviceIndex];
        final synced = _syncDevice(current);
        if (identical(current, synced)) continue;
        devices[deviceIndex] = synced;
        locationChanged = true;
      }

      if (!locationChanged) continue;
      _locations[locationIndex] = location.copyWith(devices: devices);
      changed = true;
    }

    if (createdDemoDevice || dailyUsageChanged) {
      _notifyAndPersist();
    } else if (changed) {
      notifyListeners();
    }
  }

  bool _recordDailyUsage(Map<String, WaterLoopReading> readings) {
    var changed = _resetDailyUsageIfNeeded();

    for (final entry in readings.entries) {
      final currentTotal = entry.value.totalLiters;
      if (!currentTotal.isFinite || currentTotal < 0) continue;

      final previousTotal = _lastDeviceTotals[entry.key];
      if (previousTotal == null) {
        _lastDeviceTotals[entry.key] = currentTotal;
        if (currentTotal > 0) {
          _dailyUsageLiters += currentTotal;
          _dailyUsageHistory[_dailyUsageDateKey] = _dailyUsageLiters;
        }
        changed = true;
        continue;
      }
      if (currentTotal == previousTotal) continue;

      _lastDeviceTotals[entry.key] = currentTotal;
      changed = true;

      final addedLiters = currentTotal >= previousTotal
          ? currentTotal - previousTotal
          : currentTotal;
      if (addedLiters <= 0) continue;

      _dailyUsageLiters += addedLiters;
      _dailyUsageHistory[_dailyUsageDateKey] = _dailyUsageLiters;
    }

    return changed;
  }

  bool _resetDailyUsageIfNeeded() {
    final todayKey = _dateKey(DateTime.now());
    if (_dailyUsageDateKey == todayKey) return false;

    _dailyUsageDateKey = todayKey;
    _dailyUsageLiters = _dailyUsageHistory[todayKey] ?? 0;
    return true;
  }

  void _scheduleDailyReset() {
    _dailyResetTimer?.cancel();
    final now = DateTime.now();
    final nextDay = DateTime(now.year, now.month, now.day + 1);
    _dailyResetTimer = Timer(nextDay.difference(now), () {
      if (_resetDailyUsageIfNeeded()) _notifyAndPersist();
      _scheduleDailyReset();
    });
  }

  static String _dateKey(DateTime value) {
    return [
      value.year.toString().padLeft(4, '0'),
      value.month.toString().padLeft(2, '0'),
      value.day.toString().padLeft(2, '0'),
    ].join('-');
  }

  WaterLoop _syncDevice(WaterLoop device) {
    final reading =
        _cloudReadings[device.id] ??
        (device.name.trim().toLowerCase() == 'test'
            ? _cloudReadings['SL-001']
            : null);
    if (reading == null ||
        (device.totalLiters == reading.totalLiters &&
            device.currentFlowRate == reading.currentFlowRate &&
            device.status == reading.status &&
            device.lastSeen == reading.lastSeen)) {
      return device;
    }

    return device.copyWith(
      totalLiters: reading.totalLiters,
      currentFlowRate: reading.currentFlowRate,
      status: reading.status,
      lastSeen: reading.lastSeen,
    );
  }

  void _notifyAndPersist() {
    notifyListeners();

    final locationsSnapshot = List<DeviceLocation>.of(_locations);
    final devicesSnapshot = List<WaterLoop>.of(_ungroupedDevices);
    final dailyGoalSnapshot = _dailyGoal;
    final dailyUsageDateKeySnapshot = _dailyUsageDateKey;
    final dailyUsageLitersSnapshot = _dailyUsageLiters;
    final lastDeviceTotalsSnapshot = Map<String, double>.of(_lastDeviceTotals);
    final dailyUsageHistorySnapshot = Map<String, double>.of(
      _dailyUsageHistory,
    );
    _saveQueue = _saveQueue.then(
      (_) => _saveSnapshot(
        locationsSnapshot,
        devicesSnapshot,
        dailyGoalSnapshot,
        dailyUsageDateKeySnapshot,
        dailyUsageLitersSnapshot,
        lastDeviceTotalsSnapshot,
        dailyUsageHistorySnapshot,
      ),
    );
  }

  Future<void> _saveSnapshot(
    List<DeviceLocation> locations,
    List<WaterLoop> ungroupedDevices,
    DailyUsageGoal dailyGoal,
    String dailyUsageDateKey,
    double dailyUsageLiters,
    Map<String, double> lastDeviceTotals,
    Map<String, double> dailyUsageHistory,
  ) async {
    try {
      await _storage.save(
        locations: locations,
        ungroupedDevices: ungroupedDevices,
        dailyGoal: dailyGoal,
        dailyUsageDateKey: dailyUsageDateKey,
        dailyUsageLiters: dailyUsageLiters,
        lastDeviceTotals: lastDeviceTotals,
        dailyUsageHistory: dailyUsageHistory,
      );
    } catch (error) {
      debugPrint('Could not save Smart Loop data: $error');
    }
  }

  @override
  void dispose() {
    _dailyResetTimer?.cancel();
    _deviceSubscription?.cancel();
    super.dispose();
  }
}
