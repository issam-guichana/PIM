import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/health_data.dart';
import '../services/health_service.dart';

class HealthController {
  final HealthService _healthService = HealthService();

  Future<void> fetchAndSendHealthData() async {
    Map<String, dynamic> healthData = await _healthService.fetchHealthData();

    if (healthData.isNotEmpty) {
      HealthData data = HealthData(
        steps: (healthData['steps'] as num).toInt(),  // Ensuring steps are int
        heartRate: (healthData['heartRate'] as num).toDouble(), // Safely casting to double
        caloriesBurned: (healthData['caloriesBurned'] as num).toDouble(), // Safely casting to double
      );

      await sendDataToServer(data);
    }
  }

  Future<void> sendDataToServer(HealthData data) async {
    final String apiUrl = "http://192.168.137.51:3000/health";

    // Convert the health data to query parameters (URL encoding)
    final String queryString = Uri(queryParameters: {
      'steps': data.steps.toString(),
      'heartRate': data.heartRate.toString(),
      'caloriesBurned': data.caloriesBurned.toString(),
    }).query;

    // Append query parameters to the URL
    final String finalUrl = "$apiUrl?$queryString";

    final response = await http.get(
      Uri.parse(finalUrl),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      print("Données envoyées avec succès !");
    } else {
      print("Erreur d'envoi : ${response.body}");
    }
  }
}
