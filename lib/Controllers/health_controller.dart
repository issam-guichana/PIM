import 'package:flutter/material.dart';
import 'package:pim_project/services/websocket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/health_data.dart';
import '../services/health_service.dart';

class HealthController extends ChangeNotifier {
  final HealthService _healthService = HealthService();
  final SocketService _socketService = SocketService();

  HealthData _healthData =
      HealthData(steps: 0, heartRate: 0.0, caloriesBurned: 0.0, sleep: 0.0);
  // Historique des dernières mesures (limité à 5)
  final List<HealthData> _healthHistory = [];

  HealthData get healthData => _healthData;
  List<HealthData> get healthHistory => _healthHistory;

  HealthController() {
    _socketService.connect();
    loadDataFromPreferences();
    fetchAndSendHealthData(); // Récupération initiale

    // Écoute des mises à jour en temps réel via WebSocket
    _socketService.listenForHealthUpdates((data) {
      print("[HealthController] Données en temps réel reçues: $data");
      // On met à jour le modèle avec les nouvelles données reçues
      _healthData = HealthData.fromMap(data);
      // On ajoute à l'historique et on limite à 5 mesures
      _healthHistory.add(_healthData);
      if (_healthHistory.length > 5) {
        _healthHistory.removeAt(0);
      }
      // Sauvegarder les données en local si besoin
      saveDataToPreferences();
      notifyListeners();
    });
  }

  Future<void> loadDataFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _healthData = HealthData(
        steps: prefs.getInt('steps') ?? 0,
        heartRate: prefs.getDouble('heartRate') ?? 0.0,
        caloriesBurned: prefs.getDouble('caloriesBurned') ?? 0.0,
        sleep: prefs.getDouble('sleep') ?? 0.0,
      );
      _healthHistory.add(_healthData);
      notifyListeners();
      print("[HealthController] Données chargées : $_healthData");
    } catch (e) {
      print('[HealthController] Erreur de chargement : $e');
    }
  }

  Future<void> saveDataToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('steps', _healthData.steps);
      await prefs.setDouble('heartRate', _healthData.heartRate);
      await prefs.setDouble('caloriesBurned', _healthData.caloriesBurned);
      await prefs.setDouble('sleep', _healthData.sleep);
      print("[HealthController] Données sauvegardées");
    } catch (e) {
      print('[HealthController] Erreur de sauvegarde : $e');
    }
  }

  Future<void> fetchAndSendHealthData() async {
    try {
      final newHealthDataMap = await _healthService.fetchHealthData();
      if (newHealthDataMap.isEmpty) {
        print("[HealthController] ⚠️ Aucune donnée reçue");
        return;
      }

      _healthData = HealthData.fromMap(newHealthDataMap);
      print("[HealthController] ✅ Nouvelles données : $_healthData");

      // Ajoute dans l'historique et limite à 5 mesures
      _healthHistory.add(_healthData);
      if (_healthHistory.length > 5) {
        _healthHistory.removeAt(0);
      }

      // Envoi des données via WebSocket
      _socketService.sendHealthData(_healthData.toJson());
      await saveDataToPreferences();
      notifyListeners();
    } catch (e) {
      print('[HealthController] 🔴 Erreur lors de la récupération : $e');
    }
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }
}
