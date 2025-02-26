import 'package:flutter/material.dart';
import 'package:pim_project/Controllers/health_controller.dart';


class HealthScreen extends StatefulWidget {
  @override
  _HealthScreenState createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final HealthController _healthController = HealthController();
  int steps = 0;
  double heartRate = 0;
  double calories = 0;

  Future<void> fetchData() async {
    await _healthController.fetchAndSendHealthData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Données HealthKit")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Pas : $steps"),
            Text("Fréquence cardiaque : $heartRate bpm"),
            Text("Calories : $calories kcal"),
            ElevatedButton(
              onPressed: fetchData,
              child: Text("Rafraîchir"),
            ),
          ],
        ),
      ),
    );
  }
}
