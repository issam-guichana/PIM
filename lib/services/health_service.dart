import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pim_project/Models/health_data.dart';

class HealthService {
  static const MethodChannel _channel = MethodChannel('healthkit_channel');
  final String _baseUrl = 'http://192.168.1.124:3000/health';

  /// Récupère les données de santé depuis HealthKit (iOS)
  Future<Map<String, dynamic>> fetchHealthData() async {
    try {
      final data = await _channel.invokeMethod<Map<dynamic, dynamic>>('getHealthData');

      if (data == null) {
        print("⚠️ Aucune donnée reçue de HealthKit");
        return {};
      }

      // ✅ Conversion correcte en `Map<String, dynamic>`
      final parsedData = data.map<String, dynamic>((key, value) => MapEntry(key.toString(), value));

      print("✅ Données reçues de HealthKit: $parsedData");
      return parsedData;
    } catch (e) {
      print("🔴 Erreur lors de la récupération des données HealthKit: $e");
      return {};
    }
  }

  /// Récupère l'historique des données de santé depuis le backend
  Future<List<HealthData>> fetchHealthHistory(String userId, int days) async {
    final String url = '$_baseUrl/history/$userId/$days';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('✅ API Response: $data');
        return data.map((item) => HealthData.fromJson(item)).toList();
      } else {
        print('⚠️ Erreur récupération historique: ${response.statusCode}');
        throw Exception('Échec de la récupération de l’historique');
      }
    } catch (e) {
      print('🔴 Erreur de connexion ou parsing JSON: $e');
      throw Exception('Erreur de connexion au serveur');
    }
  }
}

