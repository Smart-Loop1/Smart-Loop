import 'package:finalproject/models/device_location.dart';
import 'package:finalproject/models/waterloop.dart';
import 'package:flutter/foundation.dart';

class AppDataController extends ChangeNotifier {
  final List<DeviceLocation> _locations = [];
  final List<WaterLoop> _ungroupedDevices = [];

  List<DeviceLocation> get locations => List.unmodifiable(_locations);
  List<WaterLoop> get ungroupedDevices => List.unmodifiable(_ungroupedDevices);

  void addLocation(DeviceLocation location) {
    _locations.add(location);
    notifyListeners();
  }

  void addDevice(WaterLoop device, {String? locationId}) {
    if (locationId == null) {
      _ungroupedDevices.add(device);
      notifyListeners();
      return;
    }

    final locationIndex = _locations.indexWhere(
      (location) => location.id == locationId,
    );
    if (locationIndex == -1) {
      _ungroupedDevices.add(device);
      notifyListeners();
      return;
    }

    final location = _locations[locationIndex];
    _locations[locationIndex] = location.copyWith(
      devices: [...location.devices, device],
    );
    notifyListeners();
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
    notifyListeners();
  }

  void deleteLocation(String id) {
    final index = _locations.indexWhere((location) => location.id == id);
    if (index == -1) return;

    _ungroupedDevices.addAll(_locations[index].devices);
    _locations.removeAt(index);
    notifyListeners();
  }

  void renameDevice(String id, String name) {
    final ungroupedIndex = _ungroupedDevices.indexWhere(
      (device) => device.id == id,
    );
    if (ungroupedIndex != -1) {
      _ungroupedDevices[ungroupedIndex] = _ungroupedDevices[ungroupedIndex]
          .copyWith(name: name);
      notifyListeners();
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
      notifyListeners();
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

    if (changed) notifyListeners();
  }
}
