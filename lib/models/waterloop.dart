class WaterLoop {
  final String id;
  final String name;
  final double? totalLiters;
  final double? currentFlowRate;

  const WaterLoop({
    required this.id,
    required this.name,
    this.totalLiters,
    this.currentFlowRate,
  });

  WaterLoop copyWith({String? name}) {
    return WaterLoop(
      id: id,
      name: name ?? this.name,
      totalLiters: totalLiters,
      currentFlowRate: currentFlowRate,
    );
  }
}
