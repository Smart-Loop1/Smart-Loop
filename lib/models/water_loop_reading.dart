class WaterLoopReading {
  const WaterLoopReading({
    required this.deviceId,
    required this.totalLiters,
    required this.currentFlowRate,
    required this.status,
    this.lastSeen,
  });

  final String deviceId;
  final double totalLiters;
  final double currentFlowRate;
  final String status;
  final DateTime? lastSeen;

  factory WaterLoopReading.fromMap(
    String deviceId,
    Map<Object?, Object?> data,
  ) {
    final lastSeenMilliseconds = (data['lastSeen'] as num?)?.toInt();
    final lastSeen = lastSeenMilliseconds == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(lastSeenMilliseconds);
    final rawStatus = data['status'] as String? ?? 'offline';
    final isFresh =
        lastSeen != null &&
        DateTime.now().difference(lastSeen) <= const Duration(seconds: 8);

    return WaterLoopReading(
      deviceId: deviceId,
      totalLiters: (data['totalLiters'] as num?)?.toDouble() ?? 0,
      currentFlowRate: (data['currentFlowRate'] as num?)?.toDouble() ?? 0,
      status: rawStatus == 'online' && isFresh ? 'online' : 'offline',
      lastSeen: lastSeen,
    );
  }
}
