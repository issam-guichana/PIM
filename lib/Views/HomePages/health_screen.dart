import 'package:flutter/material.dart';
import 'package:pim_project/Controllers/health_controller.dart';


class HealthScreen extends StatefulWidget {
  @override
  _HealthScreenState createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final HealthController _healthController = HealthController();
  Map<String, dynamic> healthData = {
    'steps': 0,
    'heartRate': 0.0,
    'caloriesBurned': 0.0
  };

  @override
  void initState() {
    super.initState();
    _healthController.listenForHealthUpdates((data) {
      setState(() {
        healthData = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Santé')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("👣 Pas : ${healthData['steps']}", style: TextStyle(fontSize: 20)),
            Text("❤️ Fréquence cardiaque : ${healthData['heartRate']} bpm",
                style: TextStyle(fontSize: 20)),
            Text("🔥 Calories brûlées : ${healthData['caloriesBurned']} kcal",
                style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _healthController.fetchAndSendHealthData();
              },
              child: Text("📥 Récupérer et envoyer les données"),
            ),
          ],
        ),
      ),
    );
  }
}
