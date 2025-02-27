import 'package:pim_project/services/websocket_service.dart';
import '../models/health_data.dart';
import '../services/health_service.dart';

class HealthController {
  final HealthService _healthService = HealthService();
  final SocketService _socketService = SocketService();

  HealthController() {
    _socketService.connect(); // Connexion au WebSocket dès le démarrage
  }

  Future<void> fetchAndSendHealthData() async {
    Map<String, dynamic> healthData = await _healthService.fetchHealthData();

    if (healthData.isNotEmpty) {
      HealthData data = HealthData(
        steps: (healthData['steps'] as num).toInt(),
        heartRate: (healthData['heartRate'] as num).toDouble(),
        caloriesBurned: (healthData['caloriesBurned'] as num).toDouble(),
      );

      _socketService.sendHealthData(data.toJson());
    }
  }

  void listenForHealthUpdates(Function(Map<String, dynamic>) callback) {
    _socketService.listenForHealthUpdates(callback);
  }
}
