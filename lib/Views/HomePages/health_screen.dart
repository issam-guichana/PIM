import 'package:flutter/material.dart';
import 'package:pim_project/Controllers/health_controller.dart';
import 'package:pim_project/Models/health_data.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'health_history.dart'; // Ajout de l'import pour l'écran HealthHistoryScreen

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HealthController()..fetchAndSendHealthData(),
      child: const HealthView(),
    );
  }
}

class HealthView extends StatelessWidget {
  const HealthView({super.key});

  @override
  Widget build(BuildContext context) {
    final healthCtrl = Provider.of<HealthController>(context);
    final data = healthCtrl.healthData;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(healthCtrl, context), // Passage du contexte à _buildAppBar
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHealthCard(data),
            const SizedBox(height: 20),
            _buildNormalizedBarChart(data),
            const SizedBox(height: 20),
            _buildRefreshButton(healthCtrl),
          ],
        ),
      ),
    );
  }

  // Ajout du contexte pour la navigation
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
        // Bouton pour naviguer vers l'historique des données de santé
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: () {
            // Navigation vers l'écran d'historique
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HealthHistoryScreen()),
            );
          },
        ),
      ],
    );
  }

  /// Carte affichant les statistiques.
  Widget _buildHealthCard(HealthData data) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Statistiques de santé',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              // Ajustez childAspectRatio pour éviter l'overflow
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                // Diminuez cette valeur pour donner plus de hauteur
                childAspectRatio: 2.0,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              children: [
                _buildMetricItem(Icons.directions_walk, 'Pas', data.steps.toString(), Colors.purple),
                _buildMetricItem(Icons.favorite, 'Fréquence', '${data.heartRate.toStringAsFixed(0)} bpm', Colors.red),
                _buildMetricItem(Icons.local_fire_department, 'Calories', '${data.caloriesBurned.toStringAsFixed(0)} kcal', Colors.orange),
                _buildMetricItem(Icons.nightlight_round, 'Sommeil', '${data.sleep.toStringAsFixed(1)} h', Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Réduisez légèrement la taille de la police si besoin
                Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Graphique en barres comparant les valeurs normalisées.
  Widget _buildNormalizedBarChart(HealthData data) {
    final normalizedData = _normalizeData(data);

    return Container(
      padding: const EdgeInsets.all(15),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comparaison normalisée des données',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 250, // Augmenter la hauteur pour plus de lisibilité
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.center,
                minY: 0,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        );
                      },
                      interval: 20,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text(
                        _getLabel(value.toInt()),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      interval: 1, // Espacement entre les titres
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                barGroups: _buildNormalizedBarGroups(normalizedData),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _normalizeData(HealthData data) {
    return {
      'steps': (data.steps / 10000 * 100).clamp(0.0, 100),
      'heartRate': (data.heartRate / 200 * 100).clamp(0.0, 100),
      'calories': (data.caloriesBurned / 500 * 100).clamp(0.0, 100),
      'sleep': (data.sleep / 24 * 100).clamp(0.0, 100),
    };
  }

  List<BarChartGroupData> _buildNormalizedBarGroups(Map<String, double> normalizedData) {
    final colors = [Colors.purple, Colors.red, Colors.orange, Colors.blue];

    return List.generate(4, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: normalizedData[_getDataKey(index)]!,
            color: colors[index],
            width: 25,
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      );
    });
  }

  String _getDataKey(int index) {
    return ['steps', 'heartRate', 'calories', 'sleep'][index];
  }

  String _getLabel(int index) {
    return ['Pas', 'FC', 'Calories', 'Sommeil'][index];
  }

  /// Bouton rafraîchir centré.
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}

