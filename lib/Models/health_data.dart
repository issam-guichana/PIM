class HealthData {
  final int steps;
  final double heartRate;
  final double caloriesBurned;
  final double sleep; // Sleep duration in hours

  HealthData({
    required this.steps,
    required this.heartRate,
    required this.caloriesBurned,
    required this.sleep,
  });

  // Converts the HealthData instance into a Map object that mirrors the JSON structure.
  Map<String, dynamic> toJson() {
    return {
      'steps': steps,
      'heartRate': heartRate,
      'caloriesBurned': caloriesBurned,
      'sleep': sleep, // Convert to seconds if necessary for the API
    };
  }

 factory HealthData.fromJson(Map<String, dynamic> json) {
  return HealthData(
    steps: (json['steps'] as num?)?.toInt() ?? 0, // Conversion explicite pour steps
    heartRate: (json['heartRate'] as num?)?.toDouble() ?? 0.0,
    caloriesBurned: (json['caloriesBurned'] as num?)?.toDouble() ?? 0.0,
    sleep: (json['sleep'] as num?)?.toDouble() ?? 0.0,
  );
}

static HealthData fromMap(Map<String, dynamic> map) {
  return HealthData(
    steps: (map['steps'] as num?)?.toInt() ?? 0, // Conversion explicite pour steps
    heartRate: (map['heartRate'] as num?)?.toDouble() ?? 0.0,
    caloriesBurned: (map['caloriesBurned'] as num?)?.toDouble() ?? 0.0,
    sleep: (map['sleep'] as num?)?.toDouble() ?? 0.0,
  );
}
}