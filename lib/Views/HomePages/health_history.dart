import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pim_project/Models/health_data.dart';

class HealthHistoryScreen extends StatefulWidget {
  @override
  _HealthHistoryScreenState createState() => _HealthHistoryScreenState();
}

class _HealthHistoryScreenState extends State<HealthHistoryScreen> {
  List<HealthData> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHealthHistory();
  }

  // Load the health history from SharedPreferences
  Future<void> _loadHealthHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> healthHistory = prefs.getStringList('healthHistory') ?? [];
    List<HealthData> historyList = [];

    for (var item in healthHistory) {
      try {
        final data = item.split(',');
        if (data.length == 5) { // Include the date as the first item in the saved data
          historyList.add(HealthData(
            steps: int.parse(data[1]),
            heartRate: double.parse(data[2]),
            caloriesBurned: double.parse(data[3]),
            sleep: double.parse(data[4]),
          ));
        }
      } catch (e) {
        print('Error parsing health data: $e');
      }
    }

    setState(() {
      _history = historyList;
    });
  }

  // Save the current health data to SharedPreferences
  Future<void> _saveHealthHistory(HealthData data) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> healthHistory = prefs.getStringList('healthHistory') ?? [];
    String currentDate = DateTime.now().toIso8601String();

    healthHistory.add(
      '$currentDate,${data.steps},${data.heartRate},${data.caloriesBurned},${data.sleep}',
    );

    await prefs.setStringList('healthHistory', healthHistory);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique des Données de Santé'),
      ),
      body: ListView.builder(
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final data = _history[index];
          final date = DateTime.now().subtract(Duration(days: index)).toIso8601String();
          return ListTile(
            title: Text('Date: $date'),
            subtitle: Text('Pas: ${data.steps}, Fréquence: ${data.heartRate} bpm, '
                'Calories: ${data.caloriesBurned} kcal, Sommeil: ${data.sleep} h'),
            leading: Icon(Icons.history),
          );
        },
      ),
    );
  }
}
