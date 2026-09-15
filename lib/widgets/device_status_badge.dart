import 'package:finalproject/core/constants/app_colors.dart';
import 'package:finalproject/extensions/water_loop_extensions.dart';
import 'package:finalproject/models/waterloop.dart';
import 'package:flutter/material.dart';

class DeviceStatusBadge extends StatelessWidget {
  const DeviceStatusBadge({
    required this.device,
    this.compact = false,
    super.key,
  });

  final WaterLoop device;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isOnline = device.isOnline;
    final color = isOnline ? AppColors.deviceOnline : AppColors.deviceOffline;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 7 : 8,
            height: compact ? 7 : 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: compact ? 5 : 6),
          Text(
            device.connectionLabel,
            style: TextStyle(
              color: color,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
