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
    } catch (e) {
      print('Error loading data from SharedPreferences: $e');
    }
  }

  Future<void> saveDataToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('steps', _healthData.steps);
      await prefs.setDouble('heartRate', _healthData.heartRate);
      await prefs.setDouble('caloriesBurned', _healthData.caloriesBurned);
      await prefs.setDouble('sleep', _healthData.sleep);
    } catch (e) {
      print('Error saving data to SharedPreferences: $e');
    }
  }

  Future<void> fetchAndSendHealthData() async {
    try {
      final newHealthData = await _healthService.fetchHealthData();
      _healthData = HealthData.fromMap(newHealthData);
      _socketService.sendHealthData(_healthData.toJson());
      saveDataToPreferences();
      notifyListeners();
    } catch (e) {
      print('Error fetching and sending health data: $e');
    }
  }
}
