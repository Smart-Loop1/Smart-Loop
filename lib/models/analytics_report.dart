import 'package:finalproject/extensions/water_loop_extensions.dart';
import 'package:finalproject/models/device_location.dart';
import 'package:finalproject/models/waterloop.dart';

class AnalyticsReport {
  const AnalyticsReport({
    required this.generatedAt,
    required this.periodLabel,
    this.thisMonthLiters,
    this.thisMonthCost,
    this.lastMonthLiters,
    this.lastMonthCost,
    this.yearlyLiters,
    this.yearlyCost,
    this.dailyAverageLiters,
    this.peakFlowRate,
    this.totalDevices,
    this.onlineDevices,
    this.leakAlerts,
    this.monthlyUsage = const [],
    this.locationUsage = const [],
    this.devices = const [],
  });

  final DateTime generatedAt;
  final String periodLabel;
  final double? thisMonthLiters;
  final double? thisMonthCost;
  final double? lastMonthLiters;
  final double? lastMonthCost;
  final double? yearlyLiters;
  final double? yearlyCost;
  final double? dailyAverageLiters;
  final double? peakFlowRate;
  final int? totalDevices;
  final int? onlineDevices;
  final int? leakAlerts;
  final List<MonthlyUsage> monthlyUsage;
  final List<LocationUsage> locationUsage;
  final List<DeviceAnalytics> devices;

  int? get offlineDevices {
    if (totalDevices == null || onlineDevices == null) return null;
    return totalDevices! - onlineDevices!;
  }

  double? get monthlyChangePercent {
    final current = thisMonthLiters;
    final previous = lastMonthLiters;
    if (current == null || previous == null || previous == 0) return null;
    return ((current - previous) / previous) * 100;
  }

  factory AnalyticsReport.awaitingCloudData() {
    return AnalyticsReport(
      generatedAt: DateTime.now(),
      periodLabel: 'All available data',
    );
  }

  factory AnalyticsReport.fromDevices({
    required List<DeviceLocation> locations,
    required List<WaterLoop> ungroupedDevices,
    double? thisMonthLiters,
    double? thisMonthCost,
    double? lastMonthLiters,
    double? lastMonthCost,
    double? yearlyLiters,
    double? yearlyCost,
    List<MonthlyUsage> monthlyUsage = const [],
  }) {
    final devices = <DeviceAnalytics>[
      for (final device in ungroupedDevices)
        DeviceAnalytics(
          name: device.name,
          location: 'Unassigned',
          status: device.connectionLabel,
          totalLiters: device.totalLiters,
          currentFlowRate: device.currentFlowRate,
        ),
      for (final location in locations)
        for (final device in location.devices)
          DeviceAnalytics(
            name: device.name,
            location: location.name,
            status: device.connectionLabel,
            totalLiters: device.totalLiters,
            currentFlowRate: device.currentFlowRate,
          ),
    ];

    final locationUsage = <LocationUsage>[
      for (final location in locations)
        LocationUsage(
          name: location.name,
          liters: _sumAvailableLiters(location.devices),
        ),
      if (ungroupedDevices.isNotEmpty)
        LocationUsage(
          name: 'Unassigned',
          liters: _sumAvailableLiters(ungroupedDevices),
        ),
    ];

    return AnalyticsReport(
      generatedAt: DateTime.now(),
      periodLabel: 'All available data',
      thisMonthLiters: thisMonthLiters,
      thisMonthCost: thisMonthCost,
      lastMonthLiters: lastMonthLiters,
      lastMonthCost: lastMonthCost,
      yearlyLiters: yearlyLiters,
      yearlyCost: yearlyCost,
      totalDevices: devices.length,
      devices: devices,
      monthlyUsage: monthlyUsage,
      locationUsage: locationUsage,
    );
  }

  static double? _sumAvailableLiters(List<WaterLoop> devices) {
    final values = devices
        .map((device) => device.totalLiters)
        .whereType<double>()
        .toList();
    if (values.isEmpty) return null;
    return values.fold<double>(0, (sum, value) => sum + value);
  }
}

class MonthlyUsage {
  const MonthlyUsage({required this.month, required this.liters, this.cost});

  final String month;
  final double liters;
  final double? cost;
}

class LocationUsage {
  const LocationUsage({required this.name, required this.liters, this.cost});

  final String name;
  final double? liters;
  final double? cost;
}

class DeviceAnalytics {
  const DeviceAnalytics({
    required this.name,
    required this.location,
    this.status,
    this.totalLiters,
    this.currentFlowRate,
  });

  final String name;
  final String location;
  final String? status;
  final double? totalLiters;
  final double? currentFlowRate;
}
