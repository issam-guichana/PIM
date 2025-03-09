import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pim_project/Models/health_data.dart';
import 'package:pim_project/services/health_service.dart';
import 'package:pim_project/services/websocket_service.dart';

class HealthController extends ChangeNotifier {
  final HealthService _healthService = HealthService();
  final SocketService _socketService = SocketService();

  HealthData _healthData = HealthData(
    steps: 0,
    heartRate: 0.0,
    caloriesBurned: 0.0,
    sleep: 0.0,
  );

  HealthData get healthData => _healthData;

  HealthController() {
    _socketService.connect();
    loadDataFromPreferences();
  }

  /// Charge les données depuis le stockage local (SharedPreferences)
  Future<void> loadDataFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _healthData = HealthData(
        steps: prefs.getInt('steps') ?? 0,
        heartRate: prefs.getDouble('heartRate') ?? 0.0,
        caloriesBurned: prefs.getDouble('caloriesBurned') ?? 0.0,
        sleep: prefs.getDouble('sleep') ?? 0.0,
      );
      notifyListeners();
      print("✅ Données chargées depuis SharedPreferences: $_healthData");
    } catch (e) {
      print('🔴 Erreur chargement SharedPreferences: $e');
    }
  }

  /// Sauvegarde les données dans SharedPreferences
  Future<void> saveDataToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('steps', _healthData.steps);
      await prefs.setDouble('heartRate', _healthData.heartRate);
      await prefs.setDouble('caloriesBurned', _healthData.caloriesBurned);
      await prefs.setDouble('sleep', _healthData.sleep);
      print("✅ Données sauvegardées dans SharedPreferences");
    } catch (e) {
      print('🔴 Erreur sauvegarde SharedPreferences: $e');
    }
  }

  /// Récupère les données de HealthKit et les envoie via WebSocket
  Future<void> fetchAndSendHealthData() async {
    try {
      final newHealthData = await _healthService.fetchHealthData();

      if (newHealthData.isEmpty) {
        print("⚠️ Aucune nouvelle donnée reçue de HealthKit");
        return;
      }

      _healthData = HealthData.fromMap(newHealthData);
      print("✅ Nouvelles données récupérées: $_healthData");

      _socketService.sendHealthData(_healthData.toJson());
      print("📡 Données envoyées via WebSocket");

      await saveDataToPreferences();
      notifyListeners();
    } catch (e) {
      print('🔴 Erreur lors de la récupération et l’envoi des données: $e');
    }
  }

  /// Ferme proprement la connexion WebSocket
  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }
}
