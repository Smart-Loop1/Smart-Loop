import 'package:finalproject/models/device_location.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

extension LocationIconTypeUi on LocationIconType {
  Widget iconWidget({double? size, Color? color}) {
    return switch (this) {
      LocationIconType.water => Icon(
        Icons.water_drop_rounded,
        size: size,
        color: color,
      ),
      LocationIconType.kitchen => Icon(
        Icons.kitchen_rounded,
        size: size,
        color: color,
      ),
      LocationIconType.garden => Icon(
        Icons.yard_rounded,
        size: size,
        color: color,
      ),
      LocationIconType.bathroom => FaIcon(
        FontAwesomeIcons.toilet,
        size: size,
        color: color,
      ),
      LocationIconType.floor => Icon(
        Icons.apartment_rounded,
        size: size,
        color: color,
      ),
    };
  }

  String get label {
    return switch (this) {
      LocationIconType.water => 'Water',
      LocationIconType.kitchen => 'Kitchen',
      LocationIconType.garden => 'Garden',
      LocationIconType.bathroom => 'Bathroom',
      LocationIconType.floor => 'Floor',
    };
  }
}
