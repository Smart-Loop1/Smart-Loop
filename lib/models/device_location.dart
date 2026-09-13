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

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'iconType': iconType.name,
      'devices': devices.map((device) => device.toJson()).toList(),
    };
  }

  factory DeviceLocation.fromJson(Map<String, dynamic> json) {
    final iconName = json['iconType'] as String?;

    return DeviceLocation(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Location',
      iconType: LocationIconType.values.firstWhere(
        (icon) => icon.name == iconName,
        orElse: () => LocationIconType.water,
      ),
      devices: [
        for (final device in json['devices'] as List<dynamic>? ?? const [])
          if (device is Map<Object?, Object?>)
            WaterLoop.fromJson(Map<String, dynamic>.from(device)),
      ],
    );
  }
}
