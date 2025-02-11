class HealthData {
  final int heartRate;
  final int steps;
  final int calories;

  HealthData({required this.heartRate, required this.steps, required this.calories});

  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(
      heartRate: json["heartRate"],
      steps: json["steps"],
      calories: json["calories"],
    );
  }
}
