import 'package:flutter/material.dart';
import 'package:pim_project/Controllers/health_controller.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HealthController()..fetchAndSendHealthData(),
      child: const HealthView(),
    );
  }
}

class HealthView extends StatelessWidget {
  const HealthView({super.key});

  @override
  Widget build(BuildContext context) {
    final healthController = Provider.of<HealthController>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Données HealthKit', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.purple,
        centerTitle: true,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHealthCard(healthController),
            const SizedBox(height: 20),
            Expanded(child: _buildChart(healthController)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => healthController.fetchAndSendHealthData(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Rafraîchir', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCard(HealthController controller) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHealthInfo('Pas', controller.healthData.steps.toString(), Icons.directions_walk),
            _buildHealthInfo('Fréquence cardiaque', '${controller.healthData.heartRate.toStringAsFixed(1)} bpm', Icons.favorite),
            _buildHealthInfo('Calories', '${controller.healthData.caloriesBurned.toStringAsFixed(1)} kcal', Icons.local_fire_department),
            _buildHealthInfo('Sommeil', '${controller.healthData.sleep.toStringAsFixed(1)} h', Icons.nightlight_round),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthInfo(String label, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.purple, size: 30),
      title: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildChart(HealthController controller) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.shade300,
            strokeWidth: 1,
          );
        }),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 500,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54),
                );
              },
              reservedSize: 40,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Transform.rotate(
                  angle: -0.4, // Rotation légère (~23°) pour éviter le chevauchement
                  child: Text(
                    _getLabel(value.toInt()),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
              reservedSize: 50, // Augmentation de l'espace sous les labels
            ),
          ),
        ),
        borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade400, width: 1)),
        lineBarsData: [
          _buildLineChartBarData([
            FlSpot(0, controller.healthData.steps.toDouble()),
            FlSpot(1, controller.healthData.heartRate.toDouble()),
            FlSpot(2, controller.healthData.caloriesBurned.toDouble()),
            FlSpot(3, controller.healthData.sleep.toDouble()),
          ], Colors.purple),
        ],
      ),
    );
  }

  LineChartBarData _buildLineChartBarData(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 5,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );
  }

  /// Fonction pour récupérer les labels en fonction de l'index
  String _getLabel(int index) {
    switch (index) {
      case 0: return "Pas";
      case 1: return "Fréquence";
      case 2: return "Calories";
      case 3: return "Sommeil";
      default: return "";
    }
  }
}
