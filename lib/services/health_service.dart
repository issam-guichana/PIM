import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pim_project/Models/health_data.dart';

class HealthService {
  static const MethodChannel _channel = MethodChannel('healthkit_channel');

  // Fonction pour récupérer les données de santé
  Future<Map<String, dynamic>> fetchHealthData() async {
    try {
      // Appel au code natif pour récupérer les données HealthKit
      final data = await _channel.invokeMethod<Map<dynamic, dynamic>>('getHealthData');

      // Retourner les données en map et s'assurer que toutes les clés et valeurs sont des strings
      return data?.map((key, value) => MapEntry(key.toString(), value)) ?? {};
    } catch (e) {
      // En cas d'erreur, on retourne un message d'erreur vide
      print("Erreur récupération HealthKit: $e");
      return {};
    }
  }
  final String _baseUrl = 'http://192.168.43.73:3000/health';

  /// Récupère l'historique des données de santé depuis le backend
  Future<void> fetchHealthHistory(String userId, int days) async {
  final String url = '$_baseUrl/history/$userId/$days';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Réponse API : $data'); // 👀 Ajoute ce log pour voir la réponse

      // Vérifie que les valeurs ne sont pas null avant la conversion
      final steps = (data['steps'] ?? 0) as int;
      final heartRate = (data['heartRate'] ?? 0.0) as double;
      final caloriesBurned = (data['caloriesBurned'] ?? 0.0) as double;
      final sleep = (data['sleep'] ?? 0.0) as double;

      print('✅ Données formatées : $steps, $heartRate, $caloriesBurned, $sleep');

    } else {
      print('⚠️ Erreur lors de la récupération de l\'historique : ${response.statusCode}');
    }
  } catch (e) {
    print('🔴 Erreur de connexion ou parsing JSON : $e');
  }
}
}

