import 'package:flutter/services.dart';

class HealthService {
  static const MethodChannel _channel = MethodChannel('healthkit_channel');

  Future<Map<String, dynamic>> fetchHealthData() async {
    try {
      final data = await _channel.invokeMethod<Map<dynamic, dynamic>>('getHealthData');
      return data?.map((key, value) => MapEntry(key.toString(), value)) ?? {};
    } catch (e) {
      print("Erreur récupération HealthKit: $e");
      return {};
    }
  }
}
