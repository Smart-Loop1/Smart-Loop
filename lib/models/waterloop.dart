class WaterLoop {
  String id;
  String name;
  double totalLiters;
  double currentFlowRate;

  WaterLoop({
    required this.id,
    required this.name,
    this.totalLiters = 0.0,
    this.currentFlowRate = 0.0,
  });

  double get estimatedCost => (totalLiters * 0.001) + 5;
}