class HealthData {
  final int steps;
  final double heartRate;
  final double caloriesBurned;
  final double sleep;  // Ajout de la donnée de sommeil

  HealthData({
    required this.steps,
    required this.heartRate,
    required this.caloriesBurned,
    required this.sleep,  // Initialisation du sommeil
  });

  Map<String, dynamic> toJson() {
    return {
      'steps': steps,
      'heartRate': heartRate,
      'caloriesBurned': caloriesBurned,
      'sleep': sleep,  // Ajout du sommeil dans les données JSON
    };
  }

 
}
