class FitData {
  final int steps;
  final double heartRate;
  final double calories;
  final double sleepHours;

  FitData({
    required this.steps,
    required this.heartRate,
    required this.calories,
    required this.sleepHours,
  });

  factory FitData.fromJson(Map<String, dynamic> json) {
    return FitData(
      steps: json['steps'] ?? 0,
      heartRate: (json['heartRate'] ?? 0).toDouble(),
      calories: (json['calories'] ?? 0).toDouble(),
      sleepHours: (json['sleep'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'steps': steps,
      'heartRate': heartRate,
      'calories': calories,
      'sleep': sleepHours,
    };
  }
}
