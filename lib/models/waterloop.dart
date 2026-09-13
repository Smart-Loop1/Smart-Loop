class WaterLoop {
  final String id;
  final String name;
  final double? totalLiters;
  final double? currentFlowRate;
  final String? status;
  final DateTime? lastSeen;

  const WaterLoop({
    required this.id,
    required this.name,
    this.totalLiters,
    this.currentFlowRate,
    this.status,
    this.lastSeen,
  });

  WaterLoop copyWith({
    String? name,
    double? totalLiters,
    double? currentFlowRate,
    String? status,
    DateTime? lastSeen,
  }) {
    return WaterLoop(
      id: id,
      name: name ?? this.name,
      totalLiters: totalLiters ?? this.totalLiters,
      currentFlowRate: currentFlowRate ?? this.currentFlowRate,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'totalLiters': totalLiters,
      'currentFlowRate': currentFlowRate,
      'status': status,
      'lastSeen': lastSeen?.millisecondsSinceEpoch,
    };
  }

  factory WaterLoop.fromJson(Map<String, dynamic> json) {
    final lastSeenMilliseconds = (json['lastSeen'] as num?)?.toInt();

    return WaterLoop(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Water Device',
      totalLiters: (json['totalLiters'] as num?)?.toDouble(),
      currentFlowRate: (json['currentFlowRate'] as num?)?.toDouble(),
      status: json['status'] as String?,
      lastSeen: lastSeenMilliseconds == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastSeenMilliseconds),
    );
  }
}
