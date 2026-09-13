import 'dart:async';
import 'dart:convert';

import 'package:finalproject/models/water_loop_reading.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class FirebaseWaterService {
  FirebaseWaterService({
    required this.databaseUrl,
    http.Client? client,
    this.pollInterval = const Duration(seconds: 1),
  }) : _client = client ?? http.Client();

  final String databaseUrl;
  final Duration pollInterval;
  final http.Client _client;

  Stream<Map<String, WaterLoopReading>> watchDevices() async* {
    while (true) {
      try {
        yield await _readDevices();
      } catch (error) {
        debugPrint('Could not poll Smart Loop readings: $error');
      }
      await Future<void>.delayed(pollInterval);
    }
  }

  Future<Map<String, WaterLoopReading>> _readDevices() async {
    final response = await _client.get(
      Uri.parse('${databaseUrl.replaceFirst(RegExp(r'/+$'), '')}/devices.json'),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Firebase returned HTTP ${response.statusCode}.');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return const {};

    return {
      for (final entry in decoded.entries)
        if (entry.value is Map<Object?, Object?>)
          entry.key: WaterLoopReading.fromMap(
            entry.key,
            entry.value as Map<Object?, Object?>,
          ),
    };
  }
}
