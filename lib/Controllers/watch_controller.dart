import 'dart:math';

class WatchController {
  Future<Map<String, dynamic>> getSimulatedHealthData() async {
    await Future.delayed(const Duration(seconds: 1)); // Simule un délai de récupération

    return {
      "heartRate": Random().nextInt(40) + 60, // Entre 60 et 100 bpm
      "steps": Random().nextInt(5000) + 1000, // Entre 1000 et 6000 pas
      "calories": Random().nextInt(300) + 100, // Entre 100 et 400 kcal
      "sleep": (Random().nextDouble() * 5 + 3).toStringAsFixed(1), // Entre 3h et 8h
    };
  }
}
