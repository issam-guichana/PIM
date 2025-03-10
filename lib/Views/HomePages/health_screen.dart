import 'package:flutter/material.dart';
import 'package:pim_project/Controllers/health_controller.dart';
import 'package:pim_project/Views/HomePages/health_history.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

enum Metric {
  steps,
  heartRate,
  sleep,
  calories,
}

class HealthScreen extends StatelessWidget {
  const HealthScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HealthController(),
      child: const HealthView(),
    );
  }
}

class HealthView extends StatefulWidget {
  const HealthView({Key? key}) : super(key: key);
  
  @override
  State<HealthView> createState() => _HealthViewState();
}

class _HealthViewState extends State<HealthView> {
  Metric _selectedMetric = Metric.steps;

  @override
  Widget build(BuildContext context) {
    final healthCtrl = Provider.of<HealthController>(context);
    final data = healthCtrl.healthData;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(healthCtrl, context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHealthCard(data),
            const SizedBox(height: 30),
            _buildMetricButtons(),
            const SizedBox(height: 30),
            _buildChartTitle(),
            const SizedBox(height: 10),
            _buildBarChart(healthCtrl), // <-- Bar chart au lieu d'un line chart
            const SizedBox(height: 30),
            _buildRefreshButton(healthCtrl),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(HealthController healthCtrl, BuildContext context) {
    return AppBar(
      title: const Text(
        'Données HealthKit',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.purple,
      centerTitle: true,
      elevation: 5,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => healthCtrl.fetchAndSendHealthData(),
        ),
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  HealthHistoryScreen()),
            );
          },
        ),
      ],
    );
  }

  /// Carte affichant les données de santé
  Widget _buildHealthCard(dynamic data) {
    return Center(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              const Text(
                'Statistiques de santé',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              // Grille des indicateurs
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.0,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildMetricItem(
                    Icons.directions_walk,
                    'Pas',
                    data.steps.toString(),
                    Colors.purple,
                  ),
                  _buildMetricItem(
                    Icons.favorite,
                    'Fréquence',
                    '${data.heartRate.toStringAsFixed(0)} bpm',
                    Colors.red,
                  ),
                  _buildMetricItem(
                    Icons.local_fire_department,
                    'Calories',
                    '${data.caloriesBurned.toStringAsFixed(0)} kcal',
                    Colors.orange,
                  ),
                  _buildMetricItem(
                    Icons.nightlight_round,
                    'Sommeil',
                    '${data.sleep.toStringAsFixed(1)} h',
                    Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget pour un indicateur (icône, label, valeur)
  Widget _buildMetricItem(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Rangée de boutons pour sélectionner la métrique
  Widget _buildMetricButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildMetricButton("Pas", Metric.steps, Colors.purple),
        _buildMetricButton("Fréquence", Metric.heartRate, Colors.red),
        _buildMetricButton("Sommeil", Metric.sleep, Colors.blue),
        _buildMetricButton("Calories", Metric.calories, Colors.orange),
      ],
    );
  }

  Widget _buildMetricButton(String label, Metric metric, Color color) {
    final bool isSelected = _selectedMetric == metric;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.grey[400],
        foregroundColor: isSelected ? Colors.white : Colors.black,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () => setState(() => _selectedMetric = metric),
      child: Text(label),
    );
  }

  /// Titre dynamique du graphique
  Widget _buildChartTitle() {
    String title;
    switch (_selectedMetric) {
      case Metric.steps:
        title = "Évolution des pas";
        break;
      case Metric.heartRate:
        title = "Évolution de la fréquence cardiaque";
        break;
      case Metric.sleep:
        title = "Évolution du sommeil";
        break;
      case Metric.calories:
        title = "Évolution des calories brûlées";
        break;
    }
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  /// Affiche un bar chart au lieu d'un line chart
  Widget _buildBarChart(HealthController healthCtrl) {
    final history = healthCtrl.healthHistory;
    if (history.isEmpty) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: const Text(
          "Aucune donnée pour afficher le graphique",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    // Préparation des BarChartGroupData
    final List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < history.length; i++) {
      double value;
      switch (_selectedMetric) {
        case Metric.steps:
          value = history[i].steps.toDouble();
          break;
        case Metric.heartRate:
          value = history[i].heartRate;
          break;
        case Metric.sleep:
          value = history[i].sleep;
          break;
        case Metric.calories:
          value = history[i].caloriesBurned;
          break;
      }

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              color: _getColorForMetric(_selectedMetric),
              width: 18,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: _getMaxY(),
          barGroups: barGroups,
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) => Text('J${value.toInt() + 1}'),
              ),
            ),
          ),
          barTouchData: BarTouchData(enabled: true),
        ),
      ),
    );
  }

  /// Renvoie la couleur selon la métrique
  Color _getColorForMetric(Metric metric) {
    switch (metric) {
      case Metric.steps:
        return Colors.purple;
      case Metric.heartRate:
        return Colors.red;
      case Metric.sleep:
        return Colors.blue;
      case Metric.calories:
        return Colors.orange;
    }
  }

  /// Limite max de l'axe Y
  double _getMaxY() {
    switch (_selectedMetric) {
      case Metric.steps:
        return 10000;
      case Metric.heartRate:
        return 120;
      case Metric.sleep:
        return 10;
      case Metric.calories:
        return 250;
    }
  }

  /// Bouton de rafraîchissement
  Widget _buildRefreshButton(HealthController healthCtrl) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => healthCtrl.fetchAndSendHealthData(),
        icon: const Icon(Icons.refresh),
        label: const Text(
          'Rafraîchir',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
      ),
    );
  }
}
