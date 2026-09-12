import 'package:finalproject/models/waterloop.dart';

enum LocationIconType { water, kitchen, garden, bathroom, floor }

class DeviceLocation {
  final String id;
  final String name;
  final LocationIconType iconType;
  final List<WaterLoop> devices;

  const DeviceLocation({
    required this.id,
    required this.name,
    this.iconType = LocationIconType.water,
    this.devices = const [],
  });

  DeviceLocation copyWith({
    String? name,
    LocationIconType? iconType,
    List<WaterLoop>? devices,
  }) {
    return DeviceLocation(
      id: id,
      name: name ?? this.name,
      iconType: iconType ?? this.iconType,
      devices: devices ?? this.devices,
    );
  }
}
