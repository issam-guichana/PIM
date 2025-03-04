import 'package:flutter/material.dart';
import 'package:pim_project/services/websocket_service.dart';
import '../models/health_data.dart';
import '../services/health_service.dart';

class HealthController extends ChangeNotifier {
  final HealthService _healthService = HealthService();
  final SocketService _socketService = SocketService();

  HealthData _healthData = HealthData(
    steps: 0,
    heartRate: 0.0,
    caloriesBurned: 0.0,
    sleep: 0.0,  // Sommeil en heures
  );  
  HealthData get healthData => _healthData;

  HealthController() {
    _socketService.connect();
    listenForHealthUpdates();
  }

  /// Récupérer les données de santé et les envoyer au serveur
  Future<void> fetchAndSendHealthData() async {
    try {
      Map<String, dynamic> healthData = await _healthService.fetchHealthData();

      if (healthData.isNotEmpty) {
        double sleepDuration = (healthData['sleep'] as num).toDouble() / 3600; // 💤 Convertir en heures

        _healthData = HealthData(
          steps: (healthData['steps'] as num).toInt(),
          heartRate: (healthData['heartRate'] as num).toDouble(),
          caloriesBurned: (healthData['caloriesBurned'] as num).toDouble(),
          sleep: sleepDuration,  // Utilisation de la valeur corrigée
        );

        print('🟢 Données récupérées : Pas: ${_healthData.steps}, Fréquence: ${_healthData.heartRate} bpm, '
            'Calories: ${_healthData.caloriesBurned} kcal, Sommeil: ${_healthData.sleep} h');

        _socketService.sendHealthData(_healthData.toJson());
        notifyListeners();
      }
    } catch (e) {
      print('🔴 Erreur lors de la récupération des données de santé : $e');
    }
  }

  /// Écoute des mises à jour de données via WebSocket
  void listenForHealthUpdates() {
    _socketService.listenForHealthUpdates((data) {
      try {
        int steps = (data['steps'] as num).toInt();
        double heartRate = (data['heartRate'] as num).toDouble();
        double caloriesBurned = (data['caloriesBurned'] as num).toDouble();
        double sleep = (data['sleep'] as num).toDouble() / 3600; // 💤 Convertir en heures

        // Vérification des valeurs aberrantes
        if (heartRate <= 0 || heartRate > 200) { 
          print("⚠️ Valeur de fréquence cardiaque invalide: $heartRate bpm");
          heartRate = _healthData.heartRate;
        }

        if (sleep < 0 || sleep > 24) { 
          print("⚠️ Durée de sommeil invalide: $sleep h");
          sleep = _healthData.sleep;
        }

        _healthData = HealthData(
          steps: steps,
          heartRate: heartRate,
          caloriesBurned: caloriesBurned,
          sleep: sleep,  
        );

        print('🔄 Mise à jour des données reçues : Pas: $steps, Fréquence: $heartRate bpm, '
            'Calories: $caloriesBurned kcal, Sommeil: $sleep h');

        notifyListeners();
      } catch (e) {
        print('🔴 Erreur lors de la mise à jour des données via WebSocket : $e');
      }
    });
  }
}
