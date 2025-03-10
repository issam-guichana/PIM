class HealthData {
  final int steps;
  final double heartRate;
  final double caloriesBurned;
  final double sleep; // durée de sommeil en heures

  HealthData({
    required this.steps,
    required this.heartRate,
    required this.caloriesBurned,
    required this.sleep,
  });

  Map<String, dynamic> toJson() {
    return {
      'steps': steps,
      'heartRate': heartRate,
      'caloriesBurned': caloriesBurned,
      'sleep': sleep,
    };
  }

  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(
      steps: (json['steps'] as num?)?.toInt() ?? 0,
      heartRate: (json['heartRate'] as num?)?.toDouble() ?? 0.0,
      caloriesBurned: (json['calories'] as num?)?.toDouble() ?? 0.0, // Attention à la clé ici
      sleep: (json['sleep'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static HealthData fromMap(Map<String, dynamic> map) {
    return HealthData(
      steps: (map['steps'] as num?)?.toInt() ?? 0,
      heartRate: (map['heartRate'] as num?)?.toDouble() ?? 0.0,
      caloriesBurned: (map['calories'] as num?)?.toDouble() ?? 0.0, // Modification ici
      sleep: (map['sleep'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'Steps: $steps, HeartRate: $heartRate, Calories: $caloriesBurned, Sleep: $sleep';
  }
}
