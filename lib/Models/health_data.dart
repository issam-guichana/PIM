class HealthData {
  final int steps;
  final double heartRate;
  final double caloriesBurned;

  HealthData({
    required this.steps,
    required this.heartRate,
    required this.caloriesBurned,
  });

  Map<String, dynamic> toJson() {
    return {
      'steps': steps,
      'heartRate': heartRate,
      'caloriesBurned': caloriesBurned,
    };
  }
}
