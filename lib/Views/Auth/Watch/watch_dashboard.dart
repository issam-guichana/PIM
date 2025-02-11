import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HealthDataScreen extends StatelessWidget {
  const HealthDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Health Data", style: TextStyle(color: Colors.purple.shade700)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.purple.shade700),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHealthCard("Sleep", "7h 45m", Icons.bedtime, Colors.blue),
            _buildHealthCard("Heart Rate", "78 bpm", Icons.favorite, Colors.red),
            _buildHealthCard("Steps", "10,254", Icons.directions_walk, Colors.green),
            _buildHealthCard("Calories", "2,150 kcal", Icons.local_fire_department, Colors.orange),
            const SizedBox(height: 20),
            Expanded(child: _buildLineChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCard(String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: TextStyle(fontSize: 16, color: Colors.purple.shade700)),
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              const FlSpot(0, 2),
              const FlSpot(1, 2.5),
              const FlSpot(2, 3),
              const FlSpot(3, 3.5),
              const FlSpot(4, 4),
              const FlSpot(5, 3.8),
              const FlSpot(6, 3.5),
            ],
            isCurved: true,
            color: const Color.fromARGB(255, 167, 42, 189),
            barWidth: 4,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}
